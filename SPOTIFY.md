# Spotify integration

DIY Spotify control for macOS, driven entirely through AppleScript (`osascript`).
Lives in `lua/config/spotify.lua`, loaded from `init.lua`. Namespace: `<leader>m`
(music). No external plugin dependency.

## Why AppleScript

Spotify's macOS app ships a full AppleScript dictionary, so transport, volume,
seeking, shuffle/repeat and "play this URI" all work locally with **zero auth**.
Anything that touches **search, your library, the queue, or device switching**
is not in the AppleScript dictionary — those require the **Spotify Web API**
(OAuth token + refresh), which is a bigger lift documented separately below.

Legend: ✅ done · 🟢 AppleScript (cheap) · 🔵 Web API (needs OAuth)

---

## 1. Transport — 🟢 (done)

- [x] Play / pause toggle — `<leader>mp`
- [x] Play — `:Spotify play`
- [x] Pause — `:Spotify pause`
- [x] Next track — `<leader>mn`
- [x] Previous track — `<leader>mb`
- [x] Stop — `<leader>mx`
- [x] Volume up / down (10pt step, clamped 0–100) — `<leader>mk` / `<leader>mj`
- [x] Seek within track (±10s, clamped) — `<leader>ml` / `<leader>mh`
- [x] Toggle shuffle — `<leader>mz`
- [x] Toggle repeat — `<leader>mr`
- [x] `:Spotify <action> [value]` command mirroring the keymaps + completion
- [ ] Mute / unmute toggle (remember pre-mute volume)

## 2. Display & ambient — 🟢

- [x] Live status float (`:Spotify` / `<leader>ms`) — polls every 1s, shows
      state, track/artist/album, and a progress bar; auto-stops on close
- [ ] Now-playing component in statusline / winbar (always visible)
- [ ] Toast notification when the track changes (background poller)
- [ ] Album art inside the float (image.nvim / kitty / sixel / chafa)
- [ ] In-float mini-player keymaps (space = pause, j/k = skip, etc.)
- [ ] Copy current track's Spotify URL / share link to clipboard

## 3. Play specific things — 🟢

- [ ] Paste a `spotify:` URI or share link → play it immediately
- [ ] Quick-launch picker of hardcoded favourite playlist/album URIs

## 4. Search & library — 🔵 (needs Web API / OAuth)

- [ ] Search tracks / albums / playlists → snacks/telescope picker → play
- [ ] Browse your playlists → pick → play
- [ ] Like / save current track to library (one key)
- [ ] Add track to the queue (AppleScript can't queue — API only)
- [ ] Recently played / recommendations picker
- [ ] Device switching (Spotify Connect: laptop ↔ phone ↔ speaker)

## 5. Spicy / nice-to-have

- [ ] Lyrics panel (external lyrics API, synced to player position) 🔵
- [ ] Focus mode: auto-play a "deep work" playlist on entering Zen mode (`<leader>z`) 🟢
- [ ] Pomodoro tie-in: pause music on break 🟢
- [ ] Persist / restore last volume across sessions 🟢

---

## Build order

1. **Transport** (section 1) — high value, all AppleScript. ← starting here
2. Now-playing statusline + track-change toast (section 2).
3. Play-by-URI + favourites picker (section 3).
4. Web API layer (OAuth token storage + refresh) → unlocks section 4.
5. Spicy extras (section 5) as the mood takes.

## Notes & gotchas

- **macOS only.** Everything is guarded behind `vim.fn.has("mac")`.
- **Reserved words:** short AppleScript identifiers like `st` are reserved —
  use verbose variable names in scripts.
- **Locale decimals:** `player position` / `duration` may come back with a comma
  decimal separator; numbers are normalised (`,` → `.`) before parsing.
- **`is running`** is used so we never force-launch Spotify when it's closed.
