#!/usr/bin/env bash
# Endless Buffet walk smoke (the slice, Part E): the bridge and the walk into the Grand Dining Hall, every quest NPC and the vendor, the interactables, the quiz,
# Dinner in a Dash, the taste test, the stew pot, the Walk-In Freezer (the Omakase's door, sealed and unlocked), the Test Kitchen gate, the giant chest and the
# lever, and the walk back out over the bridge to town, with real input, windowed; screenshots in _screenshots/buffet_walk/. Run alone (one Godot process at a
# time). Exit code 0 = every check passed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/buffet_walk_smoke.log"
mkdir -p _screenshots/buffet_walk
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/buffet_walk_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^buffet_walk_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "buffet_walk_smoke: script errors found"; code=1; fi
exit $code
