#!/usr/bin/env bash
# Story still screenshots: all seven stills with their first caption, at the given window size(s).
# Usage: bash tools/story_still_shots.sh [WxH ...]   (default 1600x900 1024x768)  ->  _screenshots/stills/<id>_<WxH>.png
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
sizes=("$@")
[ ${#sizes[@]} -eq 0 ] && sizes=(1600x900 1024x768)
for size in "${sizes[@]}"; do
	"$GODOT" --path . --resolution "$size" -s res://tools/story_still_shots.gd -- --size="$size" 2>&1 | grep -E "SCRIPT ERROR|Parse Error|saved|no art"
done
