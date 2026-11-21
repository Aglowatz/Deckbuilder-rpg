#!/usr/bin/env bash
# Fable Nov 21 review (Part 3): the balance sims after the Nov 21 changes, one group per Godot run (headless, one at a time), into
# docs/design/sim/nov21r/<group>.md. Same seed and games as the last pass (Nov 11: seed 7100, 8 games per Path and encounter), so the
# tables compare line by line.   bash tools/sims_nov21r.sh [games=8] [group ...]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
games="${1:-8}"; shift 1 2>/dev/null
groups=("$@")
if [ ${#groups[@]} -eq 0 ]; then
	groups=(town dungeon:D-HOG dungeon:D-HFA dungeon:D-TTK dungeon:D-ROT dungeon:D-PC postgame:D-LAB side:S-BEEF side:S-NECRO side:S-GOUR side:S-REF)
fi
mkdir -p docs/design/sim/nov21r
for group in "${groups[@]}"; do
	[ -f STOP_OVERNIGHT ] && break
	name="${group//:/_}"
	out="docs/design/sim/nov21r/${name}.md"
	t0=$(date +%s)
	timeout 2400 "$GODOT" --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --filter="$group" --games="$games" --seed=7100 --out="res://$out" 2>&1 \
		| grep -E "SCRIPT ERROR|Parse Error" | head -5
	echo "sims_nov21r: $group -> $out ($(( $(date +%s) - t0 )) s)"
done
