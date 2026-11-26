extends GutTest
## Nov 26 day (Part A): every dungeon map draws each link as one straight line from room to room - the zone dungeons, the minis,
## the postgame, Primm's Castle and the Shuffled Halls - and no curve data is read when a map is drawn.

const KEYS: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer", "final", "S-IRON", "S-GOUR", "D-LAB", "S-GALLERY", "D-SHUFFLE"]


func _open(key: String) -> DungeonMapScreen:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.dungeon_key = key
	Session.dungeon_map = MainDungeons.build_map(key)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	Session.main_dungeon_active = true
	Session.dungeon_story_seen = []
	var screen: DungeonMapScreen = DungeonMapScreen.new()
	screen.screenshot_prepare({"quiet": true})
	add_child_autofree(screen)
	return screen


func _paths_of(screen: Node) -> MapPaths:
	for child: Node in screen.find_children("*", "", true, false):
		if child is MapPaths:
			return child as MapPaths
	return null


func test_the_curve_system_is_off_for_drawing() -> void:
	assert_false(MapPaths.FOLLOW_CURVES, "the path-curve system is off")
	# the data stays in the repo in case it returns
	assert_false(DungeonCatalog.curves("D-PC").is_empty(), "the castle's traced lines are still on file")


func test_every_map_draws_straight_lines_and_reads_no_curves() -> void:
	for key: String in KEYS:
		var before: int = DungeonCatalog.curve_reads
		var screen: DungeonMapScreen = _open(key)
		assert_not_null(Session.dungeon_map, key)
		await wait_frames(2)
		assert_eq(DungeonCatalog.curve_reads, before, "%s: no curve data read while the map is built and drawn" % key)
		var paths: MapPaths = _paths_of(screen)
		assert_not_null(paths, key)
		if paths == null:
			continue
		assert_true(paths.curves.is_empty(), "%s: the drawer holds no traced lines" % key)
		assert_false(paths.painted_walkways, "%s: every link gets its line" % key)
		var links: int = 0
		for node: DungeonMap.MapNode in Session.dungeon_map.nodes:
			for next_id: int in node.next:
				var from: Vector2 = Vector2(100.0 + node.id * 37.0, 900.0 - node.id * 21.0)
				var to: Vector2 = Vector2(140.0 + next_id * 53.0, 880.0 - next_id * 29.0)
				var line: PackedVector2Array = paths.link_points(node.id, next_id, from, to)
				links += 1
				assert_eq(line[0], from)
				assert_lt(line[line.size() - 1].distance_to(to), 0.5)
				var direction: Vector2 = (to - from).normalized()
				for point: Vector2 in line:
					var along: float = (point - from).dot(direction)
					assert_lt((point - (from + direction * along)).length(), 0.5, "%s %d>%d is one straight segment" % [key, node.id, next_id])
		assert_gt(links, 2, key)
		screen.queue_free()
		await wait_frames(1)
