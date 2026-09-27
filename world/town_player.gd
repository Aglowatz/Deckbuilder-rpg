class_name TownPlayer
extends Node3D
## The walkable hero: WASD / arrow movement on the town's hex tiles with simple circle
## collisions (TownBuilder.is_walkable), turning, idle/walk animations and footstep sounds.

const SPEED: float = 3.4
const MODEL_SCALE: float = 0.34

var town: WalkableArea
var input_enabled: bool = true
var model: Node3D
var _animation: AnimationPlayer
var _current_animation: StringName = &""
var _step_timer: float = 0.0
var _velocity: Vector3 = Vector3.ZERO
## Camera yaw the movement keys are relative to (the town camera never rotates).
var move_yaw: float = 0.0


func setup(town_builder: WalkableArea, model_name: String, start: Vector3) -> void:
	town = town_builder
	position = start
	model = ModelKit.character(model_name)
	add_child(model)
	model.scale = Vector3.ONE * MODEL_SCALE
	_animation = ModelKit.animation_player(model)
	_play(&"Idle")


func _process(delta: float) -> void:
	var direction: Vector2 = _read_input() if input_enabled else Vector2.ZERO
	if direction != Vector2.ZERO:
		var world_dir: Vector3 = Vector3(direction.x, 0.0, direction.y).rotated(Vector3.UP, move_yaw).normalized()
		_velocity = world_dir * SPEED
		_move(_velocity * delta)
		var target_yaw: float = atan2(world_dir.x, world_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_yaw, 1.0 - exp(-14.0 * delta))
		_play(&"Walking_A")
		_step_timer -= delta
		if _step_timer <= 0.0:
			_step_timer = 0.34
			Audio.sfx(&"footstep", -12.0, 0.12)
	else:
		_velocity = Vector3.ZERO
		_play(&"Idle")
		_step_timer = 0.0


func _read_input() -> Vector2:
	var result: Vector2 = Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		result.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		result.y += 1.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		result.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		result.x += 1.0
	return result.normalized()


## Moves by `step`, sliding along obstacles when the full step is blocked.
func _move(step: Vector3) -> void:
	if town.is_walkable(position + step):
		position += step
	elif town.is_walkable(position + Vector3(step.x, 0.0, 0.0)):
		position.x += step.x
	elif town.is_walkable(position + Vector3(0.0, 0.0, step.z)):
		position.z += step.z


func face(target: Vector3) -> void:
	var offset: Vector3 = target - position
	model.rotation.y = atan2(offset.x, offset.z)


func _play(animation_name: StringName) -> void:
	if _animation == null or _current_animation == animation_name:
		return
	if not _animation.has_animation(animation_name):
		return
	_current_animation = animation_name
	_animation.play(animation_name, 0.2)
