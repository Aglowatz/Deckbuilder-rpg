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

## Milestone 7: AI opponent - done

Built (`core/ai/`):
- `AIPersonality` (Resource): weights for own life, enemy life, own/enemy board, hand, mana
  development, exposure to counter-attack, plus attack/block bias. Presets: balanced,
  aggressive, defensive (the .tres versions are generated in milestone 8).
- `AIPlayer`: `choose_action(state)` answers whatever decision the game is waiting on: mulligan,
  discard to hand size, land choice (colors the hand needs), main-phase casts/activations,
  attackers, blockers. Main-phase and combat choices clone the state (`GameState.clone`), apply
  each candidate and score the result with `evaluate()`. Attack candidates are evaluated
  together with the opponent's best block reply; block candidates include value blocks, chump
  blocks when facing lethal, and full enumeration for small combats.
- Opponent traps are hidden from the AI's clones.

Tests: 208 total (26 new in `tests/core/ai/test_ai_player.gd`), including complete AI-vs-AI
games with zero illegal actions and seed determinism.

Known issues: none yet; balance is measured in milestone 8.

## Milestone 8: Content + simulation harness - done

Built:
- **Content** (`core/data/content_definitions.gd`, written out by `tools/generate_content.gd`):
  40 placeholder cards - 10 Neutral, 8 Affinity A (aggressive: haste, first strike, burn, a
  combat trick, a damage trap), 8 Affinity B (control: draw, removal, bounce, fliers/reach/
  defender, a "destroy their new creature" trap), 7 Affinity C (big bodies, trample, guard,
  growth, life gain), 7 Affinity D (sacrifice/value: death triggers, tokens, drain, lifesteal).
  Plus a Spirit token and 5 basic lands (one per color and a Neutral one). Every keyword, every
  trap trigger family and every effect operation the content needs is used somewhere.
- **Files**: 60 `.tres` resources - `data/cards/` (46), `data/decks/` (5), `data/encounters/
  challenges/` (6, the milestone-6 examples), `data/ai/` (3 personalities).
- **5 sample decks** (45 cards each: 28 spells + 17 lands, all legal under `DeckValidator`):
  Ember & Tide (A/B), Tide & Root (B/C), Root & Grave (C/D), Grave & Ember (D/A), Wanderer's
  Pack (neutral starter).
- **Simulation harness** (`core/sim/`): `SimulationRunner` (AI vs AI, alternating first player),
  `MatchupStats`, `BalanceReport`, `ContentLibrary` (loads the `.tres` content).
  `tools/run_simulation.gd` runs the round robin and writes `docs/balance_report.md`.
- **Balance report**: 10 matchups x 100 games = 1,000 games in about 45 seconds; 0 illegal AI
  actions. After one tuning pass all decks sit at 44-55% (see `docs/balance_report.md` for the
  matrix, most/least-played cards and analysis).

Tests: 227 total (19 new in `tests/core/sim/`): content shape, every card castable and resolving,
every trap firing, deck legality and color coverage, `.tres` files match the code definitions,
simulation determinism, aggregation math and report sections.

Known issues: see the final summary below.

## How to run things

```
tools/run_tests.sh                                   # refresh class cache + run all GUT tests
Godot --headless --path . -s res://tools/generate_content.gd     # rewrite data/*.tres from code
Godot --headless --path . -s res://tools/run_simulation.gd -- --games=100 --notes=res://docs/balance_notes.md
```

After adding a new `class_name` script, run `Godot --headless --path . --import` once (the test
script does this) so Godot's class cache knows about it. Re-run `generate_content.gd` after editing
`ContentDefinitions`; `test_saved_files_match_the_code_definitions` fails if the `.tres` are stale.

---

# Final summary

All eight milestones are complete and pushed. **227 tests, all passing** (about 7 seconds).

What exists (`core/`, 42 scripts, about 4,200 lines, no Nodes, no scenes):
- `core/data/` - card/effect/deck/profile/modifier resources, `CardBuilder`, `ContentDefinitions`.
- `core/game/` - `GameState` (turn structure, mana, mulligan, hand smoother, win/loss, event log,
  actions, cloning), `CombatResolver`, `EffectResolver`, traps, keywords.
- `core/dungeon/` - `DeckValidator`, `DungeonRun`, challenge data/resolver and 6 examples.
- `core/ai/` - `AIPlayer` (one-step look-ahead on cloned state) and `AIPersonality`.
- `core/sim/` - simulation runner, stats, balance report, content loader.

Things worth knowing:
- Rules gaps in the spec were filled by judgement and logged in `docs/design/open_questions.md`
  (38 entries). The UI can animate purely from `GameState.events` / the `event_emitted` signal and
  act through `GameState.legal_actions()` / `apply_action()`.
- `project.godot`: I enabled the `untyped_declaration` GDScript warning (CLAUDE.md asks for
  static-typing warnings). The file also shows a section reorder Godot made on its own.
- AI limits: it is a greedy one-step look-ahead. It does not plan multi-turn sequences and
  under-uses sacrifice synergies (Dark Bargain) and situational removal, which depresses the
  sacrifice deck's numbers. Not a rules problem.
- Nothing was run in a real scene or with real art; there is no UI code.

## Open questions for you

Highest impact first; the full list with reasoning is in `docs/design/open_questions.md`.

1. **Guard (Q2).** "Enemies must attack this if able" only makes sense if attackers can target
   something other than the player. I made Guard mean: while the defender has a Guard creature,
   every attacker must attack a Guard creature (damage lands on it). Is that what you meant?
2. **Attackers tap (Q1).** Attacking taps creatures until their controller's next turn (so they
   cannot block on the opponent's turn). There is no Vigilance. Keep?
3. **One blocker can block only one attacker (Q3)** - confirm.
4. **Sample decks (Q32).** "One per color pair" is 6 decks for 4 colors but you asked for 5. I built
   the 4 ring pairs (A/B, B/C, C/D, D/A) + the neutral starter. Want A/C and B/D too?
5. **Neutral basic land (Q34).** I added a colorless basic land so the neutral starter has no
   color. Keep, or give the starter a real color?
6. **Hand smoother default (Q18).** On by default, and reused by the free mulligan. Should it be
   off by default and unlocked/toggled in settings?
7. **Discard rules (Q7, Q8).** End-of-turn discard to hand size is the player's choice; discard
   *effects* discard random cards. Should discard effects let the victim choose?
8. **Trap rules (Q35).** No limit on set traps, and traps can fire during the opponent's combat
   damage as well as declaration. Do you want a cap (for example 3)?
9. **Balance targets (Q36).** What win-rate band do you want per deck (I used 35-65% per matchup)
   and should the neutral starter be intentionally weaker than the paired decks?
10. **Life rules (Q11, Q21).** Life gain is capped at max life; a max-life boon during a dungeon
    also heals by the same amount. Confirm or change.

---

# Follow-up: design review changes

Applied after the first round of answers (details in `docs/design/open_questions.md`, "Designer review").

- **Vigilance** keyword added (attacking does not tap). Ironclad now has it; effects can grant it.
  Combat tests: 4 new.
- **Guard, one-blocker-per-attacker**: confirmed, unchanged.
- **Neutral land removed** from content (4 basic lands, one per color). The sample-deck template
  "Wanderer's Pack" now carries Affinity A lands as a placeholder for simulation only.
- **Campaign start** (`core/dungeon/campaign_start.gd`): the player owns only the 28 neutral
  starter spells, picks a primary color that sets their basic lands, and receives 5 cards of that
  color once after the intro dungeon. Pair decks are never given to the player. Story framing in
  `docs/design/starting_deck_and_affinity.md` (placeholder lore: a Wellspring recognises the
  Wanderer after the Trial of the Hollow). 8 new tests in `tests/core/dungeon/test_campaign_start.gd`.
- **Hand smoother** is on by default but gentler: it only swaps a hand more than 1 land away from
  the deck's land ratio (`GameOptions.smoother_tolerance`). Test asserts it helps, but less than
  always comparing two hands.
- **Balance re-run** with all of the above: decks at 42-57%, starter at 50%; report and notes
  updated. `docs/design/combat_rules.md` updated (vigilance, guard, blocking, gentler smoother).

Tests: **241 total, all passing.**

Still open (unchanged, lower priority): discard-effect choice (Q7/Q8), trap cap (Q35), balance
band and whether the starter should be intentionally weaker (Q36), life-gain cap and max-life
boon healing (Q11, Q21).

---

# Playable demo (presentation layer)

Work log for the demo built on top of the finished engine. `core/` stays pure logic; everything
new is presentation (`app/`, `ui/`, `world/`, `scenes/`). Screenshot tool: `tools/shot.sh <scene> <name>`
(writes `_screenshots/<name>.png`, git-ignored).

## Demo milestone 1: Game shell - done

- Autoloads: `EventBus`, `Settings` (volumes + fullscreen, `user://settings.cfg`), `Audio` (sound
  catalog + music crossfade), `Session` (content, profile, gold, deck, flags, dungeon run; JSON
  save/load via `SaveSystem`), `SceneManager` (fade transitions + Escape pause menu).
- Custom UI look (`UIStyle` theme: no default Godot widgets), Cinzel + Alegreya Sans fonts, `FancyButton`.
- Title screen over an orbiting 3D view of the town (KayKit hex pieces): New Game / Continue /
  Settings / Quit; settings panel; pause menu.
- Core additions: `DungeonMap`, `TrialOfTheHollow` (map, enemy decks, blessing) with tests (248 total).
- Working title for the game: **Wellspring** (see open_questions.md).

## Demo milestones 2 + 3: Battle screen and card visuals - done

- `CardView` (`ui/card/`): frame tinted per affinity, cost pips, name, type line, rules text with bold gold
  keywords, power/toughness plaque, rarity gem, game-icons.net silhouettes on gradient art. Three looks:
  FULL (hand/zoom), COMPACT (battlefield) and BACK. Glow states (playable/selected/target/attack/block).
- Battle screen (`ui/battle/`): `BattleScreen` (input state machine + AI turn loop), `BattleBoard`
  (card views, layout, event animations), `BattleHud`, `BattleFX`. Driven only by the engine's event
  log: draws, plays, attack lunges, blockers, damage numbers, dissolves, screen shake on big hits,
  mulligan and result panels, keyword tooltips + zoom preview on hover, drag or click to play, target
  arrows for spells, attackers/blockers by clicking. 3D arena backdrop.
- Test tooling: `tools/shot.sh` (screenshots), `tools/ui_driver.gd` + `tools/battle_smoke.tscn` play a whole
  battle through real injected mouse events (click and drag).

## Demo milestone 4: Starter town - done

- `TownBuilder` (`world/`): a hex island built from the KayKit Medieval Hexagon pack (market, tavern = deck
  station, well = Wellspring, mine = dungeon gate, church, houses, windmill, mountains, water, clouds).
  `HexGrid` maps world positions to cells; walkability = walkable cells minus circular obstacles.
- `TownScene`: KayKit Knight with idle/walk animations, WASD movement with sliding collisions, footstep
  sounds, fixed-angle follow camera, warm sun + sky + ACES tonemapping + glow + SSAO, glowing Wellspring
  with motes, floating name plates and markers, objective tracker, gold display, dialogue box, two NPCs
  (Elder Maren, Gatekeeper Brannoch) plus the vendor (Sable), Wellspring color choice, gate confirm.
- Theme baked into `ui/game_theme.tres` (`tools/build_theme.gd`) so CanvasLayer UI is styled too.

## Demo milestone 5: Deckbuilder and vendor UI - done

- `DeckEditor` (core, tested): add/remove rules (owned copies, 3 copies, 2 colors), auto-fill lands.
- `DeckbuilderScreen`: collection grid with affinity/type/cost filters, click to add / right-click or `-`
  to remove, deck list with counts, live validation of the deck rules, save, fill lands, reset, unsaved
  changes prompt. `VendorScreen`: all cards with prices (`CardPricing`, tested), gold, buy confirmation.
- Tests: 257.

## Demo milestone 6: Intro dungeon "Trial of the Hollow" - done

- Node map (`DungeonMapScreen`, `MapNodeButton`, `MapPaths`) over a 3D diorama: Cave Mouth -> Scavenger's Den
  (tutorial battle) -> Hollow Well (deck challenge) -> Mossy Gallery (battle) -> Whispering Shrine (heal 8) ->
  Heart of the Hollow (boss). Life bar carries between nodes (Hollow's Blessing = +10 max life, so 20).
- `ChallengeScreen` (core `ChallengeResolver`), `ShrineScreen`, `RewardsScreen` (gold + choose 1 of 3 cards via
  `RewardGenerator`, tested), trial-complete screen granting the 5 attunement cards once (`CampaignStart`).
- Losing (or retreating) returns to town with a notice; the collection is untouched.
- Session flow: `begin_trial`, `make_dungeon_battle`, `complete_battle`, `apply_rewards`, `complete_trial`.

## Demo milestone 7: Tutorial layer - done

- `TutorialLayer` guides the first battle (Scavenger's Den): opening hand/mulligan, land drop, casting, keywords,
  traps, ending the turn, attacking, blocking. A bubble with a pulsing highlight points at the thing to click and
  advances when the player does it. Skippable ("Skip tutorial"), remembered in the save (`tutorial_done`).
- `TipPanel`: one-time tips on the first visit to the vendor, the deck station and the dungeon map.

## Demo milestone 8: Audio and juice - done

- Sound effects for card draw/play/discard, land, attack, hits (light/heavy), death, spells, traps, heal, turn bell,
  coins, footsteps, doors, dialogue ticks and every button (hover + press): Kenney CC0 packs, `AudioCatalog`.
- Music is original and generated in code (`MusicSynth`): title, town (with wind and birds as ambience), battle
  and map loops, rendered on a background thread at startup and crossfaded by `Audio`.
- Juice: tweened hover/press on buttons, card glow states, floating damage numbers, particle bursts on hits and
  entries, ring flashes, dissolve shader on dying cards, screen shake on big hits, Wellspring motes and light.
