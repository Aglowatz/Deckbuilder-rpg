#!/usr/bin/env bash
# Nov 26 night (Part A2): Octavia's Puzzle Tables (the board, each table's "Before the fight" panel). One Godot window at a time;
# JPGs in docs/overnight_shots/nov26n/.   bash tools/nov26n_shots.sh [only=<name part>]   SHOT_RES=1280x720 for the small window
cd "$(dirname "$0")/.."
OUT=docs/overnight_shots/nov26n
mkdir -p "$OUT"
ONLY="${1:-}"
shot() {
	local name="$1"; shift
	[ -n "$ONLY" ] && [[ "$name" != *"$ONLY"* ]] && return
	bash tools/shot.sh res://scenes/town.tscn "$name" "$@" > /dev/null 2>&1
	if [ -f "_screenshots/$name.png" ]; then
		python -c "from PIL import Image; Image.open('_screenshots/$name.png').convert('RGB').save('$OUT/$name.jpg', quality=86)"
		echo "shot $name"
	else
		echo "MISSING $name"
	fi
}
shot pA2_puzzle_tables_new --open=puzzles:0 --quiet=true --wait=5 --noroamers=true
shot pA2_puzzle_tables_one_won --open=puzzles:1 --quiet=true --wait=5 --noroamers=true
for n in 1 2 3 4 5; do
	shot pA2_before_the_fight_$n --open=puzzle_brief:$n --quiet=true --wait=5 --noroamers=true
done
