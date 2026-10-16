#!/usr/bin/env bash
# The corruption gradient in a walk north from the hub to the Rotheart's root gate (Cinematic / Normal, no UI): _screenshots/<prefix>_grad_<n>_<spot>.png and one
# strip docs/art/heap_slice/<prefix>_gradient.jpg.
#   bash tools/heap_gradient_shots.sh <prefix>
cd "$(dirname "$0")/.."
prefix="${1:-cur}"
spots="po_hub po_stream land_center po_wetlands main_dungeon"
n=0; inputs=""
for s in $spots; do
	n=$((n+1))
	bash tools/shot.sh res://scenes/heap_zone.tscn ${prefix}_grad_${n}_$s --at=$s --nohud=true --clean=true --wait=3.0 --set=camera_angle:0,camera_zoom:1.5 2>&1 | grep "saved\|SCRIPT ERROR"
	inputs="$inputs -i _screenshots/${prefix}_grad_${n}_$s.png"
done
ffmpeg -v error -y $inputs -filter_complex "[0]scale=640:-1[a];[1]scale=640:-1[b];[2]scale=640:-1[c];[3]scale=640:-1[d];[4]scale=640:-1[e];[a][b][c][d][e]hstack=inputs=5" -q:v 3 docs/art/heap_slice/${prefix}_gradient.jpg
