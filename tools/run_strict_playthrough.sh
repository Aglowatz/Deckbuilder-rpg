#!/usr/bin/env bash
# Overnight Nov 17, Part 1: one complete game, new game to the credits and the first postgame step, with no state set by debug commands
# (tools/strict_playthrough.gd). Every fight is played by the game's planning AI in the hero's seat; every walk is real keys along the
# quest arrow's route. One Godot at a time.
# Usage: bash tools/run_strict_playthrough.sh <path zone> [limit_seconds]   Log: _logs/strict/<path>.log
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.." || exit 1
p="${1:-refusemancer}"; limit="${2:-21600}"
mkdir -p _logs/strict
cache=".godot/global_script_class_cache.cfg"
if [ ! -f "$cache" ] || [ -n "$(find app core ui world scenes tools -newer "$cache" -name '*.gd' 2>/dev/null | head -1)" ]; then
	"$CONSOLE" --headless --path . --import >/dev/null 2>&1
	touch "$cache"
fi
[ -f STOP_OVERNIGHT ] && exit 3
start=$(date +%s)
( low=0; while sleep 30; do f=$(powershell -NoProfile -c "[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1024)"); f=${f//[^0-9]/}; [ -z "$f" ] && continue; if [ "$f" -lt 200 ]; then low=$((low+1)); else low=0; fi; if [ $low -ge 2 ]; then echo "MEMORY WATCHDOG: free ${f} MB - stopping the run" >> "_logs/strict/$p.log"; powershell -NoProfile -c "Get-Process Godot_v4.7.2-stable_win64 -ErrorAction SilentlyContinue | Stop-Process -Force"; break; fi; [ -f "_logs/strict/.done_$p" ] && break; done ) &
watch=$!
rm -f "_logs/strict/.done_$p"
timeout "$limit" "$GODOT" --path . --resolution 1600x900 res://tools/story_playthrough_launcher.tscn -- --path="$p" --full=1 --strict=1 $STRICT_ARGS > "_logs/strict/$p.log" 2>&1
code=$?
touch "_logs/strict/.done_$p"; kill $watch 2>/dev/null
echo "$p: exit $code after $(( $(date +%s) - start )) s; $(grep -c 'ISSUELIST' _logs/strict/$p.log) issues, $(grep -c 'SCRIPT ERROR' _logs/strict/$p.log) script errors" | tee -a _logs/strict/runs.txt
