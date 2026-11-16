extends GutTest
## Overnight Nov 16, Part 2: the items left open by the Nov 13 to Nov 15 passes - the Dump's fair stage dressed from its kit, the camera
## held in from the Dump's south corners, the minimap's own picture layer, the wooded cleft at Crosspath's south edge, the Capital's
## rim ruins stored between visits.


func _flat_boxes(node: Node) -> Array[String]:
	var found: Array[String] = []
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = child as MeshInstance3D
		if not mesh.mesh is BoxMesh:
			continue
		var material: StandardMaterial3D = mesh.material_override as StandardMaterial3D
		if material == null:
			material = mesh.mesh.surface_get_material(0) as StandardMaterial3D
		if material != null and material.albedo_texture == null:
			var size: Vector3 = (mesh.mesh as BoxMesh).size
			found.append("%s %s %s" % [mesh.name, str(size), str(material.albedo_color)])
	return found


func test_the_fair_stage_is_dressed_from_the_dump_kit() -> void:
	var stage: Node3D = HeapProps.fair_stage(null)
	add_child_autofree(stage)
	assert_not_null(stage.get_node_or_null("FairDressing"), "the kit-dressed bins, bunting and sign board")
	for index: int in range(8):
		assert_null(stage.get_node_or_null("Flag%d" % index), "no square paper flag %d" % index)
	# the flat one-colour pieces that are left are the deck (wood) and the belt: no blue banner board, no four coloured bins
	for line: String in _flat_boxes(stage):
		assert_false(line.contains("(5.2, 0.9, 0.1)"), "the flat blue banner board is gone: %s" % line)
		assert_false(line.contains("(0.8, 0.7, 0.7)"), "the flat sorting bins are gone: %s" % line)
	for id: String in ["DUMP-SHEET-FLAGS-01", "DUMP-SHEET-FLAGS-02", "DUMP-SHEET-FLAGS-03", "DUMP-SHEET-FLAGS-05", "DUMP-SHEET-FLAGS-06"]:
		assert_true(EnvKit.has_art(id), "%s (the painted cloth bunting) is imported" % id)


func test_the_dump_camera_is_held_in_from_the_south_corners() -> void:
	var max_corner: Vector2 = HeapLayout.MAX_CORNER
	var min_corner: Vector2 = HeapLayout.MIN_CORNER
	# in the south-east corner the camera stands well west of the hero; in the south-west corner well east
	var hero_se: Vector3 = Vector3(max_corner.x - 5.0, 0.0, max_corner.y - 5.0)
	var held_se: Vector3 = HeapScene.south_corner_target(hero_se + Vector3(0.0, 6.0, 15.0), hero_se)
	assert_lt(held_se.x, hero_se.x - 4.0, "held in from the east rim")
	assert_eq(held_se.y, 6.0, "its height is untouched")
	assert_eq(held_se.z, hero_se.z + 15.0)
	var hero_sw: Vector3 = Vector3(min_corner.x + 5.0, 0.0, max_corner.y - 5.0)
	assert_gt(HeapScene.south_corner_target(hero_sw + Vector3(0.0, 6.0, 15.0), hero_sw).x, hero_sw.x + 4.0, "held in from the west rim")
	# the middle of the south band (the bridge head) and everything north of the band are untouched
	var hero_mid: Vector3 = Vector3((min_corner.x + max_corner.x) * 0.5, 0.0, max_corner.y - 5.0)
	assert_eq(HeapScene.south_corner_target(hero_mid + Vector3(0.0, 6.0, 15.0), hero_mid), hero_mid + Vector3(0.0, 6.0, 15.0))
	var hero_north: Vector3 = Vector3(max_corner.x - 5.0, 0.0, max_corner.y - HeapScene.SOUTH_CORNER_BAND - 1.0)
	assert_eq(HeapScene.south_corner_target(hero_north + Vector3(0.0, 6.0, 15.0), hero_north), hero_north + Vector3(0.0, 6.0, 15.0))
	# the hold grows smoothly: no jump at the band's edge
	var just_in: Vector3 = Vector3(max_corner.x - 5.0, 0.0, max_corner.y - HeapScene.SOUTH_CORNER_BAND + 0.5)
	assert_almost_eq(HeapScene.south_corner_target(just_in + Vector3(0.0, 6.0, 15.0), just_in).x, just_in.x, 0.2)


func test_the_minimap_picture_shader_is_in_place() -> void:
	var shader: Shader = load("res://ui/shaders/minimap_picture.gdshader") as Shader
	assert_not_null(shader)
	var names: Array[String] = []
	for uniform: Dictionary in shader.get_shader_uniform_list():
		names.append(str(uniform["name"]))
	for wanted: String in ["map_tex", "tex_size", "region_pos", "region_size", "radius"]:
		assert_true(names.has(wanted), "the shader takes %s" % wanted)
	var source: String = FileAccess.get_file_as_string("res://ui/minimap/minimap_hud.gd")
	assert_true(source.contains("minimap_picture.gdshader"), "the framed minimap draws its map through it")
	assert_true(source.contains("show_behind_parent = true"), "behind the markers, not over them")


func test_crosspath_s_south_cleft_is_wooded() -> void:
	assert_gte(HubLand.GORGE_WOOD_ROWS.size(), 2, "at least two staggered rows of crowns")
	for row: Vector2 in HubLand.GORGE_WOOD_ROWS:
		assert_lt(absf(row.x), HubLand.GORGE_WIDTH * 0.5 + 0.5, "a row stands in the cleft or on its far lip")
		assert_lte(row.y, 1.0, "a crown's top stays a metre or less over the ground: under the camera's line to the hero's feet")
	assert_gt(HubLand.GORGE_WOOD_GAP, HubLand.GORGE_HEDGE_GAP, "no tree beside the bridge")
	assert_gt(HubLand.GORGE_SHADE_DEPTH, 3.0, "the shade sheet lies under the crowns, not through them")
	for kind: String in HubLand.GORGE_WOOD_KINDS:
		assert_true(TreeCards.KINDS.has(kind), "%s is a painted tree" % kind)


func test_the_capital_s_rim_ruins_are_stored_with_their_lists() -> void:
	var source: String = FileAccess.get_file_as_string("res://world/capital/capital_rim_ruins.gd")
	assert_true(source.contains("BuildCache.fetch_node(\"capital_rim_ruins_m_"), "the ruins are stored per density")
	assert_true(source.contains("KitBatch.merge_static(ruins.root)"), "merged before they are stored, so a later visit does not merge them again")
	assert_true(source.contains("&\"placed\""), "the lists of what stands where travel with the stored subtree")
	# the landmark models are built live: stored copies broke the walk to Rollo (the Capital walk smoke)
	var builder: String = FileAccess.get_file_as_string("res://world/capital/capital_builder.gd")
	assert_false(builder.contains("fetch_node(\"capital_landmark"), "no landmark is stored")
