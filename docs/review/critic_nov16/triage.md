# Critic sittings, Nov 16: triage

Briefs: `docs/review/critic_nov16_s1_brief.md` to `_s4_brief.md`. Reports: `s1_report.md` to `s4_report.md` in this folder. Shots and
logs: `_screenshots/exported/s<n>_*`. Each critic had only its brief (no repo, no reports) and played the exported test pack through
`tools/play_exported.sh`.

| Sitting | Clarity | Fun | Polish | Runs | Did not reach |
|---|---|---|---|---|---|
| 1, the first hour | 6 | 6 | 7 | 14 of 16 | the shrine, the Cave Warden, Maren, any shop or quest (lost the second cave fight to the pilot, then jumped) |
| 2, the midgame | 7 | 6 | 7 | 16 of 16 | a boss win (two losses by the pilot), Dex (he had no map marker), the freed zone up close |
| 3, the late game | 5 | 6 | 6 | 18 of 18 | "Fight Primm again", Primm's phase 2, the ending, the credits, the memory pictures |
| 4, what the three missed | 7 | 7 | 6 | 16 of 16 | the end of the ending after "File Complete", the credits and their logo, the minutes after them |

**How to read "broken" below:** the critics drive the game with a script and a weak built-in player, and they jump with debug commands.
Several findings come from that and not from the game. They are marked "the test, not the game".

## Sitting 1 (the first hour)

| # | Finding | Size | Verdict |
|---|---|---|---|
| 1 | "Pray at the Dev Shrine (+1 level)" in Crosspath | S | **The test, not the game.** The shrine is built only in a debug binary; the critic's pack runs on the editor binary. The release exe has none (the exported smoke checks the Dev Menu is absent) |
| 2 | No marker for Elder Maren | S | **The test.** The critic jumped to town before clearing the cave. From a normal save she is on the map and first in "Point me to..." (`p4_town_map_after`) |
| 3 | The hero stopped responding in Tilly's yard | M | **The test.** Reproduced: the town's arrival sequence never ends for a hero who has not cleared the cave (a state the game cannot reach). From a normal save J, J and walking work |
| 4 | The Dump's entrance pennant is a single leaf | S | **Fixed.** Both pennants are the paw print; two pennants with the real icon are a Batch 17 row |
| 5 | A reward card "joins your deck" and is not in it after a loss | S | **Fixed.** Cards won on a lost first cave run stay in the deck |
| 6 | Maps and minimap are blurry blocks | M | **Fixed in code** (the full map is drawn by the minimap's new shader: crisp edges, rounded steps). Painted maps are a Batch 17 row |
| 7 | One loss restarts the whole cave | M | Logged: the owner's rule since Nov 7 (D1, D2) |
| 8 | The defeat toast sits on the forest's banner | S | **Fixed.** No banner after a cave loss |
| 9 | "Turn 1" on turn 6 | S | **The test.** The pilot plays faster than the board shows; the deck count is the engine's, the turn label the board's. A person cannot get ahead of the playback |
| 10 | The Well's header picture is playing cards | S / L | **Prepared.** The Well uses ICON-NODE-WELL as soon as it is imported (Batch 17 row) |
| 11 | Map labels cut and overlapping | S | **Fixed.** The map writes short names; hover and the list keep the whole one |
| 12 | C does not close the Character page | S | **Fixed.** C, B, P and T close the page they open |
| 13 | Path Essence shown by bottles | S | By design (style guide: the flask is the crafting currency) |
| 14 | Foreground roofs in town | M | Logged |
| 15 | "Equip up to 4" above "Equipped 0 of 2" | S | **Fixed** |
| 16 | The Dump's first view is a brown haze | M | Logged |
| 17 | The hand overlaps the infrastructure row | S | Not touched: no battle-board layout changes (owner) |
| 18 | The Deck Station in the forest | S | Logged |

## Sitting 2 (the midgame)

| # | Finding | Size | Verdict |
|---|---|---|---|
| 1 | Dex cannot be found | S | **Fixed.** He had no map marker in any zone; he is on every Path zone's map and list now. (My brief was wrong to say he is in town.) |
| 2 | The Buffet boss beat the hero twice by turn 6 | M | Logged. Both fights were the pilot's; the Nov 8 sims put this boss inside the target band |
| 3 | The way north out of the Buffet square is not shown | M | Logged |
| 4 | Fig says "Fifty gold"; the packs cost 360 | S | **Fixed**: "Price is on the wrapper." (inbox: your line, say if you want another) |
| 5 | Conversion toasts cover the pack result | S | **Fixed.** The held toasts are dropped; each card says what it became |
| 6 | The Refusemancer card back is leaves round a cog | L | Batch 17 row (UI-CARDBACK-R, -G, -C: I checked all five backs) |
| 7 | "you own 4" against caps of 2 and 3 | S | **Fixed**: "at its copy cap" |
| 8 | A Gilded pack's sure Epic can be one you hold at cap | M | Logged (a pack rule: yours to decide) |
| 9 | Fig's Items page looks like another screen | M | Logged |
| 10 | The Card Packs tile shows a star medallion | S | By design: the General pack belongs to no Path (style guide) |
| 11 | NEW! covers the card's name | S | **Fixed** |
| 12 | Two boss rules share one icon | S | **Fixed** (Plated Just So has its own) |
| 13 | The "Before the fight" header is a mossy crypt in a kitchen | S / L | Logged: one painted banner for every dungeon |
| 14 | DEFEAT behind cards; "-2" on the name | S | Logged: the banner is drawn above the table (z 400); the shot caught its fade-in |
| 15 | The boss's long name is set small | S | Logged |
| 16 | Old Hob's label floats over a cauliflower | S | Logged: he visits every zone by design; in the Buffet he stands behind the food forest |
| 17 | Foreground broccoli covers a third of the square | M | Logged |
| 18 | "Point me to..." opens over the map | S | Logged |
| 19 | Pop-ups arrive together | S | Mostly the test (debug jumps into a freed zone); logged |
| 20 | A deck's cover is another Path's card | S | Logged (the snapshot's deck) |

## Sitting 3 (the late game)

| # | Finding | Size | Verdict |
|---|---|---|---|
| 1, 2 | The tunnels' mural and board show a sun, a wave, a sprig and a flame | L | Checked and true. Batch 17 row (MAP-S-CAP, BB-S-CAP) |
| 3 | The freed Capital still flies the smiling sun on the outer wall, the gate and Grave Row | M | Logged: Batch 15 swapped the avenue and the castle only |
| 4 | After Primm the ending is announced by a caption only | M | Logged. The map has "Old Hob at Grave Row (the city is gathering)"; the quest tracker does not |
| 5 | The defeat screen against Primm closed on one Space press | S | **The test.** "Fight Primm again" is the focused default in a real castle run; the critic entered by `dev primm`, which is a debug fight with a plain Continue |
| 6 | The same caption after the credits | S | Logged (the two snapshots are the same state) |
| 7 | The manhole to the Crease has no map marker | S | **Fixed.** It stays on the map once the Crease is known |
| 8 | Primm's rule row shows one icon twice | S | Logged, not looked into |
| 9 | The four leaders' boons share one amulet icon | S | Logged |
| 10 | One header backdrop for every boss card | M | Logged (as sitting 2, #13) |
| 11 | Primm's board is a harbour village | L | By design (the Model Room: the board is his model of the kingdom); logged that nothing says so |
| 12 | A level-20 boss offers two commons | S | Logged (reward tiers: yours) |
| 13 | "Clear bonus: +95 (everything this run paid you)" | S | **Fixed**: "the gold this dungeon's rooms paid you, once more" |
| 14 | The respawn note is behind Old Hob's box | S | Logged |
| 15 | Labels overlap in the Crease inset | S | Partly fixed (short names); logged |
| 16 | The legend calls Spotless a "Golem gate" | S | **Fixed**: "Guarded gate" |
| 17 | "Get inside the wall" is ticked outside the wall | S | Logged |
| 18 | No Collection Book in the HUD menu | S | Logged (the book opens at its place in town) |
| 19 | Roofs in Crosspath's square | M | Logged (as sitting 1, #14) |
| 20 | Small things (streaks on Grave Row, a grey hexagon in the Crease, a caption half hidden) | S | Logged |

## Sitting 4 (the Cave Warden, Maren and her memories, Primm's defeat panel, the ending)

It confirmed the story checks: Maren's eyes ("my eyes aren't what they were"; she does not know him until Fragment 4), the bars in
every line, "Tessar" first in Fragment 4 with the name plate changing then, the crest in both memory pictures and the banners in the
two ending pictures it reached (arm, chef's hat, leaf, skull).

| # | Finding | Size | Verdict |
|---|---|---|---|
| 1 | On Primm's defeat panel E takes "Leave the castle" although "Fight Primm again" is lit | S | **Fixed.** A real bug: the key always left. It presses the lit button now |
| 2 | The defeat panel came 24 s late once | S | Logged (once, after `dev lose` during the opening hand) |
| 3 | Maren's stick shows a sun, a sprig, a moon and a drop | L | Batch 17 row (NPC-ELDER and its two expressions) |
| 4 | Memory text lies over the middle of the picture | M | Logged |
| 5 | Roofs fill the screen at Maren's home | M | Logged (with sittings 1 #14 and 3 #19: the most repeated complaint of the night) |
| 6 | Toasts stack on each other and on story pictures | S | Logged |
| 7 | Fragment 4: "a coat too fine for the cold" against a ragged cloak; a dumbbell in the foreground | L / S | Logged: the dumbbell was in the first painting too and is a prop; the line is yours |
| 8 | The Pathwork Throne's "stair of four colours" is red, blue, purple and green | L | Logged (art) |
| 9 | After four `dev freed` in a row the hero did not move | S | The test (debug commands) |
| 10 | The ending says one beat twice, in two box styles | S | Logged |
| 11 | "Four banners fly from the same pole" over four poles | S | Logged: your line ("side by side" would match the picture) |
| 12 | Maren says "find me on the square"; she is at her home | S | Logged: your line |
| 13 | The cave's exit caption stays up through Maren's talk | S | Logged |
| 14 | "I still can't see her face" after a picture that shows it | S | Logged: your line |
| 15 | "the same way I have been holding yours" reads as if she knows | S | Logged: your line |
| 16 to 20 | Small overlaps and wording (the cap note on the reward screen, "The Hollow Warden" twice, Bertram's order of lines, the Point-me list over the map, the respawn note) | S | Logged |
