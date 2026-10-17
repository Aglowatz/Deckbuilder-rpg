#!/usr/bin/env bash
# Crosspath walk smoke (Oct 17, Part E): the loop round the town, every vendor on the square, the alley, the lakeshore and dock, the Undercroft hatch; windowed, real input.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/crosspath_walk_smoke.log"
mkdir -p _screenshots/crosspath_walk_smoke
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/crosspath_walk_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^crosspath_walk_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "crosspath_walk_smoke: script errors found"; code=1; fi
exit $code
