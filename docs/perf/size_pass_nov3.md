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

## Part 1 - what the game never uses

`node tools/reference_graph.js [--list]` builds the reference check the brief asked for: live code and data (scripts no other live text
mentions are dropped first - 5 dead scripts found, listed by the tool, left in place), the shipped asset text (kit scenes, manifests),
plus every loader that builds a path from an id: sprite sets by folder name (`SpriteLibrary`), `_n` / `_r` / `_nr` maps from the base
texture id (`EnvKit.map_texture`, `PaintedLibrary`), `BST-` / `ICON-GEAR-` / `ICON-ITEM-` / `CUT-` / expression-tagged portraits
(ids compared with punctuation removed), `_128` / `_96` icon sizes, build-cache entries by name, model textures next to a referenced glb.

Result: the export was already clean. Of 7005 exported files (866 MB packed) the graph leaves **84 unreferenced files, 0.8 MB**, and
after a hand check only two are dead: `UI-HUD-TOKENS.webp` and `UI-HUD-REFUSE.webp` (0.4 MB; no `UiArt.has(...)` names them). They
are listed in `tools/export_unused.json`, which `update_export_excludes.js` now folds into the export's exclude filter. The rest of the
list is pattern-loaded art whose id the data no longer carries (four Bestiary pictures of renamed enemies, cosmetic icon sizes) - kept,
since a data edit brings them back. No `_v2` / `(1)` / `_old` duplicates exist in the exported folders; the 450 unreferenced glb
models were already excluded (Oct 23 rule); every sound and font is named by the audio registry or the theme. The world-test folder
is the game's painted sprite art, not test art (all 99 sets are in the manifests and named by NPC data).

The "nothing missing on an exported build" check runs on the test-pack export after the content parts (3-4) and again on the v0.5.2
release export (Part 8), since each export costs about 1.7 GB of RAM on this machine.

## Part 2 - music

Every MUS- score was re-rendered from its Python score through the MIDI + FluidSynth pipeline (`tools/music/build.py`, 123 tracks,
~50 min) and encoded at Vorbis **q3**; the renderer now takes the quality from `VORBIS_Q` / `WP_VORBIS_Q`, writes extra `_q2/_q3/_q4`
encodes with `WP_VORBIS_EXTRA`, and keeps the float WAV master with `WP_KEEP_WAV=1` (about 60 MB a track, so only for checks). Loop
points stay whole-file loops (the render folds the tail onto the start; `deliver.py --approve` re-derived every loop end from the new
file's frame count), levels stay -20 LUFS loops / -17 LUFS stings (every render report says `lufs_ok`; two renders printed
NEEDS ATTENTION but their reports pass every check - the flag belongs to the score checks, not the audio). The previous in-game files
are kept in `C:\Dev\music_tools\q6_backup\` and in git; the Drive registry was backed up by the delivery.

Blind A/B folder: `G:\My Drive\Card Game Art\Music Review\Bitrate test\` (six tracks x q2 / q3 / q4 / current, shuffled letters,
`KEY.txt`). The objective check (`tools/music/bitrate_check.py`, against the WAV masters, sample-aligned):

| Track | Variant | kbps | KB | bandwidth kHz | SNR 2-4k | SNR 4-8k | SNR 8-14k | pre-echo dB |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| MUS-CAP-RESTORED | q2 / q3 / q4 / q6 | 86 / 104 / 120 / 170 | 1552 / 1868 / 2159 / 3065 | 20 / 20 / 20 / 20 | 6.3 / 9.6 / 10.6 / 13.4 | 3.5 / 6.4 / 7.8 / 10.5 | -0.4 / 0.4 / 0.8 / 8.4 | -0.02 / -0.14 / -0.10 / -0.08 |
| MUS-GOUR-EXP | q2 / q3 / q4 / q6 | 88 / 108 / 127 / 180 | 1255 / 1537 / 1805 / 2559 | 16.5 / 17.8 / 19.1 / 20 | 7.1 / 10.2 / 10.7 / 13.6 | 5.7 / 8.2 / 10.4 / 13.3 | 1.2 / 2.2 / 2.9 / 9.8 | -0.05 / -0.29 / -0.26 / -0.18 |
| MUS-REF-EXP | q2 / q3 / q4 / q6 | 95 / 115 / 139 / 198 | 1148 / 1398 / 1681 / 2404 | 16.4 / 17.9 / 19.5 / 20 | 7.6 / 10.8 / 11.6 / 14.7 | 5.0 / 7.8 / 10.4 / 13.4 | 2.5 / 3.6 / 4.4 / 10.6 | -0.09 / -0.39 / -0.38 / -0.28 |
| MUS-NECRO-EXP | q2 / q3 / q4 / q6 | 85 / 105 / 125 / 174 | 1189 / 1475 / 1755 / 2445 | 20 / 20 / 20 / 20 | 9.6 / 12.9 / 14.7 / 17.7 | 7.8 / 10.8 / 13.3 / 16.1 | 1.2 / 2.2 / 2.6 / 8.9 | -0.14 / -0.16 / -0.10 / -0.05 |
| MUS-MEM-01 | q2 / q3 / q4 / q6 | 85 / 103 / 118 / 165 | 808 / 974 / 1115 / 1567 | 16.5 / 17.2 / 17.6 / 18.2 | 6.5 / 9.6 / 10.4 / 13.2 | 4.2 / 7.2 / 8.9 / 11.7 | 0.0 / 1.0 / 1.4 / 8.6 | 0.01 / -0.25 / -0.18 / -0.18 |
| STG-VICTORY | q2 / q3 / q4 / q6 | 94 / 112 / 129 / 180 | 46 / 55 / 63 / 88 | 16.5 / 17.3 / 19.1 / 19.9 | 7.1 / 9.7 / 10.5 / 13.3 | 4.4 / 6.8 / 8.5 / 11.3 | -0.6 / 0.1 / 0.5 / 8.7 | 0.10 / -0.28 / 0.03 / -0.23 |

SNR = the 5th percentile (worst frames) of the per-frame band signal-to-coding-noise ratio; the band's own signal masks noise about
13-15 dB below it, so the 2-8 kHz numbers are the ones to listen for (string / cymbal "swirl"); the 8-14 kHz band is noise-filled by
every Vorbis level below q6 by design (low waveform SNR, perceptually shaped). Pre-echo is nil at every level. **Pick: q3** - the
lowest level that keeps the bandwidth above 17 kHz and the 2-8 kHz worst frames within 3 dB of q4; q2 drops to 16.5 kHz and 6-8 dB.

Saving: the in-game music folder goes **213.3 -> 174.5 MB (-39 MB)**. Less than the six loud tracks promised (-40 %), because the old
files were a mix of q6 renders (up to 170 kbps) and q5 drop-in loops (110-130 kbps); the quiet cues shrink most (-40 %), the dense
ones barely (MUS-CAP-CORRECTION 102 %, MUS-NECRO-FREED 100 %: VBR was already spending little on them). q2 would take a further
~40 MB. Stings (STG-, WAV / QOA, 5 MB) and ambience (8 MB) are unchanged.

## Parts 3-8

(filled in as each part lands)
