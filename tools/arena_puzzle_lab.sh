#!/usr/bin/env bash
# Fable Nov 20: the Arena puzzle lab (tools/arena_puzzle_lab.gd). Usage: bash tools/arena_puzzle_lab.sh [--id=<puzzle>] [--file=res://...] [--lines=N] [--out=res://...]
cd "$(dirname "$0")/.."
G=/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe
timeout ${LAB_TIMEOUT:-540} "$G" --headless --path . -s res://tools/arena_puzzle_lab.gd -- "$@" 2>&1 | grep -v "leaked\|ObjectDB\|   at: \|still in use\|BUG:\|^Godot\|^$\|Thread object\|wait_to_finish\|PagedAllocator"
