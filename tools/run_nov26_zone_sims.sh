#!/usr/bin/env bash
# Nov 26 day (Part C): whole runs through the four zone dungeons (two routes each) and Primm's Castle (its five routes), one Godot
# process per batch, each with a 20-minute limit. Rows go to docs/design/sim/nov26/zone_runs.md and castle_runs_<label>.md.
#   bash tools/run_nov26_zone_sims.sh <label: before|after|...> [runs=4] [only: D-HOG ...]   (CASTLE_ROUTES="D E" picks castle routes)
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
LABEL="${1:-after}"; RUNS="${2:-4}"; shift 2 2>/dev/null
ONLY="${*:-D-HOG D-TTK D-HFA D-ROT D-PC}"
OUT=docs/design/sim/nov26
mkdir -p _logs/nov26 "$OUT"
LOG=_logs/nov26/zone_sims.log
run() {
	local name="$1" script="$2"; shift 2
	[ -f STOP_OVERNIGHT ] && { echo "$(date +%H:%M:%S) STOP_OVERNIGHT: stopped before $name" >> "$LOG"; exit 3; }
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s "$script" -- "$@" > "_logs/nov26/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
	grep "^| " "_logs/nov26/$name.log" | tail -5 >> "$LOG"
}
for d in $ONLY; do
	if [ "$d" = "D-PC" ]; then
		# one process per castle route (all five in one process pass 20 minutes); the rows are gathered into castle_runs_<label>.md
		for r in ${CASTLE_ROUTES:-A B C D E}; do
			run "castle_${LABEL}_$r" res://tools/castle_runs_nov21.gd --runs=$RUNS --only=$r --out=res://$OUT/castle_runs_${LABEL}_$r.md
		done
		{ echo "# Primm's Castle whole runs ($LABEL), one file per route gathered"; echo; echo "| Route | Rooms | Fights before Primm | Allies | Reach Primm | Beat Primm (of all runs) | HP at his door | Most lost at |"; echo "|---|---|---:|---:|---:|---:|---:|---|"
		  cat $OUT/castle_runs_${LABEL}_*.md 2>/dev/null | grep "^| [A-E]:"; } > $OUT/castle_runs_$LABEL.md
		continue
	fi
	for r in A B; do
		run "${d}_${r}_$LABEL" res://tools/zone_runs_nov26.gd --dungeon=$d --route=$r --runs=$RUNS --label=$LABEL --out=res://$OUT/zone_runs.md
	done
done
echo "$(date +%H:%M:%S) batches finished ($LABEL)" >> "$LOG"
