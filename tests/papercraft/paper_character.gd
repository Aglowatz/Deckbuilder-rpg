extends Node3D
## A papercraft character: a flat cut-out standing on the ground that turns around the vertical axis to face the camera (see docs/art/papercraft_test.md).
## It follows `follow` (the 3D character's root) and works out its own motion from how that moves: IDLE/WALK frames for left, mirrored for right, BACK when walking away
## from the camera, a 0.15 s paper flip when the facing changes, a bouncy bob and lean while walking, a squash on stopping and a breathing sway when idle.

const SHADER: Shader = preload("res://tests/papercraft/paper_cutout.gdshader")
const ART: String = "res://assets/art/paper/%s_%s.webp"
const PAD_PX: int = 24
const FLIP_TIME: float = 0.15
const STEP_TIME: float = 0.17
const SQUASH_TIME: float = 0.2
const MOVING_SPEED: float = 0.18

enum Facing { LEFT, RIGHT, BACK }

var follow: Node3D
var height: float = 0.75
var facing: int = Facing.LEFT
var moving: bool = false

var _pivot: Node3D
var _quad: MeshInstance3D
var _material: ShaderMaterial
var _textures: Dictionary = {}
var _clock: float = 0.0
var _walk_clock: float = 0.0
var _last_position: Vector3
var _velocity: Vector3 = Vector3.ZERO
var _flip_timer: float = -1.0
var _flip_from: int = Facing.LEFT
var _shown_facing: int = Facing.LEFT
var _squash_timer: float = -1.0
var _lean: float = 0.0
var _step_flag: bool = false
var _pixel: float = 0.001


## `character_id` is the PAPER-<ID> name (NPC-HURL, V-FENWICK...); `figure_height` is the cut-out's height in metres.
static func create(character_id: String, figure_height: float, follow_node: Node3D) -> Node3D:
	var paper: Node3D = (load("res://tests/papercraft/paper_character.gd") as GDScript).new() as Node3D
	paper.set("height", figure_height)
	paper.set("follow", follow_node)
	paper.call("_build", character_id)
	return paper


func _build(character_id: String) -> void:
	name = "Paper_%s" % character_id
	for frame: String in ["IDLE", "WALK", "BACK"]:
		_textures[frame] = load(ART % [character_id, frame]) as Texture2D
	var idle: Texture2D = _textures["IDLE"] as Texture2D
	var tex_size: Vector2 = idle.get_size()
	_pixel = height / (tex_size.y - PAD_PX * 2.0)
	_pivot = Node3D.new()
	_pivot.name = "Pivot"
	add_child(_pivot)
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = tex_size * _pixel
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("texel", Vector2(1.0 / tex_size.x, 1.0 / tex_size.y))
	mesh.material = _material
	_quad = MeshInstance3D.new()
	_quad.name = "Cutout"
	_quad.mesh = mesh
	_quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The figure's soles sit at the canvas bottom minus the transparent margin: that line is the ground (y = 0).
	_quad.position = Vector3(0.0, mesh.size.y * 0.5 - PAD_PX * _pixel, 0.0)
	_pivot.add_child(_quad)
	ContactShadow.attach(self, mesh.size.x * 0.34)
	_clock = randf() * 10.0
	_set_frame(&"IDLE", false)
	if follow != null:
		_last_position = follow.global_position


## Turns to face a world position (talking), without a walk.
func face_toward(world_position: Vector3) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null or follow == null:
		return
	var side: float = (world_position - follow.global_position).dot(_flat(camera.global_basis.x))
	_request(Facing.RIGHT if side > 0.0 else Facing.LEFT)


static func _flat(v: Vector3) -> Vector3:
	v.y = 0.0
	return v.normalized() if v.length() > 0.001 else Vector3.RIGHT


func _process(delta: float) -> void:
	if follow == null or not visible:
		if follow != null:
			_last_position = follow.global_position
		return
	_clock += delta
	var camera: Camera3D = get_viewport().get_camera_3d()
	global_position = follow.global_position
	var was_moving: bool = moving
	var step: Vector3 = follow.global_position - _last_position
	_last_position = follow.global_position
	step.y = 0.0
	var instant: Vector3 = step / maxf(delta, 0.0001)
	_velocity = _velocity.lerp(instant, 1.0 - exp(-14.0 * delta))
	moving = _velocity.length() > MOVING_SPEED
	if camera != null:
		var to_camera: Vector3 = camera.global_position - global_position
		rotation.y = atan2(to_camera.x, to_camera.z)
		_steer(camera)
	_animate(delta, was_moving)


## Picks the facing from the travel direction relative to the camera: away from the camera = BACK, otherwise left/right on screen.
func _steer(camera: Camera3D) -> void:
	if not moving:
		return
	var speed: float = _velocity.length()
	var right: Vector3 = _flat(camera.global_basis.x)
	var forward: Vector3 = _flat(-camera.global_basis.z)
	var side: float = _velocity.dot(right) / speed
	var away: float = _velocity.dot(forward) / speed
	_lean = lerpf(_lean, clampf(side, -1.0, 1.0), 0.25)
	if away > (0.45 if facing == Facing.BACK else 0.7):
		_request(Facing.BACK)
	elif absf(side) > 0.2 or facing == Facing.BACK:
		_request(Facing.RIGHT if side > 0.0 else Facing.LEFT)


func _request(wanted: int) -> void:
	if wanted == facing:
		return
	if _flip_timer >= 0.0:
		# Mid-flip: just retarget; the flip's second half shows the new facing.
		facing = wanted
		return
	_flip_from = facing
	facing = wanted
	_flip_timer = 0.0


func _animate(delta: float, was_moving: bool) -> void:
	if was_moving and not moving:
		_squash_timer = 0.0
		_lean = 0.0
	var scale_x: float = 1.0
	var scale_y: float = 1.0
	var bob: float = 0.0
	var roll: float = 0.0
	if moving:
		_walk_clock += delta
		var phase: float = _walk_clock / STEP_TIME
		_step_flag = int(floor(phase)) % 2 == 1
		bob = absf(sin(phase * PI)) * height * 0.075
		roll = -_lean * deg_to_rad(8.0) + sin(phase * PI) * deg_to_rad(2.5)
		scale_y = 1.0 + (0.03 - absf(sin(phase * PI)) * 0.05)
	else:
		_walk_clock = 0.0
		_step_flag = false
		roll = sin(_clock * 1.7) * deg_to_rad(1.4)
		scale_y = 1.0 + sin(_clock * 2.2) * 0.012
		scale_x = 1.0 - sin(_clock * 2.2) * 0.006
	if _squash_timer >= 0.0:
		_squash_timer += delta
		var t: float = _squash_timer / SQUASH_TIME
		if t >= 1.0:
			_squash_timer = -1.0
		else:
			scale_y *= 1.0 - 0.13 * sin(t * PI)
			scale_x *= 1.0 + 0.08 * sin(t * PI)
	var frame: StringName = &"IDLE"
	if facing == Facing.BACK:
		frame = &"BACK"
	elif moving and _step_flag:
		frame = &"WALK"
	# Source art faces left; right is the mirror. Walking away alternates the BACK card with its mirror as the two steps.
	var mirror: float = 1.0
	if facing == Facing.RIGHT:
		mirror = -1.0
	elif facing == Facing.BACK and moving and _step_flag:
		mirror = -1.0
	var flip_scale: float = 1.0
	if _flip_timer >= 0.0:
		_flip_timer += delta
		var f: float = _flip_timer / FLIP_TIME
		if f >= 1.0:
			_flip_timer = -1.0
		else:
			# Squash to edge-on in the first half (old card), swap, open out in the second (new card).
			flip_scale = absf(1.0 - f * 2.0)
			if f < 0.5:
				_set_frame(_frame_for(_flip_from), false)
				mirror = -1.0 if _flip_from == Facing.RIGHT else 1.0
			else:
				_set_frame(frame, false)
			scale_x *= maxf(flip_scale, 0.02) * mirror
			_pivot.scale = Vector3(scale_x, scale_y, 1.0)
			_pivot.position.y = bob
			_pivot.rotation.z = roll
			return
	_set_frame(frame, false)
	_pivot.scale = Vector3(scale_x * mirror, scale_y, 1.0)
	_pivot.position.y = bob
	_pivot.rotation.z = roll


func _frame_for(f: int) -> StringName:
	return &"BACK" if f == Facing.BACK else &"IDLE"


func _set_frame(frame: StringName, _force: bool) -> void:
	if _material == null:
		return
	var texture: Texture2D = _textures.get(String(frame)) as Texture2D
	if texture != null and _material.get_shader_parameter("albedo_tex") != texture:
		_material.set_shader_parameter("albedo_tex", texture)
