#!/usr/bin/env bash
# Regression test for bug A1 ("human turns get skipped"): plays a battle with the human seat
# driven only by injected mouse input, for at least 6 full turns. Run alone (windowed, real
# viewport needed for injected input) - see docs/progress.md for why.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/battle_human_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 res://tools/battle_human_turns_smoke.tscn > "$out" 2>&1
code=$?
grep -E "^battle_human_turns_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "battle_human_turns_smoke: script errors found"; code=1; fi
exit $code
