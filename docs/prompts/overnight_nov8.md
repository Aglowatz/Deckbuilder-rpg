# Overnight Nov 8-9 (Fable) — ship-readiness: stability, art audit, cut-or-finish, release checklist

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path").

**Context:**
- The owner ships **1.0 on itch.io, free, with optional donations** this week (Steam later if people want it).
- His heavy tooling ends on Nov 12; after that it's a $20 Claude plan and a $20 ChatGPT plan.
- Tonight finds everything between the game and a stable, polished, shippable 1.0, and fixes the blockers.

Work autonomously. The owner is asleep. Log questions in docs/overnight_inbox.md under "Overnight Nov 8-9". Tag `pre-overnight-nov8` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- 7.4 GB RAM:
  - ONE Godot process at a time; kill strays before starting;
  - at most 2 sub-agents, never while Godot or the tests run.
- Tests: memory-safe shards (`bash tools/run_tests.sh --only=tests --size=12`, `--from=N` after a low-memory stop).
- Play through `bash tools/play.sh` from a hard-linked HEAD worktree. Screenshots go to docs/overnight_shots/nov9/.
- Commit after each part; push when GitHub is reachable.
- **No export.**
- Do not edit or replace art files tonight (the audit only lists).
- **Make no cut decisions** (Part 3 only recommends).

## Part 0 — Make sure the import finished
Read the last report (import_nov8). If any of its parts are unfinished (Batch 13 import, quick wins, Capital cache, tests), finish them first.

## Part 1 — Can every player finish the game? (the top priority)
1. **Quest completability check, static.** Write tools/quest_audit.gd: walk the quest data and build the graph of every quest and step, what starts it, what completes it, and where its NPC, trigger, item or enemy lives. Flag:
   - unreachable steps;
   - missing NPCs or triggers;
   - steps gated on flags nothing sets;
   - rewards pointing at missing items;
   - quests that can be broken by doing things out of order (e.g. beating a gatekeeper early).

   Fix what it finds and add the tool to the test suite.
2. **Full playthroughs, dynamic.** For each of the four Paths, run the play bot from a new save to the credits and into the postgame (Lab rescue, the Gallery entrance, Swolympus).
   - Real fights by the bot. Dev help only to skip pure walking time when the bot's pathing stalls, and note every place you had to.
   - Save and load at every zone change, and once mid-dungeon (the dungeon must correctly restart per the rules).
   - Log every softlock, stall, error, missing prompt or wrong state.
3. **Robustness:**
   - load each old save in tools/fixtures (if any) and the snapshots from this week;
   - quit during a battle, a cutscene, a shop and a dungeon, then reload;
   - a 90-minute soak walking zones and fighting, watching memory and the error log;
   - every exported scene loads without errors in the log.
4. **Fix every blocker found** (softlock, crash, unfinishable quest, broken save). List anything you can't fix.

## Part 2 — Full art audit (the owner's main objective tonight)
Goal: find every image a **casual player would spot as obviously AI-made**, every image that **doesn't make sense for the story**, and every image that is **bad or easily improved**.

**Scope:** every image the game shows:
- card art (all cards);
- portraits, cut-ins and sprites;
- story stills;
- battle boards and dungeon maps;
- UI backgrounds and icons;
- zone kit props, textures and backdrops;
- loading screens and key art.

**Method:**
1. Build contact sheets per category (docs/art/audit_nov9/sheets/). Then review every image at a readable size with your own eyes: use sub-agents for batches, but you check each flag.
2. Check each image for these things:
   - **AI tells a casual player notices:**
     - hands with wrong finger counts or fused fingers, broken anatomy, extra limbs;
     - garbled pseudo-text or glyphs on signs, books, banners, labels and cards;
     - melted or smeared detail, objects merging into each other;
     - impossible perspective or architecture, nonsense symbols;
     - mismatched eyes or faces, inconsistent lighting within an image;
     - a "plastic" over-rendered look that clashes with the painted style.
   - **Narrative sense:**
     - does it match the character's other art (face, species, outfit, colours; Flex is always a lion, and so on);
     - does it match the zone and Path palette, the card's name and rules text, and the moment in the story;
     - a character appearing where they shouldn't, the wrong number of people, a scale error (e.g. a giant Primm).
   - **Quality:** low-res or blurry, bad crops, cut-off heads, inconsistent style with its neighbours, readability at in-game size, and duplicated art used for different things.
3. For each flagged image, give:
   - its id and file;
   - where it's seen, and how often (visibility: 1 rarely to 5 constantly);
   - the problem, with a crop or screenshot showing it;
   - severity (glaring / noticeable / minor);
   - **a verdict:**
     - KEEP;
     - FIX IN CODE (crop, mask or overlay that hides the flaw, with no new art);
     - REDO, with a ready image description in the art-list format plus the reference images needed.

**Outputs:**
- docs/art/art_audit_nov9.md: a summary, the worst 25, and per-category findings;
- docs/art/art_audit_nov9.csv: every flagged image;
- **a ready Batch 14 list:** the REDO rows sorted by severity × visibility, in the art-list columns, so the owner can generate them in ChatGPT tomorrow in one go.

Do not change art tonight.

## Part 3 — Cut or finish? (analysis only, no decisions)
Inventory every feature and content piece:
- each zone, dungeon and side dungeon;
- each minigame, including Dex's matching circuit;
- the postgame (Lab, Gallery, Swolympus);
- crafting, the Wardrobe, feats, the Bestiary and the arena;
- quests by line, and each system (items, equipment, packs, the economy).

For each, rate:
- completeness;
- known bugs;
- polish against the Deck Station and Character page bar;
- whether it plays end to end;
- the effort to make it 1.0-solid (S/M/L).

Write docs/release/cut_or_finish_nov9.md:
- a table;
- a **recommendation** for each (keep as is / finish, with the effort / hide for 1.0 and add later), with the reason;
- the total effort of the recommended "finish" list against the 3 remaining days.

Change nothing based on it.

## Part 4 — Release checklist (what players expect from a free itch.io 1.0)
Audit, and write docs/release/ship_checklist.md with a status for each item.
- **Settings:**
  - master, music and SFX volume;
  - resolution, fullscreen and vsync;
  - key rebinding and controller support;
  - text speed;
  - the camera options;
  - Low-end mode.
- **Accessibility:** readable text size, a colour-blind-safe check of Path colours and the important states (don't rely on colour alone), and subtitles and captions for any voiced or audio-only cue.
- **Saves:** save slots, auto-save with an indicator, safe quitting, and pause anywhere.
- **Legal and credits:**
  - credits and licences: Godot's licence notice, fonts, the FluidR3 soundfont, any third-party code;
  - a plain **AI-generated content disclosure** draft (art via image generation, music generated with tools, writing assisted by AI) for the itch page and the credits.
- **Release basics:**
  - a version number on the title screen;
  - a log file in the user folder, with a "Copy log / open log folder" button in Settings for bug reports;
  - a crash-safe start (missing settings file, corrupt save, and so on).
- **Donations:** a "Support the game" button in the title menu and on the credits screen that opens a URL from a config file. Leave the URL empty, and hide the button until it's set.
- **itch.io page kit (docs/release/itch_page/):**
  - a short and a long description;
  - a features list;
  - controls;
  - system requirements (measure them);
  - 8-10 screenshot picks, captured in game at 1920x1080 from the best-looking moments;
  - a cover image recommendation from the existing key art;
  - tags.

**Implement the small, safe standard items tonight:** version number, log file and button, credits and licences, the disclosure draft, the hidden donation button, crash-safe start, and any missing volume slider. List the bigger missing items with an effort.

## Part 5 — Text sweep
- Fix every typo, double space, and wrong or inconsistent name (the canonical names are in the design sheet export and story_voice_nov5.md). Also leftover dev or debug text visible to players, "TODO", and placeholder "???" outside the intended spoiler-hiding.
- List (don't fix) story-level contradictions you find.
- Fix by revertible dialogue pass where the text lives in the dialogue data.

## Part 6 — Handover draft (finalised on Nov 11)
Write docs/HANDOFF.md for an owner who after Nov 12 has a $20 Claude plan and a $20 ChatGPT plan: light sessions, no all-night runs, a smaller context. Cover:
- **Where things are:** the repo map and the key files.
- **How to play, test (a lightweight subset), export and upload** to itch.io (butler or the web uploader), step by step.
- **The art pipeline:** ChatGPT, then Drive Approved_*, then the import command; the style locks; the naming.
- **The music pipeline** (tools/music) and the **dialogue workflow** (CSV to sheet to apply).
- **How to write small, safe prompts** for a $20 plan, with 6 templates: fix a bug, tweak a card, add a quest line, import one image, edit dialogue, make a release build.
- **Known issues and a prioritized post-1.0 backlog.**
- **Backups:** GitHub, plus a Drive copy of the repo.

## Finish
- All test shards green.
- docs/overnight_report.md, with at the top:
  1. **Ship blockers:** found / fixed / still open.
  2. **Art audit:** the counts and the worst 10, with a pointer to the Batch 14 list.
  3. **Cut-or-finish recommendations** in one table.
  4. **Release checklist status:** what was implemented tonight and what remains, with effort.
  5. **A recommended plan for Nov 9-11** to reach 1.0 (daytime and night runs, and what the owner does).
- Commit and push. No export.
