#!/usr/bin/env bash
# FINAL (seventh brief): (1) the regressions (D.N.A. + Gainlands e2e flows) and (2) the Endless Buffet flow with
# human-style input; screenshots in _screenshots/brief5/, brief6/ and brief7/. Run alone (windowed).
#   tools/run_seventh_brief_final_smoke.sh          # all three
#   tools/run_seventh_brief_final_smoke.sh buffet   # only the Endless Buffet flow
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
code=0
if [ "$1" != "buffet" ]; then
	bash tools/run_sixth_brief_final_smoke.sh || code=1
fi
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/seventh_brief_final_smoke.log"
mkdir -p _screenshots/brief7
timeout 1800 "$GODOT" --path . --resolution 1600x900 res://tools/seventh_brief_final_launcher.tscn > "$out" 2>&1
gcode=$?
grep -E "^seventh_brief_final_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "seventh_brief_final_smoke: script errors found"; gcode=1; fi
[ $gcode -ne 0 ] && code=1
exit $code
