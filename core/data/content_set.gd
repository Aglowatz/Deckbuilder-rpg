class_name ContentSet
extends RefCounted
## Everything the game's content defines, keyed for easy lookup. The cards are the designed card set (data/source, imported by
## `CardImporter`); `index_card` files each one under the right dictionary.

## Card ID -> CardData for the collectible single-Path and Colorless cards (including special Infrastructure).
var cards: Dictionary = {}
## Card ID -> CardData for tokens (units, Clause, resources).
var tokens: Dictionary = {}
## Affinity.Type (as int) -> the BASIC infrastructure of that Path (Powerhouse, Ghost Town, Feastforge, Wasteworks).
var infrastructure: Dictionary = {}
var decks: Array[Deck] = []
var challenges: Array[ChallengeData] = []
var personalities: Array[AIPersonality] = []
## id -> EquipmentData / ItemData.
var equipment: Dictionary = {}
var items: Dictionary = {}
## Kept for the zone-equipment pieces (they are not cards).
var zone_equipment: Dictionary = {}
## Card ID -> CardData for the cards of two or more Paths (and dual-Path Infrastructure): crafted at the Alchemist and found in
## packs that include them; never sold or offered as ordinary rewards.
var multipath_cards: Dictionary = {}
## Card ID -> CardData of cards reserved for a zone (the zone vendors' special stock): empty; every card is in `cards`.
var zone_cards: Dictionary = {}


## Files a card under tokens / basic infrastructure / multi-Path cards / cards.
func index_card(card: CardData) -> void:
	if card.is_token:
		tokens[card.id] = card
	elif card.is_infrastructure() and card.is_basic:
		infrastructure[int(card.color)] = card
	elif card.is_multipath():
		multipath_cards[card.id] = card
	else:
		cards[card.id] = card


func card(id: String) -> CardData:
	if cards.has(id):
		return cards[id] as CardData
	if multipath_cards.has(id):
		return multipath_cards[id] as CardData
	if tokens.has(id):
		return tokens[id] as CardData
	for infra: Variant in infrastructure.values():
		if (infra as CardData).id == id:
			return infra as CardData
	if zone_cards.has(id):
		return zone_cards[id] as CardData
	return null


## Every card that can be owned or put in a deck (not tokens, not basic Infrastructure).
func all_collectible() -> Array[CardData]:
	var result: Array[CardData] = []
	for card_data: Variant in cards.values():
		result.append(card_data as CardData)
	for card_data: Variant in multipath_cards.values():
		result.append(card_data as CardData)
	result.sort_custom(func(a: CardData, b: CardData) -> bool: return a.id < b.id)
	return result


func equipment_piece(id: String) -> EquipmentData:
	if zone_equipment.has(id):
		return zone_equipment[id] as EquipmentData
	return equipment.get(id) as EquipmentData


func item(id: String) -> ItemData:
	return items.get(id) as ItemData


func deck(deck_name: String) -> Deck:
	for candidate: Deck in decks:
		if candidate.deck_name == deck_name:
			return candidate
	return null
