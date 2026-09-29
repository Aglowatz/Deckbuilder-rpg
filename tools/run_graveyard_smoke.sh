#!/usr/bin/env bash
# Fourth brief, Part F: regression test for The Restless Cairn - talks to it, checks the real
# battle starts with the right opponent (The Restless Dead), plays it out for real with
# BattlePilot, and checks the town-side result (dialogue, reward) matches what actually happened.
# A loss is an expected, handled outcome (the fight is intentionally very hard unequipped) - not
# a failure. Run alone (windowed, real viewport + real SceneManager scene changes needed).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/graveyard_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 res://tools/graveyard_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^graveyard_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "graveyard_smoke: script errors found"; code=1; fi
exit $code
