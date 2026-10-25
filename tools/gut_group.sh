#!/usr/bin/env bash
# Performance pass Oct 25: GUT in groups (a whole run takes ~11 min and ~1.5 GB; this PC has 7.4 GB). Usage: bash tools/gut_group.sh <root|core|ui|world|all>
#   root = tests/*.gd (no subfolders), core = tests/core/**, ui = tests/ui + tests/audio + tests/characters, world = tests/world
# Prints GUT's summary lines and every failure. Re-imports first (new class_name scripts).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
run() {
	echo "=== GUT group: $*"
	"$GODOT" --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig= "$@" -gexit 2>&1 | sed 's/\x1b\[[0-9;]*m//g' \
		| grep -E "^\s*(Tests|Passing|Failing|Risky|Pending|Asserts|Time|Scripts)|\[Failed\]|FAILED|^res://.*\.gd$|SCRIPT ERROR|Parse Error|---- " | grep -v "^$"
}
case "$1" in
	root) run -gdir=res://tests ;;
	core) run -gdir=res://tests/core -ginclude_subdirs ;;
	ui) run -gdir=res://tests/ui,res://tests/audio,res://tests/characters ;;
	world) run -gdir=res://tests/world ;;
	all) for g in root core ui world; do bash "$0" "$g"; done ;;
	*) echo "usage: bash tools/gut_group.sh root|core|ui|world|all" ;;
esac
