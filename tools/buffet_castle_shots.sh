#!/usr/bin/env bash
# Fable Nov 16c (Part 4): shots of the Endless Buffet for the evening pass - the castle (the Test Kitchen) from the entrance, the hub and
# its own forecourt, the entrance's trees, the west edge where the gravy river meets the outer gravy, at the default and the Low camera.
# Writes _screenshots/p4_<tag>_<place>[_low].png. One Godot at a time; about 6 minutes.
# Usage: bash tools/buffet_castle_shots.sh <tag> [place ...]     (tag: before / after; places: entrance hub road forecourt west west_south east north_west; default all)
cd "$(dirname "$0")/.."
tag="${1:-after}"
shift
places="${*:-entrance hub road forecourt west west_south east north_west}"
shot() { # name pos [extra]
	SHOT_RES=1920x1080 bash tools/shot.sh res://scenes/buffet_zone.tscn "p4_${tag}_$1" --size=1920x1080 --wait=8 --quiet=true --popups=false --pos="$2" "${@:3}" 2>&1 | grep -E "screenshot saved|SCRIPT ERROR|Parse Error" | head -3
}
for place in $places; do
	case "$place" in
		entrance) pos=50,84 ;;
		hub) pos=52,75 ;;
		road) pos=45,40 ;;
		forecourt) pos=57,13 ;;
		west) pos=8.5,50.5 ;;
		west_south) pos=9,64 ;;
		east) pos=92,38.5 ;;
		north_west) pos=12,10 ;;
		*) echo "unknown place $place"; continue ;;
	esac
	shot "$place" "$pos"
	shot "${place}_low" "$pos" --set=camera_angle:3
done
