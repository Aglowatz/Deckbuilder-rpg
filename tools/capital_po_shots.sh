#!/usr/bin/env bash
# The Capital from its ten paint-over cameras (CapitalLayout.PO_CAMERAS: Cinematic / Normal, 1600x900, no UI, no plates, the gate open, every district
# broken): _screenshots/<prefix>_po_<region>.png. With the prefix "PO" the shots are the paint-over inputs: docs/art/paintover_inputs/capital/PO-CAP-<REGION>.png.
#   bash tools/capital_po_shots.sh <prefix> [region ...]      regions: gate_road resistance_camp rift_fields ruined_outpost gate_plaza
#                                                             transit_yards hungry_quarter grave_row the_reek palace_approach
cd "$(dirname "$0")/.."
prefix="${1:-cur}"; shift
regions="${*:-gate_road resistance_camp rift_fields ruined_outpost gate_plaza transit_yards hungry_quarter grave_row the_reek palace_approach}"
mkdir -p docs/art/paintover_inputs/capital
for r in $regions; do
	bash tools/shot.sh res://scenes/capital_zone.tscn ${prefix}_po_$r --at=po_$r --gate=true --nohud=true --clean=true --wait=2.6 --still=true --set=camera_angle:0,camera_zoom:1.5 2>&1 | grep "saved\|SCRIPT ERROR"
	if [ "$prefix" = "PO" ]; then
		cp "_screenshots/${prefix}_po_$r.png" "docs/art/paintover_inputs/capital/PO-CAP-$(echo $r | tr a-z_ A-Z-).png"
	fi
done
