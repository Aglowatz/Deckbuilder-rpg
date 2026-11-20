extends GutTest
## Fable Nov 20, Part 5 (the world): the D.N.A.'s gate, runner and routing desk on one line; quest marks just over each head on high
## ground; the Iron Cave's crag is a tall occluder; the clearing in front of Professor Pate and Dex Shufflewick; the Buffet's edge never
## under the gravy; the mount comes down the Dump's slide; the Harvest Meal's prompt is not taken by Billie Muckfoot.


# ---- 5.1 the D.N.A. ----------------------------------------------------------------------------------------------------------------


func test_the_dna_gate_the_runner_and_the_desk_share_one_line() -> void:
	var layout: DnaLayout = DnaLayout.new()
	layout.build()
	var axis: float = DnaLayout.AXIS_X
	var runner: Array = DnaHall.RUNNERS[0]
	assert_almost_eq((runner[0] as Vector2).x, axis, 0.001, "the red runner from the gate to the Hall's stair")
	assert_almost_eq((runner[1] as Vector2).x, axis, 0.001)
	assert_almost_eq(DnaLayout.HALL_CENTER.x, axis, 0.001, "the Hall at its far end")
	assert_almost_eq((layout.anchors["gate"] as Vector3).x, axis, 0.001, "the entrance gate")
	assert_almost_eq((layout.anchors["spawn"] as Vector3).x, axis, 0.001, "the hero arrives on the line")
	assert_almost_eq((layout.anchors["exit_door"] as Vector3).x, axis, 0.001)
	assert_almost_eq(float(DnaLayout.APPROACH_X0 + DnaLayout.APPROACH_X1) * 0.5, axis, 0.001, "the causeway is centred on it")
	var desk: Vector3 = (layout.anchors["puzzle"] as Vector3) - Vector3(1.0, 0, 1.0)
	assert_almost_eq(desk.x, axis, 0.001, "the routing desk (three green terminals) stands on the runner's line")
	assert_true(DnaHall.on_runner(desk.x, desk.z), "on the carpet")
	assert_true(DnaLayout.on_approach(axis, float(DnaLayout.APPROACH_Z0) + 1.0))


# ---- 5.2 the Gainlands -------------------------------------------------------------------------------------------------------------


func test_a_spots_marker_counts_the_ground_once() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/zone/zone_scene.gd")
	assert_false(source.contains("marker.position = pos + Vector3(0, ground + "), "the ground's height is not added to a position that already stands on it")
	assert_string_contains(source, "marker.position = Vector3(pos.x, ground + (spot.label_height")


func test_a_quest_mark_sits_just_over_the_head_on_high_ground() -> void:
	# what the marker layer does with a spot on the Gainlands' plateau (4 m up): the mark hangs head height + LIFT over the spot
	var spot: ZoneSpot = ZoneSpot.new()
	spot.id = "gus"
	spot.is_npc = true
	spot.position = Vector3(89.9, 4.0, 55.0)
	spot.label_height = 2.05
	var marker: Node3D = Node3D.new()
	autofree(marker)
	marker.position = Vector3(spot.position.x, 4.0 + spot.label_height, spot.position.z)
	spot.marker = marker
	var found: Dictionary = QuestMarkerLayer.resolve_in([spot], "gus")
	assert_almost_eq(float(found["top"]), 2.05, 0.01, "the head's height, not the plateau's on top of it")
	assert_lt(float(found["top"]) + QuestMarkerLayer.LIFT, 3.0, "the mark hangs under 3 m over his feet")


func test_the_iron_caves_crag_is_a_tall_occluder() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var crag: MeshInstance3D = builder.root.find_child("IronCrag", true, false) as MeshInstance3D
	assert_not_null(crag)
	var pieces: Array[MeshInstance3D] = [crag]
	for child: Node in crag.get_children():
		if child is MeshInstance3D:
			pieces.append(child as MeshInstance3D)
	assert_gt(pieces.size(), 4)
	for piece: MeshInstance3D in pieces:
		assert_false(piece.has_meta(&"no_occlusion_fade"), "%s takes part in the fade" % piece.name)
		assert_eq(str(piece.get_meta(&"fade_type", "")), "tall_occluder", str(piece.name))
		var box: AABB = piece.get_meta(&"occlusion_box") as AABB
		assert_lt(box.size.y, 40.0, "%s: its box is the rock over the plateau, not the wall down into the sea" % piece.name)
		assert_almost_eq(box.position.y, GainlandsLayout.PLATEAU_Y - 0.5, 0.01)
		assert_eq(OcclusionFader.type_of(box.size, str(piece.name), &"tall_occluder"), OcclusionFader.TALL_OCCLUDER)
	var main_box: AABB = crag.get_meta(&"occlusion_box") as AABB
	assert_gt(main_box.size.y, 6.0, "tall enough to hide the hero on the northern path")


# ---- 5.3 the Endless Buffet --------------------------------------------------------------------------------------------------------


func test_no_tree_stands_in_front_of_pate_and_dex() -> void:
	var layout: BuffetLayout = BuffetLayout.new()
	layout.build()
	var quiz: Vector3 = layout.anchors["quiz"] as Vector3
	assert_true(BuffetLayout.QUIZ_CLEARING.has_point(Vector2(quiz.x, quiz.z)), "the clearing is theirs")
	var in_clearing: int = 0
	var forest_left: int = 0
	var east_border: int = 0
	for prop: BuffetLayout.Prop in layout.props:
		if not (prop.kind in ["broccoli", "cauliflower"]):
			continue
		var at: Vector2 = Vector2(prop.pos.x, prop.pos.z)
		if BuffetLayout.in_quiz_clearing(at):
			in_clearing += 1
		elif Rect2(6.0, 50.0, 26.0, 24.0).has_point(at):
			forest_left += 1
			# a tree south of the two (between them and the camera) within their width would hide them again
			assert_false(at.y > quiz.z - 2.0 and absf(at.x - quiz.x) < 6.0, "a tree at %s stands between the camera and the two" % str(at))
		if at.x > 60.0:
			east_border += 1
	assert_eq(in_clearing, 0, "no broccoli or cauliflower in the clearing or along the path's south side")
	assert_gte(forest_left, 3, "a few trees of the Broccoli Forest stay (%d)" % forest_left)
	assert_gt(east_border, 4, "the east side keeps its trees")


func test_the_buffets_edge_is_never_under_the_gravy() -> void:
	var layout: BuffetLayout = BuffetLayout.new()
	layout.build()
	var water: float = BuffetShore.WATER_Y
	var checked: int = 0
	var lowest: float = INF
	# all round the table, from the very edge to 12 m in, outside the river's bed and banks
	for step: int in range(0, 360, 2):
		var angle: float = deg_to_rad(float(step))
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		var centre: Vector2 = (BuffetLayout.MIN_CORNER + BuffetLayout.MAX_CORNER) * 0.5
		var reach: float = 80.0
		# walk in from far outside until the table starts
		var at: Vector2 = centre + dir * reach
		while reach > 0.0 and BuffetLayout.edge_distance(at.x, at.y) < 0.05:
			reach -= 0.1
			at = centre + dir * reach
		for inward: float in [0.0, 0.4, 0.9, 1.5, 2.5, 4.0, 6.0, 9.0, 12.0]:
			var p: Vector2 = centre + dir * (reach - inward)
			if layout.soup_depth(p.x, p.y) > -2.2 or layout.on_bridge(p.x, p.y):
				continue
			var height: float = layout.ground_height(p.x, p.y)
			checked += 1
			lowest = minf(lowest, height)
			if inward <= 6.0:
				assert_gt(height, water + 0.04, "the ground at %s (%.1f m from the edge) lies %.2f over the gravy" % [str(p.snapped(Vector2(0.1, 0.1))), inward, height - water])
	assert_gt(checked, 1000)
	assert_gt(lowest, water - 1.0, "9 to 12 m in the hills are as they were (dry land: the gravy only lies outside the table)")
	# the owner's place: the west side at the north end, past the river
	for z: float in [10.0, 16.0, 22.0, 28.0, 34.0]:
		var edge_x: float = BuffetLayout.MIN_CORNER.x
		while BuffetLayout.edge_distance(edge_x, z) < 0.05:
			edge_x += 0.1
		assert_gt(layout.ground_height(edge_x + 0.9, z), water + 0.1, "the gravy's inner edge (0.9 m in) is hidden under the beach at z %.0f" % z)
		assert_lt(layout.ground_height(edge_x, z) - water, 0.35, "a low beach at the edge, no step, at z %.0f" % z)
		assert_almost_eq(layout.ground_height(edge_x + 3.0, z), maxf(layout.ground_height(edge_x + 3.0, z), BuffetLayout.SHORE_LEVEL), 0.001, "level with the zone three metres in")


# ---- 5.4 the Verdant Dump ----------------------------------------------------------------------------------------------------------


func test_the_slide_keeps_the_mount() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/heap/heap_scene.gd")
	var start: int = source.find("func _slide(chute: HeapLayout.Chute)")
	var slide: String = source.substr(start, source.find("\n# ---- Falling", start) - start)
	assert_gt(slide.length(), 500)
	assert_false(slide.contains("_dismount("), "taking a slide no longer sends the mount home")
	assert_string_contains(source, "func _update_mount()", "the mount follows the hero every frame, down the slide too")
	var fall: String = source.substr(source.find("func _fall_into_hazard()"), 400)
	assert_string_contains(fall, "_dismount(false)", "falling into the stream still does")


func test_the_harvest_meal_is_out_of_billies_reach() -> void:
	var layout: HeapLayout = HeapLayout.new()
	layout.build()
	var meal: Vector3 = (layout.anchors["heal"] as Vector3) + Vector3(0, 0, 1.6)
	var billie: Vector3 = (layout.anchors["wren"] as Vector3) + Vector3(0.9, 0, 0)
	# the walk smoke stands 1.6 m south of the meal's spot; Billie's Talk (reach 1.7 m x the interact factor) must not cover that
	var stand: Vector3 = meal + Vector3(0, 0, 1.6)
	assert_gt(stand.distance_to(billie), 1.7 * StorybookScale.INTERACT_FACTOR + 0.5, "in front of the meal the prompt is the meal's")
	assert_lt((layout.anchors["wren"] as Vector3).distance_to(Vector3(38.5, 0, 123.5)), 3.5, "she only moved a few steps")
