#!/usr/bin/env bash
# Fable Nov 21 castle (Part 6): Primm's three duels on one HP pool, with the leaders named in each run.
#   bash tools/sims_nov21c.sh <tag> <games per Path> "<allies>" ["<allies>" ...]      allies: none | beefcake,gourmand,...
# Output: docs/design/sim/nov21c/primm_<tag>_<n>.md (n = number of allies, or the list). One Godot at a time.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
tag="$1"; games="$2"; shift 2
for allies in "$@"; do
	name=$(echo "$allies" | tr ',' '+')
	out="docs/design/sim/nov21c/primm_${tag}_${name}.md"
	"$GODOT" --headless --path . -s res://tools/run_balance_sim.gd -- --what=sequence --filter=boss:primm --games="$games" --seed="${SEED:-7000}" --allies="$allies" --out="res://$out" > /dev/null 2>&1
	echo "== $allies"; grep -E "^\|" "$out" | head -12
done
