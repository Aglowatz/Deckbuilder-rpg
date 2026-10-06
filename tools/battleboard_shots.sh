#!/usr/bin/env bash
# One battle screenshot per battleboard context in data/battleboards.json (plus boards mapped to no context, by ID) into _screenshots/bb_<name>.png.
# Usage: tools/battleboard_shots.sh [context key or Battleboard ID ...]   (no args = all)
cd "$(dirname "$0")/.."
if [ $# -eq 0 ]; then
	set -- $(grep -o '"[a-z]*:*[a-z]*": *"BB-[A-Z-]*"' data/battleboards.json | sed 's/"\([^"]*\)".*/\1/') BB-S-CAP BB-S-TOWN
fi
for key in "$@"; do
	name="bb_$(echo "$key" | tr ':' '_')"
	case "$key" in BB-*) arg="--board=$key" ;; *) arg="--ctx=$key" ;; esac
	bash tools/shot.sh res://scenes/battle.tscn "$name" "$arg" --bot=4 --fast=true --wait=14 | grep -E "saved|rror"
done
