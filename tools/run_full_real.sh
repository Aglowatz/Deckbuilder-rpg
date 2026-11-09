#!/usr/bin/env bash
# Overnight Nov 9, Part 1: one Path played start to postgame with every fight real (story bot --full=1), one Godot at a time.
# Usage: bash tools/run_full_real.sh <path> [limit_seconds]   Log: _logs/full_real/<path>.log ; summary lines start "playthrough: FULL".
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.." || exit 1
p="${1:-beefcake}"; limit="${2:-14400}"
mkdir -p _logs/full_real
cache=".godot/global_script_class_cache.cfg"
if [ ! -f "$cache" ] || [ -n "$(find app core ui world scenes tools -newer "$cache" -name '*.gd' 2>/dev/null | head -1)" ]; then
	"$CONSOLE" --headless --path . --import >/dev/null 2>&1
	touch "$cache"
fi
[ -f STOP_OVERNIGHT ] && exit 3
start=$(date +%s)
# memory watchdog: free RAM under 200 MB twice in a row stops the run cleanly (logged)
( low=0; while sleep 30; do pgrep -f story_playthrough >/dev/null 2>&1 || true; f=$(powershell -NoProfile -c "[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1024)"); f=${f//[^0-9]/}; [ -z "$f" ] && continue; if [ "$f" -lt 200 ]; then low=$((low+1)); else low=0; fi; if [ $low -ge 2 ]; then echo "MEMORY WATCHDOG: free ${f} MB - stopping the run" >> "_logs/full_real/$p.log"; powershell -NoProfile -c "Get-Process Godot_v4.7.2-stable_win64 -ErrorAction SilentlyContinue | Stop-Process -Force"; break; fi; [ -f "_logs/full_real/.done_$p" ] && break; done ) &
watch=$!
rm -f "_logs/full_real/.done_$p"
timeout "$limit" "$GODOT" --path . --resolution 1600x900 res://tools/story_playthrough_launcher.tscn -- --path="$p" --full=1 > "_logs/full_real/$p.log" 2>&1
code=$?
touch "_logs/full_real/.done_$p"; kill $watch 2>/dev/null
echo "$p: exit $code after $(( $(date +%s) - start )) s; $(grep -c 'playthrough: FAIL' _logs/full_real/$p.log) fails, $(grep -c 'SCRIPT ERROR' _logs/full_real/$p.log) script errors" | tee -a _logs/full_real/runs.txt
