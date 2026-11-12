# Post-1.0 backlog (Nov 9, for after the itch.io release)

Most important first inside each section. Effort: S under 2 h, M half a day, L a day or more. Sources: the Nov 9 exported-build checks and
critic (`docs/review/critic_rc1/report.md`), the Nov 6-8 critics, `docs/release/cut_or_finish_nov9.md`, the art audit, the inbox.

## 1. Playtester feedback intake (first two weeks)

| Step | How | Effort |
|---|---|---|
| Collect | itch.io page comments + the F8 report folders testers send (`%APPDATA%\Deckbuilder-RPG\feedback\<stamp>\`: `report.json`, `screenshot.png`, the save, `wayward.log`). Ask for the log on every "it froze". | - |
| Triage | one row per report in `docs/playtest/feedback_log.md` (date, build, PC, what, severity, decision). Blockers (cannot progress, crash, save lost) first; then "stuck for 10 minutes" wayfinding; then polish. | S per batch |
| Reproduce | `bash tools/play.sh` with a script that follows the report; `dev load` the tester's save copied into `user://dev_saves/` if they sent one. | S each |
| Fix and ship | small-prompt template 1 in `docs/HANDOFF.md`; a hotfix build is `bash tools/export_windows.sh 1.0.1` + the itch upload (or `butler push`). Keep `CHANGELOG.md` current. | S-M |
| Watch | the walls: if story-only players report losing at Primm or the Gallery despite the level hints, soften those two by one step with the balance sims (`tools/run_balance_sim.gd --what=encounters --filter=dungeon:D-PC`) or add a "recommended level" line to the quest log step. | M |

## 2. Known issues at 1.0.0-rc1

1. **Title screen, keyboard only:** Enter does nothing until a button has the focus (mouse or pad needed once). S: focus the first menu button on the first arrow or confirm key.
2. **Difficulty walls for a story-only player** (Primm's Castle, the Shattered Gallery; the 2nd/4th main dungeons on some Paths): mitigated by the level hints; see "Watch" above.
3. **Red Cross emblem** on Nurse Hesper (portrait and epilogue still): recoloured in code; the painted redo is on the art list.
4. **Capital load 6-9 s** on an integrated GPU (a loading screen covers it); later visits use the geometry cache. M to go further.
5. **Pack size 847 MB / zip 736 MB** against the 750 MB pack budget: the music at Vorbis q6 is the designer's call; if a smaller download matters, the next candidates are the zone kit textures (79 MB) and "other images" (200 MB), not the music.
6. The Credits page scrolls with the mouse wheel only (End / Page Down do nothing). S.
7. A cutscene or still seen before skips with Esc; a first viewing asks first (by design, but testers may read it as "Esc does nothing").
8. Headless importer runs print a harmless "Identifier not found: Session" compile error from `core/zone/zone_defs.gd:46` (dev tooling only). S.
9. Exit-time leak warnings (RID allocations, "RenderingServer::get_singleton() is null") in the logs on every quit; harmless to players. M to clean.

## 2b. Known issues at 1.0.0-rc6 (Nov 12)

1. **Fig Sly's portrait** (`V-FIGSLY`) still has the third arm until the replacement lands in Pending Review / Batch 15; importing it
   is one `import portraits` run (the old file goes to Superseded).
2. **Batch 15 is not imported** (the folder did not exist during the Nov 12 fix pass): `docs/art/batch15_nov12.csv`, 23 rows "To make",
   plus the optional `UI-NODE-BANNER` (the pop-ups pick it up by themselves once it is in `assets/art/ui/`).
3. **No dialogue portrait** for Baron Quadzilla, the Restless Cairn and the Store Room Ghosts (their closing lines show a name plate only).
4. **The 3D world list that code could still do and this pass did not** (the brief's Part C): blended ground textures and edge foliage in
   the Gainlands, the Buffet and the Dump; a void and stray-quad scan of the four Path zones (done for the Capital and the Crease
   only); duplicate and broken sprites; the pale building at the top left of the Transit Yards view; smoother hedges and statues; the
   measured scale table; hub storytelling clutter; added light sources; pickups that bob, doors and chests that animate, more ambient
   life, castle music that escalates.
5. **The controller smoke's "Y hides the card details" check fails** in the ghost duel (the battle's pad layer; not looked into).
6. **A citizen of Perfection (Corwin Bale) can stroll behind a house** where neither camera sees him (NPC visibility probe).
7. **`tools/perf_run.sh capital_in` reads 57 fps on Medium** on the development PC (58 to 61 since Nov 3); the Capital's paint-over
   cameras (`tools/capital_fps.sh`) read 66 to 69. If the 60 target is judged by the first probe, the inside streets are 3 fps short.

## 3. Remaining art REDOs (`docs/art/art_audit_nov9.csv`, verdict REDO and not yet replaced)

| Id | What | Why |
|---|---|---|
| NPC-HESPER | the nurse's portrait: a green leaf or a red heart on the cap and armband instead of the cross | the protected emblem; the code recolour is a stopgap |
| STORY-EPI-WRINKLES | the epilogue still: the same change on Hesper | same |
| NPC-GUS | a file in Approved_Characters that matches no NPC id (either name it after a list entry or move it to Superseded) | housekeeping |
| the 8 bestiary pictures with no image yet | BST-ECHO-OF-* (7 echoes) and BST-THE-PERFECT-COPY (the Gallery boss shows the castle board's cut-out meanwhile) | the Bestiary page shows the icon only |
| ICON-GEAR-EARNEDBLADE | one gear icon missing (59 of 60) | the item shows a fallback icon |
| 8 bestiary files that match no id | BST-COMPLIANCE-OFFICER, -DECONTAMINATION-TECHNICIAN, -FLEXING-BRUTE, -OBSERVATION-WARD-ORDERLY, -POSSESSED-SCARECROW-DRUID, -REGIME-CHECKPOINT-CAPTAIN, -ROOTBOUND-MILLER, -ZOMBIE-INTERN: rename to their foes' ids or supersede | housekeeping |

Everything else on the Batch 14 list is in the game (Nov 9). Style drift of the glossy zone props (Gainlands gym, D.N.A. desk, Buffet cloche)
was judged KEEP.

## 4. Nice-to-haves (from the critics and the cut-or-finish list)

| Item | Effort |
|---|---|
| Tutorial cave: restart at the node you lost on (or at the cave mouth) instead of the bedroll | S-M |
| Crosspath default camera: fade near roofs more aggressively, or pull the camera in | M |
| Battle: a visible row for played Infrastructure; cap the hand fan to one row at 10+ cards | M |
| Quiz: flash right/wrong after each answer; re-check the Gainlands "mills and hamster wheels" key | S |
| Card Packs shelf: scroll arrows or a second row; refresh the HUD's unopened count | S |
| Alembic's essence bars fill against the cap; the brew panel shows the two Paths and the results | S |
| Wardrobe: tint the cloak tile with the equipped dye | S |
| Gallery map: close node tooltips when a modal opens; keep visited nodes labelled after a dev jump | S |
| NPC name plates vs bark bubbles: offset barks above the plate; name the target in the E prompt | S |
| A HUD toast when J / C are pressed in the opening forest ("your quest log opens in town") | S |
| Title screen: an "ambient" camera drift and the four Path emblems lighting up as zones are freed | M |
| Cloud saves / Steam-style save sync | L |
| Localisation hooks (every string already comes from data/story and the UI kit; a CSV export of UI strings is the first step) | L |

## 5. Steam readiness (what a Steam release would still need)

| Item | Note | Effort |
|---|---|---|
| **Steamworks** | a Steam app id, the Steamworks SDK through a Godot 4 plugin (GodotSteam prebuilt templates), init on boot, overlay-safe window | M |
| **Achievements from feats** | `core/feats` already tracks about 40 feats with ids and texts: map each to a Steam achievement id and call `set_achievement` when `EventBus.feat_unlocked` fires; icons 64x64 from the Feats icons (`ICON-FEAT-*`) | M |
| **Cloud saves** | Steam Auto-Cloud on `%APPDATA%\Deckbuilder-RPG\saves\` and `settings.cfg`; test the "newer save on another PC" case | S-M |
| **Store assets** | capsule images (header 460x215, small 231x87, main 616x353, vertical 374x448, hero 3840x1240, logo), 5+ screenshots at 1920x1080 (re-shoot on a 1440p screen), a trailer (the itch trailer at 1080p60), the AI disclosure in Steam's form (required) | M |
| **Steam Input** | the pad bindings already follow the device; add an official Steam Input config and glyph set | S |
| **Controller + Steam Deck** | test at 1280x800, the Low-end preset, text sizes; a Deck-verified pass needs every screen pad-reachable (PadFocus covers the known ones) | M |
| **Rich presence / stats** | optional: zone names in presence, lifetime counters already exist (`Session` counters) | S |
| **Pricing and keys** | a paid Steam build with free itch stays legal (both are the owner's); decide whether itch stays free or gets keys | - |
| **Build pipeline** | `steamcmd` + an app build script next to `tools/export_windows.sh`; depot = the export folder; a "steam" branch for betas | S |
