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
