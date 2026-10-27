#!/usr/bin/env bash
# Fixes Oct 27, Part 1: the gatekeeper card-pick probe against an exported pack. Make one with
#   Godot_console --headless --path . --export-pack "Windows Desktop" <out>/TheWaywardPath.pck     (a debug pack)
# then: bash tools/run_gatekeeper_pick_exported.sh <out>/TheWaywardPath.pck [mouse|key|pad]. Runs outside the project folder.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
root="$(pwd -W 2>/dev/null || pwd)"
pck="$1"
mode="${2:-mouse}"
out="$(pwd)/_screenshots/gatekeeper_pick_exported_${mode}.log"
mkdir -p _screenshots
run_dir="$(mktemp -d)"
(cd "$run_dir" && PICK_MODE="$mode" timeout 300 "$GODOT" --main-pack "$pck" --resolution 1600x900 $GODOT_ARGS -s "$root/tools/gatekeeper_pick_exported.gd" > "$out" 2>&1)
code=$?
rm -rf "$run_dir"
grep -E "^gatekeeper_pick_probe:|SCRIPT ERROR" "$out" | grep -v "state\|other box\|dialogue click"
exit $code
