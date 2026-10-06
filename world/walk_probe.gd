class_name WalkProbe
extends RefCounted
## The automated walkability check: flood-fills the ground a hero can stand on from the spawn point and reports which key
## locations (vendors, NPCs, chests, exits, travel points) cannot be reached. Works on any `WalkableArea` (town, starting area)
## and on any `Callable(Vector3) -> bool` (the zones' own walkability tests). Pure maths: no scene tree needed, so it runs under GUT.

const STEP: float = 0.3
## How far from a target the nearest reached cell may be (an interact anchor sits in front of a building, so a little slack).
const REACH_SLACK: float = 1.2


## Every grid cell (Vector2i, in STEP units) reachable from `start`. `can_stand` takes a world position.
static func flood(can_stand: Callable, start: Vector3, bounds: Rect2, step: float = STEP) -> Dictionary:
	var seen: Dictionary = {}
	var origin: Vector2i = _snap(start, step)
	if not can_stand.call(_world(origin, step)):
		origin = _nearest_standable(can_stand, start, step)
	var queue: Array[Vector2i] = [origin]
	seen[origin] = true
	var head: int = 0
	var padded: Rect2 = bounds.grow(2.0)
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		for direction: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + direction
			if seen.has(next):
				continue
			var pos: Vector3 = _world(next, step)
			if not padded.has_point(Vector2(pos.x, pos.z)):
				continue
			if can_stand.call(pos):
				seen[next] = true
				queue.append(next)
	return seen


## Distance from `target` to the nearest reached cell (1e9 when nothing within `search` metres).
static func gap(reached: Dictionary, target: Vector3, search: float = 3.0, step: float = STEP) -> float:
	var best: float = 1.0e9
	var reach: int = int(ceil(search / step))
	var base: Vector2i = _snap(target, step)
	for dx: int in range(-reach, reach + 1):
		for dz: int in range(-reach, reach + 1):
			var cell: Vector2i = base + Vector2i(dx, dz)
			if reached.has(cell):
				var pos: Vector3 = _world(cell, step)
				best = minf(best, Vector2(pos.x - target.x, pos.z - target.z).length())
	return best


## Names (keys of `targets`: String -> Vector3) that the flood fill from `start` cannot get within REACH_SLACK of.
static func unreachable(can_stand: Callable, start: Vector3, bounds: Rect2, targets: Dictionary, slack: float = REACH_SLACK) -> Array[String]:
	var reached: Dictionary = flood(can_stand, start, bounds)
	var missing: Array[String] = []
	for key: String in targets.keys():
		if gap(reached, targets[key] as Vector3, slack + 1.0) > slack:
			missing.append(key)
	return missing


## The widest body radius (searched in 0.05 steps up to `max_radius`) at which every target is still reachable: a measure of how wide the lanes are.
static func lane_clearance(make_can_stand: Callable, start: Vector3, bounds: Rect2, targets: Dictionary, max_radius: float = 0.8) -> float:
	var radius: float = 0.2
	var best: float = 0.0
	while radius <= max_radius:
		var can_stand: Callable = make_can_stand.call(radius) as Callable
		if unreachable(can_stand, start, bounds, targets).is_empty():
			best = radius
		else:
			break
		radius += 0.05
	return best


## An ASCII picture of the flood (for docs and debugging): '#' reached, '.' standable but cut off, ' ' blocked, letters mark `marks` (name -> Vector3).
static func ascii(can_stand: Callable, reached: Dictionary, bounds: Rect2, marks: Dictionary, cell: float = 0.9) -> String:
	var letters: Dictionary = {}
	for key: String in marks.keys():
		var pos: Vector3 = marks[key] as Vector3
		letters[Vector2i(roundi(pos.x / cell), roundi(pos.z / cell))] = key.substr(0, 1).to_upper()
	var lines: PackedStringArray = PackedStringArray()
	var z: float = bounds.position.y
	while z < bounds.end.y:
		var line: String = ""
		var x: float = bounds.position.x
		while x < bounds.end.x:
			var key: Vector2i = Vector2i(roundi(x / cell), roundi(z / cell))
			if letters.has(key):
				line += str(letters[key])
			elif reached.has(_snap(Vector3(x, 0.0, z), STEP)):
				line += "#"
			elif can_stand.call(Vector3(x, 0.0, z)):
				line += "."
			else:
				line += " "
			x += cell
		lines.append(line)
		z += cell
	return "\n".join(lines)


static func _snap(pos: Vector3, step: float) -> Vector2i:
	return Vector2i(roundi(pos.x / step), roundi(pos.z / step))


static func _world(cell: Vector2i, step: float) -> Vector3:
	return Vector3(float(cell.x) * step, 0.0, float(cell.y) * step)


static func _nearest_standable(can_stand: Callable, start: Vector3, step: float) -> Vector2i:
	var base: Vector2i = _snap(start, step)
	for radius: int in range(1, 12):
		for dx: int in range(-radius, radius + 1):
			for dz: int in range(-radius, radius + 1):
				var cell: Vector2i = base + Vector2i(dx, dz)
				if can_stand.call(_world(cell, step)):
					return cell
	return base
