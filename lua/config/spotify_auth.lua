-- Spotify user OAuth via Authorization Code + PKCE (no client secret).
-- One-time browser login; tokens cached on disk and silently refreshed.
-- Reuses SPOTIFY_CLIENT_ID from the environment. Add this redirect URI to your
-- Spotify app: http://127.0.0.1:8888/callback
-- See SPOTIFY.md §4.

local M = {}

local REDIRECT_PORT = 8888
local REDIRECT_URI = "http://127.0.0.1:" .. REDIRECT_PORT .. "/callback"
local SCOPES = table.concat({
  "playlist-read-private",
  "playlist-read-collaborative",
  "user-library-read",
  "user-library-modify",
  "user-read-recently-played",
  "user-read-playback-state",
}, " ")
local AUTHORIZE_URL = "https://accounts.spotify.com/authorize"
local TOKEN_URL = "https://accounts.spotify.com/api/token"
local TOKEN_FILE = vim.fn.stdpath("data") .. "/spotify_nvim_token.json"
local AUTH_TIMEOUT_MS = 120000

local function client_id()
  return os.getenv("SPOTIFY_CLIENT_ID")
end

-- ── Token storage ────────────────────────────────────────────────────────────

local function load_tokens()
  local f = io.open(TOKEN_FILE, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  return (ok and type(data) == "table") and data or nil
end

local function save_tokens(data)
  local f = io.open(TOKEN_FILE, "w")
  if not f then
    return
  end
  f:write(vim.json.encode(data))
  f:close()
  pcall((vim.uv or vim.loop).fs_chmod, TOKEN_FILE, tonumber("600", 8))
end

-- ── PKCE helpers (shell out to openssl for raw-byte SHA256 + base64url) ───────

local function url_encode(s)
  return (s:gsub("[^%w%-._~]", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

local function gen_verifier()
  local out = vim.fn.system({ "openssl", "rand", "-base64", "96" })
  out = out:gsub("%s", ""):gsub("%+", "-"):gsub("/", "_"):gsub("=", "")
  return out:sub(1, 110) -- spec allows 43–128 chars
end

local function challenge(verifier)
  -- base64url(sha256(verifier)). verifier is base64url charset, so safe to quote.
  local cmd = "printf '%s' '" .. verifier .. "' | openssl dgst -sha256 -binary | openssl base64 | tr '+/' '-_' | tr -d '='"
  return vim.trim(vim.fn.system(cmd))
end

local function gen_state()
  return vim.trim(vim.fn.system({ "openssl", "rand", "-hex", "16" }))
end

-- Guards against a second browser flow starting while one is already in flight.
local authorizing = false

-- ── Loopback callback server ─────────────────────────────────────────────────

-- Listens once on the redirect port; calls done(code, err, state) for the first
-- /callback request, then tears itself (and its timeout) down.
local function start_server(done)
  local uv = vim.uv or vim.loop
  local server = uv.new_tcp()

  local ok, err = pcall(function()
    server:bind("127.0.0.1", REDIRECT_PORT)
  end)
  if not ok then
    pcall(function()
      server:close()
    end)
    done(nil, "port " .. REDIRECT_PORT .. " unavailable (" .. tostring(err) .. ")")
    return
  end

  local finished = false
  local timeout = uv.new_timer()
  local function finish(code, ferr, state)
    if finished then
      return
    end
    finished = true
    timeout:stop()
    if not timeout:is_closing() then
      timeout:close()
    end
    if not server:is_closing() then
      server:close()
    end
    vim.schedule(function()
      done(code, ferr, state)
    end)
  end

  timeout:start(AUTH_TIMEOUT_MS, 0, function()
    finish(nil, "authorization timed out")
  end)

  server:listen(128, function(listen_err)
    if listen_err then
      return finish(nil, "listen failed: " .. listen_err)
    end
    local client = uv.new_tcp()
    server:accept(client)
    local buffer = ""
    client:read_start(function(read_err, chunk)
      if read_err then
        return client:close()
      end
      if not chunk then
        return client:close()
      end
      buffer = buffer .. chunk
      local path = buffer:match("^GET%s+(%S+)%s+HTTP")
      if not path then
        return
      end
      local code = path:match("[?&]code=([^&%s]+)")
      local state = path:match("[?&]state=([^&%s]+)")
      local denied = path:match("[?&]error=([^&%s]+)")
      if not code and not denied then
        -- Not the OAuth callback (favicon, browser probe, etc.) — keep waiting.
        client:write("HTTP/1.1 204 No Content\r\nConnection: close\r\n\r\n", function()
          client:close()
        end)
        return
      end
      local body = "<html><body style='font-family:sans-serif;text-align:center;padding-top:3em'>"
        .. "<h2>&#10003; Authenticated</h2><p>You can close this tab and return to Neovim.</p></body></html>"
      local resp = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: "
        .. #body
        .. "\r\nConnection: close\r\n\r\n"
        .. body
      client:write(resp, function()
        client:close()
        finish(code, denied and ("authorization denied: " .. denied) or nil, state)
      end)
    end)
  end)
end

-- ── Auth + refresh ───────────────────────────────────────────────────────────

local function exchange(code, verifier, cb)
  vim.system({
    "curl", "-s", "-X", "POST", TOKEN_URL,
    "-d", "grant_type=authorization_code",
    "-d", "code=" .. code,
    "-d", "redirect_uri=" .. REDIRECT_URI,
    "-d", "client_id=" .. client_id(),
    "-d", "code_verifier=" .. verifier,
  }, { text = true }, function(res)
    vim.schedule(function()
      local ok, data = pcall(vim.json.decode, res.stdout or "")
      if not ok or type(data) ~= "table" or not data.access_token then
        local detail = (ok and type(data) == "table" and (data.error_description or data.error))
          or (res.stdout and res.stdout:sub(1, 140))
          or "unknown error"
        return cb(nil, "token exchange failed: " .. detail)
      end
      local tokens = {
        access_token = data.access_token,
        refresh_token = data.refresh_token,
        expires_at = os.time() + (tonumber(data.expires_in) or 3600),
      }
      save_tokens(tokens)
      vim.notify("Spotify: authorized ✓", vim.log.levels.INFO, { title = "Spotify" })
      cb(tokens.access_token)
    end)
  end)
end

local function authorize(cb)
  if authorizing then
    return vim.notify(
      "Spotify: already waiting for browser — approve it, or :Spotify logout to reset",
      vim.log.levels.WARN,
      { title = "Spotify" }
    )
  end
  local id = client_id()
  if not id or id == "" then
    return cb(nil, "SPOTIFY_CLIENT_ID not set (see SPOTIFY.md)")
  end
  local verifier = gen_verifier()
  local chal = challenge(verifier)
  if chal == "" then
    return cb(nil, "failed to build PKCE challenge (is openssl installed?)")
  end
  local state = gen_state()

  authorizing = true
  start_server(function(code, err, ret_state)
    authorizing = false
    if err then
      return cb(nil, err)
    end
    if ret_state ~= state then
      return cb(nil, "state mismatch — try again (:Spotify logout first)")
    end
    vim.notify("Spotify: code received, fetching token…", vim.log.levels.INFO, { title = "Spotify" })
    exchange(code, verifier, cb)
  end)

  local params = {
    "response_type=code",
    "client_id=" .. url_encode(id),
    "redirect_uri=" .. url_encode(REDIRECT_URI),
    "scope=" .. url_encode(SCOPES),
    "code_challenge_method=S256",
    "code_challenge=" .. url_encode(chal),
    "state=" .. url_encode(state),
  }
  local url = AUTHORIZE_URL .. "?" .. table.concat(params, "&")
  vim.notify("Spotify: opening browser to authorize…", vim.log.levels.INFO, { title = "Spotify" })
  if vim.ui.open then
    vim.ui.open(url)
  else
    vim.system({ "open", url })
  end
end

local function refresh(tokens, cb)
  vim.system({
    "curl", "-s", "-X", "POST", TOKEN_URL,
    "-d", "grant_type=refresh_token",
    "-d", "refresh_token=" .. tokens.refresh_token,
    "-d", "client_id=" .. client_id(),
  }, { text = true }, function(res)
    vim.schedule(function()
      local ok, data = pcall(vim.json.decode, res.stdout or "")
      if not ok or type(data) ~= "table" or not data.access_token then
        return cb(nil, "refresh failed")
      end
      local new = {
        access_token = data.access_token,
        refresh_token = data.refresh_token or tokens.refresh_token, -- Spotify may rotate it
        expires_at = os.time() + (tonumber(data.expires_in) or 3600),
      }
      save_tokens(new)
      cb(new.access_token)
    end)
  end)
end

-- ── Public API ───────────────────────────────────────────────────────────────

-- Get a valid user access token: cb(token) | cb(nil, err).
-- Uses the cached token, refreshes it, or triggers the browser login as needed.
function M.token(cb)
  local tokens = load_tokens()
  if tokens and tokens.access_token and (tokens.expires_at or 0) > os.time() + 60 then
    return cb(tokens.access_token)
  end
  if tokens and tokens.refresh_token then
    return refresh(tokens, function(tok)
      if tok then
        cb(tok)
      else
        authorize(cb) -- refresh failed → full re-auth
      end
    end)
  end
  authorize(cb)
end

-- Like M.token, but never launches the interactive browser flow: cb(token|nil).
-- Use this from passive/background code (e.g. the saved-indicator check).
function M.token_silent(cb)
  local tokens = load_tokens()
  if tokens and tokens.access_token and (tokens.expires_at or 0) > os.time() + 60 then
    return cb(tokens.access_token)
  end
  if tokens and tokens.refresh_token then
    return refresh(tokens, function(tok)
      cb(tok or nil)
    end)
  end
  cb(nil)
end

function M.login(cb)
  authorize(cb or function() end)
end

function M.logout()
  os.remove(TOKEN_FILE)
  vim.notify("Spotify: logged out", vim.log.levels.INFO, { title = "Spotify" })
end

function M.is_logged_in()
  return load_tokens() ~= nil
end

return M
