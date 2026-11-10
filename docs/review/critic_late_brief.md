# Critic brief - the LATE GAME on the release-candidate build (read only this file)

You are reviewing a new indie deckbuilder RPG called **The Wayward Path** (Godot 4, Windows) in its **release-candidate build**: the
exported game as a player would download it, not the editor. You play it through a scripted driver that injects real keyboard and mouse
input and takes screenshots, so you see exactly what a player sees. **Judge only what you see and do.** Do NOT read anything else in the
project: no `docs/` (except this file), no `CLAUDE.md`, no `.gd` code, no `data/*.json`, no reports, scorecards, balance logs, design notes,
earlier reviews or code comments. The only files you may read are this brief, the screenshots and logs your own runs produce, and the
scripts you write. Do not run git. Do not edit any file other than your own scripts and your report.

This PC is slow and low on memory: **run one game process at a time, always in the foreground, and wait for it to finish** (a run that
overlaps another corrupts both). Each Bash call can last at most 10 minutes, so give every run a limit of 480 seconds or less and a Bash
timeout of 600000 ms. A script that reaches its limit stops and the game closes; plan long sessions as several runs chained with
`dev save` / `dev load` (below). Every run starts about 25 s of loading before the title screen appears. Never start a second run while one
is going, and never run anything in the background.

**Your job:** play about **45 minutes of game time** of the **end of the game**: the Capital (the last city), **Primm's Castle** (the
final dungeon) with **the real final boss fight against Primm** (all of its phases - play at least one phase yourself with clicks and
drags; `pilot` the rest), **the ending** (read it: cutscenes, epilogue, credits - judge the writing), and **the start of the postgame**
(what the game offers after the credits, the first postgame place you can reach).

Score **clarity, fun and polish**, and note anything **broken** and anything that looks **unfinished or obviously AI-made**. Then list your
**top 10 problems**, most important first.

Your play scripts go in `C:\Dev\Deckbuilder-rpg\docs\review\play_scripts\critic_late_<name>.txt` (Git Bash: `/c/Dev/Deckbuilder-rpg/...`).
Your report goes to `C:\Dev\Deckbuilder-rpg\docs\review\critic_late_nov10\report.md`.

## Running a play script

```
cd /c/Dev/Deckbuilder-rpg && bash tools/play_exported.sh docs/review/play_scripts/critic_late_<name>.txt <run_name> 480
```

Output (all in `_screenshots/exported/`): `<shot>.png` (1600x900 PNGs - open them with the Read tool; **prefix every shot name with your run
name** so runs do not overwrite each other, e.g. `shot l2_03_gate`), `play_<run_name>_play.log` (every command with a timestamp, the text that
`dump` and `scene` printed) and `play_<run_name>.log` (the game's own output; search it for `SCRIPT ERROR` - those are bugs worth reporting).
Nothing you do is ever saved to a player's real save slots.

One command per line, `#` comments. **All coordinates are screenshot pixels** (0-1600 across, 0-900 down), exactly as you see them in the PNGs.

| Command | Does |
|---|---|
| `wait <seconds>` | let the game run (dialogue typewriters, animations, loading screens need 1-4 s; a zone load can need 8-12 s) |
| `key <Name>` | tap a key: `E`, `Space`, `Escape`, `Enter`, `W`, `A`, `S`, `D`, `B`, `C`, `J`, `M`, `P`, `T`, `Tab`, `Up`, `Down`, `1` ... |
| `hold <Name>[+<Name>] <seconds>` | hold keys: walking is `hold W 2`, diagonal `hold W+D 1.5` |
| `click <x> <y>` / `rclick <x> <y>` / `move <x> <y>` | left click / right click / hover the mouse there (hover shows tooltips and card previews; `wait 1` then `shot`) |
| `drag <x1> <y1> <x2> <y2>` | drag and drop (a hand card onto the board) |
| `button <text>` | click the first visible button whose label contains `<text>` (case-sensitive; the log says NOT FOUND if none) |
| `shot <name>` | save a screenshot (name it by run, place and moment, e.g. `r2_05_shop`) |
| `dump` | write every visible label and button, with its text and position, to the log - use it to read small text and find where to click |
| `scene` | write the current scene, level, gold and HP to the log |
| `skip_dialogue [max]` | tap E / click through dialogue boxes, story stills and reward popups until none is open (default 40 taps). For the conversations that matter (the opening, a zone's first NPC, a boss's intro), read them yourself instead: `key E`, `wait 0.8`, `shot`, repeated - you are judging the writing too |
| `pilot <seconds>` | a simple built-in player plays the current battle for up to that long (keeps its hand, plays cards, attacks, blocks, reads a tip then presses Got it, confirms End Turn). Use it to get through fights; play at least a few fights **yourself** with clicks and drags to judge the combat |
| `log <text>` | a note in the log |

Debug jumps (what the game's own developer menu does). **Play the first hour straight, with no jumps**: New Game, the opening, the forest,
the cave, Crosspath. Use jumps only after that, to sample later content (a Path zone, a dungeon, a boss), and say in the report where you jumped.

| Command | Does |
|---|---|
| `dev save <name>` / `dev load <name>` | snapshot the whole game / resume it (works across runs; a run always starts at the title screen, so `dev load` is normally the first line of a script after `wait 2`). A snapshot restores the place and the game state, not an open popup or a dungeon's node map: re-enter a dungeon with `dev travel dungeon` after a load |
| `dev level <n>` / `dev gold <n>` / `dev heal` | silent level set, add gold, full heal |
| `dev travel town` / `forest` / `capital` / `arena` | jump to the town (Crosspath), the starting forest, the Capital's inside, the arena |
| `dev travel zone <beefcake|gourmand|refusemancer|necrocrat>` | jump into a Path's zone (its gatekeeper ignored): beefcake = the Gainlands, necrocrat = the D.N.A., gourmand = the Endless Buffet, refusemancer = the Verdant Dump |
| `dev travel dungeon <id> [node]` | enter a dungeon at its entrance; `node` = a node number, `-2` = next to the boss. Ids: `D-HFA` The Hall of Final Approvals (the D.N.A.'s main dungeon), `D-TTK` The Test Kitchen (the Buffet's), `D-ROT` The Rotheart (the Dump's), `D-HOG` The House of Gains (the Gainlands'), `D-PC` Primm's Castle (the final dungeon), `S-IRON` The Iron Cave, `S-NECRO` The Waiting Room of Eternity, `S-GOUR` Omakase, `S-REF` The Trash Panda Throne, `S-TOWN` The Forgotten Vault, `D-LAB` The Path-ology Lab (postgame) |
| `dev encounters <query>` / `dev encounter <query>` | list / start a fight from the game's catalog by name or group (`boss`, `zone:necrocrat`, `capital`, a boss's name such as `Primm`); starting one this way pays nothing and returns to town after |
| `dev freed <zone>` / `dev gate <zone>` | mark a Path zone freed / its gatekeeper beaten (unlocks later content) |
| `dev autowin on` / `dev win` / `dev lose` | every fight auto-won / end the current fight won or lost (to sample later content quickly) |

## Starting

The game has snapshots of a level-20 hero for you: `c13cap` (in the Capital), `c13castle` (at the castle), `c13end` and `c13post` (later).
Your first script: `wait 4`, `shot l1_01_title`, `dev load c13cap`, `wait 14`, `scene`, `shot l1_02_capital`, `dump`. Walk the Capital like
a player for a while (its districts, people, signs, shops), then go to **Primm's Castle**: walk to its entrance if you can (the map `M` and its
place list help); if after two runs you cannot, `dev load c13castle` or `dev travel dungeon D-PC` and say so. Play the castle's
nodes (pilot most of them) and **the real Primm fight**: do not use `dev win`, `dev autowin` or `dev encounter` for Primm. If you lose, say
how, `dev heal` and try again (you may `dev level 24` after two losses; say so). After the credits, keep playing into the postgame for the
rest of your time. If the ending will not come within your time, use `dev load c13end` and then `c13post` and say so. Use `dev save l<n>`
at good points. Walk with `hold W 2` etc.; `M` opens the map, `Escape` the pause menu, `E` talks and interacts.

## What to report (`docs/review/critic_late_nov10/report.md`)

1. **Summary** (one paragraph) and **how you played** (runs, snapshots and jumps used, minutes).
2. **Scores**, each with a sentence of why: Clarity /10, Fun /10, Polish /10, and a line on anything **broken** and anything that looks
   **unfinished or obviously AI-made** (placeholder art, overflowing boxes, template-sounding text, flat 3D stand-ins next to painted art).
3. **Top 10 problems**, most important first (what, where = screenshot names, severity: blocker / major / minor, smallest fix).
4. **Smaller notes** (anything else, including every `SCRIPT ERROR` you found in the game logs, and anything that differs from what the
   HUD or a tip promised).
5. **What worked** (three to five things worth keeping exactly as they are).

Be concrete and fair: a screenshot for every claim, no guessing about causes you cannot see. Copy every screenshot you cite into
`docs/review/critic_late_nov10/shots/` (keep the names). Those and your scripts are the only files you write.
