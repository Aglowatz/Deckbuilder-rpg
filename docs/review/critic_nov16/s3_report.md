# Critic S3 - the late game on the release build (Nov 16)

## 1. How I played

12 runs of the 18 (the 75-minute clock ran out first), all on the exported build through `tools/play_exported.sh`, scripts `s3_01.txt` to `s3_12.txt`.

| Run | What | Jumps |
|---|---|---|
| s3_01 | Title, the Gate Road, quest log, map | `dev load c13cap` |
| s3_02 | Captain Spotless at the gate, Gate Plaza, Palace Approach, map again | `dev load c13cap` |
| s3_03 | 15 s search for the manhole on the Gate Plaza (not found), then the Crease, east wall, map inset, a hidden chest | `dev load c13cap`, `dev travel capital` |
| s3_04 | Old Service Tunnels map at the entrance and next to the boss | `dev travel dungeon S-CAP`, `S-CAP -2` |
| s3_05 | Sergeant Scuff: room dialogue, "Before the boss" card, intro, pilot fight (lost on turn 5), defeat recap, respawn in the Crease | `dev heal`, `S-CAP -2` |
| s3_06 | Scuff again: three drags by hand, a rule tooltip, then `dev win` to see the reward screen | `S-CAP -2`, `dev win` (Scuff only) |
| s3_07 | Wasted: `dev primm 1` lands on the castle map, not in the fight; got the castle map | `dev load c13castle`, `dev primm 1` |
| s3_08 | Primm phase 1: opening dialogue (part), story picture, "Before the boss" card, pilot 45 s (turn 5, me 13 HP, Primm 37 HP, still running at the time limit) | `dev load c13castle`, `dev primm 1` |
| s3_09 | Wasted: tried to lose by ending turns; my `button End` never got past the "You can still play your Infrastructure" confirm, the fight stayed on turn 1 | same |
| s3_10 | `c13end`: stood on the Gate Road pressing E; no ending started | `dev load c13end` |
| s3_11 | `c13end`: took the Crease shaft to Grave Row and walked to its north end; no ending started | `dev load c13end`, `dev travel capital` |
| s3_12 | `c13post`: quest log, the freed gate and Gate Plaza, Crosspath's fountain square, the HUD Menu | `dev load c13post`, `dev travel town` |

**Not reached:** Primm's phases 2 and 3, "Fight Primm again", the ending pictures, the credits and their logo, the two memory pictures, Scuff's closing words (I only won by `dev win` and stopped at the reward screen), Scuff's Bestiary page, the Tessar reveal line. I never beat or lost to Primm. Everything in sections 2 to 4 is limited by that.

A note on the snapshots: `c13castle` loads in Crosspath's square, not at the castle (s3_07_00_castle.png). `c13end` and `c13post` loaded to what looked like the same state (Gate Road, level 21, 2360 gold, quest "Under the Forest", same caption).

## 2. Scores

**Clarity 5/10.** Inside a fight the game explains itself well (the "Before the boss" card, rule tooltips, the defeat recap with "what beat you" and a tip). Outside fights I got lost twice: I could not find the manhole that the main quest names and the map does not mark it, and after Primm falls the tracker already points to Crosspath while the ending waits somewhere at "the end of Grave Row", announced only by a caption.

**Fun 6/10.** The Capital is a pleasure to walk into, and Scuff and Spotless are funny in every line I read. The fights I saw were a level-20 hero with 23 HP being flattened in five turns by a +5/+3 side boss, and the reward for beating him was a choice of a 1/1, a 3/2 and a Tool.

**Polish 6/10.** Portraits, the tunnel and castle maps, the Model Room picture and the freed fountain are release quality. Against that: the old four-symbol set (sun, wave, leaf, flame round a star) is painted large on the tunnel map and the tunnel battle board, the regime's smiling-sun banners still hang after Primm falls, and there are overlapping labels on the map and the HUD.

## 3. Findings

| # | What | Where | Kind | Size | Smallest fix |
|---|---|---|---|---|---|
| 1 | The mural over "The Four-Faction Junction" shows the four Paths as a sun, a blue wave, a green sprig and a red flame round a star. None is the Path icon (arm, chef's hat, leaf in arrows, skull). | s3_04_04_nearboss.png, s3_05_03_next.png | wrong icon | L | Repaint the mural with the four real icons in ring order |
| 2 | The battle board in the Old Service Tunnels has the same wrong set as its floor medallion: sun, tree, wave, flame round a star, filling the middle of the table for the whole fight. | s3_06_04_rulehover.png, s3_05_09_afterpilot.png | wrong icon | L | Replace the medallion with the four-icon ring, or a plain floor |
| 3 | After Primm falls the Capital still flies his emblem: the black banners with the smiling sun on the outer wall and gate, the smiling-face banners and painted smiling suns on Grave Row, the smiling suns on the Gate Plaza plinth. The fountain statue is toppled and there is bunting, so the wall reads as a miss, not a choice. | s3_12_03_gate.png, s3_10_b10.png, s3_11_04_n2.png, s3_12_04_plaza.png | story | M | Swap or strike the regime banners and plinth suns in the freed state |
| 4 | After Primm falls the tracked main quest is already the postgame "Under the Forest - Go to Crosspath". The ending is only hinted by a caption, "At the end of Grave Row, the city is gathering at dusk." No quest step, no map marker, no goal arrow. I went to Grave Row, walked to its north end and nothing started; two runs spent, ending never seen. | play_s3_10_play.log 128.0, play_s3_11_play.log 137.7, s3_11_90_end.png | confusing | M | Make "Join the gathering at the end of Grave Row" the tracked step with a marker, before "Under the Forest" appears |
| 5 | The `c13post` state (after the credits) shows the same "the city is gathering at dusk" caption on arrival as `c13end`. If the credits have rolled, the invitation should be gone. | play_s3_12_play.log 26.9 | broken | S | Stop the caption once the ending has been seen |
| 6 | The main quest says "Knock at the manhole on the Gate Plaza" and the log says "down the manhole on the Gate Plaza", but the Capital map has no marker for the manhole or any way down to the Crease. I searched the plaza's west half for 15 s and did not find it. | s3_02_11_map2.png, play_s3_03_play.log 43.7-59.6 | confusing | S | Add an "Exit / portal" marker named "Manhole to the Crease" on the Gate Plaza |
| 7 | Primm's rule row in the fight has 10 icons; the "Before the boss" card lists 8 rules and 1 hidden trait. The first and the last icon look identical (three lines), so one rule appears to be shown twice. | s3_09_01_hover_last.png, s3_08_23_afterpilot.png against s3_08_20_card.png | broken | S | Drop the duplicate, or give the tenth its own icon and a line on the card |
| 8 | The four leader boons on Primm's card and in the rule row all use one green amulet icon. Flex's Heart, the Grand Chef's Feast, Agnes's Appeal and Compostella's Roots are the one place where the four Path icons would explain themselves. | s3_08_20_card.png | wrong icon | S | Use each Path's icon for its leader's boon |
| 9 | The "Before the boss" card has the same header backdrop for Scuff and for Primm: a mossy forest shrine with candles. Scuff is in a sewer; Primm is in a white and gold palace. | s3_05_05_next.png, s3_08_20_card.png | ugly | M | A backdrop per dungeon (the dungeon's own map art, cropped) |
| 10 | Primm's battle board is a sunny harbour village with boats and market stalls. The room is "The Model Room" in a white and gold castle, and the story picture a moment before shows a gilded mirror hall. | s3_08_23_afterpilot.png against s3_08_d05.png | story | L | A board set in the mirror hall, or frame the village so it reads as the tabletop model |
| 11 | Scuff's reward for a level-20 boss: Traveling Brawler 3/2, Adventurer's Pack, Gym Bro 1/1 (two commons, one uncommon). Reroll costs 240 gold against 120 won. | s3_06_06_win2.png | confusing | S | Late bosses offer rare or better |
| 12 | "+120 gold" and under it "Clear bonus: +95 gold (everything this run paid you, once more)". 95 is not 120 and the screen does not say what the 95 is made of. | s3_06_06_win2.png | confusing | S | "Clear bonus: +95 gold (the gold from this dungeon's earlier rooms, again)" or show the sum |
| 13 | After a defeat the respawn message ("Back at the respawn point with full HP. The cards, gold and items you won are kept.") is drawn behind Old Hob's dialogue box; its second line is cut off. | s3_05_11_closing2.png | ugly | S | Show the message after the dialogue closes, or move it above the portrait |
| 14 | The Crease inset on the map: six purple shaft markers in a row, three labelled, the labels run into each other ("Shaft to the Reek" sits over other markers; "Fig Sly's Contraband & Curiosities" touches "Rift Express station"). On the big map "Primm's Castle" and "Dorrit's Last Stall Before the Castle" print across their own markers. | s3_03_07_creasemap.png, s3_02_11_map2.png | ugly | S | Label a shaft on hover only; offset the two castle labels |
| 15 | The map legend calls Captain Spotless's marker a "Golem gate". He is a man with a moustache at a city gate. | s3_02_11_map2.png | confusing | S | "Gatekeeper" |
| 16 | "Get inside the Capital's wall" is ticked while the hero stands outside the wall on the Gate Road with the gate captain still in the way. | s3_01_02_capital.png, s3_01_06_walk_n2.png | confusing | S | Tick it on passing the gate |
| 17 | The HUD Menu has Character, Deck, Quests, Packs, Wardrobe, Glossary, Feats, Settings. No Collection Book or Bestiary, so I could not look Scuff up from there. | play_s3_12_play.log 75.5, s3_12_09_menu.png | confusing | S | Add "Collection Book" to the HUD Menu |
| 18 | Crosspath's fountain square: a roof fills the right third of the screen and another the left edge when the hero stands by the fountain. | s3_12_06_square.png, s3_07_00_castle.png | ugly | M | Fade roofs that sit between the camera and the hero |
| 19 | Grave Row after Primm falls: long black streaks lie across the checker floor next to the rift cracks, like shadow slivers or gaps. Also the name "Grave Row" on a pastel street of doll's houses is not explained by anything on screen. | s3_11_04_n2.png | ugly | S | Remove the streaks |
| 20 | Small HUD overlaps in a fight: the "Rules of this fight" caption is half hidden by the icon row, and the "-7" damage number lands on the "You" name. In Crosspath a caption speaks of "Brannoch's gate", a name nothing else I saw uses. | s3_05_09_afterpilot.png, play_s3_12_play.log 75.5 | ugly | S | Move the caption up 8 px; offset the damage number |

## 4. Checked and fine

- **Sergeant Scuff's portrait, intro figure and Bestiary picture:** portrait in dialogue (s3_05_03_next.png), figure on the "Before the boss" card (s3_05_05_next.png) and the full intro figure (s3_05_06_next.png) are all his own: a nervous young sergeant in a white helmet with a checklist and a lantern, mud on his boots. Bestiary picture NOT checked (no Bestiary entry in the HUD Menu, finding 17).
- **Every rule in Primm's fight shown once:** on the "Before the boss" card yes, each of the 8 rules once (s3_08_20_card.png). In the fight's icon row NO: 10 icons, the first and last look the same (finding 7). Phases 2 and 3 not seen.
- **The two memory pictures and the ending's pictures:** NOT seen.
- **The credits' logo:** NOT seen.
- **The bars of the cell, Maren's eyes, the name Tessar:** nothing I read mentioned the cell or Maren. "Tessar" appeared in no line, name plate or label I read; the hero's plate in the Model Room picture is "You" (s3_08_d05.png). I did not reach the reveal.
- **The freed Capital's banners and statues:** statues right (Primm's statue lies toppled in the fountain, bunting is up, s3_12_04_plaza.png); banners WRONG (smiling-sun banners still on the wall, the gate and Grave Row, finding 3).
- **Crosspath's banners and statues:** the square has lamp-post banners and small plinth figures round the fountain (s3_12_06_square.png, s3_12_08_square_e.png); at the game's camera they are too small for me to tell which icon is on them. Nothing looked wrong; not confirmed right.
- **The Capital map's district names and Crease inset:** names appear as you explore and were right where I walked: Gate Road, Gate Plaza, Palace Approach, Reek, Rift Fields (s3_03_07_creasemap.png). The inset is there, titled "The Crease - under the city", and the hero's arrow shows in it when below; its labels overlap (finding 14).
- **The minimap in the Capital:** fine. It follows the hero, shows the plaza's shape and markers, and switches to the Crease's shape underground (s3_02_04_plaza.png, s3_03_06_crease.png).
- **The Crease's east wall:** fine. A solid rock wall, no gap, no see-through (s3_03_09_eastwall.png, s3_03_11_ne_wall.png). The hero is half hidden behind a crystal in the north-east corner.
- **Regime emblem before the fall:** smiling sun only on the regime's own banners, plinths and walls (s3_01_08_walk_n3.png, s3_02_05_plaza2.png). Fine.

## 5. SCRIPT ERROR lines

None. `grep "SCRIPT ERROR"` printed nothing for the game logs of runs s3_01 to s3_12.

## 6. What worked (keep exactly as it is)

1. **The walk into the Capital.** Grey fog and dead trees on the Gate Road, then the gate opens on a pastel checkerboard plaza with gold statues and smiling suns (s3_01_06_walk_n2.png to s3_02_04_plaza.png). It tells the story of Primm without a word. The freed version with the statue face down in the fountain and bunting is just as good (s3_12_04_plaza.png).
2. **Scuff and Spotless.** "HALT, please." / "Sub-Inspector of Tunnels That Do Not Exist" / "You are approved, and I should like it noted that I have always supported this outcome." / "A smudge on my sleeve. I have decided to allow it. Retroactively." The portraits match the voices. Old Hob's "Not on my list. Off you pop." at the respawn is the right joke in the right place.
3. **The "Before the boss" card and the defeat recap.** Rules with icons before the fight, the same icons on the table with tooltips ("Applies to the enemy only"), and after a loss "Village Militia dealt all 23 damage you took (3 hits)" plus one concrete tip (s3_05_05_next.png, play_s3_05_play.log 109.3). The "You can still play your Infrastructure" check before ending a turn belongs with these.
