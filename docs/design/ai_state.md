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
| 5 - sim + rebalance | not started | the enemy side already uses the new core in the sim; first read: Moss 8%, Prudence 33% at 3 games/Path - the opening hour needs easing |
| 6 - verify | not started | |

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
