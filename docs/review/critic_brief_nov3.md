# Critic brief - six new flows of "The Wayward Path" (read only this file)

You are reviewing a new indie deckbuilder RPG called **The Wayward Path** (Godot 4, Windows). You play it through a scripted driver
that injects real keyboard and mouse input and takes screenshots, so you see exactly what a player sees. **Judge only what you see
and do.** Do NOT read anything else in the folder: no `docs/` (except this brief), no `CLAUDE.md`, no `.gd` code, no `data/*.json`, no
reports or notes. The only files you may read are this brief, the screenshots and logs your own runs produce, and the scripts you write.

You play from `C:\Dev\Deckbuilder-rpg` (Git Bash: `cd /c/Dev/Deckbuilder-rpg`). Your play scripts go in
`docs/review/play_scripts/critic_nov3_*.txt`; your screenshots and logs appear under `_screenshots/play/<run_name>/`. Your report goes to
`docs/review/fresh_eyes_nov3.md` and the screenshots you cite are copied into `docs/review/fresh_eyes_nov3/`. Do not run git. Do not edit
any other file.

This PC is slow and low on memory: **run one game process at a time, always in the foreground, and wait for it to finish**. Each Bash call
can last at most 10 minutes: give every run a limit of 420 seconds or less and a Bash timeout of 600000 ms.

## Running a play script

```
cd /c/Dev/Deckbuilder-rpg && bash tools/play.sh docs/review/play_scripts/critic_nov3_<name>.txt <run_name> 420
```

Output: `_screenshots/play/<run_name>/<shot>.png` (1600x900 PNGs - open them with the Read tool), `play.log` (every command, the text that
`dump` and `scene` printed) and `stdout.log` (search it for `SCRIPT ERROR` - those are bugs worth reporting). Nothing is ever saved to the
player's real save slots. One command per line, `#` comments. **All coordinates are screenshot pixels** (0-1600 across, 0-900 down).

| Command | Does |
|---|---|
| `wait <seconds>` | let the game run (dialogue, animations, loading need 1-4 s; a zone load up to 8 s) |
| `key <Name>` | tap a key: `E`, `Space`, `Escape`, `Enter`, `W`, `A`, `S`, `D`, `C`, `J`, `M`, `Tab`, `Up`, `Down`, `1` ... |
| `hold <Name>[+<Name>] <seconds>` | hold keys (walking: `hold W 2`) |
| `click <x> <y>` / `rclick <x> <y>` / `move <x> <y>` | left click / right click / hover (hover shows tooltips; `wait 1` then `shot`) |
| `drag <x1> <y1> <x2> <y2>` | drag and drop (a hand card onto the board) |
| `button <text>` | click the first visible button whose label contains `<text>` (case-sensitive; `play.log` says NOT FOUND if none) |
| `shot <name>` | save a screenshot |
| `dump` | write every visible label and button with its text and position to `play.log` (find where to click) |
| `scene` | write the scene, level, gold and HP to `play.log` |
| `skip_dialogue [max]` | click through dialogue boxes and popups (read the important ones yourself: `key E`, `wait 0.8`, `shot`) |
| `pilot <seconds>` | a simple built-in player plays the current battle for up to that long |

Debug jumps:

| Command | Does |
|---|---|
| `dev travel town` | jump to the town (Crosspath) with a ready-made game |
| `dev level <n>` / `dev gold <n>` / `dev heal` | set the level, add gold, full heal |
| `dev item <id>` | give ONE charge of an item: `energy_draught`, `firebrand_charm`, `healing_salve`, `power_wraps`, `scroll_of_insight` |
| `dev quest <quest id> <step>` | set a quest's progress: `meet_the_merchants` (the first town quest), `some_assembly_required` (the armory quest) |
| `dev goto <spot>` | stand beside an NPC (then `key E`): `item_vendor` (Tilly Tonic), `equipment_vendor` (Bertram), `tailor` (Pip Threadwell, hats) |
| `dev travel dungeon <id> [node]` | enter a dungeon (`S-BEEF`, `S-IRON`); `-2` = beside its boss |
| `dev encounter <name>` | start a fight (`Baron Quadzilla`) |
| `dev win` / `dev lose` | end the current fight |

Start every script with `wait 2`, `dev travel town`, `wait 8`. The title screen shows the developer's saves: NEVER press "Start over here",
"Delete" or "Copy" on the slot screens.

## Your brief

You are a seasoned games critic and UX researcher. Judge each of these as a first-time player would:

1. **Tilly's item lesson**: `dev quest meet_the_merchants 0`, `dev goto item_vendor`, talk to her. Follow what she says until the item is
   equipped. Is it clear, short, funny? Does the game point the way?
2. **The Energy Draught**: equip one on the Character page (C), start a fight (`dev encounter Baron Quadzilla`), use it on your turn. Is its
   effect clear before and after? Do the item slots and charges behave?
3. **A dungeon's first visit** (`dev travel dungeon S-BEEF`, later `S-IRON`): what does an unvisited map show and how does it reveal?
4. **Pip's hat shop** (`dev gold 2000`, `dev goto tailor`): preview, buy, equip, take a hat off.
5. **The Character page** (C): readability, layout, the items panel, and the equipment page (`dev quest some_assembly_required 2`, talk to
   Bertram at `equipment_vendor` and follow what he says).
6. **Baron Quadzilla's hidden trait** (`dev travel dungeon S-IRON -2` puts you beside the boss; hover his node, then fight him - `pilot`
   helps): what do you see before and after his special move?

Compare honestly to well-loved games (Slay the Spire, Inscryption, Monster Train, Sea of Stars, Pokemon TCG Pocket) on clarity, friction,
reward feel, visual readability, humour, and bugs. Be specific and blunt - cite screenshots by file name. Score each flow 1-10 and end with
the **10 biggest problems** ranked by impact, each with a concrete suggested fix.

Practicalities: budget about 50 minutes of wall clock (hard stop at 60: write the report with what you have), at most 8 runs of 30-70
lines each; read the screenshots and `play.log` after every run. Report sections: Summary, How I played, Scores (table), Findings per
flow, Top 10 problems.
