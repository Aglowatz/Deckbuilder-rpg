# Visual slice log: the main town square (Brief 12, Part C)

Screenshots live in `_screenshots/visual_slice/` (git-ignored like all screenshots). Reference comparisons: ref_cozy_interior (warm pools, dense props), ref_boxing_room (chunky props, saturated floor colour, banners).

| Iteration | Screenshot | Critique | Fix |
|---|---|---|---|
| 0 (before) | `before_town_square.png` | flat neon-green hex field, sparse props, no shadow colour, hero is a pale knight; nothing like the references | toon shader, outline, preset, dressing |
| 1 | `iter1_toon_only.png` | toon bands and outlines work, but everything is over-exposed and the grass is lime | exposure 0.82, ambient dimmer, grass tile tint |
| 2 | `iter2_first_dressing_overexposed.png` | density arrives, but huge cyan/white meadow (Kenney Nature kit has pastel flat colours), giant yellow glow decals, tents and crates far too large | re-grade Kenney palette by material name (`StyleToon.PALETTE_FIX`), glow decals 0.5 -> 0.12, prop scales down |
| 3 | `iter3_lamp_posts_palette_fix.png` | gallows-like lantern posts, orange dirt smears, pale blocky crates | custom iron lamp posts, dirt desaturated, crates/barrels 1.5 scale, lower golden-hour sun (-30 degrees) for long violet shadows |
| 4 (final) | `after_overview.png`, `after_low_west.png`, `after_from_north.png`, `after_closeup_deck.png` | warm, dense and readable; coloured violet shadows, cobble plaza with moss rim, lamp pools, bunting, stalls with goods, wind-swaying meadow | tuned performance (Medium 62 fps) |

## What the slice contains

- Procedural ground: cobbled plaza (Voronoi stones, three warm/cool tones, dark violet gaps), dirt paths with soft organic edges, moss/grass patches, a flowerbed ring around the well, soil.
- Dressing: 2 market stalls + a pie stall with Kenney Food goods, lantern posts with warm bulbs, real lights (budgeted) and ground glow decals, benches, barrels/crates/sacks, flower pots, a crop garden, fences, a campfire with logs, log stack and stump with mushrooms, bunting between the lamps.
- Wind: foliage (trees, bushes, flowers, grass) sways through the toon shader (`wind_amount`), buildings and rocks do not.
- Ambient: dust motes, falling leaves (GPU particles), 4 birds circling, NPCs with random flourishes (Interact, Use_Item, Cheer, PickUp) and a head-turn toward the hero when close.
- Camera: pitch 53 degrees, FOV 38, offset (0, 11, 8.2), smooth follow.

## Performance (tools/fps.sh, 1600x900, Ryzen 5 4500U iGPU)

Medium 62.5 fps (min 60), Low 120 fps, High 24 fps (High is meant for stronger GPUs: MSAA 2x, full resolution, SSAO, volumetric fog, 12 lights).
