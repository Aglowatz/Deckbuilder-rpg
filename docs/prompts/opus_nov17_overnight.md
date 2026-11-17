# Overnight Nov 16-17 (Opus): a harsh but fair critics' panel, a full playthrough, then fix what matters

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The 1.0.0 zip is built (Nov 16 19:23) and every test is green. The owner releases it soon on itch.io for free. **Tonight's goal is to find the weakest parts of the game honestly and fix as much as can be fixed safely.** The owner is asleep.

Read first:
- the top of docs/overnight_report.md (Fable Nov 16 evening, day, and Overnight Nov 16);
- docs/overnight_inbox.md ("Fable Nov 16c", "Fable Nov 16b", "Overnight Nov 16");
- docs/review/critic_nov16/;
- docs/writing/story_bible_v2.md;
- docs/art/path_icon_style_guide.md.

Run `git status` first; if anything is uncommitted, run the tests and commit it. Log questions under "Overnight Nov 17". Tag `pre-overnight-nov17`.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:**
  - ONE Godot at a time, the critics' included: while a critic plays, nothing else of yours runs Godot;
  - critic sub-agents run **one at a time**;
  - `tools/run_tests.sh --min-free=900`; tests run under the save guard.
- Commit and push after each part. No public upload.
- Shots go in docs/overnight_shots/nov17/; critic reports in docs/review/critic_nov17/.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - Primm's fight unchanged (numbers and rules);
  - no new painted art (log art needs as Batch 17 rows);
  - no broad dialogue rewrite: fix single lines only where a critic finds them confusing or wrong, and save an IDs file for `--revert`;
  - don't reverse any recorded owner decision (CLAUDE.md, the inboxes' answered items).

## Part 1 — The facts first: a full playthrough with no shortcuts (about 2 h)
Earlier critics jumped ahead with snapshots and debug states, and **no one has played from a new game to the credits in one save.**
- Use the play-script driver (`docs/HANDOFF.md`, `_logs/full_play` and the story playthrough tools) to play **one complete game**: a new game → the cave → Crosspath → all four Path zones and their main dungeons → the Capital → Primm → the ending → **the credits** → the first postgame step.
  - Combat may be auto-resolved by the driver's battle bot, but no state may be set by debug commands.
  - Pick the Path the bot plays best; note the others' early-game difference from the sims.
- **Log every place where:**
  - progress blocked, soft-locked or needed a guess;
  - a quest marker pointed wrong or vanished;
  - the camera, walls or props trapped the hero;
  - a fight was unwinnable or trivial;
  - a scene's text and picture disagreed;
  - gold, levels or cards fell behind what the next area expects.
- Note the time per chapter and the level and gold at each boss.
- Report docs/review/critic_nov17/playthrough.md, then fix every blocker before Part 2.

## Part 2 — The harsh critics' panel (one at a time, about 4-5 h)
Six fresh no-context critics, each with **one brief and no repo or report access**, on the **exported** build (export a test pack first). Brief each one:
- to be **harsh but fair**, like a reviewer who has played many indie deckbuilders and RPGs (Slay the Spire, Inscryption, Octopath Traveler, Sea of Stars);
- to score 1-10 against that bar, not against "good for a small team";
- to list its **top 10 problems with severity (blocker / major / minor) and one concrete fix each**, and three things that work and must not be lost.

Use snapshots only to start each sitting at its section, then play for real.

| # | Lens | What it plays | Why it's on the list |
|---|---|---|---|
| 1 | **Combat and deckbuilding: the core fun** | Twelve fights across three zones and two Paths, a main dungeon start to finish, the Deck Station, packs and the card shops | **Fun has never scored above 6** in any sitting. Is it the decisions, the pace, the enemy AI, card balance, how rewarding new cards feel, or deck building? |
| 2 | **The late game and the ending** | The Capital, the Crease, the tunnels, the castle, Primm (to the win), the ending, **the credits**, the postgame start | **Clarity 5** last night; no critic has ever reached the credits; "nothing tracks the ending after Primm" |
| 3 | **The story and the writing** | Read the main story in order (every cutscene, memory and main quest conversation, via the dialogue export plus a few played scenes): the emotional arc, the voices, the clarity, the payoffs | The blind readers rated the rewrite about even with the old text, and the main story's old text was slightly preferred |
| 4 | **The world's look: an art director** | The 113-shot set from Nov 12 plus every area changed since (the Buffet, the Dump, Crosspath, the D.N.A. wasteland, the Capital, the Crease) | It's been 6.2 since Nov 12, and the 3D world has scored lower than the painted art |
| 5 | **The first 30 minutes and the menus** | A new player from the title: the settings, the cave, the tutorials, the first fights, Crosspath, the shops, the map, the quest log, the controller | The first impression decides whether an itch player stays |
| 6 | **The new card games** | Reps, Order Up, Sort It Out, File in Order and the card quiz in all four zones, each played to a win and a loss, with a mouse and a controller | Built today, never played by a person |

After each sitting, save its report as docs/review/critic_nov17/0N_<lens>.md. Before the next critic starts, kill any stray Godot.

## Part 3 — Triage and fixes (the rest of the night, until about 1.5 h before you stop)
1. **One triage table** (docs/review/critic_nov17/triage.md): every issue from Parts 1 and 2. For each, the lens, severity, reach (how many players hit it), effort (S/M/L), "owner decision needed?", and a plan.
2. **Fix in this order:**
   - blockers;
   - majors that most players hit;
   - S/M items in the core loop (combat feel, rewards, clarity of rules and goals);
   - the rest of the S/M items.

   Stay within the owner's constraints. For **combat fun**, prefer feel and clarity fixes (feedback, pacing, readable enemy turns, reward moments, a bad card buffed or a dead card made useful) over rebalancing the whole economy. If a number changes, re-run the sims and report the turns and win rates before and after per Path. **No Primm changes.**
3. **Known items to fix tonight** (the owner's defaults, unless a decision in the inbox says otherwise):
   - **The card quiz header** shows each zone's own name ("Fitness Theory Exam", "Compliance Re-Certification" ...), not "Card Quiz" (inbox Nov 16c item 25).
   - **The freed Capital still flies the smiling-sun banners** on its wall: after `primm_defeated`, use the freed banners (CAP-BANNER-FREED-*) there too.
   - **After Primm falls**, the tracker keeps a clear goal: "See the ending" → after the credits, a postgame quest pointing to the Lab and the Gallery, with map markers.
   - **The four old zone smokes** (`run_fifth` … `run_eighth_brief_final_smoke.sh`): delete them, since `run_card_games_smoke.sh` covers that ground. Update the docs.
4. **L items:** don't start them. Write each as a short plan the owner can hand to Claude later on the smaller plan.

## Part 4 — Re-check what changed (about 45 min)
- Re-run critic 1 (combat) and critic 2 (the late game) briefly on the fixed build, with **the same briefs and fresh agents**.
- Give each 3 of the first round's screenshots and scores as an anchor, so the scores are comparable.
- Report before and after.

## Part 5 — Tests, build, the verdict
1. All test shards green, plus the walk smokes, the NPC visibility probe and the card-games smoke.
2. **Export 1.0.0:**
   - wait up to 10 minutes for at least 2.2 GB free RAM, otherwise use `EXPORT_LOW_MEMORY_OK=1`;
   - `bash tools/export_windows.sh 1.0.0`;
   - then the exported smoke and the three `play_exported.sh` checks.
3. **docs/overnight_report.md**, with at the top:
   - **the verdict:** each lens's scores, before and after; the three weakest parts of the game right now, in plain words; and "would you ship this tonight, and why?";
   - the playthrough's facts: time per chapter, level and gold at each boss, every blocker and its fix;
   - what was fixed (with shots), and what wasn't;
   - **the owner's decisions:** every item that needs his taste or a rule change, each with a recommendation, at most 12, most important first;
   - the L-item plans;
   - the Batch 17 additions;
   - where the zip is.
4. Commit and push. No public upload.
