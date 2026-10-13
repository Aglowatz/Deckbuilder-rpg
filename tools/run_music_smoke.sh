#!/usr/bin/env bash
# The music integration smoke (docs/audio/music_integration.md, Part D): forest -> town -> graveyard -> shop -> battle -> zone -> dungeon -> boss ->
# zone freed -> Capital, checking the cue at every step and that crossfades are smooth. Run alone (windowed; the real audio mixer is active).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/music_smoke.log"
mkdir -p _screenshots
MUSIC_LOG=1 timeout 600 "$GODOT" --path . --resolution 1280x720 res://tools/music_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^music_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "music_smoke: script errors found"; code=1; fi
exit $code
