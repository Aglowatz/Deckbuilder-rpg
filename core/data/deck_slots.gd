class_name DeckSlots
extends RefCounted
## Overnight Oct 17, Part 4: the Deck Station's ten fixed slots (five across the top, five across the bottom). Four are open
## at the start and two more open at levels 7, 14 and 21. A slot shows a cover card: the deck's chosen cover, else its
## highest-rarity card (ties: the first added). Pure rules: no scene tree.

const SLOT_COUNT: int = 10
const COLUMNS: int = 5
const START_SLOTS: int = 4
const UNLOCK_STEP: int = 2
const UNLOCK_LEVELS: Array[int] = [7, 14, 21]


## How many slots are open at a player level (4, 6, 8, 10).
static func unlocked_at(level: int) -> int:
	var open: int = START_SLOTS
	for at: int in UNLOCK_LEVELS:
		if level >= at:
			open += UNLOCK_STEP
	return mini(open, SLOT_COUNT)


## The level that opens `slot` (0-based); 1 for the starting slots.
static func level_for_slot(slot: int) -> int:
	if slot < START_SLOTS:
		return 1
	var step: int = (slot - START_SLOTS) / UNLOCK_STEP
	return UNLOCK_LEVELS[mini(step, UNLOCK_LEVELS.size() - 1)]


## The cover card id of a list of card ids: `chosen` when the deck still holds it, else the highest-rarity non-infrastructure
## card, ties broken by the first added; "" for an empty deck (or one of only infrastructure, which shows its first card).
static func cover_id(ids: Array[String], lookup: Callable, chosen: String = "") -> String:
	if not chosen.is_empty() and ids.has(chosen):
		return chosen
	var best: CardData = null
	for id: String in ids:
		var card: CardData = lookup.call(id) as CardData
		if card == null or card.is_unlimited():
			continue
		if best == null or int(card.rarity) > int(best.rarity):
			best = card
	if best != null:
		return best.id
	return ids[0] if not ids.is_empty() else ""


## The Paths a deck's cards walk, in the game's Path order (for the slot's Path icons).
static func paths_of(ids: Array[String], lookup: Callable) -> Array[Affinity.Type]:
	var seen: Dictionary = {}
	for id: String in ids:
		var card: CardData = lookup.call(id) as CardData
		if card == null:
			continue
		for path: Affinity.Type in card.paths():
			seen[path] = true
	var result: Array[Affinity.Type] = []
	for path: Affinity.Type in Affinity.colored_types():
		if seen.has(path):
			result.append(path)
	return result
