extends GutTest
## Hats, cloak sets and dyes on the painted hero (docs/art/world_rollout.md, Part C). The real art arrives later, so the tests draw their own stand-in hats into a temporary
## folder: a hat must sit on the head anchor of the frame that shows, mirror with the body, and follow it through the walk cycle; a cloak set swaps the whole sprite.

const TEST_HATS: String = "user://test_hats/"

var _camera: Camera3D
var _sprite: WorldSprite


func before_each() -> void:
	SpriteLibrary.reset()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(TEST_HATS + "TESTHAT"))
	for dir_name: String in SpriteLibrary.HAT_DIRS:
		var image: Image = Image.create_empty(120, 80, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.8, 0.2, 0.9, 1.0))
		image.save_png(ProjectSettings.globalize_path(TEST_HATS + "TESTHAT/%s.png" % dir_name))
	SpriteLibrary.hat_folder = TEST_HATS
	var scene: Node3D = Node3D.new()
	add_child_autofree(scene)
	_camera = Camera3D.new()
	scene.add_child(_camera)
	_camera.position = Vector3(0.0, 1.5, 6.0)
	_camera.look_at_from_position(Vector3(0.0, 1.5, 6.0), Vector3(0.0, 0.8, 0.0), Vector3.UP)
	_camera.current = true
	_sprite = WorldSprite.new()
	_sprite.turn_rate_degrees = 100000.0
	scene.add_child(_sprite)
	assert_true(_sprite.setup("PLAYER", _camera, Vector3(0.42, -0.62, -0.67)))


func after_each() -> void:
	SpriteLibrary.reset()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_HATS + "TESTHAT/FRONT.png"))


func test_head_anchor_finds_the_top_of_the_head() -> void:
	var image: Image = Image.create_empty(200, 300, false, Image.FORMAT_RGBA8)
	# A body (rectangle) with a round head on top: head centre x = 120, top row = 40.
	for y: int in range(40, 300):
		for x: int in range(200):
			var in_head: bool = y < 100 and Vector2(float(x) - 120.0, float(y) - 70.0).length() < 30.0
			var in_body: bool = y >= 100 and x >= 90 and x < 150
			if in_head or in_body:
				image.set_pixel(x, y, Color(1, 1, 1, 1))
	var anchor: Array = SpriteAnchors.head_anchor(image)
	assert_eq(anchor.size(), 4)
	assert_almost_eq(float(anchor[0]), 120.0, 2.0, "centre of the crown")
	assert_between(int(anchor[1]), 40, 42, "top row")
	assert_between(float(anchor[2]), 24.0, 62.0, "head width near the top")
	assert_eq(SpriteAnchors.head_anchor(Image.create_empty(10, 10, false, Image.FORMAT_RGBA8)).size(), 0, "an empty frame has no head")


func test_every_hero_frame_has_a_head_anchor_and_the_cloak_is_found_by_hue() -> void:
	var info: Dictionary = SpriteLibrary.info("PLAYER")
	for frame: Variant in info["frames"] as Array:
		var anchor: Array = SpriteLibrary.head_anchor("PLAYER", str(frame))
		assert_eq(anchor.size(), 3, "%s has a head anchor" % frame)
		var canvas: Array = info["canvas"] as Array
		assert_between(float(anchor[0]), 0.0, float(canvas[0]), "%s: inside the canvas" % frame)
	var hue: Array = SpriteLibrary.cloak_hue("PLAYER")
	assert_eq(hue.size(), 2)
	assert_between(float(hue[0]), 0.42, 0.62, "the default cloak is a dark teal, not the hero's brown")


func test_a_hat_sits_on_the_head_and_mirrors_with_the_body() -> void:
	_sprite.set_hat("TESTHAT")
	assert_eq(_sprite.hat_name(), "TESTHAT")
	# Facing the camera.
	_sprite.snap_heading(Vector3(0.0, 0.0, 1.0))
	_sprite.follow(Vector3.ZERO, 0.016)
	assert_true(_sprite.hat_visible)
	assert_eq(_sprite.current_dir, "FRONT")
	var front_rect: Rect2 = _sprite.hat_rect
	assert_gt(front_rect.position.y, 1.0, "the hat is above the shoulders of a 1.25 m hero")
	assert_lt(front_rect.position.y, 1.5)
	assert_gt(front_rect.size.x, 0.1)
	# A side view pointing to the screen's right is the mirror of the one pointing left.
	_sprite.snap_heading(Vector3(1.0, 0.0, 0.0))
	_sprite.follow(Vector3.ZERO, 0.016)
	var right_rect: Rect2 = _sprite.hat_rect
	var right_flip: bool = _sprite.current_flip
	_sprite.snap_heading(Vector3(-1.0, 0.0, 0.0))
	_sprite.follow(Vector3.ZERO, 0.016)
	var left_rect: Rect2 = _sprite.hat_rect
	assert_ne(right_flip, _sprite.current_flip, "the two sides use mirrored art")
	assert_almost_eq(right_rect.get_center().x, -left_rect.get_center().x, 0.002, "the hat is mirrored with the body")
	assert_almost_eq(right_rect.position.y, left_rect.position.y, 0.002, "and at the same height")


func test_the_hat_follows_the_head_through_the_walk_cycle() -> void:
	_sprite.set_hat("TESTHAT")
	_sprite.snap_heading(Vector3(1.0, 0.0, 0.0))
	_sprite.follow(Vector3.ZERO, 0.016)
	var seen_keys: Dictionary = {}
	var heights: Array[float] = []
	var position: Vector3 = Vector3.ZERO
	for frame: int in range(120):
		position += Vector3(0.07, 0.0, 0.0)
		_sprite.follow(position, 0.016)
		if _sprite.walking:
			seen_keys[_sprite.current_key] = _sprite.hat_rect
			heights.append(_sprite.hat_rect.position.y)
	assert_gte(seen_keys.size(), 4, "all four walk frames were shown")
	for key: Variant in seen_keys.keys():
		var rect: Rect2 = seen_keys[key] as Rect2
		var anchor: Array = SpriteLibrary.head_anchor("PLAYER", str(key))
		assert_eq(anchor.size(), 3)
		# The hat's width is the head width of THIS frame times the fit, so it changes with the frame like the head does.
		var fit: Dictionary = SpriteLibrary.hat_fit("TESTHAT", "SIDE")
		var head_world: float = float(anchor[2]) * (1.25 / 440.0)
		assert_almost_eq(rect.size.x, head_world * float(fit["width"]) * float(fit["scale"]), 0.002, "%s: sized from its own head" % key)
	var low: float = heights.min()
	var high: float = heights.max()
	assert_lt(high - low, 0.12, "the hat does not leap about: it follows a head that bobs a few centimetres")


func test_a_missing_hat_is_left_off_and_nothing_breaks() -> void:
	_sprite.set_hat("NOPE")
	assert_eq(_sprite.hat_name(), "")
	_sprite.follow(Vector3.ZERO, 0.016)
	assert_false(_sprite.hat_visible)
	assert_false(SpriteLibrary.has_hat("NOPE"))
	assert_false(SpriteLibrary.has_cloak("NOPE"))
	assert_eq(SpriteLibrary.cloak_character("NOPE"), "PLAYER", "an unknown cloak is the default one")
	assert_false(_sprite.set_character("PLAYER_CLOAK_NOPE"), "an unknown set is refused")
	assert_eq(_sprite.character, "PLAYER")
	var item: CosmeticData = CosmeticCatalog.find("cloak_red_cape")
	assert_eq(SpriteCosmetics.art_ready(item), SpriteLibrary.has_cloak("REDCAPE"))


func test_a_cloak_set_swaps_the_whole_sprite_and_falls_back_per_frame() -> void:
	var fake: Dictionary = (SpriteLibrary.info("PLAYER") as Dictionary).duplicate(true)
	SpriteLibrary.manifest()["PLAYER_CLOAK_TEST"] = fake
	assert_true(SpriteLibrary.has_cloak("TEST"))
	assert_eq(SpriteLibrary.cloak_character("TEST"), "PLAYER_CLOAK_TEST")
	assert_true(_sprite.set_character("PLAYER_CLOAK_TEST"))
	assert_eq(_sprite.character, "PLAYER_CLOAK_TEST")
	# The set has no image files here: every frame falls back to the default hero's.
	_sprite.follow(Vector3.ZERO, 0.016)
	assert_not_null(SpriteLibrary.frame_or_default("PLAYER_CLOAK_TEST", "FRONT_IDLE"))
	SpriteLibrary.manifest().erase("PLAYER_CLOAK_TEST")


func test_the_dye_reaches_the_shader_and_the_state_drives_it() -> void:
	var state: CosmeticState = CosmeticState.new()
	state.set_dye(CosmeticData.Slot.CLOAK, 0)
	SpriteCosmetics.apply(_sprite, state)
	var material: ShaderMaterial = _sprite.get_child(0).material_override as ShaderMaterial
	assert_almost_eq(float(material.get_shader_parameter("dye_amount")), 1.0, 0.001)
	assert_eq(material.get_shader_parameter("dye_color"), Dye.primary(0))
	assert_almost_eq(float(material.get_shader_parameter("dye_hue")), float(SpriteLibrary.cloak_hue("PLAYER")[0]), 0.001, "the hue band is the cloak's")
	state.set_dye(CosmeticData.Slot.CLOAK, Dye.NATURAL)
	SpriteCosmetics.apply(_sprite, state)
	assert_almost_eq(float(material.get_shader_parameter("dye_amount")), 0.0, 0.001, "natural = no recolour")


func test_the_actor_is_what_the_scenes_drive() -> void:
	var player: Node3D = Node3D.new()
	add_child_autofree(player)
	var actor: SpriteActor = SpriteActor.new()
	actor.follow_cosmetics = false
	player.add_child(actor)
	actor.scale = Vector3.ONE * 0.34
	await get_tree().process_frame
	assert_not_null(actor.sprite)
	assert_true(actor.sprite.local_mode)
	# A squash (the bounce pad) and a tumble go through the shader, a blink through visible.
	actor.scale = Vector3(1.35, 0.6, 1.35) * 0.34
	actor.rotation = Vector3(0.5, 1.0, 0.25)
	actor._process(0.016)
	assert_almost_eq(actor.sprite.roll_radians, 0.75, 0.001)
	assert_almost_eq(actor.sprite.scale.x * actor.scale.x, 1.0, 0.001, "the card itself never inherits the squash (its contact shadow would shrink)")
	actor.visible = false
	assert_false(actor.sprite.is_visible_in_tree(), "blinking the model hides the card")
