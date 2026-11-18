# Nov 18 evening (Opus): the D.N.A. finished properly, card ownership, a defeat-three quest per zone

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner played the Nov 18 day build; this is his list. His screenshots are in `docs/overnight_shots/nov18c/ref_*.png`.

Read first: the top of docs/overnight_report.md ("Nov 18 day") and docs/overnight_inbox.md ("Nov 18 day"). Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Nov 18 evening". Tag `pre-nov18-evening`. Work in this order; it's the priority order.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. **No export** and no public upload.
- Before/after shots in docs/overnight_shots/nov18c/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - Primm's fight and the castle rooms unchanged;
  - no enemy intent shown;
  - no new painted art (use existing assets; log real art needs as Batch 18 rows);
  - dialogue: single lines only, plus the new quests' offer / active / done lines, with an IDs file for `--revert` (`docs/dialogue/nov18c_lines.csv` / `_ids.txt`);
  - each zone keeps its own colour grade;
  - the D.N.A. stays open-air under the evening sky (the day pass's direction is right; this pass finishes it).
- Every rules or quest change gets a test.

## Part 1 — The D.N.A.: finish the plaza
Shoot the arrival, the hub, the Hall's stair (front and both sides, close and far), both cubicle farms and the breakroom, at the default and Low cameras, **before** you start. Keep every route, NPC, door, quest and interaction working, and the aisles at least 2.5 m clear.

1. **The building fronts need real buildings behind them** (`ref_dna_flat_fronts_punchcard.png`: today they read as randomly textured free-standing walls with the skyline right behind).
   - Behind each painted front (DNA-WALL-HALL-A / -B / -NARROW), add a **fake building**: a body with depth (at least 6-8 m back), side walls in DNA-WALL-EXTERIOR or DNA-WALL-GREY, a cornice and parapet in DNA-TRIM-BRASS, **slate roofs** (DNA-ROOF-SLATE) with a few chimneys, dormers or a small tower, and lit windows (DNA-SHEET-WINDOWS) on the sides and upper floors.
   - Vary the heights and roof lines so the row reads as a street of civic buildings, not one long wall. The ends of each row must be closed (a corner building), with no thin edge visible from any camera angle.
   - Behind them, the distant skyline (DNA-BD-TOWERS) stays, but further back, with haze between.
   - The walk grid doesn't change; the buildings sit outside it.
2. **Nothing floats; nothing sits inside a wall.**
   - **The punch card** at "[E] Punch in" floats in the air (`ref_dna_flat_fronts_punchcard.png`). Mount it on a wall or a post as a proper **time clock**: a brass punch clock on a wall or pillar (from the zone kit), with the card in its slot. Keep the interaction at the same spot or within a step of it, with the prompt still showing.
   - **Remove the pneumatic tubes** everywhere in the D.N.A. (they float, attached to nothing).
   - **Lamps, booths ("offices") and other props stuck in the middle of walls or partitions** (`ref_dna_hub_props_in_walls.png`): move each one clear of the wall, onto the floor beside it or against it, or remove it.
   - **Write a probe** that lists every prop in the zone that (a) floats (its bottom is above the ground or the surface under it, unless it's a chandelier, banner or wall-mounted piece), or (b) overlaps a wall, partition or building collider. Fix every hit, re-run until it reports zero, and keep the probe as a test.
3. **The walls the elevators are on** (`ref_dna_stair_ghosts_elevators.png`): make those walls **as tall as the elevator shafts** (or taller), so the shafts sit inside them. Today it looks right from the front, but close up or from the side **the tall wall fades out (the camera cut-away) and the elevator is left standing alone.** Fix it so they always behave as one piece: the wall and its elevator shaft fade together, or neither fades. Check from the front, both sides, close and far, at both cameras.
4. **The ghosts on the stairs sink into the steps** (same screenshot). Remove them. Instead, make **a line of ghosts on the left side** of the stair, walking or waiting single-file up into the Hall of Final Approvals' door, each standing on its step (feet on the tread, not sunk), gently bobbing. They don't block the player's route up the middle.
5. **The breakroom couch (the D.N.A.'s healing spot) must be easy to find.** Make it bigger and clearly lit (a warm lamp over it), with a little rug and side table, a sign with a heart or coffee-cup icon (from the existing sign sheets), a name label ("Breakroom: rest here"), and a map and minimap icon. A soft glow when the hero is near. Keep the heal working as now.
6. **The Waiting Room of Eternity (the mini dungeon) must be easy to find.**
   - Make its entrance obvious: a lit doorway or gate, a hanging sign with the hourglass icon (DNA-SHEET-SIGNS or another sign sheet), a short red runner leading to it from the main route, and a map and minimap icon once the player has seen it.
   - **Make finding and beating it an official quest** from a D.N.A. NPC who suits it (the receptionist or Agnes Overdue): "Take a Number" (or similar): find the Waiting Room of Eternity, then beat it. Tracker steps, a map marker, and a reward fitting its difficulty (gold, experience and a pack). If it already has a quest that players miss, make that one official and tracked instead of adding a second.
7. **Check it:** after shots at the same spots and angles; the D.N.A. walk smoke; the NPC visibility probe; the floating/overlap probe at zero; every NPC, chest, the couch and the Waiting Room reachable; FPS on Medium and Low-end, before and after.

## Part 2 — Card ownership: always up to 3 copies
**The owner's rule:** players can **own and buy three copies of every card at all times**. What they can **put in a deck** stays limited by rarity and level, exactly as now.
1. The owned cap is 3 for every card (basic Infrastructure stays unlimited). Packs, rewards and shops give real copies up to 3; only a 4th copy and beyond converts as duplicates do today.
2. The deck limit is unchanged (rarity, rising with level).
3. **A notice before buying a copy the player can't use yet:** when a purchase would take the owned count above what the player may currently put in a deck, show a clear confirm box first, e.g. "You can only use 1 copy of Notary Wraith in a deck right now. You'll be able to use 2 at level 14 and 3 at level 21. Buy anyway?", with Buy / Cancel. Use the real levels from the cap rules, and the card's name. Controller and mouse.
4. The Deck Station's counts make the difference clear: "Deck 1/1 · Own 3" with a small note on hover ("2 more usable at level 14").
5. Update the shop, pack and reward code, the glossary and tutorial text, the design docs and the tests (buying a 2nd and 3rd copy at low level; the notice text and its levels; the deck limit still enforced; a 4th copy converts).

## Part 3 — Quests
1. **Only the enemies a quest counts are marked.** In the D.N.A.'s "Hall Monitor" (Kyle) the fast enemies that only deal damage on contact are highlighted too. Mark only the enemies that count for the quest, on the map, the minimap and in the world. Check the same for every defeat-enemies quest.
2. **A "defeat three" quest in every zone**, like Kyle's "Hall Monitor":
   - one each in **the Gainlands, the Endless Buffet, the Verdant Dump and the Capital** (and the Opening Forest or Crosspath only if they have roaming enemies; say which you added);
   - each from an existing NPC who suits it, near where the enemies roam, with a short, funny offer in that NPC's voice (dad jokes and puns welcome; single lines);
   - the target: three of that area's ordinary roaming enemies (not the hazard enemies that only deal contact damage, not bosses); the tracker counts 0/3, the map and minimap mark only those enemies;
   - the reward: **a Gilded pack (that zone's Path where it has one; a General gilded pack in the Capital), plus gold and experience** on the same scale as "Hall Monitor", adjusted to the zone's level;
   - one time only; it shows in the quest log's side quests; it works whatever order the zones are played in.
3. Tests: each quest's offer, 0/3 to 3/3, the reward; only the right enemies marked; the D.N.A.'s contact-damage enemies not marked.

## Part 4 — Tests and report (no export)
1. All test shards green; the walk smokes (the D.N.A., the Gainlands, the Buffet, the Dump, the Capital); the NPC visibility probe; the new floating/overlap probe for the D.N.A.; the card-games smoke.
2. **docs/overnight_report.md**, with at the top, under "Nov 18 evening":
   - the D.N.A. before and after (all angles, especially the elevator walls from the side and the building rows), FPS before and after;
   - the probe's counts before and after;
   - the couch and the Waiting Room (shots, and the new quest);
   - the card-ownership rule, the notice (a shot) and the tests;
   - the new defeat-three quests: which NPC, where, rewards;
   - the dialogue revert command;
   - anything that needs the owner (at most 6 items, each with a recommendation).
3. Commit and push. No export, no public upload.
