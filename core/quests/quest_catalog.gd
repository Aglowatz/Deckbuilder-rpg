class_name QuestCatalog
extends RefCounted
## Every quest in the game, built once from `QuestDefinitions.build_all()` (the authoring source; since Oct 16 there are no generated .tres
## files to drift out of step with it). Sorted by `order`.

static var _cache: Array[QuestData] = []
static var _by_id: Dictionary = {}


static func all() -> Array[QuestData]:
	if _cache.is_empty():
		_cache = QuestDefinitions.build_all()
		_cache.sort_custom(func(a: QuestData, b: QuestData) -> bool: return a.order < b.order)
		_by_id.clear()
		for quest: QuestData in _cache:
			_by_id[quest.id] = quest
	return _cache


static func find(quest_id: String) -> QuestData:
	all()
	return _by_id.get(quest_id) as QuestData


## Drops the cache (tests that swap definitions, the dialogue rewrite tool).
static func clear_cache() -> void:
	_cache.clear()
	_by_id.clear()
