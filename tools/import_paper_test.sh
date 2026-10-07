#!/usr/bin/env bash
# Papercraft test art: copies PAPER-*.png from the Drive (read-only) and writes assets/art/paper/*.webp (docs/art/papercraft_test.md).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . -s res://tools/import_paper_test.gd 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
"$GODOT" --headless --path . --import >/dev/null 2>&1
