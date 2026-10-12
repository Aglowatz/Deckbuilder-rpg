extends SceneTree
## Renders the painted hero in all eight directions (a row of eight; --mode=idle or --mode=walk for a mid-stride frame) with an optional hat, cloak set and dye, to one PNG.
## Windowed run:  SPRITE_HAT_FOLDER=res://_art_inbox/fake_hats/ Godot --path . --resolution 1700x420 -s res://tools/sprite_sheet_shot.gd -- --hat=WIZARD --mode=walk --out=hats_wizard
## Output: _screenshots/<out>.png. Direction 0 faces the camera, then 45 degrees at a time towards the screen's right (the art mirrors the left-looking frames).

var _args: Dictionary = {}
var _sprites: Array[WorldSprite] = []
var _frames: int = 0
var _walk: bool = false
var _camera: Camera3D


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_walk = str(_args.get("mode", "idle")) == "walk"
	var scene: Node3D = Node3D.new()
	root.add_child(scene)
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.62, 0.7)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.8, 0.9)
	env.ambient_light_energy = 0.7
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.environment = env
	scene.add_child(world_env)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40.0, -30.0, 0.0)
	scene.add_child(sun)
	_camera = Camera3D.new()
	_camera.fov = 24.0
	_camera.position = Vector3(6.3, 1.4, 15.0)
	scene.add_child(_camera)
	_camera.look_at_from_position(Vector3(6.3, 1.4, 15.0), Vector3(6.3, 0.8, 0.0), Vector3.UP)
	_camera.current = true
	var hat: String = str(_args.get("hat", ""))
	var cloak: String = str(_args.get("cloak", ""))
	for column: int in range(8):
		var sprite: WorldSprite = WorldSprite.new()
		sprite.turn_rate_degrees = 100000.0
		scene.add_child(sprite)
		sprite.setup("PLAYER", _camera, Vector3(0.42, -0.62, -0.67))
		if cloak != "":
			sprite.set_character(SpriteLibrary.cloak_character(cloak))
		sprite.set_hat(hat)
		if _args.has("dye"):
			sprite.set_dye(Dye.primary(int(_args["dye"])), 1.0)
		var angle: float = deg_to_rad(float(column) * 45.0)
		sprite.snap_heading(Vector3(sin(angle), 0.0, cos(angle)))
		_sprites.append(sprite)
	print("sprite_sheet: ready (hat=%s cloak=%s mode=%s)" % [hat, cloak, "walk" if _walk else "idle"])


func _process(delta: float) -> bool:
	_frames += 1
	for index: int in range(_sprites.size()):
		var sprite: WorldSprite = _sprites[index]
		var base: Vector3 = Vector3(float(index) * 1.8, 0.0, 0.0)
		if _walk:
			# Moving along the heading at walking speed so the walk frames play; the position wraps back every 30 frames.
			var along: float = float(_frames % 30) * 0.016 * 4.6
			sprite.follow(base + sprite.heading * along, 0.016)
		else:
			sprite.follow(base, 0.016)
	if _frames == 44:
		var image: Image = root.get_viewport().get_texture().get_image()
		var path: String = ProjectSettings.globalize_path("res://_screenshots/%s.png" % str(_args.get("out", "sprite_sheet")))
		image.save_png(path)
		print("sprite_sheet: saved %s" % path)
		return true
	return false
