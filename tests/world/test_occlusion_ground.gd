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
