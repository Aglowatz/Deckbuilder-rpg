#!/usr/bin/env bash
# Vertical slice e2e: the rebuilt town square's spots, prompts and screens (windowed, injected input; run alone).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/town_slice_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 res://tools/town_slice_smoke.tscn > "$out" 2>&1
code=$?
grep -E "^town_slice_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "town_slice_smoke: script errors found"; code=1; fi
exit $code
