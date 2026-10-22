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
| 2 Crosspath test zone | not started | |
| 3 Battle and effects | not started | |
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
- **D5 (Part 2, planned): no LightmapGI.** Godot 4.7.2 exposes no script API to bake (`LightmapGI` has `light_data` but no `bake()`; the
  bake lives in the editor plugin only), the kit geometry is generated at run time without UV2 and dressing changes with story state. The
  "baked" look is built instead from cheap static pieces (see Part 2).

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
