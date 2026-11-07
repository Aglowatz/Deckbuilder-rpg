class_name WalkPlanner
extends RefCounted
## Fix pass Nov 7 (item 2): a plain grid route finder over any area's own walkability test (`WalkableArea.is_walkable`, given as a Callable),
## for the reach walk smoke (`tools/reach_walk_smoke.gd`): can the hero walk from the spawn to every shop and exit? Breadth-first on a square
## grid of `step` metres with 8 neighbours (a diagonal only when both of its sides are walkable too), then the corner points of the route.
## Pure: no scene tree.

## The most cells a search may visit (a 300 x 300 m area at 0.5 m is 360 000 cells).
const MAX_VISITS: int = 400000


## The route from `from` to the walkable cell nearest `to` (within `reach` metres of it), as world points (y 0): the start, the corners, the
## end. Empty when no such route exists inside `bounds`.
static func route(walkable: Callable, bounds: Rect2, from: Vector3, to: Vector3, step: float = 0.5, reach: float = 1.2) -> PackedVector3Array:
	var origin: Vector2 = bounds.position
	var cols: int = int(ceilf(bounds.size.x / step)) + 1
	var rows: int = int(ceilf(bounds.size.y / step)) + 1
	var start: Vector2i = _cell(from, origin, step)
	var goal_point: Vector2 = Vector2(to.x, to.z)
	if start.x < 0 or start.y < 0 or start.x >= cols or start.y >= rows:
		return PackedVector3Array()
	var came: Dictionary = {start: start}
	var queue: Array[Vector2i] = [start]
	var head: int = 0
	var found: Vector2i = Vector2i(-1, -1)
	var cache: Dictionary = {}
	while head < queue.size() and came.size() < MAX_VISITS:
		var cell: Vector2i = queue[head]
		head += 1
		if _point(cell, origin, step).distance_to(goal_point) <= reach:
			found = cell
			break
		for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
			var next: Vector2i = cell + offset
			if next.x < 0 or next.y < 0 or next.x >= cols or next.y >= rows or came.has(next):
				continue
			if not _open(walkable, next, origin, step, cache):
				continue
			# a wall thinner than the grid step must not be stepped over: the point halfway between the cells is tested too
			var mid: Vector2 = (_point(cell, origin, step) + _point(next, origin, step)) * 0.5
			if not bool(walkable.call(Vector3(mid.x, 0.0, mid.y))):
				continue
			if offset.x != 0 and offset.y != 0:
				if not _open(walkable, Vector2i(cell.x + offset.x, cell.y), origin, step, cache) or not _open(walkable, Vector2i(cell.x, cell.y + offset.y), origin, step, cache):
					continue
			came[next] = cell
			queue.append(next)
	if found.x < 0:
		return PackedVector3Array()
	var cells: Array[Vector2i] = [found]
	while cells[cells.size() - 1] != start:
		cells.append(came[cells[cells.size() - 1]] as Vector2i)
	cells.reverse()
	return _corners(cells, origin, step)


## The route's turning points: a point wherever the direction changes, plus the first and the last.
static func _corners(cells: Array[Vector2i], origin: Vector2, step: float) -> PackedVector3Array:
	var result: PackedVector3Array = PackedVector3Array()
	for index: int in range(cells.size()):
		var keep: bool = index == 0 or index == cells.size() - 1
		if not keep:
			keep = (cells[index] - cells[index - 1]) != (cells[index + 1] - cells[index])
		if keep:
			var p: Vector2 = _point(cells[index], origin, step)
			result.append(Vector3(p.x, 0.0, p.y))
	return result


## The route's length in metres (0 for an empty or one-point route).
static func length(points: PackedVector3Array) -> float:
	var total: float = 0.0
	for index: int in range(1, points.size()):
		total += points[index].distance_to(points[index - 1])
	return total


static func _open(walkable: Callable, cell: Vector2i, origin: Vector2, step: float, cache: Dictionary) -> bool:
	if cache.has(cell):
		return bool(cache[cell])
	var p: Vector2 = _point(cell, origin, step)
	var ok: bool = bool(walkable.call(Vector3(p.x, 0.0, p.y)))
	cache[cell] = ok
	return ok


static func _cell(pos: Vector3, origin: Vector2, step: float) -> Vector2i:
	return Vector2i(int(roundf((pos.x - origin.x) / step)), int(roundf((pos.z - origin.y) / step)))


static func _point(cell: Vector2i, origin: Vector2, step: float) -> Vector2:
	return origin + Vector2(cell) * step
