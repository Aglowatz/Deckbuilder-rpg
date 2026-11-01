# Starter deck study: 30 / 35 / 45 cards (Fable pass Nov 1, Part 6)

The question (first-hour critic): the 45-card starter (19 basic Infrastructure) makes each reward pick ~2 % of the deck. Sims with the
starter trimmed to 35 (15 basics + 20 spells) and 30 (13 + 17) at the same ratios (`CampaignStart.starter_deck_sized`: basics in the 19/45
proportion, the spells spread evenly over the Path's 26-card list). The real starter is unchanged (the designer's call).

Cave: `--what=tutorial --games=8 --seed=7300 --starter_size=N` (16 runs per Path, the three fights on one HP pool). First zone: the
Gainlands' two roamers, the House of Gains' six fights and the gatekeeper, `--starter --starter_size=N --games=8 --seed=7100` (32 games each).

| Fight | 45 cards | 35 cards | 30 cards |
|---|---:|---:|---:|
| Cave run cleared, Beefcake / Gourmand / Refusemancer / Necrocrat | 88 / 88 / 81 / 94 | 81 / 94 / 94 / 100 | 94 / 94 / 94 / 100 |
| Cave run, all Paths | 88 % | 92 % | 96 % |
| Gainlands brute / golem | 91 / 88 | 91 / 97 | 91 / 91 |
| House of Gains nodes 2 / 3 / 6 / 8 / 11 | 88 / 100 / 66 / 100 / 84 | 91 / 100 / 84 / 100 / 72 | 97 / 100 / 56 / 100 / 84 |
| Chancellor Clench (D-HOG:13, target 40-60) | 59 | 75 | 69 |
| Brick Bronson (gatekeeper) | 88 | 94 | 94 |
| Average over the first zone | 85 % | 89 % | 87 % |

## Reading

- A smaller starter is **not weaker**: the ratios hold, so the hands are the same hands, only the draws repeat sooner; the cave run gets a
  little safer (88 -> 92 -> 96 %) because the few good spells come up more often.
- The difference is what a reward card means: 1 of 45 (2.2 %), 1 of 35 (2.9 %), 1 of 30 (3.3 %) - and how soon the first upgrades change
  the feel of a turn. At 30 the first zone's fights start to swing (node 6 56 %, Clench 69 %): the deck is small enough that one bad draw
  is a third of it.
- 32 games per cell: +/-10 points is noise.

## Recommendation (not applied)

**35 cards, 15 basic Infrastructure + 20 spells.** Same strength as today, each reward pick a third more of the deck, and still
enough cards that the auto-fill target (16-20 basics late) and the deck minimum do not need to move. If 35 is adopted: `INFRASTRUCTURE_COUNT`
19 -> 15 and the Path starting lists trimmed by the designer (the even spread here is a stand-in; which six spells to cut per Path is a
design call), then the cave and the first zone re-measured on two seeds and the deck-minimum rule checked.
