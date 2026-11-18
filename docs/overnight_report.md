# Overnight Nov 17-18 (Opus) - report: 81 new images, the D.N.A. as an indoor grand hall, the owner's decisions

Brief: `docs/prompts/opus_nov17_night.md`. Start tag `pre-overnight-nov18`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 18".
Shots: `docs/overnight_shots/nov18/`. Import note: `docs/art/import_nov18_batch17.md`. No export, no upload. Ran on Opus 5.5.

All seven parts are done. Every one of the 81 images is in the game; the D.N.A. is one huge haunted government hall at night; tonight's
owner answers are applied; the tests, the five walk smokes, the card-games smoke and the NPC probe pass. The strict bot result is
in section 8: a full new game on the Refusemancer Path reached the credits and the first postgame step, Primm beaten with no wall.

## 1. The D.N.A. before and after (Part 2)

The owner's choice: one enormous grand hall, indoors (target `Haunted Office of Necrotic Affairs.png`, layout `PAINTOVER-DNA-HUB.png`).
Only the look changed: the walk grid, rooms, routes, NPC spots, doors, quests, the dungeon entrance and every interaction are as before
(the D.N.A. walk smoke walks all of them; the NPC probe sees all 7 NPCs from both cameras).

| Spot | Before (default / Low) | After (default / Low) |
|---|---|---|
| Arrival | `p2_before_dna_arrival_default.jpg` / `_low` | `p2_after_dna_arrival_default.jpg` / `_low` |
| Hub (the lobby) | `p2_before_dna_hub_default.jpg` / `_low` | `p2_after_dna_hub_default.jpg` / `_low` |
| Door (the Hall's stair) | `p2_before_dna_door_default.jpg` / `_low` | `p2_after_dna_door_default.jpg` / `_low` |
| Mid 1 (the mail room) | `p2_before_dna_mid1_default.jpg` / `_low` | `p2_after_dna_mid1_default.jpg` / `_low` |
| Mid 2 (breakroom to farm A) | `p2_before_dna_mid2_default.jpg` / `_low` | `p2_after_dna_mid2_default.jpg` / `_low` |
| Walk, entrance to the Hall | - | `walk/w_*.jpg` (20 shots from the walk smoke) |

What it is now (`world/dna/dna_hall.gd`, `DnaBuilder._build_grand_hall`):
- **Walls.** Every wall cell that touches the outside is a two-storey painted hall wall on its inside: DNA-WALL-HALL-A and -B in
  alternating bays (never the same twice in a row), DNA-WALL-HALL-NARROW for the leftovers and short runs. Each bay is drawn in three
  height bands that map the paintings' own wainscot and gallery lines to the same wall heights, so the lines run level round the hall.
  Its outside faces are DNA-WALL-EXTERIOR (the arrival). Every other wall cell is a waist-high partition (DNA-RAIL-PARTITION, same
  cells, same collision) with DNA-RAIL-POST at the ends and corners; a two-cell-thick wall reads as two partitions, posts at the ends.
- **Floor.** DNA-FLOOR-MARBLE everywhere inside (polished: the lamps glint on it), red DNA-FLOOR-RUNNER from the gate up the middle
  to the Hall's stair, and to the lobby's neighbours.
- **The far end and the ceiling.** A dark ceiling over the building's footprint; north of it a dark end bay with
  DNA-BD-HALL-INTERIOR on its far wall behind the Hall of Final Approvals. No sky shows from inside at either camera.
- **Columns, chandeliers, banners, sconces, booths.** Columns (DNA-PROP-COLUMN) along the long walls rising into the dark; 13
  chandeliers over the open floor, chains up out of frame, swaying very slightly (off on Low-end); stamp banners from the gallery on
  the side walls; sconce pairs; the office booths on the rooms' back partitions. Walls near the lens cut away (a two-storey wall never
  fills the view); every hanging or standing card fades when the camera comes close.
- **The landmark.** DNA-PROP-LOBBY-CLOCK stands on the Hall's drum where the faceted grey dome stood.
- **Signs.** Every board is a brass plaque from DNA-SHEET-SIGNS whose icon matches what it points to (stamp, clock, arrow, folder,
  raised hand, ghost).
- **Light.** Warm gold from the chandeliers and sconces (pooled lights), the ghost-flame posts as the green accent, cool moonlight
  shafts slanting from the tall windows of the side walls with slow dust motes (off on Low-end and Low), deep shadow overhead. The
  D.N.A.'s own grade, warmed and less desaturated (0.45 -> 0.18), fog a warm near-black.
- **Fixed on the way:** far chunks no longer hide their floor and walls (the outdoor ground showed through); the wasteland no longer
  puts rubble in the walled-in gaps between rooms; the notch between Cubicle Farm A and the Breakroom is hall floor.

**FPS (lobby, 8 s):** Medium **63.8 -> 71.5**; Low-end (uncapped) **86.3 -> 89.7**. Draw calls 1143 -> 998.

## 2. The 81 images (Part 1 and Part 3)

Every row of `batch17a_dna.csv` (17) and `batch17_nov17.csv` (64) is "In game (Nov 18)". Drive filing done (the 11 newest copies moved
into their usual folders, the old ones copied to `Superseded/Batch 17 replaced/`; the duplicate hall wall moved there too). The import
fixes (marble 2x2 crop through the square centres, partition crop, seam blends, the open cellar's doorway backed) are in the import
note with their tiling previews (`p1_tile_*.jpg`). Full table with the Path-icon check per row: `docs/art/import_nov18_batch17.md`.

| Images | In game | Shot |
|---|---|---|
| 17 D.N.A. hall pieces | The grand hall | `p2_after_dna_*`, `walk/` |
| 5 statues x 2 | Each zone hub's plinth, standing / toppled | `p3_statue_<zone>_<oppressed/freed>.jpg` |
| UI-CARDBACK-R / -G / -C | Card backs | `b17_battle_backs.jpg` |
| UI-PACK-G, UI-PACK-GILDED-B | Packs, no code medallion over them | `b17_packs.jpg` |
| MAP-S-CAP, BB-S-CAP | The tunnel map and board | `b17_map_s_cap.jpg`, `b17_board_s_cap.jpg` |
| NPC-ELDER x3 | Maren's portraits | `b17_portrait_NPC-ELDER*.jpg` |
| DUMP-SHEET-ENTRANCE-FLAGS-07 / -08 | The Dump entrance pennants | (Dump entrance) |
| MAP-WORLD-TOWN | Crosspath's map, pins lined up | `p3_town_map_all.png`, `p3_town_map_fog.png` |
| CUT-QUADZILLA | Quadzilla's intro cut-out | `b17_portrait_CUT-QUADZILLA.jpg` |
| 8 BST-* | The Shattered Gallery's Bestiary | `b17_bestiary_*.jpg` |
| ICON-NODE-WELL | The Well's node card and map node | `b17_map_tutorial_well.jpg` (fogged until reached) |
| 4 vault pieces | The painted cellar door and seals | `p3_vault_<locked/two/ajar/open>_zoom.jpg` |
| 18 card-game pieces | The four card games | `p3_cardgame_<game>_<how/mid/win>.jpg` |
| BUFF tart, cake stand, fliers | The east food forest | `p3_buffet_east.jpg` |
| BUFF-PROP-VEG-01..03 | The hub's cabbage beds, the river | `p3_buffet_hub.jpg` |
| NPC-PLAYER_CONFUSED / _DETERMINED | The hero's portraits (teal) | `b17_portrait_NPC-PLAYER_*.jpg` |
| DUMP-PROP-PIG | The escaped pig | `p3_dump_pig.jpg` |

**Hero cloak check:** the world sprites, the Wardrobe default and every story still but one are teal. Two pictures still show the
old cloak: the neutral portrait NPC-PLAYER and Fragment 4 (STORY-MEMORY-4) - Batch 18 rows.

## 3. The statues, the vault, the card games, the Buffet forest (before -> after)

- **Statues:** the flat grey-tinted cut-outs on the plinths are the painted stone statues, same scale in all five zones (3.3 m standing
  on the plinth, 1.5 m toppled beside it). `p3_statue_*`.
- **The vault:** the box-built cellar door is the painted door; locked seals are the painted padlock seals with the faint Path outline,
  a turned seal is the blank seal with its full icon; the doors open on the painted open cellar (warm light on the stair while ajar).
  Fixed diamond order kept (see inbox 2). `p3_vault_*`.
- **Card games:** Reps has the painted rack, bench, bar and plates (one per right guess, alternating ends, heaviest first); Order Up the
  painted pass, paper tickets with the target written on them, and the brass bell; Sort It Out the fair's conveyor and four painted
  crates with the type icons on their plaques; File in Order the records office, the painted cabinet's drawers under the cards and the
  APPROVED / REJECTED stamps. How to play, mid-game and win for each: `p3_cardgame_*`.
- **The Buffet forest:** the giant fruit tart and the tall cake stand stand among the cloches; butterflies and birds flap through their
  painted frames (hidden on Low-end). `p3_buffet_east.jpg`. The hub's green-ball beds are cabbages. `p3_buffet_hub.jpg`.

## 4. The owner's answers (Part 4)

| # | Answer | Done |
|---|---|---|
| 1 | Deck minimum stays 45 | Unchanged. No pacing numbers changed tonight, no sims run (inbox 7). |
| 2 | Primm's Standing Army and the castle's 4th room unchanged | Unchanged. |
| 3 | Elowen's name line | "...knocked it down. Elowen. It's Elowen. I promised." at the gate, before the guards; the name flag now comes just before her line (inbox 6); the Wanderer's closing line follows it. |
| 4 | The hero's own voice in the finale | Flex's and the Grand Chef's quoted lessons replaced with his own lines (phase 1: "Ten years of 'again'... not yet."; phase 2: "...you cannot copy a choice."). Agnes's stays (one per phase). |
| 5 | No shared colour grade | Each zone keeps its own; the D.N.A.'s was tuned for the hall. |
| 6 | Forest brightness / rim light: no | Unchanged. |
| 7 | No boss intent strip | Not added. |
| 8 | Reps keeps the streak after a miss | Done (rules text too). It made Reps much easier (inbox 1). |
| 9 | "Free the Four Zones" auto-starts: keep | Kept. |
| 10 | Tracker names kept | Kept. |
| 11 | The hero's cloak is teal | Portraits in; remaining pictures logged (Batch 18). |
| 12 | The Nov 16 leftover lines | Applied: Maren's "holding it. Do with it as you see fit.", "Four banners fly side by side over the square", "find me at my house", "I can see her face", "a worn cloak too thin for the cold". |

Ten single lines changed. **Revert:** `node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov18_single_lines.csv --revert=docs/dialogue/nov18_single_lines_ids.txt`
(the moved name flag is a data change in `data/story/story_scenes.json`, pc_capture; it is not part of the dialogue revert).

## 5. Small leftovers (Part 5)

- **The Verdant Dump's south corners:** grass slopes, no pale wedge, and the camera followed smoothly both ways at both cameras
  (`run_heap_corner_camera.sh`: the hero stays at 0.60-0.63 of the frame, at most 1.9 px jump, the lens at most 0.7 m to the side).
  `p5_dump_*`. Fine, nothing changed.
- **The Buffet castle's last chimney:** stands on the roof slope, no floating or clipping piece. `p3_buffet_east.jpg`. Fine.
- **The waist-high hedge by the Buffet entrance:** low, never blocks the path or reads as a wall (it is the cabbage bed now).
  `p5_buffet_entrance(_low).jpg`. Fine.

## 6. Batch 18 (Part 6)

`docs/art/batch18_nov18.csv`, 8 rows, each description self-contained and under 600 characters: MAP-WORLD-GAIN, -BUFF, -DUMP, -DNA,
-CAP (parchment maps that follow the plans), NPC-PLAYER (teal, transparent), STORY-MEMORY-4 (the boy's cloak teal), and the cellar door
with its sockets in a diamond. The five plans are in `G:/My Drive/Card Game Art/Batch 18 Refs/` (`plan-gainlands.jpg`, `plan-buffet.jpg`,
`plan-dump.jpg`, `plan-dna.jpg`, `plan-capital.jpg`; 2048x2048, 360-396 KB); copies in `p6_plan-*.jpg`.

## 7. Build size

101 asset files written; source art **+14.7 MB** net (17.3 MB new and replaced against 2.6 MB replaced). No export tonight; at the
import rules' compression that is roughly +15-25 MB on the 1.0.0 pack (784 MB, over the 750 MB warning on purpose,
`docs/build_size_policy.md`).

## 8. Tests and checks (Part 7)

- **GUT:** all 34 shards (size 12) run; the only failures were tests that encoded tonight's replaced designs (the quoted lessons, the
  Reps reset, the old statue/pennant/flier art, the D.N.A.'s old desaturation, sign pictures). They follow the owner's answers now;
  the touched files re-run 81/81 green. Real saves untouched.
- **Walk smokes:** Crosspath, Gainlands, Buffet, Dump and D.N.A. all OK.
- **Card-games smoke:** 137 checks passed.
- **NPC visibility probe:** **150 checks, 0 failed** (every zone, both cameras; the D.N.A. alone 14/14 earlier).
- **Strict bot (Refusemancer, new game, no shortcuts):** **went all the way: new game -> four zones -> the Capital -> Primm beaten
  (L22, 21 min, no 10-loss wall; on Nov 17 it hit the wall at L24) -> the ending and credits -> the first postgame step**, 74 min.
  23 issues, all of the kinds the Nov 17 run logged (the bot's own walking getting stuck at the same spots in the Dump, D.N.A., Buffet
  and Capital - it is moved on and carries on; the D.N.A. ones are at the same coordinates as on Nov 17, so the grand hall added
  none), plus 4 script errors of one new kind (a Buffet quest marker asked after the hero had left the zone: guarded tonight,
  `BuffetInteractables.picked_this_visit`). Log `_logs/strict/refusemancer.log`.

## 9. For the owner (most important first)

1. **Reps is easy now** (98 % first-set wins for a sensible guesser): ten reps or two misses would restore it. Recommend ten reps.
2. **Vault door sockets in a row vs the diamond rule:** recommend the small repaint (Batch 18 row); until then the seals keep the diamond.
3. **NPC-PLAYER (neutral) and STORY-MEMORY-4 still show the old cloak:** recommend sending the two Batch 18 rows with the maps.
4. **The Hall of Final Approvals is still the grey 3D building inside the painted hall:** recommend a painted interior facade card in
   the next batch (look at `p2_after_dna_door_default` first).
5. **Combat pacing (your answer 1):** not touched tonight; recommend a feel-only pass next (readable enemy turns, reward moments).
6. **The cabbage beds:** check that this is the patch you meant (inbox 4).
7. **The Batch 18 plans are renders, not drawn diagrams:** recommend sending them as they are; the painter only needs the shapes.
8. **No export was made tonight** (the brief): the last zip is 1.0.0 of Nov 17; tonight's build needs an export before upload.


# Overnight Nov 16-17 (Opus) - report: a full playthrough, six harsh critics, fixes, 1.0.0

Brief: `docs/prompts/opus_nov17_overnight.md`. Start tag `pre-overnight-nov17`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 17".
Critic reports, triage and plans: `docs/review/critic_nov17/`. Shots: `docs/overnight_shots/nov17/`. No public upload. Ran on Opus 5.5.

**A note on time:** the session sat idle from about 23:00 to 06:50 (it waited for input after a tool step), so the night ran as a day:
Part 1 in the evening, Parts 2-5 from 06:50 to the afternoon. Everything in the brief was done; the critics had smaller budgets than
planned and the re-checks are short.

## The verdict

| Lens | Before (Nov 16 or earlier) | Tonight, round 1 | Re-check on the fixed build |
|---|---|---|---|
| 1. Combat and deckbuilding | fun 6 (never higher) | **4/10** (provisional: one fight finished) | **4/10** (C5 F4 P6) |
| 2. The late game and the ending | clarity 5 | **4/10** (never reached the ending) | **4/10** (C3 F3 P6); the town quest fix seen |
| 3. The story and the writing | blind readers: rewrite = old | **6/10** | - |
| 4. The world's look (art director) | 6.2 (Nov 12) | **5.5/10** (painted ~8, the 3D world ~4.5) | - |
| 5. The first 30 minutes and the menus | first hour 6 / 6 / 7 | **4/10** | - |
| 6. The new card games | never played | **3/10** (reached only Reps) | - |

Tonight's critics were told to score against Slay the Spire, Inscryption, Octopath and Sea of Stars, not "good for a small team"; the
numbers are lower than earlier sittings partly for that reason, and partly because they play through a scripted driver that cannot react
inside a turn (critics 1, 2 and 6 say so plainly). Read the scores as "where the game stands against the best", not as a regression.

**The three weakest parts of the game right now, in plain words:**

1. **Fights are slow and the choices are thin.** A first-room fight takes about 8 turns; most turns the right play is obvious (play the
   one infrastructure, then whatever fits); a new card is 1 in 45, so winning one rarely changes how you play; bosses do nothing for two
   turns and then flood the board. This is the core loop, and it is why fun has never passed 6.
2. **Finding things.** Several places a player must reach were missing from "Point me to..." (the Capital road, the quiz teachers, the
   card-game hosts) and the main line could vanish (no main quest with four lands free if Brannoch was skipped). Tonight's fixes close
   the ones that were bugs; walking in the 3D world still costs critics many runs.
3. **The 3D world's look against the painted art.** The dungeon maps, cards, portraits and Crosspath score 7-8.5; the D.N.A. (a greybox
   look), the Capital (flat pastel fills) and the Buffet (washed out, a flat sea) score 3.5-5, and every zone has its own colour filter.

**Would I ship this tonight? Yes, as a free itch.io release - with honest expectations.** There is no blocker left that stops a game:
the full no-shortcut playthrough went from a new game to Primm with no soft-lock, no lost main-line marker and no trap; every test is
green; the exported build runs clean. What players will feel is a slow, gentle deckbuilder with lovely painted art, good jokes and an
uneven 3D world. That is a fair free game; it is not yet a game reviewers recommend. The next real gain is in the combat pacing (owner
decisions 1-2), not in more content.

## The playthrough's facts (Part 1, `docs/review/critic_nov17/playthrough.md`)

One complete game on the Refusemancer Path with the new **strict bot** (`bash tools/run_strict_playthrough.sh refusemancer`): every fight
played by the game's planning AI, real walking along the quest arrow's route, every quest done by walking up and pressing E, no flags
set, no fight decreed until a 10-loss wall. Three sittings of the same save (the bot crashed twice on its own code and continued from
the save it had just made).

| Chapter | Bot time | Level / gold at the end | Losses |
|---|---|---|---|
| Forest + the Forgotten Cave | 1.6 min | L3 / 520 | 0 |
| Crosspath: Settling In | 2.9 min | L5 / 554 | 0 |
| Verdant Dump (gatekeeper, side quest + Landfill Depths, the Rotheart) | 19 min | L10 / 1,379 | 3 |
| Gainlands (gatekeeper, a favour by play, the House of Gains) | about 15 min | L13 / 1,484 | 2 |
| D.N.A. | 5.5 min | L14 / 1,524 | 0 |
| Endless Buffet | 6.0 min | L16 / 2,619 | 0 |
| Capital: Captain Spotless | 2.4 min | L17 / 2,769 | 2 |
| The Crease, Fig Sly | 0.4 min | L17 / 1,809 | 0 |
| Primm's Castle and Primm | 42 min | L24, **wall** (decreed) | 10 |

- **Level and gold at each main dungeon:** Rotheart L8 (514), House of Gains L10 (444), Hall of Final Approvals L13 (384), Test Kitchen
  L14 (1,099), Spotless L16 (2,344), the castle L17 (1,809), Primm first reached at L19. 1.40 h of game time at the fastest battle speed;
  59 fights won, 12 lost.
- **Blockers and their fixes:** no soft-lock, no unwinnable fight below Primm, no trap. Found: the Rescuer's four cave-mouth scenes had
  no marker (**fixed**: a "!"), and "Free the Four Zones" (the castle's marker) depended on talking to Brannoch (**fixed**: it starts by
  itself once a zone is free). **Primm's Castle is the wall** (owner decision 2). The ending's own flow was not reached by the bot (the
  decree skips it), and both late-game critics lost to Primm: **no one has seen the credits from a real Primm win tonight**. The ending,
  the credits and the new tracker are covered by tests, and the Nov 16 critic reached "File Complete".

## What was fixed (shots in `docs/overnight_shots/nov17/fixes/`)

| Fix | From | Shot / test |
|---|---|---|
| The card quiz header names each zone's exam ("Compliance Re-Certification", ...) | known item | `quiz_header_dna.jpg`; test |
| Card-game hosts said "[missing text: quiz.start]" in every zone | found tonight | test |
| The freed Capital flies the four Paths' banners on its wall, towers, gate, houses, lamps and decrees | known item | `capital_freed_banners.jpg`; tests |
| After Primm: "The City Gathers" (see the ending, the gathering in Grave Row), then "After the Fall" (the Lab and the Gallery, marked) | known item | tests |
| The four old zone smokes deleted; the docs point at `run_card_games_smoke.sh` | known item | - |
| The Rescuer wears a "!" while she waits at the cave mouth | playthrough | - |
| "Free the Four Zones" starts by itself once a zone is free and leads over a side quest | playthrough, critic 2 | test; the re-check saw it |
| "Point me to..." lists the roads out (the Capital), the quiz teachers, the card-game hosts and the filing terminal | critics 2, 6 | tests |
| The Crease's back wall hides the sky and the skyline | critic 4 #1 | `crease_before.jpg` / `crease_after.jpg` |
| The Path choice selects on any click, with a gold frame | critic 5 #1 (blocker) | - |
| Peek can always be closed (Done, E, Space, Enter; the rest stays on top) | critic 5 | test |
| The forest's J / C / P say where they open | critic 5 | - |
| No "F8" in the pause menu with a controller | critic 5 | - |
| DEFEAT no longer covers the result panel's text | critic 2 | the re-check saw it |
| Hand cards say "On play" / "On death" / "On attack" instead of "Effect" | critic 1 | test |
| Card-game pop-ups keep the controller's focus (no guess under How to play, no "?" on the result screen) | critic 6 | - |
| Reps' rules say a miss resets the reps | critic 6 | - |
| 11 single lines of dialogue (Primm's cut-in, the Tuesday payoff, Escoffina x2, the seed, the Hollow Warden, Prudence, Mortimer's number, a missing "little prince" setup, the Rescuer's "stay down", Primm's "simply not true") | critics 2, 3 | revert file `docs/dialogue/nov17_single_lines_ids.txt` |

**Not fixed (logged in the triage with a plan):** what the board-layout rule protects (the hand overflowing, attackers covering
blockers), every combat number (owner decisions 1-2), the 3D world's materials (the L-plans), the walk out of Crosspath on foot (the
critics walked blind; the arrow and "Point me to..." now lead there), the story's structure (Elowen, the hero's voice), the Buffet's
haze, the forest's darkness.

**Checks:** the full suite, 41 shards, 0 failing (one stale log line, re-run green), real saves untouched; the Capital, Crosspath, Dump
and Buffet walk smokes pass; the NPC visibility probe 150 checks, 0 failed; the card games smoke 137 checks, 0 failed; the exported smoke
PASSED; exported play checks A, B and C with 0 script errors (B could not seed A's settings file and ran with defaults).

## The owner's decisions (with context: `docs/overnight_inbox.md`, "Overnight Nov 17")

1. **Combat pacing:** try a 40-card minimum with 15 infrastructure in the sims. Both combat critics' "one change" was a card pick after
   every dungeon fight. Recommendation: sim the 40-card deck first, then decide on the card pick.
2. **Primm's free Militia and the castle's 4th room.** Recommendation: Standing Army with 2 Militia, or Setting Up through turn 3.
3. **Elowen says her own name** at the gate before Plume does. Recommendation: yes (one line).
4. **The hero's own voice in the finale:** replace two quoted lessons with his own. Recommendation: yes (a small scene edit).
5. **One colour grade** for all zones, Crosspath's as the base. Recommendation: yes.
6. **The Opening Forest's brightness** (+0.5 EV, a rim light, keep the teal dusk). Recommendation: yes.
7. **An intent strip for bosses** (L5). Recommendation: yes.
8. **Reps keeps the streak after a miss.** Recommendation: yes.
9. **"Free the Four Zones" starts by itself** (done tonight; say if it should stay Brannoch's alone).
10. **The post-Primm quest names** ("The City Gathers", "After the Fall"; they are mine).
11. **The hero's cloak colour** (teal or brown; a Batch 17 row).
12. **The five lines still yours from Nov 16** (Maren's "holding yours" is now flagged by two critics).

## The L-item plans

`docs/review/critic_nov17/l_plans.md`: L1 the D.N.A.'s walls and lights, L2 the Capital's facades and floor, L3 the primitive sweep,
L4 the Gainlands' rock and brick, L5 an intent strip for bosses (needs a yes).

## Batch 17 additions

Three rows added to `docs/art/batch17_nov16.csv`: GAIN-PROP-BARBELL (+ a plate), the hero portrait's cloak colour (owner: teal or
brown), BUFF-PROP-VEG / DUMP-PROP-PIG (painted cards for the low-poly vegetables and the cube pig).

## Where the zip is

**`builds\TheWaywardPath-v1.0.0-windows.zip`, 784,415,439 bytes (748 MB), Nov 17 12:32**, rebuilt with everything above. Not uploaded
anywhere. The test pack for exported-build runs: `builds\_testpack\TheWaywardPath_test.pck`.


# Fable Nov 16 (evening) - report: your answers, the Dump's entrance and camera, the Buffet's castle, forest and west edge, 1.0.0

Brief: `docs/prompts/fable_nov16_evening.md`. Start tag `pre-fable-nov16c`. Questions: `docs/overnight_inbox.md`, "Fable Nov 16c"
(26 items). Shots: `docs/overnight_shots/nov16c/`. No public upload. No difficulty setting, the battle board untouched, Primm's fight
untouched, no new painted art. Ran on Fable 5.2. The Fable Nov 16 (day) report follows below.

## In short

| Part | Done? | What |
|---|---|---|
| 1. Your answers | **Done** | The trivia is a card quiz in all four zones. The three puzzles are gone; a chest holds each reward. The seals sit in Path order with a faint icon outline and a tooltip. Eight old screens and their rule code are deleted. |
| 2. The Dump's entrance | **Done** | The two gate trees, their code and their art are gone. The path runs open to the prompt, the sign and Moss Mulligan. |
| 3. The Dump's camera | **Done** | The camera follows in both south corners. The cause was last night's own wedge fix. |
| 4. The Buffet | **Done** | The castle is one gingerbread house. The entrance trees are a low hedge. The river thins into the outer gravy; the black line is gone. Steam, statue and banners fixed. |
| 5. Verify and build | **Done** | Smokes and all 41 test shards green. 1.0.0 exported; the exported smoke and the three exported play checks pass. |

- **Tests:** all 41 shards ran: **3194 of 3196 passed, 0 failing**, 2 pending; your real saves were not touched (14 files checked).
- **Smokes:** the Crosspath, Buffet and Dump walk smokes pass. The NPC visibility probe passes (150 checks). A new card games smoke
  plays each zone's card game, the card quiz and the chest with real clicks: 137 checks, 0 failed.
- **The zip:** **rebuilt with everything above.** `builds\TheWaywardPath-v1.0.0-windows.zip`, 784,409,895 bytes (749 MB), Nov 16 19:23. Not uploaded anywhere.

## What you must still do

1. **Play the card quiz once in each zone**, with a mouse and with a controller. It is tested by code, by a smoke with real clicks
   and by screenshots, not by hand.
2. **Look at both south corners of the Dump** (inbox 13): the rock wall beside them is a grass slope now. That is what lets the camera
   follow. `p3_after_*`.
3. **Look at the castle** (inbox 15 to 18): one chimney is left in its roof, and the Dining Hall wings in front of it are unchanged.
4. **Look at the hedge right of the Buffet's entrance** (inbox 19): it is waist-high, not knee-high.
5. **The old zone smokes** (`run_fifth` to `run_eighth_brief_final_smoke.sh`) cannot reach their zones from town any more; that was so
   before this pass. I updated their quiz and chest steps but could not run them. `tools/run_card_games_smoke.sh` covers the same
   ground from inside each zone. Say if the old four should be repaired or deleted.
6. **One small thing I saw only after the export:** the quiz's header reads "Card Quiz" in every zone. The per-zone names
   ("Fitness Theory Exam", "Compliance Re-Certification" ...) are set but not shown. I left the code as the zip has it; it is a
   two-line fix for the next build (inbox 25).


## Part 1 - your answers

### The card quiz (it was the trivia)

| | Shot |
|---|---|
| How to play | `c1_quiz_gain_how.png` |
| A picture question | `c1_quiz_gain_mid.png`, `c1_quiz_dna_mid.png`, `c1_quiz_gain_mid_720.png` |
| Passed / not passed | `c1_quiz_gain_win.png`, `c1_quiz_gain_lose.png` |

**The rules:**

- **Where:** at the same four teachers (Professor Pump, Professor Pate, Druid Thistlewick, Director Ectomund), in the painted classroom.
- **Four questions**, about four different real cards of that zone's Path or colourless ones, in a shuffled order:
  - two show **a cropped piece of a card's art** and ask "Which card is this?" (four card names);
  - one shows a card's art and name and asks **its cost** (four numbers);
  - one shows a unit's art and name and asks **its power** (four numbers).
- The card's face is not shown before the answer (it prints the cost and the power). After each answer the whole card turns up.
- **Three right answers pass**, as before. The first pass pays the old reward for that score; after it every attempt pays the old
  small fee; a fail before the first pass pays nothing.
- The quest flags are the old ones: the D.N.A.'s "Pass Director Ectomund's Compliance quiz" works.
- It has the How to play screen, the "?" button and the win / lose panels of the other card games. Keys 1 to 4 or the buttons.

The 16 written questions are deleted. 12 teacher and sign lines that said "the answers are on the signs" now say what the quiz asks.

### The chests (they were the three puzzles)

| Zone | Removed puzzle | Chest at the same spot | Holds (once) | Shot |
|---|---|---|---|---|
| Gainlands | Power Grid (hamster wheels) | The Grid Crew's Strongbox | Gainsmith's Lifting Belt | `c1_chest_gainlands.png` |
| Endless Buffet | Mystery Stew Pot | The Stew Cook's Chest | Head Chef's Ladle | `c1_chest_buffet.png` |
| Verdant Dump | Seed Shrine (garden) | The Gardeners' Chest | Refusemancer Seed Satchel | `c1_chest_dump.png` |

- A save that had solved the puzzle finds the chest open and empty.
- No quest step needed a puzzle, so no quest changed. The sign at each spot and the gear list's "where from" line are updated.
- The stew pot model is gone from the Pancake summit (inbox 5).

### The seals

`c1_seals_locked.png`, `c1_seals_locked_close.png`, `c1_seals_2of4.png`, `c1_seals_2of4_close.png`.

- The four seals form a diamond on the cellar doors: arm at the top, chef's hat right, leaf at the bottom, skull left.
- A locked seal shows a small padlock over a **faint pale outline of its Path's icon**. When it turns, the full icon shows.
- **Tooltip:** the mouse over a seal says "Gourmand seal: locked" (or "turned"). Standing at the door shows all four lines, for
  keyboard and controller.

### Deleted, kept

- **Deleted:** `RepGameScreen`, `OrderGameScreen`, `SortGameScreen`, `TubePuzzleScreen`, the three puzzle screens, the trivia screen,
  and the rule code of all of them. `RepGame`, `OrderGame` and `SortGame` keep only their reward tables.
- **Kept as they are:** the compact deck-rule lines, the vault's place, the Buffet's north side.

## Part 2 - the Dump's entrance in Crosspath

| | Before | After |
|---|---|---|
| Default camera | `p2_entrance_before_default.png` | `p2_entrance_after_default.png` |
| Low camera | `p2_entrance_before_low.png` | `p2_entrance_after_low.png` |
| Road still sealed | | `p2_entrance_after_sealed.png` |

- The two gate trees, `HubObstacles.GATE_FROM_SPOT` and the rest of the gate code, and the two cut-out tree pictures are deleted.
- Three low bushes stand beside the path. No tree stands in the view of the prompt, the sign and Moss Mulligan.
- The thorns across the forest road until Moss Mulligan is beaten are unchanged.
- **A fault found on the way and fixed:** in Crosspath every NPC's name floated about 170 px above its figure (in the sky at the Low
  camera). "Moss Mulligan" in your screenshot hangs over empty grass for this reason. Names, barks and the quest pointer now sit
  where they belong.

## Part 3 - the Dump's camera in the south corners

**The cause:** last night's fix for the pale corner wedge. It held the camera in from the side rims in the south 18 m of the zone.

| Walking into the south-east corner and out | Before | After |
|---|---|---|
| Where the hero stands across the frame (0.50 = the middle) | 0.50 to 0.81 (0.89 at Low) | 0.50 all the way |
| The camera's distance to the side of the hero | up to 11.8 m | under 1 m |
| Biggest jump of the hero on screen between two frames | 18.1 px (21.7 px at Low) | 0.8 px (1.6 px at Low) |

The south-west corner measured the same before (the hero at 0.22 of the frame, 0.15 at Low) and is the same after as the south-east.

**The fix:**

- The hold is deleted. The camera follows the hero everywhere in the Dump.
- The wedge is solved at its cause. The valley's side walls now sink over the last 24 m toward the south and are gone before the
  corners, so no cliff curves round in front of the camera.
- A knee-high line of rocks, bushes and mushrooms marks the edge of the walkable ground there.
- The chest and the lever are in plain view at both cameras.

**Shots** (a walk of five stops, both cameras, before and after): `p3_before_default_se_3_toward_lever.jpg`, `_4_lever`, `_5_chest`,
`_6_corner`, `_8_out`, and `p3_before_default_sw_4_corner.jpg`; the same names with `after`, and with `low`.

To measure it again: `bash tools/run_heap_corner_camera.sh after 0` (default camera) or `... after 3` (Low).

## Part 4 - the Endless Buffet

### 4.1 The castle

| | Before | After |
|---|---|---|
| From the entrance | `p4_before_entrance.jpg`, `_low` | `p4_after_entrance.jpg`, `_low` |
| From the hub | `p4_before_hub.jpg`, `_low` | `p4_after_hub.jpg`, `_low` |
| On the road north | `p4_before_road.jpg`, `_low` | `p4_after_road.jpg`, `_low` |
| At its door | `p4_before_forecourt.jpg`, `_low` | `p4_after_forecourt.jpg`, `_low` |

- **Before:** a kitchen-laboratory. A copper great hall and dome with a chef's hat, two copper tanks, two glass greenhouses, a whisk
  crane and a ladle crane with hanging loads, seven chimney stacks, four cake towers, oven arches in the wall.
- **After:** one gingerbread house. A tall biscuit body under one steep pie-crust gable roof, the gable to the front.
  - Thick white frosting along the eaves (with drips), down the gable's edges (scalloped), along the ridge and down the corners.
  - Gumdrops in pink, mint, yellow, red and lilac on the ridge, the gable and the walls.
  - The kit's frosted and candy-cane windows; a round candy-cane window high in the gable.
  - Candy-cane posts at the door and at the wall's corners. The kit's frosted gingerbread door.
  - Two towers only: the gate's, under frosting-topped cones.
- The door, the gate's size, the solid circles and the walk grid are unchanged. Only art the kit already had is used.

### 4.2 The trees by the entrance

`p4_before_entrance.jpg` / `p4_after_entrance.jpg`, `p4_before_hub.jpg` / `p4_after_hub.jpg`.

- 14 of the 18 trees right of the bridge are gone, and the grove of three on the plaza's corner. The hub shows from the entrance.
- A low hedge stands where the trunks stood, as solid as they were: the walk grid is the same.
- Four trees stay at the east end, where the stand runs into the east border's forest. That forest is untouched.

### 4.3 The west side

`p4_before_west.jpg` / `p4_after_west.jpg` (and `_low`), and side by side, enlarged: `p4_west_before_after_zoom.png`.

- **The slab and the straight cut:** the river ended a metre past the table's edge. It now runs out 18 m and thins away, and on the
  west side it widens into a delta. The outer gravy shows through more and more: no edge.
- **The faint black line:** it was the game's outline pass drawing the shore that lies under the gravy. The shore now runs down to a
  flat bed, and the outline pass draws nothing under the gravy in the Buffet.
- **The rest of the edge:** I checked the west, south-west, north-west, east and south sides (`p4_after_west_south`, `_north_west`,
  `_east`, `_entrance`). The line was there all round; it is gone all round. The east end of the river had the same cut and has the
  same fix.

### 4.4 The quick checks

| Thing | Was it a fault? | What I did | Shot |
|---|---|---|---|
| The grey lady | Half. She is the ruler's stone statue (your Nov 15 request), but she read as a faded picture | Warm, darker stone; moved off the paving, west of the Hearty Meal | `p4_after_statue.jpg` |
| The steam "discs" | Yes | Every puff is a soft round fading card now, in the whole zone | `p4_after_steam.jpg` |
| The banner pole on the path | Yes | The ruler's two banners flank the road north at the plaza's far end, off the paving | `p4_after_hub.jpg` |

### FPS (Medium, 1920x1080, this machine)

| Place | Before | After |
|---|---|---|
| The castle's door | 71.3 | 71.8 to 72.1 |
| The hub | 81.0 | 76.1 to 82.4 (four runs; the spread is the machine's) |
| The entrance bridge | 82.7 | 81.0 to 84.6 |
| The west shore | not measured | 73.1 |

The castle draws 9 fewer objects than before. The Dump and Crosspath changes add nothing that costs frames.

## Part 5 - verify and build

1. **Smokes** (each run alone, in the foreground):
   - Crosspath walk smoke: OK (the loop round the town, 7 shop doors, the alley, the lakeshore, the hatch).
   - Buffet walk smoke: OK (bridge, plaza, NPCs, quiz, Dinner in a Dash, the chest on the summit, both dungeons' doors, lever, back to town).
   - Dump walk smoke: OK (the same round in the Dump, the chest on Rust Peak included).
   - NPC visibility probe: OK, 150 checks, 0 failed.
   - **Card games smoke (new, `bash tools/run_card_games_smoke.sh`): OK, 137 checks, 0 failed.** In each of the four zones, with real
     keys and clicks: the host's card game opens on How to play, is won and pays; the card quiz opens with its teacher, deals four
     questions from the zone's cards, is answered by clicking, pays the trivia's top reward and sets its flags; the chest gives its
     gear once (the D.N.A.: File in Order gives the lanyard).
   - The four old zone smokes (fifth to eighth brief) do not get from town into their zones any more (see "What you must still do").
2. **Tests:** `bash tools/run_tests.sh --min-free=900`, all 41 shards in five foreground pieces: **3194 of 3196 passed, 0 failing**,
   2 pending. Real saves untouched (14 files checked before and after).
3. **Export:** free memory stayed at 1.6 GB for the 10 minutes, so the export ran with `EXPORT_LOW_MEMORY_OK=1`. `EXPORT OK`: the zip's
   CRCs, contents and size checked by the script. Peak memory 1,689 MB.
   - One stale Godot process from this afternoon (11 MB, started 14:20) blocked the export's own check; I ended that one process.
4. **The exported build:**
   - `bash tools/run_release_smoke_exported.sh`: **PASSED (1.0.0)**, 0 script errors.
   - The three `tools/play_exported.sh` checks (`exported_rc1_a`, `_b`, `_c`) each ran to "done"; `grep -c "SCRIPT ERROR"` on their
     six logs prints 0 six times. Run b opens the Gainlands quiz: the exported build shows the card quiz.
5. **Where the zip is:** `builds\TheWaywardPath-v1.0.0-windows.zip` (784,409,895 bytes). The unpacked build is `builds\_export\`.

**The memory guard** stopped one background run again this evening (the smokes). Everything was then run in the foreground, as your
brief says. Nothing is left unrun.

---

# Fable Nov 16 (day) - report: clean-up, Deck Station, four card minigames, the Dump gate, the vault, the Buffet's edges

Brief: `docs/prompts/fable_nov16_day.md`. Start tag `pre-fable-nov16b`. Questions: `docs/overnight_inbox.md`, "Fable Nov 16b"
(28 items). Shots: `docs/overnight_shots/nov16b/`. No public upload. No difficulty setting, the battle board untouched, Primm's fight
untouched, no new painted art. Ran on Fable 5.2. The Overnight Nov 15-16 report follows below.

## In short

- **Disk:** 20.1 GB freed (12.8 GB free before, 32.9 GB after). One empty folder is left for you (see below).
- **Deck Station:** the deck list is a narrow column down the whole right side. A 62-card deck shows whole at 1920x1080 (it showed
  one row before); 23 rows at a 130 % UI scale.
- **Four card minigames** replace one non-card game per Path zone, at the same spot, host and rewards: Reps, Order Up, Sort It Out,
  File in Order. **The trivia in the four zones and the other three puzzles are not replaced** (inbox 7: your call).
- **The Dump's entrance** in Crosspath is an arch of two trees over the path, walked through to the travel prompt.
- **The Four Seals** is a small cellar door in a grassy bank with four iron seals (padlock, then the Path's icon), and a gold-framed
  toast replaces the lever's cutaway.
- **The Buffet:** gravy all round the table at the ground's edge, and a food forest to the east horizon.
- **Tests:** **the full suite did not finish.** Shards 1 to 20 of 41 ran: 1959 of 1960 passed, 0 failing. Then the session's memory guard stopped the run. Every test file touching today's work passed when run on its own. The three walk smokes and the NPC probe pass.
- **The zip:** **not rebuilt.** `builds\TheWaywardPath-v1.0.0-windows.zip` is still last night's build (04:21) and has none of today's work in it.

## What you must still do

0. **Finish Part 6 yourself, or ask me to.** With the other programs closed:
   `bash tools/run_tests.sh --from=21 --min-free=900` (shards 21 to 41, about 30 minutes), then
   `bash tools/export_windows.sh 1.0.0` (or with `EXPORT_LOW_MEMORY_OK=1` in front), then
   `bash tools/run_release_smoke_exported.sh` and the three `tools/play_exported.sh` checks. To stop the guard killing long runs,
   start Claude Code with `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1` set in its environment.
1. **Remove one empty folder.** Close the ChatGPT app, then run:
   `Remove-Item -Recurse -Force "C:\Users\asche\Documents\Codex"`
   (`...\Codex\2026-11-15\files-mentioned-by-the-user-batch` was held open by another program; everything in it is already gone.)
2. **Decide inbox 7:** whether the classroom trivia (four zones) and the three other puzzles (hamster wheels, stew pot, garden)
   should also go, and what should stand there.
3. **Look at four places where taste matters:** the gate's position on the path from town (inbox 13), the cellar door staying
   where the vault stood (inbox 17), the Buffet's north side without its layer-cake rim (inbox 23), and the hosts' rewritten lines
   (inbox 10).
4. **Play one round of each new game** with a mouse and with a controller. They are tested by code and by screenshots, not by hand.
5. **Batch 17** grew by 7 items (21 items, 65 images). The new references are not on the Drive yet:
   `python tools/art/batch17_build.py` copies them.

## Part 0 - disk space

| | Free on C: |
|---|---|
| Before | 12.8 GB (13,766,610,944 bytes) |
| After | 32.9 GB (35,341,123,584 bytes) |
| **Freed** | **20.1 GB** |

Deleted: the seven old zips in `builds/`, `builds/_export/`, `builds/_testpack/`, and everything inside `_movie/`, `_screenshots/`
(11 GB), `_art_inbox/`, `_art_source/`, `_logs/` and `Documents\Codex\`. Kept: `builds/TheWaywardPath-v1.0.0-windows.zip`,
`builds/trailer_rc1.mp4`, `.godot/`, `.git/`, `_asset_library/`, `build_cache/`, everything git tracks.

The five scratch folders are emptied, not removed: 169 tool and test files name `_screenshots/` and 28 name `_logs/`, and some
write there without creating the folder first. Nothing a tool or test reads back was in them.

## Part 1 - the Deck Station's deck list

| | Before | After |
|---|---|---|
| 1920x1080 | `p1_deck_before_1080.png`: one card row under a big header | `p1_deck_after_1080.png`: every row of a 62-card deck |
| 1280x720 | `p1_deck_before_720.png` | `p1_deck_after_720.png` |
| 115 % / 130 % UI scale | held at 100 % | `p1_deck_after_115.png`, `p1_deck_after_130.png`: 23 rows |
| Large text | | `p1_deck_after_large_text.png` |
| A row hovered | | `p1_deck_after_hover.png`: the card beside the row |

- **Shape:** a column the screen's whole height, right of the slot racks. The collection took the freed width: 8 cards a row (7).
- **A row:** cost, Path icon, name, copies ("2/3"), - and +. Groups by type (Units, Spells, Tools, Traps, Wonders,
  Infrastructure), each with a small header and its count. A gold scrollbar when the deck is longer than the column.
- **Header:** the deck's name, the five slot buttons, three rule checks (cards / at least 45, copy caps, Paths), the cost curve.
- **Footer:** Save Deck, Save as new slot, Reset, Fill Infrastructure, Suggest a deck.
- **Removed:** the Primm hint and the two summary lines. The "Tip: Building a deck" pop-up stays, moved clear of the column.
- **Controller:** down from the first row passes every row and reaches the footer; right of a row's - is its +. A bug fixed on
  the way: after the first + or -, no row could be focused again.
- **Deck logic:** unchanged. The row buttons call the same add and remove as before.

## Part 2 - four card minigames

**Inventory.** Each Path zone has a replayable minigame with a host, a one-time puzzle, a trivia quiz and Dex's card-matching
table. The D.N.A.'s replayable game (Kyle's) is card matching too. Kept exactly: Dex's four tables and Kyle's game. Replaced: the
three replayable non-card games and, in the D.N.A., the tube puzzle from your screenshot. Not replaced: the trivia and the other
three puzzles (inbox 7).

| Zone | Game | Replaces | Rules | Reward (same as the game it replaces) |
|---|---|---|---|---|
| Gainlands | **Reps** | Rep Counter, Chet Thunderabs | One unit face up. Is the next card's power higher or lower? A tie is right. Eight in a row wins; a miss resets the streak; the fourth miss ends the set | First win: up to 210 gold, 70 XP, a Healing Salve, a Beefcake Pack. Later wins: up to 50 gold, 5 XP |
| Endless Buffet | **Order Up** | Order Up!, Chef Flambe | A ticket shows a total; pick cards from a row of six whose costs add up to it exactly. Three tickets; two swaps of the row; the third wrong plate ends the shift | First win: up to 210 gold, 70 XP, a Scroll of Insight, a Gourmand Pack. Later: up to 50 gold, 5 XP |
| Verdant Dump | **Sort It Out** | Sort It Out!, Recycle Rhonda | Twenty cards on a belt; send each to the bin of its type (Unit, Spell, Infrastructure, Other) before it falls off. Sixteen wins; the fifth lost card stops the belt. It speeds up gently (9 s a card at the start, 6.7 s at the end) | First win: up to 210 gold, 70 XP, a Healing Salve, a Refusemancer Pack. Later: up to 50 gold, 5 XP |
| D.N.A. | **File in Order** | Pneumatic Soul Routing, the Mail Room's terminal | Seven cards; put them in ascending cost (ties by power) by swapping two at a time, nine swaps at most. The stamp checks: the first wrong check is free and marks the cards out of place, the second is REJECTED | The Soul Courier's Lanyard, once. Replays pay nothing |

Stars count slips in a won game: none 3, one or two 2, more 1. The gold above is for 3 stars.

**Every game** uses the game's real cards (the zone's Path plus colourless), opens on a one-screen "How to play" with three lines
and a looping example, has a "?" to reopen it, ends on a win or lose panel with the reward, and can be played with mouse, keys or
controller. Reps sits on the painted gym; the other three on their zone's loading painting, blurred, in a wood and brass frame.

**Winnable on a first try:** Reps deals in the player's favour (someone who only guesses away from the nearer edge wins 84 % of
first sets; a coin flip wins 8 %). Every Order Up row holds a right answer, also after a swap. Seven cards never need more than
six swaps. Sort It Out allows four lost cards.

**Shots** (`p2_<game>_...png`, game = `reps`, `order`, `sort`, `file`): `_how`, `_mid`, `_win`, `_lose`, `_mid_720`,
`_mid_large_text`: 24 pictures.

**Also changed:** 18 lines of the hosts and signs that described the old rules; the D.N.A. spot is "Mail Room Filing Terminal".
No quest, feat or glossary entry named the old games. **Tests:** 17 for the rules, 12 for the screens. Rules and decisions:
`docs/design/card_minigames.md`.

## Part 3 - the Dump's entrance from Crosspath

| | Before | After |
|---|---|---|
| Default camera | `p3_gate_before_default.png`: two trees side by side as one flat card beside the path | `p3_gate_after_default.png` |
| Low camera | `p3_gate_before_low.png` | `p3_gate_after_low.png`: the arch over the path |
| At the travel prompt | `p3_gate_before_at_prompt.png` | `p3_gate_after_at_prompt.png`, `p3_gate_after_at_prompt_low.png` |
| Road still sealed | | `p3_gate_after_sealed.png`: the thorns alone across the forest road |

- One tree stands on each side of the path from town, turned toward it and leaning in 12.5 degrees; the tops cross over the path.
- The hero walks north through the arch to the travel prompt, the sign and Moss Mulligan, 4.4 m behind it.
- The flat two-tree card is not built any more. The three pieces are cut from the approved painting; nothing is newly painted.
- No tree is planted in the gate or within 6.5 m in front of it. I found no boulder that covers it (inbox 15).

## Part 4 - the Four Seals

| | Before | After |
|---|---|---|
| Locked | `p4_vault_before_locked.png` | `p4_vault_after_locked.png`, `p4_vault_after_locked_low.png` |
| 2 of 4 | `p4_vault_before_2of4.png` | `p4_vault_after_2of4.png`, `p4_vault_after_2of4_low.png` |
| 4 of 4 | | `p4_vault_after_4of4_low.png`: doors ajar, the quest marker, the map icon |
| Open (the Warden beaten) | | `p4_vault_after_open.png`, `p4_vault_after_open_low.png` |
| The toast | | `p4_toast.png` |

- **Placement:** a 1.75 m cellar door in a grassy bank (the old frame stood 4.75 m), a hedge on each side, an apple tree half in
  front, stepping stones up to it. Fieldstone, planks, beams, hedge and grass from the town's painted set. No purple.
- **Seals:** four round iron seals with a padlock. When a zone's lever is pulled, its seal turns to that Path's icon, with a small
  warm glow and a clunk, the next time the hero comes within 9 m. No colour lights; locked seals are identical. With all four the
  doors stand ajar; after the Warden they stand open.
- **Toast:** the Path's icon on an iron seal, "A seal turns in Crosspath", one line, "2 of 4" with four pips. About six seconds, or
  until clicked. The lever no longer holds the hero for three seconds.
- **Map and marker:** on the map and minimap from the first lever on (a padlock and the count). The quest step and its place line
  are reworded.

## Part 5 - the Buffet's edges

| | Before | After |
|---|---|---|
| Front edge | `p5_before_front.png`, `_low` | `p5_after_front.png`, `_low` |
| East side | `p5_before_east.png`, `p5_before_east_north.png`, `_low` | `p5_after_east.png`, `p5_after_east_north.png`, `_low` |
| Entrance | `p5_before_entrance.png`, `_low` | `p5_after_entrance.png`, `_low` |

- **Water:** the gravy lies all round the table at the river's level, 0.38 m under zero (the moat lay 2.6 m down, south side
  only). No slab side, step or blank band. A short wet shore runs under it; pebbles and crumbs lie along the water line; the shared
  water shader draws the foam.
- **East forest:** about 900 broccoli and cauliflower trees in four layers to the horizon, leeks and herbs at the front, cake
  stands, cloches and stock pots as boulders, on painted crumb soil. The gravy river runs on through it. It stands outside the
  table: nobody can walk there, and nothing on the table is behind a tree.
- **Alive:** 8 steam plumes, 9 butterflies, 4 birds, 14 warm light patches, swaying leaves. Low builds none of the first four.
- **Frame rate on Medium** (average fps, before -> after): beside the forest 102 -> 92, the front edge 83 -> 83, the bridge 86 -> 83.

## Part 6 - checks and build

| Check | Result |
|---|---|
| Crosspath walk smoke | **Pass** (the loop, 7 shop doors, the alley, the lakeshore, the hatch) |
| Buffet walk smoke | **Pass** (bridge to plaza, every NPC and game, the Freezer, the Test Kitchen, back to town) |
| Dump walk smoke | **Pass** |
| NPC visibility probe | **Pass**: 150 checks, 0 failed |
| Full test suite | **Not finished.** Shards 1 to 20 of 41: 1959 of 1960 passed, 0 failing (the one other is an old no-assert test). The run was in the background and the session's memory guard stopped it at shard 21 (1.1 GB of RAM free). I did not start it again: the guard's notice says not to |
| Export 1.0.0, the exported smoke, the three play checks | **Not run.** I did not build a release on a suite that had not finished |

**What did run for today's code.** Each of these test files passed on its own, in a fresh process: the Deck Station column (6) and
slots (6), the card games' rules (17) and screens (12), the Dump gate (5), the Four Seals (8) and the vault guardian (9), the
Buffet's edges (5) and its older slice tests (18), plus the screen-fit, controller-focus (19), music (23), Batch 13 (10), hub world
(5), Nov 14 (19) and Nov 15b (4) files they touch. Two caveats: the controller-focus, music and compile-every-script files ran after
Part 2 and not again after Parts 3 to 5; and the UI and world test folders sit in shards 21 to 41, so only the files named here
are covered from those.

**The zip.** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-windows.zip` is last night's build. Do not upload it as
today's.

## Part 7 - art for the next batch

Seven items added to `docs/art/batch17_nov16.csv` and `docs/prompts/chatgpt_batch17.md` (items 15 to 21; Batch 17 is now 21 items,
65 images):

| Item | Pictures |
|---|---|
| The cellar door of the Four Seals, closed and open | 2 |
| An iron seal, locked and blank | 2 |
| Minigame rooms: the kitchen pass, the fair's conveyor, the mail room | 3 |
| Reps: bench, barbell, four plates | 6 |
| Ticket, bell, four bins, filing cabinet, APPROVED and REJECTED stamps | 9 |
| The Dump's gate as one grown arch; the withered thorns without trees | 2 |
| The Buffet's forest: fruit tart, tall cake stand, a sheet of butterflies and birds | 3 |

---

# Overnight Nov 15-16 - report: Batch 16, the open items, save safety, fresh eyes, Batch 17, 1.0.0

Brief: `docs/prompts/fable_nov16_overnight.md`. Start tag `pre-overnight-nov16`. Questions: `docs/overnight_inbox.md`, "Overnight Nov
16" (16 items). Shots: `docs/overnight_shots/nov16/`. No public upload. No difficulty setting, no battle-board change, Primm's fight
untouched, no approved art repainted. Ran on Fable 5.2. The Fable Nov 15b report follows below.

## In short

- **Batch 16 is in the game: all 46 pictures**, each wired, shot and checked against the Path icon guide. **Fig Sly has two hands**
  in his shop and in his dialogue.
- **The open items:** five of the nine needed work and four of those are done (the Dump's fair stage, the Dump's south corners, the
  minimap, Crosspath's south edge). **The Capital's load time is not improved** (see Part 2). The other four were done already.
- **A test run can no longer write your saves.** It is blocked under every file call of the save system and checked from outside
  on every run.
- **Four fresh-eyes sittings** on the exported build: first hour 6 / 6 / 7, midgame 7 / 6 / 7, late game 5 / 6 / 6, and a fourth for
  what those three missed, 7 / 7 / 6 (clarity / fun / polish). 19 findings fixed, the rest triaged and logged.
- **Batch 17 is prepared:** 14 items, 38 pictures.
- **Tests:** all 40 shards after the last change of the night: **3151 of 3153 passed, 0 failing**, 2 risky (the two old no-assert tests).
- **The zip:** `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-windows.zip`, 783,638,031 bytes (784 MB), built Nov 16 04:21.
  The exported smoke prints PASSED (1.0.0); the three exported play checks ran to "done" with 0 script errors. Not uploaded.

## What you must still do before uploading

1. **Play the first ten minutes of the zip yourself**, and one fight. The checks cover the title, the menus, a new game and a save;
   they are not a playthrough.
2. **Look at five things I changed where taste matters:** Crosspath's south edge (tree crowns in the ravine), the Dump's two south
   corners (the camera holds in and the hero stands off-centre), the minimap and the full map (drawn differently), the Feats page's
   new "Path feats" heading, and Fig Sly's changed price line (inbox 9).
3. **Read inbox items 9 to 14.** They are the choices only you can make: five story lines critics flagged, the smiling-sun banners
   still on the freed Capital's wall, the ending that nothing tracks after Primm falls, the roofs over Maren's home.
4. **Use the new logo files** in `docs/release/itch_page/logo/` for the page (cover, banner, icon). The older ITCH-COVER and STEAM-*
   pictures on the Drive carry the old logo.
5. **Then the usual:** `docs/release/itch_upload.md`.

Nothing here blocks the upload. The zip's own icon is the new app icon.

## Part 1 - Batch 16 (46 pictures, all in the game)

The full table with every picture, its place, its shot and its check against the icon guide is `docs/art/import_nov16_batch16.md`.

| Pictures | In the game as | Shot (`docs/overnight_shots/nov16/b16_...`) |
|---|---|---|
| V-FIGSLY | Fig Sly's shop portrait and dialogue portrait. **Two hands** (one on the lapel, one at his side); a critic counted two as well | `figsly_shop`, `dlg_npc_V-FIGSLY` |
| STORY-MEMORY-3, -4, STORY-REUNION, STORY-EPI-FILE-COMPLETE | Their story scenes. The crest reads arm, chef's hat, leaf, skull clockwise from the top; each banner carries one icon | `still_STORY-*_1600x900` |
| NPC-SCUFF, CUT-SCUFF, BST-ENFORCER-SERGEANT-SCUFF | Sergeant Scuff's portrait, boss cut-out and Bestiary square. The Correction Officer stand-ins are gone | `dlg_npc_NPC-SCUFF`, `bestiary_scuff` |
| UI-CARDBACK-B, -N | The Beefcake and Necrocrat card backs | `battle_backs` |
| ICON-FEAT-PATHS | A "Path feats" heading on the Feats page, above the four one-Path groups (inbox 1) | `feats` |
| DEC-PLINTH-* (4) | The four plinth statues round Crosspath's fountain | `town_square_freed` |
| TOWN-SHEET-FREED-BANNERS-01..06 | 01 to 04 one per freed zone; **05 and 06 hang for the first time**, once all four zones are free (inbox 2) | `town_square_freed` |
| CAP-BANNER-FREED-03, -04 | The freed Capital's Refusemancer and Necrocrat banners | (same places as the Batch 15 shots) |
| LOGO-EMBLEM, LOGO-WORDMARK, APP-ICON | The title, loading and pause screens, the credits, the window icon, the **Windows export icon** (`assets/icon/app_icon.ico`), the itch page kit | `title`, `credits` |
| TOWN-PROP-SHORE-STONES-01..03 | Crosspath's lake bank, in place of the modelled stones | `lakeshore` |
| CAP-PROP-CREASE-STALL-01, -02, -CRATES | The Crease market: Fig Sly in front of stall 01, the supply stall beside it, five crate stacks | `crease_market` |
| SPR-RESCUER-*_WALK (5) | The Rescuer walks away in her own masked frames (mirrored, normal maps, Elowen's scale) | `rescuer_walk` |
| NPC-QUADZILLA, NPC-CAIRN | Baron Quadzilla's and the Restless Cairn's lines | `dlg_npc_NPC-QUADZILLA`, `dlg_npc_NPC-CAIRN` |
| DNA-PROP-CRATES, DNA-PROP-CABINET-TIPPED | The debris outside the D.N.A. | `dna_debris` |
| UI-PACK-GILDED-G / -N / -R, UI-PACK-N, UI-PACK-R | Their packs. The code-drawn icon is off for these five: the paintings carry the right medallion, whole and centred (inbox 3) | `packs_all` |

**Against the icon guide:** every Path sign in the 46 pictures is the canonical icon. Two notes: the feats badge is a shield, not the
hexagon asked for; the gilded packs came with painted medallions, not the plain disc asked for. Both are right as painted.

**Size** (`docs/build_size_policy.md`): the zip went from 778.1 MB (Nov 15) to 783.6 MB, **5.6 MB more**. The pack is 860.5 MB, over
the 750 MB warning as before, on purpose (music at q6). Source art in `assets/`: +6.8 MB.

## Part 2 - the open items

| # | Item | Result | Shots (`p2_...`) |
|---|---|---|---|
| 1 | The Dump's fair stage | **Done.** Four plank sorting bins with something sorted in each, painted cloth bunting in two rows, a plank sign board for the icon. No flat blue banner, no flat bins | `fair_stage_before`, `fair_stage_after` |
| 2 | The Dump's two south corners | **Done.** The Nov 13 fix had left a pale wedge on the default camera. The camera now holds in from the side rims in the Dump's southern 18 m (inbox 5). Low camera was clean | `dump_se_default_before` / `_after`, `dump_sw_default_before` / `_after`, `dump_se_low`, `dump_sw_low` |
| 3 | The Tidy-Bots' tell | **Done already** (Nov 13: they stop, flash twice and sound an alert) | |
| 4 | The Crease's east wall | **Done already** (a quarter of the frame when the hero hugs it) | `crease_east` |
| 5 | The Wanderer's portrait edge | **Done already** (feathered) | |
| 6 | The Capital's map | **Done already**: district names (they appear as you explore), the Crease as its own inset, labels that do not stack. Tonight the map also writes short names | `capital_map` |
| 7 | The minimap | **Done.** Drawn by a new shader: crisp edges in the forest, the Capital's stair-steps become slanted lines and rounded corners. The full map uses it too | `minimap_forest_before` / `_after`, `minimap_capital_before` / `_after`, `p4_map_*_after` |
| 8 | Crosspath's south edge | **Done.** The flat violet band is a wooded ravine: tree crowns rise out of the cleft, their tops under the camera's line to the hero (inbox 6) | `crosspath_south_before` / `_after`, `crosspath_south_low_before` / `_after` |
| 9 | The Capital's later-visit load | **Not done: about 6 s before and after.** Storing the rim ruins cut their step from 0.45 s to 0.1 s (6.12 s to 6.02 s for the visit), but with them stored the Capital walk smoke could not walk to Rollo; so did storing four landmark models. Both are built live again. The numbers of what is left are in inbox 7 | |

## Part 3 - your saves are safe from test runs

- **How it is blocked.** `SaveGuard` (`core/data/save_guard.gd`) sits under every file call of the save system. In a test run, a path
  into your save folder becomes the same path under `user://test_saves/` before anything is opened, written, renamed or deleted. It
  does not matter what a test sets, or which flags the run was started with.
- **What is protected:** all three campaigns, every slot, the autosave, backups and thumbnails; the old `save.json`; the account's
  feats; the title screen's memory; and, in a test run, the settings.
- **The test that fails if a run touches the real folder:** `tests/test_save_guard.gd` tries every old way in on purpose and compares
  your real files with how they were when the run started.
- **The check from outside:** `tools/run_tests.sh` lists your real folder before the first shard and after the last, prints `Real
  saves: untouched (14 files checked)` and fails the run if anything changed.
- **The exported play runs are covered too.** They used to read your real campaigns (and one check pressed Save Game on them). They
  now start like a fresh install and save in the test folder (inbox 15).
- **Documented:** `docs/HANDOFF.md`, section 2b.
- **The full suite ran three times tonight**, the last time after the last code change.

## Part 4 - fresh eyes on the exported build

Each critic had one brief and nothing else: no repo, no reports. Reports and the full triage: `docs/review/critic_nov16/`.

| Sitting | Clarity | Fun | Polish | Top issues it found |
|---|---|---|---|---|
| 1. The first hour | 6 | 6 | 7 | Blurry, blocky maps; a reward card that "joins your deck" and is gone after a loss; one loss restarts the cave; the Dump pennant's single leaf |
| 2. The midgame | 7 | 6 | 7 | Dex cannot be found; the Refusemancer card back is not the Path icon; pack notices cover the result; "Fifty gold" against 360; the way out of the Buffet square is not shown |
| 3. The late game | 5 | 6 | 6 | The tunnels' mural and board show a sun, a wave, a sprig and a flame; the freed Capital still flies the smiling sun; nothing tracks the ending after Primm; no map marker for the manhole |
| 4. What the three missed | 7 | 7 | 6 | On Primm's defeat panel E left the castle; Maren's stick shows the wrong four signs; roofs over Maren's home; memory text over the picture |

**The story checks hold** (sitting 4 read them line by line): Maren's failing eyes, and that she does not know him until the fourth
memory; bars, never glass; "Tessar" first in the fourth memory, with the name plate changing then. **The icons hold** on every crest,
pack, banner and logo the critics saw. Wrong signs were found only in older art: the tunnels' map and board, three card backs,
Maren's stick, a Dump pennant. All are Batch 17 rows.

**Fixed (19):**

- Cards won in a lost first cave stay in the deck (inbox 10).
- C, B, P and T close the page they open.
- On Primm's defeat panel the key presses the lit button, "Fight Primm again". It always left the castle.
- The full map is crisp and writes short names. Dex is on every zone's map and list. The manhole to the Crease stays on the map.
- The Dump's entrance pennants are the paw print, not a single leaf.
- The pack result drops the notices that covered it; NEW! sits above the card; "at its copy cap" replaces "you own 4".
- "Plated Just So" has its own icon; Fig's price line; the item subtitle; the clear bonus line; "Guarded gate" for "Golem gate".
- No forest banner under the cave-loss notice. The Well takes its own icon as soon as Batch 17 brings it.

**Not the game, the test (7):** the Dev Shrine in town, "no marker for Maren", the hero who stopped moving, "Turn 1 on turn 6" and
three more came from the test pack's debug binary, from debug jumps into states the game cannot reach, or from the scripted player. I
checked the first three in a normal save. They are marked in the triage.

**Logged, not fixed:** every M and L item, and the S items that are your lines or your rules. The ones worth your time are inbox 11
to 14. **No sitting reached the credits**; the ending was read up to "File Complete".

## Part 5 - Batch 17 (prepared only)

`docs/art/batch17_nov16.csv`, `docs/prompts/chatgpt_batch17.md`, 67 numbered references in `G:/My Drive/Card Game Art/Batch 17
References/`. Rebuild with `python tools/art/batch17_build.py`. **14 items, 38 pictures:**

| # | Item | Pictures | Why |
|---|---|---|---|
| 1-5 | The five ruler statues in stone, each standing and toppled: Clench, the Grand Chef, Mortimer, Compostella, Primm | 10 | Asked for; they are a grey-tinted flat picture today |
| 6 | ICON-NODE-WELL | 1 | Critic: the Well's pop-up shows playing cards. The game uses it by itself once imported |
| 7 | UI-CARDBACK-R, -G, -C | 3 | Critic: not the Path icons (I checked all five backs) |
| 8 | MAP-S-CAP, BB-S-CAP | 2 | Critic: the tunnels' mural and board show the old four signs |
| 9 | NPC-ELDER and its two expressions | 3 | Critic: Maren's stick shows a sun, a sprig, a moon and a drop |
| 10 | Two Dump entrance pennants with the real icon | 2 | Critic: the single leaf (the game hangs paw prints meanwhile) |
| 11 | The six painted world maps | 6 | Critic, twice: blocky maps. Carried over from Batch 15. The biggest item; it can wait |
| 12 | CUT-QUADZILLA | 1 | He is a speaking boss now and has no cut-out (inbox 4) |
| 13 | UI-PACK-G, UI-PACK-GILDED-B | 2 | The last two packs off the guide; the code icon can go once they are in |
| 14 | The eight echo Bestiary pictures | 8 | Carried over from Batch 15: the only Bestiary pictures missing |

**Still marked REDO: nothing.** The statue poses in the prompt are written from the five cut-outs, which I looked at.

## Part 6 - tests, the build, the release kit

- **Tests:** 40 shards, 3151 of 3153 passed, 0 failing, 2 risky, real saves untouched (14 files checked). Run in full three times; the last run (25 minutes, ended 04:56) came after the last code change. The export was built from that same code. The same two no-assert tests as before are the "risky" ones.
- **Walk smokes:** the Dump's and Crosspath's pass. The Capital's passes on the final code (it is what caught the two caches).
- **The export:** free memory stayed under 2.2 GB for the ten-minute wait (1.7 GB), so it ran with the low-memory flag, in the
  foreground: `EXPORT OK`. Peak 1.65 GB.
- **Exported smoke:** PASSED (1.0.0). **Three exported play checks:** all ran to "done"; `SCRIPT ERROR` count 0 in all six logs. Check
  B's save and load steps no longer run (inbox 15).
- **The itch page kit:** `logo/` (cover 630x500, banner, wordmark, emblem, app icon), `screenshots/nov16/` (six fresh pictures with a
  README), `page.md` updated. `docs/release/ship_checklist.md`, `v1.0.0_notes.md` and `CHANGELOG.md` updated.
- **A test build was exported twice during the night** for the critics. Its zip, `builds/TheWaywardPath-v1.0.0-test-nov16-windows.zip`
  (787 MB), is still there: delete it when you like. It is not the release.

## Not done / still open

- The Capital's load time (Part 2, item 9).
- The credits were not seen by a critic.
- The triage's "Logged" rows: about 45, most of them small.
- One slip of mine, in inbox 16: for 17 minutes I ran the game beside a critic's last runs.

---

# Fable Nov 15b - report: the hour pass (verify, your answers, small fixes)

Brief: `docs/prompts/fable_nov15_hour.md`. Start tag `pre-fable-nov15b`. Questions: `docs/overnight_inbox.md`, "Fable Nov 15b" (7 items).
Shots: `docs/overnight_shots/nov15b/`. One Godot at a time, no sub-agents. No public upload. Primm's fight, the battle board and the
difficulty are untouched. Ran on Fable 5.2, Nov 15 (evening). The Fable Nov 15 report follows below.

## In short

- **Both Dump objects from your screenshots are found and fixed.** Neither was what last pass removed. The "floating door" was the
  **fridge** by the market; the "wooden block" was the **giant root ramp's slab, tilted the wrong way**.
- **Primm's rule line shows once** (its phase badge); everything else in your answers was "keep as built".
- **Walk smokes:** the Gainlands', the Buffet's and the Dump's pass. The statue shots found **Compostella's statue standing inside
  the Dump's Rift Station**; it is moved.
- **UI scale:** the Wardrobe, the Card Packs page and the Deck Station no longer crop at 115 % and 130 %. They are held at 100 %
  (the fallback in the brief), not rebuilt.
- **Tests:** all 40 shards ran: 3121 of 3124 passed, **1 failing**, 2 pending (the same two as before). The one failure was mine (the new rocks by the fridge chest stood too near the lever); I moved them and re-ran that file and the three other Dump and pass files: 89 of 89 pass. The full suite was not run a second time after that one-line layout change. The memory guard stopped the background run after shard 17; shards 18 to 40 were finished in the foreground.
- **The zip:** **rebuilt.** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-windows.zip`, 778,087,866 bytes (778 MB), built Nov 15 19:48. Free memory stayed at 2.0 to 2.15 GB for the whole 10-minute wait (the rule is 2.2), so the export ran with the low-memory flag, as the brief says: `EXPORT OK`. The exported smoke prints PASSED (1.0.0); the three exported play checks ran to "done" and their six logs hold 0 script errors. Not uploaded anywhere.

## The parts

| Part | What | Result | Shots |
|---|---|---|---|
| 1 | Your answers | Primm's duplicate rule line removed from the gold panel; nothing else needed a change (the Gate Plaza and palace-approach signs already show the purple swirl) | none (a test pins it) |
| 2 | The Dump against your screenshots | Fridge removed, ramp fixed, tree wall re-checked | `ref_dump_*` (yours), `p2_fridge_before` / `_after`, `p2_ramp_before` / `_after`, `p2_treasure_field`, `p2_top_right_tree_wall` |
| 3 | Three walk smokes + statue shots | All three pass; one real find (the Dump's statue) | `p3_statue_<zone>_standing` / `_toppled`, `p3_statue_heap_standing_before` |
| 4 | UI scale 130 % | Nothing cropped at 115 % or 130 %; held at 100 % | `p4_wardrobe_*`, `p4_packs_all_*`, `p4_deck_*` (10 = 100 %, 115, 13 = 130 %) |
| 5 | Tests, build, report | see "In short" | |

## Part 1 - your answers

- **Primm's rule shows once.** His phase badges stay; the gold "Primm's rule" panel under the HUD no longer repeats the same line
  (`BattleHud.rule_text_is_shown`). The panel still appears for a phase rule that has no badge, so nothing can go unshown. Nothing
  else in his fight changed.
- **Kept as built:** Nov 15 items 1, 2, 3, 5, 6, 7, 8 and Nov 14 items 2, 3, 4, 5, 6, 8, 9, 11, 12. No code change.
- **Nov 14 item 7:** the two signs already carry the purple travel swirl; no change.

## Part 2 - the Verdant Dump

- **The "floating door" (`ref_dump_floating_door.png`) was the fridge** in the market's east corner, at (77, 132). It was turned so the
  walk saw its blank green back and its open door: one thick slab and one thin one. Removed. Its chest (the Leaf Crown) is still
  there, with rocks, a bush, mushrooms and flowers along the rim behind it.
- **The "wooden block" (`ref_dump_wooden_block.png`) was the giant root ramp** from the farm terrace up to the compost terrace, at
  x 62 to 67, z 54 to 70. Its bark slab was rotated the wrong way: the foot stood 3.5 m up in the air on the rope posts, the head
  was buried, and the walk went up the slope through it. One sign flipped (`HeapTerraces.root_ramp`); it lies on the slope now. A
  test checks the foot is on the lower terrace and the head on the upper one. I fixed it instead of removing it, because it is one
  of the three ways up (inbox 1).
- **Last pass's removals** (the hay bale by the barn, the hollow log) were neither of these. They stay removed.
- **The top-right tree wall:** the walk-grid flood test still finds no walker cell in the treasure field, and the four treasure
  chests are reached on the mount only. The field's shot is `p2_treasure_field.png`: four chests with their glow in open ground.
- **New tool:** `tools/heap_plain_probe.gd` lists the Dump's meshes with their colour, or every mesh in a rectangle
  (`HEAP_PROBE_RECT="x0,z0,x1,z1"`). `tools/heap_odd_probe.gd` could not see either object: the fridge sits on the ground, and the
  ramp is longer than its slab limit.

## Part 3 - walk smokes and statues

- **Gainlands:** OK. **Verdant Dump:** OK (run again after the statue moved: OK).
- **Endless Buffet:** failed first on two steps, both faults of the smoke (written Oct 18, the zone has moved since): Odalys' prompt
  was checked from the edge of her wide spot, where Dolcetta's is nearer, and the heal table's run-up started behind the ruler
  statue. The smoke now steps in closer and checks its run-up is clear. It passes.
- **The Dump's statue stood inside the Rift Station** (`p3_statue_heap_standing_before.png`): the default spot was (41, 129), the
  station is at (42, 130). It stands in the open plaza at (44.5, 126.5) now (`HeapZone` `statue_offset`).
- The Gainlands' and the Buffet's statues stand clear, standing and toppled.
- `--at=xz:<x>,<z>` now works for shots in every zone (it was the Dump's only).

## Part 4 - UI scale

- All three screens fill the whole 1920x1080 canvas. The Wardrobe and the Card Packs page are laid out at fixed positions; the Deck
  Station re-flowed, but between its racks the deck list had one row at 115 % and two at 130 %.
- Each now tells `UiScale.fit` it needs the whole canvas, so the screen is held at 100 % while the setting is higher. At 100 % nothing
  changed. This is the brief's fallback (cap the scale on that screen); a real larger layout needs scrolling pages (inbox 4).
- A test opens all three at 130 % and checks the factor is 1.0.

## Not done / still open

- A second full test run after the last layout fix (see Tests above). The play checks cover the first minutes, the menus and a save, not a playthrough: play the Dump's market and the root ramp yourself before uploading.
- The fair stage's plain-colour blocks on the farm terrace (inbox 6).
- Batch 16 is still waiting on its images.

---

# Fable Nov 15 - report: the owner's four fixes

Brief: `docs/prompts/fable_nov15_fixes.md`. Start tag `pre-fable-nov15`. Questions: `docs/overnight_inbox.md`, "Fable Nov 15" (10 items).
One Godot at a time, no sub-agents. No public upload. No difficulty setting, no battle-board change, Primm's fight untouched. Ran on
Fable 5.2, Nov 15. The Fable Nov 14 report follows below.

## In short

- **Parts 1, 2, 3, 4 and 4b are done**, each committed and pushed with before/after shots in `docs/overnight_shots/nov15/`.
- **Part 5 (Batch 16) was skipped as told**: the images are not made yet. Three pack-art rows were added to its list (below).
- **Tests: all 40 shards green, 3118 of 3120 passing, 0 failing** (2 risky: the same two no-assert tests as before). The background run
  was stopped by the low-memory guard after shard 36; shards 37 to 40 were finished in the foreground, as the house rules say.
- **Walk smokes:** the D.N.A.'s (run twice: after Part 1 and at the end), Crosspath's and the Capital's all pass.
- **The 1.0.0 zip:** **built.** `builds/TheWaywardPath-v1.0.0-windows.zip`, 778 MB (742 MiB). The exported smoke prints PASSED (1.0.0) and the three exported play checks finish with 0 script errors. Not uploaded anywhere.
- **Look at these first:** the "Before the fight" card now opens for roamers that carry a rule of their own (inbox 2); the early-zone
  ease is now a visible badge (inbox 3); the D.N.A.'s far skyline is switched on (inbox 7).

## The 1.0.0 zip

**`C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-windows.zip`** (778,089,162 bytes, built Nov 15 14:05). This is the first 1.0.0
zip: the Nov 13 and Nov 14 passes could not build one for lack of memory.

- Free memory was 2.22 GB when I checked (the rule is 2.2), so the export ran at once, in the foreground: `EXPORT OK`.
- `bash tools/run_release_smoke_exported.sh`: **PASSED (1.0.0)** (no Dev Menu, save and load work).
- The three exported play checks (`exported_rc1_a`, `_b`, `_c`) ran to "done"; `grep -c "SCRIPT ERROR"` on their six logs prints 0 six times.
- This is also the first time the Nov 13 dialogue rewrite, Batch 15 and the Nov 14 pass have run as an exe. The play checks cover the
  first minutes, the menus and a save; they are not a playthrough. **Play the first ten minutes yourself before uploading.**

## The parts

| Part | What | Done? | Shots (`docs/overnight_shots/nov15/`) |
|---|---|---|---|
| 1 | Outside the D.N.A.: a wasteland like the Capital's | **Done.** 76.7 fps on Medium (79 before) | `ref_capital_wasteland` (yours), `p1_ref_capital_gate_mine`, `p1_dna_*_before` / `_after` (six cameras) |
| 2 | Mortimer Grimsby off the Rift Station | **Done.** He has one spot (he only appears once the zone is freed) | `p2_mortimer_before`, `p2_mortimer_after`, `_zoom`, `p2_mortimer_after_prompt` |
| 3 | 3D and placeholder NPCs | **Done.** Two kinds found, both fixed; the scan is clean | `p3_pip_before` / `_after`, `p3_statue_gainlands_*`, `p3_npc_3d_scan_report.txt` |
| 4 | Every fight shows every rule in effect | **Done.** 48 of 118 fights were missing a rule | `p4_officer_before_the_fight_after`, `p4_officer_rule_icon_hover_after` |
| 4b | Shop scrollbars, the pack medallion, the pack icons | **Done**; the foil pattern needs art (Batch 16) | `p4b_*` |
| 5 | Import Batch 16 | **Skipped as told** (not made yet) | |
| 6 | Verify and build | see "In short" | |

## Part 1 - outside the D.N.A.

Your reference and my own matching shot of the Capital's gate approach are `ref_capital_wasteland.png` and
`p1_ref_capital_gate_mine.png`. Six fixed cameras were shot before and after (`bash tools/dna_outside_shots.sh before|after`): the
arrival, the causeway, the lobby's west and east sides, and the west and east edges of the main block.

- **The ground is the Capital's.** The grey 4 m tiles are gone. The endless ground is the Capital's cracked ash (`TEX-CAP-ASH`) with
  soft patches of its broken paving (`TEX-CAP-CRACKEDROAD`), tinted grey-green, sampled at two scales so no repeat shows.
- **The Capital's wasteland kit, composed, never in rows** (`world/dna/dna_wasteland.gd`). On Medium: 21 stretches of broken low wall,
  7 ruined house shells further out, 35 rubble mounds, rubble rows at the feet of the south walls, 54 dead trees, 21 purple crystal
  clusters, ash drifts, 465 dark tufts of dead grass, 9 old dead lamp posts (six of them a loose avenue beside the causeway, like
  the Capital's gate road) and 3 fallen statues. High has a few more (72 trees, 28 crystals, 12 lamps, 620 tufts). All tinted toward
  the D.N.A.'s grey-green; the crystals keep their purple.
- **Office touches kept as debris:** four tipped cabinets, two leaning filing towers and four drifts of forms. The rows of cabinets,
  crates, queue posts and towers are deleted.
- **The floating paper is untouched** (380 sheets, the same field).
- **Edges and fog:** the fog is the Capital's density (0.0065, was 0.005), and the zone's far skyline (its tower backdrop, which was in
  the data but switched off) now stands behind the ground in every direction, so the ground never ends in a bare horizon (inbox 7).
- **Nothing blocks the view or the way:** every piece stands off the floor and its walls, off the causeway and clear of the Filing
  Tower, the Endless Queue, the Records Stair and the Hall; nothing is solid; and a piece with floor to its north may only stand as
  high as the camera's line allows (the Capital rim's rule). The spots nearest the buildings are filled first, so the budget is spent
  where it is seen.
- **Frame rate on Medium: 76.7 fps** at the arrival (79 after Nov 14, 81 before that).
- **When Batch 16's D.N.A. crates and tipped cabinet arrive** they replace the turned cabinet cards in `DnaWasteland.OFFICE_DEBRIS`.

## Part 2 - Mortimer Grimsby

He stood at (49.1, 55.7), 0.6 m from the Rift Station at (48.5, 55.5): the station was placed on his old spot. He now stands at
**(41.0, 54.4)**, on the open floor of the lobby's west side: 7.6 m from the station, clear of the west passage, and more than 2.5 m
from every NPC, prop, counter and prompt in the room (a test checks each one, and open floor all round him).

- He has **one spot**: he is only in the lobby once the zone is freed (the statue stands in for him before that).
- **Name label, talk prompt, bark:** `p2_mortimer_after_prompt.png` (his label, Prudence's and Agnes's are separate; "[E] Talk" shows).
- **NPC visibility probe** (freed D.N.A., both cameras): **20 checks, 0 failed**, Mortimer included. The probe can now free a zone first
  (`NPC_FREED=necrocrat`), which it could not before, so the freed lobby's people had never been probed.
- **NPC overlap probe** (freed): Mortimer is not flagged; no pair of NPCs is closer than 1.2 m.

## Part 3 - 3D and placeholder NPCs

**What was found** (the scan: `bash tools/run_npc_3d_scan.sh`, 17 area states: the forest in four states, Crosspath oppressed and
freed, each of the four zones oppressed and freed, the Capital outside, inside and freed; it reports every rigged 3D model and every
capsule a metre or more tall):

| Where | What it was | What I did |
|---|---|---|
| Crosspath, beside Pip Threadwell (36.4, 6.5) | Her "window mannequin": the blocky 3D hero model in a party hat, with no talk prompt | **Removed** (inbox 6) |
| The Gainlands' hub (49.5, 83.0) | The ruler's statue: a red capsule with a ball for a head, a box for a cape | **Replaced** with Chancellor Clench's painted figure in stone |
| The Endless Buffet's hub (41.0, 67.0) | The same capsule statue | **Replaced** (the Doppelganger, as the Grand Chef) |
| The D.N.A.'s hub, the Verdant Dump's hub, the Capital | The same capsule statue (standing, or toppled once the zone is freed) | **Replaced** (Mortimer, Compostella, Primm) |

- **Nothing else.** After the fixes the scan finds **0 figures in all 17 states**. Every roamer, vendor, quest giver, freed leader and
  stroller is a painted sprite. (The ambient animals of the Dump are props, not people, and were left alone.)
- **The statue** is the boss's painted entrance cut-out through a stone shader, on the same plinth with the same plaque: standing while
  the zone is oppressed, lying beside the plinth once it is freed (`p3_statue_gainlands_after_zoom.png`). Inbox 5.
- **The check:** `tests/test_fable_nov15.gd` fails if any zone NPC or freed-lobby NPC, or anyone Crosspath places, does not resolve to
  an imported painted sprite set, and if a ruler statue contains a capsule or a sphere. The scan script exits 1 on any figure.

## Part 4 - every fight shows every rule in effect

**The Correction Officer.** The +1/+1 was not his: any Capital roamer whose post is within 9 m of an open rift fights with +1/+1 on its
units and 3 more HP. It was applied with no word anywhere. Now:

- the rule is **Rift-Empowered** ("This foe stood beside an open rift: its units get +1/+1 and it has 3 more HP. Seal the rift (or fight
  its guards away from it) and the next ones fight as normal.");
- a roamer that carries it shows the **"Before the fight" card** before the duel (`p4_officer_before_the_fight_after.png`), and the rule
  is one of the **fight's rule icons**, with its hover text (`p4_officer_rule_icon_hover_after.png`);
- its units carry the +1/+1 as the ordinary stat bonus, so their numbers show green over the base value like any other buff.
- I named it for its real cause rather than "Regime Drill" (inbox 1).

**The audit.** `tests/test_rule_audit.gd` builds **all 118 fights** with the game's own code (every roamer of every zone, the Capital's
also beside a rift; every fight room of all 16 dungeons (the tutorial cave, the Gallery and the Lab among them), the four Path zones entered as a first zone; Primm's three phases; the
gatekeepers; Crosspath's roamers; the Graveyard, Shiro, the vault, the Old Well, the store room; the eight arena bouts; Quota's rematch;
Captain Spotless at the gate). Each seat now remembers where its modifiers came from, and each rule badge says which modifiers it
stands for. The test fails for any modifier on a seat (beyond the player's own gear and items) that no shown badge covers.

**Encounters that were missing a rule: 48 of 118.** The full before and after lists are `docs/review/rule_audit_nov15_before.json` and
`_after.json`.

| Applied, not shown | Fights | Which | Now shown as |
|---|---|---|---|
| The early-zone ease: -1 or -2 attack on the foe's units (and less HP) | 39 | In a first-zone visit: the D.N.A. (2 roamers, 7 Hall rooms, 3 side-dungeon rooms), the Buffet (2, 7, 3), the Dump (2, 7, 3), and the gatekeepers Prudence Pallor, Chef Fennel Gravois and Moss Mulligan | **Caught Unprepared** (green: it helps you). Inbox 3 |
| A rift's empowering: +1/+1, +3 HP | 3 | The Correction Officer, the Perfection Inspector and the Rift Wretch, beside an open rift | **Rift-Empowered** |
| Primm's phase rules (units become 3/3 and you may play two cards a turn; he draws 2 more; +3/+3, 1 more draw, he loses HP each turn) | 3 | Primm, phases 1, 2 and 3 | **Standardization / Reflection / Unraveling**, one badge each, with the phase's existing rule line. They were only on the gold panel under the HUD. The fight is unchanged (inbox 4) |
| An escalating summon at the start of each of its turns | 2 | The Graveyard (the Restless Cairn) and the Four-Seal Vault's Warden | **The Graveyard Will Not Stay Quiet**, **The Seals Send Guardians** |
| "No unit plays" on the player | 1 | The arena's spells-only bout (the Cardboard Colossus) | **Spells Only** |

After the fixes: **0 of 118**.

- **Also listed now** (they are not modifiers, so the audit cannot see them; I added them by hand): Grandmaster Flex and Elowen Vey
  fighting beside you when rescued, the Rotheart's 6 lost HP after you cut the Heart Roots, and a freed zone's friendly rematch (a
  two-Path deck, 10 more HP).
- **Hidden traits** stay "?" and are listed: every one of the 35 encounters with an unseen scripted trigger shows exactly one "Hidden
  trait ?" chip that stands for all of them (a test).
- **No rule is shown without being applied:** every dungeon rule in the list has its modifiers.
- **Three other fights with modifiers checked by eye:** covered by the audit rows and the existing boss-rules tests; I did not take
  separate screenshots of them.

## Part 4b - shops and pack opening

**1. Scrollbars.**

- **Fig's Gilded Goods.** The row asked for a fixed 1780 px, wider than its panel beside the vendor, so it was clipped at the panel's
  edge with no bar (`p4b_fig_packs_large_before.png`). The row now takes the room there is. The tiles are their real 236 px (the name
  wraps, the two buttons stack), so **all four packs fit at the default and at Large text**, at 1280x720 and 1920x1080
  (`p4b_fig_packs_default_after`, `p4b_fig_packs_large_1080_after`, `p4b_fig_packs_large_720_after`).
- **When they do not fit** (UI scale 130 %: `p4b_fig_packs_ui130_after.png`) a **gold scrollbar** shows under the row. The mouse wheel
  moves the row sideways, the bar drags, and a controller's left / right brings the next pack into view (the row follows the focus).
  If the tiles are also too tall for the screen the row scrolls up and down too, so the buttons can always be reached.
- **Every list.** The theme's scrollbar was a 35 % black track with no edge, invisible on dark wood. It is now a framed track 14 px
  thick with the gold grabber, in every list of the game (vendor tabs, the Deck Station, the Collection Book, item lists, the quest
  log, Settings).
- **The same shop row** (`ScrollKit.row`) is on the Card Packs shelf and its results row, the Wardrobe's hat and cloak rows and the Deck
  Station's cover picker. **The Card Packs shelf had the same fault as Fig's shop in another form:** its bar sat below the panel's edge
  and was never seen, and a Gilded pack's Open button was cut off. Both are fixed (`p4b_card_packs_shelf_after.png`).
- **Checked at Large text, 1280x720:** the Wardrobe, the Deck Station, the Card Packs page, the Collection Book
  (`p4b_lists_large_720_after.png`), and at 1600x900 the card, item, gear, hat and pack vendors. No content is cut without a bar.
- **Not fixed:** at a UI scale of 130 % the Wardrobe, the Card Packs page and the Deck Station are cropped at the right and bottom, as
  before this pass (inbox 10).

**2. The medallion.** The Gilded pack's medallion was a square cut out of the Path Pack's painting and scaled up, so the circle cut its
bottom off. It is now the Path's icon itself, whole, centred on the medallion and inside the gold ring, on every Path Pack and every
Gilded pack, in the shops, on the shelf and on the opening screen (`p4b_pack_opening_necrocrat_after.png`). The General and Prismatic
packs keep their own painted centres (they belong to no Path).

**3. The icons, against `docs/art/path_icon_style_guide.md`** (`p4b_pack_art_before_sheet.png` is the art as painted):

| Pack art | Medallion as painted | Wrapper pattern | In the game now | Art needed |
|---|---|---|---|---|
| UI-PACK-B | gold arm on red: correct | dumbbells: correct | the canonical icon | none |
| UI-PACK-G | chef's hat, on a brown disc (the guide: cream) | croissants: fine | the canonical icon | none |
| UI-PACK-N | **a skull over a quill and scroll: wrong** | stamps: fine | the canonical icon (skull in ghost-flame) | **Batch 16: UI-PACK-N redo** |
| UI-PACK-R | **three leaves in a swirl on rust red: wrong** (the guide: a leaf in three arrows on moss green) | leaves: fine | the canonical icon | **Batch 16: UI-PACK-R redo** |
| UI-PACK-GILDED (one picture for all four Paths) | the Beefcake arm | **dumbbells on every Path's gilded pack: wrong for three of four** | the canonical icon of each Path | **Batch 16: UI-PACK-GILDED-N, -G, -R** |
| UI-PACK-GENERAL-1 / -2, UI-PACK-PRISMATIC | compass, star: no Path | stars | unchanged | none |

**For your ChatGPT run:** the three rows are in `docs/art/batch16_nov14.csv` (now 23 rows) and as items 22 and 23 of
`docs/prompts/chatgpt_batch16.md` (your item 21 is the Gilded Necrocrat pack). The game picks up `UI-PACK-GILDED-N` / `-G` / `-R` by
themselves once imported; until then the dumbbell foil stays on the gilded packs.

## Batch 16 import status

**Not imported: skipped as told** (the images are not made yet). Nothing in this pass depends on it. When it lands it runs as its own
short task; this pass added three rows to its list (above) and one place that will use its art (the D.N.A.'s debris).

## Tests and the build

- **GUT: 40 shards, 3118 of 3120 passing, 0 failing, 2 risky** (the same two tests that assert nothing). New: `tests/test_fable_nov15.gd`
  (10 tests) and `tests/test_rule_audit.gd` (5). One older test was made independent of test order (Primm's phase 2 may list the
  bosses' setup window).
- **The background test run was stopped by the low-memory guard** after shard 36 of 40; nothing had failed. I finished shards 37 to 40
  in the foreground (`--from=37`), as the house rules say.
- **Walk smokes:** the D.N.A. (75 checks), Crosspath (29) and the Capital (137): all OK.
- **Probes:** NPC visibility, freed D.N.A.: 20 checks, 0 failed. 3D-figure scan: 0 in 17 area states. Rule audit: 0 of 118 fights.
- **Not run:** the Gainlands, Buffet and Dump walk smokes (their statues changed in Part 3; the statue keeps its plinth, its blocker
  and its plaque spot, and the tests cover it). The Buffet's two plaza failures noted on Nov 14 are as they were.
- **The build:** see "The 1.0.0 zip" above.

## New tools

| Tool | What it does |
|---|---|
| `bash tools/dna_outside_shots.sh before\\|after` | The D.N.A.'s outside from six fixed cameras |
| `bash tools/run_npc_3d_scan.sh [label ...]` | Every area, oppressed and freed, scanned for rigged 3D models and capsules; exit 1 on any |
| `NPC_FREED=necrocrat bash tools/run_npc_visibility_probe.sh` | The visibility probe with zones freed first (the freed lobby's people) |
| `tests/test_rule_audit.gd` (`tools/rule_audit_sweep.gd`) | Builds all 118 fights and lists rules applied and not shown; writes `_logs/rule_audit.json` |
| `--zone_fight=final:officer:rift` (battle shot), `--roamer_brief=officer:rift` (zone shot) | A roamer's real fight, and its "Before the fight" card |
| `--open=vendor_packs` (zone shot), `--open=packs_all`, `--open=pack_open:<id>` (town shot) | A vendor's pack page, the shelf with every pack, the opening screen |

---

# Fable Nov 14 - report: the owner's playtest list, the Path icons, Batch 16

Brief: `docs/prompts/fable_nov14_owner_list.md`. Start tag `pre-fable-nov14`. Questions: `docs/overnight_inbox.md`, "Fable Nov 14"
(18 items). One Godot at a time, no sub-agents. No public upload. No difficulty setting, no battle-board change, Primm's fight
untouched, no new art (Batch 16 lists it). Ran on Fable 5.2, Nov 14 to 15. The Batch 15 report follows below.

## In short

- **Every item of your list is done except the build.** Parts 1 to 6 are committed and pushed, each with before/after shots.
- **The 1.0.0 zip was not built.** Free memory stayed at 2.0 GB for the ten minutes the brief allows (the rule is 2.2 GB). The
  commands are below. The last zip in `builds/` is still RC5 (Nov 12).
- **Tests: all 33 shards green, 3103 of 3105 passing, 0 failing** (2 risky, the same two no-assert tests as before).
- **The NPC visibility probe passed** (150 checks) and the walk grids are checked by tests (the Dump on foot and on the mount, the
  Buffet's forest, the roamers' distances in all five zones).
- **Walk smokes:** the D.N.A.'s passed. **The Dump's and the Buffet's each fail two checks** (details under "Tests and the build").
  One cause was mine and is fixed; the other failures are in the two hub plazas, where this pass changed nothing, and I did not
  prove they predate it.
- **Four things to look at first:** the officer's name (inbox 2), which Dump objects I took for the "floating door" and the "block"
  (inbox 10: I had no screenshots), the two shafts with no Path (inbox 7), and Dex's final table at 19 (inbox 17).

## The 1.0.0 zip

**There is no 1.0.0 zip yet.** Close what you can, then run these from `C:\Dev\Deckbuilder-rpg` in Git Bash, one at a time, in the
foreground:

```
EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0
bash tools/run_release_smoke_exported.sh
bash tools/export_test_pack.sh
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480
SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480
grep -c "SCRIPT ERROR" _screenshots/exported/play_r1a.log _screenshots/exported/play_r1b.log _screenshots/exported/play_r1c.log
```

- The export takes 4 to 10 minutes and writes `builds/TheWaywardPath-v1.0.0-windows.zip`. "EXPORT STOPPED" means nothing was replaced.
- The smoke must print `PASSED`. The last line must print 0 three times.
- None of this pass, the Batch 15 pass or the Nov 13 dialogue rewrite has been run as an exe. Play the first ten minutes yourself
  before uploading.

## Your list, item by item

Shots are in `docs/overnight_shots/nov14/` (`_before` / `_after`).

| # | Item | Done? | Shots |
|---|---|---|---|
| 1.1 | The cut to Primm in the Old Service Tunnels | **Done.** It was the castle's "Primm tells you who you are" scene firing before every boss in the Capital's zone; now only at his own room | (no picture: a scene that no longer plays; a test pins it) |
| 1.1 | The tunnels' boss is one of Spotless's officers | **Done.** Enforcer Sergeant Scuff; deck, HP, stats and rewards unchanged | `p1_officer_before_line`, `p1_officer_after_line` |
| 1.2 | Fragment 2: bars, not glass | **Done**, and every line that referred back to it | `p1_fragment2_after` |
| 1.3 | Elder Maren's thread | **Done.** 17 of her lines, 3 lines of others, the bible and the voices doc | (text: the tables below) |
| 2.1 | Remove Fig's crate; Items in his own shop | **Done.** Cards / Items / Card Packs | `p2_crease_crate_*`, `p2_fig_picker_after` |
| 2.2 | Items showing "?" | **Done.** A deliberate effect, removed (below) | `p2_fig_items_before`, `p2_fig_items_after` |
| 2.3 | His portrait | Batch 16 row 1 (not touched) | |
| 3.1 | Signs: the Crease's dark board, the plaza manhole's sign, Path icons on the shaft signs | **Done.** Four of six shafts show a Path; two belong to no Path (inbox 7) | `p3_crease_signs_*` |
| 3.2 | Crosspath's rocks and shoreline | **Done.** Curved water line, narrow earth bank, rounded stones, one grass to the water | `p3_shore_a_*`, `p3_shore_b_*` |
| 3.3 | No enemies within 20 m of arrival points, entrances and exits | **Done** in all five zones; the test covers it | (positions: a test) |
| 3.4 | The Dump: floating door, walk-through block, top-right closed, treasure field | **Done**, with one caveat: I picked the door and the block by probe, without your screenshots (inbox 10) | `p3_dump_*` |
| 3.5 | The Buffet's entrance: no block, a bank, a food forest | **Done** | `p3_buffet_entrance_*`, `p3_buffet_forest_after` |
| 3.6 | Outside the D.N.A.: an organised wasteland | **Done.** 79 fps on Medium (81 before); the paper still floats | `p3_dna_apron_*` |
| 4 | Path icons: guide, inventory, fixes | **Done.** 8 code and text fixes; 14 painted ones are Batch 16 rows | `p4_fountain_plinths_after`, `p4_ending_after`, `docs/art/path_icon_sheet.png` |
| 5 | Dex: 20 moves, limit 26 | **Done.** The final table is 19 (inbox 17) | `p5_dex_after` |
| 6 | Batch 16 list and prompt | **Done.** 20 rows, 94 references on the Drive | |
| 7 | Verify and build | see "Tests and the build" | |

## The officer

**Enforcer Sergeant Scuff, "Sub-Inspector of Tunnels That Do Not Exist".** A junior Enforcer whom Captain Spotless sent below; young,
earnest, apologetic, the only man in the regime with muddy boots. He borrows the Correction Officer's talk frame as his portrait and its
Bestiary square until Batch 16 (row 4).

- **Boss intro:** "HALT, please. Captain Spotless says nobody is to be down here, and that includes me, so let us be quick about it."
- **Before:**
  - "A grate lets in light from a perfect city. Under it a young Enforcer sergeant stands to attention in a puddle, reading his orders
    off a card, in the only muddy boots the regime owns."
  - "'HALT, please. Sergeant Scuff, Enforcers. Captain Spotless sent me to check the service tunnels in case anyone tried to sneak
    into the city this way, and I'm sorry to report that someone has. It's you.'"
- **After:**
  - "Sergeant Scuff sits down on a barrel and takes off his helmet. 'My gran laid pipe down here,' he says. 'She said these tunnels
    used to be full of people. I put that in a report once, and the Captain had me write it again.'"
  - "'All four Paths, shoulder to shoulder, and nobody measuring anybody. I'll tell the Captain I found nothing down here, which is
    what he says there is. Go on. The grate isn't locked.'"
- **In the fight:** "INSPECTION! The Captain wants heights, he wants smudges, and he wants every smile at the regulation angle!" and,
  near the end, "Mud. On the boots. The Captain will see it from all the way up there, I know he will." (the same two events, renamed).
- **Bestiary:** "Captain Spotless sent him down to guard tunnels that do not exist. His are the only muddy boots in the regime, and he
  has apologised to them."

Also updated: S-CAP's `boss` field, the reward card's "where to find it" line, the dungeon list, the encounter rule's text, the boss
table in `docs/design/encounter_scripts.md`, the tests. The hook, the quest text and the feats never named the boss. An old save's
Bestiary counts carry over.

## Maren's post-Path conversations, before and after

Changed lines are bold. Every gameplay instruction is unchanged. Revert everything with
`node tools/apply_dialogue_pass.js --revert=docs/dialogue/fable_nov14_ids.txt`.

**After the first Path (Fragment 1)**

| | Before | After |
|---|---|---|
| Maren | You've gone as pale as flour. Sit down, sit down. Something has come back to you, hasn't it? | **Even with my eyes I can see you've gone as pale as flour. Sit down, sit down. Something has come back to you, hasn't it?** |
| Maren | (unchanged) | Tell me all of it, however small it seems to you. In my experience it's the small things that turn out to matter. |
| Maren | (unchanged) | ...A lullaby. That tune comes from the old days, from the court, and there are very few of us left who would know it. Fewer still who ever hummed it to a child. |
| Maren | (unchanged) | Have some pie. And don't ask me why my eyes are wet, because I shan't tell you, and you wouldn't want to make an old tortoise lie. |
| Maren | (unchanged) | But look at you. With one zone free, the corruption is losing its grip on the land, and it's slipping off you along with it. |
| Maren | (unchanged) | You ought to be able to carry a second Path now. Go down to the Deck Station and try building a deck with two, and then come and tell me how it feels. |

**After the second Path (Fragment 2)**

| | Before | After |
|---|---|---|
| memory | (unchanged) | White rooms, and a white light that never changes, whatever the hour is outside. |
| memory | There is glass on every side of me, and behind the glass there are faces in white coats, taking notes. | **There are bars on every side of me, and behind the bars there are faces in white coats, taking notes.** |
| memory | (unchanged) | No one in that place ever uses my name. They call me 'the Subject', and whatever I do, the only thing they ever say to me is 'again.' |
| memory | (unchanged) | Again. Again. Again. |
| memory | (unchanged) | I wasn't lost. I was kept. |
| Maren | Glass, and white coats, and 'again.' So that is where they had you, all those years. | **Bars, and white coats, and 'again.' So that is where they had you, all those years.** |
| Maren | You've earned some truth from me in return, so here is the first piece of it: I'm not only an old tortoise who bakes. | **The way you said that... I taught the royal children at the castle once, and there was a boy who asked his questions just that way. For a moment I thought... No. That boy is ten years dead, and I'm a foolish old tortoise.** |
| Maren | There's a resistance in this kingdom, and I'm its contact here in {town}. A woman called Wren leads it, from a hideout inside the Capital itself. | **You've earned some truth in return: I'm not only an old tortoise who bakes. There's a resistance in this kingdom, and I'm its contact here in {town}. A woman called Wren leads it, from a hideout inside the Capital itself.** |
| Maren | (unchanged) | I wasn't sure of you before, and I'm sorry for that. I'm sure of you now, or near enough, and there aren't many people I would say that about. |

**After the third Path (Fragment 3)**

| | Before | After |
|---|---|---|
| Maren | A man in white and gold, who knelt and then stood up. And before that, those rooms of yours with glass on every side. | **A man in white and gold, who knelt and then stood up. And before that, those rooms of yours with bars on every side.** |
| Maren | I know that glass, because I helped to blow it. A long time ago I founded the study of the Paths, and I did it for the best of reasons, the way people generally do. | **I knew that throne room, dearie. I worked at the castle once, studying the Paths, and of an afternoon I taught the royal children their letters. I began that study for the best of reasons, the way people generally do.** |
| Maren | {villain} took my work and built a cage out of it, and the best student I ever had stayed on to run the laboratory for him. And I ran. | **{villain} took my study and built those cells out of it. I never forged a bar of them, but every one stands on something I wrote down. The best student I ever had stayed on to run the place for him, and I ran.** |
| Maren | I have been hiding here ever since with my hands in pie dough, where nobody would think to ask what else those hands had made. | **I have been hiding here ever since with my hands in pie dough, where nobody would think to ask what those hands used to write.** |
| Maren | (unchanged) | That's my secret, and now you're holding it, the same way I have been holding yours. You may do with it as you see fit. |

**After the fourth Path (Fragment 4)**

| | Before | After |
|---|---|---|
| memory | (unchanged) | A boy of eleven stands in a coat too fine for the cold, and someone is calling to him across a courtyard: '{prince}!' |
| memory | I turn toward a woman's voice, and then a man's, and on every door around me is the {royal_house} crest: four signs in a ring. | **I turn toward a woman's voice, and then a man's, and on every door around me is the {royal_house} crest: an arm, a chef's hat, a leaf and a skull, four signs in a ring.** |
| memory | (unchanged) | {prince_full}, son of the king and queen. The whole kingdom believes he died ten years ago. |
| memory | (unchanged) | That is who I am. |
| Maren | {prince}. {prince} {royal_house}. I met a boy at court once, hiding behind his mother's cloak, and he asked me why tortoises carry their houses about with them. | **{prince}. {prince} {royal_house}. I taught a boy by that name his letters. The first day he hid behind his mother's cloak, and he asked me why tortoises carry their houses about with them.** |
| Maren | (unchanged) | I told him, 'So that we are never far from home.' |
| Maren | I knew, you see. The Warden opens that tunnel for one family only, and I knew who you were the moment you walked out of it. I was too frightened to say so. | **And you have sat at my table all these weeks, and I didn't know you. My eyes have been going for years, and I had been told that boy was dead, and whenever my heart said otherwise I told it to hush.** |
| Maren | Four signs in a ring, the same as the ones carved on this stick of mine. I have leaned on it for ten years and never told a soul why. | **Four signs in a ring, the same as the ones carved on this stick of mine. The Queen gave it to me the day I began teaching you, and I have leaned on it for ten years and never told a soul why.** |
| Maren | And my laboratory, my life's work, was used on that boy. It was used on you. Forgive me, if you ever can. I would understand it if you couldn't. | **And my study, my life's work, was the thing they used on that boy. It was used on you, and I ran, and I never once asked who was behind those bars. Forgive me, if you ever can. I would understand it if you couldn't.** |
| Wanderer | (unchanged) | My mother called to me across that courtyard. I can hear her voice now, and I still can't see her face. I'd like to, one day. I'd like to know what the two of them were like. |
| Wanderer | You built the glass, Maren. You also gave me a bed and a pie when you still thought I might be a spy. I know which of those I'm keeping. | **You ran, Maren. You also gave me a bed and a pie when you still thought I might be a spy. I know which of those I'm keeping.** |
| Maren | (unchanged) | ...Then let us make this kingdom a home again, {prince}. All of it, for all of them. |

**After the fourth Path, when Primm already told him (the rushed castle)**

| | Before | After |
|---|---|---|
| Maren | (unchanged) | So he knew you from the very first. He told you who you are, and now you've come to me for the rest of it. |
| Maren | I knew as well. The Warden opens that tunnel for one family only, and I knew who you were the moment you came out of it. I was simply too frightened to say so. | **I should have known you myself. I taught you your letters. But my eyes have been going for years, and I had been told that boy was dead, and I was too frightened to hope I'd been told wrong.** |
| Maren | So hear it from somebody who held your hand at court: you are {prince_full}, and I am so very sorry for what was done to you with the things I built. | **So hear it from somebody who held your hand at court: you are {prince_full}, and I am so very sorry for what was done to you with the things I wrote.** |

**Elsewhere:** her cave-mouth welcome ("Come closer, dearie; my eyes aren't what they were..."), her first kitchen line ("...my eyes,
which see as far as a pie and not much further"), her line after two Paths ("'With my eyes I couldn't say,' I told them, 'but I know a
damp young man with good posture when one drips on my floor.'"), her line about Elowen's father ("the best student I ever had"), "bars
on the doors" for where Elowen was taken, and her Year 1 note in the castle ward ("I am told the subject is a child, and that he asks
for his mother. A child is not a specimen. I will not stay to see it. M."). The Wanderer's answer is now "You ran, Maren. You also gave
me a bed and a pie..." and his line to Primm says "behind bars for ten years".

## Why the items showed "?"

It was deliberate. The vendor-screen pass gave every shop one effect, and Fig Sly's was "hidden compartments": a wooden door with a "?"
over each tile that slid away while the mouse was on it (`VendorFx.add_compartment`, called from `ItemVendorScreen._make_tile` when
the screen id was `VS-FIGSLY`). The Nov 4 fix pass took the doors off his cards and missed his items. The doors and the function are
deleted; his Items page is the ordinary item shop.

## The Path icons

- **Guide:** `docs/art/path_icon_style_guide.md`; **sheet:** `docs/art/path_icon_sheet.png`; **code:** `PathIcons`.
- **The four:** Beefcake a gold flexed arm on red; Gourmand a white chef's hat on cream and copper; Refusemancer a green leaf in three
  rust arrows; Necrocrat a pale skull in green flame on slate. Colorless is the plain stone disc. All four in a ring read clockwise
  from the top: arm, hat, leaf, skull.
- **Inventory:** `docs/art/path_icon_inventory.csv`, **62 places**: 40 already right, **8 fixed now** (7 in code, 1 line of text),
  **14 painted** (Batch 16).
- **Fixed in code:** the ending's four icons, Crosspath's fountain pillars and crest plinths, the feats' one-Path groups, the Capital
  camp's tents, the pack fallback, the Crease's shaft signs; and Fragment 4's line now reads "an arm, a chef's hat, a leaf and a skull,
  four signs in a ring".
- **The picture after the fourth Path is `STORY-MEMORY-4`**: the ring on the arch above the King is a star, a flame, a leaf and a moon.
- **Not changed, your call (inbox 15):** the UI's accent tints for Gourmand (blue) and Necrocrat (violet) do not match their icons.

## The treasure field and the gold study

The Dump's top-right pocket is reached across the scree only (the mount). A stand of trees closes the strip along the north rim; the
walk grid is flooded on foot and on the mount in a test.

| Chest | Gold in the chest | Also |
|---|---|---|
| `chest_field_a` | 150 | Summoning Charm |
| `chest_field_b` | 120 | a Gilded Refusemancer Pack |
| `chest_field_c` | 180 | Sucker Punch Mitts (Binding Chains if you own them) |
| `chest_field_d` | 210 | Ward Sigil |

They stand on mossy plinths, half as big again as a hidden chest, with a warm glow, and the popup says "Treasure chest". The two older
chests in the pocket are unchanged. "The Oldest Trick in the Book" counts Shiro's five giant chests only, so these are not in it.

**Gold study** (`docs/design/sim/economy_model_nov14.md`): the expected, no-grind walk opens half the hidden chests and earns
**23,007 gold, 330 more than before these chests** (+1.5 %). A thorough player gains 660. The model's figure was already above the
21.2k of Nov 8 before this pass, because quest and clear rewards were raised after that study; the four chests are not what moved it.

## Batch 16

`docs/art/batch16_nov14.csv`, prompt `docs/prompts/chatgpt_batch16.md`, references in
`G:/My Drive/Card Game Art/Batch 16 References/` (94 files, numbered by row).

| # | Images | Why |
|---|---|---|
| 1 | V-FIGSLY | two right hands |
| 2 | STORY-MEMORY-4 | the crest above the King: the four Path icons |
| 3 | STORY-MEMORY-3 | the banners behind the King |
| 4 | NPC-SCUFF, CUT-SCUFF, BST-ENFORCER-SERGEANT-SCUFF | the new officer |
| 5, 6 | UI-CARDBACK-B, UI-CARDBACK-N | a dumbbell; a skull with a quill |
| 7 | ICON-FEAT-PATHS | a dumbbell, a leaf, a ladle, a stamp |
| 8 | DEC-PLINTH-BEEF / -GOUR / -REF / -NECRO | Crosspath's freed-zone statues |
| 9, 10 | TOWN-SHEET-FREED-BANNERS-01 to -06 | Crosspath's freed banners |
| 11 | CAP-BANNER-FREED-03, -04 | a leaf swirl; a stamp |
| 12, 13 | STORY-REUNION, STORY-EPI-FILE-COMPLETE | banners in the crowd |
| 14, 15 | LOGO-EMBLEM, APP-ICON, LOGO-WORDMARK | a dumbbell, a sprout in a tin, a skull with a quill |
| 16 | TOWN-PROP-SHORE-STONES-01 to -03 | painted stones for Crosspath's shore |
| 17 | CAP-PROP-CREASE-STALL-01 / -02, CAP-PROP-CREASE-CRATES | the Crease's flat stand-ins |
| 18 | SPR-RESCUER walk set (5 sheets) | the masked Rescuer walks in Elowen's frames |
| 19 | NPC-QUADZILLA, NPC-CAIRN | two bosses speak with no portrait |
| 20 | DNA-PROP-CRATES, DNA-PROP-CABINET-TIPPED | the wasteland's stand-ins |

Nothing in `docs/art/` is still marked REDO (Batch 14 delivered all twelve), so rows 16 to 20 are the five most visible stand-ins left.

## The world, in a little more detail

- **Crosspath's shore.** The lake was drawn straight from its 24-corner outline; it is drawn from a rounded copy now, so the water
  line is a curve (the two corners at the waterfall stay sharp). The 3 m band of pale sand is a 1 m bank of wet earth with a ragged
  edge. The two-tone grass was the town's painted ground stopping 2 to 3 m short of the water, with the brighter country grass showing
  in the gap; the town's grass runs to the water now. The far shore keeps the country grass. Crosspath has no painted rock prop, so the
  stones are rounded ones in the ridge's rock texture (a painted set is Batch 16 row 16).
- **Enemies at entrances.** The four Path zones' own roamers already kept 20 m. What you met at the Dump's entrance was the extra
  roamer the game adds within sight of every exit so a newcomer sees a fight at once. It lived 14 to 17 m from the exit; it lives
  23.5 to 31 m out now, 20 m from the arrival point as well, and at least 9 m from every person and service of the hub. Three Capital
  Tidy-Bots moved.
- **The Dump.** Removed: the hollow log by the east water (a 6 m slab of bark with no collision) and the hay bale beside the top-right
  barn (side-on it was four pale planks hovering over the grass). `tools/heap_odd_probe.gd` lists every floating mesh and walk-through
  slab if you meant others. The top-right is closed by four trees and three bushes along the north rim.
- **The Buffet.** A bank runs from the table's edge down under the gravy round the south half of the table. The food forest is east
  of the bridge (the west side holds Tarragon, the golem, the rift station and the giant chest): 18 trees in two rows, herbs and leeks
  at their feet, solid on the walk grid.
- **The D.N.A.** 16 rows either side of the causeway and beside the lobby: cabinets (every third tipped over), a queue of rope posts,
  crate stacks, filing towers, dead trees, rubble. Low-end keeps every other piece.

## Tests and the build

- **GUT:** 33 shards of 12, each in a fresh Godot: **3103 / 3105, 0 failing.** New: `tests/test_fable_nov14.gd` (21 tests, one or
  more per part). Six older tests were updated for the new character and the tree wall.
- **NPC visibility probe:** OK, 150 checks.
- **D.N.A. walk smoke:** OK (75 checks, 20 screenshots).
- **Dump walk smoke: FAILED, 2 causes.**
  - At the heal table the prompt offered was Billie Muckfoot's ("heal: the prompt is up (near wren)"). On that run the extra exit
    roamer stood 0.1 m from Billie, which was my regression and is fixed; **the re-run after the fix did not finish**: the session stopped it for low memory one check in, so whether this check passes now is not known.
  - A script error every frame after the smoke's save and load (`herded_this_visit` on no visit). Fixed with a guard.
- **Buffet walk smoke: FAILED, the same 2 checks before and after the roamer fix**, so the roamer was not the cause:
  - at Basil's spot the prompt offered is Madame Mirepoix's;
  - the walk from Mirepoix to the heal table stops 3 m short (the straight line crosses the fountain).
  Both are in the plaza, where this pass changed nothing; Batch 15 moved Mirepoix and her stall 3.4 m. I believe they date from that
  and did not verify it against the old build. **Worth a look in the game: stand at Basil and check that E talks to him.**
- **Not run:** the Gainlands, Capital, Crosspath and opening-forest walk smokes, and a Low-camera walk of each changed area. The
  shots were taken at the default camera only.
- **A slip of mine, repaired:** while checking a log I ran `git stash pop` with nothing stashed, which applied an old Nov 4 stash onto
  the tree and conflicted in 19 files. Nothing of this pass was uncommitted in those files; I restored exactly those 19 from the last
  commit. Both old stashes are still in the stash list.

## New tools

`tools/heap_foot_probe.gd` (the Dump's walk grid on foot and mounted, as text), `tools/heap_odd_probe.gd` (floating meshes and
walk-through slabs), `tools/buffet_rect_probe.gd`, `tools/dna_floor_probe.gd`, `tools/flat_mesh_probe.gd` (which ground mesh lies
where), `tools/art/path_icon_inventory.py`, `tools/art/batch16_build.py`, `tools/nov14_maren_table.js`, `docs/dialogue/fable_nov14_rows.js`.
Shot hooks: town `--open=memory2|memory3 --memory_line=N`, zone `--open=vendor_items`.

---

# Batch 15 + 1.0 - report (Nov 13): the last art batch, the owner's answers, the leftovers, the 1.0.0 build

Brief: `docs/prompts/batch15_import_and_fixes.md`. Start tag `pre-batch15-import`. Questions: `docs/overnight_inbox.md`, "Batch 15 + 1.0"
(10 items). One Godot at a time; the one critic ran while no Godot ran and saw pictures only. No public upload. No difficulty setting,
no battle-board or menu layout change, Primm's fight untouched. Ran on Fable 5.2. The Fable Nov 13 dialogue report follows below.

## In short

- **All 39 Batch 15 images are in the game**, each with a screenshot. 22 rows of `docs/art/batch15_nov12.csv` say "In game"; the two
  rows that were not in the batch (the painted world maps, the Gallery's bestiary pictures) say "Not delivered".
- **Your answers are applied**: both sets, 9 items.
- **All eight in-game leftovers are done.**
- **A fresh critic looked at 21 unchecked screens: clarity 5/10, polish 5/10.** Four of its top 10 were caused by how the pictures
  were taken, three were real and small and are fixed, three need art or a larger change and are logged.
- **Tests: all 33 shards green, 3084 of 3086 passing, 0 failing** (2 risky, the same two no-assert tests as before). The intro walk, the freed city, the map and every new shot ran with 0 script errors.**
- **The 1.0.0 build was not built.** Free memory stayed at 1.8 GB for the ten minutes the brief allows (the rule is 2.2 GB), so the export was not started. The source is at 1.0.0, tested, committed and pushed; the commands are below.**

## The 1.0.0 zip

**There is no 1.0.0 zip yet.** Close what you can (ChatGPT and the browser hold most of the memory), then run these from
`C:\Dev\Deckbuilder-rpg` in Git Bash, one at a time, in the foreground:

```
EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0
bash tools/run_release_smoke_exported.sh
bash tools/export_test_pack.sh
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480
SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480
grep -c "SCRIPT ERROR" _screenshots/exported/play_r1a.log _screenshots/exported/play_r1b.log _screenshots/exported/play_r1c.log
```

- The export takes 4 to 10 minutes and writes `builds/TheWaywardPath-v1.0.0-windows.zip`. "EXPORT STOPPED" means nothing was replaced.
- The smoke must print `PASSED`. The last line must print 0 three times.
- Expect a pack of about 864 MB and a zip of about 750 MB (RC1 was 847 and 736; this batch adds about 17 MB to the pack). The disk
  has 18 GB free; the export's peak is under 2 GB.
- The last zip in `builds/` is RC5 (Nov 12): RC6 was never built, so 1.0.0 is the first build with the Nov 12 fix pass, the dialogue
  rewrite and this batch.
  **Play the first ten minutes of the exported game yourself before uploading** - none of that work has been run as an exe.

## Part 1 - the import

| Images | Where it is in the game | Shot (`docs/overnight_shots/batch15/`) |
|---|---|---|
| CAP-SHEET-WINDOWS-07 / -08 | Every townhouse window of the Capital: -07 by day, -08 (lit) in the freed city | `windows_day_plaza`, `windows_day_reek`, `freed_capital_approach_low` |
| CAP-BANNER-FREED-01..04 | After `primm_defeated`: a row down the avenue, and the four over Primm's emblem | `freed_capital_approach`, `_low`, `freed_capital_plaza_low` |
| CAP-BD-LANTERNS, CAP-FX-FIREWORKS | After `primm_defeated`: lanterns climbing slowly, one soft burst every 4.5 to 9 s. Reduce motion or Low-end: one still lantern card, no fireworks | `freed_capital_approach_low` |
| CAP-PROP-PORTRAIT-PRIMM-01..03 | The easel portraits (the smiley stays the emblem elsewhere) | `freed_capital_approach_low` |
| CAP-PROP-RUBBLE-ROW | The foot of the south wall in the Reek and the Transit Yards; the outskirts' south edge | `rubble_row_transit_yards` |
| BUFF-PROP-STALL-01 / -02 | The Buffet hub's two market stalls | `buffet_stalls` |
| DNA-PROP-SERVING-ORB | The head of the lobby's ghost queue, and beside TAKE A NUMBER | `dna_serving_orb` |
| DUMP-HERO-RACCOON-STATUE | The raccoon king on the throne beside the Rotheart's gate (the art list's row) | `dump_raccoon_statue` |
| DUMP-PROP-MILL-SAILS | The three mills' sails, turning slowly | `dump_mill_sails` |
| GAIN-GROUND-MAT | The gym mats | `gainlands_gym_mat` |
| ICON-EQ-HALLPASSSLIPPERS, ICON-GEAR-EARNEDBLADE | Their own icons (60 of 60 gear icons) | `icons_gallery`, `gear_icons_character` |
| MAP-S-GALLERY | The Shattered Gallery's map; all 13 nodes moved onto the new painted landings, every painted path matches a link | `gallery_map_nodes` |
| MG-BG-MATCHTABLE, UI-CARDBACK-DEX | Dex's matching game: table and card back | `dex_match_table` |
| UI-BATTLE-ITEMSLOT-EMPTY / -READY | The battle item slots, same slot rect | `battle_item_slots` |
| UI-PACK-LOCKED-B / -G / -N / -R | Fenwick's locked Path Packs | `locked_packs` |
| UI-NODE-BANNER | The pop-up banner's base | `node_banner_shrine`, `node_banner_treasure` |
| NPC-HESPER, STORY-EPI-WRINKLES | Replaced; the code recolour and its test are deleted | `portrait_hesper` |
| V-FIGSLY | Replaced (two arms) | `portrait_figsly` |
| STORY-CREDITS-PANORAMA | Behind the credits and the thanks card, a slow pan; the text carries a dark outline | `credits_panorama`, `credits_thanks_card` |
| SPR-ELOWEN-*_WALK (5) | The intro and the cave mouth | `elowen_walk_default`, `elowen_walk_low` (six frames each), `elowen_walk_default_frame`, `elowen_walk_low_frame` |

**The locked packs.** Beefcake red, Gourmand orange and Necrocrat deep green match their packs. The Refusemancer parcel also came with
a green seal while its pack carries a rust-red medallion, so its seal is tinted rust in code (a small shader that re-colours only the
wax). Each seal now echoes its pack and the two green parcels can be told apart.

**Elowen's walk.** Built the way the townsfolk walkers are: four frames per sheet, the walkers' figure height and her own idle's scale,
normal maps, the walkers' frame rate, mirrored for the right-facing directions. She has idles for three directions and walks for five,
so the importer and the sprite now accept a walk with no idle of its own. At the intro she walks north-west into the trees (3 m in
2.6 s, her back three-quarter frames) and fades over the last second; a figure that stops goes back to its idle. The same at the cave
mouth after each freed zone. **Two things to know** (inbox 1 and 2): she still wears the disguise in both scenes and the disguise set
has no walk frames, so she walks in Elowen's own frames, seen from behind; and the Lab, her rescue and the epilogue are stills and
dialogue, so no figure of hers walks there.

**Three placements that differ from the brief's wording** (inbox 3, 4, 6): the Capital has no dusk, so the lit window is the freed
city's; the lanterns and fireworks stand in front of the castle because the sky is never in frame inside the city; Madame Mirepoix's
stall moved 3.4 m so it stands behind her.

**Size.** 81 new files, 8.0 MB of source art, **about 17 MB more in the pack**; the seven replaced files are 0.3 MB smaller. Against
`docs/build_size_policy.md`: the pack was already over the 750 MB warning on purpose (music at q6); this batch adds 2 %.
The numbers are from the imported files; the export will print the real pack size.

## Part 2 - your answers

**Fable Nov 12d**
1. Fig Sly's label: kept.
2. The Crease's arrival line: kept.
3. Maren's cave-mouth welcome now carries her introduction: "...I'm Elder Maren, dearie, and this is Crosspath. We settle most things
   here with cards..."
4. Tall pieces at 1.3 times: kept. Re-measured on Medium with the new windows: **68.5 to 73.1 fps** at the six inside cameras (Gate
   Plaza 68.5, Transit Yards 69.3, Grave Row 70.3, the Reek 71.4, Palace Approach 71.9, Hungry Quarter 73.1). No need for 1.2.
5. New Game with no save in any slot starts the story at once, in slot 1. The slot grid appears once a save exists.

**Dialogue Nov 13**
1. Fig Sly's lines: still locked.
2. Bertram: his 14 lengthened lines are back to the clipped originals (`docs/dialogue/bertram_nov13b.csv`); the lines that were already
   short are unchanged. Every line of his is under 150 characters.
3. The redistributed verbal habits: kept.
4. The exporter: Dex's 20 `cardsharp.*` lines say "Dex Shufflewick"; the 20 "(check key)" rows are named (Tilly Tonic, Auntie
   Alembic, Pip Threadwell, narration); the chef reads "The Grand Chef", the impostor "The Doppelganger" and, after the naming,
   "Escoffina". **The 56 tutorial hints are in the export** (the first duel's 20 steps and the nine one-time screen tips), with ids the
   importer already applies. None was rewritten.

## Part 3 - the leftovers (all eight)

| # | What | Result | Shot |
|---|---|---|---|
| 1 | The Dump's south corners | The land is drawn once more from behind in shadowed rock, so the camera inside the rim sees stone, not fog | `dump_corners_after` |
| 2 | The Tidy-Bots | Any roamer whose touch costs HP stops for 0.85 s, flashes twice and sounds the alert before it comes. The arrival grace is 3 s and counts only while the hero can move, so it holds on a real entry | (behaviour; covered by a test) |
| 3 | The Crease's east wall | The camera holds 3.4 m off both side walls and the view slides instead of turning back; the wall takes about a third of the frame, not half | `crease_east_wall_after` |
| 4 | The Wanderer's portrait | Fades to clear over the last 11 % of its width | `portrait_wanderer_feathered` |
| 5 | The Capital's map | District names; the Crease as its own framed inset "under the city"; a name is never written over an icon or another name, and a name several places share is written once | `capital_map_after` |
| 6 | The minimap | Draws a 3x smoothed copy of the map picture: rounded edges in the Capital. In the forest the minimap shows almost nothing but the clearing, so the gain there is small | `minimap_before_after` |
| 7 | Crosspath's south band | A knee-high kit hedge along the ravine's lip and a shadow in the cleft. The rock lip still shows as a pale and violet strip between them (inbox 9) | `crosspath_south_edge_after` |
| 8 | The D.N.A.'s apron | 17 kit pieces and 10 ground decals either side of the causeway: filing towers, cabinets, paper stacks, a roped queue with a serving orb, ghost lamps, loose forms | `dna_apron_after` |

## Part 4 - fresh eyes

A critic with no context got 21 pictures of the nine places in the brief and nothing else (`docs/review/critic_batch15/`: `brief.md`,
`shots/`, `report.md` with my triage under it). **Clarity 5/10, polish 5/10.**

| # | Its finding | Size | Verdict |
|---|---|---|---|
| 1 | The thanks card sits on top of the credits' words | S/M | **Fixed.** Real after Skip, and worse over the new panorama |
| 2 | Five things stacked at the top of the Transit Yards view | M | Mostly the capture (a fresh profile's Feat banners). The first-visit tip and the new-quest banner do share the first seconds: logged |
| 3 | "Quest complete" covers the Black Market's title | S | **Fixed.** Quest notices wait while a shop is open |
| 4 | Flat stand-in shapes round Fig Sly | L | Real: needs art |
| 5 | Giant townsfolk cut off at the bottom of the freed plaza | M | Real on the Low camera: logged |
| 6 | The well's two pictures are the same | M | The capture (full HP closes the offer). The medallion's icon is a fair point: logged |
| 7 | No panel before the fight | M | The capture |
| 8 | A late quest in the box on the first step into Crosspath | S/M | The capture. The flat lantern on the house is real: logged |
| 9 | The boss panel does not say "boss", claims rules it does not list, red X on Continue | S | **Fixed** |
| 10 | Pale, unpainted-looking citizens and lilac rectangles in the freed city | M | Real: logged |

It liked the dialogue box with the painted portraits, the dungeon map and pop-up frames, and the mood of the opening forest.
**What this means:** the low scores come mostly from the last city and the hideout, where stand-ins still sit beside painted art.
That is art, not code, and it is the honest state of those two places at 1.0.

## The itch upload checklist

The full guide is `docs/release/itch_upload.md`. In short:

1. Build the zip and run the checks above. All three must be clean.
2. Unzip it into a fresh folder, run `TheWaywardPath.exe`, start a New Game (it should go straight to the forest), walk to the cave.
3. itch.io > Dashboard > the project (or Create new project: "The Wayward Path", Games, Downloadable).
4. Pricing: "$0 or donate", suggested 3 to 5 USD (or "No payments").
5. Page text, tags and the AI disclosure from `docs/release/itch_page/` (`page.md`, `ai_disclosure.md`). AI field: Yes; Graphics,
   Sound/Music, Text/Dialogue; not Code.
6. Uploads: `builds/TheWaywardPath-v1.0.0-windows.zip`, tick Windows. It is under itch's 1 GB limit.
7. Cover and the eight screenshots from `docs/release/itch_page/screenshots/`. Consider replacing one with the freed Capital or the
   credits panorama (`docs/overnight_shots/batch15/`).
8. Visibility: Draft, check the page, download once and run it; then Restricted for playtesters or Public.
9. After the upload: `git tag v1.0.0 && git push --tags`.
10. Optional: the in-game Support button (`data/credits/credits.cfg`, `[support] url`), which needs a re-export.

---

# Fable Nov 13 - report (the dialogue rewrite: one cohesive, emotional story)

Brief: `docs/prompts/fable_nov13_dialogue.md`. Start tag `pre-dialogue-nov13`. Questions: `docs/overnight_inbox.md`, "Dialogue Nov 13"
(9 items). Text only: no gameplay, layout or art change, Primm's fight untouched, nothing exported or uploaded. One Godot at a time; the
drafting agents (at most 3 at once) only ran while no Godot ran. Ran on Fable 5.2. The Fable Nov 12d report follows below.

## In short

- **All four tiers are done and in the game: 1,245 lines rewritten** out of 4,405 exported (plus the 66 loading tips), every tier tested,
  committed and pushed. Final GUT: **3070/3072, 0 failing** (2 risky/pending, the same two as before the pass); the prologue smoke passes. The harness twice stopped the background test run for low memory, so the suite was finished in the foreground from the shard it had reached (inbox 9).
- **A new story bible and voice sheets** drive it: `docs/writing/story_bible_v2.md` and `docs/writing/voices.md`.
- **Two blind readers found the old and new text about level** (new preferred 23 of 40, then 19 of 40 on a second sample). Both times
  voice distinctness and emotional impact went up and naturalness went slightly down, because some new lines were padded. See "The
  critic" below for what it means and the 73 lines fixed or put back because of it.
- **Not every line changed, on purpose.** About 2,150 of the exported lines are dialogue or narration a rewrite could touch (the rest are
  labels, rule text, sign titles and quest-log wayfinding). Of those, 1,245 changed. The lines left alone are mostly narration that
  already flowed (the castle's rooms, the ending beats, the funeral), signs and memos (short and deadpan by design), and lines the story
  leans on word for word.

## Tiers done

| Tier | What | Lines rewritten | Written by |
|---|---|---|---|
| 1 | The main story: prologue, cave, Maren's questline, the four Fragments, cave-mouth scenes, gatekeepers, zone finales, the Capital line, Primm, the ending | 293 | the lead writer (me) |
| 2 | The core cast: Gainlands 70, Buffet 61, D.N.A. 76, Dump 51, Capital 128, Crosspath (Brannoch, Old Hob) 13 | 399 | agents, one per zone; Crosspath by me; every batch read and edited by me |
| 3 | Side content: Crosspath's shops, arena, Rift Express and secrets 132; Gainlands 51; Buffet 51; D.N.A. 33; Dump 33; Capital 11; postgame 20 | 331 | agents; read and edited by me |
| 4 | The world: barks, citizens, guards, pop-ups, map descriptions (Capital 69, Crosspath 59, Gainlands 27, Dump 26, Buffet 24, D.N.A. 17), plus the 66 loading tips | 222 + tips | agents; tips by me |

**Per character (lines rewritten):** Elder Maren 136, the Wanderer 33, the Rescuer 32, Agnes Overdue 30, Basil 28, Old Hob 27, throwers
and rippers 26, Capital guards and clerks 25, Rip Tearson and cousins 24, Gerald 23, Brother Bramble 23, Old Man Mountain 23, Chef Marlo 22,
Bertram Beetsworth 22, Wren 21, Pip Threadwell 20, the Perfectly Happy Citizens 20, Grandmaster Flex 19, the gate golems 18, Old Fern 17,
Granny Gristle 17, Percival Plume 16, Rollo Spokes 16, Announcer Bellows 16, narration and UI 143, and about 60 more speakers with fewer
than 16 each. The full list is in each tier's ledger (`docs/dialogue/rewrite_nov13_t*/applied_ledger.json`).

**What changed in kind:**
- Maren is rambling and warm and gets plainer with each Fragment; she says the theme once ("Four peoples who never matched, stitched
  together, and it held").
- Every endearment has one owner: Maren "dearie", Agnes "dear", Auntie Alembic "dear heart", Sable "darling", Madame Mirepoix "my sweet",
  Granny Gristle "my lovely" (and "Hah!"; Old Hob keeps "Heh."), Compostella "child", Flex "son", Rip "buddy", Crumb "soldier".
- Only Brannoch and Nurse Hesper Dray are terse now. Dex Shufflewick's put-downs became friendly table-talk; Pip no longer teases
  customers; the guards and clerks of the Capital are people who do not understand the rules either.
- The Wanderer answers people (to Quota: "You're the first person in this place who hasn't shouted at me. Who are you?").

## Before and after: 15 key scenes

1. **The opening** (`intro::awakening_lines::1`)
   - Before: "I keep reaching for my name, or for how I got here, and there's nothing there at all."
   - After: "I keep reaching for my name, and it isn't there. Neither is how I came to be here. There's nothing at all, like a room that somebody has emptied."
2. **Maren's first talk** (`intro::cave_mouth.maren::1`)
   - Before: "And look at the state of you. I told her I'd help whoever she sent along. I never said I'd take in a half-drowned stray."
   - After: "And just look at the state of you. I told her I would help whoever she sent along, but I don't recall agreeing to take in a half-drowned stray who can barely stand."
3. **Maren names the kingdom** (`intro::town.elder.first::1`)
   - Before: "Ten years ago Patchwork was whole. Beefcakes kept the lights on, Gourmands fed us, Necrocrats minded the dead and Refusemancers turned rubbish into harvests. Everyone complained, and everything worked."
   - After: "Ten years ago Patchwork was whole. Beefcakes kept the lights on, Gourmands fed us, Necrocrats minded the dead, Refusemancers turned rubbish into harvests. Four peoples who never matched, stitched together, and it held."
4. **A memory scene: the Coup** (`intro::memory.3.after::1`)
   - Before: "I know that glass, because I helped to blow it. Long ago I founded the study of the Paths, and I did it for the best of reasons."
   - After: "I know that glass, because I helped to blow it. A long time ago I founded the study of the Paths, and I did it for the best of reasons, the way people generally do."
5. **The Rescuer at the cave mouth** (`scenes/cave_mouth_1/steps/1::2`)
   - Before: "Let me see your hands. Steadier than they were. Good. That's the first thing I've been able to tick off my list in a long time."
   - After: "Let me see your hands. They're steadier than they were, and that's good. It's the first thing I've been able to cross off my list in a long time."
6. **The Gainlands' beat: Clench to his teacher** (mid-fight, `enc::Chancellor Clench, Iron Regent/2/line`)
   - Before: "You said I would go further than you. Look how far I went. ...Master?"
   - After: "You told me I would go further than you ever did. Well, look how far I went. Tell me it was far enough. ...Master?"
7. **The Buffet's beat: Basil** (`gourmand::npc.odalys.return::0`)
   - Before: "You came back! Good, good. I've been stirring the same pot for an hour, just to give my hands something to do. A Gourmand never stops stirring."
   - After: "Oh! You came back. Good, that's good. I've been stirring this same pot for an hour, because when my hands stop I start thinking, and I'd honestly rather stir."
8. **The D.N.A.'s beat: Prudence Pallor, freed** (`dna::freed_npc.prudence::0`)
   - Before: "Prudence Pallor, Deputy Head of the Department. Yes, I stamped DENIED on everything. I was tired, the paperwork was valid, and I am sorry."
   - After: "Prudence Pallor, Deputy Head of the Department. For ten years I stamped DENIED on everything, because the paperwork was valid and I was too tired to ask whether it was right. I am sorry for it."
9. **The Dump's beat: Brother Bramble and the twelfth tree** (`refusemancer::npc.marigold.return::3`)
   - Before: "Forgive me. I talk to that spot more than I talk to most people. It's a very good listener, and it never tracks mud into the Grange."
   - After: "Forgive me, I do go on. I talk to that spot more than I talk to most people, because it's a very good listener and it has never once tracked mud into the Grange."
10. **The Capital arrival: Wren** (`capital::npc.wren.intro::0`)
    - Before: "Another one through the shafts. Sit down. I'm Wren; I was the Royal Archivist once, and now I keep the records this city isn't supposed to have."
    - After: "Another one down through the shafts. Sit, please. I'm Wren. I was the Royal Archivist once, and these days I keep the records this city isn't supposed to have."
11. **A Capital quest: Widow Pell** (`capital::quest.cap_burial.ready::1`)
    - Before: "I sat by the plot all morning and didn't say a word. It was the first quiet in three years that wasn't a fear."
    - After: "I sat by the plot the whole morning and never said a word to him, and it was the first quiet in three years that I wasn't afraid of."
12. **Primm before the fight: the Wanderer** (`capital::cutscene.primm_intro.3::0`)
    - Before: "Sorry, that's forest mud. I've walked a long way to get here, and everyone I met on the road was afraid of you."
    - After: "I'm sorry about the floor. It's forest mud. I've walked a long way to get here, and everyone I met on the road was afraid of you."
13. **Primm at the end** (`capital::cutscene.primm_end.6::0`)
    - Before: "I'm not going to correct you; that was always your way. I'm not going to forgive you either, not today. Start smaller than a kingdom. Say sorry to one person."
    - After: "I'm not going to correct you. That was always your way of doing things. And I'm not going to forgive you either, not today. Start with something smaller than a kingdom. Say sorry to one person."
14. **The ending: Maren** (`capital::ending.beat.10::2`) and the credits
    - Before: "...loud enough for the whole plaza to hear. She has said it in her kitchen; this is the first time she has said it to the kingdom. 'Welcome home.'" / "A game about a kingdom that was strong because it was not the same."
    - After: "...loudly enough for the whole plaza to hear. She has said it in her kitchen, but this is the first time she has said it to the kingdom. 'Welcome home.'" / "A game about a kingdom that was strong because its pieces did not match."
15. **The epilogue: Isla** (`scenes/isla_talk/steps/0::1`)
    - Before: "I keep walking to the gate and back. Nobody stops me. I keep expecting somebody to stop me."
    - After: "I keep walking down to the gate and back again, just because I can. Nobody stops me, and I still catch myself waiting for somebody to."

Primm's own lines, the castle's rooms, the funeral and most of the ending were read as scenes and kept nearly whole: they were already the
best writing in the game, and the bible quotes them.

## The critic: old against new

A reader with no context got 40 conversations (10 per tier; tier 4 as barks), each in two unlabelled versions in random order
(`docs/review/dialogue_nov13/`: `sample.md`, `key.json`, `critic_brief.md`, `critic_scores.txt`). Scores are 1-10.

| | Naturalness | Voice | Emotion | Clarity | Humour | Mean |
|---|---|---|---|---|---|---|
| **Old** | 7.65 | 7.30 | 5.88 | 6.28 | 6.78 | 6.78 |
| **New** | 7.33 | 7.88 | 6.35 | 6.33 | 6.78 | 6.93 |

| Tier | Old mean | New mean | New preferred |
|---|---|---|---|
| 1 main story | 6.94 | 6.88 | 4 of 10 |
| 2 core cast | 6.98 | 7.22 | 6 of 10 |
| 3 side content | 6.80 | 7.08 | 6 of 10 |
| 4 barks | 6.38 | 6.54 | 7 of 10 |

- **New preferred in 23 of 40.** The gains are in voice (+0.58) and emotional impact (+0.47). Humour is level. **Naturalness fell by
  0.32.** The reader's reason: some new lines "pad the line past its point with trailing clauses and fillers like 'you see'", burying a
  punchline or a hurt that the old line ended on. Where the new text won, it was for specific detail and for a voice nobody else has.
- **Tier 1 came out level (old preferred 6 of 10, means 6.94 against 6.88).** The main story's old lines were already the product of the
  Nov 5 rewrite, and several of my changes there were small. This is the place a human read is most worth having.
- **The 10 weakest lines the reader named: 8 were old lines, 2 were new.** Both new ones are fixed (Granny Gristle's turnip line now ends
  on its joke; Bertram's equipment-slots line is back to his deadpan).
- **Fixed after the critic (32 lines):** every conversation where the old version was preferred for a stated reason was revisited. 21
  lines went back to their original (Pallor's freed lines, the Doppelganger's reveal, Flex's "in, hold, and out again", Wren's "Hesper
  charges by the piece", Captain Spotless's barked opening, Fenwick's first line, Bertram's stamps, three barks) and 11 were tightened
  (Hob's "Paperwork. Heh.", Gary's "No rush. Bit of a rush.", Fenwick's "I won't judge. I sniff.", Professor Pump's sigh, Kestrel's quest
  lines, Granny Gristle). The scores above are from before these fixes; no second critic run was made.
- **The critic's confusions worth knowing:** the Old Well secret's cardsharp lines are labelled "Elder Maren" in the export though Dex
  Shufflewick says them (a label in the exporter, not in the game); "Three." in the third cave-mouth scene is unclear without the count of
  zones on screen; "8 reps to one beat" does not say what to press (the rule text elsewhere does).

### Second blind read (morning of Nov 13, after the fixes)

A second reader, with a different sample of 40 conversations drawn from the fixed text (`docs/review/dialogue_nov13/round2/`):

| | Naturalness | Voice | Emotion | Clarity | Humour | Mean |
|---|---|---|---|---|---|---|
| **Old** | 7.75 | 7.67 | 6.15 | 6.38 | 7.00 | 6.99 |
| **New** | 7.53 | 7.95 | 6.47 | 6.28 | 6.80 | 7.00 |

- **Level: new preferred in 19 of 40** (main story 4 of 10, core cast 6, side content 5, barks 4). Voice and emotion are up again;
  naturalness and humour are slightly down again. Two readers now agree, so take this as the real picture: **the rewrite made the cast
  more distinct and the sad scenes land harder, and it cost some snap.**
- **The reader's rule, which matches the first one's:** fit the length to the speaker. Short, flat lines won for the terse, the hurried
  and the deadpan (Kestrel, Rollo, Bertram, Ectomund, the Rip cousins). Longer, hedging lines won where the dithering is the character
  (Gerald, Basil, Kyle, Old Man Mountain, the Hollow Warden). The losing versions either padded a joke or an instruction, or trimmed away
  the one odd detail that made the speaker a person.
- **Fixed after this read (41 lines): 37 put back to their original text and 4 rewritten.** Kestrel's first talk, Rollo's talk and his
  wheel quest (his lines after the Capital is freed keep the new text), Bertram's greeting and barks, the Rip cousins' "rarely speak"
  line, Ectomund's "That is not corruption. That is personality.", Pallor's "Ideally both.", Bronson's "a terrible souvenir", Flex's
  "Now, shall we?", Maren's "And I ran.", and six barks went back. Tilly's two Power Wraps instructions were rewritten so the keys to
  press can be followed, and Maren's road hint says "the easiest one for you" again.
- **Counts after both rounds of fixes:** 1,208 lines differ from the text before tonight (Tier 1: 288, Tier 2: 383, Tier 3: 322,
  Tier 4: 215), down from 1,245. The tier table above shows the first count.
- After these fixes the full suite was run again in three foreground pieces (`run_tests.sh` has a new `--to=K`): 3070/3072, 0 failing.
  The workbook was rebuilt and copied to the Drive again.
- No third read was made. The pattern is clear enough that a human pass over the flagged speakers is the better next step.

## Checked in the game

Play-script runs (`docs/review/play_scripts/nov13/`, with the new `dev textsize 1` for Large text) at 1280x720 and at 1920x1080 (this
screen clamps that window to 1886x1061): the opening lines, Maren and Brannoch in Crosspath, Old Man Mountain and Foreman Gus in the
Gainlands, and Primm's entrance in the Model Room (1280x720 only). Shots: `docs/overnight_shots/nov13/` (8). No overflow, no cut-off text,
no unfilled token; portraits match the speakers. Every one of the 1,245 lines also passed the importer's box measure (at most 4 lines at
Normal and 6 at Large, the same measure as `tests/test_dialogue_fit.gd`).

Added in the morning: Kestrel and Captain Spotless at the Capital (1280x720, Large text; two more shots). Not run in the game: a zone's
whole main quest played through, Wren in the Crease, and the Primm fight to its ending (the play script reached his entrance and the
victory screen but not the ending scene; the mid-fight and ending scenes were checked by the box measure and the tests only).

## Plants and payoffs

22 pairs, with line IDs, are in `docs/writing/story_bible_v2.md`, section 4. The ones the rewrite touched or sharpened:
voices through a wall (prologue to the last cave-mouth scene); the door that knows one hand (the Warden to Maren's confession); the
lullaby (Fragment 1 to the Queen at the funeral); "again" (Fragment 2 to Primm's end and Agnes); four signs in a ring (the key, the crest,
Maren's stick, the headstones, the Throne); "never far from home" (Fragment 4 to "Welcome home" and the King); the gate that is never
locked (Brannoch to Isla); the two graves (Old Hob); the third form (Agnes to HEIR: ALIVE); filed on a Tuesday (Kyle and the HR memo to
Mortimer); the dumbbell and the frosting (Old Man Mountain and Basil to the Rescuer); the twelfth tree (Bramble to Compostella); "not the
part that matters" (Flex to Primm); a blank page (the Grand Chef to Primm); the wells (townsfolk and Wren to the journals and "I miss the
wells"); "I only wish somebody would say so" (the four insights to the hero's silence); her name (prologue to "somewhere with a roof");
"I always do" (prologue to Cell 4); Maren's handwriting (the recipe card to the note in the ward); the steady hands (cave mouth to the
hatch); argued like family (Maren to the Queen); the tidy lady with shears (Moss Mulligan to Clipwell).

## Decisions I had to make

1. **Fig Sly is unchanged.** `docs/design/canon.md` locks the black market vendor's lines and the importer refuses them; the brief lists
   him among the vendors. I kept the lock (14 lines). Inbox 1.
2. **No lines were added.** The format allows it only with an importer extension and several tests count lines per key. Every beat fitted
   its existing boxes, so I did not extend the importer for new IDs. Inbox 2.
3. **Endearments were reassigned** (Mirepoix "my sweet", Granny Gristle "my lovely" and "Hah!", Alembic "dear heart", Crumb "soldier" only,
   the Grand Chef drops "dear" in one bark, Clipwell none). These are verbal habits, not names. Inbox 3.
4. **Short-box tests were obeyed, not loosened:** Maren's idle lines stay under 140/160 characters, the prologue under 160, boss intro
   lines under 160.
5. **Tested phrases were kept** ("Tell me: which Path resonates within you?", "strength is not control", "treating people with respect",
   "easiest road for you", "Not on my list. Off you pop.", "Tell Basil", and so on).
6. **Basil no longer says "the real Chef"** before the reveal (he could not know); it is "Chef baked a birthday cake... back before all
   this".
7. **Flex's line in the breathing room changed** from "You carry the whole kingdom in your lungs, son" (which nearly names the hero) to
   one about a held breath.
8. **Nurse Hesper's wake line after the Capital is freed** now says there is no fee (it read as a charge for being defeated, and there is
   no defeat penalty).
9. **Primm's past is only what the castle already says.** The bible invents nothing about him.

## Kept usable: the playtesters' work

- `tools/import_playtester_dialogue.py` now reads the tier ledgers. A returned row whose line was rewritten tonight, written against the
  old text, is **not applied**; the report lists it under "Base changed tonight" with the old base, tonight's line and the tester's line
  side by side. Tested with a doctored copy of the Nov 9 workbook.
- `docs/dialogue/playtesters_nov13.xlsx`: a fresh workbook (same four tabs and columns A-N, 4,405 rows of tonight's text, the Voice Guide
  tab rebuilt from `voices.md`), built by the new `tools/build_playtester_workbook.py` and copied to
  `G:/My Drive/Card Game Art/Playtester Dialogue/Wayward Path - Dialogue for Playtesters (Nov 13).xlsx`. The "Speakers" tab is as it was
  on Nov 9. I could not open the file in Excel from here; the XML parses and the importer reads all 4,405 rows back. Inbox 6.

## What was not reached

- **Tutorial hints** are not in the dialogue export and were not touched. Loading tips are done (edited in the file; revert with git).
- **Signs, posters, memos and plaques** were read and almost all kept (about 480 lines): they are short and deadpan by design.
- **The dungeon event screens' choice results** were only touched where clipped; most were kept.
- **A second critic run** after the 32 fixes, and a whole zone played in the game.
- **Quest Log text** (titles, steps, "where to go") was left as it is: it is the wayfinding the last three passes tuned.

## Tools made tonight

| Tool | What it does |
|---|---|
| `tools/dialogue_scene_build.js` | Scene files ("@key", "idx| text", "## purpose") to an edit CSV for the importer, with checks |
| `tools/dialogue_scene_chunks.js` | Splits the export into writing chunks by tier and zone |
| `tools/dialogue_scene_review.js` | Prints a scene file's changed lines as old / new for review |
| `tools/dialogue_blind_sample.js` | Builds the blind old/new critic sample from the ledgers |
| `tools/build_playtester_workbook.py` | Rebuilds the playtesters' workbook from the game's text and `voices.md` |
| `tools/apply_dialogue_pass.js` | Now reverts a tier from its ids file alone; knows `{road}`, `{obstacle}`, `{card}` |
| `tools/play_script.gd` | New `dev textsize 0|1|2` |

The scene sources, with a one-line purpose for every conversation, are in `docs/dialogue/rewrite_nov13/` (`t1_*.txt` to `t4_*.txt`).

## How to revert

- **One tier's group** (the lines go back to their text from before tonight):
  `node tools/apply_dialogue_pass.js --revert=docs/dialogue/rewrite_nov13_t1_ids.txt` (Tier 1), or for the other tiers one file per
  group: `rewrite_nov13_t2_<gainlands|buffet|dna|dump|capital|town>_ids.txt`, `rewrite_nov13_t3_<town|gainlands|buffet|dna|dump|capital|postgame>_ids.txt`,
  `rewrite_nov13_t4_<town|gainlands|buffet|dna|dump|capital>_ids.txt`. A whole tier is those files one after another.
- **Single lines:** put their IDs in a text file and pass it with `--csv=<that tier's CSV> --revert=<file>`.
- **The loading tips:** `git checkout pre-dialogue-nov13 -- data/loading/loading_tips.txt`.
- **Everything:** `git checkout pre-dialogue-nov13 -- data core` (text files only changed there), or reset to the tag.
- After a revert run `bash tools/run_tests.sh`.


---

# Fable Nov 12d - report (2-hour pass: the broken checks, a fresh playtest, the ghost building, edges, RC6)

Brief: `docs/prompts/fable_nov12_2h.md`. Start tag `pre-fable-nov12d`. Questions: `docs/overnight_inbox.md`, "Fable Nov 12d" (7 items).
Shots: `docs/overnight_shots/nov12d/`. One Godot at a time; the one sub-agent (the critic) ran the game itself and nothing of mine ran
beside it. Owner constraints kept: no difficulty setting, the battle board and the menus keep their layout, no new art, Primm's fight
unchanged, nothing uploaded. Ran on Fable 5.2. The Fable Nov 12c report follows below.

## RC6

**RC6 is not built.** Free RAM stayed between 2.07 and 2.15 GB through the ten-minute wait (20:50 to 20:59, nothing of mine running);
the rule was 2.2 GB, so the export was not started. No exported smoke and no `play_exported.sh` check ran. The source is at
`1.0.0-rc6`, tested and pushed. To build it, close Chrome, ChatGPT and anything else heavy, then in Git Bash from
`C:\Dev\Deckbuilder-rpg`, in the foreground:

```
EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6
bash tools/run_release_smoke_exported.sh
bash tools/export_test_pack.sh
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480
SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480
grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log
```

The export takes 4 to 10 minutes ("EXPORT STOPPED" means nothing was replaced); the smoke must print `PASSED`; the last line must print 0
three times.

## One thing to know first: tests were overwriting your campaign-1 autosave

`%APPDATA%\Deckbuilder-RPG\saves\autosave.json` (and its `.bak`) was rewritten by test runs today, at 19:59, 20:25 and 20:44, with
test state (level 3, 450 gold, a Crease flag). Twelve test files switch saving back on at the real path. **I cannot tell what was in
that slot before today and cannot recover it**; campaigns 2 and 3 are untouched (Oct 24, Oct 31). I do not think this pass introduced it
(those tests date from Nov 7 on, and every full test run would have done the same), but that is not verified. Fixed from here on: under
a GUT run the default save path is a scratch file. Checked: the twelve files plus the Crease test pass (94 tests) and the autosave's
timestamp did not move. The last full test run was before this guard; the twelve files were re-run after it.

## At a glance

- **The three failing checks all pass.** One real game bug was behind them (Maren's Path talk); the rest was the smokes being out of date.
- **The critic scored clarity 6, fun 6, polish 6, but its report is partial**: it used 9 runs and reached neither the cave's pop-ups nor
  the Black Market screen. Five of its findings are fixed; the rest are in the inbox.
- **The Transit Yards ghost building is gone.** It was a townhouse standing in the draw-distance dissolve.
- **Zone edges: six zones shot, none fixed.** Three have something left (the Dump's two south corners, Crosspath's south band, the
  D.N.A.'s bare apron).
- **Motion: pickups bob.** Chests and per-zone ambient effects already existed.
- **Tests: 3070 / 3072 passed, 0 failing, 2 pending (40 shards, 24 minutes).**

## Part 1 - the three checks

| Check | Result | Game or smoke? |
|---|---|---|
| Opening-hour smoke (`run_playtest_smoke.sh`) | **Passes** | Both, see below |
| Controller smoke, "Y hides the card details" | **Passes** | Smoke (timing) |
| NPC visibility probe, Corwin Bale | **50 / 50** | Game |

**The opening-hour smoke, check by check:**

| Check that failed | Which was wrong | What changed |
|---|---|---|
| "the only active quest is Meet the Merchants" | Smoke | It expects Meet the Merchants and Fragments (Fragments starts at `trial_cleared` since Nov 7). |
| "every merchant met: hand it to Maren" and the seven after it (Maren takes it back, Make It Yours, its banner, the pack, the Packs screen, opening the pack, Make It Yours back, the store room) | Smoke | One cause: since Nov 3-4 the quest has a step "Equip Tilly's Power Wraps", which the smoke never did. It equips them now. |
| "Bertram says enemies roam the edges of town" | Smoke | His line says "the lanes round the edge of town" since the dialogue rewrite. |
| "the Starter Blade and every equipment slot" | Smoke | Since Nov 3-4 the quest ends on equipping the blade. The smoke equips it. |
| The four "main line appears after the armory quest" checks and "the own Path's quest is tracked" | Smoke | Since Nov 7-8 the zone lines start with Maren's Path talk, not with the armory. The smoke checks they wait, then start with the talk. |
| "Maren has the Path talk ready" / "Maren sends the hero to their own Path's zone" | **Game** | Her cave-mouth welcome never set `elder_greeted`. So the report after the armory quest played her first-meeting speech ("Up and walking. Good. I am Elder Maren...", "buy a few cards from Sable"), hours late, and the Path talk needed a second conversation. The welcome sets the flag now; saves made in between are healed when she is next talked to. Inbox 3. |

Also fixed in the game on the way: the opponent's turn logged "AI produced no legal action" when a duel ended while its move was being
announced (harmless, but an error line).

**The controller check** passed on the first run I made and had failed before: the smoke pressed Y while the last card was still
resolving or a once-ever tip held the pad, when the battle cursor rightly ignores it. The smoke waits for the cursor now. The game is
unchanged. The smoke also puts your zoom and camera angle back when it ends.

**Corwin Bale** stood at x 73.5, straight behind the townhouse at x 72 to 77 from both cameras. He stands in the open alley at x 68.5
now (the mirror of Nell Hargreave's spot) and strolls 2 m instead of 3.2 m, so he cannot reach the house.

## Part 2 - the no-context playtest

Report: `docs/review/critic_nov12d/report.md`. Brief: `docs/review/critic_nov12d_brief.md`. Dev build, the play-script driver, 9 runs,
about 22 minutes, 0 script errors in every run.

**Scores: clarity 6, fun 6, polish 6.** The first hour looked finished to it (about 7 for polish); the Capital rougher (about 5).

**What it did not reach** (it lost three runs to the New Game flow and two to its own cave scripts): the shrine, the Hollow Well, the
"Before the fight" panel, the Cave Warden and his closing words, Crosspath, Maren, the Black Market screen, the Transit Yards. **So the
new pop-ups and the Warden's closing words have still not been seen by fresh eyes.**

| # | Its finding | Size | Done? |
|---|---|---|---|
| 1 | "Back out into the wastes." shows on arriving in the Crease | S | **Fixed**: the Crease has its own line (inbox 2) |
| 2 | The Black Market is easy to miss: no name, an identical stall beside it, a small reach | S | **Fixed**: a "Fig Sly - Black Market" label, reach 1.8 m to 2.6 m (inbox 1) |
| 3 | The Crease's east wall fills half the frame; flat cream rectangles hang in the air | M | **Half**: the rectangles were lantern glass, now small amber lanterns. The wall is unchanged |
| 4 | New Game is three decisions before any story | M | Not changed (inbox 5) |
| 5 | Tidy-Bots knock you flat with no warning | M | Not changed (both hits followed debug jumps) |
| 6 | The Capital map is hard to read | M | Not changed |
| 7 | The minimap is a blurry blob | M | Not changed |
| 8 | The wall's faces are plain slabs | L | Not changed (art) |
| 9 | The enemy's name crowds its plate | S | **Fixed**: the name starts 6 px clear of the portrait ring |
| 10 | The Path choice interrupts the Rescuer; the Wanderer's portrait has a hard edge | S | Not changed: the edge is art, the order is the design |
| note | A room out of reach says "Step on it to find out" | S | **Fixed**: "You can't reach it yet: clear a room that leads to it." |

Three of the five S items are fixed, plus the S note and half of one M. Shots: `crease_arrival.jpg`, `crease_fig_label.jpg`,
`crease_black_market.jpg`.

## Part 3 - the visual leftovers

**The Transit Yards ghost building: fixed.** It was the townhouse at x 72 to 77, z 33 to 45, about 48 m from that camera: exactly where
the zone's draw distance ends, so it stood half dissolved for as long as the hero stood there. Pieces 7 m tall or more now draw 1.3
times further and switch without a dissolve. Before: `docs/overnight_shots/nov12c/partc/capital_before_transit_yards_default.jpg`.
After, same camera: `docs/overnight_shots/nov12d/capital_after_transit_yards_default.jpg` and `_low.jpg`.

**Edges of the other zones: shot, not fixed.** A new driver command, `edgeshots <prefix>`, stands the hero near the eight outermost
walkable points of a place and shoots each at the default and the Low camera. Sheets: `docs/overnight_shots/nov12d/edges/<zone>_edges_default.jpg`
and `_low.jpg`, with every single shot beside them. I looked at the default sheets only; the Low sheets are shot but not reviewed.

| Zone | Default camera | Left to do |
|---|---|---|
| The Dump | **A pale wedge at the south-east and south-west corners**: the camera sits inside the ravine's rim and sees the fog through its back | Close the rim from behind or hold the camera in. Worst of the six |
| Crosspath | A violet mist band along the bottom of the frame at the south edge | Rough but reads as a boundary |
| The D.N.A. | Flat grey apron to the horizon outside the offices | Bare, no void |
| The Gainlands | Sea and painted backdrop at all eight points | Nothing (a blank pale board stands on the west islet; not checked what it is) |
| The Buffet | Gravy sea and backdrop at all eight points | Nothing |
| The forest | Closed by trees and rock at all eight points | Nothing |

## Part 4 - motion

- **Pickups bob** (the Buffet's ingredients, the Dump's beans and crates, the Capital's compost, recipe cards and seed jars): a 9 cm
  bob, a slow turn for a single model, a breathing ground ring. Off on Low-end and under Reduce motion. Tested in a unit test; **I did
  not look at one in the game.**
- **Chests already animate open** (the lid swings, a flash of light; `ChestKit.open_animated`, since Oct). Nothing added.
- **Every zone already has an ambient effect** (`AmbientFx`, since Oct 17: dust in the Gainlands, steam in the Buffet, gnats and fluff
  in the Dump, motes and the paper drift in the D.N.A.). Nothing added.

**FPS on Medium after the pass** (this PC, 1600x900; measured with the tall-piece range at 1.45 times, shipped at 1.3 times):

| Place | Medium | Before (Nov 12c) |
|---|---:|---|
| Crosspath | 75.6 | 70.1 |
| The Capital, `perf_run capital_in` | 63.7 | 57.0 |
| The Capital, Transit Yards camera | 60.6 | 65.8 to 69.1 across the cameras |
| The Capital, Gate Plaza / Hungry Quarter / Palace Approach cameras | 64.5 / 62.8 / 66.4 | same range |
| The Buffet / the Dump / the Gainlands | 81.9 / 71.7 / 83.3 | 82.7 / - / - |

Medium holds 60 everywhere measured, but the Capital's cameras lost about 3 to 5 fps to the ghost-building fix (inbox 4).

## Part 5

- **Tests:** 3070 / 3072 passed, 0 failing, 2 pending (40 shards, 24 minutes).
- **Settings on this PC:** Camera angle is 0 (Cinematic, the default) and zoom is 1.5 in `%APPDATA%\Deckbuilder-RPG\settings.cfg`; they already read so when I checked, and I changed nothing by hand. Scripted runs no longer write the camera angle or zoom into your settings (that is how it got
  left on "Low").

## What's left before 1.0.0

1. **RC6 or 1.0.0 itself** (see the top).
2. **Ten minutes of your own play**: a new game through the cave (the pop-ups, the well, the Warden), then the Capital (the manhole,
   the Crease, Fig Sly). The critic did not get there.
3. **Inbox "Fable Nov 12d"**, items 1 to 4: Fig Sly's label, the Crease line, Maren's speech, the tall-piece range.
4. **Fig Sly's portrait** (`V-FIGSLY.png`) and the rest of Batch 15, still not delivered.
5. **The Dump's two south corners** (the pale wedge), if you want it closed before release.
6. The final checklist of the Nov 12c report below still applies.

---

# Fable Nov 12c - report (the owner's fix list, the pop-ups, the Crease, the world pass, RC6)

Brief: `docs/prompts/fable_nov12_fixes.md` (it replaced `fable_nov12_final.md`). Start tag `pre-fable-nov12c`. Questions:
`docs/overnight_inbox.md`, "Fable Nov 12c" (17 items). Shots: `docs/overnight_shots/nov12c/`. One Godot at a time; no sub-agent ran.
Owner constraints kept: no difficulty setting; the battle board and the other menus keep their layout (only the non-combat dungeon
pop-ups and the pre-fight rules panel were redesigned, as opened up); no new art; nothing uploaded. Ran on Fable 5.2. The Fable pass
Nov 11-12 report follows below.

## At a glance

- **Part A (the fix list): all ten items done**, each with tests and shots (table below). A7.1, Fig Sly's portrait, waits for your image.
- **Part B (the pop-ups): done.** Every non-combat room and the "Before the fight" panel are one illustrated card. Gallery below.
- **Part C (the 3D world): about a third done.** Done: contact shadows, the water, the Capital's and the Crease's edges, the marker
  size at the Low camera. **Not done: eight of the twelve items in whole or in part** - see "What was not done".
- **Part D (Batch 15): nothing to import.** `G:/My Drive/Card Game Art/Pending Review/Batch 15/` did not exist at any check (start of
  every part, last at the end). Two rows were added to `docs/art/batch15_nov12.csv` (V-FIGSLY, UI-NODE-BANNER); all 23 stay "To make".
- **Tests: 3065 / 3067 passed, 0 failing, 2 pending** (39 shards, 24 minutes, after Part C).
- **RC6: **not built.** The export needs 3 GB of free RAM by the house rule; this PC had 1.8 to 2.0 GB free through a 15-minute wait (nothing of mine was running), so it was not started. The source is at version 1.0.0-rc6, tested and pushed. The command is under Part E.****
- **Three things found on the way that were not on the list:** the Capital's grey rectangles were a cache bug (not missing art); the
  occlusion fader could leave a wall or a building invisible for the rest of a visit; the east wall and the front wall faded away
  whenever the hero walked beside them. All three are fixed.

## What was not done (read this before the rest)

- **Part C, item 2 (blended ground, less tiling, edge foliage):** not done.
- **Item 4 (map edges and voids):** done for the Capital and the Crease only. The four Path zones, Crosspath and the forest were not
  scanned.
- **Item 5 (stray quads, foreground obstructions):** only the quest markers' size near the lens. No zone-by-zone scan.
- **Item 6 (duplicate and broken sprites):** not done.
- **Item 7 (the Transit Yards ghost buildings):** the fader bug that could leave pieces transparent is fixed, **but the pale building at
  the top left of the Transit Yards view is still there** (`docs/overnight_shots/nov12c/partc/capital_before_transit_yards_default.jpg`).
  The fader is not fading anything at that camera, so it is something else; I did not find what.
- **Item 8 (faceted props), item 9 (the measured scale table), item 10 (hub storytelling clutter):** not done.
- **Item 11 (light):** every zone already had a grade (Crosspath, the forest and the Dump included), so nothing was added there. New
  light sources only in the Crease (nine lantern lights, five crystal glows).
- **Item 12 (the world motion list):** only the Crease's dripping stalactites. No pickup bob, door or chest animation, ambient life or
  castle music escalation.
- **Part E.1, the no-context playtest:** not run as a no-context critic. I drove the real flow with the play-script driver and the
  smokes instead (the well, the Warden's closing line, the first exit, the Crease, a Primm loss and retry) and looked at the shots
  myself. A fresh pair of eyes has not seen this build.
- **Fig Sly's portrait** is unchanged (as instructed, until the image lands).
- **Three checks fail that this pass did not cause and did not fix** (details under Part E): the opening-hour smoke's quest check, the
  controller smoke's "Y hides the card details", and one strolling citizen in the NPC visibility probe.

## Part A - the fix list

| | What | Done | Shots (`docs/overnight_shots/nov12c/`) | Tests |
|---|---|---|---|---|
| A1 | The Hollow Well: "Sacrifice a random card from your deck for the rest of this dungeon: heal 4 HP." | Random pick from the whole dungeon deck; heal 4 capped at max; the card is back after clearing, losing or leaving (`DungeonRun.deck_after_run`); "Leave it"; at full HP the button reads "You're at full HP" and is disabled; at the minimum deck size it says why; once per run; a save taken mid-dungeon holds the whole deck (a run is never saved, so the cave restarts from its mouth). The sacrificed card shows face up with "The well takes **Card Name**. It returns when you leave the cave." | `a1/`, `popups_after/well*` | `tests/core/dungeon/test_hollow_well_offer.gd` (16) |
| A2 | The Cave Warden's closing words show his picture | In the dialogue box with NPC-WARDEN (they were plain text in the "Through the Forgotten Cave" panel); the line that describes him is narration. Audit of every dungeon boss: all others had a speaker and portrait. The four gatekeepers' post-fight lines had the same gap: fixed. Baron Quadzilla, the Restless Cairn and the Store Room Ghosts have no portrait art (inbox 2). | `a2/` | `tests/ui/test_boss_closing_portraits.gd` (4) |
| A3 | Deck copies text | The only player-facing "4 copies" were two loading tips; fixed, plus the progression and essence docs, the designer guidance sheet and code comments. The in-game tooltips already named 3 and the per-level caps (Common 3; Uncommon 2, 3 from level 9; Epic 1, 2 from 12, 3 from 22; Legendary 1, 2 from 18, 3 at 30). The Glossary's Terms tab gained "Copies of a card" with the caps at your level. No itch page text mentioned copies. | - | `tests/core/data/test_copy_rule_text.gd` (3) |
| A4 | First exit from the cave | The hero stands 1.4 m to Maren's left (west), facing the square, and keeps facing it through her welcome. The old spot stood under her eave, so the fader hid her whole house. | `a4/` before and after at the default and Low cameras | `tests/world/test_cave_arrival.gd` (+1: position, facing, no building under either camera's sight line) |
| A5 | Chef Fennel Gravois's Snack | The token's data was already 1/1. It stood as 0/1 because the "zone met early" ease takes 1 attack off his units. Tokens whose numbers a rule or a boss event states now enter with those numbers (`GameState.create_stated_token`). All 44 texts that state a token's numbers match the token. | - | `tests/core/game/test_token_text_stats.gd` (4) |
| A6 | The Capital's floating grey rectangles | A cache bug: the rim's dead trees and rubble are painted cards that came back from the build cache with no material. Fixed at the root. Also fixed: wall sections left invisible by the fader; the east and front walls fading when the hero walks beside them. Added from the kit, on the ridges outside the wall: ruined houses, ash walls, toppled statues, rubble mounds, crystals (`CapitalRimRuins`), and ash ground under the walls. `matscan`: 2 groups before and after (the far apron and one tunnel arch); `groundscan`: 0 offenders before and after. | `a6/before/`, `a6/after/` (17 edge spots x 2 cameras) | `tests/world/test_capital_rim_ruins.gd` (7), `tests/world/test_occlusion_ground.gd` (+2) |
| A7 | Fig Sly's art; the dual-colour dots | The dots are gone from the card face every view draws (hand, board, full size, shops, the Deck Station, the collection, rewards, packs). The Path cost icons stay. **The portrait: nothing changed, no file landed.** | `a7/` (before, after, one card in each view) | `tests/ui/test_multipath_dots.gd` (3) |
| A8 | The Crease | An enclosed cavern (`CapitalCrease`): rock walls on three sides running on past the camera, a 7.6 m rock ceiling, about 100 stalactites (five drip), stalagmites, ten puddles, nine lantern lights, five crystal glows, a second stall and five stacks of painted crates. No sky, no castle. The six black doorways are floor hatches with a lit marker (same shafts); the tunnel is a timbered mouth in the east wall; the ladder stands against the west wall. **Quest:** a new main quest, "Under the Capital", starts and takes the tracker on first arrival in the Capital (inbox 6). **One "Services restored" bar.** NPC visibility probe: Wren, Fig Sly, Hesper and Kestrel pass at both cameras. | `a8/before/`, `a8/after/` (10 spots x 2 cameras + HUD) | `tests/world/test_crease_cavern.gd` (8) |
| A9 | Losing to Primm | "Fight Primm again" (Phase 1, full HP, the leaders' boons given once, earlier rooms kept) or "Leave the castle". Driven for real: a Phase 2 loss, Fight again (Phase 1 at 23 / 23 HP), a loss, Leave (back in the Capital). | `a9/` | `tests/core/dungeon/test_primm_retry.gd` (5) |
| A10 | Inbox 11 (a) and (b) | (a) the castle map shows a room's type once a room leading to it can be reached; (b) every castle fight's three reward cards include an Uncommon or better, the paid reroll too. | `a10/` | `tests/core/dungeon/test_inbox11_nov12.gd` (6) |

## Part B - the pop-ups

One card for every non-combat room and for "Before the fight" (`ui/dungeon/node_card.gd`):

- **Banner:** the dungeon's own painted map, cropped round the room and blurred, under a colour wash per kind and a vignette; the room
  kind's large icon in the middle with a glow and a bob; particles per kind (motes for a shrine, mist for the well, sparkles for
  treasure, embers before a fight). `UI-NODE-BANNER` becomes the base by itself when it lands.
- **Body:** vellum with dark ink inside the gold frame; the kind in small caps over the name; the flavour line in italics, wrapped into
  even lines; what it does as icon rows; "HP 9 → 15" with the heal as a ghost segment on the bar ("already full" at full HP); the cost
  as a chip; a primary and a secondary button with icons. Esc and the pad's B press "Leave it" where leaving is allowed.
- **Motion and sound:** the card scales and fades in over 0.25 s, the banner a beat later; a shimmer crosses the HP bar as it fills; the
  well shows the card it took; existing sounds on open, confirm and close. Still under Reduce motion.
- **Pre-fight panel:** the foe's cut-out (head and shoulders) or Bestiary picture in the banner; a row per rule (icon, name, one line); a
  hidden trait as a "?" row; two columns and a lower banner past five rules. A card taller than the screen gives up banner height.

**Gallery:** `docs/overnight_shots/nov12c/popups_gallery_before_after.jpg` (before and after, side by side);
`popups_before/` and `popups_after/` (the well open, at full HP and after the card is given; the shrine; an event; a rescue; treasure;
the pre-fight panel with 3 rules and with 9) at 1280x720 and 1920x1080; `popups_after_large_text/` at the largest text size.
**Controller:** the buttons take the pad's focus and B leaves (tests in `tests/ui/test_node_card.gd`, 14). I did not take a screenshot
with a controller prompt showing, and the controller smoke does not walk the cave's rooms.

## Part C - the 3D world

| Item | Done? |
|---|---|
| 1 Contact shadows | **Done.** Characters' blobs are darker with a dense core (0.42 -> 0.52 on Low, 0.70 on Medium and High) and a little bigger; every ground prop gets a soft base shade from one MultiMesh per scene (`PropShade`; none on Low-end). |
| 2 Blended ground | Not done. |
| 3 Water | **Done in part.** The shared toon water and the sea plane lean to the sky at a grazing view and the sea has slow ripples; the Capital's fountains use the shared water. The Dump's stream already used it. The town fountain keeps its own shader. |
| 4 Map edges and voids | The Capital (A6) and the Crease (A8) only. |
| 5 Stray quads | Quest markers shrink near the lens. No scan. |
| 6 Sprites | Not done. |
| 7 Ghost buildings | The fader's stuck-transparent bug fixed; the Transit Yards' pale building is still there. |
| 8, 9, 10 | Not done. |
| 11 Light | Grades already existed in every zone; new lights only in the Crease. |
| 12 Motion | The Crease's drips only. |

**FPS after items 1, 3 and the Capital work** (this PC, 1600x900; `docs/perf/runs/n12c_partc.md`, `n12c_partc_cap.md`):

| Place | Medium | Low | Nov 12 before |
|---|---:|---:|---|
| Crosspath | 70.1 | 91.3 | 69 / 91 |
| The Buffet hub | 82.7 | 101.8 | 80 / 99 |
| A battle | 352 | 371 | 354 / 350 |
| The Capital, four paint-over cameras (`tools/capital_fps.sh`) | 65.8 to 69.1 | 82.2 to 84.5 | 64 / 85 |
| The Capital, `tools/perf_run.sh capital_in` | **57.0** | 75.8 | this probe read 58.3 to 61.2 on Nov 3 |

Medium holds 60 at the Capital's paint-over cameras. **The other Capital probe reads 57**, and it read under 60 before this pass on
two of three earlier runs; I could not move it (restricting, merging and unshadowing the new rim ruins changed nothing: 57.0 both times).

## Part D - Batch 15

| File | Status |
|---|---|
| The 21 rows of Nov 12 | To make (the folder never appeared) |
| `V-FIGSLY.png` | To make (row added) |
| `UI-NODE-BANNER.png` | To make, optional (row added) |

## Part E - verify and build

- **Tests:** 3065 / 3067, 0 failing, 2 pending.
- **Driven for real:** the well offer, taken and at full HP; the Warden's closing line; the first exit; the Capital's edges on foot;
  the Crease at ten spots; a Primm loss, retry and leave. 0 script errors in the play runs I checked (the Capital edges and scans, the Crease, the Primm retry, the water shots).
- **Opening-hour smoke (`run_playtest_smoke.sh`): FAILED, not from this pass.** The cave, the arrival 1.4 m from Maren and her welcome
  pass. It then fails "the only active quest is Meet the Merchants" because Fragments is active too; Fragments has started at
  `trial_cleared` since Nov 7 (`QuestDefinitions.story_gate`). Eleven later checks fail after it. I did not fix the smoke or look at
  the later ones one by one.
- **Controller smoke: one check fails** ("Y hides the card details" in the ghost duel); the other pad checks pass.
- **NPC visibility probe (the Capital): 48 of 50 pass**; the two failures are one strolling citizen (Corwin Bale) at both cameras.
- **RC6:** **not built** (free RAM 1.8 to 2.0 GB for 15 minutes; the rule is 3 GB). No exported smoke and no `play_exported.sh`
  check was run on RC6. `project.godot` is at `1.0.0-rc6`, `CHANGELOG.md` and `docs/release/rc6_notes.md` are written. To build it:
  close Chrome, ChatGPT and anything else heavy, then in Git Bash from `C:\Dev\Deckbuilder-rpg`, in the foreground:
  1. `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6` (4 to 10 minutes; "EXPORT STOPPED" means nothing was replaced);
  2. `bash tools/run_release_smoke_exported.sh` (look for `PASSED`);
  3. `bash tools/export_test_pack.sh`, then
     `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480`,
     `SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480`,
     `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480`;
     `grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log` must print 0 three times.
  The zip should come out near RC5's 734 MB: this pass added code and shaders only, no art.

## One thing to check on your PC

The play-script shot runs save the camera angle into your settings: **Settings > Display > Camera angle is on "Low"** now (the shot
scripts end on it; I do not know what it was before this session). The controller smoke had also changed the zoom to 1.3; I set it back to
the default 1.5.

## The final 1.0.0 release checklist

As Nov 11's (in the Overnight Nov 10-11 report below: donation link, version, export, smoke, the three exported checks, the real exe
once, tag, the itch upload, download it back, flip to Public), with these changes:

0. **Read inbox "Fable Nov 12c" first.** Items 5 and 6 (the shafts as floor hatches; the new quest), 13 (the pop-ups' light vellum
   body) and 14 (the shrine can be left) change what players see and were my choices.
1. **Play ten minutes before anything else:** a new game through the cave (the well, the Warden, the first step into Crosspath), then
   a late save in the Capital (the edges outside the wall, the manhole, the Crease, Fig Sly). Nobody but me has looked at this build.
2. **Fig Sly:** when `V-FIGSLY.png` is in Pending Review / Batch 15, say "import portraits" (or run `bash tools/import_portraits.sh`),
   check him in the Crease, commit. Then export.
3. **Export RC6 (or go straight to 1.0.0):** the three numbered commands under Part E above. No RC6 zip exists yet.
4. Set the camera angle back if "Low" is not what you want players' default screenshots to show (it is a per-PC setting, not in the build).
5. Then steps 1 to 10 of Nov 11's list with `1.0.0`.

---

# Fable pass Nov 11-12 - report (visual quality, world consistency, late game)

Brief: `docs/prompts/fable_nov12_visuals.md`. Start tag `pre-fable-nov12`. Questions: `docs/overnight_inbox.md`, "Fable Nov 12" (12 items).
Shots: `docs/overnight_shots/nov12/` (`before/`, `after/`, `part4/`). Gallery: `docs/review/visual_nov12/index.html`. Style bible:
`docs/art/style_bible.md`. One Godot at a time; the three critics (art director before and after, late game) were no-context agents and no
Godot of mine ran while the late-game critic played. Owner constraints kept: no difficulty setting; the battle board and every menu layout
untouched (effects, shaders and colour inside existing elements only); no approved painting repainted or replaced. Ran on Fable 5.2 (the
launch line was pasted into a running session). The Overnight Nov 10-11 report follows below.

## At a glance

- **The art-director score did not move: 6.3 before, 6.2 after** (113 shots each, the same cameras, a fresh no-context critic each time).
  The second critic scored content this pass never touched about half a point lower (dungeon maps 8.2 -> 7.6, Crosspath 7.5 -> 6.9, the
  forest 6.2 -> 5.7), so the two numbers are not on one scale; against that drift the zones that were worked on gained (table below), but
  **the honest reading is: this pass fixed specific named faults, it did not lift the 3D world to the level of the painted layers.** The
  3D world scores 5.4-5.6 in both reports; the painted screens 7.4-7.6. What closes that gap is painted art (Batch 15) and material
  work on a scale this pass did not reach.

  | Group | Before | After | Change | Worked on? |
  |---|---:|---:|---:|---|
  | The D.N.A. | 4.4 | 4.7 | +0.3 | yes (lighting 3.6 -> 4.7) |
  | The Capital after Primm | 5.6 | 5.8 | +0.2 | yes (lighting 4.3 -> 6.8) |
  | The Gainlands | 5.5 | 5.7 | +0.2 | yes |
  | Battles | 7.4 | 7.6 | +0.2 | the tutorial board fix (4.8 -> 7.8) |
  | The Endless Buffet | 5.5 | 5.5 | 0.0 | yes |
  | Screens (UI) | 6.8 | 6.8 | 0.0 | no (layouts are fixed) |
  | The Capital before Primm | 5.8 | 5.4 | -0.4 | a little (wall, camera) |
  | The Verdant Dump | 5.8 | 5.3 | -0.5 | a little (ghost glasshouse) |
  | The Opening Forest | 6.2 | 5.7 | -0.5 | no |
  | Dungeon maps | 8.2 | 7.6 | -0.6 | no |
  | Crosspath | 7.5 | 6.9 | -0.7 | no |
  | **All 113** | **6.3** | **6.2** | -0.1 | |

  (Means of the six criteria per shot, from `docs/review/visual_nov12/scores_before.csv` / `scores_after.csv`.)
- **RC5 is built:** `builds/TheWaywardPath-v1.0.0-rc5-windows.zip`, **734 MB** (RC4: 734 MB; pack 845 MB, 14104 files, every MD5 matches).
  The release smoke on the exported pack **PASSED**; the three exported-build checks ran with **0 SCRIPT ERROR**. Full GUT before the
  export: **2984 / 2987 passed, 1 failing** (a test that pinned the old 97 % fade; fixed after), 2 pending. Not uploaded anywhere.
- **Performance held** (Medium, this PC): Crosspath 72 -> 69 fps, the Buffet hub 85 -> 80, the Capital 63 -> 64 (65 in the freed state),
  a battle 344 -> 354; Low unchanged (91 / 99 / 85 / 350). All inside this laptop's 10 % run-to-run drift; the Capital keeps about 4 fps
  over 60.
- **Late-game critic on RC5: clarity 6, fun 4, polish 6 (old build 5 / 4 / 5; target 7 / 6 / 7) - the target was missed.** It never beat
  Primm's Phase 2 or 3, so it did not see the ending. Part of that was the test driver skipping its turns (fixed; see Part 4.4). Four of
  its small items are fixed **in the source but not in the RC5 zip**: the re-export was stopped by the machine's low-memory guard and
  was not started again. **The zip on disk is the build from 07:59, before those four fixes.** No second critic was run.
- **Owner decisions applied:** max hand size 10 (inbox 1 says what replaced the three things that raised it); inbox 12 no change (a test
  pins the Armory's order); inbox 13 no change to Primm, and `dev primm N` grants the four boons (verified: 31 HP at the Phase 2
  checkpoint); Escape in a conversation kept.

## What was not done (read this before the rest)

The brief was a 24-hour pass; these parts were not done or only partly done:

- **Part 1:** no SSAO / SSIL / SDFGI (SSAO measured +2.3 ms on Medium in October and the Capital has 4 fps of headroom); no new sky or LUT
  per zone; no new light sources placed; sprites' contact shadows unchanged (both critics still call them faint). Per-zone grades were
  changed only in the D.N.A., the Gainlands, the Buffet and the freed Capital. FPS was measured in four places, not every zone.
- **Part 2.1:** the Gainlands got smooth cliffs and a calmer palette, **not** blended ground textures or edge foliage; its fortress brick
  still tiles (after-critic #6) and its shadows are still hard (#7).
- **Part 2.4, the scale audit:** the ratios are in the style bible; no zone-by-zone measurement was made and no outlier fixed.
- **Part 2.6, hub storytelling clutter:** none added (only the freed Capital's dressing).
- **Part 3:** only the gaps found were filled (buff shimmer, the result banner, zone-coloured fades). The battle list's other items
  already existed (lift / land, hit-stop, shake with its Settings toggle, floating numbers, death dissolve, the turn sweep) and were not
  re-tuned; the world list (pickup bob, door and chest animations, more ambient life) and the UI list (reward sequencing, a click-sound
  audit) were not worked on.
- **Part 4.2:** castle rooms do not escalate in music (the look does, through the vignette).
- **Top 25:** see the table - 7 done, 7 partly, 1 kept by design, 10 not (most need painting: Batch 15).
- **Part 4.4:** the late-game target (7 / 6 / 7) was missed (6 / 4 / 6); no re-score after the fixes; six of the critic's top 10 are
  not fixed or only half.
- **Part 6:** the RC5 zip does not contain the last four fixes (commit 86de96a4). The re-export was stopped by the low-memory guard
  before it wrote anything; the smoke and the three exported checks were therefore run on the 07:59 build only.
- **Memory before/after:** only "after" was read (below); no baseline was taken at the start.

## Part 0 - the audit and the style bible

- **The fixed shot set:** 113 shots through the play-script driver (`bash tools/nov12_shots.sh <tag> [set ...]`, scripts in
  `docs/review/play_scripts/nov12/shots_*.txt`): each zone's arrival, hub, main dungeon door and two mid-zone views at the default and
  the Low camera angle; the Capital before (9 places) and after Primm (5); 16 dungeon maps; 7 battles; 9 screens. New driver commands:
  `hud off|on`, `cam N`, `calm`, `spots`, `at <anchor>`, `matscan [m]`, `groundscan`.
- **The art-director critic** (brief `docs/review/critic_art_nov12_brief.md`; reports `docs/review/critic_art_nov12/report_before.md`,
  `report_after.md`): images only, six scores per shot, a ranked top 25.
- **`docs/art/style_bible.md`:** reference shots, a palette per zone, the lighting model, material rules (no pure-white, pure-black or
  untextured large surface), outlines and edges, a scale table (hero 1.70 m), foliage and ground, VFX.

## Parts 1-2 - the top 25 (the before report's ranking) and what was done

| # | Problem | Done |
|---|---|---|
| 1 | D.N.A. buildings are unlit black boxes | **Done, partly effective.** Ambient 0.4 -> 0.95 (#6f8a80), the key from the side (yaw 118), exposure 1.06, lighter wallpaper with a faint self-light, a brass picture rail; the wall at the lens cuts away on floor outside every room (`DnaRoomCut` - the giant chest's alcove was 40 % wall). Lighting 3.6 -> 4.7; the after critic still calls the zone a grey box (its floor and repeats). |
| 2 | The Capital after Primm is blown out | **Done.** `CAPITAL_FREED` is the inside's AgX grade turned to a golden afternoon (it was an old ACES preset). Lighting 4.3 -> 6.8. |
| 3 | Ghost buildings mid-fade | **Done for the Dump** (the glasshouse's glass stayed when its frame dissolved) and in general (`OcclusionFader.FADED` 1.0). **Not gone in the Capital's Transit Yards** (still in the after report). |
| 4 | Flat single-colour blocks | **Partly.** Every untextured flat colour gets a painted wash in the toon shader (`flat_wash`) and is never pure white or black. The critic still names the same blocks (Grave Row's box, the camp's slabs, the stalls, the mats): a wash is not a texture. Batch 15 rows. |
| 5 | Main dungeon doors do not read as doors | **Done for two:** the kit's painted oven-brick door in the Test Kitchen's arch and the studded door behind the House of Gains' portcullis. The D.N.A.'s Hall already had its kit door; not changed. |
| 6 | Faceted low-poly props | **Partly:** smoother Capital lamp globes. Hedges, statues, the D.N.A. sphere: not done (Batch 15 rows for the statue and the orb). |
| 7 | Smiley portraits and emblem | **Kept** (Primm's emblem; inbox 7). Batch 15 asks for painted easel portraits. |
| 8 | Windows are flat colour cut-outs | **Done in the Buffet** (glazing bars, oven grates). **Not in the Capital** (hundreds of panes: Batch 15's first row). |
| 9 | Broken Low camera at the Resistance Camp | **Done.** The lens rides 1.1 m over the ground under it and the Capital counts its rim hills. |
| 10 | Flat city wall and grey gate road | **Partly:** dust over the plinth and streaks under the cornice. Still "no surface detail" for the after critic. |
| 11 | Navy rectangle on the palace | **Done:** five cloths in the Paths' colours (painted banners: Batch 15). |
| 12 | Stray giant quads and billboards | Not done (quest markers and paper at the Low camera). |
| 13 | Tutorial battle has no board art | **A dev-tool artefact, fixed:** `dev encounter` now uses the cave's board (4.8 -> 7.8). Players always had it. |
| 14 | Map edges show voids and strips | Not done (Batch 15: a rubble row). |
| 15 | Gainlands materials tile and stretch | **Partly:** smooth-shaded cliffs and rocks, saturation 1.26 -> 1.12, a calmer sea. The brick and the mats: not done. |
| 16 | Buffet is an orange monochrome with haloed sharpening | **Partly:** a lavender fill light; the default sharpening 0.8 -> 0.4 for every zone (new installs; a saved setting is kept). |
| 17 | World map looks like a debug view | Not done (painting: Batch 15). |
| 18 | Flat-colour windmill blades and bunting | Not done (Batch 15). |
| 19 | Fountain water flat blue with scribble | Not done. |
| 20 | Flat bridge deck and grey water at the Dump | Not done. |
| 21 | Foreground obstructions | Not done. |
| 22 | Duplicate and broken sprites | Not done. |
| 23 | Battle item slots and plain overlays | **Partly:** VICTORY / DEFEAT stand on a band with an outline. The slots: Batch 15. |
| 24 | Dungeon maps hide their own art | Not done (UI layout). |
| 25 | Shop screens clipped and empty | Not done (UI layout: owner constraint). |

**The known ones from the brief:**
- **2.2 the material scan** (`matscan`): lists every untextured surface of 2.5 m or more per zone; the wash above is the blanket answer.
- **2.3 the Capital after Primm celebrates** (`CapitalCelebration`): the golden light, the fountains running again, a crowd of townsfolk
  in the Gate Plaza and on the avenue with six new passing lines, bunting from the fountain to the plaza's lamps and across the avenue,
  confetti on the paving, the Path-coloured cloths. One mesh for the decor; Low-end halves the crowd and drops the confetti. Medium 65 fps
  freed against 69 before at the gate. **The after critic's verdict: "a nicer time of day, not a celebration"** - it wants several times
  the crowd, banners on the houses, stalls and a changed sky. The crowd is 18 people; this is the place to add more if you want it.
- **2.5 the prop-ground check** (`PropGroundCheck`, `groundscan`, 5 tests): all five zones scan clean apart from by-design pieces.
- **2.7 the leftovers:** the cracked mirror is nine dark shards on a backing (was one pale pane); **Old Hob's stuck portrait reproduced
  and fixed** (the listener portrait stood alone for 0.7 s after a scene's last line - the midgame critic's route, before and after
  shots in `_screenshots/play/n12_repro_hob/`); the entrance roamer stays beaten per save; the Rift pop-up was already once ever; the
  "milky" fades were the 3 % residue and the glasshouse glass.

## Lighting changes per zone

| Zone | Changed |
|---|---|
| The D.N.A. | ambient 0.4 -> 0.95 and greener, key yaw 140 -> 118, exposure 0.98 -> 1.06, wallpaper tint and self-light |
| The Gainlands | saturation 1.26 -> 1.12, post saturation 1.22 -> 1.08, look saturation 1.16 -> 1.04, shadow opacity 0.7 -> 0.62, sea tint, smooth cliff normals |
| The Endless Buffet | ambient #e8c2a4 -> #c9b4d2 (a lavender fill) at 0.56, shadow tint to match |
| The Capital, freed | a new preset on the inside's grade: sun pitch -34, warm key, violet ambient 0.42, shadow opacity 0.62, exposure 0.46 |
| Everywhere | default sharpening 0.8 -> 0.4; scene fades in the zone's colour; untextured flats washed |
| Crosspath, the forest, the Dump, the Capital before | unchanged |

## Part 3 - the motion list

Added: a band of light crossing a card when its numbers rise (`card_shimmer.gdshader`); the result word on a band with an outline and a
swell; scene fades through the zone's colour (`SceneManager.fade_colour`). All hurried by the battle speed and off or still under Reduce
motion. Already in the game and left as they were: card lift and land, attack recoil, hit-stop and the final blow's slow motion, screen
shake with "Reduce screen shake", floating damage and heal numbers, the death dissolve, the turn ribbon, button hover and press easing,
click sounds everywhere (`UiSounds`), footstep puffs and per-zone ambient particles. Not done: see "What was not done".

## Part 4 - the late game

- **4.0 max hand size 10:** `GameState.MAX_HAND_CAP`; levels 14 / 28, the Lanyard, Quota's Stopwatch and the Weighing Scale no longer
  raise it (inbox 1).
- **4.1 owner decisions:** inbox 12 and 13 no change; `dev primm N` grants the four boons.
- **4.2 the turn panel** follows the turn the board has played back to (it flipped to "Your turn" in the middle of the foe's attacks).
  **The mirror phase:** Primm's copies of your cards wear a constant silver sheen and the rule says "His copies sit on his side of the
  table and shine silver, like a mirror; the plain ones are yours." **The build-up:** castle fights wear a rift-violet vignette that
  deepens with the rooms cleared; the three phases have their own (gold, cold silver, pulsing violet with cracks of light).
- **4.3 the ending:** each still drifts slowly (`StillBackdrop.drift`), a 2.4 s crossfade into the credits, a "Thank you for playing" card
  naming the Lab and the Gallery, then the postgame announcement. Music cues unchanged (the three beat cues and the credits cue existed).
- **4.4 the late-game critic on RC5:** `docs/review/critic_late_nov12/report.md` (30 scripts, 34 runs on the exported pack, 0 SCRIPT ERROR). Scores
  6 / 4 / 6. Phase 1 won in 8 turns; Phase 2 lost four times, Phase 3 lost once and one unfinished. Its built-in player stalled 2-6
  times a fight there: in a ten-card hand it clicked the covered centre of a card, nothing happened and the driver passed the turn.
  `tools/battle_pilot.gd` now clicks the card's uncovered strip. After that, on the dev build at level 20: Phase 2 **won** (1 try, no
  stalls), Phase 3 **lost 3 of 3** (turns 6, 7, 7, no stalls). Primm was not tuned (owner decision); inbox 10 asks the owner to play
  Phase 3 once. Fixed from its top 10: #4 the turn panel left the screen during Setting Up (the line is set smaller and can no longer
  widen the panel), #5 the funeral is on the map and in "Point me to...", #7 the Phase 3 hint, #10 the reward line's wording, #3 the
  driver. Not done: #1 and #2 (Primm's difficulty, retry a phase), #6 (room fog), #8 (needs painting), #9 (not reproduced), the
  smaller notes. All four game fixes were checked on screen in the dev build (`docs/review/play_scripts/nov12/late_fix_*.txt`).

## Part 5 - Batch 15

`docs/art/batch15_nov12.csv`: 21 rows in the earlier batches' columns, ranked. The top: the Capital's windows (2), six painted area maps,
the battle item slots, ICON-EQ-HALLPASSSLIPPERS, ICON-GEAR-EARNEDBLADE, Dex's table and card back, Primm's easel portraits (3), the freed
banners (4), NPC-HESPER and STORY-EPI-WRINKLES (REDOs), the Gallery's eight bestiary pictures and its map, prop cards for the things both
critics called stand-ins (the Dump's statue and sails, the Buffet's stalls, the D.N.A.'s orb, a rubble row), locked packs, a credits
panorama, lanterns and fireworks for the freed sky. The after critic adds candidates not yet in the list: the Gainlands' fortress brick,
the Dump's heart door, painted hedges.

## Part 6 - verify and RC5

- **Tests:** `tests/test_fable_nov12.gd` (20: Primm's phase restart and the boons, the Armory's order, the freed preset, the cloths, the
  celebration and its Low-end cut, the hand cap, the finale vignette, the wash range, the fade colour, the mirror sheen) and
  `tests/world/test_prop_ground_nov12.gd` (5). Full GUT, 38 shards, 24 min: 2984 / 2987, 1 failing (fixed), 2 pending. After that run
  only the default sharpening and its test changed (those files re-run green). **After the late critic's fixes (3 new tests): full GUT
  again, 38 shards, 24 min: 2988 / 2990 passed, 0 failing, 2 pending.**
- **Performance** (`docs/art/graphics_tier1/fps_n12_before.md` / `fps_n12_after.md`, 5 s each, vsync off):

  | Area | Low before | Low after | Medium before | Medium after |
  |---|---:|---:|---:|---:|
  | Crosspath square | 92.3 | 91.1 | 71.9 | 69.3 |
  | The Buffet hub | 99.8 | 99.4 | 84.9 | 80.3 |
  | The Capital, inside | 85.8 | 85.1 | 63.2 | 64.2 |
  | A battle | 353.5 | 350.1 | 343.8 | 354.0 |

  The battle is an ordinary fight, not a boss (the finale vignette is one full-screen pass on a 350 fps screen). Memory after, one
  session walking Crosspath -> the Capital -> the Buffet: working set 1.80 GB / 0.96 GB / 0.91 GB, video memory 1026 / 930 / 700 MB. No
  before reading was taken.
- **Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc5` -> EXPORT OK, zip 734 MB, export peak 1.83 GB working set.
  The "over the 750 MB budget" warning is the same as RC3's and RC4's. The RC4 zip is kept.
- **Checks:** `run_release_smoke_exported.sh` PASSED (1.0.0-rc5). `play_exported.sh` A, B (A's settings), C (Low-end): 0 SCRIPT ERROR in
  all six logs. Three `button Continue: NOT FOUND` lines (A twice, B once) are the scripts pressing a box the Enter key had already
  closed; the shots show the game back in Crosspath.
- **Not re-exported:** the four late fixes (turn panel, funeral map entry, Phase 3 hint, reward line) are in the source after the zip
  was built. A second `export_windows.sh 1.0.0-rc5` started with 2.1 GB free and was stopped by the session's low-memory guard during
  the import step; the zip from 07:59 is untouched (MD5s as checked then). To get them into a build: close other programs, run the
  export line above, then `run_release_smoke_exported.sh` and the three `play_exported.sh` checks.
- **Docs:** `CHANGELOG.md`, `docs/release/rc5_notes.md` (both list the four late fixes; the notes say they need the re-export).

## Release-day checklist (the owner)

As Nov 11's (below, in the Overnight Nov 10-11 report), with these changes:

0. **Re-export RC5 (or go straight to 1.0.0) before giving it to anyone**: the zip on disk lacks the last four fixes.
1. Read inbox "Fable Nov 12" first - items 1 (hand-size replacements), 5 (six new crowd lines) and 6 (fountains running) change what
   players see and were my choices.
2. Decide whether RC5 or RC4 is the base for 1.0: RC5 changes the look of every zone a little (the wash, the sharpening) and of three
   zones a lot. If in doubt, play the D.N.A., the Gainlands and the freed Capital for five minutes each on your own screen.
3. Then steps 1-10 as before, with `1.0.0` in place of the RC name; the three exported checks may print the harmless `NOT FOUND` lines
   above.
4. After release: Batch 15 is the next visible gain; the after critic's top 25 (`report_after.md`) is the list to work from.

---

# Overnight Nov 10-11 - report

Brief: `docs/prompts/overnight_nov10.md`. Start tag `pre-overnight-nov10`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 10-11".
Shots: `docs/overnight_shots/nov11/`. One Godot at a time; the critics (the wayfinding critic, the late-game critic) were the only Godot while
they played, and no sub-agent ran while a Godot of mine did. Owner constraints kept: no difficulty setting; the battle board and the UI
layout untouched (Part 1's token stacks and the Setting Up words live inside the existing row and rule row); Primm as he was. Owner
decisions applied: stashes stay marked while a step wants one (1); the Dump's herd grazes on the Commons (2); the D.N.A.'s Hall door marked from arrival
(3); the Capital's secret wall hole kept (4). The Fable pass Nov 10 report follows below.

## At a glance

(Resumed Nov 11 after a PC reset cut the run after Part 5.)

- **RC4 is built:** `builds/TheWaywardPath-v1.0.0-rc4-windows.zip`, 734 MB (pack 845 MB, 14098 files, MD5s match). The release smoke on
  the exported pack **PASSED**; the three exported-build checks (fresh settings, carried settings, Low-end) ran with **0 SCRIPT ERROR**.
  Full GUT before the export: **2965 / 2967 passed, 0 failing** (2 pending), 38 shards. Not uploaded anywhere.
- **The exported-build critic's top 10 (Part 1):** all ten done - gates named in the main quest's "Where to go", roamers 10 m clear of every
  door, token swarms stacked "xN", "Setting Up" in words, 6 s toasts, E prefers the quest NPC, alphabetical "Point me to...", Esc order.
- **Wayfinding, minutes to the main dungeon door** (no-context critic, exported pack, guidance only):

  | Zone | Nov 10 | Run 1 | Run 2 |
  |---|---|---|---|
  | The Gainlands | not reached, 23.5 | reached, 21.2 | **reached, 18.6** |
  | The Verdant Dump | not reached, 19.1 | not reached, 24.0 | not reached, 24.1 (traversal, not direction; fixed after) |
  | The D.N.A. | reached, 18.3 | **reached, 5.8** | - |

- **Fight pacing (Part 3):** the expected player now plays the midgame's 27 ordinary fights in **5.6 turns** (5.8), 98 % wins, **none over 7**
  (2 before), after about -20 % HP on the L10-14 band's ordinary foes. The real cause of the critics' 9-11 turns is **gear**: a bare hero still
  runs 9-10 turns - **inbox 12 is your call** (accept / a stall breaker / steer damage gear).
- **Late-game critic (Part 4): clarity 5, fun 4, polish 5 - no change from 5/4/5.** Its top 10: Primm's Phase 2-3 HP wall (**inbox 13**, Primm
  untouched), "Every unit is a 3/3" vs 7/4 (reworded), the 10+ card hand (logged: board layout), turn label / Setting Up countdown (countdown
  fixed, ribbon lag logged), Tidy-Bot drain (fixed: 10 s retreat), stale battle hints (fixed), dialogue over the node panel (fixed), mirror-phase
  ownership / the cracked-mirror quad / the unchanged Capital (logged). **A blocker it led to was fixed first:** after "Skip card" on a boss's
  reward, E never advanced the boss's closing words - Primm's included, so the ending could not be reached that way.
- **The release-day checklist** is at the end of the Finish below.

## Part 1 - the exported-build critic's top 10 (inbox 14)

| # | Problem (critic) | Done |
|---|---|---|
| 1 | The main quest's dungeon step never names the gate | Every zone's dungeon step "Where to go" line names the gate and what opens it, and a second line once it is open (`QuestObjective.hint_open` / `way_open`): the Buffet "Sir Loin's gate on the way wants Old Meatloaf mended - see Basil (the favour Mend the Meatloaf)" -> "Sir Loin's gate is open: north over the Gravy River on the Lazy Susan"; the Dump "Two things bar the way: the stream (plant the Magic Bean from the stream bank at the West Sprout Mound...) and the junk barricade on the stairs (charge it on a mount from the stables)" -> "The way is clear"; the Gainlands "Nothing is locked on the way: the middle road climbs straight to it from the bridge, past three road guards"; the D.N.A. "Its door is open: no permit, no favour, nothing locked on the way". Mend the Meatloaf's summary ends "Needed for the gate: Sir Loin opens the way to Layer-Cake Town and the Test Kitchen for a mended loaf." Owner decision 3: the D.N.A.'s favour step carries a part that marks the Hall's door from arrival (its hint: "...or go straight up to the Hall of Final Approvals: its door is open, no favour needed"). |
| 2 | A roamer camps the Test Kitchen door | `ZoneScene.ROAMER_DOOR_CLEARANCE` 10 m: `tests/world/test_roamer_doors_nov11.gd` builds every zone headless and fails on any roamer whose home +/- patrol comes within 10 m of a dungeon door, a gate or the exit (and on a home a roamer may not walk); it prints the nearest fitting home for an offender. Eleven moves (inbox 1): the Buffet's jelly (50, 20) -> (36, 32) - the Gelatin Sentinel - its loaf and the hub meatball, the Dump's gulls, the Capital's two castle-approach roamers, its tunnel-mouth inspector and a Tidy-Bot; the scene's exit roamer stands 14-17 m out. Road guards are the obstacle on their road by design and are exempt. |
| 3 | 9-11-turn fights | Part 3 below. |
| 4 | The boss's token swarm overlaps | Identical tokens on the battlefield (same card, same live numbers and state; not attacking, blocking or blocked) share one slot with an "xN" badge (`BattleBoard._field_stacks`, `FieldStack<owner>_<n>`), both sides, from two copies up; the row's spacing counts slots, so seven Sashimi Weenies take one card's width. Real cards never stack; the pad skips the cards under a stack's top. |
| 5 | "Setting Up" is an unlabelled hourglass in the fight | "Setting Up - attacks start Turn 3" stands beside the hourglass in the rules row (`RuleIconRow.set_note`, `BattleHud._refresh_setup_note`) until the window is over; the turn panel's countdown now survives every refresh (a sync wiped it). |
| 6 | Toasts stay 20-30 s | The HUD toast is capped at 6 s plus the fade on the wall clock (`TownHud.TOAST_MAX_HOLD`; `_process` enforces the deadline whatever the tween does) and a click dismisses it. |
| 7 | E prefers plaques to the quest NPC | A person with a quest to give or hand in wins the E prompt over a plaque, a sign or a prop in reach, and reaches 0.8 m further (`ZoneScene.QUEST_NPC_BEATS`); never over a door, an exit or a station. |
| 8 | "Point me to..." reorders | Goals first (the tracked quest's first), then the places in alphabetical order (`FullMapScreen.where_to_places`). |
| 9 | The favour toast survives accepting | `TownHud.clear_toast("has a favour to ask")` when the offer is taken. |
| 10 | Escape opens the pause menu over pop-ups | `SceneManager.close_top_popup`: Esc presses Continue on a visible reward / quest-complete / level-up box, else advances the open conversation; the pause menu only when nothing else is open (inbox 8). |

Tests: `tests/ui/test_part1_fixes_nov11.gd` (10: the four zones' hints, the Buffet's line before and after the gate, the Dump's open line,
the D.N.A.'s door on the favour step, seven tokens -> one slot with "x7", a hurt / attacking token leaves the stack, real cards never stack,
the Setting Up note and its end, the alphabetical list, the toast cap and clear) and `tests/world/test_roamer_doors_nov11.gd` (6: the five
zones, the exit roamer). The quest, wayfinding, route, board token, rule badge, hand number and turn counting suites green after the change.

## Part 2 - wayfinding in every zone, proven

### 2.1 The Dump's arrow (inbox 11)

`RouteGuide` plans on a per-zone grid and frame budget (`setup(..., grid, budget)`; `ZoneScene._route_grid` / `_route_budget_usec`,
`QuestMarkerLayer.set_routing`): the Dump uses a 1 m grid and 12 ms a frame (`HeapScene.ROUTE_GRID` / `ROUTE_BUDGET_USEC`), the other zones
keep 0.75 m and 5 ms. `tests/world/test_route_grid_nov11.gd`: the Commons -> Rotheart plan (the failing strict search plus the gated one)
takes 0.8 s of search in 67 slices (1.4 s in 273 slices before), so the arrow follows the route about 1.1 s after a pick instead of ~4.6 s;
the gated route still crosses the stream on a vine bridge's line and the grown-bridge strict route still exists.

### 2.2 The no-context wayfinding critic on the exported build

A fresh critic (brief `docs/review/critic_wayfinding_nov11_brief.md`, report `docs/review/critic_wayfinding_nov11/report.md`, 46 runs on
the RC4-tree test pack after Part 1 and 2.1, fights auto-won, no dev travel) arrived in each zone and had to reach the main dungeon's door
with the game's guidance only:

| Zone | Nov 10 (before any fix) | Nov 11 run 1 (after Part 1, 2.1) | Clarity | What stopped or slowed it |
|---|---|---|---|---|
| The Gainlands | not reached, 23.5 min, 17 runs | **reached, 21.2 min, 20 runs** | 2 -> 5 | the gym hall north of the Station dissolved (the occlusion fader's 6.5 m "clutter" rule) so the road looked open and it walked into an "invisible wall" for 5.4 min; the legend's "Goal:" rows were not buttons; the Flex Mirror's 1.5 m reach |
| The Verdant Dump | not reached, 19.1 min, 14 runs | **not reached, 24.0 min, 21 runs** (stopped at the junk barricade, 40 m from the door, with the bean planted and the bridge grown) | 3 -> 3 | "finish a favour" did not accept Brother Bramble's side-dungeon quest, so it never saw the dungeon step and its text about the stables; planting the bean and growing the bridge changed nothing visible in the tracker |
| The D.N.A. | reached, 18.3 min, 11 runs | **reached, 5.8 min, 5 runs** | 5 -> 8 | the front desk (no routing); the arrival pop-up |

Fixed from its report (run 2 follows below):
- **The gym hall never dissolves as clutter** (`occlusion_near` 2.0 on its meshes, as the other landmarks): the critic's four lost runs
  (`g14_n1.png`, `g17_gap.png`: an open plaza where a two-storey brick hall stands) were the fader hiding the building the arrow routes round.
- **"Finish a favour" accepts the zone's side-dungeon quest** (`QuestDefinitions.ZONE_SIDE_QUEST`), and the favour hints say "any quest one of
  them gives you counts" (inbox 7).
- **A part done is announced**: "Quest updated / Root Cause / Done: A Magic Bean (by the stream...)" when a part of the current step completes
  without the step moving (`Session._note_step_moves`, inbox 8).
- **The legend's "Goal:" rows are buttons** (a click points the arrow at that quest's nearest place, inbox 10); **the Flex Mirrors answer E from
  2.4 m**; **the herd's two far animals graze on the Commons** (owner decision 2, inbox 11).
- Logged, not changed: the entrance ambush and the Rift Station pop-up repeat on every entry (a `dev save` resumes at the entrance: a human
  enters a zone a few times, not twenty); the Commons' counters; the junk gull's -2 HP (the zone's hazard).

**Run 2** (resumed Nov 11 after the PC reset; same no-context critic brief, `docs/review/critic_wayfinding_nov11_brief_run2.md`, on a test
pack exported after Parts 2.2 and 3; report `docs/review/critic_wayfinding_nov11/report_run2.md`, saved by me from its final message as its
own write was refused; scripts `wy_*`, shots `_screenshots/exported/wy2_*.png`):

| Zone | Nov 10 | Run 1 | **Run 2** | Clarity | What slowed it |
|---|---|---|---|---|---|
| The Gainlands | not reached, 23.5 min | reached, 21.2 min | **reached, 18.6 min, 24 runs** | 2 -> 5 -> 6 | the "middle road climbs straight" line (the road jogs west round the gym hall; it took the far west road and its stone bridge, ~120 s + 4 runs on the bridge's sticky west end); a road guard fight on every arrival; the door dialog said "???" |
| The Verdant Dump | not reached, 19.1 min | not reached, 24.0 min | **not reached, 24.1 min, 39 runs** (bean planted, bridge crossed, mount taken; stopped wedged in town) | 3 -> 3 -> 5 | traversal, not direction: wedged between the barn and a crate / planter on the town -> bean line, the golem fight beside the bean on nearly every pass, stair edges; the line still named the bean after it was planted and did not say which stables |
| The D.N.A. | reached, 18.3 min | reached, 5.8 min | (not re-run) | 5 -> 8 | - |

The Dump's 24 minutes went on walking, not on finding the way: its report says the text "said exactly what bars the Rotheart", and every
resumed run re-walks from the entrance (39 resumes x 25-60 s). Fixed from run 2:
- **The Gainlands' line describes the real road**: "take the middle road - it leaves the plaza west round the gym hall, turns back east behind
  it, then runs straight north along the ridge past three road guards to the fortress stairs (the far west road and its stone bridge are the
  long way round)".
- **The Dump's line follows the way**: once the stream is crossed it stops naming the bean and says "one thing left: the junk barricade on the
  stairs north of the Farm Terrace - borrow a mount at the Farm Terrace stables (across the stream, not the town's)"
  (`QuestObjective.step_hint` / `current_hint`); the stables marker says "The Farm Terrace stables, across the stream".
- **The town wedge**: the crate (40, 112.5) and the planter (41.5, 112.5) beside the barn are gone; **the Mossy Trash Golem** roams at
  (28, 118) r 2.5, 11 m clear of the bean and the mound (was (30, 109) r 3.5, between them); a test keeps every roamer 6 m clear of both.
- **The main dungeon's door dialog** carries the dungeon's name (the prompt over the door already said it; "???" stays on maps before a visit).
- Logged, not changed: the world arrow's floating label shows the tracked quest's name, not the "Point me to..." pick (the arrow itself
  follows the pick); the mount is not kept by a `dev save` resume; the Gainlands' stone bridge's west end is sticky (a 1 m step needed); the
  road guard 8 m in fights on every arrival (by design: the guards are the middle road's obstacle; a player arrives a few times, not 24).
  **The Dump was not re-run a third time** (it would take another ~70 minutes of the morning, and run 2's cap came from traversal the fixes
  above address); worth one run after release if you want the number.

## Part 3 - fight pacing (ordinary fights)

**Cause.** Not enemy HP alone: **the player's gear.** The balance sim's expected player (the `ProgressionModel` deck, gear and items
for the level) already finished the midgame's 27 ordinary fights in 5.8 turns on average (2 over 7). The critics' 9-11 came from a hero
without that gear. A hand-played sample (resumed Nov 11, `docs/review/play_scripts/n11_pace_sample_a.txt` / `_b.txt`: the exported-build
critic's own level-14 hero `bot_refusemancer_enter_gourmand`, the built-in pilot, after the first HP trim) took **10 turns** (Gelatin
Sentinel), **11** (Frozen Line Cook), **13** (Meatloaf Golem) and **lost in 8** (Prep Station Sous-Chef). The sim's gear lift on the
Gelatin Sentinel (`--what=gear`, `_logs/sim_gear_probe.md`) shows why: bare (no gear, no items) **9.2 turns, 72 %**; the model's L13 gear
**6.3 turns, 94 %**; gear + items 6.6, 100 %. The bot's five pieces (Clipwell's Shears, Mystery Stain Bib, Raccoon Crown, Gotta-Go Galoshes,
Quota's Stopwatch) each move it by under half a turn, and it had no items slotted (the pilot never uses items anyway). The fights are not
energy-flooded; a player who has not geared for damage cannot break the enemy's board and chips.

**Fix (smallest that works, ordinary fights at levels 10-14 only; bosses, elites, gatekeepers, Primm and the Gallery unchanged).** The band
that ran long is the D.N.A., the Endless Buffet and their side dungeons (levels 10-14); the Dump, the Alley and the final stretch (levels
16-20) already ran 4.5-5.2 turns. Their ordinary foes' HP down by about 20 % from what they were: Gelatin Sentinel 16 -> 13, Shambling
Middle Manager 14 -> 11, the D.N.A.'s rooms 18/18/19/20 -> 14/14/15/16, the Test Kitchen's rooms 14/15/15/15 -> 12/12/12/12, the Apprentice
Itamae 13 -> 11, the Conveyor Belt Sushi Chef and the Receptionist of Number One 18 -> 14, the Eternal Queue 19 -> 15. The Meatloaf Golem
(12) and the Unpaid Intern (10) were already short.

| Expected player (sim, 8 games per Path and fight, seed 7100) | Fights | Turns | Beefcake | Necrocrat | Gourmand | Refusemancer | All | Over 7 turns |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Before (Nov 10) | 27 | 5.8 | 93 % | 100 % | 99 % | 98 % | 98 % | 2 |
| After | 27 | **5.6** | 94 % | 100 % | 99 % | 99 % | **98 %** | **0** |

Per group (before -> after, mean turns): the D.N.A.'s rooms 6.8 -> 6.3, the Test Kitchen's 6.2 -> 5.7, S-GOUR 6.5 -> 6.1, S-NECRO 6.5 -> 6.0,
the Buffet's roamers 6.3 -> 6.1, the D.N.A.'s 6.4 -> 6.1; the others unchanged. Tables: `docs/design/sim/nov11/before_*.md` / `after2_*.md`
(`python -I tools/pace_table_nov11.py before after2`).

**What the trim does not fix (inbox 12, your call).** A hero without the model gear still runs long after the trim: the sim's bare player
(`--nogear`, `docs/design/sim/nov11/after2_bare_*.md`, partial) takes 9.1 turns on both Buffet roamers (69-72 %) and 8.9-10.2 in the Test
Kitchen's rooms; the Sentinel's 14 -> 13 HP moved it 9.2 -> 9.1. For that player the board stalls and HP is not the lever. Not changed
tonight (it is a rules change, not a number): the options are in the inbox.

## Part 4 - the late game on the exported build

**A blocker found on the way: after "Skip card" on a boss's reward, E never advanced the boss's closing words.** Re-saving the
snapshots (`docs/review/play_scripts/n11_resave_end_1.txt`, `_2.txt`, editor build, fights auto-won) stalled on Primm's first closing line
("The model lies in pieces...") for 200 s and 80 taps of E. The Rewards screen's keyboard handler (`RewardsScreen._input`: 1-3 choose, E
takes) stayed live after the pick was skipped - the cards and the Take button were still alive - so every E went to "E never takes a card you
did not choose" (an error blip, the key swallowed) and the dialogue on top never saw it. Taking a card freed the button, which is why bots and
critics who took a card got through. Fixed: the handler stands down once the pick is confirmed or skipped (`_confirmed`) or the panel is
hidden. Re-run (`resave3`): the closing words, the fall still, the ending, the credits and the postgame announcement went through in 59 s of
taps, back in the Capital at level 21. Any main dungeon's boss epilogue had the same trap after a skipped card.

**The snapshots:** `c13end` and `c13post` now both hold that run's state - Primm defeated, the postgame unlocked, the hero in the Capital
(`user://dev_saves`, the old ones in `dev_saves/_backup_nov11/`). The ending itself only plays by beating Primm, so a snapshot cannot sit
"inside" it; `c13castle` + `dev travel dungeon D-PC -2` is the way to see it.

**The no-context late-game critic** (a test pack rebuilt with the Rewards fix; 34 runs, about 49 minutes of game time; report
`docs/review/critic_late_nov11/report.md`, saved by me from its final message as its own write was refused; scripts `critic_late_n11_*`,
shots `_screenshots/exported/l*_*.png`) walked the Capital to the castle, played the Courtyard, read Primm's intro, fought Primm for real from
the phase checkpoints and toured the postgame from `c13end` / `c13post`. **Scores: clarity 5, fun 4, polish 5 - no change from 5/4/5.** It
beat Phase 1 on its second try (16 of 31 HP left), lost Phase 2 twice (once at level 24) and Phase 3 once, so it did not see the ending; the
re-save run above did (auto-won). No `SCRIPT ERROR` in any of its 34 logs.

| # | Its top 10 | Done |
|---|---|---|
| 1 | HP wall in Primm's Phases 2 and 3; a loss restarts the castle | **Logged** (owner: Primm stays as is). Note: its Phase 2/3 tries started from `dev primm 2/3`, which drops the four leaders' boons (23 HP instead of 31, 3 rule icons instead of 9) - a dev-checkpoint gap, not what a player gets; still, 16 HP carried into a 52-HP mirror is steep. Inbox. |
| 2 | "Every unit is a 3/3" while its units showed 7/4 | **Reworded** (the rule sets every unit's BASE to 3/3 and boons and buffs add on top - working as built): "Every unit starts as a 3/3, so cheap units are as good as big ones; boons and buffs still add on top. You may play two cards a turn." |
| 3 | 10+ card hand wraps into two rows; ENEMY TURN ribbon over the Toss prompt | **Logged** (battle board layout: owner constraint; the two-row hand is already a known issue in the RC notes). |
| 4 | Turn label and Setting Up countdown out of sync | **Countdown fixed**: it counted the boss's own turns taken, so with the hero first it read 2, 2, 1 on Turns 1-3; it now follows the Turn shown (`GameState.setup_turns_left_shown`): 2, 1, then gone on Turn 3 when attacks start; the engine's rule is unchanged. **The ribbon / panel lag logged**: the board plays events back behind the game state ("YOUR TURN" over the enemy's turn, "Turn 1" while Primm attacks), a playback-timing change too risky for an RC. |
| 5 | Tidy-Bots drain about 1 HP a second on a Capital walk | **Fixed**: a damaging roamer that knocks you flat goes home and leaves you be for 10 s (`ZoneEnemies.DAMAGE_RETREAT_TIME`; was 2.2 s, then it re-chased at 5 m/s), and does not re-aggro while it cools down. Same 2 damage per knock. |
| 6 | Stale "Needs 2 energy; you have 0" hints, even over Victory | **Fixed**: the battle toast clears at the result screen and its fade runs under a pause too (it froze there); it already cleared at every turn and phase change. |
| 7 | Dialogue box over the boss node's info panel | **Fixed**: the dungeon map hides the node info panel when a scene opens. |
| 8 | Mirror phase: whose units are whose | Logged (board look: owner constraint). |
| 9 | The cracked mirror is a white quad | Logged (art; no art replaced tonight). |
| 10 | The Capital barely changes after Primm falls | Logged (postgame content). |

Also fixed: the 8 engine errors `!is_inside_tree()` from `HoverTip._show` while clicking hand cards (no tip for a control that has left the
tree). Logged from its smaller notes: the Freed Leaders' game-term brackets inside quotes, the 11-line pre-fight box, the castle gate still
(the hooded woman held by guards), the HUD goal title "Free the Four Zones" when only the castle is left, the Shattered Gallery's unexplained
63 max HP, the castle guard and Primm fielding "Resistance Scout", the white lamp globe and stair bands near the castle. `pilot` stalls in
Primm's fights (a test-tool gap, not the game).

## Part 5 - the test runner's memory guard (inbox 13)

`bash tools/run_tests.sh --min-free=MB` (default 900) `--wait-max=SEC` (default 600): before each shard the runner reads the free RAM
(PowerShell's CIM on Windows, `/proc/meminfo` elsewhere) and waits, polling every 10 s, until it is above the floor; a shard it cannot start
in time is skipped and listed under "Crashed shards" with the `--from=N` to rerun it. `--min-free=0` turns the wait off. Documented in
`docs/HANDOFF.md` section 2.

## Part 6 - RC4

- **Version** `1.0.0-rc4` in `project.godot`; `CHANGELOG.md` has the RC4 entry; `docs/release/rc4_notes.md` is the playtester page.
- **Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc4` -> **EXPORT OK**,
  `builds/TheWaywardPath-v1.0.0-rc4-windows.zip` **734 MB** (RC3: 734 MB), pack 845 MB, 14098 files, 89 baked shaders, every MD5 matches;
  zip CRCs checked. Export peak 1851 MB working set (2.7 min). The "over the 750 MB budget" warning is the same as RC3's. The RC3 zip is kept.
- **Release smoke on the exported pack** (`bash tools/run_release_smoke_exported.sh`): **PASSED** (title and pause version, New Game, F8 form +
  report files, pause menu buttons, no Dev Menu in release, save/load slot 2). It first failed 2 checks: the smoke pressed Esc once for the
  pause menu, and since Part 1 Esc advances the opening conversation first, so the menu stayed shut. The smoke now taps Esc until the
  menu shows (6 taps from the opening scene - each advances one line) and checks the menu is really visible.
- **Exported-build checklist** (test pack rebuilt; `play_exported.sh` runs A, B with A's settings, C on Low-end): **0 `SCRIPT ERROR`** in all
  three game logs, every scripted button found. Three script updates for the new Esc order (no game change): A closes the "New Gear!" box with
  its Continue before Esc; B saves to **slot 3** (slot 2 holds the Nov 10 run's 10-second test save and asked "Overwrite this save?" - never
  overwritten; slot 3 now holds a 10-second test save too - both deletable from Load Game) and leaves the slot screen with Back; C waits
  out the way back and sends Enter before Esc.
- **Logged from the checks, not changed:** (1) an Esc pressed during a load is remembered, but dropped if the scene arrives with the hero
  locked for its title (`SceneManager._end_transition` needs `pause_allowed`); (2) after the dev-only fight in run C (`dev encounter quota`
  from the Gainlands) the way back lands in the town scene with the hero locked and no box visible until a key (Enter / Esc) - a real
  return (run A, Crosspath) shows the "New Gear!" box. Worth a look after release if a tester reports a frozen hero after a fight.

## Finish

- **Tests:** full GUT in 38 shards before the export (`bash tools/run_tests.sh --min-free=800`, 24 min): **2965 / 2967 passed, 0 failing**, 2
  pending. Since then only the release smoke and the three play scripts changed (tools / docs, no game code).
- **Commits** (all pushed; nothing uploaded): `c70394ba` Part 1, `97120a7a` Part 2.1, `cb64b5c1` Part 5, `559ad36a` Parts 2.2 + 3 (resumed),
  `a0ec9de7` Part 3, `25b5d32e` Part 2.2 run 2, `1ec6857f` Part 4 (the Skip-card blocker, snapshots), `8678b445` Part 4 (late critic fixes),
  and the Part 6 commit with RC4's version, changelog, smoke and scripts.
- **Your inbox:** items 12 (fight pacing for an ungeared hero) and 13 (Primm's Phases 2-3) need a decision; the rest are notes.

### Release-day checklist for Nov 11 (the owner)

Everything below is from `docs/HANDOFF.md` section 2 and `docs/release/itch_upload.md`; about 90 minutes end to end, most of it the upload.

1. **Decide the donation link first** (it is baked into the build): in `data/credits/credits.cfg` set `[support] url="..."` to your itch
   page's pay-what-you-want address (`https://<your-itch-name>.itch.io/the-wayward-path/purchase`) or a Ko-fi / PayPal link. While it is
   empty every "Support the game" button stays hidden - that is also fine for 1.0.
2. **Version:** `project.godot` -> `config/version="1.0.0"`. Add the 1.0.0 entry at the top of `CHANGELOG.md` (the RC4 notes list what
   changed since RC3). Commit.
3. **Export:** close Godot, free RAM (close Chrome / ChatGPT), then in Git Bash from `C:\Dev\Deckbuilder-rpg`:
   `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0` (4-10 minutes; "EXPORT STOPPED" means nothing was replaced). The zip lands at
   `builds/TheWaywardPath-v1.0.0-windows.zip`.
4. **Smoke:** `bash tools/run_release_smoke_exported.sh` (about a minute; look for `PASSED`). Then the three exported-build checks:
   `bash tools/export_test_pack.sh` (2 minutes), then `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480`,
   `SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480`,
   `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480`; `grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log`
   must print 0 three times. (Run B saves to slot 3 of this PC's own saves; the 10-second test saves in slots 2 and 3 can be deleted from
   Load Game first, or B just meets "Overwrite this save?", backs out and goes on.)
5. **The real exe once:** unzip the 1.0.0 zip into a fresh folder, run `TheWaywardPath.exe`, start a new game to the Path choice, Esc,
   Settings, quit; launch again and Continue. (Or the scripted version: HANDOFF section 2, step 3.)
6. **Tag:** `git add -A && git commit -m "1.0.0" && git tag v1.0.0 && git push && git push --tags`.
7. **itch upload** (`docs/release/itch_upload.md`): Dashboard -> the project -> Edit -> Uploads -> Upload files -> the 1.0.0 zip (about
   740 MB: 5-15 minutes; leave the tab open), tick Windows, label "Windows 64-bit (zip)"; delete or untick the RC file so players get one
   file. Pricing "$0 or donate" with a suggested 3-5 USD (or "No payments"). Check the page text, the eight screenshots and the cover, the AI
   disclosure (Yes: Graphics, Sound/Music, Text/Dialogue). Save.
8. **Download it back once** as a player (View page -> Download), unzip in a fresh folder, run the exe to the title screen.
9. **Flip:** Visibility & access -> **Public** -> Save. Optional devlog post "1.0 is out". Send the playtesters the public link.
10. After the flip: `docs/release/post_1_0_backlog.md` holds what is known and not done; F8 reports arrive in `%APPDATA%\Deckbuilder-RPG\feedback`.

---

# Fable pass Nov 10 - report

Brief: `docs/prompts/fable_nov10.md`. Start tag `pre-fable-nov10`. Questions: `docs/overnight_inbox.md`, "Fable Nov 10" (items 1-14).
Shots: `docs/overnight_shots/nov10b/`. One Godot at a time; the two critics (the wayfinding critic, the exported-build critic) were the only
Godot while they played, and no sub-agent ran while a Godot of mine did. Owner decisions kept: no difficulty setting; the battle board and the
UI layout untouched (Part 3 is numbers only); Primm as the last pass left him. Last night's report (Overnight Nov 9-10) follows below.

## At a glance

- **RC3:** `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc3-windows.zip` (**734 MB; RC2 was 734 MB too**; re-exported after the last two fixes so it matches `main`, smoked again: PASSED), release smoke on the exported pack
  ****PASSED** (`_screenshots/release_smoke_exported.log`)**, the short exported-build checklist ****done, 0 SCRIPT ERRORs**: the three RC1 scripts on the RC3 test pack - A (fresh settings: title, Credits, a new game through the intro, Crosspath, a shop, the Deck Station, the Wardrobe, the packs page, a battle, the pause menu, a setting, Copy log, a manual save, quit, load; 16 shots), B (seeded with A's settings: Settings, save and Continue, the Gainlands quiz; 8 shots), C (quality 0: a zone, the town, a battle; 4 shots) - `_screenshots/exported/x*.png`, `y*.png`, `z*.png`**. Notes for testers: `docs/release/rc3_notes.md`.
- **Part 1 (finding things):** every step of every active quest marks every part; the audit fails on a marker-less step; the gates on the way to
  the Buffet's and the Dump's main dungeons are marked; the NPC visibility probe passes; "Point me to..." opens over the map with one row per
  goal; the white sheets were steam puffs at the lens. **The wayfinding critic reached 1 of 4 main dungeons (Gainlands 2, D.N.A. 5, Buffet 4,
  Dump 3 /10)** - its first fix, a route-following arrow, is in (Part 1.6 below), with the dotted route on the map.
- **Part 2 (turns):** Turn N = both players' turns everywhere a player reads a number; no moment moved (table below).
- **Part 3 (hand numbers):** hand cards and the raised hover card show this fight's power, toughness and cost in green / red; the right-click
  preview says the printed values ("In this fight: 7/4 (printed 3/3)").
- **Part 4 (rewards):** no "losing costs nothing"; dungeon fights +50 %; completion -20 %; the gold study says 22.8k no-grind (+7 % on the
  21.2k target, inside the band, not re-tuned).
- **Part 5:** the Hall Pass Slippers (Boots, 500 gold at Mirepoix's): no HP from the world's hazards outside battle.
- **Tests:** **2942 tests in 31 shards: 2940 passing, 0 failing, 2 risky** (the same two no-assert tests as before). The parts had broken six test expectations, all fixed and re-run green: R-08's card script hash (the "your turn" wording; `import_cards.sh --stamp`), the Old Well's steps now marked like every step, Setting Up said in turns, 26 pieces and 4 on Mirepoix's shelf, the defeat line's new words. The sharded run was stopped once by the memory guard (free RAM under 800 MB with Chrome and Defender busy); the rest ran one shard at a time with a check before each. **The exported-build critic (the Buffet, arrival to the Test Kitchen):** clarity **7**, fun **6**
  (was 5 / 4). Polish 7. Its top three: the main quest's own step never names Sir Loin's gate or the side quest that opens it; a roaming Gelatin Sentinel camps the Test Kitchen door; every fight runs 9-11 turns. Report: `docs/review/critic_exported_midgame_nov10/report.md`.

## Part 1 - finding things

### 1.1 Markers for every part of every step

- `QuestObjective.parts`: a step can name several targets, each with its own "done" condition; `targets()` lists the undone ones. Mend the
  Meatloaf marks the salt, the truffle and Old Meatloaf; the Pantry Run its six pickups; the roamer-count favours every live roamer of the
  zone (`QuestMarkers.SPOT_ROAMERS`); the stash hunts every unopened stash; the Dump's herd each animal, the Capital's wheels each wheel. A
  part drops the moment it is done (the pickup taken, the animal home, the wheel freed).
- The world: up to 10 chevrons per step, the gold arrow at the nearest; the map and the minimap carry every active quest's goals (the tracked
  quest's pin to the minimap's rim); the menu steps ("Open a pack") carry no marker and say so (`menu_step`).
- `tools/quest_audit.gd` fails on a step with no marker target (and checks every part's area and spot). It found the Old Well's hum steps,
  Loose Ends, the giant chests, the vault levers and the favour steps - all marked now. Shots: `p1_point_me_list_buffet_quests.png`,
  `p1_map_goals_buffet.png`.

### 1.2 The route to each main dungeon

`tools/dungeon_route_audit.gd` plans a route from the arrival point to the main dungeon's door over each zone's real walkability, fresh (nothing
opened) and open (every gate granted), and names the gates on the open route:

| Zone | Fresh | Open | Gate on the way | What the player is told |
|---|---|---|---|---|
| The Gainlands | route | route | none | - |
| The D.N.A. | route | route | none | - |
| The Endless Buffet | no route | route | Sir Loin's golem gate | Sir Loin: "speak to Basil, east of the Soup Fountain"; Basil's offer and the gate's "active" line name the Salt Flats and the Broccoli Forest; the main line's dungeon step marks the gate until it opens |
| The Verdant Dump | no route | route (142 m) | the vine bridges, the junk barricade on the stairs | the main line marks the Magic Bean + the West Sprout Mound (Part 1.6), the stables and the barricade; the bridge sign and Moss Mulligan name the bean |
| The Capital | "narrow" route | route | the city gate | inbox 7: a fresh hero can slip through the hidden west hole; kept |

Sir Loin's stale "speak to Basil" is gone (his need line now says where Basil stands); a mended loaf not yet reported gets its own line
("Tell Basil yourself... His word opens this gate").

### 1.3 Nobody behind a prop

`tools/npc_visibility_probe.gd` stands the hero on every talk point and casts sight lines from the default and the Low camera to each NPC's
feet, chest, head and name plate (a mesh between the lens and the hero is ignored, it fades). The first full run: 78 checks, nine real hides.
Moved: Basil and Tarragon (clear of the Buffet's bridge gate; Tarragon again 3 m west of Rip at the Rift station after the Nov 10 critic
run), Madame Mirepoix's awning, sign, pudding and cupcake, Billie Muckfoot (off the Rift station's line, then off the greenhouse's corner),
Dex in the Dump (out of the appliance grove), Kestrel, a Capital ward patient. The brightened card copies now fade for the hero too. A prop
between the camera and the person you can talk to dissolves (`OcclusionFader.talk_focus`); with nobody in reach, E walks to the nearest
person in view (E's reach = the click's). Last run: every check ok; two "partly" rows remain (Mirepoix's head behind a cupcake at the default
camera - the cupcake is smaller and further back now; Dex's feet behind the stream fence at the Low camera, plate and prompt clear).

### 1.4 Map labels

Landmarks are named first and win the room; minor names hide below map scale 5.5 and show on hover; "Point me to..." is an in-screen list
over the map's right edge (a Window popup sat over the legend whatever it was told); the legend has one line per quest goal. Nov 10 critic
run: one row per goal name ("A hidden stash (any) (one of 14)" instead of fourteen rows that buried the Meatloaf's three), the area each
goal stands in ("An escaped animal (the Compost Commons)"), "via" rows for roads out ("Root Cause: via Back to Town"), and Escape closes the
list and the map together. Shots: `p1_point_me_list_gainlands.png`, `p1_point_me_list_dump.png`.

### 1.5 White sheets

Not the occlusion fader: the milky sheets north of the hub were the steam and mist puff billboards reaching the lens at the Low camera.
`ParticleLook.near_fade` fades every puff material between 9 m and 2.5 m of the camera (the Buffet's steam, the Gainlands' and the Dump's
mist). The fade walk (`docs/review/play_scripts/fade_walk_gourmand_nov10.txt`) shows no sheets; the Low shots at the Salt Flats only carry the
fall-in-the-gravy tint.

### 1.6 The wayfinding critic (and what it changed)

A no-context critic (brief `docs/review/critic_wayfinding_nov10_brief.md`, report `docs/review/critic_wayfinding_nov10/report.md`, 57 runs,
84 minutes of game time) arrived fresh in each Path zone and had to reach the main dungeon's door with the game's guidance only:

| Zone | Door reached | Game time | Runs | Clarity /10 | What stopped it |
|---|---|---|---|---|---|
| The Gainlands | no | 23.5 min | 17 | 2 | the straight arrow over the plateau wall; a pocket beside the House of Gains' stairs where it stood wedged |
| The D.N.A. | yes | 18.3 min | 11 | 5 | the front desk and the mail-room terminal on the arrow's line |
| The Endless Buffet | no (Meatloaf mended, not reported) | 22.9 min | 15 | 4 | the arrow across the Gravy River (two falls); the truffle pocket; Sir Loin's unchanged line |
| The Verdant Dump | no | 19.1 min | 14 | 3 | the arrow across the stream; no bean, no mound found; two herd animals across the water |

Its three fixes, and what was done:

1. **A route-aware pointer, or the route on the map** (35 of its 84 minutes went into the straight arrow). Done: `RouteGuide`
   (`world/route_guide.gd`) plans an A* route over the zone's own walkability (a 0.75 m grid, 8 neighbours, the midpoint between cells tested
   so a thin wall is never stepped over), sliced at 5 ms a frame so nothing hitches. The gold arrow and the "Point me to..." arrow point
   9 m along the route; the full map draws the route dotted (white for the pick, gold for the tracked goal); a waypoint that is on screen
   gets a small arrow of its own (the critic's "dead end" at (49, 55) now shows the arrow at the road's foot to the east:
   `p1_route_arrow_critic_dead_end.png`, `p1_route_arrow_middle_road.png`, `p1_map_route_gainlands.png`). Two walkability tests per zone: strict
   (what the hero can walk now - the Buffet's river only on a ferry's line, the Dump's stream only on a grown bridge) and through-gates (a
   shut golem gate, an ungrown vine bridge, a barricade count as open), so where a gate shuts the road the arrow leads to the gate, where
   the sign says what opens it (`p1_map_route_buffet_ferry.png`: the route crosses the Gravy River on the Lazy Susan; `p1_route_arrow_dump_arrival.png`).
   Search cost (tests): the Gainlands 45 ms, the Buffet 360 ms, the Dump 1.5 s (inbox 11).
2. **The gate and its requirement in the main quest and on the map.** The Buffet's dungeon step already marked Sir Loin's gate (Part 1.2);
   Sir Loin now acknowledges a mended loaf ("Tell Basil"). The Dump's main line marks the Magic Bean by the stream and the West Sprout Mound
   from the favour step on, until a bridge is grown; the Centre Bridge sign and Moss Mulligan's refusal name the bean. (Two of Billie's three
   animals graze across the water: inbox 10 asks whether to move one.)
3. **Keep the main quest in the HUD; a place name on every row.** A side quest in hand keeps the tracker when the next side quest is accepted
   (a favour still takes it from the main quest's "finish a favour" step; a main quest still takes it from a side quest). Every "Point me
   to..." row names its area; goals of one name make one row. Plus the two physical blockers: the forecourt strip beside the House of Gains'
   stairs is rubble now (the hero cannot squeeze in past the cheek wall), and the Steps banner sits on the stairs, not 14 m round them.

Not changed: Old Man Mountain in front of the gym hall and Brother Bramble at the greenhouse door stay (the route arrow walks round them);
the D.N.A.'s "finish a favour" step before an open door is the design (inbox 12); the Delt ripper out of order is a world feature.

Tests: `tests/world/test_route_guide_nov10.gd` (5: the gap, the gate, no route, a moved target), `tests/world/test_route_guide_zones_nov10.gd`
(3: the real Gainlands, Buffet and Dump routes), `tests/core/quests/test_wayfinding_nov10.gd` (5: the tracker rule, the list rows, the Dump's
parts, the story lines, the pocket). The quest audit, the zone and quest suites green after the change.

## Part 2 - a turn is both players' turns

`GameState.turn_number_of(half) = max(1, floor((half + 1) / 2))`: the engine's own counter still advances once per side (every internal
threshold keyed on it - the AI's stall rule, the item policy, Processing X, "until the start of its controller's next turn" - is untouched,
so nothing happens at a different moment). What the player reads:

| Where | Before | Now |
|---|---|---|
| Battle HUD turn panel | "Round N" / "Your turn" - "Enemy turn" | "Turn N" / "Your turn" - "Enemy's turn" |
| Board ribbons | "Round N" | "Turn N" |
| Battle log header | "-- Your turn --" / "-- Primm's turn --" | "-- Turn 1: your turn --" / "-- Turn 1: Primm's turn --" |
| Boss Setting Up (pre-fight panel, rules panel) | "Its units do not attack in rounds 1-2; they can attack from round 3" | "...in turns 1-2; they can attack from turn 3" (same window: the boss takes its N-th turn inside Turn N whichever side goes first) |
| Setting Up countdown under the turn label | "Setting Up: 2 rounds left" | "Setting Up: 2 turns left" - `setup_turns_left = clamp(window - turns_taken + 1, 0, window)`; countdown and panel agree (test: 2, 2, 1, 0 for turns taken 0..3) |
| Result lines | "in N rounds" | "in N turns" (`p1`... the Victory panel: "You defeated Quota Spotter in 1 turn") |
| Card text (34 cards + 1 token) | "until end of turn" | "until the end of your turn"; the traps that fire on the enemy's turn (BR-07, C-16, GB-04, GRB-01): "until the end of the enemy's turn" |
| Glossary / keyword info | "Round" | "Turn" (one turn = both players' turns; "your turn" and "the enemy's turn" are its halves) |
| Tutorials, status info, campaign start, pre-fight texts | rounds | turns |
| Sims and tools (`record.turns`, `turns_played`, `node_turns`, the "turns avg" print) | half-turns | turns (inbox 6: their numbers are half what they were) |
| `docs/design/combat_rules.md` Turn Structure | - | the paragraph above |

Energy: the end-turn question and the hand tooltips count the same pool (`GameState.energy_available`: ready infrastructure + the pool), so
the two contradictory messages are one. Shots: `p2_before_the_fight_setting_up_turns.png`, `p2_hud_turn1_your_turn.png`,
`p2_battle_log_turn_header.png`. Test: `tests/core/test_turn_counting_nov10.gd` (6).

## Part 3 - hand cards show this fight's numbers

`CardView.apply_instance` already drew a unit's live attack and toughness; now a shrunk attack reads red (Primm's 3/3, Red Tape) as a shrunk
toughness did, and the cost is live too: `game.generic_cost_for` + `pips_for` against the printed `energy_value()`, green when cheaper, red
when dearer, on the framed socket's number and on the plain face's pip row (`PipRow.generic_override`). `BattleBoard.sync_state` re-applies
every live view each sync (a view was asked once, when it was made - a rule that arrived after the draw never reached the hand). The
right-click preview adds `BattleHud.now_line`: "In this fight: 7/4 (printed 3/3); costs 2 (printed 3)." - only the parts that differ. No
layout changed. Under Primm's Standardization a postgame hero's Carpool (printed 3/3) reads 7/4 in green: 3/3 plus the hero's boons and gear
(`p3_primm_hand_live_numbers.png`, `p3_primm_hover_carpool.png`; the right-click preview of the Overclocked Mill Worker: "In this fight: 7/4 (printed 2/4)." in gold under its text, `p3_primm_peek_in_this_fight.png`). The House of Gains' Home Gym (+1 attack for Beefcake units) shows the
same way; a Colorless hand (Courier Pigeons, Village Militia) keeps its print. Tests: `tests/ui/test_hand_numbers_nov10.gd` (3: Primm's 3/3 in
red with the printed values in the preview line, a cost reducer in green and a tax in red on both faces, a zone rule's pump in green kept
through a rebuild).

## Part 4 - rewards and the defeat text

- "Losing costs nothing" and its cousins are gone from the defeat panels, the Old Well's confirm and the level hints; a dungeon defeat says the
  dungeon starts over from its first room and that the cards and gold you won are kept.
- Rewards (`docs/design/balance_log.md`, "Fable pass Nov 10, Part 4"):

| What | Before | Now |
|---|---|---|
| Every fight inside a dungeon (normal, elite, boss; main and side) | gold x1, XP x1 | gold x1.5 (rounded to 5), XP x1.5 (`Economy.DUNGEON_FIGHT_BONUS`); picks and packs unchanged; the tutorial cave is not a dungeon run |
| Clear bonus at the boss | the run's gold once more | 0.8 of it (`CLEAR_BONUS_SHARE`) |
| Main dungeon first clear | 200 gold, XP 0.5 of a level step, pack bonus 150 gold / 100 XP | 160, 0.4, 120 / 80 |
| Side dungeon first clear | 100 gold, XP 0.15 of a step | 80, 0.12 |
| Primm's Castle, the Lab, the Shattered Gallery | 400 XP; 400/400; 1500 gold | 320; 320/320; 1200 |
| Repeat clears | 300 main / 200 side | unchanged (not a completion reward) |

- Gold study (`docs/design/sim/nov10/gold_study_nov10.md`, the economy model paying the +50 % the game pays): **22,771 gold no-grind** against
  the ~21.2k target (+7 %, inside +/-10 %, so no re-tune); 12,971 left after the shopping list; a completionist needs about 135 extra fights
  (9.0 h) at the best grind.

## Part 5 - the Hall Pass Slippers

Boots: the slot with the fewest pieces (7 boots against 9 helms, 11 armours, 15 weapons, 19 relics). Uncommon, tier 2, **500 gold on Madame
Mirepoix's gear shelf** in the Endless Buffet (a mid-game shop at the gear price formula) - picked over a side-quest reward so a player who
hates the gravy can buy their way out. "Outside battle, roaming troublemakers and hazards can't hurt you: no HP lost to bumps, rifts, pits,
gravy or falls." Flavour: "Paperwork says you're excused. The paperwork is laminated." `Modifier.Kind.WORLD_IMMUNITY`, `ZoneRun.world_damage`:
every zone-HP hit outside battle (roamer bumps, the Buffet's gravy and rift stations, the Dump's falls and pits, the Gainlands' hazards) goes
through it and shows "Hall Pass Slippers: no harm done. The paperwork says you're excused." Battles and story damage are untouched. Icon: the
Traveler's Boots stand in; `ICON-EQ-HALLPASSSLIPPERS` is on `docs/art/art_needed_nov2.csv` with an image description. Test:
`tests/core/test_hall_pass_slippers_nov10.gd` (3).

## Finish

- **Tests:** **2942 tests in 31 shards: 2940 passing, 0 failing, 2 risky** (the same two no-assert tests as before). The parts had broken six test expectations, all fixed and re-run green: R-08's card script hash (the "your turn" wording; `import_cards.sh --stamp`), the Old Well's steps now marked like every step, Setting Up said in turns, 26 pieces and 4 on Mirepoix's shelf, the defeat line's new words. The sharded run was stopped once by the memory guard (free RAM under 800 MB with Chrome and Defender busy); the rest ran one shard at a time with a check before each.
- **RC3:** `builds/TheWaywardPath-v1.0.0-rc3-windows.zip` (734 MB; RC2 was 734 MB too); `builds/_export/` holds the unzipped build. Release smoke on the exported
  pack: **PASSED** (`_screenshots/release_smoke_exported.log`). The short exported-build checklist (runs A-C of the RC1 scripts on the test pack): **done, 0 SCRIPT ERRORs**: the three RC1 scripts on the RC3 test pack - A (fresh settings: title, Credits, a new game through the intro, Crosspath, a shop, the Deck Station, the Wardrobe, the packs page, a battle, the pause menu, a setting, Copy log, a manual save, quit, load; 16 shots), B (seeded with A's settings: Settings, save and Continue, the Gainlands quiz; 8 shots), C (quality 0: a zone, the town, a battle; 4 shots) - `_screenshots/exported/x*.png`, `y*.png`, `z*.png`.
- **The exported-build critic:** a no-context critic (brief `docs/review/critic_exported_midgame_nov10_brief.md`, report `docs/review/critic_exported_midgame_nov10/report.md`; 33 runs, 40.8 min of game time on the RC3 test pack, no `dev autowin`, no SCRIPT ERROR) replayed the Buffet from arrival to the Test Kitchen's boss: **clarity 7 (was 5), fun 6 (was 4), polish 7**. It stood 8 m from the door after 18.3 min on foot, guided by the tracker, the map's blue circles, the dotted route, the gate's sign and Basil; it used `dev travel` into the dungeon only after a roamer beside the door ate two approaches. What it credits: the gate sign and Basil's hand-in line, the dotted route and the labelled arrow, the Defeat card's recap, the right-click preview's "In this fight: 2/3 (printed 1/1)", "Turn 1 / Your turn". Its top 10 (verbatim in the report): (1) the main quest's dungeon step should say "Sir Loin's gate wants Old Meatloaf mended - see Basil" (the step marks the gate on the map, but its "Where to go" text does not say it: a one-line text fix for the next pass); (2) a roaming Gelatin Sentinel camps the Test Kitchen door; (3) 9-11-turn fights; (4) the boss's token swarm overlaps; (5) Setting Up is an unlabelled hourglass during the fight; (6) toasts stay 20-30 s; (7) the E prompt prefers plaques to the quest NPC; (8) walking costs HP (bumps, the gravy); (9) the "Point me to..." list reorders between opens; (10) a stale favour toast and Escape over pop-ups. Fixed tonight from its notes: the respawn toast still said "Losing costs nothing" (gone), and the dotted route grazed the Soup Fountain (routes now keep a 0.6 m body clear of props). The rest is logged for the owner (inbox 14).
- No public upload. Commits: Part 1 (`170722b5`, `731e720c`), Part 2 (`26847a85`), Part 4 (`a305b9df`, `4b9e85f4`), Part 5 (`d3b775cf`),
  Part 1.6 + Part 3 (`ebcbdad3`), Finish (the Finish commits that follow `ea2a6377`).

### Screenshots (`docs/overnight_shots/nov10b/`)

| File | What |
|---|---|
| `p1_point_me_list_buffet_quests.png` | the Buffet map with Mend the Meatloaf and the Pantry Run active: every part a goal, the list open over the map |
| `p1_map_goals_buffet.png` | the legend's one line per quest goal |
| `p1_point_me_list_gainlands.png`, `p1_point_me_list_dump.png` | one row per goal name, the area in brackets, "via" rows; the Dump's bean and mound rows |
| `p1_map_route_gainlands.png` | the dotted route from the bridge up the middle road to the House of Gains |
| `p1_route_arrow_critic_dead_end.png` | at (49, 55), where the critic gave up: the waypoint arrow at the road's foot to the east |
| `p1_route_arrow_middle_road.png` | the waypoint arrow up the Gauntlet |
| `p1_map_route_buffet_ferry.png` | the Buffet's route crossing the Gravy River on the Lazy Susan |
| `p1_route_arrow_dump_arrival.png` | the Dump: "The Rotheart" arrow north toward the Centre Bridge's foot |
| `p2_before_the_fight_setting_up_turns.png` | Primm's pre-fight panel: "Setting Up: ...in turns 1-2; they can attack from turn 3" |
| `p2_hud_turn1_your_turn.png` | the HUD: "Turn 1 / Your turn" |
| `p2_battle_log_turn_header.png` | the log: "-- Turn 1: your turn --" |
| `p3_primm_hand_live_numbers.png` | Primm's fight: the Militia 3/3, the hand's live numbers |
| `p3_primm_hover_carpool.png` | the raised Carpool: 7/4 (printed 3/3) |
| `p3_primm_peek_in_this_fight.png` | the right-click preview: "In this fight: 7/4 (printed 2/4)." |

---

# Overnight Nov 9-10 (Opus) - report

Brief: `docs/prompts/overnight_nov9_opus.md`. Start tag `pre-overnight-nov9b`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 9-10".
Shots: `docs/overnight_shots/nov10/`. One Godot at a time; no sub-agent ran while a Godot of mine did (the two critics were the only Godot
while they played). The Fable Nov 9 report follows below.

## At a glance

- **RC2 is built:** `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc2-windows.zip` (**734 MB**, next to RC1's 736 MB). Release smoke on
  the exported pack **PASSED 17/17**; the exported-build checklist (runs A and B) and a Low-end walk all fine, 0 SCRIPT ERRORs. Notes for
  testers: `docs/release/rc2_notes.md`.
- **Fixed tonight (with shots below):** 17 critic findings across the three reviews - the bright forest, the textured fountain, the cave flood
  guard, the attack-aware end-turn question, "Point me to...", the Path choice strip, Primm's opening army (4 -> 3 Militia) and countdown,
  no cut-outs over stills, Basil, the Buffet hints, and smaller text fixes. Plus the Text size switch and the key-rebinding guard.
- **The critics' top 10s:** Part 2 below (midgame: clarity 5, fun 4, polish 6; late game: clarity 5, fun 4, polish 5). Both lost the hard
  fights they met at the recommended level; the late critic could not beat Primm in six tries, which is why his first phase is easier now.
- **The dialogue tool:** Part 3 below, in plain steps (three commands; tested on ten fake edits, then the test files were deleted).
- **Accessibility and controller:** a single Text size switch, Large checked at 1280x720; every menu and all ten minigame screens walk with a
  pad only (tests + the gamepad smoke, 540 pad events, 0 key/mouse); rebinding can no longer leave Move / Interact / Pause without a key.
- **Size and performance:** Low-end on the exported build runs at its 30 fps cap in Crosspath, the Capital and a battle (memory below). The
  pack has almost nothing unused left (0.8 MB found; the macOS icon and four orphan pictures removed, ~2 MB). The Capital's later visit is
  **6.1 s** (was 6.2 s): the remaining pieces were not cached tonight (reason and plan in Part 5).
- **Tests:** full suite in shards **2907 / 2909 passed, 0 failing, 2 risky** (the same two no-assert tests as before). New tests: flood guard,
  text size switch, key-rebind essentials, pad walks for the Wardrobe / Tailor / pack shop / nine minigames; the boss tempo test updated.
- **Before the public release, the owner should:** (1) play the RC2 zip once; (2) decide on Primm (inbox 4: 3 Militia, re-run the sim when the
  PC is free); (3) send `rc2_notes.md` + the Restricted itch link to playtesters; (4) when their workbooks come back, run the three dialogue
  commands (Part 3); (5) on release day: `config/version` to `1.0.0`, export, smoke, upload, flip to Public (`docs/release/itch_upload.md`).
  Decide later: the Capital caching (inbox 5), the battle board's infrastructure row and two-row hands (both critics), the Gainlands kit.

## Part 0 - the Fable pass

Nothing left: its report marks the import, RC1, the exported-build checks, the critic's quick fixes, the itch kit, the trailer and the
handover as done.

## Part 1 - the RC1 critic's findings (first hour)

| # | Finding | Effort | Done |
|---|---|---|---|
| 1 | Cave entrance trigger missable | S | fixed on Nov 9 (whole doorway answers E); the chest beside it can no longer steal the press (the gate wins inside 3 m) |
| 2 | First fights drag (8-11 rounds) | M | **Cave flood guard:** in the Forgotten Cave only, once you hold 5 infrastructure (play + hand) an infrastructure draw is swapped for the next non-infrastructure card (`GameOptions.flood_guard`, `FirstDuel.CAVE_FLOOD_GUARD`, test). Sims (60 runs per Path): the AI player clears the Scavenger in 2.9-4.1 rounds with or without it, so the critic's long fights were human floods; the guard caps them. The sim tool now prints rounds per node. |
| 3 | White fountain / plinth blocks in Crosspath | S | the fountain carries the painted stone-wall texture, tinted sandstone. Before `p1_fountain_before_rc1.jpg`, after `p1_fountain_after.jpg` |
| 4 | Near-black forest, heavy blur | S | `starting_forest.json`: key 0.42 -> 0.62, ambient 0.62 -> 0.92, exposure 1.05 -> 1.32, vignette 0.5 -> 0.36; tilt-shift halved. Mean brightness 26 -> 35 (+33 %). `p1_forest_before.jpg` / `p1_forest_after.jpg`. Camera zoom not changed (shared by every area). |
| 5 | Gainlands low-poly kit; fight starts with a toast | L | **L** - plan: run the painted-texture presets (as Crosspath) over the Gainlands ground and walls, and give roamers a first-meeting line. |
| 6 | "End your turn?" while picking attackers | S | asks "End the turn without attacking? You have N attackers selected..." instead |
| 7 | Esc does not close a shop | - | not a bug (Nov 9) |
| 8 | "Where to?" sets a goal | S | renamed "Point me to..." with a tooltip saying the arrow leads there after the map closes |
| 9 | Bark bubbles over name plates | S | fixed on Nov 9 |
| 10 | Path cards unreadable until More | M | the strip keeps the picked Path described after the pointer leaves, and shows its Resource on hover |
| notes | forest hint line lacked M: map | S | added |
| notes | stray glyph label in the dump | - | the font warm-up: a 3 x 3 px clipped label at 2 % opacity - invisible |
| notes | first-duel popups stack; level-up over the card reward; Esc during talk opens pause | M | kept: the tip already sits clear of the mulligan panel; the other two are in the backlog |

## Part 2 - exported-build checks of the mid and late game

Two fresh critics with no context, each given only its brief (`docs/review/critic_mid_brief.md`, `critic_late_brief.md`), played the
exported RC1 pack with snapshots to jump ahead. Reports: `docs/review/critic_mid_nov10/report.md` (42 shots) and
`docs/review/critic_late_nov10/report.md` (41 shots; saved by me - the harness would not let the agent write it).

**Midgame** (level-14 snapshot, the Endless Buffet and the Test Kitchen; ~30 min of game time, 16 runs): **clarity 5, fun 4, polish 6**. No SCRIPT ERROR.

| # | Problem (critic) | Sev. | Done |
|---|---|---|---|
| 1 | The Test Kitchen beat it three times at level 14; a loss restarts the dungeon | major | not changed (the pilot played; the level hints cover it); the defeat text no longer says "losing costs nothing" in a dungeon |
| 2 | Sir Loin's gate ingredients have no marker | major | the favour's hint names where the truffle and the salt are |
| 3 | Basil hidden behind the soup fountain; E at 2.3 m did nothing | major | Basil 3 m east, talk reach 1.8 -> 2.4 m |
| 4 | Huge milky fade polygons | major | not reproduced tonight (inbox 7) |
| 5 | Played infrastructure tiny; unit rows touch | major | L (battle board layout) - backlog |
| 6 | Old Hob's portrait stuck after a defeat | major | not reproduced tonight (inbox 7; in the RC2 known issues) |
| 7 | Zone counters disagree (4 of 4 after one boss) | major | likely the bot snapshot's flags + `dev win`; logged (inbox 7) |
| 8 | Meatballs knock 2 HP off on arrival | minor | the meatballs live far from the bridge; it was the snapshot's arrival spot. Kept |
| 9 | Map labels pile up; "The Beefcake Rift Express" in the Buffet | minor | the map now says "Rift Express station" |
| 10 | Small UI collisions (popups over the HP panel, clipped Open, tooltips) | minor | backlog |

**Late game** (level 20-24 snapshots, the Capital, Primm's Castle, six real Primm fights, the Lab; ~50 min, 25 runs): **clarity 5, fun 4, polish 5**. No SCRIPT ERROR.

| # | Problem (critic) | Sev. | Done |
|---|---|---|---|
| 1 | Primm is a wall: six phase-1 losses by round 4-5 (L20 and L24), "Militia dealt 36 of 39" | blocker | **Standing Army 4 -> 3 Militia** (inbox 4); the countdown fix below |
| 2 | `c13end` / `c13post` snapshots load before Primm | blocker (review only) | tooling: re-save them (inbox 6) |
| 3 | Speaker cut-outs pasted into stills that already show them | major | no cut-out over a painted still any more (the name plate stays) |
| 4 | Primm on "a sunny village" board | major | it is the Model Room's miniature kingdom (`BB-PC-BOSS`); kept, art question (inbox 8) |
| 5 | Rules contradict the screen (3/3 vs 7/4 hand cards; "Setting Up: 3 rounds" for a 2-round window) | major | the countdown never exceeds its window now (test); hand cards showing standardized stats is M - backlog |
| 6 | Invisible infrastructure, two-row hands | major | L - backlog (same as mid #5) |
| 7 | Tracker "1 done" | minor | "1 earlier step done (J: the full list)" |
| 8 | Template boss reward line | minor | Primm's node: "three duels in a row (56, 52 and 50 HP), your HP carried between them. At stake: the kingdom." |
| 9 | Dialogue: skip prompt repeats its title; two box styles; Esc opens pause on first lines | minor | the prompt reads "Skip this scene? / You haven't seen it yet."; the rest backlog |
| 10 | Outer Capital: flat white wall backdrop, unseen Tidy-Bot hits | minor | backlog |

## Part 3 - the playtesters' dialogue tool (plain steps)

`tools/import_playtester_dialogue.py` (standard library only - no packages to install). When the testers send their workbooks back:

1. Put the returned `.xlsx` files in one folder, e.g. `docs/dialogue/returned/`.
2. `python tools/import_playtester_dialogue.py docs/dialogue/returned/*.xlsx` - reads each file's "Dialogue" tab (ID in B, New line in H,
   Notes in M, Reviewer in N), skips empty New lines, and checks every rewrite against the game's current text: the ID exists, every
   `{token}` / `[tag]` / `%s` is kept, one line, at most 240 characters (90 for barks). Rows added, deleted or sorted are reported (matching is by
   ID). Two testers rewriting the same line differently is a **conflict**: both are listed, neither is taken.
3. Read `docs/dialogue/playtesters_nov9_merged_report.md` (accepted / rejected with the reason / conflicts / sheet structure).
4. `node tools/apply_dialogue_pass.js --csv=docs/dialogue/playtesters_nov9_merged.csv` - the usual dry run (also checks every line fits its box).
5. The same with `--apply`. Undo with `--revert`. Settle a conflict by putting the chosen line in a CSV (`id,new_text`) and running
   `... --merge=<file> --apply`. Run the tests.

**Tested** on a copy of the workbook with ten fake edits by two fake testers: 4 accepted (one identical rewrite from both counted once),
4 rejected (a dropped `{town}`, a 326-character line, a 101-character bark, an unknown ID on an added row), 1 conflict listed, the sorted rows
reported; the importer's dry run took all 4 ("4 would apply, 0 conflicts"). The test files were deleted. HANDOFF section 5 has the workflow.

## Part 4 - accessibility and controls

- **Text size:** Settings > Text > "Text size (dialogue, cards, tooltips)": Normal / Large / Larger (sets the three per-kind sizes, which stay
  below it; "Custom" when they differ). Saved. At 1280x720 on Large: the dialogue box and the battle fit (`p4_large_text_dialogue_1280.jpg`,
  `p4_large_text_battle_1280.jpg`; the UI is one 1920 canvas scaled to the window, so the layout is the same at every size). Test:
  `tests/ui/test_text_size_master_nov10.gd`.
- **Controller pass:** the gamepad smoke (title, Path choice, gate, Crosspath, Sable's shop, a pack, the Deck Station, a duel turn, level-up,
  the menus, the map, the pause menu and Settings > Controls) **OK, 540 pad events, 0 key or mouse events**. The pad-walk test now also walks
  the **Wardrobe, the Tailor, the pack shop and nine minigame screens** (quiz, Dex's table, growth grid, match, order, recipe, reps, sort, tubes):
  every button reachable with the D-pad, no dead ends (19/19). The Gainlands wheel panel needs a zone run; the smoke covers zone screens.
- **Key rebinding:** works and is saved (existing tests + new `tests/test_keybind_essentials_nov10.gd`). New guard: moving, Interact and Pause
  can never be left with no key (clearing the last key, or taking it for another action, is refused with a message), and Pause keeps Esc in
  its first slot. Esc, Enter and Tab stay reserved for menus.

## Part 5 - performance and size

**5.1 The Capital's later visit** (`bash tools/run_loading_timing.sh <run> final`, LOAD_TIMING=1): **before 6.2 s, after 6.1 s** (noise).
Warm breakdown: the builder 3.1 s (buildings other than the houses 0.8, props 0.6, landmarks 0.45, merge 0.3, signs 0.1, rifts 0.16),
the Capital's dressing 0.39 s, the first settled frames 0.54 s, fades 0.7 s; the painted ground is already cached (new detail marks in
`painted_terrain.gd` show its splat at 4-18 ms warm). Every remaining piece registers walk blockers as it builds, which is exactly what made
the cached Crosspath buildings break the walk smoke in October. Not done on release eve. **Plan (M-L):** cache each piece's meshes *and* its
blocker list together (`BuildCache.fetch` of {scene, blockers}), one piece at a time, with the Capital walk smoke run cold and warm after each.

**5.2 Low-end on the exported build** (rc2 test pack, settings low_end / quality 0 / 30 fps cap / 75 % scale; `p5_le01_crosspath.jpg`,
`p5_le03_capital.jpg`, `p5_le05_battle_mid.jpg`):

| Place | FPS | Frame (process) | Working set | Video memory |
|---|---:|---:|---:|---:|
| Crosspath | 30 (cap) | 7-10 ms | 1.48-1.52 GB | 946-950 MB |
| The Capital | 30 (cap) | 10-24 ms | 0.99 GB | 870 MB |
| A battle | 30 (cap) | 8-17 ms | 0.92 GB | 590-614 MB |

**5.3 Download size:** RC2 zip **734 MB** (RC1 736), pack 844.8 MB, 14,092 files. The 20 largest entries are all music (MUS-CREDITS 6.1 MB,
then the boss and battle themes at 3-3.7 MB each, Vorbis q6 by design) and the Capital rim's baked geometry (4.2 MB). By folder: music 306 MB,
textures 441 MB (the zone kits 30-54 MB each, the world sprites 36 MB). `node tools/reference_graph.js --list` finds only **0.8 MB** of exported
files nothing references (cosmetic icon sizes the game builds by name - kept); removed from the export: the macOS app icon (1.9 MB, the
Windows build embeds the .ico) and four bestiary pictures with no entry. No superseded art or test files are packed. Against
`docs/build_size_policy.md`: over the 750 MB pack warning only because of the music, as decided. New: `node tools/verify_pck.js <pck> --largest=20`.
The export now ignores `_movie/` (the 931 MB trailer capture made the size guard expect a 1.5 GB pack and stop the first RC2 export).

## Part 6 - RC2

- `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc2`: the first try stopped at the guard (the `_movie` estimate above; nothing
  replaced); the second (`EXPORT_SKIP_BAKE=1`, keeping the bake the first run had just made) **EXPORT OK**: every MD5, 89 baked shaders, zip CRCs.
- **Release smoke on the exported pack: PASSED 17/17** (title shows v1.0.0-rc2).
- **Short exported-build checklist** on the rc2 test pack: run A (title, Credits, a new game, Crosspath with the new fountain, Sable's shop, the
  Deck Station, the Wardrobe, the Card Packs page, a battle, the pause menu, Reduce motion, Copy log, the save slots), run B (Reduce motion still
  ticked after a restart), the Low-end walk. 0 SCRIPT ERRORs. The real-exe fresh-install runs (`exe_drive.ps1`) were not repeated (the exe is
  the same stock binary; only the pack changed).
- Notes: `docs/release/rc2_notes.md`. Zip: `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc2-windows.zip`. CHANGELOG entry added.

## Commits (all pushed)

`99df27fd` Part 1, `b9ac7b83` Part 3 + briefs, `3917e1e6` Parts 2 + 4 (first half), `74f728dd` Part 2 fixes, version bump, `d9e66405` RC2,
then this report.

# Fable Nov 9 - report

Brief: `docs/prompts/fable_nov9.md` (with the day pass `docs/prompts/day_nov9.md` as Part 0). Questions: `docs/overnight_inbox.md`,
"Fable Nov 9". Shots: `docs/overnight_shots/nov9c/`. Run on Fable 5.1, one Godot at a time, no sub-agent while a Godot of mine ran; the
critic (a sub-agent) was the only Godot while it played. Last night's report follows below under "Overnight Nov 9 - report".

## At a glance

- **Import table with screenshots:** Part 1 below (23 images, all in the game). **The Pip pick:** `V-THREADWELL_DELIGHTED` (not the -ALT).
  **Other Sable images found:** none beyond her portraits, sprites and the figure-less shop background; nothing to redo.
- **Exported-build issues found and fixed:** the title screen ignored Enter from the keyboard (fixed); everything else matched the editor. Part 2.
- **The critic's top 10:** Part 2.3 below (first impressions 8, clarity 6, fun 6, polish 6; two of the ten fixed tonight, one was the critic's own script, the rest in the backlog).
- **Where the RC1 zip is:** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-rc1-windows.zip` (736 MB). Notes for testers: `docs/release/rc1_notes.md`.
- **Trailer:** done, 44 s, `C:\Dev\Deckbuilder-rpguilds	railer_rc1.mp4` (+ poster frame). Part 3.
- **What the owner does next:** (1) play the exported zip once yourself (unzip, run `TheWaywardPath.exe`); (2) create the itch page from
  `docs/release/itch_upload.md` and `docs/release/itch_page/` (text, tags, the AI disclosure field, "$0 or donate", the 8 screenshots, the cover),
  upload the zip, keep it **Restricted**; (3) upload the trailer to YouTube and link it on the page; (4) send the Restricted link + `rc1_notes.md`
  to playtesters; (5) collect their F8 reports / logs (`post_1_0_backlog.md`, section 1); (6) on release day set `config/version` to 1.0.0, export,
  smoke, replace the upload, flip to Public (`itch_upload.md`, step 9). Decide later: the first-fight length, the fountain blocks, the forest light and
  the Gainlands kit (the critic's majors 2-5), and whether to soften Primm / the Gallery if story-only testers stall despite the level hints.
- **Tests:** full suite in shards after every change: **2890 / 2892 passed, 0 failing, 2 risky** (pre-existing tests with no assertion). New tests:
  `tests/core/sim/test_level_hints.gd`, `tests/core/data/test_art_patches.gd`, the title focus test in `tests/test_title_art.gd`, the credits and
  un-held variants in `tests/ui/test_release_basics_nov9.gd`.
- **Commits (all pushed):** Part 0 `d1025a81`, Part 1 `0981a1af`, Part 2 `8653663d`, Finish (this commit).

## Part 1 - Batch 14 + Sable (23 images, all in the game)

Filed with `node tools/batch14_move.js --apply` (Pending Review/Batch 14 -> Approved_*; every replaced file to Drive `Superseded/` and a local copy in
`_art_source/superseded_batch14/`; Sable's old world sprites moved out of Approved_WorldTest). Importers run one Godot at a time: portraits, NPC sprites
(+ `sprite_normals.gd --only=SABLE --force`), card art, key art, bestiary, icons. Rows in `docs/art/batch14_nov9.csv` say "In game (Fable Nov 9)".

| Image | Replaces | Where it shows | Screenshot (`docs/overnight_shots/nov9c/`) |
|---|---|---|---|
| V-SABLE, V-SABLE_PLEASED, V-SABLE_SCHEMING | her three portraits (the redesign: fox, high jabot, no cleavage) | Sable's talks and shop | `b14_sable_talk.jpg` (real talk), `b14_v-sable_*_talkbox.jpg` (base, pleased, scheming) |
| SPR-SABLE-FRONT_IDLE / SIDE_IDLE / BACK_IDLE / FRONT_TALK (+ REF) | her four world sprites, `_n` normal maps regenerated | her stall in Crosspath | `b14_sable_stall_sprite.jpg` |
| V-TONIC_EXCITED, V-TONIC_OOPS | the human-woman variants (now the frog) | Tilly Tonic | `b14_tonic_talk.jpg`, `b14_v-tonic_excited_talkbox.jpg`, `b14_v-tonic_oops_talkbox.jpg` |
| NPC-GATEKEEPER_HAPPY, NPC-GATEKEEPER_STERN | the bearded-human variants (now the bear) | Brannoch | `b14_brannoch_talk.jpg`, `b14_npc-gatekeeper_happy_talkbox.jpg`, `..._stern_talkbox.jpg` |
| V-FENWICK_EXCITED | the human variant (now the magpie) | Fenwick | `b14_fenwick_talk.jpg`, `b14_v-fenwick_excited_talkbox.jpg` |
| V-THREADWELL_DELIGHTED | the human variant (now the mouse) | Pip | `b14_pip_talk.jpg`, `b14_v-threadwell_delighted_talkbox.jpg` |
| RES-IRON, BAS-G, B-13 | the glossy 3D plate, the cobalt vector Feastforge, the B-26 twin | hand and full size | `b14_hand.jpg` (all three in hand), `b14_cards_full.jpg` |
| STORY-PRIMM-P1, STORY-PRIMM-P2, STORY-REVEAL-KITCHEN | the giant-scale stills | the castle's phase cutscenes, the Test Kitchen reveal | `b14_primm_p1.jpg`, `b14_primm_p2.jpg`, `b14_reveal_kitchen.jpg` (real cutscene screen) |
| BST-ANTECHAMBER-SENTRY | the Windows-logo visor | the Collection Book's Bestiary, the Lab fight | `b14_bestiary_sentry.jpg` |
| ICON-ITEM-FIELDBANDAGE | the red-cross icon (now a leaf) | Tilly Tonic's shelf, the bag | `b14_item_vendor.jpg` |

- **The Pip pick:** `V-THREADWELL_DELIGHTED` (the first try). Against the base V-THREADWELL it keeps the hat's angle and bands, the patchwork coat
  with the same diamond patches and shoulder strap, the ears and the red neck ribbon. The `-ALT` has a steeper hat, much bigger ears and a pink
  sash; it is in Drive `Superseded/` (and `_art_inbox/batch14/`).
- **Held expressions:** `Portraits.HELD_EXPRESSIONS` is empty now (all five sets repainted on-species); the mood portraits show again. The release-basics
  test asserts the eight variants are offered and that Sable's pleased face is its own picture.
- **Other Sable images in the game:** searched every asset, data file and art sheet for her. Found only her three portraits, her four world sprites
  (both replaced) and her shop background `VS-SABLE` (the velvet salon: cards, curtains and shelves, **no figure** - nothing to redo). No card, still,
  loading painting or title art shows her. Nothing added to the art list for Sable.
- **The Red Cross emblem:** still on NPC-HESPER's cap and armband and on Hesper in STORY-EPI-WRINKLES. Fixed in code: `core/data/art_patches.gd`
  recolours red-dominant pixels inside two small normalised boxes per picture to a muted leaf green as the picture loads (Portraits and KeyArt call it;
  test `tests/core/data/test_art_patches.gd`). Seen in `b14_npc-hesper_talkbox.jpg` and `b14_epi_wrinkles_green_cross.jpg`. Two **REDO** rows added to
  `docs/art/art_audit_nov9.csv` (a leaf or heart instead of the cross). The new bandage icon has no cross.
- **Size and memory** (`docs/build_size_policy.md`): the 23 replaced files total 4.28 -> 4.66 MB in the repo (**+0.38 MB**; the portraits and cards are a
  little richer, the sentry doubled at 60 -> 91 KB, two stills shrank). Same count and import rules as before, so the pack moves by well under 1 MB
  against the 750 MB budget (the export in Part 2 gives the exact number). Memory: the same textures at the same sizes; the two patched pictures are
  rebuilt as ImageTextures once when loaded (the same VRAM as before; the CPU-side copy is transient) and sit in the bounded ArtCache like the rest.
- **Tools:** `tools/batch14_move.js`; `tools/story_still_shots.sh --ids=A,B`; `tools/shot.sh res://scenes/town.tscn x --open=bestiary:<Name_with_underscores>`;
  the card gallery's `--ids` now finds resources and infrastructure; the battle `--hand=` flag loads tokens (RES-*) too.
- **Gotchas met:** the portrait importer re-added the opaque NPC-PLAYER (reverted, as before); the NPC sprite importer rewrote the whole manifest
  (spliced only SABLE's entry: canvas 320x504 -> 304x512, `cloak_hue`/`head` kept); the importers' status writer dropped the "UI art kit" and
  "Dungeon maps" sections of `docs/art/art_status.md` (restored from HEAD); `core/zone/zone_defs.gd:46` references Session, which prints a compile
  error in every headless `-s` importer run (harmless: the import still completes).

## Part 2 - RC1 build and the real-build check

**Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc1` (1.4 GB free RAM; the export's own guard wants 2 GB, its hard stop is
1.2 GB; peak Godot working set 1.3 GB, 14 MB free at the worst moment, every check passed). **Zip:** `builds/TheWaywardPath-v1.0.0-rc1-windows.zip`
= **736 MB** (pack 847 MB, 14,101 files, 89 baked shaders, every MD5 and CRC checked; build folder 952 MB). The pack is over the 750 MB budget
warning because the music is at Vorbis q6 by the designer's decision (`docs/build_size_policy.md` has the new row). Release smoke on the
exported pack: **PASSED, 17/17** (title + version, New Game to the starting area, F8 report + screenshot + log copy, pause menu, no Dev Menu,
save to slot 2 and load back).

**Exported-build test, two layers** (shots `docs/overnight_shots/nov9c/rc1_pack_*.jpg` and `rc1_exe_*.jpg`):

| Check | On the real `.exe` (fresh user folder, real clicks and keys: `tools/exe_drive.ps1`) | On the exported pack (stock binary + test pack, play driver: `tools/play_exported.sh`) |
|---|---|---|
| First launch, no settings or save | ok: title with New Game / Settings / Credits / Quit, v1.0.0-rc1; the Low-end preset picked itself on this iGPU (log: "first launch: Low-end preset") | - |
| New game through the intro to Crosspath | ok: slot chooser, the wake-up still, the forest, the Rescuer, the Path choice (Beefcake), the forest free; Crosspath reached via the driver's jump in the pack run | ok (`x04`-`x05`) |
| Save, quit, reload | ok: autosave after the Path choice; a manual save to slot 1 ("Saved to Slot 1"); Quit Game; Continue on the next launch landed in the forest; Load Game lists the autosave and Slot 1 | - |
| A battle, a shop, the Deck Station, the Wardrobe, the Card Packs page, a minigame | - | ok: Quota's duel played by the pilot then won (`x10`-`x12`), Sable's stall (`x06`), Deck Station (`x07`), Wardrobe (`x08`), Card Packs (`x09`), the Gainlands quiz (`y07`-`y08`) |
| Settings that survive a restart | ok: Reduce motion ticked on launch 2, still ticked on launch 3 (`settings.cfg`: `reduce_motion=true`) | ok: run B seeded with run A's settings shows the tick (`y01`) |
| Low-end mode | ok: auto on first start (quality Low, 30 fps cap, render scale 0.5) | ok: forced quality 0 - town, the Gainlands, a battle (`z01`-`z03`) |
| The log file and Copy log | ok: `%APPDATA%\Deckbuilder-RPG\logs\wayward.log` (+ `.1`, `.2`), boot lines with OS/GPU/driver | ok: "Copied" toast (`x15`) |
| Credits and the AI disclosure | ok: "A game by Alex Glowatz", the licences, the AI section (launch 3) | ok (`x02`) |
| The hidden donation button | ok: no Support button on the title or the Credits head | ok |

**Differences from the editor found and fixed:** none in the game itself. Two things the real exe showed that the editor runs hid:
1. **Keyboard only at the title: Enter did nothing** (no button holds the focus until a pad or the mouse gives it). Fixed: the first keyboard
   Enter or arrow focuses the top menu button (`TitleScreen.keyboard_focus_menu`, test in `tests/test_title_art.gd`). Not re-exported for this
   (an rc1b export is not needed for a focus fix; it is in the next build).
2. The exported build's Escape is matched by physical key: a synthetic Escape without a scan code is ignored (a tooling fact, not a player issue).

**Tools made for this:** `tools/exe_drive.ps1` (drives the exported exe: `wait`, `key`, `press` with scan codes, `hold`, `click`, `shot`; never
touches the player's files - move `%APPDATA%\Deckbuilder-RPG` aside by hand), `tools/play_exported.sh` + a `play` mode and settings seeding in
`tools/run_exported_suite.sh`, the scripts `docs/review/play_scripts/exported_rc1_{a,b,c}.txt` and `exe_{a,b,c,d}.txt`.

**Fresh-eyes critic of the exported build (Part 2.3):** a fresh `general-purpose` agent given only `docs/review/critic_rc1_brief.md` played the
exported pack for about 80 minutes of game wall clock over 34 runs (r1-r33 the straight first hour with no jumps: title, Settings, Credits,
the opening line by line, Beefcake via "More", the forest, all five cave nodes and the Hollow Warden, Crosspath, Maren, every menu, Fenwick,
Tilly, the Power Wraps errand; r34 the only jump: the Gainlands and the House of Gains). Report: `docs/review/critic_rc1/report.md`
(63 shots in `docs/review/critic_rc1/shots/`). It was interrupted once by the account's usage limit and resumed.

| Score | /10 | Why (the critic's words, shortened) |
|---|---|---|
| First impressions | 8 | title, stills and portraits superb; the real 3D forest dark and blurry with a tiny hero; Path cards unreadable until "More" |
| Clarity | 6 | menus and rules panels good; the cave trigger is missable, the end-turn nag fires while picking attackers, "Where to?" sets a goal, Esc does not close Tilly's shop |
| Fun | 6 | the card game is sound, boss / level-up cadence good; the first fights last 8-11 rounds against a 3-HP enemy (infrastructure flood) |
| Polish | 6 | 2D screens about 9/10; white untextured blocks in the Crosspath square, the dark forest, low-poly Gainlands kit, bark bubbles over name labels |
| Unfinished / AI-made | - | most visible: the white 3D fountain and plinth blocks in the square and the low-poly Gainlands; the painted art is openly AI (Credits) but consistent; no template text, no overflowing boxes, no SCRIPT ERROR in 34 logs |

**The critic's top 10** (severity for a new player) and what was done tonight:
1. **Major - the cave entrance trigger** only fired on a small ring beside the stairs; under the arch there was no prompt, every other way an "I'll head back" line; five runs to get in. **Fixed:** the arch answers E from the whole doorway and the bottom step (`StartingAreaScene.GATE_RADIUS` 3.0, was the 1.7 interact radius).
2. **Major - the first fights are too long:** a 3-HP Cave Scavenger lasted 8-11 rounds in four attempts, both decks flooding with infrastructure; 11 of 15 HP lost once. Backlog (balance; the Nov 1 teaching hand helps the very first duel only).
3. **Major - white untextured fountain / plinth blocks** in the Crosspath square beside painted houses. Backlog (the painted fountain and statues are the known art item).
4. **Major - the 3D forest is near-black** with heavy tilt-shift, the hero about 60 px tall. Backlog (known from N8; a light pass).
5. **Major - the Gainlands' flat low-poly kit** clashes with the painted art; the gatekeeper fight starts two steps in with only a toast. Backlog (zone kit texture pass).
6. **Minor - "End your turn? You can still play 1 card"** appears while choosing attackers with one selected. Backlog (suppress during attacker selection).
7. **Minor - Escape does not close Tilly's shop**, only the X. **Not a bug:** reproduced in the editor build (`docs/review/play_scripts/esc_shop_probe.txt`): one Escape closes the shop, tip or no tip (`_screenshots/play/esc_shop_probe/esc_02_after_escape.png`). The critic's script pressed E again beside Tilly two lines later, which re-opened it.
8. **Minor - "Where to?"** sets a goal marker rather than travelling or closing the map. Kept (by design: the arrow leads there after the map closes); the label could say so. Backlog.
9. **Minor - townsfolk bark bubbles drawn over their own name label.** **Fixed:** the bubble sits 30 px above the plate (`NpcBarks.LABEL_CLEARANCE`).
10. **Minor - Path choice thumbnails unreadable** until click + More. Backlog (show "how it plays" and the Resource on hover).

What worked for the critic: the opening and the portraits, the cave node map and the Hollow Warden reveal, the Deck Station and Character
pages, battle readability (hover zoom, the "-1 HP if unblocked" arrow, the Just Arrived tooltip, Speed), the shopkeepers' voices.

**RC1 notes:** `docs/release/rc1_notes.md` (what is in it, known issues, how to report). **The zip:** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-rc1-windows.zip`
(no Drive `Releases` folder exists; `docs/release/itch_upload.md` names the file).

## Part 3 - itch.io page kit, final

- **Re-checked against 1.0.0-rc1** (`docs/release/itch_page/page.md`): the descriptions, the features (deck slots "four to start, more as you
  level" instead of "ten"; the minigames and the postgame named; the comfort options updated: Path symbols on by default, Reduce motion, the
  autosave indicator, level hints), the controls table against `app/keybinds.gd` (tracked-quest keys, dungeon rules R / Y, right-click inspect
  added), the measured requirements (the exported build's own boot log: Ryzen 5 4500U iGPU, 7.4 GB, Low-end auto-picked, 278-370 MB video
  memory in the forest; download about 740 MB, about 950 MB unpacked), the tags (unchanged), the AI disclosure (page text + itch's own
  disclosure field in `itch_upload.md`), and "free, donations welcome" in the pricing note and the long description.
- **The eight screenshots** (`docs/release/itch_page/screenshots/`, 1920x1080, README lists the order): a Buffet-board battle, the wake-up still,
  the Shattered Gallery map, the classroom quiz, the Wardrobe, the Card Packs shelf, Dex's table, the Capital's Gate Plaza. The Nov 8 set is kept in
  `old_nov8/`. (The Capital shot is the Gate Plaza from a postgame save; `dev travel capital` lands inside the dark Crease, and the broken-state plaza
  carries a "Tidy-Bot knocks you flat" toast - neither suits a store page.)
- **Trailer: done, 44 s** - `builds/trailer_rc1.mp4` (11.9 MB, h264 1280x720 30 fps, AAC) + `builds/trailer_rc1_poster.jpg`. Made with
  `bash tools/make_trailer.sh capture` (the play script `docs/review/play_scripts/trailer_rc1.txt` under Godot's movie writer, `--write-movie`
  `--fixed-fps 30`, MJPEG AVI 931 MB in `_movie/`) and `bash tools/make_trailer.sh cut` (ffmpeg: clips at the script's CUT marks, 0.4 s fades, three
  title cards in Cinzel on the game's ink colour, the title theme `MUS-TITLE.ogg` as the only sound, faded out). Clips: the title, Crosspath, the
  Deck Station, the Endless Buffet, a battle (12 s), the Shattered Gallery map. Two captured clips were left out: the Gainlands walk ran into the
  gatekeeper's duel and the Capital clip was the Crease interior. Honest and simple, as asked; itch takes a YouTube/Vimeo link, so the owner uploads
  the mp4 there (or attaches it to the devlog). Gotcha: the play log counts wall-clock seconds while the movie counts frames at 30 fps (the capture
  renders slower than real time), so the cut script scales the marks by movie length / last mark.
- `docs/release/itch_upload.md` names the exact files (zip 736 MB, cover, the 8 screenshots, the trailer).

## Part 4 - handover and the post-1.0 plan

- **`docs/HANDOFF.md` finalised:** section 2 is the exact sequence run today (tests, export with the low-memory switch, release smoke, the test pack
  and `play_exported.sh` runs, the real-exe driver, the critic brief, the upload guide); section 3 the art pipeline with the Batch 14 filing tool,
  the importer quirks met today and the shot commands per kind; sections 4-5 music and dialogue; section 6 the six small-prompt templates;
  section 7 points at the backlog; section 8 the one-line Drive backup (`git archive ... HEAD` into `Card Game Art/Backups/`).
- **`docs/release/post_1_0_backlog.md`:** playtester feedback intake (collect, triage, reproduce, fix and ship, watch the walls), the known issues
  at rc1 (title keyboard focus - fixed tonight -, the walls, the Red Cross stopgap, the Capital load, the pack size, Credits scroll keys, Esc on a first
  viewing, the headless Session error, exit-time leak noise), the remaining art REDOs (Hesper x2, NPC-GUS, 8 bestiary pictures, one gear icon, 8
  unmatched bestiary files), nice-to-haves (the critic's list) and Steam readiness (Steamworks, achievements from feats, cloud saves, store assets,
  Steam Input, Deck, build pipeline).
- Everything is pushed to GitHub after each part (see the commit list at the end).

## Part 0 - the day pass

| Item | Done | Where |
|---|---|---|
| Credits: Alex Glowatz as creator | yes | `data/credits/credits.cfg`; "A game by Alex Glowatz" + "Game design, direction and production: Alex Glowatz" on the Credits page (`01_credits_creator.jpg`), and under the title card in the end credits. Donation link empty: Support stays hidden. |
| Colour-blind symbols on, Dex stays | yes | both already in the game; inbox items 1 and 3 closed |
| Level hints at the walls | yes | every dungeon door (zone side and main dungeons, Swolympus, the Vault hatch, the Lab hatch, the castle, the Gallery, the Paste Works) says "Travellers here are usually around level N" under its prompt, **amber when 2+ levels under** (`02_hall_prompt_level9_amber.jpg` vs `03_..._level12_muted.jpg`); the full map's "Where to?" list says "(Dungeon entrance, usually level 11)" and the dungeon icon has the same line as a tooltip (`06_map_where_to.jpg`). `core/sim/level_hints.gd` reads `ProgressionModel.LEVELS`; test `tests/core/sim/test_level_hints.gd` (every dungeon but the level-1 cave has one). Balance unchanged. |
| Dark battle backdrop | dev-only, fixed | the UI sweep's shot 16 was `dev encounter quota`: its sim group "capital:lieutenant" is not a battle-context key, so the board fell back to the placeholder slate. The real Quota duel always had the Transit Yards board. The sim group is mapped now (`data/battleboards.json`), `07_dev_quota_board.jpg`. |
| itch upload guide | yes | `docs/release/itch_upload.md` (page, "$0 or donate", text, AI disclosure field, zip, screenshots, Draft/Restricted, Support link, playtesters, public flip, butler). |

# Overnight Nov 9 - report

Brief: `docs/prompts/overnight_nov9.md`. Tag `pre-overnight-nov9` marks the start. Questions: `docs/overnight_inbox.md`, "Overnight Nov 9".
**No export.** Last night's report is archived at `docs/overnight/nov8b/overnight_report_nov8.md`. Run on Opus 5.5 (not Fable); Claude
Code's low-memory reaper was *on* for this session, so every long Godot job was started detached and watched from the foreground.

## 1. The four real-fight playthroughs

Every Path played from a new save to the credits and through the postgame (the Lab, the Shattered Gallery, Swolympus, Loose Ends) with
**every fight real**: every node of every dungeon (the tutorial cave, all side dungeons, all four main dungeons, the castle, the postgame),
every gatekeeper, every boss phase. No decreed or auto wins - except after a **wall** (4 losses on the same dungeon), which is logged, then
decreed so the run can go on. Save and load at each zone change (state digest checked), plus one mid-dungeon save/load. A loss plays out
as a loss: the hero wakes at the respawn point, the dungeon starts over, and the bot walks back in.

| Path | Completed | Steps | Game time (bot) | Fights won / lost | Walls | Gold earned (target 21.3k) | Final level |
|---|---|---|---|---|---|---|---|
| Beefcake | **yes** | 119 / 119 | 1.08 h | 93 / 30 | 6 | 15,750 (74 %) | 24 |
| Necrocrat | **yes** | 119 / 119 | 1.03 h | 82 / 20 | 4 | 17,035 (80 %) | 23 |
| Gourmand | **yes** | 119 / 119 | 0.95 h | 82 / 16 | 3 | 16,510 (77 %) | 23 |
| Refusemancer | **yes** | 119 / 119 | 1.19 h | 100 / 15 | 2 | 19,155 (90 %) | 26 |

**How to read it.** The player is the game's own planning AI (ELITE, the same player as the balance sims) sitting in the hero's seat on the
real battle screen at battle speed x4 - so "game time" is bot time, several times shorter than a human's. Between fights it opens every
pack, wears its best gear, buys the best cards Sable has for its Paths (keeping a third of the purse), and rebuilds its deck with the Deck
Station's own "Suggest a deck" (two Paths once the game allows). It plays **no optional content**: no roamers, arena bouts, quiz, Dex or
favours beyond the one each zone needs (those are set by flag) - so it arrives everywhere **3-5 levels under** `ProgressionModel`'s
expected player, and its gold is short of the 21.3k no-grind target for the same reason (the target counts the optional fights).

**Losses by encounter** (level at the time): full lists in `docs/playthroughs/full_real_<path>_nov9.log` ("FULL loss" lines).
- **Primm (all four Paths, a wall in all four):** levels 16-20. Expected player: 21.
- **The Shattered Gallery (all four, a wall in all four):** levels 22-25. Expected: 26.
- **The fourth zone's main dungeon** (the Rotheart for Beefcake and Gourmand, a wall for both): levels 14-15. Expected: 17.
- **The second zone's main dungeon** (the Hall of Final Approvals for Beefcake, the House of Gains for Necrocrat; both walls): level 9. Expected: 11.
- **S-NECRO, the D.N.A. side dungeon** (a wall for Beefcake and Necrocrat): levels 5-9. Expected: 10. It opens with the D.N.A. favour,
  so a player who takes it as soon as it opens meets it about 4 levels early.
- Lighter: the Lab (L19-21, one wall), Swolympus (L23-25), the House of Gains boss for its own Path (L5, beaten on the 2nd-3rd try).

**Difficulty walls a normal deck can't pass:** none that stay walls once the hero is at the expected level - every wall above sits 2-5
levels under it. But a **story-only player will stall at Primm and at the Gallery** on every Path, and at the second and fourth main
dungeons on some. Recommendation (owner's call, not changed tonight): say it in the game - e.g. Maren or the dungeon entrance noting
"most travellers are level N before this" - or soften those four by one step. The balance sims are the tool to pick which.

**Dev help used:** walking (teleports to spots, the zone road walk, the Lab hatch, the Rift Express, Swolympus travel), favour steps and
Maren's early chain set by flag, Old Man Mountain's errand by its counter, and the decree after each wall. Nothing else.

## 2. Blockers found and fixed

| # | Found | State |
|---|---|---|
| 1 | **Primm's Castle could strand the player** (ship blocker). Its side branches nest (courtyard -> Grand Foyer -> Portrait Gallery -> two wings); after the wings the map sent the party back one level only, onto the Gallery, with nothing left open. Nothing to click; only Retreat (which resets the final dungeon). The Beefcake run hit it 18 times (the bot jumped ahead, logged). | **fixed**: `DungeonMap.complete` keeps doubling back the way the party came until a node has an open path. New test walks every dungeon as a completionist and with 20 random walkers each (fails on the old code, passes now). The three later runs met it 0 times. |
| 2 | **Rewards screen: a second Take/Skip press** (double click, or E right after a click) applied the rewards again, stacked a second level-up panel and ran the after-rewards step twice (the tutorial's completion twice). | **fixed**: one confirm per screen. |
| 3 | **Dungeon map: choosing a node while its cutscene played** started it again on top (stacked cutscenes). | **fixed**: picks are ignored while a node cutscene is up. |
| 4 | **The Credits page showed its own editing notes** as its first heading. | **fixed** (+ test). |
| - | **Still open:** none found that blocks finishing the game. Watch item: the walls in section 1. | - |

## 3. Game feel and polish (Part 2)

Most of the battle-impact list was already in the game (Battle feel, Oct 28-29: card lift and land with dust, wind-up lunge, hit-stop,
shake scaled to damage, floating damage numbers, the dissolve shader, buff numbers). Tonight filled what was missing and checked the rest.

**Battle impact (new tonight)**
- **Reduce motion** (Settings > Accessibility, saved): no screen shake, no hit-stop, no final-blow slow motion; lunges, recoils, pops and the
  turn-banner sweep at 30 %; half the particles. A superset of "Reduce screen shake".
- **Buffs** pop: the unit grows and settles with a green glow ring (the +x/+y number was already there).
- **Healing**: a green glow ring on the healed portrait, under the burst and the "+N HP".
- **Unit death**: the burst is now in the unit's Path colour (it was a fixed peach), matching the dissolve edge.
- **Turn banner**: 0.62 s instead of 0.75 s (both sides).
- Before/after: `docs/overnight_shots/nov9b/` (Dex, UI sweep); battle feel is motion, so it is described rather than shot.

**Sound coverage:** `docs/audio/sound_coverage_nov9.md` lists every common action. Gaps filled:
1. the world purse: gold rising now chinks softly (at most every 0.5 s) and the HUD number pops;
2. Settings, Glossary, Feats, Credits and the save slots: open with a page sound, close with a soft back sound (they closed silently);
3. opening a town or zone screen no longer plays the close sound first (it "closed" nothing);
4. a miss at Dex's table has a sound.
Loudness re-measured with both tools: nothing sits more than 3 dB over its role; no change needed. Ducking verified in code: music -4.5 dB
under any dialogue box, -9 dB (story -13) under stings, eased. Default mix unchanged (music about 2 dB under effects).

**Transitions:** every scene change already goes through SceneManager's fade (no direct scene switches anywhere in the code). New: the full
loading screen only shows when it is needed - a destination that loaded in under 0.9 s earlier this session gets the plain fade (the
"still loading" card still appears if a load runs long). First visits keep the loading screen.

**UI consistency sweep:** 23 screens shot before and after (`docs/overnight_shots/nov9b/ui_before/` and `ui_after/`, script `docs/review/play_scripts/ui_sweep_nov9.txt`).
The frames, headers, buttons and focus rings already match the Deck Station across title, Settings, Character, Deck Station, Packs, Quest
Log, Map, Wardrobe, Pause, zone HUD, dungeon map and Dex. Strays found and fixed:
1. **the Credits page printed its own editing notes** ("The Credits screen's text... '#' lines are headings...") as its first heading - the
   file's header used heading marks; now comments, with a test;
2. the D.N.A. Rec Room memory cards could not take keyboard/pad focus (Dex's table could): now focusable with the shared focus ring.

## 4. Dex's Cardsharp's Circuit (Part 3): **finished - keep it in 1.0**

- **Played through end to end** by a new smoke (`tools/dex_circuit_smoke.tscn`): Dex's talk spot in all four zones (lines, quest offer,
  table), each table won, the final table opening after four, the turn-in, and the Matching Pair granted and worn: **46 / 46 steps**.
- **Scoring was unfair:** "12 moves or fewer" (11 at the final) out of 14. Simulated: a *perfect* memory beat that only 55 % / 9 % of the
  time. Now 15 / 14 out of 20 - a careful player wins a zone table 82-97 % and the final 61-87 % (`docs/minigames/dex_odds_nov9.md`).
- **Rules:** one line under the score: "Flip two cards: that is one move. Find all eight pairs in 15 moves or fewer to beat Dex (the table
  allows 20)."
- **Polish to the Deck Station bar:** a green felt table with a gold rim, the Path's own card backs (the final table: the neutral back)
  instead of a "?", Dex's portrait at the head of the table with his name and a line after every move (pair, miss, win, close, out of moves;
  in `dungeon_content.json`, `cardsharp.quip.*`), "A pair! 3 of 8 found", and a miss that says to remember where the cards were.
- The prize's effect (draw a copy of your first spell each turn) was already tested.
- Shots: `docs/overnight_shots/nov9b/dex_*`.

## 5. Release basics (Part 4)

- **Autosave indicator:** a small quill turning in a gold ring with "Saving..." in the bottom-right corner on every autosave (it holds 0.9 s
  after the last save, then fades; slower under Reduce motion). `ui/widgets/save_indicator.gd`, `EventBus.game_saved`.
- **Colour-blind Path symbols ON by default** (`Settings.DEFAULT_COLORBLIND_SYMBOLS`; inbox item 1 says how to flip it).
- **Version 1.0.0-rc1**: title screen, log header, Credits page (all read `config/version`), Windows file/product version 1.0.0.0.
- **itch screenshots:** left as last night's - this screen cannot open a true 1920x1080 window (max about 1886x1061).
- **credits.cfg:** creator and donation link left empty, with `>>> OWNER` comments showing exactly where they go.

## 6. Final read of the main story (Part 5)

All 1,484 main-quest lines read in game order (prologue, Crosspath, the four gatekeepers, dungeons and freed-zone talks, Maren's four
memories, the cave-mouth scenes, the Capital's main beats, the castle, Primm, the ending and the post-ending scenes). The Nov 5 rewrite holds
up: voices match `docs/dialogue/story_voice_nov5.md`, clipped "short statements" are gone from the main line, and the jokes sit on side
characters. Fixed: 11 hand edits and 88 quote repairs (revertible: `node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_nov9.csv --revert`; the filled sheet is
`docs/dialogue/edit_nov9/story_read_applied.csv`):
- **69 lines of speech split across boxes** (a quote opened in one box and closed two boxes later: Agnes in the queue, Mortimer, Vellum,
  the notary, the whistleblower, Old Man Mountain, the throwers...) - every box now opens and closes its own quotes; plus 19 of Primm's
  lab notes and journals split the same way with single quotes.
- **Continuity:** Primm "in his pressed grey coat" after the fight (he wears white and gold); Primm "removed two people so that eleven
  thousand could be safe" (eleven thousand is the number he *corrected*) - now "a whole kingdom".
- **Repetition:** the blueprint vault and the early journals both used "They are good. They are so good." (Flex's repeated "it was not the
  part that matters" is a deliberate beat the Wanderer throws back at Primm - a story test caught my edit, so it stays.)
- **Clunky lines:** Clench's boss intro told you to get "off the wheel" inside his gym;
  Compostella's muddled "don't shut it away in a jar... Death is not the end of them".
- Kept on purpose: the Rescuer's "Tell me: which Path resonates within you?" is pinned word for word by a test (an earlier owner call).
- Fig Sly's black-market lines are locked by the tool and were not touched.
- Nothing contradicts the current quest steps, names or tutorials. Re-exported: `docs/dialogue/edit_nov9.csv` (4,357 rows, story order).

## 7. Plan for Nov 9-11 (updated)

- **Nov 9, day (owner):** answer the inbox (colour-blind default, Dex kept, the walls). Fill `data/credits/credits.cfg` (name, donation
  link). Generate Batch 14 (`docs/art/batch14_nov9.csv`, the five mood-variant sets first). Play Dex's table once - it should now feel winnable.
- **Nov 9, day (Claude):** import Batch 14 and un-hold the portrait variants. Decide the four walls with the balance sims (Primm, the
  Gallery, the 2nd/4th main dungeons, S-NECRO's opening point) or add "travellers are usually level N" hints - whichever you choose.
- **Nov 9, night run:** the S items left from the cut-or-finish list (quiz feedback, packs shelf scroll, Alembic bars, Wardrobe tint, Gallery
  tooltip), the forest light and the tutorial-cave restart; re-run one Path with `bash tools/run_full_real.sh <path>` after any balance change.
- **Nov 10, day:** play the first hour yourself on a clean save; one fresh-eyes critic (first hour).
- **Nov 10, night run:** Crosspath roof fade, the battle infrastructure row and hand cap, the full suite, an exported-build smoke.
- **Nov 11, day:** set `config/version` to 1.0.0 (the presets already say 1.0.0), export, test the zip on a second PC, set up the itch page
  from `docs/release/itch_page/`, upload, finalise `docs/HANDOFF.md`.

## Tests

Full suite in memory-safe shards (`bash tools/run_tests.sh --only=tests --size=12`): **2,878 / 2,882** on the full pass; the 2 failures
were tonight's (the version-preset test now compares the numeric part of "1.0.0-rc1"; the word-for-word Path question was restored) and
pass on re-run; 2 risky (pre-existing tests with no assertion). New tests: `tests/core/dungeon/test_map_never_strands.gd`, the Credits
notes test. New tools: `tools/run_full_real.sh <path>` (with a memory watchdog), `tools/story_playthrough.gd --full=1`,
`tools/dex_circuit_smoke.tscn`.
