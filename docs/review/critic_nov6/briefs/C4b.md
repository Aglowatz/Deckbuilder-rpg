# Critic brief C4b - the finale (read only this file)

You are reviewing a new indie deckbuilder RPG called **The Wayward Path** (Godot 4, Windows). You play it through a scripted driver
that injects real keyboard and mouse input and takes screenshots, so you see exactly what a player sees. **Judge only what you see
and do.** Do NOT read anything else in either folder below: no `docs/`, no `CLAUDE.md`, no `.gd` code, no `data/*.json`, no reports,
scorecards, balance logs, design notes, earlier reviews or code comments. The only files you may read are this brief, the screenshots
and logs your own runs produce, and the scripts you write.

**You play the game from its own folder, `C:\Dev\wp_critic`** (Git Bash: `cd /c/Dev/wp_critic`). Your play scripts go in
`/c/Dev/wp_critic/docs/review/play_scripts/critic_nov6_C4b_*.txt`; your runs' screenshots and logs appear under `/c/Dev/wp_critic/_screenshots/play/`.
Your report goes to `/c/Dev/Deckbuilder-rpg/docs/review/critic_nov6/C4b.md`, and the screenshots you cite are copied into
`/c/Dev/Deckbuilder-rpg/docs/review/critic_nov6/C4b/` (keep the file names, prefixed by the run name) - those are the only files you
write outside `wp_critic`. Never start the game from `/c/Dev/Deckbuilder-rpg`. Do not run git. Do not edit any other file in either folder.

This PC is slow and low on memory: **run one game process at a time, always in the foreground, and wait for it to finish** (a run that
overlaps another corrupts both). Each Bash call can last at most 10 minutes, so give every run a limit of 480 seconds or less and a Bash
timeout of 600000 ms. A script that reaches its limit stops and the game closes; plan long sessions as several runs chained with
`dev save` / `dev load` (below). The very first run may spend about two minutes starting up.

## Running a play script

```
cd /c/Dev/wp_critic && bash tools/play.sh docs/review/play_scripts/critic_nov6_C4b_<name>.txt <run_name> 480
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
| `perf` | write the game process's memory (working set, static, video), FPS and object counts to `play.log` |
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


## Controls a player is told about (keyboard; a gamepad is also supported - Settings > Controls)

WASD / arrows move. E / Space / click interact, talk, enter, advance dialogue, confirm popups. Esc pause menu (also closes most screens).
B deck builder, C character screen, J quest log, M map, P card packs, T wardrobe, [ ] switch the tracked quest, Z / X turn the camera,
V camera angle, F camera zoom, Q dismount. In battle: drag a card from the hand onto the board (or click it), click units to attack / block,
Space advances the phase (To Combat / Attack / End Turn), R in a dungeon shows its rules. F8 "report a problem" dialog. The town's HUD
has a Menu button (Character, Deck, Quests, Packs, Wardrobe, Glossary, Feats, Settings).


## Your brief: the finale

You are a seasoned games critic and UX researcher. You pick up a save at the very end: a **Beefcake** at level 20 who has freed all four
zones, reached **the Capital** and passed its gate exam. Primm's Castle, the final dungeon, is ahead. Start every session from:

```
wait 2
dev load c4_approved
wait 10
shot 01_start
```

Play by hand:

1. **Primm's Castle** (walk in if you can find it; otherwise `dev travel dungeon D-PC`), node by node, to its end. Look for **the Crease**
   (a hidden part of the Capital the story leads you to) and say whether anything pointed you to it.
2. **Primm's real fight**, the final boss, including its staging in **the Model Room** - play this fight yourself with clicks and drags,
   all the way, and judge whether it feels like a finale.
3. **The ending and the credits** - read them; judge whether the ending pays off the story.

**Rules: the only `dev` commands you may use are `dev save` and `dev load`** (to chain runs; a snapshot does not keep a dungeon in progress,
so after a load re-enter with `dev travel dungeon D-PC`, and add a node number - `dev travel dungeon D-PC <n>` - to resume near the node you
had reached; `-2` puts you next to the boss. Say in the report how often you did this). No `dev win`, `dev autowin`, `dev level` or `dev
gold`. Use `pilot` for the castle's ordinary fights if time is short, but **play Primm yourself**. If you lose Primm, try again at least
once with a changed deck or plan, and say what beat you.

Budget about 90 minutes of wall clock (hard stop at 110: write the report with what you have). **Reach Primm within the first 45 minutes**
(use the node jump if the castle eats your time) - the finale matters most. Plan each run as a script of 30-80 lines, read the screenshots
and `play.log` after every run, then write the next script from what you saw (positions from `dump`). If a run goes wrong (a NOT FOUND
button, a stuck state), that is itself a finding; recover and say so.

## Scoring and the report

Score each out of 10, against well-loved games in the space (Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath
Traveler, Pokemon TCG Pocket): **fun**, **clarity** (do I always know what to do and why I won or lost), **difficulty** (10 = perfectly
judged; say whether a low score means too hard or too easy), **text** (does the dialogue read like real people; is it clear; does the
humour land) and **look** (visual cohesion, readability, art that fits).

Write the report in Markdown with exactly these sections:

1. **Summary** - one paragraph, then a few lines on how you played (runs, Path, time spent, gold at each shop and what you could afford,
   any `dev` command you used and why).
2. **Scores** - a table: fun, clarity, difficulty, text, look (out of 10), each with one line of reasoning.
3. **Findings** - a numbered list. Each finding: what happened, **where** (a screenshot file name you copied, or a quoted line of
   text), **severity** (blocker = stops play / major = a real player is confused, frustrated or bored / minor = polish), and a concrete
   **suggested fix**. Rank them by how much they hurt a real player, worst first. Bugs, script errors in `stdout.log` and stuck states
   are findings too.
4. **What's great, don't touch** - what works and must survive any changes.

Be specific and blunt. Your final reply is a short summary: the scores and the top 5 findings. The report file is the deliverable.
