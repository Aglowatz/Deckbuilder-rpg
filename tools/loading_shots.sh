#!/usr/bin/env bash
# Loading screen screenshots: one per area (start, town, gainlands, dna, buffet, dump, capital, dungeon, lab) at the given window size(s).
# Usage: bash tools/loading_shots.sh [WxH ...]   (default 1600x900 1024x768)  ->  _screenshots/loading/<area>_<WxH>.png
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
sizes=("$@")
[ ${#sizes[@]} -eq 0 ] && sizes=(1600x900 1024x768)
for size in "${sizes[@]}"; do
	"$GODOT" --path . --resolution "$size" -s res://tools/loading_shots.gd -- --size="$size" 2>&1 | grep -E "SCRIPT ERROR|Parse Error|saved|no loading"
done
