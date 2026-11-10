# Wayfinding critic brief (Nov 10): can a stranger find each zone's main dungeon?

You are a brand-new player of **The Wayward Path** (a Godot deckbuilder RPG at `C:\Dev\Deckbuilder-rpg`). You know nothing about the game
beyond this page. Your one job: in each of the four Path zones, **starting fresh at the zone's entrance, reach the door of the zone's main
dungeon and get its entry prompt on screen**, using only what the game itself shows you - the quest tracker (top left), the map (M) and its
"Point me to..." list, the markers in the world, the minimap, and what people say when you talk to them. Then report how long it took,
how many attempts, and everything that confused you.

## How you play

The game is driven with a plain-text play script (no GDScript):

```
bash tools/play.sh <script.txt> <run_name> 170
```

Run it from `C:\Dev\Deckbuilder-rpg` (Git Bash). Output: `_screenshots/play/<run_name>/` with `play.log` and your screenshots. **Runs must
be 170 seconds or shorter** (the third argument); plan several short runs per zone. **Run one at a time, in the foreground, and never start a
second game while one is running** (`tasklist | grep -i godot` must be empty before you start the next).

Script commands (one per line, `#` comments; coordinates are screenshot pixels at 1600x900):
- `wait <s>`, `key <Name>` (E, Space, Escape, Enter, M, J, W, A, S, D, V, Up...), `hold <Name>[+<Name>] <s>` (walking: `hold W 2`, `hold W+A 1.5`),
  `click <x> <y>`, `move <x> <y>`, `button <text>`, `shot <name>`, `dump` (every visible label and button with its position, into the log),
  `scene` (where the hero is and which spots are in reach), `skip_dialogue`, `pilot <s>` (a built-in player finishes the current battle),
  `log <text>`.
- `dev load <snapshot>` loads a saved position. **Use it only as the first command of a run**, to start a zone or to resume where your last
  run stopped: at the end of each run write `dev save wf_<zone>_<n>` so the next run can continue with `dev load wf_<zone>_<n>`.
- `dev autowin on` once per zone (fights are not the test; you still have to walk to things), `dev heal` when your HP is low.
- **Forbidden:** `dev travel`, `dev goto`, `dev quest`, `dev gate`, `dev freed`, and reading the game's source files or docs for routes. You
  may read `docs/review/play_scripts/` only to copy command syntax, not for destinations. Do not edit any file of the game.

Walking: the hero walks about 3.5 m/s; `scene` prints the hero's position so you can tell whether you moved. Talking: stand close and
`key E` (an `[E] Talk` prompt appears), then `skip_dialogue` or `key E` through the lines; a quest offer may show a **button** (`dump`,
then `button <text>`). The map (`key M`) names places; **"Point me to..."** is a button on the map's legend: `click` it (its position is in a
`dump`), then click an entry in the list that opens - after you close the map (`key M`) a white arrow leads you there. Escape during a
conversation opens the pause menu (press Escape again). Gates: a zone's main dungeon may be behind something a person asks of you; the
tracker and the map are supposed to tell you what and where.

## The four starts (fresh arrivals, one snapshot each)

| Zone | Snapshot | The main dungeon you must reach |
|---|---|---|
| The Gainlands (Beefcake) | `bot_beefcake_enter_beefcake` | The House of Gains |
| The D.N.A. (Necrocrat) | `bot_necrocrat_enter_necrocrat` | The Hall of Final Approvals |
| The Endless Buffet (Gourmand) | `bot_gourmand_enter_gourmand` | The Test Kitchen |
| The Verdant Dump (Refusemancer) | `bot_refusemancer_enter_refusemancer` | The Rotheart |

Do them in this order. A zone is **done** when a screenshot shows the dungeon door's entry prompt or its confirmation dialog ("Enter the Test
Kitchen" or the like). If after about 25 minutes of game time (the sum of your runs' lengths) you still cannot reach it, stop that zone,
write down exactly where you were stuck and what you tried, and move on.

## What to report

Write `docs/review/critic_wayfinding_nov10/report.md` (create the folder; if the write is refused, put the full report in your final
message instead) with, per zone:
1. **Time** (game seconds, from the runs' play.log timestamps) and the **number of runs** until the prompt.
2. **The route you took**, in a few lines, and **what guided you** at each decision (a tracker line, a marker, the map, a person's words).
3. **Every moment of confusion**: what you expected, what the game showed, how long you lost. Name the screenshot.
4. **Markers that lied** (a marker on something that was not what you needed, a gate with no hint, a person hidden behind something).
5. A **clarity score /10** for finding the way, with one sentence why.

Finish with the four scores in one line and the three fixes that would have helped most. Screenshots stay in `_screenshots/play/<run>/`;
name them in the report as `<run>/<shot>.png`. Keep the tone plain and specific; numbers over adjectives.
