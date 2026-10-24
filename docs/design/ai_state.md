# Battle AI upgrade - running state

Resume file for the "BATTLE AI UPGRADE" brief (Oct 23 2026). Read this first after a context reset. Parts 1-6; each part ends with
GUT passing, the first-battles smoke, a commit and a push. Check for a `STOP_TASK` file in the repo root (or `C:\Users\asche`) before
each part. Rules: one Godot process at a time (foreground), sims headless in modest batches (7.4 GB RAM), old saves keep loading,
enemy intent stays hidden, no new art.

## Where things live

- AI (Part 2): `core/ai/ai_player.gd` (facade: cached turn plan, combat, mulligan/discard, skill settings), `ai_evaluator.gd`
  (position score: concave HP, board/hand/resources/traps, fast combat model with threat, lethal and race clocks, encounter-rule
  awareness; per-evaluation `Fighter` cache), `ai_turn_planner.gd` (beam search over a main phase), `ai_combat.gd` (attack / block
  candidates played out on clones against a competent block model), `ai_sanity.gd` (never-do filters), `ai_search_budget.gd`
  (node caps per skill + wall-clock safety net), `ai_personality.gd` (+ `data/ai/*.tres`; new knobs with defaults).
- Engine: `core/game/game_state.gd` (`legal_actions`, `clone(deep, hide_traps_of)`, `apply_action`), `combat_resolver.gd`.
- Sim: `core/sim/balance_sim.gd` (`play_game` builds both AIs by name, `deterministic = true`), `encounter_catalog.gd`,
  `tools/replay_encounter.gd` (`--id --path --games --show --all --level --verbose --enemy_ai=<name>`), `tools/run_balance_sim.gd`,
  `node tools/sim_summary.js <reports>`, `tools/ai_probe.gd` (hand-built position, prints every attack candidate's score and the
  evaluation's terms; `AICombat.debug`).
- UI driver: `ui/battle/battle_screen.gd` `_ai_step` (0.35 s think pause + 0.5 s announce, scaled by `board.speed`).
- Tests: `tests/core/ai/test_ai_player.gd` (27, the old contract), `tests/core/ai/test_ai_planner.gd` (13, the audit's habits).
- Docs: `docs/design/ai_audit.md` (Part 1), this file, `balance_log.md`, `sheet_changes.md`.

## Status

| Part | Status | Notes |
|---|---|---|
| 1 - audit | done (commit 419183a0) | 24 replays; 13 habits ranked in `ai_audit.md`; replay tool `--verbose` |
| 2 - core | done (GUT 2183, first-battles smoke OK) | new core, see below; sim speed unchanged (~1.5 s/game); think time avg 3-20 ms, max ~0.45 s at Elite |
| 3 - personalities | done (GUT + smoke: see commit) | `core/ai/ai_profiles.gd`: Path mix read from the seat's deck, weights nudged per share; five boss signatures by enemy name (`AIPlayer.SIGNATURES`) |
| 4 - skill levels + pacing | done (same commit) | `AIPlayer.Skill` + `for_foe(personality, skill, enemy_name)` at every call site (Session, Dev Menu, sim, replay); Normal: 15% second-best attacks and 15% forgotten blocks (never lethal ones); the tutorial foes keep their own careless rates; BattleScreen "is thinking..." line and longer holds on combat declarations |
| 5 - sim + rebalance | done | whole catalog re-measured (`docs/design/sim/ai_p5/`), tuning pass in `balance_log.md` ("Oct 23 - Battle AI upgrade, Part 5"); fuel-hoarding fix in the evaluator; Primm's phases at Elite |
| 6 - verify | running | full GUT, first-battles smoke, story playthrough bot, dungeons smoke, replays per Path; final table below |

## Final: what changed, before / after, timing

**What changed.** One planning AI for every seat (`core/ai/`): a cached per-phase plan from a beam search, combat played out on
clones against a competent block model, a static evaluation with a real combat model (threat, lethal for both sides, race clocks,
encounter rules), sanity filters, Path profiles read from the deck, five boss signatures, three skill levels with human mistakes at
Normal, and a node/time budget. The balance sim and the replay tool run the same seats as the game (`AIPlayer.for_foe`). Encounter
tuning under the new AI: see `balance_log.md`, Oct 23. No card changes. Enemy intent stays hidden; no new art.

**Opening hour, win rate per Path** (sim, player seat = Elite "decent human"; before = old AI, Oct 22 sweep at 6 games per Path;
after = new AI, 6 games per Path on seeds 7000 / 8100, mean of both):

| Fight | Target | Before B / N / G / R | After B / N / G / R |
|---|---|---|---|
| Tutorial run (50 runs per Path) | 85%+ | 91 / 94 / 89 / 87 | 88 / 98 / 90 / 88 |
| Stray Gym Hound (L1) | 80%+ | 90 / 90 / 83 / 80 | 100 / 100 / 100 / 100 |
| Lost Junior Clerk (L1) | 80%+ | 86-96 / 82-94 / 76-86 / 72-96 (Oct 22 range) | 100 / 92 / 75 / 100 |
| Bin Raccoon (L1) | 80%+ | (same range) | 83 / 100 / 92 / 83 |
| Store Room Ghosts (L3) | ~90% | 94-100 | 92 / 100 / 100 / 92 |
| Brick Bronson (L3, elite) | 60-75% | 67 (all) | 83 / 67 / 67 / 75 |
| Chef Fennel Gravois (L3, elite) | 60-75% | 70 | 75 / 58 / 58 / 58 |
| Moss Mulligan (L3, elite) | 60-75% | 55-59 | 88 / 50 / 56 / 63 (at 12 HP, 28 cards / 20 basics) |
| Prudence Pallor (L3, elite) | 60-75% | 56 | 75 / 75 / 58 / 50 |
| Gainlands roamers (L5) | 80%+ | 80-84 | Brute 81, Golem 88 (4 games per Path) |
| The Restless Dead (L7, first boss) | 40-60% | ~50 | 38 / 31 / 69 / 25 (41 overall; see the ladder step below) |

(Per-Path cells are 12 games each, so one game is 8 points. The widest spreads left in the opening hour: Moss for Necrocrat 50 and
the Restless Dead for Necrocrat / Refusemancer, the slower decks; they go to the inbox.)

**Whole catalog** (new AI, 4 games per Path, seed 7000, before the tuning pass; the Oct 22 sweep in brackets):

| Kind | Fights | In band | Too hard | Too easy | Mean win | Mean turns |
|---|---:|---:|---:|---:|---:|---:|
| Normal | 56 | 46 (48) | 10 (10) | 0 (0) | 89% (90) | 7.3 (7.3) |
| Elite | 23 | 10 (11) | 8 (5) | 5 (6) | 66% (67) | 8.7 (8.3) |
| Boss | 21 | 6 (10) | 5 (2) | 10 (10) | 55% (59) | 8.4 (8.0) |

After the pass (re-measured fights only): Mortimer 47, Doppelganger 38, Mirror Knight 72, Clipwell 72, Casserole 78, Spotless roamer
64, Spotless boss 47 / 72, Restless Dead 38 / 44, Moss 63 / 66, Primm's three-phase gauntlet 48% cleared (B 50 / G 25 / R 50 / N 67).
Walls left: none under 35% except Siphon alone (0%, by design; 69% with Elowen).

**AI turn timing** (this PC, `tools/replay_encounter.gd --verbose`): a decision averages 3-20 ms; the longest seen at Elite/Boss on
a full board was 0.45 s in the live budget's terms (the sim's deterministic mode, with no time box, reached 1.2-1.6 s twice in a
Refusemancer game with many Garbage abilities). Live: 500 ms per main-phase plan, 250 ms per attack or block decision, so a turn
thinks for about a second at most; a search that hits the box returns its best answer so far; the HUD says "<foe> is thinking..."
before a slow decision. Sim speed is unchanged (about 1.5-2 s per game at Elite vs Elite; a whole-catalog sweep at 4 games per Path
takes 48 min).

**Verification (Part 6)**: see the table in `docs/progress.md` ("Battle AI upgrade") once the runs finish.

## Part 5 - the catalog under the new AI (summary; details in balance_log.md)

- Measured with `bash tools/ai_sweep.sh ai_p5 4 7000` (48 min for the catalog at 4 games per Path; zones and dungeons are seconds,
  the scripted bosses minutes) and `--what=tutorial --games=25`.
- Averages held (Normal 89%, Elite 66%, Boss 55%) but engine decks got sharper: the gatekeepers, the Restless Dead, the Stray Gym
  Hound and several bosses moved out of band. Fixes: the four gatekeepers and the first boss play at Normal skill
  (`AIPlayer.SKILL_OVERRIDES`), Moss 13 HP, the hound loses its golem maker and Plate It, one-step stat rules on the too-easy
  bosses/elites and the Spotless wall; no card changes (`sheet_changes.md` untouched).
- Evaluator fix found through the sweep's replays: held Garbage/Ingredients were worth more than using them (Possum Prowler sat on 7
  Garbage for 13 turns); FUEL_VALUE 1.5 -> 0.8, idle 0.4 -> 0.25.

## Examples of smarter plays (from the verbose replays)

- Prudence vs Beefcake L3 (seed 7000, game 0): turn 9, Prudence at 2 HP behind a summoning-sick Notary Wraith: Dropped Weights on the
  Wraith, two Iron on Leg Day Survivor, attack with everything for lethal. The old AI held three Hustle units at home for four turns
  in the same spot.
- The probe position (`tools/ai_probe.gd`): Brawler pumped to 5/4 against Mortimer 3/5, a Temp and a Clerk with Prudence at 5 HP:
  the new AI sends the Brawler alone (she must chump with the Clerk); the old one sat because every attack looked like a trade.
- Moss (Refusemancer): Raised Bed buffs now land on the Raccoon and the Bird (the units that attack), not on the Acid Vomitor that
  exhausts to ping; the Vomitor still pings the right 1/1 each turn.
- Chef Fennel: cooks a Cake Golem the turn the second Ingredient arrives, plays Hearth Kitchen earlier, blocks with the 1/6 wall only
  when it kills or saves the game.
- Blocks: a 1/1 is no longer thrown in front of a 4/4 at 20 HP; a chump is made when the crack-back would be lethal next turn
  (7 HP, 5/5 + 3/3 + 2/2 across the table).
- Resources: Iron is used only in Main 1 on a unit that then attacks (the old AI pumped and stayed home); Red Tape goes on the
  biggest attacker before the foe's turn, never on a 1/1 on turn 2; a Contract on the only blocker finds a two-step lethal.

## Part 2 - what the new core does

- **Turn plan**: the main phase is planned once (beam 2/3/4 wide, 2/3/4 deep by skill, 60/150/280 nodes) on clones, scored by the
  evaluator *with the attack the position allows this turn* (Main 1) - so Iron before an attack, a removal that clears the blocker, a
  Hustle unit, or Red Tape before the foe's turn are seen for what they enable. The plan is cached and handed out one action at a
  time (the UI still announces each); an action that stopped being legal triggers one replan.
- **Combat**: attack candidates = none / everyone / each alone / everyone-but-one / safe / evasive / "no profitable block" /
  power prefixes; each is played out on a clone with the opponent's blocks predicted by a neutral block policy; the score's threat
  and race terms are the look-ahead (crack-back, lethal next turn, who wins the race). Zero-attack units never attack; a pumped
  unit that stays home costs a penalty. Blocks: value blocks, chumps when lethal, "save HP" chumps, every single block, full
  enumeration up to 12/40/80 combos.
- **Evaluation**: concave HP (last six points 1.75 each, 7-10 at 0.75, above 10 at 0.5); unit = 2*atk + def + keyword/ability
  bonuses, halved, plus 1.0 for the body, temporary pumps excluded, 0.1x under Rot at 1 defense; traps by condition likelihood;
  fuel resources by whether a spender exists; threat = the foe's best attack package next turn (marginal-value package search
  against greedy blocks, end-of-turn stats), lethal/near-lethal penalties; race = pressure(my clock) - pressure(their clock)
  with pressure = 2/turns; timed and escalating summons and start-of-turn damage count toward the foe's push.
- **Sanity**: harmful effects never aimed at own units when a foe target exists (and the reverse), Iron only in Main 1 on a unit
  that attacks, Red Tape/Contract only on foe units with 2+ attack that block now or attack next turn (top 3), no re-attaching a
  Tool to its own host.
- **Budget**: node caps keep sim games deterministic; the live game also has a 700 ms wall-clock net per decision.

## Parts 3 + 4 - personalities and skill

- **Path profiles** (`AIProfiles.PROFILES`, applied in proportion to each Path's share of the seat's non-infrastructure cards; a
  share under 15% is a splash and ignored): Beefcake +attack bias, +race, +enemy HP, -threat fear, attack valued over defense,
  Iron is for spending; Necrocrat +width (tokens), holds Red Tape/Contracts for the right target, values cards and threat;
  Gourmand +HP, +defense value, +threat fear, +block bias, fuel (Ingredients) valued, races less; Refusemancer fuel (Garbage)
  valued, +development, the foe's Tools/Wonders worth 1.6x (`artifact_weight`), spends HP more freely, a little width. A two-Path
  deck gets half of each. `AIPersonality.path_profile` = "auto" (default) / a Path name / "none" (the tutorial foes).
- **Signatures** (per turn, from the board): `patience` (The Restless Dead, Compostella: no attacks until three units stand),
  `trickster` (Shiro: attacks more with a trap set, blocks less), `all_in` (Warden, Clench, Quadzilla, Primm: presses once as wide
  as the foe or the foe is at 8 HP), `paperwork` (Mortimer, Vellum, Siphon: Red Tape is for using, every turn), `fortress` (the
  Echo, the Doppelganger, Crumb: blocks and heals, attacks only when safe).
- **Skill** (`EncounterSpec.skill_for(kind)` in the sim, `Session._skill_for_node` and the explicit sites in the game): Normal =
  beam 2 / depth 2 / 60 nodes + mistakes; Elite = 3 / 3 / 150; Boss = 4 / 4 / 280 + signature. Zone roamers are Normal except
  the two zone elites; town gatekeepers and the lieutenant rematch Elite; the scripted bosses Boss; arena tiers 1/2/3 = N/E/B;
  the store room ghosts and the outskirts roamers Normal. The sim's player seat is Elite without mistakes ("a decent human").
- **Mistakes** (Normal only, own RNG seeded by game seed + turn + seat, so sim games stay deterministic): `mistake_rate` = chance
  to take the second-best attack idea when it is within 4 points of the best (never when the best wins the game);
  `careless_blocks` = chance to forget a block when the unblocked damage is not lethal. Tutorial: "Aggressive (tutorial)" never
  holds an attack and forgets 30% of blocks; "First duel" forgets 75% (its old block_bias could no longer override the lethal
  penalty - D-AI-4).
- **Chump reluctance**: a block where the blocker dies without killing the attacker costs 1.0 unless no block would be lethal
  (a human needs more than a few HP to throw a card away).
- **Pacing** (`BattleScreen._ai_step`): the 0.35 s pause stays; when the previous decision took over 150 ms the next main-phase
  decision is preceded by "<foe> is thinking..." and one rendered frame; attack and block declarations are announced for 0.8 s
  (other actions 0.5 s), all divided by the battle speed.

## Decisions

- D-AI-1: `AIPlayer` keeps its public surface (`choose_action`, `evaluate`, `choose_blocks`, `personality`, `use_resources`); every
  call site and the six `.tres` personalities load unchanged (new exports have defaults).
- D-AI-2: the opponent's blocks are predicted with a neutral (Balanced) evaluator, not the AI's own weights - an Aggressive AI must
  not assume the player blocks recklessly.
- D-AI-3: the sim's seats run `deterministic = true` (node caps only): identical games for a seed on any machine.
- D-AI-4 (open, Part 4): the "First duel" tutorial foe now chump-blocks lethal attacks (its old block_bias cannot override the
  lethal penalty), so the smoke's first battle took 15 turns (limit 16) and its dumb clicker lost battles 2 and 3. Part 4 gives
  skill 0 explicit "forgets to block" mistakes and keeps the tutorial foes at the gentle end.
