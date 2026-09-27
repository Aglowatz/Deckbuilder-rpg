class_name CardPricing
extends RefCounted
## What the vendor charges for a card (gold). Placeholder economy: rarity sets the base price
## and the mana value adds a little.

const BASE_BY_RARITY: Dictionary = {
	CardEnums.Rarity.COMMON: 15,
	CardEnums.Rarity.UNCOMMON: 35,
	CardEnums.Rarity.EPIC: 80,
	CardEnums.Rarity.LEGENDARY: 160,
}
const PER_MANA: int = 5
const MAX_OWNED_FOR_SALE: int = 3


static func price(card: CardData) -> int:
	return int(BASE_BY_RARITY.get(card.rarity, 15)) + card.mana_value() * PER_MANA


## Cards are sold until the player owns as many copies as a deck can use.
static func is_for_sale(card: CardData, owned_copies: int) -> bool:
	return not card.is_token and not card.is_land() and owned_copies < MAX_OWNED_FOR_SALE
