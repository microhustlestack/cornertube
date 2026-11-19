# TizenTube PiP for Omarchy Linux

YouTube TV as a true picture-in-picture app on an Omarchy (Hyprland) desktop:
a small video window that **floats, pins to every workspace, stays on top, and
keeps 16:9**, in the bottom-right corner of the screen.

Built for a Samsung TU690T TV that has no native PiP, where the Omarchy
machine (Tiny Sith 002, studio) uses the TV itself as its 4K monitor — the
desktop does the PiP the TV can't.

## What it is

TizenTube on the TV is Samsung's Cobalt YouTube app pointed at
`https://www.youtube.com/tv` through a local ad-blocking proxy (see the
`nativeID` args in its `config.xml`). This package runs that same YouTube TV
interface on the desktop, in a dedicated Chromium profile, and lets Hyprland
do the PiP part.

Two honest differences from the TV app:

- **Browsing mode is the regular YouTube TV UI.** Ads behave like normal
  YouTube in a browser; there is no TV-style proxy in front of it.
- **Play mode is ad-free.** `tizentube-pip play <url|search>` streams the
  video directly with mpv + yt-dlp — no browser, no ads, just the video in
  the pinned PiP window.

## The Play a Video chooser

`Play a Video (PiP)` (script `tizentube-pip-input`, a small GTK4 window) is
the front door. Type a YouTube search and it shows the top 5 results
**newest first**, each with a **thumbnail, title, channel, runtime and the
date it was posted** - click one and it plays video-only in the PiP corner.
Paste a full link instead and it plays that video directly, no list.
A search takes roughly 20 seconds because the posted dates come from a
full per-video lookup, not a guess.

It appears in the app launcher, in the **dock** (its desktop file is named
to match the window's app id, so the running window gets the same icon),
and as a **play icon in the Omarchy top bar** - the bar plugin lives in
`omarchy-plugin/` and `install.sh` wires it into `shell.json` for you.

Player controls in the PiP window (click it first): Space pauses, arrow
keys skip back and forward, 9 and 0 set volume, M mutes, F fullscreen,
Q closes. Omarchy's own PiP keys also apply: Super+Shift+P pin toggle,
Super+Alt+P next corner, Super+Alt+O cycle size.

## Install

```bash
./install.sh
```

That installs, for the current user only (no sudo):

- `~/.local/bin/tizentube-pip` — the launcher script
- `~/.local/share/applications/tizentube-pip.desktop` — "TizenTube PiP" in the Omarchy launcher
- `~/.local/share/applications/tizentube-on-tv.desktop` — "TizenTube on TV" (see below)
- A managed window-rule block appended to `~/.config/hypr/looknfeel.lua`
  (backup saved as `looknfeel.lua.bak.tizentube-pip`), then reloads Hyprland

Requirements (all standard on Omarchy): a Chromium-based browser,
`hyprctl`, `python3`. Play mode also needs `mpv` and `yt-dlp`. The chooser also needs `python3` with GTK4 (PyGObject), standard on Omarchy.

The browser is **Brave** by Juan's choice (2026-11-18); set
`TIZENTUBE_PIP_BROWSER=chromium` (or chrome) to use another one. Each
browser gets its own profile (`~/.local/share/tizentube-pip/profile-brave`,
`profile-chromium`, ...), so the YouTube sign-in is per browser — switching
browsers means signing in once in the new one.

## Use

- **Launcher:** open "TizenTube PiP" from the Omarchy app launcher.
- **Terminal:** `tizentube-pip`
- **First launch only:** sign in to YouTube in that window. The dedicated
  per-browser profile lives in `~/.local/share/tizentube-pip/profile-*`, so
  the sign-in persists and never mixes with your normal browser profile.
- **Play one video:** `tizentube-pip play https://www.youtube.com/watch?v=...`
  or `tizentube-pip play omarchy linux tutorial` (plays the first search hit)
- **Close the PiP windows:** `tizentube-pip stop`
- **Size / corner:** `TIZENTUBE_PIP_WIDTH`, `TIZENTUBE_PIP_HEIGHT`,
  `TIZENTUBE_PIP_POSITION=top-right|bottom-right` (defaults 960x540, bottom-right)

How the PiP is enforced, twice over:

1. Hyprland window rules (in `hypr/tizentube-pip.lua`) match the YouTube TV
   app window's url-derived class `chrome-www.youtube.com__tv-Default`
   (and mpv windows titled "TizenTube PiP"): float, pin, 960x540, keep
   aspect ratio, move to the bottom-right corner.
2. The launcher script also finds the new window in `hyprctl clients` and
   applies float / pin / resize / move directly — using this Hyprland's Lua
   dispatcher form (`hl.dsp.window.pin({...})` etc., the same pattern as
   Omarchy's own `omarchy-hyprland-window-pop`) — so it still lands as PiP
   if the rules were edited or removed.

## TizenTube on TV

`tizentube-pip tv` (or the "TizenTube on TV" launcher) runs the Tizen SDK
command that launches TizenTube on the studio TV:

```bash
sudo docker run --rm --network host vitalets/tizen-webos-sdk bash -c \
  'sdb connect 192.168.50.61 && sdb -s 192.168.50.61:26101 shell 0 was_execute xvvl3S1TT1.TizenTubeStandalone'
```

Notes: the TV's app id is `xvvl3S1TT1.TizenTubeStandalone` — verified from
the `config.xml` inside `TizenTubeCobalt.wgt` (v2.1.1) and from the
Apps2Samsung install log, **not** `xevl...`. Docker needs sudo on this
machine (the user is not in the `docker` group), and Developer Mode must be
on with the TV pointing at this machine's IP. Override the TV address with
`TIZENTUBE_TV_IP`.

## Uninstall

```bash
./uninstall.sh          # keeps the YouTube sign-in profile
./uninstall.sh --purge  # also deletes the profile
```

## Files

- `bin/tizentube-pip` — launcher / play / tv / stop script
- `share/*.desktop` — Omarchy launcher entries
- `hypr/tizentube-pip.lua` — the Hyprland window-rule block
- `install.sh`, `uninstall.sh`
