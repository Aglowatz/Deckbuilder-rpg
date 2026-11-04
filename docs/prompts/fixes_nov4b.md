# Fix pass — Nov 4 (B) (Opus) — playtest feedback round 2

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Work autonomously through the parts
below. Do not ask questions; log decisions in docs/overnight_inbox.md and keep going.

House rules (unchanged):
- STOP_OVERNIGHT check before each part.
- ONE Godot process at a time; at most 3 sub-agents, never while Godot or the tests run.
- Run `bash tools/run_tests.sh` and add GUT tests for every rule change.
- Visual checks go through `bash tools/play.sh`; save screenshots to docs/overnight_shots/nov4b/.
- Commit and push after each part; update docs/loop_state.md.
- Follow docs/dialogue/voice_bible.md for all text. No new art in game (Part F only lists art).

Reference screenshots are in docs/ui/ref/nov4b/. Open and LOOK AT each one before starting:
- house_windows_broken.png
- gainlands_bridge_edges.png
- hog_descent_event.png
- hog_cell_block_brawler.png
- hog_rescue_event.png
- deck_station_current.png
- gainlands_cones_greta.png
- dna_elevators_misaligned.png
- dna_entrance_left_passage_blocked.png
- primm_defeat_giant.png
- ending_four_hands.png
- forest_revisit.png

## Part 0 — Keyword rename (correction)
The last pass named the keyword "Fresh Stitches"; the owner chose **"Just Arrived"**.
- Rename it everywhere: the card field, KeywordInfo constant, glossary, tooltips, docs, tests and tools.
- Reminder text: "Just Arrived: can't attack the turn it enters play."
- Grep afterwards so neither "Fresh Stitches" nor "summoning sickness" remains in game text.

## Part 1 — Answers the owner asked for (put them at the TOP of the report)
1. **Shiro's reward.** Confirm in data and by a test that finishing "The Oldest Trick in the Book" gives exactly **3 Gilded packs**. If not, fix it so it does.
2. **Mount Swolympus.** The dungeon is in data (S-BEEF, 3 nodes, boss The Ancient Spotter) but its unlock condition was never decided (open question GL2-F2), so the gate stays sealed.
   - **Decision:** it opens after Primm is defeated (postgame).
   - Talking to Old Man Mountain then gives a short quest ("Only the worthy...").
   - The sealed gate **physically opens** (animate it), and the collapsed span of the ridge is rebuilt, so the climb is walkable.
   - Before that, Old Man Mountain's line hints that it opens "when the kingdom is whole again".
   - Make sure S-BEEF has a real map, battleboard and music, or the existing stand-ins.
   - Report what was missing.
3. **The hidden side dungeon (the Iron Cave, S-IRON).** Report where its entrance is today.
   - Then **move it onto the MIDDLE path** (the guarded ridge with the three fights on the way to the House of Gains).
   - Put the cave mouth in a rock face just off the ridge, between the guard fights, visible from the road.
   - Remove the old entrance on the left road.
   - Update the walk smoke and tests.
4. **The cone objects in the Gainlands** (see gainlands_cones_greta.png: small tan spiky cones on the grass near Greta).
   - Identify them.
   - Remove them unless they serve a real purpose; if they do, say what it is.

## Part 2 — Gainlands
1. **Blue workout mats:** remove every shrub, bush, rock, grass tuft and other scatter that sits on the blue rubber mats (all yards). Exclude scatter from mat areas so it doesn't come back.
2. **House of Gains, "The Descent" event** (hog_descent_event.png). Replace the three options with:
   - "Bribe the guard" — lose 40 gold (greyed out with a reason if you have less than 40).
   - "Overpower the guard" — lose 3 HP.
   - "Distract the guard" — a random card from your deck is lost for the rest of this dungeon run (returned after the run; say which card in the result text).

   Rewrite the event text to fit, short and funny.
3. **Grandmaster Flex rescue** (hog_rescue_event.png).
   - The ONLY boon is that he fights beside you in the final battle. Remove the +1 attack / +1 defense and +3 max HP.
   - His ally unit becomes a **3/5** (keep his abilities unless they are what makes him too strong; if so, say what you changed).
   - Update the option text, the boon tooltip and the tests.
4. **Cell Block Brawler** (the prison node; hog_cell_block_brawler.png): make it much more challenging. Reference: a strong mid-dungeon elite.
   - Stronger deck, more HP, and a nasty prison-themed rule that works with "Iron can't be used".
   - Run the balance sim with each Path's typical deck at that point. Target a loss rate of about 25-35% for an average deck, up from today's.
   - Report before and after.
5. **Natural zone edges.**
   - Give every zone's outer edges the natural, layered, ragged cliff/shore treatment the Gainlands has (gainlands_bridge_edges.png), unless the edge is meant to look artificial. Artificial examples: Capital walls, D.N.A. interiors, the Buffet's food-built edges where they are clearly built.
   - List each zone and what you did.
   - Reuse the Gainlands terrain code and textures per zone palette.

## Part 3 — Crosspath, D.N.A., forest
1. **House windows** (house_windows_broken.png, the half-timbered house with blue shutters near the lake road). The shutters and windows stick out of the roof and float off the walls.
   - Fix the window/shutter placement on that house model.
   - Check every other house using the same kit for the same fault.
2. **Necrocrat elevators** (dna_elevators_misaligned.png). The elevator doors are not lined up with the doorways and stick into the hallway. Align them with the wall openings, flush with the wall.
3. **Necrocrat entrance room, left passage** (dna_entrance_left_passage_blocked.png). Filing cabinets, plants and props block the left passage.
   - Clear a path of at least 2 m.
   - Verify with the walkable overlay and a walk smoke.
4. **Path-ology Lab entrance and the post-game route** (forest_revisit.png).
   - Move the Lab entrance further SOUTH in the forest.
   - At the start of the game it can't be reached (blocked by terrain/brambles, not an invisible wall).
   - On the post-game revisit the forest map is more open, with a fairly straight path south to the entrance.

## Part 4 — Post-game and crafting quests
1. **After the main story** (Primm defeated) the player gets a quest to find the Path-ology Lab. Inside, they rescue **Elowen**.
   - The quest then directs them to a portal station to travel to the forest.
   - Wire the quest log steps, the map marker and the dialogue. Follow the existing story data for who gives it; if unclear, Tilly or Old Man Mountain gives it.
2. **Auntie Alembic's crafting.**
   - When crafting becomes available, a quest points the player to her shop.
   - Completing its first step grants the minimum essence of EACH Path needed to craft one card.
   - The essence cap per Path is **3x the amount needed** to craft.
   - **Bug:** crafting must spend only the amount needed. Example: with 18 essence, crafting a card that costs 6 leaves 12; today it takes everything. Fix this and add a test.
   - The crafting gold cost drops to **100**.
   - Update her dialogue and the UI text.

## Part 5 — In-game stopgaps until the art lands
1. **Primm's defeat scene** (primm_defeat_giant.png): this is art (Part F). In game, for now, make sure no scene scales him up as a giant.
2. **Deck station:** the art is in Part F. For now, make the deck slot frames line up as 5 above and 5 below (10 total), with level locks shown as today.

## Part F — Art list (no generation)
Append rows to docs/art/art_needed_nov4.csv (same columns):
1. **Deck Station background.**
   - New background art with 10 deck slot alcoves: 5 across the top, 5 across the bottom, exactly where the real deck frames are drawn.
   - Make docs/art/paintover_inputs/deck_station_slots_guide.png: the current screen at 1600x900 with the 10 slot rectangles outlined in bright magenta and the card grid / Your Deck panel areas shaded. It is the layout guide for the image prompt.
2. **Primm's defeat** (STORY-PRIMM-DEFEAT or its real id).
   - Primm at normal human size, kneeling among the broken model city, with the hero at the same scale.
   - He keeps his youthful, perfect looks, but is defeated and dishevelled: hair out of place, robes torn, crown slipping from his hands.
3. **Ending "Together"** (the four hands).
   - The four Path leaders' hands meet, each consistent with their own art. Use the names and looks of the four leaders from the game's data (Grandmaster Flex: lion paw; Agnes Overdue: ghostly; plus the Gourmand and Refusemancer leaders).
   - Write each leader's name and hand/sleeve description in the row.
4. Any other image this pass touches that needs new art.

## Finish
- Run the full test suite and make sure it is green.
- Do a critic play from a HEAD worktree that covers:
  - Shiro's reward;
  - the Swolympus gate after Primm, via the dev menu;
  - the Iron Cave on the middle path;
  - the Descent and Rescue events;
  - Cell Block Brawler;
  - the D.N.A. entrance;
  - Auntie Alembic's crafting with 18 essence;
  - the post-game Lab quest.
- Write docs/overnight_report.md with the answers from Part 1 at the top.
- Export 0.5.5 and run the release smoke.
- Commit and push.
