# Battle AI audit (Oct 23 2026) - how the AI plays today, and its worst habits

Part 1 of the "BATTLE AI UPGRADE" brief. Evidence: 24 replayed sim games (`tools/replay_encounter.gd --all --verbose`, new flag) across
the tutorial, the store room, the four town gatekeepers (one enemy per Path), four zone roamers, two bosses, with the player seat on
each of the four Paths; logs were read by hand. Think times are from the same runs. The engine itself checked out (one suspected
early Red Tape expiry was a misread of the log).

## 1. How the AI chooses today (`core/ai/ai_player.gd`, 541 lines)

One brain for every seat, every encounter and every skill level; an `AIPersonality` (6 weights + attack/block biases) is the only knob.
Every decision clones the state (`GameState.clone(false, hide_traps_of = opponent)`, so it never sees the opponent's traps), applies each
candidate and scores the result with `evaluate()` **one step ahead**:

- `evaluate` = own HP - foe HP (with a bump under 6 HP) + board value (units: `2*atk + def + 2*keywords`, halved; other permanents 2.0;
  traps 3.0 flat) + hand (1.0 per card, 0.4 per infrastructure) + 0.5 per infrastructure + 0.3 per held resource (2.0 for fuel the
  hand can spend) - `threat` (the damage the foe's attackers would deal after my ready units each soak the strongest one, +20 if lethal).
- **Main phase**: infrastructure first (the type the hand's pips need). Then every PLAY / ACTIVATE_ABILITY / USE_RESOURCE from
  `legal_actions()` is tried on a clone; the single best gain wins; repeat until nothing beats passing by 0.05. No sequencing of the turn:
  each action is judged alone, in whatever order the greedy loop finds. Energy-only abilities are valued by the best single follow-up play.
- **Resources**: Iron only in Main 1 on a unit that can attack; Red Tape on a foe unit that could block (Main 1) or attack next turn;
  both valued as "best attack outcome after vs before" (`_best_attack_outcome`, which itself runs the attack chooser and the foe's
  block chooser). Contracts always considered. Ingredients/Garbage are only spent through card abilities.
- **Attack**: candidates = none / everyone / each single / the "safe" set (defense above the strongest ready foe, or Flying) / the top-2 by
  attack. Each is scored after the opponent's modelled blocks (the same `choose_blocks`), plus `attack_bias` per attacker.
- **Blocks**: candidates = none / value blocks (kill-and-survive, then even trades) / value + chumps until not lethal / chumps only /
  full enumeration when <= 12 combinations. Scored by `evaluate` after damage, plus `block_bias` per blocker.
- **Mulligan**: keep unless infrastructure < 2 or > hand - 2. **Discards**: lowest keep value (infrastructure is valuable until 5 are out).
- **Targets** come from `legal_actions()` combos (first-found on ties); triggered abilities auto-pick (strongest enemy / best ally).
- Encounter rules, timed summons, boss protocols, dungeon rules: not read at all. Path identity: not read at all.
- Skill levels: none. The tutorial uses two deliberately dumb personalities (`aggressive_dumb`, `first_duel`); Normals, Elites and
  Bosses share the full brain with Aggressive / Balanced / Defensive weights (dungeon_content: 7 Aggressive, 4 Balanced, 1 Defensive).
- **UI pacing** (`BattleScreen._ai_step`): 0.35 s pause, 0.5 s announce per action, divided by the battle speed; one action at a time.
- **Think time** (this PC, headless): avg 1-32 ms per decision, max 722 ms (Prudence with 5 units a side and many Red Tape targets);
  nothing over 1 s in 12 verbose games. A 2-ply search would not fit without a time box.

## 2. The worst habits (ranked by how much they cost fun or correctness)

| # | Habit | Evidence (replay) | Why it happens |
|---|---|---|---|
| 1 | **Turtling - attacks are skipped far too often.** 38 "no attack, attackers available" against 54 attacks in the 12 town games; the player seat skipped 24 of 47 attack decisions. | Beefcake L3 vs Prudence: t7 holds Leg Day Survivor 4/2 + Militia 2/2 against a lone summoning-sick Notary Wraith; t10-t13 holds three Hustle units at 6-8 HP while Prudence builds five bodies, then loses. Moss (8/9 Acid Vomitor) does not attack into a 1/2 Skeleton Clerk. | Attacking exhausts the unit, so `threat` counts one blocker fewer and the one-step score drops; the only upside counted is HP points. No race arithmetic ("I win in 2 turns, they need 3"), no "their block costs them more than me". |
| 2 | **Blocks are bad at low HP and never think a turn ahead.** 17 "no block with blockers available" in 12 games, several fatal. | Brick (10 HP, Gym Bro 1/1 + Portal Ripper 2/2) takes 8 from Pastry Artificer 1/3 + Cake Golem 4/4 + Meatloaf Golem 3/3 unblocked, is at 2 HP and dies next turn; a chump on the Cake Golem kept him at 6. Chef at 2 HP blocks the 1/1 Snack and lets 4+1+2 through. | The block chooser only forces chumps when *this* attack is lethal; otherwise it trades a unit's board value against HP points linearly. No look at the next attack (2-ply), no value for "I am the one who is behind". |
| 3 | **Iron and Red Tape are wasted.** Iron is spent in Main 1, then the attack is not made; Red Tape goes on 1/1s on turn 2. | Brick t9: Flex on 'Em, Iron on Gym Bro, then "no attack (could attack with 2)". Beefcake player t11 and t13 vs Prudence: Iron, then no attack. Prudence t2: 1 energy + Red Tape on a summoning-sick Hamster Wheel Runner 1/1 with nothing of her own on the table; Shambling Manager t10: five Red Tapes in one turn with 4 cards in hand and no attack. | The resource's gain is computed by `_best_attack_outcome` (no `attack_bias`, on a board that then changes), while the real attack decision uses another score - the two disagree. Red Tape's threat-reduction gain counts even on tiny attackers. Nothing budgets energy across the turn. |
| 4 | **Zero-attack units attack.** | Moss: "ATTACK Raccoon 0/2, Acid Vomitor 2/5, Bird of Paradump 0/1" and later "Raccoon 0/2, Bird 0/1, Mulch Mole 0/2" - four attackers, one of them real; the 0-power ones just lose their blocks. | The "everyone" candidate scores the same as the real attackers alone (0 damage, 0 threat change from a 0/1) and ties go to the first candidate. Looks silly in the UI and announces "attacks with Raccoon and 2 more". |
| 5 | **Harmful effects aimed at its own units.** | Beefcake player: "PLAY Portal Ripper -> Village Militia 2/2" (its own Militia can't block this turn), then no attack. | `legal_actions` offers every legal target (spec `unit`), the one-step score sees no difference because no attack follows, the first combo wins. Needs: never aim a harmful effect at a friend unless the score says so clearly, and value "can't block" by the attack it enables. |
| 6 | **No plan for the turn.** Spells and resources are fired before units; energy goes to the first good-looking thing. | Brick t9: 2 energy on Flex on 'Em (2 face), 1 on Iron, no unit played, no attack; the Gourmand player holds 6 Ingredients for 4 turns because no spender is on the table, then casts Pastry Artificer and immediately cooks (fine) - but never plays the Hearth Kitchen earlier. | Greedy, one action at a time, no candidate *sequences* ("unit, then Iron, then attack" vs "spell, then attack"), no "save the energy for the Cook next turn". |
| 7 | **Tools are re-attached every turn to the same unit, or shuffled around.** | Refusemancer player: Traveler's Sword "-> Curbside Rat" on t6, t8 (already attached), then "-> Dumpster Diver" t14, back and forth. Each is an announced action. | Attach is an ACT ability; the clone shows a tiny positive gain (the unit value changes the threat sum) or a 0-cost tie. Should attach once, to the unit that attacks. |
| 8 | **Buffs land on the unit that never attacks.** | Moss: 7 Raised Bed buffs + Manure Miracle on Acid Vomitor (10/11), which exhausts every turn to deal 2 damage and attacks every other turn at best; the Raccoon and the Bird stay 0-1 attack. | Buff gain = board value (2*atk+def), independent of whether the unit will ever connect. |
| 9 | **Traps are set the moment they are affordable, with no thought to their condition** (and the AI never reasons "the player probably has a trap"). | Counterweight (3 damage to an attacker) set on t5 when the player's only unit is a 1/2 Line Cook; Underdog's Gambit ("if you control fewer units") kept set while the setter is the wide side. | Flat `TRAP_VALUE` 3.0. Acceptable for a PvE foe, but the setter could at least prefer traps whose condition the board makes likely, and hold a trap slot for the right one. |
| 10 | **Encounter rules and one-sided modifiers are invisible to it.** | Beefcake in the Rotheart keeps playing x/1 units into Rot (end-of-turn death at 1 defense) - the Oct 22 log's 17-44% outlier; Vellum's "Zombie Temp every second turn" and the Graveyard's escalating summons are never planned around (no "hold the board for the summon", no "race before the escalation"). | Nothing in the AI reads `ModifierSet`; the rules only act through the engine's state. |
| 11 | **Missed or late lethal through sequencing.** | Shiro game 1 t15: Shiro at 23 HP, the player at 4 HP with three blockers; Shiro plays G-17, a Red Tape and attacks with one unit (3 damage) - a second Red Tape or the Contract on a blocker was the kill. | Lethal is only found when one action's clone ends the game; a two-action kill (resource on a blocker, then attack) is invisible unless the greedy order happens to find it. |
| 12 | **The sim's player seat has the same habits**, so balance numbers lean: aggressive starting decks (Beefcake) look weaker than they are, defensive ones (Gourmand walls) stronger. | 24 skipped attacks out of 47 on the player seat; Oct 21's "Golem walls every Path (~65%)" and the Red Tape Dispenser / Stock the Pantry spam noted in the balance log. | One brain, one skill level. |
| 13 | **No Path identity, no skill levels, no boss signature.** Moss plays like Prudence plays like Brick, up to three weights. | - | Design gap, not a bug: `AIPersonality` is weights only. |

Habits that are fine as they are: infrastructure choice (the Path the hand needs), mulligans, discards, removal targeting (Dropped
Weights on the Notary Wraith, Pink Slip on the best <=3 attack unit), Cook/golem makers used as soon as they are affordable, Mortimer's
Reinstate, Hearth Kitchen healing when damaged, hiding the opponent's traps from the look-ahead, never freezing (max 0.7 s).

## 3. What the engine already offers the new core

- `GameState.clone(false, hide_traps_of)` is cheap (shares deck cards); `legal_actions()` lists every play / ability / resource use with
  target combos (capped at 30 per card); `possible_attackers/blockers`, `declare_attackers/blockers` run full combat with every keyword
  (Flying/Swat, Elusive, Bulldoze, Sucker Punch, One-Two Punch, Toxic, Nourish, Overtime, Unbreakable) and all triggers, so a look-ahead
  that *applies* combat on a clone needs no combat math of its own - only a fast estimate for pruning.
- `get_attack(card, expiring_for)` already answers "what will this unit attack with next turn after Red Tape expires".
- `ModifierSet` on each `PlayerState` exposes the encounter rules (`TIMED_SUMMON`, `STAT_CHANGE`, `ROT`, `START_OF_TURN_EFFECT`, ...).
- `CardAbility` (parsed scripts) tells what an ability does (`effects[].name`: damage, buff, pump, create, add...) and costs.

## 4. Baseline numbers (for the before/after table in `ai_state.md`)

Small-sample replays only (4 games per cell, seeds 7000+); the proper before numbers are the Oct 22 whole-catalog sweep
(`docs/design/sim/oct22n/m1_*.md`: Normal 90% / 58 fights, Elite 67% / 22, Boss 59% / 22; tutorial runs B 91 / G 89 / R 87 / N 94).
Think time today: avg 1-32 ms, max 722 ms per decision.
