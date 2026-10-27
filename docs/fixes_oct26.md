# Fixes Oct 26

Six parts, one commit each (pushed): Part 1 `88d43303`, Part 2 `f02f9700`, Part 3 `01348a78`, Part 4 `fa07f59e`, Part 5 `946c16d1`, Part 6 `1e3c3897`.
Questions and the safe choices taken: `docs/overnight_inbox.md`, section "Fixes Oct 26". Old saves load unchanged (no save format touched; the
settings file gains version 3, converted once). No new art was generated; the black market vendors were not touched.

Checks after the last part: GUT root 276, core 1414 (+1 known pending), ui/audio/characters 226, world 409 - all passing. Walk smokes: Crosspath,
Gainlands, Buffet, D.N.A., the Dump, the Capital - all OK. `perf_budget.sh structure` OK; `perf_budget.sh frame` met everywhere (Medium draw-call
lines of six areas raised in Part 1, see there; Crosspath and Capital-outside p99 spiked once on a first run and passed on the re-run).

## Part 1 - Shadows to the edge of the view

**What changed.** The sun's shadow stopped at 26 m on Medium (48 m on High). It now reaches each area's measured view depth on Medium and High:
`tools/shadow_reach_probe.gd` reads the depth buffer at Far zoom, every angle preset, ten hero spots per area, and keeps the farthest pixel that
lands in the area (+8 m) -> `StyleRig.SHADOW_REACH` (Crosspath 131 m, forest 64, Gainlands 161, Buffet 122, D.N.A. 103, Dump 176, Capital 190).
Medium uses two cascades (near cascade 34 m, as crisp as the old map), High four. Two cost cuts: small casters (rigged characters, pieces under
2.5 m) drop the sun shadow beyond 40 m; flat ground planes never cast. A 2048 Medium atlas was measured (+0.5 ms in the Capital) and dropped: the
1024 near cascade looked the same round the hero. Low (no sun shadow; Safe Mode is Low), Intel iGPUs (26 / 48 m) and the battle / dungeon
backdrops are unchanged. The zone look files' own lights are removed before the first frame, so none overrides the reach.

**Shots** (Medium, the Tier 1 spots): `docs/art/graphics_tier1/fixes26_p1_before/` vs `fixes26_p1_after/` (town_square, gainlands, heap, dna,
capital_out); crops `_screenshots/p1ab/`.

**Cost (Medium, dev PC, same session)** - full table and method in `docs/perf/report.md`, "Shadow reach":

| Area | fps before -> after | avg ms cost |
|---|---|---:|
| town_square | 65.8 -> 63.2 | +0.62 |
| town_street | 64.7 -> 62.4 | +0.55 |
| forest | 80.3 -> 80.0 | +0.05 |
| gainlands | 74.0 -> 70.6 | +0.64 |
| buffet | 77.2 -> 75.1 | +0.37 |
| dna | 84.1 -> 81.5 | +0.37 |
| heap | 69.6 -> 66.9 | +0.58 |
| capital_out | 66.4 -> 62.8 | +0.86 |
| capital_in | 59.8 -> 58.5 | +0.38 |

Today this laptop ran 10-15% slower than on Oct 25 (capital_in was 70 fps then, old shadows): the Capital gate spot sits at about 60 fps (interleaved
A/B: old 61.2-62.8, new 59.5-60.4). Every Medium frame-time budget is met; the Medium draw-call lines of gainlands, buffet, dna, heap,
capital_out and capital_in were raised to the new counts x1.2 (depth-only far-cascade draws), as budgets.md allows for a deliberate cost.

## Part 2 - The D.N.A.

- **Walls**: interior walls 4.5 -> 10 m, outer shell 9 -> 12 m. From the default camera (Normal zoom, Cinematic or Classic: lens 6.6 / 9.1 m up)
  no wall top shows. A wall standing nearer the camera than the hero now fades out completely (a dollhouse cut, `dna_fade.gdshader` `cut_front`),
  so the hero's whole room and everyone in it stay visible; walls beyond the hero stay up. Collision, doors and paths unchanged.
- **Pneumatic tubes**: 1.3 / 1.55 m -> 3.6 / 3.85 m (over a metre of room above the hero with a hat), moved onto the mail room's walls on brass
  brackets (no floor supports).
- **Lights**: the flicker is gone (steady pooled lights); the flat glowing plate behind every sconce (the rectangle) is now a soft round glow disc
  that fades to nothing at its rim, at every setting (`DnaFadeMesh.disc`).
- **Shots** `docs/fixes_oct26/p2/` - before / after at the lobby, breakroom, cubicle farm A, mail room (Cinematic) and the mail room at Classic.

## Part 3 - Volume

**Cause** (measured, not guessed - `docs/audio/volume_fix_oct26.md`): every slider was wired correctly - in the editor, in the exported v0.4.5 pack,
by mouse and by controller - but the slider position went straight to the bus as an amplitude. The top half of each slider was only 6 dB, and
near the defaults (80%, music 60%) one 5% step was 0.5 dB, below what the ear notices; on a controller, holding a direction moved one step.
Checked and fine: the saved values load after the buses exist, every player's bus, ducks (all released), mute-when-unfocused, the
performance pass's menu changes, the controller changes to Settings, output device switching.

**Fix**: a dB taper (`Settings.volume_db`: 2 dB per step, 50% = -20 dB, 0 = silence); settings.cfg version 3 converts old values once to the same
loudness (0.8 -> 95%, 0.6 -> 90%); new defaults sound like the old ones; a held D-pad / stick repeats on a focused slider (`PadFocus`). Tests
`tests/audio/test_volume_fix.gd`. Probes `tools/volume_probe.gd`, `volume_tone_probe.gd`, `volume_flow_probe.gd`, `volume_pad_probe.gd`,
`volume_device_probe.gd`.

## Part 4 - The Verdant Dump

- **The brown platforms**: the vine bridges' planks were flat steps placed half a plank ahead of where the deck really was, and on the banks the hero
  walked the ground under the arch (the deck only carried them over the water). Now every plank sits on the arch and tilts with it - one ramp
  from bank to bank, meeting the ground at both ends - and the whole grown strip is walked at deck height; the abutment's plank slab is gone
  (the gateway posts and rope stay). Ungrown: still no way across. All three vine bridges share the code; the entrance bridge is a flat deck.
  Shots `p4/before_bridge_center_grown.jpg` -> `after_bridge_center_grown.jpg`.
- **Greenhouse**: **Brother Bramble** now stands 2.1 m in front of the Commons Greenhouse door, facing the arrival, with his name, dialogue and
  prompt unchanged. Why him: his first line is a doorkeeper's ("Welcome to the Compost Grange... Please close the door behind you"), his quest
  (charge the dam) is done at the stables, so nothing needs him at his old spot east of the plaza; Sorrel must stay by his bridge (its grow spot
  uses his anchor) and Gristle by her stall. Quest markers follow the spot id, so they moved with him.
- **Fewer trees**: 73 -> 53 (the starting area 37 -> 23); no tree within 9.5 m on the camera side of a route, an anchor, a chest or a sign; trees
  left alone by that rule go too; the jacarandas, the giant tree cards beyond the rim and the route's mushroom trees stay. Shots
  `p4/before_hub.jpg` -> `after_hub.jpg`.
- **Mushroom and vine colour**: both places use the same card (DUMP-TREE-TWISTED); in the Dump it was multiplied by the zone's olive tree tint
  (`#7C8F45` at 70%) and lit by the violet dusk. It now takes Crosspath's tint (none) and Crosspath's sun and ambient everywhere.
  `p4/mushroom_colour_compare.png` (Dump before, after, Crosspath); the rest of the difference is the Dump's screen grade and fog.

## Part 5 - Ruler banners

A proper banner on every ruler statue (all five zones build them through `RulerPresence`): a swallowtail cloth of the kit's painted canvas dyed in
the ruler's colour, a darker trim down the sides and along the tails, a top hem, an iron crossbar with a gilt cap, a gilt ball-and-spike finial,
the emblem (0.84 m) centred in the cloth's upper third. Cloth, trim and emblem share one hang frame and swing together in the shared wind; the
pole, crossbar and finial stay rigid. Freed zones still get the bunting (`test_zone_completion`). Shots `docs/fixes_oct26/p5/` (Buffet close
before / after and the crop `buffet_banners_compare.png`, Gainlands and Buffet at the spawn).

## Part 6 - Placement

- **Gainlands power line**: the glowing pipe ran from the colossal wheel across the road to the grid panel and Gus's yard. It now joins the three
  hamster wheels - the west wheel to the run wheel's west rim, the run wheel's east rim north to the east wheel - 2.2 m or more off every path;
  any stretch within 0.8 m of a path would go overhead on poles (none needed). Shots `p6/before_gainlands_wheels.jpg` -> `after_...`.
- **The Endless Buffet**: Sous-Chef Tarragon stood inside the Rift Express station - now on the open cobbles south-east of it, facing the arrival.
  Rip (the Rift Express operator) stood in the dressing crate at the broccoli forest's edge - now in front of the station on open ground. Shots
  `p6/before_buffet_station.jpg` -> `after_buffet_station.jpg`.
- **NPC overlap sweep** (`tools/npc_overlap_probe.gd`, every zone and the town; before / after lines `p6/npc_overlap_before.txt`, `_after.txt`):

| Where | NPC | Found | Fixed |
|---|---|---|---|
| Buffet | Sous-Chef Tarragon | inside the Rift Express | moved to open ground (above) |
| Buffet | Rip (rift operator) | in the dressing crate | moved in front of the station |
| Capital | Exit Clerk | inside the closed Exit Interview Booth (unseen) | stands beside the booth's front, facing the plaza |
| D.N.A. | Druid quiz clerk | circle touching his desk's blocker | 0.3 m west |
| D.N.A. | Kyle (matching) | touching the alcove's corner | a step west |
| Capital | Gate Guard (Height Inspection) | touching the gate | 0.25 m south |
| Crosspath | tailor's window mannequin | against the window wall | 0.25 m out |
| Gainlands | Old Man Mountain | flagged by the first pass | false alarm: his own 0.6 m blocker; clear at 1 m |
| Buffet quiz, D.N.A. Dolores and Pip | | a counter or desk behind them within a metre | nothing within 0.5 m: left as they are |

After the sweep no NPC has anything solid within 0.5 m and no two NPCs stand closer than 1.2 m, in any area.
