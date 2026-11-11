# Overnight Nov 10-11 — wayfinding everywhere, fight pacing, late-game check, RC4

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). The 1.0 target is a free itch.io release. The owner is asleep.
Read docs/overnight_report.md (Fable Nov 10) and docs/overnight_inbox.md ("Fable Nov 10" items 1-14) first. Work in order (priority order).
Log questions under "Overnight Nov 10-11". Tag `pre-overnight-nov10` at the start.

## House rules
- STOP_OVERNIGHT check before each part.
- Memory:
  - ONE Godot at a time; kill strays first;
  - no sub-agents while Godot runs;
  - stop a job cleanly if free memory drops under ~800 MB.
- Tests: run shards one at a time, with a free-memory check before each.
- Screenshots go to docs/overnight_shots/nov11/.
- Commit and push after each part. No public upload. Don't replace art files.
- **Owner constraints:**
  - No difficulty setting.
  - **No battle-board or UI layout changes.** Small text/label and stacking tweaks inside existing elements are allowed where stated below.
  - Primm stays as is.

## Owner decisions for the open inbox items
1. Hidden stashes marked while a quest step asks for one: **keep** (inbox 1).
2. The Verdant Dump herd: **move the two animals that graze across the stream (animal_1, animal_3) to the Commons side**, so Billie's herd quest can be done before the first crossing (inbox 10).
3. The D.N.A.: **mark the Hall's door from arrival**, and let the dungeon step show it at once; the favour stays a recommended side step (inbox 12).
4. The Capital's secret wall hole: **keep** (inbox 7).

## Part 1 — The exported-build critic's top 10 (inbox 14)
1. **The main quest's dungeon step names its gate.** Each zone's "Where to go" text says what opens the way, e.g. "Sir Loin's gate wants Old Meatloaf mended — see Basil". Do every zone.
2. **No roamer camps a door:** keep roamers' wander areas at least ~10 m from dungeon doors, gates and zone exits in every zone, and add a check.
3. **Fight length:** see Part 3.
4. **The boss's token swarm:** stack identical tokens into one card with a ×N count (inside the existing row, no layout change).
5. **Setting Up during the fight:** add words next to the existing hourglass ("Setting Up — attacks start Turn N").
6. **Toasts:** last 5-7 s, or until clicked, instead of 20-30 s.
7. **E prefers the quest NPC** over plaques and props when both are in reach.
8. **The "Point me to..." list:** stable order (current goals first, then places alphabetically).
9. **The "has a favour to ask" toast** disappears once you accept the favour.
10. **Escape** closes the top pop-up or dialogue first, and only opens the pause menu when nothing else is open (also inbox 8).

## Part 2 — Wayfinding in every zone, proven
The wayfinding critic reached 1 of 4 main dungeons before last night's fixes (Gainlands 2/10, Dump 3/10). Only the Buffet was re-tested.
1. **Speed up the Dump's arrow** (inbox 11): use a coarser walk grid there or plan on a thread, so the route arrow follows the path within about 1 s.
2. **Re-run a no-context wayfinding critic** (fresh brief, no hints) on the exported build in **the Gainlands, the Verdant Dump and the D.N.A.**
   - Each run starts from arrival and must reach the main dungeon door using only the game's guidance. No dev travel.
   - Report the minutes taken and every point of confusion.
3. Fix what it hits, then re-run the zones that failed until each is reached in under about 20 minutes, or log why not.

## Part 3 — Fight pacing (ordinary fights)
The critics' ordinary fights (roamers and dungeon rooms, levels 10-20) run 9-11 turns. The target is about **5-7 turns** for ordinary fights. **Bosses, elites, gatekeepers, Primm and the Gallery are unchanged.**
- Find the cause with the sims and a hand-played sample: enemy HP, early board stalls, not enough damage, or energy flooding.
- Apply the smallest fix that works (e.g. ordinary-enemy HP down 15-20% from the midgame on, or a little more early pressure on the player's side). Keep win rates about where they are.
- Report turns and win rates before and after per Path.

## Part 4 — Late-game check on the exported build
Re-save the `c13end` / `c13post` snapshots (inbox 6 from Nov 10) so they really sit after Primm and after the credits.

Then a no-context critic plays the Capital, Primm's castle, the **real Primm fight** (with the new turn count and 3 Militia), the ending, the credits and the start of the postgame (Lab, Gallery entrance), on the exported build. It scores clarity, fun and polish against the old 5/4/5 and lists its top 10.

Fix the S/M items (within the owner's constraints) and log the rest.

## Part 5 — The test runner's memory guard (inbox 13)
Add `--min-free=MB` (default 900) to tools/run_tests.sh: before each shard, wait (up to a timeout) until free RAM is above it, instead of being killed. Document it in docs/HANDOFF.md.

## Part 6 — RC4
- Export `bash tools/export_windows.sh 1.0.0-rc4`, then run the release smoke and the exported-build checklist.
- Write docs/release/rc4_notes.md.
- Report the path.

## Finish
- All test shards green.
- docs/overnight_report.md, with at the top:
  - the critic fixes;
  - the per-zone wayfinding results (minutes, before and after);
  - the fight-pacing table;
  - the late-game critic's scores and top 10;
  - where RC4 is;
  - **a release-day checklist for the owner for Nov 11** (set the version to 1.0.0, export, smoke, the itch upload steps, the donation link, flip to Public).
- Commit and push. No public upload.
