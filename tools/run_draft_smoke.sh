#!/usr/bin/env bash
# Draft mode, Phase 1: the draft smoke (a whole draft and run in each zone, headless). One Godot.   bash tools/run_draft_smoke.sh
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.." || exit 1
"$GODOT" --headless --path . -s res://tools/draft_smoke.gd 2>&1 | grep -E "^draft_smoke|SCRIPT ERROR" | grep -v "Identifier not found"
exit "${PIPESTATUS[0]}"
