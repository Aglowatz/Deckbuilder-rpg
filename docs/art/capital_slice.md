# The Capital slice: the layout fixed before its art pass

The Capital (zone id `final`, `scenes/capital_zone.tscn`) prepared for its art pass by the rollout playbook (`docs/art/zone_rollout_playbook.md`), with the lessons of the four Path zones (the Verdant Dump prep above all: layout first, stand-ins of the planned sizes, paint-over cameras as data). The Capital is ONE walkable zone in two halves joined through the great wall: OUTSIDE (south, the wasteland) and INSIDE (north, Primm's Perfection). There are no sub-areas and no walkable dungeon interiors: Primm's Castle (main), the Old Service Tunnels (mini) and S-CAP (side) are node maps entered from the zone. Gameplay, quests, NPC logic, story flags and the camera system are untouched. Judgment calls are CAP-1... in `docs/design/open_questions.md`.

## The regions (all in the one scene)

Coordinates are metres, x east, z south (north is up the screen, where the castle stands). `CapitalLayout._areas` names them (`OUTSIDE_REGIONS`, `INSIDE_REGIONS`); the HUD shows the title. The great wall stands on rows z 72-75, the gate opening at x 55-64, the secret passage at x 22-23.

**OUTSIDE** (z 76-121)

| Region (id) | Where | What is there | Stand-in landmark |
|---|---|---|---|
| **The Gate Road** (`gate`, the outside hub) | the centre, x 44-75, the road from town (x 57-63) straight up to the gate | the arrival (spawn 60, 114, facing north) and the way home at the road's end (60, 119.5); Captain Spotless (60, 77.5) and the height and queue guards (50 / 70, 77.5) at the gate; a rope queue along the west kerb; dead street lamps either side | **the great wall and the Approved Gate**: a 9 m crenellated wall across the whole map, two 14 m towers framing the 10 m opening, the barrier until the gate battle is won; **Primm's Castle** seen through the gate and over the wall |
| **The Resistance Camp** (`camp`) | south-west, below the south road | Kestrel (29.5, 111), the fire (34.5, 113.5, the camp's one real light), two patched tents, a lean-to with bedrolls, a rope of warm lanterns, a rag flag, crates; the wreck with its chest in the far corner | **the camp** (`CapitalLandmarks.camp`): the tents, lean-to and lanterns round the fire, a small warm refuge |
| **The Rift Fields** (`rifts`) | north-west, between the wall road and the south road | rift `out_a` (24, 92, sealable, its stone and its guardian) and rift `out_b` (35, 95.5); the hidden service shaft (the Old Joint Works, 4.5, 88.5) by a toppled statue; the abandoned checkpoint on the west track | **two clusters of tall violet rift crystals** (40, 89.5) and (21, 99), the stand-ins for CAPO-HERO-RIFT-A / -B |
| **The Ruined Outpost** (`outpost`) | south-east | the broken watchtower north of the south road, two fallen guardhouses and the second abandoned checkpoint south of it, an officer | **the broken watchtower** (91, 96.5), about 14 m, its crown bitten off and lying beside it (CAPO-HERO-BROKEN-WATCHTOWER) |
| **The Old Service Tunnels** (`tunnels`) | north-east, at the wall's foot | the mini dungeon's door (96, 78; sealed until its quest, as before), the clue board, a hidden chest in the corner | **the tunnel mouth** (96, 76): a great culvert arch in the wall's outer face, a dark throat, a half-raised rusted grate, two pipes along the wall (CAPO-HERO-SERVICE-TUNNEL) |
| **The Wall Passage** (`passage`) | x 16-29 at the wall | the 2 m gap at x 22-23 behind a crack, loose stones and dry scrub; no sign points to it | none (it is a secret) |

**INSIDE** (z 2-71)

| Region (id) | Where | What is there | Stand-in landmark |
|---|---|---|---|
| **The Gate Plaza** (`plaza`, the inside hub) | the centre south, an open round (r 10.5) about (60, 58) | the gate (60, 69.5) between the two exit-control guards, the exit interview booth, the complaint box, the suspicious manhole and the shaft's manhole on the rim, two banners at the avenue's mouth, roving Tidy-Bots on the boulevards | **the Primm statue fountain** at the centre (7 m across, a golden Primm on a column) |
| **The Palace Approach** (`approach`) | the centre north: the grand avenue (x 57-63) from the plaza to the castle stair, the forecourt along the hill's foot, the two pockets beside the hill | sixteen identical houses in four mirrored rows (the Showcase: two painted shops, the four perfect doors), nine citizens on the avenue and in the alleys, portraits, posters and loudspeakers in one line on each verge, the second complaint box; at the forecourt the castle door (60, 13) at the stair's foot, the approach's portraits; the two big rifts in the pockets | **Primm's Castle on its hill at the city's heart** (78 m wide, the hill 7 m, the keep and spires to about 53 m): a crenellated white-and-gold body, two great cone-roofed round towers and two smaller ones, a gatehouse with Primm's portraits, a central keep with four gold spires, glowing windows, the grand stair with two golden Primm statues (CAPI-HERO-PALACE-FACADE) |
| **The Reek** (`reek`) | west, south half | the Reek's back lane (x 17-21) from the wall passage north, Old Fern and her shack by the sick patch, the three banished compost heaps, the jar of old seed, rift `reek`, two junk piles | **the back lane**: the leaning rear walls of the houses either side of the lane (the same size, broken) |
| **Grave Row** (`grave`) | west, north half | the Grave Row lane (x 17-21) lined with two perfect rows of identical headstones, the permit office and the notary's booth with the stamp, Widow Pell and her parlour, the Pell family plot, rift `grave`, the corner chest | **the Grave Row lane**: the headstone rows and the crypts at its north end |
| **The Transit Yards** (`transit`) | east, south part | the tram shed, the three energy wheels in a row along the wall, Rollo, the main power cable, the big rift `transit`, two dead pylons | **the tram shed** (104.5-114.5, 49.5-55.5): an open shed on iron posts under a sawtooth roof over the dead tram, a clock in the gable (CAPI-HERO-TRAM-SHED) |
| **The Hungry Quarter** (`hungry`) | east, middle | the identical row: three identical shuttered stall-houses each side of the lane, mirrored; Chef Marlo and his cart, the paste dispenser, the three hidden recipe cards, rift `hungry` | **the identical row** (CAPI-HERO-IDENTICAL-ROW) |
| **The Correction Ward** (`ward`) | north-east, beside the castle hill | the walled white ward, its door to the south with the spontaneity-permit window beside it, five beds in a row, the corrected citizen, the loudspeaker, rift `ward`, two chests | **the ward**: clinical white walls with a pale teal band |

The underground hideout, **the Crease** (Wren, Fig Sly's black market, the Tea of Dissent, the fast-travel station, the service shafts), is unchanged: a separate hall reached by the hidden shaft, the manhole or the ladder (CAP-1).

The zone's dungeons (`data/dungeons/dungeons.json`): Primm's Castle (main, the castle door), the Old Service Tunnels (mini, the tunnel mouth), S-CAP (side, unlocked by its quest). All three are node maps.

## Part A: regions and layout

The playbook's declutter rules (section 5) applied to the whole zone before any dressing. Every quest NPC, the vendor, every chest, the rifts and their stones, the secret passage, the hidden shaft and every dungeon entrance still work; they all moved (the map grew, CAP-2) and the tests moved with them.

- **The map** (CAP-2): the wall moved 12 m south so the inside (70 m deep) holds seven regions and the castle hill; the outside grew to 46 m. Plan from above (the cells, the routes, blocking circles red, anchors blue, chests yellow, rifts violet, enemy homes orange, stand-ins magenta, paint-over cameras green; `Godot --headless -s res://tools/capital_plan.gd -- --out=<png>`): ![](capital_slice/a_capital_plan.jpg)
- **Routes as data** (`CapitalLayout.routes`, 20 main routes 4.2 m or wider): outside, the Gate Road (6 m), the wall road along the wall's foot, the south road, the west and east tracks, two loops either side of the road; inside, the grand avenue (6 m, paved 10 m), the forecourt along the hill, the two ring streets, the plaza boulevards, the district separators and lanes. Nothing solid within 2.4 m of a route edge (the great wall excepted, which the road and the avenue pass through), no rift within 0.5 m of one, every region on a loop (by design, see the plan; `test_every_region_is_reached_from_the_gate_road` floods from the arrival).
- **Breathing room**: no building within 0.6 m of any anchor, no scattered solid piece within 5.5 m of a person, no prop on a chest; no two readable signs or interact spots within 2.5 m (the gate plaques moved onto the towers, out of the opening; the ward's window beside its door, not in it); signs 68 down to 46 (CAP-7).
- **OUTSIDE, bleak but never confusing**: cracked roads through the ash, the great wall and gate across every view, the castle over it; the generic scatter only well off the roads and the people, the dead trees, ruins and carts in twelve edge clusters (CAP-8); the camp a small warm refuge with the zone's only warm light outside.
- **INSIDE, eerily perfect**: sixteen identical 4 m houses mirrored about the avenue, six identical stall-houses mirrored about the Hungry Quarter's lane, headstones in two perfect rows, crypts and ruins in neat rows the same size; wide spotless streets (the facade recipe only on the approach's lawns, no cracks but round the rifts); a straight grand avenue from the plaza to the castle stair (tested: symmetric, straight, the plaza open).
- **The goal you can see** (CAP-4, CAP-5): Primm's Castle at immense scale on its hill on the city's axis, never culled or faded; tested to be in frame from all ten paint-over cameras, inside and out. The Cinematic camera sees only about 6 degrees above the horizon, so the wall is 9 m (five hero-heights) and the castle's silhouette sits low and wide: from outside it shows over the wall from the rift fields, the camp and the outpost, and through the gate from the Gate Road.
- **District states**: see below.
- **Entrances**: arrival on the Gate Road facing north, the way home at the road's end; inside through the gate (once won) or the wall passage, on foot; no portal effects (tested).
- **Camera occlusion**: the fader's smooth per-instance transparency (no dither); the floor, the beyond-map planes and the castle never fade or cull, the great wall never culls; a great-wall piece that blocks the lens from just inside the city (the camera trails outside the wall) fades as usual and, once it is a faint ghost, is hidden until it no longer blocks (`CapitalScene._hide_wall_round_the_lens`, as the Dump's greenhouse, VD-22): no pop, and the Transit Yards went from 53 to 60 fps.

| Part A | Before (the zone as found) | After Part A |
|---|---|---|
| Outside, the arrival | ![](capital_slice/before_PO-CAPITAL-OUTSIDE-HUB.jpg) | ![](capital_slice/a_w_01_arrival_on_the_gate_road.jpg) |
| Inside, through the gate | ![](capital_slice/before_PO-CAPITAL-INSIDE-HUB.jpg) | ![](capital_slice/a_w_09_the_gate_plaza.jpg) |
| Up the Gate Road | | ![](capital_slice/a_w_02_up_the_road_to_the_gate.jpg) |
| Kestrel at the camp | | ![](capital_slice/a_w_05_kestrel_at_the_camp.jpg) |
| The Old Service Tunnels (sealed until its quest) | | ![](capital_slice/a_w_06_old_service_tunnels.jpg) |
| Through the wall passage into the Reek | | ![](capital_slice/a_w_08_through_the_wall_passage.jpg) |
| A perfect door on the approach | | ![](capital_slice/a_w_13_a_perfect_door.jpg) |
| Old Fern in the Reek | | ![](capital_slice/a_w_16_old_fern_in_the_reek.jpg) |
| Widow Pell in Grave Row | | ![](capital_slice/a_w_17_widow_pell_in_grave_row.jpg) |
| Rollo in the Transit Yards | | ![](capital_slice/a_w_19_rollo_in_the_transit_yards.jpg) |
| Chef Marlo in the Hungry Quarter | | ![](capital_slice/a_w_21_chef_marlo_in_the_hungry_quarter.jpg) |
| The Correction Ward | | ![](capital_slice/a_w_22_the_correction_ward.jpg) |
| The castle door at the stair's foot | | ![](capital_slice/a_w_25_the_castle_door.jpg) |
| Back out through the open gate | | ![](capital_slice/a_w_27_out_through_the_gate.jpg) |

The "before" shots show the old 7 m wall filling the outside, the arrival on the town road behind a brick barrier, the inside seen from behind the gate towers.

### District states

Each district's broken / restored state follows its Path zone's freed flag: `CapitalBuilder.story_context()` reads `ZoneCompletion.is_completed` for the four Path zones when the scene builds, and `_district_free` maps the region to its Path: the Reek to the Refusemancers (the Verdant Dump), Grave Row to the Necrocrats (the D.N.A.), the Transit Yards to the Beefcakes (the Gainlands), the Hungry Quarter to the Gourmands (the Endless Buffet). Primm's fall (`zone_final_completed`) restores everything. The same map drives the music (`MusicDirector.CAPITAL_DISTRICTS`) and the broken-service debuffs (`CapitalDebuffs`).

| District | Broken (as shot) | Restored (built today) |
|---|---|---|
| The Reek | leaning brick and stone ruins, junk piles, the sick patch | the ruins upright and lit, the junk tidied, the floor greener, the planted patch blooms (its own quest flag) |
| Grave Row | grey crypts with a ghostly glow, restless headstones, the permit office open | warm-lit crypts, tidy headstones, the permit office closed for good |
| The Transit Yards | the shed and the tram dark, the wheels idle, dead pylons and street lamps (the Blackout also darkens the whole zone) | the tram and the clock lit, the wheels freed, the pylons and lamps lit |
| The Hungry Quarter | shuttered stalls boarded across, the paste dispenser | stalls open with goods, striped awnings and lanterns, the dispenser freed |
| The Correction Ward, the approach, the plaza | perfect | only when Primm falls: the identical houses as leaning ruins, the statue fallen in the dry fountain, the citizens in their own colours, the loudspeakers silent, the castle's gold dimmed |

Both states share the same footprints, so neither crowds a route. What the restoration does not do yet is in `docs/backlog.md` ("The Capital layout pass: restoration and follow-ups").

**fps on Medium** (`bash tools/fps.sh res://scenes/capital_zone.tscn 1 --at=po_<region> --gate=true`, the dev iGPU, 60 fps is the cap):

| Spot | avg fps | min fps | draw calls |
|---|---|---|---|
| po_gate_road | 60.0 | 54.8 | 265 |
| po_resistance_camp | 60.0 | 46.7 | 299 |
| po_rift_fields | 59.9 | 50.2 | 301 |
| po_ruined_outpost | 60.0 | 60.0 | 221 |
| po_gate_plaza | 60.0 | 60.0 | 397 |
| po_transit_yards | 60.0 (53.0 before the wall fix) | 28.3 (one hitch) | 445 |
| po_hungry_quarter | 60.0 | 60.0 | 346 |
| po_grave_row | 60.0 | 60.0 | 316 |
| po_the_reek (final spot, 17.5, 64) | 59.6 (56.5 at the first spot before the wall fix) | 17.0 (one hitch) | 445 |
| po_palace_approach | 60.0 | 60.0 | 409 |

**Checks**: 1587 GUT tests, all passing (GC-6, the local camera-FOV test, flips run to run on this PC and failed in one of the runs); the new `tests/world/test_capital_slice.gd` (the thirteen regions, the routes, the loops, the open ground, the prompts, the symmetry and the plaza, the castle and its frame, the stand-ins, the cameras, the way in and the wall, the district states, the dungeon doors' plates), `tests/core/zone/test_capital.gd` and `test_capital_wall_passage.gd` (updated for the moved wall), the walkability probe (`test_walkability_zones`, 120 key locations reached); the windowed walk smoke `bash tools/run_capital_walk_smoke.sh <camera>` (29 screenshots, 114 checks: the arrival and the walk up the Gate Road, the gate captain and a guard, Kestrel, the tunnels' door, a rift-stone and the hidden shaft's prompt, through the wall passage on foot with the gate shut, the plaza's booth and box, a citizen, a door, a loudspeaker, a portrait, every district's quest giver and objects, the Ward, a hidden chest, the castle door asking to enter Primm's Castle, back out through the opened gate and home) passes at the Cinematic (0) and the Overview (2) camera. The smoke holds the roaming enemies still (a patrolling Tidy-Bot bumped the hero off its scripted line; battles have their own smokes).

**Things to look at**: the stand-ins are plain primitives in the zone's colours and the painted-texture binding paints most of them brick (the wheels, the shed, the camp's lean-to); the castle reads pale through the outside's fog (CAP-11); the Old Service Tunnels' door shows "sealed" until its quest, as before; the tenth-brief smoke walks some hard-coded positions of the old layout and was not re-run (backlog).

## Part B: paint-over inputs

One clean shot per region at Cinematic / Normal, 1600 x 900, the hero visible, no UI, no world labels or spot markers, the gate open (so the inside cameras do not look through the barrier), every district in its broken state (no Path free): `bash tools/capital_po_shots.sh PO` (it runs `tools/shot.sh res://scenes/capital_zone.tscn ... --at=po_<region> --gate=true --nohud=true --clean=true --wait=2.6 --set=camera_angle:0,camera_zoom:1.5` and copies each to `docs/art/paintover_inputs/capital/PO-CAP-<REGION>.png`). Copied to `G:\My Drive\Card Game Art\Paintover_Inputs\capital\` (the folder created; nothing else in the Drive touched). The cameras are layout data (`CapitalLayout.PO_CAMERAS`, the hero's standing spot; the camera looks north from behind), so the final art pass shoots the same views; each stands on open ground a spot radius off every interact spot and off every enemy's beat (tested), and each has Primm's Castle in frame (tested: its front within 34 degrees of north).

| File | Camera spot (x, z) | What it frames |
|---|---|---|
| `PO-CAP-GATE-ROAD.png` | `po_gate_road` (60, 101) | the Gate Road from the queue up to the Approved Gate between its towers, the captain and the guards, the queue posts and dead lamps, ruins and dead trees in their clusters, Primm's Castle through the gate |
| `PO-CAP-RESISTANCE-CAMP.png` | `po_resistance_camp` (34.5, 115.6) | the camp round the hero: the two tents, the lantern rope and the fire's glow, the lean-to and its flag, Kestrel; beyond, the south road, the rift fields' crystals and rifts, the great wall, the gate towers and the castle over the wall |
| `PO-CAP-RIFT-FIELDS.png` | `po_rift_fields` (30, 101.5) | the two rifts with their crystal clusters (the guardian and an empowered officer by them), the abandoned checkpoint, the great wall with the passage's stretch, the castle's keep and towers over the wall |
| `PO-CAP-RUINED-OUTPOST.png` | `po_ruined_outpost` (92, 109.5) | the broken watchtower and its fallen crown ahead, a fallen guardhouse left, the abandoned checkpoint right, the tunnel mouth in the wall behind, the castle over the wall |
| `PO-CAP-GATE-PLAZA.png` | `po_gate_plaza` (54, 53), beside the fountain | the Primm statue fountain right, the open plaza, the bench and the manhole, the avenue's mouth with its banners, the identical houses, the castle on its hill at the avenue's end |
| `PO-CAP-PALACE-APPROACH.png` | `po_palace_approach` (60, 35.5), on the avenue | the straight grand avenue between the identical houses, the citizens, the verge lines of lamps, portraits and loudspeakers, the stair with its golden statues and Primm's Castle at the end |
| `PO-CAP-TRANSIT-YARDS.png` | `po_transit_yards` (96, 64), between two energy wheels | the wheels either side, the big rift and its swarm left, the tram shed right, Rollo, the Hungry Quarter and the castle beyond |
| `PO-CAP-HUNGRY-QUARTER.png` | `po_hungry_quarter` (100, 41), on the lane | the identical row of shuttered stall-houses either side of the lane, Marlo's cart, the dispenser, the rift, the Ward's walls ahead, the castle top left |
| `PO-CAP-GRAVE-ROW.png` | `po_grave_row` (22, 34), at the lane's south end | the Grave Row lane between its two rows of identical headstones, the crypts at its end, the permit office left, the Pell parlour and the rift right, the castle top right |
| `PO-CAP-THE-REEK.png` | `po_the_reek` (17.5, 64), the back lane | the back lane between the leaning ruins, the junk, the boulevard, the rift and Fern's corner beyond, the castle top right (the first spot, 19 / 66, left the wall's end by the passage as a slab on the right edge) |

| | |
|---|---|
| ![](capital_slice/b_PO-CAP-GATE-ROAD.jpg) GATE-ROAD | ![](capital_slice/b_PO-CAP-RESISTANCE-CAMP.jpg) RESISTANCE-CAMP |
| ![](capital_slice/b_PO-CAP-RIFT-FIELDS.jpg) RIFT-FIELDS | ![](capital_slice/b_PO-CAP-RUINED-OUTPOST.jpg) RUINED-OUTPOST |
| ![](capital_slice/b_PO-CAP-GATE-PLAZA.jpg) GATE-PLAZA | ![](capital_slice/b_PO-CAP-PALACE-APPROACH.jpg) PALACE-APPROACH |
| ![](capital_slice/b_PO-CAP-TRANSIT-YARDS.jpg) TRANSIT-YARDS | ![](capital_slice/b_PO-CAP-HUNGRY-QUARTER.jpg) HUNGRY-QUARTER |
| ![](capital_slice/b_PO-CAP-GRAVE-ROW.jpg) GRAVE-ROW | ![](capital_slice/b_PO-CAP-THE-REEK.jpg) THE-REEK |

**The stand-ins in the pictures** (what the painter replaces): Primm's Castle and its hill and stair (78 x 46 x 44 m on a 7 m hill), the great wall (9 m) and the gate towers (14 m), the Primm statue fountain (7 m across), the rift crystals (two clusters to 4.5 m), the broken watchtower (about 14 m), the tunnel mouth (9 x 7 m in the wall's face), the camp (two tents, a lean-to, a lantern rope), the tram shed (10 x 6.5 x 6 m), and, from the layout's own buildings, the identical row, the Grave Row lane's crypts and headstones, the Reek's leaning ruins and the Correction Ward's walls. The painted-texture binding paints many of the plain stand-ins brick (the wheels, the shed, the ruins); the outside's fog leaves the castle a pale silhouette (CAP-11). Enemies stand where they roam (by the rifts outside, the swarm in the Transit Yards). No PO shot is taken of the Correction Ward, the Old Service Tunnels or the wall passage (not asked; the walk smoke's `w_22`, `w_06` and `w_08` show them).

**fps on Medium** at the ten camera spots: the Part A table above (60 fps average everywhere but the Reek's final spot at 59.6).
