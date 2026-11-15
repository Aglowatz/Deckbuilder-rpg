#!/usr/bin/env bash
# Fable Nov 15 (Part 1): the D.N.A.'s outside from six fixed cameras. Usage: bash tools/dna_outside_shots.sh <before|after>
cd "$(dirname "$0")/.."
tag="${1:-after}"
mkdir -p docs/overnight_shots/nov15
shoot() { # name x,z [extra]
	local name="$1" pos="$2"; shift 2
	bash tools/shot.sh res://scenes/dna_zone.tscn "n15_dna_${name}_${tag}" --pos="$pos" --nohud=true --clean=true --wait=3 "$@" 2>&1 | grep "saved\|SCRIPT ERROR"
	cp "_screenshots/n15_dna_${name}_${tag}.png" "docs/overnight_shots/nov15/p1_dna_${name}_${tag}.png"
}
only="${2:-}"
for row in "arrival 46.5,64.5" "causeway 46.5,67" "lobby_west 22,57" "lobby_east 57,57" "west_edge 5,34" "east_edge 89,34"; do
	set -- $row
	if [ -z "$only" ] || [ "$only" = "$1" ]; then shoot "$1" "$2"; fi
done
