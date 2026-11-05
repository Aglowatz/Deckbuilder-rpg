# Critic brief - a new save of "The Wayward Path" to its first dungeon (read only this file)

You are reviewing a new indie deckbuilder RPG called **The Wayward Path** (Godot 4, Windows). You play it through a scripted driver
that injects real keyboard and mouse input and takes screenshots, so you see exactly what a player sees. **Judge only what you see
and do.** Do NOT read anything else in either folder below: no `docs/`, no `CLAUDE.md`, no `.gd` code, no `data/*.json`, no reports,
scorecards, balance logs, design notes or code comments. The only files you may read are this brief, the screenshots and logs your
own runs produce, and the scripts you write.

**You play the game from its own folder, `C:\Dev\wp_critic`** (Git Bash: `cd /c/Dev/wp_critic`). Your play scripts go in
`/c/Dev/wp_critic/docs/review/play_scripts/critic_nov5_*.txt`; your runs' screenshots and logs appear under `/c/Dev/wp_critic/_screenshots/play/`.
Your report goes to `/c/Dev/Deckbuilder-rpg/docs/review/fresh_eyes_early_nov5.md`, and the screenshots you cite are copied into
`/c/Dev/Deckbuilder-rpg/docs/review/fresh_eyes_early_nov5/` - those are the only files you write outside `wp_critic`. Never start
the game from `/c/Dev/Deckbuilder-rpg`. Do not run git. Do not edit any other file in either folder.

This PC is slow and low on memory: **run one game process at a time, always in the foreground, and wait for it to finish** (a run that
overlaps another corrupts both). Each Bash call can last at most 10 minutes, so give every run a limit of 480 seconds or less and a Bash
timeout of 600000 ms. A script that reaches its limit stops and the game closes; plan long sessions as several runs chained with
`dev save` / `dev load` (below). The very first run may spend about two minutes starting up.

## Running a play script

```
cd /c/Dev/wp_critic && bash tools/play.sh docs/review/play_scripts/critic_nov5_<name>.txt <run_name> 480
```

Output: `_screenshots/play/<run_name>/<shot>.png` (1600x900 PNGs - open them with the Read tool), `play.log` (every command with a
timestamp, the text that `dump` and `scene` printed) and `stdout.log` (the game's own output; search it for `SCRIPT ERROR` - those
are bugs worth reporting). Nothing you do is ever saved to the player's real save slots.

One command per line, `#` comments. **All coordinates are screenshot pixels** (0-1600 across, 0-900 down), exactly as you see them in
the PNGs.

| Command | Does |
|---|---|
| `wait <seconds>` | let the game run (dialogue typewriters, animations, loading screens need 1-4 s; a zone load can need 8 s) |
| `key <Name>` | tap a key: `E`, `Space`, `Escape`, `Enter`, `W`, `A`, `S`, `D`, `B`, `C`, `J`, `M`, `P`, `T`, `R`, `Tab`, `Up`, `Down`, `1`, `F10` ... |
| `hold <Name>[+<Name>] <seconds>` | hold keys: walking is `hold W 2`, diagonal `hold W+D 1.5` |
| `click <x> <y>` / `rclick <x> <y>` / `move <x> <y>` | left click / right click / hover the mouse there (hover shows tooltips and card previews; `wait 1` then `shot`) |
| `drag <x1> <y1> <x2> <y2>` | drag and drop (a hand card onto the board) |
| `button <text>` | click the first visible button whose label contains `<text>` (case-sensitive; `play.log` says NOT FOUND if none) |
| `shot <name>` | save a screenshot (name it by place, moment and number, e.g. `dna_03_office`) |
| `dump` | write every visible label and button, with its text and position, to `play.log` - use it to read small text and find where to click |
| `scene` | write the current scene, level, gold and HP to `play.log` |
| `skip_dialogue [max]` | tap E / click through dialogue boxes, story stills and reward popups until none is open (default 40 taps). For the conversations that matter (a zone's first NPC, a boss's intro), read them yourself instead: `key E`, `wait 0.8`, `shot`, repeated - you are judging the writing too |
| `pilot <seconds>` | a simple built-in player plays the current battle for up to that long (keeps its hand, plays cards, attacks, blocks, reads a tip then presses Got it, confirms End Turn). Use it to get through fights; play at least a few fights **yourself** with clicks and drags to judge the combat |
| `log <text>` | a note in `play.log` |

Debug jumps (they do what the in-game developer menu on F10 does; prefer these):

| Command | Does |
|---|---|
| `dev newgame` | a fresh game from the opening, as New Game would start it (no save slot is touched) |
| `dev save <name>` / `dev load <name>` | snapshot the whole game / resume it (works across runs; a run always starts at the title screen, so `dev load` is normally the first line of a script after `wait 2`). A snapshot restores the place and the game state, not an open popup or a dungeon's node map: re-enter a dungeon with `dev travel dungeon` after a load |
| `dev level <n>` / `dev gold <n>` / `dev heal` | silent level set, add gold, full heal |
| `dev travel town` / `forest` / `capital` / `arena` | jump to the town (Crosspath), the starting forest, the Capital's inside, the arena |
| `dev travel zone <beefcake|gourmand|refusemancer|necrocrat>` | jump into a Path's zone (its gatekeeper ignored): beefcake = the Gainlands, necrocrat = the D.N.A., gourmand = the Endless Buffet, refusemancer = the Verdant Dump |
| `dev travel dungeon <id> [node]` | enter a dungeon at its entrance; `node` = a node number, `-2` = next to the boss. Ids: `D-HFA` The Hall of Final Approvals (the D.N.A.'s main dungeon), `D-TTK` The Test Kitchen (the Buffet's), `D-ROT` The Rotheart (the Dump's), `D-HOG` The House of Gains (the Gainlands'), `D-PC` Primm's Castle (the final dungeon, in the Capital), `S-NECRO` The Waiting Room of Eternity, `S-GOUR` Omakase, `S-REF` The Trash Panda Throne, `S-CAP` The Old Service Tunnels, `S-PASTE` The Paste Works, `S-TOWN` The Forgotten Vault, `S-IRON` The Iron Cave, `D-LAB` The Path-ology Lab (postgame) |
| `dev encounters <query>` / `dev encounter <query>` | list / start a fight from the game's catalog by name or group (`boss`, `zone:necrocrat`, `capital`, `lieutenant`, a boss's name such as `Primm`); starting one this way pays nothing and returns to town after |
| `dev freed <zone>` / `dev gate <zone>` | mark a Path zone freed / its gatekeeper beaten (unlocks later content) |
| `dev card <id>` / `dev gear <id>` / `dev item <id>` / `dev slots` / `dev packs <id> <n>` | give things (ids are what the game shows in lower snake case; mostly not needed) |
| `dev autowin on` / `dev win` / `dev lose` | every fight auto-won / end the current fight won or lost (to sample later content quickly) |

## Starting a fresh game (do this at the start of every Path)

The title screen shows Continue / Load Game because this PC has the developer's saves; a brand-new player would see only New Game.
Look at the title screen, then start a fresh game with the driver's own command (it never touches a save slot):

```
wait 2
shot 01_title
dev newgame
wait 6
```

Never use the title's New Game / slot screen (every slot holds the developer's saves).

You wake in a forest; the wake-up lines lead into a conversation and then a **Path choice** screen with four columns:
Beefcake (click about `415 400`), Gourmand (`670 400`), Refusemancer (`930 400`), Necrocrat (`1185 400`); `button More` opens a longer
description, `button Begin` confirms. After that you are in the forest with the Deck button top right. The cave (the tutorial dungeon) is
through the ruined arch to the north-east of the bedroll; walk with `hold`, interact with `key E` when a prompt appears (look at the
screenshots to see prompts), or use `dev travel dungeon D-TUT` if you cannot find the way (note that in your report). Dungeons are
node maps: click a node to move there, fights start when you reach an enemy node.

## Controls a player is told about (keyboard; a gamepad is also supported - Settings > Controls)

WASD / arrows move. E / Space / click interact, talk, enter, advance dialogue, confirm popups. Esc pause menu (also closes most screens).
B deck builder, C character screen, J quest log, M map, P card packs, T wardrobe, [ ] switch the tracked quest, Z / X turn the camera,
V camera angle, F camera zoom, Q dismount. In battle: drag a card from the hand onto the board (or click it), click units to attack / block,
Space advances the phase (To Combat / Attack / End Turn), R in a dungeon shows its rules. F8 "report a problem" dialog. The town's HUD
has a Menu button (Character, Deck, Quests, Packs, Wardrobe, Glossary, Feats, Settings).

## Your brief

You are a seasoned games critic and UX researcher reviewing a new indie deckbuilder RPG for the first time. Play ONE new save, as a
brand-new player would, through: the opening and the Path choice (pick the Path you like; say which), the tutorial cave, Crosspath and
Tilly's item lesson, Elder Maren's "Meet the Merchants" errand, the first shop visits, the road to your Path's zone, that zone itself, and
its first dungeon (dungeons hide unexplored nodes under fog and some nodes stay hidden until you reach them; judge how that reads).

**Rules for this review: no `dev win`, no `dev autowin`, no `dev level`, no `dev gold`.** Play the fights for real (yourself with clicks and
drags for at least the tutorial duels and two later fights; `pilot` the rest). You may use `dev save` / `dev load` to chain runs and
`dev travel` ONLY to recover from a stuck state (say so in the report when you do). If you lose a fight, that is data: say what killed you.

Score 1-10, against well-loved games in the space (Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath Traveler, Pokemon TCG
Pocket): **fun**, **clarity** (do I always know what to do and why I won or lost), **difficulty** (fair? too hard? too easy?) and **text
quality** (does the dialogue read like real people; is it clear; does the humour land). Note the gold you had at each shop and what you
could afford. Be specific and blunt - cite screenshots (by file name) and exact moments. End with your **top 10 issues**, ranked by impact on
a new player's enjoyment, each with a concrete suggested fix.

Practicalities: budget about 75 minutes of wall clock (hard stop at 90: write the report with what you have). Plan each run as a script of
30-80 lines, read the screenshots and `play.log` after every run, then write the next script from what you saw (positions from `dump`).
The disk is nearly full: copy only the screenshots you cite into `/c/Dev/Deckbuilder-rpg/docs/review/fresh_eyes_early_nov5/` (keep the
file names, prefixed by the run name). If a run goes wrong (a NOT FOUND button, a stuck state), that is itself a finding; recover and say so.
Write the report to `/c/Dev/Deckbuilder-rpg/docs/review/fresh_eyes_early_nov5.md` in Markdown with the sections: Summary, How I played
(runs, Path, time, gold at each shop), Scores (fun, clarity, difficulty, text quality), Findings, Top 10 issues (ranked, each: what, where
(screenshot), why it matters, fix). Your final reply is a short summary of the scores and the top 5; the report file is the deliverable.
