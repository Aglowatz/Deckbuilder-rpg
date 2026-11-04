class_name HeroBust
extends SubViewport
## Fix pass Nov 4 (Part 3.3): the hero's head and shoulders, painted sprite and all, wearing the current look (hat, cloak set, cloak dye) -
## the picture in your battle plate's round socket, so a dye or a hat bought at Pip's shows in battle too. A small offscreen world (the
## same `WorldSprite` and `SpriteCosmetics` as the overworld and the Wardrobe), rendered a few times while the frames load, then held.
## Use `texture()` as the plate's picture; the node must stay in the tree.

const PIXELS: int = 160

var sprite: WorldSprite
var look: CosmeticState
var _camera: Camera3D
var _frames_left: int = 12


func _init() -> void:
	size = Vector2i(PIXELS, PIXELS)
	own_world_3d = true
	transparent_bg = true
	msaa_3d = Viewport.MSAA_2X
	render_target_update_mode = SubViewport.UPDATE_ALWAYS


func _ready() -> void:
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("8f7ed0")
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.9
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var key: DirectionalLight3D = DirectionalLight3D.new()
	key.light_color = Color("ffe2b0")
	key.light_energy = 1.1
	key.rotation_degrees = Vector3(-38.0, -30.0, 0.0)
	add_child(key)
	_camera = Camera3D.new()
	_camera.fov = 24.0
	# head and shoulders of the 1.25x hero (about 2.3 m with a tall hat)
	_camera.position = Vector3(0.0, 2.0, 1.9)
	add_child(_camera)
	_camera.look_at(Vector3(0.0, 1.95, 0.0), Vector3.UP)
	_camera.current = true
	sprite = WorldSprite.new()
	add_child(sprite)
	sprite.setup("PLAYER", _camera, Vector3(0.42, -0.62, -0.67))
	sprite.set_body_scale(Vector2(1.25, 1.25))
	SpriteCosmetics.apply(sprite, look if look != null else Session.cosmetics)


func texture() -> Texture2D:
	return get_texture()


func _process(delta: float) -> void:
	if sprite != null and _frames_left > 0:
		sprite.look_toward(Vector3(0.0, 0.0, 1.0))
		sprite.follow(Vector3.ZERO, delta)
	# A few frames while the sprite's frames and the dye mask arrive, then the picture is held (no cost for the rest of the duel).
	if _frames_left > 0:
		_frames_left -= 1
		if _frames_left == 0:
			render_target_update_mode = SubViewport.UPDATE_DISABLED
