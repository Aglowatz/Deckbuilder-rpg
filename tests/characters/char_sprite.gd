class_name CharSprite
extends Node3D
## Character look test (docs/art/character_test.md): a camera-facing character card driven by movement relative to the camera.
## Two looks share the class: HD-2D (`pixel = true`, nearest filter, integer-ish texel size on screen) and painted 2.5D (smooth, scene-lit).
## FRONT when moving towards the camera, BACK when moving away, SIDE (mirrored for right) otherwise; the nearest of the three on diagonals.

const SHADER: String = "res://tests/characters/char_sprite.gdshader"
const DIRS: Array[String] = ["FRONT", "BACK", "SIDE"]
const FRAMES: Array[String] = ["IDLE", "WALK1", "WALK2"]
## Walk cycle: IDLE, WALK1, IDLE, WALK2.
const CYCLE: Array[int] = [0, 1, 0, 2]
## World distance travelled per full walk cycle (two steps); the cycle rate is speed / this.
const STRIDE: float = 1.3
const MAX_CYCLES_PER_SECOND: float = 4.0
## The sprite's world height for the painted look (the 3D hero is about 0.7 tall; cards read better a little bigger).
const PAINTED_HEIGHT: float = 1.0
## Same for the pixel look before screen-pixel snapping.
const PIXEL_HEIGHT: float = 1.0

var pixel: bool = false
var camera: Camera3D
var _mesh: MeshInstance3D
var _material: ShaderMaterial
var _textures: Dictionary = {}
var _tex_size: Vector2 = Vector2.ONE
var _baseline_margin_px: float = 0.0
var _figure_px: float = 1.0
var _dir: String = "FRONT"
var _flip: bool = false
var _phase: float = 0.0
var _time: float = 0.0
var _last_pos: Vector3 = Vector3.ZERO
var _have_last: bool = false
var _texel_px: float = 1.0
var _world_height: float = 1.0
var _shadow: MeshInstance3D
## What the last frame chose, for tests and the HUD caption.
var current_frame: String = "FRONT_IDLE"
var current_flip: bool = false


func setup(use_pixel: bool, cam: Camera3D) -> void:
	pixel = use_pixel
	camera = cam
	var folder: String = "hd2d" if pixel else "painted"
	for dir_name: String in DIRS:
		for frame_name: String in FRAMES:
			var key: String = "%s_%s" % [dir_name, frame_name]
			_textures[key] = load("res://assets/art/characters/%s/%s.png" % [folder, key])
	var first: Texture2D = _textures["FRONT_IDLE"]
	_tex_size = first.get_size()
	# The painted canvas leaves a small margin under the feet; the pixel canvas has none. The figure itself is ~93 % of the painted canvas.
	_baseline_margin_px = 16.0 if not pixel else 0.0
	_figure_px = (536.0 if not pixel else _tex_size.y)
	_material = ShaderMaterial.new()
	_material.shader = load(SHADER) as Shader
	_material.set_shader_parameter("pixel", pixel)
	_material.set_shader_parameter("react", 0.0 if pixel else 1.0)
	var quad: QuadMesh = QuadMesh.new()
	# Unit-height quad (aspect of the canvas), feet baseline on the origin; `world_scale` sizes it.
	var aspect: float = _tex_size.x / _tex_size.y
	quad.size = Vector2(aspect, 1.0)
	quad.center_offset = Vector3(0.0, 0.5 - _baseline_margin_px / _tex_size.y, 0.0)
	_mesh = MeshInstance3D.new()
	_mesh.mesh = quad
	_mesh.material_override = _material
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh.set_meta(StyleToon.META_NO_TOON, true)
	_mesh.extra_cull_margin = 2.0
	add_child(_mesh)
	_shadow = ContactShadow.attach(self, 0.5)
	_apply_frame("FRONT_IDLE", false)
	_update_scale(true)


## Called every frame with the hero's world position (the sprite follows it) and the frame time.
func follow(world_pos: Vector3, delta: float) -> void:
	_time += delta
	var moved: Vector3 = (world_pos - _last_pos) if _have_last else Vector3.ZERO
	_last_pos = world_pos
	_have_last = true
	moved.y = 0.0
	var speed: float = moved.length() / maxf(delta, 0.0001)
	var moving: bool = speed > 0.4
	if moving:
		_pick_direction(moved.normalized())
	var frame_index: int = 0
	if moving:
		var cycles_per_second: float = minf(speed / STRIDE, MAX_CYCLES_PER_SECOND)
		_phase = fposmod(_phase + cycles_per_second * delta, 1.0)
		frame_index = CYCLE[int(_phase * 4.0) % 4]
	else:
		_phase = 0.0
	_apply_frame("%s_%s" % [_dir, FRAMES[frame_index]], _flip)
	_update_scale(false)
	var hop: float = 0.0
	var texel_world: float = _world_height / _figure_px
	if pixel:
		# Whole-texel motion only: a one-texel hop on the walk frames, a slow one-texel breath when standing.
		if moving and frame_index != 0:
			hop = texel_world
		elif not moving and sin(_time * 2.0) > 0.35:
			hop = texel_world
		position = world_pos + Vector3(0.0, hop, 0.0)
		_material.set_shader_parameter("stretch", 1.0)
	else:
		if moving and frame_index != 0:
			hop = 0.012
		position = world_pos + Vector3(0.0, hop, 0.0)
		# Gentle breathing: a 1.2 % vertical stretch about the feet while standing.
		var breath: float = 1.0 + (0.012 * sin(_time * 2.1) if not moving else 0.0)
		_material.set_shader_parameter("stretch", breath)
	if _shadow != null:
		_shadow.position = Vector3(0.0, 0.035 - hop, 0.0)
		_shadow.scale = Vector3(0.5 * _world_height, 1.0, 0.5 * _world_height)


## Movement relative to the camera, with hysteresis so an exact diagonal does not flicker between two directions.
func _pick_direction(world_dir: Vector3) -> void:
	var basis: Basis = camera.global_basis
	var right: Vector3 = Vector3(basis.x.x, 0.0, basis.x.z).normalized()
	var forward: Vector3 = Vector3(-basis.z.x, 0.0, -basis.z.z).normalized()
	var sideways: float = world_dir.dot(right)
	var towards: float = world_dir.dot(-forward)
	var wanted: String
	if absf(towards) > absf(sideways):
		wanted = "FRONT" if towards > 0.0 else "BACK"
	else:
		wanted = "SIDE"
	if wanted != _dir:
		var margin: float = absf(absf(towards) - absf(sideways))
		if margin > 0.12:
			_dir = wanted
	if _dir == "SIDE" and absf(sideways) > 0.15:
		# The side art looks left; moving right mirrors it.
		_flip = sideways > 0.0


func _apply_frame(key: String, flip: bool) -> void:
	current_frame = key
	current_flip = flip and key.begins_with("SIDE")
	_material.set_shader_parameter("tex_smooth", _textures[key])
	_material.set_shader_parameter("tex_pixel", _textures[key])
	_material.set_shader_parameter("flip_h", current_flip)


## Painted: a fixed world height. Pixel: the height that makes one texel a whole (or half) number of screen pixels, so the grid stays crisp.
func _update_scale(force: bool) -> void:
	if not pixel:
		_world_height = PAINTED_HEIGHT * (_tex_size.y / _figure_px)
		_material.set_shader_parameter("world_scale", _world_height)
		return
	var cam: Camera3D = camera
	var depth: float = maxf((global_position - cam.global_position).dot(-cam.global_basis.z), 0.5)
	var screen_h: float = get_viewport().get_visible_rect().size.y
	var px_per_unit: float = screen_h / (2.0 * depth * tan(deg_to_rad(cam.fov) * 0.5))
	var natural: float = PIXEL_HEIGHT / _figure_px * px_per_unit
	if force or absf(natural - _texel_px) > 0.62 * maxf(_texel_px, 0.5):
		_texel_px = maxf(0.5, round(natural * 2.0) * 0.5) if natural < 2.0 else round(natural)
	# The card's world height for that texel size (the figure is the whole canvas height for the pixel set).
	_world_height = _texel_px * _tex_size.y / px_per_unit
	_material.set_shader_parameter("world_scale", _world_height)


## World height of the figure (feet to top of head) as drawn, for the log.
func figure_height() -> float:
	return _world_height * (_figure_px / _tex_size.y)


func texel_screen_px() -> float:
	return _texel_px
