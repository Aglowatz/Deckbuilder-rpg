#!/usr/bin/env bash
# Draft mode, Phase 1 (Part 3): the gear and item screens that feed the proposed ban list. One Godot at a time, a fresh
# process for every 25 pieces (memory). Output: docs/design/sim/draft1/gear_<from>.md and items.md.
#   bash tools/draft_ban_sims.sh [pieces=150] [seeds=2] [games=3]
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe}"
TOTAL="${1:-150}"; SEEDS="${2:-2}"; GAMES="${3:-3}"
mkdir -p _logs/d1
"$GODOT" --headless --path . -s res://tools/draft_sim.gd -- --what=items --paths=beefcake,necrocrat --seeds="$SEEDS" --games="$GAMES" --out=res://docs/design/sim/draft1/items.md > _logs/d1/items.log 2>&1
for ((from = 0; from < TOTAL; from += 25)); do
  [ -f STOP_OVERNIGHT ] && exit 0
  "$GODOT" --headless --path . -s res://tools/draft_sim.gd -- --what=gear --paths=beefcake,necrocrat --seeds="$SEEDS" --games="$GAMES" --from="$from" --to="$((from + 25))" --out="res://docs/design/sim/draft1/gear_$(printf %03d "$from").md" > "_logs/d1/gear_$from.log" 2>&1
done
echo "draft_ban_sims: done"
