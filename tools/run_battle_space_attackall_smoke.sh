#!/usr/bin/env bash
# Human-input UI test for Part A (Battle UX): Space-to-advance and "Attack with All", driven only
# by injected mouse/keyboard input. Run alone (windowed, real viewport needed for injected input).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/battle_space_attackall_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 res://tools/battle_space_attackall_smoke.tscn > "$out" 2>&1
code=$?
grep -E "^battle_space_attackall_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "battle_space_attackall_smoke: script errors found"; code=1; fi
exit $code
