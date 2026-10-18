#!/usr/bin/env bash
# The playthrough bot (Overnight Oct 17, Part 13): tours every area, NPC, shop, menu and one battle per zone; writes docs/overnight/bot_report.md.
# Windowed (frame times need a real renderer). Run alone.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
size="${1:-1280x720}"
out="$(pwd)/_screenshots/tour_bot.log"
mkdir -p _screenshots
timeout 1500 "$GODOT" --path . --resolution "$size" res://tools/tour_bot_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^tour_bot:|SCRIPT ERROR" "$out" | tail -40
exit $code
