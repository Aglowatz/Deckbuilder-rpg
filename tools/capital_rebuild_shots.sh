#!/usr/bin/env bash
# Capital inner-city rebuild (Nov 1-2): the same standard spots every iteration, into docs/art/capital_rebuild_nov1/<phase>/<name>.jpg.
# The "ref" shot stands where the target paint-over (docs/art/paintovers/PAINTOVER-CAP-INNER-CITY.png) was framed: on the boulevard south of the
# fountain, looking north up the axis at the castle, from the Overview pitch and the Far zoom. The gate is open, enemies held, districts broken
# unless --paths=true / --flags are given. One Godot at a time (each shot is its own run).
#   bash tools/capital_rebuild_shots.sh <phase> [prefix,prefix,...] [extra shot args...]
cd "$(dirname "$0")/.."
phase="${1:-before}"
only="${2:-}"
shift 2 2>/dev/null
extra="$*"
out="docs/art/capital_rebuild_nov1/$phase"
mkdir -p "$out"
touch docs/art/capital_rebuild_nov1/.gdignore
DEFAULT="camera_angle:0,camera_zoom:1.5"
REF="camera_angle:2,camera_zoom:1.9"
MID="camera_angle:1,camera_zoom:1.9"
shot() {
	local name="$1"; shift
	if [ -n "$only" ]; then
		local hit=""
		IFS="," read -ra prefixes <<< "$only"
		for prefix in "${prefixes[@]}"; do [[ "$name" == $prefix* ]] && hit=1; done
		[ -z "$hit" ] && return
	fi
	SHOT_RES=1280x720 timeout 300 bash tools/shot.sh res://scenes/capital_zone.tscn "crb_$name" --size=1280x720 --nohud=true --clean=true --jpg=true --wait=3 --still=true --gate=true "$@" $extra 2>&1 | grep -E "saved|SCRIPT ERROR"
	[ -f "_screenshots/crb_$name.jpg" ] && mv "_screenshots/crb_$name.jpg" "$out/$name.jpg"
}
# the reference framing (the target's camera) and the same spot from the play camera
shot "ref" --pos=60,66 --set=$REF
shot "ref_mid" --pos=60,66 --set=$MID
shot "ref_play" --pos=60,66 --set=$DEFAULT
# the standard spots
shot "gate_plaza" --at=po_gate_plaza --set=$DEFAULT
shot "inner_gate" --pos=60,68 --set=$DEFAULT
shot "boulevard" --pos=60,44 --set=$DEFAULT
shot "fountain" --pos=60,63 --set=$MID
shot "palace_approach" --at=po_palace_approach --set=$DEFAULT
shot "transit_yards" --at=po_transit_yards --set=$DEFAULT
shot "hungry_quarter" --at=po_hungry_quarter --set=$DEFAULT
shot "grave_row" --at=po_grave_row --set=$DEFAULT
shot "the_reek" --at=po_the_reek --set=$DEFAULT
shot "overview" --pos=60,70 --set=$REF
ls "$out" | wc -l
