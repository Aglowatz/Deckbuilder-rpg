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
const CARD_PRICE: Array[int] = [100, 200, 500, 1000]
## Part B9: a roamer fought again (the same spot won before) pays this many times its zone's gold, so grinding buys a Common in about 2-4
## repeat fights; the first win of every spot pays the plain rate (the no-grind economy above is unchanged).
const REPEAT_FIGHT_MULTIPLIER: int = 2


## The gold of a roamer win: the plain rate the first time a spot is beaten, REPEAT_FIGHT_MULTIPLIER times it after.
static func fight_gold(base: int, repeat: bool) -> int:
	return base * (REPEAT_FIGHT_MULTIPLIER if repeat else 1)

## Equipment price by rarity, then tier (index 0 unused: tiers are 1-based). A Legendary piece is never sold.
## Fix pass Nov 4 (Part 2.2): equipment is a saving goal - a no-grind player affords about 4-6 shop pieces over the whole game on top of
## ~20 cards and normal item use (was 60-600: every piece on every shelf). Before: Common 60/90/120/150, Uncommon 120/180/240/300,
## Epic 300/300/450/600.
const GEAR_PRICE: Dictionary = {
	EquipmentData.Rarity.COMMON: [0, 1200, 1400, 1600, 1800],
	EquipmentData.Rarity.UNCOMMON: [0, 2000, 2400, 2800, 3200],
	EquipmentData.Rarity.RARE: [0, 3500, 3500, 4500, 5500],
	EquipmentData.Rarity.LEGENDARY: [0, 10000, 10000, 10000, 10000],
}

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
const ROAMER_GOLD: Array[int] = [13, 35, 40, 50, 60, 70]
const ZONE_TIER: Dictionary = {"town": 0, "forest": 0, "beefcake": 1, "necrocrat": 2, "gourmand": 3, "refusemancer": 4, "final": 5}

## Dungeon clears.
const SIDE_FIRST_CLEAR_GOLD: int = 100
const SIDE_REPEAT_GOLD: int = 40
const MAIN_FIRST_CLEAR_GOLD: int = 200
const MAIN_REPEAT_GOLD: int = 100
const ARENA_REPLAY_GOLD: int = 25

## The Alchemist's gold half of a brew.
const ALCHEMY_GOLD: int = 100  # Fix pass Nov 4 (B), Part 4.2 (was 150)

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
	return ROAMER_GOLD[clampi(int(ZONE_TIER.get(zone_id, 0)), 0, ROAMER_GOLD.size() - 1)]


static func elite_gold(zone_id: String) -> int:
	return roamer_gold(zone_id) * 2


static func reroll_price(level: int) -> int:
	return int(round(float(REROLL_BASE + REROLL_PER_LEVEL * maxi(1, level)) / 10.0)) * 10
