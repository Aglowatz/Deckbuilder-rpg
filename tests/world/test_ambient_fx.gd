extends GutTest
## Overnight Oct 17, Part 14: light per-area atmosphere around the hero and footstep puffs coloured by the surface.


func test_every_zone_has_a_light_preset() -> void:
	for zone_id: String in ["beefcake", "necrocrat", "gourmand", "refusemancer", "final"]:
		var key: String = str(ZoneScene.AMBIENT_KEYS.get(zone_id, ""))
		assert_true(AmbientFx.PRESETS.has(key), "%s -> %s" % [zone_id, key])
	for key: Variant in AmbientFx.PRESETS.keys():
		var preset: Dictionary = AmbientFx.PRESETS[key] as Dictionary
		assert_lte(int(preset["amount"]), 40, "%s stays light" % key)
		assert_lte((preset["color"] as Color).a, 0.61, "%s stays soft" % key)


func test_motes_follow_the_hero_and_cast_no_shadows() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var hero: Node3D = Node3D.new()
	hero.position = Vector3(5, 0, 3)
	root.add_child(hero)
	var fx: AmbientFx = AmbientFx.add(root, "gainlands", hero)
	await wait_process_frames(2)
	assert_not_null(fx.motes)
	assert_eq(fx.motes.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_almost_eq(fx.motes.global_position.x, 5.0, 0.01)
	hero.position = Vector3(-4, 0, 1)
	await wait_process_frames(2)
	assert_almost_eq(fx.motes.global_position.x, -4.0, 0.01, "the motes move with the hero")


func test_a_hero_footstep_puffs_the_ground() -> void:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var fx: AmbientFx = AmbientFx.add(root, "", root)
	await wait_process_frames(1)
	assert_null(fx.motes, "no preset, no motes (the forest keeps its fireflies)")
	EventBus.hero_footstep.emit(Vector3(1, 0, 2), &"dirt")
	var puffs: CPUParticles3D = fx.find_child("FootstepPuffs", true, false) as CPUParticles3D
	assert_true(puffs.emitting, "a dirt step puffs")
	assert_almost_eq(puffs.global_position.x, 1.0, 0.01)
