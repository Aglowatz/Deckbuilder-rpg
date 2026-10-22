#!/usr/bin/env bash
# Apparel Part 1 (docs/art/cosmetics.md): rebuilds the four cloak sets (REDCAPE, PATCHWORK, TATTERED, ROYAL) from the hero's own frames, their normal maps and icons,
# and re-imports. Pass --only=ROYAL,... to rebuild some, --masks=true to write the cloak masks as overlays into _art_source/cloak_masks/.
# Run from the project root: bash tools/make_cloaks.sh [--only=...] [--masks=true]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . -s res://tools/make_cloaks.gd -- "$@" 2>&1 | grep -E "make_cloaks|PLAYER_CLOAK|luminance|mask overlays|ERROR|SCRIPT"
"$GODOT" --headless --path . -s res://tools/sprite_normals.gd -- --only=PLAYER_CLOAK_REDCAPE,PLAYER_CLOAK_PATCHWORK,PLAYER_CLOAK_TATTERED,PLAYER_CLOAK_ROYAL --force=true --hats=false 2>&1 | grep -i -E "normal|written|ERROR"
"$GODOT" --headless --path . --import >/dev/null 2>&1
echo "make_cloaks: done (bash tools/import_cosmetics.sh prints which items are ready)"
