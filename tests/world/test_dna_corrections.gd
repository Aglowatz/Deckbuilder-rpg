extends GutTest
## The D.N.A. slice, Part B (docs/art/dna_slice.md): the Gainlands corrections applied to the office from the start. Wide doorways, knee-high balustrades, cabinets
## and partitions that fade per piece, a decluttered prop list and board list, the walked entrance on the approach causeway (spawn facing the gate, the exit at the
## far end), the Hall of Final Approvals beyond the executive floor's north edge with its stair clear of the floor, and the plaza kept open.

var layout: DnaLayout


func before_all() -> void:
	layout = DnaLayout.new()
	layout.build()


func test_every_doorway_is_at_least_four_cells_wide() -> void:
	# (x, z, w, d) of every link rect of the plan: all cells floor, the narrow side LINK_WIDTH or more
	for rect: Rect2i in [Rect2i(35, 51, 1, 4), Rect2i(43, 42, 4, 4), Rect2i(23, 44, 5, 4), Rect2i(34, 32, 2, 5), Rect2i(54, 32, 2, 5), Rect2i(43, 24, 4, 4), Rect2i(14, 22, 5, 4), Rect2i(34, 16, 2, 5), Rect2i(54, 17, 2, 5), Rect2i(43, 14, 4, 2), Rect2i(69, 24, 5, 2), Rect2i(44, 60, 5, 8)]:
		for cz: int in range(rect.position.y, rect.end.y):
			for cx: int in range(rect.position.x, rect.end.x):
				assert_true(layout.is_floor(cx, cz), "doorway cell (%d, %d) is floor" % [cx, cz])
		# the doorway's opening (the side that cuts through the wall) is LINK_WIDTH wide
		assert_gte(maxi(rect.size.x, rect.size.y), DnaLayout.LINK_WIDTH, "doorway %s is wide" % str(rect))


func test_walls_are_knee_high_and_the_fading_pieces_are_short() -> void:
	assert_lte(DnaBuilder.WALL_HEIGHT, 0.6, "a balustrade never hides the hero (0.68 m)")
	assert_lte(DnaBuilder.PARTITION_HEIGHT, 0.7)
	assert_lte(DnaBuilder.CABINET_HEIGHT, 1.1)


func test_the_props_are_few_and_painted() -> void:
	var models: int = 0
	var cards: int = 0
	var pieces: int = 0
	for prop: DnaLayout.Prop in layout.props:
		match prop.kind:
			"model":
				models += 1
			"card":
				cards += 1
				assert_true(DnaBuilder.CARD_KINDS.has(prop.model), "%s has a card kind" % prop.model)
				assert_true(TreeCards.KINDS.has(str(DnaBuilder.CARD_KINDS.get(prop.model, ""))), "%s has a TreeCards kind" % prop.model)
			"piece":
				pieces += 1
				assert_not_null(DnaProps.piece(prop.model, prop.model_scale), "%s is a piece" % prop.model)
	assert_lte(models, 4, "only the coffins are still Kenney models")
	assert_lte(pieces, 12, "a few kit pieces")
	assert_between(cards, 60, 160, "one desk per cubicle, lamps, plants and cabinets at the walls")


func test_the_boards_label_things_and_nothing_else() -> void:
	assert_lte(layout.signs.size(), 24, "the posters and memos are gone (GC-2)")
	for sign: DnaLayout.Sign in layout.signs:
		assert_true(DnaBuilder.SIGN_ICONS.has(sign.key), "%s has a pictogram" % sign.key)
		assert_false(sign.key.begins_with("poster."), "no posters: %s" % sign.key)
		assert_true(not sign.key.begins_with("memo.") or sign.key == "memo.cubicle_coffin", "no memos but the coffin's: %s" % sign.key)


func test_the_way_in_is_walked_from_the_approach() -> void:
	var spawn: Vector3 = layout.anchors["spawn"] as Vector3
	var exit: Vector3 = layout.anchors["exit"] as Vector3
	assert_true(DnaLayout.on_approach(spawn.x, spawn.z), "a fresh visit starts on the approach")
	assert_true(DnaLayout.on_approach(exit.x, exit.z), "the exit spot waits at its far end")
	assert_gt(exit.z, spawn.z, "the exit is behind the hero, toward town")
	assert_lt(spawn.z, DnaLayout.EXIT_EDGE_Z, "the spawn is short of the walk-off edge")
	assert_true(layout.anchors.has("gate"), "the gate stands between the approach and the lobby")
	var reach: Dictionary = layout.reachable_from(spawn)
	assert_true(reach.has(DnaLayout.world_to_cell(layout.anchors["lobby_center"] as Vector3)), "the lobby is reached by walking through the gate")
	assert_true(reach.has(DnaLayout.world_to_cell(layout.anchors["main_dungeon"] as Vector3)), "and the Hall's stair foot from there")
	assert_false(layout.is_floor(46, DnaLayout.APPROACH_Z1), "the causeway ends: beyond it is the way to town")


func test_the_hall_towers_beyond_the_north_edge_with_its_stair_clear_of_the_floor() -> void:
	assert_gte(DnaLayout.HALL_SIZE.y, 36.0, "huge")
	assert_gte(DnaLayout.HALL_SIZE.x, 56.0, "unmistakable")
	# the stair foot (local half_d + terrace_h * 1.7) sits north of the floor edge (z 2.0) and its blockers never reach a floor cell
	var terrace_h: float = clampf(DnaLayout.HALL_SIZE.y * 0.12, 1.2, 4.5)
	var foot_z: float = DnaLayout.HALL_CENTER.y + DnaLayout.HALL_SIZE.z * 0.5 + terrace_h * 1.7
	assert_lt(foot_z, 2.0, "the stair foot is north of the executive floor")
	assert_gt(foot_z, 0.5, "and close enough to step up to")
	assert_gt(layout.open_edges.size(), 6, "the balustrade opens for the stair")
	for cell: Variant in layout.open_edges.keys():
		assert_eq(layout.cell_at((cell as Vector2i).x, (cell as Vector2i).y), DnaLayout.Cell.VOID, "the open edge is not walled")
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: DnaBuilder = DnaBuilder.new()
	builder.build(host)
	assert_not_null(builder.hall, "the Hall is built")
	assert_eq(builder.hall.get_parent(), builder.root, "off the root, never chunk-culled")
	for piece: Node in builder.hall.find_children("*", "MeshInstance3D", true, false):
		assert_true(piece.has_meta(&"no_range_cull"), "the goal is never range-culled")
	assert_true(builder.is_walkable((layout.anchors["main_dungeon"] as Vector3) + Vector3(0, 0, 1.2)), "the hero can stand at the stair foot")
	assert_true(builder.is_walkable((layout.chests["chest_exec_2"] as Vector3) + Vector3(0, 0, 0.9)), "the executive chest is not under the stair (a chest blocks its own cell)")
	assert_true(builder.is_walkable((layout.chests["chest_exec"] as Vector3) + Vector3(0, 0, 0.9)))
	assert_true(builder.is_walkable(layout.anchors["spawn"] as Vector3), "the spawn is clear of the gate")
	assert_true(builder.is_walkable(layout.anchors["exit"] as Vector3), "the exit spot is walkable")
	assert_gt(DnaMaterials.fade_materials().size(), 0, "the cabinets and partitions carry the per-piece fade")
	DnaMaterials.set_hero_pos(Vector3(1.0, 0.0, 2.0))
	assert_eq(DnaMaterials.fade_materials()[0].get_shader_parameter("hero_pos"), Vector3(1.0, 0.0, 2.0))
	assert_eq(host.find_children("*", "Label3D", true, false).size(), 0, "no lettering in the world")


func test_the_plaza_middle_is_open() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: DnaBuilder = DnaBuilder.new()
	builder.build(host)
	var centre: Vector3 = layout.anchors["lobby_center"] as Vector3
	for dx: int in range(-3, 4):
		for dz: int in range(-2, 3):
			assert_true(builder.is_walkable(centre + Vector3(float(dx), 0.0, float(dz))), "open plaza at %d, %d" % [dx, dz])
	for key: String in ["dolores", "pip", "heal", "quiz", "matching", "puzzle", "coffee", "printer", "suggestion", "time_clock", "mini_dungeon", "main_dungeon"]:
		var pos: Vector3 = layout.anchors[key] as Vector3
		var free: int = 0
		for angle: int in range(0, 360, 45):
			var p: Vector3 = pos + Vector3(cos(deg_to_rad(float(angle))), 0.0, sin(deg_to_rad(float(angle)))) * 1.3
			if builder.is_walkable(p):
				free += 1
		assert_gte(free, 1 if key == "matching" else 3, "open ground round %s" % key)  # Kyle sits in a maze alcove by design
