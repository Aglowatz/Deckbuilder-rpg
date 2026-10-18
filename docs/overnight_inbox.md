# Overnight inbox

Leave instructions here for the overnight run (one per line). The run reads this file before each part and logs what it did.

## Overnight Oct 17 - decisions that are yours (most important first)

The run took the safest reasonable choice for each and carried on; the full reasoning is in `docs/design/open_questions.md` (ON17-...).

1. **Copy caps use the game's rarities** (ON17-1). There is no "Rare" tier (Common, Uncommon, Epic, Legendary), so Epic stands in for Rare:
   Common 3, Uncommon 2, Epic 1, Legendary 1 at the start. Raises: Uncommon 3 at L9, Epic 2 at L12 and 3 at L22, Legendary 2 at L18 and 3
   at L30 (`data/progression/level_track.json`). Change the levels there.
2. **You never own more than your cap** (ON17-4). A copy over the cap converts into Path essence (gold for a neutral card) the moment it
   arrives. Old saves: copies over the cap convert on load and saved decks drop the extras (the battle deck is topped up with basic
   infrastructure so it stays legal). The alternative (keep extras in the collection until the cap rises) is easy to switch to.
3. **The kingdom is Patchwork** (ON17-6): renamed from the build's "Pathwork"; the throne keeps the sheet's name "the Pathwork Throne". Say if the throne should be the Patchwork Throne too.
4. **XP curve** (ON17-7): levels 21-30 got cheaper (one completionist run reaches 30, a main-line run lands around 21-23). Levels 1-20 unchanged.
5. **Gold is a level reward again** (ON17-8) because this brief asked for it; Brief 16 had removed it.
6. **The level-5 armory quest replaces the 5/10/15/20/25 equipment-slot choices** (Part 5). Old saves with slots count the quest as done.
7. **Species for the NPCs the sheet left blank** (Part 11, ON17-10): King, Queen, Elowen, Dr. Siphon human (the royal line is human); Vivienne Quota ferret, Colonel Crumb badger, Percival Plume peacock, Hortensia Clipwell hare, Isla Brannoch bear (her father is a bear). Change them in `tools/npc_truth_input.json` and re-run `node tools/npc_truth.js`.
8. **The strolling baker is "Bun the Baker", a badger** (NPC-VILLAGER, added so he can talk to passers-by). Rename freely.
9. **Music: nothing was dropped** (Part 12). Measured, no track is broken after the loop fixes; the audit ranks 26 tracks with very wide dynamics (quiet passages vanish under battle sounds) - audition those and the 35 loop-fixed seams (`docs/audio/loop_fixes.md`; `node tools/loop_fix.js --restore` undoes them) and name any track to drop or swap.
10. **Boss wins play a 3.6 s cut of the boss track's climax** instead of the generic victory sting (`STG-WIN-*`). Say if you prefer the generic one.
11. **Keyboard / pad focus** now shows a gold ring on every menu button (Part 13). HUD buttons stay mouse-only on purpose (so Space/E in the world never re-presses a menu button).
