extends GutTest
## Fable big pass Nov 23 (Part 7): the lines between dungeon map rooms follow the painted walkways (`map_layout.json` "curves",
## traced by tools/map_curves.py; `DungeonCatalog.curves`, `MapPaths.link_points`).

const HIDDEN_ROOMS: Dictionary = {"D-SHUFFLE": [0]}


func _painted() -> Array[DungeonCatalog.Blueprint]:
	var result: Array[DungeonCatalog.Blueprint] = []
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if not DungeonCatalog.curves(blueprint.id).is_empty():
			result.append(blueprint)
	return result


func test_every_painted_map_has_a_line_for_every_link() -> void:
	var with_art: int = 0
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.map_id.is_empty() or MapArt.texture_for(blueprint.map_id) == null:
			continue
		with_art += 1
		var curves: Dictionary = DungeonCatalog.curves(blueprint.id)
		for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
			if (HIDDEN_ROOMS.get(blueprint.id, []) as Array).has(node.number - 1):
				continue
			for next_number: int in node.next:
				var key: String = "%d>%d" % [node.number - 1, next_number - 1]
				assert_true(curves.has(key), "%s: the link %s has a line" % [blueprint.id, key])
				if not curves.has(key):
					continue
				var points: PackedVector2Array = curves[key] as PackedVector2Array
				assert_gte(points.size(), 2)
				assert_lt(points[0].distance_to(node.position), 0.012, "%s %s starts on its room" % [blueprint.id, key])
				assert_lt(points[points.size() - 1].distance_to(blueprint.node(next_number).position), 0.012, "%s %s ends on its room" % [blueprint.id, key])
				for point: Vector2 in points:
					assert_between(point.x, 0.0, 1.0)
					assert_between(point.y, 0.0, 1.0)
	assert_gte(with_art, 17, "every painted dungeon map (the zone dungeons, the minis, the castle, the postgame dungeons, the Halls)")


func test_a_traced_line_is_no_wild_detour() -> void:
	for blueprint: DungeonCatalog.Blueprint in _painted():
		var curves: Dictionary = DungeonCatalog.curves(blueprint.id)
		for key: Variant in curves.keys():
			var points: PackedVector2Array = curves[key] as PackedVector2Array
			var length: float = 0.0
			for i: int in range(points.size() - 1):
				length += points[i].distance_to(points[i + 1])
			var straight: float = points[0].distance_to(points[points.size() - 1])
			assert_lt(length, straight * 1.9 + 0.02, "%s %s is not a wild detour (%.2f for %.2f)" % [blueprint.id, key, length, straight])


func test_links_without_a_painted_walkway_are_listed_for_the_artist() -> void:
	var listed: int = 0
	for blueprint: DungeonCatalog.Blueprint in _painted():
		listed += DungeonCatalog.curve_gaps(blueprint.id).size()
	var rows: PackedStringArray = FileAccess.get_file_as_string("res://docs/art/map_walkways_missing.csv").strip_edges().split("\n")
	assert_eq(rows.size() - 1, listed, "docs/art/map_walkways_missing.csv has a row for each")
	assert_has(DungeonCatalog.curve_gaps("D-SHUFFLE"), "18>19", "the Counting Room's side door has no carpet in the painting")


func test_the_screen_line_runs_from_room_to_room_in_even_steps() -> void:
	var paths: MapPaths = MapPaths.new()
	add_child_autofree(paths)
	paths.style = "highlight"
	paths.art_rect = Rect2(100.0, 50.0, 1500.0, 1000.0)
	paths.curves = {"0>1": PackedVector2Array([Vector2(0.1, 0.8), Vector2(0.2, 0.6), Vector2(0.35, 0.65), Vector2(0.5, 0.4)])}
	var from: Vector2 = Vector2(250.0, 850.0)
	var to: Vector2 = Vector2(850.0, 450.0)
	var line: PackedVector2Array = paths.link_points(0, 1, from, to)
	assert_eq(line[0], from)
	assert_lt(line[line.size() - 1].distance_to(to), 1.0)
	var bent: bool = false
	for i: int in range(1, line.size() - 1):
		assert_lt(line[i].distance_to(line[i - 1]), MapPaths.CURVE_STEP * 1.6, "even steps")
		var along: float = (line[i] - from).dot((to - from).normalized())
		var off: float = (line[i] - (from + (to - from).normalized() * along)).length()
		if off > 30.0:
			bent = true
	assert_true(bent, "the line leaves the straight between the rooms to follow the walkway")
	var straight: PackedVector2Array = paths.link_points(3, 4, from, to)
	assert_eq(straight.size(), 41, "a link without a traced line is drawn straight, as before")
	assert_lt(straight[20].distance_to(from.lerp(to, 0.5)), 0.5)
