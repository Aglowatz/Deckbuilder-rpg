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
| 0 Baseline | in progress | shots `docs/art/graphics_tier1/before/`, fps `docs/art/graphics_tier1/fps_before.md` |
| 1 Presets + upscaling | not started | |
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

(filled in per part)

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
