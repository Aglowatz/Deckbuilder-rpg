#!/usr/bin/env bash
# Nov 27 day (Part A): the random-play soak bot. Plays the real game with random valid choices over every screen and mode and logs
# script errors, softlocks, off-screen / overlapping UI, cut-off text, placeholder art and saves that load back differently.
#   bash tools/soak_bot.sh <seed> [minutes=25] [WxH=1280x720]
# Output: docs/overnight_shots/nov27/soak/seed<seed>_<WxH>/ (soak.log, issues.md, the first frame of each problem, stdout.log).
# Windowed (injected input needs a real viewport). Run one Godot at a time; never writes the player's saves or settings (--no-save).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
seed="${1:-1}"
minutes="${2:-25}"
size="${3:-1280x720}"
limit=$((minutes * 60))
cache=".godot/global_script_class_cache.cfg"
if [ ! -f "$cache" ] || [ -n "$(find app core ui world scenes tools -newer "$cache" -name '*.gd' 2>/dev/null | head -1)" ]; then
	"$CONSOLE" --headless --path . --import >/dev/null 2>&1
	touch "$cache"
fi
out="docs/overnight_shots/nov27/soak/seed${seed}_${size}"
mkdir -p "$out"
WAYWARD_TEST_SAVES=1 timeout $((limit + 120)) "$GODOT" --path . --resolution "$size" $GODOT_ARGS res://tools/soak_bot_launcher.tscn -- --no-save "--seed=$seed" "--out=res://$out" "--limit=$limit" ${ONLY:+"--only=$ONLY"} > "$out/stdout.log" 2>&1
code=$?
grep -E "SCRIPT ERROR" "$out/stdout.log" | sort | uniq -c | sort -rn | head -20
grep -E "^play: (ISSUE|soak:)" "$out/stdout.log" | tail -60
echo "soak: output in $out (exit $code)"
exit $code
