These notes are hand-written and are appended to the generated tables above by
`--notes=res://docs/balance_notes.md`.

**Overall.** All five decks land between 42% and 57% overall. The first player wins 46-54% of
decided games per matchup, so going first is not a meaningful advantage (this includes the gentle
hand smoother). Games last about 15 turns (both players' turns combined), roughly 7-8 turns each.
With 100 games per matchup the 95% confidence interval on a single win rate is about +/-10 points,
so only large gaps (for example Tide & Root vs Wanderer's Pack at 68/32) are worth acting on.
The player starts with the neutral Wanderer's Pack only; the four pair decks are opponent /
"discoverable" decks, so the starter sitting at 50% is intentional (roughly even with them).

**Tuning applied so far.** (First run: 61% / 56% / 47% / 45% / 43%.)
- Tide & Root: 3 Dissolve -> 2, 2 Frost Sentry -> 1, +1 Whispering Shade, +1 Rampaging Boar.
- Grave & Ember: fewer Martyr/Bone Servant, +1 Bloodthirst Wolf, +1 Raider, +1 Blazing Charger,
  +1 Warcry, -2 Sellsword; Martyr now drains 3.
- Root & Grave: 1 Ancient Treant -> Stag Warden (fewer double-pip cards).
- Wanderer's Pack: Ironclad 3/4 Vigilance (new keyword). Earlier buffs to Stone Sentinel were
  reverted once the starter reached 56%.
- Frost Sentry became 1/4 Defender + Reach; Ironclad carries Vigilance, so all 9 keywords appear.
- Hand smoother made gentler (see combat_rules.md): it only swaps a hand that is more than one
  land away from the deck's land ratio.

**Known weak spots.**
- Root & Grave is the weakest (42%): its double-pip cards are rarely cast (Thornback Colossus 0.07,
  Ancient Treant 0.13 per copy) with 9 C lands in 45 cards.
- Grave & Ember's sacrifice identity relies on cards the AI hardly uses (Dark Bargain about 0.1
  casts per copy per game): its one-step evaluation counts "destroy my own creature" as a loss and
  does not value the death triggers. An AI limitation, not necessarily a card problem.
- Removal (Firebolt, Dissolve) is cast less than its power suggests (about 0.15-0.2 per copy);
  the AI needs a legal target and a clear evaluation gain.

**Suggested next steps.** Teach the AI about sacrifice synergies, look at the double-pip cards,
and re-run with 500+ games per matchup before making further changes.
