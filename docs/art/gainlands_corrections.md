# The Gainlands: corrective pass (playtest feedback, 2026-10-14)

Note (2026-10-15): the sub-areas mentioned below were removed by design (docs/design/subarea_removal.md); the locked Mount Swolympus gate is now a hub landmark (SR-4) and the walk smoke no longer has sub-area legs.

Scope: the Gainlands only, nothing new added. Judgment calls are GC-1.. in `docs/design/open_questions.md`.

## What the Gainlands has (before this pass; nothing was added or removed from this list)

| Place | Scene / data | Notes |
|---|---|---|
| **Swole Station** (hub) | `scenes/gainlands_zone.tscn` (`GainlandsScene`, layout `world/gainlands/gainlands_layout.gd`) | Arrival from town, rift station, Old Man Mountain, Foreman Gus, Benchley's (vendor), hot tub, flex mirror, protein stand, the giant chest, the vault lever, 13 hidden chests, the regions below |
| Hub regions (inside the hub scene) | Mill Meadow, Hamster Wheel Heights, The Boulder Gym, Studio 3AM, Leg Day Ridge | mills, the colossal wheels (run_wheel, puzzle), gym (Gary / spot me), the studio stage (rep minigame), the main dungeon entrance (The House of Gains) and the Iron Cavern (S-BEEF side dungeon) |
| Floating islands (inside the hub scene) | Pec Perch, Delt Deck, Glute Garden, Calf Cove | reached by throwers and portal rippers (`GainlandsTravel`), two chests each |
| **The Proving Grounds** | `data/subareas/gainlands/proving_grounds.json` | hub gate `gate_proving` (38, 73); Champions Arch, gym hall, stands, coach, shrine, two chests |
| **Mill Fields** | `data/subareas/gainlands/mill_fields.json` | off the Proving Grounds; the giant wheel, mill house, shrine, two chests |
| **Mount Swolympus Trailhead** | `data/subareas/gainlands/swolympus_trailhead.json` | hub gate `gate_trailhead` (45, 24); the mountain, the Trailhead Gate, gift shop clerk, rock lever, chest |
| **The Sky Garden** (secret) | `data/subareas/gainlands/sky_garden.json` | off the Trailhead (behind the rock lever's boulder); Sky Tree, floating islets, shrine, chest |
| Side dungeon | S-BEEF "The Ascent of Mount Swolympus" (`data/dungeons`, entered at the hub's Iron Cavern after the quest "Water for the Hermit") | |

## Part A: declutter the whole zone

Done (commit "Gainlands corrections, Part A"): see GC-1 .. GC-6.

- **Trees and rocks** (`GainlandsLayout`): 150 trees -> 72 in nine groves plus a rim band, 40 rocks -> 12, nothing within 2.4 m of a path edge or 5.5 m of an anchor; islands keep three pieces each.
- **Routes**: the four roads out of the hub are 4.2 m (the dungeon road 4.8 m), the spurs 3.4 m; the scatter and the dressing keep 2.4 m off every edge.
- **Hub dressing** cut to a third, flowers only along path edges, seven kit clusters at the edges.
- **Signs**: 30 -> 8 (GC-2).
- **Sub-areas**: scattered trees halved, looser edge belts, smaller flower clumps, wider paths (the data files; `SubAreaMap` unchanged).
- **Camera occlusion**: smooth transparency everywhere, tree cards fade themselves from the hero position, terrain and islands never fade, clouds stay under the meadow (GC-3, GC-4).
- **Water**: the meadow no longer dips under the water plane (GC-5).

| Spot | Before | After |
|---|---|---|
| Hub, Cinematic / Normal (`--at=spawn`) | ![](gainlands_corrections/gc_before_hub.jpg) | ![](gainlands_corrections/gc_after_hub.jpg) |
| Hub, Overview | ![](gainlands_corrections/gc_before_hub_overview.jpg) | ![](gainlands_corrections/gc_after_hub_overview.jpg) |
| Thrower Brock (`--at=thrower_pec`): the canopy used to hide him | ![](gainlands_corrections/gc_before_thrower.jpg) | ![](gainlands_corrections/gc_after_thrower.jpg) |
| The road north (`--pos=52,44`) | ![](gainlands_corrections/gc_before_path.jpg) | ![](gainlands_corrections/gc_after_path.jpg) |
| The dungeon gate (`--at=main_dungeon`; rebuilt in Part D) | ![](gainlands_corrections/gc_before_hog_gate.jpg) | ![](gainlands_corrections/gc_after_hog_gate.jpg) |
| The exit (`--at=exit`; the bridge comes in Part C) | ![](gainlands_corrections/gc_before_entrance.jpg) | ![](gainlands_corrections/gc_after_entrance.jpg) |
| Proving Grounds (paint-over camera; before = `gainlands_slice/PO-GAINLANDS-PROVING-GROUNDS.jpg`) | ![](gainlands_slice/PO-GAINLANDS-PROVING-GROUNDS.jpg) | ![](gainlands_corrections/PO-GAINLANDS-PROVING-GROUNDS.jpg) |
| Mill Fields (paint-over camera) | ![](gainlands_slice/PO-GAINLANDS-MILL-FIELDS.jpg) | ![](gainlands_corrections/PO-GAINLANDS-MILL-FIELDS.jpg) |

fps (Medium, `tools/fps.sh res://scenes/gainlands_zone.tscn 1`): avg 60.0, 766 draw calls. GUT: 1516 / 1517 (the one failure is GC-6, pre-existing).

## Part B: the hub

Done (commit "Gainlands corrections, Part B"): see GC-7. The central plaza is empty; the rift station, vendor, protein stand, hermit, Gus, tub, mirror and the boards stand round its rim with breathing room; four pennants at the outer rim; the dungeon road skirts the Station platform.

| Spot | Before | After |
|---|---|---|
| Hub, Cinematic / Normal | ![](gainlands_corrections/gc_before_hub.jpg) | ![](gainlands_corrections/gc_b_after_hub.jpg) |
| Hub, Overview | ![](gainlands_corrections/gc_before_hub_overview.jpg) | ![](gainlands_corrections/gc_b_after_hub_overview.jpg) |

The translucent disc under the hero is the entrance arch's portal swirl, removed in Part C. fps (Medium): 60.0 / 56.9 over two runs (the iGPU numbers move by several fps run to run). GUT: 1517 / 1518 (GC-6).

## Part C: the entrance

Done (commit "Gainlands corrections, Part C"): see GC-8, GC-9. No portal: a timber-and-rope bridge from the south rim out to a landing on the town side. The hero arrives on it facing the zone and walks in; the far end leaves for town (E on the landing, or simply walking off). The town passage leads onto the same bridge model.

| Spot | Before | After |
|---|---|---|
| Arrival (`--at=spawn`): the old spawn in the hub beside the arch; now the bridge, the hub ahead | ![](gainlands_corrections/gc_before_hub.jpg) | ![](gainlands_corrections/gc_c_after_arrival.jpg) |
| The exit (`--at=exit`): the arch and its swirl; now the landing with its banner posts | ![](gainlands_corrections/gc_before_entrance.jpg) | ![](gainlands_corrections/gc_c_after_entrance.jpg) |
| From the bridge, Overview (`--pos=52,84`) | | ![](gainlands_corrections/gc_c_after_bridge_side.jpg) |
| The hub from the bridge head (`--pos=52,69`): the swirl under the hero is gone | ![](gainlands_corrections/gc_b_after_hub.jpg) | ![](gainlands_corrections/gc_c_after_hub.jpg) |
| Town side (`town.tscn --at=portal_beefcake`): the passage, the rope bridge, the Gainlands island | | ![](gainlands_corrections/gc_c_after_town_passage.jpg) |

fps (Medium): 60.0 at the hub and 60.0 on the bridge. GUT: 1519 / 1520 (GC-6).

## Part D: the House of Gains

Done (commit "Gainlands corrections, Part D"): see GC-10. The fortress-gym towers beyond the north rim and shows from the hub, the studio, the quiz corner and the roads; its gatehouse and causeway replaced the placeholder gate.

| Spot | Before | After |
|---|---|---|
| From the hub (`--at=hub`) | ![](gainlands_corrections/gc_before_hog_from_hub.jpg) | ![](gainlands_corrections/gc_d_after_hog_from_hub.jpg) |
| From the Station platform (`--at=station`) | ![](gainlands_corrections/gc_before_hog_from_station.jpg) | ![](gainlands_corrections/gc_d_after_hog_from_station.jpg) |
| From Studio 3AM (`--at=minigame`) | ![](gainlands_corrections/gc_before_hog_from_studio.jpg) | ![](gainlands_corrections/gc_d_after_hog_from_studio.jpg) |
| From the quiz corner (`--at=quiz`) | | ![](gainlands_corrections/gc_d_after_hog_from_quiz.jpg) |
| The gate (`--at=main_dungeon`): white blocks, cone, boulders, tape and lettering; now the gatehouse, portcullis, causeway and icon board | ![](gainlands_corrections/gc_before_hog_gate.jpg) | ![](gainlands_corrections/gc_d_after_hog_gate.jpg) |
| The gate, Overview | | ![](gainlands_corrections/gc_d_after_hog_gate_overview.jpg) |

fps (Medium): 60.0 at the hub, 60.0 at the gate. GUT: 1521 / 1522 (GC-6).

## Part E: Mount Swolympus postponed

Done (commit "Gainlands corrections, Part E"): see GC-11 and `docs/backlog.md` ("Later"). The trailhead gate stands locked on the north-east rim beside the sealed Iron Cavern, the mountain shows in the distance beyond them, the quest and the side dungeon keep their data but are off until the postgame, and the Sky Garden hangs off the Proving Grounds.

| Spot | Before | After |
|---|---|---|
| The trailhead gate: on the dungeon road (`--pos=45,27`); now locked on the north-east rim (`--pos=82,35`) | ![](gainlands_corrections/gc_before_swolympus_gate.jpg) | ![](gainlands_corrections/gc_e_after_swolympus_gate.jpg) |
| The corner from Overview (`--pos=80,36`): the two wheels, the cavern, the locked gate | | ![](gainlands_corrections/gc_e_after_swolympus_overview.jpg) |
| The sealed Iron Cavern (`--at=mini_dungeon`), the locked gate at its side, the mountain beyond | | ![](gainlands_corrections/gc_e_after_cavern.jpg) |

fps (Medium): 59.9 at the hub, 60.0 at the wheel corner. GUT: 1523 / 1524 (GC-6).

## Part F: throwers

Done (commit "Gainlands corrections, Part F"): see GC-12. New e2e `bash tools/run_thrower_smoke.sh` (about 2 minutes, windowed): all ten travel routes with real input, 10 / 10 pass (apex, landing island and height, destination reach, walkable and open landing, control back, ways back down); GUT route test added. One real fix: the Pec Perch return landing moved clear of the windmill.

| Spot | Before | After |
|---|---|---|
| Brock, Heavy Heaver, from the road (`--at=thrower_pec`): hidden by canopy before Part A | ![](gainlands_corrections/gc_before_thrower.jpg) | ![](gainlands_corrections/gc_after_thrower.jpg) |
| Mid-flight to Pec Perch (thrower smoke, real input) | | ![](gainlands_corrections/thrower_pec_mid_air.jpg) |
| Landing on Pec Perch (11 m) | | ![](gainlands_corrections/thrower_pec_landing.jpg) |
| The return chuck's landing beside the mill, now clear | | ![](gainlands_corrections/thrower_pec_back_landing.jpg) |
| Delt Deck to Glute Garden, landing | | ![](gainlands_corrections/thrower_glute_landing.jpg) |

fps (Medium): 60.0 at the hub, 60.0 at Brock. GUT: 1524 / 1525 (GC-6).

## Part G: verify and report

Done (commit "Gainlands corrections, Part G"). Two windowed e2e runs with real input, both passing:

- `bash tools/run_gainlands_walk_smoke.sh` (about 3 minutes): arrival on the bridge and the walk north into the plaza; the House of Gains gate (prompt, no lettered plate, E asks to enter, Not yet gives the hero back); the locked Mount Swolympus gate (coming-soon prompt, E toasts and goes nowhere) and the sealed Iron Cavern (same); Proving Grounds -> Sky Garden -> Proving Grounds -> Mill Fields -> Proving Grounds -> hub (every gate and exit, every arrival on walkable ground); then south down the bridge and off its far end into town. One real bug found and fixed on the way (GC-13).
- `bash tools/run_thrower_smoke.sh` (about 2 minutes): all ten thrower and ripper routes (Part F).
- GUT: 1524 / 1525 (the one failure is GC-6, pre-existing and local to this PC); the walkability test (`tests/world/test_walkability_zones.gd`) and the sub-area gate test pass; `tests/world/test_gainlands_corrections.gd` adds 17 checks for this pass.

| Spot (walk smoke, real input) | |
|---|---|
| Arrival on the bridge | ![](gainlands_corrections/g_01_arrival_on_the_bridge.jpg) |
| The plaza, walked to from the bridge | ![](gainlands_corrections/g_02_the_plaza.jpg) |
| The House of Gains gate asks to enter | ![](gainlands_corrections/g_04_house_of_gains_ask.jpg) |
| The locked Swolympus gate, its prompt | ![](gainlands_corrections/g_05_swolympus_gate_locked.jpg) |
| E at the locked gate: the toast | ![](gainlands_corrections/g_06_swolympus_gate_toast.jpg) |
| Proving Grounds, Sky Garden, Mill Fields | ![](gainlands_corrections/g_09_proving_grounds.jpg) ![](gainlands_corrections/g_10_sky_garden.jpg) ![](gainlands_corrections/g_12_mill_fields.jpg) |
| Leaving over the bridge | ![](gainlands_corrections/g_15_leaving_over_the_bridge.jpg) |

### fps (Medium, 1600x900, `tools/fps.sh`, final pass)

| Scene / spot | avg fps | min fps |
|---|---|---|
| Hub (plaza) | 60.0 | 60.0 |
| Bridge (arrival) | 60.0 | 60.0 |
| House of Gains gate | 60.0 | 60.0 |
| Hamster Wheel Heights / locked corner | 60.0 | 58.8 |
| Proving Grounds | 60.0 | 60.0 |
| Mill Fields | 59.9 | 55.4 |
| Sky Garden | 60.0 | 60.0 |
| Swolympus Trailhead (data kept, not reachable) | 60.0 | 60.0 |

The iGPU numbers move by a few fps run to run; every scene sat at the 60 cap in at least one run.

## What changed (short list)

1. **Declutter** (A): trees 150 -> 72 in groves and a rim band, rocks 40 -> 12, hub dressing to a third, flowers along path edges only, boards 30 -> 8, sub-area trees halved and belts loosened, roads 4.2-4.8 m wide with 2.4 m clear either side, 5.5 m open ground round every NPC, vendor, gate and travel point. Smooth transparency occlusion (no dither anywhere), tree cards fade themselves from the hero position, terrain never fades, clouds stay under the meadow, the meadow never dips under the water.
2. **Hub** (B): an empty 8.5 m plaza with everything round its rim; the dungeon road skirts the Station platform.
3. **Entrance** (C): the portal arch is gone; a timber-and-rope bridge from the south rim to a town-side landing, arrival on it facing the zone, leaving by walking off its end; the town passage leads onto the same bridge.
4. **House of Gains** (D): a 48 x 34 x 30 m fortress-gym beyond the north rim (brick, iron, red-gold roofs, towers, portcullis gatehouse, dumbbells, flexing arms, banners, glowing windows, smoking chimneys), a lantern causeway onto the plateau with the entrance on it, no placeholder gate, no lettered plate.
5. **Mount Swolympus** (E): postponed to the postgame: locked gate and sealed cavern in the north-east corner, the quest needs the postgame, no marker, the mountain in the distance, the Sky Garden off the Proving Grounds. Data intact (`docs/backlog.md`, "Later").
6. **Throwers** (F): verified route by route with real input; one landing moved clear of the mill.

## Things to look at

- The causeway top shows the brass trim texture as a red-gold carpet into the gate, and the fortress rock cap reads like a plank deck at the gate (GC-10). Both are placeholders until GAIN-HERO-HOUSE-OF-GAINS concept art; say if either should be plain stone now.
- The Sky Garden is reached from the Proving Grounds east exit while the trailhead is locked; the rock-lever secret that used to guard it is on hold with the trailhead (GC-11).
- The pennant poles no longer sway (the toon wind bent the whole pole); only the flags would need a second mesh to sway again (GC-7).
- Far objects still use the dithered visibility fade of the engine over the last 6 m before the 48 m cull (GC-9); it is not the between-camera-and-hero fade, but it is a dither.
- The spot name plates (NPCs, the Iron Cavern, Back to Town) are still lettering near the hero, as before (the HUD vocabulary decision in `docs/backlog.md`); only the House of Gains plate was removed.
- `test_the_rig_aims_the_camera_low_and_pushes_the_look` fails on this PC before and after this pass (FOV 42 vs 44, saved camera settings; GC-6).
