#!/usr/bin/env bash
# Remove CornerTube. The browser profile (sign-in) is kept unless --purge.
set -euo pipefail

rm -f "$HOME/.local/bin/cornertube"
rm -f "$HOME/.local/bin/cornertube-input"
rm -f "$HOME/.local/share/applications/cornertube.desktop"
rm -f "$HOME/.local/share/applications/cornertube-on-tv.desktop"
rm -f "$HOME/.local/share/applications/com.jjuanent.cornertube-input.desktop"
rm -f "$HOME/.local/share/icons/hicolor/scalable/apps/cornertube.svg"
rm -f "$HOME"/.local/share/icons/hicolor/*/apps/cornertube.png
gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true
PLUGIN_ID="wstunltd-sith002.cornertube"
rm -rf "$HOME/.config/omarchy/plugins/$PLUGIN_ID"
SHELL_JSON="$HOME/.config/omarchy/shell.json"
if [ -f "$SHELL_JSON" ] && command -v python3 >/dev/null 2>&1; then
  PLUGIN_ID="$PLUGIN_ID" SHELL_JSON="$SHELL_JSON" python3 - <<'PYEOF'
import json, os
p = os.environ["SHELL_JSON"]; pid = os.environ["PLUGIN_ID"]
try:
    d = json.load(open(p))
    right = d["bar"]["layout"]["right"]
    d["bar"]["layout"]["right"] = [x for x in right if x.get("id") != pid]
    json.dump(d, open(p, "w"), indent=2)
except Exception:
    pass
PYEOF
fi

HYPR_FILE="$HOME/.config/hypr/looknfeel.lua"
if [ -f "$HYPR_FILE" ] && grep -q ">>> cornertube" "$HYPR_FILE"; then
  python3 - "$HYPR_FILE" <<'PY'
import re, sys
p = sys.argv[1]
text = open(p).read()
text = re.sub(r"\n?-- >>> cornertube.*?-- <<< cornertube <<<\n?", "\n", text, flags=re.S)
open(p, "w").write(text)
PY
  echo "Hyprland rules removed from $HYPR_FILE"
fi

if [ "${1:-}" = "--purge" ]; then
  rm -rf "$HOME/.local/share/cornertube"
  echo "Profile purged."
else
  echo "Profile kept at ~/.local/share/cornertube (use --purge to delete it, including the YouTube sign-in)."
fi
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
echo "Uninstalled."
