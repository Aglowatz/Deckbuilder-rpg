# Capital pass (Oct 17)

The graphics and correction pass for the Capital (zone id `final`, `scenes/capital_zone.tscn`), both halves, after the layout pass and the art pass
(`docs/art/capital_slice.md`). Parts A-F of the brief; judgment calls are CAP-40... in `docs/design/open_questions.md`. Rules followed:
`docs/art/art_bible.md` (storybook scale, no readable world text, characters clearest) and `docs/art/zone_rollout_playbook.md` (declutter, clusters
not scatter, 60 fps on Medium). Targets: the ten `docs/art/paintovers/PAINTOVER-CAP-*.png` and the kit concepts in `docs/art/zone_kits/final/concepts/`.

Screenshots: `bash tools/capital_pass_shots.sh <phase> [prefix,...]` shoots the same spots every time into `docs/art/capital_pass/<phase>/`: the ten
paint-over cameras (`CapitalLayout.PO_CAMERAS`, gate open, enemies held, districts broken) from the default camera (Cinematic / Normal, `_default`)
and Overview (Far, `_overview`), the four restored districts, the front wall, the shut gate, the west edge, the castle from both halves and its
sides, the map's edges, the Ward and the tunnel mouth, plus top-down plans (`plan_outside`, `plan_inside`, `plan_west`: green = where the hero can
stand, red = solid circles, yellow = anchors; `--top=x,z,size --plan=true` on any zone scene now, `PlanView`). What sways: `--windlog=true`.

Coordinates are world metres (x east, z south; the camera looks north). The great wall stands on rows z 72-75, the city inside (z 2-71), the
outside south of it (z 76-121).

## Part A: the audit

Before shots: `docs/art/capital_pass/before/`.

| | |
|---|---|
| ![](capital_pass/before/po_gate_road_default.jpg) the Gate Road | ![](capital_pass/before/po_resistance_camp_default.jpg) the camp |
| ![](capital_pass/before/west_edge_south_default.jpg) the outside's west edge | ![](capital_pass/before/wall_front_west_default.jpg) the old passage |
| ![](capital_pass/before/po_gate_plaza_default.jpg) the Gate Plaza | ![](capital_pass/before/po_palace_approach_default.jpg) the approach |
| ![](capital_pass/before/plan_outside.jpg) plan, outside | ![](capital_pass/before/plan_inside.jpg) plan, inside |

### 1. Blocky and primitive-looking objects

| Object | Where (x, z) | What is wrong | Decision |
|---|---|---|---|
| The great wall (`CapitalLandmarks.wall_piece`), front, sides and north | z 72-75 across the map; x 0 and 119; z 0.5 | One long flat white slab: shallow pilasters, square merlons, nothing projecting, no plinth; the concept and every outside paint-over have square towers along it, a stone plinth, deep pilasters with gold pinnacles and dark sun banners | **rework**: towers along the outer face, a battered plinth, ashlar courses, deep pilasters with pinnacles, a cornice under the crenellations, sun banners on the towers |
| The two corners where the front wall meets the side walls | (0, 72-76) and (119, 72-76) | nothing there: the front wall starts at x 2 / ends at x 118, the side walls stop at z 72 (an open slot at each corner, seen from Overview) | **rework**: corner towers |
| The gate towers (`gate_tower`) | (52.5, 73.5), (67.5, 73.5) | plain square boxes with a gold cone | **rework**: corner pinnacles, buttress bases, deeper bands |
| The outside's side edges (`AshEdge`) | x 0.5 and 119.5, z 76-121 | a stepped row of ash-textured boxes 1.6-3 m high, a flat grey plain beyond it | **replace**: the rim terrain (ridges of rough ash ground, rocks, rubble, dead trees) |
| The outside's south edge (`RubbleEdge`, `_rock_wall`) | z 123.8, x 0-56 and 64-120 | runs of tilted boxes (the camp's foreground: big cut slabs) | **replace**: the rim terrain; the road runs on south between hills |
| The ground's rim | every edge of the walkable floor | the floor stops at the last cell and drops 0.4 m to a flat colour plane (`Wasteland`, `Meadow`) | **rework**: rim terrain flush with the floor's edge, haze beyond |
| Generic outside scatter (`ZoneDressing` recipe `capital_outskirts`) | all over the outside | Kenney low-poly crates, red-and-white barrels, logs, metal panels, fence bits, planks, stones and mushrooms; the painted-texture binding paints several of them as red brick (the "red wedges", the red balls and boxes at the wall) | **remove** the props from the recipe; dry grass only in clumps at edges and clusters (Part C) |
| The camp's tents (`CapitalLandmarks.camp`) | (29, 116.5), (40.5, 116.5) | an A-frame whose ridge runs across the view: from the camera it is a flat coloured rectangle | **rework**: draped canvas on a pole frame at three-quarter angle (the concept), sagging, pegged, its emblem patch |
| The camp's crates and barrel, the lean-to's bedrolls | round the tents and the lean-to | plain boxes and a lathe | **rework**: plank crates with edge frames, banded barrels, rolled bedrolls, log seats by the fire |
| The camp's ruins (`_ruin_wall`), the wasteland's ruin fragments (`ruin_fragment`), the outpost's fallen houses (`ruined_house`) | x 19 / 45.5 at the camp; the twelve clusters; (83, 114.5), (106.5, 115) | stepped columns of cut boxes with a brick texture (the concept's ruins are stacked stone blocks) | **rework**: masonry of individual bevelled blocks in courses, a ragged top, fallen blocks at the foot |
| The street lamps of the Gate Road (`street_lamp`) | x 54.6 / 65.4, z 92-112 | a black box lantern on a pole | **rework**: an old iron lamp with a turned post, a curled arm and a cage lantern |
| The abandoned checkpoints (`checkpoint_booth`) | (15.5, 95), (97, 112.5) | a box of boards under a flat slab | **rework**: a plank shack with a gabled broken roof, corner posts, a boarded window |
| The queue posts, the height post | x 54.4, z 90-100; (48.5, 76.8) | a box rope; a box post with box ticks | **rework**: a sagging rope between turned gold posts; a turned measuring post |
| The hidden shaft's rubble (`hatch_cover`) | (4.5, 88.5) | two plain boxes (one brick-painted) | **rework**: a slab and rubble cards |
| The tunnel mouth | (96, 76) | fine (the concept) | keep |
| The watchtower | (91, 96.5) | box courses; reads fine at its distance | **rework** lightly: masonry relief at its foot, rubble |
| Primm's Castle (`CapitalCastle`) | the hill, x 22-98, z -30..12 | big white boxes with round arched windows; flat cornices; the concept's many small spires, pointed windows, cypress on the terraces and the turned corners are missing; the hill terraces' side faces (x 47 and 74, seen from the side pockets) are blank slabs | **rework**: pinnacles along every roofline and on the keep, pointed windows, deeper cornices, cypress rows on the terraces, dressed terrace ends and corners |
| The complaint boxes | (49, 63), (65.4, 45.5) | a plain blue box | **replace**: a white-and-gold post box |
| The loudspeakers | the avenue's verges, the Ward | cylinders and two horns | **rework**: a gold pole, a turned head, two flared gold horns |
| The portraits and posters | the avenue's verges, the forecourt | a gold box with a quad | **rework**: an ornate gold frame (moulded, a crest) on a gold easel |
| The paste dispenser | (105.5, 38.5) | a plain white block | **rework**: rounded machine body, a hopper, gold bands |
| The manholes | six spots | painted red brick by the texture binding | **rework**: kept from the binding, iron rings |
| The Ward's beds and its window booth | (99-111, 6), (103, 12.2) | boxes | **replace**: white iron beds (tubes), the civic kiosk |
| The sick patch, the power cable, the seed jar | the Reek, the yards | flat disc and sticks, a box cable | **rework**: a kerbed soil bed with dead stalks / flowers, a tube cable |
| Primm's fallen houses (`_ruined`, only once Primm has fallen) | the approach | boxes | **replace**: the kit row house, cracked and slumped |
| The Crease (underground hall) | z 133-155 | boxes (tables, columns, stall) | out of scope (not either half; noted) |

### 2. Disorganized clusters and scatter

| What | Where | Decision |
|---|---|---|
| The generic scatter (stones, crates, barrels, logs, panels, planks, stumps, mushrooms) and its dark purple ground patches | evenly over the outside | **remove** the props; ground patches and dry grass only in the clusters and along the edges (Part C) |
| Ash drifts (`CapitalWasteland._drifts`) | sixteen at random spots | **regroup**: under the clusters and along the road edges |
| The wasteland's twelve clusters | edges of the outside | pieces at random angles round a centre: **regroup** into purposeful vignettes (a ruin wall parallel to the road or edge, a dead tree behind it, debris at its foot), placed along the roads' sides and the edges |
| The rubble by the old passage (red "scrub" balls, loose stones) | (21-25, 77) | **remove** (Part D) |
| Hidden chests turned at random (`_build_chests`) | everywhere | **regroup**: inside square to the streets, outside a few set angles |
| The inside rows (`CapitalDressing`) | ring streets, boulevards, separators, forecourt | gaps where a slot was refused on one side and not the other: **regroup** so every refused slot is refused on its mirror too (the city is perfect) |

### 3. Floating and detached pieces

| What | Where | Decision |
|---|---|---|
| District plaques of style "wall" with no wall behind them: a white plaque floating on a post | the Reek's (22, 39), the Hungry Quarter's (100, 23.6) and others (listed by the check in Part B) | **rework**: a plaque that has no wall within reach stands on its own white-and-gold post |
| The side walls' ends | the corners | see the corner towers above |
| A faint ghost of the west side wall at the outside's north-west corner | (0, 70) from the west edge | the fader's ghost of the side wall seen from outside; goes with the corner tower and the hidden strip (Part D) |

### 4. Things that move when they should not

Every rigid kit model in the Capital is built with `no_wind` (`CapitalLandmarks.finish`) and the card fields of the inside rows are `prop` kinds (never
sway). The sway log of the default shots lists only the plants' and trees' cards and the generic scatter's grass and mushrooms (which go in Part C).
Moving by design: the energy wheels (`Spin`), the rifts' shards and tears, Grave Row's ghosts, the castle cracks' glow, the camp fire, the gate when it
opens. Checked again in Part B (`--windlog=true`).

### 5. Readable text in the world

| Text | Where | Decision |
|---|---|---|
| The floating name plates of place spots ("Complaint Box", "Exit Interview Booth", "Rift Stone", the poster...) drawn over everything when the hero is near | every non-person spot | **remove** in the Capital, as in town (CP-3): the HUD prompt names them; people keep their name |
| Banners, plaques, posters, portraits, emblems | everywhere | pictures (faces, icons, the civic sheet); nothing to do |

### 6. Unclear boundaries

| Place | Problem |
|---|---|
| The outside's west, east and south edges | an invisible stop at a stepped box wall, a flat plain beyond it reads as open ground |
| The Gate Road's south end | the road just ends at the map's edge in an open plain; nothing says it goes on to Crosspath, nothing stops the hero but the exit spot |
| The old wall passage | a 2 m gap in the front wall at x 22-23 (the front wall is meant to be impassable) |
| The city's inner west and east edges | the floor stops 0.75 m short of the west wall (an invisible stop); at the east wall the hero walks 0.25 m into the wall |
| The corners of the city wall | open slots (above) |
| The castle hill's side pockets (x 36-47 and 74-84, z 0-12) | the hill's terrace ends are blank slabs |

### 7. Map edges

From Overview every outside edge shows the floor's rim: the cells end, a 0.4 m drop to a flat plain, the stepped box wall (`west_edge_south_overview`).
There is no hexagonal terrain in the Capital (the layout is a 1 m grid; the hub's old hex tiles are not built here). The backdrop cards
(`CAP-BD-WASTELAND`, `CAP-BD-CITY`) stand on the far ring and the haze is there; what is missing is the land between the walkable floor and them.
**Decision**: one rim of rough ground round the outside, flush at the floor's edge and rising to ridges a few metres out (rocks, rubble and dead trees
on them), falling back to the plain under the haze; the road to Crosspath carved through it; the west of the city wasteland, the meadow and a belt
of dark pines behind the city's other walls (seen over them from inside).

### 8. The wall and the passage (for Part D)

The front wall has a 2 m walk-through gap at x 22-23 hinted by two cracks, loose stones and three clumps of scrub (`docs/design/secrets.md`). The
city's west side wall stands on the map's west edge (x 0), with nothing outside it. Part D closes the gap and moves the secret round the corner.

**fps on Medium before the pass** (`bash tools/capital_fps.sh 1`): see the table in Part B.

## Part B: the blocky objects replaced

Shots: `docs/art/capital_pass/part_b/` (same spots as `before/`).

| | Before | After Part B |
|---|---|---|
| The Gate Road | ![](capital_pass/before/po_gate_road_default.jpg) | ![](capital_pass/part_b/po_gate_road_default.jpg) |
| The camp | ![](capital_pass/before/po_resistance_camp_default.jpg) | ![](capital_pass/part_b/po_resistance_camp_default.jpg) |
| The outpost | ![](capital_pass/before/po_ruined_outpost_default.jpg) | ![](capital_pass/part_b/po_ruined_outpost_default.jpg) |
| The outside's west edge (Overview) | ![](capital_pass/before/west_edge_south_overview.jpg) | ![](capital_pass/part_b/west_edge_south_overview.jpg) |
| The south edge (Overview) | ![](capital_pass/before/edge_south_overview.jpg) | ![](capital_pass/part_b/edge_south_overview.jpg) |
| The castle's west side | ![](capital_pass/before/castle_side_west_default.jpg) | ![](capital_pass/part_b/castle_side_west_default.jpg) |

- **The great wall** (`CapitalLandmarks.wall_piece`) is a wall, not a slab: a battered stone plinth (it steps out at the foot on the outer face),
  ashlar courses with staggered joints, deep pilasters on stone bases with gold capitals rising into gold-capped pinnacles over a parapet of
  gold-coped merlons, a cornice under it, and on the outer face the dark navy sun banners of the concept and every outside paint-over (a
  swallow-tailed cloth with a gold border and the radiant sun, `sun_banner`; the pale kit banners stay on the city face). Four square towers stand
  out from the front wall's outer face (`CapitalLayout.WALL_TOWERS`, x 9, 37, 83, 109: off the gate, the tunnel mouth and the corners; their
  row in front is solid), each with a battered base, gold bands, a crenellated top, four corner pinnacles, a gold spire and a long sun banner.
  Corner towers (`corner_tower`) close the two corners where the front wall met the side walls (an open slot before). The gate towers gained
  pinnacles on their corner posts and a stone plinth.
- **The rim** (`CapitalRim`, new): the stepped box walls along the outside's sides and the cut-box rubble along its south edge are gone. One ring of
  rough ground round the whole outside: its height comes from a distance field on the layout's grid (flush with the floor at the last walkable
  cell, a ridge 4-5 m up a few metres out, rolling with a slow noise, falling back to the plain under the haze at 26 m), painted with the
  wasteland's own painted ground so the edge has no seam. Rocks (irregular faceted boulders, no two alike), the rubble sheet's piles and dead
  trees stand on it: the blockers you see. Because the camera always trails south of the hero, wherever walkable ground lies just north of the
  rim (the south edge) the rise is capped under the camera's line to the hero and carries no trees, so the hills climb out of the frame, never into
  it (tested). The road from Crosspath runs on south between the hills (a view floor of road cells, then a road strip). The far planes moved to
  meet it (`WastelandWest` under the city's west side). Beyond the city's other walls a belt of dark pines on the meadow and the castle hill
  (the paint-overs' dark accents over the white walls).
- **The camp** (`CapitalLandmarks.camp`): the two A-frame "sheets" are draped tents (canvas sagging between two poles and flaring at the hem, the
  back closed, the front flaps tied back, guy ropes and pegs, the patch and both Paths' essences on the slope the camera sees), each turned three
  quarters so its open end looks at the fire, as in the concept. Plank crates with edge battens and braces, banded barrels behind each tent, log
  seats round the fire, the lean-to a sagging canvas on four posts over rolled bedrolls. The ruins it shelters in are stacked stone.
- **Ruins as masonry** (`CapitalLandmarks.masonry`): every ruin is stacked bevelled blocks in staggered courses under a ragged top (the ends stand
  longest), a block or two askew at the top, fallen blocks at its foot, mixed from a set of stone tones (`PALE_STONE`, `ASH_STONE`): the camp's
  walls, the wasteland's ruined walls, the outpost's fallen guardhouses (and the identical houses once Primm has fallen, which were box ruins).
- **Props** (`CapitalProps`), each a kit mesh now: the Gate Road's lamps (a turned iron post, a curled arm, a cage lantern), the queue (turned gold
  posts and a sagging velvet rope), the height post, the checkpoints (plank shacks on a stone footing with a caved-in gabled roof and a boarded
  window; `plank_walls`), Fern's shack (the same planks under a mossy lean-to roof and a stovepipe), the shaft's cover (a heaved road slab and a
  rubble card), the complaint boxes (a pastel post box on a turned pedestal), the loudspeakers (a turned pole and two flared gold horns), the
  portraits (a moulded gold frame with Primm's crest on an easel), the lost-property poster, the manholes (an iron grate in a gold ring; the
  painted binding drew them as red brick), the paste dispenser (a rounded machine with a hopper, pipes and a dial), the Ward's beds (white iron
  frames), its window (the civic kiosk), the sick patch (a kerbed bed of dead stalks or flowers), the power cable, the seed jar, the recipe cards.
  A test builds every prop the layout places and finds no raw box, cylinder or sphere in any of them.
- **The castle** (`CapitalCastle`): pointed lancet windows in place of the round-headed ones on the keep and the wings, a gold-capped pinnacle over
  every wing bay and pilasters between them, a ring of four pinnacles round each big tower's eaves (the concept's crown of little spires), cypress
  columns behind the terraces' balustrades, and the terraces' outer ends dressed like their fronts (pilasters, gold bands, balustrades turning
  the corner, a cypress) instead of blank slabs.
- **No floating plaques**: a "wall" plaque with no wall behind it stands on its own posts (`CapitalBuilder.sign_backed`, `_sign_stand`).
- **The outside scatter**: the generic recipe for the outskirts keeps only dry grass (no Kenney crates, barrels, logs, panels, planks, stones,
  stumps or mushrooms: the red "brick" wedges and boxes are gone); the sway log now lists only that grass. Nothing rigid sways (a test applies the
  toon shader to every prop, the wall, the towers, the camp, the ruins and the castle and finds none swaying).
- **Readable world text**: the place spots' lettered plates are hidden in the Capital (CAP-41); people keep their names.
- **The city floor** ends where the east wall's foot begins (x 116; it ran 0.25 m into the wall).

Shots: 51 of the 56 spots (the run was stopped for low memory before the Ward and tunnel-mouth views; skipped). **fps on Medium**
(`bash tools/capital_fps.sh 1`): 59.7-60.1 average at all ten cameras (the Gate Road 59.7, the camp 60.0, the rift fields 60.1, the outpost 59.9,
the plaza 59.8, the Transit Yards, the Hungry Quarter, Grave Row and the Reek 60.0, the approach 59.8). **Checks**: GUT 1693/1694 (the one failure is
the pre-existing camera-FOV test, CP-2); new `tests/world/test_capital_pass.gd`; `test_zone_dressing` allows the outside's grass-only recipe.

## Part C: organized

Shots (from here on 10-12 key views per part at 1280x720, to spare memory): `docs/art/capital_pass/part_c/`.

| | |
|---|---|
| ![](capital_pass/part_c/po_gate_road_default.jpg) the Gate Road: the wasteland's vignettes square to the road | ![](capital_pass/part_c/po_rift_fields_default.jpg) the rift fields |
| ![](capital_pass/part_c/po_resistance_camp_overview.jpg) the camp from Overview | ![](capital_pass/part_c/po_ruined_outpost_default.jpg) the outpost |
| ![](capital_pass/part_c/po_gate_plaza_default.jpg) the Gate Plaza | ![](capital_pass/part_c/po_palace_approach_default.jpg) the palace approach |
| ![](capital_pass/part_c/castle_side_west_default.jpg) the west ring street: lamps and benches in an exact line | ![](capital_pass/part_c/plan_inside.jpg) plan, inside |
| ![](capital_pass/part_c/restored_transit_yards.jpg) the Transit Yards restored | ![](capital_pass/part_c/restored_hungry_quarter.jpg) the Hungry Quarter restored |
| ![](capital_pass/part_c/restored_grave_row.jpg) Grave Row restored | ![](capital_pass/part_c/restored_the_reek.jpg) the Reek restored |

- **Outside, bleak but deliberate** (`CapitalWasteland`): each of the twelve edge clusters is one composed vignette instead of pieces dropped at random
  angles round a centre: a stretch of ruined wall square to its nearest road (its length along the road), a dead tree behind it, debris and a
  stump at its foot, a broken cart beside it, an ash drift under it, each piece only where the ground is free and off the roads. The loose ash
  drifts lie along the roads' kerbs (blown against them), not scattered over open ground. Chests outside take a quarter turn, never a random one.
- **Inside, eerily perfect**: the ring streets carry lampposts and benches in exact lines down their inner kerbs (`CapitalLayout._ring_rows`, a lamp
  every 6 m and a bench midway between each pair), the west street's mirrored exactly on the east street about the avenue; a slot stands
  only if its twin does. The kit rows along the white roads (`CapitalDressing._rows`) are now placed in mirrored pairs too (a slot on a
  mirrored street stands only if its twin across the avenue does), so a refusal on one side is a refusal on both. Chests inside stand square.
  The avenue's verge lines, the identical houses, the identical row, the headstones and the plaza's lamps were already exact rows (tested in the
  layout pass) and are unchanged.
- **The districts**: both states keep their footprints (tested in the art pass); the restored shots above, broken in Part B's set. The broken
  disorder (leaning headstones, the Reek's bins and bags, the shuttered stalls) stays inside the broken districts only.
- **Tests**: `tests/world/test_capital_order.gd` (the mirrored rows, the ring streets' exact spacing, the wasteland vignettes square to their road
  and only in clusters, square chests).

**fps on Medium** after Part C: 59.7-60.0 average at all ten cameras. **Checks**: GUT 1697/1698 (pre-existing CP-2).

## Part D: the wall, the gate and the hidden passage

Shots: `docs/art/capital_pass/part_d/`.

| | |
|---|---|
| ![](capital_pass/part_d/wall_front_west_default.jpg) the front wall where the old gap was: solid, a tower now | ![](capital_pass/part_d/gate_closed_default.jpg) the gate shut: the only opening |
| ![](capital_pass/part_d/hole_far_default.jpg) the rift fields' north-west corner: nothing gives the strip away | ![](capital_pass/part_d/west_edge_south_overview.jpg) the west edge from Overview |
| ![](capital_pass/part_d/west_strip_default.jpg) up the strip along the west wall (default camera) | ![](capital_pass/part_d/west_strip_overview.jpg) the strip from Overview |
| ![](capital_pass/part_d/hole_close_default.jpg) right by the hole, default camera: the wall is seen edge-on, the hole hard to spot | ![](capital_pass/part_d/hole_close_overview.jpg) the same from Overview |
| ![](capital_pass/part_d/hole_from_the_west.jpg) the hole up close (a debug camera from the west the game never uses) | ![](capital_pass/part_d/hole_inside_overview.jpg) the inside end, behind a Reek yard: the wall never fades |
| ![](capital_pass/part_d/plan_west.jpg) plan: the strip (green) along the west wall, the hole at its foot | |

- **The front wall** (rows z 72-75) is one piece from the west corner tower to the gate's tower and another from the gate's other tower to the
  east corner: no gap, crack or walk-through spot but the gate, which keeps its rules (closed until the gate battle is won). The old passage's
  cells, cracks, loose stones and scrub are gone; a fifth wall tower (x 23) stands where it was. Tested: every front-wall cell is solid but the gate's,
  and no point along the wall is walkable with the gate shut.
- **The west side wall** runs whole from the north wall to the front wall's corner tower (it was already there; it now takes the hole).
- **The grid grew 8 m west** (`CapitalLayout.GRID_X0` = -8, `W` 128): the strip of outside ground (x -5..-2, 3 m wide) runs north from the rift
  fields' north-west corner past the corner tower to z 60, between the west wall and the dead hills (the rim rises in full on its west side; it
  ends in rubble at its north end). It counts as the Rift Fields (no new place name shows as you walk it).
- **The hole** (`HOLE_Z0` 67, 2 m wide, `HOLE_HEIGHT` 2 m in the 9 m wall, `CapitalLandmarks.hole_piece`): the wall carries on over it; round the
  opening the stones have fallen out (a ragged edge of broken blocks, cracks running up, dark reveals and roof), a little rubble along its floor's
  sides. Outside a rubble heap and a dead bush flank its mouth (`hole_dressing`); the one hint for the curious is a faint draft of ash breathing
  out of it. It faces west, so the trailing camera only ever sees it edge-on, and the west wall never fades (it can never stand between the camera
  and the hero; a ghosted wall showed the strip from inside). Inside it comes out just south of the Reek's west yards (first at z 57, behind a yard, which hid the hero for a few steps; moved, CAP-50), its floor paved like the street.
  The hero just walks in: crossing the wall's middle switches the look as at the gate (`CapitalLayout.is_inside` and `CapitalScene._is_inside`
  now read x too), the first time sets the secret with a toast.
- **No sign, no marker, no map icon, no prompt**: none within 6 m of the hole; nothing solid in the strip; no spot of its own.
- **Quests, saves, text**: the passage's anchor (`wall_passage`) moved to the hole's inside end; the secret id is unchanged, so old saves keep it;
  the fog of war carries over (the map's origin moved; `FogOfWar.from_dict` copies the overlap). The only text that named the old place was the toast
  and the secrets doc (both updated); the objective still says "or find another way", which stays vague. The zone plans no longer name it.
- **Tests**: `tests/core/zone/test_capital_wall_passage.gd` rewritten (the front wall solid but for the gate, the west wall whole but for one small
  low hole, the route from the arrival round the corner tower, up the strip and through the hole walkable end to end with the gate shut, the
  strip narrow and nameless, nothing near the hole). The walk smoke now walks the strip and the hole.

**fps on Medium**: 60.0-60.1 at the Gate Road, the rift fields, the Reek, the Transit Yards and the plaza. **Checks**: GUT 1702/1703 (pre-existing CP-2).

## Part E: boundaries

Shots: `docs/art/capital_pass/part_e/`.

| | |
|---|---|
| ![](capital_pass/part_e/plan_outside.jpg) plan, outside: green = where the hero can stand | ![](capital_pass/part_e/edge_east_default.jpg) the east edge: the ash ridge, dead trees and rocks |
| ![](capital_pass/part_e/edge_east_overview.jpg) the east edge from Overview | ![](capital_pass/part_e/edge_south_default.jpg) the south edge: low rocks and rubble along it (the ridge rises out of the frame) |
| ![](capital_pass/part_e/road_out_overview.jpg) the road's end, the way home | ![](capital_pass/part_e/strip_end_default.jpg) the hidden strip's dead end: the ridge closes in |
| ![](capital_pass/part_e/castle_side_east_default.jpg) inside: the castle hill's terraces | ![](capital_pass/part_e/inside_north_wall_default.jpg) inside: the north wall |
| ![](capital_pass/part_e/inside_west_wall_default.jpg) inside: the west wall | ![](capital_pass/part_e/tunnel_mouth_default.jpg) the tunnel mouth in the front wall |

- **A blocker you can see everywhere the hero stops**: the great wall and its towers, the city's walls (their battered feet meet the paving; the
  floor no longer stops short of the west wall or runs into the east one), the castle hill's dressed terraces, the buildings and props, and outside
  the rim's rising ground with its rocks, rubble and dead trees. Where the rim is kept low for the camera (the south edge, beside the road, the
  strip's corner) a row of low half-sunk boulders and rubble runs right along the walkable edge (`CapitalRim._edge_row`). No invisible wall stands
  in open-looking ground: the old outside edges (an invisible stop before a stepped box wall, a flat plain beyond) are gone.
- **No open-looking ground the hero cannot enter**: beyond the walkable edge the land rises at once (a ridge 4-5 m up within a few metres), so
  nothing past the edge reads as more of the same floor; the road on beyond the south edge is the way home (its exit spot), between hills.
- **The walkable area grew where it logically should**: the hidden strip and its corner (Part D), the inner city floor up to the west wall's foot.
- **The road from Crosspath is the only way into the outside half**: nothing is walkable beyond the south edge; the road's end is the exit spot;
  hills rise either side of the road beyond it, as on the Crosspath side.
- **Checks** (`tests/world/test_capital_bounds.gd`, new): a flood from the arrival over a 0.5 m lattice with the gate open reaches only the intended
  ground (the outside, the strip and its corner, the hole, the gate's opening, the city); every walkable cell's non-walkable neighbour is a wall,
  a building, the hill, a wall tower, the rising rim or a rim rock / rubble / tree; the road is the only way out. The walkability probe
  (`test_walkability_zones`) still reaches every key location, and the west route to the hidden hole is walked end to end in
  `test_capital_wall_passage`. GUT 1702/1703 (pre-existing CP-2).

## Part F: verify

Shots: `docs/art/capital_pass/final/` (the ten regions at their paint-over cameras, the hidden hole's two ends) and the paint-over beside each
(`compare_<region>.jpg`, `tools/side_by_side.gd`).

**Each region beside its paint-over** (paint-over left, the game right; the framing differences are the cameras', CAP-36):

| | |
|---|---|
| ![](capital_pass/final/compare_gate_road.jpg) | ![](capital_pass/final/compare_resistance_camp.jpg) |
| ![](capital_pass/final/compare_rift_fields.jpg) | ![](capital_pass/final/compare_ruined_outpost.jpg) |
| ![](capital_pass/final/compare_gate_plaza.jpg) | ![](capital_pass/final/compare_palace_approach.jpg) |
| ![](capital_pass/final/compare_transit_yards.jpg) | ![](capital_pass/final/compare_hungry_quarter.jpg) |
| ![](capital_pass/final/compare_grave_row.jpg) | ![](capital_pass/final/compare_the_reek.jpg) |

**The castle from both halves**: over the wall from the Gate Road (`final/po_gate_road_default.jpg`) and at the avenue's end
(`final/po_palace_approach_default.jpg`); its west side over the forecourt (`part_c/castle_side_west_default.jpg`), its east side
(`part_e/castle_side_east_default.jpg`). **The front wall**: `part_d/wall_front_west_default.jpg`, `part_d/gate_closed_default.jpg`.
**The hidden hole** from the default camera, right beside it (hard to spot: the wall is seen edge-on, rubble and a dead bush flank its mouth):
`final/hole_close_default.jpg`; up close from a debug camera: `part_d/hole_from_the_west.jpg` (taken at its first place, z 57); its inside end with
the hero clear: `final/hole_inside_default.jpg`. **Each boundary type**: Part E's table. **The map's edge from Overview**:
`part_b/edge_south_overview.jpg`, `part_b/west_edge_south_overview.jpg`, `part_e/edge_east_overview.jpg`.

| | |
|---|---|
| ![](capital_pass/final/hole_close_default.jpg) right by the hidden hole (default camera) | ![](capital_pass/final/hole_inside_default.jpg) its inside end, the hero clear |

**The walk** (`bash tools/run_capital_walk_smoke.sh 0|2`, real input, windowed; `SMOKE_RES=1280x720` keeps it light): **138 checks, passing at the
Cinematic (0) and the Overview (2) camera**: the arrival road, the Gate Road up to the shut gate and its captain and guards, Kestrel at the camp,
the Old Service Tunnels' mouth, the ruined outpost, a rift-stone and a rift sealed, the hidden shaft, **round the front wall's west corner, up the
strip along the west wall and through the hidden hole into the city with the gate shut** (the secret found), the Gate Plaza's booth and box, a
citizen, a perfect door, a loudspeaker, a portrait, every district's quest giver and objects, the Ward, a hidden chest, the palace approach and the
castle door (it asks to enter Primm's Castle), **save and load inside**, back out through the opened gate and home to town, then back with the four
Paths freed: every district restored and welcomed. The rest of the front wall is covered by `test_capital_wall_passage` (no point along it is
walkable with the gate shut).

The walk found one thing, fixed: coming out of the hole at its first place (z 57) the hero was hidden for a few steps behind a Reek yard (a merged
model that does not fade); the hole moved to z 67-69, just south of the yards (CAP-50).

**fps on Medium** (`bash tools/capital_fps.sh 1`, the gate open, enemies held, the dev iGPU):

| Camera | avg fps | min fps | draw calls |
|---|---|---|---|
| po_gate_road | 60.0 | 60.0 | 424 |
| po_resistance_camp | 60.0 | 60.0 | 415 |
| po_rift_fields | 60.0 | 60.0 | 410 |
| po_ruined_outpost | 60.0 | 60.0 | 357 |
| po_gate_plaza | 60.0 | 60.0 | 428 |
| po_transit_yards | 60.0 | 60.0 | 410 |
| po_hungry_quarter | 60.0 | 60.0 | 399 |
| po_grave_row | 60.0 | 60.0 | 449 |
| po_the_reek | 60.0 | 60.0 | 340 |
| po_palace_approach | 60.0 | 60.0 | 495 |

**Checks**: GUT 1702/1703 (the one failure is the pre-existing camera-FOV test that reads the dev PC's saved settings, CP-2); new tests this pass:
`test_capital_pass`, `test_capital_order`, `test_capital_bounds`, `test_capital_wall_passage` (rewritten).

### What still doesn't match

- **The skies and the far trees**: the outside's sky is still a flat mauve against the paint-overs' storm clouds (CAP-SKY-STORM in the art pass's
  asset table); the inside still lacks the paint-overs' tall cypress (the shared pine card stands in, CAP-46).
- **The rim** is built from the ash ground texture, the kit's rubble cards, faceted boulders and dead trees; a painted cliff or ridge card set
  would lift it (CAP-42).
- **The castle** has more detail (lancet windows, pinnacles, cypress, dressed terraces) but is still built from kit primitives, not modelled
  tracery.
- **The Crease** (the underground hall) was not part of this pass (CAP-40).
- **Framing**: several paint-overs are painted from other places than their cameras (CAP-36), so compositions differ.
- **Right beside the hole inside the city**, at a closer saved zoom, the walk smoke's shot looked through the west wall for a moment; the shots at the
  default zoom show it solid. Worth a look in play.
