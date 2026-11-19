#!/usr/bin/env bash
# Install CornerTube for the current user on an Omarchy/Hyprland machine.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install -Dm755 "$SRC/bin/cornertube" "$HOME/.local/bin/cornertube"
install -Dm755 "$SRC/bin/cornertube-input" "$HOME/.local/bin/cornertube-input"
install -Dm644 "$SRC/share/cornertube.desktop" "$HOME/.local/share/applications/cornertube.desktop"
install -Dm644 "$SRC/share/cornertube-on-tv.desktop" "$HOME/.local/share/applications/cornertube-on-tv.desktop"
# The desktop file name must match the GTK app id so the dock shows the icon.
install -Dm644 "$SRC/share/com.jjuanent.cornertube-input.desktop" "$HOME/.local/share/applications/com.jjuanent.cornertube-input.desktop"

# Icon: SVG plus rendered PNGs for the hicolor theme.
ICONS="$HOME/.local/share/icons/hicolor"
install -Dm644 "$SRC/share/icons/cornertube.svg" "$ICONS/scalable/apps/cornertube.svg"
if command -v rsvg-convert >/dev/null 2>&1; then
  for s in 32 48 64 128 256 512; do
    mkdir -p "$ICONS/${s}x${s}/apps"
    rsvg-convert -w "$s" -h "$s" "$SRC/share/icons/cornertube.svg" -o "$ICONS/${s}x${s}/apps/cornertube.png"
  done
fi
gtk-update-icon-cache -f -t "$ICONS" >/dev/null 2>&1 || true

# Omarchy bar plugin (the play icon in the top bar). Copies the plugin,
# adds it to the bar layout in shell.json, and enables it (best effort).
PLUGIN_ID="wstunltd-sith002.cornertube"
if [ -d "$SRC/omarchy-plugin/$PLUGIN_ID" ]; then
  mkdir -p "$HOME/.config/omarchy/plugins"
  rm -rf "$HOME/.config/omarchy/plugins/$PLUGIN_ID"
  cp -r "$SRC/omarchy-plugin/$PLUGIN_ID" "$HOME/.config/omarchy/plugins/"
  SHELL_JSON="$HOME/.config/omarchy/shell.json"
  if [ -f "$SHELL_JSON" ] && command -v python3 >/dev/null 2>&1; then
    PLUGIN_ID="$PLUGIN_ID" SHELL_JSON="$SHELL_JSON" python3 - <<'PYEOF'
import json, os
p = os.environ["SHELL_JSON"]; pid = os.environ["PLUGIN_ID"]
d = json.load(open(p))
right = d.setdefault("bar", {}).setdefault("layout", {}).setdefault("right", [])
if not any(x.get("id") == pid for x in right):
    right.append({"id": pid}); json.dump(d, open(p, "w"), indent=2); print("Bar layout: plugin added")
PYEOF
  fi
  if command -v omarchy >/dev/null 2>&1; then
    omarchy plugin enable "$PLUGIN_ID" >/dev/null 2>&1 && echo "Bar plugin enabled (restart the shell or re-login to see it)" || true
  fi
fi
mkdir -p "$HOME/.local/share/cornertube/profile"

# Hyprland window rules: append the managed block to the personal overrides
# file once (looknfeel.lua is loaded by ~/.config/hypr/hyprland.lua).
HYPR_FILE="$HOME/.config/hypr/looknfeel.lua"
touch "$HYPR_FILE"
if ! grep -q ">>> cornertube" "$HYPR_FILE"; then
  cp "$HYPR_FILE" "$HYPR_FILE.bak.cornertube"
  cat "$SRC/hypr/cornertube.lua" >> "$HYPR_FILE"
  echo "Hyprland rules added to $HYPR_FILE (backup: $HYPR_FILE.bak.cornertube)"
else
  echo "Hyprland rules already present in $HYPR_FILE"
fi

update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true

# Reload Hyprland so the rules apply without logging out (best effort).
if command -v hyprctl >/dev/null 2>&1; then
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
  export DISPLAY="${DISPLAY:-:0}"
  if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    sig="$(python3 - <<'PY' 2>/dev/null || true
import glob
for comm in glob.glob('/proc/[0-9]*/comm'):
    try:
        if open(comm).read().strip() in ('Hyprland', 'quickshell'):
            pid = comm.split('/')[2]
            for entry in open(f'/proc/{pid}/environ', 'rb').read().split(b'\0'):
                if entry.startswith(b'HYPRLAND_INSTANCE_SIGNATURE='):
                    print(entry.decode().split('=', 1)[1]); raise SystemExit
    except SystemExit:
        raise
    except Exception:
        pass
PY
)"
    [ -n "${sig:-}" ] && export HYPRLAND_INSTANCE_SIGNATURE="$sig"
  fi
  hyprctl reload >/dev/null 2>&1 && echo "Hyprland reloaded" || echo "Note: Hyprland reload skipped (no session found); rules apply at next login."
fi

echo "Installed. Launch 'CornerTube' from the Omarchy launcher, or run: cornertube"
echo "First launch only: sign in to YouTube in that window (the profile is kept in ~/.local/share/cornertube/profile)."
