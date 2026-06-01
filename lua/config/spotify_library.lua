-- Your Spotify library (playlists, saved tracks) via the Web API + user OAuth.
-- Reads with the PKCE token from spotify_auth; plays the chosen context locally
-- via AppleScript (spotify.play). See SPOTIFY.md §4.

local M = {}

local auth = require("config.spotify_auth")
local API = "https://api.spotify.com/v1"

-- GET an API path: cb(decoded) | cb(nil, err).
local function api_get(path, cb)
  auth.token(function(tok, err)
    if not tok then
      return cb(nil, err)
    end
    vim.system({
      "curl", "-s", API .. path,
      "-H", "Authorization: Bearer " .. tok,
    }, { text = true }, function(res)
      vim.schedule(function()
        local ok, data = pcall(vim.json.decode, res.stdout or "")
        if not ok or type(data) ~= "table" then
          return cb(nil, "request failed")
        end
        if data.error then
          return cb(nil, (data.error.message or "API error"))
        end
        cb(data)
      end)
    end)
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

-- Browse your playlists → pick → play.
function M.playlists()
  if not (_G.Snacks and Snacks.picker) then
    return vim.notify("Spotify playlists need the snacks.nvim picker", vim.log.levels.ERROR)
  end
  api_get("/me/playlists?limit=50", function(data, err)
    if not data then
      return vim.notify("Spotify: " .. (err or "failed to load playlists"), vim.log.levels.ERROR)
    end
    local items = {}
    for _, p in ipairs(data.items or {}) do
      items[#items + 1] = {
        text = p.name,
        name = p.name,
        uri = p.uri,
        total = (p.tracks and p.tracks.total) or 0,
        owner = (p.owner and p.owner.display_name) or "",
      }
    end
    if #items == 0 then
      return vim.notify("Spotify: no playlists found", vim.log.levels.WARN)
    end
    Snacks.picker.pick({
      source = "spotify_playlists",
      title = "  Spotify Playlists",
      items = items,
      layout = { preset = "dropdown", preview = false },
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
  end)
end

return M
