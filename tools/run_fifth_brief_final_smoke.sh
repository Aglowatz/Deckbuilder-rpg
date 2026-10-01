#!/usr/bin/env bash
# FINAL (fifth brief): town quests -> vendor -> D.N.A. -> courier hit -> slow-enemy battle -> heal ->
# buy card -> quiz -> matching -> puzzle -> chest -> mini dungeon, with human-style input and
# screenshots in _screenshots/brief5/. Run alone (windowed); plays real battles with BattlePilot.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/fifth_brief_final_smoke.log"
mkdir -p _screenshots/brief5
timeout 900 "$GODOT" --path . --resolution 1600x900 res://tools/fifth_brief_final_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^fifth_brief_final_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "fifth_brief_final_smoke: script errors found"; code=1; fi
exit $code
