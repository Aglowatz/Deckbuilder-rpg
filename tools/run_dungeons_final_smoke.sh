#!/usr/bin/env bash
# FINAL (dungeon list): D-TUT and D-HOG start to boss (including the Iron-less Prison rescue) and one side dungeon via its quest, through the real UI.
# Screenshots in _screenshots/dungeons/. Run alone (windowed).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/dungeons_final_smoke.log"
mkdir -p _screenshots/dungeons
timeout 1500 "$GODOT" --path . --resolution 1600x900 res://tools/dungeons_final_launcher.tscn > "$out" 2>&1
gcode=$?
grep -E "^dungeons_final_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "dungeons_final_smoke: script errors found"; gcode=1; fi
exit $gcode
