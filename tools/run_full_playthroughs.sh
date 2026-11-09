#!/usr/bin/env bash
# Overnight Nov 8-9, Part 1.2: the story bot once per Path, real pilot fights, save/load at every zone change, into the postgame.
# Usage: bash tools/run_full_playthroughs.sh [paths...]   (default: all four). Logs: _logs/full_play/<path>.log
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.." || exit 1
mkdir -p _logs/full_play
paths=("$@"); [ ${#paths[@]} -eq 0 ] && paths=(beefcake necrocrat gourmand refusemancer)
for p in "${paths[@]}"; do
	[ -f STOP_OVERNIGHT ] && break
	start=$(date +%s)
	timeout 3300 "$GODOT" --path . --resolution 1600x900 res://tools/story_playthrough_launcher.tscn -- --path="$p" --real=1 > "_logs/full_play/$p.log" 2>&1
	echo "$p: exit $? after $(( $(date +%s) - start )) s; $(grep -c 'playthrough: FAIL' _logs/full_play/$p.log) fails, $(grep -c 'SCRIPT ERROR' _logs/full_play/$p.log) script errors"
done
