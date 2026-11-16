# Critic S3 - the late game on the release build (Nov 16)

## 1. How I played

All 18 runs used, in about 52 minutes, on the exported build through `tools/play_exported.sh`. Scripts: `docs/review/play_scripts/s3_01.txt` to `s3_18.txt`. Screenshots and logs: `_screenshots/exported/s3_*.png`, `play_s3_<nn>_play.log`, `play_s3_<nn>.log`.

| Run | What I did | Jumps |
|---|---|---|
| s3_01 | Title, the Gate Road, quest log, map | `dev load c13cap` |
| s3_02 | Captain Spotless at the gate, Gate Plaza, Palace Approach, map again | `dev load c13cap` |
| s3_03 | 15 s search for the manhole on the Gate Plaza (not found), then the Crease, its east wall, the map inset, a hidden chest | `dev load c13cap`, `dev travel capital` |
| s3_04 | Old Service Tunnels map, at the entrance and next to the boss | `dev travel dungeon S-CAP`, `S-CAP -2` |
| s3_05 | Sergeant Scuff: room dialogue, "Before the boss" card, intro, pilot fight (lost on turn 5), defeat recap, respawn in the Crease | `dev heal`, `S-CAP -2` |
| s3_06 | Scuff again: three card drags by hand, a rule tooltip, then `dev win` to see the reward screen | `S-CAP -2`, `dev win` (Scuff only) |
| s3_07 | Wasted: `dev primm 1` lands on the castle map, not in the fight. Got the castle map | `dev load c13castle`, `dev primm 1` |
| s3_08 | Primm phase 1: opening dialogue (part), the Model Room picture, "Before the boss" card, pilot 45 s (turn 5, me 13 HP, Primm 37 HP, still running) | same |
| s3_09 | Wasted: tried to lose by ending turns; stuck behind the "End your turn?" check on turn 1 | same |
| s3_10 | `c13end`: stood on the Gate Road pressing E. No ending started | `dev load c13end` |
| s3_11 | `c13end`: took the Crease shaft to Grave Row, walked to its north end. No ending started | `dev load c13end`, `dev travel capital` |
| s3_12 | `c13post`: quest log, the freed gate and Gate Plaza, Crosspath's fountain square, the HUD Menu | `dev load c13post`, `dev travel town` |
| s3_13 | Primm phase 3: intro, pilot 70 s (turn 6, me 13 HP, Primm 44 HP, still running) | `dev load c13castle`, `dev primm 3` |
| s3_14 | Tried to lose in phase 1; stuck behind "Hand full: toss 2 cards" on turn 2 | `dev primm 1` |
| s3_15 | Same; reached turn 5 with 4 HP when the run ended | same |
| s3_16 | Same; the run hit the time limit with no screenshot | same |
| s3_17 | Lost to Primm on turn 6. My next scripted Space press closed the defeat screen before I shot it; I was back in the Crease with Old Hob | same |
| s3_18 | Tried to lose again without the Space press; my own `button again` kept unticking "Don't ask again", stuck on turn 4 | same |

**Not reached:** "Fight Primm again" (I lost to Primm once, in s3_17, and my own script dismissed the defeat screen before any screenshot), Primm's phase 2, the end of any Primm phase, the ending and its pictures, the credits and their logo, the two memory pictures, the Tessar reveal, Scuff's closing words, Scuff's Bestiary page. The pilot cannot finish a Primm phase inside one 170 s run and a fight cannot be resumed, so I never beat Primm. Six of my 18 runs went on trying to lose to him. Sections 2 to 4 are limited by all of this.

**Things about the runs you should know:**
- Runs s3_14, s3_15 and s3_17 started while a Godot process that was not mine was running (`tasklist` showed it; from s3_16 on I waited for it to clear, and in s3_17 one started in the seconds between my check and my launch). Someone else was driving the game on this PC at the same time. Those three runs loaded 5 s slower but behaved normally.
- `c13castle` loads in Crosspath's square, not at the castle (s3_07_00_castle.png).
- `c13end` and `c13post` loaded to what looked like the same state: Gate Road, level 21, 2360 gold, quest "Under the Forest", the same caption.
- In the Model Room picture E advances the line, it does not complete it first, so my shots there caught half-typed lines. I read only fragments of Primm's opening speech.

## 2. Scores

**Clarity 5/10.** Inside a fight the game explains itself well: the "Before the boss" card, rule tooltips, the defeat recap with "what beat you" and one tip. Outside fights I got lost twice: I could not find the manhole the main quest names (the map does not mark it), and after Primm falls the tracker already points to Crosspath while the ending waits "at the end of Grave Row", announced only by a caption.

**Fun 6/10.** The Capital is a pleasure to walk into and Scuff, Spotless, Old Hob and Primm are funny in every line I read. The fights I saw were one-sided: a level-20 hero with 23 HP flattened in five turns by a +5/+3 side boss, and Primm at 44 of 56 HP when I was at 13.

**Polish 6/10.** Portraits, the tunnel and castle maps, the Model Room picture, Primm's phase 3 intro and the freed fountain are release quality. Against that: the old four-symbol set (sun, wave, leaf, flame round a star) is painted large on the tunnel map and the tunnel battle board, the regime's smiling-sun banners still hang after Primm falls, and labels overlap on the map and the HUD.

## 3. Findings

| # | What | Where | Kind | Size | Smallest fix |
|---|---|---|---|---|---|
| 1 | The mural over "The Four-Faction Junction" shows the four Paths as a sun, a blue wave, a green sprig and a red flame round a star. None is a Path icon (arm, chef's hat, leaf in arrows, skull). | s3_04_04_nearboss.png, s3_05_03_next.png | wrong icon | L | Repaint the mural with the four real icons in ring order |
| 2 | The battle board in the Old Service Tunnels has the same wrong set as its floor medallion: sun, tree, wave, flame round a star, in the middle of the table for the whole fight. | s3_06_04_rulehover.png, s3_05_09_afterpilot.png | wrong icon | L | Replace the medallion with the four-icon ring, or a plain floor |
| 3 | After Primm falls the Capital still flies his emblem: black smiling-sun banners on the outer wall and gate, smiling-face banners and painted smiling suns on Grave Row, smiling suns on the Gate Plaza plinth. The fountain statue is toppled and bunting is up, so the banners read as a miss. | s3_12_03_gate.png, s3_10_b10.png, s3_11_04_n2.png, s3_12_04_plaza.png | story | M | Swap or strike the regime banners and plinth suns in the freed state |
| 4 | After Primm falls the tracked main quest is already the postgame "Under the Forest - Go to Crosspath". The ending is hinted only by a caption, "At the end of Grave Row, the city is gathering at dusk." No quest step, no map marker, no goal arrow. I went to Grave Row, walked to its north end, pressed E for a minute; nothing started. Two runs, ending never seen. | play_s3_10_play.log 128.0, play_s3_11_play.log 137.7, s3_11_90_end.png, s3_11_02_map.png | confusing | M | Make "Join the gathering at the end of Grave Row" the tracked step, with a marker, before "Under the Forest" appears |
| 5 | Losing to Primm: about 2 s after the DEFEAT banner one Space press (or the click that came 1 s before it) closed the defeat screen, and I was in the Crease, under the city, with Old Hob, with the tracker back on "Browse Fig Sly's Black Market". If "Fight Primm again" is on that screen it is not the default, and a player still tapping Space to end turns loses it without seeing it. | play_s3_17_play.log 135.2 to 151.1, s3_17_c5.png, s3_17_c6.png | confusing | S | Ignore input for 1 s after the defeat screen opens; make "Fight Primm again" the default button |
| 6 | The `c13post` state (after the credits) shows the same "the city is gathering at dusk" caption on arrival as `c13end`. | play_s3_12_play.log 26.9 | broken | S | Stop the caption once the ending has been seen |
| 7 | The main quest says "Knock at the manhole on the Gate Plaza" and the log says "down the manhole on the Gate Plaza", but the Capital map has no marker for the manhole or any other way down. I searched the plaza's west half for 15 s and did not find it. | s3_02_11_map2.png, play_s3_03_play.log 43.7 to 59.6 | confusing | S | Add an "Exit / portal" marker "Manhole to the Crease" on the Gate Plaza |
| 8 | Primm's rule row has 10 icons in phase 1 (9 in phase 3); the "Before the boss" card lists 8 rules and 1 hidden trait. The first and last icons are the same three-line icon, so one rule looks shown twice. | s3_09_01_hover_last.png, s3_08_23_afterpilot.png, s3_13_23_afterpilot.png against s3_08_20_card.png | broken | S | Drop the duplicate, or give the last one its own icon and a line on the card |
| 9 | The four leader boons on Primm's card and in the rule row all use one green amulet icon. Flex's Heart, the Grand Chef's Feast, Agnes's Appeal and Compostella's Roots are the one place where the four Path icons would explain themselves. | s3_08_20_card.png | wrong icon | S | Use each Path's icon for its leader's boon |
| 10 | The "Before the boss" card has the same header backdrop for Scuff and for Primm: a mossy forest shrine with candles. Scuff is in a sewer; Primm is in a white and gold palace. | s3_05_05_next.png, s3_08_20_card.png | ugly | M | A backdrop per dungeon (its own map art, cropped) |
| 11 | Primm's battle board is a sunny harbour village with boats and market stalls. The room is "The Model Room" and the picture a moment before shows a gilded mirror hall with a model on a table. Nothing on the board says "this is the model". Phase 3's purple tint over it is good. | s3_08_23_afterpilot.png against s3_08_d05.png | story | L | Frame the village as the tabletop model (table edge, mirrors behind), or set the board in the hall |
| 12 | Scuff's reward for a level-20 boss: Traveling Brawler 3/2, Adventurer's Pack, Gym Bro 1/1 (two commons, one uncommon). Reroll costs 240 gold against 120 won. | s3_06_06_win2.png | confusing | S | Late bosses offer rare or better |
| 13 | "+120 gold" and under it "Clear bonus: +95 gold (everything this run paid you, once more)". 95 is not 120 and the screen does not say what the 95 is. | s3_06_06_win2.png | confusing | S | Show the sum, or "(the gold from this dungeon's earlier rooms, again)" |
| 14 | After a defeat the respawn message ("Back at the respawn point with full HP. The cards, gold and items you won are kept.") is drawn behind Old Hob's dialogue box; its second line is cut off. | s3_05_11_closing2.png | ugly | S | Show it after the dialogue closes, or above the portrait |
| 15 | The Crease inset on the map: six purple shaft markers in a row, three labelled, labels running into each other. On the big map "Primm's Castle" and "Dorrit's Last Stall Before the Castle" print across their own markers, and "Widow Pell" is cut by the hero arrow. | s3_03_07_creasemap.png, s3_02_11_map2.png, s3_11_02_map.png | ugly | S | Label a shaft on hover only; offset the castle labels |
| 16 | The map legend calls Captain Spotless's marker a "Golem gate". He is a man with a moustache at a city gate. | s3_02_11_map2.png | confusing | S | "Gatekeeper" |
| 17 | "Get inside the Capital's wall" is ticked while the hero stands outside the wall on the Gate Road with the gate captain still ahead. | s3_01_02_capital.png, s3_01_06_walk_n2.png | confusing | S | Tick it on passing the gate |
| 18 | The HUD Menu has Character, Deck, Quests, Packs, Wardrobe, Glossary, Feats, Settings. No Collection Book or Bestiary, so I could not look Scuff up from there. | play_s3_12_play.log 75.5, s3_12_09_menu.png | confusing | S | Add "Collection Book" to the HUD Menu |
| 19 | Crosspath's fountain square: one roof fills the right third of the screen and another the left edge when the hero stands by the fountain. | s3_12_06_square.png, s3_07_00_castle.png | ugly | M | Fade roofs that sit between the camera and the hero |
| 20 | Small things. Grave Row after the fall has long black streaks across the checker floor beside the rift cracks (s3_11_04_n2.png). A grey hexagon floats in the Crease's dark foreground (s3_17_c7.png). In a fight the "Rules of this fight" caption is half hidden by its icon row and the "-7" lands on the "You" name (s3_05_09_afterpilot.png). In the Model Room picture E skips a half-typed line where everywhere else E completes it first (s3_08_d05.png). A Crosspath caption speaks of "Brannoch's gate", a name nothing else I saw uses (play_s3_12_play.log 75.5). | as named | ugly | S | One by one |

## 4. Checked and fine

- **Sergeant Scuff's portrait, intro figure and Bestiary picture:** the portrait in dialogue (s3_05_03_next.png), the figure on the "Before the boss" card (s3_05_05_next.png) and the full intro figure (s3_05_06_next.png) are all his own: a nervous young sergeant in a white helmet with a checklist and a lantern, mud on his boots and hem. Fine. Bestiary picture NOT checked (finding 18).
- **Every rule in Primm's fight shown once:** on the "Before the boss" card yes, 8 rules once each (s3_08_20_card.png). In the fight's icon row NO, the first and last icons match (finding 8). Phase 2 not seen.
- **The two memory pictures and the ending's pictures:** NOT seen.
- **The credits' logo:** NOT seen.
- **The bars of the cell, Maren's eyes, the name Tessar:** no line I read mentioned the cell or Maren. "Tessar" appeared in no line, name plate or label I read; the hero's plate in the Model Room picture is "You" (s3_08_d05.png) and in fights "You". I did not reach the reveal and read Primm's speech only in fragments.
- **The freed Capital's banners and statues:** statues fine (Primm's statue lies face down in the fountain, bunting is up, s3_12_04_plaza.png). Banners WRONG (finding 3).
- **Crosspath's banners and statues:** the square has lamp-post banners and small plinth figures round the fountain (s3_12_06_square.png, s3_12_08_square_e.png). At the game's camera they are too small for me to say which icon is on each. Nothing looked wrong; not confirmed right.
- **The Capital map's district names and Crease inset:** names appear as you explore and sat where I walked: Gate Road, Gate Plaza, Palace Approach, Reek, Rift Fields, Grave Row (s3_03_07_creasemap.png, s3_11_02_map.png). The inset is there, titled "The Crease - under the city", and the hero's arrow shows in it when below. Its labels overlap (finding 15).
- **The minimap in the Capital:** fine. It follows the hero, shows the plaza's shape and markers, and switches to the Crease's shape underground (s3_02_04_plaza.png, s3_03_06_crease.png).
- **The Crease's east wall:** fine. Solid rock, no gap, no see-through (s3_03_09_eastwall.png, s3_03_11_ne_wall.png). The hero is half hidden behind a crystal in the north-east corner.
- **Primm's emblem before the fall:** the smiling sun is only on the regime's own banners, plinths and walls (s3_01_08_walk_n3.png, s3_02_05_plaza2.png). Fine.
- **Primm's own art:** portrait, the Model Room picture and the phase 3 intro with the cracked mirror are his own and consistent (s3_08_d01.png, s3_08_d05.png, s3_13_21_intro.png). Fine.

## 5. SCRIPT ERROR lines

None. `grep "SCRIPT ERROR"` printed nothing for the game logs of all 18 runs (`play_s3_01.log` to `play_s3_18.log`).

Not SCRIPT ERRORs, but at exit the game log of every one of the 18 runs has a `WARNING: ... ObjectDB instances were leaked at exit` line; in s3_16 it reads `186 ObjectDB instances were leaked at exit`, followed by `ERROR: 5 resources still in use at exit`.

## 6. What worked (keep exactly as it is)

1. **The walk into the Capital.** Grey fog and dead trees on the Gate Road, then the gate opens on a pastel checkerboard plaza with gold statues and smiling suns (s3_01_06_walk_n2.png, s3_02_04_plaza.png). It tells Primm's story without a word. The freed plaza, with the statue face down in the fountain and bunting overhead, is just as good (s3_12_04_plaza.png).
2. **The voices.** Scuff: "HALT, please." and "Sub-Inspector of Tunnels That Do Not Exist". Spotless: "You are approved, and I should like it noted that I have always supported this outcome." and, after the fall, "A smudge on my sleeve. I have decided to allow it. Retroactively." Primm in phase 3: "Do mind the floor. It has just been polished, by seventeen people, whom I thank daily, in writing." Old Hob at the respawn: "Not on my list. Off you pop." The portraits match the voices.
3. **The fight's teaching.** The "Before the boss" card, the same icons on the table with tooltips ("Applies to the enemy only"), the "End your turn? You can still play your Infrastructure" check, "Space tosses the lowest-value cards", and after a loss "Village Militia dealt all 23 damage you took (3 hits)" with one concrete tip (s3_05_05_next.png, s3_09_03_state.png, play_s3_05_play.log 109.3).
