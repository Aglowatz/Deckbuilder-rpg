class_name QuestObjective
extends Resource
## One step of a quest. Built on the existing Condition system: the objective is done when its
## `condition` is met (a flag, a card owned, a secret found, a COUNTER at least N...). A COUNTER
## condition also gives a "2/3" progress readout; every other kind reads 0/1 -> 1/1.

@export var text: String = ""
@export var condition: Condition


static func make(label: String, cond: Condition) -> QuestObjective:
	var made: QuestObjective = QuestObjective.new()
	made.text = label
	made.condition = cond
	return made
