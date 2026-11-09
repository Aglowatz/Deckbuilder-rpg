# Day pass Nov 9 (Opus) — release prep while the art is generated

Repo: C:\Dev\Deckbuilder-rpg. Read docs/overnight_report.md (Overnight Nov 9) first. Same house rules as last night:
- one Godot at a time;
- memory-safe test shards;
- commit and push after each part.

1. **Credits:** the owner's name is **Alex Glowatz**. Put it in data/credits/credits.cfg as creator (game design, direction and production), and check the title-menu Credits page and the end credits. The donation link stays empty, so the button stays hidden.
2. **Decisions:** colour-blind Path symbols stay **on** by default, and **Dex's matching game stays in 1.0**. Close those inbox items.
3. **Level hints at the walls:** at each entrance where the bot hit a wall (Primm's castle, the Shattered Gallery, the 2nd and 4th main dungeons, the D.N.A. side dungeon S-NECRO, and any other main or side dungeon), show a soft hint: "Travellers here are usually around level N", from the progression model's expected level.
   - Show it in the dungeon prompt and the map tooltip.
   - Show it in amber when the player is 2+ levels under.
4. **The dark battle backdrop** seen in one "after" screenshot: check whether it's real (dev-started battle only, or every battle). Fix it if it's real.
5. **RC1 build:**
   - export `bash tools/export_windows.sh 1.0.0-rc1` and run the release smoke;
   - make docs/release/rc1_notes.md (what's in it, known issues, how to report bugs: the "Copy log" button);
   - put the zip on Drive at My Drive/Card Game Art/../Releases/ if that folder exists, otherwise tell the owner where it is.
6. **itch.io upload prep:**
   - write docs/release/itch_upload.md, step by step for the owner: create the project page; set it to Free with donations ("No payments", with "Accept donations" ticked); paste the page kit text; upload the zip; set Windows; add screenshots and the cover; Visibility: Draft or Restricted until release; then the public flip;
   - include the optional butler command line for future updates.
7. **Batch 14 import:** when the 17 images appear in `G:/My Drive/Card Game Art/Pending Review/Batch 14/`, import them following docs/art/batch14_nov9.csv:
   - remove the HELD_EXPRESSIONS holds for the fixed characters;
   - screenshot each image in game;
   - re-export RC1 if the import lands before the day ends (as 1.0.0-rc1b).

Report: docs/overnight_report.md (Day Nov 9 section at the top). No public upload.
