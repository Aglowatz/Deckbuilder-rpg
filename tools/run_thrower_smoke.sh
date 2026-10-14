#!/usr/bin/env bash
# Gainlands thrower smoke (Part F of the corrective pass): every thrower and portal ripper ridden with real input, windowed; screenshots in
# _screenshots/throwers/. Run alone (one Godot process at a time). Exit code 0 = every check passed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/thrower_smoke.log"
mkdir -p _screenshots/throwers
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/thrower_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^thrower_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "thrower_smoke: script errors found"; code=1; fi
exit $code
