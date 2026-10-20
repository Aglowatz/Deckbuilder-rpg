#!/usr/bin/env bash
# Oct 20: the Dev Menu in the live game (F10, tabs, travel, a menu fight won with Win now, a boss node, snapshots). Windowed; run alone.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/dev_menu_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1280x720 res://tools/dev_menu_smoke.tscn > "$out" 2>&1
code=$?
grep -E "^dev_menu_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "dev_menu_smoke: script errors found"; code=1; fi
exit $code
