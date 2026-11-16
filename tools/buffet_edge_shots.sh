#!/usr/bin/env bash
# Fable Nov 16b (Part 5): shots of the Endless Buffet's edges - the front (south) edge, the east forest and the entrance, each at the
# default and the Low camera. Writes _screenshots/p5_<tag>_<place>[_low].png. One Godot at a time; about 4 minutes.
# Usage: bash tools/buffet_edge_shots.sh <tag>      (e.g. before, after)
cd "$(dirname "$0")/.."
tag="${1:-after}"
shot() { # name pos [extra]
	SHOT_RES=1920x1080 bash tools/shot.sh res://scenes/buffet_zone.tscn "p5_${tag}_$1" --size=1920x1080 --wait=8 --quiet=true --popups=false --pos="$2" "${@:3}" 2>&1 | grep -E "screenshot saved|SCRIPT ERROR|Parse Error" | head -3
}
for cam in default low; do
	extra=""; suffix=""
	if [ "$cam" = "low" ]; then extra="--set=camera_angle:3"; suffix="_low"; fi
	shot "front${suffix}" 66,73 $extra
	shot "east${suffix}" 92.5,58 $extra
	shot "east_north${suffix}" 92.5,26 $extra
	shot "entrance${suffix}" 50,86 $extra
done
