extends GutTest
## Overnight Oct 17 (Phase 2 cycle 18): paperwork drifts over the D.N.A.'s bare apron, never over an office floor or the approach causeway.


func test_sheets_stay_off_floors_and_the_causeway() -> void:
	var layout: DnaLayout = DnaLayout.new()
	layout.build()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7341
	var spots: Array[Vector3] = DnaPaperDrift.positions(layout, 120, rng)
	assert_gt(spots.size(), 60, "most sheets find a place")
	for index: int in range(spots.size()):
		var pos: Vector3 = spots[index]
		var cell: Vector2i = DnaLayout.world_to_cell(pos)
		assert_false(layout.in_bounds(cell.x, cell.y) and layout.is_floor(cell.x, cell.y), "sheet %d is not over a floor" % index)
		assert_false(DnaLayout.on_approach(pos.x, pos.z), "sheet %d is not over the causeway" % index)
		assert_between(pos.y, DnaPaperDrift.DEPTH.x, DnaPaperDrift.DEPTH.y)


func test_the_field_builds() -> void:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var field: MultiMeshInstance3D = DnaPaperDrift.build(holder, null, 40)
	assert_eq(field.multimesh.instance_count, 40)
	assert_eq(field.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
