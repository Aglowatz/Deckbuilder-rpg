#!/usr/bin/env bash
# Battle AI upgrade, Part 5: re-measures the encounter catalog group by group under the new AI (one Godot process at a time,
# foreground inside this script; run the script itself in the background). Reports land in docs/design/sim/<tag>/<group>.md;
# summarise with `node tools/sim_summary.js docs/design/sim/<tag>/*.md`.
#   bash tools/ai_sweep.sh <tag> [games per Path, default 4] [seed, default 7000] [group ...]
#   SWEEP_KINDS=elite,boss bash tools/ai_sweep.sh ...   (Oct 23: only those encounter kinds)
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
tag="${1:-sweep}"
games="${2:-4}"
seed="${3:-7000}"
shift $(( $# < 3 ? $# : 3 ))
groups=("$@")
if [ ${#groups[@]} -eq 0 ]; then
	groups=(town zone:beefcake dungeon:D-HOG side:S-IRON side:S-TOWN zone:necrocrat dungeon:D-HFA side:S-NECRO \
		zone:gourmand dungeon:D-TTK side:S-GOUR zone:refusemancer dungeon:D-ROT side:S-REF zone:final side:S-CAP side:S-PASTE dungeon:D-PC \
		postgame arena secret:old_well capital:lieutenant)
fi
mkdir -p "docs/design/sim/$tag" _logs
log="_logs/ai_sweep_$tag.log"
: > "$log"
for group in "${groups[@]}"; do
	name="${group//:/_}"
	echo "== $group $(date +%H:%M:%S)" >> "$log"
	timeout 3000 "$GODOT" --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --filter="$group" --games="$games" --seed="$seed" --kinds="${SWEEP_KINDS:-}" \
		--out="res://docs/design/sim/$tag/$name.md" 2>&1 | grep -E "^[a-zA-Z].*%|Simulated|SCRIPT ERROR" >> "$log"
done
echo "== done $(date +%H:%M:%S)" >> "$log"
