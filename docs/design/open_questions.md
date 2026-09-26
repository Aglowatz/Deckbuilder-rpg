# Open Design Questions

Questions that came up while implementing the rules engine. Each entry records what was
chosen and why so it can be revisited. Newest entries are at the bottom of each section.

## Rules interpretation

| # | Question | Chosen | Why |
|---|----------|--------|-----|
| 1 | Do attackers tap when attacking? | Yes. Attacking creatures tap and untap at the start of their controller's next turn, so they cannot block on the opponent's turn. | Gives attacking a real defensive cost; there is no Vigilance keyword to offset it. |
| 2 | What does **Guard** ("enemies must attack this if able") mean when attackers normally hit the player? | While a defender controls any Guard creature, every attacker must attack a Guard creature instead of the player. Unblocked damage lands on that Guard creature. Guards can still be blocked-for/blocked normally. | Smallest change that makes the keyword literal and meaningful without adding a general "attack a creature" system. |
| 3 | Can one blocker block several attackers? | No. Each blocker blocks at most one attacker; each attacker has at most one blocker. | Matches "at most one blocker per attacker" and the simplest reading of the combat rules. |
| 4 | Blocking restrictions | Tapped creatures cannot block. Flying attackers can only be blocked by Flying or Reach. Summoning-sick creatures may block. | Standard for the genre. |
| 5 | Which lands does auto-payment tap? | Colored pips are paid by matching lands first; generic cost is paid by Neutral lands first, then from the color the player has the most untapped lands of. The caller may pass explicit lands to tap. | Keeps mana flexible for later casts without a manual payment UI. |
| 6 | Neutral lands? | A land with color NEUTRAL produces colorless mana that only pays generic costs. Not used by content yet. | Free to support, useful for later. |
| 7 | Hand size overflow | Cards are drawn even when over the max hand size; at end of turn the player must discard down to their max. | Standard; keeps draw effects from being wasted mid-turn. |
| 8 | Discard effects | The affected player discards random cards from hand. | No decision step needed inside effect resolution. |
| 9 | Chosen targets for non-spell triggers | Triggered effects that name a chosen target are auto-targeted by the engine (best enemy for harmful effects, best ally for beneficial ones). Spells and creature ETBs take the target chosen at cast time. | There is no priority/stack, so no place to prompt mid-turn. |
| 10 | Multiple chosen-target effects on one card | All chosen-target effects on a card share the single target picked at cast time when it is legal for them, otherwise they auto-target. | Keeps the action API to one target per play. |
| 11 | Lifegain cap | HEAL, GAIN_LIFE and Lifesteal cannot raise life above max life. A STARTING_LIFE modifier may start a duel above max life. | Keeps max life meaningful. |
| 12 | Tokens | Tokens vanish instead of going to the graveyard or hand. | Standard. |
| 13 | Artifacts | Artifacts stay on the battlefield, cannot be targeted or destroyed in this version. They can carry ON_ENTER / START_OF_TURN / END_OF_TURN / ACTIVATED effects. | No artifact-removal cards are planned yet. |
| 14 | Activated abilities | Cost generic mana, usable once per turn per permanent, only in your main phases. | Simple and enough for the data model. |
| 15 | Both players reach 0 life at once | The game is a draw. | Only fair result. |
| 16 | Turn limit | Games not decided after `turn_limit` turns (default 100 total turns) end as a draw. | Prevents infinite stalls in AI simulation. |
| 17 | Who moves first | Player 0 by default; `GameOptions.first_player = -1` picks randomly. The first player skips the draw on turn 1. | Matches combat_rules.md; option keeps simulation fair. |
| 18 | Hand smoother default | On by default (2 candidate hands, keep the one whose land count is closest to deck ratio x hand size; ties keep the first). Mulligan re-uses the smoother. | Written as a player-facing option; default on because it is the intended experience. |
| 19 | Free mulligan | One per player: shuffle the hand back and draw the same number of cards. | "One free mulligan" - no card penalty. |
| 20 | Whose combat starts trigger START_OF_COMBAT_EFFECT modifiers? | Only the modifier owner's own combat phase. | "Start-of-combat" reads as the owner's turn structure; effects that should hit every combat can be given to both players. |
| 21 | Max-life boons mid-dungeon | A boon/source that raises max life also raises current life by the same amount. | Standard roguelike behaviour; otherwise a "+max life" reward would feel empty. |
| 22 | Full heal on entering a dungeon | Life is set to max life (including dungeon modifiers), not to max life + STARTING_LIFE modifiers. | STARTING_LIFE is a per-duel bonus; the dungeon heal is about max life. |
| 23 | Deck color limit and modifiers | `MAX_DECK_COLORS` modifiers add to the base (2, or 4 after postgame) and the total is capped at the four real land types. | Only four colored types exist, so a higher limit is meaningless. |
| 24 | Ownership checks in deck validation | Off by default (`check_ownership = false`); when on, deck copies cannot exceed owned copies and basic lands are always available. | Content/tests build decks without a collection; the game can turn it on. |
| 25 | Which card is lost by a LOSE_CARD challenge outcome? | The sacrificed card if there is one; otherwise the priciest non-basic revealed card; otherwise a random non-basic card from the deck. Basic lands are never lost. | Makes reveal challenges bite (you lose something you saw) without ever wrecking the mana base. |
| 26 | Challenge reveal randomness | Reveals use a shuffled copy of the run's current deck and a caller-supplied seeded RNG. | Keeps challenges deterministic in tests and independent of any duel state. |
| 27 | PAY_LIFE when the player cannot afford it | Declined automatically (nothing happens) if life <= the price, so the toll can never kill the player. | Avoids an unwinnable "pay or die" prompt. |
| 28 | Sacrifice challenge with nothing to give | Counts as a failure with no outcomes (no failure penalty is defined on the example). | Nothing to sacrifice = nothing lost. |
| 29 | Does the AI see hidden information? | It sees everything except the opponent's face-down traps, which are removed from its look-ahead clones (so it walks into them like a human would). It does read the opponent's board and hand size; it never uses the opponent's hand contents to decide (there are no instants, so hands cannot matter to a one-step look-ahead). | Fair-feeling opponent without needing an information-set model. |
| 30 | AI search depth | One step: each candidate action is applied to a clone and the resulting position scored. Attacks also simulate the opponent's best blocking reply (chosen with the same one-step look-ahead). | Matches the milestone spec; keeps simulation of thousands of games fast. |
| 31 | AI targets for its own spells | Chosen by the same look-ahead (each (spell, target) pair is scored), not by the engine's auto-target heuristic. | Better play for free. |
| 32 | "5 sample decks (one per color pair + one neutral starter)": 4 colors make 6 pairs, not 4 | Built the 4 ring pairs (A/B, B/C, C/D, D/A) plus the neutral starter = 5 decks, so every color is in exactly two decks. A/C and B/D are not built. | The explicit count of 5 wins; the ring keeps color coverage even. Adding the two missing pairs is easy (a recipe each in `ContentDefinitions.deck_recipes()`). |
| 33 | "40 placeholder cards: 10 Neutral and ~8 per color" | Exactly 40: 10 Neutral + 8 (A) + 8 (B) + 7 (C) + 7 (D). Plus 5 basic lands and 1 token (Spirit), which are not counted as cards. | Matches the total; the per-color split is the "~8". |
| 34 | Neutral starter deck needs lands | Added a Neutral basic land (colorless mana, pays generic costs only). Decks use 17 lands / 28 spells. | Lets the starter be genuinely colorless. Easy to swap for a real color if you would rather. |
| 35 | Trap limits | No cap on set traps; each fires once then goes to the graveyard; several traps can fire on the same event. | No rule given; a cap can be added in `GameState.cast()`. |
| 36 | Balance pass | One tuning round after the first round-robin (see `docs/balance_report.md`); all decks 44-55%, one matchup (Grave & Ember vs Wanderer's Pack) at 32/68. Stopped tuning there. | 100 games/matchup is +/-10 points of noise; the AI does not yet understand sacrifice synergies, so deeper tuning should wait. |
| 37 | Simulation turn limit | 60 total turns, then a draw (2 of 1000 games hit it). | Avoids endless stalls in bulk simulation. |
| 38 | Where do effect scripts and resource classes live? | `core/data/` (resource classes: cards, effects, modifiers, decks, profile), `core/game/` (rules), `core/dungeon/`, `core/ai/`, `core/sim/`; generated `.tres` in `data/`. | `data/` holds only .tres per CLAUDE.md; script classes live with the rules. |
