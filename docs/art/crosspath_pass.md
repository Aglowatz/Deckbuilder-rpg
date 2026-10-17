# Crosspath pass (Oct 17)

The graphics and staging pass for Crosspath, the main town, and the whole hub zone round it. Parts A-E of the brief; decisions are CP-1... in
`docs/design/open_questions.md`. Rules followed: `docs/art/art_bible.md` (storybook scale, no readable world text, characters clearest) and
`docs/art/zone_rollout_playbook.md` (declutter rules, routes four hero widths, clusters not scatter, 60 fps on Medium).

Screenshots: `bash tools/crosspath_shots.sh <phase>` shoots the same spots every time into `docs/art/crosspath_pass/<phase>/` (default camera =
Cinematic / Normal, overview = Overview / Far), plus `plan.jpg` (top-down: green = where the hero can stand, red = solid circles, yellow = anchors) and
`top.jpg` (the same view without the overlay). The top-down view is `tools/shot.sh res://scenes/town.tscn <name> --top=<x>,<z>,<size> [--plan=true]`
(`PlanView`). Object positions come from `res://tools/crosspath_inventory.tscn` (headless). What sways: `--windlog=true` on a town shot.

## Part A: the audit

Coordinates are world metres (x east, z south; the camera looks north). Before shots: `docs/art/crosspath_pass/before/`.

### 1. Old and off-style objects

| Object | Where (x, z) | What is wrong | Decision |
|---|---|---|---|
| Woodcutter's cottage (KayKit `home_A`) | -18.0, 6.2 | a hut at a third of storybook scale, blue toy roof | **remove** |
| Forester's cottage (KayKit `home_B`) | -12.6, 21.8 | same | **remove** |
| Hamlet well (KayKit `well`) | -10.8, 24.9 | toy well, second well in town | **remove** |
| Lookout tower (KayKit `tower_A`) | 9.0, -9.4 | blue toy tower, no purpose | **remove** |
| Shepherd's cottage (KayKit `home_A`) | 23.4, -9.4 | toy hut behind the gate road | **remove** |
| Fisher's cottage (KayKit `home_B`) | 57.6, 0.0 | toy hut | **replace** with a kit cottage by the lake (a fisher's cottage with a net rack at the north shore) |
| Harbor bakery (KayKit `market`) | 50.4, 6.2 | toy stall-house | **remove** (the town square has the shops) |
| Net shed (KayKit `lumbermill`) | 54.0, 18.7 | toy mill on the lake's edge | **replace** with a kit shed by the lake, beside the dock |
| Flats barn (KayKit `lumbermill`) | 16.2, 40.5 | toy mill in the middle of a field | **replace** with a kit farmhouse and garden at the south-west field's edge |
| Farmhouse (KayKit `home_B`) | 7.2, 49.9 | toy hut in the field | **remove** (the kit farmhouse above takes its place) |
| Gatekeeper's cottage (KayKit `home_A`) | 41.4, 53.0 | toy hut in the meadow | **remove** |
| Archery range (KayKit `archeryrange`) | 41.4, 46.8 | toy deck in the meadow | **remove** |
| Wayside cottage (KayKit `home_B`) | 37.8, 59.2 | toy hut by the meadow road | **replace** with a kit cottage and fenced garden by the meadow road |
| Watch shed (KayKit `barracks`) | 43.2, 37.4 | toy castle block | **remove** |
| Greengrocer's stall (Kenney tent + crate + cabbages) | 0.0, 6.2 | camping tent on the west street | **remove** (the square has the market) |
| Baker's stall (Kenney tent + crate + loaves) | 41.4, 3.1 | camping tent behind the east row | **remove** |
| Codex-side well (KayKit `well`) | 45.0, 3.1 | third toy well | **remove** |
| Back-alley smithy (kit `equipment_shop`) | 39.6, 25.6 | a second smithy crammed behind the east row, parts of the two roofs poke through each other | **rework**: the secret dealer moves to a dim alley off the square (Part C); the building goes |
| Dev shrine (KayKit `tower_B`) | 46.8, 43.6 | toy tower (debug builds only) | keep (debug only), moved off the lake shore with the layout |
| KayKit rocks on `R` cells | 1.3,-15.8; 48.2,-15.6; 52.3,-3.6; 53.7,-0.7; -20.5,15.1 | blocky low-poly rocks | **remove** (the boundary ridges and the shore stones are kit rock now) |
| The Restless Cairn (two tinted KayKit rocks), grave markers (KayKit rocks), dead trees (`tree_single_A_cut`) | -10.8, 31.2 | low-poly blocks | **rework** into the scene: a graveyard hollow behind a field wall; cairn and markers kept as story objects but rebuilt from kit stone (no rule change) |
| Old lever (KayKit `ladder`) | 5.7, 53.2 | a ladder standing in a field | **rework**: a lever post in a stone base at the field's edge (same spot, same story) |
| Hex water tiles (KayKit `hex_water`, 1206 of them) | the whole map rim | still built under the painted ground in the hub (never seen, cost draw calls) | **remove** in the hub |
| Fountain (plain cylinders and flat colours) | 25.2, 12.5 | primitive shapes | **rework**: a bigger kit-stone fountain in the bigger square (Part C) |
| Royal crest plinths (cylinders and spheres) | ring round the fountain | primitive shapes | keep the idea, rebuilt in kit stone round the new fountain |
| Pantry door (two flat boxes in a free-standing frame) | 72.0, 12.5 | a slab in a field, reads as a placeholder | **rework** (Part D): an enormous carved door with iron hinges and a big lock, built into the orchard wall |
| Thorn wall (seven cards) | -21.6, 12.5 | a thin screen with open woods both sides | **rework** (Part D): dense thorn woods on both sides |
| Permit barrier and booth | -19.8, 34.3 | fine as a model, open field both sides | stone wall and fence line beside it (Part D) |
| Gorge bridge posts | 25.2, 71 | fine; the gorge walls are flat quads | keep; the gorge lip gets rocks and the lake pours into it (Part D) |

### 2. Things that move when they should not

`--windlog` lists every mesh whose material sways. Only these rigid things swayed (everything else on the list is a tree):

| Object | Where | Why | Fix (Part B) |
|---|---|---|---|
| The Old Well and its sack, crate and barrel (`Cluster_well_corner`) | 6.2, 23.6 | the toon shader sways any mesh whose name or a parent's contains a foliage word; "well_**corn**er" contains "corn" | foliage words now match whole words only, and rigid words (well, lamp, post, fence, barrel, crate, door, wall, roof, sign, rock...) always win |
| The pantry door leaves (`DoorLeaves`) | 72.0, 12.5 | "leaves" | same |
| Card props from the zone kits (racks, signs, crates as painted cards) | none in town today; Gainlands, D.N.A., Buffet | every painted card bends with the default `sway` | rigid card props get a still material (`KitFoliage.card_material(id, still)`) |

### 3. Floating and detached pieces

| What | Where | Why | Fix (Part B) |
|---|---|---|---|
| Barge boards (the boards along a gable's rake) lying across the roof or hovering out in the air | every gable-front building: the clothier (14.6, 18.0), the chapel (18.0, 31.8), both `home_b` row houses (-0.8, 18.3 and 47.2, 18.3); the same preset in other zones | `BuildingKit._map_basis` turned the board with `swap * rot * swap`, which also swapped the board's length into its depth | map only the frame's axes (`swap * rot`, kept right-handed) |
| Wall plates and roof corners poking through a neighbour's roof | the back-alley smithy and the east row (39.6, 25.6); tight rows on both market streets | buildings set too close | the layout of Part C gives every building its own footprint (test: no two footprints overlap) |

### 4. Readable text in the world

| Text | Where | What it is | Fix (Part B) |
|---|---|---|---|
| "THE GAINLANDS / Brick Bronson" ("...LANDS") | the south road at the bridge | the floating name plate of the passage spot (drawn over everything, no depth test) | place spots get no plate; the HUD prompt and the dialogue name them |
| "THE ENDLESS BUFFET / Chef ... Gravois" | on the pantry door | same | same |
| "THE DEPARTMENT OF NECROTIC AFFAIRS", "THE VERDANT DUMP", "THE CAPITAL" | the other passages (the Capital's shows through the Hall of Records' roof) | same | same |
| "The Old Well", "The Iron Hatch", "Hall of Records", "The Restless Cairn", "The Sealed Vault", "Deck Station", "Notice Board", "Signpost" | their spots | same | same |
| Shop lettering | (checked every awning, sign and door slice in `assets/art/env_kit` and the zone kits used by the hub: all are pictures) | - | nothing to do |
| Names over people (vendors, the elder, the gatekeepers) | their heads | character name plates (UI, they fade with distance) | kept (CP-3) |

### 5. Looks walkable but is not / walkable with no visible reason to stop

The walkable ground was the old hex map (515 cells, x -21.6..72, z -15.6..68.6) with obstacle circles; everything beyond it is painted land.

| Place | Problem |
|---|---|
| South edge, z 68-70 | open grass runs on to the gorge lip 2 m further: an invisible wall in front of the drop |
| South-west, x about 0 for z 40-68 | the meadow carries on west; the hero stops at an invisible line (hex edge) |
| North-west, x < -2 for z < -3 | open meadow inside the tree belt that cannot be entered |
| North edge, z about -16 | gaps in the tree belt show open meadow beyond (gate road shot) |
| East, x 72-75 | the orchard and the land round the pantry door are open grass; the door stands alone in a field (walk round it to the land beyond: blocked only by invisible hex edges) |
| Lake, south-east | the shore is the jagged edge of hex cells; the water is overlapping discs with scalloped hard edges; the giant chest's peninsula is a strip of cells |
| Small ponds | hard-edged water patches cut into the grass at -18.0,0.0; -7.2,0.0; -3.6,0.0; -14.4,6.2; 21.6,-6.2; 32.4,-6.2; 12.6,-3.1; 27.0,-3.1; 70.2,3.1; 63.0,15.6; 70.2,15.6; -18.0,31.2 (beside the D.N.A. barrier); -7.2,37.4 |
| D.N.A. checkpoint and thorn wall | the open woods and field either side of each obstacle look walkable (the hero is stopped by hex edges and the passage posts) |
| Lanes between houses | the north rows of both market streets back onto open grass the hero can reach only round the ends; no loop round the town |

### 6. Clutter and lamps

- **Ground clutter**: the generic `ZoneDressing` recipe scatters grass tufts (22 per 100 m2), low plants, flowers, mushrooms, pebbles and stumps evenly over
  every walkable cell (about 1100 instances at Medium): the fields read as polka dots (`fields_south_default.jpg`).
- **Lamps**: 19 posts. Nine stand on the cobbled streets and the plaza ring (keep); ten stand along the dirt tracks out in the fields (south road:
  27.7,34.9; 30.1,37.7; 38.4,42.4; 32.7,49.5; 32.3,59.0; 22.7,63.4; grave road: 11.3,30.0; 1.7,28.9; -4.3,36.4; -13.4,31.8): **remove**.

### 7. The square and the vendors

- The plaza is a 6.2 m circle; the six shop vendors stand along two narrow market streets (Tilly and Sable on the west street's north side,
  Pip and Bertram opposite, Fenwick and Auntie Alembic on the east street), each behind a tight row of roofs (`west_street_default.jpg`).
- The secret dealer stands in front of a full second smithy behind the east row (`alley_default.jpg`), not hidden at all.

## Part B: cleanup and fixes

Shots: `docs/art/crosspath_pass/part_b/` (same spots as `before/`).

- **Old objects.** `TownExpansion` no longer places the seventeen KayKit huts, wells, towers and tents; it places storybook-scale kit buildings with a
  purpose: a thatched farmhouse with a fenced vegetable garden and barrels at the edge of the south-west field (12.4, 50.2) and a wayside cottage
  facing the meadow road with its garden and a bench nook (42.2, 55.4). The fisher's cottage and the boat shed by the dock come with the new
  lakeshore (Part D). The hub builds no KayKit water tiles (1206 hidden tiles) and no KayKit rocks; the Restless Cairn is a dark stack of kit
  fieldstones with five worn headstones and two twisted trees (`HubRelics`), the old lever a lever in a stone block. (`fields_south_*`, `fields_west_*`)
- **Motion.** The toon shader decides what sways by the names of the mesh and its parents. It now matches whole words only (`StyleToon.name_words`),
  and a rigid word (well, lamp, post, fence, barrel, crate, door, wall, roof, sign, rock, chest...) on the mesh or a nearer parent always wins:
  the Old Well and its barrel, crate and sack stand still, so do the pantry door's leaves. Painted card props from the zone kits that are not plants
  (racks, signs, crates) get a still card material. `test_crosspath_cleanup.gd`: every PropKit prop, every PropClusters cluster, every building
  preset and the relics stay still under full wind; a flower still sways. (`--windlog` on a town shot lists every swaying mesh: only trees and plants.)
- **Floating pieces.** Three causes, all in `BuildingKit`: (1) gable-front barge boards were turned with `swap * rot * swap`, so their length lay
  across the gable (two-metre boards hovering in the air at the clothier, the chapel and both `home_b` houses); (2) the top wall plate and (3) the
  corner posts reached the wall top and poked a few centimetres through every roof just outside the wall (the dark line across each thatch). The
  Undercroft cottage's boards now cover its real door and windows (two crosses floated above the wall and showed through the thatch). Test: every
  preset stripped of its sockets stays inside its footprint plus its overhang. (`west_street_default.jpg`, `fields_south_default.jpg`)
- **Readable text.** Places carry no floating plate any more (the five passages, the well, the hatch, the cave, the hall, the deck station, the boards,
  the signposts, the vault, the cairn): the minimap still lists them, the HUD prompt and the dialogue name them. People keep their name (CP-3).
  The shop signs, awnings and doors were already pictures. (`gate_beefcake_locked.jpg`, `gate_gourmand_locked.jpg`)
- **Ground clutter.** The town recipe is thinned (grass 22 -> 12 per 100 m2, no mushrooms or stumps, fewer flowers and pebbles) and in the hub it
  grows only where a slow noise allows a clump AND the spot is at a path edge, at the foot of a wall, fence, building or prop, or at a field's
  edge (`TownClutter`); about a third of the fields carries dressing, the rest is calm grass. (`fields_*`)
- **Lamps.** Only the cobbled streets and the square carry lamps; the ten posts along the dirt tracks in the fields are gone. Test:
  `test_lamps_stand_only_on_the_cobbled_streets`.
- Town on Medium: 60.0 fps average, minimum 60 (draw calls 712 -> 670). GUT 1672 passing (the one failure is CP-2).

## Part C: the town square and the vendors

Shots: `docs/art/crosspath_pass/part_c/` (the old spots, plus `vendors_north_default`, `vendors_west_default`, `vendors_east_default` from inside
the square and `alley_close_default`).

- **The square** is now a 23 m cobbled circle (radius 11.5, was 6.2) with a bigger kit-stone fountain at its centre (a 2.6 m basin with a moulded
  rim, a fluted pedestal, two spilling bowls and a finial; it was plain flat-coloured cylinders), the four Path plinths of the royal crest in kit
  stone round it, four lamps on the diagonals and four benches facing the fountain. Nothing else stands on it: it is crossed in a straight line
  round the fountain.
- **All six shop vendors stand round it**, each in their own storefront facing the fountain, 12.6 m from its centre: Tilly Tonic and Foil Fenwick
  on the north side either side of the Gate Road (their fronts face the camera), Sable and Bertram on the west side, Pip Threadwell and Auntie
  Alembic on the east side, either side of the market streets. Every vendor's spot is at least 5 m from the next and 2.5 m from any other prompt
  (signposts, the notice board, the Rift Express). Their icon signs, awnings and doorstep clusters come with their presets; the doorstep clusters
  are trimmed to each shop's own frontage (a barrel and crate used to spill round a corner into a street mouth). The south side stays open and low
  (the notice board on the south-west corner, the Rift Express on the south-east corner, the Grave Road running past), so the camera sees across
  the square and the shop fronts are never hidden. The old decorative stall on the east rim is gone: the shops are the market.
- **Streets**: every street into the square is 5.2 m wide (four hero widths are 4.2 m) with nothing solid on it near the square; signposts stand
  just off the paving at each mouth. The Grave Road now branches off Champions' Road just south of the square, so it never squeezes past a shop.
  The Gate Road runs straight north between the two north shops, then bends to the Capital passage; Champions' Road runs south between the
  chapel and the Deck Station to the Undercroft cottage.
- **The Secret Dealer's alley** (`TownLayout.ALLEY`): a 2.4 m lane off the square's north-east corner between Fenwick's shop and the north-east
  house, running north. Trodden dirt and soft shade pools on the ground, no street lamp; one small lantern hangs under the eave at its mouth with a
  stack of crates and a barrel on the corner as the hint; the dealer stands at a crate counter halfway up (once the giant chest has been opened)
  and has no floating name. The camera looks straight up the alley from the square, so nothing between the lens and the dealer needs to fade.
  The old back-alley smithy behind the east row is gone.
- **The rest of the centre**: the Hall of Records moved to the east street's north side; Elder Maren's home and the Forgotten Cave stand along the
  Gate Road beyond the north shops; the chapel and the Deck Station flank Champions' Road; the Old Well has its own yard off the west street.
  Anchors, the minimap's points and the quest markers follow the new spots on their own (they read the anchors); no dialogue named the old ones
  (the one location line, "the abandoned cottage at the end of Champions' Road", is still true).
- Tests: `tests/world/test_crosspath_square.gd` (the square's size, every vendor's storefront round it facing in and reachable, 5 m between
  vendors and 2.5 m to other prompts, the streets clear across four hero widths, only low things on the square, the alley narrow, dim, reachable
  with a 1 m body and opening off the square); the town walkability test still reaches every key location with a 1.1 m body.
- Town on Medium: 60.0 fps average, p95 16.7 ms (one 24 fps hitch while the scene settles; 733 draw calls). GUT 1678 passing (CP-2 aside).

## Part D: walkable area and boundaries

Shots: `docs/art/crosspath_pass/part_d/` (`edge_<kind>_*` one per kind of boundary, `loop_*`, `lake_dock_*`, `gate_<zone>_locked/open`).

- **Walking is data now** (`TownBounds`): one outline round the whole hub, every edge labelled with the blocker that stands on it, plus the lake
  and the dock. `TownBuilder.is_walkable` / `is_floor_at` / `map_bounds` read it in the hub (the title backdrop keeps the old hex map). The
  walkable country grew: the north-west meadow, the lanes behind the north row and the east street, the whole south-west field, the meadows
  between the fields, the lake and the gorge are open; the old map's hard little ponds (thirteen hex cells of water cut into the grass) are
  grass now.
- **Every edge has a reason you can see** (`BoundaryKit`, built just outside the line, never over walkable ground):
  - north, either side of the Capital road: a rocky ridge of boulders with pines behind (`edge_ridge_*`); the north-east: three rows of
    woods with bushes at their feet (`edge_forest_*`);
  - east: a 2.5 m orchard wall with pillars and coping, fruit trees beyond it (`edge_orchard_*`); the pantry door is built into it;
  - the lake: the shore (below);
  - south: the gorge lip, the lake pours over it at the south-east as a waterfall (`edge_gorge_*`);
  - south-west field: a clipped hedge with trees behind (`edge_hedge_*`); round the graveyard hollow: a field wall (`edge_wall_*`);
  - west: a fence line north of the D.N.A. checkpoint and the field wall south of it; thorn woods (twisted trees and brambles in front of
    dark pines) either side of the thorn wall (`edge_thorns_*`).
  The tree belt round the country now starts behind these, so the designed edge is what the hero meets.
- **The loop** (`TownBounds.LOOP`, a worn 2.8 m dirt lane): round the back of the north row (well clear of the Capital passage, which moved
  two map rows north so the lane fits behind the buildings), down the east side inside the orchard wall, along the lakeshore past the fisher's
  cottage, the peninsula, the boat shed and the dock, across the meadows south of the fields, up the west side past the graveyard and through
  the woods. It crosses every road at least 3 m from its passage, so walking it never leaves town (`loop_north_default.jpg`, `loop_south_default.jpg`).
- **Zone entrances, the only way through** (`HubObstacles._seal`, `PantryGate`): each obstacle is joined to the boundary on both sides
  (always solid) and its own line is solid while its gatekeeper stands, so nobody walks round an obstacle (before, only a circle in the
  passage mouth kept the hero off the trigger):
  - the Gainlands bridge: the gorge runs 90 m on both sides of it;
  - the D.N.A. checkpoint: a fence from the barrier's far post and a stone wall from the booth into the boundary's fence line and field wall;
  - the Endless Buffet's **pantry door, rebuilt**: an enormous two-leaf carved oak door (raised panels, rails and stiles, studs), long iron
    strap hinges with knuckles, ring pulls, a great iron lock box with a dinner-plate keyhole and a hasp, in a stone gatehouse (coursed
    jambs, a lintel with a keystone, a pediment with the fork-and-spoon crest), its wing walls running into the orchard wall; cleared, the
    leaves swing open away from the town (`gate_gourmand_locked.jpg` / `_open.jpg`);
  - the Verdant Dump's thorn wall: brambles from both ends into the thorn woods;
  - the Capital road: the ridge on both sides (always open).
- **Water**: the town lake is one natural shape (`TownBounds.LAKE`) with a sandy bank fading into the grass and pale shallows fading into the
  deep water, reed clumps and stones in clumps along the shore with open bank between, the giant chest's peninsula reaching out into it and a
  plank dock on posts; a waterfall where it meets the gorge. The two far lakes out in the country keep their soft shapes and reeds.
  The fisher's cottage on the west shore and a stone boat shed by the dock (CP-4) arrived with it (`lakeshore_default.jpg`, `lake_dock_*`).
- Tests: `tests/world/test_crosspath_bounds.gd`: every 1.5 m of every edge has a blocker you can see within reach outside it (the gorge and the
  lake checked as the drop and the water), no boundary piece stands on walkable ground, a flood fill from the spawn never leaves the outline
  while it reaches the far corners of every field and the lakeshore, the full loop is open for a 0.9 m body and goes round every building and
  never within 3 m of a passage, each zone road's trigger cannot be reached while its obstacle stands, the passages are the only gaps, the
  lake has its bank and shallows, the old ponds are grass, the dock is walkable and the lake is not. The walkability test, the hub world test
  and the chest scans pass on the new ground.
- Found on the way: the world-look foliage layer (up to 6500 plant cards with a flat 4 % chance everywhere) was the other half of the even
  scatter in the fields; in the hub it now follows the same clump rule as the ground dressing (CP-9). Its test read the plants back from a
  MultiMesh, which a headless run returns as the identity (every plant at the origin), so it passed by luck; the layer keeps its own list now.
- Fixed after the first shots: the ridge read as a row of identical balls (now angular bevelled boulders, two or three to a cluster, of mixed
  sizes, with bushes and pines among them); the pantry gatehouse faded out as camera clutter (it never stands between the lens and the hero:
  no fade now) and was turned edge-on (both east and west obstacles now turn their faces towards the camera); the lake's north tip reached the
  pantry gate's wing (pulled back 4 m); the debug-only Dev Shrine is a kit-stone plinth with a crystal.
- Town on Medium: 60.0 fps average and minimum at the spawn and at the lakeshore (774 / 561 draw calls; one 59.7 run with a load hitch).
  GUT 1684 passing (CP-2 aside).

## Part E: polish and verify

Final shots: `docs/art/crosspath_pass/final/` (every spot of `tools/crosspath_shots.sh`); before / after pairs: `docs/art/crosspath_pass/compare/`
(before on the left, `bash tools/crosspath_compare.sh`).

- **Dressing the outskirts** (`OutskirtDressing`, town kit only): a delivery corner of crates inside the orchard wall, a woodpile of crates
  behind the north row, barrels behind Tilly's, a bench nook over the lake, a garden bed in the west woods clearing, a low wall behind the
  graveyard, a cart by the meadow road, hay bales in the farmhouse's field, a bench looking over the gorge and bush clumps along the gorge
  lip as foreground framing. Every piece is checked against the lane, the roads, the buildings, every spot (2.5 m) and the edge; none was
  refused at the final positions, and the loop and every out-of-town spot stay reachable (test).
- **Walked** (windowed, real keyboard input, about 7 minutes in all):
  - `bash tools/run_crosspath_walk_smoke.sh`: the full loop round the town (37 legs, none stuck, never out of town), all six vendors walked up
    to from the square (prompt, E opens, closes), the Secret Dealer up the alley (prompt, opens the black market), out on the dock and never
    into the water, along the peninsula to the old chest, round the abandoned cottage to the Undercroft hatch. **OK.**
  - `bash tools/run_hub_walk_smoke.sh`: every zone road blocked (the obstacle stops the hero, the toast names the gatekeeper), then cleared
    with the debug flags, walked into each zone and back onto the same road, the Capital road, the Undercroft chained and open. **OK.**
  - `bash tools/run_town_slice_smoke.sh`: the keyboard walk and 14 spots (vendors, the Deck Station, the elder, Brannoch, the Hall of Records,
    the notice board, signposts, the hatch). **OK.**
- **fps on Medium** (`tools/fps.sh`, quality 1): spawn 59.8 average (p95 16.7 ms, one 38 fps load hitch), the alley 60.0, the lakeshore
  60.0, the pantry gate 60.0 (minimum 60 at the last three).
- GUT 1685 passing; the one failure (`test_world_look_rig`'s FOV check) is pre-existing and comes from the dev PC's saved zoom (CP-2).

### Before and after

| Fix | Before / after |
|---|---|
| The fields (toy huts, polka-dot clutter -> farmhouse, garden, calm grass) | `compare/fields.jpg`, `compare/fields_overview.jpg` |
| The well and every rigid prop stand still | (motion: `--windlog` lists only plants; `test_rigid_kit_props_have_no_sway`) |
| Floating beams and boards (barge boards, plates through the thatch) | `compare/beams.jpg`, `compare/beams_thatch.jpg` |
| The square with the vendors | `compare/square.jpg`, `compare/square_default.jpg`, `compare/vendors_west.jpg`, `final/vendors_north_default.jpg`, `final/vendors_east_default.jpg` |
| The black-market alley | `compare/alley.jpg`, `final/alley_close_default.jpg` |
| The whole hub from above (walkable ground green) | `compare/plan.jpg` |
| A boundary of each kind | `final/edge_ridge_*`, `edge_forest_*`, `edge_orchard_*`, `edge_thorns_*`, `edge_wall_*`, `edge_hedge_*`, `edge_gorge_*`, `lake_dock_*` |
| The graveyard (KayKit rocks -> kit stone) | `compare/graveyard.jpg` |
| The lakeshore | `compare/lakeshore.jpg` |
| Each zone entrance, locked and open | `compare/gate_<zone>_locked.jpg`, `compare/gate_<zone>_open.jpg` (refusemancer, necrocrat, beefcake, gourmand; the Capital road `compare/gate_final_locked.jpg`) |

### Still not right / next

- The checkpoint's striped arm is hard to see from the default camera once the booth turned to face it (it reads from Overview).
- The ridge boulders, the walls and the gatehouse are kit-textured geometry; a painted cliff/ridge card set and a pantry-gatehouse concept would
  bring them up to the painted trees (CP-13). Sheet-ready rows: `HUB-ROCK-RIDGE` (CUTOUT, 3-4 boulder silhouettes, 2-3 m), `HUB-CLIFF-FACE`
  (SURFACE, layered rock, 400 px/m), `HUB-GATEHOUSE` (CONCEPT, pantry gate in an orchard wall, storybook scale).
- The square's south side is open by design (CP-6); if it feels empty, two low market stalls on its south-west and south-east corners would fill
  it without hiding a vendor.
