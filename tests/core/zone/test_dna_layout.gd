extends GutTest
## Part C: the D.N.A.'s floor plan - size, connectivity, anchors, chests, enemies.

var layout: DnaLayout


func before_all() -> void:
	layout = DnaLayout.new()
	layout.build()


func test_zone_is_about_three_times_the_town() -> void:
	# The town has 353 land cells of 3.46 m2 (hex, 2 m flat-to-flat); the zone's cells are 1 m2.
	var town_area: float = 353.0 * (sqrt(3.0) / 2.0 * 4.0)
	var zone_area: float = float(layout.floor_cell_count())
	var ratio: float = zone_area / town_area
	assert_between(ratio, 2.7, 3.6, "zone floor area is ~3x the town (got %.2f)" % ratio)


func test_every_anchor_is_walkable_and_reachable_from_spawn() -> void:
	var reach: Dictionary = layout.reachable_from(layout.anchors["spawn"] as Vector3)
	for name: String in ["exit", "heal", "dolores", "barnaby", "pip", "quiz", "matching", "puzzle", "mini_dungeon", "main_dungeon", "coffee", "time_clock", "suggestion", "printer"]:
		var pos: Vector3 = layout.anchors[name] as Vector3
		var cell: Vector2i = DnaLayout.world_to_cell(pos)
		assert_true(reach.has(cell), "%s at %s is reachable" % [name, cell])


func test_hidden_chests_are_reachable_and_numerous() -> void:
	assert_gte(layout.chests.size(), 6)
	var reach: Dictionary = layout.reachable_from(layout.anchors["spawn"] as Vector3)
	for id: String in layout.chests.keys():
		var cell: Vector2i = DnaLayout.world_to_cell(layout.chests[id] as Vector3)
		assert_true(reach.has(cell), "%s reachable" % id)
		assert_true(DnaScene.CHEST_REWARDS.has(id), "%s has a reward" % id)


func test_enemy_homes_are_reachable_and_all_three_types_exist() -> void:
	var reach: Dictionary = layout.reachable_from(layout.anchors["spawn"] as Vector3)
	var types: Dictionary = {}
	for spawn: Dictionary in layout.enemy_spawns:
		types[str(spawn["type"])] = true
		assert_true(reach.has(DnaLayout.world_to_cell(spawn["home"] as Vector3)), "enemy home reachable %s" % str(spawn["home"]))
	assert_eq(types.size(), 3)


func test_hub_rooms_are_safe_and_have_no_enemies() -> void:
	for spawn: Dictionary in layout.enemy_spawns:
		var room: DnaLayout.Room = layout.room_at(spawn["home"] as Vector3)
		assert_not_null(room)
		assert_false(room.safe, "no enemy spawns in the hub")


func test_room_titles_cover_the_whole_brief() -> void:
	var ids: Array[String] = []
	for room: DnaLayout.Room in layout.rooms:
		ids.append(room.id)
	for needed: String in ["lobby", "breakroom", "farm_a", "farm_b", "maze", "bank", "records", "exec", "mail"]:
		assert_true(ids.has(needed), needed)
