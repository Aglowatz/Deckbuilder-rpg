#!/usr/bin/env bash
# Before/after screenshots of an area: bash tools/zone_shots.sh <scene> <name> [extra shot args]. "Before" runs with NO_STYLE=1 (the pre-Brief-12 look).
cd "$(dirname "$0")/.."
scene="$1"; name="$2"; shift 2
mkdir -p _screenshots/visual_slice/areas
NO_STYLE=1 bash tools/shot.sh "$scene" "area_${name}_before" --wait=3 --nohud=true "$@" 2>&1 | grep -E "SCRIPT"
bash tools/shot.sh "$scene" "area_${name}_after" --wait=3 --nohud=true "$@" 2>&1 | grep -E "SCRIPT"
cp "_screenshots/area_${name}_before.png" "_screenshots/area_${name}_after.png" _screenshots/visual_slice/areas/
