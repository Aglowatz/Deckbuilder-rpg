# Size + performance pass (Nov 3, 2026)

Brief: "SIZE + PERFORMANCE PASS - make The Wayward Path much smaller and lighter without losing quality". Tag `pre-size-pass`
(after 01bb49e0). State: `docs/loop_state.md`. Questions: `docs/overnight_inbox.md` ("Size pass Nov 3").
Goals: download 883 -> 350-450 MB; peak RAM down about a third; 30+ fps on old integrated GPUs in a Low-end preset.
Rule: nothing destructive - every size change lives in `tools/art_import_rules.json`, the import scripts or the export filters,
so it can be undone by re-importing. Quality gate: a visual or listening check per change, backed off when visibly worse at play size.

## Min-spec target

A 2018 laptop: Intel UHD 620 (Kaby Lake / Whiskey Lake iGPU, ~0.4 TFLOPS, shares system RAM, DX12 feature level 12_1, Vulkan 1.1,
OpenGL 4.5), **4 GB RAM** (about 2.5 GB usable by one game once Windows 10 and the GPU's share are taken), Windows 10, a 1366x768
or 1920x1080 panel. What that means for the game: the process peak must stay well under 1.5 GB, video memory (shared) under about
600 MB, and the Low-end preset must hold 30 fps at 0.67 render scale on a GPU roughly a third as fast as the development AMD iGPU
(Ryzen 5 4500U / Vega 6; the Medium 60 fps target here is a Low-end 30 fps target there).

## Part 0 - baseline (before anything changed)

Development PC: Ryzen 5 4500U, Vega 6 iGPU, 7.4 GB RAM, Windows 11, D3D12, 1600x900 window, vsync off (`tools/perf_run.sh size_base`,
raw lines `docs/perf/runs/size_base.txt`). RAM = process working set at steady state, peak = `PeakWorkingSet64` of that run
(a single area straight from launch; a long session sits higher because the session caches fill). Load = load + instantiate + `_ready`.

### Download

v0.5.1 zip: **799 MB** (762 MiB); estimated payload (`node tools/build_audit.js`): **874 MB** + the baked zone cache (18.6 MB) = ~883 MB pck.

| Category (packed MB) | Baseline |
|---|---:|
| audio: music/ambience (123 OGG, Vorbis q5 ~160 kbps) | 218.7 |
| world textures (TEX/ENV/DEC, kit, BC7) | 123.4 |
| zone kits (heap 64, gainlands 53, final 37, buffet 28, dna 22.5, openingforest 4, town 3; BC7 + lossy backdrops) | 212 |
| backgrounds / key art (stills, loading paintings, BC7 at 1920) | 64.2 |
| UI and icons | 42.7 |
| world test art (painted world sprites 38.6, backdrops, sky, foliage) | 42.7 |
| card art (357 cards 31.2 + 356 thumbs 8.4) | 39.6 |
| other (scripts, scenes, data, build cache 18.6) | 30.4 |
| normal + roughness maps | 18.0 |
| audio: sfx (503 files; ambience 8.2) | 17.5 |
| portraits | 16.4 |
| 3D models (KayKit characters 12.7) | 10.4 |
| sprites (cosmetics) / maps / battleboards / vendor screens / bestiary / fonts | 7.3 / 7.3 / 6.2 / 3.5 / 7.3 / 0.6 |
| **Total** | **874.2** |

Per-folder table: `node tools/build_audit.js --folders 4`.

### Memory, load and frame times

| Area | Q | avg fps | 1% low | avg ms | GPU ms | load ms | RAM MB | peak MB | VRAM MB | tex MB |
|---|---|---|---|---|---|---|---|---|---|---|
| title | Low | 293 | 270 | 3.41 | 1.43 | 318 | 667 | 674 | 109 | 44 |
| title | Medium | 304 | 270 | 3.29 | 1.41 | 255 | 638 | 644 | 109 | 44 |
| story (ending) | Low | 434 | 360 | 2.30 | 1.33 | 255 | 607 | 672 | 83 | 42 |
| story (ending) | Medium | 413 | 300 | 2.42 | 1.38 | 250 | 602 | 672 | 83 | 42 |
| crosspath | Low | 85.2 | 34.5 | 11.74 | 8.51 | 5593 | 1475 | 1505 | 819 | 404 |
| crosspath | Medium | 65.0 | 41.7 | 15.38 | 12.94 | 5129 | 1542 | 1575 | 843 | 418 |
| forest | Low | 122.8 | 90.0 | 8.14 | 6.90 | 1748 | 788 | 794 | 231 | 137 |
| forest | Medium | 80.1 | 40.0 | 12.49 | 11.21 | 1993 | 797 | 802 | 253 | 152 |
| gainlands | Low | 93.4 | 54.0 | 10.70 | 7.69 | 4338 | 1324 | 1354 | 669 | 296 |
| gainlands | Medium | 71.6 | 40.0 | 13.96 | 11.98 | 3682 | 1321 | 1354 | 691 | 307 |
| buffet | Low | 97.7 | 57.2 | 10.24 | 7.64 | 3800 | 1227 | 1227 | 585 | 290 |
| buffet | Medium | 72.9 | 60.0 | 13.72 | 11.66 | 3293 | 1192 | 1227 | 590 | 300 |
| dna | Low | 87.6 | 48.4 | 11.42 | 7.39 | 3560 | 1256 | 1256 | 584 | 277 |
| dna | Medium | 76.7 | 48.4 | 13.04 | 10.23 | 3470 | 1247 | 1247 | 609 | 289 |
| heap | Low | 82.7 | 28.8 | 12.09 | 8.19 | 6451 | 1331 | 1361 | 695 | 313 |
| heap | Medium | 66.4 | 45.8 | 15.07 | 12.73 | 4929 | 1331 | 1371 | 716 | 321 |
| capital_out | Low | 74.7 | 36.2 | 13.38 | 9.96 | 7933 | 1421 | 1453 | 784 | 329 |
| capital_out | Medium | 58.0 | 26.5 | 17.24 | 14.67 | 7344 | 1475 | 1511 | 828 | 350 |
| capital_in | Low | 79.9 | 50.6 | 12.52 | 9.19 | 6880 | 1428 | 1447 | 790 | 331 |
| capital_in | Medium | 58.3 | 47.9 | 17.15 | 14.85 | 7069 | 1489 | 1513 | 819 | 346 |
| battle | Low | 353 | 330 | 2.84 | 1.91 | 521 | 767 | 772 | 179 | 80 |
| battle | Medium | 361 | 330 | 2.77 | 1.93 | 446 | 775 | 779 | 176 | 80 |
| dungeon_map | Low | 485 | 420 | 2.06 | 1.24 | 989 | 608 | 674 | 113 | 45 |
| dungeon_map | Medium | 480 | 420 | 2.08 | 1.25 | 904 | 606 | 673 | 113 | 45 |
| deck_station | Low | 132 | 60.0 | 7.57 | 3.62 | 4746 | 1563 | 1599 | 838 | 382 |
| deck_station | Medium | 129 | 67.4 | 7.78 | 4.13 | 4937 | 1572 | 1609 | 878 | 404 |
| collection | Low | 159 | 118 | 6.30 | 3.71 | 4535 | 1495 | 1530 | 808 | 382 |
| collection | Medium | 153 | 107 | 6.52 | 4.07 | 4646 | 1557 | 1592 | 843 | 408 |
| vendor | Low | 184 | 135 | 5.44 | 3.09 | 4545 | 1491 | 1527 | 796 | 383 |
| vendor | Medium | 178 | 96.9 | 5.61 | 3.57 | 4847 | 1460 | 1495 | 778 | 369 |

Reading of the baseline:

- **The process floor is ~600 MB** before any world loads (title, story, dungeon map all sit at 600-670 MB with 45 MB of textures):
  engine + autoloads + preloaded data. Every walkable area adds 600-900 MB of RAM on top, and 580-840 MB of video memory
  (shared on an iGPU: it comes out of the same 4 GB). Crosspath with a menu open peaks at 1.6 GB - over the min-spec budget on its own.
- **Load times** of 3.3-7.9 s (Capital 7-8 s, Dump 5-6 s, Crosspath 5-6 s) on a fast NVMe PC; a 2018 laptop with a SATA SSD or a
  hard disk and a third of the GPU will be 2-3x that.
- Frame times at Medium are GPU-bound (11-15 ms of GPU in the zones, CPU 2 ms). Low is 8-10 ms of GPU: the UHD 620 at a third of the
  shading rate needs the render scale and the per-pixel passes cut, not fewer draw calls (Oct 25 finding).

## Parts 1-8

(filled in as each part lands)
