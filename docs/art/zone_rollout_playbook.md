# Zone rollout playbook

The exact process used to dress the Gainlands with its approved zone kit (`docs/art/gainlands_slice.md`), written down so the next zones (D.N.A., Endless Buffet, Verdant Dump, Capital, Castle Grounds, Path-ology Lab) follow the same recipe. Each step names the files, the commands and the check that closes it. One Godot process at a time; GUT after every part; e2e only for the area changed, about 15 minutes a part.

The rules that never change: gameplay, quests, NPC logic, sub-area connections and the camera system are not touched by an art pass; the Drive is read-only (every importer copies); nothing in the world carries readable text (Art Bible G-03); characters stay the clearest thing on screen; Medium holds 60 fps on the dev iGPU.

## 0. Before the kit: paint-overs and the kit list

1. **Paint-over inputs.** `Godot --path . --resolution 1600x900 -s res://tools/zone_shots.gd -- --area=<area> --mode=both` writes `docs/art/paintover_inputs/<area>/PO-<AREA>-<SUB>.png` (the hub and every sub-area from the Cinematic / Normal camera, the hero visible, no UI) and the hub's 9-combination contact sheet `docs/art/zone_plans_shots/<area>.png`. These are what the painter paints over; the camera positions are fixed by the tool (hub: the spawn; sub-areas: 40% of the way from the spawn to the hero landmark), so the finished paint-over and the game shot line up.
2. **The kit list.** `docs/art/zone_kits/<area>.md` is the sheet-ready table (ID, Asset, Category, Lock, Image Description, Size / Format, In-Game Use, Priority): the Art Bible budget per zone is about 40 images in six locks (SURFACE, CUTOUT, TREE, SHEET, CONCEPT, BACKDROP). It is pasted into the designer's sheet; the export comes back as `data/source/<area>_kit.csv` (rows 1-7 the style target and locks, row 9 the header, assets from row 10, like `data/source/env_kit.csv`).
3. **The art** lands in `G:\My Drive\Card Game Art\Approved_ZoneKits\<Zone>` named by ID (`GAIN-WALL-BRICK.png`). Paint-overs go to `Paintovers/PAINTOVER-<AREA>-<SUB>.png` and are copied into `docs/art/paintovers/`.

## 1. Import (Part A)

4. `bash tools/import_zone_kit.sh <area>` ("import zone kit <area>"): copies and prepares every id of the sheet by lock (surfaces: seam check and repair, normal and roughness maps, 400 px/m like the town kit; cut-outs and trees: alpha cleanup, trim, pivot; sheets: sliced into `<ID>-01..06`; concepts: small references under `docs/art/zone_kits/<area>/concepts/`; backdrops: full width), writes the registry `data/art/zone_kits/<area>.json` and the report `docs/art/zone_kits/<area>_import_report.md`. **Read the report first**: missing ids, files that match no id, and notes (an opaque "sky", an empty sheet cell) are the first thing to tell the user.
5. **Check the slices and pivots** by eye: a strip of each sheet's six parts (`_screenshots/zonekit_<SHEET>.png` in the Gainlands run) and the kit bench with the zone's swaps: `bash tools/shot.sh res://tools/kit_bench.tscn <name> --presets=cottage,inn --trees=oak,pine --zone=<area> --nohud=true`.
6. **Hand numbers in the registry** (they survive a re-import): `height` for prop and plant cards (metres), `width` for sheet windows, aliases for painted textures the zone reuses (`"placeholder": "tex:<name>"`, `"dec:<name>"`).
7. **Hero landmarks.** For each CONCEPT id write a static builder in `world/<area>/<area>_landmarks.gd` (`has_model`, `build(spec)`), register the prefix in `HeroLandmarks.BUILDERS`, model it to the `size` of its sub-area data row with `KitMesh` primitives textured from the kit (`EnvKit.material(id)`), painted cards for banners, signs, doors, windows and plants (`_card`, `_tree_card`), and set meta `circles` (blockers), `spinner` (a part that turns), `lights`, `no_wind`. Check each one alone: `bash tools/shot.sh res://tools/kit_bench.tscn lm --landmarks=<ID>:<w>x<h>x<d> --zone=<area> --dist=16 --zoom=2.6 --lyaw=25`. The size comes from the sub-area data; the silhouette from the concept.
8. **Backdrops and sky.** Backdrop strips become `kit_cards` in the zone's mood (`data/art/zone_looks.json`, scenery block: id, compass angle, angular width, ring, lift). A real sky panorama would replace the painted gradient; an opaque picture stays a reference (GK-2).
9. **Tests, commit, push.** `bash tools/run_tests.sh`; `tests/world/test_zone_kit.gd` covers the slicer, pivots, families, the registry and the swaps; add the zone's ids to it.

## 2. Dress (Part B)

10. **Material swaps** in `data/zone_styles/<area>.json`: every shared kit id the zone's buildings, paths and trees use maps to a zone id (walls, roofs, eave trim, doors, windows, signs, ground, trees). Zone art is untinted (`tinted: false`); shared surfaces the zone keeps (cobble, foundation, fences) still take the palette tints.
11. **Building presets** in `data/art/building_presets.json`: a few `<area>_*` presets with the zone walls, roof, trim and sliced doors / windows / signs (storeys 1.2-1.9 heroes, `timber: none` when the wall paints its own posts).
12. **Prop clusters** in `data/art/zone_kits/<area>_clusters.json` (`ZoneClusters`): vignettes of the kit's card props and plants with shared kit props, named like `PropClusters` names and used from sub-area data and the hub dressing. Card props anywhere: `PropKit.make("card:<ID>")`. Plant kinds for scatter: `TreeCards.KINDS` (`plant: true`).
13. **Sub-area data** `data/subareas/<area>/<sub>.json`: presets, clusters at doorways / walls / junctions, `scatter` groups (never even), `flowers` clumps along paths and fences, `decals` (flat kit quads: chalk, plates, ruts), stand-ins with `surface` / `accent_surface` (a kit surface instead of a flat colour), zone `ground` kinds (`SubAreaMap.GROUND_KINDS`). Keep every `poi`, `exits`, `entries`, `spawn` and gate position exactly as they were.
14. **The hub**: the zone's own builder swaps its procedural materials to the kit (`<Area>Materials.kit(...)`), its layout trees to painted cards (`KitFoliage.tree_field`), its stand-in building to the hero model (`LandmarkKit.build({"id": ...})`), and its dressing places kit clusters at the anchors (`KIT_CLUSTERS`). Layout positions and obstacles stay.
15. **Check**: every sub-area and the hub at the paint-over cameras (`zone_shots.gd --mode=po --out=res://_screenshots/<area>_slice`), `bash tools/fps.sh <scene> 1` for each scene (Medium, 60), the sub-area smoke `SMOKE_ONLY=<area>,save_load bash tools/run_subarea_smoke.sh`, GUT, commit, push.

## 3. Match the paint-overs (Part C)

16. **Numbers first**: `Godot --headless -s res://tools/image_stats.gd -- <paint-over> <shot> ...` gives mean RGB, luma p5 / p50 / p95, saturation and the sky / mid / ground thirds of both; grade is data (`data/zone_styles/<area>.json`: key, ambient, contrast, saturation, post saturation, vignette, haze). Three passes at least: (1) composition and landmark size, (2) building shapes, prop density and palette, (3) light, shadows and haze. Re-shoot after each pass; keep the hero the most saturated thing on screen.
17. **Side by side**: `tools/side_by_side.gd --left=<paint-over> --right=<shot> --out=docs/art/<area>_slice/compare_<sub>.jpg --height=450`; the hub's 9 combinations: `zone_shots.gd --mode=grid --out=...` (every combination must look finished, G-02).
18. **fps** after every pass; batch anything repeated (cards in MultiMeshes, `KitBatch`, `KitPools`), keep real lights to the lantern budget.

## 4. Report (Part D)

19. `docs/art/<area>_slice.md`: paint-over beside the result for every scene, the hub contact sheet, fps per scene, the grade numbers, the honest list of what still does not match, a sheet-ready table of extra assets that would close the gap, and the kit status table (`data/art/zone_kits/<area>.json`). Update `docs/art/art_status.md` (the kit ids now in the game), `docs/design/open_questions.md` (judgment calls), `docs/progress.md`.

## Files at a glance

| What | Where |
|---|---|
| Sheet export | `data/source/<area>_kit.csv` |
| Drive folder | `zonekits_dir` in `data/source/art_config.cfg` + `/<Zone>` |
| Importer | `tools/import_zone_kit.sh`, `tools/import_zone_kit.gd`, `tools/zone_kit_prep.gd` |
| Art, registry, report | `assets/art/zone_kits/<area>/`, `data/art/zone_kits/<area>.json`, `docs/art/zone_kits/<area>_import_report.md` |
| Concept references | `docs/art/zone_kits/<area>/concepts/` |
| Hero landmark models | `world/<area>/<area>_landmarks.gd` via `world/subarea/hero_landmarks.gd` |
| Clusters | `data/art/zone_kits/<area>_clusters.json` (`world/kit/zone_clusters.gd`) |
| Swaps, tints, grade | `data/zone_styles/<area>.json` |
| Backdrop cards, sky | `data/art/zone_looks.json` (`kit_cards`, `sky`) |
| Presets | `data/art/building_presets.json` |
| Sub-areas | `data/subareas/<area>/*.json` |
| Shots, grade, compare | `tools/zone_shots.gd`, `tools/image_stats.gd`, `tools/side_by_side.gd`, `tools/image_to_jpg.gd`, `tools/kit_bench.tscn` |
| Checks | `bash tools/run_tests.sh`, `bash tools/fps.sh`, `bash tools/run_subarea_smoke.sh` |
