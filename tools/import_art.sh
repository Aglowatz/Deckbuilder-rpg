#!/usr/bin/env bash
# The card art importer (docs/art/art_pipeline.md). Drop PNG/JPG files named by Card ID in _art_inbox/, then run this.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/import_art.gd 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
# Newly written .webp files need Godot's import step before the game can load them.
"$GODOT" --headless --path . --import >/dev/null 2>&1
