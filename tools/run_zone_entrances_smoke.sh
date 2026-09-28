#!/usr/bin/env bash
# New brief, Part C: regression test for the 5 map-edge zone entrances - walks to each one with
# injected input and checks locked/unlocked state and the real town<->zone scene change.
# Run alone (windowed, real viewport + real SceneManager scene changes needed).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/zone_entrances_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 res://tools/zone_entrances_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^zone_entrances_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "zone_entrances_smoke: script errors found"; code=1; fi
exit $code
