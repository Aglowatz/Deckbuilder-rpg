#!/usr/bin/env bash
# "import textures": painted TEX-/DEC- art. Copies from texture_dir in data/source/art_config.cfg (read-only on the Drive), makes textures seamless, writes
# assets/art/textures/*_albedo.webp + *_nr.webp and assets/art/decals/*.webp, then re-imports. Options: --only=TEX-MAT-ROCK,DEC-MOSS  --skip-existing
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . -s res://tools/import_textures.gd -- "$@" 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
"$GODOT" --headless --path . --import >/dev/null 2>&1
