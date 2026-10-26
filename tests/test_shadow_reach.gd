extends GutTest
## Fixes Oct 26, Part 1: the sun's shadow reaches the top of the screen on Medium and High (each area's measured view depth), while Low,
## Safe Mode and Intel integrated GPUs never get heavier.

var _heavy: bool = true


func before_each() -> void:
	_heavy = GraphicsQuality.heavy_passes_allowed


func after_each() -> void:
	GraphicsQuality.heavy_passes_allowed = _heavy


func test_medium_and_high_reach_the_measured_view_depth() -> void:
	GraphicsQuality.heavy_passes_allowed = true
	for preset: StringName in StyleRig.SHADOW_REACH.keys():
		var reach: float = float(StyleRig.SHADOW_REACH[preset])
		assert_eq(GraphicsQuality.sun_shadow_reach(GraphicsQuality.Level.MEDIUM, reach), reach, "Medium in %s" % preset)
		assert_eq(GraphicsQuality.sun_shadow_reach(GraphicsQuality.Level.HIGH, reach), reach, "High in %s" % preset)
		assert_eq(GraphicsQuality.sun_shadow_splits(GraphicsQuality.Level.MEDIUM, reach), 2, "Medium splits in %s" % preset)


func test_every_area_reaches_past_the_old_26_m() -> void:
	for preset: StringName in [&"town", &"start", &"gainlands", &"buffet", &"dna", &"heap", &"capital"]:
		assert_true(StyleRig.SHADOW_REACH.has(preset), "measured reach for %s" % preset)
		assert_gt(float(StyleRig.SHADOW_REACH.get(preset, 0.0)), 48.0, preset)


func test_low_safe_mode_and_intel_never_get_heavier() -> void:
	GraphicsQuality.heavy_passes_allowed = true
	assert_eq(GraphicsQuality.shadow_detail(GraphicsQuality.Level.LOW), 0, "Low (and Safe Mode, which is Low) has no sun shadow")
	assert_eq(GraphicsQuality.sun_shadow_atlas(GraphicsQuality.Level.LOW), 1024)
	assert_eq(GraphicsQuality.sun_shadow_atlas(GraphicsQuality.Level.MEDIUM), 1024, "Medium atlas unchanged (2048 measured and dropped)")
	GraphicsQuality.heavy_passes_allowed = false
	assert_eq(GraphicsQuality.sun_shadow_reach(GraphicsQuality.Level.MEDIUM, 176.0), 26.0, "Intel Medium keeps 26 m")
	assert_eq(GraphicsQuality.sun_shadow_reach(GraphicsQuality.Level.HIGH, 176.0), 48.0, "Intel High keeps 48 m")
	assert_eq(GraphicsQuality.sun_shadow_splits(GraphicsQuality.Level.MEDIUM, 26.0), 1, "Intel Medium keeps one map")
	assert_eq(GraphicsQuality.sun_shadow_splits(GraphicsQuality.Level.HIGH, 48.0), 2, "Intel High keeps two splits")


func test_scenes_without_a_measured_reach_keep_the_old_one() -> void:
	GraphicsQuality.heavy_passes_allowed = true
	assert_eq(GraphicsQuality.sun_shadow_reach(GraphicsQuality.Level.MEDIUM, 0.0), 26.0)
	assert_eq(GraphicsQuality.sun_shadow_reach(GraphicsQuality.Level.HIGH, 0.0), 48.0)


func test_rig_applies_the_reach_and_switches_small_far_casters() -> void:
	var scene: Node3D = Node3D.new()
	var cam: Camera3D = Camera3D.new()
	scene.add_child(cam)
	var near_box: MeshInstance3D = MeshInstance3D.new()
	near_box.mesh = BoxMesh.new()
	near_box.position = Vector3(0, 0, -10)
	scene.add_child(near_box)
	var far_box: MeshInstance3D = MeshInstance3D.new()
	far_box.mesh = BoxMesh.new()
	far_box.position = Vector3(0, 0, -120)
	scene.add_child(far_box)
	var ground: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(200, 200)
	ground.mesh = plane
	scene.add_child(ground)
	add_child_autofree(scene)
	var rig: StyleRig = StyleRig.install(scene, &"heap", cam)
	rig.quality_override = GraphicsQuality.Level.MEDIUM
	GraphicsQuality.heavy_passes_allowed = true
	rig.apply()
	assert_almost_eq(rig.sun.directional_shadow_max_distance, float(StyleRig.SHADOW_REACH[&"heap"]), 0.01)
	assert_eq(rig.sun.directional_shadow_mode, DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS)
	assert_eq(ground.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "a flat ground plane never casts")
	for i: int in 3:
		rig._process(0.016)
	assert_eq(near_box.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_ON, "a small caster near the camera keeps its shadow")
	assert_eq(far_box.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "a small caster beyond the near cascade drops it")
	assert_eq(rig.area_shadow_reach(), float(StyleRig.SHADOW_REACH[&"heap"]))
