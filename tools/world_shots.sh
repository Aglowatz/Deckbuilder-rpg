#!/usr/bin/env bash
# World Look Test (docs/art/world_look_test.md). One Godot process at a time.
# Usage: bash tools/world_shots.sh one <name> [--preset=5 --pos=x,z --yaw=0 --wait=2.5]   -> docs/art/world_look/<name>.jpg
#        bash tools/world_shots.sh shots                                                    -> the whole documented set (docs/art/world_look/*.jpg)
#        bash tools/world_shots.sh perf                                                     -> frame time per preset (log lines "world_look: perf|...")
#        bash tools/world_shots.sh walk                                                     -> walk-cycle probe frames
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
cache=".godot/global_script_class_cache.cfg"
if [ ! -f "$cache" ] || [ -n "$(find app core ui world scenes tools tests assets -newer "$cache" \( -name '*.gd' -o -name '*.gdshader' -o -name '*.png' -o -name '*.json' \) 2>/dev/null | head -1)" ]; then
	"$CONSOLE" --headless --path . --import >/dev/null 2>&1
	touch "$cache"
fi
mode="$1"; shift
if [ "$mode" = "one" ]; then
	name="$1"; shift
	"$GODOT" --path . --resolution 1600x900 res://tests/world/world_look_test.tscn -- --fresh=true --run=one --name="$name" "$@" 2>&1 | grep -E "world_look|SCRIPT ERROR|Parse Error|ERROR: |WARNING: .*shader" | head -60
else
	"$GODOT" --path . --resolution 1600x900 res://tests/world/world_look_test.tscn -- --fresh=true --run="$mode" "$@" 2>&1 | grep -E "world_look|SCRIPT ERROR|Parse Error|ERROR: " | head -200
fi
