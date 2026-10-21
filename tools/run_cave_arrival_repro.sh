#!/usr/bin/env bash
# v0.4.2 hotfix: the cave -> Crosspath arrival on the project or an exported pack, windowed (one Godot at a time).
#   bash tools/run_cave_arrival_repro.sh            the project (editor binary, --path .)
#   bash tools/run_cave_arrival_repro.sh <pck>      an exported pack, run by the stock binary from a folder outside the project
#   CAVE_PATH=beefcake|gourmand|refusemancer|necrocrat  CAVE_MODE=normal|levelups|speed2x|continue|mash  COLD=1 (clear the shader cache first)
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
root="$(pwd -W 2>/dev/null || pwd)"
mkdir -p _screenshots
out="$(pwd)/_screenshots/cave_arrival_${CAVE_PATH:-beefcake}_${CAVE_MODE:-normal}.log"
if [ "${COLD:-0}" = "1" ]; then
  rm -rf "$APPDATA/Deckbuilder-RPG/shader_cache" "$APPDATA/Deckbuilder-RPG/vulkan"
  echo "cave_arrival: shader cache cleared"
fi
if [ -n "$1" ]; then
  run_dir="$(mktemp -d)"
  (cd "$run_dir" && timeout 400 "$GODOT" --main-pack "$1" --resolution 1600x900 -s "$root/tools/cave_arrival_repro.gd" > "$out" 2>&1)
  code=$?
  rm -rf "$run_dir"
else
  timeout 400 "$GODOT" --path . --resolution 1600x900 -s res://tools/cave_arrival_repro.gd > "$out" 2>&1
  code=$?
fi
grep -E "^cave_arrival:|SCRIPT ERROR" "$out"
exit $code
