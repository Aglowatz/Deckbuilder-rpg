#!/usr/bin/env bash
# Nov 25 night (Parts A.3 and F): the changed and new cards, measured in drafted decks (tools/draft_sim.gd --what=card: each deck as
# drafted, and with one copy of the card in place of its weakest pick, against the same rivals on the same seeds). Each card is
# measured twice, AFTER the change (the data as it is) and BEFORE it (the card files of the tag pre-nov25-night, swapped in for the
# run and put back after), one Godot process per batch with a 20-minute limit (a batch over the limit is killed and logged).
# The decks are Classic Draft decks (--challenge=open: the card mode reads a Path set only for a Shuffle House table).
#   bash tools/run_nov25n_card_sims.sh [games=2] [seeds=3]
# Tables: docs/design/sim/nov25n/card_<id>_<after|before>.md; log: _logs/nov25n/card_sims.log
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
GAMES="${1:-2}"; SEEDS="${2:-3}"
OUT=docs/design/sim/nov25n
mkdir -p _logs/nov25n "$OUT" _tmp_tools/nov25n_cards_now
LOG=_logs/nov25n/card_sims.log
# card id | Path set | the story's Path limit | level
CARDS="NB-06|necrocrat+beefcake|2|14 N-19|necrocrat|2|12 B-19|beefcake|2|12 B-13|beefcake|2|12 B-23|beefcake|2|12 N-20|necrocrat|2|12 N-10|necrocrat|2|12 R-10|refusemancer|2|12 R-01|refusemancer|2|12"
# the new cards (Part F): measured after only (there is no before)
NEW_CARDS="B-39|beefcake|2|12 N-39|necrocrat|2|12 R-38|refusemancer|2|12 G-36|gourmand|2|12 C-41|beefcake+gourmand|2|12"
run() {
	local name="$1"; shift
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/draft_sim.gd -- "$@" --games=$GAMES --seeds=$SEEDS --out=res://$OUT/$name.md > "_logs/nov25n/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
}
measure() {
	local tag="$1"
	for row in $CARDS; do
		IFS='|' read -r id paths most level <<< "$row"
		run "card_${id}_$tag" --what=card --challenge=open --card=$id --paths=$paths --max_paths=$most --level=$level
	done
}
measure after
for row in $NEW_CARDS; do
	IFS='|' read -r id paths most level <<< "$row"
	run "card_${id}_after" --what=card --challenge=open --card=$id --paths=$paths --max_paths=$most --level=$level
done
# BEFORE: the old card files (cost, text, script) in place for the run
for row in $CARDS; do
	IFS='|' read -r id _rest <<< "$row"
	cp "data/cards/$id.tres" "_tmp_tools/nov25n_cards_now/$id.tres"
	git show "pre-nov25-night:data/cards/$id.tres" > "data/cards/$id.tres"
done
measure before
for row in $CARDS; do
	IFS='|' read -r id _rest <<< "$row"
	cp "_tmp_tools/nov25n_cards_now/$id.tres" "data/cards/$id.tres"
done
echo "$(date +%H:%M:%S) all card batches finished; card files restored" >> "$LOG"
