# Fable Nov 12 (2-hour pass): fresh eyes, broken checks, RC6

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). Read the top of docs/overnight_report.md (Fable Nov 12c) and
docs/overnight_inbox.md, "Fable Nov 12c". **Time box: about 2 hours. Stop adding work at 1 h 45 m and finish Part 5.**
Log questions under "Fable Nov 12d". Tag `pre-fable-nov12d` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:** ONE Godot at a time; no sub-agents while Godot runs; use `tools/run_tests.sh --min-free=900`.
- Commit and push after each part. No public upload.
- Shots go in docs/overnight_shots/nov12d/.
- **Owner constraints:** no difficulty setting; the battle board and the menus keep their layout; no new art; Primm's fight unchanged.
- **Owner decisions on inbox "Fable Nov 12c":** keep everything as built (the shafts as floor hatches, the ladder and the tunnel, "Under the Capital", the castle-only room reveal, the vellum pop-ups, the shrine's "Leave it").

## Part 1 — The three failing checks (about 25 min)
1. **The opening-hour smoke (`run_playtest_smoke.sh`):**
   - update its quest check to the real design (Fragments is active from `trial_cleared` since Nov 7);
   - then go through the eleven later checks one by one. Fix the game where it's wrong and the smoke where it's out of date, and log which was which.
2. **The controller smoke's "Y hides the card details"** in the ghost duel: find out whether the game or the smoke is wrong, and fix the right one.
3. **Corwin Bale**, the strolling citizen who walks behind a house on the avenue: keep his stroll in open view, so the NPC visibility probe passes 50/50.

## Part 2 — A fresh no-context playtest of the new build (about 50 min including fixes)
No fresh pair of eyes has seen today's changes. Run one no-context critic on the dev build, with the fixed driver, in two runs:
1. **A new game through the first hour:**
   - the tutorial cave, including the Hollow Well (take the offer once) and a shrine;
   - the new pop-ups and the pre-fight panel;
   - the Cave Warden and his closing words;
   - the first exit into Crosspath;
   - the first quests up to choosing a Path.
2. **From the `c12` / Capital-arrival snapshot:**
   - reaching the Capital;
   - "Under the Capital", from the quest through the manhole into the Crease;
   - the Black Market;
   - the Capital's edges and the Transit Yards.

It scores clarity, fun and polish, and lists its top 10: anything broken, confusing, ugly or obviously AI-made. **Fix every S item and as many M items as fit;** log the rest.

## Part 3 — Two known visual leftovers (about 20 min)
1. **The pale "ghost" building at the top left of the Transit Yards view**
   (`docs/overnight_shots/nov12c/partc/capital_before_transit_yards_default.jpg`):
   - find what it is (a backdrop card, a far LOD, a missing material, a fog-free mesh) and fix it;
   - re-shoot the same camera.
2. **Map edges and voids in the other zones** (Part C item 4, done only for the Capital and the Crease):
   - shoot each zone's edges at the default and Low cameras: Crosspath, the forest, the Gainlands, the Buffet, the Dump, the D.N.A.;
   - close any void, strip or bare edge with existing kit dressing and fog;
   - do as many zones as fit, worst first, and list what's left.

## Part 4 — If time is left: cheap world motion
In this order, each one small:
1. pickups bob and glow;
2. chests animate open;
3. one ambient-life effect per zone from existing particles: birds or dust in the Gainlands, steam in the Buffet, spores in the Dump, paper motes in the D.N.A.

Low-end turns them off. Check FPS on Medium in the Capital and Crosspath after each one.

## Part 5 — Tests, RC6, report (start by 1 h 45 m at the latest)
1. All test shards green.
2. **RC6:**
   - wait up to 10 minutes until free RAM is **at least 2.2 GB** (the owner closes Chrome and ChatGPT before this run);
   - then, in the **foreground**, run `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6`;
   - then `bash tools/run_release_smoke_exported.sh`, then `bash tools/export_test_pack.sh` and the three `play_exported.sh` checks (0 SCRIPT ERROR each).
   - If it's still under 2.2 GB, don't start: log it, and keep the owner's command at the top of the report.
3. **Settings:** set this PC's Settings > Display > Camera angle back to the game's default (the shot scripts left it on "Low"), and the zoom to 1.5.
4. **docs/overnight_report.md**, with at the top:
   - the three checks (fixed in the game or the smoke);
   - the critic's scores and top 10, with what was fixed;
   - the Transit Yards and edge results with shots;
   - any motion added, with FPS;
   - **where RC6 is, or the exact command if it wasn't built**;
   - what's left before 1.0.0.
5. Commit and push. No public upload.
