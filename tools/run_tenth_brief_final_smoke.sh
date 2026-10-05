#!/usr/bin/env bash
# FINAL (brief 10): the Capital, the Castle, the boss and the ending with human-style input. Screenshots in _screenshots/brief10/. Run alone (windowed).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/tenth_brief_final_smoke.log"
mkdir -p _screenshots/brief10
timeout 1500 "$GODOT" --path . --resolution 1600x900 res://tools/tenth_brief_final_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^tenth_brief_final_smoke:|SCRIPT ERROR" "$out"
exit $code
