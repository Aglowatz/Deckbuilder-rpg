# ART LIST READY - docs/art/art_needed_nov2.csv (47 rows; Part 1 of the Nov 2 pass)

# Report - Nov 2 pass (Fix + polish, Fable 5.1)

Sun Nov 2, from 09:45 MST. Brief: "FIX + POLISH PASS Nov 2 - The Wayward Path", Parts 1-8. Tag `pre-nov2`. Judgment calls:
`docs/overnight_inbox.md` ("Nov 2 pass"). State: `docs/loop_state.md`. Previous report (the Capital sides pass) is below this one.

## Part 1 - Art audit (done first; commit "Nov 2 pass, Part 1")

**The art list**: `docs/art/art_needed_nov2.csv`, the Art Batch tab's columns (Art ID, Category, Zone, Name/what, Priority, Lock, Size/format,
Save to, File name(s), Image description, Notes), 47 rows. High = seen in normal play. Contents: the Rescuer portrait redo (both arms), two
Rescuer expressions on the redone base, the Leaf Crown sheet redo, 11 sprite sets + 7 portraits for the figures below that have no fitting set
(plus a Low-priority dedicated gate-guard set), 11 story stills for the beats that still play on the icon stage (Primm's phase 1, phase 2
and fall; the House of Gains rescue; the Doppelganger reveal; epilogue beats 1, 3, 9, 4, 10, 6, 7), the Crease prop sheet + brick texture, the
D.N.A. lobby carpet / terrazzo / prop sheet, the Gate Road palace backdrop, the Buffet bridge's salt-shaker pillars, the Quota lieutenant
battle board, the four Capital requests from the Nov 1 report, the skipped expression portraits and N-10-REDO. No item icon changes: Part 4
keeps every item's name and object (see Part 4).

**3D figures found in walkable areas** (every NPC, roamer, guard, citizen, vendor and enemy was checked: the sprite-vs-model choice is
`NpcSprites.character_for_entry` for list NPCs (an entry with neither `npc_id` nor `sprite` keeps its 3D model), `ZoneEnemy._make_model` for
roamers (all 22 enemy kinds have painted sets), `TownScene._add_npc` for Crosspath). The Rescuer, Maren, the rift operators, the ninja, the
Dump workers and Colonel Casserole have painted sets with a 3D fallback only when the art is missing; none fall back today.

| Figure | Where | Was | Now |
|---|---|---|---|
| Gate Guard (Height Inspection), Gate Guard (Queue Management) | Capital, outside the gate beside Spotless | tinted KayKit Knight | painted Correction Officer set (`"sprite": "FOE_CORRECTION_OFFICER"`, 1.2 x hero): a white-and-gold officer, the fitting guard look; talk spots unchanged |
| Gate Guard (Exit Control) x 2 | Capital, inside the gate by the plaza fountain (the ones in the user's screenshot) | tinted Knight | the same officer set, facing into the city as before (`nov2_p1_gate_guards_in.jpg`) |
| Primm's Guard | the Crease after Primm falls (freed state) | tinted Knight | the same officer set |
| Citizen 4471 (the ward patient) | Capital, Correction Ward | tinted Rogue | the painted CITIZEN set, pale tint (`nov2_p1_patient.jpg`) |
| Foreman Gus | Gainlands, by the works | tinted Rogue_Hooded (his own set existed but the entry never named it) | `"sprite": "GUS"` (`nov2_p1_gus.jpg`) |
| Nurse Hesper Dray | Capital, the Crease heal spot | tinted Mage | art list: SPR-HESPER + NPC-HESPER (High) |
| The Exit Clerk | Capital, Gate Plaza booth | tinted Rogue_Hooded | art list: SPR-EXIT-CLERK + NPC-EXIT-CLERK (High); the Lost Junior Clerk set is a 0.6-height child and reads wrong |
| Gym attendant (cheering) | Gainlands gym hall | Barbarian, Cheer animation | art list: SPR-GYM-ATTENDANT (High; barks only, no portrait) |
| Gary, Currently Under a Barbell | Gainlands yard | Barbarian, Lie_Idle | art list: SPR-GARY (a lying set) + NPC-GARY (High) |
| Sous-Chef Tarragon | Endless Buffet | Rogue_Hooded | art list: SPR-TARRAGON + NPC-TARRAGON (High) |
| Brisket, Sir Loin (gate guardians) | Endless Buffet gates | code-built 3D golems (Casserole is painted) | art list: SPR-BRISKET, SPR-SIR-LOIN (High) |
| Billie Muckfoot | Verdant Dump | Rogue | art list: SPR-MUCKFOOT + NPC-MUCKFOOT (High) |
| Sorrel (growth-spot druid) | Verdant Dump | Mage | art list: SPR-SORREL + NPC-SORREL (High) |
| The Secret Dealer | Crosspath hidden alley | Rogue_Hooded | art list: SPR-DEALER + NPC-DEALER (Medium, hidden) |
| Threadwell's window mannequin | Crosspath | HeroModel "mannequin" | kept: it is a mannequin by design |
| Dump critters, the stable animal | Verdant Dump | Cube Pets animals | kept: ambient wildlife, not characters (inbox 1) |
| D.N.A. queue figures | D.N.A. far landmark (backdrop, not walkable) | KitMesh ghost silhouettes | kept: part of the painted landmark's composition |

**The Rescuer**: only the dialogue portrait `NPC-RESCUER` has the one-armed read (her left arm vanishes under the cloak). Her sprite set and the
STORY-CAPTURE still show both arms; NPC-ELOWEN (revealed) is fine. The list row describes the same design with both hands placed.
**Leaf Crown**: the FRONT view's arc ends point straight up (horns); the row asks for a closed ring whose ends sweep down and round the head.

Shots: `docs/overnight/nov2/shots/nov2_p1_*.jpg`.

## Part 2 - Capital: no plants inside the walls on every entry path

**Cause**: the look rig (`WorldLookRig`) builds a random foliage layer (grass, wildflowers, bushes) from the zone mood's `foliage` block, once,
at scene build, from the mood the hero stands in. `capital_inside` / `capital_freed` carried `density 1` (cells grass, wildflowers, tall
flowers, bush) while `capital_outskirts` has `density 0`. Walking in through the gate therefore never built the layer (the mood change at
the gate only toggles visibility of a layer that does not exist), but any build that STARTS with the hero inside - a save loaded inside, the
return from a fight inside, the first build after the hole in the west wall or the service shaft, the freed city - scattered 2811 cards over
the city, 1418 of them inside the wall. The build cache replayed the same placement.

**Fix**: `data/art/zone_looks.json`: `capital_inside` and `capital_freed` foliage density 0 (the dark variants extend them). The design
dressing (CapitalDressing: topiary, rose planters, parterres) is untouched. Every path now produces the same scene: no WorldFoliage layer,
ZoneDressing's 395 wasteland items all outside the wall (z >= 76).

**Test**: `tests/world/test_capital_no_scatter_paths.gd` builds the real Capital scene per entry path (gate, west-wall hole, service shaft /
Crease spawn, fast-travel landing, a save loaded inside at four points, back from a battle inside, the freed city inside and at the gate, a
second build from the build cache) and counts the generic scatter layers' instances inside the wall: 0 on every path; plus the moods' density
is asserted 0. Run with the old density it fails with 1418 inside. Because the headless renderer returns no MultiMesh transforms, both scatter
producers now keep their instance positions as node metadata (`positions`), which the test reads.

**Screenshot**: `docs/overnight/nov2/shots/nov2_p2_side_left.jpg` - Grave Row's lawn after a build that started inside (the hole's exit), no
bushes.


## Part 3 - Loading times (partly done; the run stopped here at the usage limit)

**Measured first** (`tools/run_loading_timing.sh`, windowed, the real SceneManager; cold = build-cache miss, warm = second visit):
`docs/perf/loading_nov2_before.md`. Back from a fight 2.5-3.5 s in the zones, 4.2 s in town, 8.6 s in the Capital; town -> zone 3.5-3.9 s warm
(the Capital 10 s, the Dump 11 s cold: painted swaps 5 s); zone -> town 5.2 s; zone -> side dungeon map 2.3 s (1.6 s of it the loading screen's
minimum hold). Peak working set 2222 MB.

**(1) Return from a fight - done.** SceneManager keeps the world scene alive OUT of the tree for a zone or town roamer battle and puts it back on
the return (`park_next`, `has_parked`, `_resume_parked`; `ZoneScene.resume_after_battle`, `TownScene.resume_after_battle`, `AmbientEmitter.resume_in`;
`Session.start_battle` asks for it only for roamer fights - gatekeeper, arena, graveyard, dungeon and dev battles rebuild as before). After: 0.9-1.0 s
in every zone, the town and the Capital (`docs/perf/loading_nov2_after_parked.md`); peak RAM 2113 MB (no rise); no script errors over 60 transitions.

**(2) Procedural layouts cached - the Capital, in part.** `KitMesh.fill_cached_set` + `CapitalKit.resolve_slot`: the townhouse and tower generators
(`CapitalGrand`) keep their geometry in the BuildCache (the painted card slots are re-resolved on a hit). Capital builder 7.5 s -> 4.9 s warm (the 16
houses 2.5 s -> 0.2 s, the skyline 1.2 s -> 0.7 s). Left: the other Capital buildings (1.2 s), landmarks + props (1.1 s), the merge (0.4 s); the town's
props (0.8 s), square (0.9 s) and hub land (0.8 s) are many small pieces and are not cached yet (town -> zone stays 3.5-3.9 s warm, zone -> town 5.2 s).

**Loading screen hold** 1.6 -> 0.9 s (`LoadingScreen.MIN_SECONDS`): zone -> dungeon map 2.3 -> 1.6 s.

**Not done**: (3) threaded pre-loading during the fade, (4) shader pre-warm at boot (the settle step is 0.45-0.65 s per zone load, worst frame
320-440 ms), (5) the loading screen already shows zone art + a tip for area changes. The full after-measurement with the Capital cache was not re-run.

## Part 4 - Items (sim run, no data changed)

`tools/item_sim.gd` plays every encounter of a filter with the expected player, no item vs one charge of each variant. Low shelf (Gainlands, L6, 12 games
x 4 Paths x each encounter, `docs/design/sim/items_nov2_low.md`): no item 86.5 % wins. Lift in points: Healing Draught +7.3, Vitality Charm +5.2,
Reckless Tonic 5 HP +1.0 (7 HP -3.1: the policy drinks it too early), Healing Salve +5.2, Field Bandage as it is (mend 3) -1.0 and used in 0 % of
games (confirmed useless), Bandage +0/+3 this turn +11.5 (used 99 %), Bandage +0/+2 for the battle +5.2, Bandage +1/+1 for the battle +0.0,
Scroll of Insight draw 2 +12.5, draw 1 +9.4, Firebrand +10.4, Sharpening Stone +9.4.
Reading: Draw 1 at 45 keeps the Scroll in line with the Firebrand and the Stone (draw 2 is the strongest item on the shelf); the Bandage as
"+0/+3 this turn" is the strongest at 30 gold, so pick "+0/+2 for the rest of the battle" (+5.2, a lasting job the Stone does not do) or price the
+0/+3 version at 45. The high-shelf sim (Dump, L18) may have finished after the stop: `docs/design/sim/items_nov2_high.md`.
Plan not applied: Scroll -> Draw 1 at 45; Reckless Tonic "Heal 5 HP. One use." at 30; Field Bandage -> "+0/+2 for the battle" at 30; the high
shelf to level 17 (`data/progression/level_track.json` item_advanced + `ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL`; the L6 headline
"Tilly's back shelf" moves to L17 beside "Sable's rare stock"), its items retuned (Chains 2 uses 90 g, Silence toss 2, Dust bury 6, Charm 3 Militia,
Ward 60 g) by the high sim; every description to state numbers, target, duration, uses; regenerate `data/items/*.tres` with
`tools/generate_content.gd` (the game loads the .tres, the code in `core/data/progression_content.gd` is the source).

## Parts 5-8 - state when the run stopped

- Part 5: not started. The fit data says the preview and the world place hats from the same anchors; a tailor try-on screenshot is the next step.
- Part 6: the solid fountain is WRITTEN in `world/town_streets.gd` (`_fountain`, `_pool_colour`, `_fountain_stream`, FOUNTAIN_ART_HEIGHT 3.55,
  FOUNTAIN_ART_FORWARD 0) with `assets/shaders/fountain_water.gdshader`: UNCOMMITTED, not yet compiled or screenshotted.
- Part 7: the pack holder centring in `ui/screens/reward_popup.gd` and `ui/town/pack_shop_screen.gd` is WRITTEN, uncommitted, not yet screenshotted.
- Part 8: not run (sharded GUT, walk smokes, perf budget, play script). The compile-all-scripts test last passed before the fountain and Part 7 edits.


---

# Report - Capital sides pass (Nov 2, Fable 5.1)

Sun Nov 2 07:00 -> 09:30 MST. Brief: "CAPITAL SIDES PASS (follow-up to the inner-city rebuild)", items 1-7. Tag `pre-capital-sides-nov2`.
Full report (what the screenshot showed, every part, the critics' rounds, perf, the before / after gallery): `docs/art/capital_rebuild_nov1.md`,
section "The sides pass (Nov 2)". Judgment calls: `docs/overnight_inbox.md` ("Capital sides Nov 2", items 1-5). Previous report below.

## Morning summary

- **No scatter on paving.** Plants stand only on painted lawn or inside a planter; every district lane and separator is lined with continuous
  white planters (gold lips, roses, a cone in a gold urn every 4 m). A test counts loose plants inside the wall (0).
- **No black objects.** The cause was the kit's near-black flat slots under the toon shadow band, not a missing texture. Every inside piece is
  restyled white and gold (bins, sacks, crates, the compost covers, the sick patch, drain covers, Ward bars, tram rails, dead windows, dead
  globes, Fern's shack). A probe test walks every visible triangle inside the wall: 434.8 m2 of near-black before, 0.31 after (budget 0.6).
- **No skinny buildings.** The Reek's yards, Grave Row's crypts and the Hungry Quarter's six stalls are grand townhouses with their district's
  service layer (one long shop-house a side of the Hungry lane); the plaza corners' pylons are gate piers; the district pylons are gone; the
  walls' inner faces wear a blind arcade with niche statuettes, wall basins and eleven engaged towers.
- **Side plazas** at (19, 58) and (100, 58): a two-tier side fountain with the gilded Primm on top, a gilded statue pair, a checker disc with
  ring borders, banner lamps, rose planter arcs; the routes end at the rim. The wheels, the pylons, a chest, the junk and the transit rift
  moved a little for them; every NPC, talk spot, pickup and entrance stays.
- **Gardens / order**: pink 3D lamps in rows on every lane (the painted card read brown), two parterre beds on Grave Row, a white-and-gold
  cordon round every rift inside the wall.
- **Critics (sides only, strict)**: s2 4/4/5/5/4/3/5/4 -> s3 4/4/5/5/4/4/6/5 -> s4 5/5/6/6/4/4/6/5. What they ask for next is mostly the
  story's props (the wheels, the rifts, the shed, the cable) - inbox 1.
- **Verified**: world 432/433 (one pre-existing pending), core 1563/1564 (one pre-existing pending), walk smoke OK (36 screenshots), the walkability test green,
  `capital_in` Medium 833 draw calls / p99 19.5 ms (budget 850 / 25; the first measure was 859 - the new statics merged city-wide fixed it).

Commits: ca14bb1c (Parts 1-4), ff06ea81 (perf), af4b45b2 (round 2), 88762f43 (round 3), and the finish commit.


---

# Report - Capital inner-city rebuild (Nov 1-2, Fable 5.1)

Sun Nov 1 20:10 -> 23:15 MST. Brief: "CAPITAL INNER-CITY REBUILD (overnight)", Parts A-G. Tag `pre-capital-rebuild-nov1`. Full report with
the before/after gallery, the plan, the piece list, the scores per iteration and the perf table: `docs/art/capital_rebuild_nov1.md`.
Questions and judgment calls: `docs/overnight_inbox.md` ("Capital rebuild Nov 1-2", items 1-4). Previous report: `docs/overnight/nov1/report.md`.

## Morning summary

Everything inside the great wall was rebuilt in code from the kit's own textures and painted cards (no new image files):

- **The kit** (`world/capital/capital_grand.gd`): a grand townhouse generator (storeys, bays, pastel accent, hip / mansard / gable roofs,
  balcony, pediment with the sun medallion, flower boxes, door, pinnacles, one banner that can hang a degree off), slender towers with pointed
  pastel spires, the gilded Primm (the painted statue card) on tall laurel plinths, a three-tier fountain, planters, paving borders,
  balustrades, lamp banners. Look-dev lineup: `tools/capital_lineup.tscn`.
- **The layout**: the sixteen Showcase footprints, every route, anchor, spot, sign, rift, entrance and the hidden hole stay exactly where they
  were; the houses are 4- and 5-storey mirrored townhouses, towers stand at the plaza's four corners and three districts' corners, two gilded
  pairs flank the avenue's mouth and the castle terraces, four parterre beds and eight banner lamps ring the enlarged fountain, rose planters
  run the boulevard and the lawn panels, the plaza and the boulevard wear a crisp 2 m checker with white-and-gold borders, the gate piers
  carry medallions, lancets and banners, and a skyline of five-storey rows and spires stands beyond the walls and on the hill top. The Grave
  Row flower clumps are gone; nothing random is left inside.
- **Light**: four grade passes (`data/zone_styles/capital_inside.json`): no violet ambient, thin fog, far blur cut, bloom cut, shadows up,
  exposure down, a bluer horizon band.
- **Checks**: world tests 431/431, core 1564/1564, the Capital walk smoke OK (twice), `perf_budget.sh frame capital_in` met on Medium after
  a perf pass (1004 -> 847 draw calls; the townhouses and towers draw as a shadow body plus a no-shadow detail mesh; the second rank, towers,
  statues, lamps and benches batch or instance). Loading path unchanged.
- **Scores** (a fresh critic per iteration, nine criteria, 1-10): c2 4/5/4/2/7/4/6/3/4 -> c6 6/6/5/4/7/6/7/4/5. Statues/fountain reached 8
  once; towers and light stayed at 4. Every critic reported "no roofs, no spires, white sky, overexposed": the play camera sees about six
  degrees above the horizon, so the roofs of any townhouse nearer than ~40 m, the plaza towers' spires and the blue sky are out of frame in
  play, and the sunlit cream plaster is a look-wide matter. Those are camera and look decisions, not Capital ones (inbox 1, 4). The brief's
  8+ on every criterion was not reached; the loop stopped at the plateau rather than making the zone gloomy to please a still picture.

## What to look at in game

1. Walk in through the gate: the inner gate plaza, the fountain ring with its parterres, the gilded pair at the avenue's mouth, the boulevard
   to the castle. Try the Far zoom and the Overview angle for the skyline.
2. The fallen state (after Primm, or `--flags=zone_final_completed` in a shot): crooked banners, warm windows, toppled statues, the dry
   fountain. The Showcase's houses no longer turn into ruins (inbox 2: say if you want the ruins back).
3. The districts keep their own models and states inside the new frame (inbox 3: replacing them with townhouse modules is a day's work).

## Art requests (nothing missing was invented)

- A side / three-quarter painting of the gold Primm statue: the plinth pairs face south like every card; a second angle would let the pairs
  face each other across the boulevard.
- A tileable pastel slate roof in sage (only pink and blue exist), and a gold urn card without the topiary (the rose beds use white planters).
- A CAP-PATH-WHITE re-upload (the Drive copy is truncated; noted since the art pass).

## Parts

| Part | Result |
|---|---|
| A | 13 before shots from the standard spots and the target's framing; the audit table and the plan (fc73c016) |
| B | `CapitalGrand` + the lineup scene; lineup shots in the report (663bf3af) |
| C | The layout as above; `KitBatch.merge_static(root, cell_size)` keeps far views unculled; `garden_fields` apart from the rows' people-room rule |
| D | The light passes; a fog-off and an ACES diagnostic shot showed the remaining paleness is the scene's own brightness, not fog |
| E | Tests, walk smoke, perf (table in the report); the Transit tower moved off a Tidy-Bot home, the Ward tower dropped (it cut the strip to the Ward chest) (b69feace, 1e19b4f4) |
| F | Six shot sets (c1-c6), five critic reports (`docs/review/capital_critic_c2..c6.md`) |
| G | This report, the gallery, the scores, the art requests; committed and pushed |

Gotchas for the next run: the play camera's six-degree sky band; a `node -e` string with an escaped apostrophe or a backtick inside bash
double quotes hangs the whole command (write .js files); the loudspeakers' open horns read as black discs from the front (gold inside now);
the forecourt lawn holds two rifts, so no tower pair fits there; `KitBatch` merged meshes never fade.
