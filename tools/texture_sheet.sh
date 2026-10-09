#!/usr/bin/env bash
# bash tools/texture_sheet.sh <name> <ids...|all> : 2x2-tiled contact sheet of the painted albedos -> docs/art/screens/textures/sheet_<name>.png
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . -s res://tools/texture_sheet.gd -- "$@" 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
