#!/usr/bin/env bash
# Nov 18 evening (Part 1): the D.N.A. at the brief's spots - arrival, hub, the Hall's stair (front, both sides, close and far), the elevator
# walls (front, both sides, close), both cubicle farms, the breakroom and the time clock - at the default (Cinematic) and Low cameras.
# One Godot at a time. Usage: bash tools/dna_nov18c_shots.sh <tag> [only-spot-substring]
#   -> docs/overnight_shots/nov18c/p1_<tag>_<spot>_<cam>.jpg
cd "$(dirname "$0")/.."
tag="${1:-after}"
only="${2:-}"
out=docs/overnight_shots/nov18c
mkdir -p "$out"
# name  pos  extra args (--yaw = swing round the hero, + from the east; --dist = distance ratio)
rows=(
	"arrival|46.5,62.5|"
	"hub|45.5,52|"
	"stair_front_close|45.5,5.5|--dist=0.7"
	"stair_front_far|45.5,9|--dist=1.4"
	"stair_west_close|43,5|--yaw=-65 --dist=0.7"
	"stair_west_far|43,6|--yaw=-65 --dist=1.4"
	"stair_east_close|48,5|--yaw=65 --dist=0.7"
	"stair_east_far|48,6|--yaw=65 --dist=1.4"
	"lifts_front|45,19|"
	"lifts_behind|45,12.5|"
	"lifts_west_close|40,18|--yaw=-65 --dist=0.7"
	"lifts_east_close|51,18|--yaw=65 --dist=0.7"
	"farm_a|17,36|"
	"farm_b|71,36|"
	"breakroom|26,54|"
	"time_clock|20,53|"
)
for row in "${rows[@]}"; do
	IFS='|' read -r spot pos extra <<< "$row"
	if [ -n "$only" ] && [[ "$spot" != *"$only"* ]]; then continue; fi
	for cam in 0 3; do
		cn=$([ "$cam" = 0 ] && echo default || echo low)
		name="n18c_p1_${tag}_${spot}_${cn}"
		timeout 300 bash tools/shot.sh res://scenes/dna_zone.tscn "$name" --pos="$pos" --nohud=true --wait=4 --set=camera_angle:$cam $extra $SHOT_EXTRA >/dev/null 2>&1
		python - "_screenshots/$name.png" "$out/p1_${tag}_${spot}_${cn}.jpg" <<'EOF'
import sys
from PIL import Image
Image.open(sys.argv[1]).convert('RGB').save(sys.argv[2], quality=82)
EOF
	done
done
ls "$out" | grep "p1_${tag}_" | wc -l
