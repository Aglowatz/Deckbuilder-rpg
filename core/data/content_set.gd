class_name ContentSet
extends RefCounted
## Everything the placeholder content defines, keyed for easy lookup.

## card id -> CardData for the 40 collectible placeholder cards.
var cards: Dictionary = {}
## card id -> CardData for tokens created by effects.
var tokens: Dictionary = {}
## Affinity.Type (as int) -> basic land CardData (including a Neutral land).
var lands: Dictionary = {}
var decks: Array[Deck] = []
var challenges: Array[ChallengeData] = []
var personalities: Array[AIPersonality] = []
## Part E: id -> EquipmentData / ItemData for the 5 placeholder equipment pieces and 3 items.
var equipment: Dictionary = {}
var items: Dictionary = {}
## Zone-exclusive collectible cards (the D.N.A. vendor, mini dungeon, printer). Kept apart from `cards`
## so they never leak into random rewards, the general card vendor or the balance simulations.
var zone_cards: Dictionary = {}
var zone_equipment: Dictionary = {}


func card(id: String) -> CardData:
	if cards.has(id):
		return cards[id] as CardData
	if tokens.has(id):
		return tokens[id] as CardData
	if zone_cards.has(id):
		return zone_cards[id] as CardData
	return null


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
