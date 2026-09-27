#!/usr/bin/env bash
# Usage: tools/shot.sh <scene-res-path> <name> [extra --key=value args]
# Saves _screenshots/<name>.png from a real (windowed) run of the scene.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
scene="$1"; name="$2"; shift 2
"$GODOT" --path . --resolution 1600x900 -s res://tools/screenshot.gd -- --scene="$scene" --name="$name" --no-save "$@" 2>&1 | grep -v "^Godot Engine\|^Vulkan\|^Using\|^OpenGL\|^D3D12\|^$" | head -40
