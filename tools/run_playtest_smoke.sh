#!/usr/bin/env bash
# Playtest v0.4.0, Part G: the windowed end-to-end of the new opening hour - New Game, the wake-up lines, the Path choice, the
# Forgotten Cave, the arrival next to Elder Maren in Crosspath, an outskirts roamer fight, the level-5 notice, the armory quest
# completing on a win, and opening a deck from a Deck Station rack slot. Run alone (windowed; injected input needs a real viewport).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/playtest_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 $GODOT_ARGS res://tools/playtest_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^playtest_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced\|RID allocations\|leaked\|still in use"
if grep -q "SCRIPT ERROR" "$out"; then echo "playtest_smoke: script errors found"; code=1; fi
exit $code
