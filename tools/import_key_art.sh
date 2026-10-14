#!/usr/bin/env bash
# The vendor-screen + key-art importer (docs/art/art_pipeline.md): copies the vendor-screen and key-art folders from the Drive folder in art_config.cfg (read-only).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . -s res://tools/import_key_art.gd 2>&1 | grep -v "leaked\|Leaked\|ObjectDB\|resources still in use\|at: \|^Godot Engine"
"$GODOT" --headless --path . --import >/dev/null 2>&1

# Folder import rules (docs/build_size.md): compression and right-sizing for the new art.
node "$(dirname "$0")/apply_import_rules.js" && "/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path "$(dirname "$0")/.." --import >/dev/null 2>&1
