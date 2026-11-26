# The owner's changed cards, before and after (Fable Nov 25, Part 6.10)

Classic Draft decks (tools/draft_sim.gd --what=card --challenge=open), 5 seeds x 3 rivals x 4 games: each deck as drafted, and with one copy of the card in place of its weakest pick. **Before** = the card files of pre-nov25 swapped in; **after** = today's. Batches that hit the 20-minute limit (house rule) are tallied from their logs (fewer games). Runner: `bash tools/run_nov25_card_sims.sh`.

| Card | Before: without / with (change) | After: without / with (change) | Games each way (before / after) |
|---|---|---|---|
| First Pick (C-37) | 82% / 78% (-3) | 78% / 72% (-7) | 60 / 60 |
| The Haunted Buffet (GN-07) | 62% / 62% (+0) | 50% / 52% (+2) | 40 / 44 |
| Final Meal Request (GN-10) | 59% / 59% (+0) | 50% / 50% (+0) | 32 / 44 |
| Vigor Mortis (NB-03) | 77% / 78% (+2) | 73% / 75% (+2) | 60 / 60 |
| Circle of Life Insurance (GRN-03) | 56% / 58% (+3) | 63% / 60% (-3) | 36 / 60 |
| Global Gains Platinum Membership (B-33) | 82% / 78% (-3) | 77% / 77% (+0) | 60 / 60 |

**Reading:** no change swings much. Every "change" is within 7 points either way, which is noise at 32-60 games (two games in 60 are 3 points). The deck-level rates ("without") differ between before and after because the opponents of a Classic table were redrawn with the Hover Boots rule; compare the change columns, not the rates. Nothing to rebalance from these numbers.
