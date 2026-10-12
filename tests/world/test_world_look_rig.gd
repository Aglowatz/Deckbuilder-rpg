extends GutTest
## The rolled-out world look (docs/art/world_rollout.md, Parts A and B): the camera values, the per-zone moods in data/art/zone_looks.json, the rig that applies them
## (post pass, bloom, fog, sky, scenery, foliage), the graphics options, and the occlusion fader's cut-away.

var _scene: Node3D
var _camera: Camera3D
var _hero: Node3D


func before_each() -> void:
	WorldLookRig.clear_cache()
	_scene = Node3D.new()
	add_child_autofree(_scene)
	_camera = Camera3D.new()
	_scene.add_child(_camera)
	_camera.current = true
	_hero = Node3D.new()
	_scene.add_child(_hero)


func after_each() -> void:
	Settings.depth_of_field = true
	Settings.bloom = true
	Settings.fog_quality = 2
	Settings.graphics_quality = GraphicsQuality.Level.MEDIUM
	WorldLookRig.clear_cache()


func test_the_game_camera_is_the_approved_look() -> void:
	var values: Dictionary = WorldLookRig.game_values()
	if LookParams.load_my_preset().is_empty():
		assert_eq(float(values["pitch"]), 20.0)
		assert_eq(float(values["distance"]), 6.2)
		assert_eq(float(values["fov"]), 44.0)
		assert_eq(float(values["height"]), 0.9)
		assert_eq(float(values["focus"]), 0.62)
		assert_eq(float(values["band"]), 0.13)
		assert_eq(float(values["bloom"]), 0.5)
		assert_eq(float(values["bloom_threshold"]), 1.05)
		assert_eq(float(values["fog_density"]), 0.0035)
		assert_eq(str(values["fog_color"]), "f2cfa4")
	var offset: Vector3 = WorldLookRig.base_offset()
	assert_almost_eq(rad_to_deg(atan2(offset.y, offset.z)), float(values["pitch"]), 0.01)
	assert_almost_eq(offset.length(), float(values["distance"]), 0.001)
	assert_gt(WorldLookRig.wide_offset(1.3).length(), offset.length(), "a pulled-back view is farther away")
	assert_true(Settings.ZOOM_MIN >= 1.0 and Settings.ZOOM_MAX <= 2.0, "the wheel keeps the camera between 6 and 12 m")


func test_every_world_preset_has_a_complete_mood() -> void:
	for id: StringName in StylePresets.ids():
		if id in [StylePresets.BATTLE, StylePresets.DUNGEON, StylePresets.ARENA]:
			continue
		var mood: Dictionary = WorldLookRig.mood_for(id)
		var values: Dictionary = WorldLookRig.values_for(mood)
		for slider: Dictionary in LookParams.SLIDERS:
			assert_true(values.has(str(slider["key"])), "%s has %s" % [id, slider["key"]])
		assert_true(str(values["fog_color"]).is_valid_html_color(), "%s fog colour" % id)
		var sky: Dictionary = mood["sky"] as Dictionary
		if bool(sky.get("enabled", true)):
			for key: String in ["horizon", "gold", "mid", "zenith"]:
				if sky.has(key):
					assert_true(str(sky[key]).is_valid_html_color(), "%s sky %s" % [id, key])
		assert_true(mood.has("scenery") and mood.has("foliage") and mood.has("ambient"), "%s has every block" % id)


func test_zones_have_their_own_mood() -> void:
	var dna: Dictionary = WorldLookRig.values_for(WorldLookRig.mood_for(StylePresets.DNA))
	var gain: Dictionary = WorldLookRig.values_for(WorldLookRig.mood_for(StylePresets.GAINLANDS))
	var outside: Dictionary = WorldLookRig.values_for(WorldLookRig.mood_for(StylePresets.CAPITAL_OUTSKIRTS))
	var inside: Dictionary = WorldLookRig.values_for(WorldLookRig.mood_for(StylePresets.CAPITAL_INSIDE))
	assert_lt(float(dna["saturation"]), float(gain["saturation"]), "the D.N.A. is near-monochrome, the Gainlands saturated")
	assert_lt(float(outside["saturation"]), float(inside["saturation"]), "the Capital outside is bleak, inside is eerily perfect")
	assert_gt(float(outside["vignette"]), float(inside["vignette"]))
	assert_ne(str(dna["fog_color"]), str(gain["fog_color"]))
	# The camera itself is shared: no mood changes it.
	for values: Dictionary in [dna, gain, outside, inside]:
		assert_eq(float(values["pitch"]), float(WorldLookRig.game_values()["pitch"]))
		assert_eq(float(values["fov"]), float(WorldLookRig.game_values()["fov"]))
	var variant: Dictionary = WorldLookRig.mood_for(StylePresets.CAPITAL_DARK)
	assert_gt(float((variant["sky"] as Dictionary).size()), 0.0, "a variant extends its parent mood")


func test_the_rig_aims_the_camera_low_and_pushes_the_look() -> void:
	var rig: StyleRig = StyleRig.install(_scene, StylePresets.TOWN, _camera, _hero)
	var look: WorldLookRig = WorldLookRig.install(_scene, _camera, _hero, rig, null, false)
	await get_tree().process_frame
	_hero.position = Vector3(10.0, 0.0, 10.0)
	_camera.position = _hero.position + WorldLookRig.base_offset() * Settings.camera_zoom
	look._process(0.016)
	var forward: Vector3 = -_camera.global_basis.z
	var down_degrees: float = rad_to_deg(asin(-forward.y))
	var expected: float = float(WorldLookRig.game_values()["pitch"]) - rad_to_deg(atan2(float(WorldLookRig.game_values()["height"]), float(WorldLookRig.game_values()["distance"])))
	assert_almost_eq(down_degrees, expected, 0.2, "the view is the pitch minus the height offset's tilt")
	assert_almost_eq(_camera.fov, float(WorldLookRig.game_values()["fov"]), 0.01)
	assert_not_null(look.post_rect, "the post pass exists")
	var material: ShaderMaterial = look.post_rect.material as ShaderMaterial
	assert_gt(float(material.get_shader_parameter("blur_far")), 0.0, "tilt-shift on")
	Settings.depth_of_field = false
	Settings.graphics_changed.emit()
	assert_eq(float(material.get_shader_parameter("blur_far")), 0.0, "tilt-shift off from the settings")
	Settings.depth_of_field = true
	Settings.bloom = false
	Settings.graphics_changed.emit()
	assert_false(rig.world_env.environment.glow_enabled, "bloom off from the settings")
	Settings.bloom = true
	Settings.fog_quality = 0
	Settings.graphics_changed.emit()
	assert_false(rig.world_env.environment.fog_enabled, "fog off from the settings")
	Settings.fog_quality = 1
	Settings.graphics_changed.emit()
	assert_almost_eq(rig.world_env.environment.fog_density, float(WorldLookRig.mood_for(StylePresets.TOWN)["look"].get("fog_density", WorldLookRig.game_values()["fog_density"])) * 0.5, 0.0005, "light fog is half")
	Settings.fog_quality = 2
	Settings.graphics_quality = GraphicsQuality.Level.LOW
	Settings.graphics_changed.emit()
	assert_eq(float(material.get_shader_parameter("blur_far")), 0.0, "no tilt-shift on Low")


func test_the_sky_survives_a_graphics_change_and_a_mood_change() -> void:
	var rig: StyleRig = StyleRig.install(_scene, StylePresets.GAINLANDS, _camera, _hero)
	var area: WalkableArea = WalkableArea.new()
	var look: WorldLookRig = WorldLookRig.install(_scene, _camera, _hero, rig, area, true)
	await get_tree().process_frame
	assert_not_null(look.sky, "the outdoor mood has a sky")
	assert_not_null(look.scenery, "and distant scenery")
	assert_eq(rig.world_env.environment.background_mode, Environment.BG_SKY)
	Settings.graphics_changed.emit()
	assert_not_null(rig.world_env.environment.sky, "the sky is re-attached to the fresh environment")
	look.set_mood(StylePresets.CAPITAL_OUTSKIRTS)
	assert_eq(look.mood_id, StylePresets.CAPITAL_OUTSKIRTS)
	assert_eq(str(look.values["fog_color"]), str(WorldLookRig.mood_for(StylePresets.CAPITAL_OUTSKIRTS)["look"]["fog_color"]))


func test_an_indoor_mood_has_no_clouds_but_a_floor_that_goes_on() -> void:
	var rig: StyleRig = StyleRig.install(_scene, StylePresets.DNA, _camera, _hero)
	var area: WalkableArea = WalkableArea.new()
	var look: WorldLookRig = WorldLookRig.install(_scene, _camera, _hero, rig, area, true)
	await get_tree().process_frame
	assert_not_null(look.scenery)
	assert_not_null(look.scenery.get_node_or_null("Apron"), "the office floor carries on to the horizon")
	assert_null(look.scenery.get_node_or_null("WaterPlane"), "no sea inside")
	assert_null(look.foliage, "no grass in an office")


func test_the_fader_cuts_away_what_the_camera_is_inside() -> void:
	var fader: OcclusionFader = OcclusionFader.new()
	fader.camera = _camera
	fader.hero = _hero
	fader.root = _scene
	_scene.add_child(fader)
	var wall: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(4.0, 4.0, 1.0)
	wall.mesh = box
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://assets/shaders/style_toon.gdshader") as Shader
	wall.material_override = material
	_scene.add_child(wall)
	wall.position = Vector3(0.0, 2.0, 5.0)
	_hero.position = Vector3(0.0, 0.0, 0.0)
	# Camera behind the wall: the wall is between the camera and the hero (faded, not cut away).
	_camera.position = Vector3(0.0, 2.0, 9.0)
	fader._scan()
	for i: int in range(40):
		fader._process(0.1)
	assert_gt(float(wall.get_instance_shader_parameter("occlusion_fade")), 0.5, "a wall in the way fades")
	assert_lt(float(wall.get_instance_shader_parameter("occlusion_fade")), 0.95, "but is not cut away")
	# Camera inside the wall's volume: cut away entirely.
	_camera.position = Vector3(0.0, 2.0, 5.0)
	for i: int in range(40):
		fader._process(0.1)
	assert_almost_eq(float(wall.get_instance_shader_parameter("occlusion_fade")), 1.0, 0.01, "a wall around the lens is cut away")
	# A mesh flagged as part of the look (rings, sky) never fades.
	wall.set_meta(&"no_occlusion_fade", true)
	fader._scan()
	assert_false(fader._candidates.has(wall))
