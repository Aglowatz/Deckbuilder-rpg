# Fable pass Nov 9 — Batch 14 + Sable import, RC1 build, release-candidate check

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The 1.0 target is a free itch.io release (with donations) this week.
Read docs/overnight_report.md first. Work autonomously; log questions in docs/overnight_inbox.md under "Fable Nov 9".

## House rules
- STOP_OVERNIGHT check before each part.
- Memory:
  - ONE Godot at a time; kill stray Godot processes first;
  - no sub-agents while Godot runs;
  - stop a job cleanly if free memory drops under ~800 MB.
- Tests: memory-safe shards (`bash tools/run_tests.sh --only=tests --size=12`, `--from=N`).
- Screenshots go to docs/overnight_shots/nov9c/.
- Commit and push after each part.
- No public upload.

## Part 0 — The day pass (docs/prompts/day_nov9.md)
If any of it hasn't run yet, do it now:
1. Credits: **Alex Glowatz** as creator.
2. Colour-blind symbols on; Dex stays in 1.0.
3. The level hints at the wall entrances.
4. Check the dark battle backdrop.
5. Write the itch upload guide.

Skip anything already done (check the git log and the report).

## Part 1 — Import Batch 14 + Sable (23 approved images)
The source is `G:/My Drive/Card Game Art/Pending Review/Batch 14/`.

1. **Sable (modest redesign, owner's request: no cleavage, family-friendly):**
   - **The images:** V-SABLE, V-SABLE_PLEASED, V-SABLE_SCHEMING, SPR-SABLE-REF and SPR-SABLE-FRONT_IDLE / SIDE_IDLE / BACK_IDLE / FRONT_TALK.
   - Replace ALL her old portraits, plus her world sprites in assets/art/world_test/sprites/SABLE; regenerate the `_n` normal maps the way the sprite pipeline does.
   - Old versions go to Superseded, both in Drive and in the repo history.
   - Remove her from Portraits.HELD_EXPRESSIONS.
   - **Search the whole game** for any other image of Sable (cards, stills, shop art, loading screens, the vendor screen) and list it. If one shows the old design, add it to the art list as a REDO.
2. **The species-flip fixes:**
   - **The images:** V-TONIC_EXCITED / OOPS, NPC-GATEKEEPER_HAPPY / STERN, V-FENWICK_EXCITED and V-THREADWELL_DELIGHTED.
   - **Two Pip versions** (V-THREADWELL_DELIGHTED and V-THREADWELL_DELIGHTED-ALT): compare both with V-THREADWELL and use the more on-model one. The other goes to Superseded. Log which one you picked.
   - Remove every remaining HELD_EXPRESSIONS hold that these fix, so the mood portraits show again.
3. **The rest:**
   - RES-IRON, BAS-G and B-13 (card art);
   - STORY-PRIMM-P1, STORY-PRIMM-P2 and STORY-REVEAL-KITCHEN (the scale-fixed stills);
   - BST-ANTECHAMBER-SENTRY;
   - ICON-ITEM-FIELDBANDAGE (no red cross).
   - Also check NPC-HESPER's cap and armband and STORY-EPI-WRINKLES for the Red Cross emblem. If it's still visible, mask or recolour it in code (a small overlay) and add a REDO row to the art list.
4. Move everything to its Approved_* folder, run the importers one Godot at a time, mark the rows in docs/art/batch14_nov9.csv "In game", and screenshot each image in game (portraits in a real conversation, cards in hand and at full size, stills in their scene).
5. Report the size and memory change against docs/build_size_policy.md.

## Part 2 — RC1 build and a real-build check
1. Set the version to **1.0.0-rc1**. Export `bash tools/export_windows.sh 1.0.0-rc1` and run the release smoke.
2. **Exported-build test:** run the EXPORTED .exe (not the editor). Check:
   - first launch with no settings or save;
   - new game through the intro to Crosspath;
   - save, quit and reload;
   - a battle, a shop, the Deck Station, the Wardrobe, the Card Packs page and a minigame;
   - settings changes that survive a restart;
   - Low-end mode;
   - the log file and "Copy log";
   - the Credits page and the AI disclosure;
   - the hidden donation button stays hidden.

   Fix anything that differs from the editor (missing resources, import settings, paths), and re-export as 1.0.0-rc1b if needed.
3. **Fresh-eyes playtest of the exported build:** one fresh critic (no context) plays 60-90 minutes from the title as a new player. It scores first impressions, clarity, fun, polish and anything that looks unfinished or obviously AI-made, and lists its top 10. Fix the quick ones.
4. Write docs/release/rc1_notes.md (what's in it, known issues, how playtesters report bugs). Put the zip where the owner can find it, and tell him the path.

## Part 3 — itch.io page kit, final
- Re-check docs/release/itch_page/ against the current game:
  - descriptions;
  - features;
  - controls;
  - the measured system requirements;
  - tags;
  - the AI disclosure;
  - "Free, donations welcome".
- Pick the 8 best screenshots from the new art (the Gallery, the classroom trivia, the Wardrobe, Dex, the Card Packs page, a battle, a story still, the Capital).
- **A short gameplay trailer (30-60 s):** capture clips with the play driver (Godot's movie writer, or frame capture), cut them together with ffmpeg, add the game's own music, and write title cards in the UI font. Keep it simple and honest. If ffmpeg isn't available or memory is too tight, leave a shot list and capture script instead.
- Update docs/release/itch_upload.md with the exact files to upload.

## Part 4 — Handover and the post-1.0 plan
- **Finalise docs/HANDOFF.md:**
  - the steps to build, test, export and upload, checked against what you actually did today;
  - the art, music and dialogue pipelines;
  - the six small-prompt templates for the $20 Claude plan.
- **docs/release/post_1_0_backlog.md:** the prioritized backlog for after launch:
  - playtester feedback intake;
  - known issues;
  - the remaining art REDOs;
  - nice-to-haves;
  - Steam readiness (what a Steam release would still need: achievements from feats, Steamworks, the store assets).
- Make sure everything is pushed to GitHub, and write the one-line backup command (a repo zip to Drive) into HANDOFF.md.

## Finish
- All test shards green.
- docs/overnight_report.md, with at the top:
  - an import table (with screenshots);
  - the Pip pick;
  - other Sable images found;
  - the exported-build issues found and fixed;
  - the critic's top 10;
  - where the RC1 zip is;
  - the trailer status;
  - what the owner does next (itch page, playtesters).
- Commit and push. No public upload.
