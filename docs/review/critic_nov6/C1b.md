# C1b - The first hour in town (Beefcake, from `n6_beef_postcave`)

## 1. Summary

Crosspath looks lovely, and the people in it are well written. Tilly, Sable, Pip, Maren and the Store Room Ghosts each have a voice in a line or two, the portraits are excellent, and the quest log, map legend, shop tips and defeat recap all explain themselves. Two things hurt the hour. First, **getting around the square on foot is a fight with the furniture.** The fountain, its statue plinths, benches, lamp posts, a signpost, barrels and roaming townsfolk all stop you dead. The camera angle shifts between parts of town, so "up" on the keyboard keeps changing what it points at. Buildings in front hide the hero and the doors you are looking for. I spent more of the hour walking into things than doing anything else. Second, **the main quest never sends you toward your Path's gatekeeper.** After the merchants it goes Make It Yours (pack, then Deck Station), then Something in the Store Room (a fight). After 90 minutes I was still in the store-room step, with no marker, quest line or map icon pointing at a Beefcake gatekeeper. The only gatekeeper on the town map is "Gatekeeper Brannoch" at the Capital gate. So I did **not** reach or play the Beefcake gatekeeper. That is the brief's most important finding, though part of it is my own speed (see "How I played"). The first real fight (Store Room Ghosts, 3 HP against your 17) went 1 win, 1 loss and 1 unrecorded for the built-in pilot. It is a slow, mana-starved opener in which a 2/1 Cannon Fodder can chip a new player to death.

**How I played.** 45 runs (`c1b_r1` to `c1b_r45`), about 90 minutes of wall clock, Beefcake, keyboard and mouse only. Of the dev commands I used only `dev load`/`dev save` (snapshots `c1b_t1` to `c1b_t9`), and never `dev travel`. About 20 runs went on learning to walk through the square. Every snapshot reload puts you back at the spawn by the fountain, so each run had to walk the route again. Gold at each shop:
- **Tilly Tonic (items): 520.** She gives Power Wraps free, and I bought nothing. I never opened her shelf, so I can't say what 520 buys there.
- **Sable (cards): 520.** Commons cost 100, the Resistance Scout (an Uncommon) 200, and a General Pack 150. That money covers 5 commons or 3 packs. I bought Sledgehammer and a third Personal Trainer and left with 320.
- **Pip Threadwell (hats): 320.** Wide-Brim Hat 100, Chef's Toque 120; I already owned the Bowler. I could afford either, and bought nothing.
- **Bertram Beetsworth (gear):** not visited. He is not part of "Meet the Merchants", and the Character page says equipment is locked anyway.
- After the quest rewards I had 410, then 465. Beating the Store Room Ghosts paid +15, for 480.

Fights: the Store Room Ghosts, three times. In `c1b_r41` I played the first three turns by hand with drags and clicks, to judge the controls. The rest was the `pilot`: win in `c1b_r42`, defeat in `c1b_r44`, and in `c1b_r43` the result went unrecorded (likely a loss, since gold did not change). `c1b_r45` was a pilot win in 5 rounds. I played fewer than the two required hand fights in full. I ran out of time before the gatekeeper.

## 2. Scores

| | Score | Why |
|---|---|---|
| Fun | 5/10 | The talk and shops are charming. The fights have real texture once units hit the board. But a lot of the hour was fighting the walk, not playing. |
| Clarity | 5/10 | The quest log ("Where to go: ..."), the map legend, the hover-zoom keyword boxes and the "What beat you" recap are best in class. But the on-foot routes are unreadable, and the main quest never points at the Path gatekeeper the game is built around. |
| Difficulty | 5/10 (too swingy, leaning hard) | The pilot lost 1 of 3 (possibly 2 of 3) fights against a 3-HP tutorial-tier foe. One infrastructure per turn makes your turns 1-2 nearly empty while the Ghosts flood 1/1s and 2/1s. |
| Text | 8/10 | Characters with distinct voices, jokes that land ("Your haunting is very important to us"), clear instructions inside the jokes. Minus points for Sable and Pip sharing the "darling" tic, and for item rules that contradict each other. |
| Look | 7/10 | Gorgeous painted portraits, card art and picnic-blanket board. Tilt-shift town with good lighting. But the hero is a tiny dark sprite that vanishes behind roofs, and small card text is unreadable on the shop and deck grids. |

## 3. Findings

1. **The main quest never leads to the Path gatekeeper.** After "Meet the Merchants" (Tilly → wraps → Sable → buy → Pip → Maren), Maren hands out "Make It Yours", then "Something in the Store Room". Nothing names the Beefcake gatekeeper or marks the way out to the Gainlands. The town map shows only "Gatekeeper Brannoch" at the Capital gate, and the "Where to?" list has the bare entry "The Gainlands (Exit / portal)". A Beefcake player who wants to go and *be a Beefcake* has nothing to follow. **Where:** `c1b_r43_f1_map.png`; quest log text "Where to go: The row house beside Tilly Tonic's Supplies". **Severity:** major (close to a blocker for the brief's step 4). **Fix:** once the hero picks a Path, keep a standing HUD line or side quest ("Your Path: face Brick Bronson at the Gainlands road") with its own map marker from minute one. Or have Maren name the gatekeeper and the road in her hand-in line.

2. **Walking around the square is a collision maze.** On the straight route from spawn to Tilly's shop (north of the fountain), the hero stuck on: the fountain rim plus a statue plinth, wedged so that A and D did nothing (`c1b_r5_02_n.png`); a bench and a standing townsperson (`c1b_r2_03_north2.png`); barrels and a white goose outside Tilly's (`c1b_r10b_01.png`); and a signpost on the north road, where "North: The Capital" body-blocks the lane (`c1b_r25_02.png`). Roaming townsfolk make the same input succeed one run and fail the next. **Severity:** major. **Fix:** much smaller colliders on benches, lamps, plinths, signposts and critters (or slide along them); give NPCs no hard collision, or make them step aside; keep a 3-4 m clear ring around the fountain.

3. **The camera angle changes by area, so the movement keys keep changing meaning.** The square is seen from the south. North of the fountain the view swings, so the north road runs diagonally up-left (`c1b_r23_02.png` vs `c1b_r1_01_start.png`). Holding W toward a goal you saw on the map takes you somewhere else. **Severity:** major. **Fix:** keep the yaw fixed within the town, or make movement follow the camera smoothly. Show a compass on the minimap ring all the time.

4. **The hero and doors disappear behind buildings.** Next to the store room and Sable's stall the hero is hidden behind the near house. The quest marker floats on a roof, and the door it marks is out of sight (`c1b_r36_00.png`, `c1b_r9_02.png`). **Severity:** major. **Fix:** cut-away or dither roofs in front of the hero (a silhouette pass), and anchor quest markers at the door, not the rooftop.

5. **The first real fight is swingy and slow for a new player.** You have 17 HP against the Store Room Ghosts' 3, yet the pilot lost in `c1b_r44`: "Cannon Fodder dealt 14 of the 22 damage you took (7 hits)" (`c1b_r44_f2_end.png`). By hand, my first turns were one Powerhouse and nothing castable while the enemy filled the board (`c1b_r41_t1_b_played.png`, `c1b_r41_t3_a_hand.png`). A 49-card deck with 19 infrastructure and one land per turn means slow starts. **Severity:** major. **Fix:** for the intro fights, give a scripted or partly stacked opening hand (two infrastructure plus a 1-drop), or a free starting infrastructure, and cap the Ghosts' board at two bodies.

6. **The item rules contradict each other.** Tilly's lines: "Everything here is one use in a fight!" / "Whatever's in a slot comes with you into every fight!" / "One wrap, one use, then it's gone!" The item card says "One of your units gets +0/+2 for the rest of the battle" (`c1b_r10c_06_t5.png`, `c1b_r13_01_char.png`). "Every fight" and "one use, then it's gone" read as opposites. **Severity:** minor (it feeds clarity). **Fix:** change her line to "A slotted item is ready in every fight until its charges run out." Show the charge count on the battle item slot.

7. **The Character page shows locked or unexplained things in the first hour.** Every equipment slot is locked with "Equipment unlocks after Some Assembly Required", a quest name the player has never seen. Maren then hands you the "Participation Trophy: Common Relic" while the Relic slot is still locked. The Path Essence row is four unlabelled icons with 0s, and their names appear only on hover ("Beefcake essence") (`c1b_r14_00_essence_hover.png`). "+0/+2" is never explained. **Severity:** minor. **Fix:** write unlock rules in player terms ("unlocks when you reach the Gainlands' first dungeon"). Don't give a relic you can't equip, or auto-equip the trophy and say so. Label the essence icons.

8. **Esc behind a confirm leaves the confirm on screen.** In Sable's card grid I clicked a card ("Buy Sledgehammer?"), then pressed Esc. The grid closed, but the buy confirm stayed floating over the "What are you after?" menu (`c1b_r17_04_after_esc.png`). **Severity:** minor (bug). **Fix:** make Esc close the topmost modal first.

9. **The Deck Station save prompt is unreadable, and Esc doesn't leave the station.** "Save to which slot? Click a slot in the racks above or below (Esc cancels)." is printed over the locked-slot labels in the bottom rack (`c1b_r32_01_saved.png`). Two Escs did not close the Deck Station; only the X button did. Saving the deck also needs a second step (pick a slot), which the quest text doesn't mention. **Severity:** minor. **Fix:** put the prompt on a solid banner, highlight the valid slots, and make Esc close the station when no prompt is open.

10. **Shop and deck grid card text is too small to read.** Sledgehammer's rules on the shop grid, and Alarm-ish Clock on the deck grid, are a blur at 1600x900 (`c1b_r16_01_cards.png`, `c1b_r31_01_deck.png`). Hover zoom saves it, and the keyword boxes are excellent (`c1b_r17_01_hover_trainer.png`). **Severity:** minor. **Fix:** fewer, larger cards per row, or a short-rules mode for grid cards.

11. **Tip boxes overflow.** "Tip: Buying cards" spills its last line ("unlock as you play.") below the frame (`c1b_r16_01_cards.png`). The quest descriptions end in "..." in both the log and the reward card ("There's a trophy in it, though ever..."). **Severity:** minor. **Fix:** size boxes to their text, or wrap and scroll instead of truncating.

12. **"Where to?" on the map doesn't show a route in the world.** Picking "Tilly Tonic's Supplies" changed nothing I could see after closing the map. There is no in-world trail or arrow, only the small minimap ring (`c1b_r2_01_whereto.png`). The map is also mostly black until you explore. **Severity:** minor. **Fix:** after a pick, draw a ground trail or edge-of-screen arrow, and reveal the whole town square map from the start.

13. **Dialogue needs two presses per line and loops if you press too often.** The first E finishes the typewriter and the second advances. Pressing E after the last line restarts the NPC's idle lines, so a player mashing through can land straight back in conversation ("I'll wait! I'm bad at waiting! I'm turning yellow!"). **Severity:** minor. **Fix:** ignore interact for about 0.5 s after a conversation closes.

14. **Sable and Pip share a voice tic.** Both open with "darling", and Maren's "dearie" is close to it. It blurs three otherwise distinct voices. **Severity:** minor. **Fix:** give the tic to Sable alone; Pip can be all measuring-tape fuss ("Hold still!").

15. **Pip's mirror doesn't show you.** Pip says "Try anything on in the little mirror first", but Preview shows the hat icon on an empty panel, not the hero wearing it (`c1b_r21_03_pip.png`). **Severity:** minor. **Fix:** render the hero sprite with the item in the preview pane.

No `SCRIPT ERROR` lines appeared in any `stdout.log`. There were only engine leak warnings at exit.

## 4. What's great, don't touch

- **The writing.** Tilly's colour-changing chatter ("I'm teal today, which means the new batch works!"), Sable's "Where do my cards come from? The past, darling. Next question", Maren's "a deck you never chose is a deck you'll lose with", and the Store Room Ghosts' lantern refund saga ("Your haunting is very important to us"). Instructions are folded into the jokes without killing them.
- **Portraits and card art** (`c1b_r10c_06_t5.png`, `c1b_r16_01_cards.png`). The painted vendor art is the best thing on screen.
- **The quest log's "Where to go" line**, the HUD tracker, the map legend with vendor and challenger icons, and the "QUEST UPDATED" toasts.
- **Hover zoom with keyword boxes** in the shops (Buff, Iron), and Sable's buy confirm that states the gold you will have left.
- **The defeat recap, "What beat you"**, with a concrete tip (`c1b_r44_f2_end.png`), and the End Turn guard: "You have 1 energy left and can still play 1 card this turn."
- **The battle board**: picnic-blanket table, phase ladder with a one-line hint for each phase, mulligan prompt, and token tip.
- **The pack opening tear-and-reveal**, with a "NEW!" tag.
