#!/usr/bin/env bash
# New brief (third), Part D: human-input e2e test for the hidden-tunnel tutorial skip - walks to
# the tunnel, interacts, picks an element, and confirms the result lands in town with a legal
# deck, the tutorial's own XP/gold, and the tutorial-complete flags. Run alone (windowed, real
# viewport needed for injected input).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/starting_area_tunnel_smoke.log"
mkdir -p _screenshots
timeout 120 "$GODOT" --path . --resolution 1600x900 res://tools/starting_area_tunnel_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^starting_area_tunnel_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "starting_area_tunnel_smoke: script errors found"; code=1; fi
exit $code
