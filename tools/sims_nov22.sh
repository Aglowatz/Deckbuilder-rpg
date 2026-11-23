#!/usr/bin/env bash
# Fable Nov 22 night (Part 2): the three re-simulations after the owner's answers, one Godot at a time, each in a fresh process.
#   bash tools/sims_nov22.sh [bellows] [primm] [castle]        (default: all three)
#   1. bellows: Grand Bellows as the game plays him (scripted events and all) without "The Crowd Roars"  -> docs/design/sim/nov22/bellows.md
#   2. primm:   Primm's three duels on one HP pool with 0 to 4 leaders, 16 games per Path                -> docs/design/sim/nov22/primm_<allies>.md
#   3. castle:  whole runs along every route (8 per Path), the Archivists' Kettle on routes A and B      -> docs/design/sim/nov22/castle_runs.md
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.." || exit 1
out="docs/design/sim/nov22"
mkdir -p "$out"
what="${*:-bellows primm castle}"
for step in $what; do
	[ -f STOP_OVERNIGHT ] && exit 3
	case "$step" in
		bellows)
			"$GODOT" --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --filter=arena:arena_marshal --games=24 --seed=7000 --out="res://$out/bellows.md" > /dev/null 2>&1
			echo "== bellows"; grep -E "^\| Arena" "$out/bellows.md" ;;
		primm)
			for allies in none beefcake gourmand necrocrat refusemancer beefcake,gourmand necrocrat,refusemancer beefcake,gourmand,necrocrat beefcake,gourmand,necrocrat,refusemancer; do
				[ -f STOP_OVERNIGHT ] && exit 3
				name=$(echo "$allies" | tr ',' '+')
				"$GODOT" --headless --path . -s res://tools/run_balance_sim.gd -- --what=sequence --filter=boss:primm --games=16 --seed=7000 --allies="$allies" --out="res://$out/primm_${name}.md" > /dev/null 2>&1
				echo "== primm $allies"; grep -E "^\|" "$out/primm_${name}.md" | head -12
			done ;;
		castle)
			"$GODOT" --headless --path . -s res://tools/castle_runs_nov21.gd -- --runs=8 --seed=7000 --out="res://$out/castle_runs.md" > /dev/null 2>&1
			echo "== castle"; grep -E "^\|" "$out/castle_runs.md" ;;
	esac
done
