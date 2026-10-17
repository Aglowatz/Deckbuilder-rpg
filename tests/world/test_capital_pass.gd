extends GutTest
## The Capital pass (docs/art/capital_pass.md), Part B: the blocky stand-ins are kit models, nothing rigid sways, the great wall has its towers
## and closed corners, and the land round the map (`CapitalRim`) is flush at the walkable edge, rises beyond it and never rises between the
## camera (which always trails south of the hero) and the hero.

## The props the layout places (kind, variant), built from the kit: none of them is a raw box, cylinder or sphere.
const PROP_KINDS: Array[Array] = [
	["gate_barrier", 0], ["lamp_street", 0], ["queue_post", 0], ["height_post", 0], ["booth", 1], ["toppled_statue", 0], ["tunnel_hatch_cover", 0],
	["campfire", 0], ["wreck_stack", 0], ["rift_crystals", 0], ["fountain", 0], ["lamp_perfect", 0], ["bench", 0], ["portrait", 0], ["portrait", 1],
	["loudspeaker", 0], ["complaint_box", 0], ["manhole", 0], ["junk_pile", 0], ["compost_heap", 0], ["sick_patch", 0], ["stall_shack", 0],
	["seed_jar", 0], ["grave", 0], ["parlor", 0], ["permit_office", 0], ["notary_booth", 0], ["family_plot", 0], ["energy_wheel", 0],
	["crate_stack", 0], ["pylon", 0], ["power_cable", 0], ["paste_dispenser", 0], ["kitchen_cart", 0], ["recipe_card", 0], ["window_booth", 0],
	["bed", 0], ["booth", 2],
]

var layout: CapitalLayout
var rim: CapitalRim


func before_all() -> void:
	layout = CapitalLayout.new()
	layout.build()
	var holder: Node3D = Node3D.new()
	rim = CapitalRim.build(holder, layout)
	holder.free()


func _prop(kind: String, variant: int) -> Node3D:
	var prop: CapitalLayout.Prop = CapitalLayout.Prop.new()
	prop.kind = kind
	prop.variant = variant
	return CapitalProps.build(prop, {"free": {}, "dark": false, "final": false}, ZoneStoryText.for_zone(CapitalZone.ID))


## The raw primitive meshes under `node` (BoxMesh, CylinderMesh, SphereMesh, PrismMesh), skipping a quest state's small overlay (the defaced
## portrait's moustache) and particles.
func _primitives(node: Node) -> Array[String]:
	var out: Array[String] = []
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh: Mesh = (child as MeshInstance3D).mesh
		if mesh is BoxMesh or mesh is CylinderMesh or mesh is SphereMesh or mesh is PrismMesh:
			if str(node.get_path_to(child)).contains("Defaced"):
				continue
			out.append(str(node.get_path_to(child)))
	return out


func test_the_capital_props_are_kit_models_not_primitives() -> void:
	for entry: Array in PROP_KINDS:
		var node: Node3D = _prop(str(entry[0]), int(entry[1]))
		assert_not_null(node, "%s builds" % str(entry[0]))
		if node == null:
			continue
		add_child_autofree(node)
		assert_eq(_primitives(node), [] as Array[String], "%s (variant %d) is built from the kit, not raw primitives" % [str(entry[0]), int(entry[1])])


func test_nothing_rigid_in_the_capital_sways() -> void:
	var root: Node3D = Node3D.new()
	root.name = "Capital"
	add_child_autofree(root)
	for entry: Array in PROP_KINDS:
		var node: Node3D = _prop(str(entry[0]), int(entry[1]))
		if node != null:
			root.add_child(node)
	for node: Node3D in [CapitalLandmarks.wall_piece(30.0, 9.0, 4.0, 3, [0.0] as Array[float]), CapitalLandmarks.corner_tower(4.0, 9.0), CapitalLandmarks.gate_tower(5.0, 14.0, 5.0),
			CapitalLandmarks.build({"id": "CAP-HERO-RESISTANCE-CAMP"}), CapitalLandmarks.build({"id": "CAP-HERO-WATCHTOWER"}), CapitalLandmarks.ruin_fragment(4.0, 2.5, 3),
			CapitalLandmarks.ruined_house(6.0, 4.0, 4.0, 5.0, 1), CapitalLandmarks.build({"id": "CAP-HERO-PRIMMS-CASTLE"})]:
		root.add_child(node)
	StyleToon.apply(root, 1.0)
	assert_eq(PlanView.swaying(root), PackedStringArray(), "no wall, tower, prop, ruin, tent or castle moves in the wind")


func test_the_great_wall_has_its_towers_and_closed_corners() -> void:
	var piece: Node3D = CapitalLandmarks.wall_piece(40.0, 9.0, 4.0, 1, [-10.0, 10.0] as Array[float])
	add_child_autofree(piece)
	assert_gt(int(piece.get_meta("triangles", 0)), 2000, "pilasters, courses, crenellations, towers: a wall, not a slab")
	assert_gte(CapitalLayout.WALL_TOWERS.size(), 4, "towers stand out along the front wall")
	for tower_x: float in CapitalLayout.WALL_TOWERS:
		assert_false(tower_x > float(CapitalLayout.GATE_X0) - 8.0 and tower_x < float(CapitalLayout.GATE_X1) + 9.0, "no tower crowds the gate")
		for dx: float in [-1.5, 0.0, 1.5]:
			assert_ne(layout.cell_at(int(tower_x + dx), CapitalLayout.WALL_Z1 + 1), CapitalLayout.Cell.GROUND, "the tower at x %.0f stands on solid ground" % tower_x)
	# the corner towers cover the ends of the front wall and the side walls
	for corner_x: float in CapitalBuilder.CORNER_TOWERS:
		assert_lt(absf(corner_x - (0.5 if corner_x < 60.0 else 119.5)), 0.01)
	assert_true(FileAccess.get_file_as_string("res://world/capital/capital_builder.gd").contains("corner_tower"), "the builder places the corner towers")


func test_the_box_edges_are_gone() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/capital/capital_builder.gd")
	assert_false(source.contains("AshEdge"), "no stepped box wall along the outside's sides")
	assert_false(source.contains("_rock_wall"), "no cut-box rubble along the south edge")
	var recipe: Dictionary = ZoneDressing.recipe(StylePresets.CAPITAL_OUTSKIRTS)
	for item: Array in recipe["items"] as Array:
		assert_true(str(item[1]).begins_with("grass"), "the outside scatter carries no low-poly blocks: %s" % str(item[1]))


func test_the_rim_is_flush_at_the_walkable_edge_and_rises_beyond() -> void:
	# every walkable outside cell's corners sit at the floor's height
	var checked: int = 0
	for cz: int in range(CapitalLayout.WALL_Z1 + 1, CapitalLayout.OUT_Z1 + 1):
		for cx: int in [2, 117]:
			if layout.cell_at(cx, cz) != CapitalLayout.Cell.GROUND:
				continue
			for vertex: Vector2i in [Vector2i(cx, cz), Vector2i(cx + 1, cz)]:
				assert_almost_eq(rim.height_at(vertex.x, vertex.y), 0.0, 0.01, "the rim meets the floor at (%d, %d)" % [vertex.x, vertex.y])
				checked += 1
	assert_gt(checked, 40)
	# a few metres out to the sides it is a ridge (the blocker you see), and the ridge carries rocks, rubble and dead trees
	var high: int = 0
	for cz: int in range(80, 120, 4):
		if rim.height_at(-6, cz) > 2.0:
			high += 1
		if rim.height_at(126, cz) > 2.0:
			high += 1
	assert_gt(high, 14, "ridges rise west and east of the outside")
	assert_gt(rim.trees, 40, "dead trees on the ridges")
	assert_gt(rim.rocks + rim.rubble, 40, "rocks and rubble at the foot of the rise")


func test_the_rim_never_rises_between_the_camera_and_the_hero() -> void:
	# the camera trails about 12 m south of the hero and 7.5 m up: south of the walkable ground the rim stays under that line
	for cx: int in range(2, 118, 3):
		for k: int in range(1, 14):
			var line: float = 0.9 + 6.6 * float(k) / 12.0
			assert_lt(rim.height_at(cx, CapitalLayout.OUT_Z1 + 1 + k), line, "the rim %d m south of the edge at x %d keeps under the camera's line" % [k, cx])


func test_the_road_to_crosspath_runs_on_between_the_hills() -> void:
	for cz: int in range(CapitalLayout.ROAD_BEYOND.position.y, CapitalLayout.ROAD_BEYOND.end.y):
		assert_eq(layout.cell_at(60, cz), CapitalLayout.Cell.VOID, "the road beyond the edge is seen, never walked")
		assert_eq(layout.floor_at(60, cz), CapitalLayout.Floor.ROAD, "and drawn as road")
		assert_almost_eq(rim.height_at(60, cz), 0.0, 0.01, "no hill on the road")
	assert_gt(rim.height_at(48, CapitalLayout.OUT_Z1 + 7), 1.0, "hills either side of it")
	assert_gt(rim.height_at(72, CapitalLayout.OUT_Z1 + 7), 1.0)


func test_the_city_floor_meets_its_walls() -> void:
	# the floor ends where the walls' battered feet begin: the hero never stops short of a wall, never walks into one
	assert_eq(layout.cell_at(116, 30), CapitalLayout.Cell.GROUND)
	assert_eq(layout.cell_at(117, 30), CapitalLayout.Cell.VOID, "the east wall's foot (x 117 on)")
	assert_eq(layout.cell_at(2, 30), CapitalLayout.Cell.GROUND)
