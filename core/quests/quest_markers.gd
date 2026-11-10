class_name QuestMarkers
extends RefCounted
## Overnight Oct 16: which quest markers an area shows - pure rules, no scene. Two kinds:
## - Giver marks: "!" over an NPC who has a quest on offer, "?" over one a quest can be handed in to (every quest, tracked or not).
## - Objective markers: a quest's current step, over its target(s) in this area. A target in another area points at the way
##   there instead (in town: that zone's road; in a zone: the way back to town). A turn-in waits on the "?" mark, so it adds no second marker.
## Areas: "town", "forest" or a zone id.
## Fable pass Nov 10, Part 1.1: a step marks EVERY one of its parts (`QuestObjective.parts`), and `all_targets` lists the current step of every
## active quest (the map, the minimap and the "Point me to..." list show them all); the world chevrons and edge arrows follow the tracked
## quest and the other kind's most recent quest (`goal_targets`), as before.

const MARK_OFFER: String = "!"
const MARK_TURN_IN: String = "?"

## Spot ids a scene resolves to something that is not a fixed spot (the quest audit accepts them): every live roaming enemy of the area, every
## hidden stash still shut, the original giant chest in Crosspath.
const SPOT_ROAMERS: String = "roamers"
const SPOT_CHESTS: String = "chests"
const SPOT_HARBOR_CHEST: String = "harbor_chest"
const VIRTUAL_SPOTS: Array[String] = [SPOT_ROAMERS, SPOT_CHESTS, SPOT_HARBOR_CHEST]


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


## The tracked quest's first objective marker for this area: {"spot": id, "quest": quest id, "index": objective index, "via": true when it
## points at the way to another area}, or {} when there is nothing to mark here.
static func objective_target(area: String, qlog: QuestLog, state: UnlockState) -> Dictionary:
	var quest: QuestData = QuestCatalog.find(qlog.tracked_id())
	if quest == null or not qlog.is_active(quest.id):
		return {}
	if qlog.is_ready_to_turn_in(quest, state):
		if quest.turn_in_area == area:
			return {}  # the "?" mark already stands there
		return _via(area, quest.turn_in_area, quest.id, -1)
	var found: Array[Dictionary] = targets_for(quest, area, qlog, state)
	return found[0] if not found.is_empty() else {}


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


## Overnight Oct 30-31, Part 2 (goal pointer everywhere): the targets of the goal pointer in this area - the tracked quest's step first
## (every part of it), then the other kind's (the most recent main line's step while a side quest is tracked, the most recent side quest's
## step while a main line is tracked). Each is `targets_for`'s dictionary plus "main" (bool). A second target on a spot already listed is dropped.
static func goal_targets(area: String, qlog: QuestLog, state: UnlockState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var tracked: QuestData = QuestCatalog.find(qlog.tracked_id())
	if tracked == null or not qlog.is_active(tracked.id):
		return result
	var spots: Dictionary = {}
	for target: Dictionary in targets_for(tracked, area, qlog, state):
		if spots.has(str(target["spot"])):
			continue
		spots[str(target["spot"])] = true
		target["main"] = tracked.is_main()
		result.append(target)
	for index: int in range(qlog.active.size() - 1, -1, -1):
		var other: QuestData = QuestCatalog.find(str(qlog.active[index]))
		if other == null or other.id == tracked.id or other.is_main() == tracked.is_main():
			continue
		var found: Array[Dictionary] = targets_for(other, area, qlog, state)
		if found.is_empty():
			continue
		for target: Dictionary in found:
			if spots.has(str(target["spot"])):
				continue
			spots[str(target["spot"])] = true
			target["main"] = other.is_main()
			result.append(target)
		break
	return result


## Fable pass Nov 10, Part 1.1: the current step of EVERY active quest in this area (the map, the minimap and "Point me to..."): the tracked
## quest first, then the others newest first. Each is `targets_for`'s dictionary plus "main", "tracked" and "title" (the quest's name).
## One entry per spot per quest; the same road ("via") is listed once per quest.
static func all_targets(area: String, qlog: QuestLog, state: UnlockState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var order: Array[String] = []
	var tracked_id: String = qlog.tracked_id()
	if tracked_id != "":
		order.append(tracked_id)
	for index: int in range(qlog.active.size() - 1, -1, -1):
		var id: String = str(qlog.active[index])
		if id != tracked_id:
			order.append(id)
	for id: String in order:
		var quest: QuestData = QuestCatalog.find(id)
		if quest == null:
			continue
		var seen: Dictionary = {}
		for target: Dictionary in targets_for(quest, area, qlog, state):
			if seen.has(str(target["spot"])):
				continue
			seen[str(target["spot"])] = true
			target["main"] = quest.is_main()
			target["tracked"] = id == tracked_id
			target["title"] = quest.title
			result.append(target)
	return result


## One quest's first goal in this area (`targets_for`'s first entry, {} with none).
static func target_for(quest: QuestData, area: String, qlog: QuestLog, state: UnlockState) -> Dictionary:
	var found: Array[Dictionary] = targets_for(quest, area, qlog, state)
	return found[0] if not found.is_empty() else {}


## One quest's goals in this area: a turn-in in this area points at the NPC to hand it to ("turn_in": true; that NPC already wears the "?"
## mark, so the layer draws no chevron there, only the arrow and the map dot); otherwise every part of the current step that is not yet
## done ({"spot", "quest", "index", "via", "label", "kind"}); a part in another area becomes the way there (one "via" entry per road).
static func targets_for(quest: QuestData, area: String, qlog: QuestLog, state: UnlockState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if quest == null or not qlog.is_active(quest.id):
		return result
	if qlog.is_ready_to_turn_in(quest, state):
		if quest.turn_in_area == area and quest.turn_in_spot != "":
			result.append({"spot": quest.turn_in_spot, "quest": quest.id, "index": -1, "via": false, "turn_in": true, "label": "Hand in to %s" % quest.turn_in_npc, "kind": QuestObjective.TargetKind.NPC})
			return result
		var road: Dictionary = _via(area, quest.turn_in_area, quest.id, -1)
		if not road.is_empty():
			road["label"] = "Hand in to %s" % quest.turn_in_npc
			road["kind"] = QuestObjective.TargetKind.NPC
			result.append(road)
		return result
	var index: int = qlog.current_index(quest, state)
	if index >= quest.objectives.size():
		return result
	var objective: QuestObjective = quest.objectives[index]
	if not objective.has_marker():
		return result
	var roads: Dictionary = {}
	for target: Dictionary in objective.targets(state):
		var spot: String = str(target["spot"])
		var target_area: String = str(target["area"])
		if target_area == area:
			result.append({"spot": spot, "quest": quest.id, "index": index, "via": false, "label": str(target["label"]), "kind": target["kind"]})
			continue
		if spot == QuestDefinitions.OUTSKIRTS_SPOT:
			continue  # Fixes Oct 25: "win one fight" points at the outskirts in town only - a fight anywhere else counts just the same
		var road: Dictionary = _via(area, target_area, quest.id, index)
		if road.is_empty() or roads.has(str(road["spot"])):
			continue
		roads[str(road["spot"])] = true
		road["label"] = str(target["label"])
		road["kind"] = target["kind"]
		result.append(road)
	return result
