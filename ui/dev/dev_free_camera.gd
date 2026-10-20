class_name DevFreeCamera
extends Camera3D
## Oct 20 Dev Menu: a fly camera for screenshots. It copies the game camera, becomes current and runs while the world is paused:
## WASD moves on the view plane, Q/E down/up, Shift is faster, the right mouse button held turns the view. `release` hands the
## view back to the game camera.

const SPEED: float = 8.0
const FAST: float = 3.0
const TURN: float = 0.004

var _previous: Camera3D
var _yaw: float = 0.0
var _pitch: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func take_over(game_camera: Camera3D) -> void:
	_previous = game_camera
	global_transform = game_camera.global_transform
	fov = game_camera.fov
	far = maxf(game_camera.far, 400.0)
	var euler: Vector3 = global_transform.basis.get_euler()
	_yaw = euler.y
	_pitch = euler.x
	current = true
	get_tree().paused = true


func release() -> void:
	if _previous != null and is_instance_valid(_previous):
		_previous.current = true
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_yaw -= motion.relative.x * TURN
		_pitch = clampf(_pitch - motion.relative.y * TURN, -1.5, 1.5)
		rotation = Vector3(_pitch, _yaw, 0.0)


func _process(delta: float) -> void:
	var move: Vector3 = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		move -= global_transform.basis.z
	if Input.is_key_pressed(KEY_S):
		move += global_transform.basis.z
	if Input.is_key_pressed(KEY_A):
		move -= global_transform.basis.x
	if Input.is_key_pressed(KEY_D):
		move += global_transform.basis.x
	if Input.is_key_pressed(KEY_E):
		move += Vector3.UP
	if Input.is_key_pressed(KEY_Q):
		move -= Vector3.UP
	if move == Vector3.ZERO:
		return
	var speed: float = SPEED * (FAST if Input.is_key_pressed(KEY_SHIFT) else 1.0)
	# Real time: the world is paused, and a dev time scale should not change how the camera flies.
	global_position += move.normalized() * speed * delta / maxf(Engine.time_scale, 0.01)
