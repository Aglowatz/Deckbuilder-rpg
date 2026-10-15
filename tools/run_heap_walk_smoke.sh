#!/usr/bin/env bash
# Verdant Dump walk smoke (the slice, Part A): the entrance bridge and the walk into the Compost Commons, every quest NPC and the vendor, the
# interactables, the boar, the quiz, the fair, the Seed Shrine, the Landfill Depths door at the Trash Panda Throne (sealed and unlocked), the Rotheart's
# root gate, the giant chest and the lever, and the walk back out over the bridge to town, with real input, windowed; screenshots in
# _screenshots/heap_walk/. Usage: bash tools/run_heap_walk_smoke.sh [camera 0|1|2] (Cinematic, Classic, Overview; default the saved setting).
# Run alone (one Godot process at a time). Exit code 0 = every check passed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
camera="${1:-}"
out="$(pwd)/_screenshots/heap_walk_smoke${camera:+_cam$camera}.log"
mkdir -p _screenshots/heap_walk
HEAP_WALK_CAMERA="$camera" timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/heap_walk_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^heap_walk_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "heap_walk_smoke: script errors found"; code=1; fi
exit $code
