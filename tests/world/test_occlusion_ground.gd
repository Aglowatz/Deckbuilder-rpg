extends GutTest
## The occlusion fader's rules (Fable Nov 19, Part 1; first tests Oct 17): what looks solid stays visible. Only a tall occluder that
## really hides the hero goes see-through, as a window round him; low blockers, small props and signs never fade.


func test_wide_floor_is_ground_and_props_are_not() -> void:
	var floor_mesh: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(900.0, 900.0)
	floor_mesh.mesh = plane
	var prop: MeshInstance3D = MeshInstance3D.new()
	prop.mesh = BoxMesh.new()
	add_child_autofree(floor_mesh)
	add_child_autofree(prop)
	assert_true(OcclusionFader._is_ground(floor_mesh))
	assert_false(OcclusionFader._is_ground(prop))


func test_types_by_size_and_name() -> void:
	assert_eq(OcclusionFader.type_of(Vector3(7.2, 1.1, 0.9)), OcclusionFader.LOW_BLOCKER, "the front counter of the D.N.A.")
	assert_eq(OcclusionFader.type_of(Vector3(3.0, 1.4, 0.3)), OcclusionFader.LOW_BLOCKER, "a fence, a rail, a hedge")
	assert_eq(OcclusionFader.type_of(Vector3(0.8, 2.1, 1.5), "Signpost"), OcclusionFader.SIGN, "the signpost in Crosspath")
	assert_eq(OcclusionFader.type_of(Vector3(0.4, 4.0, 0.4)), OcclusionFader.SMALL_PROP, "a lamp post")
	assert_eq(OcclusionFader.type_of(Vector3(1.4, 2.0, 1.4)), OcclusionFader.SMALL_PROP, "a barrel stack, a potted tree")
	assert_eq(OcclusionFader.type_of(Vector3(1.5, 5.0, 0.2), "RulerBanner"), OcclusionFader.SMALL_PROP, "a banner")
	assert_eq(OcclusionFader.type_of(Vector3(8.6, 8.8, 7.5)), OcclusionFader.TALL_OCCLUDER, "a house")
	assert_eq(OcclusionFader.type_of(Vector3(48.0, 9.0, 4.0)), OcclusionFader.TALL_OCCLUDER, "the great wall of the Capital")
	assert_eq(OcclusionFader.type_of(Vector3(1.2, 6.0, 1.2)), OcclusionFader.TALL_OCCLUDER, "a column covers him")
	assert_eq(OcclusionFader.type_of(Vector3(8.0, 7.0, 8.0), "Building_signwriter"), OcclusionFader.TALL_OCCLUDER, "a name only counts at prop size")
	assert_eq(OcclusionFader.type_of(Vector3(8.0, 7.0, 8.0), "", OcclusionFader.LOW_BLOCKER), OcclusionFader.LOW_BLOCKER, "an explicit fade_type wins")
	for type: StringName in OcclusionFader.TYPES:
		assert_true(OcclusionFader.RULES.has(type), "a rule for %s" % type)


## A fader over: a hero at the origin, a lens 12 m south and 6 m up, and one box of `size` standing 6 m south of the hero (between them).
func _fader_with(size: Vector3, node_name: String = "Thing", toon: bool = false) -> Array:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0.0, 6.0, 12.0)
	root.add_child(camera)
	var hero: Node3D = Node3D.new()
	root.add_child(hero)
	var holder: Node3D = Node3D.new()
	root.add_child(holder)
	var thing: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	thing.mesh = box
	thing.name = node_name
	if toon:
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = load("res://assets/shaders/style_toon.gdshader") as Shader
		thing.material_override = material
	thing.position = Vector3(0.0, size.y * 0.5, 6.0)
	holder.add_child(thing)
	var fader: OcclusionFader = OcclusionFader.new()
	fader.camera = camera
	fader.hero = hero
	fader.root = root
	fader.set_process(false)
	root.add_child(fader)
	return [fader, thing, hero]


func _run(fader: OcclusionFader, seconds: float) -> void:
	var steps: int = int(ceilf(seconds / 0.05))
	for _step: int in range(steps):
		fader._process(0.05)


func _window(mesh: MeshInstance3D) -> float:
	var value: Variant = mesh.get_instance_shader_parameter(&"occlusion_fade")
	return float(value) if value != null else 0.0


func test_a_tall_wall_in_the_way_opens_a_window_and_is_never_faded_whole() -> void:
	var made: Array = _fader_with(Vector3(8.0, 6.0, 1.0), "Wall", true)
	var fader: OcclusionFader = made[0] as OcclusionFader
	var wall: MeshInstance3D = made[1] as MeshInstance3D
	_run(fader, 1.0)
	assert_almost_eq(_window(wall), 1.0, 0.01, "the window round the hero is open")
	assert_almost_eq(wall.transparency, 0.0, 0.001, "the wall itself is not faded")
	assert_gt(fader.hero_hidden, 0.9, "and the outline of the hero shows through it")
	assert_eq(fader.verdict_now().size(), 1)


func test_a_mesh_without_the_window_shader_fades_partly_never_to_nothing() -> void:
	var made: Array = _fader_with(Vector3(8.0, 6.0, 1.0))
	var fader: OcclusionFader = made[0] as OcclusionFader
	var wall: MeshInstance3D = made[1] as MeshInstance3D
	_run(fader, 1.0)
	assert_almost_eq(wall.transparency, OcclusionFader.WHOLE_FADE, 0.01)
	assert_lt(wall.transparency, 0.66, "35 % or more of it stays")


func test_low_blockers_small_props_and_signs_never_fade() -> void:
	for spec: Array in [[Vector3(7.2, 1.1, 0.9), "Counter"], [Vector3(6.0, 1.4, 0.4), "Fence"], [Vector3(0.4, 4.5, 0.4), "Lamp"], [Vector3(0.8, 2.1, 1.5), "Signpost"], [Vector3(1.5, 5.0, 0.2), "RulerBanner"], [Vector3(1.4, 2.0, 1.4), "Crates"]]:
		var made: Array = _fader_with(spec[0] as Vector3, str(spec[1]), true)
		var fader: OcclusionFader = made[0] as OcclusionFader
		var thing: MeshInstance3D = made[1] as MeshInstance3D
		# the hero right behind it, where it covers the most of him
		(made[2] as Node3D).position = Vector3(0.0, 0.0, 5.0)
		fader.camera.position = Vector3(0.0, 6.0, 17.0)
		_run(fader, 1.0)
		assert_almost_eq(thing.transparency, 0.0, 0.001, "%s stays solid" % str(spec[1]))
		assert_almost_eq(_window(thing), 0.0, 0.001, "%s gets no window" % str(spec[1]))
		assert_eq(fader.verdict_now(true).size(), 0, "%s is not in the verdict" % str(spec[1]))
		for row: Dictionary in fader.catalogue():
			assert_false(bool(row["can_fade"]), "%s cannot fade" % str(spec[1]))


func test_a_wall_beside_or_behind_the_hero_does_not_fade() -> void:
	var made: Array = _fader_with(Vector3(8.0, 6.0, 1.0), "Wall", true)
	var fader: OcclusionFader = made[0] as OcclusionFader
	var wall: MeshInstance3D = made[1] as MeshInstance3D
	var hero: Node3D = made[2] as Node3D
	# the hero in front of the wall (south of it), the lens further south
	hero.position = Vector3(0.0, 0.0, 8.0)
	fader.camera.position = Vector3(0.0, 6.0, 20.0)
	_run(fader, 1.0)
	assert_almost_eq(_window(wall), 0.0, 0.001, "in front of it")
	# beside its end
	hero.position = Vector3(5.5, 0.0, 5.0)
	fader.camera.position = Vector3(5.5, 6.0, 17.0)
	_run(fader, 1.0)
	assert_almost_eq(_window(wall), 0.0, 0.001, "beside it")


func test_the_window_eases_and_holds_at_an_edge() -> void:
	var made: Array = _fader_with(Vector3(8.0, 6.0, 1.0), "Wall", true)
	var fader: OcclusionFader = made[0] as OcclusionFader
	var wall: MeshInstance3D = made[1] as MeshInstance3D
	var hero: Node3D = made[2] as Node3D
	fader._process(0.05)
	fader._process(0.05)
	fader._process(0.05)
	assert_between(_window(wall), 0.05, 0.7, "it eases in (about a quarter of a second), no pop")
	_run(fader, 1.0)
	# the hero steps out past the end of the wall: the window holds a moment, then eases out
	hero.position = Vector3(6.0, 0.0, 0.0)
	fader.camera.position = Vector3(6.0, 6.0, 12.0)
	fader._process(0.07)
	assert_gt(_window(wall), 0.95, "held for a moment (hysteresis)")
	_run(fader, 1.0)
	assert_almost_eq(_window(wall), 0.0, 0.001, "then closed")


func test_a_piece_the_lens_is_inside_is_cut_away_and_leaves_its_footprint() -> void:
	var made: Array = _fader_with(Vector3(8.0, 8.0, 6.0), "House", true)
	var fader: OcclusionFader = made[0] as OcclusionFader
	var house: MeshInstance3D = made[1] as MeshInstance3D
	fader.camera.position = Vector3(0.0, 6.0, 6.0)
	_run(fader, 1.0)
	assert_almost_eq(house.transparency, 1.0, 0.01, "nothing of it can be drawn from inside")
	assert_not_null(fader.get_node_or_null("FadeFootprint"), "its footprint is outlined on the ground")
	fader.camera.position = Vector3(0.0, 6.0, 30.0)
	(made[2] as Node3D).position = Vector3(0.0, 0.0, 20.0)
	_run(fader, 1.0)
	assert_almost_eq(house.transparency, 0.0, 0.001, "back when the lens leaves")
	await get_tree().process_frame
	await get_tree().process_frame
	assert_null(fader.get_node_or_null("FadeFootprint"))


func test_a_piece_hidden_while_cut_is_solid_again_when_it_is_shown() -> void:
	var made: Array = _fader_with(Vector3(8.0, 8.0, 6.0), "House", true)
	var fader: OcclusionFader = made[0] as OcclusionFader
	var house: MeshInstance3D = made[1] as MeshInstance3D
	var hero: Node3D = made[2] as Node3D
	fader.camera.position = Vector3(0.0, 6.0, 6.0)
	_run(fader, 1.5)
	assert_almost_eq(house.transparency, 1.0, 0.01)
	# the scene hides the cut piece outright (the wall of the Capital round the lens), and the next scans no longer list it
	house.visible = false
	_run(fader, OcclusionFader.SCAN_INTERVAL * 2.0 + 1.0)
	hero.position = Vector3(0.0, 0.0, 30.0)
	fader.camera.position = Vector3(0.0, 6.0, 42.0)
	_run(fader, 1.0)
	house.visible = true
	_run(fader, OcclusionFader.SCAN_INTERVAL + 1.0)
	assert_almost_eq(house.transparency, 0.0, 0.001, "shown again, it is solid")
	assert_ne(house.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "and it casts its shadow again")


func test_buntings_are_left_alone() -> void:
	for bridge: Node3D in [BuffetLandmarks.entrance_bridge(10.0, 4.0), HeapLandmarks.entrance_bridge(10.0, 4.0)]:
		add_child_autofree(bridge)
		var bunting: MeshInstance3D = bridge.get_node_or_null("Bunting") as MeshInstance3D
		assert_not_null(bunting, "the bunting is its own mesh")
		if bunting != null:
			var size: Vector3 = (bunting.global_transform * bunting.get_aabb()).size
			assert_true(size.y < OcclusionFader.MIN_HEIGHT or OcclusionFader.type_of(size, "Bunting") != OcclusionFader.TALL_OCCLUDER, "a banner line never fades")
