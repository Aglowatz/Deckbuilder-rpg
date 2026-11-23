# Fable: Draft mode, Phase 1 (after the Nov 22 night brief is finished)

Repo: C:\Dev\Deckbuilder-rpg. **Start only after `docs/prompts/fable_nov22_night.md` is complete,** committed and pushed. The owner is asleep: work without stopping to ask.

Read first: **`docs/design/draft_mode.md`** (the owner's agreed design: follow it exactly; where it says "default", use the default). Also read `docs/owner_backlog.md` and `docs/release/two_week_plan.md`. **The launch has moved back** to ship draft mode with 1.0; note that in the two-week plan, and rename it to the release plan if that reads better.

Run `git status`; if anything is uncommitted, run the tests and commit it. Log questions under "Fable draft phase 1". Tag `pre-draft-phase1`.

## House rules
The same as the Nov 22 night brief:
- STOP_OVERNIGHT check before each part;
- **memory first:** one Godot at a time; if the owner's Godot editor or game is open, wait or run what fits; `--min-free=1200`; tests in small groups; sims split into small runs;
- commit and push after each part;
- no public upload;
- no new painted art (rows in `docs/art/batch20.csv` instead);
- family friendly;
- the battle board layout stays;
- every rule gets a test.

## Part 1 — The draft engine (the rules in the design doc)
- **The Path choice:** set challenges fix the Paths; repeatable drafts let the player choose 1-4. Pathless cards are always offered. The multi-Path lock stays consistent: two-Path cards only after all four zones, three- and four-Path cards only after Primm.
- **25 card picks, one of three each:**
  - every 5th pick offers the top two rarities; the others are weighted by rarity;
  - offers lean toward cards that fit what's already taken, never three duds;
  - the screen shows the cost curve and the Path split.
- **Gear picks:** 5 equipment picks (a random slot each, three pieces weighted by rarity) after picks 4, 9, 14, 19 and 23; 2 item picks after picks 7 and 17.
- **All equipment and items** are in the pool, with an empty ban list in data.
- **One reroll per draft**, usable on any card, equipment or item offer; the number lives in data.
- **The deck:** 20 of the 25 drafted cards plus 15 basic Infrastructure, split automatically across the drafted Paths (the player can change the split). No copy limits (5-6 copies allowed), no 45-card minimum.
- **The player in a draft:**
  - base HP and hand size for their level;
  - only the drafted equipment and items (the main loadout is untouched and restored afterwards).
- **Saving:** a draft in progress (picks, offers, the reroll, wins and losses) is saved and resumes after quitting. Old saves still load.
- **A run:**
  - three fights, full HP each, ending at **3 wins or 2 losses**;
  - rewards for every result, rising with wins, a clear bonus for 3 wins, **much more the first time** each challenge is won;
  - after a full win, **keep one drafted card** in the collection;
  - **the fee:** 100 gold, with the first attempt at each challenge free.
- **Opponents:**
  - rival drafters (the AI drafts with the same system, with personalities: aggressive, controlling, swarming; existing NPC portraits and names);
  - **check they're competitive** by sim (aim for a fair fight, about 50-60 % for a sensible player draft);
  - fudge their decks if the AI drafts badly.
- **Screens:** Path choice, the pick screen (three cards with hover zoom, the reroll, curve and Path split, equipment and item offers in the same flow), the deck builder for the 35, the run screen (wins and losses, the next opponent), rewards (with the keep-one choice). Mouse and controller. Use the stained-glass theme and existing art.

## Part 2 — The travelling draft host and the four zone drafts
- **A new recurring character**, like Dex and Rip, who turns up in every zone (a spot in each zone hub; a map and minimap marker).
  - Give them a fitting pun name and a personality in the game's voice, in the story bible and the name registry.
  - Log the name as the owner's decision, with two alternatives.
  - Use an existing NPC look as a stand-in.
- **A zone draft in each zone:** that zone's Path plus Pathless, three fair fights. Solid rewards the first time, fair on replays.
- **The draft quest line:** an introduction (the first draft explains the mode through play), one quest per zone draft, and a finale when all four are beaten that **opens the Crosspath draft arena** (just the unlock and a teaser now; the arena itself is Phase 2).
  - Rewards: fun, powerful equipment, cards, gold, experience.
- **Equipment:**
  - design the reward gear (about 6-8 new, fun pieces);
  - **every new draft-related piece also exists in the main game** (vendors, chests or quest rewards; weaker pieces earlier and easier).
- **A few new cards:** design 4-8 fun, high-impact cards for draft pools (balanced for the main game too). Stand-in art for now.

## Part 3 — Balance and checks
- Simulate drafts (player and rivals, every Path, many seeds):
  - the rival win rates;
  - the reward value against the economy (the first wins and the replays);
  - equipment or items that break drafts. **Propose bans; don't apply them.**
- Play a full zone draft in each zone from a mid-game save. Shoot each screen.

## Part 4 — Art rows (Batch 20)
In `docs/art/batch20.csv` (self-contained descriptions under 600 characters, sizes, refs copied under 1 MB to `G:/My Drive/Card Game Art/Batch 20 Refs/`):
- the draft host's portrait, world poses and shop backdrop;
- the pick screen backdrop;
- the draft hall backdrop, if the cave arena menu can't be reused;
- the map marker;
- the reroll icon, if needed;
- the reward gear icons;
- the new cards' art.

**Plan the draft dungeon map for Phase 3** (rooms that shape the run: multi-Path card offers, planned hard-but-rewarding encounters, heals, buffs, curses):
- as a written plan in `docs/design/draft_dungeon_plan.md`;
- as a top-down plan image in the Refs folder;
- as a Batch 20 row to paint it.

## Part 5 — Tests, build, report
- All test shards green (small groups); the walk smokes; the probes; the four story bots one after another; a draft smoke (a full draft and run, automated).
- **Export 1.0.0 for the playtesters:**
  - only after the tests, with `EXPORT_LOW_MEMORY_OK=1` if needed;
  - `bash tools/export_windows.sh 1.0.0`;
  - the exported smoke and the three `play_exported.sh` checks.
- **Report at the top of docs/overnight_report.md under "Fable draft phase 1":**
  - what's built (with shots);
  - the host's name and the alternatives;
  - the new gear and cards;
  - the sim tables;
  - the proposed bans;
  - the Batch 20 rows;
  - the draft dungeon plan;
  - the zip;
  - the owner's decisions needed (at most 6, each with a recommendation).
- Commit and push. No public upload.
