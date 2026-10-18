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
