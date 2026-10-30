#!/usr/bin/env bash
# Fresh eyes Oct 30: plays the real game from the title screen following a plain-text script (keys, clicks, screenshots, dev jumps).
#   bash tools/play.sh <script.txt> [run_name] [limit_seconds]
# Output: _screenshots/play/<run_name>/<shot>.png and play.log. Commands: see the header of tools/play_script.gd.
# Windowed (injected input needs a real viewport); run one Godot at a time. Never writes a save (--no-save).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
script="$1"
if [ -z "$script" ] || [ ! -f "$script" ]; then echo "usage: bash tools/play.sh <script.txt> [run_name] [limit_seconds]"; exit 2; fi
name="${2:-$(basename "${script%.*}")}"
limit="${3:-900}"
cache=".godot/global_script_class_cache.cfg"
if [ ! -f "$cache" ] || [ -n "$(find app core ui world scenes tools -newer "$cache" -name '*.gd' 2>/dev/null | head -1)" ]; then
	"$CONSOLE" --headless --path . --import >/dev/null 2>&1
	touch "$cache"
fi
case "$script" in
	/*|[A-Za-z]:*) abs="$script" ;;
	*) abs="$(pwd)/$script" ;;
esac
out="_screenshots/play/$name"
mkdir -p "$out"
timeout $((limit + 60)) "$GODOT" --path . --resolution "${SHOT_RES:-1600x900}" $GODOT_ARGS res://tools/play_script_launcher.tscn -- --no-save "--script=$abs" "--out=res://$out" "--limit=$limit" > "$out/stdout.log" 2>&1
code=$?
grep -E "^play:|SCRIPT ERROR|ERROR:" "$out/stdout.log" | grep -v "BUG: Unreferenced\|RID allocations\|leaked\|still in use" | tail -80
echo "play: output in $out (exit $code)"
exit $code
