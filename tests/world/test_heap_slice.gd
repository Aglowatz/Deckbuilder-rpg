extends GutTest
## The Verdant Dump slice, Part A (docs/art/heap_slice.md): one walkable zone in six regions laid out by the declutter rules of the playbook (section 5)
## before any art arrives. The way in is a walked bridge, the Commons an open plaza round the greenhouse stand-in, the routes wide and clear, props in
## clusters at the edges, trees only at the edges and in framing groups, flowers in clumps along the paths that thin toward the Rotheart, the stand-in
## landmarks of the right size standing clear or beyond the rim, the corruption gradient read from data, the paint-over cameras as layout data.

const TREES: Array[String] = ["tree", "bush", "rock", "mushrooms"]

var layout: HeapLayout


func before_all() -> void:
	layout = HeapLayout.new()
	layout.build()


## The things that stand at an anchor (the table at the heal spot, the stable at its spot...): their own prop is not clutter round them.
func _anchored_feature(prop: HeapLayout.Prop) -> bool:
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < 4.0:
			return true
	return false


func test_the_six_regions_are_the_brief_regions() -> void:
	var ids: Dictionary = {}
	for area: HeapLayout.Area in layout.areas:
		ids[area.id] = area.title
	for id: String in HeapLayout.REGION_IDS:
		assert_true(ids.has(id), "region %s exists" % id)
	assert_eq(str(ids.get("commons", "")), "Compost Commons")
	assert_eq(str(ids.get("throne", "")), "The Throne Approach")
	# the regions name the spots that belong to them
	var expect: Dictionary = {"hub": "commons", "heal": "commons", "quiz": "farm", "crop_1": "farm", "minigame": "peaks", "mound_a": "peaks", "sorrel": "stream", "barricade_dam": "stream", "main_dungeon": "wetlands", "mini_dungeon": "throne", "puzzle": "throne"}
	for key: String in expect.keys():
		var pos: Vector3 = layout.anchors[key] as Vector3
		var area: HeapLayout.Area = layout.area_at(pos.x, pos.z)
		assert_eq(area.id if area != null else "", str(expect[key]), "%s stands in the %s region" % [key, str(expect[key])])
	for id: String in ["chest_barn", "chest_scree_ne"]:
		var chest: Vector3 = layout.chests[id] as Vector3
		assert_eq(layout.area_at(chest.x, chest.z).id, "peaks", "%s lies on the scree under Junk Mountain, the junk peaks' north half" % id)


func test_routes_are_wide_and_nothing_solid_stands_on_them() -> void:
	for path: Dictionary in layout.paths:
		var width: float = float(path["width"])
		assert_gte(width, HeapLayout.SIDE_PATH_WIDTH, "every route is at least %.1f m wide" % HeapLayout.SIDE_PATH_WIDTH)
	var main_roads: int = 0
	for path: Dictionary in layout.paths:
		if float(path["width"]) >= HeapLayout.MAIN_PATH_WIDTH:
			main_roads += 1
	assert_gte(main_roads, 8, "the roads off the plaza, the bank roads, the avenue and the wetlands road are four hero-widths")
	var on_route: Array[String] = []
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind in ["wall_tires", "divider", "junk_dam"] or _anchored_feature(prop):
			continue
		if prop.radius <= 0.0 and prop.kind not in TREES:
			continue
		if layout.path_edge_distance(prop.pos.x, prop.pos.z) < HeapLayout.PATH_CLEARANCE - 0.01:
			on_route.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	assert_eq(on_route, [] as Array[String], "nothing solid within %.1f m of a route edge" % HeapLayout.PATH_CLEARANCE)
	for blocker: Vector3 in HeapLayout.LANDMARK_BLOCKERS:
		if blocker.y < HeapLayout.MIN_CORNER.y + 2.0:
			continue  # the root gate and the throne steps stand at the ends of their roads
		assert_gte(layout.path_edge_distance(blocker.x, blocker.y) - blocker.z, HeapLayout.PATH_CLEARANCE - 0.01, "the landmark at (%.0f, %.0f) keeps off the routes" % [blocker.x, blocker.y])


func test_open_ground_round_every_anchor_and_chest() -> void:
	var crowded: Array[String] = []
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		for prop: HeapLayout.Prop in layout.props:
			if prop.kind not in TREES:
				continue
			if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < HeapLayout.ANCHOR_CLEARANCE - 0.01:
				crowded.append("%s near %s" % [prop.kind, str(key)])
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		for prop: HeapLayout.Prop in layout.props:
			if prop.kind in TREES and Vector2(prop.pos.x - chest.x, prop.pos.z - chest.z).length() < 1.9:
				crowded.append("%s on chest %s" % [prop.kind, str(id)])
	assert_eq(crowded, [] as Array[String], "every NPC, gate, pickup and chest can be reached without weaving round trees")
	# interactables never fight for the prompt
	var spots: Array[String] = ["heal", "compost_bin", "trough", "shrine", "stable_1", "stable_2", "rift_station", "wren", "hob", "marigold"]
	for a: String in spots:
		for b: String in spots:
			if a < b:
				var pa: Vector3 = layout.anchors[a] as Vector3
				var pb: Vector3 = layout.anchors[b] as Vector3
				assert_gt(Vector2(pa.x - pb.x, pa.z - pb.z).length(), 4.0, "%s and %s have breathing room" % [a, b])


func test_props_stand_in_clusters_at_the_edges_never_scattered() -> void:
	var kinds: Dictionary = {}
	for prop: HeapLayout.Prop in layout.props:
		kinds[prop.kind] = int(kinds.get(prop.kind, 0)) + 1
	for gone: String in ["arch", "landfill_gate", "composting_door", "windmill", "appliance_pile"]:
		assert_false(kinds.has(gone), "no %s: the stand-ins and the roadside wrecks are gone" % gone)
	assert_lte(int(kinds.get("tire_stack", 0)), 6, "tyre stacks only in the clusters (%d)" % int(kinds.get("tire_stack", 0)))
	assert_lte(int(kinds.get("junk_pile", 0)), 4, "junk piles only in the clusters")
	assert_lte(int(kinds.get("car_husk", 0)), 2, "a wreck hides a chest, another stands by the barn; no more")
	# every tree stands in a framing group at an edge: within 9 m of the rim, or within 6 m of two others
	var trees: int = 0
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind != "tree":
			continue
		trees += 1
		var near: int = 0
		for other: HeapLayout.Prop in layout.props:
			if other != prop and other.kind == "tree" and Vector2(prop.pos.x - other.pos.x, prop.pos.z - other.pos.z).length() < 6.0:
				near += 1
		assert_true(HeapLayout.edge_distance(prop.pos.x, prop.pos.z) < 9.0 or near >= 2, "tree at (%.0f, %.0f) frames an edge or stands in a group" % [prop.pos.x, prop.pos.z])
	assert_between(trees, 20, 62, "a few framing groups and the rim bands, not a wood (%d trees)" % trees)
	# flowers stand in clumps along the path edges (each within 3.5 m of a route edge or of the crop row)
	var flowers: int = 0
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind != "flowers":
			continue
		flowers += 1
		var by_crops: bool = prop.pos.z > 56.5 and prop.pos.z < 61.0 and prop.pos.x < 27.0
		assert_true(layout.path_edge_distance(prop.pos.x, prop.pos.z) < 3.5 or by_crops, "flowers at (%.0f, %.0f) line a path or the crop row" % [prop.pos.x, prop.pos.z])
	assert_gte(flowers, 40, "there are flower clumps (%d flowers)" % flowers)


func test_the_hub_plaza_is_open_round_the_greenhouse() -> void:
	var inside: Array[String] = []
	for prop: HeapLayout.Prop in layout.props:
		if prop.radius <= 0.0 and prop.kind not in TREES:
			continue
		if Vector2(prop.pos.x - HeapLayout.PLAZA_CENTER.x, prop.pos.z - HeapLayout.PLAZA_CENTER.y).length() < HeapLayout.PLAZA_RADIUS:
			inside.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	for sign: HeapLayout.Sign in layout.signs:
		if Vector2(sign.pos.x - HeapLayout.PLAZA_CENTER.x, sign.pos.z - HeapLayout.PLAZA_CENTER.y).length() < HeapLayout.PLAZA_RADIUS:
			inside.append(sign.key)
	assert_eq(inside, [] as Array[String], "nothing solid and no board inside the plaza (%.1f m) but the greenhouse" % HeapLayout.PLAZA_RADIUS)
	assert_true(HeapLayout.GREENHOUSE.is_equal_approx(HeapLayout.PLAZA_CENTER), "the greenhouse stand-in is the plaza's centrepiece")
	assert_gte(HeapLayout.GREENHOUSE_SIZE.x, 8.0, "a greenhouse-sized stand-in")
	var wake: Vector3 = layout.anchors["hub"] as Vector3
	assert_lt(Vector2(wake.x - HeapLayout.PLAZA_CENTER.x, wake.z - HeapLayout.PLAZA_CENTER.y).length(), HeapLayout.PLAZA_RADIUS, "the hub anchor (where you wake) is in the plaza")
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_false(builder.is_walkable(Vector3(HeapLayout.PLAZA_CENTER.x, 0.0, HeapLayout.PLAZA_CENTER.y), 0.3), "the greenhouse is solid")
	assert_true(builder.is_walkable(wake, 0.3), "the wake point is open ground")
	# the hub's things stand round the rim, 4 m or more apart (checked above), the barn and the shed off the plaza
	for key: String in ["heal", "hob", "wren", "marigold", "rift_station", "compost_bin", "stable_1"]:
		var pos: Vector3 = layout.anchors[key] as Vector3
		var distance: float = Vector2(pos.x - HeapLayout.PLAZA_CENTER.x, pos.z - HeapLayout.PLAZA_CENTER.y).length()
		assert_between(distance, HeapLayout.PLAZA_RADIUS - 1.0, 22.0, "%s stands on the plaza's rim (%.1f m)" % [key, distance])


func test_few_sign_boards_each_with_a_pictogram_and_the_quiz_answers_stay() -> void:
	assert_lte(layout.signs.size(), 24, "the boards that label something (was 35)")
	var keys: Array[String] = []
	for sign: HeapLayout.Sign in layout.signs:
		assert_true(HeapBuilder.SIGN_ICONS.has(sign.key), "%s has an icon" % sign.key)
		assert_ne(sign.style, "memo", "no memos (%s)" % sign.key)
		assert_ne(sign.style, "poster", "no posters (%s)" % sign.key)
		keys.append(sign.key)
	for needed: String in ["sign.hub_main", "sign.oath", "sign.crops", "sign.fields", "sign.main_dungeon", "sign.landfill", "sign.exit", "sign.barricade", "sign.dam"]:
		assert_has(keys, needed, "%s stays (a quiz answer or a label)" % needed)


func test_the_way_in_is_a_walkable_bridge_not_a_portal() -> void:
	var spawn: Vector3 = layout.anchors["spawn"] as Vector3
	var exit: Vector3 = layout.anchors["exit"] as Vector3
	assert_eq(layout.surface_at(spawn.x, spawn.z), HeapLayout.Surface.BRIDGE, "the hero arrives on the bridge")
	assert_eq(layout.surface_at(exit.x, exit.z), HeapLayout.Surface.BRIDGE, "the exit is the far end of the bridge")
	assert_gt(exit.z, spawn.z, "the exit is behind the arriving hero (town side); the zone opens up ahead")
	assert_gte((HeapLayout.ENTRANCE_HALF_WIDTH - HeapLayout.ENTRANCE_RAIL) * 2.0, 2.8, "the deck between the kerbs is four hero-widths")
	assert_gt(HeapLayout.edge_distance(HeapLayout.ENTRANCE_X, HeapLayout.ENTRANCE_Z0 + 0.5), 0.0, "the near end stands on the land")
	assert_lt(HeapLayout.edge_distance(HeapLayout.ENTRANCE_X, HeapLayout.ENTRANCE_Z1 - 1.0), 0.0, "the far end is out over the overflow pool")
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_true(builder.is_walkable(spawn, 0.3), "the arrival point is walkable")
	assert_true(builder.is_walkable(exit, 0.3), "the exit landing is walkable")
	assert_false(builder.is_walkable(Vector3(HeapLayout.ENTRANCE_X + HeapLayout.ENTRANCE_HALF_WIDTH, 0.0, HeapLayout.ENTRANCE_Z1 - 8.0), 0.3), "the kerbs hold the hero on the deck")
	assert_true(builder.map_bounds().has_point(Vector2(exit.x, exit.z)), "the map bounds reach the far landing")
	assert_almost_eq(builder.height_at(spawn), 0.0, 0.001, "the hero stands on the deck")
	assert_almost_eq(builder.height_at(Vector3(HeapLayout.ENTRANCE_X, 0.0, HeapLayout.ENTRANCE_Z0 + 1.0)), 0.0, 0.25, "the land meets the deck level at the bridge head (no step)")
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var missing: Array[String] = WalkProbe.unreachable(can_stand, spawn, builder.map_bounds(), {"hub": layout.anchors["hub"], "heal": layout.anchors["heal"], "quiz": layout.anchors["quiz"], "minigame": layout.anchors["minigame"], "mound_a": layout.anchors["mound_a"], "giant_chest": layout.anchors["giant_chest"], "vault_lever": layout.anchors["vault_lever"]}, 2.5)
	assert_eq(missing, [] as Array[String], "the bridge leads into the plaza and on to every region south of the stream")
	var no_props: int = 0
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind == "arch":
			no_props += 1
	assert_eq(no_props, 0, "the tyre arch (the old portal) is gone")
	# the town side: the Dump's passageway has no glow at its end
	var passage: Node3D = TownPassages.build("refusemancer", "The Verdant Dump", Color.GREEN, false)
	add_child_autofree(passage)
	assert_null(passage.find_child("FarGlow", true, false), "no portal glow at the end of the Dump passage")


func test_the_landmarks_stand_clear_or_beyond_the_rim() -> void:
	# the views: the Rotheart beyond the north rim at castle scale, Junk Mountain beyond the north-east corner, the throne beyond the north-west rim
	assert_lt(HeapLayout.ROTHEART.y, HeapLayout.MIN_CORNER.y, "the Rotheart stands north of the land")
	assert_gte(HeapLayout.ROTHEART_SIZE.y, 40.0, "the Rotheart is castle scale (%.0f m)" % HeapLayout.ROTHEART_SIZE.y)
	assert_gte(HeapLayout.ROTHEART_SIZE.x, 40.0)
	assert_lt(HeapLayout.JUNK_MOUNTAIN.y, HeapLayout.MIN_CORNER.y)
	assert_gt(HeapLayout.JUNK_MOUNTAIN.x, HeapLayout.MAX_CORNER.x, "Junk Mountain lies beyond the north-east corner")
	assert_lt(HeapLayout.THRONE.y + HeapLayout.THRONE_SIZE.z * 0.5, HeapLayout.MIN_CORNER.y, "the throne's dais is beyond the north rim; only its steps reach the land")
	assert_lt(Vector2(HeapLayout.ROTHEART.x - 50.0, 0.0).length(), 6.0, "the Rotheart stands on the zone's centre line, seen from most of it")
	# the region landmarks: flat kept-clear ground, edge off every anchor and route
	for spot: Vector3 in HeapLayout.LANDMARK_SPOTS:
		assert_true(spot in layout.flat_spots, "the ground under (%.1f, %.1f) is flat" % [spot.x, spot.y])
		for key: Variant in layout.anchors.keys():
			if str(key) in ["main_dungeon", "mini_dungeon", "hub"]:
				continue  # the doors stand at their landmark's foot; the hub anchor is the plaza's open half
			var anchor: Vector3 = layout.anchors[key] as Vector3
			var gap: float = Vector2(spot.x - anchor.x, spot.y - anchor.z).length() - spot.z
			assert_gte(gap, 1.5, "%s stays off the landmark at (%.1f, %.1f) (%.1f m)" % [str(key), spot.x, spot.y, gap])
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind in TREES or prop.kind == "flowers":
			for spot: Vector3 in HeapLayout.LANDMARK_SPOTS:
				assert_gte(Vector2(prop.pos.x - spot.x, prop.pos.z - spot.y).length(), spot.z - 0.01, "no %s under the landmark at (%.1f, %.1f)" % [prop.kind, spot.x, spot.y])
	# the built models
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: HeapBuilder = HeapBuilder.new()
	builder.build(host)
	for id: String in ["HEAP-HERO-ROTHEART", "HEAP-HERO-JUNK-MOUNTAIN", "HEAP-HERO-TRASH-PANDA-THRONE", "HEAP-HERO-RUSTY-WINDMILL", "HEAP-GREENHOUSE", "HEAP-ROOT-GATE"]:
		var node: Node3D = builder.landmarks.get(id) as Node3D
		assert_not_null(node, "%s stands in the zone" % id)
		if node == null:
			continue
		assert_eq(node.get_parent(), builder.root, "%s hangs off the root, never a chunk" % id)
		for piece: Node in node.find_children("*", "MeshInstance3D", true, false):
			assert_true(piece.has_meta(&"no_range_cull"), "%s never culls" % id)
			if id in ["HEAP-HERO-ROTHEART", "HEAP-HERO-JUNK-MOUNTAIN", "HEAP-HERO-TRASH-PANDA-THRONE"]:
				assert_true(piece.has_meta(&"no_occlusion_fade"), "%s never fades" % id)
	assert_not_null(builder.rotheart)
	assert_almost_eq(float(builder.rotheart.get_meta("height", 0.0)), HeapLayout.ROTHEART_SIZE.y, 0.01, "the Rotheart stand-in is the planned height")
	# the doors still work: the hero stands at the root gate and at the throne's steps; the region landmarks are solid
	var gate: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_true(builder.is_walkable(gate + Vector3(0.0, 0.0, 1.4), 0.3), "the hero can stand at the Rotheart's root gate")
	assert_false(builder.is_walkable(Vector3(HeapLayout.ROOT_GATE.x, 0.0, HeapLayout.ROOT_GATE.y - 1.5), 0.1), "the root gate's hollow is solid")
	var door: Vector3 = layout.anchors["mini_dungeon"] as Vector3
	assert_true(builder.is_walkable(door + Vector3(0.0, 0.0, 1.6), 0.3), "the hero can stand at the throne's steps")
	assert_false(builder.is_walkable(Vector3(HeapLayout.WINDMILL.x, 0.0, HeapLayout.WINDMILL.y), 0.1), "the windmill's tower is solid")
	assert_true((builder.landmarks["HEAP-HERO-RUSTY-WINDMILL"] as Node3D).has_meta("spinner"), "the windmill's sails turn")
	for key: String in ["crop_1", "quiz", "pickup_bean_1", "pickup_fert_1"]:
		var anchor: Vector3 = layout.anchors[key] as Vector3
		assert_gte(Vector2(anchor.x - HeapLayout.WINDMILL.x, anchor.z - HeapLayout.WINDMILL.y).length() - HeapLayout.WINDMILL_SIZE.x * 0.5, 3.0, "the windmill keeps %s clear" % key)
	# the entrance bridge and the terrain never dissolve under the hero
	var bridge: Node3D = builder.root.find_child("Bridge", false, false) as Node3D
	assert_not_null(bridge, "the zone builds the entrance bridge")
	if bridge != null:
		assert_gt((bridge.get_meta("circles", []) as Array).size(), 2, "its gate pillars and landing posts block")
		assert_true((bridge.find_child("Body", true, false) as Node).has_meta(&"no_occlusion_fade"), "the deck never dissolves under the hero")
	for name: String in ["Land", "FarGround", "RecyclingStream", "OverflowPool"]:
		var piece: Node = builder.root.find_child(name, false, false)
		assert_true(piece != null and piece.has_meta(&"no_occlusion_fade") and piece.has_meta(&"no_range_cull"), "%s never fades or culls" % name)


func test_the_corruption_gradient_comes_from_data() -> void:
	var data: Dictionary = ZoneStyles.style("heap").get("corruption", {}) as Dictionary
	assert_false(data.is_empty(), "data/zone_styles/heap.json has the corruption block")
	assert_eq(layout.corruption, data, "the layout reads it")
	assert_almost_eq(layout.corruption_at(50.0, 64.0), 0.0, 0.001, "the Commons are healthy")
	assert_almost_eq(layout.corruption_at(18.0, 60.0), 0.0, 0.001, "the farm rows are healthy")
	var bank: float = layout.corruption_at(50.0, 34.0)
	var wet: float = layout.corruption_at(50.0, 20.0)
	var roots: float = layout.corruption_at(50.0, 9.0)
	assert_lt(bank, wet, "the land grows more twisted past the barricade")
	assert_lt(wet, roots, "...and most at the Rotheart's roots")
	assert_gte(roots, 0.95, "full corruption at the roots")
	assert_lt(layout.corruption_at(16.0, 16.0), layout.corruption_at(50.0, 16.0), "the throne approach and the scree are less twisted than the wetlands")
	# fewer flowers north of the wall than south of the stream
	var north: int = 0
	var south: int = 0
	for prop: HeapLayout.Prop in layout.props:
		if prop.kind == "flowers":
			if prop.pos.z < HeapLayout.WALL_Z and prop.pos.x > HeapLayout.DIVIDER_XS[0] and prop.pos.x < HeapLayout.DIVIDER_XS[1]:
				north += 1
			elif prop.pos.z > 50.0:
				south += 1
	assert_lt(north, south / 3, "flowers thin toward the Rotheart (%d in the wetlands, %d in the south)" % [north, south])
	# the violet tint reaches the terrain colour
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: HeapBuilder = HeapBuilder.new()
	builder.build(host)
	var healthy: Color = builder._terrain_color(Vector3(30.0, 0.0, 60.0))
	var twisted: Color = builder._terrain_color(Vector3(50.0, 0.0, 12.0))
	assert_gt(twisted.b / maxf(twisted.g, 0.001), healthy.b / maxf(healthy.g, 0.001), "the wetlands' ground leans violet against the farm's green")
	assert_lt(twisted.get_luminance(), healthy.get_luminance(), "and darker")


func test_the_paint_over_cameras_are_layout_data_on_open_ground_facing_the_rotheart() -> void:
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	builder.mounted = false
	for name: String in ["po_hub", "po_junk_peaks", "po_farm_rows", "po_stream", "po_wetlands", "po_throne_approach"]:
		assert_true(HeapLayout.PO_CAMERAS.has(name), "%s is a camera spot" % name)
		var at: Vector2 = HeapLayout.PO_CAMERAS[name] as Vector2
		assert_true(builder.is_walkable(Vector3(at.x, 0.0, at.y), 0.3), "%s stands on open ground" % name)
		assert_false(layout.anchors.has(name), "%s is not an anchor" % name)
		assert_lt(HeapLayout.ROTHEART.y, at.y, "%s looks north toward the Rotheart" % name)
		var bearing: float = rad_to_deg(atan2(absf(HeapLayout.ROTHEART.x - at.x), at.y - HeapLayout.ROTHEART.y))
		assert_lt(bearing, 30.0, "%s has the Rotheart in frame (%.0f degrees off north)" % [name, bearing])


func test_a_fresh_visit_starts_on_the_bridge_facing_the_commons() -> void:
	var scene: HeapScene = (load("res://scenes/heap_zone.tscn") as PackedScene).instantiate() as HeapScene
	Session.new_game()
	scene.screenshot_prepare({"nohud": "true"})
	add_child(scene)
	await get_tree().process_frame
	assert_true(HeapLayout.on_entrance(scene.player.position.x, scene.player.position.z), "a fresh visit starts on the bridge")
	assert_lt(scene.player.position.z, HeapLayout.ENTRANCE_Z1 - 1.5, "the arrival point is well short of the walk-off end")
	scene._update_entrance_exit()
	assert_false(scene._locked, "arriving never trips the walk-off exit")
	var wake: Vector3 = scene._hub_spawn()
	assert_lt(Vector2(wake.x - HeapLayout.PLAZA_CENTER.x, wake.z - HeapLayout.PLAZA_CENTER.y).length(), HeapLayout.PLAZA_RADIUS, "waking after a faint puts the hero in the plaza, not on the bridge")
	for spot: ZoneSpot in scene.spots:
		if spot.kind in ["main_dungeon", "mini_dungeon"]:
			assert_false(spot.plate.visible, "%s: no lettered plate at the door (its board carries a pictogram)" % spot.id)
	assert_null(scene.heap.root.find_child("MM_tire_stack", false, false), "no scattered tyre multimesh")
	scene.queue_free()
	await get_tree().process_frame


func test_the_occlusion_fader_uses_a_smooth_transparency() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/style/occlusion_fader.gd")
	assert_false(source.contains("set_instance_shader_parameter(\"occlusion_fade\""), "the fader no longer drives the ordered dither")
	assert_true(source.contains("piece.transparency = "), "every faded piece uses the per-instance transparency")
