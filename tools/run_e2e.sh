#!/usr/bin/env bash
# Plays the whole demo through the real UI (windowed). Prints "E2E PASSED" or the failures and
# fails on any SCRIPT ERROR in the engine output. Takes a few minutes.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/e2e_output.log"
mkdir -p _screenshots
timeout 1000 "$GODOT" --path . --resolution 1600x900 res://tools/e2e_launcher.tscn -- --no-save > "$out" 2>&1
code=$?
grep -E "^e2e:|^E2E|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked" | head -80
if grep -q "SCRIPT ERROR" "$out"; then echo "E2E: script errors found"; code=1; fi
exit $code
