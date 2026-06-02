-- Spotify search (tracks, playlists, albums) via the Web API Client Credentials
-- flow — public search needs no user login. Results play locally via AppleScript;
-- playlists/albums play in-context so the queue continues. UI is a live snacks
-- picker. Requires SPOTIFY_CLIENT_ID/SECRET in the environment (see SPOTIFY.md).

local M = {}

local TOKEN_URL = "https://accounts.spotify.com/api/token"
local API = "https://api.spotify.com/v1"
local SEARCH_TYPES = "track,playlist,album"
local PER_TYPE = 10

-- Fixed-width, colour-coded type tags (all 8 cols wide so names align).
local KIND = {
  track = { label = "track   ", hl = "SpotifyKindTrack" },
  playlist = { label = "playlist", hl = "SpotifyKindPlaylist" },
  album = { label = "album   ", hl = "SpotifyKindAlbum" },
}

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

local function api_get(path, cb)
  get_token(function(tok, err)
    if not tok then
      return cb(nil, err)
    end
    vim.system(
      { "curl", "-s", API .. path, "-H", "Authorization: Bearer " .. tok },
      { text = true },
      function(res)
        vim.schedule(function()
          local ok, data = pcall(vim.json.decode, res.stdout or "")
          cb((ok and type(data) == "table") and data or nil)
        end)
      end
    )
  end)
end

-- vim.json.decode turns JSON null into vim.NIL (truthy userdata), so guard with
-- type(x) == "table" before indexing anything that could be null.
local function artist_names(obj)
  local names = {}
  if type(obj.artists) == "table" then
    for _, a in ipairs(obj.artists) do
      if type(a) == "table" and a.name then
        names[#names + 1] = a.name
      end
    end
  end
  return table.concat(names, ", ")
end

-- Resolve the first track in a playlist/album so we can play it in-context.
local function first_track(context_uri, cb)
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
    local it = data and data.items and data.items[1]
    cb(it and ((it.track and it.track.uri) or it.uri) or nil)
  end)
end

-- cb(items) | cb(nil, err). Items: { kind, name, sub, uri, text }.
local function search(query, cb)
  get_token(function(tok, err)
    if not tok then
      return cb(nil, err)
    end
    vim.system({
      "curl", "-s", "-G", API .. "/search",
      "--data-urlencode", "q=" .. query,
      "-d", "type=" .. SEARCH_TYPES,
      "-d", "limit=" .. PER_TYPE,
      "-H", "Authorization: Bearer " .. tok,
    }, { text = true }, function(res)
      vim.schedule(function()
        local ok, data = pcall(vim.json.decode, res.stdout or "")
        if res.code ~= 0 or not ok or type(data) ~= "table" then
          return cb(nil, "search request failed")
        end
        local items = {}
        for _, t in ipairs((data.tracks and data.tracks.items) or {}) do
          if type(t) == "table" and t.uri then
            local sub = artist_names(t)
            items[#items + 1] = { kind = "track", name = t.name or "?", sub = sub, uri = t.uri, text = (t.name or "") .. " " .. sub }
          end
        end
        for _, p in ipairs((data.playlists and data.playlists.items) or {}) do
          if type(p) == "table" and p.uri then
            local owner = (type(p.owner) == "table" and p.owner.display_name) or ""
            local total = (type(p.tracks) == "table" and p.tracks.total) or 0
            items[#items + 1] = {
              kind = "playlist",
              name = p.name or "?",
              sub = owner .. (total > 0 and ("  ·  " .. total .. " tracks") or ""),
              uri = p.uri,
              text = (p.name or "") .. " " .. owner,
            }
          end
        end
        for _, a in ipairs((data.albums and data.albums.items) or {}) do
          if type(a) == "table" and a.uri then
            local sub = artist_names(a)
            items[#items + 1] = { kind = "album", name = a.name or "?", sub = sub, uri = a.uri, text = (a.name or "") .. " " .. sub }
          end
        end
        cb(items)
      end)
    end)
  end)
end

local function play_item(item)
  if item.kind == "track" then
    require("config.spotify").play_uri(item.uri)
  else
    -- playlist/album: start the first track within the context so it continues
    first_track(item.uri, function(track_uri)
      require("config.spotify").play_uri(track_uri, item.uri)
    end)
  end
  vim.notify("▶ " .. item.name, vim.log.levels.INFO, { title = "Spotify" })
end

-- Open the live search picker. `initial` optionally pre-fills the query.
function M.open(initial)
  if not (_G.Snacks and Snacks.picker) then
    vim.notify("Spotify search needs the snacks.nvim picker", vim.log.levels.ERROR)
    return
  end

  Snacks.picker.pick({
    source = "spotify_search",
    title = "  Spotify Search",
    live = true, -- re-query the API on every keystroke
    search = initial or "",
    layout = { preset = "dropdown", preview = false },
    finder = function(_, ctx)
      local query = vim.trim(ctx.filter.search or "")
      if query == "" then
        return {}
      end
      -- Async finder: search, suspend the coroutine, emit items on resume.
      return function(cb)
        local results, ferr
        search(query, function(items, err)
          results, ferr = items, err
          ctx.async:resume()
        end)
        ctx.async:suspend()
        if ferr then
          vim.schedule(function()
            Snacks.notify.warn("Spotify: " .. ferr)
          end)
          return
        end
        for _, item in ipairs(results or {}) do
          cb({ text = item.text, item = item })
        end
      end
    end,
    format = function(entry)
      local item = entry.item
      local k = KIND[item.kind] or KIND.track
      local ret = {
        { "  ", "SpotifyArtist" },
        { k.label, k.hl },
        { "  " .. item.name, "SpotifyTitle" },
      }
      if item.sub ~= "" then
        ret[#ret + 1] = { "   " .. item.sub, "SpotifyArtist" }
      end
      return ret
    end,
    confirm = function(picker, entry)
      picker:close()
      if entry and entry.item then
        play_item(entry.item)
      end
    end,
  })
end

return M
