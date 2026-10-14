class_name SubAreaDefs
extends RefCounted
## Sub-areas (Art Bible G-07): each area is a hub (the existing scene) plus 3-5 connected sub-area scenes that load one at a time.
## Data: `data/subareas/<area>/_zone.json` (the area: style, hub scene, the gates standing in the hub) and `data/subareas/<area>/<sub>.json`
## (one blockout: ground, paths, buildings, landmarks, clusters, trees, points of interest, exits). Plans live in `docs/zone_plans/<area>.md`.
## Pure data: no scene tree.

const DIR: String = "res://data/subareas/"
const AREAS: Array[String] = [
	"main_town", "starting_forest", "gainlands", "dna", "buffet", "heap", "capital_outside", "capital_inside", "castle_grounds", "pathology_lab",
]
static var _cache: Dictionary = {}


static func _read(path: String) -> Dictionary:
	if _cache.has(path):
		return _cache[path] as Dictionary
	var result: Dictionary = {}
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary:
			result = parsed as Dictionary
	_cache[path] = result
	return result


static func clear_cache() -> void:
	_cache.clear()


## The area file (`_zone.json`): {} for an area without sub-areas.
static func area(area_id: String) -> Dictionary:
	return _read("%s%s/_zone.json" % [DIR, area_id])


static func has_area(area_id: String) -> bool:
	return not area(area_id).is_empty()


static func sub_ids(area_id: String) -> Array[String]:
	var result: Array[String] = []
	for entry: Variant in area(area_id).get("subareas", []) as Array:
		result.append(str(entry))
	return result


static func sub(area_id: String, sub_id: String) -> Dictionary:
	return _read("%s%s/%s.json" % [DIR, area_id, sub_id])


## The gates the hub scene shows: [{id, sub, label, pos: [x, z], yaw, return: [x, z]?}].
static func gates(area_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Variant in area(area_id).get("gates", []) as Array:
		result.append(entry as Dictionary)
	return result


## The ZoneDef id of the area ("" for the town, the forest, the castle and the lab).
static func zone_id(area_id: String) -> String:
	return str(area(area_id).get("zone_id", ""))


## The scene the "hub" exit of this area's sub-areas returns to.
static func hub_scene(area_id: String) -> String:
	return str(area(area_id).get("hub_scene", ""))


## Every area that has this hub scene file (the Capital's two areas share one scene).
static func areas_of_scene(scene_path: String) -> Array[String]:
	var result: Array[String] = []
	for area_id: String in AREAS:
		if hub_scene(area_id) == scene_path:
			result.append(area_id)
	return result


## The save token of a sub-area ("sub:<area>/<sub>") and its parts.
static func token(area_id: String, sub_id: String) -> String:
	return "sub:%s/%s" % [area_id, sub_id]


static func parse_token(value: String) -> Array[String]:
	if not value.begins_with("sub:") or not value.contains("/"):
		return []
	var rest: String = value.trim_prefix("sub:")
	var parts: PackedStringArray = rest.split("/", false)
	if parts.size() != 2 or sub(parts[0], parts[1]).is_empty():
		return []
	return [parts[0], parts[1]]
