#!/usr/bin/env bash
# Usage: tools/fps.sh <scene> <quality 0-2> [--at=anchor] [--zone=...]: frame-time probe in a real window (run alone).
cd "$(dirname "$0")/.."
scene="$1"; q="$2"; shift 2
/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe --path . -s res://tools/fps_probe.gd -- --scene="$scene" --quality="$q" "$@" 2>&1 | grep "fps_probe"
