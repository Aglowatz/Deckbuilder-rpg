# Nov 18 (Opus): the owner's playtest fixes — battle, quests, cards, UI, and the D.N.A. back outdoors

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner played the game this morning; this is his list. Each item quotes what he saw, and his screenshots are in `docs/overnight_shots/nov18b/ref_*.png`.

Read first: the top of docs/overnight_report.md (Overnight Nov 17-18) and docs/overnight_inbox.md ("Overnight Nov 18"). Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Nov 18 day". Tag `pre-nov18-day`. Work in this order; it's the priority order.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. **No export** and no public upload.
- Before/after shots in docs/overnight_shots/nov18b/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board **layout** stays (card spacing and pop-ups are not layout; the items below are allowed);
  - Primm's fight and the castle rooms unchanged;
  - no enemy intent shown;
  - no new painted art (use existing assets; log real art needs as Batch 18 rows);
  - dialogue: single lines only, with an IDs file for `--revert` (`docs/dialogue/nov18b_single_lines.csv` / `_ids.txt`);
  - each zone keeps its own colour grade.
- Every rules change gets a test.

## Part 1 — Card rules that are broken
1. **Unconscionable Contract doesn't work** (`ref_unconscionable_contract.png`). "Gain control of target unit permanently. Create three Contracts." When played, the target unit must **move to the player's side of the field** and stay under the player's control **for the rest of the battle** (it attacks, blocks and dies for the player; if it dies it goes to its owner's Refuse Pile, unless the rules already say otherwise). Then create the three Contracts.
   - Find why it fails (target choice, the control change, the board not moving the card, the AI side keeping it) and fix it.
   - **Check every other "gain control" / "steal" / "swap" effect** in the card list against the same rule and fix the same way.
   - Tests: play it on an enemy unit; the unit is on the player's board, attacks next turn, is still the player's at the end of the battle; three Contracts are created. And the AI casting it on a player unit.
2. **Tools that grant a keyword must show it on the unit.** When a tool (e.g. the Corporate-Approved Pen) gives a unit an ability (e.g. Toxic), the unit's card on the field shows that keyword badge, as a printed keyword shows (`Flying`, `Toxic`). Its hover/preview text says where it came from ("Toxic (from Corporate-Approved Pen)"). It disappears when the effect ends. Do this for **every** granted keyword (tools, spells, auras, infrastructure), not only the pen. Test: equip, see the badge, remove, badge gone.
3. **Non-basic infrastructure is collected like other cards** (`ref_deck_station_infra_9999.png`: "Deck Own 9999").
   - Only **basic** infrastructure stays unlimited.
   - Every non-basic infrastructure card follows the same copy rules as other cards: **at most 3 copies**, higher rarities start capped lower and level-ups raise the cap toward 3, exactly as for units and spells.
   - It must be **collected**: it appears in packs, rewards and shops like other cards of its rarity and Path (General packs must not favour the starting Path).
   - **Existing saves:** a player keeps the copies currently in his decks (at most the cap), plus any the starting deck needs; drop the rest of the 9999. Log the migration rule in the report.
   - Update the Deck Station counts ("Deck 2/3  Own 2"), the shops, the glossary/tutorial text and the tests. Check the starting decks and the deck suggester still build legal decks.

## Part 2 — The battle screen
1. **Remove the AI action pop-ups** (`ref_battle_ai_popup_and_stacks.png`: "Cave Scavenger plays Feastforge"). The banner in the middle of the board when the computer acts goes away entirely. The battle log keeps the record. Keep the card's own fly-in/reveal animation so the player still sees what was played.
2. **Spread out stacks of the same unit or token** (same screenshot: the stacked Zombie Temps, the three Ghost Town / token cards, and the stacked infrastructure rows). Offset each card underneath more, so a clear strip of every card below shows (at least its name bar and a little art). Keep the "x2" count badge. It must still fit the existing lanes at 1280x720 and 1920x1080; don't move the board layout.
3. **All units show full art on the field** (`ref_battle_pigeon_text_vs_fullart.png`: one Courier Pigeon shows full art, the other shows the card with its rules text). Find why one is in the "detail" view (just played, hovered, selected, a new card flag) and make **every** unit and token on the field use the full-art field view. The rules text shows only in the hover preview on the left, as now.

## Part 3 — Packs and rewards
- **Hovering a card makes it bigger** when opening a pack (`ref_pack_open_small_cards.png`) and when choosing a reward card after a fight: the hovered card scales up smoothly (to about the size of the battle hover preview), staying on screen and readable, and returns when the mouse leaves. With a controller, the focused card does the same. It works at 1280x720 and 1920x1080, Large text, and 115% / 130% UI scale.

## Part 4 — Quests
1. **Right after the tutorial dungeon and talking to Maren, the tracked quest is "Fragments"; it should be "Meet the Merchants"** (`ref_quest_box_your_path.png`). After Maren, "Meet the Merchants" is the active, tracked quest.
2. **"Meet the Merchants" and the whole chain through getting equipment are MAIN quests** (they show the MAIN tag, in the main section of the log and tracker). Fragments stays a main quest too but comes after that chain in the tracker order.
3. **Remove the "Your Path" section from the quest box (tracker).** If a quest lived only there (e.g. "Settle in: Say hello to Tilly Tonic"), it moves into the main chain or the side list, whichever fits; nothing is lost.
4. **Kyle's quest "Rec Room: match the memories" is scrapped** (it is the same matching game as Dex's).
   - New quest from Kyle, same quest giver and spot: **defeat three enemies in his area** (the roaming enemies of that zone near him; the tracker counts 0/3 and the map marks the area).
   - Reward: **a Gilded pack, plus gold and experience** at the level of the quest it replaces (or a little more).
   - Rewrite only Kyle's lines that describe the old quest (single lines, IDs file). Delete the old matching game's quest data, its scene if nothing else uses it, and its tests; update the quest log, feats and glossary.
5. Tests: the quest order after Maren; the MAIN tags; the tracker without "Your Path"; Kyle's 0/3 to 3/3 and the reward.

## Part 5 — UI
1. **The empty gear slot message** (`ref_gear_empty_vertical_text.png`): with no gear owned for a slot, a message is written vertically and cut off. Show it as one normal line of text under "OWNED" at the top of the list ("You don't own any armour yet. Find gear in chests and shops." or the existing text, written horizontally and wrapped). Check every slot and Large text.
2. **The Deck Station must be easy to find in Crosspath.** Replace the "random house you interact with" with a clear **card-trader's cart or market stall** built from existing assets (e.g. ENV-PROP-STALL or ENV-PROP-CART with ENV-PROP-CANVAS, ENV-AWNING-01/02, crates, a lantern, and the hanging card sign ENV-SIGN-CARDS), standing on the square or by the main road where new players pass. It gets a clear map and minimap icon and a name label ("Deck Station"). Move the interaction there; keep any quest that points to it working and update its marker. Shots at both cameras.

## Part 6 — The D.N.A., again (the owner's playtest)
**The owner changed his mind about indoors:** "It never rains there (rain has not been properly approved), so it can be outdoors with no roof and not fully encased in walls. Floating chandeliers are okay. We can still have buildings and walls along at least one side making a barrier. The aesthetic is good, but visually it's not quite working. Ensure the imposing clock tower is visible."

Shoot the arrival, hub, door, mid1, mid2 and two aisles at the default and Low cameras **before** you start. Keep the walk grid's routes, NPC positions, doors, quests and interactions working (you may widen walkable space; see 2).

1. **Outdoors, open, under the sky:**
   - Remove the dark ceiling and the end bay. The D.N.A. is an **open-air civic plaza at night** under an existing sky (DNA-SKY-GLOOM, graded to a deep evening that suits the warm lamps; no rain).
   - Keep the look that works: the marble floor, the red runners, the waist-high mahogany partitions and posts, the booths, the banners, the sconce lamps, the ghost-flame posts, the moonlight, and **the chandeliers floating in the air** over the plaza (keep their slight sway; drop the chains going up into a ceiling, or let them fade out a little above).
   - **Not walled in on every side.** Keep the two-storey painted hall walls (DNA-WALL-HALL-A / -B / -NARROW) as **building fronts along at least one side** (the north and one long side work best) as the barrier. The other edges open onto the grey wasteland and distant skyline (DNA-BD-TOWERS) with low partitions, railings or rows of filing towers as the edge, so the player sees out.
2. **It's too hard to move around** (`ref_dna_cluttered_aisles.png`): too many desks and props in the aisles.
   - Every aisle and route the player uses is **at least 2.5 m clear** (about three hero widths), with no prop sticking into it. Thin out the desks in the cubicle rows (fewer, in tidy rows with gaps), and move props to the sides.
   - No dead-end slots the hero can get stuck in. Run a walk-grid probe for pinch points under 2.5 m and fix every one; report the before and after counts.
3. **Players can't see everything.** For **the D.N.A. only**, raise the camera pitch a little (about 6-10 degrees steeper than the other zones at each camera preset), so the player looks down into the plaza and the partitions hide less. Keep the player's three presets working; the other zones are unchanged. Shoot both versions (current and raised) at the same spots and pick the one that reads better; say which in the report.
4. **The imposing clock tower must be visible.** The lobby clock on the Hall's drum is lost today. Make the clock tower the D.N.A.'s landmark, seen from the arrival and from most of the plaza: tall enough to rise above the building fronts, lit (a warm glow behind the clock face and a little green ghost light), and on the skyline when you enter. Use DNA-PROP-LOBBY-CLOCK scaled up on a tower body built from the zone kit (DNA-WALL-EXTERIOR, DNA-TRIM-BRASS), or the clock from DNA-HERO-FINAL-APPROVALS. If a real tower needs new painted art, build the best version from existing pieces and add a Batch 18 row.
5. **The walls with the elevators** (`ref_dna_hall_door_bricks_elevators.png`): the two elevator shafts stick out above the wall beside the Hall's stair. Make those walls **taller and thicker** (deep enough that an elevator shaft could really be inside), so the shafts sit inside them and nothing pokes out above.
6. **The Hall of Final Approvals' entrance just looks like bricks now** (same screenshot). Give it **a big imposing door** at the top of the stair: tall double doors (from DNA-SHEET-DOORS, scaled up, or the doors of DNA-BD-HALL-FACADE / DNA-HERO-FINAL-APPROVALS), a stone frame and pediment, the red stamp banners either side, warm light spilling from the gap, and the ghost queue on the steps. From the plaza it must read as the main goal.
7. **Check it:**
   - after shots at the same spots, both cameras;
   - a walk from the arrival to the Hall door and through both cubicle farms;
   - the D.N.A. walk smoke, the NPC visibility probe, every NPC and chest reachable;
   - FPS on Medium and Low-end, before and after.

## Part 7 — Tests and report (no export)
1. All test shards green; the walk smokes (Crosspath, the D.N.A.); the NPC visibility probe; the card-games smoke; a strict playthrough bot run on one Path from the start through Maren, "Meet the Merchants" and the equipment chain (checks Part 4).
2. **docs/overnight_report.md**, with at the top, under "Nov 18 day":
   - each item done or not, with before/after shots;
   - Unconscionable Contract and the other control effects found, with the test names;
   - the infrastructure rule, the save migration and the new counts;
   - the D.N.A. before and after, the camera choice, the pinch-point counts and FPS;
   - the dialogue revert command;
   - anything that needs the owner (at most 6 items, each with a recommendation).
3. Commit and push. No export, no public upload.
