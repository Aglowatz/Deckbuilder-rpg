#!/usr/bin/env bash
# Daytime Oct 19: the release smoke against the exported pack (builds/_export/TheWaywardPath.pck), windowed. Release templates ignore
# --script, so the stock Godot binary of the same version runs the pack with tools/release_smoke_exported.gd from disk. It runs from a
# folder outside the project so the project itself is not picked up. Usage: bash tools/run_release_smoke_exported.sh [pck]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
root="$(pwd -W 2>/dev/null || pwd)"
pck="${1:-$root/builds/_export/TheWaywardPath.pck}"
out="$(pwd)/_screenshots/release_smoke_exported.log"
mkdir -p _screenshots
run_dir="$(mktemp -d)"
(cd "$run_dir" && timeout 240 "$GODOT" --main-pack "$pck" --resolution 1600x900 $GODOT_ARGS -s "$root/tools/release_smoke_exported.gd" > "$out" 2>&1)
code=$?
rm -rf "$run_dir"
grep -E "^release_smoke_exported:|SCRIPT ERROR" "$out"
exit $code
