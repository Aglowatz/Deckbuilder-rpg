#!/usr/bin/env bash
# Brief 13: new-game look, tailor, wardrobe and persistence end to end with human-style input. Screenshots in _screenshots/brief13/. Run alone (windowed).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/thirteenth_smoke.log"
mkdir -p _screenshots/brief13
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/thirteenth_brief_final_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^thirteenth_smoke:|SCRIPT ERROR" "$out"
exit $code
