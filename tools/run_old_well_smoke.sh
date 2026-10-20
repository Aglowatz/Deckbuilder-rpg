#!/usr/bin/env bash
# Overnight Oct 19-20, Part 6: the Old Well secret quest end to end - the vision starts the hidden quest, the two hums in the Dump and the Buffet,
# the confirm, the Echo's lines, the "Before the fight" brief, the duel (rules, vault battle song), a forced win, the reveal, the Phial paid once.
# OLD_WELL_SMOKE_API=1 sets the two hums through the Session API instead of loading the two zones.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/old_well_smoke.log"
mkdir -p _screenshots
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/old_well_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^old_well_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced\|RID allocations\|leaked\|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "old_well_smoke: script errors found"; code=1; fi
exit $code
