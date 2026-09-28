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

## Demo milestone 9: End-to-end check and polish - partly done

- `tools/run_e2e.sh` plays the demo through the real UI with injected mouse and key events (title, new game,
  walking to the Wellspring, color choice, buying a card, editing/saving the deck, gate, map, tutorial battle
  won by real clicks, challenge, second battle, shrine, boss, rewards, Trial complete). It got as far as the
  second battle, where it exposed a real bug (a bot attached after the mulligan prompt never woke the battle
  loop); fixed with `BattleScreen.set_bot`. **The full run has not completed since that fix**: both reruns were
  stopped by the system for low memory, so I did not restart them. Run `tools/run_e2e.sh` once to confirm.
- Trap cap of 3 added to the engine (`GameState.MAX_TRAPS`, documented in `combat_rules.md`, tested). 261 tests pass.
- README rewritten (how to play, layout, tools). Demo decisions D1-D27 are in `docs/design/open_questions.md`.

## Known issues

- Attacking a Guard always targets the first Guard; no picker.
- Mid-dungeon state is not saved; one save slot.
- Card and world art are placeholders; hex-grass color is tinted at runtime.

## Questions for you

1. Title/working name "Wellspring" and the names Ember/Tide/Root/Grave: keep?
2. ~~Is +10 max life in the Trial (D7) acceptable, or should the base 10 life apply?~~ **Answered
   by Part C: base 10 life, no blessing (D32).**
3. ~~Vendor sells every card from the start (D6): want a discovery/unlock system instead?~~
   **Answered by Part E: yes, built (D37).**
4. Trap cap of 3 (D25): OK?
5. Should draws count as a loss in the dungeon (D13)?

---

# Post-demo work (from your F5 playtest)

## Part A: critical bug fixes - done

Played the demo, found two game-breaking bugs. Both fixed, both covered by a new UI regression
test that drives the real scene with injected input (mouse only for A1, mouse/keyboard for A2)
and both were verified to actually fail against the old code and pass against the fix (see
`docs/design/open_questions.md` D28/D29 for the root causes).

- **A1 - every human turn after the first was skipped.** Root cause: `BattleScreen._fast_end_turn`
  (set by the "End Turn" shortcut button) was never cleared on the human's own next turn, only
  when it became the opponent's turn or the human had to block. It now clears on every
  `TURN_STARTED` event. New test: `tools/battle_human_turns_smoke.gd` (run with
  `tools/run_battle_human_smoke.sh`) plays 6+ full human turns through real injected mouse input
  only (no bot) and asserts the battle screen enters a human decision mode on every one of them.
- **A2 - NPC/vendor interaction.** E already worked; the likely real-world failure is that players
  reached for the mouse and clicking did nothing. Added Space and left-click-the-NPC (screen-space
  picking against the spot marker) as full alternatives to E, matching the "[E] Talk" style prompt
  that already existed. **Update (found while building Part B): the actual root cause was probably
  deeper than the input method - `DialogueBox`'s panel never rendered on screen at all** (an anchor
  preset fighting a manual position; see D30). E's `_check`/state were always correct, so the
  dialogue silently never appeared - which looks exactly like "nothing happens." Fixed alongside.
  New test: `tools/town_interact_smoke.gd` (run with `tools/run_town_interact_smoke.sh`) walks to
  the elder, guard, vendor and deck station with injected input, interacts with each via a
  different one of E/Space/Click, asserts the correct dialogue/screen opens, and asserts the
  dialogue panel's rect actually lands on screen.

Both new UI tests are windowed (real viewport needed for injected input) and are meant to be run
alone, one at a time - the machine this ran on is short on memory for more than one windowed
Godot instance plus the editor. Both pass; the 261 GUT tests still pass.

Visual verification: `_screenshots/battle_turn4plus.png` (Turn 7, the HUD shows "Your turn" /
Main highlighted, waiting on real input - proves A1) and `_screenshots/vendor_open.png` (Sable's
Card Stall fully rendered with stock, prices and gold - proves A2/vendor works end to end).
Screenshots are git-ignored; regenerate with `tools/shot.sh`.

## Part B: new starting flow - done

New campaign start, replacing the town Wellspring color pick (see `docs/design/
starting_deck_and_affinity.md` for the full flow and `open_questions.md` D31 for why).

- **Starting area** (`world/starting_area_scene.gd`, `scenes/starting_area.tscn`): a small,
  enclosed forest clearing built from the same KayKit hex pieces as town (`StartingAreaBuilder`;
  `TownBuilder`/`StartingAreaBuilder` now share a `WalkableArea` base so `TownPlayer` works in
  both). The hero wakes up and talks to themselves (`data/story/intro_story.tres`, the one file to
  edit to rewrite the opening - `StoryText` resource). The only interactable is the cave mouth
  (E/Space/Click, same as town), which leads straight into the Trial of the Hollow with a fixed
  neutral tutorial deck (`Session.begin_intro_trial`). No town access from here.
- **Starting-deck choice** (`StartingDeckChoiceScreen`, right after the boss reward): one deck per
  affinity (`StartingDecks`), each shown with its identity, playstyle and three key cards, built
  from the existing balanced two-color sample decks. Choosing one (`Session.choose_starting_deck`)
  hands over every card in it (legal to play immediately) and unlocks the town
  (`trial_cleared` flag). Losing before choosing sends the player back to the starting area, not a
  town they have not unlocked (`Session.abandon_run`).
- **Wellspring repurposed**: no longer a choice screen: it always "recognizes" the color the
  player already carries (flavor toast + light burst). `Session.choose_affinity` and
  `WellspringChoice` were removed. The old 5-card "attunement reward" is gone too, since owning
  the whole starting deck already does that job.
- `tools/e2e_demo.gd` rewritten for the new flow end to end (title -> starting area -> tutorial
  dungeon -> deck choice -> town), and passes.
- **Two more real bugs found and fixed while building this** (same pattern as A2 - state was
  right, nothing rendered/registered):
  - `CardView.wrapped()` silently ate clicks meant for anything behind it (e.g. a clickable tile),
    because `CardView._ready()` unconditionally resets `mouse_filter` to STOP *after* `wrapped()`
    tried to set it to IGNORE. Fixed with `set_deferred()` (D33).
  - The starting-deck choice tiles' card-preview row was wider than the tile at first pass,
    overlapping neighboring tiles - fixed by sizing the tiles and card scale to actually fit.

266 GUT tests pass (5 new `test_starting_decks.gd` + `test_campaign_start.gd` trimmed of the
removed attunement tests). Screenshots: `_screenshots/starting_area_awaken.png` (wake-up line),
`_screenshots/starting_area_check3.png` (the clearing), `_screenshots/deck_choice_screen.png`
(all four decks, no overlap).

## Part C: tutorial balance - done

- Removed `TrialOfTheHollow.blessing()` (+10 max life); the tutorial run now uses the player's
  plain base life (10), everywhere (the intro run and town replays alike).
- Added a new forgiving `AIPersonality.passive()` and gave it to all three tutorial encounters
  (Cave Scavenger, Hollow Stalker, Hollow Warden), lowered their life (5/4/5) and thinned/land-
  heavied their decks so a beginner's deck can beat them reliably.
- The Whispering Shrine (the node right before the boss) is now a full heal (`heal_amount = 999`;
  `DungeonRun.heal()` already caps at max life).
- New simulator (`core/sim/dungeon_simulation.gd`, pure `core/` logic, tested): plays a whole AI-
  vs-AI dungeon run through `DungeonRun`/`ChallengeResolver` exactly like a real playthrough, no
  UI. `tools/run_dungeon_simulation.gd` runs many and updates `docs/balance_report.md`.
- **Result: 500 runs, 90.0% won** (target 85%) with the fixed neutral tutorial deck, AI-controlled,
  life carried between nodes. See `docs/balance_report.md` for the loss breakdown by node.

266 GUT tests still pass (6 new in `test_starting_decks.gd`... already counted above; plus 2 new
in `test_trial.gd`, 2 removed/replaced there for the dropped blessing).

**Two more real bugs found (and fixed) while finishing the end-to-end pass through Parts B/C**
(the first time this flow ever ran to completion): the deck-choice overlay's own confirm button
was unreachable (a stale identically-labelled button underneath it always won a text search -
D34), and the e2e run's own save verification could never pass because `--no-save` silently beat
the safe custom save path it also sets (D35). Both fixed; `tools/run_e2e.sh` now passes clean,
start to finish, for the first time.

## Part F: rules - done

- **Trap cap is now a modifier**, not a hardcoded limit: `PlayerState.max_traps` (base 3 +
  `Modifier.Kind.MAX_TRAPS`), computed once in `GameState.add_player()` exactly like
  `max_hand_size`. Dungeons/equipment/a future final dungeon can raise it by adding a modifier
  source - no engine change needed. New tests in `test_modifiers_and_decks.gd` and
  `test_traps.gd`.
- **Deck-out is a loss**: already true (`GameState.draw_cards`), already tested
  (`test_drawing_from_empty_library_loses`) - confirmed, no change needed.
- **A drawn dungeon encounter is a loss**: already true (`DungeonRun.finish_encounter` only counts
  `winner == 0` as a win), but untested until now - added
  `test_a_drawn_encounter_also_fails_the_run`.

269 GUT tests pass.

## Part E: discovery / unlock system - done

- **`Condition`** (`core/data/condition.gd`, pure `core/`, no `Session` dependency): flag set,
  dungeon cleared, card owned (copy count), secret found, gold spent (lifetime), player level,
  quest completed, plus `ALL_OF`/`ANY_OF`. Evaluated against `UnlockState`, a plain-data snapshot
  (`Session.unlock_state()` builds one); a null condition always passes. `Condition.teaser()`
  gives a spoiler-free "why it's locked" line.
- **Vendors**: `VendorData`/`VendorStockEntry` attach a `Condition` to each card. The town vendor
  now uses `VendorData.graduated()`: neutral cards and the player's own two colors unlock once
  the home dungeon is cleared; other colors unlock progressively behind lifetime gold spent
  (`Session.gold_spent_total`), rarity-scaled - stock genuinely starts small and grows. A locked
  card shows as a card-back with "???" in place of its price (`VendorScreen`).
- **Card discovery**: `Session.seen_cards` (owned, bought, or actually played/faced in battle -
  `BattleScreen` records this from real game events) backs a new Codex screen
  (`ui/town/codex_screen.gd`, reachable at the new Hall of Records): every card in the game in a
  grid, unseen ones shown as a card-back silhouette, with a "Discovered X / Y" counter.
- **Save/load**: `gold_spent_total`, `cleared_dungeons`, `seen_cards`, `found_secrets`,
  `player_level`, `completed_quests` all round-trip through `Session.to_dict()`/`from_dict()`.
- Tests: `tests/core/data/test_condition.gd` (15) and `test_vendor_data.gd` (4) cover the
  `core/` logic; the Codex/vendor UI wiring is presentation and was checked by screenshot
  (`_screenshots/town_codex_open.png`, `vendor_gated2.png`) and the full e2e pass.

284 GUT tests pass (see docs/design/open_questions.md D37).

## Part D: town expansion - done

Extended `TownBuilder.MAP` from 7x9 to 10x15 (~2.4x by cell count; see D38 for why not exactly
3x) with two new districts, reached from the original town core: the **Harbor Quarter** (east,
across a one-bridge canal near the market) holds the Hall of Records (Codex) and the hidden
vendor's stall, plus open undeveloped plots for future vendors/quests; the **Secluded Grove**
(south of the spawn row) holds the three placeholder secrets, all built on Part E's Condition
system rather than special-cased:

1. **A hidden chest** behind trees - grants gold, `Session.discover_secret("harbor_chest")`.
2. **A locked gate** (a sealed vault) - stays sealed until a nearby, easy-to-miss lever sets a
   flag; the vault checks `Condition.flag(...)` against `Session.unlock_state()`, not a raw
   `if` on the flag, so it genuinely exercises the reusable system.
3. **A hidden vendor** - its NPC and interact spot are only ever constructed
   (`_build_actors`/`_build_spots`) once `Session.found_secret("harbor_chest")` is true, so it is
   not just locked, it is not *there* until the chest is found. Sells a small, always-open stock
   of rare/mythic cards.

One new asset added: `assets/KayKit-Dungeon-Remastered-1.0/props/chest_gold.glb` (same
KayKit/CC0 family already in use - the only 3D chest prop in any approved pack; see `CREDITS.md`).

Screenshots: `_screenshots/town_overview.png` (unchanged core, confirming no regressions),
`town_codex.png`, `town_vault.png`, `town_chest.png` - no clipping or performance issues found.
The full e2e pass (title through vendor purchase and deck save) still passes end to end.

---

# Final pass

## Full end-to-end run

`tools/run_e2e.sh` plays the whole new flow with injected mouse and keyboard input - title,
starting area (wake-up dialogue, walk to the cave, confirm), the tutorial dungeon (all three
battles, the challenge, the shrine, the boss, retrying through the starting area on a loss exactly
like a human would see), the starting-deck choice, town, buying a card, editing and saving the
deck, and a save/load check - and **passes clean, start to finish**. This is the first time in the
project's history that it has completed; see D28-D36 for the six real bugs (two from the original
Parts A/B request, four more found while getting this run to finish) that were blocking it. It
takes about 2 minutes now (down from timing out) because the tutorial dungeon is winnable in one
or two attempts instead of three-plus.

`tools/run_battle_human_turns_smoke.gd` and `tools/town_interact_smoke.gd` (the two regression
tests written for Part A) both still pass after every later change, including the town expansion.

## Screenshot review

Every new/changed screen was screenshotted and looked at, not just exercised programmatically:
battle at turn 7 (A1), the vendor and its dialogue (A2/D30), the starting area awake and at the
cave mouth, the starting-deck choice (all four decks), the gated vendor stock ("???" teasers), the
Codex, and the three new town landmarks (Hall of Records, sealed vault + lever, hidden chest).
Two real problems were caught and fixed this way, not by any automated check: `DialogueBox`'s
panel never actually rendering (D30), and the starting-deck tiles' card-preview row overflowing
into its neighbors (fixed by resizing, see the Part B section above). Nothing else looked off;
the expanded town holds up from a distance and up close, and framerate was not a concern at this
asset budget (all reused, low-poly KayKit pieces).

## What's next / not done

Deliberately out of scope for this pass (flag for later if you want them):
- The hidden vendor's stock, the vault's reward and the chest's reward are all placeholder
  values/cards, not tuned for balance.
- No UI yet surfaces `player_level` or `completed_quests` (Condition supports them; nothing
  drives them yet - see D37).
- The Harbor Quarter's "open plots" are intentionally empty (per the brief) - nothing to fix.
- Locked vendor stock is computed once when the screen opens; crossing a gold-spent threshold
  mid-visit will not reveal new stock until the vendor is reopened.

## Questions for you (consolidated)

Everything below is either new from this pass or still open from before (superseded items are
struck through above, in the original "Questions for you" list).

1. Title/working name **"Wellspring"** and the affinity names Ember/Tide/Root/Grave: keep?
2. Trap cap of 3 (D25), balance band 35-65% (D26), and discard effects staying random (D24): all
   still just my defaults from the first pass - OK, or change any of them?
3. Should draws count as a loss **outside** dungeons too (practice battles), or only in dungeons
   as implemented (D36)?
4. The starting-deck choice (Part B) permanently commits the player to one of the four
   two-color decks as their identity. Is that the right weight, or should it feel more provisional
   (easy to reverse early on)?
5. The three Part D/E secrets (chest, vault+lever, hidden vendor) are placeholders "to prove the
   system" - do you want real rewards/balance for them, or should they stay as a template for you
   to fill in later?
6. Is a ~2.4x town (not the literal "about 3x" asked for) acceptable, given the reasoning in D38,
   or would you like it pushed further?

---

# Second follow-up brief (new Part A-G, September 2026)

A new work order reuses the letters A-G for a different, larger set of parts (battle UX, card
rarities, a new starting flow, tutorial balance, player progression 1-30, the deck color rule,
zone portals). To avoid confusion with the Part A-G already completed above, every section below
is titled "New Part <letter>" and cross-references the old one by name where relevant.

## New Part A: battle UX - done

- **Space advances the current phase/step**: wired to fire whatever the primary button
  (`BattleHud.primary_button`) would do - it already *is* "the end-step button for the current
  phase" in every mode that advances a turn (Main/Attack/Block) - and only in those three modes.
  The button's own label shows the hint ("...  [Space]"), same convention as the existing
  "[E]  Talk" prompts. See D39.
- **"Select All Attackers" button** (the brief's "Attack with all", renamed - see D40) appears
  only during declare-attackers, selects every creature `game.possible_attackers(0)` reports, and
  the player can still click one of the selected creatures to deselect it before confirming
  (unchanged existing behaviour - confirming is still the primary button or Space).
- **Board clears before the result panel**: `BattleBoard.clear_board()` dissolves every remaining
  card (same shader as a creature dying) after the victory/defeat banner and tutorial teardown,
  strictly before the result panel is built. See D41.
- **New human-input UI test**: `tools/battle_space_attackall_smoke.gd` (run with
  `tools/run_battle_space_attackall_smoke.sh`) plays a real battle through injected mouse clicks
  for card plays and the Space key for every phase/step advance (never the primary/"End Turn"
  buttons directly), clicks "Select All Attackers" and asserts the selection matches
  `possible_attackers(0)` exactly, deselects one attacker and confirms it was removed, then
  confirms the reduced attack with Space. Passes, and the existing
  `battle_human_turns_smoke`/`town_interact_smoke` regression tests still pass unchanged.

284 GUT tests still pass (no `core/` changes - this part is presentation only).

## New Part B: card rarities - done

- `CardEnums.Rarity` renamed in place to the four required tiers, **Common, Uncommon, Epic,
  Legendary** - the old `RARE`/`MYTHIC` sat at the same ordinals, so every saved `.tres` card
  needed no migration (see D42).
- `CardPricing`, `RewardGenerator`'s weight tables, `VendorData.graduated`'s spend thresholds and
  the hidden-vendor stock filter (`world/town_scene.gd`) all already indexed by rarity ordinal, so
  pricing and reward generation needed no logic changes, only the renamed constant references.
- `CardView`'s rarity gem is now a genuinely distinct **shape** per tier, not just a color: a
  circle (Common), the original diamond (Uncommon), a hexagon (Epic) and a four-point sparkle
  (Legendary) - see D43. New "Rarity" section added to `docs/design/combat_rules.md` as the
  source of truth.
- Verified by screenshot (`_screenshots/rarity_gems_check.png`, `rarity_epic_check.png`, both
  git-ignored): existing Common/Uncommon cards still render correctly, and the renamed Epic tier
  (Necromancer) shows its new purple hexagon gem and "Epic" label. No card is Legendary yet in the
  placeholder content, so the sparkle shape has not been seen on a real card (only reviewed as
  code).

284 GUT tests still pass (no test exercised rarity names directly, so none needed changes).

## New Part C: new starting flow and starter deck - done

Reworked the starting flow again (this is the third version - see `docs/design/
starting_deck_and_affinity.md` "History" and D44): the player now picks their **element** in the
starting area, before the tutorial dungeon even starts, and carries a single-element starter deck
through it that grows into a full legal deck by the end - not a fixed neutral deck followed by a
two-color deck choice afterward (that whole step is removed).

- **`ElementChoiceScreen`** (`core/dungeon/element_choice.gd` + `ui/dungeon/
  element_choice_screen.gd`): shown from `StartingAreaScene` when confirming "Enter" for the very
  first time (no profile yet). Four tiles, one per element, each with its identity, playstyle and
  3 representative cards (reused almost verbatim from the removed `StartingDecks` pair-deck text,
  reframed per single color - D44). A retry after an abandoned first attempt skips this and reuses
  the already-chosen element. Replaces `StartingDecks`/`StartingDeckChoiceScreen`, deleted outright.
- **Starter deck**: 23 colorless non-land cards + 19 basic lands of the chosen element = 42 cards
  (`CampaignStart.starter_deck`/`starter_spells`), including two new 1-cost neutral creatures
  (`apprentice_blade`, `scrappy_recruit`, 3 copies each - D48) so turn 1 always has something to
  do. Short of the normal 45-card minimum on purpose.
- **The 45-card minimum is waived only in the tutorial dungeon**, via a new `Modifier.Kind.
  MIN_DECK_SIZE` and `DeckValidator.min_deck_size(modifiers)` (a modifier, not a hack - D45).
  `DeckEditor`/`DeckbuilderScreen` now thread a `ModifierSet` through everywhere they previously
  used the plain constant, which also fixes a pre-existing gap where the deck station never
  respected dungeon/equipment `MAX_DECK_COLORS` boons either.
- **Tutorial rewards**: after each of the 3 reward-granting fights (2 battles + boss), the pick is
  restricted to the player's own element only on this first-ever clear
  (`RewardGenerator.card_choices_for_color`, `Session.complete_battle` - D47); a later replay of
  the trial offers normal full-variety rewards. Each pick joins the run's deck immediately
  (`DungeonRun.gain_card`), not just the permanent collection, so by the boss the deck is a real,
  legal 45 cards - the only on-element cards the player leaves the dungeon owning are those 3.
- **Clearing the trial** (`Session.complete_trial`) is what unlocks the town now: the run's
  finished 45-card deck becomes `Session.deck`, `intro_dungeon_cleared`/`trial_cleared` are set.
  `RewardsScreen` collapsed its old two-branch ending (first-clear deck choice vs. replay recap)
  into one "Trial Complete -> Enter town" step with slightly different flavor text.
- **A deck builder inside the dungeon**: a "Deck" button on the dungeon map screen opens
  `DungeonDeckbuilderScreen`, a ~20-line subclass of the town's `DeckbuilderScreen` that edits
  `DungeonRun.current_deck()`/`run.modifiers()` instead of `Session.deck`, saving by replacing
  `run.base_deck` (D46) - same validation rules as town (including the waiver while it applies).

**Full end-to-end verification**: `tools/run_e2e.sh` was rewritten for the new flow (title ->
element choice -> tutorial dungeon, trying the in-dungeon deck builder once -> 3 battles with
on-element reward picks verified card-by-card -> trial complete -> town, buying a card and editing
the deck) and **passes clean**, including a real loss-and-retry (the first attempt this run
happened to lose battle 1, retried with the same element, as a human would). One real bug was
found and fixed getting there: vendor/deck-station grid clicks silently missed any card scrolled
out of view (D49, test tooling only, not a product bug).

289 GUT tests pass (new coverage for `MIN_DECK_SIZE`, `DeckEditor` with/without the waiver,
`card_choices_for_color`, and `test_element_choice.gd` replacing `test_starting_decks.gd`).
`docs/design/combat_rules.md` gained a "Starting deck" section; `docs/design/
starting_deck_and_affinity.md` was rewritten for the new flow.

## New Part D: tutorial opponent balance - done

- **Non-boss opponents are now genuinely weak and vanilla**: Cave Scavenger and Hollow Stalker's
  decks only use low-stat vanilla creatures (including a 1-cost one, `apprentice_blade`), no
  removal, no card draw - `field_medic`'s +3 life turned out to be disproportionately strong at
  this life scale and was cut. Both decks are also much more land-heavy now (65-70%) so the AI
  frequently has nothing to deploy.
- **The tutorial AI actually attacks**: a new `AIPersonality.aggressive_dumb()` ("Aggressive
  (tutorial)") - eager to attack, barely weighs counter-attack risk - replaces the old `passive()`
  (never attacked, kept as a general-purpose easy personality for later use) on both non-boss
  encounters. Since opponent traps are already hidden from the AI's clones, an eager-but-blind
  attacker walks into the player's traps (Pitfall etc.) exactly like a real opponent would.
- **The boss is a real step up but still fair**: `balanced()` personality (smarter than the
  tutorial mooks, not the full min-maxing `aggressive()`), a few real effects (a death trigger,
  token generation from `necromancer`) instead of all-vanilla, life dropped to 3 to keep the whole
  dungeon's win rate on target.
- **Simulation harness extended** (`core/sim/dungeon_simulation.gd`): now simulates each element's
  real 42-card starter deck (not the old fixed neutral template) with the 3 on-element reward
  picks added along the way exactly like a real playthrough (`reward_color` param, `DungeonRun.
  gain_card`), and counts real enemy attack declarations (`RunResult.enemy_attacks`) to confirm
  Part D's fix. `tools/run_dungeon_simulation.gd` now runs all four elements and writes a
  per-element table to `docs/balance_report.md`.
- **Result: 500 runs per element (2000 total), 85.2-91.0% per element (target 85%), 88.3%
  overall, 9,472 real enemy attacks recorded** - see `docs/balance_report.md`. Getting from the
  initial ~38% (once the AI actually started attacking) back above target took life cuts, deck
  thinning and toning the boss's AI/deck down together - see D51 for the full tuning story.

295 GUT tests pass (new: `test_dungeon_simulation.gd`; extended `test_trial.gd` and
`test_ai_player.gd` for the new personality/decks). The general (non-tutorial) balance report was
also regenerated since the two new neutral cards and the Wanderer's Pack template's new 42-card
size changed it slightly (noted inline in `balance_report.md`).
## New Part E: player progression (levels 1-30) - done

The biggest single part of this brief: 30 levels, XP/gold from every encounter, life/hand/item
slot growth, chosen equipment-slot unlocks, level-dependent deck copy limits, and a placeholder
equipment/item framework, all built on the existing Modifier pipeline.

- **`ProgressionTable`** (`core/data/progression_table.gd`, one function, `build()`, is the whole
  source of truth): 30 `LevelData` rows, each an absolute snapshot (not a delta) of max life,
  opening hand size, item slots, copy limits by rarity, whether an equipment choice happens, and
  (if nothing else lands that level) a filler reward. Verified in code, not just by design, that
  every level 1-30 grants something (`test_every_level_up_grants_something`). Full table written
  to `docs/design/progression.md` by `tools/generate_progression_doc.gd`. Milestone level choices
  (which level bumps which stat) are judgment calls - see D53.
- **XP**: `EncounterRewards` (Tutorial/Normal/Elite/Boss = 15/30/60/120, gold similarly scaled) -
  `DungeonMap.MapNode` gained a `difficulty` field, `Session.make_dungeon_battle`/`complete_battle`
  award XP the same way gold already was. Curve reasoning and its "no real length to calibrate
  against" caveat: D52.
- **Life 10->25, hand 5->8, item slots 1->4**: `PlayerProfile.apply_level(row)` applies one level's
  absolute stats - never inferred automatically from `level` alone, so tests/tools that set
  `max_life`/`opening_hand_size` directly for scenario setup are untouched (only whatever calls
  `apply_level` - i.e. real XP gain - changes them for real play).
- **Equipment slots, chosen**: `EquipmentSlotChoiceScreen` offers only the not-yet-unlocked slots;
  `Session.pending_equipment_choices` is a counter (not a flag) so a big XP jump crossing more than
  one choice-level never silently loses one (D54).
- **Deck copy limits by rarity and level**: `PlayerProfile.max_copies_for(rarity)`, read by both
  `DeckValidator.validate` (replacing the flat `MAX_COPIES=3`) and `DeckEditor.why_not_add` - the
  deck station's rules panel now shows a live per-rarity breakdown instead of one flat number.
- **Equipment/item framework**: `EquipmentData extends ModifierSource` (slot + Modifiers - drops
  straight into `PlayerProfile.equipment`/the pipeline, D57) and `ItemData` (uses + one
  `EffectData`, resolved between fights by `ItemUseResolver` against the current `DungeonRun` -
  D55, only `GAIN_LIFE`/`LOSE_LIFE` are supported outside a duel, a documented scope limit). 5
  placeholder equipment pieces (one per slot) and 3 placeholder items - `Session.equip_item`/
  `unequip_slot`/`use_item` wrap the profile methods and save.
- **A real mechanical use for the "vendor unlock" level reward**: `VendorData.graduated`'s
  off-color unlock is now `gold_spent OR player_level` (either path opens a rarity tier) - D56.
- **UI**: `CharacterScreen` (town, hotkey **C** or a HUD button - level/XP bar/stats/item slots/
  equipment slots, locked ones shown locked, equip/unequip/use right there) and `LevelUpScreen`
  (shown from the rewards screen right after a battle levels the player up - recaps every level
  gained, then walks through any pending equipment choices and card-reward picks one at a time
  before letting the dungeon flow continue). All three new screens (Character, Level Up, Equipment
  Slot Choice) were screenshotted in every state (locked/unlocked/equipped/multi-level) and render
  correctly - screenshots are git-ignored, verified with disposable debug scenes then deleted.
- **A real bug found and fixed via the e2e driver**: `tools/e2e_demo.gd` now forces one battle's
  XP high enough to cross both an equipment-choice level and a card-choice level in one jump, then
  clicks all the way through it (not just the simple single-level case) - this caught
  `LevelUpScreen` leaking its resolved equipment-choice overlay instead of freeing it before
  showing the next step, which would have left it clickable underneath forever on a real multi-
  choice level-up. Fixed (D58); the full e2e run now passes clean start to finish with this path
  genuinely exercised, not just left to natural XP pacing.
- **Save/load**: level, xp, equipment_slots, owned/equipped equipment, owned items + uses
  remaining, and pending equipment choices all round-trip through `Session.to_dict`/`from_dict`.
  `Session.player_level` (a placeholder field from D37, never driven by anything) is retired in
  favor of `profile.level`, which is now the real thing driving `Condition.PLAYER_LEVEL`.

315 GUT tests pass (19 new: `test_progression.gd` covers the table, leveling, copy limits,
equip/unequip and item use end to end; `test_vendor_data.gd` gained a level-unlock case).
`docs/design/combat_rules.md` gained a "Progression" section and its copy-limit line was updated.

## New Part F: deck color rule - not started
## New Part F: deck color rule - not started
## New Part G: zone portals - not started
