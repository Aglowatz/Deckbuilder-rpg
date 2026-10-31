# Starter deck Infrastructure study (Oct 31, fresh eyes round 2)

Sim only (`tools/starter_infra_study.gd`): each Path's 45-card starter rebuilt with 19, 17, 15 Infrastructure (the removed basics become extra copies of the deck's own cheapest cards, 3-copy cap), played by the sim's Elite AI with `deterministic` on, 50 games per fight per seed, seeds 7000,8100. The cave is the tutorial's three fights at level 1; the first zone is the Path's own zone (its roamers and elites) at the zone's expected level with the model's gear and items. "First real play" is the player's turn on which the first non-Infrastructure card was played; "dead turns" are the player's turns on which nothing was played; "flood turns" are player turns that ended with 3 or more Infrastructure still in hand.

## Beefcake

| Infra | Deck fill | Cave win % | Cave first play | Cave dead / game | Cave flood / game | Zone win % | Zone first play | Zone dead / game | Zone flood / game |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 19 | as shipped | 97% | 2.7 | 2.41 | 0.93 | 85% | 2.8 | 2.43 | 1.15 |
| 17 | +Dropped Weights, Courier Pigeon | 96% | 2.5 | 2.46 | 0.36 | 89% | 2.6 | 2.31 | 0.53 |
| 15 | +Dropped Weights, Courier Pigeon, Tripwire, Protein Shake | 95% | 2.5 | 2.66 | 0.27 | 87% | 2.4 | 2.64 | 0.32 |

## Gourmand

| Infra | Deck fill | Cave win % | Cave first play | Cave dead / game | Cave flood / game | Zone win % | Zone first play | Zone dead / game | Zone flood / game |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 19 | as shipped | 99% | 2.5 | 2.78 | 1.02 | 96% | 2.5 | 1.79 | 2.14 |
| 17 | +Courier Pigeon, Tripwire | 97% | 2.3 | 2.88 | 0.40 | 96% | 2.3 | 1.84 | 1.68 |
| 15 | +Courier Pigeon, Tripwire, Amuse-Bouche, Shield Bearer | 97% | 2.4 | 2.91 | 0.31 | 95% | 2.4 | 1.96 | 1.36 |

## Refusemancer

| Infra | Deck fill | Cave win % | Cave first play | Cave dead / game | Cave flood / game | Zone win % | Zone first play | Zone dead / game | Zone flood / game |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 19 | as shipped | 94% | 2.7 | 2.65 | 0.92 | 100% | 2.2 | 1.12 | 3.52 |
| 17 | +Watchtower Archer, Traveler's Sword | 94% | 2.7 | 2.89 | 0.37 | 100% | 2.2 | 1.15 | 2.92 |
| 15 | +Watchtower Archer, Traveler's Sword, Ambush Party, Dumpster Diver | 94% | 2.6 | 3.12 | 0.27 | 100% | 2.2 | 1.17 | 2.31 |

## Necrocrat

| Infra | Deck fill | Cave win % | Cave first play | Cave dead / game | Cave flood / game | Zone win % | Zone first play | Zone dead / game | Zone flood / game |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 19 | as shipped | 98% | 2.8 | 2.73 | 0.95 | 100% | 2.4 | 1.31 | 1.97 |
| 17 | +Courier Pigeon, Village Militia | 97% | 2.6 | 2.97 | 0.38 | 100% | 2.3 | 1.36 | 1.57 |
| 15 | +Courier Pigeon, Village Militia, Ambush Party, Pending Approval | 97% | 2.6 | 3.13 | 0.28 | 100% | 2.4 | 1.46 | 1.29 |

## Reading

- Beefcake at 17: cave 97% -> 96%, zone 85% -> 89%, first play 2.7 -> 2.5, dead turns 2.41 -> 2.46, flood 0.93 -> 0.36: worse somewhere.
- Beefcake at 15: cave 97% -> 95%, zone 85% -> 87%, first play 2.7 -> 2.5, dead turns 2.41 -> 2.66, flood 0.93 -> 0.27: worse somewhere.
  - Beefcake: keep 19.
- Gourmand at 17: cave 99% -> 97%, zone 96% -> 96%, first play 2.5 -> 2.3, dead turns 2.78 -> 2.88, flood 1.02 -> 0.40: worse somewhere.
- Gourmand at 15: cave 99% -> 97%, zone 96% -> 95%, first play 2.5 -> 2.4, dead turns 2.78 -> 2.91, flood 1.02 -> 0.31: worse somewhere.
  - Gourmand: keep 19.
- Refusemancer at 17: cave 94% -> 94%, zone 100% -> 100%, first play 2.7 -> 2.7, dead turns 2.65 -> 2.89, flood 0.92 -> 0.37: a wash.
- Refusemancer at 15: cave 94% -> 94%, zone 100% -> 100%, first play 2.7 -> 2.6, dead turns 2.65 -> 3.12, flood 0.92 -> 0.27: a wash.
  - Refusemancer: keep 19.
- Necrocrat at 17: cave 98% -> 97%, zone 100% -> 100%, first play 2.8 -> 2.6, dead turns 2.73 -> 2.97, flood 0.95 -> 0.38: worse somewhere.
- Necrocrat at 15: cave 98% -> 97%, zone 100% -> 100%, first play 2.8 -> 2.6, dead turns 2.73 -> 3.13, flood 0.95 -> 0.28: worse somewhere.
  - Necrocrat: keep 19.

**Verdict**: not every Path improves (or the cave leaves the 80 %+ band): the starter stays at 19 Infrastructure; the table is the designer's to read.

Wall clock: 1896 s.

## Recommendation (Fable, Oct 31)

Keep the starters at 19 Infrastructure. Fewer basics do what the critics felt they would - flood turns (3+ Infrastructure in hand at the
end of a turn) drop by a half to two thirds and the first real play comes ~0.2 turns earlier - but every Path pays for it with more dead
turns (the AI has nothing castable more often: 2.4 -> 2.5-2.7 per cave game for Beefcake, 2.7 -> 2.9-3.1 for the others) and the cave win
rate slips 1-2 points on three of the four Paths. Beefcake is the only Path whose zone fights get better (85 -> 89 % at 17) and even
there the cave gives a point back. Nothing clears the brief's bar (every Path improves, cave stays 80 %+), so nothing was changed. If the
flood feeling is what matters, the lever that does not cost tempo is a better fill than extra copies of the cheapest cards (this study's
fill rule): a cheap card that cantrips, or the mulligan rule (keep 2-3 Infrastructure). Both are deck design calls.
