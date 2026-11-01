# Critic brief - the late game and ending of "The Wayward Path" (read only this file)

You are reviewing a new indie deckbuilder RPG called **The Wayward Path** (Godot 4, Windows). You play it through a scripted driver
that injects real keyboard and mouse input and takes screenshots, so you see exactly what a player sees. **Judge only what you see
and do.** Do NOT read anything else in either folder below: no `docs/`, no `CLAUDE.md`, no `.gd` code, no `data/*.json`, no reports,
scorecards, balance logs, design notes or code comments. The only files you may read are this brief, the screenshots and logs your
own runs produce, and the scripts you write.

**You play the game from its own folder, `C:\Dev\wp_critic`** (Git Bash: `cd /c/Dev/wp_critic`). Your play scripts go in
`/c/Dev/wp_critic/docs/review/play_scripts/critic6_*.txt`; your runs' screenshots and logs appear under `/c/Dev/wp_critic/_screenshots/play/`.
Your report goes to `/c/Dev/Deckbuilder-rpg/docs/review/fresh_eyes_lategame_oct31n.md`, and the screenshots you cite are copied into
`/c/Dev/Deckbuilder-rpg/docs/review/fresh_eyes_lategame_oct31n/` - those are the only files you write outside `wp_critic`. Never start
the game from `/c/Dev/Deckbuilder-rpg`. Do not run git. Do not edit any other file in either folder.

This PC is slow and low on memory: **run one game process at a time, always in the foreground, and wait for it to finish** (a run that
overlaps another corrupts both). Each Bash call can last at most 10 minutes, so give every run a limit of 480 seconds or less and a Bash
timeout of 600000 ms. A script that reaches its limit stops and the game closes; plan long sessions as several runs chained with
`dev save` / `dev load` (below). The very first run may spend about two minutes starting up.

## Running a play script

```
cd /c/Dev/wp_critic && bash tools/play.sh docs/review/play_scripts/critic6_<name>.txt <run_name> 480
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
| `dev save <name>` / `dev load <name>` | snapshot the whole game / resume it (works across runs; a run always starts at the title screen, so `dev load` is normally the first line of a script after `wait 2`). A snapshot restores the place and the game state, not an open popup or a dungeon's node map: re-enter a dungeon with `dev travel dungeon` after a load |
| `dev level <n>` / `dev gold <n>` / `dev heal` | silent level set, add gold, full heal |
| `dev travel town` / `forest` / `capital` / `arena` | jump to the town (Crosspath), the starting forest, the Capital's inside, the arena |
| `dev travel zone <beefcake|gourmand|refusemancer|necrocrat>` | jump into a Path's zone (its gatekeeper ignored): beefcake = the Gainlands, necrocrat = the D.N.A., gourmand = the Endless Buffet, refusemancer = the Verdant Dump |
| `dev travel dungeon <id> [node]` | enter a dungeon at its entrance; `node` = a node number, `-2` = next to the boss. Ids: `D-HFA` The Hall of Final Approvals (the D.N.A.'s main dungeon), `D-TTK` The Test Kitchen (the Buffet's), `D-ROT` The Rotheart (the Dump's), `D-HOG` The House of Gains (the Gainlands'), `D-PC` Primm's Castle (the final dungeon, in the Capital), `S-NECRO` The Waiting Room of Eternity, `S-GOUR` Omakase, `S-REF` The Trash Panda Throne, `S-CAP` The Old Service Tunnels, `S-PASTE` The Paste Works, `S-TOWN` The Forgotten Vault, `S-IRON` The Iron Cave, `D-LAB` The Path-ology Lab (postgame) |
| `dev encounters <query>` / `dev encounter <query>` | list / start a fight from the game's catalog by name or group (`boss`, `zone:necrocrat`, `capital`, `lieutenant`, a boss's name such as `Primm`); starting one this way pays nothing and returns to town after |
| `dev freed <zone>` / `dev gate <zone>` | mark a Path zone freed / its gatekeeper beaten (unlocks later content) |
| `dev card <id>` / `dev gear <id>` / `dev item <id>` / `dev slots` / `dev packs <id> <n>` | give things (ids are what the game shows in lower snake case; mostly not needed) |
| `dev autowin on` / `dev win` / `dev lose` | every fight auto-won / end the current fight won or lost (to sample later content quickly) |

## Where you start

A late-game snapshot exists: **`dev load lategame_real`** - a real save made by an automated player that played the story so far: the
Beefcake Path, all four Path zones freed (the Gainlands, the D.N.A., the Endless Buffet, the Verdant Dump) with their dungeons cleared,
standing in Crosspath (the hub town) with a level-appropriate built deck, gear, items, gold and a few card packs. The road to **the
Capital** is the story's next step (the Undercroft under Crosspath leads there). The player travelled by jumps, so the maps show only the
spots it stood on. Use it as the first line of every script after `wait 2`:

```
wait 2
dev load lategame_real
wait 12
shot 01_town
dump
```

The title screen shows Continue / New Game / Load Game / Settings / Quit because this PC has the developer's saves. NEVER press
"Start over here", "Delete" or "Copy" on the slot screens (slots 1-2 are the developer's).

## Your brief

You are a seasoned games critic and UX researcher reviewing the **late game and the ending** of a new indie deckbuilder RPG. From the
snapshot, play (via screenshots and the tools above):

1. **Getting to the Capital**: from Crosspath, find the way on (the quest log J, the map M with its "Where to?" list, the Undercroft) -
   is the final act's start clear?
2. **The Capital** (walk there, or `dev travel capital`): walk its districts, talk to people, fight at least one lieutenant (`dev encounters
   lieutenant` lists them) and one roaming enemy; the Capital's broken services and its own rules (its HP, its debuffs).
3. **Primm's Castle** (`dev travel dungeon D-PC`): play it through to **Primm** and all three of his phases (fight some yourself, `pilot`
   others, `dev autowin on` if you must - say so), then **the ending** to the credits. Read the final story scenes yourself (`key E`,
   `wait 0.8`, `shot`) - the ending's writing is part of the review.
4. One Capital side dungeon (`S-CAP` The Old Service Tunnels or `S-PASTE` The Paste Works).

Skip whatever the time budget does not allow (say what you skipped); depth on 2-3 matters more than breadth.

## Controls a player is told about (keyboard; a gamepad is also supported - Settings > Controls)

WASD / arrows move. E / Space / click interact, talk, enter, advance dialogue, confirm popups. Esc pause menu (also closes most screens).
B deck builder, C character screen, J quest log, M map, P card packs, T wardrobe, [ ] switch the tracked quest, Z / X turn the camera,
V camera angle, F camera zoom, Q dismount. In battle: drag a card from the hand onto the board (or click it), click units to attack / block,
Space advances the phase (To Combat / Attack / End Turn), R in a dungeon shows its rules. F8 "report a problem" dialog. The town's HUD
has a Menu button (Character, Deck, Quests, Packs, Wardrobe, Glossary, Feats, Settings).

Compare honestly to well-loved games in the space (Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath Traveler,
Pokemon TCG Pocket) on: clarity (do I always know what to do and why I won or lost; do new rules, keywords, zone effects and boss
events explain themselves), pacing and friction (walking, menus, waiting, repetition, dungeon length), combat depth and feel at this
level (are the fights interesting, do bosses feel like bosses, do the scripted events read), deck-building satisfaction (does the Deck
Station make a mid-game collection fun to build with; do packs and shops feel worth it), reward rhythm (gold, XP, cards, gear, level-ups),
exploration and world (do the three zones feel different, are landmarks and dungeon entrances findable, do the maps help), story and
humour landing (zone NPCs, bosses, the Capital), visual cohesion and readability (zones, dungeon maps, boards, the HUD), UI/UX consistency,
audio (what the screenshots and logs let you infer; say when you cannot judge), performance (loading waits, stutter you can see in the
logs' timestamps), and bugs. Be specific and blunt - cite screenshots (by file name) and exact moments. Score each area 1-10 against
those games (not against an earlier version of this game). End with the **15 biggest problems** ranked by impact on a player's
enjoyment and retention in the the late game and ending, each with a concrete suggested fix.

Practicalities: budget about 70 minutes of wall clock (hard stop at 80: write the report with what you have). Plan each run as a script of 30-80 lines, read the screenshots and `play.log`
after every run, then write the next script from what you saw (positions from `dump`). Take many screenshots - every screen, every
tooltip you hover, every popup - and copy the ones you cite into `/c/Dev/Deckbuilder-rpg/docs/review/fresh_eyes_lategame_oct31n/` (keep the same file names,
prefixed by the run name). If a run goes wrong (a NOT FOUND button, a stuck state), that is itself a finding; recover with `dev` jumps
and say so. Write the report to `/c/Dev/Deckbuilder-rpg/docs/review/fresh_eyes_lategame_oct31n.md` in Markdown with the sections: Summary, How I played (runs,
places, time), Scores (a table), Findings per area, Top 15 problems (ranked, each: what, where (screenshot), why it matters, fix). Your
final reply is a short summary of the scores and the top 5; the report file is the deliverable.
