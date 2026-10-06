extends GutTest
## Polish round, Group C: the endless forest around the starting clearing (visual only, never in the clearing, scaled by quality).


func _cells() -> Array:
	var cells: Array = []
	for row: int in range(StartingAreaBuilder.MAP.size()):
		for col: int in range(StartingAreaBuilder.MAP[row].length()):
			cells.append(Vector2i(col, row))
	return cells


func _forest(quality: int) -> StartingForest:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var spawn: Vector3 = HexGrid.cell_to_world(2, 3)
	return StartingForest.build(host, _cells(), spawn, quality)


func test_three_layers_of_trees_surround_the_clearing() -> void:
	var forest: StartingForest = _forest(GraphicsQuality.Level.MEDIUM)
	assert_gt((forest.tree_points["near"] as Array).size(), 150, "a dense near forest")
	assert_gt((forest.tree_points["mid"] as Array).size(), 300, "a middle layer")
	assert_gt((forest.tree_points["far"] as Array).size(), 800, "a far tree line")


func test_the_forest_extends_far_beyond_the_playable_bounds_in_every_direction() -> void:
	var forest: StartingForest = _forest(GraphicsQuality.Level.MEDIUM)
	var reach: float = 0.0
	var quadrants: Dictionary = {}
	for p: Vector2 in forest.tree_points["far"] as Array:
		reach = maxf(reach, p.distance_to(forest.center))
		quadrants[Vector2i(int(signf(p.x - forest.center.x)), int(signf(p.y - forest.center.y)))] = true
	assert_gt(reach, 100.0, "trees out past 100 m, well beyond the clearing")
	assert_eq(quadrants.size(), 4, "trees in all four directions: no visible edge of the world")


func test_nothing_grows_inside_the_clearing() -> void:
	var forest: StartingForest = _forest(GraphicsQuality.Level.HIGH)
	for layer: String in forest.tree_points.keys():
		for p: Vector2 in forest.tree_points[layer] as Array:
			assert_false(forest.keep_out.has_point(p), "%s tree at %s stays out of the clearing" % [layer, str(p)])


func test_the_strip_between_the_clearing_and_the_camera_stays_low() -> void:
	var forest: StartingForest = _forest(GraphicsQuality.Level.MEDIUM)
	assert_lt(forest._height_cap(forest.spawn + Vector2(0.0, 3.5)), 5.0, "right behind the hero the trees are short")
	assert_gt(forest._height_cap(forest.spawn + Vector2(0.0, -8.0)), 100.0, "north of the hero they may be as tall as they like")


func test_quality_scales_the_forest_and_the_ambience() -> void:
	var low: StartingForest = _forest(GraphicsQuality.Level.LOW)
	var high: StartingForest = _forest(GraphicsQuality.Level.HIGH)
	assert_lt((low.tree_points["near"] as Array).size(), (high.tree_points["near"] as Array).size())
	assert_lt(low.firefly_count, high.firefly_count)
	assert_lt(low.shaft_count, high.shaft_count)
	assert_gte(low.shaft_count, 3, "even Low keeps a few light shafts")


func test_the_forest_is_deterministic() -> void:
	var first: StartingForest = _forest(GraphicsQuality.Level.MEDIUM)
	var second: StartingForest = _forest(GraphicsQuality.Level.MEDIUM)
	assert_eq((first.tree_points["near"] as Array).size(), (second.tree_points["near"] as Array).size())
	assert_eq((first.tree_points["near"] as Array)[0], (second.tree_points["near"] as Array)[0])
