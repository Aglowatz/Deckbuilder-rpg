# The Gainlands: corrective pass (playtest feedback, 2026-10-14)

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

