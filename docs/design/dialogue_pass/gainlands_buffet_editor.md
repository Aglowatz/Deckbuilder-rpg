# Dialogue pass Oct 19: gainlands_buffet, editor review

Editor pass over `data/story/gainlands_story.tres` and `data/story/gourmand_story.tres`. Writer's report: `gainlands_buffet.md`.
OLD = `git show pre-overnight-oct19:<path>`; NEW = the writer's version (before this pass); FINAL = after this pass.
Scores (1-5): **C** in character, **F** funny (fit, not volume), **B** story beat landed, **R** brevity, **Q** clarity of what to do next.
A conversation's score is the minimum of the five. Godot was not run. I checked the edits with a node script: the key counts match
(261 / 267 lines with keys, same as the old files), placeholders, tags and tokens are unchanged by this pass, and no string in either
file is now over 240 characters.

## Scan results

| Check | Found | Fixed |
|---|---|---|
| Boxes over 240 characters | gainlands `hud.objective` (254), gainlands `ui.main.body` (319), gourmand `ui.main.body` (316) | All three cut to 203-215 characters, with the mechanics info kept (HP carries in, where you heal, who to beat) |
| Banned old names (canon.md) | none in text values (`npc.brenda.*`, `npc.tony.*`, `npc.dolcetta.*`, `freed_npc.heartlift` survive only as keys) | - |
| `Gus` outside "Foreman Gus" (canon: allowed only in that phrase) | `npc.gus.intro` and `npc.gus.intro.freed` ("Gus. Foreman of the wheels."), `sign.heal_tub` ("Gus drank the water") | Now "Foreman Gus. I run the wheels.", "Foreman Gus. Still on the wheels.", "Foreman Gus drank the water" |
| Literal "Primm" in text | none (`{villain}` / `{capital}` used) | - |
| "Elowen", umlaut "Doppelgänger" | none | - |
| Real brand names | none ("Spandex" is a generic fabric word; the infomercial and TV parodies are invented) | - |
| Mean-spirited jokes | none. The old `freed_npc.heartlift` "Do not look at my legs" and the old freed poster "(The rest of him is also strong. Look at him.)" were already gone in NEW | - |
| Shared catchphrases | Benchley's new "FRESH LEGS!" repeated Gus's "You. Fresh legs." (`quest.gain_power.offer`); Basil's new "Oh! A customer." repeated Tarragon's "Oh! A customer! A helper!" in the same hub | Benchley now "NEW RECRUIT!"; Basil now opens with a whispered "Psst. Hello." |

## The Gainlands (`gainlands_story.tres`)

| # | Conversation (key group) | Old min (C/F/B/R/Q) | New min (C/F/B/R/Q) | Final min | Final C/F/B/R/Q | What I changed |
|---|---|---|---|---|---|---|
| G1 | Old Man Mountain: `npc.brenda.intro`, `.return` | 3 (3/3/3/3/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - (the trailing-off voice, Clench named as star pupil, C6 set-up all land) |
| G2 | Old Man Mountain freed: `npc.brenda.intro.freed`, `.return.freed` | 3 (3/3/5/4/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| G3 | `fx.wake` | 3 (3/3/4/4/4) | 4 (5/4/4/5/4) | 4 | 5/4/4/5/4 | - |
| G4 | `quest.gain_spot_me.*` | 3 (3/3/4/4/4) | 4 (5/4/4/4/5) | 4 | 5/4/4/4/5 | - |
| G5 | Foreman Gus: `npc.gus.intro`, `.return` | 3 (4/4/3/4/4) | 4 (4/4/5/4/4) | 4 | 5/4/5/4/4 | "Gus." -> "Foreman Gus. I run the wheels." (canon rule for the name) |
| G6 | Gus freed: `npc.gus.intro.freed`, `.return.freed` | 3 (4/3/4/5/4) | 4 (4/4/4/5/4) | 4 | 4/4/4/5/4 | "Foreman Gus. Still on the wheels." (canon rule) |
| G7 | `quest.gain_power.*` | 2 (2/3/4/4/2) | 4 (5/4/4/4/5) | 4 | 5/4/4/4/5 | - |
| G8 | Coach Brutus Benchley: `npc.tony.intro`, `.return` | 2 (2/2/4/4/4) | 4 (4/4/4/4/4) | 4 | 5/4/4/4/4 | "FRESH LEGS!" -> "NEW RECRUIT!" (it was Gus's phrase) |
| G9 | Benchley freed: `npc.tony.intro.freed`, `.return.freed` | 3 (3/3/4/5/4) | 4 (5/4/4/5/4) | 4 | 5/4/4/5/4 | - |
| G10 | `quest.gain_lanes.*` | 3 (3/3/4/4/4) | 4 (5/4/4/4/5) | 4 | 5/4/4/4/5 | - |
| G11 | Professor Pump: `npc.quiz.*`, `quiz.*` | 4 (4/4/4/4/4) | 4 (5/4/4/4/4) | 4 | 5/4/4/4/4 | - |
| G12 | Chet Thunderabs: `npc.minigame.*`, `reps.*` | 4 (4/4/4/4/4) | 4 (5/5/4/4/4) | 4 | 5/5/4/4/4 | - (8 boxes; see the list at the end) |
| G13 | Gary: `npc.gary.*`, `fx.spot_done`, `fx.spot_again` | 4 (4/4/4/4/4) | 4 (5/4/4/4/4) | 4 | 5/4/4/4/4 | - |
| G14 | Throwers and rippers: `travel.*` | 2 (2/4/4/4/3) | 4 (4/4/4/5/4) | 4 | 4/4/4/5/4 | - (pronoun fix was the writer's) |
| G15 | Grid puzzle: `wheel.*` | 4 (4/4/4/4/5) | 4 (4/4/4/4/5) | 4 | 4/4/4/4/5 | - |
| G16 | Hub effects: `fx.*` (tub, shakes, mirror, fall, wheel) | 4 (4/4/4/5/4) | 4 (4/4/4/5/4) | 4 | 4/4/4/5/4 | - |
| G17 | Zone signs: `sign.*` | 4 (4/4/4/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | `sign.heal_tub`: "Foreman Gus drank the water" (canon rule) |
| G18 | Freed signs: `sign.*.freed`, `ruler.statue.freed` | 3 (4/4/3/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | - |
| G19 | House of Gains nodes: `dungeon.hg_*.title/.blurb`, `hg_gates.before`, `hg_warden.after` | 4 (4/4/4/4/4) | 4 (4/4/5/4/4) | 4 | 4/4/5/4/4 | - (Quota's stopwatch lands) |
| G20 | `event.hg_descent.*` | 4 (4/4/4/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | - |
| G21 | The rescue: `event.hg_rescue.*`, `cutscene.rescue.*` | 3 (3/4/4/3/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| G22 | `dungeon.hg_stretch.after` | 4 (4/4/4/5/4) | 4 (5/4/4/5/4) | 4 | 5/4/4/5/4 | - |
| G23 | `event.hg_trophy_hall.*` | 4 (4/4/4/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | - |
| G24 | Boss with Flex: `dungeon.hg_boss.before/.after`, `cutscene.flex.*` | 3 (4/4/3/3/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - (C1 quote now really in `cutscene.flex.3`; 230-char box split) |
| G25 | Boss alone: `dungeon.hg_boss.before_alone/.after_alone` | 3 (3/4/4/3/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| G26 | `freed_npc.heartlift` (Flex freed) | 3 (3/4/4/3/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| G27 | Enemies, statue, effect flavour: `enemy.*`, `ruler.statue`, `effect.*` | 4 (4/4/4/5/4) | 4 (4/4/4/5/4) | 4 | 4/4/4/5/4 | - |
| G28 | HUD and panels: `hud.objective*`, `ui.*` | 3 (4/4/4/3/5) | 3 (4/4/4/3/5) | 4 | 4/4/4/4/5 | **Rewrote** `hud.objective` (254 -> 215) and `ui.main.body` (319 -> 206) |
| G29 | Quiz questions (`quiz_questions`) | 4 (4/4/4/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | - (answers still findable: "Bare hands" in Rita's intro, "never skip leg day" in Old Man Mountain's) |

## The Endless Buffet (`gourmand_story.tres`)

| # | Conversation (key group) | Old min (C/F/B/R/Q) | New min (C/F/B/R/Q) | Final min | Final C/F/B/R/Q | What I changed |
|---|---|---|---|---|---|---|
| B1 | Basil: `npc.odalys.intro`, `.return` | 3 (3/3/4/3/4) | 3 (3/4/5/4/4) | 4 | 5/4/5/4/4 | **Rewrote** the opener: "Oh! A customer." (Tarragon's line in the same hub) -> "Psst. Hello." (her whisper) |
| B2 | Basil freed: `npc.odalys.intro.freed`, `.return.freed` | 2 (2/4/5/4/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| B3 | `fx.wake` | 3 (3/3/4/4/4) | 4 (5/4/4/4/4) | 4 | 5/4/4/4/4 | - |
| B4 | `quest.buf_mend.*`, `npc.old_meatloaf.*` | 3 (3/3/4/4/3) | 4 (5/4/4/4/5) | 4 | 5/4/4/4/5 | - |
| B5 | Sous-Chef Tarragon: `npc.tarragon.intro`, `.return` | 3 (4/4/3/3/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| B6 | Tarragon freed | 4 (4/4/4/5/4) | 4 (4/4/4/5/4) | 4 | 4/4/4/5/4 | - |
| B7 | `quest.buf_pantry.*` | 3 (4/3/4/3/3) | 4 (5/4/4/4/5) | 4 | 5/4/4/4/5 | - |
| B8 | Madame Mirepoix: `npc.dolcetta.intro`, `.return` | 2 (2/3/4/3/4) | 4 (5/4/4/4/4) | 4 | 5/4/4/4/4 | - |
| B9 | Mirepoix freed | 2 (2/3/4/4/4) | 4 (5/4/4/5/4) | 4 | 5/4/4/5/4 | - |
| B10 | `quest.buf_pie.*` | 3 (3/4/4/4/3) | 4 (5/4/4/4/5) | 4 | 5/4/4/4/5 | - |
| B11 | Professor Pate: `npc.quiz.*`, `quiz.*` | 4 (4/4/4/4/4) | 4 (5/4/4/4/4) | 4 | 5/4/4/4/4 | - |
| B12 | Chef Flambe Fontaine: `npc.minigame.*`, `order.*` | 3 (4/4/4/3/4) | 3 (4/4/4/3/4) | 4 | 4/4/4/4/4 | **Rewrote** boxes 1-2 (about 200 / 170 -> 162 / 131 characters: one welcome, no repeated host intro, the years became "Seven seasons!"). Still 9 boxes; see the list |
| B13 | Golem gates: `gate.*` | 4 (4/4/4/4/4) | 4 (5/4/4/4/5) | 4 | 5/4/4/4/5 | - |
| B14 | Hub effects and fortunes: `fx.*`, `fortune.hints` | 4 (4/4/4/5/4) | 4 (4/4/4/5/4) | 4 | 4/4/4/5/4 | - |
| B15 | Mystery Stew: `recipe.*` | 4 (4/4/4/4/5) | 4 (4/4/4/4/5) | 4 | 4/4/4/4/5 | - |
| B16 | Zone signs: `sign.*` | 3 (4/4/3/4/4) | 4 (4/4/5/4/4) | 4 | 4/4/5/4/4 | - (the inspector's note no longer gives the twist away; Crumb's seal on `sign.innovation`) |
| B17 | Freed signs: `sign.*.freed`, `ruler.statue.freed` | 4 (4/4/4/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | - |
| B18 | Test Kitchen nodes: `dungeon.tk_*` (dock, canteen, cold, vats) | 4 (4/4/4/4/4) | 4 (4/4/5/4/4) | 4 | 4/4/5/4/4 | - (the humming freezer set-up lands) |
| B19 | `event.tk_cannon_bay.*` | 4 (4/4/4/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | - |
| B20 | `event.tk_whistleblower.*` | 2 (2/4/3/4/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| B21 | The reveal: `dungeon.tk_boss.before/.after`, `cutscene.reveal.*` | 2 (2/3/3/4/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| B22 | Dinner: `cutscene.wonder.*` | 2 (4/4/4/2/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - (the 300-character box split into three) |
| B23 | `freed_npc.grandchef` | 3 (3/4/4/4/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| B24 | `freed_npc.escoffina` | 4 (4/4/4/4/4) | 4 (5/4/5/4/4) | 4 | 5/4/5/4/4 | - |
| B25 | Enemies, statue, effect flavour | 4 (4/4/4/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | - |
| B26 | HUD and panels: `hud.objective*`, `ui.*` | 3 (4/4/4/3/5) | 3 (4/4/4/3/5) | 4 | 4/4/4/4/5 | **Rewrote** `ui.main.body` (316 -> 203) |
| B27 | Quiz questions (`quiz_questions`) | 4 (4/4/4/4/4) | 4 (4/4/4/4/4) | 4 | 4/4/4/4/4 | - ("Nobody leaves hungry", "golem", "Yes, Chef" all still in the cited lines) |

## Averages (of the conversation minimums)

| Area | Conversations | Old | New (before edit) | Final |
|---|---|---|---|---|
| The Gainlands | 29 | 3.31 | 3.97 | 4.00 |
| The Endless Buffet | 27 | 3.19 | 3.89 | 4.00 |
| **Both files** | **56** | **3.25** | **3.93** | **4.00** |

Rewritten because the new min was under 4: **4 conversations** (G28, B1, B12, B26). Polished although already at 4 (canon or
distinctness fixes): G5, G6, G8, G17. Total: 9 strings changed in this pass, 0 keys, 0 arrays resized.

## Needs code or the user

1. **Long minigame intros.** Chet's `npc.minigame.intro` (8 boxes) and Flambe's (9 boxes) are talk walls before a minigame. Each box is now
   short, but cutting boxes means shortening the arrays, which the writer rules forbid. Safe to cut to 4-5 boxes if the user agrees (the
   code reads one box per entry; check `ZoneStoryText.get_lines` callers first).
2. **Rhonda name clash.** The Gainlands ripper Rhonda and Recycle Rhonda still share a name (`travel.ripper_calf.*`,
   `quest.gain_spot_me.offer/.ready`). Open inbox decision; I kept the name.
3. **`still.flex`** ("They had not taken his muscles") is in `intro_story.tres`, not these files. It still contradicts the lesson that the
   new `cutscene.rescue.3` / `cutscene.flex.3` now land.
4. **C24 / Brick.** The "old man who never broke" line and Brick's freed lines live in `intro_story.tres` and need code (the victory array
   is replayed after the zone is freed).
5. **Dungeon node text may be overridden.** `DungeonCatalog` builds some `dungeon.hg_*` / `dungeon.tk_*` titles and blurbs from the sheet.
   If it wins, the Quota mention (`dungeon.hg_checkpoint.blurb`) and the freezer hint (`dungeon.tk_cold.blurb`) never show. Needs a check in
   code or a run.
6. **Real years in a fantasy world.** "Operators have been standing by since 1989" (Chet) and "two-thousand-three" (Flambe's return line)
   are not brands, but they are real-world dates. The user's call; I left them.
7. **Not reviewed (other files):** the Gainlands and Buffet barks in `npcs.json`, and `quest.side_s_beef/_gour.*` in
   `dungeon_content.json`.
8. **Fit test not run** (no Godot in this pass). Every string this pass touched got shorter or grew by a few characters (Foreman Gus) and is
   under 240 characters.

## The 5 best final before -> after examples

1. `gourmand cutscene.reveal.5`
   - Old: "THIS is my real face. Behold the true dish of {villain}: the Doppelgänger. Now. Let me serve you."
   - New: "This is what was under it. I wore her face so long that I forgot my own. There is nothing in here to taste with." / "Sit down,
     taster. I was told to serve you."
2. `gainlands cutscene.flex.3`
   - Old: "You took my plates, my protein, my pump, Clench. You thought you had taken my strength. But you only took the weight." / "You left
     me my heart, and my mind. I taught you everything I knew about the first, and you stopped listening before I got to the second."
   - New: "They took my weights, Clench. They forgot to take me." / "You only ever took the weight. I taught you the heart, and you stopped
     listening before I got to the mind."
3. `gourmand cutscene.reveal.3`
   - Old: "...Soup is for the weak. {villain}'s orders are for the strong. I have given the Gourmands the Special Sauce, and they have given
     me an army of golems. It is a very efficient arrangement."
   - New: "...Tasting is inefficient. The orders from {capital} asked for golems, not flavour, and the Special Sauce delivers golems." /
     "\"Delicious.\" That is the word I was given for it. I say it often. I do not know what it means."
4. `gainlands npc.tony.intro` (box 1 and 4)
   - Old: "I'm Coach Brutus Benchley. Yes, I know. Everything's relative." ... "Do not ask what is under it. Iron."
   - New: "LET'S GO! NEW RECRUIT! Coach Brutus Benchley! Retired champion, current motivator, part-time merchant!" ... "*whispering* And do
     not stand on the loose floorboard behind the counter. There's nothing under it. Iron. Nothing."
5. `gainlands quest.gain_power.done`
   - Old: "The grid's running smooth, and some of it is even staying here. Gus would hug you, but Gus is allergic to humility."
   - New: "The grid's running smooth, and some of it's even staying here. I'd hug you, but I'm a foreman. We nod. ...That was a big nod."
