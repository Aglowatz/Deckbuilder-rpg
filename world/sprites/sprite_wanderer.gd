class_name SpriteWanderer
extends Node3D
## A townsperson drawn as a painted sprite who wanders the plaza on a small graph of waypoints (a ring round the fountain plus the street mouths and a few doorsteps),
## pausing now and then, with the full walk set of `WorldSprite` (the badger baker in the town; first built for the World Look Test). `character` is the sprite set.
## `tick(delta, player_pos)` every frame; `world_position()` is where they stand (for a talk spot); `paused` is true while standing still, `frozen` stops them (dialogue).

const SPEED: float = 1.15
const RING_RADIUS: float = 4.6
const RING_POINTS: int = 14
const PAUSE_CHANCE: float = 0.55

var sprite: WorldSprite
var character: String = "VILLAGER"
## While true the wanderer stands still (the hero is talking to them).
var frozen: bool = false
var _town: TownBuilder
var _points: Array[Vector3] = []
var _links: Array[PackedInt32Array] = []
var _at: int = 0
var _next: int = 0
var _pause: float = 1.0
var _previous: int = -1
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _pos: Vector3 = Vector3.ZERO
var _player_pos: Vector3 = Vector3(1e4, 0.0, 1e4)


func setup(town: TownBuilder, plaza: Vector3, camera: Camera3D, sun_direction: Vector3) -> void:
	_town = town
	_rng.seed = 11
	_build_graph(plaza)
	sprite = WorldSprite.new()
	add_child(sprite)
	sprite.setup(character, camera, sun_direction)
	sprite.turn_rate_degrees = 420.0
	_pos = _points[_at]
	sprite.position = _pos
	sprite.snap_heading(Vector3(1.0, 0.0, 0.0))
	_choose_next()


func _build_graph(plaza: Vector3) -> void:
	# Ring round the fountain.
	for i: int in range(RING_POINTS):
		var angle: float = float(i) / float(RING_POINTS) * TAU
		_add_point(plaza + Vector3(cos(angle), 0.0, sin(angle)) * RING_RADIUS)
	var ring_count: int = _points.size()
	# Street mouths and a few doorsteps hang off the nearest ring point.
	var extras: Array[Vector3] = []
	for offset: Vector3 in [Vector3(9.2, 0.0, 0.0), Vector3(-9.2, 0.0, 0.0), Vector3(0.0, 0.0, 9.0), Vector3(0.0, 0.0, -9.0)]:
		extras.append(plaza + offset)
	for key: String in ["market", "deck", "gate", "well"]:
		if _town.anchors.has(key):
			extras.append(_town.anchors[key] as Vector3)
	for point: Vector3 in extras:
		if _is_ok(point):
			_add_point(point)
	_links.clear()
	for i: int in range(_points.size()):
		_links.append(PackedInt32Array())
	for i: int in range(ring_count):
		_link(i, (i + 1) % ring_count)
	for i: int in range(ring_count, _points.size()):
		var nearest: int = 0
		var best: float = 1e9
		for j: int in range(ring_count):
			var d: float = _points[i].distance_to(_points[j])
			if d < best and _clear(_points[i], _points[j]):
				best = d
				nearest = j
		_link(i, nearest)
	# Drop ring links that cross something solid.
	for i: int in range(ring_count):
		var j: int = (i + 1) % ring_count
		if not _clear(_points[i], _points[j]):
			_unlink(i, j)


func _add_point(point: Vector3) -> void:
	if _is_ok(point):
		_points.append(point)


func _is_ok(point: Vector3) -> bool:
	return _town.is_walkable(point, 0.3)


func _clear(from: Vector3, to: Vector3) -> bool:
	for step: int in range(1, 9):
		if not _is_ok(from.lerp(to, float(step) / 8.0)):
			return false
	return true


func _link(a: int, b: int) -> void:
	if a == b:
		return
	if not _links[a].has(b):
		_links[a].append(b)
	if not _links[b].has(a):
		_links[b].append(a)


func _unlink(a: int, b: int) -> void:
	var ia: int = _links[a].find(b)
	if ia >= 0:
		_links[a].remove_at(ia)
	var ib: int = _links[b].find(a)
	if ib >= 0:
		_links[b].remove_at(ib)


func _choose_next() -> void:
	var options: PackedInt32Array = _links[_at]
	if options.is_empty():
		_next = _at
		return
	# Mostly carry on round the ring (not straight back where we came from), sometimes take a spur.
	var pool: Array[int] = []
	for option: int in options:
		if option != _previous or options.size() == 1:
			pool.append(option)
	_next = pool[_rng.randi() % pool.size()]


func world_position() -> Vector3:
	return _pos


## Turns the wanderer to face `position` (the hero who talks to them).
func face(position: Vector3) -> void:
	sprite.look_toward(position - _pos)


func tick(delta: float, player_pos: Vector3) -> void:
	_player_pos = player_pos
	if frozen:
		sprite.follow(_pos, delta)
		return
	if _pause > 0.0:
		_pause -= delta
		sprite.follow(_pos, delta)
		return
	var target: Vector3 = _points[_next]
	var to_target: Vector3 = target - _pos
	to_target.y = 0.0
	var step: float = SPEED * delta
	# Stop politely when the hero stands in the way.
	var ahead: Vector3 = _pos + to_target.normalized() * 0.9
	if Vector2(ahead.x - player_pos.x, ahead.z - player_pos.z).length() < 0.7:
		sprite.follow(_pos, delta)
		return
	if to_target.length() <= step:
		_pos = target
		_previous = _at
		_at = _next
		_choose_next()
		if _rng.randf() < PAUSE_CHANCE:
			_pause = _rng.randf_range(1.5, 4.0)
	else:
		_pos += to_target.normalized() * step
	sprite.follow(_pos, delta)
