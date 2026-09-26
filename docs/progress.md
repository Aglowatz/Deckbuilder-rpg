# Progress

Headless rules engine, built milestone by milestone. Run all tests with `tools/run_tests.sh`
(refreshes the class cache, then runs GUT).

## Milestone 1: Data model - done

Built:
- `Affinity` (Type enum NEUTRAL, A-D + display names: the one place to rename colors).
- `CardEnums` (card types, keywords, triggers, targets, ops, durations, rarity).
- `CardData`, `EffectData` resources; `Deck`, `PlayerProfile` resources.
- Unified modifier types: `Modifier`, `ModifierSource`, `ModifierSet`.
- `CardBuilder` typed helper for defining cards/effects/modifiers in code and tests.
- Cards are saved as `.tres` (round trip verified). The 40-card content set is generated in
  milestone 8 into `data/cards/`.
- Enabled the `untyped_declaration` GDScript warning in `project.godot`.

Tests: 13 total (11 new).

Known issues: none.

## Milestone 2: Core game loop - done

Built (`core/game/`):
- `GameState` (rules for one duel), `PlayerState`, `CardInstance`, `GameOptions`, `PlayerSetup`.
- Turn structure Start -> Main 1 -> Combat -> Main 2 -> End; untap/draw; first player skips the
  first draw; one land per turn; hand-size discard at end of turn; damage and temporary
  effects clear at end of turn; summoning sickness flag.
- Mana with colored pips + generic (`Mana`), auto payment or explicit land choice, cost-change
  modifiers, casting creatures/artifacts/spells and setting traps face-down.
- Deck-out loss, life-0 loss, simultaneous loss = draw, turn-limit draw.
- Opening hand with `HandSmoother` (2 candidates, closest land ratio) and one free mulligan.
- Typed event log (`GameEvent`, emitted via the `event_emitted` signal) for every state change.
- `GameAction` + `legal_actions()` / `apply_action()` (the vocabulary for AI and UI) and
  `GameState.clone()` for look-ahead.
- Player stats come from `PlayerProfile` + `ModifierSet` (max life, starting life, hand sizes,
  extra draws, cost and stat changes are already wired into the engine).

Stubs left for later milestones: combat declaration (M3), triggers/effects/traps/activated
abilities (M4), start-of-combat modifier effects (M5).

Tests: 57 total (44 new in `tests/core/game/test_game_loop.gd`).

Known issues: none.

## Milestone 3: Combat - done

Built (`core/game/combat_resolver.gd`, wired into `GameState`):
- Declare attackers (summoning sickness, Haste, Defender, tapped checks), attackers tap.
- Defender assigns at most one blocker per attacker (and one attacker per blocker); tapped
  creatures cannot block; Flying needs Flying/Reach to block.
- Damage: first-strike step then regular step; deaths resolved between steps; unblocked damage
  hits the player; damage clears at end of turn (M2).
- Combat keywords were implemented here because the damage rules need them: Trample, First
  Strike, Lifesteal (capped at max life), Guard (attackers must attack a Guard creature).
- Passing in combat = no attackers / no blockers, so `advance_phase()` alone can drive a turn.
- `possible_attackers`, `possible_blockers`, representative combat `legal_actions()`.

Tests: 92 total (35 new in `tests/core/game/test_combat.gd`).

Known issues: none. Interpretation choices (Guard, attackers tapping, one attacker per blocker)
are in `docs/design/open_questions.md`.

## Milestone 4: Effects and keywords - done

Built (`core/game/effect_resolver.gd`, `effect_context.gd`, wired into `GameState`):
- Data-driven effects (`EffectData`): triggers ON_ENTER (also spell resolution), ON_DEATH,
  ON_ATTACK, ON_BLOCK, START_OF_TURN, END_OF_TURN, ON_DAMAGE_TAKEN, ACTIVATED.
- Targeting: self, controller, opponent, triggering card, chosen creature (any/enemy/ally),
  chosen player, all creatures (any/enemy/ally), all players, all attackers, random creature
  (any/enemy/ally). Spells/creatures take the target chosen at cast; triggers auto-target.
  A chosen target that died before resolution fizzles.
- Operations: deal damage, heal, draw, discard, destroy, buff/debuff (temporary or permanent),
  summon token, return to hand, mill, gain/lose life, grant keyword (temporary or permanent).
- Keywords, all covered by tests: Flying, Reach, Haste, Defender, Trample, First Strike,
  Lifesteal, Guard (combat behaviour was added in M3).
- Traps: set face-down on your own main phase, trigger automatically on the opponent attacking,
  casting a creature, casting a spell, or on damage to their controller. No priority/stack.
  Each trap fires once and goes to the graveyard.
- Activated abilities (generic mana cost, once per turn), included in `legal_actions()`.
- Safety: trigger recursion is cut off at depth 12; simultaneous combat damage is applied before
  deaths are checked.

Tests: 141 total (49 new: `test_effects.gd`, `test_traps.gd`).

Known issues: none.

## Milestone 5: Modifier system - done

Built:
- `ModifierPipeline` (`core/data/`): one entry point that merges equipment, items, zone effects,
  dungeon rules and boons into a `ModifierSet` (player side and enemy side).
- Engine hooks, all reading the same `ModifierSet`: max life, starting life, max hand size,
  opening hand size, cost change by color, power/toughness change by color, extra draws,
  max deck colors, and start-of-combat effects (new in this milestone; fires the owner's
  `START_OF_COMBAT_EFFECT` modifiers when their combat phase begins).
- `DeckValidator` (`core/dungeon/`): 45 minimum, 3 copies (basic lands exempt), 2 colors, 4 once
  `postgame_unlocked` (plus `MAX_DECK_COLORS` modifiers, capped at 4), optional ownership check.
- `DungeonRun` (`core/dungeon/`): full heal on entering, life carries between encounters, heal and
  life loss, active dungeon modifiers/boons, cards lost/gained for the dungeon only, builds each
  encounter's `GameState`, records the result (a loss or 0 life fails the run).

Tests: 162 total (21 new in `tests/core/dungeon/test_modifiers_and_decks.gd`).

Known issues: none.

## Milestone 6: Challenge encounters - done

Built (`core/dungeon/`):
- `ChallengeData` (Resource, storable as .tres) with 6 kinds: first-creature power, top-N land count,
  top-N type count, top-N total cost, sacrifice a card, pay life.
- `ChallengeOutcome`: lose life, heal, lose a card, gain boon (any `ModifierSource`), gain a card
  from a pool.
- `ChallengeResolver` reveals from the run's current deck with a seeded RNG, decides success and
  applies outcomes to the `DungeonRun`; returns a `ChallengeResult` (revealed cards, what was
  lost/gained, life changes) for the UI.
- `ChallengeExamples`: six example challenges (Test of Might, The Hollow Well, Scholar's Riddle,
  The Weighing Scale, Altar of Sacrifice, The Toll Keeper). They are written to
  `data/encounters/challenges/*.tres` by the content generator in milestone 8.

Tests: 182 total (20 new in `tests/core/dungeon/test_challenges.gd`).

Known issues: none.
