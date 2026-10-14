#!/usr/bin/env bash
# Sub-area e2e: every hub gate, a chest, the exit back, save and load inside a sub-area (windowed, injected input; run alone).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/subarea_smoke.log"
mkdir -p _screenshots
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/subarea_smoke.tscn > "$out" 2>&1
code=$?
grep -E "^subarea_smoke:|SCRIPT ERROR" "$out"
exit $code
