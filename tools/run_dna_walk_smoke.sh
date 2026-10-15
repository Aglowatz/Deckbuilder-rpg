#!/usr/bin/env bash
# D.N.A. walk smoke (the slice, Part E): the approach causeway and the gate, the Lobby Plaza, every quest NPC and the vendor, the interactables, the quiz,
# the matching game, the puzzle, Sub-Basement 3, the Hall of Final Approvals at its stair, the giant chest and the lever, every sub-area and the walk back
# out to town, with real input, windowed; screenshots in _screenshots/dna_walk/. Run alone (one Godot process at a time). Exit code 0 = every check passed.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/dna_walk_smoke.log"
mkdir -p _screenshots/dna_walk
timeout 600 "$GODOT" --path . --resolution 1600x900 res://tools/dna_walk_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^dna_walk_smoke:|SCRIPT ERROR" "$out"
if grep -q "SCRIPT ERROR" "$out"; then echo "dna_walk_smoke: script errors found"; code=1; fi
exit $code
