#!/usr/bin/env bash
# Overnight Oct 16, Block 3h: the hub world screenshots for docs/art/hub_world/ (JPEG): each approach road, each zone entrance locked and open,
# the Capital on the horizon, the Undercroft cottage, and the map edge from all nine camera combinations. One Godot at a time (each shot is its
# own run). Usage: bash tools/hub_shots.sh [only-prefix]
cd "$(dirname "$0")/.."
out="docs/art/hub_world"
mkdir -p "$out"
only="${1:-}"
shot() {
	local name="$1"; shift
	if [ -n "$only" ] && [[ "$name" != $only* ]]; then return; fi
	timeout 300 bash tools/shot.sh res://scenes/town.tscn "hub_$name" --nohud=true --jpg=true --wait=5 "$@" 2>&1 | grep -E "saved|SCRIPT ERROR"
	[ -f "_screenshots/hub_$name.jpg" ] && mv "_screenshots/hub_$name.jpg" "$out/$name.jpg"
}
for z in refusemancer necrocrat beefcake gourmand final; do
	shot "road_$z" --at=portal_$z --set=camera_angle:1,camera_zoom:1.9
done
for z in beefcake necrocrat gourmand refusemancer; do
	shot "gate_${z}_locked" --at=npc_$z
	shot "gate_${z}_open" --at=npc_$z --gates=open
done
shot "capital_horizon" --at=portal_final --set=camera_angle:0,camera_zoom:1.9
shot "undercroft_house" --at=arena --zones=1
angles=(cinematic classic overview)
zooms=(close normal far)
zoom_values=(1.2 1.5 1.9)
for a in 0 1 2; do
	for z in 0 1 2; do
		shot "edge_${angles[$a]}_${zooms[$z]}" --pos=-12,40 --set=camera_angle:$a,camera_zoom:${zoom_values[$z]}
	done
done
ls "$out" | wc -l
