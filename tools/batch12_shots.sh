#!/usr/bin/env bash
# Batch 12 art import (Nov 6): one in-game screenshot per new image, one Godot at a time. Out: _screenshots/batch12/ (+ dialogue/, beats/).
# Run from the project root: bash tools/batch12_shots.sh [group ...]   groups: portraits stills world ui (default: all)
cd "$(dirname "$0")/.."
OUT=batch12
mkdir -p "_screenshots/$OUT"
groups=("$@")
[ ${#groups[@]} -eq 0 ] && groups=(portraits stills world ui)
s() { scene="$1"; name="$2"; shift 2; bash tools/shot.sh "$scene" "$OUT/$name" --wait=5 "$@" 2>&1 | grep -E "SCRIPT ERROR|saved" | head -3; }

for g in "${groups[@]}"; do case "$g" in
portraits)
	bash tools/dialogue_shots.sh res://scenes/town.tscn b12 \
		"portrait:NPC-FLEX@NPC-FLEX,portrait:NPC-FLEX@NPC-FLEX~reveal,portrait:CUT-FLEX,portrait:NPC-TOWNSFOLK,portrait:NPC-TOWNSFOLK-A,portrait:NPC-TOWNSFOLK-B,portrait:NPC-TOWNSFOLK-C,portrait:NPC-GYM-ATTENDANT,portrait:NPC-BRISKET,portrait:NPC-SIR-LOIN,portrait:NPC-CAPITAL-GUARD,portrait:NPC-PLAYER" --jpg=true
	;;
stills)
	"/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe" --path . --resolution 1600x900 res://tools/beat_shots.tscn -- --only=flex,rescue,primm_end,epilogue 2>&1 | grep -E "SCRIPT ERROR|saved" | tail -3
	bash tools/story_still_shots.sh 1600x900
	;;
world)
	s res://scenes/town.tscn crosspath_well --at=well --noroamers=true
	s res://scenes/town.tscn crosspath_market --at=market --noroamers=true
	s res://scenes/town.tscn crosspath_square --noroamers=true
	s res://scenes/capital_zone.tscn capital_fig --at=fig
	s res://scenes/capital_zone.tscn capital_rollo --at=rollo
	s res://scenes/capital_zone.tscn capital_crease_freed --at=fig --freed=true --flags=primm_defeated
	s res://scenes/gainlands_zone.tscn gainlands_freed_flex --freed=true
	s res://scenes/dna_zone.tscn dna_gerald --at=barnaby
	s res://scenes/dna_zone.tscn dna_kyle --at=matching
	s res://scenes/starting_area.tscn forest_brambles --pos=1.3,9.5 --quiet=true --nohud=true
	s res://scenes/starting_area.tscn wake_night --fresh=true --wait=3
	;;
ui)
	s res://scenes/town.tscn deck_station --open=deck
	for beast in "Unpaid Intern" "Hungry Scarecrow" "Correction Officer" "Undersecretary Vellum" "Intake Orderly"; do
		s res://scenes/town.tscn "bestiary_${beast// /_}" --open=bestiary "--beast=${beast// /_}"
	done
	s res://scenes/dungeon_map.tscn map_gallery --dungeon=S-GALLERY
	;;
esac; done
