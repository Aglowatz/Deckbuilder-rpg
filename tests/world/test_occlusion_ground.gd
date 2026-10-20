extends GutTest
## Overnight Oct 17 (Phase 2 cycle 3): wide terrain never fades with the group of a blocking prop (the starting forest floor went 88% see-through).


func test_wide_floor_is_ground_and_props_are_not() -> void:
	var floor_mesh: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(900.0, 900.0)
	floor_mesh.mesh = plane
	var prop: MeshInstance3D = MeshInstance3D.new()
	prop.mesh = BoxMesh.new()
	add_child_autofree(floor_mesh)
	add_child_autofree(prop)
	assert_true(OcclusionFader._is_ground(floor_mesh))
	assert_false(OcclusionFader._is_ground(prop))


## Overnight Oct 19 (Part 1): a thin piece hanging over the hero's ground (a pennant line across an entrance) blocks the view and qualifies; ground clutter,
## small pieces and tall pieces (handled by the normal height rule) do not count as overhead.
func test_overhead_pieces_qualify_and_ground_clutter_does_not() -> void:
	assert_true(OcclusionFader.is_overhead(AABB(Vector3(-3, 2.6, 0.4), Vector3(6, 0.8, 0.1)), 0.0), "a pennant line across a bridge")
	assert_false(OcclusionFader.is_overhead(AABB(Vector3(-3, 0.0, 0.0), Vector3(6, 0.1, 3)), 0.0), "a rug")
	assert_false(OcclusionFader.is_overhead(AABB(Vector3(0, 2.6, 0), Vector3(0.4, 0.4, 0.4)), 0.0), "a small lantern")
	assert_false(OcclusionFader.is_overhead(AABB(Vector3(-3, 6.6, 0.4), Vector3(6, 0.8, 0.1)), 5.6), "the same line at the hero's knees on a terrace")
	assert_false(OcclusionFader.is_overhead(AABB(Vector3(-3, 2.0, 0), Vector3(6, 3.0, 1)), 0.0), "a tall piece uses the normal rule")


func test_entrance_bunting_fades_on_its_own() -> void:
	for bridge: Node3D in [BuffetLandmarks.entrance_bridge(10.0, 4.0), HeapLandmarks.entrance_bridge(10.0, 4.0)]:
		add_child_autofree(bridge)
		var bunting: MeshInstance3D = bridge.get_node_or_null("Bunting") as MeshInstance3D
		assert_not_null(bunting, "the bunting is its own mesh")
		if bunting != null:
			assert_true(bunting.has_meta(&"occlusion_overhead"))
			assert_false(bunting.has_meta(&"no_occlusion_fade"))
