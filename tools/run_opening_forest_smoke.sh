#!/usr/bin/env bash
# Opening Forest rebuild, Part E: human-input e2e from the title's New Game through the wake-up, the hooded figure's conversation, the walk up the path
# (held WASD keys) and out through the cave mouth to Crosspath. Run alone (windowed, real viewport needed for injected input). Saves are off.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/opening_forest_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1280x720 res://tools/opening_forest_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^opening_forest_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "opening_forest_smoke: script errors found"; code=1; fi
exit $code
