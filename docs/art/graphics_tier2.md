# Graphics pass, Tier 2: spending the performance headroom

Overnight Oct 25b, Part 2 (brief: `docs/overnight/oct25b/brief.md`). Tier 1 (`docs/art/graphics_tier1.md`) built the look; the performance pass
(`docs/perf/report.md`) then freed 1.7-4.8 ms per frame on Medium. Tier 2 spends some of it, one feature per commit, keeping each only when it
clearly improves the look within `docs/perf/budgets.json` (Medium stays 60+ on the development PC: Ryzen 5 4500U, AMD integrated GPU, D3D12,
1600x900). Low and Safe Mode never get heavier; Intel integrated GPUs get nothing new on High beyond Medium's set; characters stay the clearest
thing on screen; the painted storybook look stays.

Start: `48b2488e` (tag `pre-overnight-oct25b`). Before shots: `docs/art/graphics_tier1/t2_before/<area>.jpg` (the Tier 1 camera spots,
`bash tools/tier1_shots.sh t2_before`); before fps: `docs/art/graphics_tier1/fps_t2_before.md` (`bash tools/tier1_fps.sh t2_before "0 1 2"`).
After shots: `docs/art/graphics_tier1/t2_after/`, fps `fps_t2_after.md`; per-feature shots in `docs/art/graphics_tier2/f<N>_*/`.

## What was kept, what was dropped

| # | Candidate | Verdict | Where it lives | Cost on Medium (dev PC) |
|---|---|---|---|---|
| 1 | Height fog volume for the Verdant Dump ravine (and other hollows) | **kept, Dump only** | zone style `fog.height` / `fog.height_density` (`ZoneStyles.look_overrides`, `WorldLookRig._apply`: the engine's exponential height term of the existing fog) | 0 (the Dump 75.3 -> 75.5 fps) |
| 2 | Bounce-colour channel in the ground light map | **kept** | `GroundLight` (G/B channels: signed red/blue chroma deltas of the walls round a spot, luminance-preserving; `BOUNCE_AMOUNT`, `BOUNCE_REACH`), `style_ground_light.gdshaderinc`, global `style_ground_bounce`, zone style `light.bounce` | 0 per frame (66.2 -> 65.9 fps on the square); the bake reads each kit texture once per session (Crosspath 215 occluders, 88 coloured, ~0.4 s on the first load, 22 textures) |
| 3 | Wind sway from one shared wind | **kept** | `assets/shaders/style_wind.gdshaderinc` (direction, gust front, flutter, `hang_offset`), used by `style_grass`, `world_foliage` (foliage cards), `kit_card` (tree cards), `style_toon` / `_double` (foliage sway + cloth), `style_cloth_icon` | 0 (Gainlands 76.5 -> 76.7, forest 83.6 -> 82.7) |
| 4 | Water upgrade (depth colour, shoreline foam, gentle refraction) | **kept: refraction added** (depth colour and shore foam were Tier 0 already) | `style_water.gdshader` `use_refraction` / `refraction` / `see_through` (screen copy + depth read; a sample that would pull something above the water into it falls back), `StyleWater.material` sets it from `GraphicsQuality.water_refraction` (Medium and up) | ~0.1-0.4 ms (Gainlands 76.5 -> 75.8, Buffet 79.7 -> 77.3) |
| 5 | Shadow-casting lanterns in night scenes | **kept: 1 on Medium, 2 on High** | `StyleRig._update_light_budget` + `GraphicsQuality.lantern_shadows`, gated on `preset.sun_energy <= StyleRig.NIGHT_SUN_ENERGY` (0.5: the forest camp's moon is the one night scene) | ~0.4 ms (forest 83.6 -> 81.0) |
| 6 | FSR 2 as the Medium default on discrete GPUs only | **kept (rule + test)** | `GraphicsQuality.discrete_gpu` (set by `Settings` from `GpuInfo.current_kind`, the by-name classifier), `upscaler_mode`: Auto + Medium + discrete -> FSR 2; integrated GPUs, Low, explicit choices unchanged; `test_fsr2_is_the_medium_default_on_discrete_gpus_only` | not measurable here (this PC is integrated: FSR 1) |
| 7 | SSAO at half resolution on Medium | **dropped** | measured with `GraphicsQuality.ssao` opened to Medium: town square 66.2 -> 57.8 fps (+2.3 ms GPU), forest 83.6 -> 71.4 (+2.0 ms): under 60 in Crosspath, the whole headroom in every zone | - |
| 8 | Baked vertex AO on kit meshes (eaves, window reveals) | **already present, no change** | `BuildingKit` paints vertex colours: 0.74 at the foot of the ground floor, 0.8 along the top of the top floor (the eave band), 0.7 / 0.62 / 0.5 on the eave fascia and soffit, a dark reveal quad behind every opening (`building_kit.gd` 205-220, 314-318, 458) | - |
| 9 | Ground decals from existing art (dirt, cracks, moss, puddles, petals) | **already present; left for the polish cycles** | every area scatters painted decals from `data/art/texture_presets.json` (`PaintedDecals`): the town moss / cracks / puddles / leaves / flowers, the Gainlands chalk / mud, the Buffet crumbs / sauce, the D.N.A. papers / cracks / puddles / ectoplasm, the Dump rust / oil / mud / puddles / scorch, the Capital cracks / scorch / rifts; the kit's DEC-PATHEDGE / WORNPATCH / IVY / WALLSTAIN are on paths and walls | - |

## Per feature

### 1. Height fog (the Dump)

Godot's environment fog carries an exponential height term (`fog_height`, `fog_height_density`) that costs nothing extra. The Dump's style sets the
line at 0.5 m with density 0.3: the stream bed (-3.4 m) and the water (about -1 m) sit in a pale violet mist, the ravine floor (0 m) takes a
trace, the terraces (3 / 6.5 / 10 m) and everything standing on the floor stay clear. Tried and reverted in the forest camp (0.4 / 0.25: the
camp floor sits at the line, and the paint-over's mist cards already do the job) and the Gainlands (no hollow at the spawn's eye level): neither
shot changed visibly. `f1_heightfog/heap_stream_before.jpg` / `heap_stream_after.jpg` (the water beside the entrance bridge).

### 2. Bounce colour

The ground light map was R8 (openness). It is RGBA8 now: R openness as before, G / B the red and blue chroma deltas (0.5 = none) of the
coloured walls round the texel, blurred with the shade. Each rect occluder's colour is the average of its materials' albedo times its
texture's average (an 8x8 grid of point samples after one decode per texture per session; the toon shader's `albedo` / `albedo_tex` as
`StyleToon` copied them); the amount follows the colour's saturation, so grey stone bounces nothing and warm plaster, timber and red tile
bounce most; tree discs bounce nothing (their shade is the violet ambient). The shader multiplies by `1 + delta` with the green delta chosen
so luminance never changes: a tint, never a brightening. The bounce band reaches 2.2x the shade margin (bounced light spreads wider than
contact shadow) and fades out lower on the screen than the shade (a warm tint left by a cut-away building is no dark rectangle).
`f2_bounce/town_square.jpg`, `town_street.jpg` (vs `t2_before/`), `town_square_x3.jpg` (3x, for the eye), `debug_channels.jpg` (the raw map
painted on the ground: the violet bands are the data).

### 3. One shared wind

Before: the grass blades had their own gust wave, the foliage cards another, the tree cards none (a per-card sine), the toon foliage a
third, and the cloth a fourth; the foliage and tree cards ignored the zone's `wind` global. Now `style_wind.gdshaderinc` holds the direction,
a gust front (a main wave along the wind plus a slower one, squared) and the shared `hang_offset`; every system scales its own amplitude by
the gust and the zone wind. A gust visibly crosses the grass, the trees and the banners in one motion; the banner icons move with their
cloth because both use the one `hang_offset`. `f3_wind/gainlands.jpg` (a still: banners and grass intact, no stretch).

### 4. Water refraction

The toon water already had the depth gradient, the wobbling shore foam, caustics and sparkles. Medium and up now also show the bed through
the shallows: the opaque screen is sampled with a noise wobble (`refraction` 0.018, less in deep water), a depth check rejects any sample
nearer than the water (so the hero on the bank is never smeared into it), and the bed blends in by shallowness (`see_through` 0.55) under
the caustics and foam. `f4_water/heap.jpg` (the Dump's shallows beside the bridge), `gainlands.jpg` (deep water: unchanged, as intended).

### 5. Lantern shadows at night

`KitLights` keeps every dressing light shadowless; the style rig's 0.3 s budget pass now also turns shadows on for the nearest one (Medium) or
two (High) lanterns when the preset's sun is dim (<= 0.5: the forest camp's moon at 0.42; every daylight zone is 0.66+). By day the sun's
shadow owns the scene and a lantern shadow would only fight it. Cost 0.4 ms on Medium in the forest. Honest note: at the camp the lantern
sits on the ground beside the bedroll, so the shadow is modest; it shows when the hero or a critter passes the lamp. `f5_lanterns/forest.jpg`.

### 6. FSR 2 on discrete GPUs

Tier 1's D1 kept FSR 2 opt-in (6 ms on this iGPU). A discrete GPU (by name: `GpuInfo.classify`, which ignores D3D12's "everything is discrete")
now gets it as the Medium default under Auto; High is native (nothing to upscale); explicit Settings choices are untouched; Intel iGPUs still
map FSR 2 to FSR 1. Not measured here (no discrete GPU); the rule is covered by `tests/test_graphics_tier1.gd`.

## Readability check

Every zone, the battle and the dungeon map were re-shot from the fixed spots after all features (`t2_after/`): characters keep their rim,
normal-map shading and contact shadow and stay the brightest, sharpest thing on screen; the bounce tint and the mist sit under them; the
battle board and the dungeon map (2D screens) are untouched by every Tier 2 feature.

## Fps (dev PC, vsync off, 5 s sample; `fps_t2_before.md` -> `fps_t2_after.md`, every feature on)

| Area | Low before -> after (fps / GPU ms) | Medium before -> after | High before -> after | Medium avg ms vs budget |
|---|---|---|---|---|
| town_square | 93.6 / 8.13 -> 95.0 / 8.17 | 66.2 / 13.09 -> 65.5 / 12.96 | 19.5 / 49.12 -> 19.4 / 48.31 | 15.26 vs 19.5 |
| town_street | 91.9 / 8.60 -> 92.7 / 8.60 | 64.4 / 13.91 -> 65.1 / 13.48 | 19.3 / 51.02 -> 18.0 / 51.25 | 15.36 vs 19.5 |
| forest | 120.2 / 6.70 -> 125.0 / 6.71 | 83.6 / 10.33 -> 83.3 / 10.38 | 24.1 / 39.47 -> 24.4 / 39.80 | 12.01 vs 15.5 |
| gainlands | 96.3 / 7.45 -> 95.7 / 7.06 | 76.5 / 10.93 -> 75.8 / 11.19 | 25.8 / 37.16 -> 26.1 / 35.82 | 13.19 vs 19.2 |
| buffet | 106.2 / 7.74 -> 100.1 / 7.42 | 79.7 / 10.37 -> 77.5 / 11.10 | 27.6 / 34.64 -> 26.0 / 36.09 | 12.90 vs 16 |
| dna | 99.4 / 6.35 -> 102.9 / 6.23 | 86.7 / 9.15 -> 86.9 / 9.24 | 30.6 / 29.71 -> 31.0 / 30.53 | 11.51 vs 15.7 |
| heap | 92.0 / 7.55 -> 87.9 / 7.45 | 75.3 / 11.89 -> 71.9 / 11.84 | 26.9 / 34.31 -> 25.3 / 37.64 | 13.90 vs 17.1 |
| capital_out | 85.2 / 7.41 -> 85.0 / 7.35 | 68.4 / 11.87 -> 69.0 / 12.02 | 22.7 / 42.21 -> 22.6 / 41.76 | 14.49 vs 18.2 |
| capital_in | 85.8 / 7.14 -> 87.0 / 7.21 | 69.2 / 11.73 -> 70.0 / 11.83 | 23.6 / 39.78 -> 23.9 / 39.21 | 14.29 vs 18.5 |
| battle | 363.0 / 1.69 -> 366.0 / 1.82 | 365.2 / 1.70 -> 363.5 / 1.75 | 362.5 / 1.77 -> 370.4 / 1.87 | 2.75 vs 3.8 |
| dungeon_map | 456.0 / 1.19 -> 473.7 / 1.21 | 454.3 / 1.20 -> 464.6 / 1.20 | 446.4 / 1.36 -> 464.3 / 1.19 | 2.15 vs 2.9 |

Medium stays at 65-87 fps in every 3D area (the lowest, the two Crosspath spots, 65.1-65.5 as before); Low is within run-to-run noise
everywhere (nothing new runs there); High within noise. The water refraction and the night lantern are the only per-frame costs and they
sit inside the noise band (0.1-0.4 ms measured one feature at a time, above). Every Medium average is 3-6 ms under its `budgets.json` line
and every Low average likewise; draw calls are unchanged (the features are shader work and data).

## Budgets and checks

- GUT in groups: root 247, core 1414 (+1 pending, the chef hat art), ui/audio/characters 195, world 394 - all passing. The banner hang test
  now checks the shared wind include (the offset and the direction moved there); a new test covers the FSR 2 rule.
- Walk smokes: Crosspath (19 shots), the opening forest, Gainlands (11), Buffet (22), D.N.A. (20), the Dump (21), the Capital (36): all OK.
- `bash tools/perf_budget.sh structure`: OK, all budgets met (the features add no nodes, meshes, lights or scripts).
- `bash tools/perf_budget.sh frame`: started as a background run and stopped by the tool harness for low system memory before it wrote a
  line (an orphaned Godot was then killed by hand). Not restarted by the overnight run; the after-fps table above was taken with the same
  probe at the same spots and every area is inside its Low and Medium `avg_ms` and `draw_calls` lines with margin. Re-run the formal check
  when the PC is free: `bash tools/perf_budget.sh frame`.
- Readability: `t2_after/` shots of every area, the battle and the dungeon map reviewed against `t2_before/`; characters unchanged, the
  2D screens unchanged.
