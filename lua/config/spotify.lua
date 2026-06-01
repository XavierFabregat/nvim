-- DIY Spotify control for macOS via AppleScript (osascript).
-- Transport + a live status float, under the <leader>m namespace.
-- Roadmap & ideas: see SPOTIFY.md.

local M = {}

-- AppleScript: returns linefeed-separated fields, or "not_running".
-- `is running` does not launch Spotify, so a closed app stays closed.
-- NOTE: `st`/short tokens like it are AppleScript reserved words, hence verbose names.
local STATUS_SCRIPT = [[
if application "Spotify" is running then
  tell application "Spotify"
    set pState to player state as text
    set tName to name of current track
    set tArtist to artist of current track
    set tAlbum to album of current track
    set pPos to player position
    set tDur to (duration of current track) / 1000
    return pState & linefeed & tName & linefeed & tArtist & linefeed & tAlbum & linefeed & pPos & linefeed & tDur
  end tell
else
  return "not_running"
end if
]]

local STATE_ICON = { playing = "▶ Playing", paused = "⏸ Paused", stopped = "⏹ Stopped" }

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

-- Spotify returns floats using the system locale, so a comma decimal is possible.
local function to_num(v)
  return tonumber((tostring(v):gsub(",", "."))) or 0
end

local function fmt_time(seconds)
  seconds = math.floor(to_num(seconds))
  return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function progress_bar(pos, dur, width)
  pos, dur = to_num(pos), to_num(dur)
  local filled = dur > 0 and math.floor((pos / dur) * width + 0.5) or 0
  filled = math.max(1, math.min(width, filled))
  return string.rep("━", filled - 1) .. "●" .. string.rep("─", width - filled)
end

local function build_lines(info)
  if info.not_running then
    return { "", "  Spotify isn't running.", "" }
  end
  return {
    "",
    "  " .. (STATE_ICON[info.state] or info.state),
    "",
    "  ♫  " .. info.track,
    "  ♪  " .. info.artist,
    "  💿 " .. info.album,
    "",
    "  " .. fmt_time(info.pos) .. " " .. progress_bar(info.pos, info.dur, 22) .. " " .. fmt_time(info.dur),
    "",
  }
end

local state = { win = nil, buf = nil, timer = nil }

local POLL_MS = 1000

local function stop()
  if state.timer then
    state.timer:stop()
    if not state.timer:is_closing() then
      state.timer:close()
    end
    state.timer = nil
  end
  state.win, state.buf = nil, nil
end

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

local function set_lines(lines)
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
end

local function open(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  state.buf = buf

  local cfg = geometry(lines)
  cfg.style, cfg.border, cfg.title, cfg.title_pos = "minimal", "rounded", " Spotify ", "center"
  state.win = vim.api.nvim_open_win(buf, true, cfg)
  vim.wo[state.win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  set_lines(lines)

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      vim.api.nvim_win_close(state.win, true)
    end, { buffer = buf, nowait = true, silent = true })
  end
  -- Stop polling once the float is gone.
  vim.api.nvim_create_autocmd("BufWipeout", { buffer = buf, once = true, callback = stop })
end

local function render(info)
  local lines = build_lines(info)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    set_lines(lines)
    vim.api.nvim_win_set_config(state.win, geometry(lines))
  else
    open(lines)
  end
end

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
        })
      end
    end)
  end)
end

function M.status()
  fetch(function(info, err)
    if not info then
      vim.notify("Spotify: " .. (err or "osascript failed"), vim.log.levels.ERROR)
      return
    end
    render(info)

    -- Start polling so position advances and song changes show live.
    if not state.timer then
      state.timer = vim.uv.new_timer()
      state.timer:start(POLL_MS, POLL_MS, function()
        vim.schedule(function()
          if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
            stop()
            return
          end
          fetch(function(next_info)
            if next_info then
              render(next_info)
            end
          end)
        end)
      end)
    end
  end)
end

-- ── Transport ──────────────────────────────────────────────────────────────

local VOLUME_STEP = 10
local SEEK_STEP = 10

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
  volume = function(v)
    M.volume(tonumber(v) or VOLUME_STEP)
  end,
  seek = function(v)
    M.seek(tonumber(v) or SEEK_STEP)
  end,
}

if vim.fn.has("mac") == 1 then
  vim.api.nvim_create_user_command("Spotify", function(opts)
    local action = opts.fargs[1] or "status"
    local fn = ACTIONS[action]
    if fn then
      fn(opts.fargs[2])
    else
      vim.notify("Spotify: unknown action '" .. action .. "'", vim.log.levels.WARN)
    end
  end, {
    nargs = "*",
    desc = "Control Spotify (status|playpause|next|prev|stop|shuffle|repeat|volume|seek)",
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
  map("<leader>mk", function() M.volume(VOLUME_STEP) end,  "Volume up")
  map("<leader>mj", function() M.volume(-VOLUME_STEP) end, "Volume down")
  map("<leader>ml", function() M.seek(SEEK_STEP) end,      "Seek forward")
  map("<leader>mh", function() M.seek(-SEEK_STEP) end,     "Seek backward")
  map("<leader>mz", M.toggle_shuffle, "Toggle shuffle")
  map("<leader>mr", M.toggle_repeat,  "Toggle repeat")
  -- stylua: ignore end
end

return M
