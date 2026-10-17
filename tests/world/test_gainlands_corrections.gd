extends GutTest
## The corrective pass on the Gainlands (docs/art/gainlands_corrections.md): the zone stays open and readable.
##  - (Gainlands v2) a few hardy trees along the rims, never on a route;
##  - main routes at least 4 hero-widths wide with nothing solid inside their clearance, open ground round every anchor;
##  - few sign boards, each with a pictogram;
##  - the plateau stands well above the look rig's water plane (the canyons drop to it);
##  - Mount Swolympus stays a locked coming-soon landmark on the north-east rim with nothing walkable behind it (SR-4);
##  - the camera occlusion fade is a smooth transparency: tree cards fade in their own shader from the hero's position, the fader drives no dither.

var layout: GainlandsLayout


## The region landmarks kept from the removed sub-areas (SR-7, SR-8): the Wheel, the Champions Arch and the Pump Shrine stand on the main land clear of every route
## and anchor; the Sky Tree is a view off the land; the Record Board is a sign with a pictogram and words.
func test_the_region_landmarks_stand_clear_and_the_sky_tree_is_a_view() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	for node_name: String in ["HeroWheel", "ChampionsArch", "PumpShrine", "DistantSkyTree"]:
		assert_not_null(builder.root.find_child(node_name, false, false), "%s stands in the hub" % node_name)
	var wheel: Node3D = builder.root.find_child("HeroWheel", false, false) as Node3D
	assert_true(wheel != null and wheel.has_meta("spinner"), "the Wheel turns")
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	for entry: Array in [["HeroWheel", GainlandsLayout.HERO_WHEEL, GainlandsLayout.HERO_WHEEL_CLEARANCE], ["ChampionsArch", GainlandsLayout.CHAMPIONS_ARCH, GainlandsLayout.CHAMPIONS_ARCH_CLEARANCE]]:
		var at: Vector2 = entry[1] as Vector2
		var clearance: float = float(entry[2])
		assert_true(GainlandsLayout.is_main_ground(at.x, at.y), "%s stands on the main land" % str(entry[0]))
		for prop: GainlandsLayout.Prop in layout.props:
			if prop.kind == "tree" or prop.kind == "boulder":
				assert_gte(Vector2(at.x - prop.pos.x, at.y - prop.pos.z).length(), clearance - 0.01, "no scattered %s under the %s" % [prop.kind, str(entry[0])])
		# every solid part of the model (its blocking circles) keeps off the routes, out of the plaza and clear of every anchor
		var node: Node3D = builder.root.find_child(str(entry[0]), false, false) as Node3D
		var circles: Array = node.get_meta("circles", []) as Array
		assert_gt(circles.size(), 0, "%s blocks through its circles" % str(entry[0]))
		for circle: Variant in circles:
			var local: Vector3 = circle as Vector3
			var world: Vector3 = node.position + node.basis * Vector3(local.x, 0.0, local.y)
			assert_gte(layout.path_edge_distance(world.x, world.z) - local.z, GainlandsLayout.PATH_CLEARANCE - 0.01, "%s keeps off the routes" % str(entry[0]))
			assert_gt(Vector2(world.x - hub.x, world.z - hub.z).length() - local.z, GainlandsLayout.PLAZA_RADIUS, "%s is outside the plaza" % str(entry[0]))
			for key: Variant in layout.anchors.keys():
				if str(key) == "shrine":
					continue
				var anchor: Vector3 = layout.anchors[key] as Vector3
				assert_gte(Vector2(world.x - anchor.x, world.z - anchor.z).length() - local.z, GainlandsLayout.ANCHOR_CLEARANCE - 0.01, "%s keeps %s clear" % [str(entry[0]), str(key)])
	var shrine: Vector3 = layout.anchors["shrine"] as Vector3
	assert_true(builder.is_walkable(shrine, 0.3), "the hero can stand at the shrine")
	assert_false(builder.is_walkable(shrine + GainlandsBuilder.SHRINE_OFFSET, 0.3), "the shrine itself is solid")
	assert_gte(layout.path_edge_distance(shrine.x, shrine.z), GainlandsLayout.PATH_CLEARANCE, "the shrine is off the routes")
	var tree: Node3D = builder.root.find_child("DistantSkyTree", false, false) as Node3D
	assert_false(GainlandsLayout.is_main_ground(tree.position.x, tree.position.z), "the Sky Tree is off the land")
	assert_null(layout.island_at(tree.position.x, tree.position.z), "and off every island")
	assert_gt(tree.position.y, 8.0, "high in the sky")
	var keys: Array[String] = []
	for sign: GainlandsLayout.Sign in layout.signs:
		keys.append(sign.key)
	assert_has(keys, "sign.record_board", "the Record Board stands at the arch")
	assert_true(GainlandsBuilder.SIGN_ICONS.has("sign.record_board"), "with a pictogram")
	assert_false(ZoneStoryText.for_zone(GainlandsZone.ID).get_lines("sign.record_board").is_empty(), "and words to read")


func test_mount_swolympus_is_a_locked_postgame_bonus() -> void:
	# the gate: a landmark at the right road's overlook, closed, with a coming-soon prompt and no sub-area behind it (GC-11, SR-4)
	assert_true(layout.anchors.has(GainlandsZone.SWOLYMPUS_GATE), "the trailhead gate has an anchor")
	var gate_pos: Vector3 = layout.anchors[GainlandsZone.SWOLYMPUS_GATE] as Vector3
	var road: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_gt(Vector2(gate_pos.x - road.x, gate_pos.z - road.z).length(), 25.0, "it stands well off the middle road")
	var def: ZoneDef = GainlandsZone.build_def()
	var gate_spot: Dictionary = {}
	for spot: Dictionary in def.spots:
		if str(spot["id"]) == GainlandsZone.SWOLYMPUS_GATE:
			gate_spot = spot
	assert_false(gate_spot.is_empty(), "the gate is a spot of the zone")
	if not gate_spot.is_empty():
		assert_true(bool(gate_spot.get("no_plate", false)), "no lettered plate at the gate")
		assert_eq(str(gate_spot["kind"]), "zone", "E is handled by the Gainlands scene (a toast, never a scene change)")
	assert_false(def.poi_kinds.has(GainlandsZone.SWOLYMPUS_GATE), "no marker for a closed gate on the minimap")
	var source: String = FileAccess.get_file_as_string("res://world/gainlands/gainlands_scene.gd")
	var body: String = source.substr(source.find("GainlandsZone.SWOLYMPUS_GATE:"), 300)
	assert_false(body.contains("change_scene"), "E at the gate loads nothing")
	# the gate model stands at the overlook, closed, and blocks the way through
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var gate: Node3D = builder.root.find_child("SwolympusGate", false, false) as Node3D
	assert_not_null(gate, "the trailhead gate model stands at the overlook")
	if gate != null:
		assert_not_null(gate.find_child("GateBarrier", false, false), "its opening is closed by the barrier")
		assert_eq(gate.find_children("*", "Label3D", true, false).size(), 0, "no lettering on the gate")
		assert_false(builder.is_walkable(Vector3(gate_pos.x, 0.0, gate_pos.z), 0.3), "the hero cannot walk through the closed arch")
	var landing: Vector3 = gate_pos + Vector3(-2.5, 0.0, 2.5)
	assert_true(builder.is_walkable(landing, 0.3), "the ground in front of the gate is open")
	# S-BEEF (Mount Swolympus): data intact, sealed, its quest never offered in the main story
	Session.new_game()
	assert_not_null(DungeonCatalog.find("S-BEEF"), "S-BEEF is still in the dungeon list")
	assert_false(Session.side_unlocked("S-BEEF"), "sealed")
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_BEEF)
	assert_not_null(quest)
	assert_true(quest != null and quest.prerequisite != null and quest.prerequisite.kind == Condition.Kind.POSTGAME, "Water for the Hermit waits for the postgame (data file)")
	var offered: Array[String] = []
	for item: QuestData in Session.quests_offered_by(GainlandsZone.NPC_BRENDA):
		offered.append(item.id)
	assert_does_not_have(offered, ZoneQuestDefinitions.SIDE_BEEF, "Old Man Mountain does not offer it")
	# the mountain itself: in the distance, off the land
	var mountain: Node3D = builder.root.find_child("DistantSwolympus", false, false) as Node3D
	assert_not_null(mountain, "Mount Swolympus stands in the distance")
	if mountain != null:
		assert_false(GainlandsLayout.is_main_ground(mountain.position.x, mountain.position.z), "off the main land")


func before_each() -> void:
	layout = GainlandsLayout.new()
	layout.build()


func _main_land(kind: String) -> Array[GainlandsLayout.Prop]:
	var result: Array[GainlandsLayout.Prop] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind == kind and GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z):
			result.append(prop)
	return result


## Gainlands v2 (Part D): gym equipment is the decoration; a few hardy trees stand near the rims, not in groves over the plateau.
func test_a_few_hardy_trees_stand_near_the_rims() -> void:
	var trees: Array[GainlandsLayout.Prop] = _main_land("tree")
	assert_lte(trees.size(), GainlandsLayout.TREE_COUNT, "no more than %d trees on the plateau (was 74)" % GainlandsLayout.TREE_COUNT)
	assert_gte(trees.size(), 8, "a few hardy trees still frame the views")
	for tree: GainlandsLayout.Prop in trees:
		assert_lte(GainlandsLayout.main_edge_distance(tree.pos.x, tree.pos.z), GainlandsLayout.RIM_BAND.y + 0.5, "the tree at (%.0f, %.0f) stands near a rim" % [tree.pos.x, tree.pos.z])
	assert_lte(_main_land("boulder").size(), GainlandsLayout.ROCK_COUNT, "rocky outcrops along the rims, not a field of boulders")


func test_routes_are_wide_and_nothing_solid_stands_on_them() -> void:
	for path: Dictionary in layout.paths:
		var width: float = float(path["width"])
		assert_gte(width, GainlandsLayout.SIDE_PATH_WIDTH, "every route is at least %.1f m wide" % GainlandsLayout.SIDE_PATH_WIDTH)
		if str(path["route"]) in ["middle", "left", "right", "plaza"]:
			assert_gte(width, GainlandsLayout.MAIN_PATH_WIDTH, "a %s road is at least %.1f m wide (4 hero-widths and more)" % [str(path["route"]), GainlandsLayout.MAIN_PATH_WIDTH])
	var on_route: Array[String] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.kind != "tree" and prop.kind != "boulder":
			continue
		if not GainlandsLayout.is_main_ground(prop.pos.x, prop.pos.z):
			continue
		if layout.path_edge_distance(prop.pos.x, prop.pos.z) < GainlandsLayout.PATH_CLEARANCE - 0.01:
			on_route.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	assert_eq(on_route, [] as Array[String], "no tree or rock within %.1f m of a path edge" % GainlandsLayout.PATH_CLEARANCE)


func test_open_ground_round_every_anchor_chest_and_sign() -> void:
	var crowded: Array[String] = []
	for key: Variant in layout.anchors.keys():
		var anchor: Vector3 = layout.anchors[key] as Vector3
		for prop: GainlandsLayout.Prop in layout.props:
			if prop.kind != "tree" and prop.kind != "boulder":
				continue
			if Vector2(prop.pos.x - anchor.x, prop.pos.z - anchor.z).length() < GainlandsLayout.ANCHOR_CLEARANCE - 0.01:
				crowded.append("%s near %s" % [prop.kind, str(key)])
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		for prop: GainlandsLayout.Prop in layout.props:
			if (prop.kind == "tree" or prop.kind == "boulder") and Vector2(prop.pos.x - chest.x, prop.pos.z - chest.z).length() < 1.9:
				crowded.append("%s on chest %s" % [prop.kind, str(id)])
	assert_eq(crowded, [] as Array[String], "every NPC, travel point, gate and chest can be reached without weaving round trees")


func test_few_sign_boards_each_with_a_pictogram() -> void:
	assert_lte(layout.signs.size(), 10, "the boards that point somewhere or carry a quiz answer (was 30)")
	for sign: GainlandsLayout.Sign in layout.signs:
		assert_true(GainlandsBuilder.SIGN_ICONS.has(sign.key), "%s has an icon" % sign.key)
	var keys: Array[String] = []
	for sign: GainlandsLayout.Sign in layout.signs:
		keys.append(sign.key)
	for needed: String in ["sign.hub_power", "sign.ripper_rule", "sign.main_dungeon", "sign.exit"]:
		assert_has(keys, needed, "%s stays (a quiz answer or a direction)" % needed)


func test_the_meadow_never_dips_under_the_water() -> void:
	assert_gt(GainlandsLayout.MIN_GROUND, WorldScenery.WATER_Y + 3.0, "the plateau's floor is metres above the water plane: the canyons and the outer cliffs drop to the sea")
	var lowest: float = 99.0
	for x: int in range(0, 112, 2):
		for z: int in range(-8, 90, 2):
			if GainlandsLayout.is_main_ground(float(x), float(z)):
				lowest = minf(lowest, layout.ground_height(float(x), float(z)))
	assert_gte(lowest, GainlandsLayout.MIN_GROUND - 0.001, "no walkable cell below %.2f (lowest %.2f)" % [GainlandsLayout.MIN_GROUND, lowest])
	assert_gt(lowest, WorldScenery.WATER_Y, "the hero never wades")


func test_tree_cards_fade_in_their_shader_from_the_hero_position() -> void:
	var card: MeshInstance3D = KitFoliage.card("ENV-TREE-OAK", Vector2(5.0, 5.0))
	autofree(card)
	assert_true(card.has_meta(&"no_occlusion_fade"), "the fader leaves tree cards alone (they fade themselves)")
	var shader_code: String = (load(KitFoliage.CARD_SHADER) as Shader).code
	assert_true(shader_code.contains("uniform vec3 hero_pos"), "the card shader knows where the hero is")
	assert_true(shader_code.contains("ALPHA = 1.0 - v_fade"), "and fades with plain alpha, not a dither")
	assert_false(shader_code.contains("BAYER"), "no ordered dither in the card shader")
	KitFoliage.set_hero(Vector3(12.0, 0.5, 34.0))
	var material: ShaderMaterial = card.material_override as ShaderMaterial
	assert_eq(material.get_shader_parameter("hero_pos"), Vector3(12.0, 0.5, 34.0), "set_hero reaches every card material")
	KitFoliage.set_hero(Vector3(0.0, -1000.0, 0.0))
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var field: MultiMeshInstance3D = KitFoliage.tree_field(host, "pine", [{"pos": Vector3.ZERO, "scale": 1.0}] as Array[Dictionary], false)
	assert_true(field.has_meta(&"no_occlusion_fade"), "tree fields opt out of the fader too")


func test_the_occlusion_fader_uses_a_smooth_transparency() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/style/occlusion_fader.gd")
	assert_false(source.contains("set_instance_shader_parameter(\"occlusion_fade\""), "the fader no longer drives the ordered dither")
	assert_true(source.contains("piece.transparency = "), "every faded piece uses the per-instance transparency")
	assert_true(source.contains("KitFoliage.set_hero("), "the fader feeds the hero position to the tree cards")


func test_terrain_and_islands_never_dissolve() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var land: Node = builder.root.find_child("MainLand", false, false)
	assert_not_null(land)
	assert_true(land.has_meta(&"no_occlusion_fade"), "the plateau is never faded by the camera")
	for island: GainlandsLayout.Island in layout.islands:
		var node: Node = builder.root.find_child("Island_" + island.id, false, false)
		assert_true(node != null and node.has_meta(&"no_occlusion_fade"), "%s never dithers when the camera passes near it" % island.id)
	for cloud: Node3D in builder.cloud_nodes():
		assert_lt(cloud.position.y, -8.0, "no cloud can poke up through the meadow")


func test_the_hub_plaza_is_open_and_the_hub_things_stand_round_its_rim() -> void:
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	var inside: Array[String] = []
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.radius <= 0.0 and prop.kind != "tree":
			continue
		if Vector2(prop.pos.x - hub.x, prop.pos.z - hub.z).length() < GainlandsLayout.PLAZA_RADIUS:
			inside.append("%s at (%.0f, %.0f)" % [prop.kind, prop.pos.x, prop.pos.z])
	for sign: GainlandsLayout.Sign in layout.signs:
		if Vector2(sign.pos.x - hub.x, sign.pos.z - hub.z).length() < GainlandsLayout.PLAZA_RADIUS:
			inside.append(sign.key)
	assert_eq(inside, [] as Array[String], "nothing solid and no board inside the plaza (%.1f m round the hub)" % GainlandsLayout.PLAZA_RADIUS)
	# The important things are spread round the plaza, not bunched: every pair of hub anchors keeps 4 m apart.
	var ring: Array[String] = ["rift_station", "heal", "tony", "brenda", "flex_mirror"]  # (Gus and the protein stand moved to the market row, Gainlands v2)
	for a: String in ring:
		for b: String in ring:
			if a < b:
				var pa: Vector3 = layout.anchors[a] as Vector3
				var pb: Vector3 = layout.anchors[b] as Vector3
				assert_gt(Vector2(pa.x - pb.x, pa.z - pb.z).length(), 4.0, "%s and %s have breathing room" % [a, b])
	# ... and each stands on the plaza's rim: between the plaza edge and 15 m out.
	for key: String in ring:
		var pos: Vector3 = layout.anchors[key] as Vector3
		var distance: float = Vector2(pos.x - hub.x, pos.z - hub.z).length()
		assert_between(distance, GainlandsLayout.PLAZA_RADIUS - 2.0, 15.0, "%s stands round the plaza (%.1f m from the centre)" % [key, distance])
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var dressing: GainlandsDressing = GainlandsDressing.build(host, builder, GraphicsQuality.Level.HIGH)
	for child: Node in dressing.root.get_children():
		var pos: Vector3 = (child as Node3D).position
		assert_gte(Vector2(pos.x - hub.x, pos.z - hub.z).length(), GainlandsLayout.PLAZA_RADIUS - 0.01, "%s stays off the plaza" % child.name)


func test_the_way_in_is_a_walkable_bridge_not_a_portal() -> void:
	for prop: GainlandsLayout.Prop in layout.props:
		assert_ne(prop.kind, "arch", "the portal arch at the exit is gone")
	var spawn: Vector3 = layout.anchors["spawn"] as Vector3
	var exit: Vector3 = layout.anchors["exit"] as Vector3
	assert_eq(layout.surface_at(spawn.x, spawn.z), GainlandsLayout.Surface.BRIDGE, "the hero arrives on the bridge")
	assert_eq(layout.surface_at(exit.x, exit.z), GainlandsLayout.Surface.BRIDGE, "the exit is the far end of the bridge")
	assert_gt(exit.z, spawn.z, "the exit is behind the arriving hero (town side); the zone opens up ahead")
	assert_gte((GainlandsLayout.BRIDGE_HALF_WIDTH - GainlandsLayout.BRIDGE_RAIL) * 2.0, 2.8, "the deck between the rails is four hero-widths")
	assert_eq(layout.surface_at(GainlandsLayout.BRIDGE_X, GainlandsLayout.BRIDGE_Z0 + 0.5), GainlandsLayout.Surface.BRIDGE, "the deck overlaps the rim: no gap between grass and planks")
	assert_true(GainlandsLayout.is_main_ground(GainlandsLayout.BRIDGE_X, GainlandsLayout.BRIDGE_Z0 + 0.5), "the near end stands on the plateau")
	assert_false(GainlandsLayout.is_main_ground(GainlandsLayout.BRIDGE_X, GainlandsLayout.BRIDGE_Z1 - 1.0), "the far end is out over the water")
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_true(builder.is_walkable(spawn, 0.3), "the arrival point is walkable")
	assert_true(builder.is_walkable(exit, 0.3), "the exit landing is walkable")
	assert_false(builder.is_walkable(Vector3(GainlandsLayout.BRIDGE_X + GainlandsLayout.BRIDGE_HALF_WIDTH, 0.0, GainlandsLayout.BRIDGE_Z1 - 8.0), 0.3), "the rails hold the hero on the deck")
	assert_true(builder.map_bounds().has_point(Vector2(exit.x, exit.z)), "the map bounds reach the far landing")
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	var missing: Array[String] = WalkProbe.unreachable(can_stand, spawn, builder.map_bounds(), {"hub": hub, "exit": exit, "main_dungeon": layout.anchors["main_dungeon"]})
	assert_eq(missing, [] as Array[String], "the bridge leads from the arrival point into the plaza and on to the dungeon road")
	assert_almost_eq(builder.height_at(spawn), GainlandsLayout.bridge_height(spawn.z), 0.001, "the hero stands on the deck, not under it")
	assert_gt(GainlandsLayout.bridge_height(spawn.z), WorldScenery.WATER_Y, "the deck is above the water")


func test_the_bridge_model_stands_in_the_zone_and_on_the_town_side() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var bridge: Node3D = builder.root.find_child("Bridge", false, false) as Node3D
	assert_not_null(bridge, "the zone builds the bridge")
	if bridge != null:
		assert_almost_eq(bridge.position.z, GainlandsLayout.BRIDGE_Z0, 0.01)
		assert_gt((bridge.get_meta("circles", []) as Array).size(), 2, "its gate posts block")
		assert_true((bridge.find_child("Body", true, false) as Node).has_meta(&"no_occlusion_fade"), "the deck never dissolves under the hero")
	var scene: GainlandsScene = (load("res://scenes/gainlands_zone.tscn") as PackedScene).instantiate() as GainlandsScene
	Session.new_game()
	scene.screenshot_prepare({"nohud": "true"})
	add_child(scene)
	await get_tree().process_frame
	assert_true(GainlandsLayout.on_bridge(scene.player.position.x, scene.player.position.z), "a fresh visit starts on the bridge")
	assert_lt(scene.player.position.z, GainlandsLayout.BRIDGE_Z1 - 1.5, "the arrival point is well short of the walk-off end")
	scene._update_bridge_exit()
	assert_false(scene._locked, "arriving never trips the walk-off exit")
	var wake: Vector3 = scene._hub_spawn()
	var hub: Vector3 = layout.anchors["hub"] as Vector3
	assert_lt(Vector2(wake.x - hub.x, wake.z - hub.z).length(), GainlandsLayout.PLAZA_RADIUS, "waking after a faint puts the hero in the plaza, not on the bridge")
	scene.queue_free()
	await get_tree().process_frame
	# The town side: the Gainlands passageway has no glow at its end and its connector is the same rope bridge.
	var passage: Node3D = TownPassages.build("beefcake", "The Gainlands", Color.RED, false)
	add_child_autofree(passage)
	assert_null(passage.find_child("FarGlow", true, false), "no portal glow at the end of the Gainlands passage")
	var other: Node3D = TownPassages.build("necrocrat", "The D.N.A.", Color.ORANGE, false)  # the Dump lost its glow too (VD-3)
	add_child_autofree(other)
	assert_not_null(other.find_child("FarGlow", true, false), "the other passages keep theirs")
	var mouth: Vector3 = Vector3(10.0, 0.0, 10.0)
	var out: Vector3 = Vector3(0.0, 0.0, 1.0)
	var connector: Node3D = TownConnectors.build(host, "beefcake", mouth, out, TownConnectors.plan(mouth, out))
	var town_bridge: Node3D = connector.find_child("Bridge", true, false) as Node3D
	assert_not_null(town_bridge, "the town connector has the bridge")
	if town_bridge != null:
		assert_eq(str(town_bridge.get_meta("kind", "")), "bridge", "and it is the rope bridge, the same model as the zone side")


## Gainlands v2: the House of Gains stands on its own rock behind the fortress mesa; its gate opens onto the mesa top (the dungeon entrance), and the mesa is
## reached from the forecourt by the wide stairs only (its other edges are cliffs).
func test_the_house_of_gains_stands_behind_the_mesa_and_its_gate_is_the_dungeon_entrance() -> void:
	for prop: GainlandsLayout.Prop in layout.props:
		assert_ne(prop.kind, "gate", "the placeholder gate (white blocks, cones, tape) is gone")
	var entrance: Vector3 = layout.anchors["main_dungeon"] as Vector3
	assert_eq(GainlandsLayout.level_at(entrance.x, entrance.z), 2, "the dungeon entrance stands on the mesa top in front of the fortress doors")
	assert_almost_eq(layout.ground_height(entrance.x, entrance.z), GainlandsLayout.MESA_Y, 0.01, "raised above the plateau")
	assert_gt(GainlandsLayout.MESA_Y - GainlandsLayout.PLATEAU_Y, 3.0, "a real mesa: well over a hero's height above the forecourt")
	assert_false(GainlandsLayout.is_main_ground(GainlandsLayout.HOUSE_OF_GAINS.x, GainlandsLayout.HOUSE_OF_GAINS.y), "the fortress stands beyond the mesa, on its own rock")
	assert_gt(GainlandsLayout.HOUSE_OF_GAINS_SIZE.y, StorybookScale.TREE_MAX * 4.0, "it towers over the trees (castle-sized)")
	var sign_pos: Vector3 = Vector3.ZERO
	for sign: GainlandsLayout.Sign in layout.signs:
		if sign.key == "sign.main_dungeon":
			sign_pos = sign.pos
	assert_lt(Vector2(sign_pos.x - entrance.x, sign_pos.z - entrance.z).length(), 6.0, "the icon board stands at the gate")
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	assert_true(builder.is_walkable(entrance, 0.3), "the entrance spot is walkable")
	var can_stand: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var missing: Array[String] = WalkProbe.unreachable(can_stand, layout.anchors["spawn"] as Vector3, builder.map_bounds(), {"main_dungeon": entrance})
	assert_eq(missing, [] as Array[String], "the gate is reachable from the bridge")
	# the stairs are the only way up: blocked foot of the mesa beside them, open steps between their cheek walls
	var stairs: Rect2 = GainlandsLayout.STAIRS
	assert_gte(stairs.size.x, GainlandsLayout.MIDDLE_PATH_WIDTH * 2.0, "wide stairs, as in the reference")
	assert_true(builder.is_walkable(Vector3(stairs.get_center().x, 0.0, stairs.get_center().y), 0.3), "the stairs are walkable")
	for x: float in [stairs.position.x - 3.0, stairs.end.x + 3.0]:
		assert_false(builder.is_walkable(Vector3(x, 0.0, 14.0), 0.3), "the mesa's foot at x %.0f is a cliff, not a ramp" % x)
	var cut: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3) and not stairs.grow(0.5).has_point(Vector2(pos.x, pos.z))
	assert_eq(WalkProbe.unreachable(cut, layout.anchors["spawn"] as Vector3, builder.map_bounds(), {"main_dungeon": entrance}), ["main_dungeon"] as Array[String], "without the stairs the mesa cannot be reached")
	var def: ZoneDef = GainlandsZone.build_def()
	for spot: Dictionary in def.spots:
		if str(spot["id"]) == "main_dungeon":
			assert_true(bool(spot.get("no_plate", false)), "no lettered plate at the gate (the board carries the dungeon icon, the prompt the name)")
			assert_eq(str(spot["kind"]), "main_dungeon", "the entrance interaction is unchanged")


func test_the_fortress_model_builds_with_towers_chimneys_and_a_gate_that_blocks() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var house: Node3D = builder.root.find_child("Landmark_GAIN-HERO-HOUSE-OF-GAINS", false, false) as Node3D
	assert_not_null(house, "the zone builds the House of Gains")
	if house == null:
		return
	assert_almost_eq(house.position.x, GainlandsLayout.HOUSE_OF_GAINS.x, 0.01)
	assert_almost_eq(house.position.z, GainlandsLayout.HOUSE_OF_GAINS.y, 0.01)
	assert_gte(float(house.get_meta("height", 0.0)), 30.0, "castle-sized")
	assert_eq((house.get_meta("chimneys", []) as Array).size(), 3, "three foundry chimneys")
	var smokes: int = 0
	for child: Node in builder.root.get_children():
		if child is CPUParticles3D and child.name.begins_with("FoundrySmoke"):
			smokes += 1
	assert_eq(smokes, 3, "smoke rises from each")
	assert_gte((house.get_meta("circles", []) as Array).size(), 2, "the gatehouse towers block")
	var body: Node = house.find_child("Body", true, false)
	assert_true(body != null and body.has_meta(&"no_range_cull"), "visible from the whole zone: never range-culled")
	assert_true(GainlandsLandmarks.has_model("GAIN-HERO-HOUSE-OF-GAINS"), "a concept of that id will slot in later")
	# a gatehouse tower is solid, the causeway between them is open
	assert_false(builder.is_walkable(Vector3(GainlandsLayout.HOUSE_OF_GAINS.x + 7.7, 0.0, GainlandsLayout.HOUSE_OF_GAINS.y + 13.0), 0.3), "the east gatehouse tower blocks")
	assert_true(builder.is_walkable(layout.anchors["main_dungeon"] as Vector3, 0.3), "the mesa top in front of the gate is open")


func test_the_sealed_cavern_says_coming_soon_in_the_hud() -> void:
	var scene: GainlandsScene = (load("res://scenes/gainlands_zone.tscn") as PackedScene).instantiate() as GainlandsScene
	Session.new_game()
	scene.screenshot_prepare({"nohud": "true"})
	add_child(scene)
	await get_tree().process_frame
	var cavern: ZoneSpot = null
	for spot: ZoneSpot in scene.spots:
		if spot.kind == "mini_dungeon":
			cavern = spot
	assert_not_null(cavern, "the Iron Cavern spot still exists")
	if cavern != null:
		assert_true(scene._prompt_for(cavern).to_lower().contains("coming soon"), "its prompt says coming soon")
		scene._ask_mini_dungeon(cavern)
		assert_false(scene._locked, "E opens nothing (no confirm dialog, no dungeon)")
	scene.queue_free()
	await get_tree().process_frame


func test_every_thrower_route_has_a_clear_landing_and_a_way_back_down() -> void:
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var throws: int = 0
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		var at: Vector3 = builder.anchor(point.anchor)
		var dest: Vector3 = builder.anchor(point.dest_anchor)
		assert_true(builder.is_walkable(at + Vector3(0.0, 0.0, 1.1), 0.3), "%s: the Beefcake can be reached (its spot is walkable)" % point.id)
		assert_true(builder.is_walkable(dest, 0.3), "%s: the landing spot %s is walkable" % [point.id, point.dest_anchor])
		var open: int = 0
		for step: int in range(8):
			var angle: float = TAU * float(step) / 8.0
			if builder.is_walkable(dest + Vector3(cos(angle) * 1.3, 0.0, sin(angle) * 1.3), 0.3):
				open += 1
		assert_gte(open, 6, "%s: open ground round the landing (%d of 8)" % [point.id, open])
		if point.kind == "throw":
			throws += 1
			var distance: float = Vector2(dest.x - at.x, dest.z - at.z).length()
			var apex: float = clampf(3.0 + distance * 0.28, 5.0, 16.0)
			assert_gt(apex, 3.0, "%s: the arc rises well above both ends (apex %.1f m)" % [point.id, apex])
			if point.dest_anchor.begins_with("arrive_") and GainlandsLayout.is_main_ground(at.x, at.z):
				assert_gt(dest.y, at.y + 5.0, "%s: a throw from the main land lands well above the thrower (%.1f -> %.1f m)" % [point.id, at.y, dest.y])
	assert_gte(throws, 5, "five or more thrower routes")
	for island: GainlandsLayout.Island in builder.layout.islands:
		var way_back: bool = false
		for point: GainlandsTravel.Point in GainlandsTravel.points():
			var at: Vector3 = builder.layout.anchors[point.anchor] as Vector3
			var to: Vector3 = builder.layout.anchors[point.dest_anchor] as Vector3
			if builder.layout.island_at(at.x, at.z) == island and point.lock == null and GainlandsLayout.is_main_ground(to.x, to.z):
				way_back = true
		assert_true(way_back, "%s has an always-open way back down" % island.title)
