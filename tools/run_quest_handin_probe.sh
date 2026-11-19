#!/usr/bin/env bash
# Fable Nov 20 (Part 4.2): the quest hand-in probe. For every quest handed in to somebody: every step is forced done, the hero stands on
# that NPC's spot in the hand-in area, talks, and the quest must be completed. Windowed (one Godot at a time), about 10 minutes.
#   bash tools/run_quest_handin_probe.sh [area]      area = town | beefcake | gourmand | refusemancer | necrocrat | final
# Report: docs/quests/handin_probe.txt (one line per quest). Exit code 0 = every hand-in works.
cd "$(dirname "$0")/.."
script="_logs/handin_probe_script.txt"
mkdir -p _logs docs/quests
printf 'wait 3\nhandins %s\n' "$1" > "$script"
bash tools/play.sh "$script" handin_probe 1800 > _logs/handin_probe_stdout.txt 2>&1
grep -h "handin" _screenshots/play/handin_probe/stdout.log | sed 's/^play: *//' | grep "^handin" > docs/quests/handin_probe.txt
cat docs/quests/handin_probe.txt
if grep -q "SCRIPT ERROR" _screenshots/play/handin_probe/stdout.log; then echo "handin probe: script errors"; grep -m5 "SCRIPT ERROR" _screenshots/play/handin_probe/stdout.log; exit 1; fi
grep -q "handin: [0-9]* passed, 0 failed" docs/quests/handin_probe.txt
