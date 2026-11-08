#!/usr/bin/env bash
# Import Nov 8 (Batch 13): one in-game screenshot per new image, one Godot at a time. Out: _screenshots/nov8c/ (copied to docs/overnight_shots/nov8c/).
# Run from the project root: bash tools/batch13_shots.sh [group ...]   groups: boards town zones ui (default: all)
cd "$(dirname "$0")/.."
OUT=nov8c
mkdir -p "_screenshots/$OUT"
groups=("$@")
[ ${#groups[@]} -eq 0 ] && groups=(boards town zones ui)
s() { scene="$1"; name="$2"; shift 2; bash tools/shot.sh "$scene" "$OUT/$name" --wait=6 "$@" 2>&1 | grep -E "SCRIPT ERROR|saved" | head -3; }

for g in "${groups[@]}"; do case "$g" in
boards)
	s res://scenes/battle.tscn b13_board_gallery --board=BB-S-GALLERY --bot=4 --fast=true --wait=14
	s res://scenes/battle.tscn b13_board_gallery_alt --board=BB-S-GALLERY-ALT --bot=4 --fast=true --wait=14
	;;
town)
	s res://scenes/town.tscn b13_plinths_default --at=fountain --statues=true --noroamers=true --popups=false --quiet=true
	s res://scenes/town.tscn b13_plinths_two --at=fountain --zones=2 --noroamers=true --popups=false --quiet=true
	s res://scenes/town.tscn b13_plinths_low --at=fountain --statues=true --noroamers=true --popups=false --quiet=true --set=graphics_quality:0
	s res://scenes/town.tscn b13_thornwall_closed --at=npc_refusemancer --noroamers=true --popups=false
	s res://scenes/town.tscn b13_thornwall_withered --at=npc_refusemancer --gates=refusemancer --noroamers=true --popups=false
	s res://scenes/town.tscn b13_lever_crosspath --pos=7.2,54.2 --noroamers=true --popups=false
	s res://scenes/town.tscn b13_lever_crosspath_pulled --pos=7.2,54.2 --flags=vault_lever_pulled --noroamers=true --popups=false
	;;
zones)
	s res://scenes/gainlands_zone.tscn b13_lever_gainlands --at=beside:vault_lever
	s res://scenes/heap_zone.tscn b13_lever_dump --at=beside:vault_lever
	s res://scenes/heap_zone.tscn b13_dex_dump --at=quiz
	s res://scenes/gainlands_zone.tscn b13_dex_gainlands --at=quiz
	s res://scenes/gainlands_zone.tscn b13_quiz_gainlands --open=quiz
	s res://scenes/dna_zone.tscn b13_quiz_dna --open=quiz
	s res://scenes/gainlands_zone.tscn b13_repcounter --open=minigame
	;;
ui)
	s res://scenes/town.tscn b13_packs --open=packs
	s res://scenes/town.tscn b13_wardrobe --open=wardrobe
	s res://scenes/town.tscn b13_alchemist --open=alchemist
	s res://scenes/town.tscn b13_character_gear --open=character_gear --gear=dex_matching_pair --levelup=12 --popups=false
	bash tools/dialogue_shots.sh res://scenes/town.tscn b13 "portrait:NPC-DEX" --jpg=true 2>&1 | grep -E "SCRIPT ERROR|saved" | head -3
	;;
esac; done
