#!/usr/bin/env bash
# One screenshot of a 2D+3D screen for the graphics loop: bash tools/ui_shot.sh <scene> <area> <tag> [extra shot args]
# (dungeon maps, battle backdrops). Output: _screenshots/graphics_loop/<area>/<tag>.png
cd "$(dirname "$0")/.."
scene="$1"; area="$2"; tag="$3"; shift 3
taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
mkdir -p "_screenshots/graphics_loop/$area"
bash tools/shot.sh "$scene" "graphics_loop/$area/$tag" --wait=3 "$@" 2>&1 | grep -E "SCRIPT|saved"
