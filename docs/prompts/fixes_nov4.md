# Fix pass — Nov 4 (Opus) — playtest feedback round 1

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Work autonomously through the
list below. Do not ask questions; log decisions in docs/overnight_inbox.md and keep going.

House rules (unchanged):
- STOP_OVERNIGHT check before each part.
- ONE Godot process at a time; at most 3 sub-agents, never while Godot or the tests run.
- Run `bash tools/run_tests.sh` and add GUT tests for every rule change.
- Visual checks go through `bash tools/play.sh`; save screenshots to docs/overnight_shots/nov4/.
- Commit and push after each part; update docs/loop_state.md.
- Follow docs/dialogue/voice_bible.md for any text. No new art.

Reference screenshots are in docs/ui/ref/nov4/. Open and LOOK AT each one before starting:
- crosspath_trainer_townsfolk.png
- character_menu_v1_icons_offcenter.png
- gourmand_shop_white_arches.png
- buffet_path_footsteps.png
- buffet_topleft_stairs.png

## Part 1 — Battle rules (highest priority)
1. **Peek is broken.**
   - Peek N must show the top N cards of the player's deck, one at a time (or together for N>1).
   - For each card, the player chooses **Top** or **Bottom**; the cards kept on top go back in the order the player chose.
   - Covers every card and effect that uses Peek, e.g. Amuse-Bouche and Consult the Cookbook.
   - Add tests, and verify in play.
2. **Rename "summoning sickness"** everywhere (keyword, tooltip, rules text, help/glossary, code-facing labels where shown) to **"Fresh Stitches"**.
   - Reminder text: "Fresh Stitches: can't attack the turn it enters play."
   - Units that ignore it keep working under the new name.
   - Grep the whole repo, including the dialogue CSVs, for the old phrase.
3. **Enemy units that start on the board have Fresh Stitches on the enemy's first turn.**
   - Example: the Sashimi Weenie Colonel Casserole starts with.
   - Treat them exactly as if just played.
   - Apply to EVERY encounter with pre-placed enemy units; list them in the report.
4. **Endless Buffet zone buff.**
   - Check the reported bug: in the Colonel Casserole fight, Gourmand units appear to get +2/+1 instead of +1/+1. Find the cause (double application? shown twice? stacked with a fight-specific buff?) and fix it. Record the cause in the report.
   - Then change the zone buff from +1/+1 to **+0/+1** (Gourmand units get +1 health only).
   - Update its description in the zone-effects chip, the tooltips and the pre-fight text.
   - Verify it applies exactly once to every Gourmand unit in every Endless Buffet fight: enemy and player units if the effect is meant to be zone-wide, otherwise as currently designed (state which in the report).
   - Add a test that runs several Buffet encounters.
5. **Colonel Casserole AI didn't attack when it clearly had lethal or near-lethal pressure.**
   - Reproduce it using a board where attacking is clearly correct.
   - Inspect the attack decision (blocker evaluation, trap fear, Fresh Stitches flags left on, buff-doubling side effects).
   - Fix the logic and add regression tests for "AI attacks when it is ahead". Check that other bosses use the same logic.
6. **Boss blockers must respond to the defeat flag, however the win happened.**
   - Bug: beating Colonel Casserole with the dev win command left him standing in the way.
   - The world-state update must hang off the "boss defeated" flag, not off the normal battle-end path only.
   - Check every boss or blocker NPC that moves aside after defeat, in every zone.

## Part 2 — Economy
1. **Card prices.**
   - The cheapest cards (Common) cost **100 gold**, the same as a pack.
   - Scale the other rarities from there, keeping roughly the current ratios between rarities.
   - Apply this in every card shop.
   - Re-run the gold study from docs/balance/gold_economy_nov3.md. Add a section listing:
     - the new price table;
     - how many cards a no-grind player can now afford;
     - the extra cards per hour of grinding.
2. **Equipment is more expensive.** Players buy only a handful of pieces per playthrough.
   - Raise equipment prices, scaled by tier and power.
   - Target: a no-grind player can afford about 4-6 pieces of shop equipment over the whole game, on top of ~20 cards and normal item use.
   - Put the before/after table in the report.

## Part 3 — UI and shops
1. **Level-up popup.**
   - Remove every mention of equipment slots unlocking from level-ups: the Level 5 popup says "1 equipment slot unlocked".
   - Equipment is unlocked by its quest now; item-slot unlocks at Levels 6 and 12 still show.
   - Check every level threshold and the level-reward data.
2. **Character page equipment icons** (see character_menu_v1_icons_offcenter.png). Re-centre each slot on the silhouette:
   - Helm: centred over the head.
   - Armor: centred on the middle of the chest.
   - Weapon: centred on the left hand.
   - Relic: centred on the right hand.
   - Boots: centred between the legs, at the feet.

   Position them relative to the silhouette's own rect so they stay right at 1280x720 and 1920x1080. Screenshot before and after.
3. **Pip's shop.**
   - Rename "Plain Hooded Cloak" to **"Plain Cloak"** everywhere (item data, shop, dialogue, saves keep working).
   - Split the shop into two sections or tabs: **Hats** and **Cloaks**.
   - The cloak dyes have disappeared. Restore them and show them in the Cloaks section with Preview / Buy / Equip like the rest.
   - Verify that the dye recolour shows on the player in the world and in battle.
4. **White arches in card shops** (see gourmand_shop_white_arches.png). A white arch shape is drawn over every card in Mirepoix's Gourmand shop.
   - Find the cause (a mask/frame/overlay texture or a shader).
   - Remove it.
   - Check EVERY card shop and every other card grid (collection, deck builder, pack opening, rewards) for the same artifact.
   - Screenshot each one after the fix.

## Part 4 — World
1. **Crosspath trainer townsfolk** (see crosspath_trainer_townsfolk.png). The standing "Townsfolk" near the lamp post looks out of place.
   - Replace her with a different existing non-story NPC sprite that suits a town square.
   - Optionally give her a slow idle wander if the area allows it without clipping.
2. **Chests are 25% bigger** (scale ×1.25) in every zone, so they are easier to spot.
   - Adjust their interaction areas and collision to match.
   - Make sure no chest now clips into walls or blocks paths.
3. **Endless Buffet footsteps.** The squishy footstep sound plays on the paved/cobbled paths (see buffet_path_footsteps.png).
   - Fix the surface mapping so path tiles play the stone or path footstep.
   - Keep squishy for the actual soft food surfaces.
   - Check the other zones' footstep surfaces for the same mismatch.
4. **Endless Buffet top-left "stairs"** (see buffet_topleft_stairs.png): the stepped waffle/lattice blocks next to the cliff.
   - Find what they are (scene node, purpose, any script).
   - If they do nothing, remove them and make sure nothing else depended on them.
   - If they have a purpose, keep them and explain it in the report.

## Finish
- Run the full test suite and make sure it is green.
- Do a short critic play from a HEAD worktree that covers:
  - Peek;
  - the Colonel Casserole fight, played both normally and via the dev win;
  - a card shop;
  - Pip's shop;
  - the character page.
- Write docs/overnight_report.md with what changed, the bug causes, the price tables and the screenshots.
- Export 0.5.4 and run the release smoke.
- Commit and push.
