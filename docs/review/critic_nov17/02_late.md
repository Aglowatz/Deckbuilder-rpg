# Critic 2: the late game and the ending (Nov 17)

## 1. How I played

I used all 14 runs (each under 170 s, one at a time, in the foreground). Scripts are `docs/review/play_scripts/n17_late_01..14.txt` and the shots are `_screenshots/exported/n17late_*`.

- **Runs 1-7 (Crosspath to the Capital, on foot):** each started from `dev load bot_refusemancer_capital_ready` or my own snapshots (`n17late_a..g`). I never got through the north exit to the Capital. Part of that was my blind scripting (holds sent too soon after a load, walking into Tilly's stall). Part was the game's: there was nothing to follow (see problems 1-3). Being stuck for seven runs is a finding.
- **Run 8:** I gave up and used `dev travel capital`. It put me straight into **the Crease** under the city, with "Get inside the Capital's wall" and "Knock at the manhole" already ticked. So I never saw the great gate or its guard, the Gate Plaza, or the streets.
- **Run 9:** I spoke to Fig Sly and browsed his Black Market. That finished the objective and gave me level 17. My walk to Wren failed because the shop was still open. I then used `dev travel dungeon D-PC` (castle gate cutscene) **without a run of trying on foot**, because the budget was gone.
- **Runs 10-14:** I used `dev travel dungeon D-PC -2` (node 9, "4 cleared on the way"), so I **skipped most of the castle**. I read Primm's pre-fight scene in the Model Room (runs 11-12) and opened his fight in runs 13-14. In run 14 I played **Phase 1 with `pilot`** and **lost on turn 6** (Primm on 10/56 HP). E on the defeat screen chose "Fight Primm again", and the run ended at the mulligan.
- **Not reached:** Primm's later phases, the win, the ending, the credits, the postgame, the Old Service Tunnels, Wren, the great gate. Like every critic before me, **I did not reach the credits.**

## 2. Score: 4/10 (late game, from what I could reach)

- **Clarity 3/10.** With all four lands freed, the Main tab of the quest log says "Nothing here right now." The HUD tracks a side quest (Mend the Meatloaf), and "Point me to..." in Crosspath does not list the Capital at all. Inside the Capital the tracking does recover: the main quest "Under the Capital" appears, and the Capital map's Point-me list is complete and useful.
- **Fun 4/10.** Primm's fight is built well on paper: two-Path rules, Mirrors, Standing Army, a Setting Up window, and boons from the four freed leaders. But reaching it took far longer than it should, and the defeat came from three free 3/3 Militia chipping 30 of my 39 damage. I could not judge the later phases.
- **Polish 6/10.** The late-game stills (castle gate, Model Room), the castle node map and Primm's cut-in are the best-looking screens I have seen in the genre at this price. The defeat screen, though, draws its big DEFEAT banner over its own explanation text, and Primm's intro line is repeated word for word.

## 3. Top 10 problems

| # | Problem | Where | Severity | One concrete fix |
|---|---|---|---|---|
| 1 | With all four lands freed there is **no main quest**: the Main tab says "Nothing here right now." and the HUD tracks a side quest ("Mend the Meatloaf"). Nothing tells the player that the Capital is next. | `n17late_03_cmain` (log run 3, 53.5 s: `Nothing here right now.`); `n17late_01_quests` | blocker | When the fourth land is freed, start a main quest such as "March on the Capital" (objective: "Take the imperial road north out of Crosspath"), and make it the tracked quest. |
| 2 | Crosspath's **"Point me to..." list has no entry for The Capital**, though the Endless Buffet and Gainlands exits are listed. The Capital exit exists only as a small map icon. | `n17late_01_pointme`, `n17late_04_cpoint` | major | Add "The Capital (Exit / portal)" to the Crosspath Point-me list, and put it first once the four lands are freed. |
| 3 | The north exit is hard to find on foot. Walking up the obvious lawn stops you dead at z -23.4 under a floating "THE CAPITAL" label, and the cobbled road sits a few metres to the left. Over several runs I hit the treeline, Tilly's stall and the gate area without leaving town. | `n17late_02_w3`, `n17late_02_w8` (hero stuck at (21.9,-23.4) from 32 s to 74 s) | major | Widen the exit trigger to the full width of the northern lawn, or block the lawn with a fence so that walking north funnels onto the road. Put an exit sign or arrow on the road itself. |
| 4 | The **defeat screen draws a big "DEFEAT" banner over its own body text**. The lines explaining "Fight Primm again" vs "Leave the castle" can't be read. | `n17late_14_e1` | major | Fade the DEFEAT banner out before the panel text appears, or move the panel below the banner. |
| 5 | **Primm's free 3 Militia decide the fight.** "Militia dealt 30 of the 39 damage you took (10 hits)" before he even left Phase 1. It is a pile-on rule, and only the defeat tip explains how to answer it. | `n17late_14_e1`, `n17late_14_b2` | major | Start Primm with 2 Militia, or give them Summoning Sickness until turn 3. Put the defeat tip's advice ("block or trade with Militia early") on the Before the Boss card. |
| 6 | The **Standing Army text says the Militia are 3/3**, but on turn 3 they show **3/1 with a -2 marker** and later 3/3 again. The rule card and the board disagree. | rules card `n17late_14_rules` vs log run 14, 85.1 s: `Militia ... 3/1 ... -2` | minor | Make the rule text match the board (say what the -2 is and when it ends), or start the Militia at the stated 3/3. |
| 7 | Primm's pre-fight scene is long: about 7 lines of Primm, then 8+ lines of the four freed leaders' boons, then a rules card, then a cut-in. Every retry from the map plays it again (21 E presses were not enough in run 12). | log run 12 (51-72 s); run 13 `skip_dialogue: 27 taps` | minor | After the first viewing, start "Fight Primm again" and re-entries at the rules card, with a "Replay scene" button. |
| 8 | **The same line twice**: "Do mind the floor. It has just been polished, by seventeen people..." is his first line in the Model Room, and it is also his battle cut-in quote. | `n17late_11_f`, `n17late_14_b0` | minor | Give the cut-in its own line, something that sets up the fight, e.g. one about Standardization. |
| 9 | Primm's Castle is listed as "usually level 21", yet the "capital ready" hero is level 16-17 with 26 run HP. Nothing in the Capital warns you or suggests where to grind. | `n17late_08_cpoint` (Point-me list); log run 9, 56.0 s `level 17 ... run hp 26/26` | minor | When the player is below the suggested level, show it on the castle's entrance prompt ("Suggested level 21; you are 17") and point to the Old Service Tunnels as the place to level up. |
| 10 | The tracker's "1 of 4" pager is unclear. In the Crease the main quest is tracked, but the HUD in the Black Market flips back to "SIDE Mend the Meatloaf", the quest that misled me in Crosspath. | log run 9, 53.7 s (shop open: `SIDE ▾ Mend the Meatloaf`) | minor | Pin the main quest to page 1 of the tracker whenever one exists, and never switch to a side quest automatically. |

## 4. Three things that work and must not be lost

- **The late-game stills.** The castle gate arrest with the peacock official, and Primm hunched over his miniature kingdom, are striking and tell the story without words (`n17late_09_pc1`, `n17late_11_f`).
- **The castle node map.** It is a gorgeous isometric painting with clearly named rooms, a boss skull and locks, and it reads at a glance (`n17late_10_map`).
- **The Before the Boss rules card plus the defeat report.** Every rule and boon is listed with icons, "What beat you" names the culprit and gives a tip, and "Fight Primm again" keeps your HP and boons (`n17late_14_rules`, `n17late_14_e1`).

## 5. SCRIPT ERROR lines

None. `grep "SCRIPT ERROR"` found 0 matches in all 14 game logs (`play_n17late_01.log` to `play_n17late_14.log`).

## Short answers

- **Wayfinding:** From Crosspath, no, I did not know where to go. There is no main quest, the tracker pushed the Buffet side quest, and Point-me leaves out the Capital. I guessed "north" from the map icon and still failed to get through on foot over seven runs. Inside the Capital, wayfinding is good: the main quest "Under the Capital" has a "Where to go" line, the Point-me list names every NPC, the Old Service Tunnels and Primm's Castle, and the castle map is clear. I could not judge the gate guard step or anything after Primm.
- **The climax:** The presentation is worthy. There is a domed Model Room, a strong monologue ("This will not hurt. It will, however, be Standard."), the four freed leaders step in with boons, there is a rules card, and a cut-in names the phase ("Phase 1: Standardization"). The rule mix (Mirrors copying your first card, Perfect Order, Setting Up) is interesting. I saw only Phase 1, and it played as a Militia beatdown: the pilot lost on turn 6 with Primm at 10/56. That is a fair test for a level-17 hero against a "level 21" boss, but it is not a test of the mechanics that make the fight special.
- **The ending:** Not reached, so I can't judge it.
- **The credits and after:** Not reached. Nothing I saw before the fight prepares a postgame goal.
