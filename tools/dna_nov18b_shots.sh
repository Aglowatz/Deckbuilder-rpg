#!/usr/bin/env bash
# Nov 18 day (Part 6): the D.N.A. at eight spots, default (Cinematic) and Low cameras. One Godot at a time.
# Usage: bash tools/dna_nov18b_shots.sh <tag> [extra shot args, e.g. --pitch_bonus=0]   -> docs/overnight_shots/nov18b/p6_<tag>_<spot>_<cam>.jpg
cd "$(dirname "$0")/.."
tag="${1:-after}"; shift
out=docs/overnight_shots/nov18b
mkdir -p "$out"
for row in "arrival 46.5,62.5" "hub 45.5,52" "door 45.5,5.5" "mid1 45,35" "mid2 26,47" "aisle_a 17,36" "aisle_b 71,36" "maze 18,13"; do
	set -- $row
	for cam in 0 3; do
		cn=$([ "$cam" = 0 ] && echo default || echo low)
		name="n18b_p6_${tag}_${1}_${cn}"
		timeout 300 bash tools/shot.sh res://scenes/dna_zone.tscn "$name" --pos="$2" --nohud=true --wait=4 --set=camera_angle:$cam "${@:3}" $SHOT_EXTRA >/dev/null 2>&1
		python - "_screenshots/$name.png" "$out/p6_${tag}_${1}_${cn}.jpg" <<'EOF'
import sys
from PIL import Image
Image.open(sys.argv[1]).convert('RGB').save(sys.argv[2], quality=84)
EOF
	done
done
ls "$out" | grep "p6_${tag}_" | wc -l
