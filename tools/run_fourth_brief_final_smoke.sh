#!/usr/bin/env bash
# FINAL (fourth brief): the whole brief's flow with human-style input - buy basic equipment ->
# equip -> verify its effect in a real battle -> dev shrine to level 10 -> confirm the equipment
# vendor's advanced stock unlocked -> open a hidden equipment chest -> attempt the Graveyard.
# Screenshots every new/changed screen to _screenshots/ (git-ignored). Run alone (windowed, real
# viewport + real SceneManager scene changes needed) - this one plays several real battles with
# BattlePilot, so it takes a while.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/fourth_brief_final_smoke.log"
mkdir -p _screenshots
timeout 540 "$GODOT" --path . --resolution 1600x900 res://tools/fourth_brief_final_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^fourth_brief_final_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "fourth_brief_final_smoke: script errors found"; code=1; fi
exit $code
