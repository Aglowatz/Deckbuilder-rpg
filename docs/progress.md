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
