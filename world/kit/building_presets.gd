class_name BuildingPresets
extends RefCounted
## The named building presets (data/art/building_presets.json): homes, the inn, the card / potion / equipment / clothing / pack shops, the Alchemist, a stone hut, the chapel and the
## hall. `spec()` returns a deep copy you may override (size, floors, roof style ...); `build()` assembles it with `BuildingKit`.

const PATH: String = "res://data/art/building_presets.json"

static var _presets: Dictionary = {}
static var _loaded: bool = false


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var file: FileAccess = FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		push_warning("BuildingPresets: %s missing" % PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_presets = ((parsed as Dictionary).get("presets", {}) as Dictionary)


static func names() -> Array[String]:
	_load()
	var result: Array[String] = []
	for key: Variant in _presets.keys():
		result.append(str(key))
	return result


static func has(preset_name: String) -> bool:
	_load()
	return _presets.has(preset_name)


## A deep copy of the preset with `overrides` merged over the top (shallow keys: width, depth, floors, roof ...). The preset's name is stored as spec["name"].
static func spec(preset_name: String, overrides: Dictionary = {}) -> Dictionary:
	_load()
	var base: Dictionary = (_presets.get(preset_name, {}) as Dictionary).duplicate(true)
	base["name"] = preset_name
	for key: Variant in overrides.keys():
		base[key] = overrides[key]
	return base


static func build(preset_name: String, overrides: Dictionary = {}, tint: Color = Color.WHITE) -> Node3D:
	return BuildingKit.build(spec(preset_name, overrides), tint)


## Every kit id a preset uses (walls, trims, roof, doors, windows, signs ...), for the status table.
static func kit_ids(preset_name: String) -> Array[String]:
	var found: Dictionary = {}
	var data: Dictionary = spec(preset_name)
	for key: String in ["wall", "wall_upper", "foundation_wall", "beam", "eave"]:
		if data.has(key):
			found[str(data[key])] = true
	if not data.has("wall"):
		found["ENV-WALL-TIMBER"] = true
	found["ENV-WALL-FOUNDATION"] = true
	found["ENV-BEAM"] = true
	found["ENV-ROOF-EAVE"] = true
	var roof: Dictionary = data.get("roof", {}) as Dictionary
	found[str(roof.get("material", "ENV-ROOF-TILE-RED"))] = true
	for face_list: Variant in (data.get("faces", {}) as Dictionary).values():
		for socket: Variant in face_list as Array:
			var socket_data: Dictionary = socket as Dictionary
			if socket_data.has("id"):
				found[str(socket_data["id"])] = true
			if socket_data.has("awning_id"):
				found[str(socket_data["awning_id"])] = true
			if str(socket_data.get("type", "")) == "ivy":
				found["DEC-IVY"] = true
	var result: Array[String] = []
	for key: Variant in found.keys():
		result.append(str(key))
	result.sort()
	return result
