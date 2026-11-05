# Fresh-eyes critic: Fix pass Nov 4 (B)

Worktree `/c/Dev/wp_critic` at `c2438824`. Seven play runs: the four given scripts plus three retries (`_critic_tmp/hog_retry.txt`, `hog_retry2.txt`, `final_retry.txt`). Screenshots are under `/c/Dev/wp_critic/_screenshots/play/<run>/`:
`c4b_gain`, `c4b_hog` (+ retries `c4b_hog2`, `c4b_hog3`, `c4b_final`), `c4b_town`, `c4b_post`.

Script problems found along the way:
- `critic_nov4b_house_of_gains.txt` never opened a node. `dev travel dungeon D-HOG 7` clears node 7 (Stairs Down = the Descent) on the way, so the Descent is skipped. The map also needs two clicks on a node (or a click then E), and the script used none. Every `button` call in it missed. Use `dev travel dungeon D-HOG 6` and double-click the node at (912,478).
- `critic_nov4b_town.txt` never presses Craft and stops on the Shiro "Victory!" panel, before the reward. So the craft result and the Shiro reward are not shown in game.
- `critic_nov4b_gainlands.txt`: its Old Man Mountain talks are skipped, so neither the hint nor the "Only the Worthy..." offer is ever on screen. I covered both in `c4b_final`.

## 1. The Gainlands (`c4b_gain`, `c4b_final`)

| Fix | Verdict | Evidence | Why |
|---|---|---|---|
| Iron Cave on the middle road, a cave mouth in a rock crag you can see from the road | WORKS (reads weakly) | `c4b_gain/01_iron_cave_middle_road.png`, `02_iron_cave_ask.png` | There is a dark doorway in a blocky rock crag right beside the stone road ("The Gauntlet"), with a sign and a banner, and the prompt "Enter the Iron Cave: leg day" shows. But a power-line pylon in the foreground cuts across the crag, and the crag looks like a square block rather than a cave. The Enter popup's title is "???" even though the prompt names the Iron Cave. |
| Old Man Mountain hints the gate opens "when the kingdom is whole again" | PARTLY | `c4b_final` log 110-120 s, `35_mountain_pre.png`; `c4b_gain/04_swolympus_sealed.png` | The gate's own toast says "Sealed. Old Man Mountain says it opens when the kingdom is whole again." But in his first talk (welcome, the regime, rules one and two) and his second talk ("Spot Me!"), Mountain never says it himself. The player is told he said something they never heard. |
| Gate sealed before the endgame | WORKS | `c4b_gain/04_swolympus_sealed.png` | Padlock and chained doors, "[E] Mount Swolympus (sealed)", plus the toast above. Clear. |
| After Primm, Mountain offers "Only the Worthy..." | WORKS | `c4b_final/37_mountain_post.png`, `38_mountain_post2.png` | "Only the worthy reach the top. Also bring water." then a NEW QUEST card "Only the Worthy... / Buy a protein shake at the Station's stand". One flaw: talking to him once more replays the old "Spot Gary..." line instead of the shake step. |
| The gate opens (barrier sinks) | WORKS (end state only) | `c4b_gain/06_gate_opening.png` | The arch is open with no doors and no padlock. The shot was taken 4 s after the teleport, so I did not see the sinking animation itself. |
| Collapsed bridge span rebuilt; ridge walkable | WORKS | `c4b_gain/07_ridge.png` | A continuous plank bridge with lamp posts runs from the gate along the ridge to the mountain. There is no visible gap. |
| Trail offers "Climb Mount Swolympus" | WORKS | `c4b_gain/08_climb_ask.png` | The popup "The Ascent of Mount Swolympus" has Climb and Not yet buttons and a clear blurb. |

Also seen: after `dev postgame`, the HUD and the quest log still list "Raise the Bar: Out-muscle Brick Bronson / Go to Crosspath" as the active main quest (`05_mountain_postgame_offer.png`). This may only be a side effect of the dev flag.

## 2. The House of Gains (`c4b_hog`, `c4b_hog2`, `c4b_final`)

| Fix | Verdict | Evidence | Why |
|---|---|---|---|
| The Descent: Bribe (40 gold), greyed out with a reason under 40 | WORKS | `c4b_final/30_descent_poor.png` | With 20 gold, the button is dark grey and reads "Bribe the guard (you need 40 gold)". Very clear. |
| Overpower the guard (lose 3 HP) | WORKS (offer only) | `c4b_final/30_descent_poor.png` | The cost is spelled out on the button. I did not pick it. |
| Distract: a random card is lost for the run and named | WORKS | `c4b_final/31_descent_distract_result.png` | "You fling Personal Trainer down the far stairwell..." then a highlighted line "Lost for this run: Personal Trainer (back after the run)". Well written and clear. |
| Cell Block Brawler: a tough prison fight with "Smuggled Weights" beside "Iron-less Prison" | WORKS (text); toughness NOT SEEN | `c4b_hog2/10_descent_poor.png` (it is the Brawler brief), `14_cell_block_battle.png` | The brief lists Iron-less Prison and, in red, Smuggled Weights ("...The Brawler's units get +1 attack"). The foe has 16 HP and a 23-card deck against your 15 HP. I won with `dev win`, so I cannot judge how tough the fight is. The brief has redundancy: Smuggled Weights restates "Nobody can use Iron in the prison" right under the Iron-less Prison line, and "Pump It Up" and "Pump Iron" are two near-identical +1 attack rules side by side. Five rules plus a tip popup is heavy for one fight. |
| The Rescue promises only that Flex fights beside you | PARTLY / not seen in game | `c4b_final/34_rescue_event.png`; `data/story/gainlands_story.tres` lines 236-239 | In game I reached only Flex's opening cell line ("Careful, son...") before the run moved on. The event text in the data is right: "When you face Clench, I will be beside you", with no +1/+1 and no max HP. The boon in code is empty apart from the ally. The choice button and result screen were not shown. |

Also seen: the "Your first duel" tip is drawn on top of the Opening-hand panel and covers the top of the Keep Hand / Mulligan buttons (`c4b_hog2/14_cell_block_battle.png`).

## 3. Town and D.N.A. (`c4b_town`)

| Fix | Verdict | Evidence | Why |
|---|---|---|---|
| D.N.A. lobby west passage clear | PARTLY / inconclusive | `00_dna_entrance.png`, `01_dna_west_passage.png` | Rip's "Rift Station unlocked" dialogue was still open and covers the whole left half of both shots. In `01`, the floor right next to the hero has no filing cabinets, but there is a large dark urn or pillar beside him, and the far-west side is hidden. |
| Elevators flush with the wall | NOT SEEN | - | No elevator was in frame without the dialogue covering it. |
| "A Pinch of Everything" gives 6 essence of each Path on the first visit | WORKS | `03_alembic_talk.png`, `04_alchemist_screen_starter_jar.png`, log 80 s | The quest updates on talking to her, a toast says "+6 essence of every Path", and all four jars show 6. |
| Craft costs 100 gold and spends 6 per Path (18 leaves 12); cap 18 | PARTLY | `05_alchemist_18_essence.png` | The panel text states 6 of each, 100 gold, and a cap of 18. Jars at 18 display correctly. The script never crafted, so "18 leaves 12" is not seen in game (`core/data/alchemy.gd` has MIN 6, CAP 18). With Beefcake and Refusemancer outlined (or Necrocrat), the Craft button is grey with no reason given. A player cannot tell which Paths are chosen or why they cannot brew. |
| Shiro's reward is exactly 3 Gilded packs | NOT SEEN | `06_shiro_reward.png` (Victory panel only) | The run ended on the battle Victory panel. The code comment at `app/game_session.gd:2085` says 3 Gilded Packs. |

## 4. Postgame (`c4b_post`)

| Fix | Verdict | Evidence | Why |
|---|---|---|---|
| "Under the Forest" points to Rip at the Rift Station | PARTLY | `00_postgame_town_quest.png`, `01_rip_tip.png` | When you arrive in town after Primm, the HUD tracker still shows "Root Cause: Uproot Moss Mulligan". The new main quest appears and gets tracked only after you happen to talk to Rip. |
| Rip's tip | WORKS | `01_rip_tip.png` | "Spotter! Big news. You know that forest outside town, where you first turned up?" plus "QUEST UPDATED: Take the Rift Express to the forest where you woke". His nameplate is cut off: "RIP TEARSON, RIFT TECHNICI...". |
| Quest log | WORKS (cluttered) | `02_quest_log.png` | It has a good description, objective 1/4 ticked, "Where to go: Any Rift Express station: choose the forest (Crosspath)", and 200 gold / 200 XP. But the Main tab still lists Raise the Bar, Take a Number, Key Ingredients, Root Cause and Fragments at 0/4 after Primm is dead (possibly a dev-flag artifact). And "(Crosspath)" after "the forest" is confusing. |
| A straight path runs SOUTH from the clearing to a hatch far south | PARTLY | `03_forest_postgame.png`, `04_path_south.png`, `05_lab_ask.png` | The minimap shows a new narrow strip running south, and the trees open into a corridor. But on the ground it reads as dark undergrowth, not a trail. The hatch is only about 10 m below the bedroll (at the bottom edge of `04`), not "far south". It is a dim grey disc with no light or beacon. The "Path-ology Lab" popup with Descend / Not yet is clear. |

## Top issues

1. **Old Man Mountain never says the gate hint himself.** Add a line to his talk before the endgame, e.g. after rule two: "That gate up the ridge? Opens when the kingdom's whole again." Then the gate toast's "Old Man Mountain says..." pays off something the player actually heard.
2. **The Alchemist's Craft button is disabled with no reason, and the selection is unclear.** Mark the two chosen jars with a "Selected" label or tick. Put the reason on the button ("Pick two Paths", "Need 6 Necrocrat", "Need 100 gold"). Show the cost on it ("Craft - 100 gold, 6 + 6").
3. **The postgame quest is not surfaced on arrival.** After Primm, set the HUD tracker to "Under the Forest" (step "Ask Rip...") automatically, instead of the stale "Root Cause". Also close or hide the finished zone main quests that still show 0/4 in the log, if this also happens in a real playthrough (check this without `dev postgame`).
4. **The forest hatch is too close and too dark.** Move it further south as the brief intended. Give the trail a visible dirt or stone texture and put a small light or quest beacon on the hatch.
5. **The Iron Cave entry popup is titled "???"** while the prompt already says "Enter the Iron Cave: leg day". Use the real name. Also hide or fade the pylon in front of the crag at the default camera, and make the opening read more like a cave than a door in a block.
6. **The "Your first duel" tip overlaps the Opening-hand panel** in the Brawler fight and covers the top of the Keep/Mulligan buttons. Place the tip above the panel, or show it after the mulligan.
7. **The Cell Block Brawler brief is redundant.** Drop "Nobody can use Iron in the prison" from Smuggled Weights, since the Iron-less Prison line says it. Rename one of "Pump It Up" / "Pump Iron" so the two +1 attack rules are not near-twins.
8. **Old Man Mountain repeats "Spot Gary..." after giving "Only the Worthy...".** His repeat line should point to the protein shake step of the newest quest.
9. **Rip's nameplate is truncated** ("RIP TEARSON, RIFT TECHNICI..."). Widen the plate, or shrink the font for long titles.
10. **The critic scripts need fixes** so the next pass actually checks these: HOG travel to node 6 plus a double-click, a Craft click with two jars selected, and a Continue on Shiro's Victory panel.

## Score

**6/10** for this pass's polish. The core mechanical fixes I could see work and read well: the Descent's three priced choices with a greyed-out bribe and a named lost card, Smuggled Weights, the sealed gate and its postgame unlock, the rebuilt bridge and the Climb popup, the 6-essence starter jars and the cap text. But two hints point at things the player never sees (Mountain's gate line; the stale quest tracker after Primm). The forest hatch is neither far nor easy to see. The Alchemist fails silently. Three items (the Rescue choice, the craft result, the Shiro reward) could not be confirmed in game.
