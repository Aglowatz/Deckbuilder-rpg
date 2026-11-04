extends GutTest
## Fix pass Nov 4 (Part 4.2): every hidden chest is 25% bigger (ChestKit.SCALE), with a matching solid footprint and reach. A bigger chest must
## not sink into a wall or close a path: round every chest of every zone the ground just outside its new footprint is open on at least one side
## (the hero can walk up to it). test_walkability_zones.gd still floods every zone to every chest and key place with the new footprints.

const ZONES: Array[String] = ["dna", "gainlands", "buffet", "heap", "capital"]
## How far round the chest the open ground is sampled (the model's half-diagonal at the new scale, plus a little).
const RING: float = 0.42
const BODY: float = 0.25


func _zone(zone_id: String) -> ZoneMap:
	var helper: GutTest = load("res://tests/world/test_walkability_zones.gd").new() as GutTest
	var zone_map: ZoneMap = helper._make_zone(zone_id)
	helper.free()
	return zone_map


func test_the_chest_is_25_percent_bigger_everywhere() -> void:
	assert_almost_eq(ChestKit.SCALE, 0.225 * 1.25, 0.0001)
	assert_almost_eq(ChestKit.FOOTPRINT, 0.18 * 1.25, 0.0001)
	assert_gt(ChestKit.REACH, 1.5, "the reach grew with the chest")
	for path: String in ["res://world/buffet/buffet_builder.gd", "res://world/capital/capital_builder.gd", "res://world/dna/dna_builder.gd",
			"res://world/gainlands/gainlands_builder.gd", "res://world/heap/heap_builder.gd", "res://world/starting_area_builder.gd", "res://world/town_builder.gd"]:
		var source: String = FileAccess.get_file_as_string(path)
		assert_true(source.contains("ChestKit.SCALE"), "%s builds its chests at ChestKit.SCALE" % path)


func test_every_zone_chest_has_open_ground_beside_it() -> void:
	for zone_id: String in ZONES:
		var zone_map: ZoneMap = _zone(zone_id)
		var chests: Dictionary = zone_map.chest_positions()
		assert_gt(chests.size(), 0, zone_id)
		for id: Variant in chests.keys():
			var pos: Vector3 = chests[id] as Vector3
			var open_sides: int = 0
			for step: int in range(12):
				var angle: float = TAU * float(step) / 12.0
				var probe: Vector3 = pos + Vector3(cos(angle), 0.0, sin(angle)) * (RING + BODY)
				if zone_map.is_walkable(probe, BODY):
					open_sides += 1
			assert_gte(open_sides, 2, "%s chest %s: the hero can stand beside it" % [zone_id, str(id)])


## Fix pass Nov 4 (Part 4.4): the Potato Peak's three decorative pie-crust "biscuit bridges" (the stair to nowhere by the Cheddar Cliffs) are gone,
## and the Peak still builds (its pool, streams and trees stay).
func test_the_potato_peak_has_no_stair_to_nowhere() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/buffet/buffet_landmarks.gd")
	var start: int = source.find("static func _potato_peak(")
	var end: int = source.find("static func _peak_height(")
	assert_gt(start, 0)
	assert_false(source.substr(start, end - start).contains("for bridge"), "no biscuit bridges round the Peak's pool")
	var peak: Node3D = BuffetLandmarks.build({"id": "BUFF-HERO-POTATO-PEAK", "size": [36.0, 22.0, 36.0]})
	assert_not_null(peak)
	if peak != null:
		peak.free()
