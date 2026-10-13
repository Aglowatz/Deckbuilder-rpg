# Vertical slice: the main town square

The first vertical slice rebuilds the town square to match the approved paint-over (`docs/art/paintovers/PAINTOVER-TOWN.png`, an HD-2D, Octopath-like look, painted).
Everything is built in code from an **Environment Kit**: placeholder textures now (existing TEX-MAT-* / TEX-TOWN-* and a few generated stand-ins), and every slot takes the real
kit art by dropping a file in `assets/art/env_kit/`. Judgment calls are VS-1 ... VS-14 in `docs/design/open_questions.md`. Gameplay, quests, NPC logic and the camera style
are untouched (the camera rig, FOV, pitch and tilt-shift are the approved values).

![paint-over beside the rebuilt square, same angle](vertical_slice/compare_square.jpg)

Left: the paint-over. Right: the rebuilt square from the default camera (the hero at the spawn).

| Other angles | |
|---|---|
| West Market Street (card shop, potion shop opposite the clothier and the smithy) | ![](vertical_slice/vs_market_west.jpg) |
| The Deck Station (the inn) and the south end of the square | ![](vertical_slice/vs_inn.jpg) |
| Gate Road: the cave hut, Elder Maren's house, the Hall of Records, the castle beyond | ![](vertical_slice/vs_gate_road.jpg) |

## What is where

| Part | Code | Data |
|---|---|---|
| **A** modular building kit | `world/kit/building_kit.gd` (walls, foundation band, posts, beams, half-timbering, gable / hip / thatch / spire roofs with real overhangs, eave trim, chimneys, dormers, sockets for doors / windows / awnings / signs / lanterns / ivy / stains / flower boxes, lit glass), `building_presets.gd`, `kit_mesh.gd` | `data/art/building_presets.json` (11 presets: home_a, home_b, cottage, inn, card_shop, potion_shop, equipment_shop, clothing_shop, pack_shop, alchemist, stone_hut, chapel, hall) |
| **B** props and plants | `prop_kit.gd` (barrel, crate, sack, flowerpot, planter, bench, well, lantern post, banner post, stall, cart, fences, hedge, stone wall, signpost, notice board), `prop_clusters.gd` (doorstep, crates, market set, garden bed, bench nook, well corner, fenced garden, banner lamp, barrel pair), `tree_cards.gd` / `kit_foliage.gd` (painted tree cards, flower and grass clumps) | |
| **C** ground and paths | `path_tool.gd` + `kit_path.gdshader` (dirt / cobble along curves, soft edge, DEC-PATHEDGE strips, worn patches, irregular clumps, cobbled plaza) | `TownLayout.road_kinds()` |
| **D** light and atmosphere | `kit_ao.gd`, `kit_pools.gd` (baked-look occlusion pools, light pools), `kit_lights.gd`, per-vertex AO in `kit_mesh.gd`, `world_post.gdshader` (`green_calm`, `red_calm`) | `StylePresets` (TOWN), `data/art/zone_looks.json` |
| **E** the square | `world/town_layout.gd` (shops as kit presets), `town_builder.gd`, `town_square.gd`, `town_streets.gd`, `world/kit/town_kit.gd`, `kit_batch.gd` | |
| Registry | `world/kit/env_kit.gd`, `kit_textures.gd`, `kit_canvas.gd` | `data/art/environment_kit.json` (merged with the sheet by `tools/env_kit_sync.gd`) |

Tools: `tools/kit_bench.tscn` (`bash tools/shot.sh res://tools/kit_bench.tscn name --presets=home_a,inn --props=barrel --clusters=doorstep --trees=oak --hero=0,24`),
`bash tools/import_env_kit.sh` (art import, copy-only), `tools/env_kit_status.gd` (the table below), `tools/side_by_side.gd` (the comparison images),
`bash tools/run_town_slice_smoke.sh` (windowed e2e: 14 spots, prompt / interact / close, plus walking).

## What matches the paint-over

- **Composition from the default camera:** buildings frame both sides of the cobbled square, a lamp-post avenue with banners and lanterns, the fountain (the crest) in the middle,
  the Gate Road opening to the castle, the lake and the far trees. Props are clustered at doorsteps and walls; nothing is scattered on the lanes.
- **Materials and shapes:** half-timbered plaster houses on stone foundations, tiled roofs with overhangs, eave trim, chimneys, shuttered windows with warm glass and flower
  boxes, striped awnings, hanging icon signs, ivy; barrels, crates, sacks, pots, benches, fences, a market stall, a cart, a well; painted tree cards (no cones).
- **Ground:** cobbled square and streets, calm grass, worn dirt tracks with soft edges, flowers in natural clumps along walls and paths (never an even scatter); the old saturated
  moss patches and the mown stripes are gone.
- **Light:** one warm low sun from the east, soft shadows, cool violet shade with warm lantern and window glow on top, occlusion at the foot of walls and under eaves, a gentle
  vignette, loud greens and reds pulled back (`green_calm` 0.4, `red_calm` 0.3).
- **No readable text in the world:** signposts carry the Path crest on arrow boards, the Rift Express and the zone passages carry the crest in their destination colour, the
  closed Alchemist and Arena show a padlock; what the signs said is read in a popup when the hero uses them (signposts) or in the dialogue and the prompt (the others).
- **Scale rule:** the hero (1.25 m) reaches a third of the way up a 3.4 m door; lamp posts 4.2 m, fences 1.1 m, barrels 1.1 m.

## What is still placeholder, by kit ID

`bash tools/import_env_kit.sh` (copy-only from `Approved_EnvKit`) turns a placeholder into the real art with no code change. **All 48 sheet ids are in the Drive's `Approved_EnvKit`
folder now** (it appeared while the slice was being built): a preview with that art is in `vertical_slice/preview_real_art_square.jpg` (not committed to the game; see
"Dropping the real art in"). Until then every id is a placeholder:

| Kit ID | Slot | Lock / size | Now | Placeholder | Used by |
|---|---|---|---|---|---|
| `ENV-WALL-TIMBER` | wall.main | SURFACE 1024x1024 PNG, tileable horizontally | placeholder | tex:mat_plaster | 6 building presets (home_a, home_b, card_shop) |
| `ENV-WALL-TIMBER-WARM` | wall.warm | SURFACE 1024x1024 PNG, tileable horizontally | placeholder | tex:mat_plaster | 8 building presets (home_a, home_b, inn) |
| `ENV-WALL-PLANK` | wall.plank | SURFACE 1024x1024 PNG, tileable horizontally | placeholder | tex:mat_woodplanks | 2 building presets (cottage, equipment_shop) |
| `ENV-WALL-FOUNDATION` | wall.foundation | SURFACE 1024x512 PNG, tileable horizontally | placeholder | tex:mat_stonewall | 13 building presets (home_a, home_b, cottage) |
| `ENV-ROOF-EAVE` | roof.eave | CUTOUT 1536x512 PNG, transparent | placeholder | tex:mat_timber | 13 building presets (home_a, home_b, cottage) |
| `ENV-BEAM` | wall.beam | CUTOUT 1536x512 PNG, transparent | placeholder | tex:mat_timber | 13 building presets (home_a, home_b, cottage) |
| `ENV-AWNING-01` | awning.a | CUTOUT 1536x1024 PNG, transparent | placeholder | gen:stripes_red | 5 building presets (home_b, inn, card_shop) |
| `ENV-AWNING-02` | awning.b | CUTOUT 1536x1024 PNG, transparent | placeholder | gen:stripes_green | 2 building presets (potion_shop, clothing_shop) |
| `ENV-DOOR-01` | door.a | CUTOUT 1024x1536 PNG, transparent | placeholder | tex:mat_woodplanks | 5 building presets (home_a, home_b, cottage) |
| `ENV-DOOR-02` | door.b | CUTOUT 1024x1536 PNG, transparent | placeholder | tex:mat_woodplanks | 4 building presets (inn, card_shop, equipment_shop) |
| `ENV-DOOR-03` | door.c | CUTOUT 1024x1024 PNG, transparent | placeholder | tex:mat_woodplanks | 4 building presets (alchemist, stone_hut, chapel) |
| `ENV-WINDOW-01` | window.a | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:window_cross | 13 building presets (home_a, home_b, cottage) |
| `ENV-WINDOW-02` | window.b | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:window_wide | 7 building presets (home_a, home_b, inn) |
| `ENV-WINDOW-03` | window.c | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:window_dark | 1 building presets (home_a) |
| `ENV-WINDOW-04` | window.d | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:window_round | 6 building presets (home_b, card_shop, potion_shop) |
| `ENV-WINDOW-05` | window.e | CUTOUT 1536x1024 PNG, transparent | placeholder | gen:window_shop | 2 building presets (card_shop, clothing_shop) |
| `ENV-SIGN-CARDS` | sign.cards | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:sign_cards | 1 building presets (card_shop) |
| `ENV-SIGN-POTION` | sign.potion | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:sign_potion | 1 building presets (potion_shop) |
| `ENV-SIGN-SHIELD` | sign.shield | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:sign_shield | 1 building presets (equipment_shop) |
| `ENV-SIGN-NEEDLE` | sign.needle | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:sign_needle | 1 building presets (clothing_shop) |
| `ENV-SIGN-PACK` | sign.pack | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:sign_pack | 1 building presets (pack_shop) |
| `ENV-SIGN-FLASK` | sign.flask | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:sign_flask | 1 building presets (alchemist) |
| `ENV-SIGN-INN` | sign.inn | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:sign_inn | 1 building presets (inn) |
| `ENV-SIGNPOST` | sign.post | CUTOUT 1024x1536 PNG, transparent | placeholder | gen:sign_path | PropKit signpost (Path crest), passage signs, Rift Express sign |
| `ENV-GROUND-DIRTPATH` | ground.dirt | SURFACE 1024x1024 PNG, tileable | placeholder | tex:mat_plaster | PathTool dirt paths (grave road, south road), worn patches |
| `ENV-GROUND-COBBLE` | ground.cobble | SURFACE 1024x1024 PNG, tileable | placeholder | tex:town_stone | PathTool cobble streets and the plaza |
| `ENV-GROUND-GRASS-CALM` | ground.grass | SURFACE 1024x1024 PNG, tileable | placeholder | tex:town_grass | kit bench ground (the town keeps its painted TEX-TOWN-GRASS ground) |
| `DEC-PATHEDGE` | decal.pathedge | CUTOUT 1536x512 PNG, transparent | placeholder | gen:pathedge | PathTool edge strips |
| `DEC-WORNPATCH` | decal.worn | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:wornpatch | doorsteps, bends (PathTool.patch) |
| `DEC-IVY` | decal.ivy | CUTOUT 1024x1536 PNG, transparent | placeholder | gen:ivy | 5 building presets (home_a, cottage, inn), wall sockets (ivy) |
| `DEC-WALLSTAIN` | decal.stain | CUTOUT 1024x1024 PNG, transparent | placeholder | gen:wallstain | wall sockets (stain) |
| `ENV-TREE-OAK` | tree.oak | TREE 1024x1536 PNG, transparent | placeholder | gen:tree_oak | TreeCards / tree fields |
| `ENV-TREE-FRUIT` | tree.fruit | TREE 1024x1536 PNG, transparent | placeholder | gen:tree_fruit | TreeCards / tree fields |
| `ENV-TREE-PINE` | tree.pine | TREE 1024x1536 PNG, transparent | placeholder | gen:tree_pine | TreeCards / tree fields |
| `ENV-TREE-BIRCH` | tree.birch | TREE 1024x1536 PNG, transparent | placeholder | gen:tree_birch | TreeCards / tree fields |
| `ENV-HEDGE` | hedge | SURFACE 1024x1024 PNG, tileable | placeholder | tex:mat_leaves | PropKit hedge, bush |
| `ENV-PROP-BARREL` | prop.barrel | SURFACE 1024x1024 PNG, tileable horizontally | placeholder | tex:mat_woodplanks | PropKit barrel |
| `ENV-PROP-CRATE` | prop.crate | SURFACE 1024x1024 PNG | placeholder | tex:mat_woodplanks | PropKit crate |
| `ENV-PROP-SACK` | prop.sack | SURFACE 1024x1024 PNG, tileable | placeholder | gen:burlap | PropKit sack, stall, cart |
| `ENV-PROP-FENCE` | prop.fence | CUTOUT 1536x512 PNG, transparent | placeholder | tex:mat_woodplanks | PropKit picket fence, bench, planter |
| `ENV-PROP-FENCE-RAIL` | prop.rail | CUTOUT 1536x512 PNG, transparent | placeholder | tex:mat_woodplanks | PropKit rail fence |
| `ENV-PROP-CANVAS` | prop.canvas | SURFACE 1024x1024 PNG, tileable | placeholder | gen:stripes_cream | PropKit cart hood |
| `ENV-PROP-CLOTHGOODS` | prop.cloth | CUTOUT 1536x1024 PNG, transparent | placeholder | gen:stripes_blue | (clothier counter: not built yet) |
| `ENV-PROP-FLOWERPOTS` | prop.pots | CUTOUT 1024x1024 PNG, transparent | placeholder | tex:mat_brick | PropKit flowerpot, building pots and window boxes |
| `ENV-PROP-LANTERN` | prop.lantern | CUTOUT 1024x1024 PNG, transparent | placeholder | tex:mat_metal | (lantern meshes are built; the card is for hung lanterns) |
| `ENV-PROP-WELL` | prop.well | CUTOUT 1024x1536 PNG, transparent | placeholder | tex:mat_stonewall | PropKit well |
| `ENV-PROP-STALL` | prop.stall | CUTOUT 1024x1536 PNG, transparent | placeholder | tex:mat_woodplanks | PropKit stall |
| `ENV-PROP-CART` | prop.cart | CUTOUT 1024x1536 PNG, transparent | placeholder | tex:mat_woodplanks | PropKit cart |
| `ENV-ROOF-TILE-RED` | roof.red |   | placeholder | tex:mat_roof_red | 6 building presets (home_a, home_b, inn) |
| `ENV-ROOF-TILE-BLUE` | roof.blue |   | placeholder | tex:mat_roof_blue | 4 building presets (potion_shop, alchemist, chapel) |
| `ENV-ROOF-THATCH` | roof.thatch |   | placeholder | tex:mat_thatch | 3 building presets (cottage, pack_shop, stone_hut) |

The three roof surfaces are not on the sheet (the sheet's `ENV-ROOF-EAVE` is the fascia only): `ENV-ROOF-TILE-RED`, `ENV-ROOF-TILE-BLUE`, `ENV-ROOF-THATCH` are suggested ids
(see "What else would close the gap") and use TEX-MAT-ROOF-RED / -BLUE / -THATCH now.

## Dropping the real art in

`EnvKit.texture(id)` takes `assets/art/env_kit/<ID>.webp` when it exists, so the import is the whole integration. Looking at the art in the slice before committing it
(`ENV_KIT_ART_DIR=res://_art_inbox/env_kit_preview/` after `bash tools/import_env_kit.sh --out=res://_art_inbox/env_kit_preview/`) shows it drops in cleanly (trees,
cobbles, signs and windows read well) and what the first art pass should adjust:

1. **Wall surfaces already paint the half-timbering**, so the geometry studs and braces double it: set `"timber": "none"` in the presets (or only keep posts and floor beams) and
   re-check the `tile` size (2.4 m shows the pattern about every wall panel).
2. **Doors, windows, awnings and signs are cut-outs with their own frame / bracket**: the kit swaps the geometry for a quad when art exists, but the quad size and aspect
   (doors 2:3, signs 1:1, awnings 3:2) should be set from the sheet's size column rather than the placeholder metres.
3. **Fence, barrel and crate art is one face**: wrap with the sheet's mapping notes (crate: one face per side; barrel: tileable horizontally).
4. Re-run `bash tools/run_town_slice_smoke.sh` and the fps probe after the swap.

## What else would close the gap (suggested sheet rows)

| Suggested ID | Category | Description |
|---|---|---|
| `ENV-ROOF-TILE-RED` | Roof surface | Terracotta-red clay roof tiles in soft overlapping rows with a few mossy tiles, seamless, 1024x1024, tileable both ways (the paint-over's big red roof). |
| `ENV-ROOF-TILE-BLUE` | Roof surface | The same tile pattern in slate blue-grey, for the Alchemist, the chapel and the hall. |
| `ENV-ROOF-THATCH` | Roof surface | Golden thatch with shaggy straw lines and a darker band at the eave, seamless 1024x1024. |
| `ENV-ROOF-RIDGE` | Trim cut-out | A short run of curved ridge cap tiles seen from the side, 1536x512, tileable left-right. |
| `ENV-CHIMNEY-STONE` | Cut-out | A stone chimney stack with a stepped cap and two clay pots, straight-on, 1024x1536 (the paint-over's stone chimney). |
| `ENV-WALL-STONE` | Wall surface | A full fieldstone wall (not only a foundation band) in warm greys and tans, seamless 1024x1024, for the cave hut, the hall and the chapel. |
| `ENV-BANNER-01` / `-02` | Cut-out | A hanging cloth banner with a gold fringe and a Path symbol in red / blue, 768x1536, the lamp-post banners of the paint-over (now flat red cloth). |
| `ENV-PROP-LAMPPOST` | Prop concept | The tall wooden lamp post of the paint-over with its iron lantern bracket, from the low game camera, 1024x1536 (now iron-and-wood built in code). |
| `ENV-PROP-BENCH` | Prop texture | A weathered plank bench seen from the front, 1536x512, transparent (benches use the fence wood now). |
| `ENV-PROP-FLOWERBOX` | Cut-out | A long wooden window box brimming with mixed flowers, 1536x512, transparent. |
| `ENV-PLANT-FLOWERS-01...03` | Cut-out | Three flower clumps (daisies and yellow blooms, lavender, foxgloves) as separate cards, 1024x1024, base at the bottom centre (now the FOL atlas). |
| `ENV-GROUND-CURB` | Ground surface | A strip of cut stone curb and low garden wall, 1536x512, tileable left-right (flowerbeds in the paint-over have stone walls). |
| `ENV-PROP-FOUNTAIN` | Prop concept + surface | The town fountain in warm stone with a worn basin and moss (it is the one bright white, out-of-palette piece left in the square), plus a seamless warm stone surface for the crest plinths. |
| `ENV-PROP-PIER` | Prop concept | The little wooden pier at the end of the street in the paint-over, three-quarter view, 1536x1024, to build the Gate Road's end. |
| `ENV-PROP-BUCKET`, `ENV-PROP-HAYBALE`, `ENV-PROP-WHEELBARROW` | Prop cut-outs | Small dressing pieces for doorsteps and stalls, 1024x1024 each. |
| `ENV-DEC-LIGHTPOOL` | Decal | A soft warm elliptical pool of lantern light with a slightly brighter core, 1024x1024, additive (now a generic soft disc). |

## Performance (Ryzen 5 4500U iGPU, 1600x900, vsync off, `bash tools/fps.sh res://scenes/town.tscn <quality>`)

| Quality | fps (avg ms) | Notes |
|---|---|---|
| Low | 59.7 (16.8) | |
| **Medium** | **55 - 57 (17.5 - 18.1)** | was 59.1 - 60 before the slice; 849 draw calls (from 713), 1,448 objects, 726k primitives |
| High | 18 (55) | the iGPU cannot carry High (as before; not a target) |

**The Medium target of 60 is not quite met (about 3 fps short).** What was done: props, trees, lamp posts and pools are batched (a 1,640 draw-call first version is 849), buildings
cast their shadows from a three-surface proxy, flat details share one surface, the ground tiles no longer dither as "foreground clutter" (a bug that was already there: it cost
about 1 - 2 fps in the town), and the occlusion fader's tests run at about 16 Hz. What would close the rest: merging each building's twelve surfaces by material across the street
(they must stay separate nodes for the dissolve), a smaller number of window glow quads, and fewer chimney emitters.

## Rolling the kit out to the other zones

1. **Buildings**: `BuildingPresets.build(name)` anywhere; a zone only needs a `TownLayout`-like list of (preset, position, yaw) and `TownKit.place_building` for obstacles. The
   Gainlands gym, the Buffet's restaurants and the Dump's shacks are new presets in `building_presets.json` (wall / roof ids per zone, e.g. `ENV-WALL-PLANK` + rust roof).
2. **Props and clusters**: `PropClusters.make(name)` + `TownKit.place_cluster` dress any doorway; `KitPools` / `KitBatch` batch them. New props are one function in `prop_kit.gd`.
3. **Paths**: `PathTool.build(parent, control_points, {kind, width})`: each zone's roads become curves with a soft edge; the zone's ground texture id is the only change.
4. **Trees**: `TownBuilder`'s tree fields and `TreeCards` replace the cone trees in the starting forest and the zones (the forest is the first candidate: it is where the sheet says
   `ENV-TREE-PINE` replaces the cones).
5. **Grade and light**: `green_calm` / `red_calm` and the sun yaw are per-area data in `zone_looks.json` / `StylePresets`; set them per zone from the paint-over of that zone
   (`PAINTOVER-GAINLANDS.png` is the next).
6. **Order that makes sense**: Starting forest (trees, paths), Gainlands (the second paint-over), then the Capital's facades, then the Buffet and the Dump.
