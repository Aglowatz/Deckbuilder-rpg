# Critic C2b - the Verdant Dump and the Rotheart (Refusemancer)

## 1. Summary

The Verdant Dump looks gorgeous. The painted portraits (Granny Gristle, Brother Bramble, Old Hob) are some of the best character art I have seen in an indie card RPG, and the Rotheart's node map is a real painting you want to stare at. Playing it is another story. I spent most of my session fighting the overworld instead of foes. Walking north out of the starting Compost Commons stops dead at an invisible line across almost the whole plaza, and the same keys sometimes get through and sometimes don't. I never found a roaming foe or a fertilizer sack on foot and had to use a dev jump to reach the dungeon. Once inside, the very first node beat me three times out of three, against 4 HP enemy heroes. Each defeat cost me 10 gold and sent me back to the start, and I was left with 0 gold, so the "fight, gold, cards, better deck" loop never got going. In about 90 minutes I saw a lovely zone, three good conversations and three defeats, and won no fight at all.

How I played:
- **Runs and time:** 22 short runs, about 90 minutes of wall clock, as a level 4 Refusemancer from `n6_ref_dump` (17/17 HP, 310 gold, 51-card Wanderer's Deck).
- **Shop:** at Granny Gristle's Compost Grange with 310 gold, every common card cost 100. I bought 2 Heap Tortoise and 1 Junkyard Giraffe and had 10 gold left. The only gear on sale (Flip-Flops of Fortitude) cost 1400, out of reach. Old Hob is listed as a vendor too, but I never got to his stock.
- **Deck:** I added the new cards at the Deck Station (B). The station showed 52-53 cards, but the dungeon fights drew from a 51-card deck. Only one copy of Junkyard Giraffe and no Heap Tortoise ever turned up.
- **Fights:** 3, all on the Rotheart's first nodes (Overgrown Scarecrow twice, Mutant Mushroom Troop once), all lost.
  - I played turns 1-2 of fight 1 myself, then let `pilot` finish it. Fights 2 and 3 were `pilot` throughout.
  - I did not manage the four hand-played fights the brief asks for, and never reached the boss.
  - Gold after the defeats: 10, then 0 ("Mucking-out fee: -10 gold").
- **Dev commands:** `dev save` / `dev load` to chain runs. **`dev travel dungeon D-ROT` once, to get out of a stuck state:** after 6 runs I still could not walk north out of the Compost Commons (finding 1). I used the same command again after each `dev load`, which the brief allows for re-entry.

## 2. Scores

| | Score | Why |
|---|---|---|
| Fun | 3/10 | Lovely to look at, but in 90 minutes I never won a fight, never found a foe on foot, and spent my time fighting the collision. |
| Clarity | 4/10 | The quest log, the "Where to?" list and the defeat recap ("What beat you") are clear. But the walkable area is unreadable, name tags point at the wrong NPC, and the deck station quietly loses edits. |
| Difficulty | 3/10 (too hard) | The first dungeon node beat a fresh-into-the-zone Refusemancer 3 times out of 3. Snowballing room rules, mana screw and a gold fee on defeat make it feel stacked, not tough. |
| Text | 7/10 | The NPCs have real voices: "The Buffet calls us garbage eaters, and then they eat our carrots." Granny's raccoon line lands. Quest text is clear but generic ("Gather fertilizer sacks around the Dump"). |
| Look | 8/10 | Portraits, card art and the Rotheart map are superb. The overworld has a heavy sepia/purple haze, a ghosted title banner overlaps dialogue, and the map is mostly a black box. |

## 3. Findings

1. **I could not walk out of the starting plaza.** Walking north in the Compost Commons stops dead at about y≈121.9 across most of its width, against an invisible line in front of a fence and stream that look like decoration. The same inputs (`hold W` after `hold D`) let me through once, to (68.8, 104.1) by the stone bridge. Two other runs left me pinned at (63.1, 114.0) or (68.9, 121.9), where none of W/A/D moved me for 15+ seconds. I lost 6 runs (about 20 minutes) here and finally used `dev travel`. Where: `c2b_r14_145.png` (pinned in an open field with nothing visible blocking me), `c2b_r13_133_ne2.png`, `c2b_r15_153.png` (the one time I got through). **Severity: blocker.** Fix:
   - Audit the commons' collision against the art. Every solid edge should be a visible fence, rock or hedge.
   - Make the real way north (the bridge and the east stairs) obvious with a path texture, lanterns or a sign.
   - Add a stuck-recovery button to the pause menu ("Return to the zone's entrance").

2. **The first dungeon node beat me three times.** The Rotheart's opening fights were 0-3. The Overgrown Scarecrow and the Mutant Mushroom Troop have 4 HP and I start with 17, yet they killed me in 4-5 rounds and I never dealt them a point of damage.
   - The room rules snowball: "Wild Growth: at the start of each turn each unit gets a buff (up to 3)". A 0/4 Bird of Paradump with Flying grew into a 4-damage flier and did 12 of my 20 damage in 3 hits.
   - A 19-infrastructure, 51-card deck missed infrastructure drops on 3 of 5 turns in one fight.
   - It doesn't feel fair. Both sides get Wild Growth, but the AI's flier isn't blocked by my ground units.

   Where: `c2b_r20_201_t3.png` (the Bird on turn 2), `c2b_r20_202_result.png`, `c2b_r21_210_result.png` ("You played no Infrastructure on 3 of your 5 turns"). **Severity: major (borderline blocker for a real player).** Fix:
   - Make the first node of a main dungeon a teaching fight: no Wild Growth, or Wild Growth starting on turn 3.
   - Give the zone's own Path a starter edge here. Overgrowth's +2 defense doesn't help when the threat is a flier.
   - Raise the deck station's infrastructure guidance, or deal at least 2 infrastructure in the opening hand.

3. **Losing costs gold, so the loop can collapse.** Every defeat carries you out and charges "Mucking-out fee: -10 gold". After a shop visit I had 10 gold, the first loss took it to 0, and the next two losses had nothing left to take. A player who spends their gold on cards (which the game invites) and then loses can't buy anything and has no way to earn except fights they are losing. Where: `c2b_r22_223_after.png`, `c2b_r21_211_after.png` (gold 0). **Severity: major.** Fix: drop the fee in a Path's own first dungeon, or pay a small consolation (gold or XP) per enemy unit destroyed so a loss still moves you forward.

4. **The Deck Station silently drops or refuses edits.**
   - Clicking a card in the grid adds it only sometimes. The first click on Junkyard Giraffe worked; two clicks on Heap Tortoise did nothing.
   - The "Spells and units" list shows only 4 rows, so the `-` buttons for rows 5+ (Village Militia, Traveler's Sword) are hidden and clicks there do nothing.
   - With unsaved changes, **Escape and the X button do nothing at all**: no prompt and no feedback, and you are stuck in the screen until you find "Save Deck" (`c2b_r10_102_closed.png`).
   - The station then said 53 cards, but the dungeon fights drew from 46 + 5 = 51 and Heap Tortoise never showed up.

   Where: `c2b_r10_102_closed.png`, `c2b_r18_182_battle.png` ("Deck 46" + 5 in hand). **Severity: major.** Fix:
   - Make Esc / X on unsaved changes open "Save changes? Save / Discard / Cancel".
   - Make the deck list scroll, or grow it to fill the panel.
   - Make a card click always add one copy, with a visible +1 pop.
   - Show the deck count that is actually used in battle.

5. **Name tags point at the wrong NPC.** The interact prompt next to Granny Gristle's stall sits under a floating "Old Hob the Gravedigger" tag, but pressing E opens Granny Gristle and her shop. Old Hob is a different person standing nearby (`c2b_r22_223_after.png`). Where: `c2b_r3_22_ne.png` vs `c2b_r4_30_hob1.png`. **Severity: minor.** Fix: tag the nearest interactable with its own speaker name, and offset overlapping tags.

6. **I never found the zone's roaming foes or side content on foot.** In about 40 minutes of overworld time I saw no roaming enemy, no fertilizer sack and no sign of the Landfill Depths mini dungeon, though the "Where to?" list names them. Picking "The Rotheart" in "Where to?" drew no visible guide in the world (`c2b_r13_130_whereto.png`, `c2b_r14_145.png`). Combined with finding 1, the zone felt like a pretty dead end. **Severity: major.** Fix: make "Where to?" draw a breadcrumb or compass marker in the world and on the minimap, and put one roaming foe within sight of the Commons exit.

7. **The map is a black box.** At the start of the zone the M map is a tall black rectangle with a sliver revealed at the bottom (`c2b_r1_03_map.png`, `c2b_r3_25_map.png`). It tells me nothing about where the dungeon or the exits are. **Severity: minor.** Fix: reveal the zone's outline and the main landmarks (the Rotheart, the mini dungeon) from the start, and keep fog only for details.

8. **Escape opens the pause menu one press too early.** One Escape closes the shop's Cards page and its menu together, so my next Escape (and J) opened the pause menu or did nothing. In the shop, the "What are you after?" screen also doesn't close on E. Where: `c2b_r7` play log, `c2b_r12` ("button Side: NOT FOUND"). **Severity: minor.** Fix: Esc should go back one level at a time, and ignore Esc for about 0.2 s after a screen closes.

9. **The gear tip doesn't match the screen.** "The 5 grayed-out pieces are advanced gear", but only one locked "???" piece is shown, next to a 1400-gold item I can't afford (`c2b_r5_51_gear.png`). **Severity: minor.** Fix: count the locked pieces actually shown, and hint at a price band the player can reach in this zone.

10. **The zone title banner overlaps dialogue.** A ghosted "THE VERDANT DUMP / Home of the Refusemancer Path" banner fades in behind Old Hob's portrait and dialogue (`c2b_r22_223_after.png`). **Severity: minor.** Fix: hold the arrival banner until no dialogue is open.

11. **Visual haze hurts readability in the overworld.** The commons are washed in a strong sepia-purple filter and tilt-shift blur. Paths, edges and NPCs blend together, which makes finding 1 worse (`c2b_r1_01_start.png`, `c2b_r3_22_ne.png`). **Severity: minor.** Fix: cut the colour grade and edge blur by about a third, and give walkable ground a clearly different value from blocked ground.

12. **The prompt says "close" while the line is still typing.** Mid-typewriter, Granny's box already reads "E / Click to close" over a half-written line ("lying wherever the anima"), `c2b_r12_122_fav3.png`. **Severity: minor.** Fix: show "continue" until the line is complete.

No `SCRIPT ERROR` appeared in any of the 22 runs' `stdout.log`.

## 4. What's great, don't touch

- **The portraits.** Granny Gristle with her raccoon, the anxious hedgehog Brother Bramble and the grinning Old Hob are expressive, consistent and full of character (`c2b_r4_30_hob1.png`, `c2b_r2_13_talk2.png`, `c2b_r22_223_after.png`).
- **The Rotheart's node map.** A single painted landscape with the corruption creeping from the healthy farm (bottom left) to the bleeding heart-tree (top right). It tells the dungeon's story without a word (`c2b_r17_170_dungeon.png`).
- **The writing voice.** "Would you close the door behind you, and lock it, and maybe check the window? The vines keep trying it." and "The Buffet calls us garbage eaters, and then they eat our carrots." Short, funny, in character.
- **The defeat recap.** "What beat you: Bird of Paradump dealt 12 of the 20 damage you took" plus a concrete tip is exactly what a deckbuilder needs. Keep it.
- **The "Before the fight" rules card,** with the same icons kept on screen during the fight (`c2b_r17_171_rules.png`).
- **The shop's buy confirmation** ("100 gold for one copy. You own 0 and will have 210 gold left."): clear and safe.
- **The card art and frames** in the shop and deck station, and the battle board's look.
