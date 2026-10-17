#!/usr/bin/env bash
# The sound check (tools/sfx_check.gd): every bank event and ambience profile through the real mixer, windowed, with peaks per bus; then a burst.
# SFX_CHECK_ONLY=events|ambience|burst limits it; SFX_CHECK_FILTER=<prefix> limits the events. Results: _screenshots/sfx_check.tsv.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
mkdir -p _screenshots
out="$(pwd)/_screenshots/sfx_check.log"
timeout 900 "$GODOT" --path . --resolution 960x540 res://tools/sfx_check.tscn > "$out" 2>&1
code=$?
grep -E "^sfx_check:|SCRIPT ERROR|ERROR:" "$out" | grep -v "ObjectDB\|resources still in use"
exit $code
