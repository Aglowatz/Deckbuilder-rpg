#!/usr/bin/env bash
# Fable big pass Nov 23 (Part 2): the draft ban sims in batches, one Godot process at a time, each batch a fresh process with a
# 20-minute limit (a batch that runs over is killed and logged, and the next one starts).
#   bash tools/run_draft_ban_sims.sh [batch size=15] [first piece=0] [last piece=200]
# Tables: docs/design/sim/nov23/ban_gear_<from>.md and ban_items.md; log: _logs/nov23/ban_sims.log
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
SIZE="${1:-15}"; FROM="${2:-0}"; LAST="${3:-200}"
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
	run "$name" --what=gear --seeds=1 --games=4 --from=$at --to=$to --out=res://docs/design/sim/nov23/$name.md
	# the pool is shorter than LAST: stop at the first batch that measured nothing
	if ! grep -q "^| .* | .* | .* | [0-9]*% |" "docs/design/sim/nov23/$name.md" 2>/dev/null; then
		if ! grep -q "KILLED at 20 minutes: $name" "$LOG"; then rm -f "docs/design/sim/nov23/$name.md"; break; fi
	fi
	at=$to
done
run ban_items --what=items --seeds=1 --games=4 --out=res://docs/design/sim/nov23/ban_items.md
echo "$(date +%H:%M:%S) all batches finished" >> "$LOG"
