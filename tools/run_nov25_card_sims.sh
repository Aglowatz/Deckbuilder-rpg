#!/usr/bin/env bash
# Fable Nov 25 (Part 6.10): the owner's changed cards, measured in drafted decks (tools/draft_sim.gd --what=card: each deck as
# drafted, and with one copy of the card in place of its weakest pick, against the same rivals on the same seeds). Each card is
# measured twice, AFTER the change (the data as it is) and BEFORE it (the card files of the tag pre-nov25, swapped in for the
# run and put back after), one Godot process per batch with a 20-minute limit (a batch over the limit is killed and logged).
#   bash tools/run_nov25_card_sims.sh [games=4] [seeds=5]
# Tables: docs/design/sim/nov25/card_<id>_<after|before>.md; log: _logs/nov25/card_sims.log
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
GAMES="${1:-4}"; SEEDS="${2:-5}"
OUT=docs/design/sim/nov25
mkdir -p _logs/nov25 "$OUT" _tmp_tools/nov25_cards_now
LOG=_logs/nov25/card_sims.log
# card id | Path set | the story's Path limit | level
CARDS="C-37|beefcake|2|12 GN-07|gourmand+necrocrat|2|14 GN-10|gourmand+necrocrat|2|14 NB-03|necrocrat+beefcake|2|14 GRN-03|gourmand+necrocrat+refusemancer|4|22 B-33|beefcake|2|14"
run() {
	local name="$1"; shift
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/draft_sim.gd -- "$@" --games=$GAMES --seeds=$SEEDS --out=res://$OUT/$name.md > "_logs/nov25/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
}
measure() {
	local tag="$1"
	for row in $CARDS; do
		IFS='|' read -r id paths most level <<< "$row"
		run "card_${id}_$tag" --what=card --card=$id --paths=$paths --max_paths=$most --level=$level
	done
}
measure after
# BEFORE: the old card files (cost, text, script) in place for the run
for row in $CARDS; do
	IFS='|' read -r id _rest <<< "$row"
	cp "data/cards/$id.tres" "_tmp_tools/nov25_cards_now/$id.tres"
	git show "pre-nov25:data/cards/$id.tres" > "data/cards/$id.tres"
done
measure before
for row in $CARDS; do
	IFS='|' read -r id _rest <<< "$row"
	cp "_tmp_tools/nov25_cards_now/$id.tres" "data/cards/$id.tres"
done
echo "$(date +%H:%M:%S) all card batches finished; card files restored" >> "$LOG"
