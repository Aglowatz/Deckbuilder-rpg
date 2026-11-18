extends SceneTree
## Nov 18 day (Part 6.2): finds the D.N.A.'s pinch points - places on the walk grid where the walkable way is narrower than `MIN_WIDTH` (2.5 m,
## about three hero widths) - and dead-end slots (pockets narrower than that with one way in). Reads the layout only (floor cells, wall cells
## and every prop's blocker circle), so it runs headless in a second.
##
## A sample point (every 0.5 m on walkable floor) is a pinch when the blockers on two roughly opposite sides of it are closer together than
## MIN_WIDTH and it stands about midway between them (the middle of a narrow way). Neighbouring pinch samples form one pinch point.
## Usage: Godot --headless -s res://tools/dna_pinch_probe.gd [-- --list]   (prints the count per room, and each point with --list)

const MIN_WIDTH: float = 2.5
const STEP: float = 0.5
const REACH: float = 2.0


var layout: DnaLayout
var circles: Array[Vector3] = []
var _buckets: Dictionary = {}


func _initialize() -> void:
	var list: bool = OS.get_cmdline_user_args().has("--list")
	layout = DnaLayout.new()
	layout.build()
	for prop: DnaLayout.Prop in layout.props:
		if prop.radius > 0.0:
			circles.append(Vector3(prop.pos.x, prop.pos.z, prop.radius))
	for circle: Vector3 in circles:
		var key: Vector2i = Vector2i(floori(circle.x / 2.0), floori(circle.y / 2.0))
		if not _buckets.has(key):
			_buckets[key] = []
		(_buckets[key] as Array).append(circle)
	var pinches: Array[Vector2] = []
	var z: float = 0.25
	while z < float(DnaLayout.H):
		var x: float = 0.25
		while x < float(DnaLayout.W):
			if _walkable(x, z) and _pinch(x, z):
				pinches.append(Vector2(x, z))
			x += STEP
		z += STEP
	var groups: Array = _group(pinches)
	var by_room: Dictionary = {}
	for group: Variant in groups:
		var points: Array = group as Array
		var at: Vector2 = points[0] as Vector2
		var found: DnaLayout.Room = layout.room_at(Vector3(at.x, 0, at.y))
		var room: String = found.id if found != null else ""
		by_room[room] = int(by_room.get(room, 0)) + 1
		if list:
			print("pinch: (%.1f, %.1f) %s, %d samples" % [at.x, at.y, room, points.size()])
	print("DNA_PINCH: %d pinch points under %.1f m (%d samples)" % [groups.size(), MIN_WIDTH, pinches.size()])
	for room: Variant in by_room.keys():
		print("DNA_PINCH room %s: %d" % [str(room) if str(room) != "" else "(corridor)", int(by_room[room])])
	quit(0)


func _walkable(x: float, z: float) -> bool:
	var c: Vector2i = DnaLayout.world_to_cell(Vector3(x, 0, z))
	if not layout.is_floor(c.x, c.y):
		return false
	for circle: Vector3 in _near(x, z):
		if Vector2(x - circle.x, z - circle.y).length() < circle.z + 0.3:
			return false
	return true


func _near(x: float, z: float) -> Array:
	var result: Array = []
	var key: Vector2i = Vector2i(floori(x / 2.0), floori(z / 2.0))
	for dz: int in range(-2, 3):
		for dx: int in range(-2, 3):
			var list: Variant = _buckets.get(key + Vector2i(dx, dz))
			if list != null:
				result.append_array(list as Array)
	return result


## The nearest blocker point in each of 16 directions (walls, void and prop circles), within REACH; INF where none.
func _ray(x: float, z: float, dir: Vector2) -> float:
	var t: float = 0.1
	while t <= REACH:
		var px: float = x + dir.x * t
		var pz: float = z + dir.y * t
		var c: Vector2i = DnaLayout.world_to_cell(Vector3(px, 0, pz))
		if not layout.is_floor(c.x, c.y):
			return t
		for circle: Vector3 in _near(px, pz):
			if Vector2(px - circle.x, pz - circle.y).length() < circle.z:
				return t
		t += 0.1
	return INF


func _pinch(x: float, z: float) -> bool:
	for index: int in range(8):
		var angle: float = PI * float(index) / 8.0
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		var a: float = _ray(x, z, dir)
		if a == INF:
			continue
		var b: float = _ray(x, z, -dir)
		if b == INF:
			continue
		if a + b < MIN_WIDTH and absf(a - b) <= STEP:
			# narrow across this direction: a way runs along it only if the way along is open (not a closed pocket)
			var along: Vector2 = Vector2(-dir.y, dir.x)
			if _ray(x, z, along) > 0.6 or _ray(x, z, -along) > 0.6:
				return true
	return false


func _group(points: Array[Vector2]) -> Array:
	var seen: Dictionary = {}
	var groups: Array = []
	var lookup: Dictionary = {}
	for p: Vector2 in points:
		lookup[Vector2i(roundi(p.x / STEP), roundi(p.y / STEP))] = p
	for key: Variant in lookup.keys():
		if seen.has(key):
			continue
		var group: Array = []
		var queue: Array = [key]
		seen[key] = true
		while not queue.is_empty():
			var k: Vector2i = queue.pop_back() as Vector2i
			group.append(lookup[k])
			for dz: int in range(-1, 2):
				for dx: int in range(-1, 2):
					var n: Vector2i = k + Vector2i(dx, dz)
					if lookup.has(n) and not seen.has(n):
						seen[n] = true
						queue.append(n)
		groups.append(group)
	return groups
