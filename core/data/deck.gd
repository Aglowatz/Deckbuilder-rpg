class_name Deck
extends Resource
## A list of cards (one entry per copy).

@export var deck_name: String = ""
@export var cards: Array[CardData] = []


func size() -> int:
	return cards.size()


func count_of(card_id: String) -> int:
	var count: int = 0
	for card: CardData in cards:
		if card.id == card_id:
			count += 1
	return count


## Map of card id -> copies in the deck.
func copy_counts() -> Dictionary:
	var counts: Dictionary = {}
	for card: CardData in cards:
		counts[card.id] = int(counts.get(card.id, 0)) + 1
	return counts


func land_count() -> int:
	var count: int = 0
	for card: CardData in cards:
		if card.is_land():
			count += 1
	return count


## Distinct non-neutral color types used by any card (lands included).
func colors() -> Array[Affinity.Type]:
	var result: Array[Affinity.Type] = []
	for card: CardData in cards:
		if card.color != Affinity.Type.NEUTRAL and not result.has(card.color):
			result.append(card.color)
	return result
