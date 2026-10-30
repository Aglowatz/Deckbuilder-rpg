class_name Economy
extends RefCounted
## Overnight Oct 29, Part 2: the one price and payout curve (docs/design/economy.md). Every shelf, stall, roamer and reward reads its
## number from here, so the curve can be re-tuned in one place and `tools/economy_model.gd` shows the result. Pure data: no scene tree.
##
## Tiers: 1 = Crosspath and a zone's first visit, 2 = a zone's freed stock and the second zones, 3 = Bertram's advanced rack (L13) and
## the late zones, 4 = the Capital and the postgame.

## Card price by rarity (Common, Uncommon, Epic, Legendary); no energy term (a 1-cost and a 5-cost Common cost the same).
const CARD_PRICE: Array[int] = [30, 60, 150, 300]

## Equipment price by rarity, then tier (index 0 unused: tiers are 1-based). A Legendary piece is never sold.
const GEAR_PRICE: Dictionary = {
	EquipmentData.Rarity.COMMON: [0, 60, 90, 120, 150],
	EquipmentData.Rarity.UNCOMMON: [0, 120, 180, 240, 300],
	EquipmentData.Rarity.RARE: [0, 300, 300, 450, 600],
	EquipmentData.Rarity.LEGENDARY: [0, 900, 900, 900, 900],
}

## Item price by strength band.
enum ItemBand { WEAK, STANDARD, STRONG }
const ITEM_PRICE: Array[int] = [30, 45, 60]

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
const ALCHEMY_GOLD: int = 150

## Phase 2 (the late sink): rerolling a world card pick once, 40 + 10 per level, to the nearest 10 (L5 90, L12 160, L22 260).
const REROLL_BASE: int = 40
const REROLL_PER_LEVEL: int = 10


static func card_price(rarity: CardEnums.Rarity) -> int:
	return CARD_PRICE[clampi(int(rarity), 0, CARD_PRICE.size() - 1)]


static func gear_price(rarity: EquipmentData.Rarity, tier: int) -> int:
	var row: Array = GEAR_PRICE.get(rarity, GEAR_PRICE[EquipmentData.Rarity.COMMON]) as Array
	return int(row[clampi(tier, 1, row.size() - 1)])


static func item_price(band: ItemBand) -> int:
	return ITEM_PRICE[clampi(int(band), 0, ITEM_PRICE.size() - 1)]


static func roamer_gold(zone_id: String) -> int:
	return ROAMER_GOLD[clampi(int(ZONE_TIER.get(zone_id, 0)), 0, ROAMER_GOLD.size() - 1)]


static func elite_gold(zone_id: String) -> int:
	return roamer_gold(zone_id) * 2


static func reroll_price(level: int) -> int:
	return int(round(float(REROLL_BASE + REROLL_PER_LEVEL * maxi(1, level)) / 10.0)) * 10
