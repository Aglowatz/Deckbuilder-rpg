# Performance pass (Oct 25-26) - running state

Overnight brief "PERFORMANCE PASS (Oct 25)": faster and lighter on older / low-end PCs with no visible quality loss. Start 2026-10-25
13:28 MDT, stop by 22:28 MDT. Start commit `476eb756` (tag `pre-perf-oct25`). Questions go to `docs/overnight_inbox.md`
("Performance pass Oct 25"). Resume from this file after a context reset.

Rules kept: one Godot at a time (foreground, closed between runs; 7.4 GB RAM), GUT in groups, STOP_OVERNIGHT check per part, GUT + walkability
+ walk smokes + commit + push per part, old saves load, zones stay code-built, before/after screenshots + pixel diff per part (anything
visibly different is reverted), no playtest export.

## State

| Part | Status | Notes |
|---|---|---|
| 0 Baseline | done | `docs/perf/baseline.md` (ranked costs), `runs/baseline.md`; tools perf_probe / perf_run / process_census / texture_census |
| 1 Zone build cache | done | `BuildCache` (world/build_cache.gd): splat images, ground overlay, foliage placement; bake for export; loads Crosspath 8.2->5.3 s, Dump 8.6->7.1, Gainlands 5.7->4.6, Buffet 4.5->3.8; shots identical within noise |
| 2 Draw calls | measured, nothing kept | GPU-bound on shading, not geometry or draw calls: KitLod (runtime LODs for kit meshes) +0.1-0.3 ms, small-far culling 0, KitInstancer (MultiMesh repeats) found 45 safe pieces; all reverted (decisions P2-a..c) |
| 3 Culling + per-frame work + UI | 3a done | WorldCover (menus pause the hidden 3D world: Deck Station 48->85, Collection 52->95, vendor 55->112 fps Medium, pixel-identical); off-screen sprites / strollers / patrolling enemies update every 4th frame with the missed time; WorldSprite sends only changed shader values; zone markers/plates/prompts only near the hero (Capital: markers 0.76->0.10 ms); Low: Crosspath 69->91, Gainlands 70->98, Buffet 80->107, D.N.A. 79->104, Dump 65->92, Capital 62->84 fps. 3b (visibility ranges, occluders, UI pooling) next |
| 4 Memory | done | SpriteLibrary drops NPC frames on area change (town textures after a tour 522 -> 455 MB, zones -45..-100 MB); 16 full-screen paintings to BC7 (town 422 -> 390 MB textures, pixel diff <= 2/255 per block on menus); export +16 MB (741.5 MB) |
| 5 Dynamic resolution + budget tests | done | DynamicResolution (Settings child; Auto = Low/Medium, Always, Off; steps 0.04 down when the frame is >1.15x budget for 0.75 s and the GPU is busy, up when the GPU is under 0.68x for 2 s; floor = level scale - 0.14); off in -s tool runs (WAYWARD_DRS=force to test); budgets.json + perf_budget.sh (headless structure + windowed frame) |
| 6 Verify + report | done | `docs/perf/report.md`, `runs/final.md`, `runs/before_after.md`, `diff_final.md`; GUT groups, walk smokes, first battles, tour bot, story bot all OK |

## Tools

- `bash tools/perf_run.sh <tag> ["0 1"] [areas]`: the 13 areas (crosspath forest gainlands buffet dna heap capital_out capital_in battle
  dungeon_map deck_station collection vendor) at Low / Medium -> `docs/perf/runs/<tag>.md` + raw `<tag>.txt`. ~45 s per run.
  Columns: avg fps, 1% low (99th percentile frame), avg ms, viewport CPU / GPU ms, draw calls, objects, nodes, load ms (load +
  instantiate + `_ready`, unstaged), worst frame in the first 3 s, process working set (RAM), video memory, texture memory.

## Decisions

- **P5-a: dynamic resolution only steps down when the GPU is the reason** (a CPU-bound frame would only look worse smaller), by 0.04 at a
  time, never below the level scale - 0.14 (Medium 0.44, Low 0.40, High 0.86 when chosen), and never in tool / test runs (fixed-scale
  measurements and screenshots). On the development PC it stays idle at Medium in every area (all over 66 fps after the pass).

- **P2-a: no runtime LODs.** `ImporterMesh.generate_lods` works on the kit meshes once welded (castle gold 19k > 9k > 4.5k...), but the
  Capital at Medium gained 0.1-0.3 ms: the far-geometry cost (3 ms for everything past 60 m) is shaded screen area, not triangles.
- **P2-b: no extra culling.** Small meshes (<1.5 / <3 m) ending at 45 m: +0.06 / +0.33 ms (noise). Anything bigger is visible.
- **P2-c: no generic instancing.** Only the Dump has repeats sharing mesh+material+parent (360 -> 117 groups), and after the safety rules
  (under 1 m so nothing fades or shades differently, no script above, not held by the builder/scene) 45 pieces qualify, none in view.
  KitBatch (Capital, Crosspath square, Gainlands roads) and the MultiMesh foliage/trees already cover the repeated kit props.
- **P4-a: BC7 only for full-screen paintings with sides in multiples of 4** (BC7 works in 4x4 blocks; odd sizes such as 1672x941 would be
  padded or resized): UI-BG-*, STORY-* (not APPROVAL), LOAD-BUFFET/DUMP/GAINLANDS, the foliage atlas. Portraits were tried and reverted
  (+20 MB of export for ~2 MB of video memory: only two are loaded at a time). Crisp UI pieces (frames, buttons, 9-slices) untouched.
- **P4-b: the hero's sprite frames stay cached across areas, NPC frames go** (they reload on demand; a live sprite keeps its own).

- **P3-a: a still picture under menus.** OverlayScreens are opaque paintings or a 94% shade; WorldCover keeps the last world frame as a
  TextureRect under the screen and sets `Viewport.disable_3d` once the 0.14 s open fade ends (screens replacing each other reuse the
  picture). The world behind a 94% shade standing still is invisible; pixel diff 0.00. `WORLD_COVER=off` for A/B.
- **P3-b: off-screen throttling uses the camera frustum + 3 m.** A figure at the camera itself (tests) is never throttled; the hero never.

- **P1-a: cache generated data, not whole scene trees.** The builders interleave nodes with game data (anchors, blockers, chest
  nodes, fader groups, KitLights, wind lists, OcclusionFader candidates, story-state variants); packing the built tree into a scene would
  need every one of ~15 runtime systems to re-find its nodes from a loaded tree, and a stale pack would silently diverge from the
  builders. Instead `BuildCache.fetch(key, build)` stores the slow deterministic results (images, meshes, transform arrays) keyed by
  a hash of every `world/**` script + `data/art` + `data/zone_styles` and by the story state the result depends on (freed, hub, quality,
  a coarse fingerprint of the masks / walkability as a guard). Builders stay the only source of truth; any edit rebuilds.
- **P1-b: the bake runs windowed.** Headless (dummy renderer) crashed on the second town build; the export already runs windowed.
  Saving the same `.res` path twice in one run also crashed: each key is written once per run.
- **P1-c: kit meshes (KitMesh) are not cached yet.** They are many small GDScript calls per building; caching them needs each
  builder function split into geometry + nodes (Capital walls 1.6 s, Dump terrain 1.1 s). Left for Phase 2.

## Numbers

- Part 3a: `runs/p3_cover.md` (menus), `runs/p3_scripts_low.md` + `runs/p3_cp.md` (Low; the first Crosspath row there was a cold-cache run).
  Shots `_screenshots/perf/p3_after` vs `p1_after`: only motion (drifting papers in D.N.A., foliage, the hero breathing).

- Baseline: `docs/perf/baseline.md`. Part 1 loads (Medium, warm cache): `runs/p1_loads.md` (Dump after the foliage cache: 7.1 s).
- Part 1 pixel diff (`_screenshots/perf/p1_before` vs `p1_after`, cache off vs baked cache; `p1_noise` = two unchanged runs):
  every area within the noise floor except a little more motion in the Dump / forest (heat map: foliage sway, motes, cloud
  shadows - nothing structural). UI screens 0.00.

## Phase 2 (remaining time)

Next biggest costs from the ranked list: kit-mesh caching for loads (Capital walls, Dump terrain), StyleRig conversion time.
