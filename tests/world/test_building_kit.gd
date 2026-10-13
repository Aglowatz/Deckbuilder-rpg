extends GutTest
## Vertical slice, Part A: the Environment Kit registry and the modular building kit.

const SHEET_IDS: Array[String] = [
	"ENV-WALL-TIMBER", "ENV-WALL-TIMBER-WARM", "ENV-WALL-PLANK", "ENV-WALL-FOUNDATION", "ENV-ROOF-EAVE", "ENV-BEAM", "ENV-AWNING-01", "ENV-AWNING-02",
	"ENV-DOOR-01", "ENV-DOOR-02", "ENV-DOOR-03", "ENV-WINDOW-01", "ENV-WINDOW-02", "ENV-WINDOW-03", "ENV-WINDOW-04", "ENV-WINDOW-05",
	"ENV-SIGN-CARDS", "ENV-SIGN-POTION", "ENV-SIGN-SHIELD", "ENV-SIGN-NEEDLE", "ENV-SIGN-PACK", "ENV-SIGN-FLASK", "ENV-SIGN-INN", "ENV-SIGNPOST",
	"ENV-GROUND-DIRTPATH", "ENV-GROUND-COBBLE", "ENV-GROUND-GRASS-CALM", "DEC-PATHEDGE", "DEC-WORNPATCH", "DEC-IVY", "DEC-WALLSTAIN",
	"ENV-TREE-OAK", "ENV-TREE-FRUIT", "ENV-TREE-PINE", "ENV-TREE-BIRCH", "ENV-HEDGE",
	"ENV-PROP-BARREL", "ENV-PROP-CRATE", "ENV-PROP-SACK", "ENV-PROP-FENCE", "ENV-PROP-FENCE-RAIL", "ENV-PROP-CANVAS", "ENV-PROP-CLOTHGOODS", "ENV-PROP-FLOWERPOTS", "ENV-PROP-LANTERN",
	"ENV-PROP-WELL", "ENV-PROP-STALL", "ENV-PROP-CART",
]


func test_every_sheet_id_has_a_slot_and_a_placeholder() -> void:
	for id: String in SHEET_IDS:
		assert_true(EnvKit.has(id), "%s is in the kit data" % id)
		assert_ne(EnvKit.slot(id), "", "%s has a slot" % id)
		assert_ne(str(EnvKit.entry(id).get("placeholder", "")), "", "%s names a placeholder" % id)
		assert_ne(str(EnvKit.entry(id).get("desc", "")), "", "%s has the sheet description" % id)


func test_slots_are_unique() -> void:
	var seen: Dictionary = {}
	for id: String in EnvKit.ids():
		var slot: String = EnvKit.slot(id)
		assert_false(seen.has(slot), "slot %s is used once" % slot)
		seen[slot] = id


func test_placeholders_resolve_to_textures() -> void:
	for id: String in EnvKit.ids():
		var generator: String = EnvKit.generator(id)
		if generator.begins_with("window_"):
			continue  # the window styles are geometry, not a picture
		assert_not_null(EnvKit.texture(id), "%s has a placeholder texture" % id)


func test_status_follows_the_art_file() -> void:
	assert_eq(EnvKit.status("ENV-WALL-TIMBER"), "art" if EnvKit.art_path("ENV-WALL-TIMBER") != "" else "placeholder")
	assert_eq(EnvKit.status("ENV-NOPE"), "unknown")


func test_material_uses_metre_uvs_and_is_cached() -> void:
	var a: StandardMaterial3D = EnvKit.material("ENV-WALL-TIMBER")
	var b: StandardMaterial3D = EnvKit.material("ENV-WALL-TIMBER")
	assert_same(a, b)
	assert_almost_eq(a.uv1_scale.x, 1.0 / EnvKit.tile_size("ENV-WALL-TIMBER"), 0.001)
	var cut: StandardMaterial3D = EnvKit.material("ENV-SIGN-CARDS", true)
	assert_eq(cut.transparency, BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR)


func test_every_preset_builds_with_the_right_parts() -> void:
	var names: Array[String] = BuildingPresets.names()
	assert_gte(names.size(), 10)
	for preset_name: String in ["home_a", "home_b", "inn", "card_shop", "potion_shop", "equipment_shop", "clothing_shop", "pack_shop", "alchemist"]:
		assert_true(BuildingPresets.has(preset_name), "preset %s" % preset_name)
	for preset_name: String in names:
		var building: Node3D = BuildingPresets.build(preset_name)
		add_child_autofree(building)
		var body: MeshInstance3D = building.get_node("Body") as MeshInstance3D
		assert_not_null(body.mesh, "%s has a mesh" % preset_name)
		assert_gt(body.mesh.get_surface_count(), 5, "%s has material slots" % preset_name)
		assert_gt(int(building.get_meta("triangles")), 200, "%s has real geometry" % preset_name)
		assert_lt(int(building.get_meta("triangles")), 10000, "%s stays light" % preset_name)
		assert_gt(float(building.get_meta("height")), 5.0, "%s towers over the hero" % preset_name)


func test_preset_ids_are_all_in_the_kit() -> void:
	for preset_name: String in BuildingPresets.names():
		for id: String in BuildingPresets.kit_ids(preset_name):
			assert_true(EnvKit.has(id), "%s of %s is a kit id" % [id, preset_name])


func test_scale_rule_hero_reaches_a_third_of_a_door() -> void:
	var hero: float = 1.25
	var ratio: float = hero / BuildingKit.DOOR_H
	assert_between(ratio, 0.3, 0.42, "the hero reaches about a third of the door")


func test_overrides_change_the_building() -> void:
	var small: Node3D = BuildingPresets.build("home_a", {"width": 5.0, "floors": 1})
	var big: Node3D = BuildingPresets.build("home_a")
	add_child_autofree(small)
	add_child_autofree(big)
	assert_lt((small.get_meta("footprint") as Vector2).x, (big.get_meta("footprint") as Vector2).x)
	assert_lt(float(small.get_meta("height")), float(big.get_meta("height")))


func test_roof_styles_all_build() -> void:
	for style: String in ["gable", "hip", "thatch", "spire"]:
		for front: bool in [false, true]:
			var roof: Dictionary = {"style": style, "pitch": 40, "overhang": 0.7, "material": "ENV-ROOF-TILE-RED", "gable_front": front}
			var node: Node3D = BuildingPresets.build("home_a", {"roof": roof})
			add_child_autofree(node)
			assert_gt(float(node.get_meta("height")), 4.0, "%s roof (front %s)" % [style, str(front)])


func test_obstacle_circles_cover_the_footprint() -> void:
	var circles: Array[Vector3] = BuildingKit.obstacle_circles({"width": 10.0, "depth": 6.0})
	assert_gte(circles.size(), 2)
	for circle: Vector3 in circles:
		assert_almost_eq(circle.z, 3.0, 0.001)
	assert_lte(absf(circles[0].x), 7.0)
