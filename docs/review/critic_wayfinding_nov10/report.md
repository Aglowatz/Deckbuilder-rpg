# Wayfinding critic, Nov 10: can a stranger find each zone's main dungeon?

(Report handed back by the no-context critic; the file write was refused in its sandbox, so it is saved here verbatim. Play scripts:
`docs/review/play_scripts/wf_*.txt` (57); screenshots and logs in `_screenshots/play/wf_*/`.)

Played from the four fresh-arrival snapshots with `tools/play.sh` (57 runs, all 170 s or shorter, one at a time), fights auto-won, no dev travel. Guidance used: the HUD tracker, the quest log (J), the map (M) with "Point me to...", the white pointer, the minimap, signs and people. Screenshots are in `_screenshots/play/<run>/`. Times are the sum of the runs' play.log end stamps.

Result: **1 of 4 doors reached** (the Hall of Final Approvals). The House of Gains, the Test Kitchen and the Rotheart were not reached inside the ~25-minute budget each. Method note: `dev save` resumes at the zone entrance, not where the hero stood, so every run re-walked the approach; the times include that.

| Zone | Door prompt reached | Game time | Runs | Clarity /10 |
|---|---|---|---|---|
| The Gainlands (House of Gains) | no | 1412 s (23.5 min) | 17 | 2 |
| The D.N.A. (Hall of Final Approvals) | yes, `wf_dna_11/01_n1.png` | 1097 s (18.3 min) | 11 | 5 |
| The Endless Buffet (Test Kitchen) | no | 1373 s (22.9 min) | 15 | 4 |
| The Verdant Dump (Rotheart) | no | 1146 s (19.1 min) | 14 | 3 |

## 1. The Gainlands: the House of Gains (not reached)

**Time:** 1412 s over 17 runs (`wf_gain_01`..`wf_gain_17`). Stopped at "The House of Gains Steps", ~17 m south-east of the door on the map, unable to move.

**Route and what guided me**
- Arrival on the bridge at (56,100). Tracker: "Spot the locals: finish a favour in the Gainlands". Quest log: "Where to go: Foreman Gus, Old Man Mountain or Coach Brutus Benchley". Map (`wf_gain_01/03_map.png`) shows the House of Gains top centre.
- First step forward: a fight with Quota Spotter on the bridge (`wf_gain_01/04_walk_w.png`).
- "Point me to... The House of Gains (Dungeon entrance, usually level 5)" (`wf_gain_03/04_point_me_list.png`): white arrow due north across the hub pavilion (`wf_gain_04/02_arrow.png`).
- Straight north is the Swole Station pavilion; Old Man Mountain stands in its one northern gap at (56,70) and stops the hero (`wf_gain_05/04_n3.png`). Talking: three lore lines, then "has a favour to ask. Talk again." No direction.
- Round the pavilion west and north: dead end at the plateau wall (49,55) while the arrow still says north (`wf_gain_07/09_arrow.png`, `wf_gain_07/16_map.png`).
- East side of the hub, road north: (68,61) -> (75,27) -> (75,16), a bridge end with a Portal ripper (Rita) and a signpost. Rita: "Can't rip a thing with the grid this dry" (`wf_gain_17/02_sign_read.png`). Pointer now says north-west, up a cliff (`wf_gain_09/06_n3.png`).
- North-west from there: a notch at (64.5,14.6) where the banner reads "The House of Gains Steps" (`wf_gain_13/09_n4.png`) but W, A and W+A move 0 m and the camera is inside the rock (`wf_gain_14/05_a2.png`). Back off, further west, further east (85-95, 10-20): all dead ends (`wf_gain_16`, `wf_gain_17/09_map.png`).

**Confusions**
1. The pointer is as-the-crow-flies: through the pavilion, across a 15 m plateau wall, up a cliff. ~9 min lost (runs 5-12). `wf_gain_08/07_n4.png`, `wf_gain_12/10_map.png`.
2. Old Man Mountain blocks the only northern exit of the hub and says nothing about the road. ~2 min. `wf_gain_06/09_n2.png`.
3. "The House of Gains Steps" banner fires while the hero is wedged in a cliff notch with no climbable steps; camera clips into rock. ~5 min (runs 13-16). `wf_gain_13/08_nw.png`, `wf_gain_15/05_n3.png`.
4. The quest log names Foreman Gus and Coach Benchley; neither has a marker and I never saw them in 23 minutes.
5. The bridge fight reset the chosen pointer target after the victory screen (re-picked in run 5).

**Markers that lied:** the Point-me arrow to the House of Gains (every shot where it points north over unwalkable ground); the Portal ripper marker at (88,19) (ripper is out of order); the "House of Gains Steps" banner on a spot where no steps can be climbed.

**Clarity: 2/10.** The map knows where the door is; nothing tells you how the terrain gets you there, and the one spot that claims to be the Steps is a wall.

## 2. The D.N.A.: the Hall of Final Approvals (reached)

**Time:** 1097 s (18.3 min) over 11 runs; prompt at 88 s into `wf_dna_11` (`wf_dna_11/01_n1.png`: "[E] Take a number and enter the Hall of Final Approvals"; confirmation dialog `wf_dna_11/03_e.png`, "Take a number and go in / Not yet").

**Route and what guided me**
- Tracker: "Help the staff: finish a favour in the D.N.A."; log: "Where to go: Agnes Overdue, Gerald or Clerk Ledgerbone". Map lists "The Hall of Final Approvals (Dungeon entrance, usually level 11)" (`wf_dna_01/04_list.png`); the pointer says north the whole way (`wf_dna_02/02_arrow.png`).
- Fight with Unpaid Intern, then the Lobby. The front desk (Agnes) is on the pointer line and stops the hero at (46.8,50) (`wf_dna_02/06_n4.png`).
- East round the desk: pressed against the north wall among queueing ghosts at (52.2,47.6) (`wf_dna_04/03_n1.png`).
- Slide west: the corridor; "The Mail Room" with the Soul Routing Terminal puzzle on the centre line at (45.5,36.5) (`wf_dna_05/02_n1.png`).
- North of the terminal: filing cabinets x 49-52 and a cabinet/sign cluster x 40-43 (`wf_dna_09/01_n1.png`, `wf_dna_10/01_n1.png`); the way north is a 3 m slot at x 44-47 directly behind the terminal.
- Through it: "The Executive Floor" and the door at (45.5,3.4). No favour needed; the door let a level-5 hero in despite "usually level 11".

**Confusions**
1. Closing the Point-me list with Escape leaves the map open; all of run 1's walking happened under the map. 1 run lost.
2. The desk and ghost queue sit on the pointer line; 3 runs (2-4, ~4.5 min) to get round.
3. The Mail Room: terminal and cabinets hide the slot north; 5 runs (6-10, ~9.5 min) poking the north wall at x 40.6, 49.3, 51.1, 51.7. The two signposts at (42.5,28) never came into reach. `wf_dna_07/01_n1.png`.
4. The tracker says "finish a favour" first; the door needed none. A player who obeys the tracker hunts a favour before trying the door.

**Markers that lied:** the objective "Help the staff: finish a favour" implies a gate that does not exist for the door; the pointer gives no hint that the route bends around the desk and the terminal.

**Clarity: 5/10.** The building is a straight corridor north and the pointer is honest, but two pieces of furniture on the centre line cost 14 minutes.

## 3. The Endless Buffet: the Test Kitchen (not reached)

**Time:** 1373 s (22.9 min) over 15 runs. Stopped with Old Meatloaf mended and Sir Loin still refusing passage.

**Route and what guided me**
- Tracker: "Help the kitchen: finish a favour"; log: "Where to go: Basil, Sous-Chef Tarragon or Madame Mirepoix". Map: Test Kitchen top centre (`wf_buf_01/03_map.png`); "Point me to... The Test Kitchen" arrow north.
- North past the Soup Fountain to the Gravy River; "Gravy Bank": Sir Loin, Golem gate: "HALT! Nobody enters Layer-Cake Town until Old Meatloaf has been mended. It is Basil's request, so speak to Basil: east of the Soup Fountain." (`wf_buf_03/04_raft_e.png`, `wf_buf_03/06_n1.png`). The clearest gate of the four zones.
- Basil: talk 1 lore, talk 2 gives "Mend the Meatloaf" (sea salt from the Salt Flats by the river, black truffle under the Broccoli Forest, south-west), talk 3 gives "The Golden Reservation" (`wf_buf_05/02_favour3.png`, `wf_buf_05/05_favour9.png`).
- Point me: "Mend the Meatloaf: Sea Salt Crystals (the Salt Flats, by the river)" (`wf_buf_08/03_list.png`): followed it north-east into the gravy twice (-1 HP each, `wf_buf_06/08_ne3.png`) before going west along the bank. Salt picked at (38,51.5) (`wf_buf_09/02_salt_e.png`).
- Truffle: no Point-me row for it until the salt was taken; the next row read "Old Meatloaf (the Grand Pantry's west wall)". Walked the Broccoli Forest on three runs (7, 9, 10) before finding the truffle in a pocket at (9,56) reachable only from the forest's south-west corner (`wf_buf_14/01_truffle_spot.png`).
- Old Meatloaf at (36,69.6) mended (`wf_buf_14/05_after.png`); tracker: "Hand in to Basil".
- Back at Sir Loin: "HALT! Old Meatloaf is still in two pieces, and I have Basil's list right here." (`wf_buf_15/03_sir_loin_e.png`). Out of budget before the hand-in and the Lazy Susan.

**Confusions**
1. "Goal: Mend the Meatloaf (3 places)" but the list shows two rows; the truffle row is missing until the salt is picked. ~4 min.
2. The salt pointer points across the river; the hero falls in twice following it. `wf_buf_06/06_n1.png`.
3. The HUD tracker switches to whichever side quest was accepted last (The Golden Reservation replaced Mend the Meatloaf, `wf_buf_05/06_after.png`), so the HUD said "Find a hidden stash" while I gathered salt.
4. The truffle "under the Broccoli Forest's trees": a 25 m maze with one pocket; the marker is on the map but the approach only works from the south-west. ~6 min (runs 7, 9, 10, 13).
5. Sir Loin does not know Meatloaf is mended until Basil is told; his line is unchanged.
6. Two 'R' raft markers (Crouton Raft, Lazy Susan); nothing says which one Sir Loin guards.

**Markers that lied:** Sir Loin's dialogue after the mend; "Mend the Meatloaf (3 places)" vs two rows; the HUD tracker auto-switching to the newest side quest.

**Clarity: 4/10.** The gate speaks plainly (go to Basil, east of the fountain), but the fetch quest behind it loses the player in the forest and the gate does not acknowledge the work.

## 4. The Verdant Dump: the Rotheart (not reached)

**Time:** 1146 s (19.1 min) over 14 runs. Stopped south of the stream with the herd quest open and no way to cross.

**Route and what guided me**
- Tracker: "Lend a hand: finish a favour"; log: "Where to go: Billie Muckfoot, Granny Gristle or Brother Bramble". Map: Rotheart top centre (`wf_dump_01/03_map.png`); Point me puts a "The Rotheart" marker on the HP bar pointing north (`wf_dump_01/06_arrow.png`).
- Compost Commons: Marigold stands on the path at (50,126) and stops the hero (`wf_dump_02/05_n5.png`); a fence closes the commons to the north except a gap at x 56.
- The stream's south bank fence at z 101. A brick ramp with a rope gate at (45,100) looks like a bridge and ends in the water: "You fall in! Someone fishes you out with a pitchfork" (`wf_dump_04/02_bridge_foot.png`, `wf_dump_06/01_bridge.png`).
- Sign at the gate: "CENTRE BRIDGE. Moss Mulligan grows this one for anyone who helps Billie Muckfoot round up the herd." (`wf_dump_08/01_sign_text.png`). Moss Mulligan is an interactable 4 m south of the ramp (map 'V', Growing spot) and says the same (`wf_dump_08/03_grow_e.png`).
- Billie: "Round Up the Herd", goat, pig, raccoon, 0/3 (`wf_dump_09/06_tracker.png`). Point me rows: "An escaped animal" x3 with no place; the pointer shows no label (`wf_dump_13/01_herd1.png`). Every herd circle on the map is north of the stream (`wf_dump_11/06_map.png`).
- East end of the bank (70,102): a translucent, ungrown lattice bridge and stairs up the far bank, not walkable (`wf_dump_12/01_bridge.png`). Brother Bramble's "Unblock the Stream" needs Gideon the goat from the north stable, also across.
- Two roaming Mossy Trash Golem fights at (35,104) completed "Who Ate the Compost?" by accident (`wf_dump_13/05_side_quests.png`).

**Confusions**
1. The Rotheart marker points due north across a stream with no grown bridge; nothing says the 'V' icons are the crossings.
2. The brick ramp reads as a bridge; two falls. 2 runs (4, 6).
3. The growing spot is off the ramp, 4 m south, invisible in the world; found only via `scene`. 1 run.
4. Billie's animals appear to be on the far bank that her own quest unlocks; none found south of the stream in 3 runs (10-12). If intended, the quest text should say where the first one is.
5. Three quests use the same blue circle (herd, scavengers x9, goat); Point-me rows are "An escaped animal" and "Scavengers (any)" with no place names (`wf_dump_09/08_list.png`).
6. The HUD tracker switched to each new side quest (Unblock the Stream, then Round Up the Herd).

**Markers that lied:** the 'V' growing-spot icons labelled "Vine Bridge" where no bridge exists; the ramp with gate and rope that leads into the water; Point-me rows with no place names.

**Clarity: 3/10.** The sign and Moss Mulligan state the gate clearly, but the gate's own quest sends you across the gate.

## Scores and the three fixes

**Gainlands 2 / D.N.A. 5 / Buffet 4 / Dump 3**

1. **Make the white pointer route-aware, or draw the walkable route on the map.** In three zones the arrow pointed across ground you cannot walk (Gainlands plateau and cliff, Gravy River, Dump stream), and in the D.N.A. through a desk and a terminal. Roughly 35 of the 84 minutes played went into that. A navmesh-following pointer, or a dotted path on the map, fixes most of it.
2. **Put the gate and its requirement in the main quest and on the map.** "Finish a favour" is not an instruction. Write "Mend Old Meatloaf for Sir Loin at the Lazy Susan" / "Help Billie's herd so Moss Mulligan grows the Centre Bridge", give the gate marker a lock icon, and make gate dialogue update as sub-steps complete (Sir Loin should say "tell Basil", not "still in two pieces"). In the Dump, make sure at least one escaped animal is on the player's side of the stream, and say which.
3. **Keep the main quest in the HUD and give every Point-me row a place name.** New side quests must not replace the tracked quest; rows like "An escaped animal", "Scavengers (any)" x9 and the missing truffle row should read like the salt row ("Sea Salt Crystals (the Salt Flats, by the river)"). Plus two physical blockers: the House of Gains Steps notch at (64.5,14.6) where the banner fires but the hero cannot climb and the camera clips into rock, and Old Man Mountain / Marigold standing in the only exits of their hubs.
