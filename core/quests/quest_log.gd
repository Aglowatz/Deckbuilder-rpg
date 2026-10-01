class_name QuestLog
extends RefCounted
## The player's quest state: which quests are active/completed, plus the counter baselines taken
## when a quest started (so "defeat 3 enemies" counts from acceptance, not from the save's
## lifetime total). Pure data + rules; `Session` applies rewards and emits the UI events.

var active: Array[String] = []
var completed: Array[String] = []
## "<quest id>|<counter key>" -> the counter's value when the quest started.
var baselines: Dictionary = {}


func is_active(quest_id: String) -> bool:
	return active.has(quest_id)


func is_completed(quest_id: String) -> bool:
	return completed.has(quest_id)


func can_start(quest: QuestData, state: UnlockState) -> bool:
	if quest == null or is_active(quest.id) or is_completed(quest.id):
		return false
	return Condition.met(quest.prerequisite, state)


func start(quest: QuestData, state: UnlockState) -> bool:
	if not can_start(quest, state):
		return false
	active.append(quest.id)
	for objective: QuestObjective in quest.objectives:
		var cond: Condition = objective.condition
		if cond != null and cond.kind == Condition.Kind.COUNTER:
			baselines[_baseline_key(quest.id, cond.key)] = int(state.counters.get(cond.key, 0))
	return true


## (current, target) progress of one objective. Non-counter objectives are (0|1, 1).
func objective_progress(quest: QuestData, index: int, state: UnlockState) -> Vector2i:
	var cond: Condition = quest.objectives[index].condition
	if cond != null and cond.kind == Condition.Kind.COUNTER:
		var base: int = int(baselines.get(_baseline_key(quest.id, cond.key), 0))
		var value: int = maxi(0, int(state.counters.get(cond.key, 0)) - base)
		return Vector2i(mini(value, cond.amount), cond.amount)
	return Vector2i(1 if Condition.met(cond, state) else 0, 1)


func objective_met(quest: QuestData, index: int, state: UnlockState) -> bool:
	var progress: Vector2i = objective_progress(quest, index, state)
	return progress.x >= progress.y


func objectives_met_count(quest: QuestData, state: UnlockState) -> int:
	var count: int = 0
	for index: int in range(quest.objectives.size()):
		if objective_met(quest, index, state):
			count += 1
	return count


func all_objectives_met(quest: QuestData, state: UnlockState) -> bool:
	return objectives_met_count(quest, state) == quest.objectives.size()


## Active, every objective met, and waiting for the player to talk to the turn-in NPC.
func is_ready_to_turn_in(quest: QuestData, state: UnlockState) -> bool:
	return is_active(quest.id) and not quest.turn_in_npc.is_empty() and all_objectives_met(quest, state)


## Moves an active quest to completed. Returns false if it was not active.
func complete(quest_id: String) -> bool:
	if not active.has(quest_id):
		return false
	active.erase(quest_id)
	completed.append(quest_id)
	return true


## Ids of active quests with no turn-in NPC whose objectives are all met (to be completed now).
func auto_completable(catalog: Array[QuestData], state: UnlockState) -> Array[String]:
	var result: Array[String] = []
	for quest: QuestData in catalog:
		if is_active(quest.id) and quest.turn_in_npc.is_empty() and all_objectives_met(quest, state):
			result.append(quest.id)
	return result


func to_dict() -> Dictionary:
	return {"active": active, "completed": completed, "baselines": baselines}


func from_dict(data: Dictionary) -> void:
	active.assign(data.get("active", []) as Array)
	completed.assign(data.get("completed", []) as Array)
	baselines = (data.get("baselines", {}) as Dictionary).duplicate()


func reset() -> void:
	active.clear()
	completed.clear()
	baselines.clear()


static func _baseline_key(quest_id: String, counter_key: String) -> String:
	return "%s|%s" % [quest_id, counter_key]
