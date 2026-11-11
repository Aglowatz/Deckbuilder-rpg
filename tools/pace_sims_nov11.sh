#!/usr/bin/env bash
# Overnight Nov 10-11, Part 3 (fight pacing): the balance sim over every ordinary-fight group of the midgame (levels 10-20): each Path
# zone's roamers, each main dungeon's rooms and the side dungeons of that stretch, one group per Godot run (foreground, one at a time),
# into docs/design/sim/nov11/<tag>_<group>.md. The tables carry win rates per Path and the average turns (both players' turns).
#   bash tools/pace_sims_nov11.sh <tag> [games per Path and encounter, default 8] [group ...]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
tag="${1:-before}"; games="${2:-8}"; shift 2 2>/dev/null
groups=("$@")
if [ ${#groups[@]} -eq 0 ]; then
	groups=(zone:necrocrat dungeon:D-HFA side:S-NECRO zone:gourmand dungeon:D-TTK side:S-GOUR zone:refusemancer dungeon:D-ROT side:S-REF zone:final)
fi
mkdir -p docs/design/sim/nov11
for group in "${groups[@]}"; do
	name="${group//:/_}"
	out="docs/design/sim/nov11/${tag}_${name}.md"
	t0=$(date +%s)
	timeout 1500 "$GODOT" --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --filter="$group" --games="$games" --seed=7100 --out="res://$out" 2>&1 \
		| grep -E "turns|Simulated|ERROR" | grep -v "RID\|leaked" | tail -40
	echo "pace_sims: $group -> $out ($(( $(date +%s) - t0 )) s)"
done
