# Critic brief - a first look at today's build (Nov 12d; read only this file)

You are reviewing an indie deckbuilder RPG called **The Wayward Path** (Godot 4, Windows), in its development build. You play it through
a scripted driver that injects real keyboard and mouse input and takes screenshots, so you see what a player sees. **Judge only what you
see and do.** Do NOT read anything else in the project: no `docs/` (except this file), no `CLAUDE.md`, no `.gd` code, no data files, no
reports, earlier reviews or other people's scripts. The only files you may read are this brief, the screenshots and logs your own runs
produce, and the scripts you write. Do not run git. Do not edit any file other than your own scripts and your report.

**Hard limits.** This PC is slow and low on memory:
- **One game process at a time, always in the foreground; wait for it to finish.** `tasklist | grep -i godot` must print nothing before
  the next run. Never run anything in the background.
- **Every run is 170 seconds or shorter** (the third argument). A run starts with about 20 s of loading before the title screen.
- **Wall-clock budget: 30 minutes in total, at most 12 runs.** Run `date` first and before every run. At 24 minutes stop playing and
  write the report, whatever you have seen. An honest partial report on time is worth more than a complete one late.
- Look at screenshots sparingly (they are large): about 4 to 8 per run, the ones that matter.

## Your job: two short sessions

**Session 1 (about 6 runs) - a new game through the first hour.** The title's New Game, the opening forest, the tutorial dungeon
(**the Forgotten Cave**): its pop-up rooms (a **shrine**, and **the Hollow Well** - take the well's offer once), the **"Before the fight"
panel** before a fight, the boss (**the Cave Warden**) and **his closing words**, then **the first step out into the town of Crosspath**
and the first quests (Elder Maren's errands) as far as you get, up to being sent out on your Path.

**Session 2 (about 5 runs) - the last city.** From the snapshot `c13cap` (a level-20 hero arriving at the Capital): reach the Capital,
follow the quest **"Under the Capital"** from its first step through **the manhole** into **the Crease** (a hideout under the city), find
**the Black Market** (Fig Sly) there, then walk **the Capital's edges** (along the outer wall, outside and inside) and the district called
**the Transit Yards**, looking for anything that floats, is cut off, shows a void or looks wrong.

Score **clarity, fun and polish** out of 10 (one score each for the whole of what you saw; say if the two sessions differ much). Then list
your **top 10 problems**, most important first: anything **broken**, **confusing**, **ugly** or **obviously AI-made** (template-sounding
text, placeholder or mismatched art, flat stand-ins next to painted art, overflowing or clipped boxes). Give each a size: **S** (a small,
safe fix: text, a position, a size, a colour, a missing prompt), **M** (a contained change to one screen or one place), **L** (a redesign
or new art).

Your scripts go in `/c/Dev/Deckbuilder-rpg/docs/review/play_scripts/n12d_<nn>.txt`. Your report goes to
`/c/Dev/Deckbuilder-rpg/docs/review/critic_nov12d/report.md` (if the write is refused, put the complete report in your final message).

## Running a play script

```
cd /c/Dev/Deckbuilder-rpg && bash tools/play.sh docs/review/play_scripts/n12d_<nn>.txt <run_name> 170
```

Output in `_screenshots/play/<run_name>/`: `<shot>.png` (1600x900; open with the Read tool), `play.log` (every command with a timestamp,
plus what `dump` and `scene` printed) and `stdout.log` (the game's own output: run `grep -c "SCRIPT ERROR" _screenshots/play/<run_name>/stdout.log`
after every run - anything above 0 is a bug worth reporting, with the lines). Nothing you do touches a player's real saves.

One command per line, `#` comments. **Coordinates are screenshot pixels** (0-1600 across, 0-900 down).

| Command | Does |
|---|---|
| `wait <seconds>` | let the game run (dialogue and animations need 1-4 s; a zone load 8-14 s) |
| `key <Name>` | tap a key: `E`, `Space`, `Escape`, `Enter`, `W`, `A`, `S`, `D`, `B`, `C`, `J`, `M`, `P`, `Tab`, `Up`, `Down`, `1` ... |
| `hold <Name>[+<Name>] <seconds>` | hold keys: walking is `hold W 2`, diagonal `hold W+D 1.5` (W is away from the camera, i.e. north) |
| `click <x> <y>` / `rclick <x> <y>` / `move <x> <y>` | left click / right click / hover |
| `drag <x1> <y1> <x2> <y2>` | drag and drop (a hand card onto the board) |
| `button <text>` | click the first visible button whose label contains `<text>` (case-sensitive; the log says NOT FOUND if none) |
| `shot <name>` | save a screenshot (prefix with the run name) |
| `dump` | write every visible label and button with its text and position to the log: use it to read text and find where to click, instead of a screenshot, whenever the words are what you need |
| `scene` | write the current scene, level, gold and HP to the log |
| `skip_dialogue [max]` | tap through dialogue boxes, story stills and reward popups until none is open. For the conversations you are judging (the Warden's closing words, Maren's welcome, Fig Sly), read them: `dump`, `key E`, `wait 0.8`, repeated |
| `pilot <seconds>` | a simple built-in player plays the current battle for up to that long. Use it for most fights; play a turn or two of one fight yourself |
| `log <text>` | a note in the log |

Debug jumps (the game's own developer menu). Say in the report where you jumped.

| Command | Does |
|---|---|
| `dev save <name>` / `dev load <name>` | snapshot the whole game / resume it across runs (a run always starts at the title: `wait 4`, then `dev load <name>`, `wait 14`). Name yours `n12d_<x>`. A snapshot restores the place and the state, not an open pop-up or a dungeon's room map; a dungeon is never saved mid-run, so play the cave within runs or re-enter it |
| `dev heal` / `dev gold <n>` | full heal / add gold |
| `dev travel town` / `forest` / `capital` | jump to Crosspath / the opening forest / the Capital |
| `dev travel dungeon <id> [node]` | enter a dungeon at its entrance or at a room number (`-2` = next to the boss). The Forgotten Cave is `D-TUT` (use this only if walking to its gate in the forest fails) |
| `dev goto <spot id>` | stand the hero on a talk / use spot of the current place, then `key E` uses it. In Crosspath: `elder` (Maren), `vendor` (Sable), `item_vendor` (Tilly), `tailor` (Pip), `equipment_vendor` (Bertram). In the Capital: `manhole`. Prefer real walking where you are judging wayfinding, `goto` where you are short of time |
| `dev win` / `dev autowin on|off` | end the current fight won / every fight auto-won. Fine for fights you are not judging |

## Starting

Run 1: `wait 5`, `shot`, `button New Game`, `wait 8`, then read the opening with `dump` + `key E`. Play forward like a new player: the game
tells you where to go. In a dungeon you move by clicking rooms on a map; a pop-up or panel opens per room. If you are stuck for more than
one run, jump (`dev travel ...`) and say so: being stuck is itself a finding. Keep Session 1 to about 6 runs, then start Session 2 with
`dev load c13cap` whatever happened.

## The report (`docs/review/critic_nov12d/report.md`), short

1. **How you played** (runs, jumps, what you did not reach).
2. **Scores**: Clarity /10, Fun /10, Polish /10, two sentences each.
3. **Top 10 problems**, most important first: what, where (screenshot `run/shot.png` or a log line), why it matters, size S / M / L, the
   smallest fix you can see.
4. **Smaller notes**, including every `SCRIPT ERROR` line.
5. **What worked** (three things to keep as they are).

A screenshot or a log line for every claim; no guessing about causes you cannot see.
