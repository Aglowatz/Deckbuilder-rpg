#!/usr/bin/env bash
# Nov 26 night (Part D): the postgame solution hunt in batches (no postgame changes) - one Godot process per batch, 20-minute limit each,
# STOP_OVERNIGHT between batches. Fights: docs/design/sim/nov26n/postgame_fights.md; whole runs: postgame_runs.md (run with "runs").
#   bash tools/run_postgame_hunt.sh fights [games=2]        every postgame fight against the build library
#   bash tools/run_postgame_hunt.sh runs "<builds>" [runs=4] the whole dungeons with the named builds (deck/kit/items;...)
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
WHAT="${1:-fights}"
mkdir -p _logs/nov26n docs/design/sim/nov26n
LOG=_logs/nov26n/postgame_hunt.log
run() {
	local name="$1"; shift
	[ -f STOP_OVERNIGHT ] && { echo "$(date +%H:%M:%S) STOP_OVERNIGHT: stopped before $name" >> "$LOG"; exit 3; }
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/postgame_hunt.gd -- "$@" > "_logs/nov26n/hunt_$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
}
if [ "$WHAT" = fights ]; then
	G="${2:-2}"
	K="--kits=model,sturdy,control --games=$G --out=res://docs/design/sim/nov26n/postgame_fights.md"
	run beef --mode=fights --dungeon=S-BEEF --fights=1,2,3 $K
	run vault --mode=fights --dungeon=VAULT $K
	run lab_1 --mode=fights --dungeon=D-LAB --fights=2,3,5 $K
	run lab_2 --mode=fights --dungeon=D-LAB --fights=8,10,13 $K
	run lab_3 --mode=fights --dungeon=D-LAB --fights=15,16 $K
	run gallery_1 --mode=fights --dungeon=S-GALLERY --fights=2,4,5 $K
	run gallery_2 --mode=fights --dungeon=S-GALLERY --fights=7,9,10 $K
	run gallery_3 --mode=fights --dungeon=S-GALLERY --fights=11,13 $K
else
	B="$2"; R="${3:-4}"
	O="--mode=runs --runs=$R --builds=$B --out=res://docs/design/sim/nov26n/postgame_runs.md"
	run runs_beef --dungeon=S-BEEF $O
	run runs_vault --dungeon=VAULT $O
	run runs_lab_a --dungeon=D-LAB --route=A $O
	run runs_lab_b --dungeon=D-LAB --route=B $O
	run runs_gallery --dungeon=S-GALLERY $O
fi
echo "$(date +%H:%M:%S) all hunt batches finished ($WHAT)" >> "$LOG"
