#!/usr/bin/env bash
# Nov 26 night (Part B): the draft balance audit's raw data in batches - one Godot process per batch, a 20-minute limit each (a batch that
# runs over is killed and logged; its file is lost, the next batch starts). STOP_OVERNIGHT stops between batches.
#   bash tools/run_draft_audit.sh [drafts=4] [games=2] [only=<batch name part>]
# Raw files: docs/design/sim/nov26n/raw/<batch>.json; log: _logs/nov26n/draft_audit.log; tables: python tools/nov26n_draft_report.py
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
DRAFTS="${1:-4}"; GAMES="${2:-2}"; ONLY="${3:-}"
RAW=docs/design/sim/nov26n/raw
mkdir -p _logs/nov26n "$RAW"
LOG=_logs/nov26n/draft_audit.log
SINGLES="beefcake gourmand necrocrat refusemancer"
PAIRS="beefcake+gourmand beefcake+necrocrat beefcake+refusemancer gourmand+necrocrat gourmand+refusemancer necrocrat+refusemancer"
TRIOS="beefcake+gourmand+necrocrat beefcake+gourmand+refusemancer beefcake+necrocrat+refusemancer gourmand+necrocrat+refusemancer"
QUAD="beefcake+gourmand+necrocrat+refusemancer"
join() { local mode="$1"; shift; local out=""; for p in "$@"; do out="$out${out:+,}$mode:$p"; done; echo "$out"; }
run() {
	local name="$1" configs="$2" level="$3"
	[ -n "$ONLY" ] && [[ "$name" != *"$ONLY"* ]] && return
	[ -f STOP_OVERNIGHT ] && { echo "$(date +%H:%M:%S) STOP_OVERNIGHT: stopped before $name" >> "$LOG"; exit 3; }
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/draft_audit.gd -- --configs="$configs" --level=$level --drafts=$DRAFTS --games=$GAMES --out=res://$RAW/$name.json > "_logs/nov26n/audit_$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
}
run classic_bg_bn "$(join open beefcake gourmand)" 18
run classic_nr "$(join open necrocrat refusemancer)" 18
run classic_pairs_a "$(join open beefcake+gourmand beefcake+necrocrat)" 18
run classic_pairs_b "$(join open beefcake+refusemancer gourmand+necrocrat)" 18
run classic_pairs_c "$(join open gourmand+refusemancer necrocrat+refusemancer)" 18
run high_a "$(join high beefcake gourmand)" 18
run high_b "$(join high necrocrat refusemancer)" 18
run high_pairs "$(join high beefcake+necrocrat gourmand+refusemancer)" 18
run zone_a "$(join zone beefcake gourmand)" 12
run zone_b "$(join zone necrocrat refusemancer)" 12
run mystery_mini "$(join mini $SINGLES)" 18
run late_trios_a "$(join open beefcake+gourmand+necrocrat beefcake+gourmand+refusemancer)" 23
run late_trios_b "$(join open beefcake+necrocrat+refusemancer gourmand+necrocrat+refusemancer)" 23
run late_quad "$(join open $QUAD),$(join high $QUAD)" 23
run late_high "$(join high beefcake+gourmand+necrocrat gourmand+necrocrat+refusemancer)" 23
echo "$(date +%H:%M:%S) all audit batches finished" >> "$LOG"
