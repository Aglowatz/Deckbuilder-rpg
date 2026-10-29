#!/usr/bin/env bash
# Overnight Oct 28-29, Part 5: memory across Crosspath round trips (tools/memory_roundtrip_smoke.gd). Windowed, alone. Exit 1 when memory grows.
#   bash tools/run_memory_roundtrip_smoke.sh [--trips=10]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
mkdir -p _screenshots
out="$(pwd)/_screenshots/memory_roundtrip_smoke.log"
timeout 1500 "$GODOT" --path . --resolution 1280x720 res://tools/memory_roundtrip_smoke.tscn -- "$@" > "$out" 2>&1
code=$?
grep -E "^memory_roundtrip:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "memory_roundtrip: script errors found"; code=1; fi
exit $code
