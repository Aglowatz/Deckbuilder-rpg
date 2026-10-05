extends GutTest
## The hand-dressed Gainlands: placed only on walkable ground, away from anchors, within a sane count.


func test_dressing_is_walkable_clear_and_scaled_by_quality() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var high: GainlandsDressing = GainlandsDressing.build(host, builder, GraphicsQuality.Level.HIGH)
	assert_gt(high.count, 20, "the hub is dressed")
	assert_lt(high.count, 90, "but not cluttered")
	for child: Node in high.root.get_children():
		var pos: Vector3 = (child as Node3D).position
		assert_gt(Vector2(pos.x - builder.anchor("hub").x, pos.z - builder.anchor("hub").z).length(), 3.0, "the hub itself stays open")
		for key: String in ["spawn", "tony", "brenda", "gus", "exit"]:
			assert_gt(Vector2(pos.x - builder.anchor(key).x, pos.z - builder.anchor(key).z).length(), 3.0, "clear of %s" % key)
	var low: GainlandsDressing = GainlandsDressing.build(host, builder, GraphicsQuality.Level.LOW)
	assert_lt(low.count, high.count, "less on Low")
