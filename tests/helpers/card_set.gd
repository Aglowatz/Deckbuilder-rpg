class_name CardSet
extends RefCounted
## The designed card set for tests: every card and token as imported from the sheets (in memory, no files written), with the
## tokens registered so `create(T-04)` works. Parsed once per test run.

static var _cards: Dictionary = {}
static var _entries: Array[CardImporter.Entry] = []


static func load_all() -> void:
	if not _cards.is_empty():
		return
	_entries = CardImporter.build_all()
	for entry: CardImporter.Entry in _entries:
		_cards[entry.id] = entry.data
		if entry.is_token:
			TokenRegistry.register(entry.data)


static func entries() -> Array[CardImporter.Entry]:
	load_all()
	return _entries


static func card(id: String) -> CardData:
	load_all()
	assert(_cards.has(id), "unknown card id %s" % id)
	return _cards[id] as CardData


static func all_cards() -> Array[CardData]:
	load_all()
	var result: Array[CardData] = []
	for entry: CardImporter.Entry in _entries:
		if not entry.is_token:
			result.append(entry.data)
	return result


static func all_tokens() -> Array[CardData]:
	load_all()
	var result: Array[CardData] = []
	for entry: CardImporter.Entry in _entries:
		if entry.is_token:
			result.append(entry.data)
	return result
