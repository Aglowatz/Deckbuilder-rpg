extends GutTest
## Fable Nov 16c (Part 4): the Endless Buffet's evening pass - the castle (the Test Kitchen) is one gingerbread house, the trees right
## of the entrance are a low hedge, the gravy river thins away into the outer gravy in a delta, the submerged shore draws no outline,
## the steam is soft puffs, the ruler's banners and statue stand off the paving.

var layout: BuffetLayout


func before_all() -> void:
	layout = BuffetLayout.new()
	layout.build()


func _castle() -> Node3D:
	var size: Vector3 = BuffetLayout.TEST_KITCHEN_SIZE
	var node: Node3D = BuffetLandmarks.build({"id": "BUFF-HERO-TEST-KITCHEN", "size": [size.x, size.y, size.z]})
	add_child_autofree(node)
	return node


# ---- 4.1 the castle ---------------------------------------------------------------------------------------------------------------

func test_the_castle_is_one_gingerbread_house_with_nothing_sticking_out_of_its_roof() -> void:
	var castle: Node3D = _castle()
	var size: Vector3 = BuffetLayout.TEST_KITCHEN_SIZE
	# one chimney at most steams (there were seven stacks, two cranes, two tanks and four cake towers)
	assert_eq((castle.get_meta("steam", []) as Array).size(), 1, "one frosted chimney")
	var body: MeshInstance3D = castle.get_node("Body") as MeshInstance3D
	var box: AABB = body.get_aabb()
	# the silhouette: nothing reaches out past the plinth sideways (the whisk crane swung 15 m out over the wall), and the highest
	# point is the gable's finial over the middle, not a stack at the back
	assert_lt(box.end.x, size.x * 0.5 + 3.0, "nothing swings out past the east wall")
	assert_gt(box.position.x, -size.x * 0.5 - 3.0, "nor past the west wall")
	assert_between(box.end.y, size.y * 0.9, size.y * 1.25, "about as tall as it was (%.1f m)" % box.end.y)
	var source: String = FileAccess.get_file_as_string("res://world/buffet/buffet_landmarks.gd")
	var a: int = source.find("static func _test_kitchen(")
	var b: int = source.find("static func _frosting_run(")
	var built: String = source.substr(a, b - a)
	for gone: String in ["copper", "steel", "glass", "cheese", "_chimney(", "_strawberry("]:
		assert_false(built.contains("\"%s\"" % gone) or (gone.ends_with("(") and built.contains(gone)), "no %s in the gingerbread house" % gone)
	for kept: String in ["\"biscuit\"", "\"crust\"", "\"white\"", "_candy_cane(", "_frosting_run(", "BUFF-SHEET-WINDOWS-01", "BUFF-SHEET-WINDOWS-03", "BUFF-SHEET-DOORS-05"]:
		assert_true(built.contains(kept), "built with %s" % kept)


func test_the_castle_uses_only_art_the_kit_already_has() -> void:
	for id: String in ["BUFF-WALL-BISCUIT", "BUFF-ROOF-CRUST", "BUFF-SHEET-WINDOWS-01", "BUFF-SHEET-WINDOWS-02", "BUFF-SHEET-WINDOWS-03", "BUFF-SHEET-DOORS-05", "BUFF-SHEET-SIGNS-01", "BUFF-SHEET-SIGNS-03"]:
		assert_true(EnvKit.has(id) and EnvKit.has_art(id), "%s is in the Buffet kit" % id)


func test_the_gate_and_the_walk_grid_are_where_they_were() -> void:
	var castle: Node3D = _castle()
	var size: Vector3 = BuffetLayout.TEST_KITCHEN_SIZE
	var circles: Array = castle.get_meta("circles", []) as Array
	assert_eq(circles.size(), 3, "two gate towers and the footprint: the same three circles")
	var front_z: float = size.z * 0.5 - 1.2
	for index: int in range(2):
		var circle: Vector3 = circles[index] as Vector3
		assert_almost_eq(absf(circle.x), 7.0 * 0.5 + 2.0 + 0.2, 0.01, "a gate tower's place")
		assert_almost_eq(circle.y, front_z + 0.6, 0.01)
		assert_almost_eq(circle.z, 3.0, 0.01, "and its solid radius")
	assert_eq(circles[2], Vector3(0.0, -2.0, size.x * 0.5))
	assert_eq(castle.get_meta("footprint"), Vector2(size.x, size.z))
	# the door's spot stands on the forecourt as before
	var gate: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_true(BuffetLayout.FORECOURT.has_point(Vector2(gate.x, gate.z)))
	assert_eq(BuffetLayout.TEST_KITCHEN, Vector2(57.0, -14.5), "the castle has not moved")


# ---- 4.2 the entrance -------------------------------------------------------------------------------------------------------------

func test_most_trees_right_of_the_entrance_are_gone() -> void:
	var forest: Rect2 = BuffetLayout.ENTRANCE_FOREST
	var trees: int = 0
	var hedge: int = 0
	for prop: BuffetLayout.Prop in layout.props:
		var at: Vector2 = Vector2(prop.pos.x, prop.pos.z)
		if prop.kind in ["broccoli", "cauliflower"]:
			assert_false(BuffetLayout.ENTRANCE_VIEW.has_point(at), "no tree in the view from the entrance to the hub (%s at %.1f, %.1f)" % [prop.kind, at.x, at.y])
			if forest.has_point(at):
				trees += 1
				assert_gte(at.x, BuffetLayout.ENTRANCE_TREES_FROM_X, "the trees that stay stand at the east end")
		elif prop.kind == "divider" and forest.has_point(at):
			hedge += 1
	assert_between(trees, 2, 6, "a few trees stay where the stand joins the east forest (%d; there were 18)" % trees)
	assert_gt(hedge, 20, "a low hedge stands where the trunks stood (%d posts)" % hedge)


func test_the_hedge_closes_the_south_rim_as_the_trees_did() -> void:
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var forest: Rect2 = BuffetLayout.ENTRANCE_FOREST
	var x: float = forest.position.x + 1.6
	while x < forest.end.x - 1.0:
		assert_false(builder.is_walkable(Vector3(x, 0.0, 73.9)), "nobody walks through at x %.1f" % x)
		x += 0.5
	assert_true(builder.is_walkable(Vector3(BuffetLayout.BRIDGE_X, 0.0, 73.0)), "the way in stays open")
	assert_true(builder.is_walkable(builder.anchor("plaza")))
	# the big food forest of the east border stays
	var shore_source: String = FileAccess.get_file_as_string("res://world/buffet/buffet_shore.gd")
	assert_true(shore_source.contains("func _build_forest()"))


# ---- 4.3 the west side ------------------------------------------------------------------------------------------------------------

func test_the_gravy_river_thins_away_into_the_outer_gravy() -> void:
	var west: float = BuffetLayout.MIN_CORNER.x
	var east: float = BuffetLayout.MAX_CORNER.x
	assert_eq(BuffetBuilder.river_strength(50.0), 1.0, "the river is itself on the table")
	assert_gt(BuffetBuilder.river_strength(west - 2.0), 0.7, "still there just past the edge: no cut at the edge")
	assert_between(BuffetBuilder.river_strength(west - BuffetBuilder.RIVER_DELTA * 0.5), 0.2, 0.8, "half gone half-way out")
	assert_eq(BuffetBuilder.river_strength(west - BuffetBuilder.RIVER_DELTA), 0.0, "gone at the end of the delta")
	assert_eq(BuffetBuilder.river_strength(east + BuffetBuilder.RIVER_DELTA), 0.0, "and at the east end")
	# it widens west of the table (a delta), not east (the forest's land holds it in its channel)
	var on_table: float = BuffetBuilder.river_half_width(30.0)
	assert_almost_eq(on_table, BuffetLayout.RIVER_HALF_WIDTH + 1.0, 0.01)
	assert_gt(BuffetBuilder.river_half_width(west - 9.0), on_table + 2.5, "wider half-way out")
	assert_gt(BuffetBuilder.river_half_width(west - BuffetBuilder.RIVER_DELTA), on_table + 7.0, "widest at its end")
	assert_almost_eq(BuffetBuilder.river_half_width(east + 10.0), on_table, 0.01)
	# no step in width or strength along the way
	var x: float = west - BuffetBuilder.RIVER_DELTA
	while x < west + 3.0:
		assert_lt(absf(BuffetBuilder.river_half_width(x + 0.5) - BuffetBuilder.river_half_width(x)), 0.9, "the delta widens smoothly at x %.1f" % x)
		assert_lt(absf(BuffetBuilder.river_strength(x + 0.5) - BuffetBuilder.river_strength(x)), 0.08, "and thins smoothly")
		x += 0.5


func test_the_river_mesh_reaches_out_to_the_end_of_the_delta_with_thinning_vertices() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.build(host)
	var river: MeshInstance3D = builder.root.get_node("GravyRiver") as MeshInstance3D
	var box: AABB = river.get_aabb()
	assert_lt(box.position.x, BuffetLayout.MIN_CORNER.x - BuffetBuilder.RIVER_DELTA + 2.0, "it runs out west of the table")
	assert_gt(box.end.x, BuffetLayout.MAX_CORNER.x + BuffetBuilder.RIVER_DELTA - 2.0, "and east")
	var arrays: Array = river.mesh.surface_get_arrays(0)
	var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR] as PackedColorArray
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	assert_eq(colors.size(), vertices.size(), "every vertex carries how much of the river shows")
	var clear_far: int = 0
	var full_inside: int = 0
	for index: int in range(vertices.size()):
		if vertices[index].x < BuffetLayout.MIN_CORNER.x - BuffetBuilder.RIVER_DELTA + 1.6 and colors[index].a < 0.05:
			clear_far += 1
		if vertices[index].x > 20.0 and vertices[index].x < 80.0 and colors[index].a > 0.99:
			full_inside += 1
	assert_gt(clear_far, 2, "its far end is clear: no edge, no slab")
	assert_gt(full_inside, 50, "on the table it is the river it was")
	var material: StandardMaterial3D = river.material_override as StandardMaterial3D
	assert_true(material != null and material.vertex_color_use_as_albedo, "the plain material thins with the vertices too")
	# the painted gravy (the paint-over's own shader) thins with them as well
	assert_true(FileAccess.get_file_as_string("res://assets/shaders/style_painted_flow.gdshader").contains("ALPHA = alpha * COLOR.a;"))
	# the shore runs down to a bed: no far edge to draw a line
	var bed: MeshInstance3D = builder.root.get_node_or_null("SeaBed") as MeshInstance3D
	assert_not_null(bed, "a bed lies under the outer gravy")
	var last: Vector2 = BuffetShore.SHORE_RINGS[BuffetShore.SHORE_RINGS.size() - 1]
	assert_almost_eq(bed.get_aabb().position.y, last.y, 0.01, "at the depth where the shore ends")
	assert_lt(last.y, BuffetShore.WATER_Y - 4.0, "well under where the gravy is clear")
	assert_gt(bed.get_aabb().size.x, 400.0, "all round the table")


func test_no_outline_is_drawn_under_the_gravy() -> void:
	for path: String in ["res://assets/shaders/style_outline.gdshader", "res://assets/shaders/style_outline_depth.gdshader"]:
		var source: String = FileAccess.get_file_as_string(path)
		assert_true(source.contains("uniform float floor_y"), "%s has the floor" % path)
		assert_true(source.contains("* above;"), "%s draws nothing below it" % path)
	var scene: BuffetScene = BuffetScene.new()
	assert_lt(scene._outline_floor(), BuffetShore.WATER_Y, "the Buffet's floor lies just under the gravy's surface")
	assert_gt(scene._outline_floor(), BuffetShore.WATER_Y - 0.2, "so the dry shore and the pebbles keep their lines")
	scene.free()
	var other: HeapScene = HeapScene.new()
	assert_lt(other._outline_floor(), -1000.0, "other zones are untouched")
	other.free()


# ---- 4.4 the quick checks ---------------------------------------------------------------------------------------------------------

func test_steam_is_soft_puffs_not_discs() -> void:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var steam: CPUParticles3D = BuffetProps.steam(holder, Vector3.ZERO, 8, 0.5, 1.4)
	assert_true(steam.mesh is QuadMesh, "a puff is a card, not a ball")
	var material: StandardMaterial3D = steam.material_override as StandardMaterial3D
	assert_not_null(material)
	assert_eq(material.billboard_mode, BaseMaterial3D.BILLBOARD_PARTICLES, "facing the camera")
	assert_eq(material.shading_mode, BaseMaterial3D.SHADING_MODE_UNSHADED)
	assert_true(material.albedo_texture is GradientTexture2D, "a soft round fade")
	assert_lt(material.albedo_color.a, 0.36, "thin (%.2f)" % material.albedo_color.a)
	assert_not_null(steam.color_ramp, "it fades in and out")
	assert_eq(steam.color_ramp.get_color(0).a, 0.0)
	assert_eq(steam.color_ramp.get_color(steam.color_ramp.get_point_count() - 1).a, 0.0)
	assert_not_null(steam.scale_amount_curve, "it swells as it rises")


func test_the_ruler_s_banners_and_statue_stand_off_the_paving() -> void:
	var def: ZoneDef = ZoneDefs.get_def(BuffetZone.ID)
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	assert_eq(def.banner_offsets.size(), 2)
	for offset: Vector3 in def.banner_offsets:
		var at: Vector3 = hub + offset
		assert_lt(layout.path_weight(at.x, at.z), 0.05, "no banner pole on a path (%.1f, %.1f)" % [at.x, at.z])
		for dx: float in [-0.6, 0.6]:
			assert_lt(layout.path_weight(at.x + dx, at.z), 0.5, "nor at its edge")
	var statue: Vector3 = RulerPresence.statue_position(def, hub)
	assert_lt(layout.path_weight(statue.x, statue.z), 0.05, "the statue stands off the paving")
	assert_gte(BuffetLayout.edge_distance(statue.x, statue.z), 2.0, "on the table")
	# the plaque can be read: the spot in front of it can be stood on
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_true(builder.is_walkable(statue + Vector3(0.0, 0.0, 1.2), 0.3), "the plaque's spot is free")
	# the statue is carved of warm stone here, not pale blue-grey
	var figure: MeshInstance3D = RulerPresence.ruler_figure(BuffetZone.ID, def.ruler_tint)
	if figure != null:
		var stone: Color = (figure.material_override as ShaderMaterial).get_shader_parameter("stone") as Color
		assert_gt(stone.r, stone.b + 0.1, "warm stone (%s)" % stone)
		figure.free()
