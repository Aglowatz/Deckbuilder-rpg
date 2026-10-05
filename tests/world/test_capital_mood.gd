extends GutTest
## The Capital's two moods: wasteland outside the wall, idyll inside, and the presets that go with them.


func test_inside_is_bright_and_outside_is_gray() -> void:
	var inside: ZonePreset = StylePresets.get_preset(StylePresets.CAPITAL_INSIDE)
	var outside: ZonePreset = StylePresets.get_preset(StylePresets.CAPITAL_OUTSKIRTS)
	assert_gt(inside.saturation, 1.0, "lush")
	assert_lt(outside.saturation, 0.8, "sickly")
	assert_gt(inside.sky_top.b, inside.sky_top.r, "a blue sky inside")
	assert_gt(outside.desaturate, 0.2)
	assert_gt(outside.fog_density, inside.fog_density * 4.0, "the wastes are hazy")


func test_preset_follows_the_wall() -> void:
	assert_eq(StylePresets.capital_inside(false, false), StylePresets.CAPITAL_INSIDE)
	assert_eq(StylePresets.capital(false, false), StylePresets.CAPITAL_OUTSKIRTS)
	assert_eq(StylePresets.capital_inside(true, false), StylePresets.CAPITAL_INSIDE_DARK)
	assert_eq(StylePresets.capital_inside(false, true), StylePresets.CAPITAL_FREED)


func test_both_capital_tracks_exist() -> void:
	assert_true(MusicSynth.TRACKS.has(&"capital_inside"))
	assert_true(MusicSynth.TRACKS.has(&"capital_wasteland"))
	assert_not_null(MusicSynth.render(&"capital_inside"))


func test_wasteland_dressing_keeps_the_road_clear() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: CapitalBuilder = CapitalBuilder.new()
	builder.build(host)
	var wasteland: CapitalWasteland = CapitalWasteland.build(host, builder, builder.layout, GraphicsQuality.Level.HIGH)
	assert_gt(wasteland.count, 40, "dead trees, ruins and debris")
	for child: Node in wasteland.root.get_children():
		if child is Node3D and not child is MeshInstance3D:
			var pos: Vector3 = (child as Node3D).position
			assert_false(pos.x > CapitalWasteland.ROAD_X0 and pos.x < CapitalWasteland.ROAD_X1 and pos.z < CapitalWasteland.Z_MAX, "the road stays clear")
