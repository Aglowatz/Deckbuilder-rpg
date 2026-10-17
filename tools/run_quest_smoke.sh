#!/usr/bin/env bash
# Quest smoke (Oct 16, Block 1g): tracker, markers, Quest Log, accept / toggle / hand in in two zones; windowed, real input.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/quest_smoke.log"
mkdir -p _screenshots/quest_smoke
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/quest_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^quest_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "quest_smoke: script errors found"; code=1; fi
exit $code
