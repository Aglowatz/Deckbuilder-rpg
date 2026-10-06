extends GutTest
## ScatterTool: deterministic output, keep-outs and lanes respected, clusters of three, per-set report.


func _tool() -> ScatterTool:
	var tool: ScatterTool = ScatterTool.new()
	tool.seed_value = 42
	tool.bounds = Rect2(-30, -30, 60, 60)
	return tool


func _entries() -> Array[ScatterTool.Entry]:
	var entries: Array[ScatterTool.Entry] = []
	entries.append(ScatterTool.Entry.make("kit/", "rock", 2.0, 1.0, 1.4))
	entries.append(ScatterTool.Entry.make("kit/", "bush", 1.0, 0.8, 1.2, 0.1, 0.4))
	return entries


func _signature(placements: Array[ScatterTool.Placement]) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for placement: ScatterTool.Placement in placements:
		parts.append("%s@%.3f,%.3f,%.3f" % [placement.model, placement.position.x, placement.position.z, placement.scale])
	return ",".join(parts)


func test_same_seed_gives_same_placements() -> void:
	var first: Array[ScatterTool.Placement] = _tool().scatter("rocks", _entries(), 40)
	var second: Array[ScatterTool.Placement] = _tool().scatter("rocks", _entries(), 40)
	assert_eq(first.size(), 40)
	assert_eq(_signature(first), _signature(second))
	var other: ScatterTool = _tool()
	other.seed_value = 43
	assert_ne(_signature(first), _signature(other.scatter("rocks", _entries(), 40)))


func test_keep_out_circle_and_polygon_stay_empty() -> void:
	var tool: ScatterTool = _tool()
	tool.keep_out_circles.append(Vector3(0.0, 0.0, 8.0))
	tool.keep_out_polygons.append(PackedVector2Array([Vector2(10, 10), Vector2(20, 10), Vector2(20, 20), Vector2(10, 20)]))
	for placement: ScatterTool.Placement in tool.scatter("rocks", _entries(), 200):
		assert_true(Vector2(placement.position.x, placement.position.z).length() >= 8.0, "outside the circle")
		assert_false(Geometry2D.is_point_in_polygon(Vector2(placement.position.x, placement.position.z), tool.keep_out_polygons[0]), "outside the polygon")


func test_lanes_stay_clear_and_path_edge_hugs_them() -> void:
	var tool: ScatterTool = _tool()
	tool.lane_half_width = 1.0
	var lane: PackedVector2Array = PackedVector2Array([Vector2(-25, 0), Vector2(25, 0)])
	tool.lanes.append(lane)
	var placed: Array[ScatterTool.Placement] = tool.scatter("edge", _entries(), 120, 3, 1.0, 0.8)
	var near: int = 0
	for placement: ScatterTool.Placement in placed:
		var distance: float = absf(placement.position.z)
		assert_true(distance >= 1.0, "nothing on the lane")
		if distance < 3.0:
			near += 1
	assert_gt(near, placed.size() / 2, "most props hug the path edge")


func test_clusters_are_big_medium_small_and_report_counts() -> void:
	var tool: ScatterTool = _tool()
	var placed: Array[ScatterTool.Placement] = tool.scatter("rocks", _entries(), 30, 3, 1.0)
	var roles: Dictionary = {}
	for placement: ScatterTool.Placement in placed:
		roles[placement.role] = int(roles.get(placement.role, 0)) + 1
	assert_true(roles.has(0) and roles.has(1) and roles.has(2), "all three roles used")
	assert_eq(int(tool.report().get("rocks", 0)), placed.size())


func test_floor_callable_and_blockers() -> void:
	var tool: ScatterTool = _tool()
	tool.is_floor = func(pos: Vector3) -> bool: return pos.x > 0.0
	var bushes: Array[ScatterTool.Entry] = [ScatterTool.Entry.make("kit/", "bush", 1.0, 1.0, 1.0, 0.0, 0.5)]
	var placed: Array[ScatterTool.Placement] = tool.scatter("bushes", bushes, 20)
	for placement: ScatterTool.Placement in placed:
		assert_true(placement.position.x > 0.0)
	assert_eq(tool.blockers.size(), placed.size())
