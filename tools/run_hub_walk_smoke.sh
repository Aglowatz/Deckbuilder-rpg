#!/usr/bin/env bash
# Hub walk smoke (Oct 16, Block 3h): every zone road blocked and open, in and back, the Capital road, the Undercroft; windowed, real input.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/hub_walk_smoke.log"
mkdir -p _screenshots/hub_walk_smoke
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/hub_walk_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^hub_walk_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "hub_walk_smoke: script errors found"; code=1; fi
exit $code
