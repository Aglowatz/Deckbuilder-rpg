# Fix pass Nov 4 (B) - report

Brief: `docs/prompts/fixes_nov4b.md` (playtest feedback round 2). Tag `pre-fixes-nov4b`. Decisions: `docs/overnight_inbox.md` ("Fix pass Nov 4 (B)").
Shots: `docs/overnight_shots/nov4b/`. Previous report: `docs/overnight/nov4b/report_fixes_nov4.md`.

## Part 1 - the answers you asked for

1. **Shiro's reward: confirmed, exactly 3 Gilded packs.** Finishing "The Oldest Trick in the Book" (beating Shiro Swindle) runs
   `Session.apply_ninja_win`: every stolen coin back plus `NinjaBoss.PACK_REWARD_COUNT` = 3 packs, each a Gilded pack of a random Path
   (`PackRules.gilded_pack_id`). A rematch after the quest pays nothing more. New test
   `test_finishing_the_oldest_trick_puts_exactly_three_gilded_packs_in_the_inventory` checks the INVENTORY (not just the result): +3 packs, all
   Gilded, every Path has a Gilded pack in the catalog. Nothing needed fixing.
2. **Mount Swolympus opens after Primm.**
   - **What was missing:**
     - The dungeon itself was complete. S-BEEF already had its painted map (MAP-S-BEEF), its battleboard (BB-S-BEEF), its own music
       (MUS-SWOLY-EXP/-BATTLE/-BOSS) and a postgame hermit quest ("Water for the Hermit") that unlocked it.
     - The quest had no dialogue at all.
     - The gate never opened. The ridge's span stayed collapsed, so nothing behind the gate was walkable.
     - There was no entrance: the zone's dungeon door only opens S-IRON.
   - **Now:**
     - Before Primm, Old Man Mountain's return lines and the sealed gate's toast say it opens "when the kingdom is whole again".
     - After Primm he offers **"Only the Worthy..."**: bring him a protein shake from the Station's stand. The quest now has its own offer,
       active and ready lines.
     - Handing it in unlocks S-BEEF. The first time you come near the overlook the **gate opens on screen**: the barrier grinds down into
       the ground with dust and a shake, and the collapsed span rises back into place.
     - The ridge is then walkable, from approach steps at the overlook to a trail spot at the mountain's foot. E there offers "Climb" into
       S-BEEF, through the side-dungeon flow with the zone's HP.
   - **Shots:** `p1_g_07_swolympus_gate_opening.png`, `p1_g_08_swolympus_ridge.png`, `p1_g_09_swolympus_climb_ask.png`.
3. **The Iron Cave (S-IRON).**
   - **Where it was:** on the LEFT road. Its mouth was in the north-west cliff at (15, 21), reached by a short paved spur off the left
     road's north bend, with the leg-day yard in front of it.
   - **Where it is now:** on the **middle road**, in a new sandstone crag that rises out of the east canyon beside the ridge. It sits
     **between the second and third road guards** (z 32.8, between the narrows at 37.5 and 28).
     - The mouth faces south-west, toward the road and the camera, so it reads from the road (`p1_g_03_iron_cave.png`).
     - A short spur leads to it.
   - **Removed:** the old mouth, its spur and its sign on the left road. The cliff stays as scenery, and the leg-day yard stays as a lifting
     yard.
   - **Smoke and tests:** the walk smoke now goes to the cave on the middle road. The tests check it is between the guards, walkable, and
     reachable along the ridge. The left road no longer passes it.
4. **The cones near Greta: grass clumps, removed.**
   - They were the dry-grass clumps of the zone dressing: `ZoneDressing`'s Gainlands recipe "grass_leafs", drawn as StyleGrass blades
     tinted in the sand colours.
   - On the green island meadows (Greta stands on the Glute island) they read as small tan spiky cones. They were pure decoration, so
     they are gone; the loose stones stay.

## Part 0 - keyword rename
"Fresh Stitches" is now **"Just Arrived"** everywhere: the card field (`just_arrived`), `KeywordInfo.JUST_ARRIVED_REMINDER` ("Just Arrived:
can't attack the turn it enters play."), the glossary, the battle tooltips, the design docs, the tests and the tools. A grep finds neither
"Fresh Stitches" nor "summoning sickness" in game text.

## Part 2 - Gainlands
1. **Mats:** no shrub, grass, rock, tree or loose kit on the blue workout mats.
   - `GainlandsLayout.on_mat` covers the yard rects plus the painted mat's soft edge.
   - The builder's `is_floor_at` says no there, so every floor-planting pass skips the mats, and the layout's tree/rock scatter skips them too.
   - A test builds the dressing and checks every instance.
2. **The Descent:** the three choices are now:
   - "Bribe the guard": pay 40 gold. Below 40 gold the button is greyed out and says "you need 40 gold".
   - "Overpower the guard": lose 3 HP.
   - "Distract the guard": a random non-basic card leaves your deck for the rest of this run and is back after it. The result names it
     ("You fling **Gym Bro** down the far stairwell...") and adds a "Lost for this run" line.
   - New event outcome `DungeonEvent.lose_card()`. The text is rewritten.
3. **Grandmaster Flex:** the boon is now only "Grandmaster Flex fights beside you in the final battle". The +1/+1 to all units and the +3
   max HP are gone. His ally T-15 is a **3/5**.
   - I also removed **Unbreakable**: an unkillable blocker that pumps your team every turn trivialises Clench at 3/5.
   - He keeps Overtime and his rally (+1/+1 to your other units each turn).
   - The option text, the boon tooltip, the importer test and the dungeon test are updated.
4. **Cell Block Brawler:** a mid-dungeon elite now.
   - Deck: Beefcake Bruisers (was the default archetype).
   - HP: 16 (was 13). Deck size 28; basics 12 (was 13).
   - New rule **Smuggled Weights**: "Nobody can use Iron in the prison. Nobody told him: he has been curling contraband plates under his
     bunk for years. The Brawler's units get +1 attack."
   - **Balance sim** (each Path's expected deck at L8, 40-60 games each):

     | | Beefcake | Necrocrat | Gourmand | Refusemancer | All | Loss rate |
     |---|---:|---:|---:|---:|---:|---:|
     | Before | 98% | 100% | 100% | 98% | 99% | 1% |
     | After | 77% | 67% | 65% | 78% | 72% | **28%** |

     (Steps tried: +1/+1 with 20 HP and 15 basics gave 47%; +1/+0 at 20 HP gave 52%; 18 HP and 13 basics gave 58%; 18 HP and 12 basics
     gave 66%; 16 HP and 12 basics gave 72%.) Files: `docs/design/sim/nov4b_cell_block_before.md` / `_after.md`.
5. **Natural zone edges**, zone by zone:
   - **Gainlands:** the reference, unchanged.
   - **Crosspath:** the gorge beside the Gainlands road was two flat rock quads. It now has the Gainlands' layered, ragged cliff on both
     walls: a lip, an upper face, a ledge and a talus leaning into the cleft, strata bands darkening downward, in the town's grey-brown
     stone.
     - This uses a new shared `CliffSkirt.wall(line, top, bottom, side, ...)`, the Gainlands profile as a strip, with the shared
       StyleTerrain material so each zone's painted cliff texture applies.
     - The lake and the treelines stay natural as they were.
   - **Verdant Dump:** the valley walls were one smooth ramp. They now rise in three courses with two ledges and a ragged line along the
     rim (`HeapLayout.wall_rise`), with the same 6.5 m total.
   - **Opening Forest:** the treeline is the edge; there is no drop to treat, so it is unchanged (apart from Part 3.4).
   - **Kept artificial on purpose:**
     - The Endless Buffet: its whole rim is the built cake layers.
     - The D.N.A.: interiors, plus the approach causeway with its parapets.
     - The Capital: its walls. The ground outside them is soft hills, with no cliff edge.
   - Shots: `p2_5_crosspath_gorge.png`, `p2_5_dump_rim.png`.

## Part 3 - Crosspath, D.N.A., forest
1. **House windows:** the painted windows (art 2.5 m wide with open shutters) were placed at the socket height and width whatever the wall.
   On narrow faces they overhung the corners, and above an eave they poked into the roof.
   - `BuildingKit.fit_window` now keeps every painted window inside its face's corners and under the roof line (the eave on an eave face,
     the slope on a gable end). It shrinks the window in place first and lowers it only when it would get too small.
   - This applies to every building of the kit. The test builds all 23 presets and checks every window vertex (the old code fails it on
     the alchemist and others).
   - Shot: `p3_1_lake_house_fixed.png`.
2. **D.N.A. elevators:** all four now stand flush against the bank's north wall (they floated 0.4 m out), each on a whole pair of wall
   cells. The second one stood half in the corridor opening to the executive floor; they are now at x 38, 41 | 49, 52, clear of x 43-47.
3. **D.N.A. lobby, left passage:**
   - The bench, the cooler and the television stood along the west wall in front of the breakroom's doorway; the filing-cabinet row and
     the chairs filled the rest.
   - The bench and cooler moved to the south wall west of the exit, the television to the east wall, and the cabinet row is out of the
     lobby.
   - `DnaLayout.LOBBY_WEST_PASSAGE` is a no-dressing zone.
   - **Verified:** a walk probe with a 2 m body from the gate to the breakroom doorway, the strip clear at five points, and the D.N.A. walk
     smoke (OK).
4. **Path-ology Lab entrance:**
   - The hatch is now far **south** (z 16.6, was 4.2), down a fairly straight path (four points, all within 18 degrees of one heading)
     through a glade.
   - **At the start:** none of it is floor, and a solid bramble thicket fills the gap in the clearing's south rim. The forest blocks the
     way; there is no invisible wall.
   - **Post-game:** the path, the glade and the pocket open up, and the brambles are gone.
   - Shots: `p3_4_forest_start_brambles.png`, `p3_4_forest_postgame_path.png`, `p3_4_forest_postgame_hatch.png`.

## Part 4 - post-game and crafting quests
1. **"Under the Forest"** (main, auto-given once Primm is down). The giver is Rip, who in the story data is the one who finds the hatch.
   - **Steps:**
     1. Ask Rip at Crosspath's Rift Station.
     2. Take the Rift Express to the forest. This completes on arrival there.
     3. Find the hatch at the end of the new path south of the clearing. Its map marker is on the hatch in the forest; it completes on
        going down.
     4. Free the prisoner in Cell 4. This is Elowen; quest text stays spoiler-free, as the reveal test requires.
   - **Dialogue:** Rip's tip now points south past the brambles, and to "any of my stations".
   - Loose Ends now points at this quest instead of repeating its steps.
2. **Auntie Alembic:**
   - **The bug is fixed:** a brew spends only what it needs. With 18 essence, a craft that needs 6 leaves 12 (it used to take everything).
     There is a test for exactly that.
   - **Cap:** 18 per Path (3 crafts' worth); more is lost.
   - **Gold:** 100 (was 150; the tri-Path brew is 200).
   - **Quest:** when the Alchemist opens (two zones free), **"A Pinch of Everything"** is given. Its first step, visiting her, pays 6
     essence of EVERY Path (one brew of any two). The second step is the brew.
   - Her dialogue and the screen's texts say the new rules.

## Part 5 - stopgaps
1. **Primm's defeat:** STORY-PRIMM-FALL (the giant) is parked. Cutscene primm_end plays over STORY-EPI-MODEL-FALLS (the broken model city,
   nobody in it). No scene scales Primm up; no code ever did, the giant was in the painting.
2. **Deck station:** the bottom row now uses the top row's five columns and height: 5 above, 5 below, lined up. The locks are as before
   (Level 7/14/21).

## Part F - art list
Rows appended to `docs/art/art_needed_nov4.csv`:
- **UI-BG-DECKBUILDER:** ten alcoves, 5 + 5. The guide is `docs/art/paintover_inputs/deck_station_slots_guide.png` at 1600x900, with the
  slots in magenta and the grid and panel shaded; it is made by `tools/deck_station_guide.gd`.
- **STORY-PRIMM-FALL:** human-sized, youthful but dishevelled, the crown slipping.
- **STORY-EPI-TOGETHER:** the four leaders' hands, each described:
  - Grandmaster Flex: a lion paw.
  - Agnes Overdue: a translucent ghost hand.
  - The Grand Chef: a floury hand with a mustard sleeve.
  - Archdruid Compostella: a soil-stained hand with a vine sleeve.
- **OF-PROP-BRAMBLES:** the stand-in thicket.
- **GAIN-HERO-IRON-CRAG:** the Iron Cave's new crag.

## Finish
(filled in below as it runs)
- **Tests:** every part's own tests and the world, quest, game and dungeon folders were run green as I went.
  - The final full GUT run was **stopped by Claude Code because the system was low on memory**, after 14 shards (about 1,400 tests).
  - Two failures showed up there, both from the new essence cap: the vault reward and a save migration. Both are fixed, and those two
    test files pass again.
  - The full suite still needs a clean run.
- **Critic play:** **not run.** The scripts are ready (`docs/review/play_scripts/critic_nov4b_{gainlands,house_of_gains,town,postgame}.txt`)
  and the HEAD worktree is at `/c/Dev/wp_critic`, hard-linked, so it uses no extra disk.
  - `critic_nov4b_town.txt` needs two play-driver actions that are not written yet: `dev essence <path> <n>` and `dev shiro`.
- **Export 0.5.5 and release smoke:** **not run.**
  - The version is still 0.5.4.
  - Disk is 2.5 GB free after deleting `builds/_export` (export staging) and old play-run shots. The export peaks at about 1.7 GB.
- New tools:
  - Play driver: `dev tp <x> <z>` and `dev postgame`.
  - `tools/deck_station_guide.gd`.
  - `CliffSkirt` (world/kit).
