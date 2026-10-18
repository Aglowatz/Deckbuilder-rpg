class_name DeckBox
extends RefCounted
## Brief 16, Group E: the player's saved decks. A box of named decks (card ids only, so a deck never breaks when a card is missing), one of them active - the active
## deck is the one battles and dungeons use (`Session.deck` always mirrors it). The box has 5 slots, 10 after the level-3 "deck box expansion" reward
## (`PlayerProfile.deck_slots`). Overnight Oct 17, Part 4: every deck sits in one of ten fixed Deck Station slots (`DeckSlots`; 4
## open at the start, 2 more at levels 7, 14 and 21) and may have a chosen cover card. Pure data and rules: no scene tree.

const MAX_NAME_LENGTH: int = 28
const DEFAULT_NAME: String = "New Deck"


class SavedDeck:
	extends RefCounted
	var name: String = ""
	## One entry per copy, in the order they were added.
	var card_ids: Array[String] = []
	## Overnight Oct 17, Part 4: the Deck Station slot (0-9, five across the top, five across the bottom) and the chosen
	## cover card ("" = the default, `DeckSlots.cover_id`).
	var slot: int = -1
	var cover_id: String = ""

	func card_count() -> int:
		return card_ids.size()

	func copies(card_id: String) -> int:
		var count: int = 0
		for id: String in card_ids:
			if id == card_id:
				count += 1
		return count

	func to_dict() -> Dictionary:
		return {"name": name, "cards": card_ids.duplicate(), "slot": slot, "cover": cover_id}

	static func from_dict(data: Dictionary) -> SavedDeck:
		var deck: SavedDeck = SavedDeck.new()
		deck.name = str(data.get("name", DEFAULT_NAME))
		for id: Variant in data.get("cards", []) as Array:
			deck.card_ids.append(str(id))
		deck.slot = int(data.get("slot", -1))
		deck.cover_id = str(data.get("cover", ""))
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


## True when no open slot is free (`capacity` = how many slots are open, `DeckSlots.unlocked_at`).
func is_full(capacity: int) -> bool:
	return free_slot(capacity) < 0


## The index of the deck in Deck Station slot `slot`, or -1 when the slot is empty.
func index_in_slot(slot: int) -> int:
	for index: int in range(decks.size()):
		if decks[index].slot == slot:
			return index
	return -1


## The first empty slot among the first `capacity` (open) slots, or -1.
func free_slot(capacity: int) -> int:
	for slot: int in range(mini(capacity, DeckSlots.SLOT_COUNT)):
		if index_in_slot(slot) < 0:
			return slot
	return -1


## Adds a deck in the first free open slot; returns its index, or -1 when the box is full (`capacity` = open slots).
func create(deck_name: String, ids: Array[String], capacity: int) -> int:
	var slot: int = free_slot(capacity)
	if slot < 0:
		return -1
	return _add(deck_name, ids, slot)


## Saves a deck into `slot`: overwrites the deck already there (name, cards, cover) or adds one. Returns its index.
func save_to_slot(slot: int, deck_name: String, ids: Array[String], cover: String = "") -> int:
	if slot < 0 or slot >= DeckSlots.SLOT_COUNT:
		return -1
	var index: int = index_in_slot(slot)
	if index < 0:
		index = _add(deck_name, ids, slot)
	else:
		decks[index].name = clean_name(deck_name, decks[index].name)
		decks[index].card_ids = ids.duplicate()
	decks[index].cover_id = cover
	return index


func _add(deck_name: String, ids: Array[String], slot: int) -> int:
	var deck: SavedDeck = SavedDeck.new()
	deck.name = clean_name(deck_name)
	deck.card_ids = ids.duplicate()
	deck.slot = slot
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
	var created: int = create(clean_name("%s (copy)" % source.name.substr(0, MAX_NAME_LENGTH - 7)), source.card_ids, capacity)
	if created >= 0:
		decks[created].cover_id = source.cover_id
	return created


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
	box.assign_missing_slots()
	return box


## Save migration (Part 4): decks from before the fixed slots (or with a clashing slot) take the first free slots in order.
func assign_missing_slots() -> void:
	var taken: Dictionary = {}
	for deck: SavedDeck in decks:
		if deck.slot >= 0 and deck.slot < DeckSlots.SLOT_COUNT and not taken.has(deck.slot):
			taken[deck.slot] = true
		else:
			deck.slot = -1
	for deck: SavedDeck in decks:
		if deck.slot >= 0:
			continue
		for slot: int in range(DeckSlots.SLOT_COUNT):
			if not taken.has(slot):
				deck.slot = slot
				taken[slot] = true
				break
