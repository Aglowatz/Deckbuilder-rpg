#!/usr/bin/env bash
# Capital pass (Oct 17): the same spots before and after each part, from the default camera (Cinematic, Normal) and Overview (Far), plus top-down
# plans of both halves (green = where the hero can stand, red = solid circles, yellow = anchors). One Godot at a time (each shot is its own run).
# The ten paint-over cameras (CapitalLayout.PO_CAMERAS) hold the gate open and the enemies still, every district broken unless a flag says so.
# Usage: bash tools/capital_pass_shots.sh <phase> [prefix,prefix,...]   ->  docs/art/capital_pass/<phase>/<name>.jpg
cd "$(dirname "$0")/.."
phase="${1:-before}"
only="${2:-}"
out="docs/art/capital_pass/$phase"
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
	SHOT_RES=1280x720 timeout 300 bash tools/shot.sh res://scenes/capital_zone.tscn "cpp_$name" --size=1280x720 --nohud=true --clean=true --jpg=true --wait=3 --still=true "$@" 2>&1 | grep -E "saved|SCRIPT ERROR"
	[ -f "_screenshots/cpp_$name.jpg" ] && mv "_screenshots/cpp_$name.jpg" "$out/$name.jpg"
}
both() {
	local name="$1"; shift
	shot "${name}_default" --set=$DEFAULT "$@"
	shot "${name}_overview" --set=$OVERVIEW "$@"
}
# top-down plans (no fog, nothing culled)
shot "plan_outside" --top=60,97,70 --plan=true --nofog=true --gate=true --set=depth_of_field:false
shot "plan_inside" --top=60,36,74 --plan=true --nofog=true --gate=true --set=depth_of_field:false
shot "plan_west" --top=4,66,30 --plan=true --nofog=true --set=depth_of_field:false
# the ten paint-over cameras
for r in gate_road resistance_camp rift_fields ruined_outpost gate_plaza transit_yards hungry_quarter grave_row the_reek palace_approach; do
	both "po_$r" --at=po_$r --gate=true
done
# restored districts (the four Paths freed)
for r in transit_yards hungry_quarter grave_row the_reek; do
	shot "restored_$r" --at=po_$r --gate=true --paths=true --set=$DEFAULT
done
# the front wall, the gate shut, the west edge and the hole, the castle from both halves, the map's edges
both "wall_front_west" --pos=30,84
both "wall_front_east" --pos=88,84
shot "gate_closed_default" --pos=60,86 --set=$DEFAULT
both "west_edge_south" --pos=4,90
both "west_strip" --pos=-3.5,70
shot "hole_far_default" --pos=8,88 --set=$DEFAULT
shot "hole_close_default" --pos=-3.5,61.5 --set=$DEFAULT
shot "hole_close_overview" --pos=-3.5,60.5 --set=$OVERVIEW
both "hole_inside" --pos=5,62 --gate=true
both "castle_outside" --pos=60,92 --gate=true
both "castle_side_west" --pos=36,16 --gate=true
both "castle_side_east" --pos=84,16 --gate=true
both "edge_south" --pos=30,119
both "edge_east" --pos=115,100
both "inside_west_wall" --pos=10,20 --gate=true
both "inside_north_wall" --pos=100,6 --gate=true
both "ward" --pos=101,18 --gate=true
both "tunnel_mouth" --pos=96,82
# Part E: the end of the hidden strip and the road out
shot "strip_end_default" --pos=-3.5,54.5 --set=$DEFAULT
shot "road_out_overview" --pos=60,119 --set=$OVERVIEW
ls "$out" | wc -l
