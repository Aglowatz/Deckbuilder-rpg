#!/usr/bin/env bash
# Fable Nov 24 (Part 6, a leftover of the big pass): an in-game shot of every dungeon map, at its door and two rooms in, so the
# traced walkway lines (tools/map_curves.py) are seen as the game draws them. One Godot at a time.
#   bash tools/nov24_map_shots.sh [ID ...]     -> docs/overnight_shots/nov24b/maps/map_<ID>.jpg
cd "$(dirname "$0")/.."
out=docs/overnight_shots/nov24b/maps
mkdir -p "$out"
ids="${*:-D-TUT D-HOG D-TTK D-HFA D-ROT D-PC S-BEEF S-IRON S-GOUR S-NECRO S-REF S-CAP S-PASTE S-TOWN D-LAB S-GALLERY D-SHUFFLE}"
for id in $ids; do
	timeout 300 bash tools/shot.sh res://scenes/dungeon_map.tscn "map_$id" --dungeon=$id --progress=2 --jpg=true --wait=3 --clean=true 2>&1 | grep -E "saved|SCRIPT ERROR"
	[ -f "_screenshots/map_$id.jpg" ] && mv "_screenshots/map_$id.jpg" "$out/map_$id.jpg"
done
ls "$out" | wc -l
