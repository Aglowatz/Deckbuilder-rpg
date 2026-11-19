class_name ZoneCamera
extends RefCounted
## Fable Nov 19 (Part 2): the default camera of each place - how many degrees it looks down more than the presets (`pitch_bonus`) and
## how far it stands (`distance`, 1.0 = as everywhere) - read from `data/camera/zone_camera.json`, ONE line per place. A scene calls
## `apply(<place>)` when it starts and `clear()` when it leaves; `CameraRig.shape` does the rest. Places: "crosspath", "forest", the four
## zone ids ("beefcake", "gourmand", "refusemancer", "necrocrat"), "final" (the Capital) and "crease".

const FILE: String = "res://data/camera/zone_camera.json"

static var _places: Dictionary = {}
static var current: String = ""


static func _load() -> void:
	if not _places.is_empty():
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FILE))
	if parsed is Dictionary:
		_places = (parsed as Dictionary).get("places", {}) as Dictionary
	if _places.is_empty():
		_places = {"crosspath": {}}


static func reload() -> void:
	_places = {}
	_load()


static func places() -> Array:
	_load()
	return _places.keys()


static func pitch_bonus(place: String) -> float:
	_load()
	return float((_places.get(place, {}) as Dictionary).get("pitch_bonus", 0.0))


static func distance(place: String) -> float:
	_load()
	return clampf(float((_places.get(place, {}) as Dictionary).get("distance", 1.0)), 0.5, 2.0)


## The place's camera from now on. `eased` lets the rig glide to it (walking from the Capital into the Crease) instead of jumping.
static func apply(place: String, eased: bool = false) -> void:
	current = place
	CameraRig.zone_pitch_target = pitch_bonus(place)
	CameraRig.zone_distance_target = distance(place)
	if not eased:
		CameraRig.zone_pitch_bonus = CameraRig.zone_pitch_target
		CameraRig.zone_distance = CameraRig.zone_distance_target


static func clear() -> void:
	current = ""
	CameraRig.zone_pitch_bonus = 0.0
	CameraRig.zone_pitch_target = 0.0
	CameraRig.zone_distance = 1.0
	CameraRig.zone_distance_target = 1.0
