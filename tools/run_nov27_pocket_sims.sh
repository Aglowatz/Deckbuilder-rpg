#!/usr/bin/env bash
# Nov 27 day (Part B): the Extra Pocket measured - paired runs with and without it, with heal items and with burn items, on the same
# decks and seeds, in drafts, the zone dungeons and the postgame. One headless Godot per batch, a 20-minute limit each (logged when killed).
#   bash tools/run_nov27_pocket_sims.sh [draft|zone|postgame|all] [only=<batch name part>]
# Rows: docs/design/sim/nov27/pocket_*.md; log: _logs/nov27/pocket.log. The sim's item policy makes the Pocket's free second use
# (SimItemPolicy.second_use_free), so "with" simply wears the Pocket.
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
WHAT="${1:-all}"; ONLY="${2:-}"
OUT=docs/design/sim/nov27
mkdir -p _logs/nov27 "$OUT"
LOG=_logs/nov27/pocket.log
run() {
	local name="$1"; shift
	[ -n "$ONLY" ] && [[ "$name" != *"$ONLY"* ]] && return
	[ -f STOP_OVERNIGHT ] && { echo "$(date +%H:%M:%S) STOP_OVERNIGHT: stopped before $name" >> "$LOG"; exit 3; }
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . "$@" > "_logs/nov27/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
	grep "^| " "_logs/nov27/$name.log" | tail -4 >> "$LOG"
}
if [ "$WHAT" = "draft" ] || [ "$WHAT" = "all" ]; then
	# Trey's zone drafts (level 12): each Path, the bare deck / two items / two items + the Pocket
	for p in beefcake gourmand necrocrat refusemancer; do
		run "draft_heal_$p" -s res://tools/draft_sim.gd -- --what=pocket --paths=$p --items=healing_salve,hearty_pie --games=3 --out=res://$OUT/pocket_draft_heal_$p.md
		run "draft_burn_$p" -s res://tools/draft_sim.gd -- --what=pocket --paths=$p --items=firebrand_charm,sharpening_stone --games=3 --out=res://$OUT/pocket_draft_burn_$p.md
	done
fi
if [ "$WHAT" = "zone" ] || [ "$WHAT" = "all" ]; then
	# the four zone dungeons, route B, one HP pool, each Path's reference deck and gear at the boss's level; items carried fight to fight
	for d in D-HOG D-TTK D-HFA D-ROT; do
		for items in heal burn; do
			for pocket in off on; do
				run "zone_${d}_${items}_${pocket}" -s res://tools/zone_runs_nov26.gd -- --dungeon=$d --route=B --runs=${ZONE_RUNS:-6} --items=$items --pocket=$pocket --seed=9100 --out=res://$OUT/pocket_zone_runs.md
			done
		done
	done
fi
if [ "$WHAT" = "postgame" ] || [ "$WHAT" = "all" ]; then
	# the postgame's key fights: the six late decks x aggro gear with / without the Pocket x heal / burn items, 2 games each
	run "post_lab" -s res://tools/postgame_hunt.gd -- --mode=fights --dungeon=D-LAB --fights=8,16 --decks=late --kits=aggro,aggro_pocket --items=heal,burn --games=2 --by_kit --out=res://$OUT/pocket_postgame.md
	run "post_gallery" -s res://tools/postgame_hunt.gd -- --mode=fights --dungeon=S-GALLERY --fights=6,10 --decks=late --kits=aggro,aggro_pocket --items=heal,burn --games=2 --by_kit --out=res://$OUT/pocket_postgame.md
	run "post_swol_vault" -s res://tools/postgame_hunt.gd -- --mode=fights --dungeon=S-BEEF --fights=2 --decks=late --kits=aggro,aggro_pocket --items=heal,burn --games=2 --by_kit --out=res://$OUT/pocket_postgame.md
	run "post_vault" -s res://tools/postgame_hunt.gd -- --mode=fights --dungeon=VAULT --decks=late --kits=aggro,aggro_pocket --items=heal,burn --games=2 --by_kit --out=res://$OUT/pocket_postgame.md
fi
echo "$(date +%H:%M:%S) pocket batches finished ($WHAT)" >> "$LOG"
