#!/usr/bin/env bash
# Playtest release smoke: title/version, New Game, F8 feedback report, pause menu, save/load (windowed, injected input; run alone).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/release_smoke.log"
mkdir -p _screenshots
timeout 240 "$GODOT" --path . --resolution 1600x900 res://tools/release_smoke.tscn > "$out" 2>&1
code=$?
grep -E "^release_smoke:|SCRIPT ERROR" "$out"
exit $code
