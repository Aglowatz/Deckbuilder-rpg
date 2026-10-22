# Graphics pass, Tier 1: AAA look on a low-end budget

Running document of the Tier 1 graphics pass (October 2026): state, decisions, before/after shots and fps per zone, so the work can
resume after a context reset. Brief: the biggest visual jump for the least runtime cost, 60 fps on Medium on the development PC
(Ryzen 5 4500U, AMD integrated GPU, D3D12), safe on Intel integrated graphics (`GpuInfo` / `BootGuard` / Safe Mode from v0.4.3),
painted 2.5D storybook art direction kept (characters are always the clearest thing on screen), export under 1 GB, Low and Safe Mode
never heavier.

Start commit: `22aff389` (tag `pre-graphics-tier1`). Rules: one Godot at a time (foreground), 10-12 screenshots per part at 1280x720,
`STOP_TASK` check per part, GUT + walkability + smokes + fps + commit + push per part, old saves keep loading, no new art.

## State

| Part | Status | Notes |
|---|---|---|
| 0 Baseline | done (commit 409b7195) | shots `docs/art/graphics_tier1/before/`, fps `docs/art/graphics_tier1/fps_before.md` |
| 1 Presets + upscaling | done | upscaler / render scale / sharpness settings, Medium 0.58 + crisp, cheaper sun shadow, Low cull 0.8; `fps_part1_{low,medium}.md` |
| 2 Crosspath test zone | done | ground light map, sprite normal maps + zone rim, sun turned to the front-right, AgX grade, haze cards (off in Crosspath), fader fixes; `part2/`, `part2_cameras/`, `compare/part2_*`, `fps_part2.md` |
| 3 Battle and effects | done | 2D effect lights on the board and cards (budget 1/3/6), board grade per area, chest-opening flash, level-up pulse; `part3/`, `compare/part3_battle.jpg` |
| 4 Zone roll-out | not started | |
| 5 Verify and report | not started | |

## Tools

- `bash tools/tier1_shots.sh <tag> [areas]`: the fixed camera spots (town square + west street, forest camp, each zone's spawn, Capital
  outside and inside the gate, a Gainlands practice battle, the Necrocrat mini dungeon map) at 1280x720 into `docs/art/graphics_tier1/<tag>/`.
- `bash tools/tier1_fps.sh <tag> ["0 1 2"] [areas]`: avg / p95 / min fps, GPU and CPU ms, draw calls and objects per area and quality into
  `docs/art/graphics_tier1/fps_<tag>.md` (vsync off, 3 s warm-up, 5 s sample; `tools/fps_probe.gd`).
- `tools/side_by_side.gd` for the before/after collages (`docs/art/graphics_tier1/compare/`).

## What exists already (read before changing anything)

- Quality presets: `GraphicsQuality` (Low / Medium / High knobs, `heavy_passes_allowed` false on Intel iGPUs), `Settings.graphics_quality`,
  `StyleRig.apply()` pushes them to the viewport, environment and lights. Render scale is already FSR 1 at 0.5 (Low) / 0.62 (Medium) / 1.0 (High);
  no sharpness control, no FSR 2, no settings-screen choice.
- Lighting: one `DirectionalLight3D` sun + a faint fill per scene (`StyleRig`), lantern `OmniLight3D`s on a nearest-N budget (`KitLights`,
  3 / 6 / 12). No LightmapGI: kit geometry is generated at run time (no UV2) and dressing changes with story state (`KitAO` note).
  Fake AO: vertex colours on kit meshes + unlit footprint / blob quads (`KitAO`), SSAO only on High.
- Sprites: `WorldSprite` cards are lit by the sun and lamps through a custom `light()` (wrap lighting, shadow-map attenuation cools the card),
  screen-space rim from the texture alpha, a sheared silhouette ground shadow as a next pass (`world_sprite_shadow.gdshader`), a violet
  contact blob (`ContactShadow`), and `cast_shadow = ON` with `depth_prepass_alpha` + alpha scissor (so the sun shadow map sees the silhouette).
  No normal maps.
- Grade: `world_post.gdshader` (tilt-shift, warmth, saturation, vignette, green/red calm) + `Environment.adjustment_*` + ACES / Filmic
  tonemap per preset (`ZonePreset.filmic`). AgX is available in 4.7.2 (`TONE_MAPPER_AGX`), unused. `adjustment_color_correction` unused.
- Sky: painted gradient (`world_sky.gdshader`) with optional zone kit panorama, 29 drifting cloud cards in three layers, a sun card, and a
  noise cloud-shadow plane (`world_cloud_shadow.gdshader`, `cloud_shadow` per mood). Light shafts exist (`world_shaft.gdshader`) but are
  off everywhere (`ambient.shafts false`): they read as flat strips with the sun behind the camera.
- Fog: distance fog per mood; volumetric fog High-only (and never on Intel iGPUs); no height fog.

## Decisions

- **D1 (Part 1): FSR 2 is not for Medium.** On the dev iGPU FSR 2 costs 6 ms of GPU at 0.62 scale (town square 13.4 -> 19.7 ms) and still 3.5 ms
  more than FSR 1 at 0.5. It stays an opt-in choice in Settings for discrete GPUs; Auto never picks it, and Intel iGPUs map it to FSR 1.
- **D2 (Part 1): Medium renders at 0.58 with FSR 1 and a crisp default sharpness (slider 0.8).** Crops of the square at 0.62 / 0.55 / 0.5
  (`tools/crop_strip.gd`): 0.55 at a crisp sharpness reads like 0.62 at the old default; 0.5 goes blocky on the paintings. 0.58 is the
  middle and buys about 1 ms.
- **D3 (Part 1): the sun shadow goes crisper on Low and Medium** (blur 2.4 -> 1.2, PCF soft-low -> soft-very-low): 1.2 ms of GPU on Medium
  and a better fit for the painted style (readable shadow shapes instead of a smear). High keeps 1.8 / soft-medium.
- **D4 (Part 1): Low culls meshes at 0.8 of the zone range.** Low is partly draw-call bound; the zones lose 20-25% of their draw calls at
  the spawn spots (Gainlands 515 -> 392) with no visible change at the default camera, since the far third is haze anyway.
- **D5 (Part 2): no LightmapGI.** Godot 4.7.2 exposes no script API to bake (`LightmapGI` has `light_data` but no `bake()`; the
  bake lives in the editor plugin only), the kit geometry is generated at run time without UV2 and dressing changes with story state. The
  "baked" look is built instead from a ground light map baked at load (`GroundLight`, D6) plus the kit's own AO skirts; SSAO stays High-only.
- **D6 (Part 2): the ground light map is hollow under buildings.** The first bake darkened whole footprints; a building the OcclusionFader
  cuts away then showed a dark rectangle. Buildings paint a band of shade along their footprint line (fading 1 m inward, 0.8-2.8 m outward
  with height), tree cards and posts paint a canopy disc, fences and flat meshes paint nothing. The map also fades out over the lowest fifth of
  the screen (where the fader works), as do the kit's AO skirts and window pools.
- **D7 (Part 2): the Crosspath sun moved from behind the camera (yaw 70) to the front-right (yaw 112, pitch -32, shadow opacity 0.72).** With
  the sun behind the camera every shadow fell north, hidden behind its caster: the sun shadow pass cost 12 fps and showed nothing. From the
  front-right, lamps, benches, the fountain and every character throw a readable shadow to the left and towards the viewer, faces stay lit.
  `light.key_yaw / key_pitch / shadow_opacity` are zone-style keys, so each zone sets its own in Part 4.
- **D8 (Part 2): AgX with tuned values, not ACES.** Plain AgX was flat and grey; with exposure 1.0, saturation 1.2 / 1.14 post, contrast 1.06
  and a violet-shadow / gold-highlight split tint it keeps the warmth of ACES and handles bright highlights better (the Capital's white glare
  in Part 4). Keys: `grade.tonemap, exposure, brightness, shadow_tint, highlight_tint, gamma, post_contrast`.
- **D9 (Part 2): light shafts and fog cards are off in Crosspath.** The shaft cards face the camera and the sun is now in front of it, so they
  drew as nothing; the fog cards were invisible on the flat lawn at every strength that did not read as a pale rectangle. Both stay as the
  `haze` block of a mood (`HazeCards`, none on Low) for the zones whose paint-overs have mist and rays (the forest, the Dump).
- **D10 (Part 2): sprite shadows.** The shadow-map shadow of a card was always there (the card turns to face the light in the shadow pass) but
  invisible with the old sun; the sheared silhouette pass collapsed to a line under a side light (its width ran along the camera) and sat
  below the painted decals (0.035 m under 0.045 m). Now: the silhouette's width runs across the light's ground direction, both it and the
  contact blob sit at 0.085 m, and the map shadow is kept on every level (its cost is in the shadow pass Medium already pays).

## Part 0: Baseline (done)

Before shots: `docs/art/graphics_tier1/before/<area>.jpg` (11 spots, 1280x720, the saved Medium setting). Fps: `fps_before.md`
(merged), `fps_before_{low,medium,high}.md` (full columns), probe window 1600x900, vsync off, 5 s sample.

| Area | Low fps / GPU ms | Medium fps / GPU ms | High fps / GPU ms | draw calls (Medium) |
|---|---|---|---|---|
| town_square | 93.7 / 8.05 | 59.7 / 14.57 | 21.3 / 44.40 | 751 |
| town_street | 94.8 / 8.88 | 56.6 / 15.78 | 20.2 / 47.64 | 638 |
| forest | 126.6 / 6.53 | 76.6 / 11.34 | 25.6 / 37.19 | 163 |
| gainlands | 92.5 / 7.20 | 68.8 / 12.31 | 25.2 / 37.83 | 551 |
| buffet | 104.2 / 6.95 | 72.0 / 11.62 | 28.2 / 34.30 | 456 |
| dna | 100.8 / 5.82 | 81.3 / 10.32 | 33.1 / 27.39 | 631 |
| heap | 75.9 / 7.43 | 66.3 / 13.25 | 27.2 / 35.32 | 711 |
| capital_out | 77.3 / 7.59 | 62.7 / 13.46 | 21.9 / 42.94 | 405 |
| capital_in | 77.0 / 7.66 | 62.9 / 13.70 | 24.6 / 39.28 | 531 |
| battle | 344.1 / 1.77 | 367.4 / 1.76 | 347.0 / 1.78 | 206 |
| dungeon_map | 454.5 / 1.20 | 474.8 / 1.19 | 453.7 / 1.20 | 48 |

What the baseline says:
- Medium is GPU-bound and already at the 60 fps line in Crosspath (14.6-15.8 ms of GPU per frame at 0.62 scale). Every technique
  added on Medium has to be paid for by a saving elsewhere; Part 1 (presets and upscaling) must first buy headroom.
- Low is partly CPU / submission bound (8 ms GPU but 10.7 ms frames, 600-750 draw calls): visibility ranges and fewer objects
  help Low more than a lower render scale would.
- High (native 1600x900, MSAA 2x, SSAO, volumetric fog, 4096 shadow atlas) runs at 20-33 fps on this iGPU: it is a discrete-GPU
  preset, as intended (`GpuInfo` never recommends it for an iGPU).
- Battle and dungeon map are 2D painted screens (a battleboard image, a painted node map) on top of a dimmed 3D backdrop; they cost
  under 3 ms, so Part 3 has room for lights.
- Look (before shots): the lighting is even and flat; the sun sits behind the camera, so sun shadows are short and hidden behind
  their casters; corners, eaves and the ground under trees are as bright as open ground; characters read small and do not separate
  from the ground; the far third of every zone is blurred haze (tilt-shift + fog) with a pale sky; the Capital inside is overexposed
  white at the gate, the D.N.A. and the Capital outside are flat grey. A pre-existing artifact in `town_street`: a building cut away
  by the `OcclusionFader` leaves its sun shadow and window-glow pool as a flat violet rectangle on the ground.

Lever sweep on the square at Medium (`tools/fps_toggles.gd`, baseline 61.8 fps): no sun shadow +12 fps, scale 0.5 +17, scale 0.55 +10,
shadow blur 0 +7.6, bloom off +6.6, tilt-shift post off +6.4, hard shadow filter +5, outline off +4.6, scenery off +5; far cull changed
nothing (GPU-bound). This is what Part 1 spends and what later parts may still trade.

## Part 1: Quality presets + upscaling (done)

What changed (`GraphicsQuality`, `Settings`, `StyleRig`, the Display page of `SettingsPanel`, `tools/fps_probe.gd --set=`):
- Settings: **Upscaling** (Auto / Off native / FSR 1 / FSR 2), **Render scale (3D)** (quality preset / 50 / 62 / 75 / 85 / 100 %) and a
  **Sharpness** slider (0 soft .. 1 crisp -> `Viewport.fsr_sharpness` 0.8 .. 0.0). Saved in settings.cfg (`video/upscaling`,
  `render_scale`, `sharpness`); an older file keeps Auto / preset / 0.8. Safe Mode is unchanged (Low, which is FSR 1 at 0.5 as before).
- Presets: Medium 0.62 -> 0.58, sun shadow blur [1.0, 1.2, 1.8] and filter [very low, very low, medium], Low mesh range x 0.8. MSAA and
  FXAA are never combined with FSR 2. New knobs for the later parts: `cloud_shadows` (Medium+), `sprite_normals` (Medium+), `haze_cards`
  [0, 6, 10], `effect_lights` [1, 3, 6], `effect_light_shadows` (High, never on Intel iGPUs).
- Tests: `tests/test_graphics_tier1.gd` (round trip, old-file defaults, upscaler rules, Low never heavier, Intel never gets High-only passes).

| Area | Medium before fps / GPU ms | Medium Part 1 | Low before | Low Part 1 |
|---|---|---|---|---|
| town_square | 59.7 / 14.57 | 72.3 / 12.23 | 93.7 / 8.05 | 82.5 / 8.36 (rerun; the sweep's 59 was a one-off) |
| town_street | 56.6 / 15.78 | 69.1 / 12.84 | 94.8 / 8.88 | 92.3 / 8.72 |
| forest | 76.6 / 11.34 | 87.7 / 9.95 | 126.6 / 6.53 | 122.5 / 6.60 |
| gainlands | 68.8 / 12.31 | 79.1 / 10.89 | 92.5 / 7.20 | 90.7 / 7.05 |
| buffet | 72.0 / 11.62 | 82.0 / 10.18 | 104.2 / 6.95 | 99.2 / 7.51 |
| dna | 81.3 / 10.32 | 94.4 / 8.63 | 100.8 / 5.82 | 105.0 / 7.13 |
| heap | 66.3 / 13.25 | 72.5 / 11.39 | 75.9 / 7.43 | 78.0 / 7.84 |
| capital_out | 62.7 / 13.46 | 68.5 / 11.53 | 77.3 / 7.59 | 75.8 / 7.62 |
| capital_in | 62.9 / 13.70 | 71.8 / 11.60 | 77.0 / 7.66 | 75.7 / 7.33 |

Medium gained 2-3 ms of GPU in every zone (the budget Parts 2-4 spend); Low is within noise of before (its GPU ms never rose beyond
the +-0.5 ms run-to-run spread) with fewer draw calls in the zones.

## Part 2: Crosspath as the test zone (done)

Techniques, what each does, where it is on:

| Technique | Where it lives | Low | Medium | High | Kept? |
|---|---|---|---|---|---|
| Ground light map ("baked" AO) | `GroundLight` (bakes at load from every static occluder, half-metre texels, ~55 ms for 133 occluders in Crosspath), `style_ground_light.gdshaderinc` multiplied into the toon, painted terrain, triplanar, path, decal and sprite shaders | off | on | on | yes: corners, the foot of walls, under trees and the people standing there share one soft violet shade |
| Sprite normal maps + zone rim | `tools/sprite_normals.gd` -> 299 `<FRAME>_n.png` (half res, 6.7 MB on disk), `SpriteLibrary.normal_frame`, `world_sprite.gdshader use_normal` (amount 0.7), rim colour from the zone's key light | off | on | on | yes: the sun and lanterns shape the figures, still painterly |
| Real character shadows | shadow-map shadow of the card (all levels with shadows), silhouette pass (`world_sprite_shadow.gdshader`, fixed axes), contact blob, both lifted to 0.085 m | blob + silhouette | + map shadow | + map shadow (soft medium) | yes |
| Grade | AgX + exposure, split tint, gamma, post contrast per zone style (`main_town.json`: warm, violet shadows, gold highlights) | on | on | on | yes (free) |
| Sky + cloud shadows | painted sky as before; cloud-shadow plane now Medium+ only (`WorldSky.set_cloud_shadows`), `cloud_shadow_scale` key | off | on | on | yes |
| Light shafts + height fog | `HazeCards` from the mood's `haze` block, budget [0, 6, 10] | off | 6 | 10 | system kept, no cards in Crosspath (D9) |
| Sun angle + shadow opacity | zone style `light.key_yaw 112, key_pitch -32, shadow_opacity 0.72` | - | - | - | yes (D7) |
| Fader fixes | a cut-away building hides its shadows-only proxy and stops casting; the ground under kit buildings is painted (grass, a soil band along the walls) instead of the bare hub floor; FADED 1.0 | all | all | all | yes: the violet rectangle of Part 0 is gone |
| Tree card shadows | `kit_card.gdshader` alpha scissor so the shadow pass cuts the leaves (a blended card cast its whole rectangle) | - | on | on | yes |

Shots: `part2/town_square.jpg`, `part2/town_street.jpg` (same spots as `before/`), the camera presets and swivels in `part2_cameras/`
(classic, overview, close, swivel_left, swivel_right), collages `compare/part2_town_square.jpg` and `compare/part2_town_street.jpg`.

| Spot | Low before -> Part 2 (fps / GPU ms) | Medium before -> Part 2 | High before -> Part 2 |
|---|---|---|---|
| town_square | 93.7 / 8.05 -> 92.9 / 8.23 | 59.7 / 14.57 -> 69.6 / 12.61 | 21.3 / 44.40 -> 20.6 / 45.61 |
| town_street | 94.8 / 8.88 -> 94.6 / 8.88 | 56.6 / 15.78 -> 67.6 / 13.65 | 20.2 / 47.64 -> 19.6 / 51.00 |

Medium holds 60 with every Part 2 technique on (12.6-13.7 ms of GPU, about 2.5 ms under the baseline); Low is unchanged within noise.

## Part 3: Battle and effects (done)

The battle is a painted battleboard (a `TextureRect`) with the cards as Controls on top, not a 3D scene, so "effects light the scene" is 2D lighting:

- **Effect lights** (`BattleLights`, a `Node2D` of pooled `PointLight2D`s under the board root): every `BattleFX.burst` and `flash_ring` (card
  plays, hits, spells, heals, the win) pulses an additive radial light at its position (in 0.06 s, out over 0.45-0.55 s) in the effect's
  colour. Only canvas items carrying `BattleLights.LIT_BIT` are lit: the board and every card view (`mark_lit`), never the HUD, log or
  tooltips. Budget `GraphicsQuality.effect_lights` = 1 / 3 / 6 live lights (the oldest is reused). `--lights=true` holds three lights for shots.
- **D11: no 2D shadows.** A hit's light sits at the struck card; with a `LightOccluder2D` on every card the light inside the occluder went
  black (first High shot). The brief's "shadows on High" is kept for the 3D effect lights only: the **chest-opening flash** (`ChestKit._open_flash`,
  an `OmniLight3D` over the lid, 3.2 energy fading over 1.1 s, shadow on High and never on an Intel iGPU).
- **Board grade per area** (`BattleGrade` + `ui/shaders/board_grade.gdshader`): the board image takes the zone style's grade at half strength
  (warmth, post saturation / contrast, split tint) from the arena theme's preset (Gainlands bright gold, D.N.A. cool, Buffet copper...); the
  neutral board stays plain. Cards and HUD are untouched.
- **Level-up moment**: `BattleLights.flash` puts a 1.6 s gold pulse under the level number (lights the rays and the dark stage).

Shots: `part3/battle.jpg` (same spot as `before/`, graded), `part3/battle_lights_high.jpg` (units on both sides, three held lights, High),
collage `compare/part3_battle.jpg`. Fps with three lights held and four units out: Medium 268.6 fps (GPU 2.67 ms, was 1.76), High 240.3
(3.00 ms): the battle keeps 60 fps with room to spare.
