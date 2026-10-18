#!/usr/bin/env bash
# Gainlands walk smoke (Part G of the corrective pass, updated for Gainlands v2): the bridge, the plaza, the Iron Cave, the left road over the west
# span and up the mesa stairs to the House of Gains gate, the sealed Swolympus gate and the walk back out to town, with real input, windowed; screenshots in _screenshots/gainlands_walk/. Run alone (one Godot
# process at a time). Exit code 0 = every check passed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/gainlands_walk_smoke.log"
mkdir -p _screenshots/gainlands_walk
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/gainlands_walk_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^gainlands_walk_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "gainlands_walk_smoke: script errors found"; code=1; fi
exit $code
