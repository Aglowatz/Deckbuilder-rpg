#!/usr/bin/env bash
# Performance pass Oct 25, Part 5 (docs/perf/budgets.md): fails (exit 1) when an area goes over its performance budget.
#   bash tools/perf_budget.sh            - both halves: the headless structure check, then the windowed frame-time check (Low + Medium)
#   bash tools/perf_budget.sh structure  - headless only (nodes, meshes, MultiMesh instances, lights, particles, labels, per-frame scripts)
#   bash tools/perf_budget.sh frame [areas] [qualities]  - windowed only: avg / 1%-low frame time, draw calls, video memory and RAM per area
# Budgets: docs/perf/budgets.json. The frame budgets are for the development PC (Ryzen 5 4500U iGPU, 1600x900); on another PC run with
# PERF_BUDGET_SCALE=<factor> (e.g. 1.5 allows 50% longer frames) or re-base the file from a fresh tools/perf_run.sh.
cd "$(dirname "$0")/.."
what="${1:-all}"
status=0
if [ "$what" = all ] || [ "$what" = structure ]; then
	/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://tools/perf_budget.gd 2>&1 | grep -E "^\||perf_budget|SCRIPT ERROR"
	[ "${PIPESTATUS[0]}" = 0 ] || status=1
fi
if [ "$what" = all ] || [ "$what" = frame ]; then
	areas="${2:-crosspath,forest,gainlands,buffet,dna,heap,capital_out,capital_in,battle,dungeon_map,deck_station,collection,vendor}"
	qualities="${3:-0 1}"
	bash tools/perf_run.sh budget_check "$qualities" "$areas" >/dev/null
	node tools/perf_budget_check.js docs/perf/runs/budget_check.txt docs/perf/budgets.json "${PERF_BUDGET_SCALE:-1}" || status=1
fi
[ "$status" = 0 ] && echo "perf_budget: all budgets met" || echo "perf_budget: OVER BUDGET (see above)"
exit $status
