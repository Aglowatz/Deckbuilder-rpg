# Economy design (Overnight Oct 29, Part 2)

The audit (`docs/design/economy_audit_oct29.md`) found: gold in lumps at the dungeons and nothing on arrival; every stock affordable at
every stop; hoarding from the Capital on with no sink; the one pinch in the wrong place (the armory at L5); prices that follow no curve;
side-dungeon first clears that pay less than their nodes; essence that barely exists. This file sets the targets and the curve, and
every price and payout in the game is set from it. Code: `core/data/economy.gd` (`Economy`), the single table every vendor, roamer,
dungeon and reward reads. Measure with `tools/economy_model.gd`.

## Targets

1. **A meaningful purchase in reach about every zone visit**: on arrival (one piece of the arrival stock, from the last zone's leftover
   plus the roamers) and when the zone is freed (one of the Path pieces or the Epic, not all of them).
2. **Each zone's stock is affordable-but-choosy when you arrive**: the stock a player wants at a stop costs about 1.5-2x the gold on hand.
3. **No long droughts** (never two shop stops in a row with wants and nothing affordable), **no runaway hoarding by mid-game** (gold on hand
   never more than twice the priciest thing wanted, through the Dump).
4. **Gold always has a use late**: the Gilded and Prismatic packs, the Royal Mantle, Sable's rare stock, the Alchemist.
5. **Essence feels valuable**: a pack's duplicates pay essence worth having; the Alchemist is reachable mid-game, not only in the postgame.
6. **Repeat content pays less than first clears, but pays**: about half.
7. **Packs and singles both feel worth it**: a pack costs about what its cards are worth on the shelf; a single is the sure thing.
8. **Prices follow a clear curve by rarity and tier, in round numbers**; a player can predict a price before reading it.

## The curve

Tiers: **1** = Crosspath and the first visit to a zone, **2** = a zone's freed stock and the second zones, **3** = Bertram's advanced
rack (L13) and the late zones, **4** = the Capital and the postgame.

| Sink | Common | Uncommon | Epic | Legendary |
|---|---:|---:|---:|---:|
| Cards (any shelf; no energy term any more) | 30 | 60 | 150 | 300 |
| Equipment, tier 1 | 60 | 120 | - | - |
| Equipment, tier 2 | 90 | 180 | 300 | - |
| Equipment, tier 3 | - | 240 | 450 | - |
| Items (weak / standard / strong) | 30 | 45 | 60 | - |

| Packs | Price | Why |
|---|---:|---|
| General Pack | 100 | 3 Commons / Uncommons: about shelf value |
| Path Pack | 150 | 3 cards of one Path, rarity-weighted: shelf value about 165 |
| General Pack II | 200 | the whole selection |
| Gilded Pack | 600 | a guaranteed Epic or Legendary; a late sink |
| Prismatic Pack | 900 | postgame |

| Cosmetics | Price |
|---|---:|
| From the start: Wide-Brim 100, Chef's Toque 120, Bowler 150 | |
| Level 4-5: Patchwork Cloak 250, Tricorn 250 | |
| One zone freed: Wizard Hat 300, Red Cape 300 | |
| Two zones freed: Tattered Cloak 350, Crown of Leaves 400 | |
| After Primm: Royal Mantle 1,000 | |

Other sinks: the Alchemist 150 gold + essence (min 6 of each of two Paths); zone fees unchanged (15-20: a loss already costs time).
The vendor discount of the level track (10 % at L11, 20 % at L21) still applies to everything.

## Payouts

| Source | Before | After | Why |
|---|---|---|---|
| Zone roamers (Normal) | 25-35 in every zone, the Capital 35-45 | by zone tier: Gainlands 35, D.N.A. 40, Buffet 50, Dump 60, Capital 70 | income on arrival that scales with the prices the player faces; still a fight for one Common, never a farm |
| Zone elites | Casserole 50, Spotless 120 | Casserole 100, Spotless 150 | an elite pays two roamers |
| Dungeon nodes | Normal 35 / Elite 65 / Boss 100 (every run) | unchanged | the lump is the clear, not the nodes |
| Main dungeon first clear | 200 + 150 bonus + Gilded + Path Pack | unchanged | the story payday |
| Main dungeon repeat | 100 + Path Pack + the nodes | unchanged (about half a first clear) | |
| Side dungeon first clear | 30 + the card + the gear | 100 + the card + the gear | the clear bonus was noise next to its nodes (170) |
| Side dungeon repeat | 30 + a pack | 40 + a pack | |
| Arena replay | 15 | 25 | one roamer's worth |
| Level track gold | L2-5 180, L6-10 320, L11-20 1,020, L21-30 1,550 | L2-5 240, L6-10 520, L11-20 1,230, L21-30 1,100 | front-loaded to the levels where the armory and the first zone pinch; the postgame band paid during the main game under the current XP curve |
| Essence per duplicate | 1 / 2 / 4 / 8 | 2 / 4 / 8 / 16 | packs pay essence worth having; the Alchemist (min 6 per Path) is reachable from the second zone |
| Gold per Colorless duplicate | 15 / 30 / 60 / 120 | 15 / 30 / 75 / 150 | half the shelf price |
| Quests, chests, feats, gatekeepers, graveyard, minigames | unchanged | | quests are frozen with the dialogue; chests and feats are already tiered |

**Added in Phase 2**: a card pick (a gatekeeper, a zone elite, a town boss, the arena's upper tiers, every dungeon node's pick) can be rerolled once for
`Economy.reroll_price(level)` = 40 + 10 x level to the nearest 10 (L5 90, L12 160, L22 260): the repeatable sink the late game lacked.
Not added (inbox): rotating rare stock, an essence-for-gold exchange; selling and an inn do not exist in the game.

## Before / after

`docs/design/sim/economy_model_before.md` (the audit's run) and `docs/design/sim/economy_model.md` (after). Summary in
`docs/overnight_report.md` (Part 2).
