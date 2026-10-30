class_name CardPricing
extends RefCounted
## What the vendor charges for a card (gold). Overnight Oct 29: the price is the curve's by rarity (Economy.CARD_PRICE:
## 30 / 60 / 150 / 300, docs/design/economy.md); the old energy term is gone, so a 1-cost and a 5-cost Common cost the same.

const PER_ENERGY: int = 0
## The absolute copy limit; the real limit is the card's copy cap at the player's level (`CopyCaps`).
const MAX_OWNED_FOR_SALE: int = CopyCaps.ABSOLUTE_MAX


static func price(card: CardData) -> int:
	return Economy.card_price(card.rarity) + card.energy_value() * PER_ENERGY


## Cards are sold until the player owns as many copies as their copy cap allows (`cap` < 0: the absolute limit).
static func is_for_sale(card: CardData, owned_copies: int, cap: int = -1) -> bool:
	var limit: int = MAX_OWNED_FOR_SALE if cap < 0 else mini(cap, MAX_OWNED_FOR_SALE)
	return not card.is_token and not card.is_infrastructure() and owned_copies < limit
