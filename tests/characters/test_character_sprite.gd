extends GutTest
## Character look test bench (docs/art/character_test.md): every imported frame exists, and the sprite picks its direction from movement relative to the camera.


func _sprite(pixel: bool) -> Array:
	var camera: Camera3D = Camera3D.new()
	add_child_autofree(camera)
	# The town camera: south of the hero, looking north (-z).
	camera.position = Vector3(0.0, 8.0, 10.0)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	var sprite: CharSprite = CharSprite.new()
	add_child_autofree(sprite)
	sprite.setup(pixel, camera)
	return [sprite, camera]


func _walk(sprite: CharSprite, direction: Vector3) -> void:
	# Two steps, so the second one has a measured velocity.
	var position: Vector3 = Vector3.ZERO
	for _i: int in range(6):
		position += direction * 0.08
		sprite.follow(position, 0.016)


func test_every_frame_is_imported() -> void:
	for folder: String in ["hd2d", "painted"]:
		for dir_name: String in CharSprite.DIRS:
			for frame_name: String in CharSprite.FRAMES:
				var path: String = "res://assets/art/characters/%s/%s_%s.png" % [folder, dir_name, frame_name]
				assert_true(ResourceLoader.exists(path), path)


func test_direction_follows_movement_relative_to_the_camera() -> void:
	var built: Array = _sprite(true)
	var sprite: CharSprite = built[0] as CharSprite
	_walk(sprite, Vector3(0, 0, 1))
	assert_true(sprite.current_frame.begins_with("FRONT"), "towards the camera shows the front")
	var away: Array = _sprite(true)
	_walk(away[0] as CharSprite, Vector3(0, 0, -1))
	assert_true((away[0] as CharSprite).current_frame.begins_with("BACK"), "away from the camera shows the back")
	var left: Array = _sprite(false)
	_walk(left[0] as CharSprite, Vector3(-1, 0, 0))
	assert_true((left[0] as CharSprite).current_frame.begins_with("SIDE"))
	assert_false((left[0] as CharSprite).current_flip, "the side art looks left, so moving left is not mirrored")
	var right: Array = _sprite(false)
	_walk(right[0] as CharSprite, Vector3(1, 0, 0))
	assert_true((right[0] as CharSprite).current_flip, "moving right mirrors the side art")


func test_idle_uses_the_idle_frame() -> void:
	var built: Array = _sprite(false)
	var sprite: CharSprite = built[0] as CharSprite
	sprite.follow(Vector3.ZERO, 0.016)
	sprite.follow(Vector3.ZERO, 0.016)
	assert_eq(sprite.current_frame, "FRONT_IDLE")


func test_camera_presets_are_ordered_from_high_to_low() -> void:
	var previous: float = 90.0
	for preset: Dictionary in CharacterTest.PRESETS:
		assert_lt(float(preset["pitch"]), previous + 0.01, str(preset["name"]))
		previous = float(preset["pitch"])
