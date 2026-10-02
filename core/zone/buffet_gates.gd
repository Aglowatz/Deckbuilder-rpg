class_name BuffetGates
extends RefCounted
## The three golem gate guardians of the Endless Buffet. Each blocks the road into one northern district
## and lets you pass only after a condition: bring it an INGREDIENT (Saffron Threads, handed over and
## used up), complete a QUEST (Mend the Meatloaf), or defeat it in a card BATTLE. Once a gate has been
## opened it stays open (a flag), and the golem steps aside.

const INSTANCE_BATTLE: String = "gate_casserole"
const ENEMY_CASSEROLE: String = "casserole"


class Gate:
	extends RefCounted
	var id: String = ""
	## "ingredient", "quest" or "battle".
	var kind: String = ""
	var title: String = ""
	var speaker: String = ""
	## Layout anchor the golem stands at (the road runs through it).
	var anchor: String = ""
	## The persistent flag set once the gate is open.
	var flag: StringName = &""
	## What the golem checks (null for the battle gate: it is the fight).
	var requirement: Condition
	var district: String = ""

	func key(suffix: String) -> String:
		return "gate.%s.%s" % [id, suffix]


static func _gate(id: String, kind: String, title: String, speaker: String, flag: StringName, requirement: Condition, district: String) -> Gate:
	var gate: Gate = Gate.new()
	gate.id = id
	gate.kind = kind
	gate.title = title
	gate.speaker = speaker
	gate.anchor = "gate_" + id
	gate.flag = flag
	gate.requirement = requirement
	gate.district = district
	return gate


static func gates() -> Array[Gate]:
	return [
		_gate("ingredient", "ingredient", "Brisket, Doorman of the Cheese Cliffs", "Brisket", BuffetZone.FLAG_GATE_INGREDIENT, Condition.counter(BuffetZone.stock_key("saffron"), 1), "west"),
		_gate("quest", "quest", "Sir Loin, Warden of Layer-Cake Town", "Sir Loin", BuffetZone.FLAG_GATE_QUEST, Condition.quest_completed(BuffetZone.QUEST_MEND), "center"),
		_gate("battle", "battle", "Colonel Casserole, Gatekeeper of the Pancake Mesa", "Colonel Casserole", BuffetZone.FLAG_GATE_BATTLE, null, "east"),
	] as Array[Gate]


static func find(id: String) -> Gate:
	for gate: Gate in gates():
		if gate.id == id:
			return gate
	return null



## True when the golem's requirement is met right now (the battle gate never is: you must fight it).
static func requirement_met(gate: Gate, state: UnlockState) -> bool:
	if gate.kind == "battle":
		return false
	return Condition.met(gate.requirement, state)


