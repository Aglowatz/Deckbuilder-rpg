#!/usr/bin/env bash
# Three-angle screenshot set of one area for the graphics loop rubric (docs/art/graphics_loop.md).
# Usage: bash tools/area_shots.sh <scene> <area> <tag> [extra shot args, e.g. --at=spawn]
#   tag: "before" / "after" / "iter2"... Output: _screenshots/graphics_loop/<area>/<tag>_{a,b,c}.png (a = default high angle,
#   b = low three-quarter, c = reverse). Walking scenes accept --cam=x,y,z (camera offset from the hero); a per-angle --cam
#   already in the extra args wins for angle a. Kills any leftover Godot first and runs one Godot at a time.
cd "$(dirname "$0")/.."
scene="$1"; area="$2"; tag="$3"; shift 3
taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
taskkill //F //IM Godot_v4.7.2-stable_win64_console.exe >/dev/null 2>&1
mkdir -p "_screenshots/graphics_loop/$area"
bash tools/shot.sh "$scene" "graphics_loop/$area/${tag}_a" --wait=3 --nohud=true "$@" 2>&1 | grep -E "SCRIPT|saved"
bash tools/shot.sh "$scene" "graphics_loop/$area/${tag}_b" --wait=3 --nohud=true "$@" --cam=-8,5.5,7 2>&1 | grep -E "SCRIPT|saved"
bash tools/shot.sh "$scene" "graphics_loop/$area/${tag}_c" --wait=3 --nohud=true "$@" --cam=6,8,-9 2>&1 | grep -E "SCRIPT|saved"
