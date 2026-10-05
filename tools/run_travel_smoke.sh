#!/usr/bin/env bash
# Brief 10b: the Beefcake Rift Express and the return position after a battle, with human-style input. Screenshots in _screenshots/brief10b/. Run alone (windowed).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/travel_smoke.log"
mkdir -p _screenshots/brief10b
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/travel_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^travel_smoke:|SCRIPT ERROR" "$out"
exit $code
