#!/usr/bin/env bash
# Crosspath pass, Part E: before / after pairs for the report (docs/art/crosspath_pass/compare/<name>.jpg, before on the left).
# Usage: bash tools/crosspath_compare.sh   (after tools/crosspath_shots.sh before / final)
cd "$(dirname "$0")/.."
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
dir="docs/art/crosspath_pass"
mkdir -p "$dir/compare"
pair() {
	local name="$1" before="$2" after="$3"
	[ -f "$dir/$before" ] && [ -f "$dir/$after" ] || { echo "skip $name ($before / $after)"; return; }
	"$CONSOLE" --headless --path . -s res://tools/side_by_side.gd -- --left="res://$dir/$before" --right="res://$dir/$after" --out="res://$dir/compare/$name.jpg" --height=450 >/dev/null 2>&1
	[ -f "$dir/compare/$name.jpg" ] && echo "compare/$name.jpg"
}
pair fields before/fields_south_default.jpg final/fields_south_default.jpg
pair fields_overview before/fields_south_overview.jpg final/fields_south_overview.jpg
pair beams before/west_street_default.jpg part_b/west_street_default.jpg
pair beams_thatch before/fields_south_default.jpg part_b/fields_south_default.jpg
pair square before/square_overview.jpg final/square_overview.jpg
pair square_default before/square_default.jpg final/square_default.jpg
pair vendors_west before/west_street_default.jpg final/vendors_west_default.jpg
pair alley before/alley_default.jpg final/alley_close_default.jpg
pair plan before/plan.jpg final/plan.jpg
pair graveyard before/fields_west_overview.jpg final/fields_west_overview.jpg
pair lakeshore before/lakeshore_default.jpg final/lakeshore_default.jpg
for z in refusemancer necrocrat beefcake gourmand final; do
	pair "gate_${z}_locked" "before/gate_${z}_locked.jpg" "final/gate_${z}_locked.jpg"
	pair "gate_${z}_open" "before/gate_${z}_open.jpg" "final/gate_${z}_open.jpg"
done
