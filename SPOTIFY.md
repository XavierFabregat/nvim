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

- [x] Live status float (`:Spotify` / `<leader>ms`) — shows state,
      track/artist/album and a progress bar; live via the shared poller
- [x] Now-playing component in the statusline (lualine_x) — green, click to
      play/pause, hidden when stopped/closed (`lua/plugins/lualine.lua`)
- [x] Toast notification when the track changes (shared poller, deduped by id)
- [x] In-float mini-player keymaps — `space` play/pause, `h`/`l` prev/next,
      `+`/`-` volume, `s`/`r` shuffle/repeat, `y` copy link, `q` close
- [x] Copy current track's share link — `<leader>my`, float `y`, `:Spotify copy`
- [ ] Album art inside the float — parked: Warp has no inline-image protocol;
      would need `chafa` (coloured Unicode blocks) or a kitty/ghostty/wezterm switch

### Architecture note

A single **refcounted, focus-gated poller** drives the float, statusline and
toast (no competing timers). It polls at the fastest interval any subscriber
asks for (float 1s, ambient 2s), backs off to 10s when Spotify is closed, and
stops entirely when nvim loses focus. Tune via `M.config` at the top of
`lua/config/spotify.lua`.

## 3. Play specific things — 🟢

- [ ] Paste a `spotify:` URI or share link → play it immediately
- [ ] Quick-launch picker of hardcoded favourite playlist/album URIs

## 4. Search & library — 🔵 (needs Web API)

- [x] **Search tracks → play** — live snacks picker (`<leader>m/`, `:Spotify
      search <query>`), `<CR>` plays the pick. See "Search setup" below.
- [x] **Browse your playlists → play** — `<leader>mP` / `:Spotify playlists`.
      PKCE login (once), reads `/me/playlists`, plays via AppleScript. See
      "Library setup" below.
- [ ] Like / save current track to library (add scope + endpoint)
- [ ] Add track to the queue (`me/player/queue`, needs Premium)
- [ ] Recently played / recommendations picker
- [ ] Device switching (Spotify Connect — needs Premium)

### Search setup

Search uses the **Client Credentials** flow — an app-only token, no user login,
no redirect server. We search over HTTP and **play the result via AppleScript**
(`play track <uri>`). The flip side: client-credentials can't touch your
library/playlists/queue — those need the heavier user OAuth (PKCE) still to come.

One-off: create an app at developer.spotify.com, then export your credentials
(e.g. in `~/.zshrc`, never committed):

```sh
export SPOTIFY_CLIENT_ID="…"
export SPOTIFY_CLIENT_SECRET="…"
```

The token is cached in memory for its ~1h lifetime and silently re-fetched.
Code: `lua/config/spotify_search.lua`.

### Library setup (PKCE, for playlists)

Reading your library needs **user OAuth** — Authorization Code + **PKCE** (no
secret). Hybrid design: **read via the Web API, play via AppleScript** — so no
Premium needed and the existing playback path is reused.

One-off: in the same Spotify app, add this exact **Redirect URI**:

```
http://127.0.0.1:8888/callback
```

Then `<leader>mP` (or `:Spotify playlists`) triggers a one-time browser login: a
local loopback server on `127.0.0.1:8888` catches the redirect, exchanges the
code for tokens, and stores them at `stdpath("data")/spotify_nvim_token.json`
(chmod 600, never committed). The access token is silently refreshed thereafter.

- `:Spotify login` / `:Spotify logout` — manage the session.
- Scopes requested: `playlist-read-private playlist-read-collaborative
  user-library-read`.
- Code: `lua/config/spotify_auth.lua` (OAuth) + `lua/config/spotify_library.lua`
  (playlist picker).

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
