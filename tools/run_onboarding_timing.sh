#!/usr/bin/env bash
# Daytime Oct 19, Part 3: times New Game -> the first saved deck edit with real input (clicks, E per dialogue line, WASD walks) and a
# reading model; writes _screenshots/onboarding_timing.json. Run alone (windowed). Notes: docs/playtest/onboarding_timing.md.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/onboarding_timing.log"
mkdir -p _screenshots
timeout 400 "$GODOT" --path . --resolution 1600x900 res://tools/onboarding_timing_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^onboarding:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced\|RID allocations\|leaked\|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "onboarding: script errors found"; code=1; fi
exit $code
