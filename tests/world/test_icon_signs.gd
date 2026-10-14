extends GutTest
## G-03 (no readable text in the world): the Gainlands signs and every zone's ruler props carry pictograms; the words are read by using them.


func _labels(node: Node) -> Array[Node]:
	return node.find_children("*", "Label3D", true, false)


func test_the_rulers_banners_and_plinth_have_no_lettering() -> void:
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer"]:
		var parent: Node3D = Node3D.new()
		add_child_autofree(parent)
		RulerPresence.build(parent, ZoneMap.new(), ZoneDefs.get_def(zone_id), ZoneStoryText.for_zone(zone_id), Vector3(50, 0, 60), false)
		assert_eq(_labels(parent).size(), 0, "%s: no Label3D on the statue or banners" % zone_id)
		assert_gt(parent.find_children("Emblem", "MeshInstance3D", true, false).size(), 1, "%s: the emblem stands in for the words" % zone_id)


func test_every_gainlands_sign_has_a_pictogram() -> void:
	var layout: GainlandsLayout = GainlandsLayout.new()
	layout.build()
	assert_gte(layout.signs.size(), 8, "the Gainlands keeps the 8 boards that point somewhere or carry a quiz answer (corrective pass, GC-2)")
	for sign: GainlandsLayout.Sign in layout.signs:
		assert_true(IconArt.has(GainlandsBuilder.sign_icon(sign.key)), "%s has an icon" % sign.key)
		assert_true(GainlandsBuilder.SIGN_ICONS.has(sign.key), "%s is mapped on purpose (not the fallback)" % sign.key)


func test_the_gainlands_hub_builds_with_no_lettering_on_its_signs() -> void:
	Session.new_game()
	var scene: Node = (load("res://scenes/gainlands_zone.tscn") as PackedScene).instantiate()
	if scene.has_method("screenshot_prepare"):
		scene.call("screenshot_prepare", {"nohud": "true"})
	add_child_autofree(scene)
	await get_tree().process_frame
	var signs: int = 0
	for node: Node in scene.find_children("SignIcon", "MeshInstance3D", true, false):
		signs += 1
		assert_eq(_labels(node.get_parent()).size(), 0, "a sign board carries no text")
	var layout: GainlandsLayout = GainlandsLayout.new()
	layout.build()
	assert_eq(signs, layout.signs.size(), "one pictogram per sign")
	var readable: int = 0
	for spot: ZoneSpot in (scene as ZoneScene).spots:
		if spot.kind == "sign":
			readable += 1
	assert_eq(readable, signs, "every sign can be read by using it")


func test_the_normal_buffer_outline_is_a_high_quality_feature() -> void:
	assert_false(GraphicsQuality.outline_normals(GraphicsQuality.Level.MEDIUM))
	assert_true(GraphicsQuality.outline_normals(GraphicsQuality.Level.HIGH))
	assert_true(GraphicsQuality.outlines(GraphicsQuality.Level.MEDIUM), "Medium still has outlines (depth edges)")
	assert_true(ResourceLoader.exists("res://assets/shaders/style_outline_depth.gdshader"))


func test_walking_out_of_a_zone_returns_to_its_entrance_in_town() -> void:
	Session.new_game()
	Session.ensure_game()
	Session.pending_zone_id = ""
	# enter_zone changes the scene; the part under test is only what it records first.
	var source: String = FileAccess.get_file_as_string("res://app/game_session.gd")
	var body: String = source.substr(source.find("func enter_zone(zone_id: String)"), 300)
	assert_true(body.contains("pending_zone_id = zone_id"), "enter_zone remembers the entrance for the way back")


func test_every_sub_area_gate_has_an_icon_and_no_plate() -> void:
	var count: int = 0
	for area_id: String in ["main_town", "starting_forest", "gainlands", "dna", "buffet", "heap", "capital_outside", "capital_inside", "castle_grounds", "pathology_lab"]:
		for gate: Dictionary in SubAreaDefs.gates(area_id):
			count += 1
			assert_true(gate.has("icon"), "%s/%s: the gate names an icon" % [area_id, str(gate["sub"])])
			assert_true(IconArt.has(str(gate.get("icon", ""))), "%s/%s: the icon exists" % [area_id, str(gate["sub"])])
	assert_gte(count, 26)
	var hub: Node3D = Node3D.new()
	add_child_autofree(hub)
	Session.new_game()
	Session.set_flag(&"trial_cleared")
	var gates: SubAreaGates = SubAreaGates.install(hub, ["main_town"] as Array[String])
	assert_not_null(gates)
	await get_tree().process_frame
	assert_eq(gates.find_children("*", "Label3D", true, false).size(), 0, "no 3D lettering on the gates")
	assert_eq(gates._icons.size(), 4, "one pictogram per gate")
	for icon: MeshInstance3D in gates._icons:
		assert_not_null((icon.material_override as StandardMaterial3D).albedo_texture, "the pictogram has its icon texture")
