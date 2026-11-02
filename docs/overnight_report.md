# Report - Fable pass Nov 1 (Fable 5.1): core gameplay + first hour + the designer's answers

Sun Nov 1 10:27 -> 18:45 MST. Tag `pre-fable-nov1` before the run. State `docs/loop_state.md`; questions `docs/overnight_inbox.md`,
section "Fable pass Nov 1". Last run's report: `docs/overnight/oct31n/overnight_report_oct31n.md`.

## Morning summary

| Part | State | Commits |
|---|---|---|
| 1 Healing | done: the Crease's tea and the castle Safe Room already existed - made findable and reachable; the Capital's hit toast names its source | 17042af8 |
| 2 Boss tempo + tuning | done: 2-turn setup window on every boss, Wild Growth capped at +3, 17 of 22 bosses in band (table below) | ad42c84d |
| 3 Progression | done: tier-scaled dungeon-clear XP bonus; expected player within +1 of the model | 2c0c7b6d |
| 4 Naming | done: Grand Chef / Doppelganger / Escoffina agree on every surface | dd9bd479 |
| 5 Freed roamers | done: damage roamers wander in peace once the zone is freed; the Capital once Primm fell | 1112bf0a |
| 6 First hour | a-e done (teaching hand, right-click inspect, roofs dissolve, the fountain, starter study); critic 12 + fixes: see below | 23c02536, eda8d80e |
| 7 Yes-to-all | see below | |
| 8 Verify + build | done: Loose Ends in play, saves, suite green, v0.5.1 + smokes, three critics (mid 5.3, late ~5, post ~5) | b91e4cb8, bdc35851, fcfe99a8 |

- **Decide first** (inbox "Fable pass Nov 1"): 1 Primm's phases (gauntlet 47 %, per phase 83/100/67), 2 Siphon with Elowen 100 %,
  3 the Safe Room's place, 4 card G-33's name, 5 side dungeons' first-clear gold.
- **New dialogue rows for your review**: `docs/dialogue/new_rows_nov1.csv` (2 Capital toasts + the 11 Loose Ends quest rows the export added).
  **Typo fixes on frozen lines**: `docs/dialogue/typo_fixes_nov1.csv` (5: three double spaces, "judgment .", "color" in the Lab).
- **Disk**: 4.0 GB free. Deleting the v0.4.9 zip (762 MB) was blocked by the tool's permission classifier - delete `builds/TheWaywardPath-v0.4.9-windows.zip` by hand.

## Part 1 - Healing (the designer: no healing after battles in freed zones)

- **The Crease** already had a full heal (Nurse Hesper's "Tea of Dissent", `capital_zone.gd`) and **Primm's Castle** already had a full-heal
  node on every road to the boss (the Resistance Safe Room, step 7 of 10: 4 fights before it, the Royal Stair and the boss after). The critics
  never found either. Done: the nurse reads as a healer (her name floats over her, "Nurse Hesper Dray"; her spot carries her NPC so her body
  counts for E and a vendor's reach - a hero at her side got "Read the sign"), id-less spot NPCs show their short title, and a test pins the
  Safe Room as a full heal on the critical path. Moving it to the exact middle means re-fitting the painted map (inbox 3).
- **The Capital's "drain"** was rift contact (1-2 HP) and touch-damage roamers with one toast ("Ow! The Capital has hurt you again."). The toast
  names the source now: `fx.hit_rift` / `fx.hit_roamer` ("A Tidy-Bot knocks you flat. Please remain orderly. (-2 HP)"), through
  `ZoneStoryText.hit_text`; the other zones keep their own lines.
- Checks: `tests/core/zone/test_fable_nov1_healing.gd`; play scripts `fable_nov1_crease_heal` (prompt + tea toast in play) and
  `fable_nov1_safe_room` (the node opens as "mend all of your HP", Rest works). The play driver's `scene` now prints the hero's position and
  the spots in reach.

## Part 2 - Boss tempo + every boss into its band

- **Setup window**: `BossTempo` / `Modifier.Kind.SETUP_TURNS`: for its first 2 turns a boss's units do not attack ("Setting Up" badge on the
  node map, the brief, the HUD and in the sim). Data per boss: `setup_turns` in the boss block of `dungeon_content.json` (0 = off),
  `PrimmBoss.SETUP_TURNS`, the town bosses' setups. It moves the sims by nothing (the sim player never dies on turn 1-2); it is for people.
- **Wild Growth** caps at +3 per unit (`GameState.OVERGROWTH_CAP`); the Rotheart's rule text says so.
- **Tuning** (AI skill, deck, rule strength, some HP): `docs/design/sim/bosses_nov1.md` has the before / setup-only / after table and the
  gauntlet. Summary (3 games per Path, seed 7100): Restless Dead 75 -> 58, Shiro 67 -> 42, Warden 92 -> 58, Echo 75 -> 58, Compostella 50
  (cap + 26 HP), Spotter 83 -> 50, Betty 75 -> 42, Spotless 83 -> 67, Automaton 83 -> 50, Siphon without Elowen 33 -> 50; Clench 50,
  Doppelganger 42, Mortimer 58, Itamae 58, Raccoon 58, Crumb 58, Quadzilla 42 unchanged. Outside: Primm's phases 83 / 100 / 67 one at a time
  (gauntlet 47 %: Beefcake 0/8, Necrocrat 8/8), Siphon with Elowen 100, arena tier 3 100 (inbox 1-2).

## Part 3 - Progression

- `DungeonClearBonus`: a main dungeon's first clear pays 0.5 of a level at its tier (190 / 225 / 240 / 255; was a flat 160), a side
  dungeon's 0.15 (45-90; paid nothing); Primm's Castle keeps 400; per-fight XP unchanged. Timeline re-run (`docs/design/sim/economy_model.md`):
  the expected player arrives at the Dump at 18 (model 17) and the castle at 22 (model 21); 0.6 / 0.35 over-levelled by two and was dropped.

## Part 4 - Naming

- The real chef reads "The Grand Chef" everywhere (the registry strips "(formerly ...)"); the disguised figure reads as the chef it poses as
  before the reveal and "The Doppelganger" after (node blurb); the boss fight always reads "The Doppelganger" (the intro no longer applies the
  reveal); the apprentice reads "Escoffina" after the naming cutscene (`SpoilerFree.REVEALS`); a dialogue line keeps the label the writer gave
  the beat ("The Doppelganger" / "Escoffina"), so the naming cutscene moves name by name. Bestiary, music list, quest log and Buffet NPCs
  already agreed. No existing line contradicts the rule; G-33 and the Bestiary blurb are in the inbox (4).

## Part 5 - Freed zones

- `ZoneEnemies.is_freed` / `is_peaceful` + `ZoneEnemy.peaceful`: in a freed zone touch-damage roamers wander and never chase or hit (no -HP
  toast), battle roamers with a sparring deck keep their friendly rematch, the rest stand down; the Capital stands down once Primm fell and his
  fall closes every rift. Tests per zone.

## Part 6 - The first hour

- **First duel**: a teaching hand (`FirstDuel`: 2 basics, the 2 cheapest units, 1 trick, read from the Path's starter) dealt live and in the
  sims (`GameOptions.scripted_opening_hand`); the Scavenger lost its 2/2 Militia. Sim: 100 % in 4.3 player turns (was 8-10 for the critic).
- **Clicks**: a single click already played a hand card (press and release without a drag); a right-click now inspects any card; hover inspects.
- **Roofs**: the occlusion fader's building core was inset 2.6 m, so a roof covering the hero from its edge never counted; now 0.2 m, plus a
  sight line to the hero's head. Verified with `OCCLUSION_DEBUG=1` (the new "near" listing) on the square walk.
- **The fountain**: a quarter bigger (7.1 m, blocker 3.2), never ghosts or fades (its card keeps `fade_strength` 0 and `no_occlusion_fade`), and
  the hero shows through it as an x-ray silhouette (`WorldSprite.set_silhouette`, shown while the card's screen rectangle covers the figure).
- **Starter study** (`docs/design/sim/starter_nov1.md`): 45 / 35 / 30 cards at the same ratios - cave 88 / 92 / 96 %, first zone 85 / 89 / 87 %.
  **Recommendation: 35 cards (15 basics)** - same strength, each reward pick a third more of the deck; not applied.
- **Critic 12 (first hour, fresh, worktree)**: **5.7 / 10** (last night's first-hour critic: 5.0). Report `docs/review/fresh_eyes_firsthour_nov1.md`, 57 shots in
  `fresh_eyes_firsthour_nov1/`. Scores: hook 4, clarity 6, pacing 3, combat 6, deck building 6, reward rhythm 7, exploration 5, story 6,
  visuals 7, UI/UX 4, performance 6, bugs 5. Its top 5: duels of 7-16 turns against 3-4 HP foes (the critic's pilot: 13 turns; the teaching
  hand was dealt - shot c12f_01 - and the sim player wins in 4), 22 taps of exposition before the Path choice, the cave path on foot, tutorial
  modals stacking, inconsistent popup keys. **Fixed**: a tip never opens over a confirm dialog; the Victory banner holds solid until the result
  panel (it was caught mid-fade behind the last card); a click on the field clears a stale card tooltip; the quest log's empty state hides its
  blank panel. **Yours** (inbox 6): the opening's length, the Path screen's readability, a "How a turn works" card, hand card text size, the
  Deck Station's locked slots, the forest path, Esc over a battle. No second look was run (the three Part 8 critics take the time).

## Part 7 - The yes-to-all list

All done, tested in GUT (core 1564, ui 196, world 431 green) except where noted (commit 33dc7eeb):

- **Click an NPC to walk there and talk**: a click on any named spot's marker out of reach walks the hero to it (`TownPlayer.walk_to`; any
  key cancels; 6 s give-up) and talks on arrival, in Crosspath and every zone. Not yet exercised by a critic.
- **Boss card picks 2 of 3 on-Path or Colorless**: the first two slots always fit (`RewardPicks.fits_own`); the third may be the chase card.
- **Decline on deck-test events**: "Leave it (no test)" under Reveal passes the node with nothing won or lost.
- **E on the boss pick highlights the rarest card** (the middle among equals).
- **One Victory popup, no leftover "Next turn" banner**: `_result_shown` guards the two paths to the result; the script banner's warning is
  cleared when the fight ends.
- **Draw-call budget** re-based: Crosspath Medium 840 -> 890 (874 measured Oct 31).
- **HeapLayout cached as data**: `HeapLayout.build_cached` (snapshot / restore of its peaks, chutes, ramps, bridges, props, signs, areas,
  spots): 641 -> 117 ms; the Dump walk smoke passes cold and warm.
- **Captain Spotless "[E] Talk opens nothing"**: not reproduced; my walk from the Crease ladder to his post hit a wall south of the manhole
  twice and I stopped (the critic's late-game run will pass him again).
- **The Lab's -5 max life on the map HUD**: Specimen Conditions rides the run from entry (the map shows 10/10 of 15), battles no longer add it a
  second time (test).
- **The Intake Corridor's foe** is the "Intake Orderly" (Bestiary and request list follow).
- **Arena first-clear prizes** scale with the level over the tier's expected level (a L24 player at tier 1: 90 -> 270 gold), never below print.
- **Typo sweep** (`node tools/typo_sweep.js`): the sheet's 4203 lines and 638 scripts' prose strings - no misspellings; 5 frozen-line fixes for
  you in `docs/dialogue/typo_fixes_nov1.csv` (three double spaces, "judgment .", one "color" in the Lab against 17 "colour"); the UI's double
  spaces are deliberate spacing ("HP  12 / 15") and were left.

## Part 8 - Verify + build

- **Loose Ends in play** (`fable_nov1_loose_ends` from the postgame story-bot save): given on town entry (0/4, "500 gold / 400 XP" in the log);
  the four steps progress in order (Mount Swolympus cleared, Rip at the Rift Station, the Lab cleared, an arena bout) and the reward lands
  after the fourth (1800 -> 2770 gold = the arena's 270 + the level-25 purse 200 + the quest's 500; level 24 -> 25). A level-up popup sat
  over the final quest-log shot. Note: the quest counts its steps **in order** - an arena win before Swolympus does not tick.
- **Story-bot saves at the new HP curve**: `midgame_real` (L13, 2 zones freed), `lategame_real` (L20, 4 zones), `postgame_real` (L23 after
  Primm). The bot defaults every snapshot to one name - pass `--snapshot=<name>` (the first late run overwrote the midgame one).
- **Full sharded suite**: core 1563/1564 (1 pending), ui 196/196, world 431/431, characters 4/4, root 287/287 - 0 failing.
- **Dialogue CSV re-exported** in place: 4203 rows in the same order (8 current lines refreshed), 13 new rows appended and listed in
  `new_rows_nov1.csv` (b91e4cb8).
- **v0.5.1**: `builds/TheWaywardPath-v0.5.1-windows.zip`, **762 MB** (payload 849 MB over the 800 MB budget, as v0.5.0 was); release smoke
  PASSED on the project and on the exported pack (0.5.1). Not shared.
- **Disk: 1.5 GB free.** The permission classifier refused my deletes; please remove `builds/TheWaywardPath-v0.4.9-windows.zip` (762 MB),
  `builds/_export` (955 MB, re-made by any export) and the old `_screenshots/play/critic*` folders by hand.
- **Mid / late / postgame critics**: fresh critics from the worktree at HEAD on the new story-bot saves (reports and cited shots in
  `docs/review/fresh_eyes_{midgame,lategame,postgame}_nov1[.md|/]`):
  - **Mid-game 5.3** (last night 5.5; a different reviewer's eye). Top: fights long and inert (a 26-turn trash fight by the critic's
    pilot; "play one Powerhouse, pass"), a dungeon loss ejects you with a toll line and no Defeat recap, energy taught after the failed
    play, "shops cannot be opened", black zone map / "Where to?" a text field. The shop item is **not a regression**: its own log shows E
    pressed after walking out of Sable's prompt, and Escape on Fenwick's second greeting line (the stall opens when the greeting ends);
    the first-hour critic opened Sable's stall on the same build.
  - **Late-game ~5** (last night 4.6; "a 7 with the flow bugs and ending staging fixed"). Top: Victory, Opening Hand and the boss node's
    "Click again to go" ignore E/Space (seven runs to reach the credits by keyboard), the map's "Where to?" / "Goal:" never learn about the
    Capital after the four zones, Infrastructure floods castle hands (10 of 12 Powerhouses; Primm's mirror deck too), the ending staged as
    icon collages and PLACEHOLDER CREDITS, the Capital arrival in the grey Crease with a silent nurse.
  - **Postgame ~5** (last night 4.0). Top: both postgame bosses are walls for the snapshot's own deck (the pilot lost to Siphon in 8 turns at
    14 max HP in the Lab; the Spotter's Millstone Pusher did 25 in two hits), a dungeon defeat throws away the run's cleared nodes, E/Space on
    the result popups (fixed below), nothing points at the Lab (Loose Ends hides three of its four steps as ???), the Swolympus hook is a
    hidden fetch chain behind NPCs who block the paths.
  - **Fixed after the critics** (tested: ui 196/196, play script `fable_nov1_keys`): Space / E / Enter keep the opening hand, press Continue
    on the Victory or Defeat panel, and go to a hovered dungeon node ("Click again or press E to go").
  - **Not fixed (next pass, in order)**: the map's goal after the four zones; the Infrastructure flood late (the auto-fill target); a Defeat recap on a dungeon loss;
    the ending's placeholder art and credits (art).
