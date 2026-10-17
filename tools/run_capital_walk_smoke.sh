#!/usr/bin/env bash
# Capital walk smoke (the layout pass): the Gate Road, the gate, the camp, the tunnels, the rift fields, the west strip and the hidden hole, the Gate Plaza,
# the palace approach, every district and the Ward, the castle door, back out through the gate and home, with real input, windowed; screenshots in
# _screenshots/capital_walk/. Usage: bash tools/run_capital_walk_smoke.sh [camera 0|1|2] (Cinematic, Classic, Overview; default the saved setting).
# Run alone (one Godot process at a time). Exit code 0 = every check passed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
camera="${1:-}"
out="$(pwd)/_screenshots/capital_walk_smoke${camera:+_cam$camera}.log"
mkdir -p _screenshots/capital_walk
CAPITAL_WALK_CAMERA="$camera" timeout ${CAPITAL_WALK_TIMEOUT:-600} "$GODOT" --path . --resolution "${SMOKE_RES:-1600x900}" res://tools/capital_walk_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^capital_walk_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "capital_walk_smoke: script errors found"; code=1; fi
exit $code
