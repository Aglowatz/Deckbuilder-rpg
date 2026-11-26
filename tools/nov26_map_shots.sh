#!/usr/bin/env bash
# Nov 26 day (Part A): in-game shots of several dungeon maps, to compare the lines before and after the switch to straight lines.
#   bash tools/nov26_map_shots.sh <before|after> [ID ...]   -> docs/overnight_shots/nov26/maps/<tag>_<ID>.jpg
cd "$(dirname "$0")/.."
tag="${1:-after}"; shift
out=docs/overnight_shots/nov26/maps
mkdir -p "$out"
ids="${*:-S-TOWN D-PC D-SHUFFLE D-HOG D-TTK D-ROT S-GALLERY}"
for id in $ids; do
	timeout 300 bash tools/shot.sh res://scenes/dungeon_map.tscn "map_$id" --dungeon=$id --progress=2 --jpg=true --wait=3 --clean=true 2>&1 | grep -E "saved|SCRIPT ERROR"
	[ -f "_screenshots/map_$id.jpg" ] && mv "_screenshots/map_$id.jpg" "$out/${tag}_$id.jpg"
done
ls "$out"
