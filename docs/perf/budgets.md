# Performance budgets

Performance pass Oct 25, Part 5. The budgets stop a future zone, effect or graphics change from quietly slowing the game down on Low and
Medium. Numbers live in `docs/perf/budgets.json`; this page says what they mean and how to check them.

## How to check

```
bash tools/perf_budget.sh             # both halves (about 20 minutes): exit 1 when any area is over
bash tools/perf_budget.sh structure   # headless only, about 1 minute: nodes, meshes, MultiMesh instances, lights, particles, labels, per-frame scripts
bash tools/perf_budget.sh frame [areas] ["0 1"]   # windowed only: frame time, 1% low, draw calls, video memory, RAM
```

- **structure** (`tools/perf_budget.gd`, headless, no GPU): each walkable area is built once at Medium and its tree counted - nodes,
  visible MeshInstance3D nodes, MultiMesh instances, lights, particle emitters, Label3D and nodes running a script every frame (autoloads
  included). These counts grow with every new prop or system and are the same on every PC, so this half can run anywhere, any time.
- **frame** (`tools/perf_run.sh` + `tools/perf_budget_check.js`): the 13 areas at Low and Medium in a real 1600x900 window with vsync off.
  The time budgets are for the development PC (Ryzen 5 4500U, AMD iGPU); on another PC either pass `PERF_BUDGET_SCALE=1.5` (50% longer
  frames allowed) or re-base the file from a fresh run there.
- Run one Godot at a time; close other heavy programs first (this laptop's frame times drift by 10% with heat and background load - the
  1.3x / 1.4x margins absorb that).

## What the budgets are

Base: the Oct 25 numbers after the performance pass (`docs/perf/runs/final.md`).

| Budget | Margin over the Oct 25 number | Why |
|---|---|---|
| avg_ms (average frame) | x1.3 | a new effect that costs 2-3 ms on Medium shows; run-to-run noise (about 10%) does not |
| p99_ms (the 1% low as a frame time) | x1.4 | hitches: worst frames are noisier than the average |
| draw_calls | x1.2 | a new prop type scattered without instancing shows at once |
| vram_mb / ram_mb | x1.15 / x1.12 | uncompressed art or a cache that never empties shows |
| structure counts | x1.2 (counts under 40: +20% or +2) | a builder that doubles its props, a new per-frame script on every NPC |

Medium budgets in the 3D areas sit at 15.6-19.5 ms average: Medium stays at or above about 55 fps on the development PC even at the edge
of its budget. The menus (Deck Station, Collection Book, vendors) are budgeted at their new numbers (7-10 ms), so a change that makes the
3D world render under a menu again (WorldCover) fails the check.

## When a budget fails

1. Re-run the one area (`bash tools/perf_budget.sh frame <area> "<quality>"`): a single slow run is usually heat or a background program.
2. If it fails again, find the cost: `tools/fps_toggles.gd --ab=true` (GPU pieces), `tools/process_census.gd` (scripts), `HITCH_PROFILE=1`
   (pieces of a scene's `_process`), `tools/perf_probe.gd --drawlist=true / --meshlist=true / --far=60 / --lights=true`, `tools/texture_census.gd`.
3. If the cost is wanted (a deliberate new effect), raise that area's budget in `budgets.json` in the same commit and say why in the message.

## Areas

crosspath, forest, gainlands, buffet, dna, heap, capital_out, capital_in, battle, dungeon_map, deck_station, collection, vendor (frame);
crosspath, forest, gainlands, buffet, dna, heap, capital (structure).
