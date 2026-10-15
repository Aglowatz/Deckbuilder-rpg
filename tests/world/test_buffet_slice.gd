extends GutTest
## The Endless Buffet slice (docs/art/buffet_slice.md), Part A: the five hero landmarks are modelled from the approved concepts and placed inside the one zone
## by the declutter rules (the Test Kitchen and Potato Peak as views beyond the rim, never culled or faded; the Cake Cathedral, the Broccoli Giant and the
## Omakase Pavilion on flat kept-clear ground, clear of every anchor, chest and route), the stand-ins they replace are gone, the sky is the kit's dinner
## panorama over a dry table (no sea plane flooding the mash), and the cake skyline rings the horizon.

var layout: BuffetLayout


func before_all() -> void:
	layout = BuffetLayout.new()
	layout.build()


func test_the_five_hero_landmarks_build_from_the_concepts() -> void:
	var sizes: Dictionary = {
		"BUFF-HERO-TEST-KITCHEN": BuffetLayout.TEST_KITCHEN_SIZE, "BUFF-HERO-CAKE-CATHEDRAL": BuffetLayout.CAKE_CATHEDRAL_SIZE,
		"BUFF-HERO-POTATO-PEAK": BuffetLayout.POTATO_PEAK_SIZE, "BUFF-HERO-BROCCOLI-GIANT": BuffetLayout.BROCCOLI_GIANT_SIZE,
		"BUFF-HERO-OMAKASE-PAVILION": BuffetLayout.OMAKASE_PAVILION_SIZE,
	}
	for id: String in BuffetLandmarks.IDS:
		assert_true(HeroLandmarks.has_model(id), "%s has a model" % id)
		var size: Vector3 = sizes[id] as Vector3
		var node: Node3D = LandmarkKit.build({"id": id, "kind": "facade", "size": [size.x, size.y, size.z]})
		assert_not_null(node, "%s builds" % id)
		if node == null:
			continue
		assert_eq(str(node.get_meta("hero_id", "")), id, "%s is the modelled landmark, not a stand-in" % id)
		assert_gt(int(node.get_meta("triangles", 0)), 400, "%s is a real model" % id)
		assert_false((node.get_meta("circles", []) as Array).is_empty(), "%s blocks" % id)
		node.free()


func test_the_region_landmarks_stand_clear_of_anchors_chests_and_routes() -> void:
	# the plan: a flat kept-clear spot under each region landmark, its edge 5.5 m off every anchor and 2.4 m off every route edge (SR-8, GC-1)
	for spot: Vector3 in BuffetLayout.LANDMARK_SPOTS:
		assert_true(spot in layout.flat_spots, "the ground under (%.1f, %.1f) is flat" % [spot.x, spot.y])
		for key: Variant in layout.anchors.keys():
			if str(key) == "mini_dungeon" and spot.x == BuffetLayout.OMAKASE_PAVILION.x:
				continue  # the Pavilion IS the Walk-In Freezer door: the spot stands at its foot
			var anchor: Vector3 = layout.anchors[key] as Vector3
			var gap: float = Vector2(spot.x - anchor.x, spot.y - anchor.z).length() - spot.z
			assert_gte(gap, 1.5, "%s stays off the landmark at (%.1f, %.1f) (%.1f m)" % [str(key), spot.x, spot.y, gap])
		for path: Dictionary in layout.paths:
			var line: PackedVector2Array = path["line"] as PackedVector2Array
			for i: int in range(line.size() - 1):
				var closest: Vector2 = Geometry2D.get_closest_point_to_segment(Vector2(spot.x, spot.y), line[i], line[i + 1])
				var distance: float = closest.distance_to(Vector2(spot.x, spot.y)) - spot.z - float(path["width"]) * 0.5
				assert_gte(distance, 0.0, "no route runs under the landmark at (%.1f, %.1f)" % [spot.x, spot.y])
	# the built models: every blocking circle of a region landmark keeps the breathing room of its anchors, and no scattered prop stands under one
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.build(host)
	for id: String in ["BUFF-HERO-CAKE-CATHEDRAL", "BUFF-HERO-BROCCOLI-GIANT", "BUFF-HERO-OMAKASE-PAVILION"]:
		var node: Node3D = builder.landmarks.get(id) as Node3D
		assert_not_null(node, "%s stands in the zone" % id)
		if node == null:
			continue
		var basis: Basis = Basis(Vector3.UP, node.rotation.y)
		for circle: Variant in node.get_meta("circles", []) as Array:
			var local: Vector3 = circle as Vector3
			var world: Vector3 = node.position + basis * Vector3(local.x, 0.0, local.y)
			assert_false(builder.is_walkable(world, 0.1), "%s is solid at (%.1f, %.1f)" % [id, world.x, world.z])
			for chest_id: Variant in layout.chests.keys():
				var chest: Vector3 = layout.chests[chest_id] as Vector3
				assert_gte(Vector2(world.x - chest.x, world.z - chest.z).length() - local.z, 1.9, "%s leaves chest %s reachable" % [id, str(chest_id)])
			for key: Variant in ["quiz", "odalys", "main_dungeon", "puzzle", "minigame", "gate_quest", "gate_ingredient", "pickup_basil", "pickup_truffle"]:
				var anchor: Vector3 = layout.anchors[key] as Vector3
				var gap: float = Vector2(world.x - anchor.x, world.z - anchor.z).length() - local.z
				assert_gte(gap, 5.0, "%s keeps %s clear (%.1f m)" % [id, str(key), gap])
	for prop: BuffetLayout.Prop in layout.props:
		if prop.kind in ["broccoli", "cauliflower", "cabbage", "cupcake", "muffin", "cheese_block", "lollipop"]:
			for spot: Vector3 in BuffetLayout.LANDMARK_SPOTS:
				assert_gte(Vector2(prop.pos.x - spot.x, prop.pos.z - spot.y).length(), spot.z - 0.01, "no %s under the landmark at (%.1f, %.1f)" % [prop.kind, spot.x, spot.y])
	# the Walk-In Freezer spot still works: the hero stands at the Pavilion's foot
	var freezer: Vector3 = layout.anchors["mini_dungeon"] as Vector3
	assert_true(builder.is_walkable(freezer + Vector3(0.0, 0.0, 1.6), 0.3), "the hero can stand at the freezer door")
	var door: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_true(builder.is_walkable(door + Vector3(0.0, 0.0, 1.4), 0.3), "the hero can stand at the Test Kitchen gate")


func test_the_test_kitchen_and_potato_peak_are_views_beyond_the_rim() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.build(host)
	assert_not_null(builder.test_kitchen, "the Test Kitchen stands beyond the north rim")
	assert_lt(BuffetLayout.TEST_KITCHEN.y, BuffetLayout.MIN_CORNER.y, "north of the table")
	assert_lt(BuffetLayout.POTATO_PEAK.x, BuffetLayout.MIN_CORNER.x, "Potato Peak lies beyond the west rim")
	assert_lt(BuffetLayout.POTATO_PEAK.y, BuffetLayout.MIN_CORNER.y, "and beyond the north rim (the north-west corner is rounded away)")
	for id: String in ["BUFF-HERO-TEST-KITCHEN", "BUFF-HERO-POTATO-PEAK"]:
		var node: Node3D = builder.landmarks.get(id) as Node3D
		assert_not_null(node)
		if node == null:
			continue
		assert_eq(node.get_parent(), builder.root, "%s hangs off the root, never a chunk" % id)
		for piece: Node in node.find_children("*", "MeshInstance3D", true, false):
			assert_true(piece.has_meta(&"no_range_cull") and piece.has_meta(&"no_occlusion_fade"), "%s never culls or fades" % id)
	# the Test Kitchen is the biggest thing in the zone and steams
	assert_gte(BuffetLayout.TEST_KITCHEN_SIZE.x, 48.0)
	assert_gte(BuffetLayout.TEST_KITCHEN_SIZE.y, 28.0)
	var steaming: int = 0
	for child: Node in builder.root.get_children():
		if child.name.begins_with("Steam_TestKitchen"):
			steaming += 1
	assert_gte(steaming, 5, "steam rises from the chimneys")
	# the forecourt is level with the threshold and the main_dungeon spot stands on it
	var gate: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_true(BuffetLayout.FORECOURT.has_point(Vector2(gate.x, gate.z)), "the gate spot is on the forecourt")
	for z: float in [5.0, 7.0, 9.0, 11.0, 13.0]:
		assert_almost_eq(layout.ground_height(gate.x, z), 0.0, 0.02, "the forecourt is flat at z %.0f" % z)


func test_the_stand_ins_are_gone() -> void:
	for prop: BuffetLayout.Prop in layout.props:
		assert_false(prop.kind in ["freezer", "kitchen_door"], "the taped kitchen door and the freezer box are replaced by the hero models")


func test_the_sky_is_the_dinner_panorama_over_a_dry_table() -> void:
	var mood: Dictionary = WorldLookRig.mood_for(&"buffet")
	var sky: Dictionary = mood.get("sky", {}) as Dictionary
	assert_eq(str(sky.get("panorama", "")), "BUFF-SKY-DINNER", "the kit sky wraps the dome")
	assert_true(EnvKit.has("BUFF-SKY-DINNER") and EnvKit.has_art("BUFF-SKY-DINNER"), "and it is imported")
	var scenery: Dictionary = mood.get("scenery", {}) as Dictionary
	assert_false(bool(scenery.get("water", true)), "no sea plane: it flooded the mashed potato (the table dips below the water height)")
	var cards: Array = scenery.get("kit_cards", []) as Array
	assert_gte(cards.size(), 3, "the cake skyline rings the horizon")
	for card: Variant in cards:
		assert_eq(str((card as Dictionary).get("id", "")), "BUFF-BD-CAKE")
	assert_true(EnvKit.has_art("BUFF-BD-CAKE"))


func test_the_kit_cards_have_hand_heights() -> void:
	for kind: String in ["buff_broccoli", "buff_cauli", "buff_herb", "buff_leek", "buff_cloche", "buff_pot", "buff_cutlery", "buff_flour", "buff_cakestand"]:
		assert_true(TreeCards.KINDS.has(kind), "%s is a card kind" % kind)
		var id: String = str((TreeCards.KINDS[kind] as Dictionary)["id"])
		assert_true(EnvKit.has_art(id), "%s is imported" % id)
		assert_almost_eq(float(EnvKit.entry(id).get("height", 0.0)), ((TreeCards.KINDS[kind] as Dictionary)["size"] as Vector2).y, 0.01, "%s: the registry height is the card height" % id)
	for id: String in ["TEX-BUFF-MASHED", "TEX-BUFF-FROSTING", "TEX-BUFF-BISCUIT", "TEX-BUFF-CHEESE", "TEX-BUFF-GRAVY", "TEX-BUFF-CRUMBSOIL", "DEC-CRUMBS", "DEC-SAUCE"]:
		assert_eq(EnvKit.zone_of(id), "buffet", "%s is an alias of the Buffet kit" % id)
		assert_not_null(EnvKit.texture(id), "%s resolves to the painted texture" % id)


# ---- Part B: layout and declutter (docs/art/buffet_slice.md) -----------------------------------------------------------------------------------------


## The things that stand at an anchor (the fountain at the soup fountain, the stall at the vendor...): their own prop is not clutter round them.
func _anchored_feature(prop: BuffetLayout.Prop) -> bool:
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < 4.0:
			return true
	return false


func test_routes_are_wide_and_nothing_solid_stands_on_them() -> void:
	var hub: Vector2 = Vector2(50.0, 62.0)
	for path: Dictionary in layout.paths:
		var width: float = float(path["width"])
		assert_gte(width, BuffetLayout.SIDE_PATH_WIDTH, "every route is at least %.1f m wide" % BuffetLayout.SIDE_PATH_WIDTH)
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		if line[0] == hub and (line[-1].distance_to(hub) > 18.0 or line[-1].y < 50.0 or line[-1].y > 72.0):
			assert_gte(width, BuffetLayout.MAIN_PATH_WIDTH, "a road out of the hub (to %s) is at least %.1f m wide (4 hero-widths)" % [str(line[-1]), BuffetLayout.MAIN_PATH_WIDTH])
	var on_route: Array[String] = []
	for prop: BuffetLayout.Prop in layout.props:
		if prop.kind in ["fence_fork", "divider", "mill_pillar"] or _anchored_feature(prop):
			continue
		if prop.radius <= 0.0 and prop.kind not in ["broccoli", "cauliflower"]:
			continue
		if layout.path_edge_distance(prop.pos.x, prop.pos.z) < BuffetLayout.PATH_CLEARANCE - 0.01:
			on_route.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	assert_eq(on_route, [] as Array[String], "nothing solid within %.1f m of a route edge" % BuffetLayout.PATH_CLEARANCE)


func test_open_ground_round_every_anchor_and_chest() -> void:
	var crowded: Array[String] = []
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		for prop: BuffetLayout.Prop in layout.props:
			if prop.kind not in ["broccoli", "cauliflower"]:
				continue
			if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < BuffetLayout.ANCHOR_CLEARANCE - 0.01:
				crowded.append("%s near %s" % [prop.kind, str(key)])
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		for prop: BuffetLayout.Prop in layout.props:
			if prop.kind in ["broccoli", "cauliflower"] and Vector2(prop.pos.x - chest.x, prop.pos.z - chest.z).length() < 1.9:
				crowded.append("%s on chest %s" % [prop.kind, str(id)])
	assert_eq(crowded, [] as Array[String], "every NPC, gate, pickup and chest can be reached without weaving round trees")


func test_nothing_is_scattered_but_broccoli_and_cauliflower_at_the_edges() -> void:
	var kinds: Dictionary = {}
	for prop: BuffetLayout.Prop in layout.props:
		kinds[prop.kind] = int(kinds.get(prop.kind, 0)) + 1
	for gone: String in ["lollipop", "cabbage", "cupcake", "muffin", "cheese_block", "fork", "spoon", "knife", "donut_arch", "sundae", "hub_pot", "cabinet", "arch", "freezer", "kitchen_door"]:
		assert_false(kinds.has(gone), "no scattered %s" % gone)
	# outside the forest, every tree stands in a framing group at an edge: within 9 m of the table's rim, or within 3 m of two others
	var outside: int = 0
	for prop: BuffetLayout.Prop in layout.props:
		if prop.kind not in ["broccoli", "cauliflower"] or Rect2(6.0, 50.0, 26.0, 24.0).has_point(Vector2(prop.pos.x, prop.pos.z)):
			continue
		outside += 1
		var near: int = 0
		for other: BuffetLayout.Prop in layout.props:
			if other != prop and other.kind in ["broccoli", "cauliflower"] and Vector2(prop.pos.x - other.pos.x, prop.pos.z - other.pos.z).length() < 6.0:
				near += 1
		assert_true(BuffetLayout.edge_distance(prop.pos.x, prop.pos.z) < 9.0 or near >= 2, "%s at (%.0f, %.0f) frames an edge or stands in a group" % [prop.kind, prop.pos.x, prop.pos.z])
	assert_lte(outside, 42, "a few framing groups, not a scatter (%d trees outside the forest)" % outside)


func test_the_hub_plaza_is_open_and_the_hub_things_stand_round_its_rim() -> void:
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	var inside: Array[String] = []
	for prop: BuffetLayout.Prop in layout.props:
		if prop.kind == "fountain":
			continue  # the Soup Fountain is the plaza's centrepiece (an interactable at its own anchor)
		if prop.radius <= 0.0 and prop.kind not in ["broccoli", "cauliflower"]:
			continue
		if Vector2(prop.pos.x - hub.x, prop.pos.z - hub.z).length() < BuffetLayout.PLAZA_RADIUS:
			inside.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	for sign: BuffetLayout.Sign in layout.signs:
		if sign.key != "sign.fountain" and Vector2(sign.pos.x - hub.x, sign.pos.z - hub.z).length() < BuffetLayout.PLAZA_RADIUS:
			inside.append(sign.key)
	assert_eq(inside, [] as Array[String], "nothing solid and no board inside the plaza (%.1f m round the hub) but the fountain" % BuffetLayout.PLAZA_RADIUS)
	# the hub's things stand round the plaza, not bunched (Tarragon shares the Rift Express's corner: both are quest content and stay)
	var ring: Array[String] = ["heal", "dolcetta", "oven", "fortune_cookie", "old_meatloaf", "odalys", "rift_station"]
	for a: String in ring:
		for b: String in ring:
			if a < b:
				var pa: Vector3 = layout.anchors[a] as Vector3
				var pb: Vector3 = layout.anchors[b] as Vector3
				assert_gt(Vector2(pa.x - pb.x, pa.z - pb.z).length(), 4.0, "%s and %s have breathing room" % [a, b])
	# the Dining Hall's two wings stand north of the plaza with the road to the river between them
	var wings: Array[float] = []
	for prop: BuffetLayout.Prop in layout.props:
		if prop.kind == "hall_wing":
			wings.append(prop.pos.x)
	assert_eq(wings.size(), 2, "two kitchen wings")
	assert_true(wings.min() < 50.0 - BuffetLayout.MAIN_PATH_WIDTH and wings.max() > 50.0 + BuffetLayout.MAIN_PATH_WIDTH, "the road north runs between them")


func test_few_sign_boards_each_with_a_pictogram() -> void:
	assert_lte(layout.signs.size(), 12, "the boards that label something (was 37)")
	var keys: Array[String] = []
	for sign: BuffetLayout.Sign in layout.signs:
		assert_true(BuffetBuilder.SIGN_ICONS.has(sign.key), "%s has an icon" % sign.key)
		assert_ne(sign.style, "memo", "no memos (%s)" % sign.key)
		keys.append(sign.key)
	for needed: String in ["sign.hub_main", "sign.golem_oath", "sign.main_dungeon", "sign.mini_dungeon", "sign.exit", "sign.gate_quest"]:
		assert_has(keys, needed, "%s stays (a quiz answer or a label)" % needed)


func test_the_way_in_is_a_walkable_bridge_not_a_portal() -> void:
	var spawn: Vector3 = layout.anchors["spawn"] as Vector3
	var exit: Vector3 = layout.anchors["exit"] as Vector3
	assert_eq(layout.surface_at(spawn.x, spawn.z), BuffetLayout.Surface.BRIDGE, "the hero arrives on the bridge")
	assert_eq(layout.surface_at(exit.x, exit.z), BuffetLayout.Surface.BRIDGE, "the exit is the far end of the bridge")
	assert_gt(exit.z, spawn.z, "the exit is behind the arriving hero (town side); the zone opens up ahead")
	assert_gte((BuffetLayout.BRIDGE_HALF_WIDTH - BuffetLayout.BRIDGE_RAIL) * 2.0, 2.8, "the deck between the kerbs is four hero-widths")
	assert_gt(BuffetLayout.edge_distance(BuffetLayout.BRIDGE_X, BuffetLayout.BRIDGE_Z0 + 0.5), 0.0, "the near end stands on the table")
	assert_lt(BuffetLayout.edge_distance(BuffetLayout.BRIDGE_X, BuffetLayout.BRIDGE_Z1 - 1.0), 0.0, "the far end is out over the moat")
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_true(builder.is_walkable(spawn, 0.3), "the arrival point is walkable")
	assert_true(builder.is_walkable(exit, 0.3), "the exit landing is walkable")
	assert_false(builder.is_walkable(Vector3(BuffetLayout.BRIDGE_X + BuffetLayout.BRIDGE_HALF_WIDTH, 0.0, BuffetLayout.BRIDGE_Z1 - 8.0), 0.3), "the kerbs hold the hero on the deck")
	assert_true(builder.map_bounds().has_point(Vector2(exit.x, exit.z)), "the map bounds reach the far landing")
	for gate_id: String in ["ingredient", "quest", "battle"]:
		builder.open_gate(gate_id)
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var missing: Array[String] = WalkProbe.unreachable(can_stand, spawn, builder.map_bounds(), {"salt": layout.anchors["pickup_sea_salt"], "exit": exit, "main_dungeon": layout.anchors["main_dungeon"], "mini_dungeon": layout.anchors["mini_dungeon"], "quiz": layout.anchors["quiz"], "minigame": layout.anchors["minigame"]})
	assert_eq(missing, [] as Array[String], "the bridge leads into the plaza and on to every region")
	assert_almost_eq(builder.height_at(spawn), 0.0, 0.001, "the hero stands on the deck")
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var built: BuffetBuilder = BuffetBuilder.new()
	built.build(host)
	var bridge: Node3D = built.root.find_child("Bridge", false, false) as Node3D
	assert_not_null(bridge, "the zone builds the bridge")
	if bridge != null:
		assert_gt((bridge.get_meta("circles", []) as Array).size(), 2, "its posts block")
		assert_true((bridge.find_child("Body", true, false) as Node).has_meta(&"no_occlusion_fade"), "the deck never dissolves under the hero")
	# the town side: the Buffet passageway has no glow at its end
	var passage: Node3D = TownPassages.build("gourmand", "The Endless Buffet", Color.ORANGE, false)
	add_child_autofree(passage)
	assert_null(passage.find_child("FarGlow", true, false), "no portal glow at the end of the Buffet passage")


func test_a_fresh_visit_starts_on_the_bridge_facing_the_hall() -> void:
	var scene: BuffetScene = (load("res://scenes/buffet_zone.tscn") as PackedScene).instantiate() as BuffetScene
	Session.new_game()
	scene.screenshot_prepare({"nohud": "true"})
	add_child(scene)
	await get_tree().process_frame
	assert_true(BuffetLayout.on_bridge(scene.player.position.x, scene.player.position.z), "a fresh visit starts on the bridge")
	assert_lt(scene.player.position.z, BuffetLayout.BRIDGE_Z1 - 1.5, "the arrival point is well short of the walk-off end")
	scene._update_bridge_exit()
	assert_false(scene._locked, "arriving never trips the walk-off exit")
	var wake: Vector3 = scene._hub_spawn()
	assert_lt(Vector2(wake.x - 50.0, wake.z - 64.0).length(), BuffetLayout.PLAZA_RADIUS, "waking after a faint puts the hero in the plaza, not on the bridge")
	for spot: ZoneSpot in scene.spots:
		if spot.kind in ["main_dungeon", "mini_dungeon"]:
			assert_false(spot.plate.visible, "%s: no lettered plate at the door (its board carries a pictogram)" % spot.id)
	# the trees are painted cards (they fade per card) and the fence is one low wall, not a hundred fork poles
	assert_not_null(scene.buf.root.find_child("Trees_buff_broccoli_shadow", false, false), "the broccoli are kit cards")
	assert_not_null(scene.buf.root.find_child("DistrictWalls", false, false), "the fence and the dividers are one wall")
	assert_null(scene.buf.root.find_child("MM_broccoli", false, false), "no Kenney broccoli multimesh")
	scene.queue_free()
	await get_tree().process_frame


func test_the_district_wall_is_knee_high_and_the_gates_still_seal() -> void:
	var walls: Node3D = BuffetLandmarks.district_walls([Vector3(10.0, 0.0, 30.0), Vector3(11.0, 0.0, 30.0), Vector3(12.0, 0.0, 30.0), Vector3(36.0, 0.0, 5.0), Vector3(36.0, 0.0, 6.0)])
	add_child_autofree(walls)
	var body: MeshInstance3D = walls.find_child("Body", true, false) as MeshInstance3D
	assert_not_null(body)
	if body != null:
		assert_lte(body.get_aabb().size.y, 1.6, "a biscuit wall with a hedge never hides the hero")
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	for x: float in [10.0, 30.0, 40.0, 60.0, 70.0, 90.0]:
		assert_false(builder.is_walkable(Vector3(x, 0.0, BuffetLayout.FENCE_Z), 0.3), "the fence line blocks at x %.0f" % x)
	assert_false(builder.is_walkable(Vector3(22.0, 0.0, BuffetLayout.FENCE_Z), 0.3), "the closed gate blocks its gap")


# ---- Part C: dress (docs/art/buffet_slice.md) ------------------------------------------------------------------------------------------------------


func test_the_swaps_land_on_the_zone_art_untinted() -> void:
	var previous: String = ZoneStyles.current
	ZoneStyles.use_area("buffet")
	assert_eq(ZoneStyles.swap("ENV-WALL-TIMBER"), "BUFF-WALL-BISCUIT")
	assert_eq(ZoneStyles.swap("ENV-ROOF-TILE-RED"), "BUFF-ROOF-CRUST")
	assert_eq(ZoneStyles.swap("ENV-DOOR-02"), "BUFF-SHEET-DOORS-02")
	assert_eq(ZoneStyles.swap("ENV-TREE-OAK"), "BUFF-TREE-BROCCOLI")
	var material: StandardMaterial3D = EnvKit.material("ENV-WALL-TIMBER")
	assert_eq(material.resource_name, "BUFF-WALL-BISCUIT", "the material is the zone surface")
	assert_not_null(material.albedo_texture, "and it is painted")
	assert_eq(material.albedo_color, Color.WHITE, "zone art is untinted")
	var card: ShaderMaterial = KitFoliage.card_material("ENV-TREE-OAK")
	assert_eq((card.get_shader_parameter("card_tex") as Texture2D).resource_path.get_file(), "BUFF-TREE-BROCCOLI.webp", "tree cards swap to the zone trees")
	ZoneStyles.use_area(previous)
	EnvKit.clear_cache()
	KitFoliage.clear_cache()


func test_the_presets_and_clusters_build_from_the_kit() -> void:
	for preset: String in BuffetBuilder.BUILDING_PRESETS:
		assert_true(BuildingPresets.has(preset), "%s is a preset" % preset)
		for id: String in BuildingPresets.kit_ids(preset):
			assert_not_null(EnvKit.texture(id), "%s: %s is imported (or a painted alias)" % [preset, id])
		var node: Node3D = BuildingPresets.build(preset)
		assert_not_null(node, "%s builds" % preset)
		if node != null:
			node.free()
	for cluster_name: String in ["banquet_corner", "stock_pots", "flour_store", "herb_bed", "cutlery_marker", "pastry_display"]:
		assert_true(ZoneClusters.has(cluster_name), "%s is a Buffet cluster" % cluster_name)
		var node: Node3D = ZoneClusters.make(cluster_name, 1)
		assert_not_null(node, "%s builds" % cluster_name)
		if node != null:
			assert_gt(node.get_child_count(), 1, "%s has its pieces" % cluster_name)
			node.free()


func test_the_buildings_stand_clear_of_routes_chests_and_anchors() -> void:
	var buildings: int = 0
	for prop: BuffetLayout.Prop in layout.props:
		if prop.kind != "building":
			continue
		buildings += 1
		var preset: String = BuffetBuilder.BUILDING_PRESETS[prop.variant % BuffetBuilder.BUILDING_PRESETS.size()]
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw))
		for circle: Vector3 in BuildingKit.obstacle_circles(BuildingPresets.spec(preset)):
			var world: Vector3 = prop.pos + basis * Vector3(circle.x, 0.0, circle.y)
			assert_gte(layout.path_edge_distance(world.x, world.z) - circle.z, BuffetLayout.PATH_CLEARANCE - 0.01, "%s at (%.0f, %.0f) keeps off the routes" % [preset, prop.pos.x, prop.pos.z])
			for id: Variant in layout.chests.keys():
				var chest: Vector3 = layout.chests[id] as Vector3
				assert_gte(Vector2(world.x - chest.x, world.z - chest.z).length() - circle.z, 1.9, "%s leaves chest %s reachable" % [preset, str(id)])
			for key: Variant in layout.anchors.keys():
				var anchor: Vector3 = layout.anchors[key] as Vector3
				assert_gte(Vector2(world.x - anchor.x, world.z - anchor.z).length() - circle.z, 3.0, "%s keeps %s clear" % [preset, str(key)])
			for spawn: Dictionary in layout.enemy_spawns:
				var home: Vector3 = spawn["home"] as Vector3
				assert_gte(Vector2(world.x - home.x, world.z - home.z).length() - circle.z, 0.5, "%s leaves the enemy home at (%.0f, %.0f) on open ground" % [preset, home.x, home.z])
	assert_eq(buildings, 3, "the bakery, the cake square's cottage and the pancake end's kitchen house")


func test_the_dressing_keeps_the_plaza_the_routes_and_the_anchors_open() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.build(host)
	var dressing: BuffetDressing = BuffetDressing.build(host, builder, GraphicsQuality.Level.HIGH)
	assert_gte(dressing.count, 8, "the clusters and decals are placed (%d)" % dressing.count)
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	var clusters: int = 0
	var placed: PackedStringArray = PackedStringArray()
	for child: Node in dressing.root.get_children():
		if not child.name.contains("Cluster_"):
			continue
		clusters += 1
		placed.append("%s (%.0f, %.0f)" % [child.name, (child as Node3D).position.x, (child as Node3D).position.z])
		var pos: Vector3 = (child as Node3D).position
		assert_gte(Vector2(pos.x - hub.x, pos.z - hub.z).length(), BuffetLayout.PLAZA_RADIUS - 0.01, "%s stays off the plaza" % child.name)
		var solid: bool = not ((child as Node3D).get_meta("circles", []) as Array).is_empty()
		if solid:
			assert_gte(layout.path_edge_distance(pos.x, pos.z), BuffetLayout.PATH_CLEARANCE - 0.01, "%s stays off the routes" % child.name)
		for key: Variant in layout.anchors.keys():
			var anchor: Vector3 = layout.anchors[key] as Vector3
			assert_gte(Vector2(pos.x - anchor.x, pos.z - anchor.z).length(), 3.0 - 0.01, "%s keeps %s clear" % [child.name, str(key)])
		assert_false(BuffetLayout.on_bridge(pos.x, pos.z), "%s is not on the bridge" % child.name)
	gut.p("placed: " + ", ".join(placed))
	assert_gte(clusters, 8, "most of the clusters found free ground (%d: %s)" % [clusters, ", ".join(placed)])
	# every key location still reachable with the dressing's blockers in place
	for gate_id: String in ["ingredient", "quest", "battle"]:
		builder.open_gate(gate_id)
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var targets: Dictionary = {}
	for key: String in ["odalys", "tarragon", "dolcetta", "quiz", "minigame", "pickup_sea_salt", "pickup_truffle", "pickup_basil", "pickup_saffron", "pickup_hot_pepper", "gate_quest", "main_dungeon", "mini_dungeon", "exit"]:
		targets[key] = layout.anchors[key]
	var missing: Array[String] = WalkProbe.unreachable(can_stand, layout.anchors["spawn"] as Vector3, builder.map_bounds(), targets)
	assert_eq(missing, [] as Array[String], "the dressing blocks no way to a key location")
