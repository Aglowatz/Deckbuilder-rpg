# Primm, explained (Overnight Nov 7-8, Part 8)

For the owner: what we measured about the final boss, why the simulations and the play tests disagree, what makes him hard or easy, and
three options. **Nothing about Primm was changed tonight.**

## The fight in one paragraph

Primm is three duels in a row on the same boss node; your HP carries from one phase to the next, his resets to each phase's number.
1. **Standardization (56 HP).** Every unit on both sides is a 3/3 and you may play at most two non-Infrastructure cards a turn ("Two Is the
   Perfect Number"). He starts with four 3/3 Militia. Big printed stats stop mattering; numbers of bodies and tempo matter.
2. **Reflection (52 HP).** His deck is a copy of yours, and he draws two extra cards a turn ("He Already Knows").
3. **Unraveling (50 HP).** His units are stronger and he draws more, but he loses 1 HP at the start of each of his turns.

On top: the Capital's broken-services debuffs for every zone not yet freed, the castle's own rules (Perfect Order: at most two keywords;
Mirrors: the first card each player plays is copied for the other side), a two-turn setup window before his units may attack
(`BossTempo`), the freed leaders' boons on your side, and the Boss AI skill level.

## Measurement 1 - the Paths' reference decks (what the sims always used)

Measured tonight (`--what=encounters --games=12 --filter=D-PC`, `docs/design/sim/nov8/p4_targets.md`): each Path's reference deck at the
expected level (L22), the model's gear and items, the Boss AI. Target band per phase: 40-60 %.

| Phase | Beefcake | Necrocrat | Gourmand | Refusemancer | All |
|---|---:|---:|---:|---:|---:|
| 1 Standardization | 83 % | 100 % | 100 % | 92 % | 94 % |
| 2 Reflection | 83 % | 83 % | 92 % | 100 % | 90 % |
| 3 Unraveling | 42 % | 100 % | 58 % | 83 % | 71 % |

The Critic pass of Nov 6 (C8) found the same shape: 75-100 % in phases 1-2, 50-100 % in phase 3. Read on its own, Primm is too easy.

## Measurement 2 - the deck a no-grind player could own

Measured Nov 8 (`--what=encounters --games=16 --filter=D-PC:10 --budget`, `docs/design/sim/nov8/p8_primm_budget.md`). `--budget` plays
`ProgressionModel.budget_deck`: the reference deck's upgrades but at most 4 Epics and 1 Legendary (the no-grind shopping list of the gold
study), refilled from the starter. Same gear, items and Boss AI. Next to it, the same night's reference run with 16 games (`p8_primm_reference.md`):

| Phase | Beefcake | Necrocrat | Gourmand | Refusemancer | All | (reference, 16 games) |
|---|---:|---:|---:|---:|---:|---:|
| 1 Standardization | 75 % | 100 % | 100 % | 100 % | 94 % | 94 % |
| 2 Reflection | 81 % | 81 % | 94 % | 100 % | 89 % | 89 % |
| 3 Unraveling | 31 % | 88 % | 81 % | 88 % | 72 % | 73 % |

**What it shows:** almost no difference. Cutting the shelf Epics and Legendaries barely matters to the sim, because under Standardization a
big card is a 3/3 like any other, phase 2 copies whatever deck you bring, and phase 3 is a clock. So the gap between the sims (easy) and the
play tests (hard, swingy) is not about what the player owns - it is about how the deck is built and played (cheap bodies, two cards a turn)
and about HP carrying over between phases. That supports the owner's choice: explain phase 1 plainly and advise a cheap-units deck, and
leave his numbers alone. Beefcake's phase 3 (31-44 %) is the one real low point, in line with its known late-game weakness.

## Measurement 3 - a fresh critic playing him by hand with the second deck

**Not run tonight** (the same memory limit; a play critic needs the game window for an hour). The Nov 6 play critic C4c is the closest
evidence: with a snapshot deck and the simple pilot, phase 1 went win (15 HP left), loss (Primm at 7 HP), and a hand-played loss in round 5.

## Why the sims and the play tests disagreed

- **Different decks.** The sims play a tidy 46-card reference deck full of cheap bodies; the play critics brought the deck they had: a
  51-card collection with expensive cards they could not field under phase 1's two-cards-a-turn limit.
- **Different pilots.** The sim's AI player never plays badly around the 3/3 rule (it simply plays the most bodies); a person (or the
  critics' simple pilot) holds the "good" cards that phase 1 turns into plain 3/3s.
- **One phase decides three.** The sims score each phase on its own from full HP; in play your HP carries over, so a bad phase 1 makes
  phases 2 and 3 much harder. The sim's 94 / 90 / 71 does not multiply into the 60 % a run would suggest, because losses cluster.
- **The rule text did not match the board** until the Nov 7 fix (live stats now shown), so players misread fights in phase 1.

## What makes him hard, and what makes him easy

- **The hand limit of phase 1** turns a strong deck into an ordinary one: big cards are 3/3 like everything else, and you can only put two
  cards down a turn, while he opens with four 3/3s. A player holding several expensive cards falls behind on bodies; the AI (and the
  reference decks, full of cheap units by L22) does not.
- **The clock.** Your HP carries across three duels (about 31-35 at L22 with the boons). Four 3/3s attacking from round 3 is about 12 damage a
  turn if unblocked: a phase 1 that goes badly leaves too little for phases 2 and 3. That is why play feels swingy: one bad phase-1 hand
  decides the whole fight.
- **Phase 2 copies your deck**, so it is exactly as strong as your deck - and he draws two more cards a turn. A deck with a few strong
  combos sees them turned on itself.
- **Phase 3 bleeds him** 1 HP a turn, so a defensive player wins it on the clock; it is the easiest phase for a deck that can block.
- **Easy side:** the freed leaders' boons (one per freed zone) and the setup window. A player who freed all four zones gets four boons; a
  player who rushed the castle gets none and also carries the broken-services debuffs.

## Options

1. **Teach phase 1 instead of nerfing it.** Before phase 1, the rules card says plainly "Every unit is a 3/3: cheap units are as good as
   big ones. You may play two cards a turn." and the Deck Station offers "Primm deck" advice (more cheap units). *Expected effect:* play
   results rise toward the sims (phase 1 from about 50 % to about 75 % for a real collection) without touching the sims' numbers.
2. **Let the HP carry less.** Heal 25 % of your max HP between phases (a "the leaders steady you" beat). *Expected effect:* runs stop being
   decided by phase 1 alone; the whole-fight win rate for a real collection rises by an estimated 15-20 points; the sims barely move
   (they already score phases from full HP).
3. **Make the sims' Primm harder where they say he is easy** (phases 1-2: +15 % HP, as C8 suggested). *Expected effect:* sim phases 1-2
   drop to about 75-80 %, but a player with an ordinary collection would find him harder still - this widens the play/sim gap.

**Recommendation:** option 1 first (it fixes the cause - a rule players do not plan for), with option 2 if play tests still lose most runs
in phase 1. Leave the numbers (option 3) until measurement 2 and a hand-played run exist.
