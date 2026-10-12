#!/usr/bin/env bash
# World rollout: a new game, the starting area, the town (sprite and 3D NPCs, the clothing vendor), four zones and both sides of the Capital end to end with human-style
# input, with a screenshot and a frame rate for every area. Screenshots in _screenshots/rollout_smoke/. Run alone (windowed).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/rollout_smoke.log"
mkdir -p _screenshots/rollout_smoke
timeout 900 "$GODOT" --path . --resolution 1600x900 res://tools/world_rollout_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^rollout_smoke:|SCRIPT ERROR" "$out"
exit $code
