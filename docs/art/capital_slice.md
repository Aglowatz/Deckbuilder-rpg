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

# The art pass

The Capital dressed with its approved zone kit (`Approved_ZoneKits/Capital`, the sheet `data/source/capital_kit.csv`) and matched to its ten paint-overs (`docs/art/paintovers/PAINTOVER-CAP-*.png`) by the rollout playbook, on the layout above: routes, regions, positions, the wall and the passage, the castle's placement and the ten cameras are unchanged. Judgment calls are CAP-12... in `docs/design/open_questions.md`.

## Part A: import

- **The kit** (`bash tools/import_zone_kit.sh final`, CAP-12): the Capital is zone `final`, its folder and its sheet mapped in `data/source/art_config.cfg` (`zonekit_folders`, the new `zonekit_sheets`). 39 of the sheet's 40 ids imported first time; **CAP-PATH-WHITE is truncated on the Drive** (546 of 1024 rows, no end chunk) and was rebuilt from its readable half (CAP-13: ask the painter to re-upload it). The ten paint-overs sat in the kit folder (unmatched files, as expected) and were copied to `docs/art/paintovers/`. Two notes: the two skies are opaque pictures (used as sky panoramas, as the Dump's). Report: `docs/art/zone_kits/final_import_report.md`; registry `data/art/zone_kits/final.json` (with aliases for the reused TEX-CAP-* textures and DEC-RIFT / -CRACKS / -SCORCH).
- **Slices and pivots**: all six sheets cut cleanly (doors, outpost doors and windows, rubble, banners, civic signs); pivots read right (the bench, the lamp, the tram, the campfire at their feet; the trees at their trunks). Nothing reads as pixel art (CAP-15). Derived tiles: the three bands of CAP-WALL-PASTEL as their own tiles and a pink CAP-ROOF-PASTEL (CAP-14, `tools/capital_kit_derive.gd`).
- **Hero landmarks** (`world/capital/capital_landmarks.gd`, `capital_castle.gd`, `capital_districts.gd`, shared pieces in `capital_kit.gd`; "CAP-HERO-" in `HeroLandmarks.BUILDERS`): every stand-in replaced in place by a model built from its concept with the kit's painted surfaces, one mesh per model.

| Concept | Model | Where |
|---|---|---|
| CAP-HERO-PRIMMS-CASTLE | the white-and-gold palace on its terraced hill: the keep's portal with the great arched doors of mirrored glass and the colossal smiling emblem under a gold gable, two long wings of mirrored windows, sixteen round towers with blue cone roofs and gold finials, the central spire, the grand stair with its balustrades, lamps and banners, the marble Primm on the landing, hedges, topiaries and rose beds; hairline cracks leaking a slowly pulsing rift light | the city's heart (Part B) |
| CAP-HERO-GREAT-WALL-GATE | the great wall and the city wall as one flawless white wall (plaster, gold band, pilasters with finials, Primm's banners, crenellations, a few hairline cracks outside), the two gate towers (gold spires, the sun-faced banners), the gate's crown (lintel, gold arch outline, the radiant sun-emblem) | rows z 72-75 and round the city |
| CAP-HERO-PRIMM-FOUNTAIN | the marble basin with its gold rim and rose planters, the middle tier with face medallions and four gold spouts, the marble Primm, arms spread; mist; dry and toppled once Primm falls | the Gate Plaza's centre |
| CAP-HERO-RIFT | scorched rift ground, a glowing rim at the hazard's reach, the jagged tear (bright violet edges, a near-black heart), floating stone and crystal shards turning, crystals at its foot; every copy varied by its id (size, turn, lean); the distortion lens fitted to the tear and edgeless (CAP-20) | every rift, outside and in |
| CAP-HERO-WATCHTOWER | the ash-blackened tower with its jagged broken crown and timbers, the arrow slit and splintered door from the outpost sheet, the four Paths' tattered banner with their four essences, rubble and the fallen crown | the ruined outpost |
| CAP-HERO-SERVICE-TUNNEL | the stone arch in the wall's foot, the iron hatch from the outpost sheet, a dim cold lantern, dead branches, rift crystals | the Old Service Tunnels |
| CAP-HERO-RESISTANCE-CAMP | the patched tents in Beefcake red and Necrocrat teal with Gourmand and Refusemancer patches and all four essences, the copper lean-to, the green rag banner, the warm lantern rope and its light, crates and barrels, the old stone ruins it shelters in (CAP-19) | the camp |
| CAP-HERO-TRAM-SHED | the white-and-gold arcade of three arched bays, a pastel tram in each under a Primm banner, the slate-blue glass roof; broken / restored | the Transit Yards |
| CAP-HERO-IDENTICAL-ROW | six identical half-timbered bakeries (gold frame, pink roof, striped awning, display windows, a pink door with Primm's face); broken / restored | the Hungry Quarter |
| CAP-HERO-GRAVE-ROW | the white-and-gold mausoleums (blue roof, gable emblem, arched gold door, lanterns); broken / restored | Grave Row |
| CAP-HERO-THE-REEK | the back yards: a perfect painted screen hiding the bins, bags and stink (broken); compost bins, a raised bed of flowers, moss and vines (restored) | the Reek |
| CAP-HERO-CORRECTION-WARD | the compound's white walls with barred mirrored windows and turrets, the palace front with its dome and Primm's sign over the gold door (CAP-17) | the Correction Ward |

- **Skies and backdrops** (`data/art/zone_looks.json`): CAP-SKY-DUSK wrapped round the sky outside, CAP-SKY-NOON inside (no clouds: unnaturally even), the CAP-BD-WASTELAND horizon on the far ring outside and the CAP-BD-CITY skyline inside (six cards each at 60 degrees, BF-7).
- Also replaced: the rift crystal clusters (the kit's crystals on rift ground), the wasteland's dead trees, ruins and rubble (the kit's dead tree, ash-stone ruins with the outpost sheet's windows, the rubble sheet's pieces, ash drifts) and the outpost's fallen guardhouses (kit ruined houses).
- The kit on a checker (`tools/kit_contact_sheet.gd`): ![](capital_slice/cap_kit_sheet.jpg)

The ten cameras after Part A (`bash tools/capital_po_shots.sh a`: now with `--still=true`, CAP-21; the Tidy-Bot still visible ahead of the hero on the Gate Road is at its home there, layout data):

| | |
|---|---|
| ![](capital_slice/a_po_gate_road.jpg) GATE-ROAD: the white great wall, the gate's crown, the castle's cones over the wall | ![](capital_slice/a_po_resistance_camp.jpg) RESISTANCE-CAMP |
| ![](capital_slice/a_po_rift_fields.jpg) RIFT-FIELDS: the kit's rifts and crystals | ![](capital_slice/a_po_ruined_outpost.jpg) RUINED-OUTPOST: the watchtower, a kit ruin |
| ![](capital_slice/a_po_gate_plaza.jpg) GATE-PLAZA: the fountain, the castle at the avenue's end | ![](capital_slice/a_po_palace_approach.jpg) PALACE-APPROACH |
| ![](capital_slice/a_po_transit_yards.jpg) TRANSIT-YARDS: the tram shed | ![](capital_slice/a_po_hungry_quarter.jpg) HUNGRY-QUARTER: the identical row |
| ![](capital_slice/a_po_grave_row.jpg) GRAVE-ROW: the mausoleums | ![](capital_slice/a_po_the_reek.jpg) THE-REEK: the screens and bins |

**fps on Medium after Part A** (`bash tools/capital_fps.sh 1`, a new wrapper of `tools/fps.sh` over the ten cameras with the gate open and the enemies held): 60.0 average at the gate road (59.9), the camp, the rift fields, the outpost, the plaza, Grave Row, the Reek and the approach; the Hungry Quarter 55.2 and the Transit Yards 58.3 at first. A/B with the new knobs (`CAPITAL_HIDE=<name,...>`, `CAPITAL_NO_SHADOW=1`): the rifts' lights were the cost (an 8-12 m reach where several rifts share a view); their reach is now 4-6 m, round the tear and its scorched ground: 58.2 and 58.7. Readings near 16.7 ms are bimodal (VD-22); the rest is Part F's. The repeated district models (the identical row, the mausoleums, the Reek's yards, the outpost ruins) and the shared gold, mirror and water materials are set up for `KitBatch`.

**Checks**: 1593 GUT tests, all passing (new: `tests/world/test_capital_art.gd`, the Capital's registry in `test_zone_kit.gd`).

## Part B: Primm's Castle

The face of the finale, matched to its concept and to PAINTOVER-CAP-PALACE-APPROACH (`world/capital/capital_castle.gd`): immense (about 82 m across, its spire 56 m up on the 7 m hill), gleaming white plaster and rich gold, perfectly symmetric about the grand avenue, eighteen towers with blue cone roofs and gold finials (a back row and a tall pair added so the cones fill the band seen over the wall), the keep's portal with its great arched doors of mirrored glass in gold frames, the colossal smiling emblem under a gold-edged gable, two wings of tall mirrored windows with Primm's great banners, balustrades along both terraces with rose planters, clipped hedges, topiaries, lamps, the grand stair with its gold rail, the marble Primm on the landing, and hairline cracks up the portal, the keep, a wing and the front towers leaking a faint violet light that pulses slowly (`CapitalBuilder.animate`).

- **The castle door** (CAP-25): a white-and-gold gateway over the stair's foot, two banded piers with finials and lamps, a gold arch, and Primm's crown in its gold frame (the civic sign sheet) on the crest: the main dungeon door's icon sign. Everything stands on the hill, off the forecourt (tested); the door spot still opens the node map.
- **Seen from both halves and over the wall** (CAP-22, CAP-23): never culled or faded; its own lighter haze in place of the outside fog reads its cones, keep and spire over the great wall from every outside camera, and the gate's crown was lowered so the Gate Road sees the keep over it. Inside, from the plaza the whole face reads (doors, emblem, gable, crown sign); from the approach the frame's top (about 16 m up at 40 m) shows the doors and the emblem's smile.
- **When Primm falls** (CAP-24): the cracks go dark, the gold dims, the emblem cracks and hangs under a dark cloth, the mirrored panes become warm lit windows, the crown sign dims; the freed preset's exposure fixed so the light is warm and honest, not glare.

| | Broken (as it stands) | Primm has fallen (`--flags=zone_final_completed`) |
|---|---|---|
| The palace approach | ![](capital_slice/b_po_palace_approach.jpg) | ![](capital_slice/bf_po_palace_approach.jpg) |
| The Gate Plaza | ![](capital_slice/b_po_gate_plaza.jpg) | ![](capital_slice/bf_po_gate_plaza.jpg) |
| Over the wall: the Gate Road | ![](capital_slice/b_po_gate_road.jpg) | ![](capital_slice/bf_po_gate_road.jpg) |
| Over the wall: the rift fields | ![](capital_slice/b_po_rift_fields.jpg) | ![](capital_slice/bf_po_rift_fields.jpg) |
| Over the wall: the camp, the outpost | ![](capital_slice/b_po_resistance_camp.jpg) | ![](capital_slice/b_po_ruined_outpost.jpg) |
| From the districts: the Transit Yards, Grave Row | ![](capital_slice/b_po_transit_yards.jpg) | ![](capital_slice/b_po_grave_row.jpg) |

Also in Part B: the rift's tear keeps its HDR only in its rim (a brighter tear bloomed over its own dark heart). **fps on Medium**: the approach 59.9, the plaza, the Gate Road and the rift fields 60.0. **Checks**: 1594 GUT, all passing (the castle never reaches onto the forecourt, the crown sign; a stray backup of the builder in an ignored folder broke the compile-all test once and was removed).

## Part C: outside

Bleak but readable, per the five outside paint-overs:

- **Ground**: the painted terrain of earlier batches (TEX-CAP-ASH, -DEADGRASS, -CRACKEDROAD), the kit's rift-scorched earth (CAP-GROUND-RIFT) and crystals (CAP-PLANT-CRYSTAL) only round the rifts, soft ash drifts (CAP-DEC-ASH) over the open ground and under the clusters, the painted scorch and crack decals.
- **Ruins and wreckage**: the outpost's fallen houses (pale crumbling CAP-WALL-RUIN, slumped CAP-ROOF-BROKEN, charred timbers, the outpost sheet's splintered and barred doors and broken windows), the abandoned checkpoints as board shacks with boarded windows, the wasteland's edge clusters of dead trees (CAP-TREE-DEAD), ash-stone ruins and the rubble sheet's pieces, the toppled statue as Primm's broken marble head on a gold-banded plinth slab, the camp's wreck as the broken cart and scattered crates, the map's south and side edges as kit rubble and ash stone (they were boulders the painted binding drew as red brick).
- **The rifts**: bright purple, the strongest colour outside, each with a real light pulsing gently (reach 4-6 m, Part A).
- **The great wall**: flawless and pristine against the ruin, the gold-trimmed gate (two white leaves in gold lattice with Primm's emblem, CAP-29) under the radiant sun-emblem, a few hairline cracks.
- **The resistance camp**: the only warm light outside (the flickering fire, the lantern rope, the tents' lanterns, CAP-26, CAP-28), the four Paths' colours and essences on its canvas, sheltered by its ruins.
- **Grade** (CAP-27): from near-grey to the paint-overs' mauve-brown overcast dusk; median luma now 96-110 (paint-overs 82-109, the layout pass 60-69), the hero the clearest thing on screen.

| | |
|---|---|
| ![](capital_slice/c_po_gate_road.jpg) GATE-ROAD | ![](capital_slice/c1_gate_closed.jpg) the gate closed (before the gate battle) |
| ![](capital_slice/c_po_resistance_camp.jpg) RESISTANCE-CAMP | ![](capital_slice/c_po_rift_fields.jpg) RIFT-FIELDS |
| ![](capital_slice/c_po_ruined_outpost.jpg) RUINED-OUTPOST | |

| image | mean RGB | luma p5 / p50 / p95 | saturation |
|---|---|---|---|
| PAINTOVER-CAP-GATE-ROAD | 116, 97, 92 | 40 / 101 / 172 | 0.25 |
| after Part C | 132, 117, 116 | 56 / 105 / 199 | 0.15 |
| PAINTOVER-CAP-RESISTANCE-CAMP | 101, 83, 81 | 33 / 82 / 163 | 0.23 |
| after Part C | 132, 114, 114 | 55 / 110 / 197 | 0.17 |

**fps on Medium**: 60.0 at all four outside cameras. **Checks**: 1595 GUT; the outskirts' presets stay "sickly" and the blackout darker (two art tests caught the first pass and the colour moved into the post grade), the outside lights test added.

## Part D: inside

Perfect but quietly wrong, per the six inside paint-overs:

- **Walls and roofs**: pristine plaster (CAP-WALL-PLASTER), the pastel bands (CAP-WALL-PASTEL as three tiles), pastel roofs (blue and the derived pink), gold trim (CAP-TRIM-GOLD) on every eave; the Showcase's sixteen identical houses as one kit mesh with the doors sheet's door (one in sixteen with a heart, CAP-31), the two painted storefronts, the identical row of the Hungry Quarter (Part A), the Correction Ward cheerful outside and sinister in detail (barred mirrored windows, the smiling sign, an empty lawn).
- **Roads**: white roads with their gold centre line and gold kerbs (CAP-PATH-WHITE) along the ring streets, boulevards, separators and the forecourt; the avenue, the plaza and the lanes keep the pastel plaza paving and the perfect lawn of the paint-overs.
- **Rows** (CAP-30): topiary cones in gold pots, identical rose beds, identical lampposts and benches in exact rows; the lamps and benches of the plaza and the avenue are the kit's cards; the polish shine on the plaza and down the avenue.
- **Banners and signs** (CAP-32): Primm's white-and-gold banners on gold poles, the civic sign sheet's icons on the district plaques, white-and-gold boards.
- **The tram**: the pastel tram in each bay of the tram shed (Part A).
- **Symmetry**: the layout pass's mirrored rows kept; the rows follow the roads on both sides alike.
- **Light** (CAP-33): flat, nearly shadowless noon (shadows at 0.3), a warmer post grade; the fountain crisp and gleaming at the plaza's centre.

| | |
|---|---|
| ![](capital_slice/d_po_gate_plaza.jpg) GATE-PLAZA | ![](capital_slice/d_po_palace_approach.jpg) PALACE-APPROACH |
| ![](capital_slice/d_po_hungry_quarter.jpg) HUNGRY-QUARTER | ![](capital_slice/d_po_transit_yards.jpg) TRANSIT-YARDS |
| ![](capital_slice/d_po_grave_row.jpg) GRAVE-ROW | ![](capital_slice/d_po_the_reek.jpg) THE-REEK |

| image | mean RGB | luma p5 / p50 / p95 | saturation |
|---|---|---|---|
| PAINTOVER-CAP-GATE-PLAZA | 192, 174, 153 | 95 / 179 / 236 | 0.25 |
| after Part D | 208, 185, 168 | 124 / 197 / 224 | 0.26 |
| PAINTOVER-CAP-HUNGRY-QUARTER | 198, 178, 157 | 82 / 192 / 234 | 0.31 |
| after Part D | 212, 182, 170 | 139 / 195 / 224 | 0.24 |

**fps on Medium**: the plaza 59.8, the Transit Yards 60.1, the Hungry Quarter 59.0, Grave Row, the Reek and the approach 60.0. **Checks**: 1596 GUT, all passing (new: the rows keep off the routes and the people, the identical houses wear the doors sheet).

## Part E: the districts heal

Each service district has two states on the same footprints (no route changes, tested), the broken one matching its paint-over and the left half of its concept, the restored one the right half: the Path's personality back in the perfect city, less uniform and more alive (CAP-16, CAP-35). The state follows the Path zone's freed flag; Primm's fall restores all four.

| District (Path) | Broken | Restored |
|---|---|---|
| **The Transit Yards** (the Gainlands, the Beefcakes): the trams stalled grey in a dark arcade, pale still wheels, dead pylons, holes in the glass roof, dead shrubs, grime | ![](capital_slice/e_po_transit_yards.jpg) | ![](capital_slice/e_po_transit_yards_restored.jpg) red-and-gold spokes and bunting, the arcade's lanterns and globes lit, the trams in colour, lit pylons, roses |
| **The Hungry Quarter** (the Endless Buffet, the Gourmands): cold ovens, empty shelves with bowls of grey paste, torn awnings, dark lanterns, the paste dispenser's grey slop | ![](capital_slice/e_po_hungry_quarter.jpg) | ![](capital_slice/e_po_hungry_quarter_restored.jpg) warm ovens glowing, cakes, loaves and berries on the shelves, copper pots, cream awnings, flowers, Marlo's cart with loaves, a cake and steam |
| **Grave Row** (the D.N.A., the Necrocrats): leaning headstones, unfiled paper, restless ghosts drifting, mausoleum doors ajar on darkness, papers piled at the permit office | ![](capital_slice/e_po_grave_row.jpg) | ![](capital_slice/e_po_grave_row_restored.jpg) upright stones with flowers and calm green lanterns, the doors shut gold, topiaries, the permit office shuttered for good |
| **The Reek** (the Verdant Dump, the Refusemancers): perfect painted screens hiding overflowing bins, black bags, grime and flies | ![](capital_slice/e_po_the_reek.jpg) | ![](capital_slice/e_po_the_reek_restored.jpg) the screens gone; clean compost bins, raised beds of flowers and greens, moss and vines on the walls, Fern's warm window |

**The change, earned** (CAP-34): the first time the hero walks into a freed district (before Primm falls), its lights flicker on, the Path's sting rings over its restored music, a burst of the Path's colours, and four citizens in its colours gather beyond the hero and cheer, then go home. Once per save, no words, input never blocked. The fuller moment (the concepts' working crews as NPCs) is in `docs/backlog.md`.

| The Transit Yards welcome | Grave Row welcome |
|---|---|
| ![](capital_slice/e_welcome_transit_yards.jpg) | ![](capital_slice/e_welcome_grave_row.jpg) |

**fps on Medium**, broken / restored: the Transit Yards 59.3 / 60.0, the Hungry Quarter 59.6 / 60.1, Grave Row 60.0 / 60.0, the Reek 60.0 / 60.0. **Checks**: 1597 GUT, all passing (the welcome's rules, both states on the footprint).
