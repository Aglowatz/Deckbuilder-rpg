extends GutTest
## WorldSprite / SpriteLibrary / LookParams (docs/art/world_look_test.md): the imported frames line up, the eight directions follow the camera, the live look values are complete.

const CHARACTERS: Array[String] = ["PLAYER", "ELDER", "GATEKEEPER", "SABLE", "TONIC", "FENWICK", "VILLAGER"]


func _sprite(character: String) -> WorldSprite:
	var camera: Camera3D = Camera3D.new()
	add_child_autofree(camera)
	var sprite: WorldSprite = WorldSprite.new()
	add_child_autofree(sprite)
	assert_true(sprite.setup(character, camera), "%s sets up" % character)
	return sprite


func test_manifest_lists_every_character_with_loadable_frames() -> void:
	for character: String in CHARACTERS:
		assert_true(SpriteLibrary.has_character(character), "%s is in the manifest" % character)
		var info: Dictionary = SpriteLibrary.info(character)
		var canvas: Array = info["canvas"] as Array
		for key: Variant in info["frames"] as Array:
			var texture: Texture2D = SpriteLibrary.frame(character, str(key))
			assert_not_null(texture, "%s %s loads" % [character, str(key)])
			if texture != null:
				assert_eq(texture.get_width(), int(canvas[0]), "%s %s shares the canvas width" % [character, str(key)])
				assert_eq(texture.get_height(), int(canvas[1]), "%s %s shares the canvas height" % [character, str(key)])


func test_walkers_have_four_walk_frames_in_five_directions() -> void:
	for character: String in ["PLAYER", "VILLAGER"]:
		var frames: Array = SpriteLibrary.info(character)["frames"] as Array
		for dir_name: String in WorldSprite.DIR_ANGLES.keys():
			assert_true(frames.has("%s_IDLE" % dir_name), "%s %s idle" % [character, dir_name])
			for n: int in range(1, 5):
				assert_true(frames.has("%s_WALK%d" % [dir_name, n]), "%s %s walk %d" % [character, dir_name, n])


func test_standing_characters_have_idle_directions_and_a_talk_pose() -> void:
	for character: String in ["ELDER", "GATEKEEPER", "SABLE", "TONIC", "FENWICK"]:
		var info: Dictionary = SpriteLibrary.info(character)
		assert_true(bool(info["has_talk"]), "%s can talk" % character)
		assert_eq((info["dirs"] as Array).size(), 3, "%s has front, side and back" % character)


func test_height_follows_the_relative_height() -> void:
	var player: WorldSprite = _sprite("PLAYER")
	var guard: WorldSprite = _sprite("GATEKEEPER")
	assert_almost_eq(player.world_height, WorldSprite.PLAYER_HEIGHT, 0.001)
	assert_almost_eq(guard.world_height, WorldSprite.PLAYER_HEIGHT * 1.35, 0.001)


func test_direction_follows_the_heading_relative_to_the_camera() -> void:
	var sprite: WorldSprite = _sprite("PLAYER")
	# The default camera looks along -z; facing the camera means pointing along +z.
	var expectations: Array[Array] = [
		[Vector3(0, 0, 1), "FRONT", false],
		[Vector3(0, 0, -1), "BACK", false],
		[Vector3(1, 0, 0), "SIDE", true],
		[Vector3(-1, 0, 0), "SIDE", false],
		[Vector3(1, 0, 1), "FRONTSIDE", true],
		[Vector3(-1, 0, 1), "FRONTSIDE", false],
		[Vector3(1, 0, -1), "BACKSIDE", true],
		[Vector3(-1, 0, -1), "BACKSIDE", false],
	]
	for entry: Array in expectations:
		sprite.snap_heading(entry[0] as Vector3)
		sprite.follow(Vector3.ZERO, 0.016)
		assert_eq(sprite.current_dir, str(entry[1]), "heading %s" % str(entry[0]))
		assert_eq(sprite.current_flip, bool(entry[2]), "heading %s mirrors" % str(entry[0]))


func test_walking_cycles_through_the_four_frames_at_a_pace_that_follows_speed() -> void:
	var sprite: WorldSprite = _sprite("PLAYER")
	sprite.snap_heading(Vector3(-1, 0, 0))
	var seen: Dictionary = {}
	var x: float = 0.0
	for i: int in range(120):
		x -= 3.0 * 0.016
		sprite.follow(Vector3(x, 0, 0), 0.016)
		seen[sprite.current_key] = true
	assert_true(sprite.walking, "moving at 3 m/s is walking")
	for n: int in range(1, 5):
		assert_true(seen.has("SIDE_WALK%d" % n), "frame SIDE_WALK%d was shown" % n)
	var slow: WorldSprite = _sprite("PLAYER")
	slow.snap_heading(Vector3(-1, 0, 0))
	var slow_frames: Dictionary = {}
	var sx: float = 0.0
	for i: int in range(120):
		sx -= 0.6 * 0.016
		slow.follow(Vector3(sx, 0, 0), 0.016)
		slow_frames[slow.current_key] = true
	assert_lt(slow_frames.size(), seen.size() + 1, "a slow walk never cycles faster")


func test_standing_still_uses_the_idle_frame() -> void:
	var sprite: WorldSprite = _sprite("VILLAGER")
	sprite.snap_heading(Vector3(0, 0, 1))
	sprite.follow(Vector3.ZERO, 0.016)
	sprite.follow(Vector3.ZERO, 0.016)
	assert_false(sprite.walking)
	assert_eq(sprite.current_key, "FRONT_IDLE")


func test_talk_pose_replaces_the_idle_front_frame() -> void:
	var sprite: WorldSprite = _sprite("ELDER")
	sprite.snap_heading(Vector3(1, 0, 0))
	sprite.talking = true
	sprite.follow(Vector3.ZERO, 0.016)
	assert_eq(sprite.current_key, "FRONT_TALK")
	sprite.talking = false
	sprite.follow(Vector3.ZERO, 0.016)
	assert_eq(sprite.current_key, "SIDE_IDLE")


func test_three_direction_characters_pick_the_nearest_drawn_direction() -> void:
	var sprite: WorldSprite = _sprite("SABLE")
	sprite.snap_heading(Vector3(1, 0, 1))
	sprite.follow(Vector3.ZERO, 0.016)
	assert_true(sprite.current_dir == "FRONT" or sprite.current_dir == "SIDE", "a diagonal falls back to front or side, not a missing frame")
	sprite.snap_heading(Vector3(0, 0, -1))
	sprite.follow(Vector3.ZERO, 0.016)
	assert_eq(sprite.current_dir, "BACK")


func test_look_params_are_complete() -> void:
	for slider: Dictionary in LookParams.SLIDERS:
		var key: String = str(slider["key"])
		for values: Dictionary in [LookParams.recommended(), LookParams.old_preset(0), LookParams.old_preset(2), LookParams.old_preset(3)]:
			assert_true(values.has(key), "%s present" % key)
			assert_between(float(values[key]), float(slider["min"]) - 0.001, float(slider["max"]) + 0.001, "%s inside its slider range" % key)
	assert_true(LookParams.recommended().has("fog_color"))
