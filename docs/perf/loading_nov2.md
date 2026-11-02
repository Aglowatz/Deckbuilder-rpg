# Loading times, Nov 2 pass (Part 3)

Measured with `bash tools/run_loading_timing.sh <run>` (windowed 1600x900, the real SceneManager: fade, loading screen, build, settle; the dev PC, Ryzen 5 4500U iGPU). Load = LoadTiming from `change_scene` to the fade-in; cold = the first build of the area this session (a build-cache miss when world scripts changed), warm = the second. Raw runs: `loading_nov2_before.md`, `loading_nov2_after_parked.md` (+ `.json` under `_screenshots/loading_timing/`).

## Before / after (the parked scene, the shorter loading-screen hold)

| Transition | Before (ms) | After (ms) | Change |
|---|---:|---:|---:|
| title -> town (cold) | 10964 | 11445 | +481 |
| town -> forest (cold) | 2590 | 2621 | +31 |
| forest -> town (warm) | 5210 | 5126 | -85 |
| town -> battle (town) | 1216 | 1198 | -19 |
| battle -> town (town) | 4266 | 932 | -3334 |
| town -> beefcake (cold) | 4831 | 6715 | +1885 |
| beefcake -> battle (cold) | 846 | 765 | -81 |
| battle -> beefcake (cold) | 2869 | 928 | -1941 |
| beefcake -> dungeon map S-IRON | 2284 | 1678 | -606 |
| dungeon map -> beefcake (retreat) | 3686 | 3560 | -126 |
| beefcake -> town (cold) | 5358 | 5162 | -196 |
| town -> gourmand (cold) | 5408 | 5045 | -363 |
| gourmand -> battle (cold) | 777 | 785 | +8 |
| battle -> gourmand (cold) | 2515 | 944 | -1572 |
| gourmand -> dungeon map S-GOUR | 2296 | 1601 | -695 |
| dungeon map -> gourmand (retreat) | 3287 | 3270 | -17 |
| gourmand -> town (cold) | 5206 | 5173 | -33 |
| town -> necrocrat (cold) | 4223 | 4140 | -83 |
| necrocrat -> battle (cold) | 777 | 729 | -48 |
| battle -> necrocrat (cold) | 3013 | 965 | -2048 |
| necrocrat -> dungeon map S-NECRO | 2304 | 1593 | -711 |
| dungeon map -> necrocrat (retreat) | 3638 | 3471 | -166 |
| necrocrat -> town (cold) | 5150 | 5232 | +81 |
| town -> refusemancer (cold) | 11075 | 10941 | -134 |
| refusemancer -> battle (cold) | 795 | 811 | +16 |
| battle -> refusemancer (cold) | 3521 | 948 | -2573 |
| refusemancer -> dungeon map S-REF | 2303 | 1609 | -694 |
| dungeon map -> refusemancer (retreat) | 4415 | 4415 | +0 |
| refusemancer -> town (cold) | 5178 | 5176 | -2 |
| town -> final (cold) | 10612 | 12186 | +1574 |
| final -> battle (cold) | 798 | 779 | -19 |
| battle -> final (cold) | 8671 | 1023 | -7648 |
| final -> dungeon map S-CAP | 2304 | 1600 | -704 |
| dungeon map -> final (retreat) | 9530 | 9610 | +80 |
| final -> town (cold) | 5194 | 5289 | +94 |
| town -> beefcake (warm) | 3808 | 3792 | -16 |
| beefcake -> battle (warm) | 787 | 757 | -30 |
| battle -> beefcake (warm) | 2792 | 893 | -1899 |
| beefcake -> town (warm) | 5188 | 5113 | -75 |
| town -> gourmand (warm) | 3544 | 3495 | -49 |
| gourmand -> battle (warm) | 790 | 759 | -32 |
| battle -> gourmand (warm) | 2548 | 909 | -1640 |
| gourmand -> town (warm) | 5236 | 5116 | -120 |
| town -> necrocrat (warm) | 3848 | 3756 | -92 |
| necrocrat -> battle (warm) | 790 | 722 | -68 |
| battle -> necrocrat (warm) | 2864 | 896 | -1968 |
| necrocrat -> town (warm) | 5137 | 5139 | +2 |
| town -> refusemancer (warm) | 4951 | 4780 | -171 |
| refusemancer -> battle (warm) | 788 | 731 | -57 |
| battle -> refusemancer (warm) | 3546 | 1018 | -2528 |
| refusemancer -> town (warm) | 5322 | 5172 | -151 |
| town -> final (warm) | 10002 | 9937 | -65 |
| final -> battle (warm) | 777 | 732 | -45 |
| battle -> final (warm) | 8595 | 957 | -7638 |
| final -> town (warm) | 5150 | 5154 | +4 |

Peak working set: before 2222 MB, after 2113 MB.

## Where the time goes (before)

- **forest -> town (warm)**: fade out 304, town: TownBuilder.build 696, town: TownSquare 779, town: outskirt dressing 131, town: actors 194, town: spots, enemies, obstacles 136, look rig: sky 135, look rig: scenery 1112, town: ZoneDressing 176, frame 2 409, fade in 399
- **battle -> beefcake (warm)**: fade out 275, zone: builder 864, painted: swaps 530, zone: camera, UI 124, frame 2 142, settled (6 frames, worst 319 ms) 445, fade in 263
- **battle -> final (warm)**: fade out 275, zone: builder 6397, painted: swaps 747, frame 2 161, settled (6 frames, worst 399 ms) 580, fade in 288
- **town -> refusemancer (cold)**: fade out 300, change_scene_to_file 360, zone: builder 3297, zone: player, NPCs, spots 215, painted: swaps 5002, painted: decal placement 115, zone: camera, UI 216, scene ready + frame 1 189, settled (7 frames, worst 380 ms) 654, fade in 393
- **beefcake -> dungeon map S-IRON**: fade out 286, change_scene_to_file 624, scene ready + frame 1 254, fade in 984

Capital builder (LOAD_TIMING=1 detail, warm): before 7.5-7.9 s = buildings 2.5 s (the 16 townhouses) + skyline 2.3 s + wall dressing 0.66 + props 0.58 + landmarks 0.47 + walls 0.37 + merge 0.31 + rim 0.23. After the townhouse / tower cache: 4.9 s = other buildings 1.2 s, houses 0.2 s, skyline 0.7 s, props 0.6 s, landmarks 0.5 s, merge 0.4 s, walls 0.3 s, wall dressing 0.3 s.

Town (LOAD_TIMING=1 detail): TownBuilder.build 0.86 s (props 0.77), TownSquare 0.94 s, StyleRig 0.43 s (painted material layers 0.28), hub land 0.9 s (boundary 0.26, outskirts 0.21, tree belt 0.32), look rig scenery 0.9-1.1 s, frame 2 0.25-0.4 s, the two fades 0.6-0.7 s.

## What changed

1. **Return from a fight** (`SceneManager.park_next` / `_park_current` / `_resume_parked`; `ZoneScene.resume_after_battle`, `TownScene.resume_after_battle`, `AmbientEmitter.resume_in`; `Session.start_battle`): a zone or town roamer battle keeps the world scene alive out of the tree and puts it back on the return - the beaten roamer leaves, the hero stands where the fight began (or wakes at the hub by the pending result), the emitters play again, the HUD HP line is refreshed, the usual result toast / popups follow. Gatekeeper, arena, graveyard, dungeon and dev battles rebuild as before (they change the world). Back from a fight: 0.9-1.0 s in every zone, the town and the Capital (target 1.5 s).
2. **Capital geometry cache** (`KitMesh.fill_cached_set`, `CapitalKit.resolve_slot`, `CapitalGrand.townhouse` / `tower` -> `_townhouse_geometry` / `_tower_geometry`): the townhouse and tower meshes are built once per spec and come from the BuildCache after (the painted card slots re-resolved on a hit; a district house with a service layer builds live). Builder 7.5 -> 4.9 s.
3. **Loading screen hold** `LoadingScreen.MIN_SECONDS` 1.6 -> 0.9 s: zone -> dungeon map 2.3 -> 1.6 s; it still never flashes (0.28 s in, 0.4 s out).

## Not done (next, in value order)

- Zone -> town (5.2 s) and town -> zone (3.5-3.9 s warm) are still over the 3 s target: the town is many 0.1-0.9 s pieces (props, the square, hub land, scenery) with no single cacheable chunk; a zone is its builder (0.9-1.8 s) + painted swaps (0.5-0.75 s) + settle (0.45-0.65 s). The Capital stays at about 7 s (other buildings 1.2 s, landmarks + props 1.1 s, merge 0.4 s) and the Dump 11 s cold (painted swaps 5 s).
- Threaded pre-loading of the destination (textures during the fade; the next zone when the hero nears an exit or picks a fast-travel stop) and a shader / material pre-warm at the title (the settle step is 0.45-0.65 s a load, worst frame 320-440 ms) were not built.
- The loading screen already shows the area art and a tip for every area change over the quick threshold.
