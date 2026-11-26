#!/usr/bin/env bash
# Nov 26 day (Part E): the postgame runs re-measured with the improved sim player (items used when none of the heal is wasted, a damage
# item finishing the foe, the Energy Draught when it makes a card playable, drafted gear that suits the deck, the Silver Reserve's best
# offered boon). For information only: nothing in the postgame changes. One Godot process per batch, 20-minute limit each.
# Rows go to docs/design/sim/nov26/postgame_runs.md. Log: _logs/nov26/postgame_sims.log
#   bash tools/run_nov26_postgame_sims.sh [runs=3]
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
RUNS="${1:-3}"
OUT=docs/design/sim/nov26
mkdir -p _logs/nov26 "$OUT"
LOG=_logs/nov26/postgame_sims.log
run() {
	local name="$1"; shift
	[ -f STOP_OVERNIGHT ] && { echo "$(date +%H:%M:%S) STOP_OVERNIGHT: stopped before $name" >> "$LOG"; exit 3; }
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/postgame_runs_nov25n.gd -- "$@" --runs=$RUNS --label=nov26 --out=res://$OUT/postgame_runs.md > "_logs/nov26/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
	grep "^| " "_logs/nov26/$name.log" | tail -1 >> "$LOG"
}
run gallery_ref_best --dungeon=S-GALLERY --decks=ref --boon=best
run gallery_draft_best --dungeon=S-GALLERY --decks=draft --boon=best
run lab_ref_A --dungeon=D-LAB --route=A --decks=ref
run lab_ref_B --dungeon=D-LAB --route=B --decks=ref
run lab_draft_A --dungeon=D-LAB --route=A --decks=draft
run beef_ref --dungeon=S-BEEF --decks=ref
run beef_draft --dungeon=S-BEEF --decks=draft
run vault_ref --dungeon=VAULT --decks=ref
echo "$(date +%H:%M:%S) all postgame batches finished" >> "$LOG"
