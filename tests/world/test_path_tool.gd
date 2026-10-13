extends GutTest
## Vertical slice, Part C: the path tool, the cobbled square and the calm town ground.


func _control() -> Array[Vector3]:
	return [Vector3(0, 0, 0), Vector3(6, 0, 2), Vector3(12, 0, 0), Vector3(18, 0, -4)] as Array[Vector3]


func test_smooth_passes_through_the_control_points_and_adds_samples() -> void:
	var control: Array[Vector3] = _control()
	var points: Array[Vector3] = PathTool.smooth(control, 0.7)
	assert_gt(points.size(), 30, "a curve is sampled finely")
	assert_eq(points[0], control[0])
	assert_eq(points[points.size() - 1], control[control.size() - 1])
	for point: Vector3 in control:
		var nearest: float = 99.0
		for sample: Vector3 in points:
			nearest = minf(nearest, sample.distance_to(point))
		assert_lt(nearest, 0.4, "the curve goes through every control point")


func test_a_path_has_surface_edges_and_irregular_clumps() -> void:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var path: Node3D = PathTool.build(holder, _control(), {"width": 3.0, "kind": "dirt", "seed": 4})
	assert_not_null(path.get_node_or_null("Surface"))
	assert_not_null(path.get_node_or_null("Edge_L"))
	assert_not_null(path.get_node_or_null("Edge_R"))
	var clumps: Array = path.get_meta("clumps") as Array
	assert_gt(clumps.size(), 4, "grass and flowers along the edges")
	# never evenly spaced: the gaps between consecutive clumps on one side vary
	var gaps: Dictionary = {}
	var last: Vector3 = (clumps[0] as Dictionary)["pos"] as Vector3
	for index: int in range(1, mini(clumps.size(), 12)):
		var pos: Vector3 = (clumps[index] as Dictionary)["pos"] as Vector3
		gaps[snappedf(pos.distance_to(last), 0.5)] = true
		last = pos
	assert_gt(gaps.size(), 3, "irregular spacing")


func test_path_materials_use_the_kit_ground_slots() -> void:
	var dirt: ShaderMaterial = PathTool.surface_material("dirt")
	var cobble: ShaderMaterial = PathTool.surface_material("cobble")
	assert_not_null(dirt.get_shader_parameter("surface_tex"))
	assert_ne(dirt.get_shader_parameter("surface_tex"), cobble.get_shader_parameter("surface_tex"))
	var edge: ShaderMaterial = PathTool.edge_material("dirt")
	assert_not_null(edge.get_shader_parameter("edge_tex"), "DEC-PATHEDGE placeholder")


func test_path_stops_at_the_shore() -> void:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var land: Callable = func(p: Vector3) -> bool: return p.x < 9.0
	var path: Node3D = PathTool.build(holder, _control(), {"is_floor": land})
	for point: Vector3 in path.get_meta("points") as Array[Vector3]:
		assert_lt(point.x, 9.0)


func test_plaza_builds_with_a_soft_fringe() -> void:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var plaza: Node3D = PathTool.plaza(holder, Vector3(5, 0, 5), 6.0)
	assert_not_null(plaza.get_node_or_null("Cobbles"))
	assert_not_null(plaza.get_node_or_null("Fringe"))


func test_the_town_roads_are_paths_and_the_ground_is_calm() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root, false)
	var square: TownSquare = TownSquare.build(root, town, GraphicsQuality.Level.MEDIUM)
	assert_eq(square.streets.paths.size(), TownLayout.roads().size(), "one PathTool path per road")
	assert_not_null(square.streets.plaza_node)
	var kinds: Dictionary = TownLayout.road_kinds()
	for id: String in TownLayout.roads().keys():
		assert_true(kinds.has(id), "%s has a surface kind" % id)
	var moss_discs: int = 0
	for child: Node in square.root.get_children():
		var instance: MeshInstance3D = child as MeshInstance3D
		if instance != null and instance.material_override is ShaderMaterial and int((instance.material_override as ShaderMaterial).get_shader_parameter("pattern")) == int(GroundDecals.Pattern.MOSS):
			moss_discs += 1
	assert_eq(moss_discs, 0, "no saturated moss patches on the ground any more")
