#!/usr/bin/env bash
# UI + economy fixes Oct 22: runs tools/layout_check.gd at each size (one Godot at a time) and keeps the LAYOUT lines.
# Usage: bash tools/layout_check.sh [tag] ["1280x720 1920x1080"] [screens,comma,list] ; SHOTS=true to save pictures.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
tag="${1:-check}"
sizes="${2:-1280x720 1366x768 1600x900 1920x1080 1280x800 1920x1200}"
screens="${3:-}"
mkdir -p _logs
out="_logs/layout_${tag}.txt"
: > "$out"
for size in $sizes; do
	taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
	args=(--size="$size" --tag="$tag" --shots="${SHOTS:-false}" --ui_scale="${UI_SCALE:-1.0}")
	[ -n "$screens" ] && args+=(--screens="$screens")
	"$GODOT" --path . --resolution "$size" -s res://tools/layout_check.gd -- "${args[@]}" 2>&1 | grep "^LAYOUT" | tee -a "$out"
done
echo "report: $out"
