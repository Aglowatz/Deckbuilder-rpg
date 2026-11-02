# Usable items, Nov 2 pass (Part 4)

Every consumable reviewed for power vs price vs the gold curve (`core/data/economy.gd`; the expected player holds 300-1400 gold at a shop stop
from level 5 on, about 400 after spending from level 10, see `docs/design/sim/economy_model.md`). Sims: `tools/item_sim.gd` plays every
encounter of a filter with the expected player of each Path, no item vs one charge of one item (`docs/design/sim/items_nov2_low.md`,
`items_nov2_high.md`). Rules that did not change: an equipped item works once per battle, its charges are the item's `uses`, items are used
in your own main phase (and the HP ones between fights); the inventory holds any number, the item slots (1, a second at L10, a third at L20)
decide what comes to a fight.

## The low shelf (Gainlands roamers, the level-6 player, 12 games x 4 Paths x 8 encounters; no item 86.5 % wins)

| Item | Before | After | Price | Sim lift (pts) | Job |
|---|---|---|---:|---:|---|
| Healing Draught | "A common camp remedy." (3 HP x 3) | "You heal 3 HP. Three uses, one per battle. A common camp remedy." | 45 | +7.3 | the steady heal |
| Vitality Charm | "A small, steady comfort." (2 HP x 2) | "You heal 2 HP. Two uses, one per battle. A small, steady comfort." | 30 | +5.2 | the cheap heal |
| Reckless Tonic | "One big gulp - use it wisely, there is only one." (5 HP x 1) | "You heal 5 HP in one big gulp. One use - there is only one." | 45 -> **30** | +1.0 (7 HP: -3.1, drunk too early) | the one-shot emergency heal; a weak item at a weak price |
| Healing Salve | "Heal 4 HP." (4 HP x 3) | "You heal 4 HP. Three uses, one per battle." | 60 | +5.2 | the big heal |
| Field Bandage | "Mend 3 damage from one of your units." (HEAL 3 x 3) | **"One of your units gets +0/+2 for the rest of the battle. Three uses, one per battle."** (BUFF 0/+2 permanent) | 30 | mend 3: **-1.0, used in 0 % of games**; +0/+3 this turn: +11.5; **+0/+2 for the battle: +5.2**; +1/+1 for the battle: +0.0 | a lasting sturdy unit (the Stone is the one-turn strike); the +0/+3-this-turn version was the strongest item on the shelf at 30 gold, so the lasting +0/+2 at 30 was picked |
| Scroll of Insight | "Draw 2 cards." (x 2) | **"You draw 1 card. Two uses, one per battle."** (DRAW 1 x 2) | 45 | draw 2: **+12.5** (the strongest item); **draw 1: +9.4** | card advantage in line with the Firebrand (+10.4) and the Stone (+9.4) at the same 45 |
| Firebrand Charm | "Deal 2 damage to an enemy unit." (x 2) | "Deal 2 damage to one enemy unit. Two uses, one per battle." | 45 | +10.4 | removal |
| Sharpening Stone | "Give a unit +2/+2 until end of turn." (x 3) | "One of your units gets +2/+2 until the end of this turn. Three uses, one per battle." | 45 | +9.4 | the strike |

## The high shelf (opens at level 17, was 6)

`ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL` 6 -> 17 and `data/progression/level_track.json` (`item_advanced` 17; the level-6 headline
"Tilly's back shelf" is now "A little pocket money", level 17 reads "The shops' best stock: Sable's rares, Tilly's high shelf" beside the rare
stock that already opened there). Two price bands added (`Economy.ItemBand.LATE` 90, `PREMIUM` 120). Against the Dump's roamers at level 18
the expected player wins 100 % with or without any item (the sim cannot rank them there); the Capital run (`items_nov2_high.md`) is the one to
read. The retune is by job and by what the late game holds:

| Item | Before | After | Price | Job |
|---|---|---|---:|---|
| Binding Chains | "Return an enemy unit to its owner's hand." (x 1) | "Return one enemy unit to its owner's hand. **Two** uses, one per battle." | 60 -> **90** | tempo against the big late units |
| Silence Powder | "The opponent tosses a random card." (toss 1 x 2) | "The opponent tosses **2** random cards from their hand. Two uses, one per battle." | 30 -> **60** | hand attack |
| Grave Dust | "The opponent buries their top 3 cards." (x 2) | "The opponent buries the top **6** cards of their deck. Two uses, one per battle." | 30 -> **45** | deny the next draws (and feed nothing to a Necrocrat) |
| Summoning Charm | "Summon a 1/1 Militia token." (x 1) | "Summon **three** 1/1 Militia tokens on your side. One use." | 45 -> **90** | three bodies at once (blockers, or a swarm) |
| Ward Sigil | "Give a unit Untouchable until end of turn." (x 2) | "One of your units gains Untouchable until the end of this turn. Two uses, one per battle." | 30 -> **60** | push one attacker through |

## The rest (the Capital's black market, chests)

Iron Ration / Spice Pouch / Bag of Rubbish / Blank Form: "You create 2 Iron (2 Ingredients, 3 Garbage, 2 Red Tape). Two uses, one per battle."
Hearty Pot Pie: "You heal 6 HP. One use. Baked at the Grand Pantry oven." Black-market prices (`core/zone/capital_zone.gd`) unchanged.

## Icons

No item changed its name or its object (the Bandage is still a bandage, the Scroll a scroll), so no icon is redrawn; none went on the art list.

## Where the words live

`core/data/progression_content.gd` is the source; `data/items/*.tres` (what the game loads) is written from it by
`Godot --headless --path . -s res://tools/generate_content.gd`. `tests/core/data/test_items_nov2.gd` checks the reworks, the prices, the level and
that every description names a number and its uses, in the code and in the .tres alike.

## The high shelf against the Capital (level 17, 12 games x 4 Paths x the Capital's roamers; no item 92.2 % wins)

`docs/design/sim/items_nov2_high.md` (the first five variants; the run hit the tool's 10-minute limit, the rest ran at 8 games into
`items_nov2_high_b.md`): Binding Chains +2.1 (used in 33 % of games: the policy only sends back a 4+ attack or 5+ defence unit), Silence
Powder toss 1 +2.1, **toss 2 +6.8**, Grave Dust bury 3 -1.6 and bury 6 -2.1 (burying feeds the Capital's Necrocrat-rule foes - the Dust is a
deck-out tool against the long bosses, kept as the niche at 45, not a staple). The Chains' second use is what makes them a 90-gold item: one
send-back a fight was the single-use card at 60.
