# Critic brief - WHAT THE FIRST THREE SITTINGS MISSED, on the release build (Nov 16; read only this file)

You are reviewing a new indie deckbuilder RPG called **The Wayward Path** (Godot 4, Windows) in its **release build**: the exported
game as a player would download it, not the editor. You play it through a scripted driver that injects real keyboard and mouse input
and takes screenshots, so you see exactly what a player sees. **Judge only what you see and do.** Do NOT read anything else in the
project: no `docs/` (except this file), no `CLAUDE.md`, no `.gd` code, no `data/*.json`, no reports, design notes, earlier reviews or
code comments. The only files you may read are this brief, the screenshots and logs your own runs produce, and the scripts you write.
Do not run git. Do not edit any file other than your own scripts and your report.

This PC is slow and low on memory: **run one game process at a time, always in the foreground, and wait for it to finish** (a run that
overlaps another corrupts both; `tasklist | grep -i godot` must print nothing before you start the next). **Every run must be 170
seconds or shorter** (the third argument below); plan the sitting as short runs chained with `dev save` / `dev load`. Every run starts
with about 25 s of loading before the title screen appears. Never run anything in the background.

**You have a budget of 16 runs.** Stop playing when it is spent, or after 75 minutes on the clock, whichever comes first, and write
the report with what you have. A short honest report beats a long late one.

**Your job:** three earlier reviewers ran out of runs before these, so you look at exactly them and nothing else: **(A)** the end of the first cave: the boss **the Cave Warden**, his closing words, the walk out to **Elder Maren** and the town of **Crosspath** (her lines, one shop, the first quests); **(B)** **Maren's memory scenes** with their pictures (the third and the fourth above all); **(C)** losing to **Primm** and the **"Fight Primm again"** choice, then **the ending and the credits**, read beat by beat, and the first minutes after them.

Score **clarity, fun and polish** from 1 to 10. Then list **everything that is broken, confusing, ugly, inconsistent with the story, or
that shows a wrong Path icon** (the two lists below say what the story and the icons must be). Give each item a size: **S** (a small fix:
a text, a number, a position, a missing icon), **M** (a few hours: a screen's layout, a flow), **L** (needs new art or a redesign).

Your play scripts go in `C:\\Dev\\Deckbuilder-rpg\\docs\\review\\play_scripts\\s4_<nn>.txt` (Git Bash: `/c/Dev/Deckbuilder-rpg/...`).
Your report goes to `C:\\Dev\\Deckbuilder-rpg\\docs\\review\\critic_nov16\\s4_report.md` (create the folder; if the write is refused,
put the complete report in your final message). **Either way, put the complete report in your final message too.**

## The story the game must not contradict

Flag any line of dialogue, sign, caption or picture that goes against these:

- The hero is called **the Wanderer**. He was kept for ten years in a cell with **bars on every side** in the Path-ology Lab. His cell
  never has glass (other rooms of the Lab may).
- **Elder Maren** is an old tortoise. She once worked at the castle: she studied the Paths and **tutored the royal children**, the
  little prince among them. She **never made the cell or its bars**. **Her eyes are failing** ("my eyes aren't what they were"), which
  is why she does **not** know who the Wanderer is until the fourth memory. Anything that shows her seeing clearly at a distance,
  recognising him early, or having built the cell is wrong.
- The Wanderer's real name is **Prince Tessar Wayweaver**. Nobody says "Tessar", and no name plate shows it, before the reveal (Maren's
  fourth memory, or Primm in his castle). After the reveal the name plate may change.
- **Primm** ("His Perfection") rules from the Capital and wants everything the same. His emblem is a smiling face; it belongs on the
  regime's own banners only.

## The four Path icons

Each of the four Paths is shown by **one icon everywhere**. Flag any card back, pack, banner, sign, statue, badge, map marker or picture
that shows a Path by anything else.

- **Beefcake:** a gold flexed arm on a red disc. Wrong: a dumbbell, a barbell, a flame.
- **Gourmand:** a white chef's hat on a cream disc with a copper rim. Wrong: a ladle, a fork and knife, a cauldron, a drop, a sun.
- **Refusemancer:** a green leaf inside three rust-orange recycling arrows on a moss-green disc. Wrong: a single maple leaf, a sprout in a tin.
- **Necrocrat:** a pale skull in green ghost-flame on a dark slate disc. Wrong: a rubber stamp, a tombstone, a moon, a quill, skull and crossbones.
- **All four in a ring** read clockwise from the top: arm, chef's hat, leaf, skull. Wrong: a star, a flame, a leaf and a moon.

## Running a play script

```
cd /c/Dev/Deckbuilder-rpg && bash tools/play_exported.sh docs/review/play_scripts/s4_<nn>.txt <run_name> 170
```

Output (all in `_screenshots/exported/`): `<shot>.png` (1600x900 PNGs - open them with the Read tool; **start every shot name with
`s4`** and your run number so nothing is overwritten, e.g. `shot s4_03_05_gate`), `play_<run_name>_play.log` (every command with a
timestamp, and the text that `dump` and `scene` printed) and `play_<run_name>.log` (the game's own output; search it for `SCRIPT ERROR`:
those are bugs worth reporting). Nothing you do is saved to a player's real save slots.

One command per line, `#` comments. **All coordinates are screenshot pixels** (0-1600 across, 0-900 down), exactly as in the PNGs.

| Command | Does |
|---|---|
| `wait <seconds>` | let the game run (dialogue, animations and loading screens need 1-4 s; a zone load can need 8-14 s) |
| `key <Name>` | tap a key: `E`, `Space`, `Escape`, `Enter`, `W`, `A`, `S`, `D`, `B`, `C`, `J`, `M`, `P`, `R`, `T`, `Tab`, `Up`, `Down`, `1` ... |
| `hold <Name>[+<Name>] <seconds>` | hold keys: walking is `hold W 2`, diagonal `hold W+D 1.5` |
| `click <x> <y>` / `rclick <x> <y>` / `move <x> <y>` | left click / right click (a card's full preview) / hover (tooltips; `wait 1` then `shot`) |
| `drag <x1> <y1> <x2> <y2>` | drag and drop (a hand card onto the board) |
| `button <text>` | click the first visible button whose label contains `<text>` (case-sensitive; the log says NOT FOUND if none) |
| `shot <name>` | save a screenshot |
| `dump` | write every visible label and button, with its text and position, to the log: use it to read small text and to find where to click |
| `scene` | write the current scene, level, gold and HP to the log |
| `skip_dialogue [max]` | tap through dialogue boxes, story pictures and reward pop-ups until none is open (default 40 taps). For conversations that matter, read them yourself instead (`key E`, `wait 0.8`, `shot`, or `dump`): you are judging the writing too |
| `pilot <seconds>` | a simple built-in player plays the current battle for up to that long. Use it to get through fights; play at least one fight **yourself** with clicks and drags |
| `log <text>` | a note in the log |

Debug jumps (what the game's own developer menu does). Say in the report where you jumped.

| Command | Does |
|---|---|
| `dev save <name>` / `dev load <name>` | snapshot the whole game / resume it (works across runs; a run always starts at the title screen, so `dev load` is normally the first line of a script after `wait 2`). A snapshot restores the place and the game state, not an open pop-up or a dungeon's room map: re-enter a dungeon with `dev travel dungeon` after a load. **Start your own snapshot names with `s4`** |
| `dev level <n>` / `dev gold <n>` / `dev heal` | set the level, add gold, full heal |
| `dev travel town` / `forest` / `capital` | jump to the town (Crosspath), the starting forest, the Capital's inside |
| `dev travel zone <beefcake|gourmand|refusemancer|necrocrat>` | jump into a Path's zone: beefcake = the Gainlands, gourmand = the Endless Buffet, refusemancer = the Verdant Dump, necrocrat = the D.N.A. |
| `dev travel dungeon <id> [node]` | enter a dungeon at its entrance; `node` = a room number, `-2` = next to the boss. Ids: `D-HOG` The House of Gains (the Gainlands), `D-TTK` The Test Kitchen (the Buffet), `D-ROT` The Rotheart (the Dump), `D-HFA` The Hall of Final Approvals (the D.N.A.), `S-CAP` The Old Service Tunnels (the Capital), `D-PC` Primm's Castle, `D-LAB` The Path-ology Lab (postgame) |
| `dev freed <zone>` / `dev gate <zone>` | mark a Path zone freed / its gatekeeper beaten |
| `dev primm <1|2|3>` | straight to phase 1, 2 or 3 of the final boss at the castle's boss room |
| `dev autowin on` / `off` / `dev win` / `dev lose` | every fight auto-won / end the current fight won / lost |

Keys: walk with `W A S D` (`hold W 2`); `E` talks and interacts; `M` opens the map (it has a "Point me to..." list); `J` the quest log;
`C` the Character page; `B` the Deck Station (in town); `P` the Card Packs page; `T` the Wardrobe; `Escape` closes the top pop-up or
advances a conversation, then opens the pause menu. In a dungeon you move by clicking rooms on a map; a pop-up opens per room.
If you are stuck for more than one run, jump and say so: being stuck is itself a finding.

## Starting

**Part A, about 5 runs.** `wait 4`, `dev load s1_a` (a new hero in the starting forest), `wait 14`, `dev travel dungeon D-TUT -2` (the first cave, next to its boss), `wait 8`, `shot`, `dump`. Click the boss room, read the pop-up, `pilot 100`. If the pilot loses, `dev heal` and try once more; after two losses use `dev win` and say so. Read the Warden's closing words one line at a time (`key E`, `wait 1`, `shot`), take the reward, leave the cave. Outside, read what Elder Maren says at the cave mouth, then follow the goal line into Crosspath and to her home; read every line of hers (watch for her eyes and for what she knows about you). `dev save s4_a` in town. Then one shop (walk in, `key E`, shoot each page) and the quest log (`key J`).

**Part B, about 4 runs.** `dev load midgame_real`, `wait 14`, `dev travel town`, `wait 14`. Open the map (`key M`), `button Point me`, and pick Elder Maren; walk to her and talk. Each freed Path zone gives one memory scene the next time you talk to her: run `dev freed beefcake`, talk to her, read the scene line by line and shoot its picture; then `dev freed gourmand`, `dev freed refusemancer`, `dev freed necrocrat`, talking to her after each. In the pictures look at the crest and banners (the four icons), at the cell (bars or glass), and at when the name Tessar first appears.

**Part C, about 7 runs.** `dev load c13castle`, `wait 14`, `dev heal`, `dev travel dungeon D-PC -2`, `wait 8`, click the boss room and read Primm's opening. In the fight play two turns by hand, then `dev lose`: shoot the defeat screen at once (`wait 1.5`, `shot`, `dump`) and press `button Fight` ("Fight Primm again"); say what it did. Then, in a new run, `dev autowin on` and enter his room again: for this sitting auto-winning Primm is allowed, because the ending is what you are here for. After each phase read what is shown. When the ending starts, turn nothing off and read it beat by beat: `key E`, `wait 1.2`, `shot` (name the shots `s4_end_<nn>`), with `dump` for the text. Look at every picture's banners and crests. Read the credits (their logo at the end) and then play one run of whatever the game offers next.

## The report (`docs/review/critic_nov16/s4_report.md`), short

1. **How you played** (runs, snapshots and jumps used, what you did not reach).
2. **Scores:** Clarity /10, Fun /10, Polish /10, two sentences each.
3. **Findings**, most important first, as a table: what, where (a screenshot name or a log line), kind (broken / confusing / ugly /
   story / wrong icon), size (S / M / L), the smallest fix you can see. Up to 20 rows.
4. **Checked and fine:** say in one line each whether these were right when you saw them: the Cave Warden's closing words (in the dialogue box, with his picture); Maren's eyes and what she knows; the bars of the cell; the name Tessar (when it first appears); the crest in the third and fourth memory pictures; the banners in the ending's pictures; the credits' logo; the "Fight Primm again" choice (shown, default, what it did); the full map (crisp or blurry) and its short names; C closing the Character page.
5. **Every `SCRIPT ERROR` line** from the game logs, with the run.
6. **What worked** (three things to keep exactly as they are).

A screenshot or a log line for every claim; no guessing about causes you cannot see. Screenshots stay in `_screenshots/exported/`;
name them in the report as `<shot>.png`. Those, your scripts and the report are the only files you write.
