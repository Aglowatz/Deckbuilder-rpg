extends GutTest
## Fix pass Nov 4 (B), Part 2.5: natural zone edges. CliffSkirt (the Gainlands' layered ragged cliff as a strip) builds the Crosspath gorge's walls;
## the Verdant Dump's valley walls rise in courses with ledges between them.


func test_a_cliff_skirt_is_a_ragged_layered_wall_down_to_its_bottom() -> void:
	var line: PackedVector2Array = PackedVector2Array([Vector2(0, 0), Vector2(20, 0)])
	var wall: MeshInstance3D = CliffSkirt.wall(line, 0.0, -9.0, 1.0, "Probe", Color.WHITE, Color.GRAY)
	add_child_autofree(wall)
	var aabb: AABB = wall.mesh.get_aabb()
	assert_almost_eq(aabb.position.y, -9.0, 0.6, "down to the bottom")
	assert_almost_eq(aabb.end.y, 0.0, 0.3, "from the lip")
	assert_gt(aabb.size.z, 0.8, "its courses lean out (not a flat quad)")
	assert_true(wall.material_override is ShaderMaterial, "the shared terrain material, so the zone's painted cliff applies")


func test_the_dump_valley_walls_have_ledges() -> void:
	# along a line out from the rim the rise has flat stretches (ledges) between steep courses, and still reaches the old 6.5 m
	var slopes: Array[float] = []
	for k: int in range(0, 70):
		var out: float = float(k) * 0.1
		slopes.append(HeapLayout.wall_rise(0.0, 0.0, out + 0.1) - HeapLayout.wall_rise(0.0, 0.0, out))
	var flat: int = 0
	for slope: float in slopes:
		if slope < 0.02:
			flat += 1
	assert_gt(flat, 15, "ledges between the courses")
	assert_almost_eq(HeapLayout.wall_rise(0.0, 0.0, 9.0), 6.5, 0.05, "the full wall height")
