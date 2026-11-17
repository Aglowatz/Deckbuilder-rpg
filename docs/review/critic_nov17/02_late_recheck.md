# Critic 2 re-check (late game), Nov 17

## 1. How I played

I used all 8 runs (each under 170 s, one at a time, all in the foreground), about 45 minutes in total. Shots and scripts are named `n17rlate_*`.

- **Runs 1-4: walking from Crosspath to the Capital (section 1). I never got there.** I loaded `bot_refusemancer_capital_ready`, read the tracker, the quest log and the map, then tried to walk north. Each attempt ended against something solid:
  - run 1: the town well;
  - run 2: a signpost by Bertram;
  - run 3: Tilly Tonic's shop;
  - run 4: Foil Fenwick's shop.

  My own `dev save` snapshots did not keep the hero's position: every `dev load` put him back at (25.2, 19.2) (log, run 4, 26.8 s). So each run started from the square again.
- **Run 5:** `dev travel capital`. It put me straight into the Crease, past the gate and its guard, so I never saw the gate or Captain Spotless. I read the tracker and the map's "Point me to...". Then a double Escape opened the pause menu and the rest of the run was lost.
- **Runs 6-8: the castle (section 2), via `dev travel dungeon D-PC -2`.**
  - Run 6: I found the boss room on the castle map.
  - Run 7: the pre-fight dialogue was too long for the rest of the run.
  - Run 8: I fought Primm with `pilot 40` twice and lost on turn 6, with Primm still at 56/56.
- **Not reached:** the gate guard, Wren, Fig Sly's market, the Old Service Tunnels, a win against Primm, the ending, the credits and the postgame. I ran out of runs before I could retry, so I never used `dev level 24`.

## 2. Score: 4/10 (same as the anchor)

- **Clarity 3/10 (same as the anchor).**
  - Better than the anchor: the quest data is now there. In town the log shows "Free the Four Zones 4/6" with a "Where to go" line (n17rlate_03_journal), where the anchor's log was empty (n17late_03_cmain). In the Crease the tracker moves on to "Under the Capital 2 of 5: Browse Fig Sly's Black Market" (n17rlate_05_cap2).
  - Worse: following it on foot failed four runs in a row. Walking north from the square runs into the well, a signpost and two shop fronts. Only the map's thin dashed line shows the real route (n17rlate_01_map, n17rlate_02_w6, n17rlate_03_w1, n17rlate_04_w1).
- **Fun 3/10 (lower than the anchor).**
  - Primm beat me on turn 6 without losing a single HP: 56/56 at the end, the same "wins after 6 turns" as the anchor (n17rlate_08_b3).
  - The rule "Setting Up - attacks start Turn 3" did not stop it. I went from 34 HP to 24 by turn 4 and to 0 by turn 6 (log, run 8, 63.1 s / 103.7 s / 133.8 s).
  - Getting there meant about 15 s of tapping through the freed leaders' speeches every attempt (run 8: `skip_dialogue 60` from 40.0 s to 54.9 s), plus four runs of walking into shop walls.
- **Polish 6/10 (same as the anchor).**
  - Strong: the painted castle map is gorgeous (n17rlate_06_dmap), and so are Primm's cut-in and the rules card (n17rlate_08_b1, n17rlate_08_rules).
  - Rough edges: the DEFEAT banner sits on top of the board (n17rlate_08_b3). The "Quest updated" toast covers the left edge of the HP panel (n17rlate_05_cap2). The dialogue says the Heart gives "+1 power" while the rules card says "+1 attack" (run 7 log, 60.1 s, against n17rlate_08_rules).

## 3. Top 10 problems

| # | Problem | Where | Severity | One concrete fix |
|---|---|---|---|---|
| 1 | Primm still wins on turn 6 untouched (56/56); the player takes about 12 HP a turn from turn 4 | n17rlate_08_b2, n17rlate_08_b3; run 8 log 103.7 s / 133.8 s | blocker | Cut Standing Army from 3 Militia to 2, or extend Setting Up to turns 1-3 |
| 2 | The walk from Crosspath to the Capital: going north from the square hits the well, a signpost and two shop fronts, and only the map's dashed line shows the way | n17rlate_01_walk2, n17rlate_02_w6, n17rlate_03_w1, n17rlate_04_w1; hero stuck at (25.1, 16.1), (12.9, 18.4), (18.3, 0.8), (31.4, 0.2) | blocker | Put a glowing ground trail or in-world arrow along the dashed route whenever "Go to the Capital" is the tracked step |
| 3 | The pre-boss scene (Model Room plus four freed leaders) replays in full before every attempt | run 7 log 42.9-62.1 s; run 8 `skip_dialogue 60` took 15 s | major | Play the scene once; on a retry, show a single "The leaders stand with you" line plus the boon list |
| 4 | The tracker shows "Go to the Capital" below a "???" line, after the Crease step it needs first, so the next physical step reads like the last one | n17rlate_01_start | major | Show the step the player must do now ("Go to the Capital") first, and the Crease step under it |
| 5 | The rules card says Primm's units cannot attack on turns 1-2, but by turn 4 he fields 5 cards and the player is at 24/34; "Watch what it builds" gives no advice | n17rlate_08_rules, n17rlate_08_b2 | major | Add a one-line counter tip to Setting Up (e.g. "Trade with Militia before turn 3") |
| 6 | The DEFEAT banner sits on top of the board and the cards, not on a clean screen (the anchor showed it covering the defeat panel's text too) | n17rlate_08_b3, anchor n17late_14_e1 | minor | Fade the board to about 40 % before the banner, and remove the banner before the defeat panel opens |
| 7 | The "Quest updated" toast covers the "H" of the HP panel on arrival in the Crease | n17rlate_05_cap2 | minor | Move the toast below the HP panel, or stack it under the tracker |
| 8 | The boon wording disagrees: dialogue says "+1 power", the rules card says "+1 attack" | run 7 log 60.1 s; n17rlate_08_rules | minor | Use the rules card's word ("attack") in the leader's line |
| 9 | Walking up to a shop sign opens the shop, and a buying tip pops over it while the player is only passing by | n17rlate_03_capmap (Tilly's shop and tip open after one E) | minor | Ask for E on the shop's door or counter only, not within 3 m of the sign |
| 10 | The Capital map is mostly dark, so the castle's route is hard to read from the Crease | n17rlate_05_pointme | minor | Reveal the main road from the Gate Plaza to the castle on the map once the Crease is found |

## 4. Three things that work and must not be lost

- The painted castle map, with named rooms, ticks and a skull boss medallion, is the best screen I saw (n17rlate_06_dmap).
- Primm's cut-in, with his name, his phase ("Phase 1: Standardization") and a line of dialogue, is a real boss entrance (n17rlate_08_b1).
- The map's "Point me to..." list names every goal, quest giver, shaft and dungeon in the Capital (n17rlate_05_pointme).

## 5. SCRIPT ERROR lines

None. All 8 runs have 0 `SCRIPT ERROR` lines (play_n17rlate_01.log to play_n17rlate_08.log).

## Wayfinding

- **In Crosspath:** I knew where to go ("Go to the Capital", with the Capital at the top of the map and a dashed route), but not how to get there. Four runs of holding north ended against the well, a signpost and two shops.
- **In the Crease:** once there (by dev jump), the tracker and "Point me to..." were clear: browse Fig Sly's market next, Primm's Castle at the top of the map.
- **Not seen:** the gate, its guard and the route up to the castle on foot.

## The climax

- **Presentation:** the build-up is strong. There is a gorgeous castle map, a rules card that lists all nine rules and a hidden trait, and a cut-in naming the phase.
- **Difficulty:** as a fight it failed for me exactly as it did for the anchor. Primm never lost a point, and I was dead on turn 6 against four Militia and a Village Well.
- **Phases:** I never saw a second one.
- **Caveat:** the pilot plays worse than a person. At turn 6 my hand still held The Big Unit, Landfill Leviathan and Resistance Scout (n17rlate_08_b3).

## The ending

Not reached.

## The credits and after

Not reached.
