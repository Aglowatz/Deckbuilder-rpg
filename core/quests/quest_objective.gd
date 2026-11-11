class_name QuestObjective
extends Resource
## One step of a quest. Built on the existing Condition system: the objective is done when its
## `condition` is met (a flag, a card owned, a secret found, a COUNTER at least N...). A COUNTER
## condition also gives a "2/3" progress readout; every other kind reads 0/1 -> 1/1.
## Objectives are ORDERED: the first one not yet done is the "current" step (the tracker highlights it and the world marker points at its target).
## Overnight Oct 16: each objective names a target (what and where the step is) and may pay a milestone reward the first time it is met.
## Fable pass Nov 10, Part 1.1: a step with several things to find (sea salt AND a black truffle AND Old Meatloaf; the three favour givers; every
## roaming enemy) carries `parts` - one marker each, and a part drops off the map on its own once its `done` condition is met.

enum TargetKind { NONE, NPC, SPOT, ITEM_COUNT, BATTLE, DUNGEON, ZONE_FLAG }

@export var text: String = ""
@export var condition: Condition
@export var target_kind: TargetKind = TargetKind.NONE
## Where the target is: "town", "forest" or a zone id (`ZoneDefs`). "" = anywhere (no world marker).
@export var target_area: String = ""
## The target inside that area: a spot id ("npc_beefcake", "main_dungeon", "portal_gourmand"...). "" = no marker.
@export var target_id: String = ""
## Player-facing "where to go" line for the Quest Log ("The gorge bridge, south of town").
@export var hint: String = ""
## Paid once, the first time this step is met while the quest is active (a quest line's gatekeeper pack, its midpoint gear). Null = none.
@export var milestone: QuestReward
## The step's several targets, each {"kind": TargetKind, "area": String, "spot": String, "label": String, "done": Condition or null}. With any
## part the primary target above is only a fallback for the Quest Log's hint; the markers come from the parts that are not yet done.
@export var parts: Array[Dictionary] = []
## A step done in a menu (open a pack, equip a piece): it has no place in the world, so it needs no marker (the quest audit accepts it).
@export var menu_step: bool = false


static func make(label: String, cond: Condition) -> QuestObjective:
	var made: QuestObjective = QuestObjective.new()
	made.text = label
	made.condition = cond
	return made


## Fluent helper for the definitions: `QuestObjective.make(...).at(TargetKind.NPC, "town", "npc_beefcake", "The gorge, south of town")`.
func at(kind: TargetKind, area: String, id: String, where: String = "") -> QuestObjective:
	target_kind = kind
	target_area = area
	target_id = id
	hint = where
	return self


## Adds one part: `done` (optional) is the condition that drops this part's marker before the whole step is done (the salt is held).
func part(kind: TargetKind, area: String, id: String, label: String = "", done: Condition = null) -> QuestObjective:
	parts.append({"kind": kind, "area": area, "spot": id, "label": label, "done": done})
	return self


## Overnight Nov 10-11 (Part 1.1): the "where to go" line once every gate part on the way is open (`way_open`); "" = the hint stays.
@export var hint_open: String = ""


func open_hint(where: String) -> QuestObjective:
	hint_open = where
	return self


## True once no part but the destination itself (a DUNGEON part) is left undone: the gates on the way are open, so the hint can stop
## naming them. False for a step without parts.
func way_open(state: UnlockState) -> bool:
	if parts.is_empty():
		return false
	for entry: Dictionary in targets(state):
		if int(entry.get("kind", TargetKind.SPOT)) != TargetKind.DUNGEON:
			return false
	return true


## Marks a menu step (no world marker by design).
func in_menu() -> QuestObjective:
	menu_step = true
	return self


func pays(reward: QuestReward) -> QuestObjective:
	milestone = reward
	return self


func has_marker() -> bool:
	if not parts.is_empty():
		return true
	return target_area != "" and target_id != ""


## The things this step marks right now: every part whose `done` is not met (in authoring order), or the primary target alone. Each is
## {"kind", "area", "spot", "label"}; [] when nothing is marked.
func targets(state: UnlockState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if parts.is_empty():
		if target_area != "" and target_id != "":
			result.append({"kind": target_kind, "area": target_area, "spot": target_id, "label": ""})
		return result
	for entry: Dictionary in parts:
		var done: Condition = entry.get("done") as Condition
		if done != null and state != null and Condition.met(done, state):
			continue
		result.append({"kind": entry.get("kind", TargetKind.SPOT), "area": str(entry.get("area", "")), "spot": str(entry.get("spot", "")), "label": str(entry.get("label", ""))})
	return result
