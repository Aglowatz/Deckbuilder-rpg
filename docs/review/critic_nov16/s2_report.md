# Critic report S2 - the midgame on the release build (Nov 16)

Build: The Wayward Path v1.0.0 (exported Windows build), played through `tools/play_exported.sh`.
All screenshots are in `_screenshots/exported/`; scripts are `docs/review/play_scripts/s2_01.txt` to `s2_16.txt`.

## 1. How I played

16 runs of 16, about 30 minutes on the clock (each run finished in 55 to 125 s).

| Run | What |
|---|---|
| 01 | Title, `dev load bot_refusemancer_enter_gourmand` (worked: level 14, 1095 gold, Buffet entrance), map, quest log, walked the bridge to the square |
| 02 | Zone-effect tooltips, the Orchard Lane sign |
| 03 | Madame Mirepoix: first talk read line by line, her shop opened |
| 04 | Mirepoix's favour (quest "Bake Me a Pie"), Basil: first talk and favour read line by line; tried to walk north to the Test Kitchen and was stopped |
| 05 | `dev travel dungeon D-TTK`: dungeon map |
| 06 | Dungeon rules (R), first room "Frozen Line Cook": before-the-fight card, opening hand, 55 s of pilot (fight not finished at turn 7) |
| 07 | `dev travel dungeon D-TTK -2`: boss intro, boss fight with the pilot at 1.5x: DEFEAT on turn 6 |
| 08 | `dev travel capital` (lands inside the Crease), `dev gold 3000` |
| 09 | Lost run: `dev load` of my Crease snapshot put the hero on the Capital's Gate Road instead; Capital map and "Point me to..." list |
| 10 | Fig Sly: dialogue read, shop menu, Card Packs page |
| 11 | Fig Sly: Cards page, Items page, bought and opened a Gilded Beefcake Pack |
| 12 | Town, Card Packs page (P), opened a Gourmand Pack from the shelf |
| 13 | Deck Station (B), town map and "Point me to..." list |
| 14 | Deck Station: Cover Card picker, + on a deck row, Suggest a deck; Buffet "Point me to..." list |
| 15 | Boss again: "Before the boss" card, rule hover, three plays by hand (drag), To Combat, End Turn, then pilot at 4x: DEFEAT on turn 6 |
| 16 | `dev freed gourmand`, Buffet arrival (level-up pop-up, Basil's freed scene), then Fig's pack row with the Gourmand pack unlocked |

Snapshots: `s2_a`, `s2_b`, `s2_c` (Buffet), `s2_cap` (Capital). Note: a snapshot always resumes at the zone's entrance, not where the hero stood.

Jumps used: `dev travel dungeon D-TTK` (after one run of trying to walk there), `D-TTK -2` (to the boss), `dev travel capital`, `dev travel town`, `dev travel zone gourmand`, `dev gold 3000`, `dev heal`, `dev freed gourmand`. No `dev win`, no `dev autowin`.

Not reached: Sous-Chef Tarragon; a roaming-enemy fight; the Test Kitchen's door on foot; dungeon rooms 2 to 7 (the `-2` jump cleared them); a boss win (two honest defeats); **Dex** (no "Point me to..." list named him, see finding 1); a card-back chooser (none found in the Deck Station); the freed Buffet's banners and statue close up; buying a non-Gilded Path pack from Fig (his row only has Gilded packs; I opened a plain Gourmand Pack from my own shelf instead).

## 2. Scores

**Clarity 7/10.** Rules are explained very well (the before-the-fight card, the icon row, "Needs 3 energy; you have 1", the Deck Station's checklist), and the map's "Point me to..." list is a good idea. It loses points in the world: I could not find the way north out of the Buffet square, Dex is in no list, and several pop-ups stack on arrival.

**Fun 6/10.** The writing is funny and the shops and packs are a pleasure, but the one fight I could not skip, the Buffet boss, was lost twice on turn 6 with the boss untouched at 16 HP, and a normal room at 1x speed was still going at turn 7 after 55 seconds. Caveat: the built-in pilot did most of the playing, and it plays badly.

**Polish 7/10.** The painted art (dungeon map, portraits, shops, packs, battle table) is release quality and no run logged a script error. The rough edges are overlapping text (toasts over the pack result, NEW! over a card name, DEFEAT behind cards), one shop page that looks like a different game (Items), and a card back that does not show a Path icon.

## 3. Findings

| # | What | Where | Kind | Size | Smallest fix |
|---|---|---|---|---|---|
| 1 | Dex cannot be found. The brief says the map's list names "Dex"; the "Point me to..." lists in Town, the Buffet and the Capital have no such entry, and no marker says Dex. I never reached the matching game. | `s2_13_05_list.png`, `s2_14_07_buffet_list.png`, `s2_09_02_list.png` | confusing | S | Add "Dex (card-matching game)" to the list and a map marker wherever he stands |
| 2 | The Buffet boss (The Doppelganger) beat the level-14 snapshot hero twice on turn 6 without losing a single HP (16/16). It has 9 to 12 units on the table by turn 6 (five Sashimi Weenies stacked "x5", all at +1/+1) and attacks "with Sashimi Weenie and 8 more". Pilot-played, so only a warning, but the hero had 2 or 3 units out each time. | `s2_07_07_late.png`, `s2_15_08_late.png`, log `play_s2_15_play.log` 109.8 | broken (balance) | M | Check this fight with the stock level-14 deck; cap the Weenie tokens or drop "Plated Just So" to +0/+1 |
| 3 | Walking north from the Buffet square stops dead at (57.3, 55.7): three 3-second holds of W moved nothing, and nothing on screen says why or where the way through is. I had to jump to the dungeon. | `s2_04_10_end.png`, log `play_s2_04_play.log` 68.4 to 75.0 | confusing | M | A visible gap, gate or signpost on the square's north edge; or the goal arrow routing around it |
| 4 | Fig Sly says "Gilded Packs? Never heard of them. Fifty gold. Don't tell Primm." Every Gilded pack costs 360. | `s2_11_09_packs_page.png` (bark, top left), `s2_10_04_packs.png` (prices) | story / inconsistent | S | Change the line to the real price, or drop the number |
| 5 | Pack result screen: the two "Extra copy ... converted into gold" toasts sit on top of the title ("Gilded Beefcake Pack - opened" is cut in half) and cover the tops and names of all three cards. | `s2_11_07_open3.png` | ugly | S | Show the toasts below the cards, or drop them (the panel already lists the conversions) |
| 6 | The card back in the pack reveal, and on the hero's own deck in battle, shows three leaves around a brass cog on green. That is not the Refusemancer icon (a leaf inside three rust-orange recycling arrows on a moss-green disc), and it came out of a Gourmand pack. | `s2_12_03_pack_opened.png`, `s2_15_05_play2.png` (bottom right deck) | wrong icon | L (new back) or S (swap the centre for the real medallion) | Put the Path medallion in the middle of the back |
| 7 | Copy caps disagree. The pack result says "Extra copy (you own 4)" for Unstable Rift (an Epic) and Ambush Party; the Deck Station says "Copy caps: Common 3, Uncommon 3, Epic 2" and shows "Own 3"; Fig's Cards page shows Epics as "Own 0/2"; the tip says "3 copies at most". | `s2_11_07_open3.png`, `s2_13_02_deck_hover.png`, log `play_s2_11_play.log` 59.1 and 80.7 | confusing | S | One wording: "past its cap of N", with the real N for that rarity |
| 8 | A Gilded pack's "guaranteed Epic" can be a card you already hold at cap: I paid 360 and the Epic turned straight into 125 gold. | `s2_11_07_open3.png` | confusing | M | Roll the guaranteed slot among cards not yet at cap, or say so on the pack |
| 9 | Fig's Items page looks like a different screen: no portrait, no shop frame, a flat purple-to-orange gradient, tiles in the top left only. The Cards and Card Packs pages have the portrait and the dark panel. Blank Form's icon is a gift-wrapped present. | `s2_11_03_items.png` vs `s2_10_04_packs.png` | ugly / inconsistent | M | Put the Items grid inside the same shop panel beside the portrait |
| 10 | The "Card Packs" tile on Fig's menu, and the small icon beside "The Shelf", show a pack with a four-point star medallion. The brief lists a star as wrong for the Paths. | `s2_11_09_packs_page.png`, `s2_12_01_packs.png` (top left) | wrong icon | S | Use a pack with the four-Path ring, or no medallion |
| 11 | "NEW!" badge covers the card's name in the reveal ("Consult the Cookbook" reads "...T THE ...OKBOOK"). | `s2_12_03_pack_opened.png` | ugly | S | Move the badge above the card's top-left corner |
| 12 | Two different boss rules use the same icon (a red chef's jacket): "Mise en Place" and "Plated Just So". In the fight's icon row you cannot tell them apart. | `s2_15_01_boss_rules_before.png`, `s2_15_05_play2.png` | confusing | S | A second icon (a plate) for Plated Just So |
| 13 | The picture strip at the top of the "Before the fight" and "Before the boss" cards is a mossy stone crypt with candles. The fight is in a steam-and-copper kitchen. | `s2_06_02_node1.png`, `s2_15_01_boss_rules_before.png` | inconsistent | S (reuse the kitchen table art) | Use the dungeon's own backdrop per dungeon |
| 14 | On defeat, "DEFEAT" was drawn behind two of my cards and could barely be read; in the other loss the "-2" damage number sat on top of the hero's name ("Yo-2"). | `s2_15_08_late.png`, `s2_07_07_late.png` | ugly | S | Draw the result banner above the table; offset the damage number |
| 15 | The boss's name plate does not fit: "THE" is tiny on its own line and "DOPPELGANGER" is far smaller than "FROZEN LINE COOK" or "YOU". | `s2_15_05_play2.png` vs `s2_06_05_after.png` | ugly | S | Auto-fit to one size, or drop "The" on the plate |
| 16 | A name label "OLD HOB THE GRAVEDIGGER" floats over a cauliflower at the Buffet's entrance with no character to be seen, and a gravedigger is an odd neighbour in the kitchen zone. | `s2_01_05_walk2.png`, `s2_02_13_end.png` | confusing | S | Hide labels of characters that are behind scenery; check he belongs here |
| 17 | In the Buffet square the foreground broccoli and cauliflower cover a quarter to a third of the screen, including the spot where Madame Mirepoix stands; the hero is a small figure in the gap. | `s2_03_02_talk.png`, `s2_02_13_end.png` | ugly | M | Fade or lower foreground foliage near the camera |
| 18 | The "Point me to..." list opens on top of the map and hides its right side: labels are cut ("The Old Service Tur", "Deck Stati", "Elder Maren", "Bertram ... Mercha") and it covers half of the Crease inset. | `s2_09_02_list.png`, `s2_13_05_list.png` | ugly | S | Open the list over the Legend panel instead |
| 19 | Arriving in the Crease, a tutorial tip ("The Capital's broken services") opens under the Rift Station speech and then swallows the M key: M did nothing until "Got it" was pressed. In the freed Buffet a level-up pop-up, the "is free" banner and Basil's "The Colonel's gone" scene (Basil is nowhere in sight) all arrive together on the bridge. | `s2_08_01_capital.png`, log `play_s2_08_play.log` 47.3 to 52.0; `s2_16_04_statue_text.png`, log `play_s2_16_play.log` 45.8 | confusing | S | Queue pop-ups one at a time; play Basil's scene when the hero reaches him |
| 20 | Deck Station: the slot called "Refusemancer deck" wears a Beefcake card (The Big Unit) as its cover, and there is no card-back view or chooser anywhere on the screen ("Cover" only picks the slot's picture). | `s2_13_02_deck_hover.png`, `s2_14_01_cover.png` | confusing | S | Default the cover to a card of the deck's first Path; show the deck's card back beside the cover |

Smaller notes, not in the table: the enemy's deck and hand backs in the Test Kitchen are a gold compass-style design with no chef's hat (`s2_15_05_play2.png`, top); the Buffet's green banners carry a crowned pale face on a red disc that, at game distance and through the blur, reads as a skull (`s2_04_07_basil.png`); a room fight at 1x speed took 55 s to reach turn 7 with the enemy at 10 of 12 HP (`s2_06_05_after.png`); the Crease is very dark and low in contrast next to every other place (`s2_10_02_talk.png`), and the brown door frame on its right edge is a flat-shaded box.

Story check: nothing I read contradicted the story list. Nobody said "Tessar"; the battle plate says "You"; Maren was not met. Basil's "Ten years ago Primm's people came to the Buffet" fits the ten years in the cell. Primm's line on the Royal Audit card ("Imperfections will be removed. Kindly.") fits.

## 4. Checked and fine

- **Fig Sly's hands:** two in the shop portrait (one at the lapel, one gloved at the hip), two in the dialogue portrait. Right. (`s2_10_04_packs.png`, `s2_10_02_talk.png`)
- **Pack medallions:** every one whole, centred and the right icon: Beefcake gold arm on red; Gourmand white chef's hat on cream with a copper rim (plain pack on the shelf, Gilded pack at Fig's after freeing, and the padlocked one before); Refusemancer leaf in three orange arrows on green; Necrocrat pale skull in green flame on dark slate. (`s2_10_04_packs.png`, `s2_12_01_packs.png`, `s2_16_05_packs_freed.png`)
- **The Crease's stalls and crates:** painted (wooden stalls with awnings, painted crates, crystal clusters, stone pillar). Only the door frame at the right edge looks like a flat box. (`s2_10_02_talk.png`, `s2_08_01_capital.png`)
- **Freed zone's banners and statue:** not checked. I freed the Buffet with `dev freed gourmand` but pop-ups stopped the walk; from the bridge the square looks the same as before. Fig's Gourmand pack did unlock and the Capital went to "Services restored: 4 of 4" with full 25 HP. (`s2_16_04_statue_text.png`, `s2_16_05_packs_freed.png`)
- **Buffet boss's rules before and during the fight:** right. The "Before the boss" card lists 7 rules plus "Hidden trait ?"; the fight shows 8 icons in the same order, a hover tooltip per icon, and "Setting Up - attacks start Turn 3" / "Setting Up: 2 turns left". Only the shared icon (finding 12) is off. (`s2_15_01_boss_rules_before.png`, `s2_15_05_play2.png`, `s2_07_05_rule_hover.png`)
- **Pack row's scrollbar:** not seen. Fig's row holds four packs, all fit, no scrollbar is drawn and a drag did nothing; the shelf on the P page is the same. The Cover Card picker in the Deck Station does have a scrollbar and it draws cleanly. (`s2_10_04_packs.png`, `s2_16_06_packs_drag.png`, `s2_14_01_cover.png`)
- **Dex's move counts:** not checked; Dex was not reached (finding 1).

## 5. SCRIPT ERROR lines

None. `grep -c "SCRIPT ERROR"` printed 0 for `play_s2_01.log` to `play_s2_13.log`, and the same check was empty for runs 14, 15 and 16.

## 6. What worked (keep exactly as they are)

1. **The dungeon map and the rules card.** The painted Test Kitchen map with its room nodes, the "Before the fight" card that lists each rule in plain words with green and red names, and the same icons staying under the enemy's portrait with hover text. (`s2_05_01_dungeon.png`, `s2_15_01_boss_rules_before.png`)
2. **Fig Sly's shop and the packs.** The portrait, the barks ("Would you like a bag? Bags are illegal too."), the gilded pack art with clear correct medallions, the padlocked pack with "Fig can only get these once the Endless Buffet is free", and "Buy & open". (`s2_10_04_packs.png`, `s2_16_05_packs_freed.png`)
3. **The Deck Station's right-hand panel.** The three green checks (45 cards, copy caps, at most 2 Paths), the cost curve, "Fill Infrastructure" and "Suggest a deck" with one button per Path mix; and in battle the plain message when a card cannot be played ("Needs 3 energy; you have 1 (each ready Infrastructure gives 1 a turn)."). (`s2_13_02_deck_hover.png`, `s2_14_05_suggest.png`, `s2_15_05_play2.png`)
