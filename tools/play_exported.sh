#!/usr/bin/env bash
# Fable Nov 9: a play script (tools/play_script.gd) on the EXPORTED test pack (release content + tools/), run by the stock Godot binary -
# what a player's build does, not the editor. Usage: bash tools/play_exported.sh <script.txt> <run_name> [limit_seconds]
# Output: _screenshots/exported/<shot>.png, _screenshots/exported/play_<run_name>_play.log (the driver's log), _screenshots/exported/play_<run_name>.log (the game's output).
cd "$(dirname "$0")/.."
script="$1"; name="${2:-run}"; limit="${3:-480}"
if [ -z "$script" ] || [ ! -f "$script" ]; then echo "usage: bash tools/play_exported.sh <script.txt> <run_name> [limit_seconds]"; exit 2; fi
case "$script" in /*|[A-Za-z]:*) abs="$script" ;; *) abs="$(pwd -W 2>/dev/null || pwd)/$script" ;; esac
pck="$(pwd -W 2>/dev/null || pwd)/builds/_testpack/TheWaywardPath_test.pck"
bash tools/run_exported_suite.sh "$pck" d3d12 1 play "--script=$abs" "--name=$name" "--limit=$limit" | grep -v "^exported_suite" 
grep -E "^play:" "_screenshots/exported/play_$name.log" | grep -v "> wait" | tail -60
echo "play_exported: shots in _screenshots/exported/, log _screenshots/exported/play_${name}_play.log"
