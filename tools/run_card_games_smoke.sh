#!/usr/bin/env bash
# Fable Nov 16c (Part 5): the card games of the four Path zones in the real game with real input - the host's card game, the card quiz
# (How to play, four questions answered by clicking, the trivia's reward and flags) and the one-time reward (the chest that replaced
# the puzzle; the D.N.A.'s File in Order). Shots in _screenshots/card_games/.
# Usage: bash tools/run_card_games_smoke.sh [zone,zone]   (beefcake,gourmand,refusemancer,necrocrat; default all). One Godot at a time.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
CONSOLE="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
export WAYWARD_TEST_SAVES=1  # SaveGuard: never the player's real saves
"$CONSOLE" --headless --path . --import >/dev/null 2>&1
out="$(pwd)/_screenshots/card_games_smoke.log"
mkdir -p _screenshots/card_games
CARD_GAMES_ZONES="${1:-}" timeout 540 "$GODOT" ${GODOT_ARGS:-} --path . --resolution 1600x900 res://tools/card_games_smoke_launcher.tscn > "$out" 2>&1
code=$?
grep -E "^card_games_smoke: (FAIL|OK|FAILED)|SCRIPT ERROR" "$out"
echo "card_games_smoke: $(grep -c '^card_games_smoke: ok' "$out") checks passed, $(grep -c '^card_games_smoke: FAIL' "$out") failed"
if grep -q "SCRIPT ERROR" "$out"; then echo "card_games_smoke: script errors found"; code=1; fi
exit $code
