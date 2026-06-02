-- Your Spotify library (playlists, saved tracks) via the Web API + user OAuth.
-- Reads with the PKCE token from spotify_auth; plays the chosen context locally
-- via AppleScript (spotify.play). See SPOTIFY.md §4.

local M = {}

local auth = require("config.spotify_auth")
local API = "https://api.spotify.com/v1"

-- Call the API: cb(decoded|{ok=true}) | cb(nil, err). `token_fn` lets passive
-- callers pass auth.token_silent so they never trigger the browser flow.
local function api(method, path, cb, token_fn)
  local get_token = token_fn or auth.token
  get_token(function(tok, err)
    if not tok then
      return cb(nil, err or "not logged in")
    end
    local args = { "curl", "-s", "-X", method, API .. path, "-H", "Authorization: Bearer " .. tok }
    if method ~= "GET" then
      -- PUT/DELETE to these endpoints carry no body.
      args[#args + 1] = "-H"
      args[#args + 1] = "Content-Length: 0"
    end
    vim.system(args, { text = true }, function(res)
      vim.schedule(function()
        -- Write endpoints return an empty body on success.
        if not res.stdout or vim.trim(res.stdout) == "" then
          return cb({ ok = true })
        end
        local ok, data = pcall(vim.json.decode, res.stdout)
        if not ok or type(data) ~= "table" then
          return cb(nil, "request failed")
        end
        if data.error then
          local msg = type(data.error) == "table" and (data.error.message or "API error") or tostring(data.error)
          return cb(nil, msg)
        end
        cb(data)
      end)
    end)
  end)
end

-- GET an API path: cb(decoded) | cb(nil, err).
local function api_get(path, cb)
  api("GET", path, cb)
end

-- Your Spotify user id (cached) — used to build the Liked Songs context URI.
local cached_user_id = nil
local function me_id(cb)
  if cached_user_id then
    return cb(cached_user_id)
  end
  api_get("/me", function(data)
    cached_user_id = data and data.id or nil
    cb(cached_user_id)
  end)
end

-- Resolve the first track URI inside a playlist/album context, for `play track
-- <track> in context <ctx>`. cb(track_uri | nil).
function M.first_track(context_uri, cb)
  local kind, id = context_uri:match("spotify:(%w+):(%w+)")
  local path
  if kind == "playlist" then
    path = "/playlists/" .. id .. "/tracks?limit=1&fields=items(track(uri))"
  elseif kind == "album" then
    path = "/albums/" .. id .. "/tracks?limit=1"
  else
    return cb(nil)
  end
  api_get(path, function(data)
    local item = data and data.items and data.items[1]
    local uri = item and ((item.track and item.track.uri) or item.uri) or nil
    cb(uri)
  end)
end

-- Play a context: resolve its first track, then hand off to AppleScript.
local function play_context(context_uri, label)
  M.first_track(context_uri, function(track_uri)
    require("config.spotify").play_uri(track_uri, context_uri)
    if label then
      vim.notify("▶ " .. label, vim.log.levels.INFO, { title = "Spotify" })
    end
  end)
end

-- Open a picker backed by a paginating Web API endpoint. Items stream in as
-- pages arrive (Spotify caps each page at 50, returning a `next` URL), so the
-- picker opens immediately and fills out — handles libraries of any size.
-- opts = { source, title, first_path, extract(page)->items, format, confirm, max_pages? }
local function paged_picker(opts)
  if not (_G.Snacks and Snacks.picker) then
    return vim.notify("Spotify needs the snacks.nvim picker", vim.log.levels.ERROR)
  end
  Snacks.picker.pick({
    source = opts.source,
    title = opts.title,
    layout = { preset = "dropdown", preview = false },
    format = opts.format,
    confirm = opts.confirm,
    finder = function(_, ctx)
      return function(cb)
        local path, pages = opts.first_path, 0
        while path do
          local page, perr
          api_get(path, function(d, e)
            page, perr = d, e
            ctx.async:resume()
          end)
          ctx.async:suspend()
          if not page then
            if perr then
              vim.schedule(function()
                Snacks.notify.warn("Spotify: " .. perr)
              end)
            end
            return
          end
          for _, item in ipairs(opts.extract(page)) do
            cb(item)
          end
          pages = pages + 1
          if opts.max_pages and pages >= opts.max_pages then
            return
          end
          -- Spotify returns `next` as a full URL; strip to a path for the next call.
          local nxt = page.next
          path = (type(nxt) == "string") and (nxt:gsub("^https?://api%.spotify%.com/v1", "")) or nil
        end
      end
    end,
  })
end

-- Shared track formatting + play-on-confirm (used by liked/recent pickers).
local function track_format(item)
  local ret = {
    { "  ", "SpotifyTitle" },
    { item.name, "SpotifyTitle" },
    { "   " .. item.artist, "SpotifyArtist" },
  }
  if item.album ~= "" then
    ret[#ret + 1] = { "  ·  " .. item.album, "SpotifyAlbum" }
  end
  return ret
end

local function track_confirm(picker, item)
  picker:close()
  if item and item.uri then
    require("config.spotify").play_uri(item.uri)
    vim.notify("▶ " .. item.name .. " — " .. item.artist, vim.log.levels.INFO, { title = "Spotify" })
  end
end

-- Browse your playlists → pick → play (all pages).
function M.playlists()
  paged_picker({
    source = "spotify_playlists",
    title = "  Spotify Playlists",
    first_path = "/me/playlists?limit=50",
    extract = function(page)
      local items = {}
      for _, p in ipairs(page.items or {}) do
        items[#items + 1] = {
          text = p.name,
          name = p.name,
          uri = p.uri,
          total = (p.tracks and p.tracks.total) or 0,
          owner = (p.owner and p.owner.display_name) or "",
        }
      end
      return items
    end,
    format = function(item)
      local ret = {
        { "  ", "SpotifyTitle" },
        { item.name, "SpotifyTitle" },
        { "   " .. item.total .. " tracks", "SpotifyArtist" },
      }
      if item.owner ~= "" then
        ret[#ret + 1] = { "  ·  " .. item.owner, "SpotifyAlbum" }
      end
      return ret
    end,
    confirm = function(picker, item)
      picker:close()
      if item and item.uri then
        play_context(item.uri, item.name)
      end
    end,
  })
end

-- Normalise a Web API track object into a picker item.
local function track_item(t)
  local artists = {}
  for _, a in ipairs(t.artists or {}) do
    artists[#artists + 1] = a.name
  end
  return {
    text = (t.name or "") .. " " .. table.concat(artists, " "),
    name = t.name or "?",
    artist = table.concat(artists, ", "),
    album = (t.album and t.album.name) or "",
    uri = t.uri,
  }
end

-- Liked Songs → pick → play (all pages).
function M.liked()
  paged_picker({
    source = "spotify_liked",
    title = "  Liked Songs",
    first_path = "/me/tracks?limit=50",
    extract = function(page)
      local tracks = {}
      for _, it in ipairs(page.items or {}) do
        if it.track then
          tracks[#tracks + 1] = track_item(it.track)
        end
      end
      return tracks
    end,
    format = track_format,
    -- Play the picked song *within* the Liked Songs collection, so the queue
    -- continues with subsequent liked songs (collection context verified working).
    confirm = function(picker, item)
      picker:close()
      if not (item and item.uri) then
        return
      end
      me_id(function(id)
        local ctx = id and ("spotify:user:" .. id .. ":collection") or nil
        require("config.spotify").play_uri(item.uri, ctx)
        vim.notify("▶ " .. item.name .. " — " .. item.artist, vim.log.levels.INFO, { title = "Spotify" })
      end)
    end,
  })
end

-- Recently played → pick → play (single page; the API caps this at 50).
function M.recent()
  local seen = {}
  paged_picker({
    source = "spotify_recent",
    title = "  Recently Played",
    first_path = "/me/player/recently-played?limit=50",
    max_pages = 1,
    extract = function(page)
      local tracks = {}
      for _, it in ipairs(page.items or {}) do
        local t = it.track
        if t and t.uri and not seen[t.uri] then
          seen[t.uri] = true
          tracks[#tracks + 1] = track_item(t)
        end
      end
      return tracks
    end,
    format = track_format,
    confirm = track_confirm,
  })
end

-- bare track id from a spotify:track:ID uri (or pass a bare id through).
local function track_id(uri)
  return uri:match("spotify:track:(%w+)") or uri
end

-- Is a track saved in the library? cb(true|false|nil). `silent` avoids any login.
function M.is_saved(uri, cb, silent)
  api("GET", "/me/tracks/contains?ids=" .. track_id(uri), function(data, err)
    if not data or type(data[1]) ~= "boolean" then
      return cb(nil, err)
    end
    cb(data[1])
  end, silent and auth.token_silent or nil)
end

-- Toggle save/unsave for the currently playing track.
function M.toggle_save_current()
  local cur = require("config.spotify").current
  local uri = cur and not cur.not_running and cur.id
  if not uri or uri == "" then
    return vim.notify("Spotify: nothing playing", vim.log.levels.WARN)
  end
  M.is_saved(uri, function(saved, err)
    if saved == nil then
      return vim.notify("Spotify: " .. (err or "couldn't check library"), vim.log.levels.ERROR)
    end
    local method = saved and "DELETE" or "PUT"
    api(method, "/me/tracks?ids=" .. track_id(uri), function(_, e2)
      if e2 then
        return vim.notify("Spotify: " .. e2, vim.log.levels.ERROR)
      end
      require("config.spotify").set_saved(not saved)
      vim.notify(
        saved and "♡  Removed from Liked Songs" or "♥  Saved to Liked Songs",
        vim.log.levels.INFO,
        { title = "Spotify" }
      )
    end)
  end)
end

return M
