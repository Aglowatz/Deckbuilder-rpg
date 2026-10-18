# Gainlands improvement pass v2

Visual target: `docs/art/paintovers/gainlands_v2_reference.png` (rocky sandstone mesas, cliffs and canyons with water below, stone roads, sparse dry scrub, the fortress on a raised mesa with stairs, gym props everywhere). Builds on the Gainlands slice (`gainlands_slice.md`), the corrective pass (`gainlands_corrections.md`) and the sub-area removal (SR-1..8). Judgment calls are logged below as GL2-01, GL2-02...

Rules for the whole pass: one Godot process at a time, at most 10-12 shots per part at 1280x720, GUT + walkability after every part, storybook scale (hero 1.7 m, door 1.95 m, storey about 2.5 m), no readable text in the world, 60 fps on Medium, routes at least four hero-widths wide, no new explorable sub-areas, dungeons node-based.

## Part A: audit

### Before shots

`bash tools/gl2_shots.sh before` (one Godot at a time, `--nohud`, 1280x720) writes the seven fixed views; JPEGs in `docs/art/gainlands_v2/before/`:

| View | Camera | File |
|---|---|---|
| Entrance | `--at=spawn` (on the bridge) | `gl2_before_01_entrance.jpg` |
| Centre | `--at=hub` | `gl2_before_02_center.jpg` |
| Left (west) | `--pos=24,44` | `gl2_before_03_left.jpg` |
| Right (east) | `--pos=80,48` | `gl2_before_04_right.jpg` |
| Fortress | `--pos=50,16` | `gl2_before_05_fortress.jpg` |
| Swolympus view | `--pos=84,36` | `gl2_before_06_swolympus.jpg` |
| Top-down plan | `--top=52,46,110 --plan=true` | `gl2_before_07_plan.jpg` |

What they show: a green, flat, round meadow floating in a blue sea, trees everywhere (74 on the main land), the House of Gains as a flat red wall straight behind the hub, a round Swole Station platform in the middle of the plaza that the hero cannot walk through, the Rift Station (portal) and stalls crowding the arrival, windmills smaller than the hamster wheels, Mount Swolympus a cone of cobbles next to the locked trailhead gate. Nothing reads as sandstone, cliffs or canyons; the three ways out of the plaza are dirt smudges.

### fps baseline (Medium, `bash tools/fps.sh res://scenes/gainlands_zone.tscn 1`)

| Spot | avg fps | min fps | GPU ms | draw calls | primitives |
|---|---|---|---|---|---|
| spawn (bridge) | 60.0 | 46.9 | 11.3 | 520 | 190 k |
| hub | 59.8 | 39.1 | 13.0 | 846 | 235 k |
| fortress road (50, 16) | 59.9 | 36.5 | 10.9 | 200 | 75 k |

The hub is the heaviest view (13 ms GPU of 16.7): whatever the pass adds there must be batched.

### Walkable layout now

- Main land: one wobbly ellipse (`GainlandsLayout.CENTER` 52,46, `RADII` 44 x 34), rolling hills between -0.22 and about +1.6 m, **4705 m²** of main ground (counted per square metre). The sea plane (`WorldScenery.WATER_Y` -0.36) sits 0.14 m under the lowest meadow, so the land reads as a flat island, not a plateau.
- Way in: the rope bridge from the south rim (x 52, z 76.5 - 97), arrival at its far end facing north.
- Hub plaza: 8.5 m open circle round (52, 64) with the Swole Station platform just north of it (52, 53.5), the hot tub, mirror, vendor, protein stand and Rift Station round its rim.
- Routes (8 polylines): west road to the quiz and the west thrower, east road to the wheels and the east thrower, the dungeon road north from the plaza's north-east corner to the causeway of the House of Gains (50, 7 - 13.5), two spurs to the north throwers, the gym spur south-east. All dirt colour on grass, no edging, no lamps.
- Enemies: six roamers (2 brutes, 2 golems, 2 sprites) wandering the fields, none on the dungeon road: the fortress can be reached without a fight.
- Islands: Pec Perch, Delt Deck, Glute Garden, Calf Cove (throw or portal only), 13 chests (6 on the main land).

### Props: current size vs intended size

Measured from the built meshes (`res://tools/gainlands_inventory.tscn`, world-space bounds, hero 1.7 m). "Intended" follows Art Bible G-01 (storybook: props slightly oversized, a storey about 1.5 heroes).

| Prop | Count | Now (w x h x d m) | Intended | Verdict |
|---|---|---|---|---|
| Windmill (KayKit at 2.8-3.4x) | 3 | 3.7-4.7 x 4.1-5.0 x 3.2-4.3 | 4-5 storeys: 11-13 m to the cap, sails about 12 m across | **far too small** (2.6 heroes, lower than the hamster wheels) |
| Hamster wheels | 3 | 6.3-8.9 tall | 7-9 m (Beefcake machinery) | ok |
| Hero Wheel (GAIN-HERO-WHEEL) | 1 | 13 x 8.3 x 12 | 9-10 m | ok |
| Swole Station platform | 1 | 11.1 x 6.1 x 8.3 | removed (Part C) | blocks the plaza middle |
| Market stalls | 2 | 3.4-3.8 x 2.5-2.8 x 2.5-2.8 | 3.4 x 3.0 x 2.6 (counter 1.0, awning at 2.4-2.8) | slightly low |
| Bench press | 2 | 3.8 x 2.2 x 1.5 | 2.4 x 1.4 x 1.4 (bar at 1.1 m) | **too big** (a bar 3.8 m wide) |
| Lying barbell | 1 | 3.7 x 0.9 x 1.1 | 2.4 m bar, 0.6 m plates | **too big** |
| Dumbbell rack | 1 | 0.9 x 1.3 x 3.1 | 2.2 x 1.0 x 0.8 | long but ok |
| Log rack | 2 | 3.2 x 2.8 x 1.0 | 2.6 x 2.0 x 1.0 | slightly tall |
| Kettlebell (card or proc) | 5 | 0.6 x 0.9 x 0.6 | 0.45 m tall (knee) | **too big** (hip-high kettlebells) |
| Plate stack | 3 | 1.3 x 1.0 x 1.3 | 0.6 m plates, 0.7 m stack | **too big** |
| Tyre pile | 2 | 1.4 x 0.7 x 1.5 | 1.5 m tractor tyres | ok |
| Punching bag | 1 | 1.3 x 2.4 x 1.0 | 2.4 m | ok |
| Pennant pole | 4 | 1.1 x 3.4 x 1.1 | 3.5-4 m, banner below a top bar | ok size, wrong form (streams sideways) |
| Sign boards | 9 | 1.0-1.3 x 1.8-2.1 | 1.8-2.2 | ok |
| Hidden chests | 13 | 0.5 x 0.3 x 0.4 | 0.9 x 0.6 x 0.6 (hip) | small on purpose ("quarter size", hidden) - kept, GL2-03 |
| Crystals (islands) | 4 | 0.8 x 2.2 x 0.8 | ok | ok |
| Flex mirror | 2 | 0.9 x 3.2 x 2.7 | 2.4-2.8 tall | slightly tall, ok |
| Hot tub | 1 | 4.5 x 1.3 x 3.6 | ok | ok |
| Studio stage | 1 | 6.3 x 4.1 x 5.8 | ok | ok |
| Iron Cavern mouth (KayKit mountain at 3.4x + mouth) | 1 | rock 6.1 x 4.8, mouth 4.7 x 4.3 | a cliff face 10 m+ with a 5 m mouth | **too small** (a rock, not a cliff) |
| Bridge lamps (globes on the rails) | 12 | 0.35 globes at 1.2-1.6 m | lamp posts 2.6-3 m along roads | no lamps on the roads at all |
| Energy pipes | 4 lines | 0.4 m pipes at knee height | (keep, smaller role) | read as fallen striped poles |
| Power lines | 0 | none in the zone | tall pylons (14-16 m) with sagging cables | **missing**: built new in Part D, GL2-02 |

### Banners and their animation

| Banner | Where | Built by | Moves? |
|---|---|---|---|
| Kit banner cards (GAIN-SHEET-BANNERS-01..06) on the fortress, gatehouse, Wheel posts, Champions Arch, trailhead gate, Swolympus stair, Station posts, bridge gate and far landing | landmarks | `GainlandsLandmarks._card` into each model's one KitMesh | no (part of a rigid body mesh) |
| Pennants (swallow-tail, streaming sideways) | 4 round the hub rim | `GainlandsDressing._pennant` | no (`no_wind`, since GC-7) |
| Kit `banner_post` (two hanging banners) | Crosspath streets, banner clusters | `PropKit` "banner_post" | **yes**: toon wind `wind_amount` from the name "banner", displacement = local height squared, so the TOP of a hanging banner swings most and the bottom stays still; it moves along world x and z regardless of the banner's facing (folds through its own pole), phase from world position only |
| Ruler banners (zone ruler's colour) | every unfreed zone hub | `RulerPresence._banner` | yes, same shader path |
| Capital `sun_banner`s, D.N.A. `_banner`s | other zones | their landmark builders | rigid mesh, no |

The shared fix (Part E) goes into the toon shader's wind for cloth: a banner hangs from its top bar.

### Vegetation now

| Kind | Count |
|---|---|
| Trees on the main land (KitFoliage oak/pine cards) | 74 (+ 4 on islands) |
| Boulders (KayKit rocks) | 16 |
| Sunflower cards (dressing) | 8 per quality step |
| Kit clusters with plants (hay stack, sunflower fence, mill yard) | 3 of 7 |
| Grass / flower field (WorldFoliage, green) | the whole meadow |

## Plan

### Layout (top-down, x east, z south, metres; not to exact scale)

```
 z
-30          Sky Tree islet (view)                 .  .  MOUNT SWOLYMPUS (view, NE)
-20   Pec Perch            [ HOUSE OF GAINS ]                /^^^^^^^^\
-10   (island)             [   fortress     ]               /  summit  \
  0                     ###### MESA ######             ...broken span  |
  4                     #   gate (main)  #           ridge/land bridge |
 12                     ######-STAIRS-#####        ======              
 16   ^^^^ IRON CAVE ^^^^  |  FORECOURT  |  bridge  OVERLOOK  <- swolympus gate
 24   ^ cliff (cave mouth) =bridge=[F]=bridge=  R north   (view east/north-east)
 28   L north: arch,     ~~~~|   G3   |~~~~   R: puzzle, colossal wheel
 34   shrine, thrower    ~~~~|        |~~~~   gus, ripper (Delt)
 40   L: mills (tall),   ~ C |   G2   | C ~   R: mini gyms, Gary,
 48   Hero Wheel, quiz   ~ A |        | A ~   thrower east (Glute)
 52   thrower west       ~ N |   G1   | N ~   R: market street: stalls,
 56   mini gym yards     ~~~~|  MID   |~~~~   protein stand, studio stage
 60    \__ LEFT PATH ___  [ GYM HALL ]  ___ RIGHT PATH __/  mini gyms
 70   Shiro chest  rift portal   PLAZA   vendor/tub  (edges)
 80                  mirror  [ hub ]  mini gym (right of entrance)
 86                    pillar  GATEWAY  pillar
 90-108                   = = bridge = =   (to town, over the sea)
```

`G1..G3` = encounter guards standing in the middle road (forced fights), `CANYON` = drops to the water (not walkable), `=` = stone bridges.

### The land

- One plateau of sandstone **about 4 m above the sea** (so canyons and the outer cliffs drop to water, as in the reference), built as several flat-topped land polygons that meet edge to edge: the plaza, the middle ridge, the forecourt, the left lands, the right lands; the **fortress mesa** is a fifth polygon 3.5 m higher, reached by wide stairs. Canyons are the gaps between them; stone bridges (layout rects) cross them. Target: **6600-7000 m²** walkable (+40-50 % on 4705).
- Walkability is a raster of the land union (0.5 m cells with a distance-to-edge field), so the polygons can touch and holes (the canyons) cost nothing; the hero stops 0.35 m from any drop and at the foot of the mesa except on the stairs.
- Ground: sandy chalk dirt with patches of dry grass (painted layers), stone paving on every route with stone edging, sandstone strata on every cliff face (triplanar `gain_islandrock`), rock shelves and outcrops along the edges, waterfalls into the canyons and over the outer rim. Background sandstone mesas stand in the sea and the canyons (views, not walkable). The floating islands stay in the sky.

### The three paths

| Path | Route | Fights | Landmarks and loot |
|---|---|---|---|
| **Middle** (direct) | plaza (behind the gym hall) -> ridge road north -> forecourt -> stairs -> fortress gate | 3 guard groups standing in the road at the ridge's rocky narrows (the canyon on both sides: no way round); about 10 m apart, a guard's challenge circle spans the whole width | the House of Gains straight ahead all the way; lamps and banner posts every 8-10 m |
| **Left** (long) | plaza west -> mill lands (tall windmills, the Hero Wheel, quiz) -> Iron Cave cliff in the north-west -> east along the north rim (Champions Arch, shrine) -> stone bridge over the west canyon -> forecourt | 1-2 optional roamers off the road | Iron Cave entrance (cave mouth in a cliff face, squat racks, leg press, worn steps), mini gym yards, 2 chests in side pockets, the west thrower |
| **Right** (long) | plaza east -> market street (stalls, protein stand, the studio stage, mini gyms) -> wheel works (colossal wheel, power grid, Gus) -> the Swolympus overlook in the north-east -> west along the north rim -> stone bridge over the east canyon -> forecourt | 1-2 optional roamers | Benchley's stalls, Gary's lifting yard, the overlook with the ridge to Mount Swolympus ending at a collapsed span, 2 chests, the east thrower and the Delt ripper |

### Where each landmark goes

| Landmark | Place |
|---|---|
| Entrance | the rope bridge from town arrives at a stone gateway (two pillars with gold orbs and hanging banners) on the south rim; a wide open plaza behind it; vendor and tub on the plaza's east edge, the Rift Station portal and the mirror on its west edge |
| Gym hall (replaces the round Swole Station platform) | the plaza's north half, about 13 x 9 m, open front facing the plaza with racks of dumbbells, barbells and plates inside, a dumbbell emblem over the door, fully solid; the lanes round its two sides lead to the middle road (behind it) and the left and right paths |
| House of Gains | centred on the far side of the mesa, its gate at the head of the stairs; seen down the middle road from the plaza |
| Iron Cave | the left path's north-west cliff face |
| Mount Swolympus | a view to the north-east beyond the right overlook: a rocky ridge (land bridge) runs out from the overlook toward it and ends at a collapsed span; the locked gate stands at the ridge's start |
| Hero Wheel, windmills (tall), quiz, Champions Arch, shrine, west thrower | left lands |
| Market stalls, protein stand, studio stage, Gary, colossal wheel, power grid, Gus, east thrower, Delt ripper | right lands |
| Power lines | two lines of tall pylons with sagging cables: one along the left lands and over the west canyon to the fortress mesa, one along the right lands and over the east canyon |

## Judgment calls

- **GL2-01** The existing "Iron Cavern" was the door to Mount Swolympus (S-BEEF, postgame). The brief's Iron Cave is a different, early leg-day side dungeon: it becomes a new dungeon S-IRON (the zone's side dungeon, open from the start) and S-BEEF stays in the data as the postgame bonus behind the locked gate (Part F).
- **GL2-02** The brief says "keep the large power lines", but the Gainlands had none (only knee-high energy pipes). They are built new in Part D; the pipes stay as the powered-grid feature of the puzzle, shortened to the wheel works.
- **GL2-03** The hidden chests stay quarter-size: their smallness is the "hidden" part of the design (`test_the_hidden_chests_are_at_least_six_quarter_size...`).

## Part B: bigger, rugged terrain and three paths (done)

- **Land as data** (`GainlandsLayout`): three land polygons that meet edge to edge (`SOUTH`: plaza, left lands, middle ridge, right lands; `FORECOURT`; `MESA`, 3.6 m higher), the canyons are the gaps, two stone `SPANS` cross them, the `STAIRS` (12 m wide) climb the mesa. The plateau is `PLATEAU_Y` 4 m over the sea. Walkable land **7212 m2** (+53 % on 4705; mesa 672 m2).
- **Walkability** reads the polygons (`level_at`) and a 0.5 m distance-to-edge raster (`main_edge_distance`, built once): the hero stops 0.35 m from any drop and at the mesa's foot; the stairs' cheek walls block their sides.
- **Meshes** (`GainlandsTerrain`): flat tops on a 1 m grid with the edge cells clipped to the polygon (the mesh edge is the walkable edge), ragged five-layer cliff walls with sandstone strata to below the waterline, terraced rock columns (ten background mesas in the sea, the Iron Cave's cliff, the fortress rock), cut-stone stairs and spans. Six waterfalls (`GainlandsWater`, a scrolling shader strip, foam and mist) pour over the rims and into both canyons.
- **Ground** (painted preset `gainlands`): chalk-dirt sand, stone paving on the routes, the plaza, the forecourt and the mesa top, dry-grass scrub patches thicker at the rims, gym mat in the lifting yard, hay under the mills, triplanar sandstone on every steep face; the floating islands keep green tops (preset variant `islands`). The generic zone dressing is dry scrub and loose stones (no flowers), the world foliage has a new opt-in `dry` mix (straw, Gainlands only).
- **Routes** (`GainlandsRoads`): stone kerbs along both edges of every paved route (one MultiMesh, 900+ stones), lamp posts and banner posts every 9 m on alternate sides of the three roads (KitBatch-merged).
- **Three paths**: MIDDLE plaza -> ridge -> forecourt -> stairs -> gate (the ridge has three rocky narrows where its guards will stand, Part G); LEFT plaza -> mill lands -> Iron Cave spur -> north rim -> west span -> forecourt; RIGHT plaza -> market row -> wheel works -> Swolympus overlook -> north rim -> east span -> forecourt.
- **fps** (Medium, 14 s probes): hub 60.0, ridge 59.3 (p95 16.67 ms, GPU 12.3-12.7 ms); one load hitch about 3 s in (the painted splat), steady state 60.

### Judgment calls (Part B)

- **GL2-04** The area grew 53 %, a little over the brief's 40-50 %: the right lands need room for the market row, the wheel works and the overlook, and trimming the east rim would crowd the throwers' landings.
- **GL2-05** The old cloud layer under the meadow is gone: with the plateau 4 m over the sea it sat under the water plane (34 clouds drawn for nothing).
- **GL2-06** The gym hall fills the plaza's north half (Part C), so the middle road's head sits behind it; it reads by the lane round each side, the lamp posts and the fortress straight above. The left and right heads are in clear view from the gateway.
- **GL2-07** The fortress keeps its model and size class (40 x 34 x 26 m now, was 48 wide) so it sits on its rock behind a 32 m wide mesa; its causeway is off (`causeway: false`).

## Part C: entrance and centre (done)

- **Gateway** (`GainlandsPlaza.gateway`): the rope bridge arrives at two dressed sandstone pillars with gold orbs, iron arms with hanging kit banners, torches and a low parapet off each side along the rim; the bridge's own timber gate is gone (`rope_bridge(..., near_gate = false)`; the town side keeps its gate).
- **Plaza**: an open paved square round the hub; Benchley's stall and the hot tub on its east edge, the Rift Station portal, the mirror and the hermit on its west edge, the ruler's statue and banners in the south corners beside the gateway (`statue_offset`, `banner_offsets` in `GainlandsZone`). No pennants, sunflowers or loose weights on the square (the dressing's gym kit starts beyond it).
- **Gym hall** (`GainlandsPlaza.gym_hall`, STANDIN for a painted concept): replaces the round Swole Station platform. 13 x 8.5 m, brick side and back walls with lit windows, an open front of four cream-stone pillars with half-height parapets between the outer pairs, a red gable roof (ridge about 8 m), a gold dumbbell emblem in the gable, kit banners on the outer pillars; inside, in view: a two-tier dumbbell rack, a barbell rack, plate trees, a squat rack with a loaded bar and a bench on a rubber floor. The layout's `GYM_HALL` rectangle is solid (`GainlandsBuilder.add_rect_blocker`); lanes go round both sides and behind it.
- Cliff walls meet at the polygons' corners with mitred normals (no more slivers of sky at the corners).
- Tests: `tests/world/test_gainlands_v2.gd` (gateway, hall solid with open lanes, emblem and no lettering, the platform gone, clear lines from the gateway to the three path heads).

### Judgment calls (Part C)

- **GL2-08** The ruler's statue and banners (oppressed state) moved from the hub's default offsets, which now fall on the open square, to the plaza's south corners beside the gateway: the first thing the arriving hero passes.
- **GL2-09** "Clear sightline to the path heads": the left and right heads and both lanes round the gym hall are in a clear line from the gateway; the middle road itself starts behind the hall (GL2-06), marked by its lamp posts and the fortress above.

## Part D: props, scale and gym-first decoration (done)

- **Scale fixes** (the Part A audit): the three windmills are four-storey tower mills now (`GainlandsStructures.windmill`, STANDIN: sandstone ground storey, brick and plaster above, a gallery, a red cap, lattice sails 11 m across, about 13.9 m to the cap; the KayKit mill was 4.4 m); `GainlandsBuilder.SCALE_FIX` shrinks the bench press (0.62), the lying barbell (0.68), the log rack (0.75) and the dumbbell rack (0.75) and grows the stalls (1.12); kettlebells are knee-high (0.45 m, were 0.9 m) and the plate stacks 0.62x. Lamps (4.2 m posts) and the wheels were already right.
- **Gym equipment is the decoration** (`GainlandsGym`, layout `yards`): seven lifting yards on their own rubber mats at path edges and in side pockets, none on the middle road and none in the plaza (the gym hall is the plaza's gym): west strongman (by Shiro's giant chest), west rig, west lifting, east strongman, east lifting, east rig and Gary's yard right of the entrance. Pieces: squat racks with loaded bars, benches, two-tier dumbbell racks, kettlebell racks, atlas stones on plinths, tyre piles, a sled track with its sled, pull-up frames, rope stations, plate stacks, chalk buckets (and a leg press for the Iron Cave, Part F). Each yard is one mesh; every piece is a solid "gym:<kind>" prop in the layout, so the walkability probe sees it.
- **Trees cut to a few hardy ones**: 16 on the plateau (was 74): wind-bent dry-land trees leaning with the zone's wind and cypress accents (`GainlandsStructures.windbent_mesh`, `cypress_mesh`, two MultiMesh fields), only near the rims; no flowers or mushrooms anywhere (the generic scatter is dry scrub and stones).
- **Power lines** (new, GL2-02): three lines of 16 m lattice towers with three sagging cables per span (catenaries, sag 5.5 % of the span): down the west rim to the Iron Cave's cliff and the left canyon's mouth, down the east rim past the overlook to the right canyon's mouth, and one across the whole zone from the west sea over both canyons (towers on canyon stacks) and the middle road to the east sea. Every tower stands on a sandstone stack off the walkable land (or on the cave's cliff), so none blocks a route.
- **fps** (Medium, 10-12 s): hub 60.0, ridge mouth 60.0, forecourt 59.9, left lands 59.9, market row 60.0, overlook 59.3.
- `GAIN_HIDE=<name,...>` hides root pieces by name for fps hunting (like HEAP_HIDE).

### Judgment calls (Part D)

- **GL2-10** Gary's yard keeps its equipment within 3-4 m of Gary's spot: Gary is "currently under a barbell", the yard is his. Every other anchor keeps 5.5 m.
- **GL2-11** The legacy return points of the removed Gainlands sub-areas (old saves) land in the plaza and at the overlook now (the old point stood where a tower mill is).
- **GL2-12** fps probes on the middle road must stand outside the guards' reach: a probe 2.5 m from a guard measured the battle screen (54 fps). Measured spots: the ridge mouth and the forecourt.

## Part E: banners (done)

- **What was wrong**: the only banners that moved were the ruler banners (every unfreed zone) and anything else named like cloth, and they moved with the foliage sway: displacement by the square of the *local height*, so the top of a hanging banner swung most and its bottom stayed still, in world x and z whatever the banner's facing (shearing through its own pole), and the pole bent too (it sat under a node named "banners").
- **The fix, shared** (`assets/shaders/style_toon.gdshader`, `style_toon_double.gdshader`): a hang mode for cloth. Per instance (`hang` = the cloth's normal and length, `hang_top_phase` = its top edge and a phase), set by `StyleToon.apply_mesh` for every mesh whose name says banner / flag / cloth / pennant / bunting (`StyleToon.is_cloth`, `hang_params`: the normal is the mesh's thinnest horizontal axis, the top and length its bounds; meta `hang` / `hang_normal` override). The offset is along the cloth's normal only, zero at the top edge, growing with the square of the distance down the cloth, at most 3.5 % of its length, leaning with one zone-wide wind direction (`STYLE_WIND_DIR`) and a slow gust with a phase per banner (from the banner's own node, so its cloth, stripe and emblem move as one and two banners never move in step).
- **Banners updated**: the ruler banner (`RulerPresence`): its pole is named rigid, its cloth and stripe hang from the bar, its emblem uses `world/style/style_cloth_icon.gdshader` (unshaded, the same hang offset) so it never parts from the cloth; the freed bunting stays still. The kit banner post (`PropKit` "banner_post", Crosspath streets, banner clusters, the Gainlands roads): its banner is its own mesh ("BannerCloth") hung from the bar, the post rigid. Kit banner cards painted into landmark meshes (the fortress, the gateway, the gym hall) hang still, as before.
- Rigid words gained "stack" and "bale" (the hay-stack cluster used to bend from its foot).
- Checked: the Gainlands, Crosspath, the Capital and the D.N.A. render as before; `tests/world/test_banner_hang.gd` (the offset's properties, cloth detection, rigid poles, the emblem, the kit post) and the Crosspath cleanup test (banner cloth is the one swaying thing allowed besides plants).
- Dressing: the loose kettlebells, plate stacks and tyres now lie round the lifting yards' edges (never on the paving or the bridge); Gary's two old kit clusters and the catapult pit went (his yard is built from `GainlandsGym`).

### Judgment calls (Part E)

- **GL2-13** Banner cards painted into a landmark's single mesh (fortress, gateway, gym hall, wheel posts) stay still: splitting every card out of its landmark costs draw calls for little; the cloth that moves is the separate banners (ruler banners, the kit banner posts along every road).

## Part F: dungeons (done)

- **The Iron Cave (S-IRON)**, a new leg-day side dungeon, available from the start (GL2-01, design gaps GL2-F1 in `docs/design/open_questions.md`): a hand-made entry beside the Path-ology Lab in `data/dungeons/postgame_dungeons.json` (`open`: no unlocking quest; `zone_side`: the Gainlands' side-dungeon door opens it, `DungeonCatalog.side_for_zone`), three nodes (The Calf Raise Crawl, The Squat Rack Gallery, the boss at The Leg Press Throne: Baron Quadzilla), early-game foes (11-16 HP, 24-25 card decks), the rule "Never Skip Leg Day: Beefcake units get +0/+1", first clear The Ultimate Cardio Machine (B-31, now kept out of packs), repeats small gold and a Beefcake Pack, boss lines before and after. It borrows the Swolympus map (`MapArt.STANDIN_MAPS`), battleboard and the House of Gains music until it has its own.
- **Its entrance** on the left road's cave spur (`GainlandsCave.mouth`, STANDIN): a dark arched mouth 5 m wide in the north-west cliff, rough rock frame, timber props and a studded iron lintel, a big iron dumbbell over it (the leg-day emblem, no lettering), worn stone steps down into the dark, torches; the leg-day kit round it (two squat racks, a leg press machine, plates, chalk) is the "cave" lifting yard; the side-dungeon marker is on the minimap; E opens the side-dungeon dialog (ZoneScene's flow).
- **Mount Swolympus (S-BEEF)** stays the end-game climb: seen from the right road's overlook rising beyond the sealed gate, a rock ridge with a paved causeway, parapet stubs and lamp posts runs from the overlook toward it and ends at a collapsed span (a broken arch over a chasm, fallen blocks in the water) before the far spine reaches its foot (`GainlandsCave.swolympus_ridge`). The gate carries a padlock board; its prompt and toast say "sealed" (no "coming soon" anywhere). The unlock condition is an open question (GL2-F2).
- Delt Deck moved west a little (it hid the ridge from the overlook); one pylon stack moved east for the same reason.

## Part G: enemies on the middle road (done)

- **Road guards** (`ZoneEnemy.make_guard`, spawn keys `guard` and `escorts`, any zone can use them): a guard holds its ground in the road (no patrol, no chase), shows its "!" as the hero nears and starts the battle once the hero steps inside its challenge circle (`GainlandsLayout.GUARD_RADIUS` 3.6 m, centre to centre); its training partners stand either side of it a step behind and leave with it.
- **The middle road**: three guard groups at the ridge's rocky narrows (6.4-6.8 m wide between the canyon edges, so each circle spans the whole road): a Flexing Brute with two partners at z 47, a Protein Shake Golem with one at z 37.5, a Brute with two at z 28; 9.5 m apart, the gym-hall plaza (hot tub, mirror) behind them for a heal before the run (zone HP does not heal between battles).
- **The side roads** keep 1-2 optional roamers each (left: a golem by the mill lands, a sprite by the Champions Arch; right: a brute by the east rig, a sprite below the overlook), placed off the paving so their reach can be walked round.
- **Tests** (`tests/world/test_gainlands_v2.gd`): 3-4 guard groups in the middle road, spaced 8 m and more, battles not hits; a flood along the ridge reaches the forecourt without the guards and cannot with them; with both side spans closed the fortress cannot be reached without a fight; the left road (east span closed) and the right road (west span closed) both reach the fortress, the Iron Cave and the Swolympus gate while avoiding every guard and the roamers' reach; a guard leaves a hero outside its circle alone and challenges one inside it.
