#!/usr/bin/env bash
# Fable Nov 21 review (Part 2): the story bot for one Path, new game to the postgame, with a save/load at every zone change.
#   bash tools/run_story_bot_nov21r.sh <path zone> [real=0|1] [limit_seconds]     Log: _logs/n21r/story_<path>[_real].log
# The Path's own zone is played first, then the others in the gatekeepers' order, so two Paths give two zone orders. One Godot at a time.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.." || exit 1
p="${1:-beefcake}"; real="${2:-0}"; limit="${3:-2400}"
mkdir -p _logs/n21r
[ -f STOP_OVERNIGHT ] && exit 3
log="_logs/n21r/story_${p}$([ "$real" = 1 ] && echo _real).log"
start=$(date +%s)
timeout "$limit" "$GODOT" --path . --resolution 1600x900 res://tools/story_playthrough_launcher.tscn -- --path="$p" --real="$real" > "$log" 2>&1
code=$?
echo "$p: exit $code after $(( $(date +%s) - start )) s; $(grep -c 'playthrough: PASS' "$log") passed, $(grep -c 'playthrough: FAIL' "$log") failed, $(grep -c 'SCRIPT ERROR' "$log") script errors, $(grep -c '^WARNING' "$log") warnings"
grep -E "playthrough: FAIL|SCRIPT ERROR" "$log" | sort | uniq -c | sort -rn | head -30
exit $code
