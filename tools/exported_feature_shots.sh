#!/usr/bin/env bash
# Overnight Oct 22, Part 5: the new things on the exported test pack, one shot each (docs/playtest/exported_oct22/):
# the wardrobe, hats and cloaks walking in every zone, the Deck Station at 1280x720 and 1920x1080, card crops in a battle on the
# Paste Works board, the painted Lab and Paste Works maps. Usage: bash tools/exported_feature_shots.sh [pck] [d3d12|vulkan]
cd "$(dirname "$0")/.."
root="$(pwd -W 2>/dev/null || pwd)"
pck="${1:-$root/builds/_export/TheWaywardPath.pck}"
# The shot script runs from disk (a release pack has no tools/), as tools/run_release_smoke_exported.sh does.
export SHOT_SCRIPT="$root/tools/screenshot.gd"
driver="${2:-d3d12}"
out="docs/playtest/exported_oct22"
mkdir -p "$out"
shot() {
	local name="$1" res="$2"; shift 2
	SHOT_RES="$res" bash tools/run_exported_suite.sh "$pck" "$driver" 1 shot --scene="$1" --name="$name" --size="$res" --no-save "${@:2}" > /dev/null 2>&1
	local png
	png=$(ls -t _screenshots/exported/"$name".png 2>/dev/null | head -1)
	if [ -n "$png" ]; then cp -f "$png" "$out/$name.png"; echo "shot $name: ok"; else echo "shot $name: MISSING (see _screenshots/exported/shot_${driver}_1.log)"; fi
}
shot wardrobe 1600x900 res://scenes/town.tscn --open=wardrobe --wear=cloak_royal,hat_wizard --wait=6
shot zone_gainlands 1600x900 res://scenes/gainlands_zone.tscn --wear=hat_tricorn,cloak_red_cape --wait=9
shot zone_dna 1600x900 res://scenes/dna_zone.tscn --wear=hat_bowler,cloak_patchwork --wait=9
shot zone_buffet 1600x900 res://scenes/buffet_zone.tscn --wear=hat_chef,cloak_tattered --wait=9
shot zone_heap 1600x900 res://scenes/heap_zone.tscn --wear=hat_wide_brim,cloak_royal --wait=11
shot zone_capital 1600x900 res://scenes/capital_zone.tscn --wear=hat_wizard,cloak_red_cape --wait=9
shot deck_station_720 1280x720 res://scenes/town.tscn --open=deck_slots --wait=6
shot deck_station_1080 1920x1080 res://scenes/town.tscn --open=deck_slots --wait=6
shot battle_paste_works 1600x900 res://scenes/battle.tscn --board=BB-S-PASTE --bot=4 --fast=true --wait=14
shot map_lab 1600x900 res://scenes/dungeon_map.tscn --dungeon=D-LAB --wait=5
shot map_paste_works 1600x900 res://scenes/dungeon_map.tscn --dungeon=S-PASTE --wait=5
