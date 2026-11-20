extends GutTest
## Fable Nov 21 (Part 7.2): trees, the D.N.A.'s cabinets and the Iron Cave's rock open the same round window round the hero as the
## buildings (the shared include in their shaders), and the hero's outline is drawn behind batched pieces (tree fields, merged cabinets).


func _fader() -> OcclusionFader:
	var fader: OcclusionFader = OcclusionFader.new()
	add_child_autofree(fader)
	return fader


func test_the_three_shaders_carry_the_window() -> void:
	for path: String in ["res://world/kit/kit_card.gdshader", "res://world/dna/dna_fade.gdshader", "res://assets/shaders/style_painted_terrain.gdshader"]:
		var source: String = FileAccess.get_file_as_string(path)
		assert_string_contains(source, "#include \"res://assets/shaders/style_occlusion.gdshaderinc\"", path)
		assert_string_contains(source, "occlusion_window_cut(", path)
	assert_false(FileAccess.get_file_as_string("res://world/kit/kit_card.gdshader").contains("ALPHA = 1.0 - v_fade"), "a tree no longer fades as a whole card")
	assert_string_contains(FileAccess.get_file_as_string("res://world/style/occlusion_fader.gd"), "style_painted_terrain", "the fader gives the rock its window")


func test_a_tree_field_and_a_cabinet_mesh_say_where_their_pieces_stand() -> void:
	var parent: Node3D = Node3D.new()
	add_child_autofree(parent)
	var kind: String = str(TreeCards.KINDS.keys()[0])
	var entries: Array[Dictionary] = [{"pos": Vector3(4, 0, 6), "scale": 1.0}, {"pos": Vector3(9, 0, 2), "scale": 1.2}]
	var field: MultiMeshInstance3D = KitFoliage.tree_field(parent, kind, entries, false)
	assert_not_null(field)
	var pieces: PackedFloat32Array = field.get_meta(OcclusionFader.META_PIECES) as PackedFloat32Array
	assert_eq(pieces.size(), 8, "x, z, half width and top for each tree")
	assert_almost_eq(pieces[0], 4.0, 0.001)
	assert_almost_eq(pieces[1], 6.0, 0.001)
	assert_gt(pieces[3], 2.0, "a tree's top")
	var mesh: DnaFadeMesh = DnaFadeMesh.new()
	mesh.set_slot("cabinet", "")
	mesh.set_slot("wall", "", Color.WHITE, 1.0, 0.0, 6.0)
	mesh.box("cabinet", Vector4(3, 3, 0.5, 2.4), Vector3(3, 1.2, 3), Vector3(1, 2.4, 1))
	mesh.box("wall", Vector4(8, 3, 0.5, 10.0), Vector3(8, 5, 3), Vector3(1, 10, 1))
	var built: MeshInstance3D = mesh.instance()
	autofree(built)
	var cabinet_pieces: PackedFloat32Array = built.get_meta(OcclusionFader.META_PIECES) as PackedFloat32Array
	assert_eq(cabinet_pieces.size(), 4, "the cabinet, not the full wall (walls keep the room cut)")


func test_a_tall_piece_on_the_sight_line_hides_the_hero_and_others_do_not() -> void:
	var fader: OcclusionFader = _fader()
	var lens: Vector3 = Vector3(0, 10, 18)
	var hero: Vector3 = Vector3(0, 0, 0)
	fader._pieces = PackedFloat32Array([0.0, 4.0, 1.2, 6.0])
	assert_true(fader.pieces_cover(lens, hero), "a 6 m tree 4 m in front of the hero, on the line")
	fader._pieces = PackedFloat32Array([5.0, 4.0, 1.2, 6.0])
	assert_false(fader.pieces_cover(lens, hero), "the same tree 5 m to the side")
	fader._pieces = PackedFloat32Array([0.0, -4.0, 1.2, 6.0])
	assert_false(fader.pieces_cover(lens, hero), "a tree behind the hero")
	fader._pieces = PackedFloat32Array([0.0, 4.0, 1.2, 1.4])
	assert_false(fader.pieces_cover(lens, hero), "a bush lower than his shoulder")
	fader._pieces = PackedFloat32Array([0.0, 0.8, 1.2, 6.0])
	assert_false(fader.pieces_cover(lens, hero), "a tree he stands right beside (its shader does not cut there either)")
	fader._pieces = PackedFloat32Array([0.0, 15.0, 1.2, 3.0])
	assert_false(fader.pieces_cover(lens, hero), "a low piece near the lens, under the sight line")
