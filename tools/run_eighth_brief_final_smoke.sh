#!/usr/bin/env bash
# FINAL (eighth brief): (1) the regressions (D.N.A. + Gainlands e2e flows) and (2) the Verdant Dump flow with
# human-style input; screenshots in _screenshots/brief5/, brief6/ and brief8/. Run alone (windowed).
#   tools/run_eighth_brief_final_smoke.sh          # all three
#   tools/run_eighth_brief_final_smoke.sh heap   # only the Verdant Dump flow
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
code=0
if [ "$1" != "heap" ]; then
	bash tools/run_seventh_brief_final_smoke.sh || code=1
fi
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/eighth_brief_final_smoke.log"
mkdir -p _screenshots/brief8
timeout 1800 "$GODOT" --path . --resolution 1600x900 res://tools/eighth_brief_final_launcher.tscn > "$out" 2>&1
gcode=$?
grep -E "^eighth_brief_final_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "eighth_brief_final_smoke: script errors found"; gcode=1; fi
[ $gcode -ne 0 ] && code=1
exit $code
