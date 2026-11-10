#!/usr/bin/env bash
# NPC visibility probe (Fable pass Nov 10, Part 1.3): the hero on every talk point, the default and the Low camera, sight lines to the NPC's
# feet / chest / head / plate against every mesh.   bash tools/run_npc_visibility_probe.sh      NPC_AREAS=gourmand,town to limit it
# Report: _screenshots/npc_visibility/report.md (+ a screenshot per failing NPC and camera; NPC_SHOTS_ALL=1 for every one)
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
mkdir -p _screenshots/npc_visibility
out="$(pwd)/_screenshots/npc_visibility/stdout.log"
timeout 2400 "$GODOT" ${GODOT_ARGS:-} --path . --resolution 1600x900 res://tools/npc_visibility_probe_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^npc_visibility_probe:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "npc_visibility_probe: script errors found"; code=1; fi
exit $code
