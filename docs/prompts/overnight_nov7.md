# Overnight pass — Nov 7-8 (Opus) — playtest notes, economy, story finale, balance, UI, minigames

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner is asleep. Work through the parts **in order**: they are in
priority order, so if the night runs out, the late parts slip, not the early ones. Do not ask questions; log decisions in
docs/overnight_inbox.md under "Overnight Nov 7-8". Tag `pre-overnight-nov7` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- 7.4 GB RAM:
  - ONE Godot process at a time;
  - at most 2 sub-agents, never while Godot or the tests run.
- Tests: memory-safe shards (`bash tools/run_tests.sh --only=tests --size=12`; after a low-memory stop, resume with `--from=N`). Add GUT tests for every rule change.
- Visual checks through `bash tools/play.sh`; screenshots to docs/overnight_shots/nov8/.
- Commit and push after each part; update docs/loop_state.md.
- Text follows docs/dialogue/story_voice_nov5.md.
- No new art in game. Art needs go to the art list (Part 9).
- No export.

Reference screenshots are in docs/ui/ref/nov8/. Open and LOOK AT each one first:
- peek_behind_cards.png
- packs_opened_small.png
- wardrobe_current.png
- target_style_character_page.png
- target_style_deck_station.png
- trivia_minigame_current.png
- swolympus_gate.png

## Part 0 — Leftovers
Read the last report (fixes_nov7). Finish anything it lists as not done or failing, then carry on.

## Part 1 — Playtest bugs and quick changes
1. **Peek** (peek_behind_cards.png): the Peek choice is drawn behind the cards in play, so it can't be used. It must sit on top of everything (its own top layer / modal), with the peeked card and the Top / Bottom buttons clearly visible and clickable. Test it with a full board.
2. **Gatekeeper quests are given only after the introductory quests are done** (at least the equipment quest). This replaces the morning's "gatekeeper quest from the Path choice".
   - Maren gives the gatekeeper quests once the intro line, including the equipment quest, is complete.
   - She recommends starting with the player's own Path ("it'll be the easiest road for you").
   - That Path's gatekeeper quest is auto-tracked.
   - Before then, the "Your Path" tracker line points at the next intro step.
   - Gatekeepers met earlier say a friendly "come back when Maren sends you" line, and can't be fought yet.
3. **Maren's lines when she gives the gatekeeper quests** currently talk as if it were the first meeting, and mix in earlier quests (buying cards, building the deck). Rewrite them for this exact moment: she knows the player, the intro is finished, and now she sends them out.
4. **Remove Maren's line about 1987.**
5. **Haunted Store Room ghosts:**
   - Rework their dialogue to be darker, implying that Tilly's ancestors dabbled in dark magic. Hints, not an info-dump; unsettling but still this game's tone.
   - Update Elder Maren's quest lines around the Store Room so they fit (what she knows or won't say).
   - Keep quest steps and IDs intact.
6. **The Capital debuffs tutorial.**
   - The first time the player enters the Capital, show a short tutorial: point at the debuff icons in the upper left, say what each does, and say that freeing each zone removes its debuff.
   - Show it once per save, and add it to the glossary/help.
7. **Back to Crosspath:** remove "(Full Heal)" from the travel text. Keep the full heal itself.
8. **Gatekeeper Brannoch:** his talk area overlaps the "travel to the Capital" trigger. Move him (and his talk area) so talking to him can never trigger travel. Keep the travel exit clearly marked.
9. **Mount Swolympus gate** (swolympus_gate.png): the player can walk round the back and get behind the gate. Block it with collision and terrain that reads naturally (cliff, rocks, wall); no invisible-wall feel. Walk-smoke every side.
10. **Pip** (Threadwell's shop): make her sprite 50% bigger in the world (scale ×1.5, collider and talk area to match). She's hard to see.
11. **Opening several packs** (packs_opened_small.png): the result cards are too small to read. Hovering a card shows it large (full readable card, like the Deck Station's hover); keyboard and controller focus do the same.

## Part 2 — Economy: player-friendly, less grind
Owner's direction: players who like the game are completionists and enjoy some grinding, but a single-player game like this shouldn't take forever.
1. **Common cards cost 50 gold.** Scale the other rarities from there (keep sensible ratios) in every card shop.
2. **Equipment:** the cheapest piece costs **250**. Scale the rest by tier and power.
3. **Target checkpoint:** when the player finishes the intro-to-equipment quest, they can afford **one more piece of equipment + 4 Common cards + 2 items**. Tune the intro's gold rewards (quests, cave, first fights) so a no-grind player has that much at that moment.
4. **The whole run:**
   - Re-run the gold study (docs/balance/gold_economy_nov3.md) with the new prices.
   - Make the economy friendlier: a no-grind player should afford roughly 35-40 cards plus 6-8 gear pieces and normal item use over a playthrough.
   - Collecting every card should take a modest amount of extra grinding: aim for about 25-35% extra playtime, and report your estimate.
   - Packs stay a good deal.
5. **Late fights pay more gold:** castle, Lab, postgame and other level 18+ fights. Scale them to their level so late grinding feels worth it.
6. **Extra Pocket** (equipment, today "max hand size +1"): it becomes "You can use each equipped item twice per battle" (each use still spends a charge).
   - First check that nothing else in the game already allows a second use. If something does, report it and give Extra Pocket a different, clearly useful effect instead.
   - Update its text and tests.
7. Put the before/after price tables and the study numbers in the report.

## Part 3 — Story finale and fixes (from docs/review/critic_nov6_summary.md item 11 and C6)
Do it as a revertible dialogue pass (apply_dialogue_pass.js), then re-export the review CSV as docs/dialogue/edit_nov8.csv.
- **The climax:**
  - The Wanderer gets one line of their own at the climax, not quotes from the four leaders.
  - Primm answers "You took my mother and father" in his own register.
  - No instant forgiveness.
  - Add a Wanderer beat before he absolves Maren.
- **The castle OPENS** in the ending; it does not fall. Make every ending beat consistent with that.
- **Elowen:**
  - The ending notices that she's missing: we learn she has been taken to the Path-ology Lab.
  - That is the hook into the postgame quest to rescue her ("Under the Forest").
  - The Lab stays postgame.
- **Fix:**
  - Maren being "the first" to say the prince's name;
  - the beat 10 speaker tag;
  - "never once asked her", which becomes "I asked her twice and she said 'a friend'";
  - a reaction to the Memory 4 reveal;
  - cut two of the identical "you've a look of the prince" hints, and give the Wanderer a reaction to the rest.
- **Primm's confession** is about credit and consent, not authorship (so it stops contradicting the archive and the ending).
- **Lieutenants:** keep one menial-job redemption, have one **refuse** redemption, and have one **arrested**.
- **Also:**
  - Gerald both passed on and serving coffee;
  - Maren's "the day she brought you to my door";
  - Kestrel's Capital instructions loop;
  - Bramble's compost line after the culprit is caught;
  - plant the D.N.A.'s Tuesday rule early and give Kyle the filing;
  - cut ending beat 6's sermon.
- Keep the zone-lesson tests passing.

## Part 4 — Balance retune (summary item 9), with the owner's decisions
- **Approved:**
  - Clench starts with Iron 2 -> 1.
  - Snack Bar costs 1, "Pay 1: +2/+0"; B-24 gets +1 defence.
  - Betty's Surly +3/+1 -> +2/+1; the Automaton loses one extra.
  - Necrocrat: drop the Trophy Hall Honor Guard's starting Militia.
  - ZoneOrderEase: an HP floor of about 0.65, attack ease growing with places early (-1 at 2, -2 at 3), Gourmand eased to about 0.8, and the Necrocrat added to the early study.
  - Siphon without Elowen drops a Protocol.
- **Not approved:** gatekeepers do NOT get a new rule.
- **The castle:** shorten the main line to about 6 rooms, with optional side rooms off it. Late fights pay a card pick or a relic as well as more gold (Part 2).
- **The Shattered Gallery is "very challenging":** a strong late deck should clear the full run about **15-25%** of the time.
  - First fix the Echoes' dropped signature cards (add the Echoes as allowed owners of NB-16, N-33 and the others).
  - Then tune: Perfect Form off the third wing's Normal fights, or Echo HP down; relabel the hardest node as Elite.
- **Primm: no number changes** (see Part 8).
- Re-sim each change and report before and after for every Path.

## Part 5 — UI redesigns, no new art yet
Target look: the Character page and the Deck Station (target_style_*.png): dark panels, gold frames, caps headers, painted icons, clear grouping.
1. **Wardrobe** (wardrobe_current.png): a major redesign on par with those pages.
   - A large framed hero preview on a proper stage.
   - Hats and Cloaks as grids of painted tiles with names, owned/equipped states and a detail line.
   - Cloak dyes at the **bottom** of the page. Dyes apply only to the Plain Cloak: if that's true in code, grey out the whole dye section with "Dyes work on the Plain Cloak" whenever another cloak is selected. (If dyes in fact work on every cloak, keep the section active and report it.)
   - Use existing UI textures. If it needs a background image, add a row to the art list (UI-BG-WARDROBE) and use the Character page's background until it arrives.
2. **Card Packs page:**
   - Write a design plan in docs/ui/card_packs_redesign.md, to the same standard: the layout, a pack shelf with the painted pack art large, pack counts, Open / Open all, a results grid, and the header.
   - Build the layout now with existing art, using UI-BG-PACKS (already on the art list) as the planned background.
   - Add any other image it needs to the art list (Part 9).
3. Screenshot before and after for both.

## Part 6 — Minigames
1. **Trivia** (trivia_minigame_current.png, "Compliance Re-Certification" and the other zones' trivia):
   - Give it a fun, exciting anime-style classroom: a background of desks, a chalkboard showing the question, and an excited mood.
   - The zone's trivia-giver appears as the **teacher**, using their existing portrait (no new character art).
   - Add answer feedback (correct/wrong flourish, streak) with code effects.
   - The classroom background is one new image: add the row MG-BG-CLASSROOM to the art list, and use a coded chalkboard-and-wood stand-in until it arrives.
2. **Every other zone minigame:**
   - Write docs/design/minigame_graphics_plan.md: for each minigame, how to make it look and feel exciting with minimal image generation (reused card and portrait art, shaders, particles, screen shake, music stings, scoring flourishes), and which single images, if any, would lift it most.
   - Implement the code-only improvements tonight.
   - Add the needed images to the art list.
3. **Card-matching minigame in every Path zone:**
   - The D.N.A. matching game uses **Necrocrat card art**. Add a matching game to each of the four Path zones, each using its own Path's card art.
   - Run them from a **persistent vendor** with their own questline. Reuse an existing NPC sprite and portrait that isn't a named story character; if none fits, add a row to the art list.
   - Questline: a short chain across the four zones (beat a target score in each, then a final challenge).
   - **Final reward:** a new piece of equipment for whichever slot currently has the fewest options (count them and report). Effect: "Once each turn, when you play your first non-Infrastructure card, draw a copy of that card from your deck, if you have one."
   - Refine the wording to the game's card-text style, keeping these rules:
     - only the first non-Infrastructure card each turn;
     - the copy must already be in your deck (draw pile);
     - if there's no copy, nothing happens.
   - Log the final wording in the inbox for the owner to approve.
   - Add an art row for its icon (Part 9). Balance-sim it.

## Part 7 — Load times and Low-end (summary item 15)
1. **The Capital takes a long time to load.**
   - Profile it, with numbers before and after.
   - Bake the painted swaps at import, prewarm materials behind the fade, and show a loading card when a load passes 2 s.
   - Also fix the Dump's 15-17 s first load and the first-visit shader hitches.
2. **Low-end mode is for people playing on old computers:**
   - make it a real cut: texture mip limit, foliage, draw distance, particles, and the Compatibility renderer offered;
   - accept a visible drop in looks;
   - Settings rows update when a preset is picked;
   - fix the black holes in the Gainlands cliffs.

## Part 8 — Primm measurement and write-up (no number changes)
After Part 1's presentation fixes:
1. Measure Primm two ways:
   - with each Path's **reference deck**;
   - with decks rebuilt from what the gold study says a **no-grind player could own** at that point.
2. Have one fresh critic **hand-play** him with the second kind of deck.
3. Write docs/balance/primm_explained.md for the owner, in plain language:
   - what each measurement shows, and why sims and play disagreed;
   - what makes him hard or easy (his rules, phases, the hand limit, the clock);
   - 2-3 concrete options, each with its expected effect, and your recommendation.
4. Change nothing.

## Part 9 — Art list for the next ChatGPT batch
Add rows to docs/art/art_needed_nov4.csv (status "Needed — next batch"), each with a full image description in the existing style:
- **LEVER-LOCKED and LEVER-OPEN:** a high-quality painted lever in its locked and opened states. Today it's a basic box with coloured circles. Find every lever in the game and the size it's drawn at.
- **The matching-quest equipment icon** (ICON style), plus any NPC art the vendor needs.
- **MG-BG-CLASSROOM**, plus the images from the minigame plan.
- **UI-BG-WARDROBE** (if used), UI-BG-PACKS (already listed: update its description to match the plan), and any other Card Packs page images.
- Keep the five rows already added (BB-S-GALLERY, DEC-PLINTH-EMBLEMS, UI-CAULDRON, UI-BG-PACKS, KIT-HEAP-THORNWALL).

## Finish
- Run all test shards green.
- A short fresh-eyes critic: a new save through the intro to the first gatekeeper quest, then the Capital's first entry by snapshot.
- Write docs/overnight_report.md with a per-part table, before/after numbers and screenshots, the Extra Pocket check, the matching equipment's wording for approval, and the open questions.
- Commit and push. No export.
