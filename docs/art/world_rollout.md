# World rollout: the approved World Look Test style, game-wide

The look approved in the World Look Test (`docs/art/world_look_test.md`) is now the game's look in every overworld area, and the hero is the painted 2.5D sprite. The World
Look Test scene (`tests/world/world_look_test.tscn`) is unchanged and stays as the dev reference (it builds its own copy of the pieces, with its tuning panel and F1 - F6
presets; the game's rig stays out of it).

Judgment calls are numbered WR-1... in `docs/design/open_questions.md`. What each area still needs is in `docs/art/world_rollout_needs.md`.

## Part A: camera and post-processing

**One camera for the whole overworld** (starting area, town, the four zones, the Capital outside and inside). `WorldLookRig` (`world/look/world_look_rig.gd`) is installed by
every scene right after its `StyleRig`:

| What | Value |
|---|---|
| Pitch / distance / FOV / height offset | 20 deg / 6.2 m (x the mouse-wheel zoom, 1.5 by default) / 44 deg / 0.9 m |
| Tilt-shift | focus 0.62, band 0.13, blur 7 px at the top and 6 px at the bottom |
| Bloom | intensity 0.5, threshold 1.05, spread 0.6 |
| Fog | density 0.0035, colour `#f2cfa4` (the town; each zone has its own colour and density, see below) |
| Grade | warmth 0.3, saturation 1.1, vignette 0.28 |

There is no saved "My Preset" (`data/art/world_look_my_preset.json` does not exist), so these are the approved F5 values. If you save one in the World Look Test panel the game
uses it (`WorldLookRig.game_values()`). The wheel zoom is 1.0 - 2.0 of the base distance (6.2 - 12.4 m).

**Per-zone mood, stored as data:** `data/art/zone_looks.json`, one entry per style preset id (the camera is shared; a mood changes only fog colour and density, warmth,
saturation, vignette, bloom, the sky palette, how the distant scenery is tinted, foliage and ambient life). A mood can `extends` another (the Capital's "service down"
variants). The Capital swaps mood when the hero walks through the gate.

| Area | Mood |
|---|---|
| Main town | the approved golden afternoon |
| Starting area | blue-violet dusk, stars-and-mist: dark sky, low bloom threshold, pale blue motes, no birds |
| D.N.A. | near-monochrome: desaturated 0.85, cold grey-blue fog 0.016, low bloom, an office floor that carries on to the horizon and a dark ceiling-gloom for a sky (no clouds, no water, no grass) |
| Gainlands | bright and sunny: saturation 1.16, pale blue haze, big blue sky and white clouds |
| Endless Buffet | warm and appetising: apricot haze, orange sky, rose-tinted hills |
| Verdant Dump | golden hour: amber haze, rust-tinted hills, drifting leaves |
| Capital outside | bleak: saturation 0.72, vignette 0.46, grey-violet fog, ash sky, dead-grey ground to the horizon |
| Capital inside | eerily perfect: saturation 1.14, almost no vignette, clean blue sky with perfect clouds |

**Nothing blocks the hero.** `OcclusionFader` (the existing dither fade) was extended for the low camera: it considers anything 1 m or taller (was 1.8), tests two points on
the hero, dissolves a piece that is close to the lens (foreground clutter, 6.5 m) and **cuts away completely** anything the camera is inside of (gate towers, the walls of a
building). Pieces without the toon shader (portals, light pillars) fade through their transparency instead. The scan is spread over frames and the per-frame test is plain
float maths over cached boxes. The rig's own pieces (sky, rings, water) are never faded or culled. The camera cannot clip into geometry because whatever it would enter is cut
away; there is no physics collider in these scenes to ray-cast against.

**Oversized props:** town signposts are 0.68 x their old size, the notice board 0.72 x; zone signboards went from 0.6 to 0.5 (Gainlands 0.8 to 0.58). Tall trees in the camera's
wedge in the starting forest are gone (they filled the screen).

**Settings** (Display page): "Depth of field (tilt-shift blur, Medium and High)", "Bloom", "Fog quality" (Off / Light / Full), plus the existing Graphics quality presets
(Low / Medium / High). The tuning panel and F1 - F5 presets stay in the World Look Test (a debug scene).

## Part B: sky, distant scenery, water, foliage in every outdoor area

The test's pieces moved to `world/look/` (`WorldSky`, `WorldScenery`, `WorldFoliage`, `WorldAmbient`, their shaders) and now take their settings from the zone's mood:

- **Sky**: gradient + sun glow + three layers of drifting clouds + soft cloud shadows, palette per zone.
- **Scenery**: one sea plane to the horizon, painted far shore, three painted rings (treeline, hills, mountains) centred on the middle of each map and pushed out to clear its
  corners, shore foam; the five landmark cards in the town. The Capital island in the town keeps its white wall ring and castle (they looked bare from behind in the test but
  from the bridge they read as a finished fortress).
- **No edges**: the D.N.A. and the Capital outside have an `Apron` (an unlit ground plane the scene fog dissolves into the background) instead of a sea.
- **Foliage and ambient life**: the 1,750-card foliage layer and the motes / leaves / bird flocks, per zone (cell mix, density, tint).

Closest existing assets stand in for zone-specific art (the Gainlands uses the town's treeline and hills tinted blue, the Buffet the same tinted apricot, ...); each need is in
`docs/art/world_rollout_needs.md`.

## Performance (Ryzen 5 4500U iGPU, 1600x900, Medium, vsync off)

The low camera sees every zone to the horizon, which the old high camera never did: the Capital went from 244 to over 2,200 draw calls. Meshes beyond 48 m of the camera are
now not drawn (a dithered fade over the last 6 m), the foliage and rings are single draws. Numbers are in `docs/progress.md` ("World rollout").
