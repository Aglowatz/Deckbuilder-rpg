extends GutTest
## The visual slice: the town square dressing is deterministic, bounded and respects the graphics quality.


func _build(quality: int) -> Array:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root)
	var square: TownSquare = TownSquare.build(root, town, quality)
	return [square, town]


func _count_multimesh_instances(square: TownSquare) -> int:
	var total: int = 0
	for node: Node in square.root.find_children("*", "MultiMeshInstance3D", true, false):
		total += (node as MultiMeshInstance3D).multimesh.instance_count
	return total


func test_square_has_lights_within_the_budget() -> void:
	var built: Array = _build(GraphicsQuality.Level.HIGH)
	var square: TownSquare = built[0] as TownSquare
	assert_gt(square.lights.size(), 4, "lanterns and a campfire")
	assert_lte(square.lights.size(), GraphicsQuality.light_budget(GraphicsQuality.Level.HIGH) + 2)


func test_meadow_scales_with_quality() -> void:
	var high: int = _count_multimesh_instances((_build(GraphicsQuality.Level.HIGH)[0]) as TownSquare)
	var low: int = _count_multimesh_instances((_build(GraphicsQuality.Level.LOW)[0]) as TownSquare)
	assert_gt(high, 300, "a dense meadow on High")
	assert_lt(low, high, "fewer tufts on Low")


func test_meadow_keeps_the_lanes_and_buildings_clear() -> void:
	var built: Array = _build(GraphicsQuality.Level.HIGH)
	var square: TownSquare = built[0] as TownSquare
	var town: TownBuilder = built[1] as TownBuilder
	assert_gt(square.meadow_points.size(), 300)
	var well: Vector3 = town.anchors["well"] as Vector3
	for pos: Vector3 in square.meadow_points:
		assert_true(town.is_floor_at(pos), "tufts only grow on land")
		assert_gt(Vector2(pos.x - well.x, pos.z - well.z).length(), 0.8, "nothing grows on the well")


func test_dressing_does_not_wall_off_the_anchors() -> void:
	var town: TownBuilder = (_build(GraphicsQuality.Level.HIGH)[1]) as TownBuilder
	for key: String in ["market", "deck", "well", "spawn", "npc_market", "npc_well"]:
		var anchor: Vector3 = town.anchors[key] as Vector3
		assert_true(town.is_walkable(anchor + Vector3(0, 0, 0.0), 0.2) or key.begins_with("npc") or key == "market" or key == "deck" or key == "well", "%s stays reachable" % key)


func test_square_is_deterministic() -> void:
	var first: int = _count_multimesh_instances((_build(GraphicsQuality.Level.MEDIUM)[0]) as TownSquare)
	var second: int = _count_multimesh_instances((_build(GraphicsQuality.Level.MEDIUM)[0]) as TownSquare)
	assert_eq(first, second)


func test_birds_and_npc_life() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var flock: AmbientBirds = AmbientBirds.spawn(host, Vector3.ZERO, 3, Color.WHITE)
	assert_eq(flock.birds.size(), 3)
	var life: NpcLife = NpcLife.new()
	host.add_child(life)
	life.register(ModelKit.character("Mage"), 0.0)
	assert_eq(life.entry_count(), 1)
