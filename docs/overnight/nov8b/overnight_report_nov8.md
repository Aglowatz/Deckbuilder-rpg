# Overnight Nov 8-9 (ship-readiness) - report

Brief: `docs/prompts/overnight_nov8.md`. Tag `pre-overnight-nov8` marks the start. Questions: `docs/overnight_inbox.md`, "Overnight Nov 8-9".
No export. The previous report (Import Nov 8) is archived at `docs/overnight/nov8c/overnight_report_import_nov8.md`.

## 1. Ship blockers

| # | Found | State |
|---|---|---|
| 1 | **Five side quests could become unfinishable**: Capital recipe cards, compost heaps and wheel crews, and the D.N.A./Buffet hidden stashes, are once-ever pickups, but their quest steps counted only from acceptance. Take them before the quest and the step never moves (Chef Marlo's Recipe Box, Old Fern's Untidy, Rollo's The Wheel Never Stops, Compliance Audit, The Golden Reservation). Found by the new quest audit. | **fixed**: `QuestLog.LIFETIME_COUNTERS` + every zone's chest counter count from zero; old saves with a stored baseline are unstuck too. Test + the audit now fail on any new case. |
| 2 | **Quit mid-dungeon or right after a zone fight reloaded in Crosspath** instead of the zone (a save taken on a dungeon map, battle or reward screen recorded `scene = "town"`). | **fixed**: `GameSession.scene_kind()` falls back to the active zone visit. Checked live: battle -> zone, dungeon -> zone (run dropped, map restarts), Deck Station -> town. |
| 3 | Five characters **change species** when their mood changes (Brannoch bear -> human, Sable fox -> human, Tonic frog -> human, Fenwick magpie -> human, Threadwell mouse -> human), on the most-visited screens. | **held in code** (`Portraits.HELD_EXPRESSIONS`: the base portrait stays); redo is Batch 14 rows 1-5. |
| 4 | Licences: `assets/fonts/Cinzel/OFL.txt` carried Alegreya Sans' copyright; no in-game credits/licences; end credits said "PLACEHOLDER CREDITS" / "Design and direction: you". | **fixed**: Credits page with every licence, corrected OFL, end credits rewritten (revertible CSV). |
| 5 | The Capital's Old Hob faced a stale key ("hob" is Granny Gristle since Nov 8). | **fixed** (small). |
| - | **Still open:** the four full real-fight playthroughs did not finish. Claude Code's low-memory guard stopped the background run after about 30 minutes, during the first Path. Its rule says not to restart it without you, so it was not restarted. What did run is listed under Part 1. | **open**: rerun `bash tools/run_full_playthroughs.sh` in a daytime session with Chrome and other apps closed, or start Claude Code with `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1`. |

No crash, softlock or broken save turned up in what ran.

## 2. Art audit

**1,957 images reviewed**: every card, portrait, sprite, still, board, map, UI piece, icon, cosmetic, kit prop and texture. **26 flagged**:
6 glaring, 10 noticeable, 10 minor. Verdicts: **12 REDO rows (17 files)**, 5 FIX IN CODE (one applied tonight), 9 KEEP with a note. There is no garbled
pseudo-text, no bad hands and no melted detail at game size. The real problems are narrative: species flips and scale errors.

Worst 10: 1-5 the species-flipping mood variants of Sable, Tonic, Brannoch, Fenwick and Threadwell; 6 STORY-PRIMM-P1/P2 (a giant Primm);
7 RES-IRON (a photoreal render among painted cards); 8 the Capital pastel walls (green stripes from a bad slice); 9 the Capital plaza texture
seam; 10 the D.N.A. queue post (its rope ends in mid-air).

Report `docs/art/art_audit_nov9.md`; every flag `docs/art/art_audit_nov9.csv`; **Batch 14: `docs/art/batch14_nov9.csv`**, ready to
generate (descriptions + the references to attach; attach the base portrait for every mood variant).

## 3. Cut or finish (recommendations only; nothing changed)

| Piece | Recommendation | Effort |
|---|---|---|
| Opening forest light, the slab over the cave arch, and a tutorial-cave loss restarting from the bedroll | finish | M |
| Crosspath: roofs fill the view | finish (fade the near roofs) | M |
| Quiz right/wrong feedback + the Gainlands answer key | finish | S |
| Dex's Matching Circuit (placeholder look) | finish **or hide for 1.0** | M / S |
| Battle: a played Infrastructure shows tiny; the 12-card hand overlaps | finish | M |
| Packs shelf scroll, Alembic bars, Wardrobe tint, Gallery stale tooltip | finish | S each |
| Autosave indicator | finish | S |
| Every zone, dungeon, postgame piece and other system | keep as is | - |

Total about 2-3 working days (2 if Dex is hidden). Full table: `docs/release/cut_or_finish_nov9.md`.

## 4. Release checklist

**Implemented tonight:**
- a Credits page on the title menu: the Godot licence plus every engine third-party licence, the fonts, FluidR3_GM, the sound and model sources, and the AI disclosure;
- a "Support the game" button on the title, the Credits page and the end credits. It reads its link from `data/credits/credits.cfg` and stays **hidden while the link is empty**;
- "Open log folder" and "Copy log" buttons in Settings > Accessibility;
- the Cinzel licence fix, and new end-credits text;
- the itch page kit: descriptions, features, controls, measured requirements, tags, cover advice, the AI disclosure, and 8 screenshots;
- crash-safe start checked (damaged save or settings file), with a test.

Already present: version on the title screen, the log file, volume sliders, rebinding, controller support, text speed, camera options, Low-end mode, save slots, autosave, pause.

**Remains:**

| Item | Effort |
|---|---|
| Autosave indicator | S |
| Colour-blind Path symbols on by default (the four Path colours collide for red-green colour blindness) | S |
| Your creator name and donation link in `credits.cfg` | owner, 1 min |
| CREDITS.md music section is out of date | S |
| Set version 1.0.0, export, upload (steps in `docs/HANDOFF.md`) | S, owner |
| Better Capital, Deck Station and Gainlands screenshots | S |

Full list: `docs/release/ship_checklist.md`.

## 5. Recommended plan for Nov 9-11

- **Nov 9, day (owner):** generate Batch 14 in ChatGPT (about 17 images; the five mood-variant sets first). Answer the inbox: creator name, donation
  link, Dex finish or hide, symbols on by default. **Day session (Claude):** import Batch 14 and un-hold the variants. Rerun the four Path
  playthroughs in the foreground with other apps closed.
- **Nov 9, night run:** the S items: quiz feedback, autosave indicator, symbols default, packs shelf, Alembic bars, Wardrobe tint, Gallery tooltip. Then the forest light and the cave restart.
- **Nov 10, day:** play the first hour yourself on a clean save. Run one fresh-eyes critic (first hour).
- **Nov 10, night run:** Crosspath roof fade, the battle infrastructure row and hand cap, Dex art (or hide it), the full suite, and an exported-build smoke.
- **Nov 11, day:** set version 1.0.0, export, test the zip on a second PC if you can, set up the itch page from the kit, upload, and finalise `docs/HANDOFF.md`.

---

## Part 0 - the import's unfinished parts

The last report (Import Nov 8) stopped at shard 25 of 30. Shards 25-30 ran and passed. The one "failing" test in the old logs was a stale
log, but the Character-pill test was made whitespace-robust anyway. Batch 13, the quick wins and the Capital cache were done.

## Part 1 - Can every player finish the game?

**1.1 Static quest audit:** `tools/quest_audit.gd` (class `QuestAudit`), in the suite as `tests/core/quests/test_quest_audit.gd`. Run
`bash tools/quest_audit.sh` to write the report with the full quest graph: `docs/quests/quest_audit.md`. It covers all 42 quests and every step: what starts each quest, what completes each step, and where its giver and target live. It flags:
- rewards pointing at missing items, cards, equipment or packs;
- conditions naming a missing quest, dungeon or card, and prerequisite cycles;
- flags, counters or secrets that nothing sets, checked against the source, the data and the real generators: ZoneDef fields, gatekeeper, memory, Dex table, arena-bout and barricade flags;
- givers who stand nowhere;
- undeclared marker spots and invalid areas;
- **once-ever counters counted from acceptance**: this check found blocker #1.

A negative test proves it catches each kind of error. Result after the fix: 0 errors, 0 warnings.

**1.2 Playthroughs:** the story bot (`tools/story_playthrough.gd`) gained:
- `--path=<zone>`: that Path's zone first;
- `--real=1`: the BattlePilot plays the gatekeepers and every dungeon boss on the real map. A lost or stalled fight is decreed and logged as DEV HELP;
- save and load at every zone change, checked by a state digest of quests, flags, gold, level, deck, gear, dungeons and secrets;
- one mid-dungeon save and load, which must come back in the zone with no run and a fresh map;
- the postgame: Rip's tip, the forest, the Lab and Elowen, the cracked mirror and the Gallery, Old Man Mountain's errand and Swolympus, and Loose Ends.

Runner: `bash tools/run_full_playthroughs.sh [paths]`.

What ran:
- **Beefcake, decreed fights, the whole game into the postgame:** 117 of 119 steps passed. The two misses were bot artefacts, both fixed in the bot: the Lab's Cell 4 boon was skipped, and a dependent Loose Ends check failed with it.
  - Every save/load at the four zone entries, back in town after each zone, and in the forest: same state.
  - Mid-dungeon: the save records the zone, the load comes back in the Gainlands with no run, and the dungeon restarts.
  - The Lab, the Gallery and Swolympus all opened and cleared.
- **Beefcake, real fights:** the run was stopped twice. The first time, a decreed dungeon loss did not stick (the bot now plays a loss out and re-enters). The second time, the low-memory guard stopped it.
  - It won the gatekeeper for real once and lost it once.
  - It lost the House of Gains boss at level 8 with the reference deck.
  - The pilot is a simple player, so its losses are not a balance verdict; the balance sims cover that.
- **Necrocrat, Gourmand and Refusemancer:** not run (the guard). Rerun before release.

Dev help used, every place:
- walking time: teleports to spots, the walk to the Lab hatch, the Rift Express ride;
- the map walk to each dungeon boss, plus a level and deck catch-up to the expected player for that dungeon;
- favour steps set by their flags;
- Old Man Mountain's errand set by its counter.

**1.3 Robustness:**
- All **165 snapshots** on this PC (the bot, critic and play saves of the last weeks) load through the real load path with no script error: `tools/checks/test_snapshot_loads.gd`. There is no `tools/fixtures` folder.
- Quit during a battle, the Deck Station and a dungeon, then reload: `docs/review/play_scripts/quit_reload_nov9.txt`. All three come back right (blocker #2's fix).
- Soak: **9 minutes, not 90**. The guard stops long background runs, so it ran in the foreground, which allows about 10 minutes at a time. It covered three zone loops with real fights. Static memory stayed flat at 440-510 MB, the object count went back to about 8.4k after every loop, frames held at 60 fps, and there were 0 script errors. A 90-minute soak remains to do (script: `docs/review/play_scripts/soak_nov9.txt`).
- Every shipped scene (`scenes/*.tscn`) loads (a new test). Every main scene was also entered live tonight.

## Part 2 - Art audit

See section 2 above and `docs/art/art_audit_nov9.md`.
- Tools: `tools/art_audit_sheets.py` builds the contact sheets (gitignored, regenerate them), `tools/art_audit_crop.py` crops evidence, and `tools/art_audit_write.js` writes the CSVs.
- The two reviewers' flags were each re-checked by eye.

## Part 3 - Cut or finish

`docs/release/cut_or_finish_nov9.md` (section 3 above).

## Part 4 - Release checklist

`docs/release/ship_checklist.md`, `docs/release/itch_page/` (section 4 above). New code:
- `ui/screens/credits_panel.gd` (`CreditsPanel`, with `support_url()` and `support_button()`), text in `data/credits/credits.txt`;
- `data/credits/credits.cfg` (exported through `include_filter`);
- the title menu "Credits" and "Support the game" buttons;
- the Support button in the end credits;
- `SettingsPanel.log_text()` and the two log buttons.

Tests: `tests/ui/test_release_basics_nov9.gd`.

## Part 5 - Text sweep

`node tools/text_sweep.js` scanned 5,512 player-facing strings: story, NPCs, cards, items, equipment, feats, bestiary, loading tips and quest text. It checks:
- double spaces and spaces before punctuation;
- dev text, and "???";
- repeated words and common misspellings;
- the canon spellings (D.N.A., Path-ology, Doppelganger, Crosspath);
- names one letter off a canon name.

The text is clean after the earlier dialogue passes. The only real hits were the placeholder end credits, fixed by a revertible pass: `docs/dialogue/text_sweep_nov9.csv`, applied with `tools/apply_dialogue_pass.js`. The "???" hits are intended (a locked travel name, a card's joke), and the name near-misses are false positives (plurals). Code strings visible to players were also grepped: none left. **Story contradictions found: none new** (the sweep is mechanical; no read-through was done).

## Part 6 - Handover

`docs/HANDOFF.md` (draft, to finalise Nov 11). It covers:
- the repo map and key files;
- how to play, a light test subset, export, and upload with butler or the web uploader;
- the art, music and dialogue pipelines;
- six prompt templates for the $20 plan;
- the known issues and the post-1.0 backlog;
- backups.

## Finish

- Full suite **2,876 / 2,878 passed, 0 failing**, plus 2 risky/pending as before (30 shards, `--size=12`). After that run, the scene-load test was added and passes. The snapshot check passes too (it runs outside the suite).
- Committed and pushed. No export.
