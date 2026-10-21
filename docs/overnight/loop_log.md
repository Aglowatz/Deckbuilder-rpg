# Overnight Oct 20-21 - stability and first-hour loop (Phase 2)

Last night's loop log: `docs/overnight/oct19/loop_log_oct19.md`. Phase 2 started Wed Oct 21 ~00:20 (Parts 1-5 done, Part 6 waits for
the loop's fixes so the zip is built once).

## Cycle 1 - the Vulkan tour broke in the Verdant Dump (VK_ERROR_TOO_MANY_OBJECTS) + resources only ever grew

- Found: the tour bot on Vulkan (project, `GODOT_ARGS="--rendering-driver vulkan"`) failed building the Dump's enemies:
  `Can't create buffer of size: 1088 (VkResult error -10)` in `BuffetProps.mesh_at` (heap_mobs -> ball), then thousands of draw errors.
  D3D12 toured clean. New per-reveal memory lines in wayward.log showed everything growing across areas: resources 1.3k -> 3.9k,
  textures 161 -> 946 MB, video memory 1.86 GB by the Capital; a ~400-node battle still held 13.5k objects.
- Fixed: `AreaCaches.release()` drops the world-art caches (painted textures, kit models/materials, each zone's materials and models,
  map, battle-board, key-art and bestiary pictures) when the player moves to a different area or the title (not zone <-> battle);
  `BuffetProps` shares one mesh per identical ball/box/cylinder (each call made new GPU buffers - thousands per zone).
- Verified (D3D12 tour, before the mesh sharing): Capital reached with resources 2.9k (was 3.9k), video memory 1.53 GB (was 1.86),
  battles 10.9k objects (was 13.5k); tour OK, 0 errors.
- Then: `BuffetProps` shares one mesh per identical primitive. Vulkan tour (alone, clean): **OK - 276 spots, 9 menus, 5 battles,
  0 errors, 0 VkResult errors** (failed in the Dump before). Capital reached at 851 MB video memory on Vulkan.
- Process note: one pair of tour runs overlapped (a wait loop matched the import step's exit); those numbers were discarded and the
  run repeated alone.

## Cycle 2 - first-draw spikes after fade-ins without a loading screen; results opening under the cover

- Found (release smoke on the export, wayward.log): a change without a loading screen (title -> forest) never ran the settle step, so
  first-draw shader frames showed after the fade-in; the reveal watch also counted frames while a menu the player opened was up (the
  smoke's F8 form made a "532 ms" there). Playtest smoke log: after the store-room ghost duel, the ghosts' result conversation opened
  while the town was still building behind the loading screen (`busy=yes (build) modals=[Dialogue]` in the heartbeat) - its first lines
  typed out unseen.
- Fixed: every scene change settles behind its cover (4 quick frames for a light scene); the reveal watch skips paused frames;
  TownScene's post-battle results wait for `SceneManager.revealed` when the town is built behind a cover.
- Verified: playtest smoke OK twice, prologue smoke OK; the ghosts' lines now open at the reveal (123.3 s, same frame as "town
  revealed"); test_playtest_stability, test_loading_screens, test_cave_arrival, test_town green. The one remaining 460 ms frame in
  the playtest smoke's first 5 s is the smoke's own screenshot (a viewport readback).

## Cycle 3 - does the stall watchdog really write when the main thread hangs?

- Test: a `-s` probe that blocks the main thread for 11 s (`OS.delay_msec`). wayward.log: `[9.5] WARNING stall: the main thread has
  not finished a frame for 8 s (last step: test: about to block the main thread for 11 s)` then `[12.5] stall: the main thread is back
  after 11.2 s`. A tester's frozen game will leave that line (and the boot stage "stalled", so the next launch is in Safe Mode).

## Cycle 4 - a last resort for old graphics chips: the Compatibility renderer

- Test: the exported pack with `--rendering-method gl_compatibility --rendering-driver opengl3` runs the whole cave -> Crosspath arrival
  (OpenGL 3.3; 28 s load, welcome, walk; one 338 ms frame) and Crosspath looks right (`_screenshots/compat_town.png`). Errors: the
  outline-with-normals shader (Forward+ only) was compiled on every area build, FSR and FXAA warnings.
- Fixed: StyleRig builds the depth-only outline unless normals are wanted; `GraphicsQuality.outline_normals` and FSR need Forward+;
  no FXAA on Compatibility. New `Start (Compatibility).bat` (Compatibility + Safe Mode) and a README line for it.
- Verified: the Compatibility town screenshot logs no shader error; test_style green.
