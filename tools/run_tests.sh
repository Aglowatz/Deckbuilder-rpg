#!/usr/bin/env bash
# Memory-safe full GUT run (Oct 31): the suite is split into shards of N test scripts, each run in a FRESH Godot process
# (one at a time), so memory never piles up across ~290 scripts. Prints one line per shard and a combined summary with
# every failing test by name. Logs: _logs/gut/shard_NN.log (+ summary.txt).
# Usage: bash tools/run_tests.sh [--size=N] [--only=<path prefix, e.g. tests/core>] [--from=K] [--to=K] [--min-free=MB] [--wait-max=SEC]
#   --size  scripts per shard (default 10)   --only  run just the scripts under a prefix   --from  start at shard K (resume)
#   --min-free  (Overnight Nov 10-11, inbox 13) before each shard, wait until the machine has at least this much free RAM in MB
#               (default 900; a 12-file shard holds 400-630 MB; 0 = no wait), instead of being killed by the harness's memory guard
#   --wait-max  how long to wait for that at most, in seconds (default 600); when it runs out the shard is skipped and counted as crashed
# Exit code 0 only when every shard finished and nothing failed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
SIZE=10
ONLY="tests"
FROM=1
TO=0
MIN_FREE=900
WAIT_MAX=600
for a in "$@"; do
	case "$a" in
		--size=*) SIZE="${a#--size=}" ;;
		--only=*) ONLY="${a#--only=}" ;;
		--from=*) FROM="${a#--from=}" ;;
		--to=*) TO="${a#--to=}" ;;
		--min-free=*) MIN_FREE="${a#--min-free=}" ;;
		--wait-max=*) WAIT_MAX="${a#--wait-max=}" ;;
	esac
done

# Free physical RAM in MB (Windows: PowerShell's CIM; elsewhere /proc/meminfo); -1 when it cannot be read (then nothing waits).
free_mb() {
	local kb
	# Git Bash (MSYS) has a /proc/meminfo too, but with MemFree only (no MemAvailable): take MemAvailable, else MemFree, else ask Windows.
	if [ -r /proc/meminfo ]; then
		kb=$(awk '/^MemAvailable:/ {a=$2} /^MemFree:/ {f=$2} END {if (a != "") print a; else if (f != "") print f}' /proc/meminfo)
		if [[ "$kb" =~ ^[0-9]+$ ]]; then echo $((kb / 1024)); return; fi
	fi
	kb=$(powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory" 2>/dev/null | tr -d '\r ')
	if [[ "$kb" =~ ^[0-9]+$ ]]; then echo $((kb / 1024)); else echo -1; fi
}

# Waits (up to WAIT_MAX s, polling every 10 s) until free RAM is at least MIN_FREE MB. Returns 1 when the wait ran out.
wait_for_memory() {
	local shard="$1" waited=0 free
	[ "$MIN_FREE" -le 0 ] && return 0
	while :; do
		free=$(free_mb)
		[ "$free" -lt 0 ] && return 0
		[ "$free" -ge "$MIN_FREE" ] && { (( waited > 0 )) && echo "    shard $shard: $free MB free after ${waited}s, going on"; return 0; }
		if (( waited >= WAIT_MAX )); then
			echo "shard $shard: only $free MB free after ${waited}s (need $MIN_FREE): skipped"
			return 1
		fi
		(( waited == 0 )) && echo "    shard $shard: $free MB free, waiting for $MIN_FREE MB (up to ${WAIT_MAX}s)..."
		sleep 10
		waited=$((waited + 10))
	done
}
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
	# Nov 13: --to=K stops after shard K, so a long run can be done in pieces that each fit one foreground call (resume with --from=K+1).
	if (( TO > 0 && s > TO )); then break; fi
	if (( s < FROM )); then
		[ -f "$log" ] || continue
	else
		list=""
		for ((i = (s - 1) * SIZE; i < s * SIZE && i < TOTAL_FILES; i++)); do list="$list,res://${FILES[$i]}"; done
		if ! wait_for_memory "$s"; then
			echo "skipped: free RAM stayed under $MIN_FREE MB for ${WAIT_MAX}s" > "$log"
			CRASHED="$CRASHED\n  shard $s (skipped: low memory; rerun with --from=$s)"
			echo "shard $s/$SHARDS: SKIPPED (low memory)"
			continue
		fi
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
	f=$(awk '/= Run Summary/ {exit} /^res:\/\/tests\/.*\.gd$/ {scr=$0} /^\* test_/ {t=$2} /\[Failed\]/ {if (scr":"t != last) {print "  " scr " :: " t; last=scr":"t}}' "$log")
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
