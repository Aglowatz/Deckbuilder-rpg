# Critic report S1 - the first hour on the release build (Nov 16)

Build: The Wayward Path v1.0.0 (exported Windows build), Path played: **Refusemancer**.

## 1. How I played

- **14 runs used** (budget 16; the coordinator capped the last stretch at 5), about 35 minutes on the clock. Scripts: `docs/review/play_scripts/s1_01.txt` ... `s1_14.txt` (plus my helpers `run.sh`, `flt.sh` in the same folder).
- Runs 1-3: title, New Game, the whole opening read line by line, the Path choice (hover, pick, "More"), `dev save s1_a` in the forest clearing.
- Run 4: Deck Station (B) in the forest, walk to the cave gate, enter, the dungeon map and its tip.
- Runs 5-10: the Forgotten Cave. Run 5 was wasted by me (I did not press E at the gate), run 7 was wasted by me (my Escape opened the pause menu and the pilot "played" a paused game). First fight (Cave Scavenger) played partly by hand in runs 7 and 8 (Keep Hand, play an infrastructure, play a unit, read the tips) and finished by the pilot; won three times by the pilot in 4-6 turns. Reward pick taken. The Hollow Well pop-up read. Second fight (Hollow Stalker): **the pilot lost it**, and I was put back in the forest clearing.
- **Stuck:** the cave cannot be snapshotted mid-way with the driver, and one 170 s run was not enough for me to get through fight 1 + Well + fight 2 + shrine + boss. After being stuck in the cave for more than one run I **jumped**: `dev travel town` (runs 11, 13, 14) and `dev travel zone refusemancer` (run 14). Snapshot `s1_e` = forest after the defeat (160 gold, one reward card). Snapshot `s1_f`, saved in town with the Character page open, loaded back into the **forest** in run 12 (run 12 wasted; driver quirk or snapshot bug, I cannot tell which).
- Runs 11, 13, 14: Crosspath square, town map and "Point me to...", quest log, Character page, walk north (reached Tilly Tonic's yard), walk to the south edge, walk east to the lake, Deck Station in town; then the first minute of the Verdant Dump (bridge, hub, zone map).
- **Not reached:** the shrine pop-up, the Cave Warden and his closing words, Elder Maren (never found her house), any shop's inside, any quest, any conversation after the opening, the walk out of town by road (zone was a jump). Everything in section 4 about those is marked "not seen".

## 2. Scores

- **Clarity 6/10.** The opening, the Path choice and the first-duel tips explain themselves well and the goal line ("Settle in: talk to Elder Maren at her home, north of the square") is always on screen. But that goal has no marker: Maren is not on the town map nor in "Point me to...", and walking "north of the square" brought me to an item vendor's yard, not to her.
- **Fun 6/10.** The first duel is quick and readable (3 HP enemy, won in 4-6 turns at 2x) and the reward pick of three cards lands well. I saw too little beyond it (one lost fight, no quest, no shop) to rate it higher, and being sent back to the forest with "the cave starts over" after one loss in fight 2 stings in the first ten minutes.
- **Polish 7/10.** Title screen, dialogue portraits, the cave's painted room map, the Path choice and the Deck Station look finished and consistent. The maps and the minimap (blurry blocks), a "Dev Shrine (+1 level)" prompt in town, overlapping banners, and one spot where the hero stopped responding pull it down.

## 3. Findings (most important first)

| # | What | Where | Kind | Size | Smallest fix |
|---|---|---|---|---|---|
| 1 | A **"[E] Pray at the Dev Shrine (+1 level)"** prompt on a crystal pedestal beside the lake in Crosspath, in the release build. A player can walk to it. | `s1_14_05_east.png`; log run 14, 60.9 s: `near: dev_shrine ... E -> dev_shrine` | broken | S | Remove or hide the dev shrine in exported builds. |
| 2 | The current goal "talk to Elder Maren at her home, north of the square" has **no marker**: Maren / her home is not on the town map, not in the "Point me to..." list (16 entries, none is Maren), and no arrow was visible in the world. Walking north from the square I ended in Tilly Tonic's yard. (I arrived by `dev travel town`, so if the normal arrival adds a marker I did not see it.) | `s1_11_11_pointme.png`, `s1_13_03.png` | confusing | S | Add "Elder Maren's home" to the map and the Point-me list while that goal is active. |
| 3 | **Hero stopped responding to movement** north of the square: after opening and closing the quest log (J, J) beside the barrels in Tilly's yard, four holds (S 9 s, D 1.2 s, S 5 s x3, D 5 s) moved him nowhere; position stayed (16.3, -0.8) for 35 s. Screenshots show the town with no pop-up open and the hero standing inside the barrel row. B still opened the Deck Station afterwards. | log run 13, 74.5-109.9 s `hero at (16.3, -0.8)`; `s1_13_12.png` ... `s1_13_15_south.png` | broken (stuck spot or input left locked after the quest log) | M | Check collision between the barrels at Tilly's yard, and that closing the quest log with J gives movement back. |
| 4 | **Zone entrance pennants show wrong Path art**: on the Verdant Dump's entrance bridge the left pennant is a single pale lobed leaf on dark green (not the leaf inside three recycling arrows), the right one a white paw print on red. | `s1_14_10_zone.png` (bottom left and right) | wrong icon | S | Use the Refusemancer disc on both pennants. |
| 5 | **Reward card says "joins your deck" but is not in the deck later.** After fight 1 I took a card in run 10 (the same screen in run 9 reads "Let Them Eat Cake joins your deck.", log 71.4 s); in fight 2 my deck was 46 cards (Deck 41 after drawing 5). After the defeat and the trip to town the Deck Station shows 45 cards and the reward (Heap Tortoise) at "Deck 0/3 Own 1". | `s1_13_17_deckstation.png`; log run 10, 80.0 s `Deck 41` | confusing | S | Keep the card in the deck after a defeat, or say "added to your collection". |
| 6 | **Maps and minimap are blurry, blocky silhouettes.** The forest map is a smeared beige blob on black; the town map and every minimap are coarse pixel blocks next to crisp gold UI. | `s1_03_20_map.png`, `s1_11_11_pointme.png`, minimap in `s1_11_01_town.png`, `s1_14_05_east.png` | ugly | M | Draw the walkable area at a higher resolution with a hard edge, or use painted maps as the cave does. |
| 7 | **One loss in the second cave fight restarts the whole cave** ("You come round in the forest clearing at full HP. The cave starts over"). The built-in simple player lost to the Hollow Stalker (5 HP) at full HP right after the tutorial fight. I did not play that fight by hand, so I only report that it happened and how it is handled. | `s1_10_n3_c.png`; log run 10, 111.7 s | confusing / pacing | M | Let the first dungeon restart at the last cleared room, or at least keep the Well visited. |
| 8 | The defeat toast is drawn **on top of the area banner**: the scroll's title is hidden behind the dark toast bar and only "Somewhere outside Crosspath" shows under it. | `s1_10_n3_c.png` | ugly | S | Queue the toast after the area banner or move it below. |
| 9 | **Turn counter shows "Turn 1" on turn 6.** During the "YOUR TURN" banner the banner subtitle and the side panel both read "Turn 1" (my deck was already at 35); three seconds later the panel reads "Turn 6". | `s1_06_05.png` then `s1_06_07.png`; log run 6, 98.1 and 101.6 s | broken | S | Update the turn number before the banner is shown. |
| 10 | The **Hollow Well** pop-up's header picture is not a well: it shows a round medallion of playing cards with a lightning bolt between two candle-lit niches. The text (dry spring, "still listens, and still trades", heal 4 HP / lose a random card, "already full ... the well asks for nothing") is clear and good. | `s1_10_n2_a.png` | ugly / inconsistent | S (L if new art) | Use the well's own picture or icon in the header. |
| 11 | Town map label **"Bertram Beetsworth - Assistant to the Regional Mercha..."** is cut off by the Point-me panel and collides with other markers; "The Harvest Meal" and "Granny Gristle's Compost Grange" overlap their markers on the Dump map. | `s1_11_11_pointme.png`, `s1_14_16_zonemap.png` | ugly | S | Short labels on the map (name only), full title in the list. |
| 12 | **C does not close the Character page** (J toggles the quest log, C opened the page and a second C left it open; P did nothing visible on top of it). | `s1_11_21_s.png` (page still open 20 s and four walk holds after the second C); log run 11, 84.7 s still dumps CHARACTER | confusing | S | Make every page key a toggle. |
| 13 | **Path Essence** on the Character page is shown by four coloured potion bottles, not by the four Path icons. | `s1_11_21_s.png` | wrong icon (if essence is meant to read as "a Path") | S | Put the Path disc beside each count. |
| 14 | The first town view is one-third **foreground roofs** with a heavy blur; the hero and the fountain are small in the middle and passers-by are labelled just "Townsfolk". Tilly's yard view is the same (a roof fills the left 40 %). | `s1_11_01_town.png`, `s1_13_03.png` | ugly | M | Fade or lower roofs between camera and hero; weaker depth blur. |
| 15 | "Equip up to 4 single-use items" directly above "Equipped 0 of 2" on the Character page at level 1. | `s1_11_21_s.png` | confusing | S | "Equip up to 2 (4 at level 12)". |
| 16 | The Verdant Dump's first view is a brown-orange haze: little in it reads as green or "verdant", and distant props are a blur. The zone HP bar is red inside a green frame at full HP. | `s1_14_10_zone.png`, `s1_14_13_zone.png` | ugly | M | Less haze at the entrance; one clear landmark in focus. |
| 17 | In the first duel a just-played infrastructure sits as a tiny tilted card between the hand and the board, and the hand overlaps the infrastructure row all fight. | `s1_07_04.png`, `s1_06_07.png` | ugly | S | Raise the infrastructure row or lower the hand. |
| 18 | "Deck (B)" and the full Deck Station (with its "saved decks sit in the racks" tip) are available in the forest before the first fight; J does nothing there. | `s1_04_01_deck.png`, `s1_03_21_quests.png` | confusing (minor) | S | Fine to keep; hide the station's locked racks until town, or let J say "no quests yet". |

No story contradictions seen in what I read (the opening only): the hero is "The Wanderer", nobody says "Tessar", the Rescuer says "After what they put you through" and "the Path-ologists are already out hunting for us", and sends him to Elder Maren in Crosspath.

## 4. Checked and fine

- **Title logo's four icons:** right - gold arm on red, white chef's hat on cream, leaf in rust arrows on green, pale skull in green flame on dark, in that order (`s1_01_01_title.png`). The same four are right on the Path choice (`s1_02_10.png`) and the pause menu ring reads arm, hat, leaf, skull clockwise from the top (`s1_03_22_w.png`).
- **Card back of my deck:** green and gold with a round leafy medallion (`s1_06_02.png`, bottom right); at screen size I can see leaves in a ring but cannot make out the three arrows - not wrong, not confirmable. The enemy's back is a neutral gold four-way emblem.
- **Maren's eyes and what she says about the Wanderer:** not seen (never found her).
- **The Well's pop-up:** text and options right and clear; header picture is not a well (finding 10). **The shrine's pop-up:** not seen.
- **The Cave Warden's closing words:** not seen (did not reach the boss).
- **The minimap:** blurry / blocky in the forest, the town and the zone (finding 6).
- **The lake's bank in Crosspath:** fine - a clean brown rim, reeds and rocks, no gap or floating edge in the stretch I saw (`s1_14_06_east.png`).
- **The south edge of Crosspath:** walked to it at x 25: the hero is stopped at z 43.8 by a flower bed with wooden X barriers; it looks deliberate and tidy, no void visible (`s1_14_02_south.png`). I saw only that one spot.

## 5. SCRIPT ERROR lines

**None.** `grep -c "SCRIPT ERROR"` is 0 in all 14 game logs (`play_s1_01.log` ... `play_s1_14.log`). The only `ERROR:` lines are engine messages at exit ("RID allocations ... were leaked at exit", "resources still in use at exit"), in every run.

## 6. What worked (keep exactly as it is)

1. **The opening and the Path choice.** Short, well-written lines with good portraits ("my head feels as if someone has packed it with wool"; "A friend. I know that isn't much of an answer"), then four columns with the right icons, three sample cards, a one-line plan each, and "More" with the Resource and the whole starting deck (`s1_01_10.png`, `s1_03_03_more.png`).
2. **The cave's painted room map** and its one tip: beautiful, readable, the next room glows, and clicking a locked room says why ("You can't reach it yet: clear a room that leads to it") (`s1_04_08.png`).
3. **The first duel's teaching**: a 3 HP enemy, "Opening hand: 2 infrastructure, 3 other cards", a free mulligan, tips that point at the thing they explain with "Got it / Skip tips", a Speed button, and a three-card reward with plain text (`s1_06_02.png`, `s1_07_05_preview.png`, run 9 log 64.5 s).
