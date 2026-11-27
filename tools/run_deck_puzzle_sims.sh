#!/usr/bin/env bash
# Nov 26 night (Part A2): Octavia's deck-building puzzles in batches - one puzzle per batch (at most 12 decks = variants), each a fresh
# Godot process with a 20-minute limit (a batch that runs over is killed and logged, and the next one starts). --record=1 keeps one
# winning line per puzzle in data/arena/deck_puzzle_lines.json.
#   bash tools/run_deck_puzzle_sims.sh [games=12] [label=final]
# Tables: docs/design/sim/nov26n/puzzles_<label>_<id>.md; log: _logs/nov26n/puzzle_sims.log
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
GAMES="${1:-12}"; LABEL="${2:-final}"
mkdir -p _logs/nov26n docs/design/sim/nov26n
LOG=_logs/nov26n/puzzle_sims.log
for id in deckpuzzle_tea_garden deckpuzzle_velvet_rope deckpuzzle_last_ride deckpuzzle_confetti deckpuzzle_all_in; do
	echo "$(date +%H:%M:%S) start $id" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/deck_puzzle_sim.gd -- --only=$id --games=$GAMES --record=1 --out=res://docs/design/sim/nov26n/puzzles_${LABEL}_$id.md > "_logs/nov26n/puzzle_${LABEL}_$id.log" 2>&1
	code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $id" >> "$LOG"; else echo "$(date +%H:%M:%S) done $id (exit $code)" >> "$LOG"; fi
done
echo "$(date +%H:%M:%S) all puzzle batches finished ($LABEL)" >> "$LOG"
