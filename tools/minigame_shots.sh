#!/usr/bin/env bash
# Fable Nov 16b (Part 2): shots of the four zone card minigames - "How to play", mid-game and the win panel of each, plus one game at
# 1280x720 and one with Large text. Writes _screenshots/p2_<game>_<state>.png. One Godot at a time. About 4 minutes.
# Fable Nov 16c: also the card quiz in each zone (quiz_gain quiz_buffet quiz_dump quiz_dna), prefix c1_.
# Usage: bash tools/minigame_shots.sh [game ...]   (reps order sort file quiz_gain quiz_buffet quiz_dump quiz_dna; default all)
cd "$(dirname "$0")/.."
games="${*:-reps order sort file quiz_gain quiz_buffet quiz_dump quiz_dna}"
shot() { # name size scene open state [extra]
	SHOT_RES="$2" bash tools/shot.sh "$3" "$1" --size="$2" --wait=7 --quiet=true --open="$4" --mg="$5" "${@:6}" 2>&1 | grep -E "screenshot saved|SCRIPT ERROR|Parse Error" | head -4
}
for game in $games; do
	case "$game" in
		reps) scene=res://scenes/gainlands_zone.tscn; open=minigame ;;
		order) scene=res://scenes/buffet_zone.tscn; open=minigame ;;
		sort) scene=res://scenes/heap_zone.tscn; open=minigame ;;
		file) scene=res://scenes/dna_zone.tscn; open=puzzle ;;
		quiz_gain) scene=res://scenes/gainlands_zone.tscn; open=quiz ;;
		quiz_buffet) scene=res://scenes/buffet_zone.tscn; open=quiz ;;
		quiz_dump) scene=res://scenes/heap_zone.tscn; open=quiz ;;
		quiz_dna) scene=res://scenes/dna_zone.tscn; open=quiz ;;
		*) echo "unknown game $game"; continue ;;
	esac
	prefix=p2; case "$game" in quiz_*) prefix=c1 ;; esac
	for state in how mid win lose; do
		shot "${prefix}_${game}_${state}" 1920x1080 "$scene" "$open" "$state"
	done
	shot "${prefix}_${game}_mid_720" 1280x720 "$scene" "$open" mid
	shot "${prefix}_${game}_mid_large_text" 1920x1080 "$scene" "$open" mid --set=text_cards:2,text_tooltips:2,text_dialogue:2
done
