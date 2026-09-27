#!/usr/bin/env bash
# Usage: tools/shot.sh <scene-res-path> <name> [extra --key=value args]
# Saves _screenshots/<name>.png from a real (windowed) run of the scene.
# Re-imports first when scripts/assets changed (new class_name scripts need the class cache).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
cache=".godot/global_script_class_cache.cfg"
if [ ! -f "$cache" ] || [ -n "$(find app core ui world scenes tools assets -newer "$cache" \( -name '*.gd' -o -name '*.gltf' -o -name '*.glb' -o -name '*.svg' -o -name '*.ogg' -o -name '*.ttf' \) 2>/dev/null | head -1)" ]; then
	"$CONSOLE" --headless --path . -s res://tools/build_theme.gd >/dev/null 2>&1
	"$CONSOLE" --headless --path . --import >/dev/null 2>&1
	touch "$cache"
fi
scene="$1"; name="$2"; shift 2
"$GODOT" --path . --resolution 1600x900 -s res://tools/screenshot.gd -- --scene="$scene" --name="$name" --no-save "$@" 2>&1 | grep -v "^Godot Engine\|^Vulkan\|^Using\|^OpenGL\|^D3D12\|^$" | head -40
