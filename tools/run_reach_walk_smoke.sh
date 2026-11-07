#!/usr/bin/env bash
# Reach walk smoke (Fix pass Nov 7, item 2): from the spawn to every shop and exit in Crosspath and each zone hub, planned then walked with WASD.
#   bash tools/run_reach_walk_smoke.sh        REACH_AREAS=town,refusemancer bash tools/run_reach_walk_smoke.sh
# Report: _screenshots/reach_walk/report.md
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
mkdir -p _screenshots/reach_walk
out="$(pwd)/_screenshots/reach_walk/stdout.log"
timeout 2400 "$GODOT" ${GODOT_ARGS:-} --path . --resolution 1600x900 res://tools/reach_walk_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^reach_walk_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "reach_walk_smoke: script errors found"; code=1; fi
exit $code
