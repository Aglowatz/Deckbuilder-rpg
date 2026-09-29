#!/usr/bin/env bash
# FINAL: the whole new brief's flow with human-style input, end to end (see tools/
# final_flow_smoke.gd's header). Run alone (windowed, real viewport needed for injected input).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/final_flow_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 res://tools/final_flow_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^final_flow_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "final_flow_smoke: script errors found"; code=1; fi
exit $code
