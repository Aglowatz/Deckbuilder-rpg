# Overnight report (2026-10-13)

Source of truth: `data/source/art_bible.csv` / `docs/art/art_bible.md`. Decisions: `docs/design/open_questions.md` ("Overnight decisions", OD-1 .. OD-12).

## What changed

| Step | Result |
|---|---|
| 1 Art Bible in the repo | `docs/art/art_bible.md`; per-area style files `data/zone_styles/*.json` (light, fog, grade, bloom, palette, material swaps, tints; hot-reload in debug builds, `docs/art/zone_styles.md`); palette tinting and kit swaps in `EnvKit.material` / `KitFoliage`; the Path-ology Lab row is filled (sheet-ready line below). |
| 2 Storybook scale | Hero 1.25 -> 1.70 m (all characters x1.36, Relative Heights kept), door 3.4 -> 1.95 m, storey about 1.5 heroes (presets rewritten in storybook metres), rounder trees, speed 3.4 -> 4.9, body radius 0.22 -> 0.30, reach x1.2, enemy speeds scale with the player's. `docs/art/storybook_scale_and_camera.md`. |
| 3 Camera | `CameraRig`: 3 angles (Cinematic 20, Classic 30, Overview 45) x 3 zooms (Close, Normal, Far), swivel Z / X (or right stick) up to 18 degrees that eases back, V and F cycle angle and zoom, Settings dropdowns, remembered in settings.cfg (not per save). The hero is about 11% of the screen at Normal. |
| 4 Sub-areas | `SubAreaDefs / SubAreaMap / SubAreaScene / SubAreaGates / LandmarkKit` (data-driven blockouts in `data/subareas/<area>/`), one scene at a time, state in session flags, zone visit preserved, saves record `sub:<area>/<sub>` and resume there, dungeon exits (`dungeon:main`, `dungeon:lab`). |
| 5 Areas | 40 sub-area scenes across the ten areas, hub gates, plans, asset lists, paint-over inputs, contact sheets. |

## Area status

| Area | Planned | Blocked out | Paint-over shots (hub + sub-areas) | Asset list | Verified (build + walkability + gates) | Medium fps hub / sub-area (avg, min) |
|---|---|---|---|---|---|---|
| Main Town | yes | 4 scenes | 5 | yes | yes | 55 (min 33) / 60 |
| Starting Forest | yes | 4 scenes | 5 | yes | yes | 60 / 60 |
| The Gainlands | yes (hand-written) | 4 scenes | 5 | yes | yes | 60 (min 55) / 60 |
| The D.N.A. | yes | 4 scenes | 5 | yes | yes | 60 / 60 |
| The Endless Buffet | yes | 4 scenes | 5 | yes | yes | 60 / 60 |
| The Verdant Dump | yes | 4 scenes | 5 | yes | yes | 60 (min 59) / 60 |
| Capital: Outside | yes | 3 scenes | 4 | yes | yes | 59 (min 18, a load hitch) / 60 |
| Capital: Inside | yes | 4 scenes | 5 | yes | yes | (same scene as outside) / 60 |
| Castle Grounds | yes | 4 scenes | 4 | yes | yes | n/a / 58 |
| Path-ology Lab | yes | 5 scenes | 5 | yes | yes | n/a / 60 |

Checks per sub-area (GUT, `tests/world/test_subareas.gd`, `test_subarea_gates.gd`, `test_subarea_scene.gd`): builds, spawn walkable, every point of interest and exit reachable, exits lead to real places, every scene pays something and has 4+ points of interest and a hero landmark stand-in, all scenes reachable from a hub gate, rewards drawn only from existing zone tables, gates stand on reachable hub ground, a chest pays once and is remembered, saves record the sub-area. Full suite: 1490 tests.

## Look at these first

* `docs/art/zone_plans_shots/<area>.png`: the hub at all nine camera combinations (rows Cinematic / Classic / Overview, columns Close / Normal / Far).
* `docs/art/paintover_inputs/main_town/PO-MAIN-TOWN-HUB.png` against `docs/art/paintovers/PAINTOVER-TOWN.png` (scale and camera did not change the look).
* `docs/art/paintover_inputs/gainlands/PO-GAINLANDS-MILL-FIELDS.png` (the Gainlands wheel stand-in) and `.../pathology_lab/PO-PATHOLOGY-LAB-GLASS-TANK-HALL.png`.

## Paint-over inputs in Drive

`G:\My Drive\Card Game Art\Paintover_Inputs\<area>\PO-<AREA>-<SUB>.png`, 48 images, 1600x900, Cinematic / Normal. Folders: main_town (5), starting_forest (5), gainlands (5), dna (5), buffet (5), heap (5), capital_outside (4), capital_inside (5), castle_grounds (4), pathology_lab (5). Copies in `docs/art/paintover_inputs/`. Nothing else in Drive was touched.

## New assets needed

355 images listed in `docs/art/zone_kits/ALL.md` (per area `docs/art/zone_kits/<area>.md`): 48 are paint-overs (2 per area at priority 1, the rest 3), the rest surfaces, cutout sheets (3-4 per zone), trees, props, decals, skies / backdrops and hero landmark concepts (priority 1). Counts per area against the Art Bible budget are at the top of ALL.md; Town and Castle Grounds list more than the budget because hero concepts and paint-overs are counted: take priority 1-2 for the budget.

## Sheet-ready row: The Path-ology Lab

`The Path-ology Lab` | `No sun: cold pre-dawn hush above, flat fluorescent white-blue below with four Path-colour tank glows` | `#E4EAEE, #9FB4C4, #4C5B66, #8A5A3C, #E0443A, #E8C13A, #8E5FD0, #5FBF6A` | `Sterile, quiet, wrong; one warm thing per room` | `White-tiled clinical corridors cracked by tree roots, glass tanks, draining rigs, bone-pale cell bars, desks with notes and mugs` | `Shared kit in white tile, clinical panels, brushed steel, green-blue glass; pale concrete and grating ground; roots over everything` | `Hidden Hatch, Glass Tank Hall, Draining Chamber rig, Prince's Old Cell, Chief Path-ologist's Laboratory` | `Hub: Hatch Yard. Sub-areas: Decontamination Corridor, Specimen Gallery, Records and Break Room, Glass Tank Hall` | `Tree roots through tile, pale ferns; steel carts, tanks, desks, mugs, keycards, cells` | `About 25` | `Needed`

## Decisions made for you (see open_questions.md)

Characters grew instead of buildings only (OD-5); camera keys Z X V F (OD-6); existing content was NOT moved out of the hub scenes, sub-areas are new scenes (OD-8); rewards only from existing chest tables (OD-9); forest and Lab gates only appear after the trial / hatch flags (OD-10, OD-11); the Lab antechamber is walkable while the dungeon stays a 2D map (OD-1).

## Known problems and honest limits

* Blockouts are placeholders: landmark stand-ins are plain shapes, no painted art; water reads as a pale slab; the Lab and Castle ground are the kit cobble with their tint.
* The existing Gainlands hub still has readable text signs (violates G-03); not changed.
* The two-camera-pull-back (Normal distance 19 m) makes buildings near the lens large; the `OcclusionFader` handles the ones that block the hero. Town average is 55 fps on Medium (it was 55-57 before; the 60 target is still open, draw calls are the cost).
* Capital hub min fps 18 in the probe (a single load hitch at start; avg 59).
* The full human-style e2e smokes (`tools/run_*_smoke.sh`) were not re-run: only the unit suite, scene-level GUT tests, fps probes and screenshots (the memory on this PC was low; one early tool run hung on autoload identifiers and was stopped by the system).
* The plans' "something every 15-20 s" is by construction (4+ POIs per scene), not play-tested.
* Kit tints (zone styles) were verified by test and screenshots only for the zones above; the town kit is untinted on purpose.

## Questions for you

1. Keep characters at 1.7 m (door 1.95 m) or go taller (the Art Bible ratio holds at any size)?
2. Should existing hub regions (Mill Meadow, the Capital districts) be split into their own scenes later? It needs a quest and save audit.
3. Should the sub-area gates carry icons instead of plates with names (G-03)?
