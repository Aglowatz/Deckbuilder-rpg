class_name Economy
extends RefCounted
## Overnight Oct 29, Part 2: the one price and payout curve (docs/design/economy.md). Every shelf, stall, roamer and reward reads its
## number from here, so the curve can be re-tuned in one place and `tools/economy_model.gd` shows the result. Pure data: no scene tree.
##
## Tiers: 1 = Crosspath and a zone's first visit, 2 = a zone's freed stock and the second zones, 3 = Bertram's advanced rack (L13) and
## the late zones, 4 = the Capital and the postgame.

## Card price by rarity (Common, Uncommon, Epic, Legendary); no energy term (a 1-cost and a 5-cost Common cost the same).
## Overnight Nov 3-4, Part B9 (docs/balance/gold_economy_nov3.md): a no-grind playthrough leaves about 14,000 gold after items, hats, gear and
## fees - about 20 cards in a normal mix at these prices (was 30 / 60 / 150 / 300: hundreds of cards). Ratio 1 : 2 : 5 : 10 kept.
## Fix pass Nov 4 (Part 2.1): a Common costs 100, the same as a General Pack; the ratio stays 1 : 2 : 5 : 10. The gold this frees goes to
## equipment, now the big purchase (GEAR_PRICE; study in docs/balance/gold_economy_nov3.md, "Fix pass Nov 4").
## Overnight Nov 7-8, Part 2.1 (owner): a Common costs 50, ratio 1 : 2 : 5 : 10 kept (was 100 / 200 / 500 / 1000). Study: docs/balance/gold_economy_nov3.md, "Overnight Nov 7-8".
const CARD_PRICE: Array[int] = [50, 100, 250, 500]
## Overnight Nov 4-5, Part 2.2: a repeat fight pays the SAME gold as the first win (Part B9's x2 for repeats is gone); the extra gold now comes
## from dungeon clear bonuses (`Session.pay_clear_bonus`) and richer quests (QuestDefinitions / ZoneQuestDefinitions, `QUEST_GOLD_SCALE`).
const REPEAT_FIGHT_MULTIPLIER: int = 1


## The gold of a roamer win: the same the first time a spot is beaten and after (`repeat` kept for the callers and the study).
static func fight_gold(base: int, repeat: bool, level: int = 1) -> int:
	if repeat and level >= LATE_LEVEL:
		return base * REPEAT_LATE_MULTIPLIER  # Fixes Nov 8: late grinding pays double (no-grind runs never repeat, so their total is unchanged)
	return base * REPEAT_FIGHT_MULTIPLIER


## Fixes Nov 8 (owner: three copies of every card and every multi-Path craft, finished with a moderate amount of extra play): a roamer spot
## beaten before at expected level LATE_LEVEL or more pays this multiple (the Capital's are the grinding ground).
const REPEAT_LATE_MULTIPLIER: int = 4

## Equipment price by rarity, then tier (index 0 unused: tiers are 1-based). A Legendary piece is never sold.
## Fix pass Nov 4 (Part 2.2): equipment is a saving goal - a no-grind player affords about 4-6 shop pieces over the whole game on top of
## ~20 cards and normal item use (was 60-600: every piece on every shelf). Before: Common 60/90/120/150, Uncommon 120/180/240/300,
## Epic 300/300/450/600.
## Overnight Nov 7-8, Part 2.2 (owner): the cheapest piece costs 250; the curve keeps its shape by tier and rarity (about a fifth of the Nov 4
## prices: Common 1200-1800, Uncommon 2000-3200, Epic 3500-5500).
const GEAR_PRICE: Dictionary = {
	EquipmentData.Rarity.COMMON: [0, 250, 300, 350, 400],
	EquipmentData.Rarity.UNCOMMON: [0, 400, 500, 600, 700],
	EquipmentData.Rarity.RARE: [0, 750, 750, 950, 1150],
	EquipmentData.Rarity.LEGENDARY: [0, 2000, 2000, 2000, 2000],
}

## Overnight Nov 7-8 cut these (chests, clear bonus, late level gold) to bring a no-grind run down to ~11,300. Fixes Nov 8 (owner): the goal is
## three copies of every card plus every multi-Path craft, so the run earns about 21,200 again - the knobs are back at 1.0 (kept as knobs).
const CHEST_GOLD_SCALE: float = 0.6  # Fixes Nov 8: 21.2k with the late-fight raise kept
const CLEAR_BONUS_SHARE: float = 1.0
const LEVEL_GOLD_FROM: int = 6
const LEVEL_GOLD_SCALE: float = 0.85
## Overnight Nov 7-8, Part 2.5: late fights pay more - every fight at an expected level of LATE_LEVEL or more (the Capital, the castle, the Lab, the
## postgame dungeons) pays its gold x (1 + LATE_STEP per level from LATE_LEVEL): L18 x1.15, L20 x1.45, L21 x1.6, L23 x1.9, L25 x2.2, L26 x2.35.
const LATE_LEVEL: int = 18
const LATE_STEP: float = 0.15

## Nov 3-4, Part B3: one price per single-use charge, by item. The regular shelf runs 50-100 by power (cheapest 50; the Energy Draught and the
## Firebrand Charm top it at 100); every item on the high shelf (level 17) is 150. Items sold nowhere (rewards only) have no price.
const ITEM_PRICES: Dictionary = {
	"reckless_tonic": 50, "vitality_charm": 50, "power_wraps": 60, "healing_salve": 70, "scroll_of_insight": 80, "sharpening_stone": 80,
	"energy_draught": 100, "firebrand_charm": 100,
	"binding_chains": 150, "silence_powder": 150, "grave_dust": 150, "summoning_charm": 150, "ward_sigil": 150,
}
const ITEM_PRICE_MIN: int = 50
const ITEM_PRICE_REGULAR_MAX: int = 100
const ITEM_PRICE_HIGH_SHELF: int = 150

## Roamer pay by zone tier (Normal fights); an elite pays about twice its zone's roamer. Index 0 = Crosspath outskirts.
const ROAMER_GOLD: Array[int] = [13, 35, 40, 50, 60, 70]  # Fixes Nov 8: restored (Nov 7-8 had 13 / 25 / 28 / 35 / 42 / 50)
const ZONE_TIER: Dictionary = {"town": 0, "forest": 0, "beefcake": 1, "necrocrat": 2, "gourmand": 3, "refusemancer": 4, "final": 5}

## Dungeon clears.
const SIDE_FIRST_CLEAR_GOLD: int = 100
const SIDE_REPEAT_GOLD: int = 200  # Fixes Nov 8: a replayed side dungeon is the completionist's grind (was 40)
const MAIN_FIRST_CLEAR_GOLD: int = 200
const MAIN_REPEAT_GOLD: int = 300  # Fixes Nov 8 (was 100)
const ARENA_REPLAY_GOLD: int = 25

## The Alchemist's gold half of a brew.
const ALCHEMY_GOLD: int = 40  # Fixes Nov 8: crafting all 136 multi-Path cards is part of the goal (was 100; 150 before Nov 4 (B))

## Phase 2 (the late sink): rerolling a world card pick once, 40 + 10 per level, to the nearest 10 (L5 90, L12 160, L22 260).
const REROLL_BASE: int = 40
const REROLL_PER_LEVEL: int = 10


static func card_price(rarity: CardEnums.Rarity) -> int:
	return CARD_PRICE[clampi(int(rarity), 0, CARD_PRICE.size() - 1)]


static func gear_price(rarity: EquipmentData.Rarity, tier: int) -> int:
	var row: Array = GEAR_PRICE.get(rarity, GEAR_PRICE[EquipmentData.Rarity.COMMON]) as Array
	return int(row[clampi(tier, 1, row.size() - 1)])


## The shop price of one charge of `item_id` (0 when the item is not sold).
static func item_price(item_id: String) -> int:
	return int(ITEM_PRICES.get(item_id, 0))


static func roamer_gold(zone_id: String) -> int:
	var base: int = ROAMER_GOLD[clampi(int(ZONE_TIER.get(zone_id, 0)), 0, ROAMER_GOLD.size() - 1)]
	return late_gold(base, ProgressionModel.level_for("zone:%s" % zone_id, 1))


## Overnight Nov 7-8, Part 2.5: `gold` scaled up for a fight at expected level `level` (unchanged below LATE_LEVEL), rounded to 5.
static func late_gold(gold: int, level: int) -> int:
	if gold <= 0 or level < LATE_LEVEL:
		return gold
	return roundi(float(gold) * late_scale(level) / 5.0) * 5


static func late_scale(level: int) -> float:
	return 1.0 + LATE_STEP * float(maxi(0, level - LATE_LEVEL + 1))


## Overnight Nov 7-8, Part 2.4: a hidden chest's gold after CHEST_GOLD_SCALE, rounded to 5.
static func chest_gold(gold: int) -> int:
	return maxi(5, roundi(float(gold) * CHEST_GOLD_SCALE / 5.0) * 5) if gold > 0 else 0


## Overnight Nov 7-8, Part 2.4: the level track's gold grant for reaching `level`.
static func level_gold(level: int, amount: int) -> int:
	return amount if level < LEVEL_GOLD_FROM else roundi(float(amount) * LEVEL_GOLD_SCALE / 5.0) * 5


static func elite_gold(zone_id: String) -> int:
	return roamer_gold(zone_id) * 2


static func reroll_price(level: int) -> int:
	return int(round(float(REROLL_BASE + REROLL_PER_LEVEL * maxi(1, level)) / 10.0)) * 10
