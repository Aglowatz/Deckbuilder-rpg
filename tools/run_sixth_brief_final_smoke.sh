#!/usr/bin/env bash
# FINAL (sixth brief): (1) the D.N.A. regression (the fifth brief's e2e) and (2) the Gainlands flow with
# human-style input; screenshots in _screenshots/brief5/ and _screenshots/brief6/. Run alone (windowed).
#   tools/run_sixth_brief_final_smoke.sh            # both
#   tools/run_sixth_brief_final_smoke.sh gainlands   # only the Gainlands flow
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
code=0
if [ "$1" != "gainlands" ]; then
	bash tools/run_fifth_brief_final_smoke.sh || code=1
fi
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/sixth_brief_final_smoke.log"
mkdir -p _screenshots/brief6
timeout 1500 "$GODOT" --path . --resolution 1600x900 res://tools/sixth_brief_final_launcher.tscn > "$out" 2>&1
gcode=$?
grep -E "^sixth_brief_final_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "sixth_brief_final_smoke: script errors found"; gcode=1; fi
[ $gcode -ne 0 ] && code=1
exit $code
