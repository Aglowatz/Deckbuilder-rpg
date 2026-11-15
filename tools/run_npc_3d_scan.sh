#!/usr/bin/env bash
# Fable Nov 15 (Part 3): scans every walkable area, in its oppressed and its freed state, for 3D or placeholder figures
# (tools/npc_3d_scan.gd). Windowed, one Godot at a time (do not edit scripts while it runs). Prints one line per figure and a summary per
# area; exit 1 when any is found that is not on the allow list (NPC_3D_ALLOW=a,b).   bash tools/run_npc_3d_scan.sh [label ...]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
mkdir -p _screenshots/npc_3d
out="_screenshots/npc_3d/report.txt"
: > "$out"
# label | scene | extra args
runs=(
	"forest|res://scenes/starting_area.tscn|--fresh=true"
	"forest_postgame|res://scenes/starting_area.tscn|--postgame=1"
	"forest_rescuer|res://scenes/starting_area.tscn|--show=rescuer"
	"forest_maren|res://scenes/starting_area.tscn|--show=maren"
	"crosspath|res://scenes/town.tscn|--quiet=true"
	"crosspath_freed|res://scenes/town.tscn|--quiet=true --gates=open --zones=4 --flags=primm_defeated,rescuer_met"
	"gainlands|res://scenes/gainlands_zone.tscn|--quiet=true"
	"gainlands_freed|res://scenes/gainlands_zone.tscn|--freed=true"
	"buffet|res://scenes/buffet_zone.tscn|--quiet=true"
	"buffet_freed|res://scenes/buffet_zone.tscn|--freed=true"
	"dna|res://scenes/dna_zone.tscn|--quiet=true"
	"dna_freed|res://scenes/dna_zone.tscn|--freed=true"
	"dump|res://scenes/heap_zone.tscn|--quiet=true"
	"dump_freed|res://scenes/heap_zone.tscn|--freed=true"
	"capital_outside|res://scenes/capital_zone.tscn|--quiet=true"
	"capital_inside|res://scenes/capital_zone.tscn|--gate=true --hub=true --lieutenants=true"
	"capital_freed|res://scenes/capital_zone.tscn|--gate=true --hub=true --paths=true --flags=primm_defeated"
)
code=0
for row in "${runs[@]}"; do
	IFS='|' read -r label scene extra <<< "$row"
	if [ $# -gt 0 ] && [[ ! " $* " =~ " $label " ]]; then continue; fi
	timeout 240 "$GODOT" ${GODOT_ARGS:-} --path . -s res://tools/npc_3d_scan.gd -- --scene="$scene" --label="$label" --allow="${NPC_3D_ALLOW:-}" $extra 2>&1 | grep -E "^npc_3d|SCRIPT ERROR" | tee -a "$out"
	if ! grep -q "^npc_3d_summary: $label " "$out"; then echo "npc_3d: $label no summary (the scene did not finish loading)" | tee -a "$out"; fi
done
if grep -q "SCRIPT ERROR" "$out"; then code=1; fi
if grep "^npc_3d: " "$out" | grep -qv "(allowed)$"; then code=1; fi
echo "npc_3d_scan: $(grep -c '^npc_3d: ' "$out") figure(s) in $(grep -c '^npc_3d_summary' "$out") area states; report $out"
exit $code
