#!/usr/bin/env bash
# UI + economy fixes Oct 22, Part 3: contact sheets of every card's art crop -> docs/art/card_crops/<tag>/<kind>_<page>.jpg
# Usage: bash tools/card_crop_sheet.sh [tag] [kinds: field,card,slot] [only: R-22,G-23,T-06]
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
cd "$(dirname "$0")/.."
taskkill //F //IM Godot_v4.7.2-stable_win64.exe >/dev/null 2>&1
args=(--tag="${1:-sheet}" --kinds="${2:-field,card,slot}")
[ -n "$3" ] && args+=(--only="$3")
"$GODOT" --path . --resolution 1920x1080 -s res://tools/card_crop_sheet.gd -- "${args[@]}" 2>&1 | grep "card_crop_sheet\|SCRIPT ERROR\|Parse Error"
