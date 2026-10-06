class_name TokenRegistry
extends RefCounted
## Looks up token cards (T-01 Poo Golem, T-09 Snack, T-12 Clause...) by id. Tokens are generated from the token sheet into
## `data/tokens/`; resource tokens are built in code (`ResourceRules.data_for`).

const DIRS: Array[String] = ["res://data/tokens/", "res://data/cards/"]

static var _cache: Dictionary = {}
## Tokens registered directly (tests, the importer) take precedence over the files in data/tokens/.
static var _registered: Dictionary = {}


static func register(card: CardData) -> void:
	_registered[card.id] = card
	_cache.erase(card.id)


static func data(id: String) -> CardData:
	if _registered.has(id):
		return _registered[id] as CardData
	if _cache.has(id):
		return _cache[id] as CardData
	var kind: int = ResourceKind.from_card_id(id)
	if kind != ResourceKind.NONE:
		var resource_card: CardData = ResourceRules.data_for(kind as ResourceKind.Kind)
		_cache[id] = resource_card
		return resource_card
	for dir: String in DIRS:
		var path: String = "%s%s.tres" % [dir, id]
		if ResourceLoader.exists(path):
			var loaded: CardData = load(path) as CardData
			if loaded != null:
				_cache[id] = loaded
				return loaded
	return null


static func clear_cache() -> void:
	_cache.clear()
