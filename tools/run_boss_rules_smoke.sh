#!/usr/bin/env bash
# Daytime Oct 19: Grand Bellows and Shiro show the "Before the fight" brief, Continue starts the duel, the HUD and the enemy seat carry the rules.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/boss_rules_smoke.log"
mkdir -p _screenshots
timeout 200 "$GODOT" --path . --resolution 1600x900 res://tools/boss_rules_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^boss_rules_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced\|RID allocations\|leaked\|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "boss_rules_smoke: script errors found"; code=1; fi
exit $code
