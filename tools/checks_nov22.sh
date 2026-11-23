#!/usr/bin/env bash
# Fable Nov 22 night, Part 6: the walk smokes, the probes and the smokes that go stale, one Godot at a time. One line per check;
# the full output of each is in _logs/n22/<name>.log.     bash tools/checks_nov22.sh [names...]
cd "$(dirname "$0")/.." || exit 1
mkdir -p _logs/n22
names="${*:-buffet_walk_smoke dna_walk_smoke capital_walk_smoke crosspath_walk_smoke gainlands_walk_smoke heap_walk_smoke hub_walk_smoke npc_visibility_probe fade_probe quest_handin_probe playtest_smoke gamepad_smoke old_well_smoke dungeons_final_smoke}"
for name in $names; do
	[ -f STOP_OVERNIGHT ] && exit 3
	start=$(date +%s)
	timeout 1500 bash "tools/run_$name.sh" > "_logs/n22/$name.log" 2>&1
	code=$?
	echo "$name: exit $code, $(( $(date +%s) - start )) s, script errors $(grep -c 'SCRIPT ERROR' "_logs/n22/$name.log"); $(grep -iE 'passed|failed|PASS|FAIL' "_logs/n22/$name.log" | tail -1 | cut -c1-160)"
done
