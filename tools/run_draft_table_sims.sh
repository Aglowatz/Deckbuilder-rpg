#!/usr/bin/env bash
# Fable Nov 24 (Part 7.1 and Part 6): the Shuffle House's tables in batches, one Godot process at a time, each batch a fresh
# process with a 20-minute limit (a batch that runs over is killed and logged, and the next one starts). A batch is at most
# 30 variants (a variant: one drafted deck against its three opponents).
#   bash tools/run_draft_table_sims.sh [what=tables|card|rivals|all] [games=4]
# tables: Classic and High Rollers, six Path sets (four single Paths, two pairs) x 2 drafts = 12 variants a batch (a variant
#         is three sets of games, about 25 s each: 30 variants do not fit 20 minutes), two batches each, before Primm (one
#         or two Paths) - and one batch each after Primm (three- and four-Path sets, 9 variants).
# card:   Bomb in the Pack by itself (Part 6): Beefcake drafts with and without one copy.
# rivals: the zone drafts' rivals, a longer measurement (Part 6): four Paths x 3 drafts = 12 variants a batch, four batches.
# Tables: docs/design/sim/nov24/table_*.md; log: _logs/nov24/table_sims.log
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
WHAT="${1:-all}"; GAMES="${2:-4}"
mkdir -p _logs/nov24 docs/design/sim/nov24
LOG=_logs/nov24/table_sims.log
SETS="beefcake,gourmand,necrocrat,refusemancer,beefcake+necrocrat,gourmand+refusemancer"
LATE="beefcake+gourmand+necrocrat,gourmand+necrocrat+refusemancer,beefcake+gourmand+necrocrat+refusemancer"
run() {
	local name="$1"; shift
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/draft_sim.gd -- "$@" --games=$GAMES --out=res://docs/design/sim/nov24/$name.md > "_logs/nov24/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
}
if [ "$WHAT" = tables ] || [ "$WHAT" = all ]; then
	for challenge in open high; do
		for from in 0 2; do
			run "table_${challenge}_$from" --what=rivals --challenge=$challenge --paths=$SETS --seeds=2 --seed_from=$from --max_paths=2
		done
		run "table_${challenge}_late" --what=rivals --challenge=$challenge --paths=$LATE --seeds=3 --seed_from=0 --max_paths=4 --level=22
	done
fi
if [ "$WHAT" = card ] || [ "$WHAT" = all ]; then
	run "card_bomb_in_the_pack" --what=card --card=B-38 --paths=beefcake --seeds=5
fi
if [ "$WHAT" = rivals ] || [ "$WHAT" = all ]; then
	for part in 0 3 6 9; do
		run "zone_rivals_$part" --what=rivals --seeds=3 --seed_from=$part
	done
fi
echo "$(date +%H:%M:%S) all batches finished ($WHAT)" >> "$LOG"
