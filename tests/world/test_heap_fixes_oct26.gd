extends GutTest
## Fixes Oct 26, Part 4 (the Verdant Dump): the vine bridges meet the ground at both banks and are walked at deck height on the whole grown strip
## (no abutment slab floating over the path), growth gating unchanged; Brother Bramble greets at the Commons Greenhouse door; fewer trees, none
## between the default camera and a route, an anchor, a chest or a sign; the mushroom trees keep the Crosspath look.

var heap: HeapBuilder


func before_all() -> void:
	heap = HeapBuilder.new()
	heap.layout.build()


func test_every_vine_bridge_meets_the_ground_at_both_banks() -> void:
	for bridge: HeapLayout.Bridge in heap.layout.bridges:
		assert_almost_eq(bridge.deck_height(0.0), heap.layout.ground_height(bridge.a.x, bridge.a.y) + HeapLayout.BRIDGE_HEIGHT, 0.05, "%s a" % bridge.id)
		assert_almost_eq(bridge.deck_height(1.0), heap.layout.ground_height(bridge.b.x, bridge.b.y) + HeapLayout.BRIDGE_HEIGHT, 0.05, "%s b" % bridge.id)
		# the slope the planks tilt by matches the deck (a plank's ends sit on the deck, no lip)
		for t: float in [0.0, 0.25, 0.5, 0.75, 1.0]:
			var e: float = 0.01
			var numeric: float = (bridge.deck_height(clampf(t + e, 0.0, 1.0)) - bridge.deck_height(clampf(t - e, 0.0, 1.0))) / ((clampf(t + e, 0.0, 1.0) - clampf(t - e, 0.0, 1.0)) * bridge.length())
			assert_almost_eq(bridge.deck_slope(t), numeric, 0.02, "%s slope at %.2f" % [bridge.id, t])


func test_a_grown_bridge_is_walked_at_deck_height_banks_included_and_an_ungrown_one_not_at_all() -> void:
	for bridge: HeapLayout.Bridge in heap.layout.bridges:
		heap.bridge_progress[bridge.id] = 0.0
		var crossing: bool = false
		for i: int in range(1, 40):
			var t: float = float(i) / 40.0
			var p2: Vector2 = bridge.a.lerp(bridge.b, t)
			var p: Vector3 = Vector3(p2.x, 0.0, p2.y)
			if heap.is_in_hazard(p):
				crossing = true
		assert_true(crossing, "%s ungrown: no way across (a hazard on the line)" % bridge.id)
		heap.bridge_progress[bridge.id] = 1.0
		for i: int in range(1, 40):
			var t: float = float(i) / 40.0
			var p2: Vector2 = bridge.a.lerp(bridge.b, t)
			var p: Vector3 = Vector3(p2.x, 0.0, p2.y)
			assert_false(heap.is_in_hazard(p), "%s grown: no hazard at %.2f" % [bridge.id, t])
			assert_almost_eq(heap.height_at(p), bridge.deck_height(bridge.fraction_at(p.x, p.z)), 0.01, "%s grown: the deck carries the hero at %.2f" % [bridge.id, t])
		heap.bridge_progress[bridge.id] = 0.0


func test_the_abutment_has_no_plank_slab() -> void:
	var abutment: Node3D = HeapTerraces.bridge_abutment()
	add_child_autofree(abutment)
	for node: Node in abutment.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		for surface: int in range(mesh_instance.mesh.get_surface_count()):
			var arrays: Array = mesh_instance.mesh.surface_get_arrays(surface)
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
			var low_wide: int = 0
			for v: Vector3 in verts:
				if absf(v.y) < 0.1 and absf(v.x) > HeapLayout.BRIDGE_HALF_WIDTH * 0.5 and absf(v.x) < HeapLayout.BRIDGE_HALF_WIDTH + 0.1:
					low_wide += 1
			assert_eq(low_wide, 0, "nothing flat across the walk at ground level (surface %d)" % surface)


func test_bramble_greets_at_the_greenhouse_door() -> void:
	var at: Vector3 = heap.layout.anchors["marigold"] as Vector3
	var door_z: float = HeapLayout.GREENHOUSE.y + HeapLayout.GREENHOUSE_SIZE.z * 0.5
	assert_almost_eq(at.x, HeapLayout.GREENHOUSE.x, 0.01, "on the door's axis")
	assert_between(at.z - door_z, 1.5, 3.0, "just in front of the door, on the arrival side")
	assert_true(heap.is_walkable(at, 0.3), "he stands on open ground")
	# his prompt spot (1 m toward the arrival) is reachable too
	assert_true(heap.is_walkable(at + Vector3(0, 0, 1.0), 0.3))
	var entry: Dictionary = {}
	for npc: Dictionary in HeapZone.build_def().npcs:
		if str(npc["id"]) == "marigold":
			entry = npc
	assert_eq(float(entry.get("yaw", -1.0)), 0.0, "facing the arrival (+z)")


func test_fewer_trees_and_none_hides_a_route_an_anchor_a_chest_or_a_sign() -> void:
	var trees: int = 0
	var commons: int = 0
	for prop: HeapLayout.Prop in heap.layout.props:
		if prop.kind != "tree" and prop.kind != "mushroom_tree":
			continue
		trees += 1
		if prop.pos.z > 100.0:
			commons += 1
		assert_false(heap.layout.blocks_a_view(prop.pos.x, prop.pos.z), "a %s at (%.1f, %.1f) hides something from the camera" % [prop.kind, prop.pos.x, prop.pos.z])
	assert_lte(trees, 56, "fewer trees (73 before Oct 26)")
	assert_lte(commons, 25, "the starting area most of all (37 before)")
	assert_gte(trees, 40, "the zone keeps its woods")


func test_the_mushroom_trees_keep_the_crosspath_look() -> void:
	var town: ZonePreset = StylePresets.get_preset(StylePresets.TOWN)
	var material: ShaderMaterial = KitFoliage.card_material("DUMP-TREE-TWISTED")
	assert_eq(material.get_shader_parameter("mood_tint") as Color, Color.WHITE, "no zone tree tint")
	assert_eq(material.get_shader_parameter("light_color") as Color, town.sun_color)
	assert_eq(material.get_shader_parameter("ambient_color") as Color, town.ambient_color)
	assert_eq(TreeCards.KINDS["dump_shroom"]["id"], "DUMP-TREE-TWISTED")
