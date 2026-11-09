# Dex's table: how hard is "beat Dex's score"? (Overnight Nov 9, Part 3)

Dex's table is the memory game (`MatchGame`): 16 cards, 8 pairs, flip two at a time, one move per pair of flips.
Simulated 50,000-200,000 deals per row (node, a near-optimal player who always takes a known pair and otherwise flips unknown cards).
"Forget" = the chance that each card the player has seen slips from memory on each later move (0 = perfect recall).

| Player | <= 11 | <= 12 | <= 13 | <= 14 | <= 15 | <= 16 | <= 18 | <= 20 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Perfect memory | 9 % | 55 % | 96 % | 100 % | 100 % | 100 % | 100 % | 100 % |
| Forgets 5 % per move | - | 25 % | 61 % | 87 % | 97 % | 100 % | 100 % | 100 % |
| Forgets 10 % per move | - | 12 % | 35 % | 61 % | 82 % | 93 % | 99 % | 100 % |
| Forgets 15 % per move | - | 6 % | 19 % | 39 % | 60 % | 78 % | 95 % | 99 % |

Average with perfect recall: 12.4 moves (the textbook result for 8 pairs is about 1.61 x pairs - 0.5).

**Before tonight:** zone tables "12 moves or fewer", the final table "11 or fewer", out of 14 moves. Even perfect recall beat a zone table
only 55 % of the time and the final 9 % of the time, and ran out of moves 4 % of the time. A normal player was mostly beating dice.

**Now:** zone tables 15 or fewer, the final table 14 or fewer, out of 20 (`CardMatchCircuit.TARGET_MOVES`, `FINAL_TARGET_MOVES`,
`TABLE_MAX_MOVES`). A careful player wins a zone table 82-97 % of the time and the final 61-87 %; a distracted one 60 % / 39 %, with retries
free. The D.N.A. Rec Room game keeps its own 14-move rules.
