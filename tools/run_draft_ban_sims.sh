#!/usr/bin/env bash
# Fable big pass Nov 23 (Part 2): the draft ban sims in batches (against elite-level rivals with no HP bonus: the question is
# what each piece is worth, and boss-level rivals take twenty times as long a game)
# The draft ban sims in batches, one Godot process at a time, each batch a fresh process with a
# 20-minute limit (a batch that runs over is killed and logged, and the next one starts).
#   bash tools/run_draft_ban_sims.sh [batch size=4] [first piece=0] [last piece=200] [extra sim flags=--rarity_min=2] [items too=0]
# A piece takes about four minutes (48 games), so four fit a batch; the default measures the Epic and Legendary pieces only.
# Tables: docs/design/sim/nov23/ban_gear_<from>.md and ban_items.md; log: _logs/nov23/ban_sims.log
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
SIZE="${1:-4}"; FROM="${2:-0}"; LAST="${3:-200}"; EXTRA="${4---rarity_min=2}"; ITEMS="${5:-0}"
mkdir -p _logs/nov23 docs/design/sim/nov23
LOG=_logs/nov23/ban_sims.log
run() {
	local name="$1"; shift
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/draft_sim.gd -- "$@" > "_logs/nov23/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
}
at=$FROM
while [ "$at" -lt "$LAST" ]; do
	to=$((at + SIZE))
	name=$(printf "ban_gear_%03d" "$at")
	run "$name" --what=gear --seeds=1 --games=4 --skill=elite --hp=0 $EXTRA --from=$at --to=$to --out=res://docs/design/sim/nov23/$name.md
	# the pool is shorter than LAST: stop at the first batch that measured nothing
	if ! grep -q "^| .* | .* | .* | [0-9]*% |" "docs/design/sim/nov23/$name.md" 2>/dev/null; then
		if ! grep -q "KILLED at 20 minutes: $name" "$LOG"; then rm -f "docs/design/sim/nov23/$name.md"; break; fi
	fi
	at=$to
done
# the items, four at a time (only when asked: the fifth argument 1)
[ "$ITEMS" = 1 ] || { echo "$(date +%H:%M:%S) all gear batches finished (items not asked for)" >> "$LOG"; exit 0; }
for at in 0 4 8 12 16 20; do
	name=$(printf "ban_items_%02d" "$at")
	run "$name" --what=items --seeds=1 --games=4 --skill=elite --hp=0 --from=$at --to=$((at + 4)) --out=res://docs/design/sim/nov23/$name.md
	grep -q "^| .* | [0-9]*% |" "docs/design/sim/nov23/$name.md" 2>/dev/null || { grep -q "KILLED at 20 minutes: $name" "$LOG" || rm -f "docs/design/sim/nov23/$name.md"; }
done
echo "$(date +%H:%M:%S) all batches finished" >> "$LOG"
