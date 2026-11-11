class_name RouteGuide
extends RefCounted
## Fable pass Nov 10 (Part 1.6, the wayfinding critic's first fix): a goal arrow points ALONG A WALKABLE ROUTE, not as the crow flies.
## The critic followed the straight arrow into the Gravy River twice, into the Gainlands' plateau wall, across the Dump's stream and
## through the D.N.A.'s front desk: 35 of its 84 minutes. This is an A* search over the area's own walkability (a grid of STEP metres,
## 8 neighbours, the midpoint between two cells tested too so a thin wall is never stepped over - as `WalkPlanner`), sliced over frames
## (`work`, BUDGET_USEC each) so a plan never hitches the game, and asked every frame with `aim(from, target)`: the point LOOK_AHEAD
## metres along the route from where the hero stands while a route is known, the target itself until then. Two walkability tests:
## `strict` (what the hero can walk now) and `through_gates` (an ungrown vine bridge, a shut golem gate, a junk barricade count as open),
## so where a gate shuts the road the arrow leads to the gate - where the sign and the gatekeeper say what opens it (`gated()` is true
## then). Pure: no scene tree.

const STEP: float = 0.75
const LOOK_AHEAD: float = 9.0
## Metres off the route before it is planned again from where the hero is.
const STRAY: float = 3.5
## A target that moved this far (a roaming enemy) gets a new plan.
const MOVED: float = 2.5
## A target with no route is tried again this often (a gate may have opened since).
const RETRY_SECONDS: float = 12.0
## A route in hand is planned afresh this often (a bridge grown, a barricade smashed, a shortcut open).
const REFRESH_SECONDS: float = 30.0
const BUDGET_USEC: int = 5000
## Overnight Nov 10-11 (Part 2.1, inbox 11): a zone may plan on a coarser grid and with more of each frame (the Dump: 1.0 m and 12 ms, so
## its arrow follows the route within about a second instead of five); the defaults are the constants above.
var step: float = STEP
var budget_usec: int = BUDGET_USEC
const MAX_VISITS: int = 80000
const NEIGHBOURS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
const DIAGONAL: float = 1.41421356

var strict: Callable
var through_gates: Callable
var bounds: Rect2 = Rect2()

var _target: Vector3 = Vector3.INF
var _route: PackedVector3Array = PackedVector3Array()
var _route_gated: bool = false
var _route_at: float = -INF
var _failed_at: float = -INF
# the search in progress
var _planning: bool = false
var _permissive: bool = false
var _from: Vector3 = Vector3.ZERO
var _origin: Vector2 = Vector2.ZERO
var _cols: int = 0
var _rows: int = 0
var _start: Vector2i = Vector2i.ZERO
var _goal: Vector2 = Vector2.ZERO
var _came: Dictionary = {}
var _cost: Dictionary = {}
var _heap: Array = []
var _cache: Dictionary = {}
var _mid_cache: Dictionary = {}
var _reach: float = 1.5
## Set by tests: a fixed clock instead of the engine's.
var clock: Callable


func setup(strict_walkable: Callable, gate_walkable: Callable, area_bounds: Rect2, grid: float = STEP, budget: int = BUDGET_USEC) -> void:
	strict = strict_walkable
	through_gates = gate_walkable
	bounds = area_bounds
	step = maxf(0.25, grid)
	budget_usec = maxi(1000, budget)
	forget()


## True once an area gave it something to plan over.
func ready() -> bool:
	return strict.is_valid() and bounds.size.x > 0.0 and bounds.size.y > 0.0


## Drops the route and the target (a scene change, a new pick).
func forget() -> void:
	_target = Vector3.INF
	_route = PackedVector3Array()
	_route_gated = false
	_failed_at = -INF
	_planning = false


## Where the arrow should point for a hero at `from` heading to `target`: LOOK_AHEAD metres along the known route (the target itself when
## it is nearer than that, or while no route is known). Starts or restarts the planning as needed; never blocks.
func aim(from: Vector3, target: Vector3) -> Vector3:
	if not ready():
		return target
	var now: float = _now()
	if _target == Vector3.INF or Vector2(_target.x - target.x, _target.z - target.z).length() > MOVED:
		_target = target
		_route = PackedVector3Array()
		_failed_at = -INF
		_begin(from, false)
	if not _route.is_empty():
		# the route in hand serves until a better one is found (planning again keeps the arrow steady meanwhile)
		var near: Dictionary = _closest(from)
		if not _planning and (float(near["distance"]) > STRAY or now - _route_at > REFRESH_SECONDS):
			_begin(from, false)
		if float(near["distance"]) <= STRAY * 2.0:
			return _ahead(near, target)
		return target
	if not _planning and now - _failed_at > RETRY_SECONDS:
		_begin(from, false)
	return target


## Runs the search for up to BUDGET_USEC microseconds. Call once per frame.
func work() -> void:
	if not _planning:
		return
	var walkable: Callable = through_gates if _permissive and through_gates.is_valid() else strict
	var until: int = Time.get_ticks_usec() + budget_usec
	while not _heap.is_empty() and _came.size() < MAX_VISITS:
		var entry: Array = _pop()
		var cell: Vector2i = entry[1] as Vector2i
		var g: float = float(_cost[cell])
		if float(entry[0]) > g + _h(cell) + 0.001:
			continue  # a stale entry: the cell was reached cheaper since
		if _point(cell).distance_to(_goal) <= _reach:
			_finish(cell)
			return
		for offset: Vector2i in NEIGHBOURS:
			var next: Vector2i = cell + offset
			if next.x < 0 or next.y < 0 or next.x >= _cols or next.y >= _rows:
				continue
			var diagonal: bool = offset.x != 0 and offset.y != 0
			var cost: float = g + (DIAGONAL if diagonal else 1.0) * step
			if _cost.has(next) and float(_cost[next]) <= cost:
				continue
			if not _open(walkable, next):
				continue
			# a wall thinner than the grid step must not be stepped over: the point halfway between the cells is tested too
			if not _mid_open(walkable, cell, next):
				continue
			if diagonal:
				if not _open(walkable, Vector2i(cell.x + offset.x, cell.y)) or not _open(walkable, Vector2i(cell.x, cell.y + offset.y)):
					continue
			_cost[next] = cost
			_came[next] = cell
			_push(cost + _h(next), next)
		if Time.get_ticks_usec() > until:
			return
	# the open set ran dry (or the search is too big): no route this way
	if not _permissive and through_gates.is_valid():
		_begin(_from, true)
		return
	_planning = false
	_failed_at = _now()
	_route_at = _failed_at  # an old route in hand is kept, and not planned again before REFRESH_SECONDS


## The route in hand (the hero's end first), empty while none is known.
func route() -> PackedVector3Array:
	return _route


## True when the route in hand passes a gate the hero cannot pass yet.
func gated() -> bool:
	return not _route.is_empty() and _route_gated


func planning() -> bool:
	return _planning


func _begin(from: Vector3, permissive: bool) -> void:
	_planning = true
	_permissive = permissive
	_from = from
	_origin = bounds.position
	_cols = int(ceilf(bounds.size.x / step)) + 1
	_rows = int(ceilf(bounds.size.y / step)) + 1
	_goal = Vector2(_target.x, _target.z)
	_came.clear()
	_cost.clear()
	_heap.clear()
	if permissive:
		# whatever the strict test found open stays open with the gates counted open too: only the shut cells are asked again
		for key: Variant in _cache.keys():
			if not bool(_cache[key]):
				_cache.erase(key)
		for key: Variant in _mid_cache.keys():
			if not bool(_mid_cache[key]):
				_mid_cache.erase(key)
	else:
		_cache.clear()
		_mid_cache.clear()
	_reach = maxf(1.5, step * 1.2)
	var walkable: Callable = through_gates if permissive and through_gates.is_valid() else strict
	# the hero's own cell, or the nearest open one round it (the hero may stand at a kerb between two cell centres)
	var start: Vector2i = _cell(from)
	var best: Vector2i = Vector2i(-1, -1)
	var best_distance: float = INF
	for dz: int in range(-2, 3):
		for dx: int in range(-2, 3):
			var cell: Vector2i = start + Vector2i(dx, dz)
			if cell.x < 0 or cell.y < 0 or cell.x >= _cols or cell.y >= _rows:
				continue
			var distance: float = _point(cell).distance_to(Vector2(from.x, from.z))
			if distance < best_distance and _open(walkable, cell):
				best_distance = distance
				best = cell
	if best.x < 0:
		_planning = false
		_failed_at = _now()
		return
	_start = best
	_came[best] = best
	_cost[best] = 0.0
	_push(_h(best), best)


func _finish(found: Vector2i) -> void:
	var cells: Array[Vector2i] = [found]
	while cells[cells.size() - 1] != _start:
		cells.append(_came[cells[cells.size() - 1]] as Vector2i)
	cells.reverse()
	var result: PackedVector3Array = PackedVector3Array()
	for index: int in range(cells.size()):
		var keep: bool = index == 0 or index == cells.size() - 1
		if not keep:
			keep = (cells[index] - cells[index - 1]) != (cells[index + 1] - cells[index])
		if keep:
			var p: Vector2 = _point(cells[index])
			result.append(Vector3(p.x, 0.0, p.y))
	_route = result
	_route_gated = _permissive
	_route_at = _now()
	_planning = false
	_heap.clear()


## The closest point of the route to `from`: {"segment": int, "point": Vector2, "distance": float}.
func _closest(from: Vector3) -> Dictionary:
	var p: Vector2 = Vector2(from.x, from.z)
	var best: Dictionary = {"segment": 0, "point": Vector2(_route[0].x, _route[0].z), "distance": INF}
	if _route.size() == 1:
		best["distance"] = p.distance_to(best["point"] as Vector2)
		return best
	for index: int in range(_route.size() - 1):
		var a: Vector2 = Vector2(_route[index].x, _route[index].z)
		var b: Vector2 = Vector2(_route[index + 1].x, _route[index + 1].z)
		var on: Vector2 = Geometry2D.get_closest_point_to_segment(p, a, b)
		var distance: float = p.distance_to(on)
		if distance < float(best["distance"]):
			best = {"segment": index, "point": on, "distance": distance}
	return best


## The point LOOK_AHEAD metres further along the route from the closest point; the target itself when the route ends sooner.
func _ahead(near: Dictionary, target: Vector3) -> Vector3:
	var remaining: float = LOOK_AHEAD
	var p: Vector2 = near["point"] as Vector2
	var index: int = int(near["segment"])
	while index < _route.size() - 1:
		var end: Vector2 = Vector2(_route[index + 1].x, _route[index + 1].z)
		var length: float = p.distance_to(end)
		if length >= remaining:
			var at: Vector2 = p + (end - p).normalized() * remaining
			return Vector3(at.x, target.y, at.y)
		remaining -= length
		p = end
		index += 1
	return target


## The octile distance from a cell to the goal, in metres (never more than the real walk: A* stays exact).
func _h(cell: Vector2i) -> float:
	var d: Vector2 = (_point(cell) - _goal).abs()
	return (d.x + d.y) - (2.0 - DIAGONAL) * minf(d.x, d.y)


func _open(walkable: Callable, cell: Vector2i) -> bool:
	if _cache.has(cell):
		return bool(_cache[cell])
	var p: Vector2 = _point(cell)
	var ok: bool = bool(walkable.call(Vector3(p.x, 0.0, p.y)))
	_cache[cell] = ok
	return ok


## The point halfway between two neighbouring cells (the same for either order).
func _mid_open(walkable: Callable, a: Vector2i, b: Vector2i) -> bool:
	var key: Vector2i = a + b
	if _mid_cache.has(key):
		return bool(_mid_cache[key])
	var mid: Vector2 = (_point(a) + _point(b)) * 0.5
	var ok: bool = bool(walkable.call(Vector3(mid.x, 0.0, mid.y)))
	_mid_cache[key] = ok
	return ok


func _push(f: float, cell: Vector2i) -> void:
	_heap.append([f, cell])
	var index: int = _heap.size() - 1
	while index > 0:
		var parent: int = (index - 1) >> 1
		if float((_heap[parent] as Array)[0]) <= float((_heap[index] as Array)[0]):
			break
		var swap: Array = _heap[parent]
		_heap[parent] = _heap[index]
		_heap[index] = swap
		index = parent


func _pop() -> Array:
	var top: Array = _heap[0]
	var last: Array = _heap.pop_back()
	if not _heap.is_empty():
		_heap[0] = last
		var index: int = 0
		var count: int = _heap.size()
		while true:
			var left: int = index * 2 + 1
			var right: int = left + 1
			var smallest: int = index
			if left < count and float((_heap[left] as Array)[0]) < float((_heap[smallest] as Array)[0]):
				smallest = left
			if right < count and float((_heap[right] as Array)[0]) < float((_heap[smallest] as Array)[0]):
				smallest = right
			if smallest == index:
				break
			var swap: Array = _heap[smallest]
			_heap[smallest] = _heap[index]
			_heap[index] = swap
			index = smallest
	return top


func _cell(pos: Vector3) -> Vector2i:
	return Vector2i(int(roundf((pos.x - _origin.x) / step)), int(roundf((pos.z - _origin.y) / step)))


func _point(cell: Vector2i) -> Vector2:
	return _origin + Vector2(cell) * step


func _now() -> float:
	if clock.is_valid():
		return float(clock.call())
	return float(Time.get_ticks_msec()) / 1000.0
