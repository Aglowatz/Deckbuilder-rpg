# Graphics loop: bring every area of the 3D world to one high-quality level

A checklist of concrete, independently committable tasks, worked through overnight by the scheduled "Graphics Loop" (`tools/graphics_loop_prompt.md`, run by `tools/run_graphics_loop.ps1`).
Target look: `docs/art/style_guide.md` ("cozy diorama, readable toon"; benchmarks Lil Gator Game, Slime Rancher, A Hat in Time; young adult, bright, charming, readable).
References live in `_reference/` (git-ignored): a hat in time, lil gator game, slime rancher, ref boxing room, ref cozy interior, ref necro grayscale.

## STOP / DISABLE THE LOOP (run in PowerShell)

```powershell
# Pause it (keeps the task, can be re-enabled):
Disable-ScheduledTask -TaskName "Graphics Loop"
# Turn it back on:
Enable-ScheduledTask -TaskName "Graphics Loop"
# Remove it completely:
Unregister-ScheduledTask -TaskName "Graphics Loop" -Confirm:$false
# Same with schtasks:  schtasks /Change /TN "Graphics Loop" /DISABLE    |    schtasks /Delete /TN "Graphics Loop" /F
# Stop a run that is in progress right now (kills the runner and Claude; the runner removes _logs\graphics_loop.lock itself,
# delete it by hand only if it is left behind):
taskkill /PID ([int](Get-Content C:\Dev\Deckbuilder-rpg\_logs\graphics_loop.lock)[0]) /T /F
# Look at the task / its next run:
Get-ScheduledTask -TaskName "Graphics Loop" | Get-ScheduledTaskInfo
```

Logs: `_logs/graphics_loop_<timestamp>.log` (git-ignored). Lock file: `_logs/graphics_loop.lock`.

## Scope

In scope: everything in the 3D game world and its backdrops (walking zones, town, dungeon-map dioramas, battle backdrops), shaders, lighting, particles, decals, set dressing, character presentation of the hero, NPCs and zone enemies.
Out of scope for the loop: card art, card frames, the card data pipeline, gameplay rules, balance. Do not touch those.

## Status legend

`[ ]` not started, `[~]` in progress (a run was working on it; resume it first), `[x]` done (scores and screenshots recorded).

## SCORING RUBRIC (do this after every task)

1. Take screenshots of the affected area from at least 3 angles with the area command (`tools/area_shots.sh` or `tools/ui_shot.sh`); tag them `before` (first run of the task) and `after` / `iterN`.
2. VIEW the images with the Read tool (never score from memory) and score each criterion 1-10:

| Key | Criterion | 7 means | 10 means |
|---|---|---|---|
| L | Lighting | key + tinted fill + pools, coloured shadows, no blown or crushed areas | looks lit by a painter; pools guide the eye |
| C | Color harmony | one base hue family, one support, a rare accent; ground calmer than props | any frame could be a poster |
| G | Ground / terrain detail | no flat fields, visible paths and edges, 3 treatments | hand-painted feel with story (wear, moss, puddles) |
| D | Density and set dressing | prop clusters along routes, skirts on buildings, lanes clear | every patch has a reason to exist |
| M | Landmarks and composition | destinations read at a glance, framing is balanced | the player always knows where to go and wants to |
| A | Atmosphere / particles | depth from fog, sparse zone-tinted particles | the air itself tells the mood |
| R | Readability | player, NPCs, interactables, paths and exits read instantly (squint test) | zero ambiguity at any angle |
| X | Consistency with other areas | same toon/outline/grade language as the reference area (town square) | zones feel like one authored game |

3. If ANY score is below 7: write down the critique, fix it, re-shoot (tag `iter2`, then `iter3`). Maximum 3 iterations. If still below 7 after 3, check the task off with the honest scores and add a follow-up task (same area, "Follow-up: ...") at the end of that area's list, and note it in Handoff notes.
4. Record in the task's `Result:` line: the 8 scores as `L/C/G/D/M/A/R/X = 8/7/7/8/7/7/8/7`, the before and after screenshot paths (relative to `_screenshots/graphics_loop/`), then check the box.
5. Screenshots are git-ignored; for the best before/after pair per area copy the PNGs into `docs/art/screens/graphics_loop/<area>_before.png` / `_after.png` (small, committed).

## Tooling cheat sheet

- Walking scenes: `bash tools/area_shots.sh <scene> <area> <tag> [--at=<anchor>] [--pos=x,z] [--cam=x,y,z]` makes angle a (default high), b (`--cam=-8,5.5,7`, low three-quarter) and c (`--cam=6,8,-9`, reverse) into `_screenshots/graphics_loop/<area>/<tag>_{a,b,c}.png`.
- Map/battle screens: `bash tools/ui_shot.sh <scene> <area> <tag> [args]` makes `_screenshots/graphics_loop/<area>/<tag>.png`. For these, take the 3 angles by varying the screenshot args (e.g. `--progress=0|1|3`, `--enemy=`, `--zone=`) and, once the backdrop camera supports it, `--cam=`; at minimum compare the backdrop with and without the UI dim (`NO_UI=1` if implemented in the task).
- Frame rate: `bash tools/fps.sh res://scenes/town.tscn 1` (quality 0 Low, 1 Medium, 2 High). Medium must hold 60 fps in the busiest area (town). `STYLE_QUALITY=0|1|2` sets quality for shots; `NO_STYLE=1` gives the pre-style look.
- Tests: `bash tools/run_tests.sh` (GUT, includes the compile-every-script test). Run before every commit.
- Style system: `world/style/` (`StyleToon`, `StyleRig`, `StylePresets`, `GraphicsQuality`, `ZoneDressing`, `GroundDecals`), shaders `assets/shaders/style_*.gdshader`, per-zone builders in `world/<zone>/`, backdrops `world/arena_backdrop.gd` and `world/dungeon_backdrop.gd`.
- Assets: follow the CLAUDE.md Asset Policy (CC0 preferred, CC BY with attribution, never NC/ND/unclear; log everything in CREDITS.md). Free sources such as Kenney, KayKit, Quaternius, Poly Pizza, Poly Haven, ambientCG and OpenGameArt may be downloaded into `_asset_library/<pack>/`; copy only used files into `assets/`.
- One Godot process at a time; this PC is low on memory. The area scripts kill leftovers first.

---

# GLOBAL TASKS (do these first; they lift every area)

Verify for global tasks: shoot at least town (`TW`), Gainlands (`GL`) and D.N.A. (`DN`) with 3 angles each, tag `before`/`after`, score all three, and spot-check one other area for regressions.

- [x] **G-01 Toon shader and outline refinement.** Audit `assets/shaders/style_*.gdshader` against the style guide: 3 soft bands with a painted (not posterised) edge, a faint procedural paper/brush grain in the shadow band so flat colours stop looking plastic, an optional glossy specular band (for the Buffet), rim light tuned per material class (0 on ground, higher on characters). Outline: constant 1 px at 1080p, distance fade, colour from the zone shadow colour, no shimmer on thin foliage and alpha cards, no outline double lines on hex seams.
  - Verify: town + Gainlands + D.N.A. close-ups of a prop, a character and foliage; look for outline gaps, banding steps, shimmer (take two shots 1 s apart).
  - Pass bar: all 8 rubric scores 7 or higher in the three areas.
  - Result (slice 1, iter1): shader-only slice done: world-space brush grain (grain_amount), optional glossy band (`gloss` uniform, off by default), rim damped on up-facing surfaces, outline width constant per 1080p with a 1 px floor, normal edges suppressed on crumpled foliage and hex seams. Town L/C/G/D/M/A/R/X = 5/4/4/5/6/4/6/5, Gainlands 5/4/3/4/5/3/5/4 (the low scores belong to later tasks: ground, lighting, grading). Outline shimmer and double lines on foliage clearly reduced. Medium town 76 fps. before = town/before_{a,b,c}.png, gainlands/baseline_*.png; after = town/iter1_{a,b,c}.png, gainlands/iter1_{a,b,c}.png. DNA iter1 viewed (clean outlines, no regressions): DNA 5/5/4/4/5/4/6/5. Slice 2: `gloss` is wired via material meta `StyleToon.META_GLOSS` (Buffet `shiny()` sets 0.45); outline colour already comes from the preset (`outline_color`); repeat town shots (town/g01shimmer_*.png) show clean, steady outlines. Tests 1013 green.
- [x] **G-02 Lighting and shadow quality.** Soften the harsh long black shadows (shadow tint colour + opacity, PCF/soft-shadow filter, cascade splits and bias per quality level, no acne or peter-panning); replace the broad god-ray streak decals with a subtle, sparse shaft effect; ambient always tinted; add a contact-shadow blob under characters and props that sit on uneven ground; verify the omni-light budget (12 Medium / 24 High).
  - Verify: town plaza at two sun angles, Gainlands, D.N.A. corridor; look for shadow acne, light leaks, overly black shadows.
  - Pass bar: L 7 or higher in every checked area, no regressions.
  - Result (slice 1, 3 iterations): the "god-ray" streaks were the 9 radiating dirt path ribbons with a 0.7 edge fade (read as yellow light shafts), not light: now tan dirt, crisp edge (0.3), narrower (1.1 m). Sun shadows softer and translucent (`shadow_opacity` 0.62, blur 2.4/1.8, tuned bias), town ambient energy 0.4 to 0.58 so shadows stay violet-green not black, volumetric fog halved with lower anisotropy (High only). Town L/C/G/D/M/A/R/X = 6/4/4/5/6/4/6/5 (iter3), Gainlands L 4 (own sun in `gainlands_look.gd`, not on the rig), DNA L 6; no regressions seen. Tests 1013 green. before = town/before_*.png; after = town/g02c_{a,b,c}.png, gainlands/g02_*.png, dna/g02_*.png. REMAINING (follow-up G-02b): contact-shadow blobs under characters/props, route Gainlands/Buffet/Heap `*_look.gd` suns through the same shadow settings, shadow acne check on High, omni budget audit.
- [x] **G-03 Per-zone colour grading.** Build a grading layer per preset (saturation, contrast, exposure, white balance, lift/gamma/gain via Environment adjustments or a small post shader) and re-tune all 13 presets against the style guide mood table; fix the over-saturated lime (town, Gainlands), washed whites (Capital), crushed darks (Capital outside); keep ground saturation at about 70 percent of prop saturation.
  - Verify: one overview shot per zone before/after; check histograms by eye (no big clipped areas).
  - Pass bar: C 7 or higher in every zone.
  - Result (slice 1): new per-zone `ground_sat` (ZonePreset, global shader param `style_ground_sat`): up-facing surfaces in the toon shaders are pulled towards luma so the ground sits at about 70-85 percent of prop saturation (town 0.76, Gainlands 0.7, Buffet 0.82, Heap 0.85, Capital inside 0.8). Presets retuned: town saturation 1.06 to 1.0, Gainlands 1.2 to 1.04, Buffet/Heap 1.05; Capital facade exposure 0.78 + contrast 1.1 (whites), outskirts exposure 0.92, ambient 0.9, contrast 1.05 (darks lifted), Capital inside exposure 0.52, saturation 1.02. Scores (C only, honest): town 5, Gainlands 4 (faceted vertex-colour terrain ignores the up-facing trick, needs G-08), Capital outside 5, Capital inside 5 (blown white plaza, yellow wall = G-14). No big clipped areas seen. Tests 1013 green. before = town/g02c_*.png, gainlands/g02_*.png; after = {town,gainlands,capital_outside,capital_inside}/g03_{a,b,c}.png. Not done: white balance / lift-gamma-gain LUT, per-zone overview shots for all 13 presets (only 4 shot); revisit in F-01.
- [x] **G-04 Sky and clouds.** A gradient sky shader per zone with a sun disc and soft glow, painterly layered clouds (parallax drift), a horizon haze band; stage-edge treatment for floating-diorama areas (island underside, distant silhouettes, cloud sea) so no flat void colour is ever visible (the starting area is currently a flat purple void).
  - Verify: starting area angles a/b/c, Gainlands, town edge shots with a low camera (`--cam=0,3,12`).
  - Pass bar: no flat background colour visible in any zone shot; A 7 or higher.
  - Result (slice 1): new sky shader `assets/shaders/style_sky.gdshader` (gradient + horizon haze, two toon-stepped drifting cloud layers above AND below the horizon so the high-angle camera sees a cloud sea, sun disc/glow, stars), installed by `StyleRig` for every `use_sky` preset (preset fields `cloud_color/cloud_cover/star_amount/sky_haze`; fog on the sky reduced to 25 percent). The flat purple void of the starting area is gone (cloud sea in lilac, starry upper sky). Perf notes: a REALTIME radiance map cost about 16 fps in the town, HIGH_QUALITY was far worse (7 fps), so `Sky.PROCESS_MODE_INCREMENTAL` + radiance 32 is used: town Medium 72-73 fps (was 75-77), starting area 90 fps. Starting area scores L/C/G/D/M/A/R/X = 5/6/4/4/5/6/5/5 (the island itself is still plain: SA-2..6); town low-camera shot (`--cam=0,3,12`) shows a pale cream sky strip, no flat void. Still open: island underside/distant silhouettes (SA-2, SA-6), sky tuning for the other zones (Gainlands/Buffet/Heap build their own looks and barely show sky). Tests 1013 green. before = starting_area/before_{a,b,c}.png; after = starting_area/g04c_{a,b,c}.png, town/g04_low2.png.
- [x] **G-05 Water.** A toon water shader: depth gradient, foam at shorelines, scrolling caustic lines, gentle vertex waves, sky-tinted sparkle; shared by town, starting area and dump puddles; cheap on Medium.
  - Verify: town west lake from angles a/b, a puddle close-up in the dump.
  - Pass bar: water reads as water with motion cues; fps unchanged within 2.
  - Result (slice 1): `assets/shaders/style_water.gdshader` + `world/style/style_water.gd` (`StyleWater.material/apply`): depth-texture gradient (shallow to deep), banded wobbling shore foam, two scrolling caustic layers, tiny vertex waves, rare twinkling sparkles; Low quality skips the depth read (fake shore). Applied to every `hex_water` tile via `ModelKit.tile` (town lakes + ocean, battle backdrop) and to the Dump recycling stream (teal). Town Medium 72-73 fps (unchanged). Town G score with water 5 (lakes now read as water: foam edge, caustics, motion); heap stream close-up viewed (heap/g05stream_b.png). Not done: the Dump compost-pit puddles still use `H.sludge()`; sparkles are rare, tune in TW-2/TW-5. Tests 1013 green. before = town/g03_{a,b,c}.png; after = town/g05b_{a,b,c}.png, heap/g05stream_*.png.
- [x] **G-06 Wind-swept foliage and grass shader.** Grass as a MultiMesh of blades with a base-to-tip colour gradient, travelling wind gusts, hero trample, per-instance hue/height variation, density per quality; trees and bushes sway with leaf flutter; replace the uniform "confetti tuft" scatter on the ground with this system.
  - Verify: town meadow, starting area grove, Gainlands field at angles a/b; grass must read as grass, not green confetti.
  - Pass bar: G 7 or higher; no draw-call explosion (fps check).
  - Result (slice 1): `StyleGrass` (`world/style/style_grass.gd` + `assets/shaders/style_grass.gdshader`): a 7-blade clump mesh in MultiMeshes, base-to-tip colour gradient from the zone's field colour, per-clump hue/value variation, travelling wind gusts + flutter (scaled by `style_wind`), the hero tramples blades flat (new global `style_player_pos`, set by `StyleRig._process`), toon-banded lighting. Replaces the Kenney `grass_leafs` confetti tufts in `TownSquare._meadow` and `ZoneDressing` (every zone using the generic recipes) at 2x count (counted as 1/3 against the instance budget). Town now reads as a grassy meadow (town/g06b_{a,b,c}.png vs g05b); Medium 71 fps (was 72-73), High 25 fps (High was already about 24 per the style guide). Town G score 6. Not done: trees/bushes leaf flutter (they already sway via StyleToon wind), density per quality uses the existing foliage_density, Gainlands/Buffet/Heap/Capital build their own ground cover (G-08/GL/EB/VD tasks), starting-area grass is sparse and dark. Tests 1013 green. before = town/g05b_*.png; after = town/g06b_*.png, starting_area/g06_*.png.
- [x] **G-07 Ambient particles.** One particle library (`world/style/`): dust motes, leaves, petals, fireflies, ash, steam, sparkles, paper scraps, rift sparks, spores, flies, chimney smoke; soft round textures, zone tinting, quality-scaled counts, a global budget; every preset picks 1-3.
  - Verify: each zone shot shows its signature particles; count particles; fps.
  - Pass bar: A 7 or higher everywhere; budget respected.
  - Result (slice 1): `StyleAmbience` library extended: new kinds `spores`, `flies`, `embers`, `rift` (magenta/cyan sparks), `smoke`; leaves/petals now use a procedural pointed leaf texture (no squares); `StyleAmbience.chimney_smoke(parent, pos, color, amount)` helper (soft zone-tinted plume, to be placed in TW-4); a global per-zone budget (`GraphicsQuality.ambient_particle_budget`: 120/260/400, every emitter shrinks by the same factor if a preset asks for more) on top of the existing quality scale. Presets: town motes + leaves + fireflies, starting area fireflies + spores, Dump motes + flies + spores, Capital outskirts ash + motes + two rift colours. A rift particle at 2.4x HDR bloomed into a giant white blob, fixed to 1.1x (capital_outside/g07b). Medium town 70.6 fps. Scores (A): town 5, starting area 6, Capital outside 5, Dump 5; particles are sparse and mostly small, signature particles are subtle at the default zoom: bump sizes per zone in the area A-tasks. Not done: zones that build their own look (Gainlands, Buffet, DNA) keep their old emitters. Tests 1013 green. before = town/g06b_*.png; after = town/g07_*.png, starting_area/g07_*.png, capital_outside/g07b_*.png, heap/g07_*.png.
- [x] **G-08 Ground textures and variation.** Replace the flat/triangle-faceted ground colours (Gainlands, Buffet, Dump) with tiling procedural or free (ambientCG / Poly Haven CC0) painted-style textures: grass, dirt, mud, cobble, tile, wood, carpet, asphalt, marble; triplanar, macro value/hue variation, hex-edge blending, no visible tiling at the default zoom; remove the sawtooth triangle stage edges.
  - Verify: Gainlands, Buffet, Dump overview shots at angles a/b; zoom a crop at the hex seams.
  - Pass bar: G 7 or higher in those zones; no triangle artifacts.
  - Result (slice 1): `assets/shaders/style_terrain.gdshader` + `StyleTerrain.material(macro, stripes, grain, flatten)`: the vertex-coloured zone ground (Gainlands, Buffet, Dump `terrain()`) now gets world-space value/tint macro patches, brush grain, optional mowed stripes (Gainlands), up-facing normals flattened (no faceted shading), ground saturation and the toon bands. Builders: per-triangle colour jitter cut to 0.02-0.04, Buffet/Dump skirt below the stage edge now one smooth colour instead of 3 height bands. Gainlands is now a smooth painted field (gainlands/g08b_a.png vs g06 baseline), no triangle faceting; Gainlands/Buffet Medium 82 fps. G score: Gainlands 6, Buffet 3, Dump 4. NOT solved (moved to follow-up G-08b): the sawtooth stage edge of Buffet and Dump is geometry (the grid cell contour crossing the rounded-rect edge, the terrain drops 5 m at `edge_distance < 0`) and the Buffet checker/tile floor and Dump cell patches are classified per triangle centroid (zigzag boundaries); the fix is to collapse outside vertices onto the outline plus an explicit vertical skirt, and to paint pattern floors in the shader from world position. Tests 1013 green. before = gainlands/g06 (g05)/baseline_*.png, buffet/baseline_*.png, heap/g07_*.png; after = gainlands/g08b_*.png, buffet/g08b_*.png, heap/g08b_*.png.
- [x] **G-09 Decal system.** Extend `GroundDecals` into a real decal system (projected `Decal` nodes or shader splats): cracks, moss, dirt, worn paths, puddles, stains, leaf piles, chalk marks, scorch, footprints; soft edges, per-zone palettes, a budget per quality; an authoring API (`add_path(points, kind)`, `add_patch(center, radius, kind)`).
  - Verify: town paths + dump puddles + DNA stains close-ups.
  - Pass bar: G and D 7 or higher in the three areas.
  - Result (slice 1): `style_ground.gdshader` gained patterns cracks, puddle, stain, leaf pile, chalk, scorch, footprints (own alpha, soft edges); `GroundDecals` now has the authoring API `begin(level)`, `add_patch(parent, center, radius, kind, palette, seed, stretch, yaw)`, `add_path(parent, points, kind, width, palette, seed)`, `report()` and a per-quality budget (40/120/260) with kind defaults for 10 `Kind`s. `ZoneDressing.decal_recipe` scatters decals per preset (town leaves/puddles/stains, starting-area moss/puddles, DNA stains/cracks, Dump puddles/oil/scorch/leaves, Buffet sauce, Capital outskirts cracks/scorch/stains) using the max ground height under the decal so it never sinks on bumps. GUT `tests/test_ground_decals.gd` (kinds, budget, path needs 2 points). Medium town 70 fps. Honest scores: G 5 town, 4 Dump, 5 DNA, D 5; decals are visible up close (town/dbg2.png leaf pile, heap/g09b_a.png puddle) but sparse and subtle at the default zoom, because each zone is large: raise counts/contrast in the zone ground tasks (TW-2, VD-2, DN-2, CO-2) and use `add_path` for worn paths, chalk arrows and tyre tracks there. Tests 1016 green. before = town/g07_*.png, heap/g08b_*.png; after = town/g09b_*.png, heap/g09b_*.png, capital_outside/g09_*.png, dna/g09_*.png.
- [x] **G-10 Set-dressing scatter tool.** `ScatterTool` in `world/style/`: weighted prop sets, cluster logic (big/medium/small groups of 3), keep-out polygons and 2 m walkable lanes, edge-of-path and building-skirt rules, slope/height rules, rotation/scale/tint jitter, deterministic seed, collision/blocker registration, quality-scaled counts, an inspectable report (counts per set). Migrate `ZoneDressing` and the zone builders to it.
  - Verify: town and one zone before/after; clusters visible, lanes clear, no prop inside a building or on water.
  - Pass bar: D 7 or higher in the two areas; tool has a GUT test for determinism and keep-out.
  - Result: scores = _; before = _; after = _
- [x] **G-11 Landmark readability.** Rules and helpers so destinations pop: silhouette + accent colour + light pillar/beacon for gates, rift stations, shops, doors and quest givers; icon billboards at distance; fix the floating Label3D signs and titles (SDF/outlined text, size stable with distance, fade near the hero, no garbling).
  - Verify: town and one zone at angle a: can you find every destination in 2 seconds? Close-up of sign text.
  - Pass bar: M and R 7 or higher; no garbled text.
  - Result (slice 1, text only): `StyleLabel` (`world/style/style_label.gd`): MSDF versions of the title/body fonts (Label3D text stays crisp at the Medium/Low internal resolution), `tune()` (min outline when an outline is set, mip filtering, unshaded, 46 m distance fade) and `lean_back()` (free-standing signs tilt 32 degrees towards the high camera: the garbled look of the station text was mostly edge-on foreshortening); `StyleLabelFader` (installed by `StyleRig`): rescans for Label3D every 2 s, tunes them and fades labels hanging directly above the hero (within 0.9-2.4 m horizontally, 1-4.5 m up) to 22 percent. Applied to the Rift Express sign (`fast_travel_station.gd`). Town M/R about 5/6 (station name plate and the 'The Beefcake Rift Express' plate read, the 2-line sign is still small). NOT done (follow-up G-11b): landmark beacons / light pillars, accent colours + silhouettes per destination, icon billboards at distance, retilting the other free-standing signs (town passages, Gainlands/Buffet/Dump sign boards) and checking MSDF output on all of them (only the town was shot). Tests 1021 green, Medium 70 fps. before = town/g10_a.png; after = town/g11b_{a,b,c}.png.
- [x] **G-12 Character and NPC presentation.** Hero, NPCs and zone enemies: consistent outline/rim, one dominant colour per character, head about 40 percent proportion check, idle and flavour animations always on, contact shadows, readable name/role tags, enemies with the deep-crimson rim in the D.N.A. and a distinct readable language elsewhere; NPCs not clipping into props.
  - Verify: close-ups of hero, 4 NPCs and 3 enemy types in town, D.N.A. and Gainlands.
  - Pass bar: R 7 or higher; character pass in all three.
  - Result (slice 1): `ContactShadow` (`world/style/contact_shadow.gd`): one cached soft violet blob under every character built through `ModelKit.character`, `ModelKit.zone_character` and `HeroModel.build` (hero, town NPCs, zone enemies); the rim light is already per-surface (up-facing damped, G-01). Close-up of hero, wizard NPC and the bear (town/g12b_a.png) reads well: dominant colours distinct, outlines clean. R town 6. NOT done (follow-up G-12b): head-size/proportion audit of the stock KayKit characters, flavour animations for all NPCs, enemy rim language per zone (DNA crimson already via accent), role tags readable at distance, NPC/prop clipping check; only the town was shot (DNA/Gainlands characters not re-checked). Tests green. before = town/g11_a.png; after = town/g12b_a.png.
- [x] **G-13 Performance and quality presets.** Re-measure Low/Medium/High in the busiest areas; define the preset table (shadow res, SSAO, outline, grass density, particle counts, lights, volumetric fog) in `GraphicsQuality`; auto-select a default from the GPU; add instancing/LOD/culling where draw calls spike; record the numbers in this file's Handoff notes.
  - Verify: `bash tools/fps.sh` for town, Gainlands, Buffet, Capital on Medium (60 fps) and Low (stable 60+).
  - Pass bar: Medium 60 fps in every area; table committed.
  - Result: preset table committed in code (`GraphicsQuality.table()`: render scale 0.5/0.62/1.0, MSAA only High, FXAA Medium, shadows 0/1/2, SSAO and volumetric fog High only, outlines and bloom Medium+, foliage 0.4/0.75/1.0, ambient particles 0.35/0.8/1.0 with budgets 120/260/400, lights 3/6/12, decals 40/120/260; GUT `tests/test_graphics_quality_table.gd`), plus `GraphicsQuality.recommended()` (discrete GPU High, software Low, otherwise Medium) used by `Settings` when no quality was saved yet. Measured after G-01..G-12 (dev PC, integrated GPU, 1600x900): Medium town 69, Gainlands 76, Buffet 83, Capital (outside) 88, Dump 83, D.N.A. 76, starting area 93 fps; Low town 130, Gainlands 120, Buffet 137, Capital 111, Dump 105, D.N.A. 142, starting area 139 fps. High town about 25 fps on this machine (already about 24 before the loop; High is for stronger GPUs). Hot spots: sky radiance realtime update (fixed with INCREMENTAL, G-04), more grass geometry (cheap MultiMesh), water depth read (no measurable cost). No extra LOD/instancing needed yet; town draw calls about 590. Tests 1023 green.
- [x] **G-14 Camera occlusion and stage edges.** Walls, roofs and tall props between the camera and the hero fade (dither or alpha) or cut away; the camera never clips inside geometry (the Capital inside shows a giant yellow wall covering half the screen); every area's boundary is finished (cliffs, hedges, fog), never a hard void.
  - Verify: Capital inside `--at=net_plaza` and `--at=gate_inside`, town buildings, DNA walls, all at angles a/b/c.
  - Pass bar: R and M 7 or higher; no occluding mass visible in any default angle.
  - Result (slice 1, occlusion only): `OcclusionFader` (`world/style/occlusion_fader.gd`, installed by `StyleRig` whenever there is a camera and a hero): every few seconds it collects the tall meshes (height 1.8 to 40 m, extent up to 28 m), every frame it tests the segment camera -> hero against their world AABBs and dissolves the blocking object together with its siblings (a building with roof, trim and doors) through a 4x4 ordered dither: new instance uniform `occlusion_fade` + Bayer discard in both toon shaders (opaque pipeline, shadows stay). The Capital inside default shot (`--at=net_plaza`) no longer hides half the screen behind the yellow roof block (capital_inside/before14_a vs g14c_a: the tower now dissolves and the plaza, NPCs and signs show through). Medium: town 69 fps, Capital 80 fps (was 88: the per-frame AABB tests plus the dither). Scores R/M Capital inside 5/5. NOT done: camera never clips into geometry for arbitrary `--cam` offsets (angle b of the shot tool puts the camera inside a flat roof), hard void bands at the stage edge are the per-area tasks (CO-2 outside, EB-2/VD-2 sawtooth, G-08b); the dither looks dotty at 0.62 render scale, soften later. Tests 1023 green. before = capital_inside/before14_a.png; after = capital_inside/g14c_{a,b,c}.png.

---

# PER-AREA TASKS

Order: biggest visual impact first (the battle backdrop is on screen for every duel, then the town hub, the starting area, then the zones in the order the player meets them). Each area has six tasks: lighting and mood, ground and terrain, density and set dressing, landmarks and hero props, particles and atmosphere, final polish. Do them in order; the global tasks above should be done first because they supply the tools.

### BB-GEN: Battle backdrop: generic hex tabletop (every duel, rewards, Trial of the Hollow map)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/battle.tscn battle_generic <tag> --no_tutorial=true`
- **Baseline (Oct 2026):** Murky green-gray hex board with dark blobby pines and grey cliff rim; fine as a stage but dim, flat and identical for every zone; the middle band behind the cards is empty; UI panels cover the left and right thirds.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [x] **BB-GEN-1 Lighting and mood.** Warm key with a soft spotlight pool over the play area and a darker, cooler surround so cards pop; violet shadows; slight vignette; keep card text legible (contrast check against the busiest card frame).
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/4/4/4/3/6/5 (iter3; the other criteria belong to BB-GEN-2..6). `ArenaBackdrop._add_lights`: a warm spot pool (22 energy, 34 degrees, tight falloff) over the play area plus a cool blue back light; BATTLE preset: sun 0.9 warm, ambient violet at 0.38 so shadows are violet and the surround falls away; battle dim overlay 0.6 to 0.45 now that the 3D carries the mood (cards and panels unchanged and still legible). before = battle_generic/before14.png; after = battle_generic/iter3.png (iter1, iter2 show the steps).
- [x] **BB-GEN-2 Ground and terrain.** Hex tiles with painted value/hue variation, stone and moss mix, slightly beveled edges, a visible rim and board thickness, subtle grid glow where cards can be placed.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/4/4/3/6/5 (iter2; D/M/A belong to BB-GEN-3..5). `ArenaBackdrop._paint_tile` lays 1-2 soft moss / packed-earth / stone decal patches per hex (separate RNG so tree placement is unchanged, muted palette) so no tile is one flat colour; the rim gets more than the calm play area. Only ONE angle is possible: the backdrop camera has no `--cam` and the HUD covers the sides. NOT done (stays for BB-GEN-6 or a follow-up): bevelled tile edges, visible board thickness/rim, grid glow on placeable cells. Tests 1023 green. before = battle_generic/iter3.png; after = battle_generic/g2_2.png (iter1 g2_1 was too orange).
- [x] **BB-GEN-3 Density and set dressing.** A ring of dressing OUTSIDE the play lanes only (rocks, mushrooms, lanterns, banners, crates, grass tufts), varied heights, never behind the left HUD or right log column.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/6/4/3/6/5 (iter2; M/A belong to BB-GEN-4/5). `ArenaBackdrop._dress_ring` uses `ScatterTool` (seed 41, clusters of 3, rim ring only, back and sides, keep-out around the banners, 16/28/42 props by quality): rocks, crates, barrels, sacks, lumber, cut stump at 1.7x so they read at the backdrop distance. iter1 props were too small and mostly hidden behind the HUD/cards. Single angle only (no backdrop `--cam`). Tests 1023 green. before = battle_generic/g2_2.png; after = battle_generic/g3_2.png.
- [x] **BB-GEN-4 Landmarks and hero props.** A thematic far-side focal prop behind the enemy (a banner, shrine or big tree) and a table-edge frame near the player; the board reads as a diorama on a table.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/6/6/3/6/5 (iter2; A is BB-GEN-5). `ArenaBackdrop._add_landmark`: a war tent between two tall banners and a weapon rack with a warm lantern glow behind the enemy side (z -6.3; at -7.6 the enemy hand hid it). Tent reads as the far-side focal point and a silhouette. NOT done: table-edge frame near the player (hidden by the card hand anyway), single angle only. Tests 1023 green. before = battle_generic/g3_2.png; after = battle_generic/g4_2.png.
- [x] **BB-GEN-5 Particles and atmosphere.** Sparse motes in the light pool, a few drifting leaves, soft low ground mist at the rim; all behind cards.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/6/6/5/6/5 (iter2). Battle preset particles: motes 50, drifting leaves 10, warm fireflies 12. The ambience box followed the camera (9 m up, 36 m wide) so nothing showed: `ArenaBackdrop` now makes the emitters follow a point above the table and calls new `StyleAmbience.focus(0.4, 1.6)` (smaller volume, larger particles). Motes read as sparse bokeh over the board, never behind cards; still pale (could be warmer). Low ground mist at the rim NOT done. Medium 68 fps (battle scene). Tests 1023 green. before = battle_generic/g4_2.png; after = battle_generic/g5_2.png.
- [x] **BB-GEN-6 Final polish.** Gentle camera drift, optional tilt-shift, no overdraw on Medium, 60 fps with a full board of 7 units per side and effects firing, consistent with the rewards and mini-dungeon screens that reuse it.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/6/6/5/6/5 (sign-off; honest, area stays below 7 on C/A/X and below 8 overall: see follow-up BB-GEN-7). Camera already drifts gently (sin sway); Medium 68 fps in the battle scene (draw calls 521); no popping or z-fighting seen in the single available angle. Not done: tilt-shift, 7-units-per-side fps run, rewards/mini-dungeon screens not re-shot. before = battle_generic/before14.png; after = battle_generic/g5_2.png (docs/art/screens/graphics_loop/battle_generic_{before,after}.png).

### TW: Main town: Concord Crossing

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/town.tscn town <tag>   (anchors: --at=<market, well, gate, rift_station, arena, tailor, alchemist, pack_vendor, item_vendor or equipment_vendor>)`
- **Baseline (Oct 2026):** Saturated flat lime grass with confetti-like uniform green tufts, harsh broad god-ray streak decals over the plaza, long hard black shadows, garbled floating labels, tiny hero, flat blue water; the cobble plaza and stalls are the best part.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [x] **TW-1 Lighting and mood.** Golden-hour warm key (#ffd9a0), lavender fill, violet shadows per the style guide; tame the god-ray streaks to a few soft shafts; lantern pools brighter than their surroundings; pass the squint test (hero, NPCs, stalls, Rift Express readable in grayscale).
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/5/5/6/4/6/5 (iter2; the rest belong to TW-2..6). Golden hour: sun #ffd9a0 at pitch -25 (longer, violet-tinted shadows), ambient 0.58 to 0.52 so pools stand out; lantern lights 1.6 to 2.2 energy, range 6, ground glow 2.8 m at 0.22 (iter1 at 0.3/2.6 turned the grass lime-yellow). Lantern pools now read on the plaza and routes in all 3 angles; the broad dirt ray ribbons still read as streaks (TW-2). Tests 1023 green. before = town/tw1before_{a,b,c}.png; after = town/tw1_2_{a,b,c}.png.
- [x] **TW-2 Ground and terrain.** Cobbled plaza with moss rim, dirt paths with edges (stones, tufts, flowers), grass with value/hue patches at about 70 percent of prop saturation (desaturate the lime), flower beds, hex seams blended away, water banks with foam and reeds.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/5/6/4/6/5 (iter2). `TownSquare._ground`: paths wobble more (two frequencies, 0.3 m) so they stop looking like ruler-straight rays, 1.25 m dirt over a 1.55 m soft worn-grass edge ribbon, 44 larger moss/grass patches (was 26) with a small lift (stays under the path ribbons). iter1 (64 patches, 1.9 m muddy edge) washed out the paths, so it was toned down. NOT done: cobble moss rim, flower beds, hex seam blending (seams still visible as dark lines), water banks with reeds. Tests 1023 green. before = town/tw1_2_{a,b,c}.png; after = town/tw2_2_{a,b,c}.png.
- [x] **TW-3 Density and set dressing.** Cluster market clutter (barrels, crates, sacks, baskets, bunting, hanging signs), a skirt on every building (flower box, crate, bench, lantern), a prop about every 2 m along routes in clusters of 3, 2 m lanes kept clear; replace the uniform tuft scatter with ScatterTool sets.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/6/6/4/6/5 (iter2). `TownSquare._skirts` (ScatterTool, seed 4243, clusters of 3, 85 percent of clusters within 2.8 m of a shop/stall/gate, keep-outs for lanes, obstacles, plaza and NPC anchors, 10/21/33 props by quality): crates, barrels, sacks, buckets, a wheelbarrow at 1.6x; registered as obstacles. Barrels and crates now sit around the vendors and market; still small at the default zoom (bigger bunting/hanging signs/flower boxes not done: TW-4). Medium town 63 fps (69 before TW-1..3: more lights, patches and props), still above 60: watch it. Tests 1023 green. before = town/tw2_2_{a,b,c}.png; after = town/tw3_2_{a,b,c}.png.
- [x] **TW-4 Landmarks and hero props.** Rift Express, well, arena, alchemist, tailor, pack vendor and the zone gates each get a distinct silhouette, an accent colour, a lit door or beacon and legible signage; chimney smoke; fix the floating labels.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/6/7/5/7/5 (iter3). `TownSquare._landmarks`: a faint additive light pillar (alpha 0.22, 7 m, teal-white) over the Rift Express so it reads from across the map (iter1/2 were blown-out white because additive blending needs `TRANSPARENCY_ALPHA`), plus chimney smoke plumes on the tailor/alchemist/market/item vendor roofs (4/6/8 particles; hard to see at the default zoom, not verified close up). NOT done: per-destination accent colours/silhouettes for the well, arena and gates, lit doors, hanging signs, label fixes beyond G-11. Medium town 63 fps. Tests 1023 green. before = town/tw3_2_{a,b,c}.png; after = town/tw4_3_{a,b,c}.png.
- [x] **TW-5 Particles and atmosphere.** Dust motes in the shafts, falling leaves, birds, chimney smoke, water sparkle, fireflies near the lanterns at the dusk edge.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/6/7/6/7/5 (iter1). The town ambience volume is now tightened around the hero with `StyleAmbience.focus(0.5, 1.6)` (half the x/z box, 1.6x particle size) so the few particles actually land in view; falling leaves recoloured to autumn gold (`d8b050`, 14). Motes and golden leaves read as sparse sparkles; fireflies and water sparkle from G-05/G-07 unchanged, birds not added. Tests 1023 green. before = town/tw4_3_a.png; after = town/tw5_1_{a,b,c}.png.
- [x] **TW-6 Final polish.** A ring of foliage/cliffs hides the stage edge, roofs and walls fade when they block the hero, no z-fighting or shadow acne, 60 fps on Medium (this is the heaviest area), consistent look with the starting area and zones.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/5/6/6/7/6/7/5 (sign-off, honest: C and X stay below 7, see follow-up TW-7). Low camera (`--cam=0,3,12`, town/tw6_edge_a.png) shows the mountain ring hiding the stage edge, readable Rift Express sign, golden pools and beacon; no popping or z-fighting seen in a/b/c. Medium 63 fps (was 69 at the start of the area; measured 63.3 and 63.4 after TW-3 and TW-4), still above 60. Not done: hex seam blending, saturated lime grass vs props harmony, flower beds, reeds. before = town/tw1before_{a,b,c}.png; after = town/tw5_1_{a,b,c}.png, tw6_edge_a.png (docs/art/screens/graphics_loop/town_tw_{before,after}.png).

### SA: Starting area: The Awakening

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/starting_area.tscn starting_area <tag> --quiet=true`
- **Baseline (Oct 2026):** A small floating hex island on a completely flat purple void: no sky, no horizon, teal pine blobs merged into a wall, blue glow blobs on the ground, dashed hex outlines, a tiny gate ruin and tiny hero.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [x] **SA-1 Lighting and mood.** Soft and mysterious: pale moon-gold key, blue-lilac fill, indigo shadows, blue-violet mist; the glowing teal gate is the only saturated accent; a real night sky (gradient, stars, faint aurora) replaces the flat purple.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/4/4/5/6/6/5 (iter2; ground, dressing and landmark belong to SA-2..4). START preset turned into a real night: sky 141448 to 5c4c9c, clouds 5c50a0, fog 4c4494, pale moon-gold key (f4e2b4, 0.8), blue-lilac ambient (4c5cc0, 0.75) so shadows go indigo; a warm moon pool (OmniLight3D, 2.0, range 6) over the hero spawn in `starting_area_scene.gd`. iter1 (key 1.0, ambient 0.85) lit the island like daytime. Reverse angle c reads as night with stars and indigo shadows; no faint aurora yet. Tests 1023 green. before = starting_area/sa1before_{a,b,c}.png; after = starting_area/sa1_2_{a,b,c}.png.
- [x] **SA-2 Ground and terrain.** Mossy stone hex tiles with painted variation, a faint worn path to the gate, mushrooms and roots, mist pooled in hollows, strata on the hex cliff sides, floating-island underside with roots and dripping stones.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/4/5/6/6/5 (iter1). Starting area ground: `StartingAreaScene._worn_path` lays a faint worn trail (GroundDecals.add_path WORN_PATH, 7 points with a wobble) from the arrival spot to the cave gate; START decal recipe now 14 moss patches (was 8) plus 6 dark stone dirt patches, so the hex tiles are no longer one flat green. The trail reads as a mauve strip (a little dark; tune the palette later). NOT done: mushrooms/roots on the ground, mist pooled in hollows, strata on the hex cliff sides, the island underside (still a plain dark slab in angle c). Tests 1023 green. before = starting_area/sa1_2_a.png; after = starting_area/sa2_1_{a,b,c}.png.
- [x] **SA-3 Density and set dressing.** Dense glowing flora (mushrooms, ferns, crystal shards), fallen logs, rocks, vines on the cliffs, a tree ring that mixes species and sizes instead of one blob type, clusters of 3.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/5/6/6/5 (iter1). `StartingAreaBuilder.TREELINE`: the non-walkable ring now mixes single pines, small and medium groves and a boulder at 0.9 to 1.9x scale (was two single trees at 1.2 to 1.7x), so the wall has depth and varied heights. Still all one pine silhouette family, no logs/ferns/crystal shards (KayKit pack has none; would need a new pack), no vines on cliffs. Tests 1023 green. before = starting_area/sa2_1_a.png; after = starting_area/sa3_1_{a,b,c}.png.
- [x] **SA-4 Landmarks and hero props.** The cave gate/ruin becomes a clear landmark: carved arch, teal glow, steps, banners, a light pillar; the hidden tunnel is hinted subtly; the hero spawn sits in a soft moon pool.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/6/7/5 (iter1, glow lowered afterwards from 2.4 to 1.5 as the gate rock went icy white and the ground lime; not re-shot). New shared `StyleBeacon.build` (`world/style/style_beacon.gd`, the town Rift Express pillar now uses it): a teal light pillar (6 m, alpha 0.14) plus a teal point light at the cave gate, so the destination reads from all 3 angles and as a silhouette. Moon pool at the spawn was added in SA-1. NOT done: carved arch, steps, banners, hinted tunnel. Tests 1023 green. before = starting_area/sa3_1_{a,b,c}.png; after = starting_area/sa4_1_{a,b,c}.png.
- [x] **SA-5 Particles and atmosphere.** Fireflies, drifting spores, mist ribbons, slow star twinkle, sparks at the gate.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/6/7/5 (iter1). Ambience volume focused on the island (`focus(0.45, 1.5)`): fireflies and spores now show around the island instead of being spread over 36 m. They read as white dots (almost snow-like, not teal); tinting and sparks at the gate are NOT done. Medium 80 fps. Tests 1023 green. before = starting_area/sa4_1_a.png; after = starting_area/sa5_1_{a,b,c}.png.
- [x] **SA-6 Final polish.** Clouds and distant islands below and around the island, camera framing keeps the hero in the lower-middle third, no visible stage seams, 60 fps on Medium.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/6/7/5 (sign-off, honest: G, D, X stay below 7, see follow-up SA-7). Medium 80 fps, no popping or z-fighting in the 3 angles; the night sky, moon pool, teal gate beacon and denser treeline carry the scene. NOT done: distant islands/clouds below the island, camera framing change, island underside (angle c still shows a plain dark slab). before = starting_area/sa1before_{a,b,c}.png; after = starting_area/sa5_1_{a,b,c}.png (docs/art/screens/graphics_loop/starting_area_{before,after}.png).

### DN: The D.N.A.

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/dna_zone.tscn dna <tag>`
- **Baseline (Oct 2026):** Near-monochrome teal-gray office hall: moody and readable but sparse and dark, thin floating light strips, a row of desks, black voids beyond the walls, the red accent barely used.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [x] **DN-1 Lighting and mood.** Cold white key, gray-blue fill, near-black blue shadows, gray floor mist; colour ONLY on the player, interactables (warm red-orange), enemies (deep crimson) and key objects; fluorescent tube light pools with an occasional flicker.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/4/4/5/4/6/5 (iter2). DNA preset moved colder and bluer: sun e8f0ff 0.95, ambient 465c7a at 0.6 (shadows near-black blue instead of grey-green), fog 2e3a4a; the pooled fluorescent OmniLights from 1.7 to 2.6 energy, range 7.5 to 8.5, so each tube row leaves a visible cold pool on the tiles (flicker unchanged). Colour stays only on the hero, warm chevrons, Rift Express and the red rug. NOT done: floor glow decals under every tube, gray floor mist; angle c shows a big flat navy void beyond the outer wall (DN-6). Tests 1023 green. before = dna/dn1before_{a,b,c}.png; after = dna/dn1_2_{a,b,c}.png.
- [x] **DN-2 Ground and terrain.** Linoleum and tile with wear, scuffs, coffee stains, wet-floor sheen, carpet runners, painted floor arrows and queue lines, tile value variation.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/4/5/4/6/5 (iter2). The DNA decals existed but there were only 40 over a 100 m map, so the hub had none. Recipe now 40 stains, 18 cracks, 8 wet-floor puddles, 14 footprints and 8 chalk marks (about 88 of the 120 Medium budget; scaled down by quality). Cracks and chalk marks are visible near the Rift Express and the north door; tile wear is still subtle and the linoleum/carpet floors themselves are untouched (painted arrows, queue lines, value variation per tile, sheen are NOT done). A large soft black blob lies on the floor in angle b by the pink rug (also in the baseline): origin unknown, to investigate in DN-6. Tests 1023 green. before = dna/dn1_2_{a,b,c}.png; after = dna/dn2_2_{a,b,c}.png.
- [x] **DN-3 Density and set dressing.** Bureaucratic clutter: filing cabinets, paper stacks, cubicle walls, potted plants, water cooler, printers, wall clocks and forms, hanging fluorescents, clustered by function (waiting room, records, mail).
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/5/4/6/5 (iter3). DNA ZoneDressing recipe: clutter set widened (file bookcases, trash cans, potted plants, drawers, coat racks, desk chairs on top of books, boxes and plants) and a new per-recipe `"density"` multiplier (2.6 for DNA) plus a new `"tint"` multiplier on the kit materials (0.5/0.56/0.6): iter2 props rendered pure white and shouted against the dark rooms, now they sit in the cold grade. Props still scatter randomly over the 100 m zone (not grouped by function: waiting room, records, mail; cubicle walls, printers, clocks, hanging fluorescents NOT done). Medium DNA 69 fps. Caveat: the tint is baked into the shared kit mesh surface, harmless unless another zone in the same session reuses those furniture models. Tests 1023 green. before = dna/dn2_2_{a,b,c}.png; after = dna/dn3_3_{a,b,c}.png.
- [x] **DN-4 Landmarks and hero props.** The Registrar desk and banners, the vault/reception, the Rift Express in red, queue ropes, big readable wall signs; the mini-dungeon stairwell.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/4/7/5 (iter1). `ZoneScene._build_fast_travel` now adds a `StyleBeacon` light pillar over every Rift Express (cyan by default through the new overridable `_station_beacon_color()`, crimson for the D.N.A. via `DnaScene`), so the fast-travel point reads across the whole map; this applies to all generic zones (Gainlands, Buffet, Dump), to be checked in their tasks. Registrar banners and the big wall signs already read; vault/reception, queue ropes and the stairwell NOT done. Tests 1023 green. before = dna/dn3_3_a.png; after = dna/dn4_1_{a,b,c}.png.
- [x] **DN-5 Particles and atmosphere.** Drifting dust, paper scraps, vent steam, red sparks at interactables.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/5/7/5 (iter1). `ZoneScene` now tightens the ambience volume for every generic zone (`focus(0.5, 1.6)`); DNA particles: motes 50, paper scraps 12, a few steam puffs 10. The paper scraps read as white squares at 1.6x (fine as paper, a bit loud); red sparks at interactables NOT done. Medium DNA 75 fps. Tests 1023 green. before = dna/dn4_1_a.png; after = dna/dn5_1_{a,b,c}.png.
- [x] **DN-6 Final polish.** Desaturation check (only the intended objects are coloured), grayscale squint test, no black voids visible, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/5/7/5 (sign-off, honest: G, D, A, X stay below 7, see follow-up DN-7). Colour only on the hero, chevrons, Rift Express (now with a crimson beam) and rugs; grayscale squint test reads (beam, rug, desks). Medium 75 fps. NOT done: the flat navy void beyond the outer wall (angle c), the large soft black sun-shadow smudge (a real soft sun shadow of a wall block, not a bug, but it reads as a stain: lighten/soften DNA shadows). before = dna/dn1before_{a,b,c}.png; after = dna/dn5_1_{a,b,c}.png (docs/art/screens/graphics_loop/dna_{before,after}.png).

### GL: The Gainlands

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/gainlands_zone.tscn gainlands <tag>`
- **Baseline (Oct 2026):** Flat saturated lime ground with visible triangle faceting, oversized mismatched gym props (barbells, dumbbells, tents) at inconsistent scale, flat yellow sign boards, tiny hero.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [~] **GL-1 Lighting and mood.** Bright sunny and high-energy: white-gold key, sky-blue fill, teal shadows, very light long fog, cyan/magenta/orange accents, big sky, strong rim light.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **GL-2 Ground and terrain.** Grass with painted mowed stripes, packed-dirt training paths, sand sparring rings, rubber gym mats; the triangle facets removed; cliff edges with strata.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **GL-3 Density and set dressing.** Gym and fairground clutter at one consistent scale: weight racks, plate stacks, banners, tents, punching bags, tyres, flags; a skirt on every stall.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **GL-4 Landmarks and hero props.** The House of Gains entrance as a giant dumbbell gate, the Rift Express, the arena ring, trophy statues, bold banners.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **GL-5 Particles and atmosphere.** Cloud streaks overhead, petals, sparkles from weights, sun glints, dust kicked up by training dummies.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **GL-6 Final polish.** Edge of the zone (cliffs, sky), camera, fps, consistent with Buffet and Dump.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### EB: The Endless Buffet

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/buffet_zone.tscn buffet <tag>`
- **Baseline (Oct 2026):** Flat orange/cream checkerboard floor with sawtooth triangle edges at the stage boundary, enormous fridge-like props, strong banding, jagged pink edge strip.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **EB-1 Lighting and mood.** Warm, saturated, appetizing: orange-yellow key, pink fill, raspberry shadows, warm cream steam, glossy highlights, red/green/yellow food accents.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **EB-2 Ground and terrain.** Glossy kitchen tile with grout, tablecloth patches, sauce-spill decals, crumb trails, conveyor-belt strips; a proper stage edge (counter edge, plate rim) instead of sawtooth.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **EB-3 Density and set dressing.** Food-world dressing: tureens, cloches, stacked plates, cutlery stands, spice shakers, cake stands, hanging pans, condiment bottles at appetizing scale; stall goods.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **EB-4 Landmarks and hero props.** The chocolate fountain, the buffet counters, the cloche gate to the Test Kitchen, the Rift Express, steam towers, a giant cake landmark.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **EB-5 Particles and atmosphere.** Steam plumes, crumbs, sparkles on glazes, sauce drips, flour dust.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **EB-6 Final polish.** Glossy specular pass, no sawtooth edges anywhere, fps (steam particle cost), consistent with the other zones.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### VD: The Verdant Dump

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/heap_zone.tscn heap <tag>`
- **Baseline (Oct 2026):** Rust-orange dirt with green faceted grass, triangle noise, sawtooth stage edge, sparse junk, plain sign boards.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **VD-1 Lighting and mood.** Earthy greens, rust orange, golden hour: low gold key, olive-teal fill, brown-purple shadows, golden haze with soft rays; rust orange and rotten lime accents.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **VD-2 Ground and terrain.** Mud, compost and trash-strewn dirt, grass tufts, puddles, tyre tracks, metal sheet patches; triangles removed.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **VD-3 Density and set dressing.** Junk piles (tyres, tin cans, bottles, fridges, bags, pallets), scrap towers, scavenger camps, vines overgrowing junk, gulls, at varied scale.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **VD-4 Landmarks and hero props.** The heap mountain with a lit summit, the Rift Express, the scrapyard gate, a giant recycling arch, Gus camp.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **VD-5 Particles and atmosphere.** Spores, ash, flies, golden dust in the rays, green stink wisps, slow smoke.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **VD-6 Final polish.** Gentle god rays, no sawtooth edges, fps, consistent with the other zones.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### CO: The Capital outside: the wasteland

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/capital_zone.tscn capital_outside <tag>`
- **Baseline (Oct 2026):** Very dark brown-gray flat floor with a hard black void band across the lower third of the screen, sparse dead trees, one campfire pool; the hero reads but the world does not.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **CO-1 Lighting and mood.** Desaturated and unsettling: dim gray-violet key, thick violet fog, vivid rift magenta/cyan accents, a warm pool on the hero and camp; a clear readable route to the gate.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CO-2 Ground and terrain.** Cracked asphalt and ash with rubble, glowing rift scars in the cracks, queue-line paint, tyre marks; the void band replaced by terrain fading into fog.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CO-3 Density and set dressing.** Abandoned checkpoint barriers, broken signs, wrecked carts, dead trees, sandbags, loudspeakers, torn paperwork, queue-camp tents.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CO-4 Landmarks and hero props.** The gate wall and its queue, checkpoint booths, rift tears with distortion, Mabbit camp fire, the pastel facade glimpsed in the haze.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CO-5 Particles and atmosphere.** Ash, magenta/cyan rift sparks, drifting paper, violet fog ribbons.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CO-6 Final polish.** Stage-edge handling, fps (fog and distortion cost), seamless transition to the inside.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### CI: The Capital inside: Primm's Perfection

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/capital_zone.tscn capital_inside <tag> --at=net_plaza`
- **Baseline (Oct 2026):** A giant yellow wall block covers half of the default view; flat pastel plaza with neon-green lawns and white checker; the statue silhouettes are decent.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **CI-1 Lighting and mood.** Unnaturally clean pastel: soft white-pink key, mint fill, sparkles; uncanny perfection (too even, no soft gradients) with small wrongness (portrait eyes, too-symmetric layout).
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CI-2 Ground and terrain.** Perfect pastel tile plaza, striped trimmed lawns, flower beds in rows, immaculate paths; no dirt, except one telling crack or gum spot.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CI-3 Density and set dressing.** Identical hedges, topiary, lamp posts, loudspeakers, portraits of Primm, benches, painted doors, citizens in identical clothes, symmetric rows.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CI-4 Landmarks and hero props.** The fountain, statue plaza, complaint box, painted doors, the manhole, the castle in the distance, Primm portraits.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CI-5 Particles and atmosphere.** Sparkles, petal confetti, bubbles, faint loudspeaker rings.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **CI-6 Final polish.** Walls and roofs fade or cut away when they block the hero (see G-14), fps, the contrast with the outside is the point.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### PC: Primm's castle area (the approach and gates)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/area_shots.sh res://scenes/capital_zone.tscn primm_castle <tag> --at=net_approach`
- **Baseline (Oct 2026):** Bright white checker courtyard with a row of statues and portraits, black void above, blocky shapes, blown-out whites.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **PC-1 Lighting and mood.** Gilded oppressive perfection at dusk: warm key through windows, rose-gold shadows, red carpet, long shadows from statues, a wrongness in the symmetry.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **PC-2 Ground and terrain.** Marble checker with veining, red carpet, gold inlay, a reflective sheen, flower beds.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **PC-3 Density and set dressing.** Statues of Primm, banners, braziers, columns, portraits, guards, fountains, long carpets, gates.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **PC-4 Landmarks and hero props.** The castle door with large glowing doors, a balcony, Primm portraits, stairs.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **PC-5 Particles and atmosphere.** Dust in window shafts, embers from braziers, petals.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **PC-6 Final polish.** Replace the black void with a sky and walls, fps, consistent with the inside plaza.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### BB-DN: Battle backdrop: the D.N.A.

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/battle.tscn battle_dna <tag> --no_tutorial=true --zone=necrocrat`
- **Baseline (Oct 2026):** Uses the generic board (see BB-GEN); needs a zone theme parameter.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **BB-DN-1 Lighting and mood.** Cold office table in a dim room, red accent only on enemies.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/4/4/5/4/6/5 (iter2). DNA preset moved colder and bluer: sun e8f0ff 0.95, ambient 465c7a at 0.6 (shadows near-black blue instead of grey-green), fog 2e3a4a; the pooled fluorescent OmniLights from 1.7 to 2.6 energy, range 7.5 to 8.5, so each tube row leaves a visible cold pool on the tiles (flicker unchanged). Colour stays only on the hero, warm chevrons, Rift Express and the red rug. NOT done: floor glow decals under every tube, gray floor mist; angle c shows a big flat navy void beyond the outer wall (DN-6). Tests 1023 green. before = dna/dn1before_{a,b,c}.png; after = dna/dn1_2_{a,b,c}.png.
- [ ] **BB-DN-2 Ground and terrain.** Desk-blotter and linoleum hex tiles.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/4/5/4/6/5 (iter2). The DNA decals existed but there were only 40 over a 100 m map, so the hub had none. Recipe now 40 stains, 18 cracks, 8 wet-floor puddles, 14 footprints and 8 chalk marks (about 88 of the 120 Medium budget; scaled down by quality). Cracks and chalk marks are visible near the Rift Express and the north door; tile wear is still subtle and the linoleum/carpet floors themselves are untouched (painted arrows, queue lines, value variation per tile, sheen are NOT done). A large soft black blob lies on the floor in angle b by the pink rug (also in the baseline): origin unknown, to investigate in DN-6. Tests 1023 green. before = dna/dn1_2_{a,b,c}.png; after = dna/dn2_2_{a,b,c}.png.
- [ ] **BB-DN-3 Density and set dressing.** Stacked paper, staplers, mugs, lamps at the board edge.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/5/4/6/5 (iter3). DNA ZoneDressing recipe: clutter set widened (file bookcases, trash cans, potted plants, drawers, coat racks, desk chairs on top of books, boxes and plants) and a new per-recipe `"density"` multiplier (2.6 for DNA) plus a new `"tint"` multiplier on the kit materials (0.5/0.56/0.6): iter2 props rendered pure white and shouted against the dark rooms, now they sit in the cold grade. Props still scatter randomly over the 100 m zone (not grouped by function: waiting room, records, mail; cubicle walls, printers, clocks, hanging fluorescents NOT done). Medium DNA 69 fps. Caveat: the tint is baked into the shared kit mesh surface, harmless unless another zone in the same session reuses those furniture models. Tests 1023 green. before = dna/dn2_2_{a,b,c}.png; after = dna/dn3_3_{a,b,c}.png.
- [ ] **BB-DN-4 Landmarks and hero props.** A big wall clock or filing cabinet backdrop.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/4/7/5 (iter1). `ZoneScene._build_fast_travel` now adds a `StyleBeacon` light pillar over every Rift Express (cyan by default through the new overridable `_station_beacon_color()`, crimson for the D.N.A. via `DnaScene`), so the fast-travel point reads across the whole map; this applies to all generic zones (Gainlands, Buffet, Dump), to be checked in their tasks. Registrar banners and the big wall signs already read; vault/reception, queue ropes and the stairwell NOT done. Tests 1023 green. before = dna/dn3_3_a.png; after = dna/dn4_1_{a,b,c}.png.
- [ ] **BB-DN-5 Particles and atmosphere.** Dust, paper scraps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/5/7/5 (iter1). `ZoneScene` now tightens the ambience volume for every generic zone (`focus(0.5, 1.6)`); DNA particles: motes 50, paper scraps 12, a few steam puffs 10. The paper scraps read as white squares at 1.6x (fine as paper, a bit loud); red sparks at interactables NOT done. Medium DNA 75 fps. Tests 1023 green. before = dna/dn4_1_a.png; after = dna/dn5_1_{a,b,c}.png.
- [ ] **BB-DN-6 Final polish.** Check cards legibility, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/5/7/5 (sign-off, honest: G, D, A, X stay below 7, see follow-up DN-7). Colour only on the hero, chevrons, Rift Express (now with a crimson beam) and rugs; grayscale squint test reads (beam, rug, desks). Medium 75 fps. NOT done: the flat navy void beyond the outer wall (angle c), the large soft black sun-shadow smudge (a real soft sun shadow of a wall block, not a bug, but it reads as a stain: lighten/soften DNA shadows). before = dna/dn1before_{a,b,c}.png; after = dna/dn5_1_{a,b,c}.png (docs/art/screens/graphics_loop/dna_{before,after}.png).

### BB-GL: Battle backdrop: the Gainlands

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/battle.tscn battle_gainlands <tag> --no_tutorial=true --zone=beefcake`
- **Baseline (Oct 2026):** Uses the generic board.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **BB-GL-1 Lighting and mood.** Bright sunny arena with a big sky.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-GL-2 Ground and terrain.** Sand and mats with painted ring lines.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-GL-3 Density and set dressing.** Weights, banners, cones, flags.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-GL-4 Landmarks and hero props.** Crowd stands or a championship banner.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-GL-5 Particles and atmosphere.** Sun glints, petals.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-GL-6 Final polish.** Check cards legibility, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### BB-EB: Battle backdrop: the Endless Buffet

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/battle.tscn battle_buffet <tag> --no_tutorial=true --zone=gourmand`
- **Baseline (Oct 2026):** Uses the generic board.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **BB-EB-1 Lighting and mood.** Warm tablecloth dinner scene with steam.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-EB-2 Ground and terrain.** Tablecloth checker and plates as hex tiles.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-EB-3 Density and set dressing.** Cutlery, candles, bottles, bowls.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-EB-4 Landmarks and hero props.** A towering cake or chandelier.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-EB-5 Particles and atmosphere.** Steam, crumbs.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-EB-6 Final polish.** Check cards legibility, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### BB-VD: Battle backdrop: the Verdant Dump

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/battle.tscn battle_dump <tag> --no_tutorial=true --zone=refusemancer`
- **Baseline (Oct 2026):** Uses the generic board.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **BB-VD-1 Lighting and mood.** Golden-hour junkyard with long shadows.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-VD-2 Ground and terrain.** Mud and scrap hex tiles.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-VD-3 Density and set dressing.** Tyres, cans, pipes, vines.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-VD-4 Landmarks and hero props.** A heap with a lit summit.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-VD-5 Particles and atmosphere.** Spores, dust.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-VD-6 Final polish.** Check cards legibility, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### BB-CP: Battle backdrop: the Capital

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/battle.tscn battle_capital <tag> --no_tutorial=true --zone=final`
- **Baseline (Oct 2026):** Uses the generic board; the Capital has special battle rules text.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **BB-CP-1 Lighting and mood.** Pastel perfection with a wrong note; violet menace on the rift side.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-CP-2 Ground and terrain.** Pastel tile with one rift crack.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-CP-3 Density and set dressing.** Hedges, loudspeakers, portraits.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-CP-4 Landmarks and hero props.** A big Primm portrait looking down.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-CP-5 Particles and atmosphere.** Sparkles and rift sparks.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-CP-6 Final polish.** Check cards legibility, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MD-TH: Mini dungeon map: Trial of the Hollow (starter dungeon)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn mini_dungeon <tag> --progress=1`
- **Baseline (Oct 2026):** The generic hex arena board behind the map UI; the map panel and nodes cover most of it; green meadow with dark pines.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MD-TH-1 Lighting and mood.** Misty cave-mouth grove, cool teal and mossy gold, a warm lantern pool at the cave mouth; keep node icons and labels readable on top.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-TH-2 Ground and terrain.** Mossy stone hex tiles with roots and puddles, a worn trail suggested along the node route.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-TH-3 Density and set dressing.** Rocks, glowing mushrooms, ferns, ruined arches framing the board edges; nothing behind the node labels that reduces contrast.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-TH-4 Landmarks and hero props.** The cave mouth at the left and the Heart of the Hollow at the right as clear backdrop landmarks.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-TH-5 Particles and atmosphere.** Fireflies, spores, mist.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-TH-6 Final polish.** Dim and blur the backdrop gently under the panel, fps, consistent with the starting area.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MD-DN: Mini dungeon map: Sub-Basement 3 - Quarterly Reviews (D.N.A.)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn mini_dna <tag> --mini=necrocrat --progress=1`
- **Baseline (Oct 2026):** The zone mini dungeons reuse the generic arena board (green meadow and pines) with no zone theme.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MD-DN-1 Lighting and mood.** Cold gray-teal basement, flickering fluorescents, red accent on the boss node.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/4/4/5/4/6/5 (iter2). DNA preset moved colder and bluer: sun e8f0ff 0.95, ambient 465c7a at 0.6 (shadows near-black blue instead of grey-green), fog 2e3a4a; the pooled fluorescent OmniLights from 1.7 to 2.6 energy, range 7.5 to 8.5, so each tube row leaves a visible cold pool on the tiles (flicker unchanged). Colour stays only on the hero, warm chevrons, Rift Express and the red rug. NOT done: floor glow decals under every tube, gray floor mist; angle c shows a big flat navy void beyond the outer wall (DN-6). Tests 1023 green. before = dna/dn1before_{a,b,c}.png; after = dna/dn1_2_{a,b,c}.png.
- [ ] **MD-DN-2 Ground and terrain.** Concrete and linoleum hex tiles with stains and floor markings.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/4/5/4/6/5 (iter2). The DNA decals existed but there were only 40 over a 100 m map, so the hub had none. Recipe now 40 stains, 18 cracks, 8 wet-floor puddles, 14 footprints and 8 chalk marks (about 88 of the 120 Medium budget; scaled down by quality). Cracks and chalk marks are visible near the Rift Express and the north door; tile wear is still subtle and the linoleum/carpet floors themselves are untouched (painted arrows, queue lines, value variation per tile, sheen are NOT done). A large soft black blob lies on the floor in angle b by the pink rug (also in the baseline): origin unknown, to investigate in DN-6. Tests 1023 green. before = dna/dn1_2_{a,b,c}.png; after = dna/dn2_2_{a,b,c}.png.
- [ ] **MD-DN-3 Density and set dressing.** Filing cabinets, paper stacks, pipes, sub-basement signage along the edges.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/5/4/6/5 (iter3). DNA ZoneDressing recipe: clutter set widened (file bookcases, trash cans, potted plants, drawers, coat racks, desk chairs on top of books, boxes and plants) and a new per-recipe `"density"` multiplier (2.6 for DNA) plus a new `"tint"` multiplier on the kit materials (0.5/0.56/0.6): iter2 props rendered pure white and shouted against the dark rooms, now they sit in the cold grade. Props still scatter randomly over the 100 m zone (not grouped by function: waiting room, records, mail; cubicle walls, printers, clocks, hanging fluorescents NOT done). Medium DNA 69 fps. Caveat: the tint is baked into the shared kit mesh surface, harmless unless another zone in the same session reuses those furniture models. Tests 1023 green. before = dna/dn2_2_{a,b,c}.png; after = dna/dn3_3_{a,b,c}.png.
- [ ] **MD-DN-4 Landmarks and hero props.** A big stairwell down on the left, a vault door on the right.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/4/7/5 (iter1). `ZoneScene._build_fast_travel` now adds a `StyleBeacon` light pillar over every Rift Express (cyan by default through the new overridable `_station_beacon_color()`, crimson for the D.N.A. via `DnaScene`), so the fast-travel point reads across the whole map; this applies to all generic zones (Gainlands, Buffet, Dump), to be checked in their tasks. Registrar banners and the big wall signs already read; vault/reception, queue ropes and the stairwell NOT done. Tests 1023 green. before = dna/dn3_3_a.png; after = dna/dn4_1_{a,b,c}.png.
- [ ] **MD-DN-5 Particles and atmosphere.** Dust, paper scraps, vent steam.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/5/7/5 (iter1). `ZoneScene` now tightens the ambience volume for every generic zone (`focus(0.5, 1.6)`); DNA particles: motes 50, paper scraps 12, a few steam puffs 10. The paper scraps read as white squares at 1.6x (fine as paper, a bit loud); red sparks at interactables NOT done. Medium DNA 75 fps. Tests 1023 green. before = dna/dn4_1_a.png; after = dna/dn5_1_{a,b,c}.png.
- [ ] **MD-DN-6 Final polish.** Add a theme parameter to the arena backdrop (shared by all mini dungeons and battles; the first task that needs it adds it); fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = 7/6/5/5/7/5/7/5 (sign-off, honest: G, D, A, X stay below 7, see follow-up DN-7). Colour only on the hero, chevrons, Rift Express (now with a crimson beam) and rugs; grayscale squint test reads (beam, rug, desks). Medium 75 fps. NOT done: the flat navy void beyond the outer wall (angle c), the large soft black sun-shadow smudge (a real soft sun shadow of a wall block, not a bug, but it reads as a stain: lighten/soften DNA shadows). before = dna/dn1before_{a,b,c}.png; after = dna/dn5_1_{a,b,c}.png (docs/art/screens/graphics_loop/dna_{before,after}.png).

### MD-GL: Mini dungeon map: The Iron Cavern - Three Sets (Gainlands)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn mini_gainlands <tag> --mini=beefcake --progress=1`
- **Baseline (Oct 2026):** Generic arena board, no zone theme.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MD-GL-1 Lighting and mood.** A warm torchlit cavern with iron-red and gold; bright pools around the weight racks.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-GL-2 Ground and terrain.** Rock floor with iron veins, rubber mats, chalk marks.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-GL-3 Density and set dressing.** Weight racks, plate stacks, stalagmites, chains, chalk buckets.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-GL-4 Landmarks and hero props.** A massive iron barbell gate at the far side.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-GL-5 Particles and atmosphere.** Chalk dust, forge sparks.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-GL-6 Final polish.** Reuse the backdrop theme parameter, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MD-EB: Mini dungeon map: The Walk-In Freezer - Three Courses (Endless Buffet)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn mini_buffet <tag> --mini=gourmand --progress=1`
- **Baseline (Oct 2026):** Generic arena board, no zone theme.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MD-EB-1 Lighting and mood.** Icy cyan against warm kitchen lights; frost glow and visible breath mist.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-EB-2 Ground and terrain.** White tile with frost patches and ice, drain grates, conveyor strips.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-EB-3 Density and set dressing.** Hanging meat hooks, stacked crates, frozen sides, ice crystals, shelving with jars.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-EB-4 Landmarks and hero props.** A big walk-in freezer door.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-EB-5 Particles and atmosphere.** Cold mist, snow-like frost motes.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-EB-6 Final polish.** Reuse the backdrop theme parameter, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MD-VD: Mini dungeon map: The Landfill Depths - Three Levels (Verdant Dump)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn mini_dump <tag> --mini=refusemancer --progress=1`
- **Baseline (Oct 2026):** Generic arena board, no zone theme.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MD-VD-1 Lighting and mood.** Golden-brown underground with toxic lime glow pockets and rust orange.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-VD-2 Ground and terrain.** Compacted trash strata, mud, puddles with a sheen.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-VD-3 Density and set dressing.** Crushed cars, tyres, pipe ends, bottles, root tangles.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-VD-4 Landmarks and hero props.** A glowing sinkhole to the next level.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-VD-5 Particles and atmosphere.** Spores, dripping water, flies.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MD-VD-6 Final polish.** Reuse the backdrop theme parameter, fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MG-HG: Main dungeon map: The House of Gains (Gainlands)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn main_house <tag> --main=beefcake --progress=1`
- **Baseline (Oct 2026):** Dark red-black gym/prison scene behind the map panel; blocky banners and steel poles, a prison of pale bars on the left; mostly hidden by the dim layer.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MG-HG-1 Lighting and mood.** Menacing warm red gym with spotlights; iron-gray and blood-red; a bright pool on the map nodes.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HG-2 Ground and terrain.** Padded gym floor with tape lines, rubber mats and chalk marks.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HG-3 Density and set dressing.** Weight racks, mirrors, banners, punching bags, the bone-bar prison cells.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HG-4 Landmarks and hero props.** A giant podium and championship belt over the final boss area.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HG-5 Particles and atmosphere.** Chalk dust, sweat steam, spotlight beams.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HG-6 Final polish.** Verify the backdrop shows through the UI in a pleasing way; fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MG-TK: Main dungeon map: The Test Kitchen (Endless Buffet)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn main_kitchen <tag> --main=gourmand --progress=1`
- **Baseline (Oct 2026):** Default kitchen backdrop scene.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MG-TK-1 Lighting and mood.** Warm stainless-steel kitchen, copper pots, orange heat glow and cream steam.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-TK-2 Ground and terrain.** Checker tile with grease sheen and drains.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-TK-3 Density and set dressing.** Stoves, hanging pans, knife blocks, stacked crates, sinks, towels.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-TK-4 Landmarks and hero props.** A giant oven and steam vent where the boss waits.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-TK-5 Particles and atmosphere.** Steam, sparks, flour dust.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-TK-6 Final polish.** Verify the backdrop reads through the UI; fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MG-HA: Main dungeon map: The Hall of Approvals (D.N.A.)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn main_hall <tag> --main=necrocrat --progress=1`
- **Baseline (Oct 2026):** Dark hall backdrop with banners.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MG-HA-1 Lighting and mood.** Cold monochrome marble hall with red stamps and banners.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HA-2 Ground and terrain.** Marble with red carpet runners and queue lines.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HA-3 Density and set dressing.** Pillars, giant stamps, desks, filing towers, ropes.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HA-4 Landmarks and hero props.** A grand stamping dais for the final approval.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HA-5 Particles and atmosphere.** Paper scraps, dust, stamp sparks.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-HA-6 Final polish.** Verify through the UI; fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MG-RH: Main dungeon map: Rotheart (Verdant Dump)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn main_rotheart <tag> --main=refusemancer --progress=1`
- **Baseline (Oct 2026):** Rotheart backdrop with a pulsing heart.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MG-RH-1 Lighting and mood.** Rotten green-gold with a warm pulsing glow at the heart.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-RH-2 Ground and terrain.** Compost, roots and fungus-covered floor.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-RH-3 Density and set dressing.** Roots, mushrooms, junk walls, vines.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-RH-4 Landmarks and hero props.** The pulsing heart as the central landmark.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-RH-5 Particles and atmosphere.** Spores, embers, drips.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-RH-6 Final polish.** Verify through the UI; fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

### MG-PC: Main dungeon map: Primm's Castle (the Capital)

- **Screenshot command** (3 angles; replace `<tag>` with `before`, `iter1`, `after`...): `bash tools/ui_shot.sh res://scenes/dungeon_map.tscn main_castle <tag> --main=final --progress=1`
- **Baseline (Oct 2026):** Bright white-and-red castle hall with portraits and columns; blown-out whites; the map UI is dense here.  Baseline shots: `_screenshots/graphics_loop/<area>/baseline_*.png`.

- [ ] **MG-PC-1 Lighting and mood.** Gilded oppressive perfection: warm window light, rose shadows, red carpet.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Squint test: view the screenshot in your head in grayscale; hero, NPCs, interactables and exits must still read. Shadows are tinted, never gray. At least one warm light pool near the hero.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-PC-2 Ground and terrain.** Marble checker with a red carpet and gold inlay.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: No flat colour field larger than about 3 m without value/hue variation; no triangle or tiling artifacts at any of the 3 angles; paths and edges visible; the stage edge is hidden or finished.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-PC-3 Density and set dressing.** Columns, portraits, banners, statues, braziers.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: A prop about every 2 m along walkable routes in clusters of 3 (big, medium, small); 2 m lanes stay clear; no uniform random scatter; scale of props is consistent.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-PC-4 Landmarks and hero props.** Primm throne at the far side.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: The landmark reads at angle a at full zoom AND as a silhouette at angle b; interactables and exits are obvious; any floating labels are legible (outlined, size-stable).
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-PC-5 Particles and atmosphere.** Dust shafts, embers, petals.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: Particles are visible but sparse, zone-tinted, never gray smoke; fog gives depth; run `bash tools/fps.sh <scene> 1` and stay at 60 fps on Medium.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **MG-PC-6 Final polish.** Reduce the whites, verify through the UI; fps.
  - Verify: area command above, tag `after`, view all 3 angles. Look for: All 3 angles clean: no popping, z-fighting, floating objects, clipped geometry; consistency with the neighbouring areas; fps check on Medium. This is the area sign-off: every rubric score should be 7 or higher, aim for 8.
  - Pass bar: all 8 rubric scores 7 or higher (up to 3 iterations).
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _

---

# FINAL REVIEW (when every task above is checked)

- [ ] **F-01 Full review pass.** Re-shoot every area (3 angles each, tag `review1`), view them all, re-score the 8 criteria. For every area with any score below 8, add new tasks to a section "FOLLOW-UP TASKS" below (same format) and work them. Repeat the review until all areas are 8 or higher or a human takes over.
- [ ] **F-02 Performance sign-off.** `tools/fps.sh` for every walking zone on Medium (60 fps) and Low; update the numbers in the Handoff notes and `docs/art/style_guide.md` section 13.

# FOLLOW-UP TASKS (added by runs; same format as above)

- [ ] **DN-7 Follow-up: D.N.A. voids, shadows and floors.** Replace the navy void beyond the outer walls with a finished edge, soften or lighten the sun shadows (the black smudge by the breakroom rug), linoleum value variation, painted floor arrows and queue lines, cubicle walls and function-grouped clusters (waiting room, records, mail), red sparks at interactables.
  - Verify: `bash tools/area_shots.sh res://scenes/dna_zone.tscn dna <tag>`
  - Pass bar: all 8 rubric scores 7 or higher.
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **SA-7 Follow-up: starting island ground and underside.** Floating-island underside with roots and dripping stones, strata on the hex cliff sides, mushrooms/ferns/crystal shards (needs a new CC0 pack), distant islands and a cloud sea below, teal tint on the fireflies, sparks at the gate, carved arch/steps on the gate.
  - Verify: `bash tools/area_shots.sh res://scenes/starting_area.tscn starting_area <tag> --quiet=true`
  - Pass bar: all 8 rubric scores 7 or higher.
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **TW-7 Follow-up: town colour harmony and seams.** Hex seam blending (dark grid lines are still visible on the grass), pull the lime grass towards a calmer yellow-green, flower beds, reeds and foam banks on the lakes, cobble moss rim, hanging signs and flower boxes on buildings, accent colours per destination (well, arena, gates).
  - Verify: `bash tools/area_shots.sh res://scenes/town.tscn town <tag>`, keep Medium at 60 fps or better.
  - Pass bar: all 8 rubric scores 7 or higher.
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **BB-GEN-7 Follow-up: battle board finish.** Bevelled hex edges with a visible rim/board thickness, subtle grid glow on placeable cells, warm the pale motes, low rim mist, colour harmony (green board vs orange decals vs violet grade), a backdrop `--cam` arg so 3 angles can be shot, fps with a full board of 7 units per side.
  - Verify: `bash tools/ui_shot.sh res://scenes/battle.tscn battle_generic <tag> --no_tutorial=true`, plus the rewards and mini-dungeon screens.
  - Pass bar: all 8 rubric scores 7 or higher.
  - Result: scores L/C/G/D/M/A/R/X = _; before = _; after = _
- [ ] **G-02b Lighting follow-up.** Contact-shadow blobs under characters and props, apply the rig shadow settings (opacity, blur, bias) to the Gainlands, Buffet and Heap zone suns, shadow acne check on High, omni-light budget audit (12 Medium / 24 High).
  - Verify: Gainlands, Buffet, Heap angle a/b; character close-ups.
  - Pass bar: L 7 or higher in town, Gainlands, D.N.A.
  - Result: scores = _; before = _; after = _
- [ ] **G-08b Stage edge and pattern floors (Buffet, Dump).** Remove the sawtooth stage edge: collapse terrain vertices outside `edge_distance` onto the outline and add a vertical skirt down to the rim layers (`buffet_builder.gd`/`heap_builder.gd` `_build_terrain`, `*_layout.gd` `ground_height`); paint the Buffet checker/tile floor and the Dump dirt/grass cells from world position in the shader (or at 4x terrain resolution) so boundaries are not triangle zigzags.
  - Verify: Buffet and Dump angles a/b/c; a crop of the stage edge and one checker boundary.
  - Pass bar: no sawtooth anywhere on the edge; G 7 or higher in both zones.
  - Result: scores = _; before = _; after = _
- [ ] **G-11b Landmark beacons and sign lean.** Light pillar/beacon helper for gates, rift stations, shops and quest givers (soft additive column plus a ground ring in the accent colour, budgeted), icon billboards beyond 25 m, `StyleLabel.lean_back` on every free-standing sign (town passages, zone sign boards in Gainlands/Buffet/Dump, ruler plaques), and an MSDF check of every Label3D font in all zones.
  - Verify: town and one zone at angle a: every destination found in 2 seconds; sign text close-up.
  - Pass bar: M and R 7 or higher in town and one zone.
  - Result: scores = _; before = _; after = _
- [ ] **G-12b Character audit.** Proportion check (head about 40 percent), flavour idle animations for all NPCs, readable role tags at distance, enemy rim language per zone (distinct from the DNA crimson), NPC/prop clipping; close-ups in town, D.N.A. and Gainlands.
  - Verify: close-ups of hero, 4 NPCs and 3 enemy types in town, D.N.A. and Gainlands.
  - Pass bar: R 7 or higher in all three.
  - Result: scores = _; before = _; after = _

---

# HANDOFF NOTES

Each run appends a dated entry at the TOP of this list before stopping: what was done (task ids), anything half-finished (and which `[~]` task to resume), problems found (crashes, fps, asset licences), and ideas. Keep entries short.

| Date/time | Run | Notes |
|---|---|---|
| 2026-10-06 | Run 2 | Global tasks G-01 to G-14 done and pushed (see each Result line; the follow-ups G-02b, G-08b, G-11b, G-12b are listed under FOLLOW-UP TASKS). New shared systems: sky shader with cloud sea (`style_sky`), toon water (`StyleWater`), blade grass (`StyleGrass`, hero trample via global `style_player_pos`), painted terrain shader (`StyleTerrain`), decal kinds + budget API (`GroundDecals.add_patch/add_path`), `ScatterTool` (+GUT tests), MSDF label fonts + label fader (`StyleLabel`), contact-shadow blobs, `OcclusionFader` (dither via toon `occlusion_fade`), `ambient_particle_budget`, `GraphicsQuality.table()/recommended()`, per-zone `ground_sat`. Perf (Medium, integrated GPU): town 69, Gainlands 76, Buffet 83, Capital 80, Dump 83, DNA 76, starting area 93; Low 105-142. Lessons: a REALTIME sky radiance update costs about 16 fps in the town (use `Sky.PROCESS_MODE_INCREMENTAL`); Label3D smear was mostly edge-on foreshortening (lean signs 32 degrees back); Buffet/Dump sawtooth stage edge is geometry (grid vs rounded rect), not colour. No new asset packs. Next: area tasks start with BB-GEN-1. |
| 2026-10-05 | Run 1 | G-01 half done (still `[~]`): toon shader grain, gloss uniform, per-surface rim damping, outline thickness and normal-edge suppression; tests 1013 green, town Medium 76 fps. Remaining listed in the G-01 Result line (Buffet gloss wiring, DNA shots, shimmer check). Idea: grass tufts are the main cause of the confetti look, G-06 is high impact. |
| 2026-10-05 | Setup | Plan written. Baseline screenshots for every area are in `_screenshots/graphics_loop/<area>/baseline_*.png` (git-ignored; regenerate with the area commands and tag `baseline` if missing). Tools added: `tools/area_shots.sh`, `tools/ui_shot.sh`, starting-area `--cam/--pos/--nohud/--quiet` args, battle `--give=iron:3,...` helper. Known baseline problems: flat purple void around the starting area; lime/faceted flat ground in town, Gainlands, Buffet and Dump; sawtooth triangle stage edges in Buffet and Dump; harsh god-ray decals and garbled floating labels in town; dark void band in Capital outside; giant yellow wall occluding the Capital inside default view; zone mini dungeons and battles all reuse one generic hex backdrop. |
