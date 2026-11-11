# Midgame critic on the exported build (Nov 10): the Endless Buffet, arrival to the Test Kitchen boss

You are a brand-new player of **The Wayward Path**, a deckbuilder RPG (Godot, Windows). You know nothing about it beyond this page. You
play the **exported build** (what a player downloads), not the editor project. Your job: play the midgame - arrive in the Endless Buffet,
find your way to the Test Kitchen and fight its boss - and score **clarity** and **fun** out of 10, with a top 10 of problems. The same
stretch scored **clarity 5, fun 4** last night on the previous build; say plainly what moved and what did not.

## How you play

Plain-text play scripts, run against the exported pack:

```
bash tools/play_exported.sh <script.txt> <run_name> 170
```

Run it from `C:\Dev\Deckbuilder-rpg` (Git Bash). Output: `_screenshots/exported/<shot>.png` and `_screenshots/exported/play_<run_name>_play.log`.
**Runs must be 170 seconds or shorter** (the third argument); plan many short runs. **Run one at a time, in the foreground, and never
start a second game while one is running** (`tasklist | grep -i godot` must be empty before you start the next).

Script commands (one per line, `#` comments; coordinates are screenshot pixels at 1600x900):
- `wait <s>`, `key <Name>` (E, Space, Escape, Enter, M, J, R, W, A, S, D...), `hold <Name>[+<Name>] <s>` (walking: `hold W 2`), `click <x> <y>`,
  `rclick <x> <y>` (a card's full preview), `move <x> <y>` (hover), `button <text>`, `shot <name>`, `dump` (every visible label and button
  with its position, into the log), `scene` (where the hero is), `skip_dialogue`, `pilot <s>` (a built-in player finishes the current
  battle), `log <text>`.
- `dev load <snapshot>` loads a saved position - **only as the first command of a run**; `dev save <name>` at the end of a run so the next
  can continue (`dev load <name>`). `dev autowin on` is **not allowed** this time: fights are part of the test (play the first turns yourself,
  then `pilot 60`); `dev heal` is allowed between fights. `dev travel dungeon D-TTK` (the Test Kitchen's door) and `dev travel dungeon
  D-TTK -2` (its boss) are allowed **only after** you have tried to reach the door on foot for 20 minutes of game time - say so in the report.
- **Forbidden:** `dev goto`, `dev quest`, `dev gate`, `dev freed`, `dev win`, and reading the game's source files or docs for routes. You may
  read `docs/review/play_scripts/` only to copy command syntax. Do not edit any file of the game.

Walking: ~3.5 m/s. Talking: stand close and `key E`, then `skip_dialogue` or `key E` through the lines; a quest offer may show a button
(`dump`, then `button <text>`). The map is `M`; its legend has a **"Point me to..."** button that opens a list over the map - click an entry
and, after you close the map, a white arrow leads you there (it follows a walkable route; the map draws the route as a dotted line). The
quest log is `J`. In a battle: click a card or drag it onto the table, `To Combat [Space]`, `End Turn`; `R` opens the rules of the fight.

## The start

`dev load bot_refusemancer_enter_gourmand`: a level-14 hero of another Path arriving in the Endless Buffet. Play from there as a player would:
the hub, the people, the quests you are given, the way to the Test Kitchen (a gate stands on it; the game is supposed to tell you what
opens it), the dungeon's rooms and its boss. About 45 minutes of game time in all (the sum of your runs' lengths); stop at 60.

## What to report

Write `docs/review/critic_exported_midgame_nov10/report.md` (create the folder; if the write is refused, put the full report in your final
message instead):
1. **How you played** in a few lines: runs, game time, where you got to, what you used `dev travel` for (if anything).
2. **Scores:** clarity /10 and fun /10 (and polish /10), each with two sentences of why, against last night's 5 / 4.
3. **Finding the way:** how long from arrival to the Test Kitchen's door, what guided you at each step (a marker, the arrow, the map, a
   person), every moment of confusion with the screenshot's name.
4. **Battles:** what the numbers on your hand cards told you, whether "Turn N" and "Your turn / Enemy's turn" made sense, what the boss's
   "Setting Up" meant to you, how a loss read.
5. **Top 10 problems**, ranked, each with a screenshot name, what you expected, what the game showed, and the smallest fix you can think of.
6. **Anything broken** (a stuck screen, an error, a crash) with the run's name.

Screenshots stay in `_screenshots/exported/`; name them in the report as `<shot>.png`. Keep the tone plain and specific; numbers over adjectives.
