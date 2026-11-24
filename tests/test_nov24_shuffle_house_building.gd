extends GutTest
## Fable Nov 24 (Part 1): the Shuffle House is a real building in the lawn north-east of Crosspath's square - further right and
## further back than the corner plot of Nov 23 - with a body, a roof with volume, a foundation and a shadow under it, a clear
## paved path to its doors, and no tree of the old map between it and the square.

const OLD_CENTER: Vector3 = Vector3(41.6, 0.0, -10.0)


func _build() -> Node3D:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var obstacles: Array[Vector3] = []
	var house: Node3D = TownShuffleHouse.build(root, obstacles)
	house.set_meta(&"obstacles", obstacles)
	return house


func test_the_house_moved_further_right_and_further_back() -> void:
	assert_gt(TownShuffleHouse.CENTER.x, OLD_CENTER.x + 4.0, "further right (east) than the corner plot")
	assert_lt(TownShuffleHouse.CENTER.z, OLD_CENTER.z - 1.0, "its face stands further back (north) than the corner plot's")
	assert_lt(TownShuffleHouse.CENTER.z - TownShuffleHouse.WIDTH * TownShuffleHouse.PLINTH_RADIUS, OLD_CENTER.z - 5.0, "and its body reaches well into the back lawn")
	assert_gt(TownShuffleHouse.HEIGHT, 10.2, "taller, so its big top stands over the shop roofs from the square")


func test_it_has_a_real_body_behind_the_painted_face() -> void:
	var house: Node3D = _build()
	for part: String in ["Plinth", "Walls", "Eave", "BigTop", "Cap", "TurretWest", "TurretEast", "Foundation", "ContactShadow", "FootShadow"]:
		assert_not_null(house.get_node_or_null(part), "the house has its %s" % part)
	# depth: the body reaches well behind the face; volume: the big top rises from the eave to the painted peak
	var walls: MeshInstance3D = house.get_node("Walls") as MeshInstance3D
	var box: AABB = walls.mesh.get_aabb()
	assert_lt(box.position.z, -TownShuffleHouse.WIDTH * 0.35, "the walls go back behind the face")
	assert_lte(box.end.z, 0.01, "nothing of the body stands in front of the painted face")
	var top: AABB = (house.get_node("BigTop") as MeshInstance3D).mesh.get_aabb()
	assert_gt(top.size.y, 2.0, "the roof has height of its own")
	assert_gt(top.size.z, 3.0, "and depth")
	assert_almost_eq(top.end.y, TownShuffleHouse.HEIGHT * TownShuffleHouse.APEX_HEIGHT - 0.35, 0.05, "it ends where the painted cap begins")
	# the body casts a shadow, the ground pieces do not
	assert_eq(walls.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
	assert_eq((house.get_node("ContactShadow") as MeshInstance3D).cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	# the foundation carries the painted plinth down to the grass
	var foundation: AABB = (house.get_node("Foundation") as MeshInstance3D).mesh.get_aabb()
	assert_almost_eq(foundation.position.y, 0.0, 0.001, "the foundation stands on the ground")
	assert_gt(foundation.end.y, 1.5)


func test_the_body_is_solid_and_the_door_is_not() -> void:
	var house: Node3D = _build()
	var obstacles: Array[Vector3] = house.get_meta(&"obstacles") as Array[Vector3]
	var door: Vector3 = TownShuffleHouse.door_spot()
	var host: Vector3 = TownShuffleHouse.host_spot()
	var behind: Vector3 = TownShuffleHouse.CENTER + Vector3(0.0, 0.0, -TownShuffleHouse.WIDTH * 0.3)
	var hit_behind: bool = false
	for circle: Vector3 in obstacles:
		var centre: Vector2 = Vector2(circle.x, circle.y)
		assert_gt(centre.distance_to(Vector2(door.x, door.z)), circle.z + 0.4, "the door spot is free of the house's circles")
		assert_gt(centre.distance_to(Vector2(host.x, host.z)), circle.z + 0.3, "Octavia's spot is free of them too")
		if centre.distance_to(Vector2(behind.x, behind.z)) < circle.z:
			hit_behind = true
	assert_true(hit_behind, "nobody walks through the round body behind the face")


func test_the_path_runs_from_the_square_to_the_doors() -> void:
	var path: Array[Vector3] = TownShuffleHouse.PATH
	assert_lt(path[0].distance_to(TownLayout.PLAZA), 13.5, "the path starts at the square's rim")
	var last: Vector3 = path[path.size() - 1]
	assert_lt(Vector2(last.x, last.z).distance_to(Vector2(TownShuffleHouse.CENTER.x, TownShuffleHouse.CENTER.z)), 1.5, "and ends at the painted steps")
	assert_true(TownLayout.is_paved(TownShuffleHouse.door_spot(), 0.0), "the door spot is on the paving")
	for index: int in range(path.size() - 1):
		assert_lt(path[index].distance_to(path[index + 1]), 9.0, "no long unpaved jump on the way")
	# no building of the town stands on the path
	for point: Vector3 in TownLayout.sample(path, 1.0):
		for shop: TownLayout.Shop in TownLayout.shops():
			if shop.key == TownShuffleHouse.KEY:
				continue
			assert_false(shop.covers(point, 0.3), "the path is clear of %s at %s" % [shop.label, str(point)])


func test_the_lawn_between_the_square_and_the_house_keeps_no_tree() -> void:
	assert_true(TownShuffleHouse.in_forecourt(TownShuffleHouse.door_spot()))
	assert_true(TownShuffleHouse.in_forecourt(Vector3(40.0, 0.0, -6.0)), "the line of sight from the fountain")
	assert_true(TownShuffleHouse.in_forecourt(Vector3(47.0, 0.0, 1.5)), "the birches behind the Hall of Records are gone")
	assert_false(TownShuffleHouse.in_forecourt(Vector3(60.0, 0.0, -10.0)), "the trees east of the house stay as its backdrop")
	assert_false(TownShuffleHouse.in_forecourt(Vector3(25.2, 0.0, 12.5)), "the square is not the forecourt")
	# the house keeps clear of the loop lane behind it and of every other building
	var back: float = TownShuffleHouse.CENTER.z - TownShuffleHouse.WIDTH * TownShuffleHouse.PLINTH_RADIUS
	assert_gt(TownBounds.lane_distance(Vector3(TownShuffleHouse.CENTER.x, 0.0, back)), TownBounds.LANE_WIDTH * 0.5, "the round body stops short of the loop lane")
	for shop: TownLayout.Shop in TownLayout.shops():
		if shop.key == TownShuffleHouse.KEY or shop.kind != "kit":
			continue
		assert_gt(Vector2(shop.center.x - TownShuffleHouse.CENTER.x, shop.center.z - TownShuffleHouse.CENTER.z).length(), shop.radius + TownShuffleHouse.WIDTH * 0.5 + 1.0, "clear of %s" % shop.label)
	# the hidden chests of the lawn are still outside the house
	for cell_offset: Vector3 in [Vector3(54.0, 0.0, -15.0), Vector3(41.7, 0.0, -9.1)]:
		assert_gt(Vector2(cell_offset.x - TownShuffleHouse.CENTER.x, cell_offset.z - (TownShuffleHouse.CENTER.z - 2.2)).length(), TownShuffleHouse.WIDTH * 0.5 + 0.8, "a hidden chest keeps its place beside the house")


func test_the_sign_posts_stand_beside_the_path_not_on_it() -> void:
	for post: Vector3 in [TownShuffleHouse.SIGN_POST, TownShuffleHouse.SIGN_POST_LAWN]:
		var nearest: float = 99.0
		for point: Vector3 in TownLayout.sample(TownShuffleHouse.PATH, 0.4):
			nearest = minf(nearest, point.distance_to(post))
		assert_lt(nearest, 3.2, "a sign stands by the door path")
