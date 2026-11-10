#!/usr/bin/env bash
# Dungeon route audit (Fable pass Nov 10, Part 1.2): plans the way from each zone's arrival point to its main dungeon, fresh and with every gate
# granted, and names the gates on the route.   bash tools/run_dungeon_route_audit.sh      ROUTE_ZONES=gourmand,refusemancer to limit it
# Report: _screenshots/dungeon_route/report.md
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
mkdir -p _screenshots/dungeon_route
out="$(pwd)/_screenshots/dungeon_route/stdout.log"
timeout 1200 "$GODOT" ${GODOT_ARGS:-} --path . --resolution 1280x720 res://tools/dungeon_route_audit_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^dungeon_route_audit:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "dungeon_route_audit: script errors found"; code=1; fi
exit $code
