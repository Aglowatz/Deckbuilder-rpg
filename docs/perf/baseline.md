# Performance baseline (Part 0, Oct 25 2026)

Development PC: Ryzen 5 4500U, AMD integrated GPU (D3D12), 7.4 GB RAM, window 1600x900, vsync off. Start commit `476eb756`
(tag `pre-perf-oct25`). Tool: `bash tools/perf_run.sh baseline "0 1"` (`tools/perf_probe.gd`: 3 s warm-up, 6 s sample). Raw lines:
`docs/perf/runs/baseline.txt`; the Dump's Low row was re-run with the build cache off (`runs/baseline_heaplow.md`, the first run broke
on a script edited mid-run).

- **1% low** = the 99th-percentile frame. **CPU / GPU ms** = the viewport's measured render time (`viewport_get_measured_render_time_*`);
  CPU here is the render thread's command building only, scripts are not in it. **load ms** = load + instantiate + `_ready` of a
  directly-added scene (the unstaged build; a real arrival adds the loading screen's frames). **worst ms** = the worst frame of the
  first 3 s. **RAM** = the process working set (tasklist), **VRAM** = `RENDER_VIDEO_MEM_USED`, **tex** = texture memory.
- The UI rows (Deck Station, Collection Book, vendor) are Crosspath with the screen open. Their load column already had the Part 1
  splat cache (about 3 s less): the town was 8.0-8.2 s before it.

| Area | Q | avg fps | 1% low | avg ms | CPU ms | GPU ms | draw calls | objects | nodes | load ms | worst ms | RAM MB | VRAM MB | tex MB |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| crosspath | Low | 69.1 | 54.0 | 14.47 | 2.72 | 10.66 | 565 | 913 | 1786 | 7989 | 147 | 1540 | 820 | 402 |
| crosspath | Medium | 55.2 | 33.3 | 18.11 | 2.47 | 16.05 | 694 | 1047 | 1822 | 8170 | 144 | 1613 | 860 | 424 |
| forest | Low | 108.7 | 66.7 | 9.20 | 1.08 | 7.82 | 129 | 278 | 333 | 1959 | 125 | 924 | 254 | 161 |
| forest | Medium | 73.6 | 42.0 | 13.59 | 1.21 | 12.21 | 165 | 313 | 354 | 2061 | 133 | 933 | 276 | 176 |
| gainlands | Low | 70.1 | 57.8 | 14.27 | 2.18 | 9.22 | 412 | 790 | 1634 | 5798 | 136 | 1402 | 691 | 308 |
| gainlands | Medium | 58.0 | 30.0 | 17.25 | 2.85 | 13.76 | 528 | 909 | 1691 | 5680 | 126 | 1462 | 713 | 325 |
| buffet | Low | 80.3 | 60.0 | 12.46 | 1.97 | 8.52 | 378 | 784 | 1487 | 4998 | 122 | 1263 | 577 | 289 |
| buffet | Medium | 68.9 | 42.4 | 14.52 | 2.03 | 12.35 | 481 | 903 | 1489 | 4507 | 125 | 1320 | 597 | 305 |
| dna | Low | 79.1 | 60.0 | 12.64 | 1.80 | 7.83 | 381 | 767 | 1132 | 3631 | 124 | 1318 | 570 | 268 |
| dna | Medium | 70.7 | 46.2 | 14.14 | 2.31 | 11.02 | 606 | 979 | 1130 | 3386 | 121 | 1327 | 589 | 277 |
| heap | Low | 64.9 | 43.3 | 15.42 | 2.00 | 9.96 | 438 | 817 | 2452 | 8113 | 141 | 1404 | 700 | 305 |
| heap | Medium | 50.5 | 38.9 | 19.82 | 2.87 | 13.60 | 750 | 1173 | 2501 | 8589 | 133 | 1405 | 728 | 321 |
| capital_out | Low | 61.7 | 36.0 | 16.21 | 1.88 | 10.59 | 285 | 609 | 2579 | 7013 | 127 | 1492 | 733 | 299 |
| capital_out | Medium | 48.1 | 14.3 | 20.80 | 2.54 | 15.25 | 397 | 730 | 2655 | 6509 | 139 | 1495 | 769 | 320 |
| capital_in | Low | 62.4 | 45.9 | 16.02 | 2.06 | 10.44 | 318 | 836 | 2578 | 6264 | 122 | 1506 | 743 | 300 |
| capital_in | Medium | 50.9 | 30.0 | 19.63 | 2.61 | 14.59 | 474 | 988 | 2652 | 6419 | 132 | 1512 | 778 | 321 |
| battle | Low | 324.1 | 270.0 | 3.09 | 0.79 | 2.04 | 201 | 1300 | 453 | 562 | 139 | 827 | 173 | 86 |
| battle | Medium | 328.3 | 270.0 | 3.05 | 0.80 | 2.05 | 200 | 1301 | 446 | 464 | 133 | 822 | 170 | 84 |
| dungeon_map | Low | 428.9 | 360.0 | 2.33 | 0.37 | 1.30 | 48 | 541 | 206 | 1076 | 133 | 678 | 107 | 49 |
| dungeon_map | Medium | 426.7 | 360.0 | 2.34 | 0.36 | 1.32 | 48 | 541 | 206 | 944 | 133 | 678 | 107 | 49 |
| deck_station | Low | 56.3 | 16.9 | 17.75 | 4.23 | 12.64 | 1207 | 6071 | 2668 | 5428 | 147 | 1610 | 865 | 395 |
| deck_station | Medium | 48.4 | 21.4 | 20.66 | 4.00 | 17.76 | 1342 | 6210 | 2704 | 5486 | 148 | 1678 | 901 | 421 |
| collection | Low | 64.8 | 52.5 | 15.43 | 3.61 | 11.87 | 753 | 2422 | 2988 | 4878 | 133 | 1548 | 826 | 399 |
| collection | Medium | 52.3 | 33.8 | 19.13 | 3.18 | 16.67 | 884 | 2543 | 3024 | 5170 | 148 | 1546 | 859 | 423 |
| vendor | Low | 69.9 | 55.0 | 14.30 | 2.80 | 10.92 | 586 | 1432 | 2255 | 4666 | 148 | 1609 | 821 | 399 |
| vendor | Medium | 55.3 | 34.3 | 18.10 | 2.56 | 16.05 | 719 | 1464 | 2291 | 4966 | 150 | 1543 | 849 | 426 |

## What each area is bound by

- **Medium, every 3D area: GPU (fill rate).** The frame is within 1-4 ms of the GPU time; the iGPU's shading of the world at 0.58 scale,
  the sun shadow, the outline and post passes are the frame.
- **Low, the big zones: CPU scripts.** `tools/process_census.gd` in the Capital on Low: pausing every script takes the frame from about
  10.5 to 7.2 ms, and a 0.25 render scale changes nothing - so Low is limited by the main thread, not the GPU. The groups worth cutting
  (A/B against a baseline span): the zone scene's own `_process` (camera, nearest spot, prompts, banner) ~1.0 ms, `SpriteActor` x11
  ~0.8 ms, a hidden `PortraitView` that keeps processing ~0.4 ms, `MinimapHud` ~0.3, `OcclusionFader` ~0.3, `FastTravelStation` ~0.25,
  `AmbienceManager` ~0.25, the 29 `ZoneEnemy` roamers (noisy, ~1 ms). Everything else is under 0.2 ms.
- **UI screens over the town: the whole 3D town keeps rendering behind an opaque screen.** The Deck Station draws 1207-1342 draw calls
  and 12.6-17.8 ms of GPU for a town nobody can see; the Collection Book and vendor likewise.
- **Battle and the dungeon map** run at 300-430 fps: no work needed.
- **Loads**: Crosspath 8 s, the Dump 8.1-8.6 s, the Capital 6.3-7 s, the Gainlands 5.7 s, the Buffet 4.5-5 s, D.N.A. 3.4-3.6 s,
  the forest 2 s. `LOAD_TIMING=1` breakdown (Medium): the painted ground's splat image painted pixel by pixel in GDScript (Crosspath
  1.5 s + its 1 m overlay grid 1.5 s, the Gainlands 1.4 s, the Capital 0.6 s), StyleRig's toon conversion of every mesh 0.65-0.8 s in
  every zone, the Capital's `_build_boundaries` (procedural wall meshes) 1.6 s, Crosspath's look rig scenery 1.2 s and foliage 0.55 s,
  TownSquare 0.9 s, TownBuilder 0.8 s, the Gainlands look rig 0.8 s.
- **Memory**: process RAM 0.8-1.7 GB, video memory 0.1-0.9 GB; the town is the heaviest (820-900 MB video, 400-425 MB textures).

## Ranked list of the biggest costs

1. UI screens render the hidden 3D world (Deck Station / Collection / vendor: 12-18 ms of GPU, 700-1340 draw calls for nothing).
2. Low is script-bound in the zones (~3.5 ms of 10.5 ms per frame in the Capital): zone `_process`, SpriteActor, ZoneEnemy, a hidden
   PortraitView, the minimap, the fader, the travel station.
3. Medium GPU fill: sun shadow pass, outline, post (world_post) and the world shading at 0.58 - the "fixed" cost of the look
   (next: `tools/fps_toggles.gd` per zone for the shares).
4. Load: splat painting (1-3 s per area) -> Part 1 cache; StyleRig conversion (0.7 s everywhere); procedural kit meshes (Capital walls 1.6 s).
5. Draw calls 400-750 per zone on Medium (CPU render 2-3 ms: not the limit on this PC, but on a weaker CPU with a discrete GPU).
6. Memory: textures 300-425 MB per area, video memory up to 900 MB in town.
