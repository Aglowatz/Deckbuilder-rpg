class_name QuestCatalog
extends RefCounted
## Every quest in the game, built once from `QuestDefinitions.build_all()` (the authoring source; since Oct 16 there are no generated .tres
## files to drift out of step with it). Sorted by `order`.

static var _cache: Array[QuestData] = []
static var _by_id: Dictionary = {}


static func all() -> Array[QuestData]:
	if _cache.is_empty():
		_cache = QuestDefinitions.build_all()
		for quest: QuestData in _cache:
			scale_gold(quest)
		_cache.sort_custom(func(a: QuestData, b: QuestData) -> bool: return a.order < b.order)
		_by_id.clear()
		for quest: QuestData in _cache:
			_by_id[quest.id] = quest
	return _cache


## Overnight Nov 4-5, Part 2.2 (docs/balance/gold_economy_nov3.md, "Overnight Nov 4-5"): quests pay more, weighted toward the main line and
## the longer side quests - the gold a repeat fight's x2 used to give now comes from quests and dungeon clear bonuses. The authored numbers in
## QuestDefinitions / ZoneQuestDefinitions stay the base; this scales the reward and every milestone's gold, rounded to 5.
## Fixes Nov 8 (owner): back to the Nov 4-5 scales - the no-grind run earns about 21,200 again (Nov 7-8 had cut them to 0.45 / 0.5 / 0.5).
const MAIN_GOLD_SCALE: float = 1.75
const LONG_SIDE_GOLD_SCALE: float = 1.6
const SIDE_GOLD_SCALE: float = 1.5
## A side quest with at least this many steps counts as a long one.
const LONG_SIDE_STEPS: int = 3


static func gold_scale(quest: QuestData) -> float:
	if quest.is_main():
		return MAIN_GOLD_SCALE
	return LONG_SIDE_GOLD_SCALE if quest.objectives.size() >= LONG_SIDE_STEPS else SIDE_GOLD_SCALE


static func scale_gold(quest: QuestData) -> void:
	var factor: float = gold_scale(quest)
	quest.reward_gold = roundi(float(quest.reward_gold) * factor / 5.0) * 5
	for objective: QuestObjective in quest.objectives:
		if objective.milestone != null and objective.milestone.gold > 0:
			var paid: QuestReward = objective.milestone.duplicate() as QuestReward
			paid.gold = roundi(float(paid.gold) * factor / 5.0) * 5
			objective.milestone = paid


static func find(quest_id: String) -> QuestData:
	all()
	return _by_id.get(quest_id) as QuestData


## Drops the cache (tests that swap definitions, the dialogue rewrite tool).
static func clear_cache() -> void:
	_cache.clear()
	_by_id.clear()
