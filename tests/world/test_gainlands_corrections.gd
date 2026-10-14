extends GutTest
## The corrective pass on the Gainlands (docs/art/gainlands_corrections.md): the zone stays open and readable.
##  - half the trees, standing in groves and along the rim, never on a route;
##  - main routes at least 4 hero-widths wide with nothing solid inside their clearance, open ground round every anchor;
##  - few sign boards, each with a pictogram;
##  - the meadow never dips under the look rig's water plane;
##  - the sub-area data keeps the same limits (tree counts, path widths, flower clumps);
##  - the camera occlusion fade is a smooth transparency: tree cards fade in their own shader from the hero's position, the fader drives no dither.

var layout: GainlandsLayout


func before_each() -> void:
	layout = GainlandsLayout.new()
	layout.build()


func _main_land(kind: String) -> Array[GainlandsLayout.Prop]:
	var result: Array[GainlandsLayout.Prop] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind == kind and GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z):
			result.append(prop)
	return result


func test_half_the_trees_stand_in_groves_and_along_the_rim() -> void:
	var trees: Array[GainlandsLayout.Prop] = _main_land("tree")
	assert_lte(trees.size(), GainlandsLayout.TREE_COUNT, "no more than %d trees on the main land (was 150)" % GainlandsLayout.TREE_COUNT)
	assert_gte(trees.size(), 50, "still a wooded plateau")
	assert_lte(_main_land("boulder").size(), GainlandsLayout.ROCK_COUNT + 2, "a few rocks (plus the two gym boulders), not forty")
	var loners: int = 0
	for tree: GainlandsLayout.Prop in trees:
		var edge: float = GainlandsLayout.main_edge_distance(tree.pos.x, tree.pos.z)
		if edge <= GainlandsLayout.RIM_BAND.y + 0.5:
			continue
		var neighbours: int = 0
		for other: GainlandsLayout.Prop in trees:
			if other != tree and Vector2(other.pos.x - tree.pos.x, other.pos.z - tree.pos.z).length() < 9.0:
				neighbours += 1
		if neighbours < 2:
			loners += 1
	assert_lte(loners, 3, "inland trees stand in groups (deliberate groves), not scattered one by one: %d loners" % loners)


func test_routes_are_wide_and_nothing_solid_stands_on_them() -> void:
	var hub: Vector2 = Vector2(52.0, 62.0)
	for path: Dictionary in layout.paths:
		var width: float = float(path["width"])
		assert_gte(width, GainlandsLayout.SIDE_PATH_WIDTH, "every route is at least %.1f m wide" % GainlandsLayout.SIDE_PATH_WIDTH)
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		if line[0] == hub:
			assert_gte(width, GainlandsLayout.MAIN_PATH_WIDTH, "a road out of the hub is at least %.1f m wide (4 hero-widths)" % GainlandsLayout.MAIN_PATH_WIDTH)
	var on_route: Array[String] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind != "tree" and prop.kind != "boulder":
			continue
		if not GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z):
			continue
		if layout.path_edge_distance(prop.pos.x, prop.pos.z) < GainlandsLayout.PATH_CLEARANCE - 0.01:
			on_route.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	assert_eq(on_route, [] as Array[String], "no tree or rock within %.1f m of a path edge" % GainlandsLayout.PATH_CLEARANCE)


func test_open_ground_round_every_anchor_chest_and_sign() -> void:
	var crowded: Array[String] = []
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		for prop: GainlandsLayout.Prop in layout.props:
			if prop.kind != "tree" and prop.kind != "boulder":
				continue
			if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < GainlandsLayout.ANCHOR_CLEARANCE - 0.01:
				crowded.append("%s near %s" % [prop.kind, str(key)])
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		for prop: GainlandsLayout.Prop in layout.props:
			if (prop.kind == "tree" or prop.kind == "boulder") and Vector2(prop.pos.x - chest.x, prop.pos.z - chest.z).length() < 1.9:
				crowded.append("%s on chest %s" % [prop.kind, str(id)])
	assert_eq(crowded, [] as Array[String], "every NPC, travel point, gate and chest can be reached without weaving round trees")


func test_few_sign_boards_each_with_a_pictogram() -> void:
	assert_lte(layout.signs.size(), 10, "the boards that point somewhere or carry a quiz answer (was 30)")
	for sign: GainlandsLayout.Sign in layout.signs:
		assert_true(GainlandsBuilder.SIGN_ICONS.has(sign.key), "%s has an icon" % sign.key)
	var keys: Array[String] = []
	for sign: GainlandsLayout.Sign in layout.signs:
		keys.append(sign.key)
	for needed: String in ["sign.hub_power", "sign.ripper_rule", "sign.main_dungeon", "sign.exit"]:
		assert_has(keys, needed, "%s stays (a quiz answer or a direction)" % needed)


func test_the_meadow_never_dips_under_the_water() -> void:
	assert_gt(GainlandsLayout.MIN_GROUND, WorldScenery.WATER_Y, "the floor of the meadow is above the water plane")
	var lowest: float = 10.0
	var x: float = GainlandsLayout.CENTER.x - GainlandsLayout.RADII.x
	while x <= GainlandsLayout.CENTER.x + GainlandsLayout.RADII.x:
		var z: float = GainlandsLayout.CENTER.y - GainlandsLayout.RADII.y
		while z <= GainlandsLayout.CENTER.y + GainlandsLayout.RADII.y:
			if GainlandsLayout.is_main_ground(x, z):
				lowest = minf(lowest, layout.ground_height(x, z))
			z += 2.0
		x += 2.0
	assert_gte(lowest, GainlandsLayout.MIN_GROUND - 0.001, "no walkable cell below %.2f (lowest %.2f)" % [GainlandsLayout.MIN_GROUND, lowest])
	assert_gt(lowest, WorldScenery.WATER_Y, "the hero never wades")


func test_subarea_data_stays_open() -> void:
	for sub_id: String in SubAreaDefs.sub_ids("gainlands"):
		var data: Dictionary = SubAreaDefs.sub("gainlands", sub_id)
		var trees: int = 0
		for item: Variant in data.get("scatter", []) as Array:
			var entry: Dictionary = item as Dictionary
			if str(entry.get("kind", "")) == "tree" and str(entry.get("name", "")) != "sunflower" and str(entry.get("name", "")) != "hay":
				trees += int(entry.get("count", 0))
				assert_gte(float(entry.get("path_gap", 0.0)), 3.0, "%s: scattered %s stay %.1f m off the paths" % [sub_id, str(entry.get("name")), 3.0])
		assert_lte(trees, 12, "%s: at most 12 scattered trees (half the old count)" % sub_id)
		var paths: Array = data.get("paths", []) as Array
		assert_gte(float((paths[0] as Dictionary).get("width", 0.0)), 4.2, "%s: the main path is 4 hero-widths wide" % sub_id)
		for item: Variant in paths:
			assert_gte(float((item as Dictionary).get("width", 0.0)), 3.4, "%s: every path is at least 3.4 m wide" % sub_id)
		assert_gte(float((data.get("edge", {}) as Dictionary).get("spacing", 0.0)), 8.5, "%s: the edge belt is loose, not a fence" % sub_id)
		for item: Variant in data.get("flowers", []) as Array:
			assert_lte(int((item as Dictionary).get("count", 0)), 24, "%s: flowers in small clumps" % sub_id)
			assert_lte(float((item as Dictionary).get("radius", 0.0)), 3.5, "%s: flower clumps are small" % sub_id)


func test_tree_cards_fade_in_their_shader_from_the_hero_position() -> void:
	var card: MeshInstance3D = KitFoliage.card("ENV-TREE-OAK", Vector2(5.0, 5.0))
	autofree(card)
	assert_true(card.has_meta(&"no_occlusion_fade"), "the fader leaves tree cards alone (they fade themselves)")
	var shader_code: String = (load(KitFoliage.CARD_SHADER) as Shader).code
	assert_true(shader_code.contains("uniform vec3 hero_pos"), "the card shader knows where the hero is")
	assert_true(shader_code.contains("ALPHA = 1.0 - v_fade"), "and fades with plain alpha, not a dither")
	assert_false(shader_code.contains("BAYER"), "no ordered dither in the card shader")
	KitFoliage.set_hero(Vector3(12.0, 0.5, 34.0))
	var material: ShaderMaterial = card.material_override as ShaderMaterial
	assert_eq(material.get_shader_parameter("hero_pos"), Vector3(12.0, 0.5, 34.0), "set_hero reaches every card material")
	KitFoliage.set_hero(Vector3(0.0, -1000.0, 0.0))
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var field: MultiMeshInstance3D = KitFoliage.tree_field(host, "pine", [{"pos": Vector3.ZERO, "scale": 1.0}] as Array[Dictionary], false)
	assert_true(field.has_meta(&"no_occlusion_fade"), "tree fields opt out of the fader too")


func test_the_occlusion_fader_uses_a_smooth_transparency() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/style/occlusion_fader.gd")
	assert_false(source.contains("set_instance_shader_parameter(\"occlusion_fade\""), "the fader no longer drives the ordered dither")
	assert_true(source.contains("piece.transparency = "), "every faded piece uses the per-instance transparency")
	assert_true(source.contains("KitFoliage.set_hero("), "the fader feeds the hero position to the tree cards")


func test_terrain_and_islands_never_dissolve() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var land: Node = builder.root.find_child("MainLand", false, false)
	assert_not_null(land)
	assert_true(land.has_meta(&"no_occlusion_fade"), "the plateau is never faded by the camera")
	for island: GainlandsLayout.Island in layout.islands:
		var node: Node = builder.root.find_child("Island_" + island.id, false, false)
		assert_true(node != null and node.has_meta(&"no_occlusion_fade"), "%s never dithers when the camera passes near it" % island.id)
	for cloud: Node3D in builder.cloud_nodes():
		assert_lt(cloud.position.y, -8.0, "no cloud can poke up through the meadow")
