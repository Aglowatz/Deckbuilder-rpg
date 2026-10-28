class_name FeatState
extends RefCounted
## Overnight Oct 27-28, Part 3: the feats one campaign slot has earned (`Session.feats.state`, saved under "feats"). id -> unix time.

const VERSION: int = 1

var unlocked: Dictionary = {}


func has(id: String) -> bool:
	return unlocked.has(id)


## Records `id`; false when it was already earned in this campaign.
func unlock(id: String, when: int = -1) -> bool:
	if unlocked.has(id):
		return false
	unlocked[id] = int(Time.get_unix_time_from_system()) if when < 0 else when
	return true


func count() -> int:
	return unlocked.size()


func to_dict() -> Dictionary:
	return {"version": VERSION, "unlocked": unlocked.duplicate()}


func from_dict(data: Dictionary) -> void:
	unlocked = {}
	for key: Variant in (data.get("unlocked", {}) as Dictionary).keys():
		unlocked[str(key)] = int((data["unlocked"] as Dictionary)[key])
