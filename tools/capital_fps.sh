#!/usr/bin/env bash
# fps on a quality (default 1, Medium) at the Capital's ten paint-over cameras (CapitalLayout.PO_CAMERAS), the gate open, enemies held:
# one line per camera (avg / min fps, draw calls, the probe's GPU / CPU ms).   bash tools/capital_fps.sh [quality] [region ...]
cd "$(dirname "$0")/.."
q="${1:-1}"; shift
regions="${*:-gate_road resistance_camp rift_fields ruined_outpost gate_plaza transit_yards hungry_quarter grave_row the_reek palace_approach}"
for r in $regions; do
	echo "== po_$r"
	bash tools/fps.sh res://scenes/capital_zone.tscn "$q" --at=po_$r --gate=true --still=true | grep -v "^$" | tail -3
done
