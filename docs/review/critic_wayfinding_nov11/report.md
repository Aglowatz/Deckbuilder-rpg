# Wayfinding critic, Nov 11 (exported build): can a stranger find the main dungeon in three zones?

(Handed back by the no-context critic; its file write was refused in its sandbox, so the report is saved here verbatim. Brief:
`docs/review/critic_wayfinding_nov11_brief.md`. Scripts: `docs/review/play_scripts/wx_{gain,dump,dna}_<nn>.txt` (46); screenshots in
`_screenshots/exported/`; logs `_screenshots/exported/play_wx_*_play.log`. The build: the RC4 tree after Part 1 and Part 2.1.)

No-context critic. Played only the exported pack through `tools/play_exported.sh`, 46 runs of 170 s or less. Fights auto-won; I still had to walk to everything. Each resume restarts at the zone entrance, so every run re-walks the entrance and re-fights the entrance ambush; that overhead is counted.

Result: **Gainlands reached (21 min 09 s, 20 runs). Verdant Dump NOT reached (24 min 00 s, 21 runs, stopped at a junk barricade that needs a mount). D.N.A. reached (5 min 49 s, 5 runs).**

---

## 1. The Gainlands -> The House of Gains

### Time and runs
**1269.1 game seconds (21 min 09 s), 20 runs.** Prompt reached in run 20: `g20_door_near.png` shows `[E] Enter the House of Gains`; `g20_door_prompt.png` shows the confirmation dialog with the "Enter the House of Gains" button.

Runs (game seconds): wx_gain_01 36.2, 02 40.3, 03 54.4, 04 34.7, 05 46.0, 06 53.7, 07 61.2, 08 54.4, 09 62.2, 10 60.6, 11 58.3, 12 52.5, 13 63.7, 14 85.5, 15 67.4, 16 87.2, 17 83.3, 18 75.9, 19 100.0, 20 91.6.

### Route and what guided me
1. Bridge end: forced fight "Quota Spotter wants a word..." (`g02_spotter.png`). Guided by nothing; it just happens.
2. Tracker: "Spot the locals: finish a favour in the Gainlands"; quest log "Where to go: Foreman Gus, Old Man Mountain or Coach Brutus Benchley". The map drew a dotted line to Old Man Mountain 30 m north (`g01_map.png`). Talked to him twice (toast "Old Man Mountain has a favour to ask. Talk again." was clear). Got side quest **Spot Me!**: "Gary's stuck under a barbell again - follow the groaning", then "check your form at a Flex Mirror".
3. Gary: the map legend's "Goal: Spot Me!" row did nothing when clicked (`g05_goal_picked.png`, `g05_arrow.png`), but the **"Point me to..." button** opens a real list (`g06_pointme_list.png`) with "Goal - Spot Me!: Gary, Currently Under a Barbell" and "The House of Gains (Dungeon entrance, usually level 8)". Picking Gary put a floating label with an arrow in the world (`g07_arrow.png`). Gary lies in the gym yard east of the Station (`g07_near2.png`); spotted him.
4. Flex Mirror "at the Station or up on Pec Perch": the light-blue board west of the Station with a white circle on the ground in front of it (`g12_mirror_near.png`). Flexed (`g13_mirror_e.png`), handed in (`g13_omm_done.png`, QUEST COMPLETE).
5. Main quest advanced to **Storm the House of Gains**; "Where to go: The House of Gains, beyond the north rim. Nothing is locked on the way: the middle road climbs straight to it from the bridge, past three road guards who want a fight" (`g13_log.png`). Map drew a dotted route north (`g13_map.png`).
6. Leaving the Station northward took 5 runs (confusion 4). The actual exit is a diagonal slip between a rock block and a kerb at roughly world (49,60) -> (52,55), then the road: three guard fights ("The Gauntlet"), the Iron Cave on the right, "The House of Gains Steps", door at world (56,-3).

### Moments of confusion
1. **Legend goal rows are not buttons.** "Goal: Spot Me!" with a coloured dot matching a map circle; clicking it did nothing (`g05_goal_picked.png`). Only "Point me to..." works. Lost run 05 (46 s) and run 04 (35 s; my click hit a row because the legend had shifted 30 px).
2. **"Follow the groaning"** is the only place hint for Gary in the log; no groaning cue detectable. The map circle and the list did the work. ~1 min lost.
3. **Rift Station and Flex Mirror share a corner.** Walking to the mirror triggered "Rift Station unlocked" mid-walk (`g08_w1.png`), and a blind E one run later opened the full fast-travel screen (`g10_mirror_e.png`) and ate that run. Mirror reach is 1.8 m; I stood 2.1-2.5 m away three times with no prompt (`g11_mirror_near.png`, `g12_mirror_near.png`). Runs 09-12 partly lost: ~3.5 min.
4. **The road north from the Station is walled where it looks open.** Text: "the middle road climbs straight to it from the bridge". In the world the road visibly continues north behind Old Man Mountain to a staircase (`g14_n1.png`, `g17_gap.png`), but an invisible wall spans the width at z 67 (blocked at x 52.9, 54.1, 56.8), four effect boards stand in a line, and a kerb wall along x 50 slid me 10 m (`g15_n2.png`). The yellow route arrow sat at the kerb's end pointing west (`g14_n1.png`, `g17_gap.png`), not at the gap. The gap is a two-metre diagonal between a rock block and the kerb (`g15_n3.png`: the rock, with the road and six guards just beyond). Runs 14-17 lost: 85.5+67.4+87.2+83.3 = 323 s (5 min 23 s).
5. **Old Hob the Gravedigger cutscene** starts by walking near the weight racks (`g09_omm_e.png`); hijacked a mirror run (62 s).
6. **Walked straight past the door.** Reach 2.4 m; a 3 s hold ended 3.0 m beyond it, no prompt (`g19_n3.png`); one more run (100 s).
7. Overhead: the Quota Spotter ambush re-triggers on every entry (20 times, +35 gold each; gold 475 -> 1735). 8-10 s and a Continue click per visit; reads as a bug.

### Markers that lied
- Legend "Goal:" rows look clickable and are not.
- The yellow in-world arrow and the dotted map route both run along the kerb wall; neither points at the actual gap (`g14_n1.png`, `g17_gap.png`).
- "the middle road climbs straight to it from the bridge" is false for the first 40 m.
- Nothing says the Flex Mirror must be approached onto its white circle.

### Clarity score: 5/10
Every sentence was correct and the Point-me list even names the dungeon with its level, but the physical exit from the first area is hidden behind an invisible wall that the arrows do not route around, which cost a quarter of the zone budget.

---

## 2. The Verdant Dump -> The Rotheart

### Time and runs
**1439.1 game seconds (24 min 00 s), 21 runs. NOT reached.** Stopped on the Farm Terrace at world (31.7, 62.5) in front of a junk barricade ("This barricade of junk is far too heavy to push on foot, but something fast and stubborn could charge straight through it", `d19_n4.png`, `d20_n2.png`). The Rotheart is roughly 40 m further north on the map.

Runs (game seconds): wx_dump_01 48.8, 02 45.3, 03 45.2, 04 44.2, 05 61.3, 06 86.1, 07 48.2, 08 55.1, 09 49.3, 10 63.3, 11 57.7, 12 58.2, 13 67.6, 14 64.3, 15 67.4, 16 69.6, 17 100.6, 18 109.5, 19 108.6, 20 97.0, 21 91.8.

### Route and what guided me
1. Arrival: tracker "Lend a hand: finish a favour in the Verdant Dump"; log "Where to go: Billie Muckfoot, Granny Gristle or Brother Bramble". Map (`d01_map.png`): the Rotheart ringed at the top of a tall map; Bramble 18 m north. The Point-me list (`d01_pointme.png`) under *Goal - Root Cause*: the three people, "A Magic Bean (by the stream, west of the Centre Bridge)", "The West Sprout Mound: plant a Magic Bean and a vine ...".
2. Brother Bramble (pointer worked, `d02_n1.png`): talk 1 nothing visible; talk 2 gave **Who Ate the Compost?** (drive off 2 scavengers) and **Unblock the Stream** (borrow a mount from the stables, charge a junk dam on the north bank).
3. Did Who Ate the Compost?: nine blue circles (`d04_map.png`); two "Hungry Scarecrow" fights east of the Commons (`d05_n2.png`); 2/2; handed in (`d07_bramble_done.png`, QUEST COMPLETE). **Main objective did not tick** (`d07_main.png`: still "Lend a hand... Where to go: Billie Muckfoot, Granny Gristle or Brother Bramble").
4. Billie Muckfoot: first E hit the "THE ROT-IDOL" plaque beside her (`d08_billie_e.png`); she gives **Round Up the Herd** (`d09_side.png`). Not pursued.
5. Followed the main goal's own list entries: Magic Bean and West Sprout Mound at the Commons' west edge (yellow circles `d07_map.png`). Direct line blocked by the stone house and the Harvest Meal stall (`d10_n1.png`, `d11_w1.png`); the way is the tree-lined west lane (`d12_w2.png`), where a Mossy Trash Golem ambushes on every visit. "[E] Pick up the Magic Bean" (`d16_bean_near.png`), "[E] Plant a Magic Bean" (`d16_mound_e.png`), "It has grown! ... [E] Admire the vine bridge" (`d16_mound_done.png`). **Main objective still "Lend a hand"; no new line.**
6. Crossed the vine bridge north (`d17_n5.png`), the Farm Terrace (stable at world (30,86), "Druid Thistlewick"), then the junk barricade at z 62 that wants a mount. Two runs trying to get back to that stable failed because the golem fight's start point shifts my dead-reckoned route by 1-10 m each resume (`d21_stable.png` is 22 m off).

### Moments of confusion
1. **"Finish a favour" does not mean finish a favour.** Completed Bramble's "Who Ate the Compost?" (QUEST COMPLETE, 60 gold) and the main objective stayed identical (`d07_main.png`). Runs 04-07 (240 s) bought nothing toward the Rotheart. I never learned which favour counts.
2. **Planting the bean and growing the bridge changed nothing in the tracker** (`d16_mound_done.png`), though the bean and mound are listed under *Goal - Root Cause*. List and tracker disagree about what the main quest wants.
3. **The route to the Rotheart needs a mount, and nothing on the main quest says so.** The barricade text (`d19_n4.png`) is the first hint, 35 m past the bridge, and belongs to a side quest ("The stables: borrow a mount, then charge the dam"). The stable is 24 m back south. Budget ended here.
4. **Junk gull hazard**: "SCREEEE! A mutant junk gull dive-bombs you... (-2 HP)" on almost every run near the Commons (`d02_e_done.png`); HP 17 -> 9 in three runs without a fight; I healed every run.
5. **Rift Station pop-up right on arrival** ("Rift Station unlocked: the Verdant Dump", `d01_walk.png`) ate the first walk.
6. **Legend and list rows move.** "Point me to..." sat at y 567, then 548, then 495 as legend entries (Stable, Growing spot, Jelly bounce pad) appeared; list rows shift too: aiming at Billie's row selected Bramble's (`d08_billie_near.png` shows "Root Cause: Brother Bramble..." floating in the world).
7. **Side-quest tracking resets to the main quest on every reload**; the HUD never showed "Drive off scavengers 1/2"; needed J > Side each time (`d06_side.png`).
8. **The Commons is a maze of counters**: trough, Granny's stall, Harvest Meal table, stone house (`d10_n1.png`, `d11_w1.png`). Runs 10-12 (179 s) spent finding the west lane.

### Markers that lied
- "Lend a hand: finish a favour" + "Where to go: Billie Muckfoot, Granny Gristle or Brother Bramble": a Bramble favour was finished and the line did not change.
- Nine scavenger circles for a two-kill quest.
- The Root Cause goal lists the Magic Bean and the Sprout Mound as main-quest "places", yet doing both produced no tracker progress.
- The dotted map route only ever drew the path to an NPC; never to the bean, the bridge or the dam.
- Yellow in-world arrows around the Commons point in three directions at once (`d11_w1.png`).

### Clarity score: 3/10
The game gave three names and the word "favour", accepted neither of the two favours I completed, and hid the real requirement (a mount for a barricade) 35 m past a bridge that itself had to be grown; the only accurate guide was a list entry the tracker never acknowledged.

---

## 3. The D.N.A. -> The Hall of Final Approvals

### Time and runs
**349.1 game seconds (5 min 49 s), 5 runs.** Prompt reached in run 05: `n05_n3.png` shows `[E] Take a number and enter the Hall of Final Approvals`; `n05_e.png` shows the dialog with "Take a number and go in".

Runs (game seconds): wx_dna_01 41.5, 02 78.0, 03 67.3, 04 68.0, 05 94.3.

### Route and what guided me
1. Quest log, first read: "Where to go: Agnes Overdue, Gerald or Clerk Ledgerbone - **or go straight up to the Hall of Final Approvals: its door is open, no favour needed**" (`n01_questlog.png`). That sentence decided the zone.
2. Map (`n01_map.png`): a floor plan, Hall ringed at the top of a central corridor. Walked north.
3. Entrance fight at the lobby door (every entry), then the front desk (`n02_n2.png`): the doorway north is behind Agnes. The way is round the desk's right end, then west behind it (`n04_behind.png`).
4. Mail Room: "Route the souls (puzzle)" desk in the centre; north door straight behind it (`n04_n1.png`).
5. Executive Floor, great doors, prompt.

### Moments of confusion
1. **Rift Station pop-up on arrival** (`n01_walk.png`): the first 3 s hold moved the hero 0.3 m.
2. **The front desk.** Dead-ended against the counter (`n02_n2.png`, run 02, 78 s), then both ends walled at z 47.6 / 46.2 (`n03_right.png`, run 03, 67 s); the passage is the one-metre slot between the desk's right end and the pillar, then west behind the desk. No arrow pointed at it; the dotted line went straight to Agnes.
3. **Mail Room cabinets** (`n04_n2.png`): a 1 s diagonal drifted me 5 m west of the centre door.
4. Minor: "Point me to..." had moved (legend y 567, I clicked 548); never needed the list here.

### Markers that lied
None. "No favour needed" was true, the top-centre dungeon marker was true, the door prompt appeared at 1.7 m.

### Clarity score: 8/10
One honest sentence in the quest log plus a readable floor plan got a stranger to the door in six minutes; the two points lost are the desk with no routing and the arrival pop-up that swallows input.

---

## Scores
**Gainlands 5/10, Verdant Dump 3/10, D.N.A. 8/10.**

## The three fixes that would have helped most
1. **Make "finish a favour" true and specific, in the D.N.A.'s words.** "or go straight up to the Hall: its door is open, no favour needed" is the model. In the Dump, either any completed favour ticks the objective (as the text promises) or the objective names the one that counts ("Unblock the Stream: borrow Gideon at the terrace stable and charge the junk dam") and the bean/bridge step gets its own tracker line. In the Gainlands, say where the road guards' road is actually entered, or remove the wall.
2. **Route the arrow and the dotted line along walkable ground, not the straight line.** The Station exit (`g14_n1.png`), the lobby desk (`n02_n2.png`) and the Commons stalls (`d11_w1.png`) all defeated a player facing the right way. Either remove the invisible wall behind Old Man Mountain (the road is drawn as open) or make the guide arrow lead to the actual gap.
3. **Make the legend's "Goal:" rows do what "Point me to..." does, keep the chosen pointer and side-quest tracking across reloads, and stop the entrance ambush and the Rift pop-up from repeating on every entry.** Together those cost about 8 of the 51 minutes played and produced the two "nothing happened" screenshots (`g05_goal_picked.png`, `d01_walk.png`).

---

## Runs per zone (game seconds, from each run's play log "play: done" timestamp)
- **Gainlands (20 runs, 1269.1 s):** 01 36.2, 02 40.3, 03 54.4, 04 34.7, 05 46.0, 06 53.7, 07 61.2, 08 54.4, 09 62.2, 10 60.6, 11 58.3, 12 52.5, 13 63.7, 14 85.5, 15 67.4, 16 87.2, 17 83.3, 18 75.9, 19 100.0, 20 91.6.
- **Verdant Dump (21 runs, 1439.1 s):** 01 48.8, 02 45.3, 03 45.2, 04 44.2, 05 61.3, 06 86.1, 07 48.2, 08 55.1, 09 49.3, 10 63.3, 11 57.7, 12 58.2, 13 67.6, 14 64.3, 15 67.4, 16 69.6, 17 100.6, 18 109.5, 19 108.6, 20 97.0, 21 91.8.
- **D.N.A. (5 runs, 349.1 s):** 01 41.5, 02 78.0, 03 67.3, 04 68.0, 05 94.3.

Bot-side notes for whoever reruns this: walk speed measured ~4.6-4.9 m/s, not 3.5; a triggered fight takes ~8 s before its Continue button exists, so `hold`s issued meanwhile are swallowed; `skip_dialogue` reports 0 taps on "E / Click to close" pop-ups, so a blind `key E` is the only closer and it will hit whatever is nearest (the Rift Station, in both the Gainlands and the Dump).
