extends GutTest
## Overnight Nov 10-11 (owner decision 2, inbox 10 of Nov 10): Billie's herd can be rounded up before the first crossing - every escaped
## animal grazes on the Compost Commons side of the stream (south of it), on walkable ground.


func test_every_herd_animal_grazes_on_the_commons_side() -> void:
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	for name: String in ["animal_1", "animal_2", "animal_3"]:
		assert_true(builder.has_anchor(name), name)
		var at: Vector3 = builder.anchor(name)
		var stream: float = HeapLayout.stream_z(at.x)
		assert_gt(at.z, stream + 4.0, "%s (%.1f, %.1f) stands south of the stream (z %.1f) on the Commons" % [name, at.x, at.z, stream])
		assert_true(builder.is_walkable(at, 0.4), "%s stands on walkable ground" % name)
		assert_eq(builder.layout.surface_at(at.x, at.z) == HeapLayout.Surface.HAZARD, false, "%s is not in the water" % name)
