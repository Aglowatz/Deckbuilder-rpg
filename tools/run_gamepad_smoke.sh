#!/usr/bin/env bash
# Controller support (Oct 26): the opening hour played with simulated controller events only (tools/gamepad_smoke.gd, PadDriver).
# Run alone (windowed; injected input needs a real viewport). Exit code 0 = every check passed. Screenshots: _screenshots/gamepad/.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/gamepad_smoke.log"
mkdir -p _screenshots
timeout 400 "$GODOT" --path . --resolution 1600x900 $GODOT_ARGS res://tools/gamepad_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^gamepad_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced\|RID allocations\|leaked\|still in use\|RenderingServer::get_singleton"
if grep -q "SCRIPT ERROR" "$out"; then echo "gamepad_smoke: script errors found"; code=1; fi
exit $code
