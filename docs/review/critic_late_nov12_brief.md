# Critic brief - the LATE GAME on the release-candidate build (Nov 12; read only this file)

You are reviewing a new indie deckbuilder RPG called **The Wayward Path** (Godot 4, Windows) in its **release-candidate build**: the
exported game as a player would download it, not the editor. You play it through a scripted driver that injects real keyboard and mouse
input and takes screenshots, so you see exactly what a player sees. **Judge only what you see and do.** Do NOT read anything else in the
project: no `docs/` (except this file), no `CLAUDE.md`, no `.gd` code, no `data/*.json`, no reports, scorecards, balance logs, design notes,
earlier reviews or code comments. The only files you may read are this brief, the screenshots and logs your own runs produce, and the
scripts you write. Do not run git. Do not edit any file other than your own scripts and your report.

This PC is slow and low on memory: **run one game process at a time, always in the foreground, and wait for it to finish** (a run that
overlaps another corrupts both; `tasklist | grep -i godot` must print nothing before you start the next). **Every run must be 170 seconds or
shorter** (the third argument below); plan the session as many short runs chained with `dev save` / `dev load`. Every run starts with about
25 s of loading before the title screen appears. Never run anything in the background.

**Your job:** play about **45 minutes of game time** of the **end of the game**: the Capital (the last city), **Primm's Castle** (the
final dungeon) with **the real final boss fight against Primm** (all of its phases - play at least one phase yourself with clicks and
drags; `pilot` the rest), **the ending** (read it: cutscenes, epilogue, credits - judge the writing), and **the start of the postgame**
(what the game offers after the credits; the first postgame places you can reach: the Path-ology Lab, and the cracked mirror by the castle
door that leads to the Shattered Gallery).

Score **clarity, fun and polish** out of 10. The same stretch scored **clarity 5, fun 4, polish 5** on the previous build (Nov 11); say
plainly what moved and what did not. Note anything **broken** and anything that looks **unfinished or obviously AI-made**. Then list your
**top 10 problems**, most important first.

Your play scripts go in `C:\Dev\Deckbuilder-rpg\docs\review\play_scripts\critic_late_n12_<nn>.txt` (Git Bash: `/c/Dev/Deckbuilder-rpg/...`).
Your report goes to `C:\Dev\Deckbuilder-rpg\docs\review\critic_late_nov12\report.md` (create the folder; if the write is refused, put the
complete report in your final message).

## Running a play script

```
cd /c/Dev/Deckbuilder-rpg && bash tools/play_exported.sh docs/review/play_scripts/critic_late_n12_<nn>.txt <run_name> 170
```

Output (all in `_screenshots/exported/`): `<shot>.png` (1600x900 PNGs - open them with the Read tool; **prefix every shot name with your run
name** so runs do not overwrite each other, e.g. `shot q2_03_gate`; start every shot name with `q`, earlier reviews used `l`), `play_<run_name>_play.log` (every command with a timestamp, the text that
`dump` and `scene` printed) and `play_<run_name>.log` (the game's own output; search it for `SCRIPT ERROR` - those are bugs worth reporting).
Nothing you do is ever saved to a player's real save slots.

One command per line, `#` comments. **All coordinates are screenshot pixels** (0-1600 across, 0-900 down), exactly as you see them in the PNGs.

| Command | Does |
|---|---|
| `wait <seconds>` | let the game run (dialogue typewriters, animations, loading screens need 1-4 s; a zone load can need 8-12 s) |
| `key <Name>` | tap a key: `E`, `Space`, `Escape`, `Enter`, `W`, `A`, `S`, `D`, `B`, `C`, `J`, `M`, `P`, `R`, `T`, `Tab`, `Up`, `Down`, `1` ... |
| `hold <Name>[+<Name>] <seconds>` | hold keys: walking is `hold W 2`, diagonal `hold W+D 1.5` |
| `click <x> <y>` / `rclick <x> <y>` / `move <x> <y>` | left click / right click (a card's full preview) / hover the mouse there (hover shows tooltips; `wait 1` then `shot`) |
| `drag <x1> <y1> <x2> <y2>` | drag and drop (a hand card onto the board) |
| `button <text>` | click the first visible button whose label contains `<text>` (case-sensitive; the log says NOT FOUND if none) |
| `shot <name>` | save a screenshot (name it by run, place and moment, e.g. `r2_05_shop`) |
| `dump` | write every visible label and button, with its text and position, to the log - use it to read small text and find where to click |
| `scene` | write the current scene, level, gold and HP to the log |
| `skip_dialogue [max]` | tap E / click through dialogue boxes, story stills and reward popups until none is open (default 40 taps). For the conversations that matter (a boss's intro, the ending), read them yourself instead: `key E`, `wait 0.8`, `shot`, repeated - you are judging the writing too |
| `pilot <seconds>` | a simple built-in player plays the current battle for up to that long (keeps its hand, plays cards, attacks, blocks, reads a tip then presses Got it, confirms End Turn). Use it to get through fights; play at least one Primm phase and one castle room **yourself** with clicks and drags to judge the combat |
| `log <text>` | a note in the log |

Debug jumps (what the game's own developer menu does). Say in the report where you jumped.

| Command | Does |
|---|---|
| `dev save <name>` / `dev load <name>` | snapshot the whole game / resume it (works across runs; a run always starts at the title screen, so `dev load` is normally the first line of a script after `wait 2`). A snapshot restores the place and the game state, not an open popup or a dungeon's node map: re-enter a dungeon with `dev travel dungeon` after a load |
| `dev level <n>` / `dev gold <n>` / `dev heal` | silent level set, add gold, full heal |
| `dev travel town` / `capital` | jump to the town (Crosspath) / the Capital's inside |
| `dev travel dungeon <id> [node]` | enter a dungeon at its entrance; `node` = a node number, `-2` = next to the boss. Ids: `D-PC` Primm's Castle (the final dungeon), `D-LAB` The Path-ology Lab (postgame), `S-GALLERY` The Shattered Gallery (postgame, behind the cracked mirror by the castle door) |
| `dev primm <1|2|3>` | the checkpoint between Primm's phases: straight to phase 1, 2 or 3 at the castle's boss node (after a loss, to retry a phase; it grants the same allies' boons a full castle run has at that point) |
| `dev autowin on` / `dev win` | every fight auto-won / end the current fight won. **Not for Primm**: fight him for real (castle rooms may be pilot-ed or auto-won; say which) |

## Starting

The game has snapshots of a level-20 hero for you: `c13cap` (in the Capital), `c13castle` (at the castle), `c13end` (right after Primm
falls: a postgame hero in the town; the ending itself is only seen by beating him) and `c13post` (after the credits, the postgame begun).
Your first script: `wait 4`, `shot q1_01_title`, `dev load c13cap`, `wait 14`, `scene`, `shot q1_02_capital`, `dump`. Walk the Capital like
a player for a while (its districts, people, signs, shops), then go to **Primm's Castle**: walk to its entrance if you can (the map `M` and its
"Point me to..." list help); if after two runs you cannot, `dev load c13castle` or `dev travel dungeon D-PC` and say so. Play the castle's
nodes (pilot most of them; `dev autowin on` is allowed for the castle's rooms after you have played two of them) and **the real Primm fight**:
no `dev win`, `dev autowin` or `dev encounter` for Primm - if autowin is on, turn it off (`dev autowin off`) before his node. If you lose, say
how, `dev heal` and try again (`dev primm <phase>` resumes at the phase you lost; you may `dev level 24` after two losses; say so). After the
credits, keep playing into the postgame for the rest of your time (the Path-ology Lab: `dev travel dungeon D-LAB`; the cracked mirror by the
castle door: walk to it from `c13post` or `dev load c13post` then look for it on the map). If the ending will not come within your time, use
`dev load c13end` and then `c13post` and say so. Use `dev save q<n>` at good points. Walk with `hold W 2` etc.; `M` opens the map, `Escape`
closes the top pop-up or advances the conversation, then opens the pause menu, `E` talks and interacts, `J` is the quest log.

In a battle: "Turn N" counts both players' turns; "Your turn / Enemy's turn" is under it. Primm's first phase starts with a few Village
Militia and a "Setting Up" window (its units do not attack for the first turns; the words stand beside the hourglass icon in the rules
row and in the turn panel). Hand cards show this fight's numbers in green / red when a rule changes them; right-click a card for its
full preview. The battle log button is bottom left.

## What to report (`docs/review/critic_late_nov12/report.md`)

1. **Summary** (one paragraph) and **how you played** (runs, snapshots and jumps used, minutes of game time from the play logs).
2. **Scores**, each with two sentences of why against the old 5 / 4 / 5: Clarity /10, Fun /10, Polish /10, and a line on anything **broken**
   and anything that looks **unfinished or obviously AI-made** (placeholder art, overflowing boxes, template-sounding text, flat 3D stand-ins
   next to painted art).
3. **The Primm fight:** how many tries, how each went (turns, what killed you or him), whether the Militia count and the Setting Up window
   read clearly, whether the three phases felt distinct.
4. **The ending and the credits:** what you read, what landed, what did not; how the postgame was announced and whether you knew where to go next.
5. **Top 10 problems**, most important first (what, where = screenshot names, severity: blocker / major / minor, smallest fix).
6. **Smaller notes** (anything else, including every `SCRIPT ERROR` you found in the game logs, and anything that differs from what the
   HUD or a tip promised).
7. **What worked** (three to five things worth keeping exactly as they are).

Be concrete and fair: a screenshot for every claim, no guessing about causes you cannot see. Screenshots stay in `_screenshots/exported/`;
name them in the report as `<shot>.png`. Those and your scripts are the only files you write.
