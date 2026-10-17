#!/usr/bin/env bash
# Crosspath pass (Oct 17): the same audit spots before and after each part, from the default camera (Cinematic, Normal) and Overview (Far),
# plus the top-down plan with the walkable ground, the blockers and the anchors. One Godot at a time (each shot is its own run).
# Usage: bash tools/crosspath_shots.sh <phase> [prefix,prefix,...]  (only the shots whose names start with one of the prefixes)   ->  docs/art/crosspath_pass/<phase>/<name>.jpg
cd "$(dirname "$0")/.."
phase="${1:-before}"
only="${2:-}"
out="docs/art/crosspath_pass/$phase"
mkdir -p "$out"
DEFAULT="camera_angle:0,camera_zoom:1.5"
OVERVIEW="camera_angle:2,camera_zoom:1.9"
shot() {
	local name="$1"; shift
	if [ -n "$only" ]; then
		local hit=""
		IFS="," read -ra prefixes <<< "$only"
		for prefix in "${prefixes[@]}"; do [[ "$name" == $prefix* ]] && hit=1; done
		[ -z "$hit" ] && return
	fi
	timeout 300 bash tools/shot.sh res://scenes/town.tscn "cp_$name" --nohud=true --jpg=true --wait=5 "$@" 2>&1 | grep -E "saved|SCRIPT ERROR"
	[ -f "_screenshots/cp_$name.jpg" ] && mv "_screenshots/cp_$name.jpg" "$out/$name.jpg"
}
both() {
	local name="$1"; shift
	shot "${name}_default" --set=$DEFAULT "$@"
	shot "${name}_overview" --set=$OVERVIEW "$@"
}
shot "plan" --top=25,27,110 --plan=true --nocull=true --nofog=true --set=depth_of_field:false
shot "top" --top=25,27,110 --nocull=true --nofog=true --set=depth_of_field:false
both "square" --pos=25.2,19.5
both "west_street" --pos=9,15
both "east_street" --pos=44,15
both "gate_road" --pos=25.2,-1
both "champions" --pos=25.2,29
both "well" --pos=6.5,27.5
both "fields_south" --pos=18,50
both "fields_west" --pos=-8,30
both "lakeshore" --pos=50,40
both "uplands" --pos=12,-8
both "alley" --at=hidden_vendor --found=harbor_chest
both "undercroft" --at=arena --zones=1
# Part C: the vendors round the square, seen from inside it
shot "vendors_north_default" --pos=25.2,7.5 --set=$DEFAULT
shot "vendors_west_default" --pos=19.0,15.5 --set=$DEFAULT
shot "vendors_east_default" --pos=31.4,15.5 --set=$DEFAULT
shot "alley_close_default" --pos=35.8,1.6 --found=harbor_chest --set=$DEFAULT
for z in refusemancer necrocrat beefcake gourmand final; do
	shot "gate_${z}_locked" --at=npc_$( [ "$z" = final ] && echo gate || echo $z ) --set=$DEFAULT
	[ "$z" != final ] && shot "gate_${z}_open" --at=npc_$z --gates=open --set=$DEFAULT
done
ls "$out" | wc -l
