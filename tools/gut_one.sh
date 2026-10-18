#!/usr/bin/env bash
# Runs only the given GUT test scripts (ignores .gutconfig.json's whole-folder run). Usage: bash tools/gut_one.sh tests/a.gd tests/b.gd
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
list=""
for t in "$@"; do list="$list,res://${t#res://}"; done
"$GODOT" --headless --path . -s res://addons/gut/gut_cmdln.gd -gconfig= -gtest="${list#,}" -gexit 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
