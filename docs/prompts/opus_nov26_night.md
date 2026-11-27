# Nov 26 night: balance audit of drafts and equipment, postgame solution hunt, bug soak, small fixes

Repo: C:\Dev\Deckbuilder-rpg. This run is on Opus, overnight, with the owner asleep. Work without stopping to ask. Log questions under "Nov 26 night" in `docs/overnight_inbox.md` and take the safest choice.

Read first:
- the top of `docs/overnight_report.md` ("Nov 26 day");
- `docs/design/draft_mode.md`;
- the ban tables and sim runners from Nov 23 and Nov 24 (`docs/design/sim/`).

Run `git status` and tag `pre-nov26-night`.

House rules are as in `docs/prompts/opus_nov26_day.md` (STOP_OVERNIGHT, one Godot at a time, `--min-free=1200`, sims batched at most 30 variants with a 20-minute limit, commit and push after each part, no public upload, the owner constraints, a test for every change). Shots go in `docs/overnight_shots/nov26n/`; sims go in `docs/design/sim/nov26n/`.

**The big rule for tonight:** balance findings are **proposals for the owner**. Don't change card, equipment, item, mode-reward or postgame numbers. **Bugs, softlocks, script errors and unclear text** are fixed, each with a test.

## Part A — Small fixes
1. **Brother Bramble's name plate** (the Dump, by the stream) is hidden by the bridge bunting at the low camera. Lift the bunting about half a metre, or move him a little. The NPC probe must pass.
2. Nothing else from the day's "What's left" needs doing.

## Part B — The draft balance audit (all four modes and zone drafts)
1. **Run large batched draft sims** with the AI drafting like a player:
   - Classic with every single Path and every two-Path pair;
   - three- and four-Path where they unlock;
   - High Rollers;
   - Mystery Mini;
   - each zone draft.
2. **Report:**
   - **per card:** pick rate, the win rate of decks that hold it, and the win rate change when it's added (with enough games to mean something);
   - **per Path and Path pair:** draft win rates;
   - **per equipment piece and item in the draft pool:** how often it's offered and taken, and the win rate change with it. Include the 12 newer draft pieces, the Extra Pocket now that it really works, and the Hover Boots at High Rollers;
   - **mode rewards against the economy:** gold, XP and packs per hour for each mode against the main game's dungeons. Is any mode a farm that breaks the economy, or not worth playing?
3. **Write `docs/design/sim/nov26n/draft_balance.md`:**
   - the top 10 overperformers and the 10 dead cards;
   - the strongest and weakest Path pairs;
   - gear outliers;
   - for each, a concrete **proposed** change (one number or one line of text), with a sim of the proposal so the owner can see its effect.
   - Apply nothing.

## Part C — The main-game equipment and item audit
1. **List every piece of equipment and every item:** where it's found, its rarity, its effect, and whether its text is clear.
2. **Sim each piece on the reference decks** across the zone dungeons and the castle. Find:
   - must-takes;
   - dead pieces;
   - pieces that don't work or barely do (bugs: fix them with a test);
   - combos that break a fight (for example with the Extra Pocket).
3. **Write `docs/design/sim/nov26n/equipment_audit.md`** with proposals per slot: buffs for dead pieces and nerfs for outliers. Proposals only.
4. **Fix only text** that's wrong or unclear, and keep the one display order (name, slot and rarity, effect, flavour).

## Part D — The postgame solution hunt (no postgame changes)
The owner wants the postgame to be hard but beatable with one of a few strong strategies. Find out whether that's true.

1. For each postgame fight (the Lab, the Gallery, Swolympus, the Warden), **search for winning builds:**
   - decks from the full card pool a late-game player could own, including drafted cards;
   - the five equipment slots and four items chosen to counter the fight's rules;
   - Silver Reserve boons.
   Use the improved sim player, and give it event boons where a route offers them.
2. **Write `docs/design/postgame_strategies.md`:**
   - for every fight: the builds that win (deck outline, equipment, items, how to play it) and their win rate;
   - for every whole dungeon: the best route and build, with its clear rate;
   - **fights with no winning build found:** list them clearly; those are the owner's real balance problems.
3. **Proposals only.** Don't change the postgame.

## Part E — Bug soak (the exported build and the editor build)
1. **Long random-play sessions:** a bot clicks through every screen and mode (the Shuffle House's four modes and the Halls, zone drafts, the deck builders, shops, Alembic, Pip, the Bestiary, dungeons, events, saves and loads) with random but valid choices. Do several seeds, hours in total, in batches of at most 30 minutes, one process at a time.
2. **Catch:** script errors, softlocks (no valid input), stuck screens, UI off-screen at the 1280x720 and 1920x1080 window sizes, missing art (placeholder or magenta), and text overflow.
3. **Fix each with a test.** List anything you can't fix in the report.
4. Keep the seeds, logs and the first frame of each problem in `docs/overnight_shots/nov26n/soak/`.

## Part F — Checks, build, report
1. All test shards green (small groups); the draft smoke; the walk smokes; the probes; the four story bots one after another.
2. **Export 1.0.0 only if anything in the game changed:** run `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`, the exported smoke and the three `play_exported.sh` checks.
3. **`docs/overnight_report.md`,** at the top, under "Nov 26 night":
   - each part done or not;
   - the bugs found and fixed;
   - the headline balance findings (the 5 most important, in plain words);
   - the postgame strategy summary (which fights have a winning build and which don't);
   - the proposals, grouped so the owner can answer yes or no to each group;
   - the zip, if exported;
   - the owner's decisions needed (at most 6, each with a recommendation).
4. Commit and push. No public upload.

If time or usage runs short, finish the part in hand, commit, and write the report with exactly what's left. Parts B and D are worth more than a full Part E.
