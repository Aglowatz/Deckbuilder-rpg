#!/usr/bin/env bash
# Fable Nov 16c (Part 3): walks the Verdant Dump's two south corners (the fridge chest and the vault lever in the south-east) in and out
# with real keys and measures the camera every frame: where the hero stands on the screen, jumps between frames, how far the lens stands
# to the side. Shots in _screenshots/heap_corner/<tag>_<camera>_<corner>_<n>_<stop>.png.
# Usage: bash tools/run_heap_corner_camera.sh <tag> [camera 0|3]   (0 default, 3 Low). One Godot at a time. Exit code 0 = it followed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
tag="${1:-run}"
camera="${2:-0}"
out="$(pwd)/_screenshots/heap_corner_camera_${tag}_cam${camera}.log"
mkdir -p _screenshots/heap_corner
HEAP_CORNER_TAG="$tag" HEAP_CORNER_CAMERA="$camera" timeout 420 "$GODOT" ${GODOT_ARGS:-} --path . --resolution 1600x900 res://tools/heap_corner_camera_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^heap_corner_camera:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "heap_corner_camera: script errors found"; code=1; fi
exit $code
