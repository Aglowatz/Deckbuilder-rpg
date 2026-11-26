#!/usr/bin/env bash
# Nov 25 night (Parts C to E): whole runs through the postgame dungeons after tonight's changes (full opening hands, the Echoes' rules,
# the Silver Reserve's boons, the new postgame rules), one Godot process per batch, each with a 20-minute limit (a batch over it is killed
# and logged). Rows go to docs/design/sim/nov25n/postgame_runs.md (the Gallery's boons: gallery_boons.md). Log: _logs/nov25n/postgame_sims.log
#   bash tools/run_nov25n_postgame_sims.sh [runs=3]
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
RUNS="${1:-3}"
OUT=docs/design/sim/nov25n
mkdir -p _logs/nov25n "$OUT"
LOG=_logs/nov25n/postgame_sims.log
run() {
	local name="$1"; shift
	[ -f STOP_OVERNIGHT ] && { echo "$(date +%H:%M:%S) STOP_OVERNIGHT: stopped before $name" >> "$LOG"; exit 3; }
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	timeout 1200 "$GODOT" --headless --path . -s res://tools/postgame_runs_nov25n.gd -- "$@" --runs=$RUNS > "_logs/nov25n/$name.log" 2>&1
	local code=$?
	if [ $code -eq 124 ]; then echo "$(date +%H:%M:%S) KILLED at 20 minutes: $name" >> "$LOG"; else echo "$(date +%H:%M:%S) done $name (exit $code)" >> "$LOG"; fi
	grep "^| " "_logs/nov25n/$name.log" | tail -1 >> "$LOG"
}
for boon in thick guard edge look purse start first mend hand; do
	run "gallery_ref_$boon" --dungeon=S-GALLERY --decks=ref --boon=$boon --out=res://$OUT/gallery_boons.md
done
run gallery_draft_thick --dungeon=S-GALLERY --decks=draft --boon=thick --out=res://$OUT/postgame_runs.md
run gallery_draft_look --dungeon=S-GALLERY --decks=draft --boon=look --out=res://$OUT/postgame_runs.md
run lab_ref_A --dungeon=D-LAB --route=A --decks=ref --out=res://$OUT/postgame_runs.md
run lab_ref_B --dungeon=D-LAB --route=B --decks=ref --out=res://$OUT/postgame_runs.md
run lab_draft_A --dungeon=D-LAB --route=A --decks=draft --out=res://$OUT/postgame_runs.md
run beef_ref --dungeon=S-BEEF --decks=ref --out=res://$OUT/postgame_runs.md
run beef_draft --dungeon=S-BEEF --decks=draft --out=res://$OUT/postgame_runs.md
run vault_ref --dungeon=VAULT --decks=ref --out=res://$OUT/postgame_runs.md
echo "$(date +%H:%M:%S) all postgame batches finished" >> "$LOG"
