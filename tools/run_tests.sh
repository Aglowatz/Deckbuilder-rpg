#!/usr/bin/env bash
# Memory-safe full GUT run (Oct 31): the suite is split into shards of N test scripts, each run in a FRESH Godot process
# (one at a time), so memory never piles up across ~290 scripts. Prints one line per shard and a combined summary with
# every failing test by name. Logs: _logs/gut/shard_NN.log (+ summary.txt).
# Usage: bash tools/run_tests.sh [--size=N] [--only=<path prefix, e.g. tests/core>] [--from=K]
#   --size  scripts per shard (default 10)   --only  run just the scripts under a prefix   --from  start at shard K (resume)
# Exit code 0 only when every shard finished and nothing failed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
SIZE=10
ONLY="tests"
FROM=1
for a in "$@"; do
	case "$a" in
		--size=*) SIZE="${a#--size=}" ;;
		--only=*) ONLY="${a#--only=}" ;;
		--from=*) FROM="${a#--from=}" ;;
	esac
done
LOGDIR="_logs/gut"
mkdir -p "$LOGDIR"
[ "$FROM" = "1" ] && rm -f "$LOGDIR"/shard_*.log
"$GODOT" --headless --path . --import >/dev/null 2>&1

mapfile -t FILES < <(find "$ONLY" -name 'test_*.gd' | sort)
TOTAL_FILES=${#FILES[@]}
SHARDS=$(( (TOTAL_FILES + SIZE - 1) / SIZE ))
echo "GUT sharded: $TOTAL_FILES scripts in $SHARDS shards of $SIZE (fresh Godot per shard)"

T_TESTS=0; T_PASS=0; T_FAIL=0; T_RISKY=0; CRASHED=""; FAILS=""
start_all=$(date +%s)
for ((s = 1; s <= SHARDS; s++)); do
	log=$(printf "%s/shard_%02d.log" "$LOGDIR" "$s")
	if (( s < FROM )); then
		[ -f "$log" ] || continue
	else
		list=""
		for ((i = (s - 1) * SIZE; i < s * SIZE && i < TOTAL_FILES; i++)); do list="$list,res://${FILES[$i]}"; done
		t0=$(date +%s)
		timeout 1200 "$GODOT" --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig= -gtest="${list#,}" -gexit 2>&1 \
			| sed 's/\x1b\[[0-9;]*m//g' > "$log"
		echo "    (${s}: $(( $(date +%s) - t0 )) s)" >> "$log"
	fi
	tests=$(grep -E "^Tests +[0-9]+" "$log" | awk '{print $2}' | tail -1)
	pass=$(grep -E "^Passing Tests +[0-9]+" "$log" | awk '{print $3}' | tail -1)
	fail=$(grep -E "^Failing Tests +[0-9]+" "$log" | awk '{print $3}' | tail -1)
	risky=$(grep -E "^Risky(/Pending| Tests) +[0-9]+" "$log" | awk '{print $NF}' | tail -1)
	first=$(grep -m1 -oE "^res://tests/[^ ]+\.gd$" "$log")
	if ! grep -q "= Run Summary" "$log"; then
		CRASHED="$CRASHED\n  shard $s (last script: $(grep -oE "^res://tests/[^ ]+\.gd$" "$log" | tail -1))"
		echo "shard $s/$SHARDS: CRASHED or timed out ($log)"
		continue
	fi
	T_TESTS=$((T_TESTS + ${tests:-0})); T_PASS=$((T_PASS + ${pass:-0})); T_FAIL=$((T_FAIL + ${fail:-0})); T_RISKY=$((T_RISKY + ${risky:-0}))
	# failing test names: the "* test_x" line before each "[Failed]" under its script
	f=$(awk '/^res:\/\/tests\/.*\.gd$/ {scr=$0} /^\* test_/ {t=$2} /\[Failed\]/ {if (scr":"t != last) {print "  " scr " :: " t; last=scr":"t}}' "$log")
	[ -n "$f" ] && FAILS="$FAILS\n$f"
	echo "shard $s/$SHARDS: ${pass:-0}/${tests:-0} passed${fail:+, $fail failing}  ($first ...)"
done
{
	echo "=============================================="
	echo "GUT sharded summary ($(date '+%b %d %H:%M'), $(( ($(date +%s) - start_all) / 60 )) min): $T_PASS/$T_TESTS passed, $T_FAIL failing, $T_RISKY risky/pending"
	[ -n "$FAILS" ] && echo -e "Failing tests:$FAILS"
	[ -n "$CRASHED" ] && echo -e "Crashed shards:$CRASHED"
} | tee "$LOGDIR/summary.txt"
[ -z "$FAILS" ] && [ -z "$CRASHED" ]
