class_name CardPricing
extends RefCounted
## What the vendor charges for a card (gold). Placeholder economy: rarity sets the base price
## and the energy value adds a little.

const BASE_BY_RARITY: Dictionary = {
	CardEnums.Rarity.COMMON: 15,
	CardEnums.Rarity.UNCOMMON: 35,
	CardEnums.Rarity.EPIC: 80,
	CardEnums.Rarity.LEGENDARY: 160,
}
const PER_ENERGY: int = 5
## The absolute copy limit; the real limit is the card's copy cap at the player's level (`CopyCaps`).
const MAX_OWNED_FOR_SALE: int = CopyCaps.ABSOLUTE_MAX


static func price(card: CardData) -> int:
	return int(BASE_BY_RARITY.get(card.rarity, 15)) + card.energy_value() * PER_ENERGY


## Cards are sold until the player owns as many copies as their copy cap allows (`cap` < 0: the absolute limit).
static func is_for_sale(card: CardData, owned_copies: int, cap: int = -1) -> bool:
	var limit: int = MAX_OWNED_FOR_SALE if cap < 0 else mini(cap, MAX_OWNED_FOR_SALE)
	return not card.is_token and not card.is_infrastructure() and owned_copies < limit
