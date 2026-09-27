#!/usr/bin/env bash
# Regression test for bug A2 ("NPC/vendor interaction does nothing"): walks to each NPC/vendor/
# station with injected input (E, Space and a left-click, across the different spots) and checks
# the right UI opens. Run alone (windowed, real viewport needed for injected input).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/town_interact_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 res://tools/town_interact_smoke.tscn > "$out" 2>&1
code=$?
grep -E "^town_interact_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "town_interact_smoke: script errors found"; code=1; fi
exit $code
