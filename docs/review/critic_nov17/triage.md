# Nov 17: triage of the playthrough and the critics' panel

Sources: `playthrough.md` (Part 1), `01_combat.md` ... `06_cardgames.md` (Part 2). Severity is the critic's (blocker / major / minor);
reach = how many players meet it (all / most / some / few); effort S (an hour or less) / M (a few hours) / L (a day or new art).
"Owner?" = needs the owner's taste or a rule change. Status: **Fixed** (tonight, with a test or a shot), **Logged** (not tonight),
**L plan** (written below), **Owner** (in the report's decisions).

## Part 1 - the playthrough

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| P1 | Primm's Castle is a wall for the planning AI (10 tries, L17-24; the castle's 4th room lost 5 times, Primm's later phases 5) | major | some | M | yes (Primm fixed) | **Owner**: the castle's 4th room, not Primm, is the most-lost fight of the game |
| P2 | The Rescuer's cave-mouth scenes had no marker | major | most | S | no | **Fixed** ("!" over her while she waits) |
| P3 | "Free the Four Zones" (the castle's marker) depends on talking to Brannoch | minor | few | S | yes | **Owner** (start it on the first Capital visit?) |
| P4 | Captain Spotless beat an L16 hero twice | minor | some | - | - | Logged (inside the sims' band) |

## Critic 4 - the art director (5.5/10)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| A1 | The Crease shows the sky and the Capital's skyline over its back wall | blocker | all | S | no | **Fixed** (the north wall rises above the ceiling; shot after) |
| A2 | The D.N.A. reads as a greybox (one-texture wallpaper walls, white light quads, a faceted orb, blank signs, white cubes) | blocker | all | L | no | **L plan** |
| A3 | The Capital's facades and floors are flat pastel fills; a hot checkerboard | major | all | L | taste | **L plan** |
| A4 | The Buffet is washed out by its haze; the sea is a flat plane with decals | major | all | M | taste | Logged (the Buffet's look was the owner's Nov 16 pass) |
| A5 | Untextured low-poly primitives beside painted art (Buffet cabbages, cubes, an X-eyed box; the Dump's pink pig cube; topiary spheres) | major | all | M | no | **L plan** (a primitive sweep) |
| A6 | A different post filter in every zone | major | all | M | taste | **Owner** (one master grade?) |
| A7 | The Opening Forest (the first screen) is murky | major | all | S | taste (teal dusk) | **Owner** |
| A8 | The Gainlands' stepped cliffs and tiled brick | major | all | L | no | **L plan** |
| A9 | Voids at map edges (the Reek, the Transit Yards, the Dump's arrival water, the Crease's tunnel) | major | most | M | no | Logged |
| A10 | The freed Capital barely celebrates in Grave Row | minor | most | S | no | By design: Grave Row holds the royal funeral after Primm; bunting there would be wrong. Lanterns / mourners are an owner idea |

## Critic 1 - combat and deckbuilding (4/10, provisional: one fight finished)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| C1 | No roamer near the Dump's entrance (the nearest are 22 m off; the critic found none in four runs) | major | some | S | no | Logged (they were moved off the bean line on Nov 10 on purpose) |
| C2 | The 45-card minimum with 19 basic infrastructure dilutes every new card | major | all | M | **yes** (a core rule) | **Owner** |
| C3 | Fights are long (8 turns, 1.5 min at pilot speed for a first room) | major | all | M | yes (balance) | **Owner** (with C2) |
| C4 | Boss setup turns then a swarm: nothing shows what the boss will do | major | all | L | yes | **L plan** (an intent strip) |
| C5 | The hand overflows over 6 cards and overlaps the infrastructure row | major | most | M | **no: the board layout stays** | Logged (owner rule) |
| C6 | Attackers cover blockers during combat | minor | most | M | board layout | Logged (owner rule) |
| C7 | Four boxes before the first action; "End your turn?" catches double presses | minor | all | S | - | Checked: the confirm only asks while a card is playable and has "don't ask again"; logged |
| C8 | The boss intro says "The Grand Chef", the board "The Doppelganger" | minor | most | S | story | Logged: the impostor is the twist; critic 3 to judge |
| C9 | Hand cards show a generic "Effect" chip | minor | all | S | no | **Fixed** (the chip says when: On play, On death, On attack ...) |
| C10 | Path identity blurs in a two-Path deck | minor | some | M | - | Logged |

## Critic 2 - the late game and the ending (4/10; did not reach the ending: Primm phase 1 lost on turn 6 at L17)

| # | Issue | Sev | Reach | Effort | Owner? | Plan / status |
|---|---|---|---|---|---|---|
| L1 | With four lands free there was no main quest ("Nothing here right now"); the HUD tracked a side quest | blocker | some (whoever skipped Brannoch) | S | no | **Fixed**: once a zone is free, Free the Four Zones starts by itself and leads over a side quest (same as playthrough P3) |
| L2 | Crosspath's "Point me to..." had no entry for the Capital | major | all | S | no | **Fixed**: exits come right after dungeons and gates; the cap is 22 |
| L3 | The north exit is hard to find on foot (the lawn stops you under the label) | major | some | M | no | Logged (the critic's blind scripting played a part; the road is marked once L2 points at it) |
| L4 | DEFEAT drawn over the defeat panel's own text | major | all who lose | S | no | **Fixed**: the word clears as the panel opens |
| L5 | Primm's three free Militia decide phase 1 | major | all | S | **yes (Primm unchanged)** | **Owner** |
| L6 | Standing Army says 3/3, the board shows 3/1 with a -2 | minor | all | S | Primm rules | Logged (a debuff on the board, not the rule; Primm unchanged) |
| L7 | Primm's long pre-fight scene replays on every re-entry | minor | some | S | - | Logged |
| L8 | Primm's cut-in line repeats his first Model Room line | minor | all | S | single line | **Fixed** (one line, `docs/dialogue/nov17_single_lines.csv`) |
| L9 | "Usually level 21" with a level-16 hero and nothing says where to level | minor | some | S | - | Logged (the hint already shows amber 2+ levels under) |
| L10 | The tracker's pager flips to a side quest while a shop is open | minor | some | S | - | Logged |
