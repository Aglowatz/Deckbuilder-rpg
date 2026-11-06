# Critic pass — Nov 6 (Opus) — find the biggest-impact improvements

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Goal: a whole-game critic pass that ends in ONE ranked list of the
improvements that would make the game better for a real player. **This is a review pass: do not fix things**, except a blocker that
stops a critic from playing on (fix it minimally, note it). Work autonomously; log questions in docs/overnight_inbox.md under
"Critic Nov 6".

## House rules
- STOP_OVERNIGHT check between critics.
- 7.4 GB RAM:
  - ONE Godot process at a time;
  - critics run ONE AT A TIME (sequentially), each a fresh sub-agent with no context beyond its brief;
  - never a sub-agent while Godot or the tests run.
- Critics play from a fresh hard-linked HEAD worktree with `bash tools/play.sh`. Screenshots go to `docs/review/critic_nov6/<critic>/`.
- Each critic writes `docs/review/critic_nov6/<critic>.md` with these sections:
  - summary;
  - scores (fun, clarity, difficulty, text, look, out of 10);
  - findings, each with a screenshot or line ID, severity (blocker / major / minor) and a suggested fix;
  - "what's great, don't touch".
- Commit and push after each critic. No export.

## Part 0 — Make sure it's current
- If the Batch 12 art (G:/My Drive/Card Game Art/Pending Review/Batch 12, 84 images) is not imported yet, import it first. Follow docs/art/import_nov5_ready.md, then:
  - wire the 3 townsfolk into Crosspath;
  - hook up Figsly's painted sprite;
  - put STORY-PRIMM-FALL back in place;
  - run the tests, then commit.
- Then write a short brief for each critic in `docs/review/critic_nov6/briefs/` (what to play, where to start, what to look at). Give critics only that brief: no design docs, no reports, no hints about known issues.

## The critics (in this order)

**Play critics.** Dev rule: only `dev newgame / save / load` unless the brief says a start snapshot.
1. **C1 First hour** (new save, Beefcake: the last critic picked Necrocrat). Play by hand:
   - the opening and the tutorial cave;
   - Crosspath and Tilly's item lesson;
   - Meet the Merchants and the first shop visits;
   - the Character page;
   - the road out to the gatekeeper.
   Judge onboarding: does a new player know what to do and why, and is it fun?
2. **C2 First zone and first main dungeon** (Refusemancer, the hardest early Path, from a snapshot taken right after the tutorial cave).
   - Play the Verdant Dump's quests, gatekeeper, roamers and side content, then the Rotheart with dungeon fog.
   - Use the deck you'd really have, buying cards and items with the gold earned.
3. **C3 Midgame** (snapshot or `dev travel/level` to match the economy study's level and gold at that point; any Path).
   - Play two more zones' main lines, at least three side quests, Auntie Alembic's crafting, the Iron Cave, a pack shop and Pip's shop.
   - Judge pacing, variety and whether the story builds.
4. **C4 Endgame** (snapshot at the Capital's arrival). Play by hand:
   - the Capital, the Crease and the castle;
   - **Primm's real fight**, including the Model Room staging (the play driver stalled there last time);
   - the ending and the credits.
5. **C5 Postgame** (snapshot after Primm):
   - "Under the Forest" and the Lab / Elowen;
   - the portal station;
   - Mount Swolympus;
   - the Shattered Gallery, played for real (it can lose, but say whether that feels fair or cheap).

**Desk critics** (no play needed, or screenshots only):

6. **C6 Story and dialogue.** Read the main story in order, from the cutscene data and docs/dialogue/edit_nov5.csv, then a sample of 10 side quests.
   - Judge whether the kingdom's story is coherent, where the emotional beats land or fall flat, whether each main character's voice is distinct, and whether the humour works.
   - Cite line IDs.
   - List the 10 weakest moments, each with a rewrite direction (not a full rewrite).
7. **C7 UI, UX and visual consistency.** A screenshot tour of every screen and menu at 1280x720 and 1920x1080, plus Low-end mode.
   - Covers: battle, deck station, collection, shops, character page, map, quest log, dialogue, settings, pack opening, dungeon map, bestiary.
   - Look for clipping, readability, inconsistent styles, art that doesn't match its character, leftover placeholders, and controller/keyboard gaps.
8. **C8 Balance and economy.**
   - Run each Path's no-grind run through the existing sims (early_game_study, the gold study, encounter sims) and report the win-rate curve zone by zone.
   - Find card and enemy outliers (too strong / dead cards).
   - Check difficulty spikes and troughs.
   - Check the ZoneOrderEase results, and whether the Gallery's full run is beatable at all with Silver Reserve +40.
9. **C9 Tech and feel.** On the default and Low-end settings, measure:
   - load times (title, town, each zone, battle start);
   - peak memory;
   - stutters while walking in the Capital and Crosspath;
   - audio level jumps between cues;
   - any errors in the logs.

## Synthesis: `docs/review/critic_nov6_summary.md`
1. **Scorecard:** each critic's scores in one table, plus one paragraph on the game's overall state.
2. **Top 15 improvements, ranked by impact.** For each:
   - what it is;
   - who it hurts and when;
   - evidence (screenshots / line IDs / numbers);
   - the suggested fix;
   - effort (S = under 1 h, M = a few hours, L = a night or more);
   - **impact** (1-5, how much better the game gets) and **reach** (1-5, how many players hit it).

   Rank by impact × reach ÷ effort weight (S1, M2, L3), but put anything that stops or confuses a new player in the first hour at the top regardless.
3. **Quick wins:** every S-effort fix not in the top 15.
4. **Art needed:** any new art these fixes require, as rows in the art-list format.
5. **Don't touch:** what the critics loved.
6. **Decisions for the owner:** design questions only the owner can answer, each with a recommended default.

Before finishing, run one last sub-agent (no context) that reads the synthesis against the critic reports. It checks that nothing major was dropped and the ranking makes sense; fix the summary if it finds gaps.

Finish: commit, push, and put the top 15 at the top of `docs/overnight_report.md`.
