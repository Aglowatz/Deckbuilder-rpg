#!/usr/bin/env bash
# The dungeon list importer (docs/art/art_pipeline.md): data/source/dungeon_list.csv.csv -> data/dungeons/dungeons.json.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/import_dungeons.gd 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
