class_name SubAreaRewards
extends RefCounted
## Rewards of the sub-area chests and shrines: always drawn from the zone's own existing chest tables (`ZoneDef.chest_rewards`), never invented, so the economy
## (docs/design/progression.md) does not move. A tier picks which kind of entry: "small" gold only, "medium" an item entry, "large" a gold-and-item entry, "card" a card entry
## (shrines). Equipment, cosmetics and packs are left out: those are one-of-a-kind finds of the hidden chests. Deterministic per chest id.

const SMALL_GOLD: Array[int] = [15, 20, 25, 30]


static func reward(zone_id: String, tier: String, key: String) -> Dictionary:
	var pool: Dictionary = _pool(zone_id)
	var pick: int = absi(hash(key))
	match tier:
		"card":
			var cards: Array[Dictionary] = _entries(pool, "card")
			if not cards.is_empty():
				return _clean(cards[pick % cards.size()])
			return {"gold": 40}
		"large":
			var both: Array[Dictionary] = _entries(pool, "item")
			if not both.is_empty():
				var chosen: Dictionary = _clean(both[pick % both.size()])
				chosen["gold"] = maxi(int(chosen.get("gold", 0)), 50)
				return chosen
			return {"gold": 60}
		"medium":
			var items: Array[Dictionary] = _entries(pool, "item")
			if not items.is_empty():
				return _clean(items[pick % items.size()])
			return {"gold": 40}
	return {"gold": SMALL_GOLD[pick % SMALL_GOLD.size()]}


static func _pool(zone_id: String) -> Dictionary:
	if zone_id != "" and ZoneDefs.has_def(zone_id):
		return ZoneDefs.get_def(zone_id).chest_rewards
	# The town, the forest, the castle and the lab have no zone table: use the first Path zone's (a plain mix of gold, items and cards).
	return ZoneDefs.get_def(GainlandsZone.ID).chest_rewards


## Entries holding `key` (a non-empty "item" or "card") and nothing one-of-a-kind.
static func _entries(pool: Dictionary, key: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var ids: Array = pool.keys()
	ids.sort()
	for id: Variant in ids:
		var entry: Dictionary = pool[id] as Dictionary
		if str(entry.get(key, "")) == "":
			continue
		if entry.has("equipment") or entry.has("cosmetic") or entry.has("pack"):
			continue
		result.append(entry)
	return result


static func _clean(entry: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: String in ["gold", "item", "card", "xp"]:
		if entry.has(key) and (str(entry[key]) != "" and str(entry[key]) != "0"):
			result[key] = entry[key]
	return result
