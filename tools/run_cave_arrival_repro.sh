#!/usr/bin/env bash
# v0.4.2 hotfix: the cave -> Crosspath arrival on the project or an exported pack, windowed (one Godot at a time).
#   bash tools/run_cave_arrival_repro.sh            the project (editor binary, --path .)
#   bash tools/run_cave_arrival_repro.sh <pck>      an exported pack, run by the stock binary from a folder outside the project
#   CAVE_PATH=beefcake|gourmand|refusemancer|necrocrat  CAVE_MODE=normal|levelups|speed2x|continue|mash  COLD=1 (clear the shader cache first)
# Overnight Oct 20 (stability):
#   EXE=<path to an exported TheWaywardPath.exe>   run the real exported binary (release template) with its own pack instead
#   GODOT_ARGS="--rendering-driver vulkan"          extra engine arguments (driver, --rendering-method mobile, ...)
#   FRESH_SETTINGS=1                                 run with no settings.cfg (first launch defaults); the player's file is restored after
#   TIMEOUT=<s>                                      kill after this many seconds (default 400) and report "TIMEOUT" (a hang)
#   OUT_SUFFIX=<name>                                keeps logs of different runs apart (_screenshots/cave_arrival_<path>_<mode>_<suffix>.log)
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
root="$(pwd -W 2>/dev/null || pwd)"
mkdir -p _screenshots
tag="${CAVE_PATH:-beefcake}_${CAVE_MODE:-normal}${OUT_SUFFIX:+_$OUT_SUFFIX}"
out="$(pwd)/_screenshots/cave_arrival_${tag}.log"
user_dir="$APPDATA/Deckbuilder-RPG"
if [ "${COLD:-0}" = "1" ]; then
  rm -rf "$user_dir/shader_cache" "$user_dir/vulkan"
  echo "cave_arrival: shader cache cleared"
fi
if [ "${FRESH_SETTINGS:-0}" = "1" ] && [ -f "$user_dir/settings.cfg" ]; then
  mv -f "$user_dir/settings.cfg" "$user_dir/settings.cfg.repro_backup"
  echo "cave_arrival: settings.cfg moved aside (first-launch defaults)"
fi
limit="${TIMEOUT:-400}"
# shellcheck disable=SC2086
if [ -n "$EXE" ]; then
  timeout "$limit" "$EXE" --resolution 1600x900 $GODOT_ARGS -s "$root/tools/cave_arrival_repro.gd" > "$out" 2>&1
  code=$?
elif [ -n "$1" ]; then
  run_dir="$(mktemp -d)"
  (cd "$run_dir" && timeout "$limit" "$GODOT" --main-pack "$1" --resolution 1600x900 $GODOT_ARGS -s "$root/tools/cave_arrival_repro.gd" > "$out" 2>&1)
  code=$?
  rm -rf "$run_dir"
else
  timeout "$limit" "$GODOT" --path . --resolution 1600x900 $GODOT_ARGS -s res://tools/cave_arrival_repro.gd > "$out" 2>&1
  code=$?
fi
if [ -f "$user_dir/settings.cfg.repro_backup" ]; then
  mv -f "$user_dir/settings.cfg.repro_backup" "$user_dir/settings.cfg"
fi
if [ "$code" = "124" ]; then echo "cave_arrival: TIMEOUT after ${limit} s (hang)"; fi
grep -E "^cave_arrival:|SCRIPT ERROR|^D3D12|^Vulkan|Using Device|ERROR:|CRASH|crash" "$out" | head -60
exit $code
