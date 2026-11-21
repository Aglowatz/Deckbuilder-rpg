# Fable, Nov 21: launch readiness review (the game ships in about two weeks)

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The owner releases 1.0 on itch.io in about two weeks. This run is **a full review to get it ready**: find and fix what a player would hit, measure the balance, polish, and leave the owner one clear list of what's left. Work without stopping to ask; the owner may be away for hours. (This is a NEW brief, not a copy of fable_nov20_night.md: carry it out.)

Read first:
- the top of docs/overnight_report.md ("Fable Nov 20 day") and docs/overnight_inbox.md ("Fable Nov 20 day");
- docs/owner_backlog.md;
- docs/writing/story_bible_v2.md;
- docs/art/ui_style_guide.md.

Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable Nov 21 review". Tag `pre-fable-nov21-review`. Work in this order; if time runs short, finish the part you're on, then do Part 9 and list what's left.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; `tools/run_tests.sh --min-free=900`. If the guard stops a background run, finish it in the foreground with `--from=N --to=K`. Tests run under the save guard.
- Commit and push after each part. No public upload.
- Shots in docs/overnight_shots/nov21r/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - Primm's fight and the castle rooms unchanged;
  - no enemy intent shown;
  - no combat pacing changes;
  - each zone keeps its own colour grade;
  - family friendly;
  - no new painted art (Batch 19 rows instead);
  - the 45-card minimum stays.
- **Balance numbers:** measure and propose; **don't change card, enemy or Arena numbers** (the owner decides). Bugs in rules (a card doing something its text doesn't say) are bugs: fix them.
- **Dialogue:** typo, name and consistency fixes only, single lines, with `docs/dialogue/nov21n_lines.csv` and `_ids.txt` for `--revert`.
- Every fix gets a test.

## Part 1 — The owner's answers to "Fable Nov 20 day" (the recommendations, as given)
1. **The Buffet's map redo row** stays in Batch 19. Mark the D.N.A. row optional, not wanted for now.
2. **The Raw Deal's flat front** stays. Check it at +12 and +14 degrees; if it reads as a standing card, let the modelled roof show behind it (your proposed fix).
3. **The manhole** stays.
4. **Glass and gold side by side** stay for now. Also add the rose window above the title screen's menu if it fits without crowding.
5. **The slate Quit/Delete and "Done"** stay.
6. **The info screens follow the Text size setting** (quest log, glossary, settings, feats, tooltips, pop-ups). Shoot them at Large; nothing may overflow or clip.
7. **The five zone maps (MAP-WORLD-*)** were packed at 1536 px by the export rules. Look at each on the map screen (M) in the exported game; if they look soft, add a 2048 px rule for MAP-WORLD-* in `tools/art_import_rules.json` and report the size cost.

## Part 2 — A full playthrough audit (the main job)
Play the whole game with the automated runners, as a new player would, on a fresh save and on the existing test saves:
- the prologue and tutorial cave;
- Maren's quests;
- all four zones in two different orders;
- every main and side quest to its hand-in;
- every dungeon and mini dungeon to the end, including the new heal rooms;
- the Capital, Primm's Castle and Primm;
- the ending, the postgame (the Path-ology Lab, Elowen's rescue, the Shattered Gallery);
- the Arena tiers;
- Alembic crafting;
- the Deck Station, the shops, the Wardrobe, every pack type;
- feats;
- saving and loading at many points.

**Look for, and fix where it's safe:**
- softlocks, dead ends and quests that can't be finished or handed in;
- markers pointing to the wrong place;
- NPCs who say outdated things after a zone is freed;
- duplicate or missing rewards;
- items or cards that can be lost;
- any SCRIPT ERROR or warning in the logs;
- pop-ups that can't be closed with mouse, keyboard or controller;
- text that overflows or clips at 1280x720 and 1920x1080;
- anything left from renames (Colorless, Patchwork Cloak, Omakase).

Also check:
- **Save safety:** an old save from before the Nov 18-21 changes loads and keeps its cards, gold, quests and cosmetics.
- **Controller:** every screen reachable and usable with a controller (the Deck Station search box is known and deferred).

Report each finding with severity (blocker / bad / minor), what you fixed, and what you couldn't.

## Part 3 — A balance report (measure, don't change)
1. **The Nov 21 changes** were never simulated: dungeon runs with the new heal rooms and drawbacks, the five changed cards, the AI's two-Infrastructure opening hands, the three-Path lock until Primm. Run the simulators: each Path's starting deck and a typical mid-game deck through every zone dungeon, the gatekeepers and the bosses. Report win rates and HP at the end, compared with the last sim pass, and flag anything far off (above 95% or below 35% for a fair deck).
2. **The Arena:** simulate every Arena battle per tier; list the ones that are far too easy (the owner says several are) with **proposed** changes (the enemy's deck, set hand, HP), in a table the owner can approve line by line. Change nothing.
3. **The economy:** a no-grind playthrough's gold against the owner's target (about 21.2k, enough for three copies of every card plus crafting all multi-Path cards). Report the gap.
4. Write it all in `docs/balance_report_nov21.md`.

## Part 4 — Text polish
1. Run a spelling and grammar pass over every player-facing string (dialogue, card text, quests, glossary, tooltips, menus, the tutorial). Fix typos, double spaces, inconsistent capitals, and names that disagree with the canonical names (the "NPC/Vendor List" and "Dungeon List" tabs in the owner's design sheet, mirrored in the repo's name registry).
2. **Card text against card rules:** every card's text says exactly what its code does (keywords, numbers, targets). Fix the text or the bug, and list each.
3. The glossary and the tutorial mention every rule added since Nov 17 (three copies owned, the three-Path lock, the Alembic's 6/18, the heal rooms, the copy notice).

## Part 5 — Performance and size
- Measure load times (start-up, each zone, a battle), memory and FPS on Medium and Low-end in every zone.
- Fix safe wins (an unused big texture, a shader compiled at a bad moment, a leak) without changing how anything looks.
- Report before/after and the expected download size.

## Part 6 — Small polish a player would notice
From what you find in Parts 2-5, fix up to about ten small, clearly-better things with no new art and no design change. Examples:
- a confusing prompt;
- a sound missing on a button;
- a toast that hides something;
- a tooltip that's wrong;
- a hover state missing.

List each with a before/after shot.

## Part 7 — Release preparation (drafts for the owner; upload nothing)
In `docs/release/`:
1. **`itch_page.md`:**
   - a short pitch, a longer description and a features list (the four Paths, crafting, the zones, the Arena, the postgame);
   - controls, system requirements (from the Low-end measurements), the download size;
   - a donation line;
   - a plain **AI disclosure** (the art and music were made with AI tools, directed and curated by the creator; the game's design and writing are the creator's, with AI assistance).

   The owner edits it.
2. **`screenshots/`:** pick the 8 best-looking shots of the current build (world, battle, shops, cutscene, map, Arena) at 1920x1080 with no debug text, plus a 630x500 cover candidate composed from existing key art (no new painting).
3. **`known_issues.md`:** what's still open after tonight, in players' words.
4. **`player_readme.txt`:** for the zip (how to run, saves location, controls, how to report a bug).
5. **Credits:** check the in-game credits name Alex Glowatz as creator and list the tools honestly; fix gaps.
6. **`release_checklist.md`:** every step from final build to the page going Public (the owner flips it to Public himself), including the setx memory step and removing the old Codex folder, marked as the owner's.

## Part 8 — The two-week plan
Write `docs/release/two_week_plan.md`: everything left before 1.0, ranked by what a player would feel. Include:
- Part 2's open findings;
- the backlog (Arena balance by hand then Fable, more Arena puzzles, which camera preset a new player starts on, the gold screens beside the glass ones, glossary keyword colours, Rip's walk, Elowen's walk, Batch 19);
- the balance decisions from Part 3;
- the release tasks.

For each item:
- who does it (the owner by hand, a Claude Code run, or a ChatGPT art batch);
- a rough size;
- a suggested day.

Also say what you'd **cut** if time runs short.

## Part 9 — Tests, build, report
1. All test shards green; the walk smokes (every zone); the NPC visibility probe; the fade probe; the quest hand-in probe; the hover-zoom probe; the puzzle solver tests.
2. **Export 1.0.0 for the playtesters:**
   - wait up to 10 minutes for at least 2.2 GB free RAM, otherwise use `EXPORT_LOW_MEMORY_OK=1`;
   - `bash tools/export_windows.sh 1.0.0`;
   - the exported smoke and the three `play_exported.sh` checks (0 SCRIPT ERROR).
3. **docs/overnight_report.md**, at the top, under "Fable Nov 21 review":
   - each part done or not;
   - the audit findings table (severity, fixed or open);
   - the balance headlines (link the report);
   - the polish list with shots;
   - performance before/after;
   - where the release drafts and the two-week plan are;
   - the zip's path and size;
   - the dialogue revert command;
   - the owner's decisions needed (at most 6, each with a recommendation).
4. Commit and push. No public upload.
