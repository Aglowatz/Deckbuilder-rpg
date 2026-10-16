#!/usr/bin/env bash
# The Verdant Dump from its six paint-over cameras (HeapLayout.PO_CAMERAS, Cinematic / Normal, no UI, no plates): _screenshots/<prefix>_po_<region>.png
# and a compare strip per region (paint-over left, game right) in docs/art/heap_slice/<prefix>_compare_<region>.jpg.
#   bash tools/heap_po_shots.sh <prefix> [region ...]
cd "$(dirname "$0")/.."
prefix="${1:-cur}"; shift
regions="${*:-hub junk_peaks farm_rows stream wetlands throne_approach}"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
for r in $regions; do
	bash tools/shot.sh res://scenes/heap_zone.tscn ${prefix}_po_$r --at=po_$r --nohud=true --clean=true --wait=2.6 --set=camera_angle:0,camera_zoom:1.5 2>&1 | grep "saved\|SCRIPT ERROR"
	po="PAINTOVER-DUMP-$(echo $r | tr a-z_ A-Z-).png"
	"$CONSOLE" --headless --path . -s res://tools/side_by_side.gd -- --left=res://docs/art/paintovers/$po --right=res://_screenshots/${prefix}_po_$r.png --out=res://docs/art/heap_slice/${prefix}_compare_$r.jpg --height=450 >/dev/null 2>&1
done
