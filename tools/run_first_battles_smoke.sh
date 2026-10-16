#!/usr/bin/env bash
# Battle feel, Parts D and E: the intro dungeon's three battles as a brand-new player with the tips on, by mouse only, one
# at each battle speed. Run alone, windowed (injected input needs a real viewport). Pass a size (e.g. 1280x720) to check a
# smaller window.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
size="${1:-1600x900}"
out="$(pwd)/_screenshots/first_battles_smoke.log"
mkdir -p _screenshots
timeout 600 "$GODOT" --path . --resolution "$size" res://tools/first_battles_smoke.tscn > "$out" 2>&1
code=$?
grep -E "^first_battles_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "first_battles_smoke: script errors found"; code=1; fi
exit $code
