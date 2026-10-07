#!/usr/bin/env bash
# Dialogue portrait screenshots, several per run (see tools/dialogue_shots.gd).
# Usage: bash tools/dialogue_shots.sh <scene-res-path> <prefix> <tokens> [--size=WxH] [more --key=value args for the scene]
# Does not kill other Godot processes. Output: _screenshots/dialogue/<prefix>_<token>.png
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
scene="$1"; prefix="$2"; tokens="$3"; shift 3
"$GODOT" --path . --resolution 1600x900 -s res://tools/dialogue_shots.gd -- --scene="$scene" --name="$prefix" --talk="$tokens" "$@" 2>&1 | grep -E "SCRIPT ERROR|Parse Error|saved|dialogue_shots|ERROR: " | head -40
