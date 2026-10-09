#!/usr/bin/env bash
# Painted ground-texture test art: copies TEX-*.png from the Drive (read-only), makes them seamless, writes assets/art/textures/*.webp (docs/art/texture_test.md).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . -s res://tools/import_texture_test.gd 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
"$GODOT" --headless --path . --import >/dev/null 2>&1
