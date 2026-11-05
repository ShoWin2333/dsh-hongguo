# Local fork notes — dsh-hongguo

Upstream: <https://github.com/frostming/dsh-hongguo> (branch `main`, imported 2026-11-05).
This directory is a local fork; it is **not** published anywhere and DSH installs it
from the tarball built here.

## Why a fork

- The upstream repo assumes macOS: covers are HEIC and converted with `sips`; there is
  no Windows path. Without a fix every poster is a placeholder glyph.
- The upstream entry points are intrusive for daily use: a permanent text button in the
  sidebar foot (it crowds the Remote button) and an invitation card above the composer
  while the agent runs.
- Installing straight from GitHub does not work here (schannel/TLS failures for `git` and
  `pnpm`; only the GitHub API is reachable from Node), so a local build/install step was
  needed anyway.

## What this fork changes

### Windows HEIC covers (`index.js`, `cover.ps1`)

`serveCover` used to call macOS `sips` for every HEIC poster. The fork dispatches by
platform: macOS still uses `sips`; Windows runs `cover.ps1`, which decodes the HEIC with
WIC (the Microsoft HEIF Image Extension) and re-encodes a 240 px JPEG at quality 70.
Needs the HEIF Image Extension installed (`Microsoft.HEIFImageExtension`).

### Entry point: the right sidebar's guide box (`client.js`)

- `sidebar.footer.action` registration removed — no permanent button, no truncated
  label beside Remote.
- The panel-list More-menu row and the left-sidebar panel-list row are gone as
  well: nothing is registered in the left column.
- The only entry is the right Sidebar guide box: the tab type registers `guide`
  (title 摸鱼短剧, one description line), so opening the right column shows the
  card on its 开始 page, and picking it opens the player tab. `sidebar.right.pane.tab`
  is unchanged (it is what draws the player).

### Composer invitation removed (`client.js`)

- The "Agent 干活中，刷一集？" dock card is gone (no chips, no dismiss button).
- Nothing is registered in `conversation.input.dock` at all: the plugin no longer
  observes session status, so a finished task does not pause or touch playback.
  The whole pause-all control path (`players`, pause control, `pausedByFinish`
  notice) was deleted with it.
- `autoPrompt` remains in the config schema for compatibility; it no longer has a
  visible effect.

## Build & install

```powershell
cd dsh-hongguo-fork
./build.ps1
```

`build.ps1` runs `npm install` (bundles `openhongguo`), packs `dsh-hongguo-<version>.tgz`
and copies it into `%USERPROFILE%\.dsh\profiles\desktop\`. Then install it through the
plugin manager (`install_bundle` with `file:./dsh-hongguo-<version>.tgz`), which reloads
the plugin in the running app.

## Upstream sync

`git remote add upstream https://github.com/frostming/dsh-hongguo` (if a clone with
network access is available) and diff against this tree; the Windows cover patch and the
two client.js changes are the whole delta.
