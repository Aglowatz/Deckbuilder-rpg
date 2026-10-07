#!/usr/bin/env bash
# Fit sheets for the dungeon maps (see tools/map_fit_sheet.gd): bash tools/map_fit_sheet.sh [D-HOG S-BEEF ...]  ->  _screenshots/map_fit/<ID>.png
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/map_fit_sheet.gd -- "$@" 2>&1 | grep -E "saved|no map|SCRIPT"
