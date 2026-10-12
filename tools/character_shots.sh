#!/usr/bin/env bash
# Character look + camera test (docs/art/character_test.md). One Godot process at a time.
# Usage: bash tools/character_shots.sh matrix [--only_preset=N] [--probes=1 --probe_spots=plaza,arena]   -> docs/art/character_test/*.jpg
#        bash tools/character_shots.sh perf                                                              -> frame time per look x camera
#        bash tools/character_shots.sh one <look 1-3> <preset 1-4> <name>                                -> _screenshots/<name>.png
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
mode="$1"; shift
case "$mode" in
	matrix|perf)
		"$GODOT" --path . --resolution 1600x900 res://tests/characters/character_test.tscn -- --fresh=true --run="$mode" "$@" 2>&1 | grep -E "character_test|SCRIPT ERROR|Parse Error|ERROR: " | head -120 ;;
	one)
		look="$1"; preset="$2"; name="$3"; shift 3
		bash tools/shot.sh res://tests/characters/character_test.tscn "$name" --fresh=true --look=$((look - 1)) --preset=$((preset - 1)) "$@" ;;
esac
