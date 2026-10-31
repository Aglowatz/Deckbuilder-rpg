class_name QuestMarkers
extends RefCounted
## Overnight Oct 16: which quest markers an area shows - pure rules, no scene. Two kinds:
## - Giver marks: "!" over an NPC who has a quest on offer, "?" over one a quest can be handed in to (every quest, tracked or not).
## - ONE objective marker: the tracked quest's current step, over its target in this area. A target in another area points at the way
##   there instead (in town: that zone's road; in a zone: the way back to town). A turn-in waits on the "?" mark, so it adds no second marker.
## Areas: "town", "forest" or a zone id.

const MARK_OFFER: String = "!"
const MARK_TURN_IN: String = "?"


## spot id -> "!" or "?" for this area ("?" wins when an NPC has both).
static func giver_marks(area: String, qlog: QuestLog, catalog: Array[QuestData], state: UnlockState) -> Dictionary:
	var marks: Dictionary = {}
	for quest: QuestData in catalog:
		if quest.turn_in_area == area and quest.turn_in_spot != "" and qlog.is_ready_to_turn_in(quest, state):
			marks[quest.turn_in_spot] = MARK_TURN_IN
	for quest: QuestData in catalog:
		if quest.auto_give or quest.giver_area != area or quest.giver_spot == "" or marks.has(quest.giver_spot):
			continue
		if qlog.can_start(quest, state):
			marks[quest.giver_spot] = MARK_OFFER
	return marks


## The tracked quest's objective marker for this area: {"spot": id, "quest": quest id, "index": objective index, "via": true when it points
## at the way to another area}, or {} when there is nothing to mark here.
static func objective_target(area: String, qlog: QuestLog, state: UnlockState) -> Dictionary:
	var quest: QuestData = QuestCatalog.find(qlog.tracked_id())
	if quest == null or not qlog.is_active(quest.id):
		return {}
	if qlog.is_ready_to_turn_in(quest, state):
		if quest.turn_in_area == area:
			return {}  # the "?" mark already stands there
		return _via(area, quest.turn_in_area, quest.id, -1)
	var index: int = qlog.current_index(quest, state)
	if index >= quest.objectives.size():
		return {}
	var objective: QuestObjective = quest.objectives[index]
	if not objective.has_marker():
		return {}
	if objective.target_area == area:
		return {"spot": objective.target_id, "quest": quest.id, "index": index, "via": false}
	if objective.target_id == QuestDefinitions.OUTSKIRTS_SPOT:
		return {}  # Fixes Oct 25: "win one fight" points at the outskirts in town only - a fight anywhere else counts just the same
	return _via(area, objective.target_area, quest.id, index)


## The way from `area` toward `target_area`: town -> that zone's road (`portal_<zone>`), a zone -> its exit back to town.
static func _via(area: String, target_area: String, quest_id: String, index: int) -> Dictionary:
	if target_area == "" or target_area == area:
		return {}
	if area == "town":
		if ZoneDefs.has_def(target_area):
			return {"spot": "portal_%s" % target_area, "quest": quest_id, "index": index, "via": true}
		return {}
	if ZoneDefs.has_def(area):
		return {"spot": "exit", "quest": quest_id, "index": index, "via": true}
	return {}


## Overnight Oct 30-31, Part 2 (goal pointer everywhere): the targets of the goal pointer in this area, at most two - the tracked quest's
## step first, then the other kind's (the most recent main line's step while a side quest is tracked, the most recent side quest's step
## while a main line is tracked). Each is `target_for`'s dictionary plus "main" (bool). A second target on the same spot is dropped.
static func goal_targets(area: String, qlog: QuestLog, state: UnlockState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var tracked: QuestData = QuestCatalog.find(qlog.tracked_id())
	if tracked == null or not qlog.is_active(tracked.id):
		return result
	var first: Dictionary = target_for(tracked, area, qlog, state)
	if not first.is_empty():
		first["main"] = tracked.is_main()
		result.append(first)
	for index: int in range(qlog.active.size() - 1, -1, -1):
		var other: QuestData = QuestCatalog.find(str(qlog.active[index]))
		if other == null or other.id == tracked.id or other.is_main() == tracked.is_main():
			continue
		var target: Dictionary = target_for(other, area, qlog, state)
		if target.is_empty():
			continue
		if not result.is_empty() and str(result[0]["spot"]) == str(target["spot"]):
			break
		target["main"] = other.is_main()
		result.append(target)
		break
	return result


## One quest's goal in this area, like `objective_target` but for any quest, and a turn-in in this area points at the NPC to hand it to
## ("turn_in": true; that NPC already wears the "?" mark, so the layer draws no chevron there, only the arrow and the map dot).
static func target_for(quest: QuestData, area: String, qlog: QuestLog, state: UnlockState) -> Dictionary:
	if quest == null or not qlog.is_active(quest.id):
		return {}
	if qlog.is_ready_to_turn_in(quest, state):
		if quest.turn_in_area == area and quest.turn_in_spot != "":
			return {"spot": quest.turn_in_spot, "quest": quest.id, "index": -1, "via": false, "turn_in": true}
		return _via(area, quest.turn_in_area, quest.id, -1)
	var index: int = qlog.current_index(quest, state)
	if index >= quest.objectives.size():
		return {}
	var objective: QuestObjective = quest.objectives[index]
	if not objective.has_marker():
		return {}
	if objective.target_area == area:
		return {"spot": objective.target_id, "quest": quest.id, "index": index, "via": false}
	if objective.target_id == QuestDefinitions.OUTSKIRTS_SPOT:
		return {}
	return _via(area, objective.target_area, quest.id, index)
