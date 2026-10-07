class_name DeckBox
extends RefCounted
## Brief 16, Group E: the player's saved decks. A box of named decks (card ids only, so a deck never breaks when a card is missing), one of them active - the active
## deck is the one battles and dungeons use (`Session.deck` always mirrors it). The box has 5 slots, 10 after the level-3 "deck box expansion" reward
## (`PlayerProfile.deck_slots`). Pure data and rules: no scene tree.

const MAX_NAME_LENGTH: int = 28
const DEFAULT_NAME: String = "New Deck"


class SavedDeck:
	extends RefCounted
	var name: String = ""
	## One entry per copy, in the order they were added.
	var card_ids: Array[String] = []

	func card_count() -> int:
		return card_ids.size()

	func copies(card_id: String) -> int:
		var count: int = 0
		for id: String in card_ids:
			if id == card_id:
				count += 1
		return count

	func to_dict() -> Dictionary:
		return {"name": name, "cards": card_ids.duplicate()}

	static func from_dict(data: Dictionary) -> SavedDeck:
		var deck: SavedDeck = SavedDeck.new()
		deck.name = str(data.get("name", DEFAULT_NAME))
		for id: Variant in data.get("cards", []) as Array:
			deck.card_ids.append(str(id))
		return deck


var decks: Array[SavedDeck] = []
var active: int = 0


## Card ids of a Deck resource (one per copy).
static func ids_of(deck: Deck) -> Array[String]:
	var result: Array[String] = []
	for card: CardData in deck.cards:
		result.append(card.id)
	return result


static func clean_name(raw: String, fallback: String = DEFAULT_NAME) -> String:
	var trimmed: String = raw.strip_edges()
	if trimmed.is_empty():
		trimmed = fallback
	return trimmed.substr(0, MAX_NAME_LENGTH)


func size() -> int:
	return decks.size()


func is_valid_index(index: int) -> bool:
	return index >= 0 and index < decks.size()


func active_deck() -> SavedDeck:
	return decks[active] if is_valid_index(active) else null


func is_full(capacity: int) -> bool:
	return decks.size() >= capacity


## Adds a deck; returns its index, or -1 when the box is full (`capacity` = the player's current deck slots).
func create(deck_name: String, ids: Array[String], capacity: int) -> int:
	if is_full(capacity):
		return -1
	var deck: SavedDeck = SavedDeck.new()
	deck.name = clean_name(deck_name)
	deck.card_ids = ids.duplicate()
	decks.append(deck)
	return decks.size() - 1


func rename(index: int, new_name: String) -> bool:
	if not is_valid_index(index):
		return false
	decks[index].name = clean_name(new_name, decks[index].name)
	return true


## Copies a deck ("Name (copy)") into the next free slot; returns the new index or -1 when the box is full.
func duplicate_deck(index: int, capacity: int) -> int:
	if not is_valid_index(index) or is_full(capacity):
		return -1
	var source: SavedDeck = decks[index]
	return create(clean_name("%s (copy)" % source.name.substr(0, MAX_NAME_LENGTH - 7)), source.card_ids, capacity)


## Deletes a deck. The last remaining deck can never be deleted (battles always need one). The active deck index follows the shift.
func delete(index: int) -> bool:
	if not is_valid_index(index) or decks.size() <= 1:
		return false
	decks.remove_at(index)
	if active > index:
		active -= 1
	elif active == index:
		active = clampi(active, 0, decks.size() - 1)
	return true


func set_active(index: int) -> bool:
	if not is_valid_index(index):
		return false
	active = index
	return true


func set_cards(index: int, ids: Array[String]) -> bool:
	if not is_valid_index(index):
		return false
	decks[index].card_ids = ids.duplicate()
	return true


## The Deck resource for a saved deck. Ids that no longer exist in the card set are skipped (see `unknown_ids`); the deck is named after the saved deck.
func build(index: int, lookup: Callable) -> Deck:
	var result: Deck = Deck.new()
	if not is_valid_index(index):
		return result
	result.deck_name = decks[index].name
	for id: String in decks[index].card_ids:
		var card: CardData = lookup.call(id) as CardData
		if card != null:
			result.cards.append(card)
	return result


func unknown_ids(index: int, lookup: Callable) -> Array[String]:
	var result: Array[String] = []
	if not is_valid_index(index):
		return result
	for id: String in decks[index].card_ids:
		if lookup.call(id) == null and not result.has(id):
			result.append(id)
	return result


## Cards the saved deck uses more copies of than the player owns (basic Infrastructure is unlimited): card id -> how many copies are missing.
func missing_cards(index: int, profile: PlayerProfile, lookup: Callable) -> Dictionary:
	var missing: Dictionary = {}
	if not is_valid_index(index) or profile == null:
		return missing
	var wanted: Dictionary = {}
	for id: String in decks[index].card_ids:
		wanted[id] = int(wanted.get(id, 0)) + 1
	for id: Variant in wanted.keys():
		var card: CardData = lookup.call(str(id)) as CardData
		if card == null or card.is_unlimited():
			continue
		var short: int = int(wanted[id]) - profile.owned_copies(str(id))
		if short > 0:
			missing[str(id)] = short
	return missing


func to_array() -> Array:
	var result: Array = []
	for deck: SavedDeck in decks:
		result.append(deck.to_dict())
	return result


static func from_array(rows: Array, saved_active: int) -> DeckBox:
	var box: DeckBox = DeckBox.new()
	for row: Variant in rows:
		if row is Dictionary:
			box.decks.append(SavedDeck.from_dict(row as Dictionary))
	box.active = clampi(saved_active, 0, maxi(box.decks.size() - 1, 0))
	return box
