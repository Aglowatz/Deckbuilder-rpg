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
| 2 Draw calls | - | |
| 3 Culling + per-frame work + UI | - | |
| 4 Memory | - | |
| 5 Dynamic resolution + budget tests | - | |
| 6 Verify + report | - | |

## Tools

- `bash tools/perf_run.sh <tag> ["0 1"] [areas]`: the 13 areas (crosspath forest gainlands buffet dna heap capital_out capital_in battle
  dungeon_map deck_station collection vendor) at Low / Medium -> `docs/perf/runs/<tag>.md` + raw `<tag>.txt`. ~45 s per run.
  Columns: avg fps, 1% low (99th percentile frame), avg ms, viewport CPU / GPU ms, draw calls, objects, nodes, load ms (load +
  instantiate + `_ready`, unstaged), worst frame in the first 3 s, process working set (RAM), video memory, texture memory.

## Decisions

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

- Baseline: `docs/perf/baseline.md`. Part 1 loads (Medium, warm cache): `runs/p1_loads.md` (Dump after the foliage cache: 7.1 s).
- Part 1 pixel diff (`_screenshots/perf/p1_before` vs `p1_after`, cache off vs baked cache; `p1_noise` = two unchanged runs):
  every area within the noise floor except a little more motion in the Dump / forest (heat map: foliage sway, motes, cloud
  shadows - nothing structural). UI screens 0.00.
