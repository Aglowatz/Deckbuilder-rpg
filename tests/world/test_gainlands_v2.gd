extends GutTest
## Gainlands v2 (docs/art/gainlands_v2.md): the entrance and the plaza (Part C).

var layout: GainlandsLayout
var builder: GainlandsBuilder


func before_all() -> void:
	var host: Node3D = Node3D.new()
	add_child(host)
	builder = GainlandsBuilder.new()
	builder.build(host)
	layout = builder.layout


func after_all() -> void:
	builder.root.get_parent().queue_free()


func test_the_bridge_arrives_at_a_stone_gateway() -> void:
	var gateway: Node3D = builder.root.find_child("StoneGateway", false, false) as Node3D
	assert_not_null(gateway, "a stone gateway stands at the bridge head")
	if gateway == null:
		return
	assert_almost_eq(gateway.position.x, GainlandsLayout.BRIDGE_X, 0.01, "centred on the bridge")
	assert_between(gateway.position.z, GainlandsLayout.BRIDGE_Z0, GainlandsLayout.BRIDGE_Z0 + 2.5, "at the bridge head, on the rim")
	assert_gte((gateway.get_meta("circles", []) as Array).size(), 2, "its pillars block")
	for side: float in [-1.0, 1.0]:
		var pillar: Vector3 = Vector3(gateway.position.x + side * (GainlandsLayout.BRIDGE_HALF_WIDTH + 0.9), 0.0, gateway.position.z)
		assert_false(builder.is_walkable(pillar, 0.3), "the pillar on the %s is solid" % ("west" if side < 0.0 else "east"))
	assert_true(builder.is_walkable(Vector3(GainlandsLayout.BRIDGE_X, 0.0, gateway.position.z), 0.3), "the way through the gateway is open")
	var bridge: Node3D = builder.root.find_child("Bridge", false, false) as Node3D
	assert_eq(float(bridge.get_meta("height", 0.0)), 3.9, "the bridge's own timber gate is gone (only the far landing posts)")
	assert_eq(gateway.find_children("*", "Label3D", true, false).size(), 0, "no lettering")


func test_the_round_platform_is_gone_and_a_solid_gym_hall_splits_the_plaza() -> void:
	assert_null(builder.root.find_child("Landmark_GAIN-HERO-SWOLE-STATION", true, false), "the round Swole Station platform is gone")
	for prop: GainlandsLayout.Prop in layout.props:
		assert_ne(prop.kind, "station", "no station prop in the layout")
	var hall: Node3D = builder.root.find_child("GymHall", false, false) as Node3D
	assert_not_null(hall, "the gym hall stands in the plaza")
	if hall == null:
		return
	var rect: Rect2 = GainlandsLayout.GYM_HALL
	assert_almost_eq(Vector2(hall.position.x, hall.position.z).distance_to(rect.get_center()), 0.0, 0.01, "on the layout's rectangle")
	assert_gte(float(hall.get_meta("height", 0.0)), StorybookScale.STOREY_H * 2.5, "a real building: two storeys and a roof")
	assert_true(hall.has_meta("emblem"), "a dumbbell emblem in the gable")
	assert_eq(hall.find_children("*", "Label3D", true, false).size(), 0, "an icon, no lettering")
	assert_true(hall.has_meta("standin"), "tagged STANDIN until its concept art exists")
	# full collision: every point of the footprint is solid, the ground just outside every wall is open
	for fx: float in [0.05, 0.5, 0.95]:
		for fz: float in [0.05, 0.5, 0.95]:
			var p: Vector2 = rect.position + rect.size * Vector2(fx, fz)
			assert_false(builder.is_walkable(Vector3(p.x, 0.0, p.y), 0.05), "the hall is solid at (%.1f, %.1f)" % [p.x, p.y])
	# the lanes round it: west and east of the hall, and behind it to the foot of the middle road
	for probe: Vector2 in [Vector2(rect.position.x - 2.0, rect.get_center().y), Vector2(rect.end.x + 2.0, rect.get_center().y), Vector2(rect.get_center().x, rect.position.y - 1.8)]:
		assert_true(builder.is_walkable(Vector3(probe.x, 0.0, probe.y), 0.3), "the lane at (%.1f, %.1f) is open" % [probe.x, probe.y])
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	assert_false(rect.grow(GainlandsLayout.PLAZA_RADIUS * 0.5).has_point(Vector2(hub.x, hub.z)), "the open square in front of it stays open")
	assert_gte(rect.end.y, hub.z - GainlandsLayout.PLAZA_RADIUS - 4.0, "it splits the plaza: the square's north half")


## From the gateway the hero sees all three path heads: nothing solid stands between the bridge head and the lanes that lead to them.
func test_clear_sightlines_from_the_entrance_to_the_three_path_heads() -> void:
	var from: Vector3 = Vector3(GainlandsLayout.BRIDGE_X, 0.0, GainlandsLayout.BRIDGE_Z0 + 1.0)
	var heads: Dictionary = {"left": layout.route("left")[0], "right": layout.route("right")[0], "middle lane west": Vector2(46.5, 70.0), "middle lane east": Vector2(65.5, 70.0)}
	for key: String in heads.keys():
		var head: Vector2 = heads[key] as Vector2
		assert_true(builder.has_line_of_sight(from, Vector3(head.x, 0.0, head.y)), "a clear line from the gateway to the %s head" % key)
	# the vendor, the tub, the portal and the mirror stand on the plaza's edges, not in the way
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	for key: String in ["rift_station", "tony", "heal", "flex_mirror"]:
		var anchor: Vector3 = layout.anchors[key] as Vector3
		assert_gt(Vector2(anchor.x - hub.x, anchor.z - hub.z).length(), GainlandsLayout.PLAZA_RADIUS + 3.0, "%s stands at the plaza's edge" % key)
		assert_gt(absf(anchor.x - GainlandsLayout.BRIDGE_X), 8.0, "%s is off the line from the bridge" % key)


# ---- Part D: scale, gym-first decoration, trees, power lines ---------------------------------------------------------------


func test_the_windmills_are_proper_multi_storey_mills() -> void:
	var mills: int = 0
	for child: Node in builder.root.get_children():
		if child.name.begins_with("TowerMill"):
			mills += 1
			assert_gte(float(child.get_meta("height", 0.0)), StorybookScale.STOREY_H * 4.0, "%s stands four storeys and more (the KayKit mill was 4.4 m)" % child.name)
			assert_true(child.has_meta("spinner"), "its sails turn")
	assert_eq(mills, 3, "three tower mills in the mill lands")
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind == "mill":
			assert_eq(GainlandsLayout.level_at(prop.pos.x, prop.pos.z), 1, "each mill stands on the plateau")
	assert_lt(float(GainlandsBuilder.SCALE_FIX["bench_press"]), 0.8, "the bench press shrank to storybook size (was a 3.8 m bar)")
	assert_gt(float(GainlandsBuilder.SCALE_FIX["stall"]), 1.0, "the stalls grew to a door's height and more")


func test_gym_equipment_is_the_decoration_in_yards_off_the_routes() -> void:
	assert_gte(layout.yards.size(), 6, "lifting yards at the path edges and in the side pockets")
	var kinds: Dictionary = {}
	for yard: Dictionary in layout.yards:
		var rect: Rect2 = Rect2((yard["center"] as Vector2) - (yard["size"] as Vector2) * 0.5, yard["size"] as Vector2)
		assert_eq(GainlandsLayout.level_at(rect.get_center().x, rect.get_center().y), 1, "%s stands on the plateau" % str(yard["id"]))
		for item: Variant in yard["items"] as Array:
			var data: Dictionary = item as Dictionary
			kinds[str(data["kind"])] = true
			var pos: Vector3 = data["pos"] as Vector3
			var radius: float = float(data["radius"])
			assert_gte(layout.path_edge_distance(pos.x, pos.z) - radius, 0.5, "%s in %s keeps off the paving" % [str(data["kind"]), str(yard["id"])])
			# the middle road proper: the ridge from behind the gym hall to the stairs, where the fights are
			var ridge: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(pos.x, pos.z), Vector2(56.0, 55.6), Vector2(56.0, 9.0))
			assert_gt(ridge.distance_to(Vector2(pos.x, pos.z)), 8.0, "no yard on the middle road (%s)" % str(yard["id"]))
		assert_true(builder.root.find_child("Yard_%s" % str(yard["id"]), false, false) != null, "%s is built" % str(yard["id"]))
	for kind: String in ["squat_rack", "bench", "dumbbell_rack", "kettlebell_rack", "atlas_stones", "tire_pair", "sled_track", "pullup_frame", "rope_station", "plate_stack", "chalk_bucket"]:
		assert_true(kinds.has(kind), "the yards have a %s" % kind)
	assert_eq(layout.yard_rects().size(), layout.yards.size(), "each yard has its rubber mat (the painted gym mask)")


func test_few_hardy_trees_and_no_flowers() -> void:
	var trees: int = 0
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind == "tree" and GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z):
			trees += 1
	assert_lte(trees, GainlandsLayout.TREE_COUNT, "a few hardy trees (was 74)")
	assert_not_null(builder.root.find_child("HardyTrees0", false, false), "wind-bent trees")
	assert_not_null(builder.root.find_child("HardyTrees1", false, false), "cypress accents")
	for item: Variant in ZoneDressing.recipe(StylePresets.GAINLANDS)["items"] as Array:
		var model: String = str((item as Array)[1])
		assert_false(model.begins_with("flower") or model.begins_with("mushroom"), "no %s in the Gainlands scatter (dry scrub only)" % model)


func test_power_lines_cross_the_zone_on_believable_pylons() -> void:
	assert_gte(layout.power_lines.size(), 2, "power lines across the zone")
	var crosses_middle: bool = false
	var middle: PackedVector2Array = layout.route("middle")
	for line: Variant in layout.power_lines:
		var points: Array = line as Array
		assert_gte(points.size(), 3, "a line of several towers")
		for point: Variant in points:
			var base: Vector3 = point as Vector3
			assert_false(GainlandsLayout.is_main_ground(base.x, base.z) and not GainlandsLayout.CAVE_CLIFF.has_point(Vector2(base.x, base.z)), "every tower stands off the walkable land (on a sandstone stack or the cave's cliff)")
		for i: int in range(points.size() - 1):
			var a: Vector3 = points[i] as Vector3
			var b: Vector3 = points[i + 1] as Vector3
			assert_between(Vector2(b.x - a.x, b.z - a.z).length(), 12.0, 60.0, "a believable span")
			for k: int in range(middle.size() - 1):
				if Geometry2D.segment_intersects_segment(Vector2(a.x, a.z), Vector2(b.x, b.z), middle[k], middle[k + 1]) != null:
					crosses_middle = true
	assert_true(crosses_middle, "a line crosses the canyons and the middle road")
	assert_between(GainlandsStructures.PYLON_H, StorybookScale.HERO_HEIGHT * 8.0, StorybookScale.HERO_HEIGHT * 11.0, "towers tower over the hero without dwarfing the fortress")
	for index: int in range(1, layout.power_lines.size() + 1):
		var cables: Node = builder.root.find_child("Cables%d" % index, false, false)
		assert_not_null(cables, "line %d has its cables" % index)
		for sag: Variant in cables.get_meta("sag", []) as Array:
			assert_gt(float(sag), 0.5, "the cables sag naturally")
