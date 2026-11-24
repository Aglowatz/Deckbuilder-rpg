# The Shuffled Halls: clear rates by route (draft smoke, real fights by two AIs)

`Godot --headless --path . -s res://tools/draft_smoke.gd -- --only=halls --tries=10` (Nov 24). The player is the smoke's own
drafter (every third option, no taste) at level 16 on one pool of HP; a "careful" run takes the door with the fewest fights
behind it (one table, the Kettle and the buff rooms, then Octavia); a "greedy" run takes every table and champion for the picks
and turns to an event room only when under 70 % HP. Numbers are measured from the player's base HP.

| Tuning (tables / champions / Octavia) | Careful route | Greedy route | Where the runs ended |
|---|---:|---:|---|
| base HP, elite play / +4 / +10 (as first built) | 0 of 8 | 1 of 8 | the first gate (4), the Card Shop (4), the Back-Room Table (3), Octavia (3) |
| -8 HP, normal play / +0 elite / +6 | 5 of 10 | 0 of 10 | Trey (3), the gate (5), the Tea Garden (2), Octavia (4) |
| **-11 HP, normal play / -4 elite / +6** (in the game) | **4 of 10** | **2 of 10** | Octavia (5), the gate (5), Trey (2) |

In the first row the careful run did not read the map yet (it walked into three or four tables), so that row is harsher than
the tuning alone. Ten runs a cell: read the rates as "about half", "about a fifth", not to the percent.
