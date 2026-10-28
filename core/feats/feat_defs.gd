class_name FeatDefs
extends RefCounted
## Overnight Oct 27-28, Part 3: the feats (achievements) as data - data/feats/feats.json (docs/design/feats.md). Pure data: no scene
## tree. `FeatTracker` evaluates the triggers; `FeatState` / `FeatAccount` remember what was earned.

const PATH: String = "res://data/feats/feats.json"
## The group names in the order the Feats screen shows them.
const GROUP_ORDER: Array[String] = ["Story", "Zones", "Side dungeons", "Challenges", "Collection", "Beefcake", "Gourmand", "Necrocrat", "Refusemancer", "Dual Path"]
## Trigger kinds the tracker understands (the test checks every feat uses one).
const KINDS: Array[String] = ["flag", "flags", "zones", "counter", "collection", "dungeon", "snapshot", "quest", "battle", "moment"]


class Def:
	extends RefCounted
	var id: String = ""
	var name: String = ""
	var group: String = "Story"
	var hidden: bool = false
	var earned_by: String = ""
	var reward_gold: int = 0
	## Essence of EVERY Path paid once per account.
	var reward_essence: int = 0
	var trigger: Dictionary = {}

	func kind() -> String:
		return str(trigger.get("kind", ""))

	## "state" feats are re-checked against the save (retroactive); "moment" feats only fire from a live battle.
	func is_state() -> bool:
		var k: String = kind()
		return k != "battle" and k != "moment"

	func reward_text() -> String:
		var parts: Array[String] = []
		if reward_gold > 0:
			parts.append("%d gold" % reward_gold)
		if reward_essence > 0:
			parts.append("%d essence of each Path" % reward_essence)
		return ", ".join(parts)


static var _defs: Array[Def] = []
static var _by_id: Dictionary = {}


static func reload() -> void:
	_defs = []
	_by_id = {}


static func all() -> Array[Def]:
	if _defs.is_empty() and FileAccess.file_exists(PATH):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary:
			for row: Variant in (parsed as Dictionary).get("feats", []) as Array:
				var data: Dictionary = row as Dictionary
				var def: Def = Def.new()
				def.id = str(data.get("id", ""))
				def.name = str(data.get("name", def.id))
				def.group = str(data.get("group", "Story"))
				def.hidden = bool(data.get("hidden", false))
				def.earned_by = str(data.get("earned_by", ""))
				var reward: Dictionary = data.get("reward", {}) as Dictionary
				def.reward_gold = int(reward.get("gold", 0))
				def.reward_essence = int(reward.get("essence", 0))
				def.trigger = (data.get("trigger", {}) as Dictionary).duplicate()
				if def.id.is_empty():
					continue
				_defs.append(def)
				_by_id[def.id] = def
		else:
			push_error("FeatDefs: could not parse %s" % PATH)
	return _defs


static func find(id: String) -> Def:
	all()
	return _by_id.get(id, null) as Def


static func count() -> int:
	return all().size()


## The feats of one group, in file order.
static func in_group(group: String) -> Array[Def]:
	var result: Array[Def] = []
	for def: Def in all():
		if def.group == group:
			result.append(def)
	return result
