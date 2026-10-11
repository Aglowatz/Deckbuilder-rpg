#!/usr/bin/env bash
# Zone title card screenshots: every area's banner at the given window size(s) (the banner shows with --card=true; photographed once it has slid in).
# Usage: bash tools/zone_card_shots.sh [WxH ...]   (default 1600x900 1024x768)  ->  _screenshots/zone_cards/<area>_<WxH>.png
cd "$(dirname "$0")/.."
mkdir -p _screenshots/zone_cards
sizes=("$@")
[ ${#sizes[@]} -eq 0 ] && sizes=(1600x900 1024x768)
for size in "${sizes[@]}"; do
	shot() { # name scene
		bash tools/shot.sh "$2" "zone_cards/${1}_${size}" --size="$size" --card=true --wait=2.4 | grep -E "SCRIPT ERROR|Parse Error|saved"
	}
	shot start res://scenes/starting_area.tscn
	shot town res://scenes/town.tscn
	shot gainlands res://scenes/gainlands_zone.tscn
	shot dna res://scenes/dna_zone.tscn
	shot buffet res://scenes/buffet_zone.tscn
	shot dump res://scenes/heap_zone.tscn
	shot capital res://scenes/capital_zone.tscn
done
