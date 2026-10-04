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


func infrastructure_count() -> int:
	var count: int = 0
	for card: CardData in cards:
		if card.is_infrastructure():
			count += 1
	return count


## Distinct Paths used by any card (infrastructure included). A multi-Path card counts as BOTH of its Paths.
func colors() -> Array[Affinity.Type]:
	var result: Array[Affinity.Type] = []
	for card: CardData in cards:
		for path: Affinity.Type in card.paths():
			if not result.has(path):
				result.append(path)
	return result
