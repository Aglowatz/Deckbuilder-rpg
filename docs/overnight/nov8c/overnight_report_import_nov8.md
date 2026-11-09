# Import Nov 8 (Batch 13 + polish) - report

Brief: `docs/prompts/import_nov8.md`. Tag `pre-import-nov8` marks the start. Questions: `docs/overnight_inbox.md`, "Import Nov 8".
Screenshots: `docs/overnight_shots/nov8c/`. Load numbers: `docs/perf/nov8c/`. Critic: `docs/review/critic_nov8c/N8.md`. No export.

| Part | What | State |
|---|---|---|
| 0 | Remaining test shards (9-30), push | done: every failure fixed (all were Dex / Batch 13 expectations); pushed |
| 1 | Batch 13: 23 images filed, imported, wired, shot | done (all 23 in game; NPC-PLAYER held back again) |
| 2 | Quick wins | done (10 items; "rules drawn twice" was already fixed Nov 7) |
| 3 | Capital later-visit load | done: 7.2 -> 5.9 s later visits, 9.9 -> 8.2 s first visit |
| 4 | Fresh-eyes critic | done: first hour 5/5/5/7/6; 5 of its top 10 fixed or partly fixed tonight, the rest logged |
| Finish | all shards, report, push | partly: the final full run was stopped by Claude Code at shard 25 of 30 for low memory (not restarted, per its rule); shards 1-24 passed except one test, now fixed and re-run |

### Owner decisions (Nov 8, after the report)

- Dex stays a ferret; tips stay as they are; the Capital load is good as it is.
- **Low camera angle, for playtesters:** a fourth camera preset, **Low** (Settings > Display > Camera angle, or V cycles Cinematic -> Classic
  -> Overview -> Low). Pitch 11 degrees (Cinematic is 20), the camera 26 % closer so the hero keeps his size, the lens 3 degrees wider,
  the tilt-shift blur a little stronger. Saved in settings.cfg like the others (existing settings keep their index). Shots:
  `low_crosspath.jpg` (vs `cin_crosspath.jpg`), `low_gainlands.jpg`, `low_dump.jpg`. Known at Low: name tags of NPCs standing behind the
  fountain stack up toward the sky (the tag spreader pushes them up); roofs and the occlusion fade were not tuned for it.

## Part 0 - Finishing the last pass

Shards 9-30 of the full suite ran (`bash tools/run_tests.sh --only=tests --size=12 --from=9`). Every failure was an expectation that Batch 13
or Dex's prize changed:
- `test_icon_wiring` / `test_icon_conventions`: Dex's Matching Pair is an 11th named piece that lives in `data/equipment/zone/` and keeps its
  art-list name (`ICON-EQ-MATCHING-PAIR`, not `ICON-GEAR-*`); the tests know both now.
- `test_ui_art`: the UI kit lists 61 ids (6 new, two of them `MG-BG-*`).
- `test_no_citizen_outside_capital`: Dex stood as the CITIZEN stand-in; with his sprite set imported he stands as himself.

The two unpushed commits were pushed at the start.

## Part 1 - Batch 13 (23 images)

Filing: `node tools/batch13_move.js [--apply]` (the Batch 12 mover with Batch 13's folders). Nothing replaced an older file, so nothing went to
Superseded. Folders: boards -> Approved_Battleboards, plinth statues and levers -> Approved_EnvKit (the town kit), the thorn wall ->
Approved_ZoneKits/VerdantDump, the UI and minigame backgrounds -> Approved_UI, the icon -> Approved_Icons, Dex -> Approved_Characters /
Approved_Sprites. Importers, one Godot at a time: battleboards, zone kit `town` and `heap` (`--only`), UI art (it now also accepts `MG-*` ids),
icons, portraits, NPC sprites. Clean-ups after them:
- the zone kit registries were rewritten with float churn; only the new items were spliced into HEAD's text (`python tools/kit_splice.py <zone> ID...`);
- the sprite manifest was rewritten; only the DEX entry was added to HEAD's text;
- the portrait importer re-imported **NPC-PLAYER** (still the opaque version): reverted to HEAD, as on Nov 6.

The art list (`docs/art/art_needed_nov4.csv`) has a new `status` column: the Batch 13 rows say "In game (Batch 13, Nov 8)", the older rows point
to the Batch 12 report, and BB-S-GALLERY-ALT has its own row (it came without one).

### Per-image table

Cost = packed size in the export and the texture memory when shown (VRAM: BC-compressed images at 0.5-1 byte per pixel, lossy WebP
decompressed to 4 bytes per pixel, +33 % with mipmaps).

| Image | Where / wiring | Screenshot | Scale check | Pack | VRAM |
|---|---|---|---|---:|---:|
| BB-S-GALLERY | every Shattered Gallery fight (the castle board stand-in drops out by itself) | `b13_board_gallery.jpg` | 16:9 crop of 1536x1024, cards read on it | 148 KB | 5.1 MB |
| BB-S-GALLERY-ALT | The Perfect Copy's fight only (`ShatteredGallery.board_for`, boss node) | `b13_board_gallery_alt.jpg` | same; darker blue mirror hall, the boss fight looks different | 115 KB | 5.1 MB |
| DEC-PLINTH-BEEF / NECRO / GOUR / REF | one statue per freed zone on the fountain's crest plinths; the plinth's gem and floating icon hide under it (`TownScene.PLINTH_STATUES`) | `b13_plinths_default.jpg`, `b13_plinths_close.jpg`, `b13_plinths_low.jpg` | 1.15 m on the 0.58 m plinth: the top at the hero's head, the base as wide as the cap; checked at Medium and Low | 4 x 133 KB | 0.5 MB |
| UI-CAULDRON | Alembic's brew panel (the vector glyph stays as the fallback) | `b13_alchemist.jpg` | 260 px in the brew stage, shakes and glows as before | 323 KB | 2.9 MB |
| UI-BG-PACKS | the Card Packs page (lighter dimming than the stand-in) and both result screens (Open all summary, a single pack's summary) | `b13_packs.jpg` | full screen | 1.5 MB | 1.5 MB |
| UI-PACK-SHELF | THE SHELF's board: trimmed at import to the board (1528x203), scaled to 48 px high, brackets kept and the carved middle tiled; drawn behind the packs, their feet on its top, ending above the names | `b13_packs.jpg` | fits the panel, never over the names | 71 KB | 1.2 MB |
| UI-BG-WARDROBE | the Wardrobe's room (replaces the dimmed Character crop) | `b13_wardrobe.jpg` | full screen | 1.5 MB | 1.5 MB |
| KIT-HEAP-THORNWALL / -DEAD | the wall at Moss Mulligan's gate (Crosspath's west road): breathes (a slow scale pulse in `HubObstacles._process`), withers and parts once he is beaten (the live wall sinks, the dead one rises). Collision: closed = the old line across the road; parted = only the two sides (`_add_parted_circles`, a 1.4 m gap like the art's) | `b13_thornwall_closed.jpg`, `b13_thornwall_withered.jpg` | 4.7 m card across the road between the wings | 2 x 672 KB | 1.3 MB |
| LEVER-LOCKED / -OPEN | all five levers (`LeverKit`): two cards, the open one swaps in at the bottom of a squash-and-settle tween; the plain enamel badge is tinted per Path (a per-colour copy of the art; Crosspath's old lever is brass). The two states are trimmed differently, so each has its own height and a small shift that keeps the plinth in place | `b13_lever_crosspath.jpg`, `_pulled.jpg`, `b13_lever_gainlands.jpg`, `b13_lever_dump.jpg` | about half the hero's height, as the row asked | 2 x 150 KB | 0.3 MB |
| ICON-EQ-MATCHING-PAIR | Character page, gear shop tooltip, quest reward (all through `IconArt.EQUIPMENT_IDS`) | `b13_character_gear.jpg`, `crop_gear.jpg` | 256 px master + 6 crisp sizes | 134 KB | 0.4 MB |
| MG-BG-CLASSROOM | every zone's quiz: scaled to the screen's width and anchored at the top so the question is chalked on the painted board (`QuizScreen.PAINTED_BOARD_RECT`); the quiz-giver's portrait stands in the open left third; the coded room stand-in is deleted | `b13_quiz_gainlands.jpg`, `b13_quiz_dna.jpg` | the board area holds the longest questions | 317 KB | 6.0 MB |
| MG-BG-GYM | the Rep Counter's backdrop; the bar sits on the painted platform, the intro text got a dark plate | `b13_repcounter.jpg` | full screen | 279 KB | 6.0 MB |
| NPC-DEX | Dex's portrait (`CardMatchCircuit.portrait_id` swaps by itself) | `b13_portrait_NPC-DEX.jpg` | the standard portrait canvas | 110 KB | 1.5 MB |
| SPR-DEX (FRONT/SIDE/BACK idle, FRONT_TALK; REF filed only) | Dex at his table in every Path zone | `b13_dex_gainlands.jpg`, `b13_dex_dump.jpg`, `dex_frames.jpg` | the standard 440 px figure: about the hero's height | 139 KB | 2.1 MB |

**Size and memory against `docs/build_size_policy.md`:** the import adds **6.7 MB to the pack** (v0.5.2 was 700 MB against the 750 MB warning)
and at most about 6-12 MB of texture memory on any one screen (the quiz or the gym backdrop is the biggest single picture, as a lossy
full-screen painting, like the stills). One fix against the policy's "1.0-1.3x the largest on-screen size" rule: the statues and levers
arrived at about 1000 px but draw at 60-150 px, so a new import rule caps them at 384 px (BC7) - 4.1 MB of pack became 0.8 MB.

**Note for the art list:** Dex arrived as a ferret cardsharp (bowler, cards in the band, green waistcoat, spats); the row described a wiry man.
The portrait and the sprites match each other, so they are in as approved.

## Part 2 - Quick wins

| Item | Fix |
|---|---|
| Forest station "???" (C5 F10) | Reproduced in the code: after Primm the forest's station only opens when Rip in Crosspath gives his tip; until then the Crease's list showed it as "???" with "walk into that town yourself", which walking never answers. The row is left off the list until it is open (`FastTravelScreen.shown_station_ids`). |
| The Dump's haze (C2b F11, C3 F13) | The zone style was the real source: the lavender shadow tint, the height fog, warmth and vignette (and their stronger values toward the Rotheart) cut by a third, plus the look's fog, bloom, tilt-shift blur (7/6 -> 4.7/4.0 px) and haze cards. Before/after: `p2_dump_haze_before.jpg` / `_after.jpg` (edge detail +14 %, contrast +5 %). |
| Quest log hint under the quill (C7 F11) | a 230 px gap at the right of the tab row; the hint is a little larger and darker |
| Tips overflow and cover content (C1b F11, C7 F12, C3 F6) | a tip re-fits on screen whenever its text grows (the last line spilled below the frame); a click anywhere outside it folds it into a small "Tip: ..." pill (click to read again); battle coach tips step aside while a confirm is open (one already up stayed over "End your turn?") |
| Wrong name tag (C2b F5) | Old Hob's zone cameo used the key "hob", which is the Dump's Granny Gristle's legacy id: his record replaced hers (the tag and the NPC). His key is `old_hob` now. `p2_dump_gristle_tag.jpg` |
| Zone banner (C2b F10, C3 F14) | it already waited for a quiet moment and skipped after a defeat (Nov 7); now it also fades at once if a conversation opens while it is up |
| Sticky tooltip (C4b F12) | a card played from under the cursor drops its hover box and stays quiet until the cursor leaves it |
| "Rules of this fight" twice (C2 F14, C4c F9) | already fixed on Nov 7 (a second call replaces the row); unchanged |
| Round label lag (C4c F11) | the turn ribbon read the live turn (ahead of the playback); it reads the event's turn, like the HUD label |
| ENEMY TURN over the action line (C4b F11) | the HUD drew a second, band-less "ENEMY TURN" over the board's ribbon - removed; the opponent's action line waits for the ribbon to clear |
| (found on the way) Character page | the "Equipment unlocks with the quest ..." pill was clipped at the right; it wraps onto two lines |

## Part 3 - Capital later-visit load

`bash tools/run_loading_timing.sh` (windowed, the real SceneManager), Capital only, before and after; the build cache re-baked after the last
world edit (`bash tools/build_cache.sh bake`, hash 2263c04e70673c9e):

| Transition | Before | **After** |
|---|---:|---:|
| town -> Capital, first visit (baked cache) | 9,874 ms | **8,239 ms** |
| town -> Capital, later visit | 7,174 ms | **5,923 ms** |
| dungeon map -> Capital (retreat) | 7,355 ms | **6,098 ms** |
| the Capital's builder alone, later visit | 4,214 ms | **2,970 ms** |
| Capital -> town, later visit | 5,566 ms | 5,811 ms (unchanged; noise) |

What changed:
- `BuildCache.fetch_node(key, build)` stores a finished static subtree as a packed scene and gives back a fresh copy on later visits. Used for
  the **skyline** (614 ms -> under 60) and the **wall dressing** (392 ms -> under 60). Both merge into their own batches before they are
  stored, so the copies draw exactly as the live build (no extra draw calls).
- The great wall's pieces (236 ms) and the ruined houses (about 150 ms) cache their geometry like the townhouses (`KitMesh.fill_cached_set`),
  so materials stay shared and the end-of-build merge still batches them.
- **Not done, and why:** the props (0.6 s), the landmarks (0.44 s) and the district buildings (stalls, crypts, sheds, the Reek: about
  0.65 s) keep live references (lights, spinners, ghosts, story states) or many different builders; caching them as stored subtrees would
  give them their own copies of every material and break the merge's batching (more draw calls). Their next step is a geometry cache in
  each district builder, like the wall pieces. Coming back to Crosspath (5.8 s) is the town's own look rig and painted ground.

## Part 4 - Fresh-eyes critic

One fresh critic with no project context (brief `docs/review/critic_nov8c/briefs/N8.md`, played from the `C:\Dev\wp_critic` worktree at
this pass's commit; report `docs/review/critic_nov8c/N8.md`, 36 screenshots in `docs/review/critic_nov8c/N8/`). About 80 minutes. It picked
Gourmand. It lost the tutorial cave once to the Hollow Stalker; that resets the cave and puts you back at the bedroll. Driver timing then
broke two more attempts, so it used its one allowed `dev travel town` (its town read starts at L1 with 120 gold). No `SCRIPT ERROR` in any run.

**First hour:** fun 5, clarity 5, difficulty 5 (too punishing for a tutorial), text 7, look 6.
**Both parts:** fun 6, clarity 5, difficulty 6, text 7, look 7.

**New art check (its words, shortened):**

| Place | Verdict |
|---|---|
| Shattered Gallery map + boss board | fits - "the best art in the game" |
| Trivia classroom | fits - "lovely"; but no visible right/wrong reveal, and the reaction bubble is faint |
| Dex's matching game | **out of place** - plain "?" rectangles on a gradient (the game screen itself has no painted table or card back) |
| Wardrobe | fits; the cloak tile is red while the hero wears teal |
| Card Packs | fits; the shelf scrolls sideways with no cue past 7 packs; revealed cards small |
| Alembic's cauldron | fits; the essence bars don't fill, the brew panel is empty |
| Thorn wall | **out of place** - reads as autumn trees; it "never opened" after `dev gate` (see below); a grey slab behind it |
| Fountain statues | **out of place** - too small and dark; the fountain itself reads untextured |
| Old lever | not found in time |

**Its top 10 (worst first) and what happened to each:**

| # | Issue | Done tonight |
|---|---|---|
| 1 | "Settle in: talk to Elder Maren on the square" - she is not on the square, and the early town map / "Where to?" list doesn't show her | **fixed the text** ("at her home, north of the square"); the map listing is logged |
| 2 | The cave resets on one loss and sends you to the bedroll with no pointer back | logged (design: the cave is all-or-nothing) |
| 3 | The opening forest is too dark; the hero vanishes behind foliage; a black slab over the cave arch | logged |
| 4 | Quiz: no visible reveal; the obvious answer (mills / hamster wheels) marked wrong | **fixed two causes:** the reveal and the teacher's bubble hold 1.6 s (was 1.0 / 1.1); the old answer buttons left the grid only at the end of the frame, so a click in that frame scored the old answer against the new question (now removed at once). The data does mark the mills correct; the critic most likely clicked a position from an earlier screenshot after the answers reshuffled |
| 5 | The thorn wall doesn't read as thorns and didn't change after the gate | **fixed the "didn't change":** `dev gate` (the critic's shortcut) set the flag without touching the town already built; it plays the withering live now. The real fight always did, and the withered/parted state shows on every load after (`b13_thornwall_withered.jpg`). The art's look is logged |
| 6 | Dex's matching game looks like placeholder UI | logged (needs a painted table/card back: an art row) |
| 7 | The fountain looks untextured; the statues can't be read | **statues 1.15 -> 1.35 m and brighter** (`n8_plinths_after.jpg`); the fountain is logged |
| 8 | Foreground roofs fill a third of the town camera | logged |
| 9 | Battle: tiny played infrastructure above the hand; 12-card hand in two rows; orbs over the rules caption | logged |
| 10 | Overflow: the Character pill, Professor Pump's long line, the Packs shelf, names over barks | **Character pill fixed** (it was sized before wrapping: now two explicit lines, `n8_character_pill.jpg`); the rest logged |


## Tests

The final full run (`bash tools/run_tests.sh --only=tests --size=12`) was stopped by Claude Code during shard 25 of 30 because the PC was
critically low on memory; per its rule it was not restarted. Shards 1-24 passed (2,454 of 2,456 tests: one risky, one failing), with one failure
caused by tonight's two-line Character pill (`test_overnight_oct31n_ux`); the test was updated and passes on its own. Shards 25-30
(`tests/world`, from `test_wardrobe_redesign` on) last passed in Part 0, and every file changed afterwards was run on its own (the build-cache,
Capital, heap, quiz, travel, title-card, tip and battle-HUD tests all green). To finish: `bash tools/run_tests.sh --only=tests --size=12 --from=25`.

## Open questions (inbox "Import Nov 8")

1. **Dex is a ferret** in the approved Batch 13 art (the row described a man). Kept: portrait and sprites match each other. Update the art list
   description, or ask for a redo?
2. **NPC-PLAYER** is still the opaque picture; held back again (the importer re-adds it on every portrait import - it is reverted each time).
3. **"Low camera" for the statues** was read as the Low graphics preset (`b13_plinths_low.jpg`). If it meant a camera angle, say which.
4. **Tips now fold into a small "Tip: ..." pill** on any click outside them (so they never sit over a screen in use). Keep, or prefer them to
   close for good?
5. **The Capital's remaining load:** props, landmarks and the district buildings (about 1.7 s) need a geometry cache in each district builder.
   Worth a dedicated pass?
6. **Critic N8's logged items** (above, top 10 #2, 3, 6, 8, 9 and the rest of 10, plus findings 12-18): pick the next fix list.
7. **Dex's matching game screen** needs art (a painted table and a card back, like the quiz's classroom). Add rows to the art list?

# Fix pass Nov 8 - report

Brief: `docs/prompts/fixes_nov8.md` (owner decisions on the Nov 7-8 overnight, plus its leftovers). Tag `pre-fixes-nov8` marks the start.
Questions: `docs/overnight_inbox.md`, "Fixes Nov 8". Screenshots: `docs/overnight_shots/nov8b/`. Sims: `docs/design/sim/nov8/`. No export.

| Part | What | State |
|---|---|---|
| 0.1 | Full test shards, failures fixed | done (19 failures fixed: a Settings compile error from Nov 7-8 broke 8; the rest were stale expectations) |
| 0.2 | Primm Measurement 2 (no-grind decks) | done: 94 / 89 / 72 % by phase, same as the reference decks |
| 1.1 | Gatekeepers fightable at any time | done |
| 1.2 | Dex's Matching Pair (rename, ICON-EQ-MATCHING-PAIR) | done |
| 1.3 | Difficulty: no changes; Gallery Echo HP restored | done |
| 1.4 | Primm: plain phase lines, Deck Station advice | done |
| 1.5 | Economy back to ~21.2k; 3x every card + every craft | done: 21,332; finishing everything about 57 % extra play |
| 1.6 | Dex's own art (rows + wiring) | done |
| 2.1 | Capital load time | done: cold 12.1 -> 9.5 s |
| 2.2 | Dump first load, shader hitches | done: cold 11.9 -> 5.9 s |
| 2.3 | Gainlands cliff holes (Low / Low-end) | done |
| 2.4 | Wardrobe / Card Packs after-shots | done |
| 2.5 | Nov 7 quick wins | partly (below) |
| Finish | shards green, report | report done; the final full run was stopped at shard 9 of 30 by Claude Code for low memory (see below) |

**The final test run was cut short.** The first full run of the night (2850 tests) found 19 failures, all fixed and re-checked in targeted
runs. The final full run after Parts 1-2 was stopped by Claude Code at shard 9 of 30 because the PC was critically low on memory (it was not
restarted, per its rule): shards 1-8 passed apart from two NPC-DEX art checks, now fixed (Dex's portrait is on order, like Quota's). Every
file changed in Parts 1-2 had its tests run on its own; shards 9-30 still need one full pass: `bash tools/run_tests.sh --only=tests --size=12 --from=9`.

## Part 0

**Shards.** The first full run since the overnight: 2829 / 2850, 19 failing. A `show_toast` call with two arguments in the Low-end toast
(Settings panel) failed to compile and took eight Settings, controller and pad tests with it; the rest expected the old values of the Nov 7-8
changes (Snack Bar +2/+0, the Honor Guard's Militia, the Echo owners, the Lucky Spats) or Dex's missing NPC entry. One test read
`battle_screen.gd` with `\n` while git's autocrlf checks files out with CRLF; it now normalises line endings.

**Primm, Measurement 2** (`docs/balance/primm_explained.md`): the no-grind decks (`--budget`: at most 4 Epics and 1 Legendary) score **94 / 89 / 72 %**
by phase, the reference decks 94 / 89 / 73 %. What the player owns barely matters to Primm; how the deck is built and the HP carried between
phases do - which is what the plain rule lines and the Deck Station advice address.

## Part 1 - Owner decisions

1. **Gatekeepers** can be fought at once, at any time (the "come back when Maren sends you" block is gone). The player isn't pointed at them
   before Maren's errands are done: no quest, no YOUR PATH line naming them, no map pin on the Path's road. A gatekeeper beaten early shows
   its step as done when Maren gives the line, and her send-off still comes. Test: `tests/core/quests/test_fixes_nov8_gatekeepers.gd`.
2. **Dex's Matching Pair** (was Dex's Lucky Spats): data, quest reward, rarities, icon id **ICON-EQ-MATCHING-PAIR** in the art list and the
   icon importer's known ids (`IconArt.EQUIPMENT_IDS`; the boots slot icon stands in until it is imported). Wording unchanged.
3. **Difficulty:** Clench (1 Iron) and the Automaton (one extra fewer) were on the approved list and stay. The Gallery got both "Perfect Form
   off the normals" and "Echo HP -20 %" last night where "or" was approved, so the **Echo HP cut is reverted**. Current win rates (sims):
   Clench 67 / 50 / 25 / 33 % (B / N / G / R), the Automaton 33 / 33 / 17 / 17 %, the Gallery full run 0 / 10 / 0 / 20 % (B / N / G / R; 7.5 %),
   Primm as in Part 0.
4. **Primm:** phase 1 now says "Every unit is a 3/3, so cheap units are as good as big ones. You may play two cards a turn."; phase 2 "He plays
   a copy of your own deck and draws two extra cards a turn, so expect your best cards to come back at you." (it said one extra card, the code
   draws two); phase 3 "His units get +1/+1 and he draws an extra card, but he loses 1 HP every turn, so hold the line and he runs out of time."
   When the castle is next, the Deck Station shows "Primm deck" advice with the deck's count of units costing 2 or less. No number changes.
5. **Economy:** see the table below.
6. **Dex** is `NPC-DEX` in the NPC registry. Rows for NPC-DEX and SPR-DEX (REF, FRONT_IDLE, SIDE_IDLE, BACK_IDLE, FRONT_TALK) are in the art list
   ("Needed — Batch 13"). Until they are imported, the townsfolk portrait and the CITIZEN sprite stand in; `CardMatchCircuit.portrait_id()` /
   `sprite_key()` switch to his own art by themselves once it exists.

### The gold study (Part 1.5)

| | Nov 7-8 | **Nov 8** |
|---|---:|---:|
| Gold earned, no grinding | 11,314 | **21,332** |
| Left after the shopping list (38 cards, 6 gear, 20 item charges, 3 hats, 4 packs) | 1,514 | **11,532** |
| Three copies of every single-Path and Colorless card (534 copies), shelf prices | - | 56,400 |
| Copies a no-grind run gets free (starter, 33 picks, 41 packs) | - | about 181 (about 14,300 worth) |
| All 136 multi-Path crafts (102 dual, 34 tri): gold + essence bought as packs | - | 6,800 + 7,757 |
| **Finishing everything** | - | **about 56,600 gold** |
| A no-grind run covers | - | about 20 % |
| **Extra grinding to finish** | - | **about 140 late fights = 9.4 h = 57 % on top of a 16.5 h run** |

What changed: the Nov 4-5 income knobs are back (quests, the clear bonus, dungeon nodes, roamers, first clears), with chests at 60 % and late
level-track gold at 85 % so the kept late-fight raise lands near 21.2k. Grinding (never part of a no-grind run): a roamer beaten before at level
18+ pays **x4** (the Capital's 100 -> 400), a replayed side dungeon 200 (was 40), a main one 300 (was 100). **Crafting was the bottleneck** (a
duplicate lottery at 6 essence per Path): a brew now costs **2 essence of each Path and 40 gold** (tri 80), a Path holds up to 60 essence, and the
cauldron brews the cards you don't own yet first. With the old crafting the same goal took 236 % extra play. The intro checkpoint still holds
(about 850 gold after the armory quest, against 590). Full write-up: `docs/balance/gold_economy_nov3.md`, "Fixes Nov 8".

## Part 2 - Leftovers

### Load times (Parts 2.1, 2.2)

Measured with `bash tools/run_loading_timing.sh` (windowed, the real SceneManager), before and after:

| Transition | Before | **After** | What moved |
|---|---:|---:|---|
| town -> Capital (cold) | 12,104 ms | **9,478 ms** | the baked build cache (houses, rim, skyline, splat) |
| town -> Capital (warm) | 7,268 ms | **7,028 ms** | the builder's uncached code (about 4.1 s) remains |
| town -> Dump (cold) | 11,941 ms | **5,889 ms** | the splat bake (was 5.0 s of "painted: base material") |
| town -> Dump (warm) | 4,710 ms | **4,628 ms** | the lighter mask fingerprint |

- **Why cold was slow:** the zone builders' expensive results (splat images, ground overlays, townhouse and tower geometry) come from
  `BuildCache`, keyed by a hash of every world script; the baked copy in `res://build_cache/` was from Nov 3, so every cold load rebuilt them.
  It is re-baked (`bash tools/build_cache.sh bake`, manifest 32e001df8264cecc) - an export bakes again anyway.
- The painted splat's cache key re-evaluated the zone's masks on a 16 x 16 grid every visit (about 0.9 s in the Dump); 8 x 8 now.
- Materials prewarm behind the cover: the transition already draws 7 frames behind the loading screen before the fade-in (the worst of them
  is the first shader compile, 300-570 ms, hidden); loads that take over 2 s with no loading screen show the "Loading..." card.
- **Not done:** caching the Capital's non-house buildings (1.2 s a visit), skyline (0.6 s) and props (0.6 s) - the next step for the warm load.

### The Gainlands cliffs (Part 2.3)

At Low and Low-end (no sun shadow) the faceted cliff walls were lit facet by facet, and the faces turned from the sun read as black triangles
(`p2_cliffs_lowend_before.png`; Medium for comparison: `p2_cliffs_medium.png`). Without a sun shadow the cliff faces now get smooth normals
(their own smooth group, so the plateau tops stay faceted), the ambient fills a little more and the sun eases a little
(`p2_cliffs_lowend_after.png`). The land and cliff meshes are also never range-culled. New play command: `dev lowend on|low|off`.

### Screenshots (Part 2.4)

Wardrobe `p2_wardrobe_before.png` -> `p2_wardrobe_after.png`; Card Packs `p2_packs_before.png` -> `p2_packs_after.png` and
`p2_packs_after_opened.png` (LAST OPENED filled). The shelf's board sat on the pack names; it is under the art now and hidden on an empty shelf.

### Nov 7 quick wins (Part 2.5)

Done: the gear shop's tip counts the grayed-out pieces of that shelf (it said "the 5" everywhere); Alembic's brew screen no longer flips its
own toggle (the "eaten" first click) and keeps space for the odds grid (nothing jumps under the cursor); the balance sim's `--resume`. Already
in: Curb Alert opens the Refuse Pile picker by itself. Not done: the Dump's haze, the quest log hint under the quill, tip boxes overflowing,
the name tag over the wrong NPC, the round label / ENEMY TURN banner / sticky tooltip, the forest station "???" in the Crease's list (not a
literal in the code: it needs a repro), the fountain plinth statues (art row DEC-PLINTH-EMBLEMS).

## Open questions (inbox "Fixes Nov 8")

1. Finishing everything is about **57 % extra play**: nearer 30-40 % would need late repeats x5-x6, cheaper third copies of Epics and
   Legendaries, or a pack per late repeat win.
2. The Gallery is back to 7.5 % (0 / 10 / 0 / 20 %); the approved changes alone kept it hard, as the owner wants.

# Overnight Nov 7-8 - report

Brief: `docs/prompts/overnight_nov7.md` (Parts 0-9 + Finish, in priority order). Tag `pre-overnight-nov7` marks the start. State:
`docs/loop_state.md`. Decisions and questions: `docs/overnight_inbox.md`, "Overnight Nov 7-8". Screenshots: `docs/overnight_shots/nov8/`.
Sims: `docs/design/sim/nov8/`. No export.

**The night ended early on memory.** Late in the run Claude Code stopped a background Primm sim because the PC was critically low on memory.
Its rule is not to restart a job stopped that way, so the remaining heavy Godot work was not run: the full GUT shards, the fresh critic,
the Primm measurements 2 and 3, and the Part 7 load profiling. Everything changed tonight was covered by targeted GUT runs as it was made
(listed per part); the full suite still needs a run: `bash tools/run_tests.sh --only=tests --size=12`.

| Part | What | State |
|---|---|---|
| 0 | Leftovers (fixes_nov7 "not done" + the fresh critic's majors) | done |
| 1 | Playtest bugs and quick changes (11 items) | done |
| 2 | Economy: Commons 50, gear from 250, a friendlier run | done |
| 3 | Story finale and fixes (revertible dialogue pass) | done |
| 4 | Balance retune with the owner's decisions | done; two bosses still under band (below) |
| 5 | UI redesigns: Wardrobe, Card Packs | done (no after-shots: memory) |
| 6 | Minigames: trivia classroom, flourishes, the Cardsharp's Circuit | done |
| 7 | Load times and Low-end | partly: slow-load card, Low-end cuts, preset rows; profiling, baking, Dump load and Gainlands cliff holes not done |
| 8 | Primm measurement and write-up (no changes) | partly: measurement 1 and the write-up; 2 and 3 not run (memory) |
| 9 | Art list | done |
| Finish | shards, critic, report | report only (memory) |

## Part 0 - Leftovers

- **The cave ran backwards** (critic CF #3): the fights now go 3 -> 5 -> 9 HP (the Stalker was 7, the Warden 3). The whole cave clears
  94 / 98 / 100 / 100 % (B / G / R / N, 48 runs each; `p0_cave.md`).
- **A capped reward pick** joined the deck AND paid essence; now it only converts, and the card says "AT CAP: becomes essence" before you pick.
- **Shop purchases** say they go to the collection and point to the Deck Station (B), in the buy box and the toast.
- **Chef Fennel** stands on the open apron in front of the pantry door, out of the orchard trees (`p0_fennel_on_apron.png`).
- Battle error toasts clear on the next phase; the Menu button shows "N unopened packs".
- Not done from the old list: the rest of the Nov 7 quick wins (inbox Fixes Nov 7, item 12).

## Part 1 - Playtest bugs

1. **Peek** is a true modal on its own layer above everything (the table dimmed), tested with a full board (`p1_peek_full_board.png`, before: `p1_peek_before.png`).
2. **Gatekeeper quests** start only when Maren sends you out after the whole Settling In line (armory included). She names your own Path's
   zone as "the easiest road for you", gives all four, and your Path's is tracked. Before that, the YOUR PATH tracker line shows the next
   intro step ("Settle in: ...", then "Report back to Elder Maren"). Gatekeepers met early give a friendly "come back when Maren sends you"
   line (one per gatekeeper, in voice) and cannot be fought. Old saves that already had a gatekeeper line keep it.
3. **Maren's send-off** is rewritten for that moment (no shopping talk, no first-meeting tone); her cave-mouth lines now say "settle in first".
4. **1987** is gone from both of Maren's lines.
5. **Store room ghosts** are darker: Tilly's great-grandmother's "remedies", chalk under the floorboards, a lantern that showed the wrong
   thing, a ledger to burn unread; Maren won't talk about it on the square. Quest steps and ids unchanged.
6. **Capital debuffs tutorial** on the first entry (once per save), pointing at the panel in the upper left, listing each active debuff and
   saying freeing its zone lifts it; also in the Glossary's Zones tab (`p1_capital_debuff_tutorial.png`).
7. "(full heal)" is gone from every exit's travel text (the heal itself stays).
8. **Brannoch** stands well back on the imperial road; his talk area can never overlap the Capital trigger (a test checks the distance).
9. **Swolympus gate:** the land ran on past the west tower. A sandstone crag (two tiers, solid) now fills it to the rim; a flood-fill test
   proves nothing behind the shut gate is reachable from any side; the chest that stood in that strip moved out front (`p1_swolympus_gate_crag.png`).
10. **Pip** is drawn at x1.5 with her collider and talk area to match.
11. **Opened packs:** hovering (or keyboard / pad focus on) a result card shows it whole, like the Deck Station (`p1_packs_hover_zoom.png`).

## Part 2 - Economy

**Prices, before -> after.** Cards 100 / 200 / 500 / 1000 -> **50 / 100 / 250 / 500**. Equipment Common 1200-1800 -> **250-400**, Uncommon
2000-3200 -> **400-700**, Epic 3500-5500 -> **750-1150**. Packs: General 150 -> 100, Path 200 -> 150, Gilded 800 -> 400, General II 300 -> 175,
Prismatic 1200 -> 350 (every pack still well under its cards' shelf value; a test checks it).

**Income.** With prices this low, the old income (21,159 gold, no grinding) bought most of the collection without one repeat fight, so the big
earners came down (quest scales, chests, dungeon nodes, the clear bonus, first clears, level-track gold from level 6, roamers): **11,314 gold**
no-grind. Fights at expected level 18+ pay more, scaled by level (the Capital's roamers 50 -> 75, castle x1.6, the Lab x2.2, the Gallery x2.35).

| The no-grind player (`tools/gold_study_nov8.gd`) | |
|---|---:|
| Gold earned | 11,314 |
| 38 cards (19 / 11 / 6 / 2) + 6 gear + 20 item charges + 3 hats + 4 packs | 9,800 |
| Left over | ~1,500 (a dozen more cards, or two more pieces) |
| Collecting every card: extra grinding | about 5.5 h = **about 33 %** of a 16.6 h playthrough (estimate) |

**Checkpoint (2.3):** at the end of the armory quest a no-grind player has about 700 gold against the 590 the brief asks (a 250 piece, four
Commons, two Healing Salves); a test keeps it between the target and the target + 400. Full tables: `docs/balance/gold_economy_nov3.md`,
"Overnight Nov 7-8".

**The Extra Pocket check (2.6):** nothing else in the game allowed a second use of an item in a battle (items were tracked once per battle in
`GameState.items_used`; no modifier, card or item touched it). So the Extra Pocket is now **"You can use each equipped item twice per battle
(each use spends a charge)"** (`Modifier.Kind.ITEM_USES_PER_BATTLE`), with tests.

## Part 3 - Story finale

58 line rewrites through `apply_dialogue_pass.js` (revertible: `--csv=docs/dialogue/pass_nov8/edit_rows.csv --revert`) and three new boxes
(`docs/dialogue/pass_nov8/additions.md`). Review CSV: `docs/dialogue/edit_nov8.csv`.
- The Wanderer's own climax line: "You took my mother and father. Then you kept me behind glass for ten years, and every morning someone said
  'again'." Primm answers in his own register ("I removed two people so that eleven thousand could be safe. I did the sums twice. ... you were
  never once cold. Tell me which part of that was unkind."). No forgiveness: "not today". He reacts to Memory 4 before he absolves Maren.
- The castle **opens** (every locked door swings open). Elowen's absence is noticed: she is in the Path-ology Lab under the forest, and Maren
  sends him to fetch her - the hook into "Under the Forest" (the Lab stays postgame).
- Fixed: Maren's "first" to say the name, "I asked her twice, and both times she said 'a friend'", two prince hints cut and reactions to the
  rest, Primm's confession about credit and consent, Gerald, "the day she sent you through my cave", Kestrel's loop, Bramble's compost line, the
  Tuesday rule planted with Kyle filing, beat 6 cut to one image.
- Lieutenants: **Crumb** keeps the menial job, **Quota is arrested**, **Clipwell refuses** and walks off.
- Story and zone-lesson tests: 640 of 643 passed in the story set; the 2 failures were castle-map tests, updated for Part 4.

## Part 4 - Balance (before -> after, per Path B / N / G / R)

| Change | Before (C8) | After (tonight, 12 games) |
|---|---|---|
| Clench starts with 1 Iron | Gourmand wall | 67 / 50 / **25** / 33 % (Gourmand still under the 40-60 band) |
| Honor Guard: no starting Militia | Necrocrat 30 % | 92 / **75** / 58 / 92 % |
| Betty's Surly +2/+1 | 8 / 30 / 63 / 67 % | 17 / 50 / 75 / 75 % |
| The Automaton: one extra fewer | 42 / 30 / 13 / 17 % | 33 / 33 / 17 / 17 % (no real change: HP 23 -> 19 is the next lever) |
| Siphon without Elowen drops Containment | B 17 %, others 50-63 % | 50 / 83 / 83 / 83 % |
| Snack Bar (B) "Pay 1: +2/+0"; B-24 2/4 | dead cards | in game; not re-simmed on their own |
| ZoneOrderEase: floor 0.65, ease -1 / -1 / -2, Buffet ~0.8 | Dump 0.36, Buffet 0.72 | in game; the early study (now with the Necrocrat) was not re-run (memory) |
| Castle main line | 10 rooms | **6 rooms** (gate, courtyard, Hall of Mirrors, safe room, Archive, Model Room) + side rooms; L18+ Normal fights offer a card pick |
| Shattered Gallery full run | 1 clear in 40 (2.5 %), dropped Echo cards | Echo owners fixed, Perfect Form from node 11 only, node 10 Elite, Echo HP -20 %: **0 / 40 / 10 / 30 % = 20 %** (target 15-25 %) |

Gatekeepers got no new rule; Primm unchanged.

## Part 5 - UI

- **Wardrobe:** a framed hero stage on the left (the turning preview), HATS and CLOAKS as grids of painted tiles (worn: gold frame and tick;
  not owned: dimmed with a padlock and "Pip sells it"), a detail line under each, the dyes at the bottom. **Dyes do only apply to the Plain
  Cloak in code** (`SpriteCosmetics.dye_applies`), so the whole dye section greys out with "Dyes work on the Plain Cloak" under another cloak.
  Background: the Character page's room until UI-BG-WARDROBE arrives.
- **Card Packs:** plan `docs/ui/card_packs_redesign.md`; built: THE SHELF (each pack's art large on a wooden board, count badge, contents line,
  Open), the Open all bar, LAST OPENED (the latest cards with the hover zoom).
- Before shots: `docs/ui/ref/nov8/wardrobe_current.png`; the after-shots were not taken (memory).

## Part 6 - Minigames

- **Trivia classroom:** a coded wood-and-chalkboard room (MG-BG-CLASSROOM on the art list), the question chalked on the board, the zone's
  quiz-giver as the teacher with a speech bubble, answers that flash green/red with the right one lit, a streak counter, sparkles. Each zone
  now has its own quiz name (the D.N.A.'s showed everywhere).
- **Every other minigame:** `docs/design/minigame_graphics_plan.md`; tonight's code-only flourishes (`MinigameFx`: sparks on a score, shake on a
  miss, flash and confetti at the end) are hooked into all eight screens.
- **The Cardsharp's Circuit:** Dex Shufflewick (the generic townsfolk sprite and portrait) keeps a table beside each Path zone's trivia
  corner, dealt from that Path's own card art; one quest: beat his score (12 moves) in all four, then the final table (two cards of every
  Path, 11 moves). The slot with the fewest pieces was **Boots** (6; Helm 9, Armor 11, Weapon 15, Relic 19).
- **Prize - Dex's Lucky Spats (Epic boots). Wording for your approval:** *"Once each turn, when you play your first non-Infrastructure card,
  draw a copy of that card from your deck (if there is one)."* Rules tested: first non-Infrastructure card only, copy from the draw pile,
  nothing if there is none. **Not balance-simmed** (memory).

## Part 7 - Load times and Low-end

- A transition without a loading screen that is still building after 2 s shows a small "Loading..." card.
- **Low-end** is a real cut now: mip bias 1.0 (textures a level smaller), foliage 12 %, particles 10 %, draw distance x0.5, one dressing light;
  picking the preset also sets fog off, no DoF or bloom, 30 fps and a 75 % render scale, and the Settings page redraws with the new values.
  The Compatibility renderer is offered through the existing "Start (Compatibility).bat" (a Settings note and a toast); Godot can't switch
  renderers at run time.
- **Not done:** the Capital load profile (before/after numbers), baking painted swaps at import, material prewarm, the Dump's 15-17 s first
  load, first-visit shader hitches, and the Gainlands cliff holes. The profiler is `bash tools/run_loading_timing.sh <run> final,refusemancer`.

## Part 8 - Primm

`docs/balance/primm_explained.md`: measurement 1 (reference decks: 94 / 90 / 71 % by phase), why sims and play disagree, what makes him hard or
easy, three options and a recommendation (teach phase 1 first; heal between phases if needed; leave his numbers). Measurement 2 (`--budget`,
added tonight) and the hand-played critic were not run (memory). Nothing about Primm changed.

## Part 9 - Art list

`docs/art/art_needed_nov4.csv`, "Needed — next batch": LEVER-LOCKED and LEVER-OPEN (the four vault levers and Crosspath's old lever, ~0.9 m in
the world, 70-90 px on screen), ICON-EQ-LUCKY-SPATS, MG-BG-CLASSROOM, MG-BG-GYM, UI-BG-WARDROBE, UI-PACK-SHELF; UI-BG-PACKS re-described for the
new page. The five earlier rows are kept. The Cardsharp needs no NPC art.

## Open questions (details in the inbox)

1. Approve the Lucky Spats wording (Part 6).
2. Clench vs the Gourmand (25 %) and the Automaton (17-33 %) are still under band: next levers are Clench's HP -15 % and the Automaton's HP 23 -> 19.
3. Beefcake clears the Gallery 0 / 10: its late-game weakness (C8 finding 3) needs its own pass.
4. Primm: pick an option in `primm_explained.md` once measurement 2 has run.
5. To finish the night's work: the full GUT shards, the fresh-eyes critic (intro to the first gatekeeper quest, then the Capital), the
   early study and Part 7's profiling.

# Fix pass Nov 7 - report

Brief: `docs/prompts/fixes_nov7.md` (critic top 15, part 1, with owner decisions D1-D8). Source: `docs/review/critic_nov6_summary.md`.
State: `docs/loop_state.md`. Questions and choices made: `docs/overnight_inbox.md`, "Fixes Nov 7". Screenshots: `docs/overnight_shots/nov7/`.
Tag `pre-fixes-nov7` marks the start. No export.

## Part 1 - First hour (items 1, 4, 5; D3, D6)

- **Your Path (item 1, D3).** Picking the Path starts that zone's main line (its gatekeeper) at once and tracks it; the tracker keeps a
  standing **YOUR PATH** line ("Face Brick Bronson on the Gainlands road") while anything else is tracked; the map and minimap ring that
  road's exit and gatekeeper in the Path's colour; Maren names the zone, gatekeeper and road at the cave mouth and again in her Path talk
  (no longer waiting for the armory); E at a sealed portal prefers the guardian standing in front of it.
- **Settling In (D3).** Maren's four errands are a side line tagged SETTLING IN; they never take the tracker from a main quest; the other
  zone lines, Fragments and Brannoch's quest open on the first arrival in Crosspath. Every gatekeeper can be fought at any point.
- **Opening hand (D6).** Every player opening hand holds at least two infrastructure (a hidden swap with the deck; after a mulligan too).
- **Early fights (item 4).** Wild Growth waits until round 3 in a main dungeon's first rooms; the cave's duel 2 has 7 HP and a Shield
  Bearer; the Warden's swarm is smaller; the Refusemancer starter swaps two Desperate Measures for a Watchtower Archer and Kidding Around.
- **Input traps (item 5).** Nothing is pre-chosen on the victory pick and E takes nothing until a card is chosen; the whole Path column is
  one click target with "Pick a Path first" beside a disabled Begin; quest banners wait while a dialogue is open and size to their text;
  the dungeon map tip sits low, clear of the title scroll, and states the D2 rule.

**Re-sims** (reports in `docs/design/sim/nov7/`, numbers in `docs/design/balance_log.md`):

| | Beefcake | Necrocrat | Gourmand | Refusemancer |
|---|---:|---:|---:|---:|
| Whole cave, before (C8) | 92 % | 92 % | 96 % | 79 % |
| **Whole cave, after** | **96 %** | **96 %** | **100 %** | **96 %** |
| Own gatekeeper (quick, L3; band 60-75 %) | Brick Bronson 92 % | Prudence Pallor 83 % | Chef Fennel 67 % | Moss Mulligan 92 % |
| Own first dungeon node, expected level | 83 % | 100 % | 100 % | 100 % |
| Own first node, bare starter at L5, no gear | 75 % | 50 % | 42 % | 83 % |
| Own first main dungeon, early study, L9 (60 runs) | 67 % | not run (time cap) | 87 % | 63 % |

The Refusemancer against Brick Bronson was 25 % in C8; now 67 %. Two own gatekeepers sit above their band (Brick Bronson and Moss
Mulligan for their own Paths, 92 %), which the gatekeeper rule twists of item 9 would address. Shots: `p1_path_choice_card_click.png`,
`p1_victory_no_default_pick.png`, `p1_cave_map_tip.png`, `p1_forest_path_quest.png`, `p1_town_path_tracked.png`.

## Part 2 - Walking and maps (items 2, 7, 14; D5, D7)

- **Walking.** The hero's body slides along whatever it meets (a tangent slide in the one mover every scene shares); Crosspath's prop
  colliders shrink to their footprints (lamps, signposts, benches, the notice board, dressed props x0.8); the fountain plinths moved out
  for a ~3 m clear ring; standing townsfolk keep only a 0.1 m core; a house between the camera and the tracked goal's door dissolves
  when the hero is within 11 m; door goal markers hang at the door. The camera yaw was already fixed (only a held swivel key turns it).
- **Reach walk smoke** (`bash tools/run_reach_walk_smoke.sh`, report `docs/review/nov7/reach_walk_smoke.md`): from the spawn to every
  shop and exit in Crosspath, the four zone hubs and the Capital, plus the postgame forest's Rift station to the Lab hatch, planned over
  each area's own walkability and walked with held keys: **38 of 38 reached** (the Dump's north landings with the vine bridges grown).
- **Compost Commons.** No invisible wall exists in the walkable map; the critic's stops were small round props met head-on by the old
  axis-only slide. The stream north is crossed by the grown vine bridges, as designed.
- **Maps (D5, item 7).** Towns stay fogged; shops, exits, quest givers and landmarks always show; walking reveals 16 m (was 9); roads are
  drawn, through the fog too; zones show their outline from the first arrival. Labels move round their icon and stay inside the frame.
  A "Where to?" pick leaves a labelled white arrow at the screen edge until you get there. Each zone hub has a roamer near its exit.
- **Endgame wayfinding (item 14).** A main quest's step always takes the tracker; exits say "Travel to the Capital" (sealed ones name
  their guardian); Free the Four Zones gains a Crease step with a pin; castle rooms show their type once a neighbour is cleared (the boss
  node is always the Model Room). **Postgame blocker fixed:** the Lab's path opened only after Rip's tip in Crosspath, so any other way
  into the forest met the old bramble collider; it now opens with the postgame, and the forest has the tracker, J and a goal pin. The
  Gallery has its own quest line and map / "Where to?" entry, and every Crease shaft names where it leads. Heals name their cause in the
  log and float "+2 HP (Nourish)".
- **The Capital (D7).** The nine citizens have their own names on their labels and over their lines (Gideon Plumb, Bea Ashgrove...);
  Dorrit's Last Stall stands on the castle approach; no side doors.

Shots: `p2_town_map_d5.png`, `p2_your_path_line.png`, `p2_forest_hatch_reached.png`.

## Part 3 - Menus and cards (items 3, 8, 12, 13; D4)

- **Deck Station.** Save Deck saves the deck's own slot at once (a toast says when it is not your battle deck); "Save as new slot" picks
  another; Esc with unsaved changes asks Save / Discard / Cancel; the list scrolls with the wheel over any row; every add shows "+1". The
  53-vs-51 count was the old save trap: the station showed the edited deck while battles used the last one actually saved.
- **Packs (D4).** Any click skips a single pack's animation; Open all shows the cards in a grid with NEW badges (new first) and says how
  many gilded packs it leaves; toasts are held over it. General Packs stay fully random; Sable stocks 6 Commons of the player's Path and
  5 of each other Path.
- **Cards.** Hand cards are compact (cost, name, art, stats) and the hovered one is shown whole; no left preview for hand cards; a drag
  starts on the raised card; above 10 cards the hand uses two rows; the legacy frame's rarity gem moved off the type line. Checked at
  1280x720 (`p3_hand_720p_compact.png`, `p3_hand_720p_hover.png`).
- **One Esc rule.** One press closes one thing: the first handler owns it and nothing else counts for 0.2 s; a confirm dialog answers Esc
  itself; Esc steps back out of the pause menu's pages; the dungeon Rules panel and the battle log close on Esc; every FancyButton shows
  the gold focus ring. The gamepad smoke now also checks that Esc closes the Quest Log, Character, map, Packs, Wardrobe and Deck Station
  screens (all pass; the smoke had been stale since the Nov 3-4 equip steps and was updated).

## Part 4 - Losing (D1, D2) and Primm's presentation (item 10)

- **D1.** Losing costs nothing anywhere: no fee (the six wake gags keep their joke, waived), no item loss, no Try again. A zone loss
  wakes you at the hub at full HP; Primm's at the Capital; a cave loss in the forest clearing with the cave starting over (the Nov 4-5
  retry in place is retired).
- **D2.** Leaving or losing restarts a dungeon, and every run pays every node again (it already did). The Retreat confirm and the map tip
  say "Leaving resets this dungeon. Cards and gold you've won are kept."
- **Primm (presentation only; his numbers are unchanged).** A big "Hand full: click a card to toss" prompt, with Space tossing the
  lowest-value cards; a "Phase 1 Broken" card instead of Victory; "PRIMM" on the plate and in the log; the fight plays on the Model Room
  board (BB-PC-BOSS, verified); the boss node always shows as the Model Room; Setting Up is worded in rounds with a countdown beside the
  round label; `dev primm 1|2|3` in the play driver is the checkpoint between phases; Mirrors never copies Infrastructure and announces
  what it copied. **"Every unit starts as a 3/3" was neither a rule nor a display bug:** the rule standardizes both sides' base stats and
  buffs add on top; the critic's 7/4s were 3/3 plus that save's gear and boons (GUT-tested through Primm's real seat). Two real display
  gaps found on the way (cards rebuilt by a mode change, and newly drawn cards, showed printed stats until their next refresh) are fixed.
  Shots: `p4_primm_model_room.png`, `p4_primm_phase_break.png`.

## Part 5 - Quick wins

Done: "Equipped N of M"; the equipment-unlock line names its quest, and the trophy now comes with the armory; Settings tab label, scroll
reset and themed dropdowns (and the map's "Where to?"); plurals; the dialogue hint says what E does now, a faster typewriter (Normal 80
letters a second), hold E to speed up, E ignored for 0.5 s after a conversation closes (town and zones); toasts last 3.5 s and a dialogue
clears them; the zone banner waits for dialogue and is skipped after a defeat; the cave's subtitle; dungeon Rules bullets; "Not reachable
yet"; the Hollow Well's reveal greyed at full HP; shops and people before signposts, quest givers' prompt at 2.4 m; Sable's and Tilly's
contradicting lines; Moss Mulligan's portrait; the doubled rule row; the Capital's welcome after Primm, the Model Room coat, the castle
popup's title and services line; Rift arrivals 3 m from the station; Alembic's "Two Paths" and "Brew now / Tell me more"; the
Doppelganger's cover name in the Test Kitchen's opening; the Spotless exam on the gilded gate board; the balance sim's `--filter` takes
several keys. Both failing GUT scripts are fixed (eight S-GALLERY Bestiary entries and their request rows; Meet the Merchants' current
80-gold payout), plus a third stale test (the Gallery quest has no hand-in). On hold as instructed: story line edits, Tidy-Bot balance,
the Gallery Echo cards. Not done: inbox "Fixes Nov 7", item 12.

## D8 - Art rows

The five rows (BB-S-GALLERY, DEC-PLINTH-EMBLEMS, UI-CAULDRON, UI-BG-PACKS, KIT-HEAP-THORNWALL) are in `docs/art/art_needed_nov4.csv` as
"Needed - later batch".

## Finish

- **Tests:** all 29 GUT shards green - 2824 of 2826 passed, 0 failing, 2 risky/pending (`bash tools/run_tests.sh --only=tests --size=12`). Windowed smokes run: reach walk (38/38), gamepad (OK, with the new Esc checks).
- **Fresh-eyes critic** (no context, a new Gourmand save from the title; report `docs/review/critic_nov7/CF.md`, shots in `CF/`): **reached the Path gatekeeper - yes.** Lost to Chef Fennel Gravois at about minute 33 and beat him at about minute 40 (both by the pilot). Scores: fun 6, clarity 5, difficulty 5 (badly ordered), text 8, look 8 (C1/C1b were 6/6/5/7/8 and 5/5/5/8/7). No SCRIPT ERROR. Top findings for the next pass: (1) **blocker** - the Peek popup (Amuse-Bouche) draws behind the board's units, so its buttons are covered; (2) bought cards go to the collection with no hint to add them at the Deck Station; (3) the cave now runs backwards - the 7-HP Stalker is harder than the 3-HP Warden; (4) an at-cap reward pick turned into essence that did not appear; (5) the combat board is crowded and its messages go stale, and Fennel hides behind orchard trees with a narrow talk prompt.

# Critic pass Nov 6 - top 15 improvements

Brief: `docs/prompts/critic_nov6.md`. Full synthesis (scorecard, evidence, fixes, quick wins, art rows, don't-touch, owner decisions):
**`docs/review/critic_nov6_summary.md`**. Reports and screenshots: `docs/review/critic_nov6/`. Inbox: "Critic Nov 6". No export; no game
code changed (only the play driver's pilot, three blocker fixes, plus a `perf` command).

Mean scores across 13 critic runs: fun 5.0, clarity 4.8, difficulty 4.2, text 7.1, look 7.4. No play critic finished its section as
briefed: walking, wayfinding and difficulty swings stopped all of them. No game script error in about 230 runs.

| # | Improvement (first hour: 1-5) | Impact | Reach | Effort |
|---:|---|---:|---:|---|
| 1 | Point every player at their Path from minute one (tracker line, map icon, E prefers the guardian at a sealed gate) | 5 | 5 | M |
| 2 | Make walking work: colliders with sliding, non-blocking roamers, fixed town yaw, roofs cut away, the Dump's invisible wall | 5 | 5 | M |
| 3 | Fix the Deck Station traps: slot-pick save mode, Esc/X dead with unsaved changes, missed clicks, hidden rows, 53-vs-51 count | 4 | 5 | M |
| 4 | Stop early mana starvation: 2 infrastructure in opening hands, no Wild Growth on first nodes, a smoother cave, a sturdier Refusemancer start | 4 | 5 | M |
| 5 | First-hour input traps: E takes a reward card, Path choice dead clicks, toast over Tilly, hidden map tip, cave resets on leave | 3 | 5 | S |
| 6 | Losing never spirals: no fee when broke, retry bosses (and Primm) in place | 4 | 4 | S |
| 7 | Reveal the town map, draw "Where to?" routes in the world, a roamer in sight of each hub exit | 4 | 5 | M |
| 8 | Packs as a reward: a card-face reveal, Path-weighted General Packs, more Path singles | 4 | 4 | M |
| 9 | Retune the agreed outliers: Gallery 1/40 (+ dropped Echo cards), Clench vs Gourmand, Beefcake fall-off, Necrocrat snowball, Betty/Automaton, ZoneOrderEase floor, late rewards | 4 | 4 | L |
| 10 | Primm's finale: a toss prompt, a phase break instead of "VICTORY!", the Model Room board, the 3/3 rule check, a phase checkpoint | 4 | 3 | M |
| 11 | Story finale and ending contradictions (C6 weak moments 1-5, plus prince hints, Primm's confession, the redemption conveyor) | 4 | 3 | M |
| 12 | Card readability at 720p and the triple hover | 3 | 5 | M |
| 13 | One Esc/focus rule for every screen | 3 | 4 | M |
| 14 | Endgame/postgame wayfinding: the Capital route, the Crease, the Gallery, the forest hatch (blocker), a thin Capital | 4 | 3 | M |
| 15 | First-visit hitches, the 17 s Dump load, a Low-end mode that cuts memory | 3 | 5 | M |

Not reviewed as played: Primm's phase 2, the ending and the credits, Swolympus, the Lab's middle, a real Gallery run (see the summary).

---

# Overnight Nov 4-5 - report

Brief: `docs/prompts/overnight_nov4.md` (Parts 1-8 + Finish). Tag `pre-overnight-nov4`. Decisions: `docs/overnight_inbox.md` ("Overnight Nov 4-5").
Shots: `docs/overnight_shots/nov5/`. Previous report: `docs/overnight/nov4b/overnight_report_fixes_nov4b.md`. No export.

## Part 1 - the critic's list (docs/review/critic_nov4b.md)

| # | Item | Result | Evidence |
|---|---|---|---|
| 1 | Old Man Mountain | His first talk now says the gate hint himself (4th box: "that gate up on the overlook... opens when the kingdom is whole again"). Any NPC speaks to the NEWEST active quest of theirs first (`Session.quests_active_for`, zone NPCs and Maren), so after "Only the Worthy..." he talks about the shake, not "Spot Gary". | `tests/core/test_overnight_nov5_part1.gd` |
| 2 | Alchemist screen | Chosen jars get a gold border, a fill and "✓ Selected"; the Craft button always reads "Craft — 100 gold, 6 + 6" and, when it can't be pressed, says why on a second line ("Pick two Paths", "Need 4 more Necrocrat essence", "Need 100 gold"). A jar short of essence can be picked so the reason shows. The 16 possible cards now sit in two rows of 8 (one row pushed the whole screen past the right edge). Real craft in play with 18 + 18 essence: both jars show 12 after. | `p1_2_01/03/04_*.png`, `docs/review/play_scripts/nov5_alchemist.txt` |
| 3 | Quest log after Primm | Primm's fall closes every unfinished zone line quietly (no "0/4" left) and starts + tracks "Under the Forest" at once (`Session.settle_postgame_quests`; old saves are settled on the next town visit). A freed zone also finishes its own line without the favour step. Verified through the code a real castle win runs (`resolve_main_dungeon`); the play driver could not get through the Model Room staging into Primm's duel (inbox 1). | `test_beating_primm_in_the_castle_settles_the_quest_log` |
| 4 | Forest hatch | The hatch is at z 34, about 29 m below the clearing's south rim (was ~10 m). The trail is painted dirt with a stone kerb, flagstones, glowing blue mushroom clumps every 3-4 m, two lanterns on posts and a cool fill light; the hatch has a brighter light and a pale beacon shaft. Brambles still block it at the start. | `p1_4_closed/open/trail/hatch.png` |
| 5 | Iron Cave | The Enter popup uses the real name at the entrance. The canyon pylon that stood in front of the crag moved 10 m south. The crag has two ragged tiers, a leaning spire and stepped lumps on its corners instead of one straight block; chalk bucket, plate stack and kettlebell rack at the mouth (the torches, arch and dark recess were already there). | `p1_5_iron_cave.png` |
| 6 | First-duel tip | Sits above the Opening-hand panel, clear of Keep Hand / Mulligan. | `p1_6_first_duel_tip.png` |
| 7 | Rule text | Pump Iron -> **Home Gym** ("yours only"); zone stat rules say "on both sides"; Smuggled Weights no longer repeats the Iron line. Audit of every dungeon fight's pre-fight list (`tools/rules_audit.gd`, 71 fights): renamed the Gainlands debuff Processing Time -> Out of Breath (the D.N.A. dungeon has its own Processing Time), Mortimer's duplicate Red Tape Everywhere -> Paper Mountain, Primm's Royal Guard -> Standing Army, the Doppelganger's Perfect Copy -> Plated Just So, Specimen Conditions (enemies) -> Enhanced Specimens, Drained Strength -> Borrowed Strength; Prize Topiary says it stacks. No contradictions found. | inbox 2 |
| 8 | Nameplates | The plate measures names in capitals, shrinks the font to 20 px, then widens (up to 560 px) before shrinking further. "RIP TEARSON, RIFT TECHNICIAN" shows in full. | `p1_8_rip_nameplate.png`, test |
| 9 | Item slots | A used-up item stays in its slot greyed with a "Used" badge (battle bar and Character page) until something else is equipped there (`PlayerProfile.spent_item_slots`, saved). | test |
| 10 | Never seen in game | Rescue choice + result (button text no longer repeats the boon's description: "Flex's Promise"); a real craft (item 2); Shiro's 3 Gilded packs in the pack inventory; the D.N.A. elevators and lobby with no dialogue. Critic scripts fixed (HOG node 6 + double-click, Craft click, Shiro Continue). Cut-in hints say "E / Click" and the driver's skip handles cut-ins. | `p1_10_*.png` |

## Part 2 - economy and dungeon rules

- **Packs:** General 150, Path 200, Gilded 800 (4x Path, as before), General II 300, Prismatic 1200.
- **Repeat fights** pay the same as the first win.
- **Dungeon clear bonus:** beating a dungeon's boss pays the run's gold again, shown on the boss's Victory screen ("Clear bonus: +X gold").
  To keep the no-grind target, dungeon nodes now pay half (a finished run pays exactly the old amount, an abandoned one half).
- **Quests:** main x1.75, side quests of 3+ steps x1.6, shorter x1.5 (milestones too).
- **No deck changes inside a dungeon:** the Deck button, B on the map and the in-dungeon Deck Station are gone. Cards won go to the
  collection (the tutorial cave still adds its picks to the deck); a card lost in the Descent stays lost.
- **Tri-Path recipes:** 35 tri-Path cards exist and every trio of Paths has some; the "(no tri-Path recipes exist yet)" line was already gone.

Gold study (`docs/balance/gold_economy_nov3.md`, "Overnight Nov 4-5"). The study had never loaded the quests (they counted as 0), so the
"before" column is the Nov 4 economy re-measured with them.

| | Before | After |
|---|---:|---:|
| Earned (no grinding) | 19,159 | **21,189** |
| Items, hats, fees | -1,325 | -1,325 |
| 20 cards | -4,700 | -4,700 |
| Left for gear | 13,134 (5 pieces) | **15,164 (6 pieces)** |

By source after: main 6,415, side quests 2,180, clear bonus 2,165, side-dungeon nodes 1,140, postgame nodes 980, the rest unchanged.

## Part 3 - early-game fun check, every Path

Full write-up: `docs/balance/early_game_nov5.md` (tool `tools/early_game_study.gd`: a new save of each Path walked through the economy
timeline as a no-grind player, then its first main dungeon simulated with the starter deck + two Commons, 10 runs per Path).

**Gold:** 520 at the first shop (5 Commons, 7 items or 3 General Packs; goal 2-3), ~800-870 at the own gatekeeper, 1,530-1,890 on reaching
the first main dungeon. Affordability is fine for every Path.

| Path | First dungeon | Level | Before | **After** | HP left |
|---|---|---:|---:|---:|---:|
| Beefcake | The House of Gains | 9 | 50% | **70%** | 17.6 |
| Necrocrat | The Hall of Final Approvals | 8 | (30% with HP-only ease) | **90%** | 18.6 |
| Gourmand | The Test Kitchen | 9 | 40% | **90%** | 16.1 |
| Refusemancer | The Rotheart | 9 | 10% | **70%** | 15.1 |

Goal 65-80%. The cause was zone order: the four zones are tuned for Gainlands -> D.N.A. -> Buffet -> Dump, but every Path starts in its own,
so a Refusemancer met the Rotheart (tuned for level 17) at level 9. **Fix:** `ZoneOrderEase` (`core/zone/zone_order_ease.gd`) - a zone
played earlier than its designed place gets easier foes (HP x1.0 / 0.95 / 0.85 / 0.42 by places early, x0.85 more for the very first zone,
units -1 attack); a freed zone, the Capital and a zone in or after its designed place are untouched. Decks, prices and rewards unchanged.
Necrocrat and Gourmand sit slightly above the band (inbox 9). Tests: `tests/core/test_overnight_nov5_part3.gd`.

## Part 4 - dialogue rewrite

Full write-up: `docs/dialogue/rewrite_nov5.md`; style guide `docs/dialogue/story_voice_nov5.md`; review sheet **`docs/dialogue/edit_nov5.csv`**.

- 1,178 lines rewritten in 15 story-order chunks (main quests first, then primary characters, side quests, barks), applied as a revertible
  pass; the 15 lines a blind critic preferred in their old form were put back and 4 weak ones fixed.
- Blind critic (100 random changed lines, versions unlabelled): main story new 49 / old 5 (6 ties), side content new 29 / old 10. Averages
  new vs old - main: voice 7.5 vs 6.3, clarity 8.0 vs 7.3, emotion 7.0 vs 6.0, humour 7.2 vs 6.3; side: voice 7.4 vs 6.6, clarity 8.1 vs
  7.3, humour 7.2 vs 6.7.
- Before / after (seven of the ten in `docs/dialogue/rewrite_nov5.md`):

| Speaker | Before | After |
|---|---|---|
| The Wanderer, waking | I search for my name. For how I got here. But I find nothing. | I keep reaching for my name, or for how I got here, and there's nothing there at all. |
| Elder Maren, memory 1 | I sense something within you that wasn't there before. I trust the Paths to guide you. | That tune's stayed with you, hasn't it? I can see it on your face. Good. Keep it somewhere safe, dearie, even when it hurts. |
| Agnes Overdue, the vacancy | Even the dead deserve humanity. Our job is to help the lost souls. Following orders be damned: we treat everyone with respect. | Everyone in that queue was somebody, dear, and the dead deserve to be treated as people. No order outranks that, not his and not anyone's. |
| Elowen, Cell 4 | They put me in your cell. My father thinks that's educational. With him it is hard to tell. | They put me in your cell. My father calls it educational, and the worst of it is that he means it. |
| Widow Pell | I cannot bury him. Form 27-B needs Form 27-C, and 27-C needs 27-B. He has waited in his chair for three years. | And I can't bury him. Form 27-B needs a 27-C, and the 27-C needs a 27-B, so he's still in his chair, waiting, the way he always used to wait for me. |
| Chef Gravois, freed | The simmer let go. The sauce let go. Plain bread. No sauce. I could weep. I am weeping. | The sauce has let go of me. Is that plain bread, with no sauce on it at all? I could weep. In fact, I am weeping. |
| A freed citizen | He was not kind. He was afraid. I think both can be true. | He wasn't kind, he was afraid, and for ten years none of us could tell the difference. |


## Part 5 - The Shattered Gallery (postgame dungeon)

Design and sim: `docs/design/shattered_gallery.md`; code `core/dungeon/shattered_gallery.gd`; tests `tests/core/dungeon/test_shattered_gallery.gd`.

- **Entry:** after Primm, a cracked mirror by the castle door (primitives, cold light) and Wren's side quest "Cracks in the Glass". Looking
  into it unlocks the dungeon; it runs on the Capital's HP with **Silver Reserve** (+40 max life inside) and returns to the Capital.
- **13 nodes, three wings:** seven **Echoes** of beaten bosses (Quota, Clench, Plume, Mortimer, the Doppelganger, Clipwell, the Rotheart -
  their own decks, 18-26 HP and one twisted rule each), three costly events, one optional paid rest, and **The Perfect Copy**: your current
  deck, your max HP + 20, one extra card a turn, your own face through a silver shader.
- **Stacking wing rules:** Silvered (enemy units +1/+0, from node 2), Reflected Order (your first card each turn costs 1 more, from node 5),
  Perfect Form (your first unit each turn is copied for the enemy, nodes 9-12; new modifier `MIRROR_FIRST_UNIT`).
- **Look and sound with no new assets:** Echo plates are their originals' Bestiary pictures through `mirror_tint.gdshader`; the castle map
  and board stand in until MAP-S-GALLERY exists; the castle and Primm cues play through a detuned mirror chorus on the Music bus.
- **Rewards:** first clear 1,500 gold, 6 essence of every Path, hidden feat **Through the Glass**, and the **Mirrored card finish** (a
  silver sheen you toggle per card in the Collection Book). Repeats: side-dungeon gold, a Prismatic Pack, the clear bonus.

**Sim** (reference deck of each Path at level 26 with gear and items; target: a strong late deck beats the boss 20-35%):

| What | Setting | Player wins |
|---|---|---:|
| The Perfect Copy alone, full HP | all three wing rules, +15 HP | 3% |
| | Silvered + Reflected Order, +20 HP (**kept**) | **51%** (Beefcake 40, Gourmand 45, Necrocrat 55, Refusemancer 65) |
| Whole run, one HP pool (events skipped) | first draft | 0% |
| | Echo HP 18-26, Silver Reserve +20, two Echoes eased | 0% (one run reached the Copy) |
| | Silver Reserve +40 (**kept**) | not measured: the host stopped the sim for low memory |

Each Echo alone is beatable (Quota and Clench 100%, Mortimer 94%, Plume 84%, the Rotheart 56%), but each costs a strong deck about 10 HP.
The whole run is a wall by design, maybe too much of one (inbox 8). Knobs: `SILVER_RESERVE`, `PERFECT_COPY_HP_BONUS`, the `WING_*_ON` lists,
the Echo HP in `dungeon_content.json`.

## Part 6 - music: the Gainlands quotes

| Cue | What quoted the old march | Now |
|---|---|---|
| MUS-CREDITS | the Gainlands section (bars 22-39, trumpets + horns) | the rock riff and answer, same bars and orchestration |
| MUS-PRIMM-02 | the Gainlands section of the medley (trumpet + horn, violins) | rock riff / answer |
| MUS-PRIMM-03 | the Gainlands head in D | rock riff head |
| MUS-PRIMM-DEFEAT | the Gainlands head on horn | rock riff head |
| MUS-QUEST-ROLLO | the whole theme (horn, then violins) | rock riff / answer |
| MUS-REUNION | a horn call from the theme's head | rock riff head |
| MUS-THRONE | the head on trumpet | rock riff head |
| MUS-CAP-RESTORED | the head in D | rock riff head |
| MUS-CAP-RIFT | its own copy of the march, bent to D minor | rock riff / answer, bent the same way |

Method: the march melody (`scores/_fork_b.py` GAIN_THEME, CAP-RIFT's BEEF) was replaced by 16 bars of the rock material (`lib/rock.py`
MOTIF_RESOLVED / ANSWER_MAJOR, up a tritone into the march's Bb major and harmony), so each cue keeps its own instruments, key and length.
All nine re-rendered at q6 one at a time, every check OK (-20.0 LUFS), delivered (`deliver_part.sh`), music smoke OK. FOREST, DECK and
TUT-EXP already quote the rock riff's melody (it is the Crossroads motif) and were left alone (inbox 6).

## Part 7 - art list and import prep

- `docs/art/art_needed_nov4.csv`: every row now has its target id(s), game file, size and format (38 rows). New rows: SPR-TOWNSFOLK-A/B/C
  (a human market regular, a badger labourer, an old hare; idle + walk in FRONT / FRONTSIDE / SIDE / BACK, talk, REF) with a portrait each
  (NPC-TOWNSFOLK-A/B/C), and MAP-S-GALLERY with a full map description. Sprite batch rows NT-TOWNSFOLK-A/B/C give the importer their height.
- `docs/art/import_nov5_ready.md`: for each id, the Approved_* folder and filename, and the command.
- Node guide for the map: `docs/art/paintover_inputs/gallery_map_guide.png` (1536 x 1024, `tools/art/gallery_map_guide.py`).

### Art import checklist (importer dry run)

Every importer was run once on placeholder PNGs with the exact names of `docs/art/import_nov5_ready.md`, through its `*_SOURCE_DIR`
override (the Drive was never touched). Each run's outputs and manifest changes were removed afterwards, along with the placeholders.

| Importer | Placeholders | Result | Fix made tonight |
|---|---|---|---|
| Portraits (`import_portraits.sh`) | 10 (NPC-FLEX_REVEAL, CUT-FLEX, NPC-TOWNSFOLK, -A/-B/-C, GYM-ATTENDANT, BRISKET, SIR-LOIN, CAPITAL-GUARD) | all 10 picked up | `Portraits.EXTRA_PORTRAITS` lists the new ids |
| NPC sprites (`world_test_import.gd --npcs`) | 38 (FLEX-FREED, ROLLO, TOWNSFOLK-A/B/C) | all cut and scaled; townsfolk 21 frames, walks FRONT/FRONTSIDE/SIDE/BACK | the 8 FLEX-FREED and ROLLO files matched no batch row: rows **NS-FLEX-FREED** and **NS-ROLLO** added to `npc_sprite_batch.csv` |
| Key art (`import_key_art.sh`) | STORY-CLENCH-THRONE | matched no ID at first | row added to `logo_title_art.csv`; wired behind the flex cutscene's beats 1-2 (`StoryStills.CLENCH_THRONE`, icon stage until the file exists) |
| Bestiary (`import_bestiary.sh`) | 5 BST ids | all 5 picked up; 99 of 99 Bestiary ids would have a picture | - |
| Maps (`import_maps.sh`) | MAP-S-GALLERY | picked up | - (the castle stand-in drops out when the real file exists) |
| Opening Forest kit (`import_zone_kit.sh openingforest --only=`) | OF-PROP-BRAMBLES | matched no row at first | row added to `openingforest_kit.csv`; `StartingAreaBuilder._build_brambles` now puts two painted cards in the gap once it exists (the walls stay the same; tests pass both ways) |
| Gainlands kit (`import_zone_kit.sh gainlands --only=`) | GAIN-HERO-IRON-CRAG | matched no row at first | row added to `gainlands_kit.csv`. It is a CONCEPT row, so it lands in `docs/art/zone_kits/gainlands/concepts/` as the reference for the crag model; the target path in the art list was corrected |
| UI art | UI-BG-DECKBUILDER | not run: the id already exists in the game and the run would overwrite it | - |

Gotcha: the key art, bestiary and map importers rewrite their manifest CSV from the source folder alone, so a run on a partial folder
empties those manifests. Restore them after any test run.

## Part 8 - fresh critic playthrough

A no-context critic played a new save from a hard-linked HEAD worktree (`/c/Dev/wp_critic`), with no dev wins, levels or gold. Report:
**`docs/review/fresh_eyes_early_nov5.md`**, with 17 screenshots in `docs/review/fresh_eyes_early_nov5/`. It picked **Necrocrat** and
**never got out of the tutorial cave** in about 80 minutes:
- it lost twice (to Hollow Stalker and to the Hollow Warden), and each loss sent it back to the bedroll with the cave reset;
- two more runs stalled on input: the Shrine popup ignored E/Space, and the boss node seemed to need a second click.

So Tilly, Meet the Merchants, the shops, the road, the D.N.A. and its first dungeon went unreviewed. Gold reached 240 with no shop in
reach. No SCRIPT ERROR in any run.

**Scores:** fun 5, clarity 5, difficulty 4 (too hard for a tutorial), text 7 ("Even in death, he files."). The art and the defeat recap
("What beat you") were its highlights.

| # | Critic's issue | Done tonight |
|---|---|---|
| 1 | The cave is too hard, and a loss restarts it from the bedroll | **Fixed:** a lost fight in the intro trial no longer ends the run. You come round at full HP on the map, the fight stays open, and the defeat panel says "Try this fight again - the cards and gold you won are kept" (`Session.tutorial_retry_on_loss`). The decks are not softened (inbox 10). |
| 2 | Popups ignore E/Space; the Shrine has no exit; E at the Well gambles a card | **Fixed:** the Shrine's Rest / Continue take E / Enter / Space / pad A and the focus. At the Well, a confirm press now means "Leave it" until the test is taken; Reveal needs a click or the pad's focus. |
| 3 | E at the cave arch needs 2-3 presses | **Fixed (cause found):** the arch is at the floor's edge, so the treeline self-talk fired there, and its nudge "back toward the cave" pushed the hero out of the arch's reach. The E then only replayed the bubble. No self-talk within 3.2 m of the arch now. |
| 4 | Enemy HP "3" next to a bar a fifth full | **Fixed:** the cave's 3-HP foes have a max HP of 3 (`PlayerSetup.max_hp_cap`), so the bar starts full (and they cannot heal past 3). |
| 5 | Path choice cards are too small to read | logged (inbox 11) |
| 6 | The boss node "needs two clicks" | One click always went; the hover hint said "Click again or press E to go", which reads as two clicks. It now says "Click it or press E to go." A swallowed first click was not reproduced (inbox 11). |
| 7 | Grey untextured rocks in front of the bedroll | logged (inbox 11) |
| 8 | The turn counter counts both sides | **Fixed:** the battle shows rounds ("Round 2" on your second turn), and so do the banners and the victory/defeat lines (`BattleHud.round_of`). |
| 9 | The tutorial foes play Gourmand and Refusemancer basics | logged (inbox 11): changing their decks moves the cave's tuned win rate |
| 10 | Long name plates overflow; hand cards cut off; a tip overlaps the phase panel | logged (inbox 11) |

Tests: `tests/core/test_overnight_nov5_part8.gd`.

## Open questions (details in `docs/overnight_inbox.md`, "Overnight Nov 4-5")

1. **Primm's real fight through the driver** stalled in the Model Room staging. Verified through code instead; one manual castle run is
   worth doing (inbox 1).
2. **A dark round object by the D.N.A. lobby's west passage**: unidentified. Keep it or remove it? (inbox 3)
3. **Clear bonus vs node gold:** the nodes pay half and the bonus doubles them back (21,189 earned, 6 gear pieces). Would you rather keep
   the full node gold (~9 pieces) or a 50 % bonus? (inbox 4)
4. **The Shattered Gallery's whole run** is a wall (0 % clears in every measured setting; Silver Reserve +40 is unmeasured). How hard
   should the full run be? (inbox 8)
5. **ZoneOrderEase:** Necrocrat and Gourmand sim at 90 % for their first dungeon, a little over the 65-80 % goal (inbox 9).
6. **The tutorial cave:** losses now retry at full HP. Should the cave decks also be softened? A second critic run starting past the
   cave is needed to review Crosspath through the first dungeon (inbox 10).
7. **The critic's remaining items:** Path choice readability, grey forest rocks, other Paths' basics in the cave, battle layout
   clipping (inbox 11).
8. **Art:** STORY-CLENCH-THRONE, OF-PROP-BRAMBLES and GAIN-HERO-IRON-CRAG were wired or listed tonight. Their sheet rows say
   "Needed" / "Requested" until the art arrives (`docs/art/import_nov5_ready.md`).

## Tests (Finish)

Full sharded GUT (`tools/run_tests.sh --only=tests --size=12`, 341 scripts in 29 shards). **Shards 1-12 ran** (the audio, AI, data,
dungeon, game and quest scripts): 1,448 tests and 3 failures, all from tonight's changes and all fixed and re-run green:
- the feat count is now 41 (Through the Glass);
- Rip's forest tip was reworded by the rewrite;
- the rewrite had dropped Primm's "No order outranks treating people with respect." from `cutscene.primm_p2.2`, so that zone lesson is
  back in the new line (`edit_nov5.csv` updated to match).

**Shards 13-29 did not run.** Claude Code stopped the run for low system memory during shard 13, and its rule is not to restart a
stopped run on my own. Those shards cover the rest of `tests/core` (quests to zone), `tests/ui`, `tests/world` and the root tests. Tonight's
targeted runs covered the scripts touched in those folders (opening forest, story backdrops, the oct31n UX, the part 1-8 test files),
all green. So the brief's "every shard passed once tonight" is **not met**. To finish:
`bash tools/run_tests.sh --only=tests --size=12 --from=13` with nothing else open.
