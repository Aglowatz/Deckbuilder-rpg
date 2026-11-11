# Wayfinding critic brief (Nov 11, exported build, second run): can a stranger find the main dungeon in two zones?

You are a brand-new player of **The Wayward Path**, a deckbuilder RPG (Godot, Windows). You know nothing about it beyond this page. You
play the **exported build** (what a player downloads), not the editor project. Your one job: in each of two zones, **starting fresh at the
zone's entrance, reach the door of the zone's main dungeon and get its entry prompt on screen**, using only what the game itself shows you:
the quest tracker (top left), the quest log (J), the map (M) and its "Point me to..." list, the markers and arrows in the world, the
minimap, signs, and what people say when you talk to them. Then report how long it took, how many runs, and everything that confused you.

## How you play

Plain-text play scripts, run against the exported pack:

```
bash tools/play_exported.sh <script.txt> <run_name> 170
```

Run it from `C:\Dev\Deckbuilder-rpg` (Git Bash). Output: `_screenshots/exported/<shot>.png` and `_screenshots/exported/play_<run_name>_play.log`
(the driver's log, with timestamps) plus `_screenshots/exported/play_<run_name>.log` (the game's own log). **Runs must be 170 seconds or
shorter** (the third argument); plan many short runs. **Run one at a time, in the foreground, and never start a second game while one is
running** (`tasklist | grep -i godot` must print nothing before you start the next). Save your scripts as
`docs/review/play_scripts/wy_<zone>_<nn>.txt` (zone = gain, dump).

Script commands (one per line, `#` comments; coordinates are screenshot pixels at 1600x900):
- `wait <s>`, `key <Name>` (E, Space, Escape, Enter, M, J, W, A, S, D, V, Up...), `hold <Name>[+<Name>] <s>` (walking: `hold W 2`,
  `hold W+A 1.5`), `click <x> <y>`, `move <x> <y>` (hover), `button <text>`, `shot <name>`, `dump` (every visible label and button with its
  position, into the log), `scene` (where the hero is and which spots are in reach), `skip_dialogue`, `pilot <s>` (a built-in player
  finishes the current battle), `log <text>`.
- `dev load <snapshot>` loads a saved position. **Use it only as the first command of a run**, to start a zone or to resume where your last
  run stopped: at the end of each run write `dev save wy_<zone>_<nn>` so the next run can continue with `dev load wy_<zone>_<nn>`. (A
  resumed run starts at the zone's entrance with your quest state kept; count that re-walk in your time.)
- `dev autowin on` once per zone (fights are not the test; you still have to walk to things), `dev heal` when your HP is low.
- **Forbidden:** `dev travel`, `dev goto`, `dev quest`, `dev gate`, `dev freed`, `dev grow`, and reading the game's source files, data files
  or docs for routes. You may read `docs/review/play_scripts/` only to copy command syntax, never for destinations or routes. Do not edit any
  file of the game.

Walking: the hero walks about 3.5 m/s; `scene` prints the hero's position so you can tell whether you moved. Talking: stand close and
`key E` (an `[E] Talk` prompt appears), then `skip_dialogue` or `key E` through the lines; a quest offer may show a **button** (`dump`,
then `button <text>`). The map is `M`; its legend has a **"Point me to..."** button that opens a list over the map: click an entry and,
after you close the map, an arrow leads you there. Escape closes the top pop-up or the current conversation line first; with nothing open
it opens the pause menu (Escape again closes it). A zone's main dungeon may lie behind something the zone asks of you first; the tracker,
the quest log's "Where to go" line, the map and the people are supposed to tell you what and where.

## The two starts (fresh arrivals, one snapshot each)

| Zone | Snapshot | The main dungeon you must reach |
|---|---|---|
| The Verdant Dump | `bot_refusemancer_enter_refusemancer` | The Rotheart |
| The Gainlands | `bot_beefcake_enter_beefcake` | The House of Gains |

Do them in this order. A zone is **done** when a screenshot shows the dungeon door's entry prompt or its confirmation dialog ("Enter the
House of Gains" or the like). If after about 25 minutes of game time (the sum of your runs' lengths, from the play logs) you still cannot
reach it, stop that zone, write down exactly where you were stuck and what you tried, and move on. Two practical notes from an earlier
player: a fight that starts on arrival takes about 8 s before its Continue button exists, so wait before walking; and a pop-up that says
"E / Click to close" needs a plain `key E` (`skip_dialogue` does not count it).

## What to report

Write `docs/review/critic_wayfinding_nov11/report_run2.md` (create the folder; if the write is refused, put the full report in your final
message instead) with, per zone:
1. **Time** (game seconds, from the runs' play logs) and the **number of runs** until the prompt.
2. **The route you took**, in a few lines, and **what guided you** at each decision (a tracker line, a marker, the arrow, the map, a
   person's words, a sign).
3. **Every moment of confusion**: what you expected, what the game showed, how long you lost. Name the screenshot.
4. **Markers that lied** (a marker on something that was not what you needed, a gate with no hint, a person hidden behind something, an
   arrow that led into something you could not cross).
5. A **clarity score /10** for finding the way, with one sentence why.

Finish with the two scores in one line and the three fixes that would have helped most. Screenshots stay in `_screenshots/exported/`;
name them in the report as `<shot>.png`. Keep the tone plain and specific; numbers over adjectives.
