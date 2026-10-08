#!/usr/bin/env bash
# New brief, Part E: regression test for one corrupted-NPC challenge - talks to Brick Bronson (Beefcake),
# checks the real battle starts with the right opponent, plays it out for real with BattlePilot,
# and checks the town-side result (dialogue, reward/unlock) matches what actually happened.
# Run alone (windowed, real viewport + real SceneManager scene changes needed).
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/corrupted_npc_smoke.log"
mkdir -p _screenshots
timeout 300 "$GODOT" --path . --resolution 1600x900 res://tools/corrupted_npc_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^corrupted_npc_smoke:|SCRIPT ERROR|ERROR:" "$out" | grep -v "BUG: Unreferenced|RID allocations|leaked"
if grep -q "SCRIPT ERROR" "$out"; then echo "corrupted_npc_smoke: script errors found"; code=1; fi
exit $code
