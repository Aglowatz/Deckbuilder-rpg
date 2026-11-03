#!/usr/bin/env bash
# Nov 2 pass, Part 3: measures every scene transition (zone <-> town, zone <-> battle, zone <-> side dungeon), cold and warm, with the real
# SceneManager in a window. Output: _screenshots/loading_timing/<run>.md + .json and the log. Run alone (one Godot at a time).
# Usage: bash tools/run_loading_timing.sh [run_name] [zones=beefcake,gourmand,necrocrat,refusemancer,final]
#        LOADING_FIGHTS=1 bash tools/run_loading_timing.sh <run>   (only the arena / graveyard / dungeon-node fight returns)
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
run="${1:-run}"
zones="${2:-beefcake,gourmand,necrocrat,refusemancer,final}"
mkdir -p _screenshots/loading_timing
out="$(pwd)/_screenshots/loading_timing/$run.log"
timeout 1500 "$GODOT" --path . --resolution 1600x900 res://tools/loading_timing_launcher.tscn -- "--run=$run" "--zones=$zones" "--fights=${LOADING_FIGHTS:-0}" > "$out" 2>&1
code=$?
grep -E "^loading_timing:|SCRIPT ERROR|load_timing:" "$out" | head -80
exit $code
