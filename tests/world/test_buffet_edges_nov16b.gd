extends GutTest
## Fable Nov 16b (Part 5): the Endless Buffet's edges - the gravy lies all round the table just under the painted ground (no slab side,
## no step), a short wet shore runs under it, and east of the table the land goes on as a food forest nobody can walk into, with steam,
## butterflies, birds and light patches on Medium and High and none of them on Low.

var _quality: int = 0


func before_all() -> void:
	_quality = Settings.graphics_quality


func after_each() -> void:
	Settings.graphics_quality = _quality


func _built(quality: int) -> BuffetBuilder:
	Settings.graphics_quality = quality
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.build(host)
	return builder


func test_the_gravy_stands_just_under_the_ground_all_round() -> void:
	assert_lt(BuffetShore.WATER_Y, BuffetLayout.SOUP_LEVEL, "a finger under the river's own surface: one sheet")
	assert_gt(BuffetShore.WATER_Y, BuffetLayout.SOUP_LEVEL - 0.1)
	assert_gt(BuffetShore.WATER_Y, -0.6, "above the top of the table's cake rim: no slab side shows (the moat lay at -2.6)")
	var builder: BuffetBuilder = _built(GraphicsQuality.Level.MEDIUM)
	var sea: MeshInstance3D = builder.root.find_child("GravySea", false, false) as MeshInstance3D
	assert_not_null(sea, "the gravy is one sheet round the whole table")
	assert_null(builder.root.find_child("GravyMoat", false, false), "the south-only moat is gone")
	assert_null(builder.root.find_child("SouthBank", false, false), "and the stepped bank with it")
	var box: AABB = sea.get_aabb()
	assert_lt(box.position.x, BuffetLayout.MIN_CORNER.x - 100.0, "it reaches far west")
	assert_gt(box.end.x, BuffetLayout.MAX_CORNER.x + 100.0, "far east")
	assert_lt(box.position.z, BuffetLayout.MIN_CORNER.y - 100.0, "far north")
	assert_gt(box.end.z, BuffetLayout.MAX_CORNER.y + 100.0, "and far south")
	assert_almost_eq(box.position.y, BuffetShore.WATER_Y, 0.001)
	assert_true(sea.material_override is ShaderMaterial, "on the shared water shader")
	assert_eq((sea.material_override as ShaderMaterial).shader, (StyleWater.material() as ShaderMaterial).shader)
	# The ground at the table's edge is never more than a step above the gravy.
	var worst: float = 0.0
	for x: float in [20.0, 35.0, 50.0, 65.0, 80.0]:
		worst = maxf(worst, builder.layout.ground_height(x, BuffetLayout.MAX_CORNER.y - 0.6) - BuffetShore.WATER_Y)
	assert_lt(worst, 0.7, "the south edge stands %.2f m over the gravy at most (it was 2.2 m and more)" % worst)


func test_a_wet_shore_runs_under_the_gravy_with_pebbles_and_crumbs() -> void:
	var builder: BuffetBuilder = _built(GraphicsQuality.Level.MEDIUM)
	var shore: MeshInstance3D = builder.root.find_child("Shore", false, false) as MeshInstance3D
	assert_not_null(shore)
	var box: AABB = shore.get_aabb()
	assert_lt(box.position.y, BuffetShore.WATER_Y - 1.0, "the shore ends well under the gravy")
	assert_gt(box.size.x, BuffetLayout.MAX_CORNER.x - BuffetLayout.MIN_CORNER.x, "it runs round the table")
	assert_gt(BuffetShore.SHORE_RINGS[1].y, BuffetShore.WATER_Y, "its first ring is still above the water line (the wet band)")
	assert_lt(BuffetShore.SHORE_RINGS[2].y, BuffetShore.WATER_Y, "its second is under it")
	for node_name: String in ["ShorePebbles", "ShoreCrumbs"]:
		var field: MultiMeshInstance3D = builder.root.find_child(node_name, false, false) as MultiMeshInstance3D
		assert_not_null(field, node_name)
		assert_gt(field.multimesh.instance_count, 30, "%s along the water line" % node_name)


func test_the_east_side_is_a_food_forest_nobody_walks_into() -> void:
	var builder: BuffetBuilder = _built(GraphicsQuality.Level.MEDIUM)
	var shore: BuffetShore = builder.shore
	assert_not_null(shore)
	assert_gt(shore.trees.size(), 500, "a dense forest (%d trees)" % shore.trees.size())
	var front: int = 0
	var deep: int = 0
	var farthest: float = 0.0
	for tree: Vector3 in shore.trees:
		assert_lt(BuffetLayout.edge_distance(tree.x, tree.z), 0.0, "every tree stands outside the table: nothing on it is hidden behind one")
		assert_true(BuffetShore.on_land(tree.x, tree.z), "on the forest's land, not in the gravy")
		assert_gt(absf(tree.z - BuffetLayout.river_z(tree.x)), BuffetShore.CHANNEL_HALF, "not in the river's channel")
		var away: float = BuffetShore.from_table(tree.x, tree.z)
		farthest = maxf(farthest, away)
		if away < 4.0:
			front += 1
		elif away > 22.0:
			deep += 1
	assert_gt(front, 40, "a close front row along the table's edge")
	assert_gt(deep, 200, "layers behind it")
	assert_gt(farthest, 100.0, "to the horizon")
	# The walk grid is blocked: no step east of the table's edge can be stood on, nor any tree's place.
	var z: float = 6.0
	while z <= 74.0:
		assert_false(builder.is_walkable(Vector3(96.6, 0.0, z), 0.3), "nobody stands east of the edge at z %.0f" % z)
		z += 2.0
	for index: int in range(0, shore.trees.size(), 25):
		assert_false(builder.is_walkable(shore.trees[index], 0.3))
	# Both kinds of tree, the hem and the boulders are there, and the forest floor is the Buffet's painted crumb soil.
	for prefix: String in ["Forest_buff_broccoli_near", "Forest_buff_broccoli_far", "Forest_buff_cauli_far", "Forest_buff_herb", "Forest_buff_leek", "ForestBoulders_buff_cakestand"]:
		assert_not_null(builder.root.find_child(prefix, false, false), prefix)
	var floor_node: MeshInstance3D = builder.root.find_child("ForestFloor", false, false) as MeshInstance3D
	assert_not_null(floor_node)
	assert_eq((floor_node.material_override as StandardMaterial3D).albedo_texture, PaintedLibrary.albedo("buff_crumbsoil"), "painted, not a flat colour")
	var lowest: float = INF
	var highest: float = -INF
	for edge_z: float in [18.0, 22.0, 26.0, 30.0, 34.0, 52.0, 56.0, 60.0]:
		lowest = minf(lowest, builder.layout.ground_height(95.7, edge_z))
		highest = maxf(highest, builder.layout.ground_height(95.7, edge_z))
	assert_between(shore.land_y(), lowest - 0.1, highest, "the forest floor lies within the heights of the table's own east edge (%.2f .. %.2f): no drop to it" % [lowest, highest])
	assert_gt(shore.land_y(), BuffetShore.WATER_Y, "and above the gravy")


func test_the_river_runs_on_through_the_forest() -> void:
	assert_true(BuffetShore.on_land(110.0, 24.0))
	assert_true(BuffetShore.on_land(110.0, 62.0))
	assert_false(BuffetShore.on_land(110.0, BuffetLayout.river_z(110.0)), "the channel stays gravy")
	assert_false(BuffetShore.on_land(50.0, 40.0), "the table is not forest")
	assert_false(BuffetShore.on_land(50.0, 100.0), "nor the open gravy south of it")
	assert_false(BuffetShore.on_land(20.0, -30.0))


func test_it_lives_on_medium_and_not_on_low() -> void:
	var medium: BuffetBuilder = _built(GraphicsQuality.Level.MEDIUM)
	var life: BuffetForestLife = medium.shore.life
	assert_not_null(life, "Medium builds the forest's life")
	assert_eq(life.steam_count, BuffetShore.STEAM_SPOTS, "steam drifts up from the forest")
	assert_eq(life.patch_count, BuffetShore.LIGHT_PATCHES, "warm light patches on the floor")
	var fliers: Node3D = life.find_child("Fliers", false, false) as Node3D
	assert_not_null(fliers, "butterflies and birds")
	# Batch 17 (Nov 18): the painted fliers are one sprite each (BUFF-SHEET-FLIERS frames); the dot wings are the fallback
	if fliers is MultiMeshInstance3D:
		assert_eq((fliers as MultiMeshInstance3D).multimesh.instance_count, (BuffetForestLife.BUTTERFLIES + BuffetForestLife.BIRDS) * 2, "two wings each, one draw call for all")
	else:
		assert_eq(fliers.get_child_count(), BuffetForestLife.BUTTERFLIES + BuffetForestLife.BIRDS, "one painted sprite per flier")
	assert_eq(life.flier_count(), BuffetForestLife.BUTTERFLIES + BuffetForestLife.BIRDS)
	var before: Vector3 = life.flier_at(0)
	life._process(0.4)
	assert_gt(life.flier_at(0).distance_to(before), 0.05, "they move")
	assert_true(BuffetShore.on_land(before.x, before.z) or BuffetShore.from_table(before.x, before.z) > 0.0, "over the forest, not over the table")
	for child: Node in life.get_children():
		if child is CPUParticles3D:
			assert_true(BuffetShore.on_land((child as Node3D).position.x, (child as Node3D).position.z), "the steam rises from the forest")
	# The leaves sway: the tree cards use the wind card shader with its sway on.
	var trees: MultiMeshInstance3D = medium.root.find_child("Forest_buff_broccoli_far", false, false) as MultiMeshInstance3D
	var sway: Variant = (trees.material_override as ShaderMaterial).get_shader_parameter("sway")
	assert_true(sway == null or float(sway) > 0.0, "the sway is not switched off (null = the shader's own default)")
	var low: BuffetBuilder = _built(GraphicsQuality.Level.LOW)
	assert_null(low.shore.life, "Low builds no steam, fliers or light patches")
	assert_null(low.root.find_child("ForestLife", false, false))
	assert_gt(low.shore.trees.size(), 500, "the forest itself stands on Low too")
