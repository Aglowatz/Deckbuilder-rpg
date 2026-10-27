#!/usr/bin/env bash
# Fixes Oct 27, Part 1: wins each zone gatekeeper and picks a card in Crosspath with one device (mouse | key | pad). Windowed, alone.
GODOT="${GODOT_EXE:-/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe}"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
mode="${1:-mouse}"
out="$(pwd)/_screenshots/gatekeeper_pick_${mode}.log"
mkdir -p _screenshots
PICK_MODE="$mode" timeout 300 "$GODOT" --path . --resolution 1600x900 $GODOT_ARGS res://tools/gatekeeper_pick_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^gatekeeper_pick_probe:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "gatekeeper_pick_probe: script errors found"; code=1; fi
exit $code
