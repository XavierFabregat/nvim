-- Karaoke-style synced lyrics panel. Lyrics come from lrclib.net (free, no auth);
-- playback position comes from the shared poller in config.spotify. The current
-- line is centred and highlighted, scrolling as the song plays. See SPOTIFY.md §5.

local M = {}

local LRCLIB = "https://lrclib.net/api"
local UA = "nvim-spotify (personal config)"
local TICK_MS = 300

local NS = vim.api.nvim_create_namespace("spotify_lyrics")

local state = {
  win = nil,
  buf = nil,
  timer = nil,
  lines = nil, -- { { t = seconds|nil, text = "…" }, … } or nil
  synced = false,
  loading = false,
  track_id = nil, -- track the loaded lyrics belong to
  active = nil, -- active line index
  last_pos = nil, -- last seen poll position (for interpolation)
  last_clock = nil,
}

local fetch_lyrics, tick -- forward declarations

local function num(v)
  return tonumber((tostring(v):gsub(",", "."))) or 0
end

local function enc(s)
  return (tostring(s):gsub("[^%w%-._~]", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

-- ── Window ───────────────────────────────────────────────────────────────────

local function win_valid()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function geometry()
  local width = math.max(32, math.min(48, math.floor(vim.o.columns * 0.4)))
  local height = math.max(8, vim.o.lines - 6)
  return {
    relative = "editor",
    width = width,
    height = height,
    row = 2,
    col = vim.o.columns - width - 2,
    style = "minimal",
    border = "rounded",
    title = "  Lyrics ",
    title_pos = "center",
  }
end

local function set_buf_lines()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return
  end
  local text = {}
  if not state.lines then
    text = { "", "  " .. (state.loading and "Loading lyrics…" or "No lyrics found."), "" }
  else
    for _, l in ipairs(state.lines) do
      text[#text + 1] = "  " .. (l.text ~= "" and l.text or "♪")
    end
  end
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, text)
  vim.bo[state.buf].modifiable = false
end

-- Highlight + centre the active line (1-based), dimming the rest via winhighlight.
local function highlight(active)
  if not win_valid() then
    return
  end
  vim.api.nvim_buf_clear_namespace(state.buf, NS, 0, -1)
  if not active then
    return
  end
  vim.api.nvim_buf_set_extmark(state.buf, NS, active - 1, 0, { line_hl_group = "SpotifyTitle" })
  vim.api.nvim_buf_set_extmark(state.buf, NS, active - 1, 0, {
    virt_text = { { "▸", "SpotifyTitle" } },
    virt_text_pos = "overlay",
  })
  pcall(vim.api.nvim_win_set_cursor, state.win, { active, 0 })
  vim.api.nvim_win_call(state.win, function()
    vim.cmd("normal! zz")
  end)
end

-- ── Lyrics fetch (lrclib) ─────────────────────────────────────────────────────

local function parse_lrc(lrc)
  local out = {}
  for line in (lrc .. "\n"):gmatch("(.-)\n") do
    local mm, ss, rest = line:match("^%[(%d+):(%d+[%.:]?%d*)%](.*)$")
    if mm then
      rest = rest:gsub("^%[%d+:%d+[%.:]?%d*%]", "") -- drop any extra timestamps
      out[#out + 1] = { t = tonumber(mm) * 60 + num((ss:gsub(":", "."))), text = vim.trim(rest) }
    end
  end
  table.sort(out, function(a, b)
    return a.t < b.t
  end)
  return out
end

local function parse_plain(txt)
  local out = {}
  for line in (txt .. "\n"):gmatch("(.-)\n") do
    out[#out + 1] = { t = nil, text = line }
  end
  return out
end

local function request(url, cb)
  vim.system({ "curl", "-s", "-H", "User-Agent: " .. UA, url }, { text = true }, function(res)
    vim.schedule(function()
      local ok, data = pcall(vim.json.decode, res.stdout or "")
      cb(ok and data or nil)
    end)
  end)
end

local function use(cur, data)
  if state.track_id ~= cur.id then
    return -- track moved on while we were fetching
  end
  state.loading = false
  if data and type(data) == "table" and type(data.syncedLyrics) == "string" and data.syncedLyrics ~= "" then
    state.lines, state.synced = parse_lrc(data.syncedLyrics), true
  elseif data and type(data) == "table" and type(data.plainLyrics) == "string" and data.plainLyrics ~= "" then
    state.lines, state.synced = parse_plain(data.plainLyrics), false
  else
    state.lines, state.synced = nil, false
  end
  state.active = nil
  set_buf_lines()
  if state.synced then
    tick()
  end
end

fetch_lyrics = function(cur)
  state.loading, state.lines, state.synced, state.active = true, nil, false, nil
  state.track_id = cur.id
  set_buf_lines()
  local base = "artist_name=" .. enc(cur.artist) .. "&track_name=" .. enc(cur.track)
  local get_url = LRCLIB .. "/get?" .. base .. "&album_name=" .. enc(cur.album) .. "&duration=" .. math.floor(num(cur.dur))
  request(get_url, function(data)
    if state.track_id ~= cur.id then
      return
    end
    if data and (data.syncedLyrics or data.plainLyrics) then
      use(cur, data)
    else
      -- Fall back to a fuzzy search if the exact get misses.
      request(LRCLIB .. "/search?" .. base, function(arr)
        use(cur, type(arr) == "table" and arr[1] or nil)
      end)
    end
  end)
end

-- ── Sync loop ─────────────────────────────────────────────────────────────────

local function active_index(pos)
  if not (state.lines and state.synced) then
    return nil
  end
  local idx
  for i, l in ipairs(state.lines) do
    if l.t and l.t <= pos then
      idx = i
    else
      break
    end
  end
  return idx
end

tick = function()
  if not win_valid() then
    return
  end
  local cur = require("config.spotify").current
  if not cur or cur.not_running then
    return
  end
  if cur.id and cur.id ~= state.track_id then
    return fetch_lyrics(cur) -- new song → reload lyrics
  end
  -- Interpolate position between (≈1s) polls for smooth line changes.
  local p = num(cur.pos)
  if state.last_pos ~= p then
    state.last_pos, state.last_clock = p, vim.uv.now()
  end
  local elapsed = (cur.state == "playing") and ((vim.uv.now() - (state.last_clock or vim.uv.now())) / 1000) or 0
  local idx = active_index(p + elapsed)
  if idx ~= state.active then
    state.active = idx
    highlight(idx)
  end
end

local function start_timer()
  if state.timer then
    return
  end
  state.timer = vim.uv.new_timer()
  state.timer:start(TICK_MS, TICK_MS, function()
    vim.schedule(tick)
  end)
end

local function stop_timer()
  if state.timer then
    state.timer:stop()
    if not state.timer:is_closing() then
      state.timer:close()
    end
    state.timer = nil
  end
end

-- ── Open / close ─────────────────────────────────────────────────────────────

local function close()
  stop_timer()
  pcall(function()
    require("config.spotify").unsubscribe("lyrics")
  end)
  if win_valid() then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win, state.buf, state.lines, state.track_id, state.active = nil, nil, nil, nil, nil
end

local function open()
  local sp = require("config.spotify")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  state.buf = buf
  -- enter=false: the panel is glanceable; keep the cursor in your code.
  state.win = vim.api.nvim_open_win(buf, false, geometry())
  vim.wo[state.win].winhighlight = "NormalFloat:SpotifyLyricDim,FloatBorder:FloatBorder"
  vim.wo[state.win].wrap = true

  for _, k in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", k, M.toggle, { buffer = buf, nowait = true, silent = true })
  end
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      state.win, state.buf = nil, nil
      stop_timer()
      pcall(function()
        require("config.spotify").unsubscribe("lyrics")
      end)
    end,
  })

  sp.subscribe("lyrics", 1000) -- keep position fresh while the panel is open
  start_timer()

  local cur = sp.current
  if cur and not cur.not_running then
    fetch_lyrics(cur)
  else
    state.loading = false
    set_buf_lines()
  end
end

function M.toggle()
  if win_valid() then
    close()
  else
    open()
  end
end

return M
