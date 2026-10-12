extends GutTest
## WorldFoliage (docs/art/world_look_test.md): plants never stand on the roads, the plaza paving or a doorstep, only on ground, and are denser at the edges than inland.


func _foliage() -> Array:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var town: TownBuilder = TownBuilder.new()
	town.build(root, false)
	var foliage: WorldFoliage = WorldFoliage.new()
	add_child_autofree(foliage)
	foliage.setup(town, null, null, Vector3(0.4, -0.6, -0.7))
	return [foliage, town]


func test_plants_keep_off_roads_plaza_and_doorsteps() -> void:
	var made: Array = _foliage()
	var foliage: WorldFoliage = made[0] as WorldFoliage
	var town: TownBuilder = made[1] as TownBuilder
	var positions: Array[Vector3] = foliage.positions()
	assert_gt(positions.size(), 500, "a town-sized field of plants")
	var roads: Array[Vector3] = TownLayout.road_points(0.9)
	var too_close_to_road: int = 0
	var inside_plaza: int = 0
	var off_ground: int = 0
	var at_door: int = 0
	for p: Vector3 in positions:
		if not town.is_floor_at(p):
			off_ground += 1
		if Vector2(p.x - TownLayout.PLAZA.x, p.z - TownLayout.PLAZA.z).length() < TownLayout.PLAZA_RADIUS:
			inside_plaza += 1
		for road: Vector3 in roads:
			if Vector2(p.x - road.x, p.z - road.z).length() < WorldFoliage.ROAD_CLEARANCE - 0.3:
				too_close_to_road += 1
				break
		for anchor: Variant in town.anchors.values():
			if anchor is Vector3 and Vector2(p.x - (anchor as Vector3).x, p.z - (anchor as Vector3).z).length() < WorldFoliage.DOOR_CLEARANCE - 0.3:
				at_door += 1
				break
	assert_eq(off_ground, 0, "every plant stands on ground")
	assert_eq(inside_plaza, 0, "none on the plaza paving")
	assert_eq(too_close_to_road, 0, "none on a road")
	assert_eq(at_door, 0, "none on a doorstep or a spot")


func _edge_fraction(town: TownBuilder, p: Vector3) -> float:
	var off: int = 0
	for i: int in range(6):
		var angle: float = float(i) / 6.0 * TAU + 0.4
		if not town.is_floor_at(p + Vector3(cos(angle), 0.0, sin(angle)) * 2.4):
			off += 1
	return float(off) / 6.0


func test_plants_favour_the_edges_of_the_land() -> void:
	var made: Array = _foliage()
	var foliage: WorldFoliage = made[0] as WorldFoliage
	var town: TownBuilder = made[1] as TownBuilder
	var plants: float = 0.0
	var plant_count: int = 0
	for p: Vector3 in foliage.positions():
		plants += _edge_fraction(town, p)
		plant_count += 1
	var ground: float = 0.0
	var ground_count: int = 0
	var bounds: Rect2 = town.map_bounds()
	var z: float = bounds.position.y
	while z < bounds.end.y:
		var x: float = bounds.position.x
		while x < bounds.end.x:
			var p: Vector3 = Vector3(x, 0.0, z)
			if town.is_floor_at(p):
				ground += _edge_fraction(town, p)
				ground_count += 1
			x += 3.0
		z += 3.0
	assert_gt(plants / float(plant_count), ground / float(ground_count), "the average plant is nearer the edge than the average bit of ground")
