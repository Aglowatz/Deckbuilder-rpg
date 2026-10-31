# Performance pass (Oct 25-26) - report

Goal: the game runs clearly faster and lighter on older / low-end PCs with no visible quality loss. Development PC: Ryzen 5 4500U with
its AMD integrated GPU (D3D12), 7.4 GB RAM, window 1600x900. Start `476eb756` (tag `pre-perf-oct25`); commits `abbee717` (Parts 0-1),
`60777e0b` (3a), `429276cd` (2 + 4), `4ff5ce6c` (5) and the Part 6 commit with this report. Running notes and every decision:
`docs/perf/perf_state.md`; baseline and ranked costs: `docs/perf/baseline.md`; budgets: `docs/perf/budgets.md`.

## Headline

- **Medium, every 3D area now runs at 67-84 fps** (was 48-74). The Capital went from 48-51 to 70-71, the Dump from 51 to 76, Crosspath
  from 55 to 67. The 1% lows improved more than the averages (Capital outside 14 -> 58, Crosspath 33 -> 55, Gainlands 30 -> 58).
- **Low, every 3D area runs at 83-125 fps** (was 62-109): Low had been limited by scripts, not the GPU.
- **Menus over the town run at 136-184 fps** (were 48-70): the 3D town no longer renders behind an opaque screen.
- **Loads** (after Phase 2, warm cache, Medium): Crosspath 8.2 -> 4.5 s, the Dump 8.6 -> 5.2 s, Gainlands 5.7 -> 3.5 s, Buffet 4.5 -> 3.1 s,
  the Capital 6.4-6.5 -> 5.0-5.2 s, D.N.A. 3.4 -> 2.9 s, the forest 2.1 -> 1.8 s (`docs/perf/runs/ph2_loads_warm.md`).
- **Memory**: video memory after visiting every zone stays at ~950 MB in town instead of climbing to ~1017 MB; textures in town after the
  tour 455 MB instead of 522; zones 45-100 MB lower on a second visit; full-screen paintings are 4x smaller in video memory.
- **Nothing looks different**: every area was photographed from the same camera spot before and after; the pixel differences are at
  the level of two runs of unchanged code (wind, clouds, particles) - heat maps show only motion (`docs/perf/diff_final.md`).

## Before / after (Part 0 vs Part 6, same tool, same spots)

`bash tools/perf_run.sh` (vsync off, 3 s warm-up, 6 s sample). Raw: `docs/perf/runs/baseline.txt`, `final.txt`.

| Area | Q | fps before -> after | 1% low | CPU ms | GPU ms | draw calls | RAM MB | VRAM MB | load s |
|---|---|---|---|---|---|---|---|---|---|
| crosspath | Low | 69 -> **90** | 54 -> 60 | 2.72 -> 1.85 | 10.66 -> 8.52 | 565 -> 567 | 1540 -> 1553 | 820 -> 809 | 8.0 -> 5.6 |
| crosspath | Medium | 55 -> **67** | 33 -> 55 | 2.47 -> 1.97 | 16.05 -> 13.18 | 694 -> 693 | 1613 -> 1649 | 860 -> 834 | 8.2 -> 5.1 |
| forest | Low | 109 -> **125** | 67 -> 105 | 1.08 -> 0.76 | 7.82 -> 6.87 | 129 -> 129 | 924 -> 821 | 254 -> 249 | 2.0 -> 1.9 |
| forest | Medium | 74 -> **84** | 42 -> 75 | 1.21 -> 1.13 | 12.21 -> 10.62 | 165 -> 165 | 933 -> 922 | 276 -> 272 | 2.1 -> 2.2 |
| gainlands | Low | 70 -> **85** | 58 -> 67 | 2.18 -> 2.27 | 9.22 -> 7.50 | 412 -> 410 | 1402 -> 1449 | 691 -> 679 | 5.8 -> 4.7 |
| gainlands | Medium | 58 -> **68** | 30 -> 58 | 2.85 -> 2.73 | 13.76 -> 11.35 | 528 -> 530 | 1462 -> 1438 | 713 -> 701 | 5.7 -> 3.8 |
| buffet | Low | 80 -> **106** | 60 -> 66 | 1.97 -> 1.61 | 8.52 -> 7.17 | 378 -> 375 | 1263 -> 1308 | 577 -> 553 | 5.0 -> 3.8 |
| buffet | Medium | 69 -> **81** | 42 -> 66 | 2.03 -> 1.67 | 12.35 -> 10.48 | 481 -> 481 | 1320 -> 1307 | 597 -> 581 | 4.5 -> 3.4 |
| dna | Low | 79 -> **97** | 60 -> 60 | 1.80 -> 1.62 | 7.83 -> 6.90 | 381 -> 376 | 1318 -> 1253 | 570 -> 549 | 3.6 -> 3.4 |
| dna | Medium | 71 -> **83** | 46 -> 48 | 2.31 -> 1.60 | 11.02 -> 9.53 | 606 -> 612 | 1327 -> 1252 | 589 -> 577 | 3.4 -> 3.3 |
| heap | Low | 65 -> **92** | 43 -> 67 | 2.00 -> 2.26 | 9.96 -> 7.16 | 438 -> 438 | 1404 -> 1478 | 700 -> 703 | 8.1 -> 8.0 * |
| heap | Medium | 51 -> **76** | 39 -> 67 | 2.87 -> 2.36 | 13.60 -> 11.11 | 750 -> 748 | 1405 -> 1464 | 728 -> 718 | 8.6 -> 6.4 |
| capital_out | Low | 62 -> **84** | 36 -> 69 | 1.88 -> 1.57 | 10.59 -> 7.61 | 285 -> 287 | 1492 -> 1547 | 733 -> 720 | 7.0 -> 6.5 |
| capital_out | Medium | 48 -> **71** | 14 -> 58 | 2.54 -> 1.82 | 15.25 -> 12.00 | 397 -> 399 | 1495 -> 1550 | 769 -> 751 | 6.5 -> 6.6 |
| capital_in | Low | 62 -> **83** | 46 -> 58 | 2.06 -> 1.72 | 10.44 -> 7.43 | 318 -> 317 | 1506 -> 1579 | 743 -> 728 | 6.3 -> 6.6 |
| capital_in | Medium | 51 -> **70** | 30 -> 56 | 2.61 -> 1.86 | 14.59 -> 12.05 | 474 -> 474 | 1512 -> 1576 | 778 -> 759 | 6.4 -> 6.7 |
| battle | Low | 324 -> **344** | 270 -> 300 | 0.79 -> 0.75 | 2.04 -> 1.85 | 201 -> 195 | 827 -> 821 | 173 -> 167 | 0.6 -> 0.5 |
| battle | Medium | 328 -> **343** | 270 -> 300 | 0.80 -> 0.71 | 2.05 -> 1.84 | 200 -> 198 | 822 -> 820 | 170 -> 168 | 0.5 -> 0.4 |
| dungeon_map | Low | 429 -> **452** | 360 -> 420 | 0.37 -> 0.31 | 1.30 -> 1.24 | 48 -> 48 | 678 -> 676 | 107 -> 102 | 1.1 -> 0.9 |
| dungeon_map | Medium | 427 -> **451** | 360 -> 420 | 0.36 -> 0.31 | 1.32 -> 1.24 | 48 -> 48 | 678 -> 678 | 107 -> 102 | 0.9 -> 0.8 |
| deck_station | Low | 56 -> **137** | 17 -> 99 | 4.23 -> 1.58 | 12.64 -> 3.70 | 1207 -> 677 | 1610 -> 1633 | 865 -> 829 | 5.4 -> 4.8 |
| deck_station | Medium | 48 -> **136** | 21 -> 100 | 4.00 -> 1.63 | 17.76 -> 3.97 | 1342 -> 677 | 1678 -> 1609 | 901 -> 854 | 5.5 -> 5.0 |
| collection | Low | 65 -> **162** | 53 -> 120 | 3.61 -> 0.94 | 11.87 -> 3.57 | 753 -> 220 | 1548 -> 1562 | 826 -> 795 | 4.9 -> 4.7 |
| collection | Medium | 52 -> **155** | 34 -> 99 | 3.18 -> 0.99 | 16.67 -> 3.83 | 884 -> 220 | 1546 -> 1570 | 859 -> 810 | 5.2 -> 4.9 |
| vendor | Low | 70 -> **184** | 55 -> 135 | 2.80 -> 0.35 | 10.92 -> 3.07 | 586 -> 54 | 1609 -> 1671 | 821 -> 813 | 4.7 -> 4.7 |
| vendor | Medium | 55 -> **178** | 34 -> 120 | 2.56 -> 0.39 | 16.05 -> 3.36 | 719 -> 54 | 1543 -> 1624 | 849 -> 799 | 5.0 -> 4.9 |

\* The first run of an area after a builder script changed rebuilds its cache (the Dump's and the Capital's Low rows and the Capital's
Medium rows here): the cached load is the Medium Dump number. The Capital's loads are dominated by its procedural kit meshes (walls 1.6 s),
which are not cached yet (see "Not done"). Process RAM in a single fresh area is within +-5% (the run-to-run spread); the memory gains are
across a session (below).

Memory across a session (`tools/memory_probe.tscn`: Crosspath -> each zone -> Crosspath, twice round), town video memory: before
884 -> 901 -> 931 -> 940 -> 950 -> 979 -> 993 -> 1015 -> 1015 -> 1015 -> 1017 MB; after 884 -> 901 -> 920 -> 920 -> 921 -> 923 -> 926 ->
948 -> 948 -> 947 -> 949 MB. Textures in town: 444 -> 523 MB before, 444 -> 455 MB after. Video memory in the zones on the second loop:
Gainlands 855 -> 756, D.N.A. 766 -> 662, the Dump 920 -> 818, the Capital 944 -> 859 MB. (Measured before the BC7 change, which takes
another ~32 MB of textures off the town.)

## What each part did

**Part 0 - baseline and profiling.** New tools: `tools/perf_probe.gd` + `tools/perf_run.sh` (all the columns above per area and level),
`tools/process_census.gd` (the frame cost of each group of per-frame scripts, A/B against a baseline span), `tools/texture_census.gd`
(textures a scene uses and the art caches), `tools/perf_shots.sh` + `tools/pixel_diff.gd` (same-spot PNGs and a diff with heat maps),
`tools/gut_group.sh` (GUT in four groups), `HITCH_PROFILE=1` (ms per frame of each `Hitch` label), `LoadTiming.detail` marks inside every
zone builder (`LOAD_TIMING=1`), `fps_toggles.gd --ab=true --only=`, `perf_probe.gd --far / --drawlist / --meshlist / --batchable / --lights`.
Findings: Medium is GPU-bound everywhere; Low was script-bound in the big zones; menus rendered the hidden town; loads painted splat images
and placed foliage pixel by pixel in GDScript.

**Part 1 - build zones once.** `BuildCache` (`world/build_cache.gd`) stores the slow, deterministic results of a build - the painted
ground's splat images, the town's painted ground mesh, the foliage placement - keyed by a hash of every `world/` script and the art / zone
data plus the story state they depend on. A builder change rebuilds automatically; `bash tools/build_cache.sh clear` forces it;
`tools/export_windows.sh` bakes every area into `res://build_cache/` first so the exported game never computes them. Whole-scene baking
was rejected: the builders mix nodes with game data and ~15 runtime systems find their nodes during the build (decision P1-a).

**Part 2 - fewer draw calls: measured, nothing kept.** Draw calls and triangles are not the limit on this hardware: runtime LODs for the
kit meshes (castle 33k triangles) saved 0.1-0.3 ms, culling small far props nothing, and instancing the Dump's repeated stand-ins found only
45 pieces that could be merged without touching fading, ground light or code-held nodes. All reverted (P2-a..c). The existing KitBatch
merging and MultiMesh foliage/tree fields already cover the repeated kit props.

**Part 3 - don't draw or update what can't be seen.** `WorldCover`: a menu keeps the last world frame as a still picture under its own
backdrop and switches the window's 3D rendering off once it has faded in. Per-frame work only where it shows: sprites, strolling citizens
and patrolling enemies out of the camera's view update every 4th frame with the missed time; sprites send shader values only when they
change; zone markers, name plates and the E prompt only look at spots near the hero; chest positions and ground heights are read once.
The Capital's per-frame zone work went from ~2.4 ms to ~1.1 ms on Low. Not done: visibility ranges (no gain, P2-b), occluders (the cost
is in what is visible), UI pooling / virtualised grids (the menus now run at 136-184 fps; the Deck Station's 677 draw calls are its cards).

**Part 4 - memory.** NPC sprite frames are dropped from the cache when the player changes area (the hero's stay). Full-screen paintings
whose sides are multiples of 4 (screen backgrounds, story stills, three loading paintings, the foliage atlas) import as BC7: 4x less video
memory, no WebP decode at load; screenshots differ by at most 2/255 per 32-pixel block. Portraits were tried and reverted (+20 MB export
for ~2 MB of memory). Export estimate 725.8 -> 741.5 MB (budget 800).

**Part 5 - safety nets.** `DynamicResolution`: Auto (Low and Medium), Always or Off in Settings > Display; it steps the 3D scale down 0.04 at
a time when the frame stays slow and the GPU is the reason, back up when there is room, never more than 0.14 below the level's scale. On
this PC it stays idle (every area is over 66 fps on Medium now); forced on High it steps 1.00 -> 0.86 in two seconds and holds. Budgets:
`bash tools/perf_budget.sh` (headless structure counts + windowed frame time / 1% low / draw calls / memory at Low and Medium) fails when an
area goes over `docs/perf/budgets.json`.

## Checks (Part 6)

- GUT in groups: root 246, core 1414 (+1 pending, as before), ui/audio/characters 195, world 394 - all passing.
- Walkability (GUT world group), every zone walk smoke (Crosspath, Gainlands, Buffet, D.N.A., the Dump, the Capital: OK; the hub smoke
  has one pre-existing failure, the same with the cache off - inbox item 2), first battles smoke OK, tour bot OK (281 spots, 9 menus,
  5 battles, 0 errors), story playthrough 90/90.
- Screenshots of all 13 areas against the pre-pass set (`docs/perf/diff_final.md`, `_screenshots/perf/final` vs `p1_before`, heat maps in
  `heat_final`): menus 0.26-0.47 mean (no pixel over 16 on the Deck Station and Collection Book), 3D areas within or near the noise floor of
  two unchanged runs; the heat maps of the higher ones (forest, Gainlands, Dump) show only cloud shadows, wind, water and particles.
- Nothing was reverted for visual reasons; four ideas were reverted because they did not pay (runtime LODs, far culling, instancing,
  BC7 portraits).

## Headroom for future graphics work

On the development iGPU at Medium the 3D areas now spend 11.9-15.0 ms per frame against the 16.7 ms of 60 fps: **about 1.7-4.8 ms of
headroom** per area (Crosspath is the tightest at ~1.7 ms, Gainlands and the Capital ~1.9-2.7 ms; the Dump, Buffet, the forest and D.N.A.
3.5-4.8 ms). That is room for one Tier 2 item per zone at Medium - e.g. SSAO at half resolution (~2 ms measured in Tier 1) in the lighter zones,
or the bounce-colour ground light channel everywhere. Low has 4.7-8.7 ms of headroom. The budgets file will flag anything that eats more.

## Phase 2 (after the six parts)

- Cycle 1: the painted material layers (30 textures prepared once per session, ~0.5 s on the first area) and the Capital's land rim
  (1.2 s -> 0.2 s) come from the build cache; `KitMesh.snapshot / restore / fill_cached` can cache any kit geometry.
- Cycle 2 (reverted): caching the kit buildings and the hub tree belt (Crosspath 5.1 -> 4.2 s) broke the warm-cache Crosspath walk smoke
  at one spot; reverted, cause open (inbox 3). Rule since: every cached piece gets a cold AND a warm walk smoke.
- Cycle 3: the Dump's land mesh from the cache (1.26 -> 0.14 s).
- Frame rates were re-checked in the warm load runs (Medium 65-85 fps, as in the table above).

## Not done / next

- Remaining load costs: Crosspath's TownSquare (0.9 s) and kit buildings (0.5 s, the reverted cache), the Capital's buildings (0.76 s) and
  castle (0.45 s), HubLand's boundary / outskirts / tree belt (0.25 / 0.19 / 0.3 s), the Gainlands land (0.46 s).
- UI pooling / virtualised grids for the Collection Book and Deck Station: not needed for frame rate any more; would cut their build time.
- Vendor stage paintings (VS-*, 1672x941) are still RGBA8 (6 MB each, 42 MB warmed in town): not multiples of 4.

## Shadow reach (Fixes Oct 26, Part 1)

The sun's shadow stopped at 26 m on Medium (48 m on High), so the top of the screen had none. Now Medium and High reach each area's measured
view depth: `tools/shadow_reach_probe.gd` puts the hero on ten spots spread over the walkable area, sets Far zoom (`Settings.ZOOM_MAX` 2.0)
and each angle preset, reads the depth buffer back and keeps the farthest pixel whose world point lies in the area's map bounds (+8 m rim,
below 30 m height: far backdrops, the sky and tall landmarks seen from afar are not "the area"). Raw lines: `docs/perf/runs/shadow_reach_a.txt`
/ `_b.txt`. `StyleRig.SHADOW_REACH` = measured + 8 m.

| Area | Measured reach (m) | Shadow reach now (m) |
|---|---:|---:|
| Crosspath | 122.9 | 131 |
| Opening forest | 55.6 | 64 |
| Gainlands | 152.5 | 161 |
| Endless Buffet | 113.9 | 122 |
| D.N.A. | 95.1 | 103 |
| Verdant Dump | 168.2 | 176 |
| Capital (outside / inside) | 176.0 / 181.9 | 190 |

How: Medium two cascades (near split ends at 34 m: the hero and the ground to mid-screen as crisp as the old 26 m map), High four
cascades on its 4096 atlas; the last 6% fades. Two cost cuts keep Medium inside the budget: (1) small casters (rigged characters and
pieces under 2.5 m across) drop the sun's shadow beyond 40 m, round robin 300 meshes a frame (`StyleRig._update_small_casters`); (2) flat
ground planes at or under the ground line never cast (the Capital's 700 x 340 m wasteland, the Dump's far ground filled the far cascade,
~0.5 ms). Measured and dropped: a 2048 Medium atlas (+0.5 ms in the Capital: 57.6 vs 60 fps; the 1024 near cascade was as crisp round the
hero in 2x crops, `_screenshots/p1ab/near2.png`). Unchanged: Low (no sun shadow; Safe Mode is Low), Intel integrated GPUs (26 m / 48 m,
`heavy_passes_allowed`), battle and dungeon backdrops (no measured reach). The zone look files' own lights (dna_look 26 m, the others 60-80 m)
are removed by `StyleRig._remove_old_environment` before the first frame, so none of them overrides the reach. A/B knob: `SHADOW_AB=reach:26,splits:1`.

Medium cost (dev PC, vsync off, 5 s; `docs/art/graphics_tier1/fps_fixes26_p1_before.md` -> `_after.md`, same session):

| Area | fps before -> after | avg ms before -> after | ms cost | GPU ms before -> after | draw calls |
|---|---|---|---:|---|---|
| town_square | 65.8 -> 63.2 | 15.20 -> 15.82 | +0.62 | 13.19 -> 13.16 | 640 -> 714 |
| town_street | 64.7 -> 62.4 | 15.46 -> 16.01 | +0.55 | 13.35 -> 13.65 | 508 -> 564 |
| forest | 80.3 -> 80.0 | 12.45 -> 12.50 | +0.05 | 10.85 -> 10.66 | 165 -> 186 |
| gainlands | 74.0 -> 70.6 | 13.52 -> 14.16 | +0.64 | 11.58 -> 11.44 | 522 -> 794 |
| buffet | 77.2 -> 75.1 | 12.95 -> 13.32 | +0.37 | 11.31 -> 11.33 | 477 -> 727 |
| dna | 84.1 -> 81.5 | 11.89 -> 12.26 | +0.37 | 9.35 -> 10.15 | 609 -> 798 |
| heap | 69.6 -> 66.9 | 14.37 -> 14.95 | +0.58 | 11.85 -> 12.09 | 768 -> 960 |
| capital_out | 66.4 -> 62.8 | 15.06 -> 15.92 | +0.86 | 12.11 -> 13.48 | 402 -> 575 |
| capital_in | 59.8 -> 58.5 | 16.72 -> 17.10 | +0.38 | 14.03 -> 15.35 | 455 -> 706 |

Interleaved A/B at the Capital gate (the tightest spot): old 61.2-62.8 fps, new 59.5-60.4. Today this laptop ran ~10-15% slower than on
Oct 25-26 night (capital_in was 70 fps then at the same spot with the old shadows), so the absolute numbers are low across the board.
Low: Crosspath 88.8 -> 91.1 (noise; same draws). High: 18.4 -> 18.8 fps (noise). `perf_budget.sh frame` (Medium): every avg_ms and p99 line
met (Crosspath and capital_out each passed p99 on a re-run after one spike); the Medium draw-call lines of gainlands, buffet, dna, heap,
capital_out and capital_in were raised to the new counts x1.2 (they are depth-only draws of the far cascade; frame time is the budget that
matters, budgets.md "When a budget fails" 3). `perf_budget.sh structure`: OK.

## Memory leak - fixed (overnight Oct 28-29, Part 5)

**Symptom.** Video memory in Crosspath climbed with every trip out and back (the open "~33 MB per Crosspath visit" of next_up): with
`tools/memory_probe.tscn` over every zone twice, town read 908 -> 985 MB video, 294 -> 457 MB static, 8968 -> 10771 objects, while the
node count, texture memory, buffer memory and resource count stayed flat - so the leaked things were neither nodes, textures nor loaded
resources. A Crosspath <-> one-zone loop (`memory_probe.tscn -- --zone=<id> --trips=N`, new tonight) put it on the D.N.A.: about +560
objects and +23 MB video per visit; the other zones +0-45 objects and ~0 MB on a repeat visit. `--verbose` at exit showed the objects were
all freed at shutdown, so something alive for the session was holding them.

**Cause.** `DnaMaterials._fade_materials` (world/dna/dna_materials.gd): every `DnaFadeMesh` slot (the cabinets, partitions and full-height
walls of the D.N.A. and the office interior) registered its ShaderMaterial in a static array so the scene can feed them the hero position
and the room cut each frame - and nothing ever took them out. 562 materials per visit, each with its GPU-side uniform set, kept for the
whole session (and still written to every frame).

**Fix.** The list holds weak references: a material lives as long as the merged mesh that draws it, and `fade_materials()` drops freed ones
whenever the list is walked (`set_hero_pos`, `set_room_cut`). Same pattern as the Oct 23 StyleToon / KitFoliage fix.

**Numbers** (`bash tools/run_memory_roundtrip_smoke.sh`: one warm-up lap of every zone and the Forgotten Cave, then 10 measured round trips
Crosspath -> zone or cave -> Crosspath, cycling Gainlands, D.N.A., Buffet, Dump, Capital, cave; readings in town):

| | static | video | objects |
|---|---:|---:|---:|
| before (fix reverted) | 451.6 -> 458.2 MB (**+6.6**) | 962.9 -> 1009.4 MB (**+46.5**) | 10215 -> 11364 (**+1149**) |
| after | 445.3 -> 446.1 MB (**+0.8**) | 935.4 -> 935.8 MB (**+0.4**) | 10025 -> 10053 (**+28**) |

The smoke fails when static or video memory grows more than 5 MB or objects more than 200 over the measured trips. Not touched: the first
visit to each area still adds its caches (sprite frames, kit textures, ~20-30 MB the first time); that is bounded (the warm-up lap).

## Faster loading (Overnight Oct 30-31, Part 5)

Measured on the real path (`LOAD_TIMING=1 bash tools/play.sh docs/review/play_scripts/oct31_p5_loads.txt <run>`: title -> snapshot into
Crosspath -> the Dump -> Crosspath; `load_timing:` lines, fade-out to fade-in, Medium, 1600x900). **This PC is noisy**: the same build
gave 8.3 s and 12.8 s for the first town load in back-to-back runs (the slow runs spend ~5 s in "painted: swaps", disk / paging with ~2 GB
free), so every figure below is from a quiet run and the return trip was checked twice.

| Load | Before (two runs) | After (quiet run; second run) | Change |
|---|---:|---:|---|
| Crosspath, first arrival of the session | 8.4 / 8.3 s | 8.1 s | ~same (the first screens are built under the cover once per session: ~1.7 s, kept on purpose) |
| The Verdant Dump | 7.3 / 6.7 s | 6.7 s | same |
| Crosspath, coming back from a zone | 7.1 / 7.2 s | **6.0 / 6.0 s** | **-1.2 s** |
| Worst frame in the 5 s after the fade-in | 30-68 ms | 36-49 ms | no new hitch |

What changed (`world/town_scene.gd`):
- The ~250 files of the first seconds in town (every facing of the painted characters, the footsteps, voices, ambience) are asked for on
  loader threads as soon as the actors and enemies exist (2.9 s into the build) instead of at its end; the reveal waited 1.2-1.7 s for them.
  The characters added later and the cave arrival's portraits are added at the end (`_warm_late_files`).
- The reveal waits for the first screens (Sable's, Tilly's, the Deck Station, built once a session) but no longer for the menu paintings,
  which keep arriving on threads after the fade-in (a screen opened before its painting arrives waits for the thread's copy, as before).

Tried and dropped: loading the next scene file on a loader thread during the fade-out (`change_scene_to_packed`): the scene's resources
then contend with the main thread's build - Crosspath 8.3 -> 13.1 s, the Dump 6.7 -> 11.8 s. The zones' remaining costs are their builders
(the Dump: landmarks 0.66 s, layout 0.64 s, props 0.4 s, painted swaps 1.0 s) and Crosspath's TownSquare (1.0 s), props (0.8 s) and hub
scenery (1.2 s); caching them is the next step (with a cold and a warm walk smoke per cached piece, the rule since the Oct 25 revert).

Checks: Crosspath walk smoke OK, prologue smoke OK (the cave -> Crosspath arrival; its treeline check updated to the Oct 31 speech
bubble), memory round trip OK (6 trips, static +1.0 MB, video +0.9 MB), structure budget OK. Raw runs: `_screenshots/play/oct31_p5_*`.
