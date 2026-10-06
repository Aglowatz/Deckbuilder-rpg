#!/usr/bin/env bash
# The card importer (docs/card_pipeline.md). Flags: --write (write the card/token resources), --clean (with --write: delete
# resources of cards no longer in the sheets), --stamp (record the sheet's current rules-text hash in each script header).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/import_cards.gd -- "$@" 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
