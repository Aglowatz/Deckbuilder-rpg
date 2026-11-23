#!/usr/bin/env bash
# Fable Nov 22 night: Primm's two target cells (no leader, all four), 16 games per Path, one Godot at a time.
#   [EXTRA=--skip_gear=glass_jaw_gauntlets] bash tools/primm_pair_nov22.sh <tag> [allies sets...]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.." || exit 1
out="docs/design/sim/nov22"; tag="$1"; shift
sets="${*:-none beefcake,gourmand,necrocrat,refusemancer}"
for allies in $sets; do
	[ -f STOP_OVERNIGHT ] && exit 3
	name=$(echo "$allies" | tr ',' '+')
	"$GODOT" --headless --path . -s res://tools/run_balance_sim.gd -- --what=sequence --filter=boss:primm --games=16 --seed=7000 --allies="$allies" $EXTRA --out="res://$out/primm_${tag}_${name}.md" > /dev/null 2>&1
	echo "== primm $tag $allies"; grep -E "^\| (Beefcake|Gourmand|Refusemancer|Necrocrat) " "$out/primm_${tag}_${name}.md" | cut -c1-40
done
