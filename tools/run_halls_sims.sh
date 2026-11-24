#!/usr/bin/env bash
# Fable Nov 24 (Part 4 and Part 7): the Shuffled Halls sims in batches, one Godot process at a time, each batch a fresh process
# with a 20-minute limit (a batch that runs over is killed and logged, and the next one starts). A batch is at most 30 variants
# (rooms x player drafts, or routes x player drafts).
#   bash tools/run_halls_sims.sh [what=rooms|runs|all] [games=4] [extra sim flags, e.g. "--hp=-2 --level=20"] [tag=""]
# Rooms: six player drafts (four single Paths, two pairs) through the ten fight rooms, five rooms a batch (30 variants);
# the elite and boss rooms play slower, so they run alone. Runs: four routes, one route a batch (6 drafts).
# Tables: docs/design/sim/nov24/halls_<what>_<name><tag>.md; log: _logs/nov24/halls_sims.log
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
WHAT="${1:-all}"; GAMES="${2:-4}"; EXTRA="${3:-}"; TAG="${4:-}"
mkdir -p _logs/nov24 docs/design/sim/nov24
LOG=_logs/nov24/halls_sims.log
run() {
	local name="$1"; shift
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/halls_sim.gd -- "$@" > "_logs/nov24/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
}
if [ "$WHAT" = rooms ] || [ "$WHAT" = all ]; then
	for group in "tables_a:2,3,5,7,10" "tables_b:12,15" "trey:8" "dex:14" "octavia:19"; do
		name="halls_rooms_${group%%:*}$TAG"
		run "$name" --what=rooms --rooms=${group##*:} --games=$GAMES $EXTRA --out=res://docs/design/sim/nov24/$name.md
	done
fi
if [ "$WHAT" = runs ] || [ "$WHAT" = all ]; then
	for route in careful middle champions greedy; do
		name="halls_runs_$route$TAG"
		run "$name" --what=runs --routes=$route --games=$GAMES $EXTRA --out=res://docs/design/sim/nov24/$name.md
	done
fi
echo "$(date +%H:%M:%S) all batches finished ($WHAT$TAG)" >> "$LOG"
