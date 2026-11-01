# Performance - Overnight Oct 31 -> Nov 1 (Part 3)

Development PC (Ryzen 5 4500U iGPU, 1600x900, vsync off), nothing else running. Runs: `docs/perf/runs/oct31n_a/b/c` (first pass),
`oct31n_re` (the over-budget areas again). Before = `docs/perf/runs/budget_check.txt` (v0.4.9, Oct 30-31, taken while the PC ran out of memory).

## Frame budget (avg ms / 1% low ms)

| Area | Q | Before | Tonight (first pass) | Tonight (re-run) | Budget (avg / 1% low) |
|---|---|---|---|---|---|
| crosspath | Low | 11.68 / 20.5 | 12.18 / 27.5 | 11.52 / 21.6 | 14.5 / 23.4 |
| crosspath | Medium | 14.89 / 26.1 | 15.00 / 33.3 | 14.54 / 19.3 | 19.5 / 25.3 |
| forest | Low / Med | 7.98 / 9.7, 11.64 / 15.0 | 7.89 / 10.9, 11.95 / 17.7 | - | ok |
| gainlands | Low | 11.15 / 29.2 | 10.86 / 21.2 | 10.73 / 20.7 | ok after re-run |
| buffet | Low | 10.44 / 25.3 | 10.52 / 29.7 | 10.74 / 18.3 | ok after re-run |
| dna | Low / Med | 11.30 / 28.6, 13.64 / 25.0 | 11.26 / 21.1, 13.20 / 24.7 | - | ok |
| heap | Low / Med | 12.51 / 31.3, 15.67 / 21.5 | 12.27 / 18.9, 15.12 / 20.7 | - | ok |
| capital_out | Medium | 15.72 / 21.6 | 15.84 / 37.2 | 15.51 / 22.6 | ok after re-run |
| capital_in | Medium | 15.66 / 27.2 | 15.68 / 21.2 | - | ok |
| **deck_station** | Low | 8.16 / **21.2** | 7.56 / 10.7 | - | 14.2 (1% low) - ok |
| **deck_station** | Medium | 7.93 / **16.7** | 7.72 / 10.3 | - | 14.0 (1% low) - ok |
| collection | Medium | 6.89 / 15.5 | 6.63 / 11.0 | - | ok |
| vendor | Low / Med | 5.87 / 11.1, 6.09 / 14.7 | 5.67 / 7.4, 5.76 / 7.9 | - | ok |
| battle, dungeon map | both | ~3 / ~2 | ~3 / ~2 | - | ok |

**Result**: every area's average is inside budget; after one re-run of the four areas whose first-pass 1% low was over (first-load
hitches on a just-woken PC), every 1% low is inside too. The only steady over is **Crosspath Medium draw calls, 874 vs 840** (836 on
v0.4.9; content added since the Oct 25 baseline - its frame times are fine). Logged, not chased.

- **The Deck Station "21 ms"** was memory pressure, not the curve/shape refresh: quiet, it is 7.6 ms avg / 10.7 ms 1% low.
- **The goal pointer's second marker**: A/B in Crosspath (`--set=goal_pointer:false|true`) 871 vs 876 draw calls, 14.24 vs 14.25 ms.
  Not a cost.
- **Crosspath draw list**: the Verdant Dump's thorn wall was 103 mesh nodes (72 spikes + 12 vines one node each). Spikes and vines are now
  one MultiMesh each (`HubObstacles._batch`; same shapes, placements and materials): 103 -> 19 nodes there, 1806 -> 1724 nodes in town.
  It saves draw calls only where the wall is on screen (the budget probe's spot does not see it, hence 874 both ways).
  Hub walk smoke OK cold (dev build cache cleared) and warm.

## Loading (LOAD_TIMING=1, `docs/review/play_scripts/oct31_p5_loads.txt`, warm cache)

| Step | ms |
|---|---|
| snapshot -> town (fade in at) | 8146 (first load of the session) |
| town -> the Dump (fade in at) | 6578 (builder 2448: `layout.build` 641, landmarks 630, props 303, terraces 214; painted swaps 988) |
| the Dump -> town (fade in at) | 5553 (TownSquare 783-984, `_build_props` 663-760, hub scenery 1106-1374 with `_tree_belt` 264-293, boundary 206-247) |
| cold cache (after any world/*.gd edit), the Dump | builder 3503, painted swaps 5005 |

**Not cached tonight (time-boxed, logged)**: the remaining big steps are model instancing (TownSquare, the Dump's landmarks and props: scene
trees, which the Oct 25 decision keeps out of the cache - "no whole-scene baking") or `HeapLayout.build` (641 ms of pure data, but ~15 kinds of
inner objects to serialise - a careful job of its own). The hub tree belt (264-293 ms) is the piece whose cache broke the warm Crosspath walk
smoke on Oct 25 (cause unknown). Next lever, in order: `HeapLayout` as a cached dictionary (with a cold + warm heap walk smoke), then the hub
`boundary` (206-247 ms, KitMesh-shaped).
