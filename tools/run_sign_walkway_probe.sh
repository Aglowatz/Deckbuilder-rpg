#!/usr/bin/env bash
# Fixes Oct 27, Part 3: every area's signs checked against its walkable ground (tools/sign_walkway_probe.gd). Windowed, one area at a time.
# Usage: bash tools/run_sign_walkway_probe.sh [area ...]   (default: every area). Exit 1 when any sign stands in a walkway or floats.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
areas="${*:-town start gainlands buffet dna heap capital}"
status=0
for area in $areas; do
	case "$area" in
		town) scene="res://scenes/town.tscn" ;;
		start) scene="res://scenes/starting_area.tscn" ;;
		*) scene="res://scenes/${area}_zone.tscn" ;;
	esac
	out=$(timeout 240 "$GODOT" --path . --resolution 960x540 $GODOT_ARGS -s res://tools/sign_walkway_probe.gd -- --scene="$scene" --label="$area" $PROBE_ARGS 2>&1 | grep -E "^sign_walkway|SCRIPT ERROR")
	echo "$out"
	echo "$out" | grep -q "problems=0" || status=1
done
exit $status
