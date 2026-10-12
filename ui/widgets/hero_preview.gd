class_name HeroPreview
extends SubViewportContainer
## A turning preview of the painted hero wearing a `CosmeticState` (the wardrobe and the tailor's try-on). Own little world: warm key light, cool fill, a round plinth, a
## camera; the hero is the same `WorldSprite` the world uses (so hat, cloak set and dye look exactly as they will in the game, from every direction). Drag with the mouse to
## turn the hero, otherwise it turns slowly. `set_look` swaps hat, cloak and dye live.

var viewport: SubViewport
var sprite: WorldSprite
var look: CosmeticState
var spin_speed: float = 0.6
var _camera: Camera3D
var _dragging: bool = false
var _yaw: float = 0.0
var _hop: float = 0.0


func _init() -> void:
	stretch = true
	custom_minimum_size = Vector2(640, 760)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	viewport = SubViewport.new()
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.msaa_3d = Viewport.MSAA_2X
	viewport.size = Vector2i(640, 760)
	add_child(viewport)
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("8f7ed0")
	env.ambient_light_energy = 0.5
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.85
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.08
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.environment = env
	viewport.add_child(world_env)
	var key: DirectionalLight3D = DirectionalLight3D.new()
	key.light_color = Color("ffe2b0")
	key.light_energy = 1.1
	key.rotation_degrees = Vector3(-38.0, -30.0, 0.0)
	viewport.add_child(key)
	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.light_color = Color("a8b8ff")
	fill.light_energy = 0.28
	fill.rotation_degrees = Vector3(-20.0, 150.0, 0.0)
	viewport.add_child(fill)
	_camera = Camera3D.new()
	_camera.fov = 26.0
	_camera.position = Vector3(0.0, 1.0, 5.6)
	viewport.add_child(_camera)
	_camera.look_at(Vector3(0.0, 0.66, 0.0), Vector3.UP)
	_camera.current = true
	var plinth: MeshInstance3D = MeshInstance3D.new()
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = 0.82
	disc.bottom_radius = 0.9
	disc.height = 0.12
	plinth.mesh = disc
	var plinth_material: StandardMaterial3D = StandardMaterial3D.new()
	plinth_material.albedo_color = Color("5a4a78")
	plinth.material_override = plinth_material
	plinth.position = Vector3(0.0, -0.06, 0.0)
	viewport.add_child(plinth)
	StyleToon.apply(plinth)
	sprite = WorldSprite.new()
	sprite.turn_rate_degrees = 4000.0
	viewport.add_child(sprite)
	sprite.setup("PLAYER", _camera, Vector3(0.42, -0.62, -0.67))
	sprite.set_body_scale(Vector2(1.25, 1.25))
	_apply()


func set_look(new_look: CosmeticState) -> void:
	look = new_look
	_apply()


func _apply() -> void:
	if sprite == null:
		return
	SpriteCosmetics.apply(sprite, look if look != null else Session.cosmetics)


## A small hop (something was bought).
func play_once(_animation_name: StringName = &"Cheer") -> void:
	_hop = 1.0


func _process(delta: float) -> void:
	if sprite == null:
		return
	if not _dragging:
		_yaw += delta * spin_speed
	_hop = maxf(0.0, _hop - delta * 2.2)
	sprite.look_toward(Vector3(sin(_yaw), 0.0, cos(_yaw)))
	sprite.follow(Vector3(0.0, sin(_hop * PI) * 0.22, 0.0), delta)


func _gui_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		_dragging = button.pressed
		accept_event()
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null and _dragging:
		_yaw += motion.relative.x * 0.012
		accept_event()
