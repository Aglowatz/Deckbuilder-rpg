extends GutTest
## Overnight Oct 17 (Phase 2 cycle 3): wide terrain never fades with the group of a blocking prop (the starting forest floor went 88% see-through).


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


## Overnight Oct 19 (Part 1): a thin piece hanging over the hero's ground (a pennant line across an entrance) blocks the view and qualifies; ground clutter,
## small pieces and tall pieces (handled by the normal height rule) do not count as overhead.
func test_overhead_pieces_qualify_and_ground_clutter_does_not() -> void:
	assert_true(OcclusionFader.is_overhead(AABB(Vector3(-3, 2.6, 0.4), Vector3(6, 0.8, 0.1)), 0.0), "a pennant line across a bridge")
	assert_false(OcclusionFader.is_overhead(AABB(Vector3(-3, 0.0, 0.0), Vector3(6, 0.1, 3)), 0.0), "a rug")
	assert_false(OcclusionFader.is_overhead(AABB(Vector3(0, 2.6, 0), Vector3(0.4, 0.4, 0.4)), 0.0), "a small lantern")
	assert_false(OcclusionFader.is_overhead(AABB(Vector3(-3, 6.6, 0.4), Vector3(6, 0.8, 0.1)), 5.6), "the same line at the hero's knees on a terrace")
	assert_false(OcclusionFader.is_overhead(AABB(Vector3(-3, 2.0, 0), Vector3(6, 3.0, 1)), 0.0), "a tall piece uses the normal rule")


func test_entrance_bunting_fades_on_its_own() -> void:
	for bridge: Node3D in [BuffetLandmarks.entrance_bridge(10.0, 4.0), HeapLandmarks.entrance_bridge(10.0, 4.0)]:
		add_child_autofree(bridge)
		var bunting: MeshInstance3D = bridge.get_node_or_null("Bunting") as MeshInstance3D
		assert_not_null(bunting, "the bunting is its own mesh")
		if bunting != null:
			assert_true(bunting.has_meta(&"occlusion_overhead"))
			assert_false(bunting.has_meta(&"no_occlusion_fade"))


# ---- Fable Nov 12c (A6): a piece hidden while it is faded comes back solid ---------------------------------------------------


func _fader_with_wall() -> Array:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0.0, 6.0, 12.0)
	root.add_child(camera)
	var hero: Node3D = Node3D.new()
	root.add_child(hero)
	var holder: Node3D = Node3D.new()
	root.add_child(holder)
	var wall: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(8.0, 6.0, 1.0)
	wall.mesh = box
	wall.position = Vector3(0.0, 3.0, 6.0)  # between the lens and the hero
	holder.add_child(wall)
	var fader: OcclusionFader = OcclusionFader.new()
	fader.camera = camera
	fader.hero = hero
	fader.root = root
	fader.set_process(false)
	root.add_child(fader)
	return [fader, wall, hero]


func _run(fader: OcclusionFader, seconds: float) -> void:
	var steps: int = int(ceilf(seconds / 0.05))
	for _step: int in range(steps):
		fader._process(0.05)


func test_a_piece_hidden_while_faded_is_solid_again_when_it_is_shown() -> void:
	var made: Array = _fader_with_wall()
	var fader: OcclusionFader = made[0] as OcclusionFader
	var wall: MeshInstance3D = made[1] as MeshInstance3D
	var hero: Node3D = made[2] as Node3D
	_run(fader, 1.5)
	assert_almost_eq(wall.transparency, OcclusionFader.FADED, 0.01, "the wall between the lens and the hero fades out")
	# the scene hides the faded piece outright (the Capital's wall round the lens), and the next scans no longer list it
	wall.visible = false
	_run(fader, OcclusionFader.SCAN_INTERVAL * 2.0 + 1.0)
	# the hero walks round to the other side: nothing blocks any more, and the scene shows the piece again
	hero.position = Vector3(0.0, 0.0, 30.0)
	fader.camera.position = Vector3(0.0, 6.0, 42.0)
	_run(fader, 1.0)
	wall.visible = true
	_run(fader, OcclusionFader.SCAN_INTERVAL + 1.0)
	assert_almost_eq(wall.transparency, 0.0, 0.001, "shown again, the wall is solid - it used to stay fully transparent for the rest of the visit")
	assert_ne(wall.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "and it casts its shadow again")


func test_a_piece_that_still_blocks_fades_again_after_being_shown() -> void:
	var made: Array = _fader_with_wall()
	var fader: OcclusionFader = made[0] as OcclusionFader
	var wall: MeshInstance3D = made[1] as MeshInstance3D
	_run(fader, 1.5)
	wall.visible = false
	_run(fader, OcclusionFader.SCAN_INTERVAL * 2.0 + 1.0)
	wall.visible = true
	_run(fader, OcclusionFader.SCAN_INTERVAL + 1.5)
	assert_almost_eq(wall.transparency, OcclusionFader.FADED, 0.01, "still in the way: it fades out again")
