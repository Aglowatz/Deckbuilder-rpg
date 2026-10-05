class_name HeroPreview
extends SubViewportContainer
## A rotating 3D preview of the hero wearing a `CosmeticState` (the wardrobe, the starting-look choice and the tailor's try-on). Own little world: warm key light,
## cool fill, a round plinth; drag with the mouse to turn the hero, otherwise it turns slowly. `set_look` swaps the hat, cloak and dyes live.

var viewport: SubViewport
var model: Node3D
var look: CosmeticState
var spin_speed: float = 0.5
var _pivot: Node3D
var _camera: Camera3D
var _dragging: bool = false
var _time: float = 0.0
var _idle_hold: float = 0.0


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
	_camera.fov = 30.0
	_camera.position = Vector3(0.0, 1.9, 6.4)
	viewport.add_child(_camera)
	_camera.look_at(Vector3(0.0, 1.22, 0.0), Vector3.UP)
	_camera.current = true
	_pivot = Node3D.new()
	viewport.add_child(_pivot)
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
	_rebuild()


func set_look(new_look: CosmeticState) -> void:
	look = new_look
	if model != null and is_instance_valid(model):
		HeroModel.refresh(model, look)
	else:
		_rebuild()


func _rebuild() -> void:
	if _pivot == null:
		return
	if model != null and is_instance_valid(model):
		model.queue_free()
	model = HeroModel.build(look if look != null else Session.cosmetics)
	_pivot.add_child(model)
	model.scale = Vector3.ONE * 1.0
	var player: AnimationPlayer = ModelKit.animation_player(model)
	if player != null and player.has_animation("Idle"):
		player.play("Idle")


## Plays a one-off animation (a wave when something is bought) and returns to idle.
func play_once(animation_name: StringName) -> void:
	var player: AnimationPlayer = ModelKit.animation_player(model)
	if player == null or not player.has_animation(animation_name):
		return
	var animation: Animation = player.get_animation(animation_name)
	animation.loop_mode = Animation.LOOP_NONE
	player.play(animation_name, 0.15)
	_idle_hold = animation.length
	var tween: Tween = create_tween()
	tween.tween_interval(animation.length)
	tween.tween_callback(func() -> void:
		if is_instance_valid(player):
			player.play("Idle", 0.2))


func _process(delta: float) -> void:
	_time += delta
	if _pivot != null and not _dragging:
		_pivot.rotation.y += delta * spin_speed
	_idle_hold = maxf(0.0, _idle_hold - delta)


func _gui_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		_dragging = button.pressed
		accept_event()
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null and _dragging and _pivot != null:
		_pivot.rotation.y += motion.relative.x * 0.012
		accept_event()


func _exit_tree() -> void:
	if model != null and is_instance_valid(model):
		model.queue_free()
