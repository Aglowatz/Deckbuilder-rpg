class_name SpriteStroller
extends Node3D
## A painted citizen who ambles about a home spot (the Capital's facade citizens, SPR-CITIZEN's full walking set): picks a random nearby point whose straight line is
## walkable, walks to it, pauses a while, picks another. Stops while the hero talks to them or stands in the way. `tick` every frame; `world_position()` is where they stand
## (a talk spot follows it). The ground test is a Callable `(Vector3) -> bool` so any scene's map can drive it.

const SPEED: float = 0.85
const PAUSE_MIN: float = 1.6
const PAUSE_MAX: float = 5.0
const STEP_CHECKS: int = 8

var sprite: WorldSprite
var character: String = "CITIZEN"
var tint: Color = Color.WHITE
## How far from home they roam (metres).
var radius: float = 3.2
## Stand still (the hero is talking to them).
var frozen: bool = false
var _walkable: Callable
var _home: Vector3 = Vector3.ZERO
var _pos: Vector3 = Vector3.ZERO
var _target: Vector3 = Vector3.ZERO
var _has_target: bool = false
var _pause: float = 1.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
const OFFSCREEN_EVERY: int = 4
var _skipped: int = 0
var _skipped_delta: float = 0.0


## `home` is where they start; `seed_value` makes each citizen's route their own.
func setup(home: Vector3, walkable: Callable, seed_value: int, camera: Camera3D = null, sun_direction: Vector3 = Vector3.ZERO) -> void:
	_walkable = walkable
	_home = home
	_pos = home
	_rng.seed = seed_value
	_pause = _rng.randf_range(0.2, PAUSE_MAX)
	sprite = WorldSprite.new()
	add_child(sprite)
	sprite.setup(character, camera, sun_direction)
	sprite.turn_rate_degrees = 420.0
	if tint != Color.WHITE:
		sprite.set_tint(tint)
	sprite.position = _pos
	sprite.snap_heading(Vector3(0.0, 0.0, 1.0) if seed_value % 2 == 0 else Vector3(0.0, 0.0, -1.0))


func world_position() -> Vector3:
	return _pos


## Turns to face `position` (the hero who talks to them).
func face(position: Vector3) -> void:
	sprite.look_toward(position - _pos)


func head_height() -> float:
	return sprite.head_height()


func tick(delta: float, player_pos: Vector3) -> void:
	# Performance pass Oct 25: out of the camera's view a citizen walks on in steps of OFFSCREEN_EVERY frames (the same route and pace, the
	# missed time added up); in view, every frame.
	var cam: Camera3D = sprite.camera if sprite != null else null
	if cam != null and not frozen and cam.global_position.distance_squared_to(_pos) > 9.0 and not cam.is_position_in_frustum(_pos + Vector3(0.0, 0.8, 0.0)):
		_skipped_delta += delta
		_skipped += 1
		if _skipped < OFFSCREEN_EVERY:
			return
	if _skipped > 0:
		delta = _skipped_delta if _skipped >= OFFSCREEN_EVERY else delta + _skipped_delta
		_skipped = 0
		_skipped_delta = 0.0
	if frozen:
		sprite.follow(_pos, delta)
		return
	if _pause > 0.0:
		_pause -= delta
		sprite.follow(_pos, delta)
		return
	if not _has_target and not _pick_target():
		_pause = _rng.randf_range(PAUSE_MIN, PAUSE_MAX)
		sprite.follow(_pos, delta)
		return
	var to_target: Vector3 = _target - _pos
	to_target.y = 0.0
	var step: float = SPEED * delta
	# Wait politely when the hero stands in the way.
	var ahead: Vector3 = _pos + to_target.normalized() * 0.8
	if Vector2(ahead.x - player_pos.x, ahead.z - player_pos.z).length() < 0.8:
		sprite.follow(_pos, delta)
		return
	if to_target.length() <= step:
		_pos = _target
		_has_target = false
		_pause = _rng.randf_range(PAUSE_MIN, PAUSE_MAX)
	else:
		var next: Vector3 = _pos + to_target.normalized() * step
		if _walkable.is_valid() and not bool(_walkable.call(next)):
			_has_target = false
			_pause = 0.6
		else:
			_pos = next
	sprite.follow(_pos, delta)


func _pick_target() -> bool:
	for attempt: int in range(10):
		var angle: float = _rng.randf() * TAU
		var distance: float = _rng.randf_range(1.0, radius)
		var candidate: Vector3 = _home + Vector3(cos(angle), 0.0, sin(angle)) * distance
		candidate.y = _pos.y
		if _line_clear(_pos, candidate):
			_target = candidate
			_has_target = true
			return true
	return false


func _line_clear(from: Vector3, to: Vector3) -> bool:
	if not _walkable.is_valid():
		return true
	for step: int in range(1, STEP_CHECKS + 1):
		if not bool(_walkable.call(from.lerp(to, float(step) / float(STEP_CHECKS)))):
			return false
	return true
