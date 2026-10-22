extends Node
## Renders the painted hero in all eight directions (a row of eight; --mode=idle or --mode=walk for a mid-stride frame) with an optional hat, cloak set and dye, to one PNG.
## Windowed run (a scene, so the autoloads exist):  SPRITE_HAT_FOLDER=res://_art_inbox/fake_hats/ Godot --path . --resolution 1700x420 res://tools/sprite_sheet_shot.tscn -- --hat=WIZARD --mode=walk --out=hats_wizard
## Output: _screenshots/<out>.png. Direction 0 faces the camera, then 45 degrees at a time towards the screen's right (the art mirrors the left-looking frames).

var _args: Dictionary = {}
var _sprites: Array[WorldSprite] = []
var _frames: int = 0
var _walk: bool = false
var _camera: Camera3D
var _captures: Array[Image] = []
var _headings: Array[Vector3] = []
var _view: SubViewport


func _ready() -> void:
	# The picture size asked for on the command line.
	var wanted: PackedStringArray = PackedStringArray()
	var all_args: PackedStringArray = OS.get_cmdline_args()
	for n: int in range(all_args.size() - 1):
		if all_args[n] == "--resolution":
			wanted = all_args[n + 1].split("x")
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_walk = str(_args.get("mode", "idle")) == "walk"
	var scene: Node3D = Node3D.new()
	# A fixed-size SubViewport (the window itself is sized by the Settings autoload and the desktop): --resolution WxH, default 1700x420.
	_view = SubViewport.new()
	_view.size = Vector2i(int(wanted[0]), int(wanted[1])) if wanted.size() == 2 else Vector2i(1700, 420)
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_view)
	_view.add_child(scene)
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
	# Fit the row of eight (about 13.6 m wide at 15 m) to the picture width, so the figures fill the height of a wide strip.
	_camera.fov = rad_to_deg(2.0 * atan(6.8 / 15.0 / (float(_view.size.x) / float(_view.size.y))))
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
		_headings.append(Vector3(sin(angle), 0.0, cos(angle)))
		_sprites.append(sprite)
	print("sprite_sheet: ready (hat=%s cloak=%s mode=%s)" % [hat, cloak, "walk" if _walk else "idle"])


func _process(_delta: float) -> void:
	_frames += 1
	# --rows=N (walk mode): N captures, --every frames apart, stacked into one picture, so every walk frame of every direction shows (Apparel Part 1).
	var rows: int = maxi(1, int(_args.get("rows", "1")))
	var every: int = int(_args.get("every", "9"))
	for index: int in range(_sprites.size()):
		var sprite: WorldSprite = _sprites[index]
		var base: Vector3 = Vector3(float(index) * 1.8, 0.0, 0.0)
		if _walk:
			# Moving along the heading at walking speed so the walk frames play; the position wraps back every 30 frames (never during a multi-row capture).
			var along: float = float(_frames % (30 if rows == 1 else 100000)) * 0.016 * 4.6
			sprite.follow(base + _headings[index] * along, 0.016)
			if rows > 1:
				# Keep the walker in its column: the walk cycle runs from the moving position, the card is drawn at the column (the bob stays).
				sprite.position = Vector3(base.x, sprite.position.y, base.z)
		else:
			sprite.follow(base, 0.016)
	if _frames >= 44 and (_frames - 44) % every == 0 and _captures.size() < rows:
		_captures.append(_view.get_texture().get_image())
	if _captures.size() >= rows:
		var first: Image = _captures[0]
		var image: Image = Image.create_empty(first.get_width(), first.get_height() * rows, false, first.get_format())
		for row: int in range(rows):
			image.blit_rect(_captures[row], Rect2i(Vector2i.ZERO, first.get_size()), Vector2i(0, first.get_height() * row))
		var path: String = ProjectSettings.globalize_path("res://_screenshots/%s.png" % str(_args.get("out", "sprite_sheet")))
		image.save_png(path)
		print("sprite_sheet: saved %s" % path)
		get_tree().quit()
