#!/usr/bin/env bash
# Story playthrough bot (Oct 16, Block 5a): new game to Primm's defeat with a pass/fail list; windowed, real input plus debug helpers.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/story_playthrough.log"
mkdir -p _screenshots/story_playthrough
timeout 900 "$GODOT" --path . --resolution 1600x900 res://tools/story_playthrough_launcher.tscn -- "$@" > "$out" 2>&1
code=$?
grep -E "^playthrough:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "story_playthrough: script errors found"; code=1; fi
exit $code
