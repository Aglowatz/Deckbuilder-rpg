extends GutTest
## Brief 16, Group D: every zone passageway leads onto land (a bridge to a themed landmass) and shows only its destination name.

const EXPECTED: Dictionary = {
	"beefcake": "The Gainlands",
	"necrocrat": "The Department of Necrotic Affairs",
	"gourmand": "The Endless Buffet",
	"refusemancer": "The Verdant Dump",
	"final": "The Capital",
}


func test_each_passageway_is_labelled_with_only_its_destination() -> void:
	var seen: int = 0
	for info: ZonePortals.Info in ZonePortals.all():
		assert_eq(info.display_name, str(EXPECTED[info.id]), info.id)
		assert_false(info.display_name.contains("Path"), "no old 'Path' names: %s" % info.display_name)
		assert_false(info.display_name.contains("Heap"), "no old 'Heap' names: %s" % info.display_name)
		seen += 1
	assert_eq(seen, 5)


func test_the_zone_exit_labels_do_not_use_the_old_path_names() -> void:
	for zone_id: String in ["beefcake", "gourmand", "refusemancer"]:
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		for spot: Dictionary in def.spots:
			assert_false(str(spot.get("title", "")).contains("Path"), "%s spot %s" % [zone_id, str(spot.get("id", ""))])


func test_every_island_stands_in_the_water_and_the_bridge_starts_at_the_mouth() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root, false)
	for zone_id: String in TownBuilder.PORTAL_CELLS.keys():
		var plan: Dictionary = town._connector_plans[zone_id] as Dictionary
		var mouth: Vector3 = town.anchors["portal_%s_mouth" % zone_id] as Vector3
		var center: Vector3 = plan["center"] as Vector3
		var distance: float = Vector2(center.x - mouth.x, center.z - mouth.z).length()
		assert_between(distance, 16.0, 26.0, "%s: a distant landmass" % zone_id)
		assert_eq((plan["cells"] as Array).size(), 19, "%s: a 19-cell island" % zone_id)
		for cell: Variant in plan["cells"] as Array:
			var c: Vector2i = cell as Vector2i
			var map_row: int = c.y + TownBuilder.ROW_OFFSET
			var map_col: int = c.x + TownBuilder.COL_OFFSET
			var on_town: bool = map_row >= 0 and map_row < TownBuilder.MAP.size() and map_col >= 0 and map_col < TownBuilder.MAP[0].length() and TownBuilder.MAP[map_row][map_col] != "."
			assert_false(on_town, "%s: island cell %s is open water, not town land" % [zone_id, str(c)])
		assert_not_null(root.find_child("Connector_%s" % zone_id, true, false), "%s: connector built" % zone_id)
		assert_not_null(root.find_child("Bridge", true, false))
		assert_false(town.walkable.has((plan["cells"] as Array)[0] as Vector2i), "visual only: the island is not walkable")
