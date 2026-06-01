-- Spotify song search via the Web API (Client Credentials flow), played locally
-- via AppleScript. Requires SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET in the
-- environment (see SPOTIFY.md §4). UI is a live snacks.nvim picker.

local M = {}

local TOKEN_URL = "https://accounts.spotify.com/api/token"
local SEARCH_URL = "https://api.spotify.com/v1/search"
local SEARCH_LIMIT = 25

-- In-memory token cache (no disk, no refresh token needed for client-credentials).
local token = { value = nil, expires_at = 0 }

local function creds()
  return os.getenv("SPOTIFY_CLIENT_ID"), os.getenv("SPOTIFY_CLIENT_SECRET")
end

-- cb(token) on success, cb(nil, err) on failure.
local function get_token(cb)
  if token.value and token.expires_at > os.time() + 30 then
    return cb(token.value)
  end
  local id, secret = creds()
  if not id or not secret or id == "" or secret == "" then
    return cb(nil, "set SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET (see SPOTIFY.md)")
  end
  vim.system({
    "curl", "-s", "-X", "POST", TOKEN_URL,
    "-d", "grant_type=client_credentials",
    "-u", id .. ":" .. secret,
  }, { text = true }, function(res)
    vim.schedule(function()
      local ok, data = pcall(vim.json.decode, res.stdout or "")
      if res.code ~= 0 or not ok or type(data) ~= "table" or not data.access_token then
        local msg = (ok and type(data) == "table" and data.error_description) or "token request failed"
        return cb(nil, msg)
      end
      token.value = data.access_token
      token.expires_at = os.time() + (tonumber(data.expires_in) or 3600)
      cb(token.value)
    end)
  end)
end

-- cb(tracks) on success, cb(nil, err) on failure. Each track: {name, artist, album, uri}.
local function search(query, cb)
  get_token(function(tok, err)
    if not tok then
      return cb(nil, err)
    end
    vim.system({
      "curl", "-s", "-G", SEARCH_URL,
      "--data-urlencode", "q=" .. query,
      "-d", "type=track",
      "-d", "limit=" .. SEARCH_LIMIT,
      "-H", "Authorization: Bearer " .. tok,
    }, { text = true }, function(res)
      vim.schedule(function()
        local ok, data = pcall(vim.json.decode, res.stdout or "")
        if res.code ~= 0 or not ok or type(data) ~= "table" or not data.tracks then
          return cb(nil, "search request failed")
        end
        local tracks = {}
        for _, t in ipairs(data.tracks.items or {}) do
          local artists = {}
          for _, a in ipairs(t.artists or {}) do
            artists[#artists + 1] = a.name
          end
          tracks[#tracks + 1] = {
            name = t.name or "?",
            artist = table.concat(artists, ", "),
            album = (t.album and t.album.name) or "",
            uri = t.uri,
          }
        end
        cb(tracks)
      end)
    end)
  end)
end

-- Open the live search picker. `initial` optionally pre-fills the query.
function M.open(initial)
  if not (_G.Snacks and Snacks.picker) then
    vim.notify("Spotify search needs the snacks.nvim picker", vim.log.levels.ERROR)
    return
  end

  Snacks.picker.pick({
    source = "spotify_search",
    title = "Spotify Search",
    live = true, -- re-query the API on every keystroke
    search = initial or "",
    layout = { preset = "dropdown", preview = false },
    finder = function(_, ctx)
      local query = vim.trim(ctx.filter.search or "")
      if query == "" then
        return {}
      end
      -- Async finder: kick off the search, suspend the picker's coroutine, then
      -- emit items once the HTTP callback resumes us (the snacks await idiom).
      return function(cb)
        local results, ferr
        search(query, function(tracks, err)
          results, ferr = tracks, err
          ctx.async:resume()
        end)
        ctx.async:suspend()
        if ferr then
          vim.schedule(function()
            Snacks.notify.warn("Spotify: " .. ferr)
          end)
          return
        end
        for _, t in ipairs(results or {}) do
          cb({
            text = t.name .. " " .. t.artist .. " " .. t.album, -- what the matcher sees
            track = t,
            uri = t.uri,
          })
        end
      end
    end,
    format = function(item)
      local t = item.track
      local ret = { { t.name, "SnacksPickerLabel" } }
      ret[#ret + 1] = { "   " .. t.artist, "SnacksPickerComment" }
      if t.album ~= "" then
        ret[#ret + 1] = { "  ·  " .. t.album, "NonText" }
      end
      return ret
    end,
    confirm = function(picker, item)
      picker:close()
      if item and item.uri then
        require("config.spotify").play_uri(item.uri)
        vim.notify("▶ " .. item.track.name .. " — " .. item.track.artist, vim.log.levels.INFO, { title = "Spotify" })
      end
    end,
  })
end

return M
