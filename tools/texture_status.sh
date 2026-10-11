#!/usr/bin/env bash
# Rewrites the "Painted textures" section of docs/art/art_status.md and prints the IDs now in the game.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . -s res://tools/texture_status.gd 2>&1 | grep -E "IDS:|SCRIPT|Parse|ERROR: [^R1]"
