class_name QuestObjective
extends Resource
## One step of a quest. Built on the existing Condition system: the objective is done when its
## `condition` is met (a flag, a card owned, a secret found, a COUNTER at least N...). A COUNTER
## condition also gives a "2/3" progress readout; every other kind reads 0/1 -> 1/1.
## Objectives are ORDERED: the first one not yet done is the "current" step (the tracker highlights it and the world marker points at its target).
## Overnight Oct 16: each objective names a target (what and where the step is) and may pay a milestone reward the first time it is met.

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


func pays(reward: QuestReward) -> QuestObjective:
	milestone = reward
	return self


func has_marker() -> bool:
	return target_area != "" and target_id != ""
