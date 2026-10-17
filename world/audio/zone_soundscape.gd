class_name ZoneSoundscape
extends RefCounted
## Which ambience each place plays and where its landmark loops stand (docs/audio/sound_direction.md, "Places"). The ambience itself is data
## (`AmbienceProfiles`); this picks the profile from the zone, the Capital's area and its districts' state, and places the `AmbientEmitter`s.

## A Path zone's id -> its ambience profile.
const ZONE_PROFILES: Dictionary = {"beefcake": "gainlands", "necrocrat": "dna", "gourmand": "buffet", "refusemancer": "heap"}
## The Verdant Dump grows eerier toward the Rotheart: full corruption at this distance from it, none beyond `HEAP_EERIE_FAR`.
const HEAP_EERIE_NEAR: float = 26.0
const HEAP_EERIE_FAR: float = 78.0


static func zone_profile(zone_id: String) -> String:
	return str(ZONE_PROFILES.get(zone_id, "none"))


## The Capital by area: outside the walls the wasteland; inside the perfect quiet, each district broken or restored by its own Path's completion
## flag, and the restored city once Primm has fallen.
static func capital_profile(area_id: String, inside: bool, flags: Dictionary) -> String:
	if not inside:
		return "capital_out"
	if MusicDirector.CAPITAL_DISTRICTS.has(area_id):
		var path: String = str(MusicDirector.CAPITAL_DISTRICTS[area_id])
		return "capital_%s_%s" % [area_id, "restored" if ZoneCompletion.is_completed(flags, path) else "broken"]
	if bool(flags.get(str(CapitalZone.FLAG_FREED), false)):
		return "capital_restored"
	return "capital_in"


## 0..1: how close a point of the Verdant Dump is to the Rotheart.
static func heap_corruption(pos: Vector3) -> float:
	var distance: float = Vector2(pos.x - HeapLayout.ROTHEART.x, pos.z - HeapLayout.ROTHEART.y).length()
	return clampf(1.0 - (distance - HEAP_EERIE_NEAR) / (HEAP_EERIE_FAR - HEAP_EERIE_NEAR), 0.0, 1.0)


## The landmark loops of a zone, as [set, position, reach metres, dB].
static func emitters(zone_id: String) -> Array:
	match zone_id:
		"beefcake":
			return [["spot/wheel_creak", Vector3(GainlandsLayout.HERO_WHEEL.x, 2.0, GainlandsLayout.HERO_WHEEL.y), 24.0, 0.0]]
		"refusemancer":
			return [
				["spot/rotheart", Vector3(HeapLayout.ROTHEART.x, 4.0, HeapLayout.ROTHEART.y + 26.0), 46.0, 2.0],
				["spot/mill", Vector3(HeapLayout.WINDMILL.x, 4.0, HeapLayout.WINDMILL.y), 20.0, -2.0],
			]
		"gourmand":
			return [
				["spot/gravy", Vector3(30.0, 0.0, BuffetLayout.RIVER_BASE_Z), 16.0, -2.0],
				["spot/gravy", Vector3(70.0, 0.0, BuffetLayout.RIVER_BASE_Z), 16.0, -2.0],
			]
		"final":  # the Capital (CapitalZone.ID)
			var result: Array = [
				["spot/fountain", Vector3(CapitalLayout.PLAZA_CENTER.x, 1.0, CapitalLayout.PLAZA_CENTER.y), 18.0, -2.0],
				["spot/rift_hum", Vector3(CapitalLayout.CASTLE.x, 6.0, CapitalLayout.CASTLE.z + 18.0), 40.0, 0.0],
			]
			for crystal: Vector2 in CapitalLayout.RIFT_CRYSTALS:
				result.append(["spot/rift_hum", Vector3(crystal.x, 1.5, crystal.y), 18.0, -4.0])
			return result
	return []


## Adds a zone's landmark loops under `parent`.
static func add_emitters(parent: Node3D, zone_id: String) -> void:
	for entry: Array in emitters(zone_id):
		parent.add_child(AmbientEmitter.make(str(entry[0]), entry[1] as Vector3, float(entry[2]), float(entry[3])))
