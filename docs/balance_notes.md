These notes are hand-written and are appended to the generated tables above by
`--notes=res://docs/balance_notes.md`.

**Overall.** After one tuning pass all five decks land between 44% and 55% overall. The first
player wins 40-57% of decided games per matchup (within noise at 100 games), so going first is not a meaningful
advantage. Games last about 15 turns (both players' turns combined), i.e. roughly 7-8 turns each.
With 100 games per matchup the 95% confidence interval on a single win rate is about +/-10
points, so only gaps larger than that (for example Grave & Ember vs Wanderer's Pack at 32%) are
worth acting on.

**Tuning pass applied to the first run.** (Before: 61% / 56% / 47% / 45% / 43%.)
- Tide & Root (was strongest, with a 72% and a 66% matchup): 3 Dissolve -> 2, 2 Frost Sentry -> 1,
  +1 Whispering Shade, +1 Rampaging Boar.
- Grave & Ember (was weakest): fewer Martyr/Bone Servant, +1 Bloodthirst Wolf, +1 Raider,
  +1 Blazing Charger, +1 Warcry, -2 Sellsword; Martyr now drains 3.
- Wanderer's Pack (neutral starter): Ironclad 3/4 -> 4/4, Stone Sentinel 2/4 -> 3/4 Guard.
- Frost Sentry became 1/4 Defender + Reach so every keyword appears on at least one card.

**Known weak spots.**
- Grave & Ember is still the weakest deck (44%) and loses badly to the neutral starter (32%): the
  starter's 3/4 Guard and 4/4 wall out its 1- and 2-power creatures. Its identity (sacrifice /
  value) depends on cards the AI hardly uses: Dark Bargain is cast about 0.08 times per copy per
  game, because the one-step evaluation sees "destroy my own creature" as a loss and does not
  value the death triggers it sets off. This is an AI limitation, not necessarily a card problem;
  a human would likely get more out of the deck.
- Removal (Firebolt, Dissolve) is cast less often than its power suggests (about 0.15-0.2 per
  copy). It needs a legal target and the AI only fires it when it improves the evaluation.
- Thornback Colossus (6 mana) and Ancient Treant (5 mana, two C pips) are rarely cast in Root &
  Grave (0.07 and 0.11 per copy): with 9 C lands in 45 cards the double pip is hard to meet.
  Consider a smaller pip requirement or more lands in that deck.

**Suggested next steps.** Teach the AI about sacrifice synergies (value of death triggers in
`evaluate`), then re-run; consider the 4 heavier cards above; rerun with more games (500+) before
making further balance changes.
