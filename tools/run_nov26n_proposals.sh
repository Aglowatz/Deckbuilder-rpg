#!/usr/bin/env bash
# Nov 26 night (Part B): each proposed card change simulated (sim only: an override file the audit tool applies to the loaded cards; the
# game data is untouched), on the configs it matters in, with the same seeds as the audit's own drafts; then the Extra Pocket measured.
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
P=docs/design/sim/nov26n/proposals
LOG=_logs/nov26n/proposals.log
run() {
	local name="$1" override="$2" configs="$3"
	[ -f STOP_OVERNIGHT ] && { echo "$(date +%H:%M:%S) STOP_OVERNIGHT before $name" >> "$LOG"; exit 3; }
	echo "$(date +%H:%M:%S) start $name" >> "$LOG"
	for which in base proposal; do
		local extra=""; [ "$which" = proposal ] && extra="--override=res://$P/$override.json"
		timeout 1200 "$GODOT" --headless --path . -s res://tools/draft_audit.gd -- --configs="$configs" --level=18 --drafts=8 --games=1 --seed_from=8 $extra --out=res://$P/${name}_$which.json > "_logs/nov26n/prop_${name}_$which.log" 2>&1
		echo "$(date +%H:%M:%S) done $name $which ($?)" >> "$LOG"
	done
}
run raccoon raccoon_cost1 "open:refusemancer,high:refusemancer"
run mmz mmz_def4 "open:necrocrat,open:beefcake+necrocrat"
run escoffina escoffina_cost2 "open:gourmand,open:gourmand+refusemancer"
run engarde engarde_atk3 "open:gourmand,high:gourmand"
echo "$(date +%H:%M:%S) start pocket" >> "$LOG"
timeout 1200 "$GODOT" --headless --path . -s res://tools/draft_sim.gd -- --what=pocket --challenge=open --paths=beefcake,gourmand,necrocrat,refusemancer,beefcake+necrocrat,gourmand+refusemancer --games=4 --level=18 --out=res://docs/design/sim/nov26n/extra_pocket.md > _logs/nov26n/pocket.log 2>&1
echo "$(date +%H:%M:%S) done pocket ($?)" >> "$LOG"
echo "$(date +%H:%M:%S) PROPOSALS FINISHED" >> "$LOG"
