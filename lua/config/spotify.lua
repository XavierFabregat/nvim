-- DIY Spotify control for macOS via AppleScript (osascript).
-- Transport, a live status float, statusline now-playing and track-change toasts,
-- all under the <leader>m namespace. Roadmap & ideas: see SPOTIFY.md.

local M = {}

-- Tweakables.
M.config = {
  statusline = true, -- now-playing component (implies the background poller)
  notify_on_change = true, -- toast when the track changes
  poll = {
    float_ms = 1000, -- cadence while the status float is open
    active_ms = 2000, -- ambient cadence (statusline/toast) while nvim is focused
    idle_ms = 10000, -- relaxed cadence when Spotify is closed
  },
  refocus_terminal = true, -- after a URI-play, re-focus the terminal (Spotify steals it)
  terminal_app = nil, -- auto-detected from $TERM_PROGRAM; set e.g. "Warp" to override
}

-- Latest status, refreshed by the poller. Read by the statusline component.
M.current = nil

local VOLUME_STEP = 10
local SEEK_STEP = 10

-- $TERM_PROGRAM -> macOS app name, for bouncing focus back to the terminal after
-- Spotify steals it on a URI-play.
local TERM_APPS = {
  WarpTerminal = "Warp",
  iTerm = "iTerm",
  ["iTerm.app"] = "iTerm",
  Apple_Terminal = "Terminal",
  ghostty = "Ghostty",
  WezTerm = "WezTerm",
  kitty = "kitty",
  alacritty = "Alacritty",
  vscode = "Code",
}

local function terminal_app()
  return M.config.terminal_app or TERM_APPS[vim.env.TERM_PROGRAM or ""]
end

-- AppleScript: linefeed-separated fields, or "not_running".
-- `is running` does not launch Spotify, so a closed app stays closed.
-- NOTE: short tokens like `st` are AppleScript reserved words, hence verbose names.
local STATUS_SCRIPT = [[
if application "Spotify" is running then
  tell application "Spotify"
    set pState to player state as text
    set tName to name of current track
    set tArtist to artist of current track
    set tAlbum to album of current track
    set pPos to player position
    set tDur to (duration of current track) / 1000
    set tId to id of current track
    return pState & linefeed & tName & linefeed & tArtist & linefeed & tAlbum & linefeed & pPos & linefeed & tDur & linefeed & tId
  end tell
else
  return "not_running"
end if
]]

local STATE_GLYPH = { playing = "▶", paused = "⏸", stopped = "⏹" }
local STATE_TEXT = { playing = "Playing", paused = "Paused", stopped = "Stopped" }
local HINT = "  space ⏯   ·   h/l ⏮ ⏭   ·   +/- vol   ·   s/r   ·   y copy"

-- Spotify-flavoured highlight groups, re-applied when the colorscheme changes.
local function setup_highlights()
  local set = vim.api.nvim_set_hl
  set(0, "SpotifyTitle", { fg = "#1db954", bold = true })
  set(0, "SpotifyState", { fg = "#1db954", bold = true })
  set(0, "SpotifyArtist", { link = "Comment" })
  set(0, "SpotifyAlbum", { link = "NonText" })
  set(0, "SpotifyTime", { link = "Comment" })
  set(0, "SpotifyHint", { fg = "#6b7280", italic = true })
  set(0, "SpotifyBarFill", { fg = "#1db954" })
  set(0, "SpotifyBarEmpty", { fg = "#3a3a3a" })
end
setup_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })

-- ── AppleScript helpers ──────────────────────────────────────────────────────

-- Run an arbitrary AppleScript, calling cb(trimmed_stdout) on success.
local function osa(script, cb)
  vim.system({ "osascript", "-e", script }, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        local err = vim.trim(res.stderr or "")
        vim.notify("Spotify: " .. (err ~= "" and err or "command failed"), vim.log.levels.ERROR)
      elseif cb then
        cb(vim.trim(res.stdout or ""))
      end
    end)
  end)
end

-- Shorthand for one-line `tell application "Spotify" to <body>`.
local function tell(body, cb)
  osa('tell application "Spotify" to ' .. body, cb)
end

-- spotify:track:ID -> https://open.spotify.com/track/ID
local function uri_to_url(uri)
  return (uri:gsub("spotify:(%w+):(%w+)", "https://open.spotify.com/%1/%2"))
end

-- ── Formatting ───────────────────────────────────────────────────────────────

-- Spotify returns floats using the system locale, so a comma decimal is possible.
local function to_num(v)
  return tonumber((tostring(v):gsub(",", "."))) or 0
end

local function fmt_time(seconds)
  seconds = math.floor(to_num(seconds))
  return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

-- A progress row as styled segments: time · bar (green fill, dim remainder) · time.
local function progress_segs(pos, dur, width)
  pos, dur = to_num(pos), to_num(dur)
  local filled = dur > 0 and math.floor((pos / dur) * width + 0.5) or 0
  filled = math.max(0, math.min(width, filled))
  return {
    { "  ", nil },
    { fmt_time(pos), "SpotifyTime" },
    { " ▕", "SpotifyBarEmpty" },
    { string.rep("█", filled), "SpotifyBarFill" },
    { string.rep("░", width - filled), "SpotifyBarEmpty" },
    { "▏ ", "SpotifyBarEmpty" },
    { fmt_time(dur), "SpotifyTime" },
  }
end

-- The float as rows; each row is a list of { text, highlight } segments.
local function build_rows(info)
  if info.not_running then
    return {
      { { "" } },
      { { "  Spotify isn't running.", "SpotifyArtist" } },
      { { "" } },
    }
  end
  return {
    { { "" } },
    { { "  " .. (STATE_GLYPH[info.state] or "•") .. "  " .. (STATE_TEXT[info.state] or info.state), "SpotifyState" } },
    { { "" } },
    { { "  ♫  " .. info.track, "SpotifyTitle" } },
    { { "  ♪  " .. info.artist, "SpotifyArtist" } },
    { { "  💿 " .. info.album, "SpotifyAlbum" } },
    { { "" } },
    progress_segs(info.pos, info.dur, 24),
    { { "" } },
    { { HINT, "SpotifyHint" } },
  }
end

-- Flatten rows into buffer lines + a list of { row, col0, col1, hl } highlights.
local function assemble(rows)
  local lines, hls = {}, {}
  for r, segs in ipairs(rows) do
    local line, col = "", 0
    for _, seg in ipairs(segs) do
      local text, hl = seg[1], seg[2]
      if hl and text ~= "" then
        hls[#hls + 1] = { r - 1, col, col + #text, hl }
      end
      line = line .. text
      col = col + #text
    end
    lines[r] = line
  end
  return lines, hls
end

-- ── Poller (single shared, refcounted, focus-gated) ──────────────────────────

local poller = {
  timer = nil,
  running_ms = nil,
  focused = true,
  subs = {}, -- name -> requested interval (ms)
  last_id = nil, -- for track-change detection
  primed = false, -- skip the toast on the very first poll
}

local state = { win = nil, buf = nil } -- the status float

-- Forward declarations (mutual references between poller pieces).
local poll_once, reschedule, poke

local function subscribe(name, ms)
  poller.subs[name] = ms
  reschedule()
end

local function unsubscribe(name)
  poller.subs[name] = nil
  reschedule()
end

-- ── Float window ─────────────────────────────────────────────────────────────

local NS = vim.api.nvim_create_namespace("spotify_float")

-- Geometry that re-centres for the current line set (no `style`, so it is also
-- valid for nvim_win_set_config when resizing an open window).
local function geometry(lines)
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = width + 4
  return {
    relative = "editor",
    width = width,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
  }
end

-- Write rows to the buffer with per-segment highlighting; returns the lines.
local function apply(rows)
  local lines, hls = assemble(rows)
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(state.buf, NS, 0, -1)
  for _, h in ipairs(hls) do
    vim.api.nvim_buf_set_extmark(state.buf, NS, h[1], h[2], { end_col = h[3], hl_group = h[4] })
  end
  return lines
end

local function open(rows)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  state.buf = buf

  local lines = assemble(rows)
  local cfg = geometry(lines)
  cfg.style, cfg.border, cfg.title, cfg.title_pos = "minimal", "rounded", "  Spotify ", "center"
  state.win = vim.api.nvim_open_win(buf, true, cfg)
  vim.wo[state.win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  apply(rows)

  -- Mini-player controls (act, then poke the poller for snappy feedback).
  local act = function(fn)
    return function()
      fn()
      poke()
    end
  end
  -- stylua: ignore start
  local maps = {
    ["<Space>"] = act(M.play_pause),
    ["l"]       = act(M.next),
    ["h"]       = act(M.previous),
    ["+"]       = act(function() M.volume(VOLUME_STEP) end),
    ["="]       = act(function() M.volume(VOLUME_STEP) end),
    ["-"]       = act(function() M.volume(-VOLUME_STEP) end),
    ["s"]       = act(M.toggle_shuffle),
    ["r"]       = act(M.toggle_repeat),
    ["y"]       = function() M.copy_link() end,
  }
  -- stylua: ignore end
  for lhs, fn in pairs(maps) do
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, silent = true })
  end
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      vim.api.nvim_win_close(state.win, true)
    end, { buffer = buf, nowait = true, silent = true })
  end

  -- Drop the float's fast subscription once it's gone.
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      state.win, state.buf = nil, nil
      unsubscribe("float")
    end,
  })
end

local function float_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function render(info)
  local rows = build_rows(info)
  if float_open() then
    local lines = apply(rows)
    vim.api.nvim_win_set_config(state.win, geometry(lines))
  else
    open(rows)
  end
end

-- ── Fetch + poll loop ────────────────────────────────────────────────────────

local function fetch(cb)
  vim.system({ "osascript", "-e", STATUS_SCRIPT }, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        cb(nil, res.stderr)
        return
      end
      local out = vim.split(vim.trim(res.stdout or ""), "\n", { plain = true })
      if out[1] == "not_running" then
        cb({ not_running = true })
      else
        cb({
          state = vim.trim(out[1] or ""),
          track = vim.trim(out[2] or ""),
          artist = vim.trim(out[3] or ""),
          album = vim.trim(out[4] or ""),
          pos = out[5],
          dur = out[6],
          id = vim.trim(out[7] or ""),
        })
      end
    end)
  end)
end

local function notify_track(info)
  local msg = info.track .. "\n" .. info.artist
  if info.album ~= "" then
    msg = msg .. " · " .. info.album
  end
  if _G.Snacks and Snacks.notify then
    Snacks.notify(msg, { title = "Now Playing", icon = "♫ " })
  else
    vim.notify("♫ " .. info.track .. " — " .. info.artist, vim.log.levels.INFO, { title = "Now Playing" })
  end
end

poll_once = function()
  fetch(function(info)
    if info == nil then
      reschedule()
      return
    end
    M.current = info

    -- Track-change toast (skips the first poll so it stays quiet on startup).
    local id = not info.not_running and info.id ~= "" and info.id or nil
    if id and id ~= poller.last_id then
      if poller.primed and M.config.notify_on_change then
        notify_track(info)
      end
      poller.last_id = id
    end
    poller.primed = true

    if float_open() then
      render(info)
    end
    if M.config.statusline then
      local ok, lualine = pcall(require, "lualine")
      if ok then
        lualine.refresh()
      else
        vim.cmd("redrawstatus")
      end
    end

    -- Spotify may have just opened/closed: re-evaluate cadence.
    reschedule()
  end)
end

reschedule = function()
  -- Fastest interval any active subscriber asked for.
  local ms
  for _, want in pairs(poller.subs) do
    if not ms or want < ms then
      ms = want
    end
  end

  -- Stop entirely when nothing wants polling or nvim isn't focused.
  if not ms or not poller.focused then
    if poller.timer then
      poller.timer:stop()
      if not poller.timer:is_closing() then
        poller.timer:close()
      end
      poller.timer = nil
    end
    poller.running_ms = nil
    return
  end

  -- Relax cadence when Spotify is closed (unless the float wants to stay live).
  if not float_open() and M.current and M.current.not_running then
    ms = math.max(ms, M.config.poll.idle_ms)
  end

  if poller.timer and poller.running_ms == ms then
    return -- already at the right cadence
  end
  if poller.timer then
    poller.timer:stop()
    if not poller.timer:is_closing() then
      poller.timer:close()
    end
    poller.timer = nil
  end
  poller.timer = vim.uv.new_timer()
  poller.running_ms = ms
  poller.timer:start(0, ms, function()
    vim.schedule(poll_once)
  end)
end

-- Nudge a fresh poll shortly after an in-float action so it feels instant.
poke = function()
  vim.defer_fn(function()
    if float_open() then
      poll_once()
    end
  end, 200)
end

-- ── Public actions ───────────────────────────────────────────────────────────

function M.status()
  fetch(function(info, err)
    if not info then
      vim.notify("Spotify: " .. (err or "osascript failed"), vim.log.levels.ERROR)
      return
    end
    M.current = info
    render(info) -- opens the float
    subscribe("float", M.config.poll.float_ms)
  end)
end

function M.copy_link()
  fetch(function(info, err)
    if not info or info.not_running or info.id == "" then
      vim.notify("Spotify: nothing playing", vim.log.levels.WARN)
      return
    end
    local url = uri_to_url(info.id)
    vim.fn.setreg("+", url)
    vim.fn.setreg('"', url)
    vim.notify("Spotify link copied:\n" .. info.track, vim.log.levels.INFO, { title = "Spotify" })
  end)
end

-- Statusline component text (empty string => hidden).
function M.statusline()
  local c = M.current
  if not (c and not c.not_running and c.state ~= "stopped" and c.track ~= "") then
    return ""
  end
  local icon = c.state == "playing" and "♫" or "⏸"
  local text = icon .. " " .. c.track .. " — " .. c.artist
  if vim.fn.strchars(text) > 45 then
    text = vim.fn.strcharpart(text, 0, 44) .. "…"
  end
  return text
end

function M.playing()
  local c = M.current
  return c ~= nil and not c.not_running and c.state ~= "stopped" and c.track ~= ""
end

-- ── Transport ──────────────────────────────────────────────────────────────

function M.play_pause()
  tell("playpause")
end

function M.play()
  tell("play")
end

function M.pause()
  tell("pause")
end

function M.next()
  tell("next track")
end

function M.previous()
  tell("previous track")
end

function M.stop()
  tell("stop")
end

-- Play a track URI, optionally within a context (playlist/album) URI.
-- Spotify grabs focus on a URI-play, so we bounce focus back to the terminal after.
function M.play_uri(track_uri, context_uri)
  local primary = track_uri or context_uri
  if not primary then
    return vim.notify("Spotify: nothing to play", vim.log.levels.WARN)
  end
  local play = 'play track "' .. primary .. '"'
  if track_uri and context_uri then
    play = 'play track "' .. track_uri .. '" in context "' .. context_uri .. '"'
  end
  local lines = { 'tell application "Spotify" to ' .. play }
  local app = terminal_app()
  if M.config.refocus_terminal ~= false and app then
    lines[#lines + 1] = "delay 0.12"
    lines[#lines + 1] = 'tell application "' .. app .. '" to activate'
  end
  osa(table.concat(lines, "\n"))
end

-- delta is a signed integer (percentage points); result is clamped to 0–100.
function M.volume(delta)
  osa(
    string.format(
      [[
tell application "Spotify"
  set newVol to sound volume + (%d)
  if newVol > 100 then set newVol to 100
  if newVol < 0 then set newVol to 0
  set sound volume to newVol
  return newVol
end tell]],
      delta
    ),
    function(out)
      vim.notify("Spotify volume: " .. out .. "%", vim.log.levels.INFO)
    end
  )
end

-- delta is a signed integer (seconds); result is clamped to >= 0.
function M.seek(delta)
  osa(string.format(
    [[
tell application "Spotify"
  set newPos to player position + (%d)
  if newPos < 0 then set newPos to 0
  set player position to newPos
end tell]],
    delta
  ))
end

-- NOTE: Spotify applies `set` asynchronously, so re-reading the property in the
-- same block returns the stale value. Return the value we computed instead.
function M.toggle_shuffle()
  osa(
    [[
tell application "Spotify"
  set newState to not shuffling
  set shuffling to newState
  return newState
end tell]],
    function(out)
      vim.notify("Spotify shuffle: " .. (out == "true" and "on" or "off"), vim.log.levels.INFO)
    end
  )
end

function M.toggle_repeat()
  osa(
    [[
tell application "Spotify"
  set newState to not repeating
  set repeating to newState
  return newState
end tell]],
    function(out)
      vim.notify("Spotify repeat: " .. (out == "true" and "on" or "off"), vim.log.levels.INFO)
    end
  )
end

-- ── Command + keymaps ────────────────────────────────────────────────────────

-- `:Spotify <action> [value]` — dispatch table for the user command.
local ACTIONS = {
  status = M.status,
  playpause = M.play_pause,
  ["play/pause"] = M.play_pause,
  play = M.play,
  pause = M.pause,
  next = M.next,
  prev = M.previous,
  previous = M.previous,
  stop = M.stop,
  shuffle = M.toggle_shuffle,
  ["repeat"] = M.toggle_repeat,
  copy = M.copy_link,
  link = M.copy_link,
  search = function(q)
    require("config.spotify_search").open(q)
  end,
  volume = function(v)
    M.volume(tonumber(v) or VOLUME_STEP)
  end,
  seek = function(v)
    M.seek(tonumber(v) or SEEK_STEP)
  end,
  playlists = function()
    require("config.spotify_library").playlists()
  end,
  login = function()
    require("config.spotify_auth").login()
  end,
  logout = function()
    require("config.spotify_auth").logout()
  end,
}

if vim.fn.has("mac") == 1 then
  vim.api.nvim_create_user_command("Spotify", function(opts)
    local action = opts.fargs[1] or "status"
    if action == "search" then
      -- Join the rest so multi-word queries work: `:Spotify search bohemian rhapsody`.
      require("config.spotify_search").open(table.concat(vim.list_slice(opts.fargs, 2), " "))
      return
    end
    local fn = ACTIONS[action]
    if fn then
      fn(opts.fargs[2])
    else
      vim.notify("Spotify: unknown action '" .. action .. "'", vim.log.levels.WARN)
    end
  end, {
    nargs = "*",
    desc = "Control Spotify (status|playpause|next|prev|stop|shuffle|repeat|volume|seek|copy)",
    complete = function(arglead)
      return vim.tbl_filter(function(a)
        return a:find(arglead, 1, true) == 1
      end, vim.tbl_keys(ACTIONS))
    end,
  })

  -- <leader>m = music namespace (reclaimed from bookmarks)
  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({ { "<leader>m", group = "music" } })
  end

  -- stylua: ignore start
  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
  end
  map("<leader>ms", M.status,         "Spotify status")
  map("<leader>mp", M.play_pause,     "Play/pause")
  map("<leader>mn", M.next,           "Next track")
  map("<leader>mb", M.previous,       "Previous track")
  map("<leader>mx", M.stop,           "Stop")
  map("<leader>my", M.copy_link,      "Copy track link")
  map("<leader>mk", function() M.volume(VOLUME_STEP) end,  "Volume up")
  map("<leader>mj", function() M.volume(-VOLUME_STEP) end, "Volume down")
  map("<leader>ml", function() M.seek(SEEK_STEP) end,      "Seek forward")
  map("<leader>mh", function() M.seek(-SEEK_STEP) end,     "Seek backward")
  map("<leader>mz", M.toggle_shuffle, "Toggle shuffle")
  map("<leader>mr", M.toggle_repeat,  "Toggle repeat")
  map("<leader>m/", function() require("config.spotify_search").open() end, "Search songs")
  map("<leader>mP", function() require("config.spotify_library").playlists() end, "Playlists")
  -- stylua: ignore end

  -- Pause polling while nvim is in the background; resume on return without
  -- toasting for a song that changed while we were away.
  vim.api.nvim_create_autocmd("FocusLost", {
    callback = function()
      poller.focused = false
      reschedule()
    end,
  })
  vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
      poller.focused = true
      poller.primed = false
      reschedule()
    end,
  })

  -- Start the ambient poller if anything passive wants live data.
  if M.config.statusline or M.config.notify_on_change then
    subscribe("ambient", M.config.poll.active_ms)
  end
end

return M
