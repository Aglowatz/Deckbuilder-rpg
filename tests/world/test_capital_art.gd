extends GutTest
## The Capital's art pass (docs/art/capital_slice.md, "The art pass"): every stand-in replaced by a hero model built from its concept
## (`CapitalLandmarks`, `CapitalCastle`, `CapitalDistricts`), the castle never culled or faded and its cracks leaking a rift light that goes dark
## when Primm falls, the four districts in two states on the same footprint, the rifts varied.


func _meshes(node: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		out.append(child as MeshInstance3D)
	return out


func _bounds(node: Node3D) -> AABB:
	var box: AABB = AABB()
	var first: bool = true
	for mesh: MeshInstance3D in _meshes(node):
		var part: AABB = mesh.transform * mesh.get_aabb()
		box = part if first else box.merge(part)
		first = false
	return box


func test_every_hero_landmark_builds_a_textured_model() -> void:
	var specs: Array[Dictionary] = [
		{"id": "CAP-HERO-PRIMMS-CASTLE"}, {"id": "CAP-HERO-GREAT-WALL-GATE"}, {"id": "CAP-HERO-PRIMM-FOUNTAIN"}, {"id": "CAP-HERO-RIFT", "radius": 1.4},
		{"id": "CAP-HERO-WATCHTOWER"}, {"id": "CAP-HERO-SERVICE-TUNNEL"}, {"id": "CAP-HERO-RESISTANCE-CAMP"},
		{"id": "CAP-HERO-TRAM-SHED", "size": [10.0, 6.5, 6.0]}, {"id": "CAP-HERO-IDENTICAL-ROW", "size": [3.5, 3.6, 4.0]},
		{"id": "CAP-HERO-GRAVE-ROW", "size": [4.0, 4.5, 4.0]}, {"id": "CAP-HERO-THE-REEK", "size": [3.5, 5.0, 4.5]},
		{"id": "CAP-HERO-CORRECTION-WARD", "size": [26.0, 4.5, 1.0], "piece": "north"},
	]
	for spec: Dictionary in specs:
		var node: Node3D = CapitalLandmarks.build(spec)
		assert_not_null(node, "%s builds" % spec["id"])
		if node == null:
			continue
		assert_eq(str(node.get_meta("hero_id", "")), str(spec["id"]))
		assert_gt(int(node.get_meta("triangles", 0)), 40, "%s is a real model, not a box" % spec["id"])
		var textured: bool = false
		for mesh: MeshInstance3D in _meshes(node):
			for surface: int in range(mesh.mesh.get_surface_count() if mesh.mesh != null else 0):
				var material: StandardMaterial3D = mesh.mesh.surface_get_material(surface) as StandardMaterial3D
				if material != null and material.albedo_texture != null:
					textured = true
		assert_true(textured, "%s wears the kit's painted surfaces" % spec["id"])
		node.free()


func test_the_castle_is_immense_symmetric_and_never_culled() -> void:
	var castle: Node3D = CapitalCastle.build(false)
	var box: AABB = _bounds(castle)
	assert_gte(box.size.x, 70.0, "immense: wider than a district")
	assert_gte(box.end.y, 50.0, "its spire soars over everything")
	assert_almost_eq(box.get_center().x, CapitalCastle.AXIS, 1.0, "symmetric about the grand avenue")
	for mesh: MeshInstance3D in _meshes(castle):
		assert_true(mesh.has_meta(&"no_range_cull") and mesh.has_meta(&"no_occlusion_fade"), "never culled or faded: %s" % mesh.name)
	var cracks: StandardMaterial3D = castle.get_meta("cracks") as StandardMaterial3D if castle.has_meta("cracks") else null
	assert_not_null(cracks, "hairline cracks leak rift light")
	assert_true(cracks.emission_enabled)
	castle.free()
	var fallen: Node3D = CapitalCastle.build(true)
	assert_false(fallen.has_meta("cracks"), "when Primm falls the cracks go dark (nothing left to pulse)")
	fallen.free()


func test_the_districts_change_state_on_the_same_footprint() -> void:
	for spec: Dictionary in [{"id": "CAP-HERO-TRAM-SHED", "size": [10.0, 6.5, 6.0]}, {"id": "CAP-HERO-IDENTICAL-ROW", "size": [3.5, 3.6, 4.0]}, {"id": "CAP-HERO-GRAVE-ROW", "size": [4.0, 4.5, 4.0]}, {"id": "CAP-HERO-THE-REEK", "size": [3.5, 5.0, 4.5]}]:
		var broken_spec: Dictionary = spec.duplicate()
		broken_spec["state"] = "broken"
		var restored_spec: Dictionary = spec.duplicate()
		restored_spec["state"] = "restored"
		var broken: Node3D = CapitalLandmarks.build(broken_spec)
		var restored: Node3D = CapitalLandmarks.build(restored_spec)
		var size: Array = spec["size"] as Array
		for node: Node3D in [broken, restored]:
			var box: AABB = _bounds(node)
			# the footprint stays the layout building's (a lamp or a planter may stand a little proud at the front, never on a route)
			assert_lt(box.size.x, float(size[0]) + 3.2, "%s keeps its footprint's width" % spec["id"])
			assert_lt(box.size.z, float(size[2]) + 3.2, "%s keeps its footprint's depth" % spec["id"])
		assert_ne(int(broken.get_meta("triangles", 0)), int(restored.get_meta("triangles", 0)), "%s looks different once its Path is free" % spec["id"])
		assert_true((restored.get_meta("lights", []) as Array).size() > 0 or spec["id"] == "CAP-HERO-THE-REEK", "%s: the warmth comes back with light" % spec["id"])
		broken.free()
		restored.free()


func test_the_rifts_are_varied_copies() -> void:
	var heights: Dictionary = {}
	for index: int in range(6):
		var rift: Node3D = CapitalLandmarks.build({"id": "CAP-HERO-RIFT", "seed": index * 13, "radius": 1.3})
		assert_not_null(rift.get_node_or_null("Tear"), "the tear")
		assert_not_null(rift.get_node_or_null("Orbit"), "the floating shards turn round it")
		assert_not_null(rift.get_node_or_null("Rim"), "the hazard's reach glows on the ground")
		heights["%.2f|%.0f" % [float(rift.get_meta("size", 1.0)), rift.rotation_degrees.y]] = true
		rift.free()
	assert_gte(heights.size(), 5, "each copy varies in size and turn")


func test_the_camp_holds_the_only_warm_lights_outside() -> void:
	var camp: Node3D = CapitalLandmarks.build({"id": "CAP-HERO-RESISTANCE-CAMP"})
	var lights: Array = camp.get_meta("lights", []) as Array
	assert_gt(lights.size(), 0)
	for light: Variant in lights:
		var color: Color = (light as OmniLight3D).light_color
		assert_gt(color.r, color.b, "warm")
	camp.free()
	var tunnel: Node3D = CapitalLandmarks.build({"id": "CAP-HERO-SERVICE-TUNNEL"})
	assert_eq(tunnel.find_children("*", "Light3D", true, false).size(), 0, "the tunnel's lantern is dim and casts no warm light")
	tunnel.free()


func test_the_castle_door_is_a_grand_entrance_that_stays_off_the_forecourt() -> void:
	# the entrance over the stair's foot, its lamps and banners stand on the hill (z 12 or less): nothing of the castle on the forecourt or its kerb
	var castle: Node3D = CapitalCastle.build(false)
	var box: AABB = _bounds(castle)
	assert_lte(box.end.z, float(CapitalLayout.HILL.end.y) + 0.3, "the castle ends at the hill's edge (%.2f)" % box.end.z)
	var door: Vector3 = CapitalLayout.new().anchors.get("castle_door", Vector3(60, 0, 13)) as Vector3
	assert_almost_eq(door.x, CapitalCastle.AXIS, 0.1, "the door spot is on the castle's axis, at the stair's foot")
	var crown_slot: bool = false
	var body: MeshInstance3D = castle.get_node("Body") as MeshInstance3D
	for surface: int in range(body.mesh.get_surface_count()):
		if body.mesh.surface_get_name(surface) == "card_CAP-SHEET-SIGNS-05":
			crown_slot = true
	assert_true(crown_slot, "the crown in its gold frame is the door's icon sign")
	castle.free()


func test_outside_lights_leave_the_warmth_to_the_camp() -> void:
	# the Gate Road's lamps, when lit (the Beefcakes are free), give Primm's cold white light; the camp fire is warm and flickers
	var lamp: Node3D = CapitalProps.street_lamp(true)
	for light: Node in lamp.find_children("*", "OmniLight3D", true, false):
		var color: Color = (light as OmniLight3D).light_color
		assert_gte(color.b, color.r, "a street lamp's light is cold")
	lamp.free()
	var fire: Node3D = CapitalProps.campfire()
	assert_true(fire.has_meta("flicker"), "the camp fire's light flickers")
	var flame: OmniLight3D = fire.get_meta("flicker") as OmniLight3D
	assert_gt(flame.light_color.r, flame.light_color.b, "and is warm")
	fire.free()
	for node: Node3D in [CapitalProps.checkpoint_booth(), CapitalProps.fallen_statue(), CapitalProps.gate_barrier(), CapitalLandmarks.ruin_fragment(4.0, 2.4, 3), CapitalLandmarks.ruined_house(6.0, 4.0, 4.0, 5.0, 1)]:
		assert_gt(int(node.get_meta("triangles", 0)), 20, "%s is built from the kit" % node.name)
		node.free()


func test_the_inside_rows_keep_off_the_routes_and_the_people() -> void:
	# the perfect city's exact rows (CapitalDressing): along the white roads on the lawns, never within the routes' clearance or 5.5 m of a person
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.layout = layout
	builder._index_obstacles()
	builder.gate_open = true
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	var keep: Array[Vector3] = []
	for key: Variant in layout.anchors.keys():
		keep.append(layout.anchors[key] as Vector3)
	var dressing: CapitalDressing = CapitalDressing.build(parent, builder, keep)
	gut.p("rows refused: %s" % str(dressing.refused))
	var total: int = 0
	for kind: String in dressing.fields.keys():
		for entry: Dictionary in dressing.fields[kind]:
			total += 1
			var p: Vector3 = entry["pos"] as Vector3
			var solid: bool = float((TreeCards.KINDS[kind] as Dictionary).get("radius", 0.0)) > 0.0
			# nothing solid within the routes' clearance; the low rose beds along a lane's kerb stay off the lane itself
			assert_gte(layout.route_edge_distance(p.x, p.z), CapitalLayout.ROUTE_CLEARANCE if solid else 0.59, "%s at (%.1f, %.1f) keeps off the routes" % [kind, p.x, p.z])
			assert_lt(p.z, float(CapitalLayout.WALL_Z0), "the rows are inside the walls")
			var room: float = CapitalDressing.ROW_CLEAR if float((TreeCards.KINDS[kind] as Dictionary).get("radius", 0.0)) > 0.0 else CapitalDressing.LOW_CLEAR
			for anchor: Vector3 in keep:
				assert_gte(Vector2(anchor.x - p.x, anchor.z - p.z).length(), room - 0.01, "%s leaves the people their room" % kind)
	assert_gt(total, 16, "rows of topiaries, roses, lamps and benches line the white roads (%d)" % total)
	assert_gt(dressing.count("cap_topiary"), 0)
	assert_not_null(parent.find_child("WhiteRoads", true, false), "the white roads with their gold lines")
	var houses: Node3D = CapitalDistricts.facade_houses([Rect2(43.5, 19.5, 4.0, 4.0), Rect2(49.5, 19.5, 4.0, 4.0)], [3.4, 3.4])
	var body: MeshInstance3D = houses.get_node("Body") as MeshInstance3D
	var doors: bool = false
	for surface: int in range(body.mesh.get_surface_count()):
		doors = doors or body.mesh.surface_get_name(surface) == "card_CAP-SHEET-DOORS-01"
	assert_true(doors, "the identical houses wear the doors sheet's door")
	houses.free()


func test_the_first_return_to_a_freed_district_is_welcomed_once() -> void:
	# CapitalScene._welcome_district: only a freed district, only before Primm falls, once per save (a cosmetic flag nothing else reads)
	for district: String in ["transit", "hungry", "grave", "reek"]:
		var path: String = str(MusicDirector.CAPITAL_DISTRICTS[district])
		assert_true(CapitalScene.WELCOME.has(path), "%s has its sting and colours" % path)
		assert_true(str((CapitalScene.WELCOME[path] as Dictionary)["sting"]).begins_with("STG-ZONE-"), "the Path's own sting")
		assert_eq(str(CapitalScene.welcome_flag(district)), "cap_welcome_%s" % district)
	var source: String = FileAccess.get_file_as_string("res://world/capital/capital_scene.gd")
	assert_true(source.contains("Session.flag(welcome_flag(area_id))"), "seen once")
	assert_true(source.contains("Session.flag(CapitalZone.FLAG_FREED)"), "not after Primm has fallen")
