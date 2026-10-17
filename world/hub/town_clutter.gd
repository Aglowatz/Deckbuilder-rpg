class_name TownClutter
extends RefCounted
## Crosspath pass, Part B: where the generic ground dressing (`ZoneDressing`: grass tufts, low plants, flowers, pebbles) may grow in the hub. It used to
## cover every walkable metre evenly, so the fields read as polka dots. Now it gathers in natural clumps along the path edges, at the feet of walls,
## fences, buildings and props, and along the edges of the fields (where the walkable ground ends), with calm open grass between: a slow noise
## decides where a clump may be, the nearness of an edge decides whether it is.

const CLUMP_NOISE_FREQUENCY: float = 0.11
## Noise values under this are open grass even beside an edge (gaps between clumps along a long wall or path).
const CLUMP_THRESHOLD: float = -0.02
## A point this far (metres) beyond a road's paved edge, at most, is a path-edge point (and never on the paving itself).
const PATH_EDGE: Vector2 = Vector2(0.25, 2.2)
## A point within this of a solid circle's rim is at the foot of a wall, a fence, a building or a prop.
const FOOT: float = 1.6
## A point within this of the end of the walkable ground is at a field's edge.
const FIELD_EDGE: float = 3.0
const BUCKET: float = 4.0


## The region callable for `ZoneDressing.build` (pos -> bool).
static func region(town: TownBuilder) -> Callable:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = 31
	noise.frequency = CLUMP_NOISE_FREQUENCY
	var buckets: Dictionary = {}
	for circle: Vector3 in town.obstacles:
		var key: Vector2i = Vector2i(floori(circle.x / BUCKET), floori(circle.y / BUCKET))
		if not buckets.has(key):
			buckets[key] = [] as Array[Vector3]
		(buckets[key] as Array[Vector3]).append(circle)
	return func(pos: Vector3) -> bool:
		return grows_at(town, noise, buckets, pos)


static func grows_at(town: TownBuilder, noise: FastNoiseLite, buckets: Dictionary, pos: Vector3) -> bool:
	if noise.get_noise_2d(pos.x, pos.z) < CLUMP_THRESHOLD:
		return false
	var road: float = TownLayout.distance_to_roads(pos) - TownLayout.ROAD_WIDTH * 0.5
	if road < PATH_EDGE.x:
		return false
	if road < PATH_EDGE.y:
		return true
	var key: Vector2i = Vector2i(floori(pos.x / BUCKET), floori(pos.z / BUCKET))
	for dx: int in range(-1, 2):
		for dz: int in range(-1, 2):
			for circle: Variant in buckets.get(key + Vector2i(dx, dz), []) as Array:
				var c: Vector3 = circle as Vector3
				if Vector2(pos.x - c.x, pos.z - c.y).length() - c.z < FOOT:
					return true
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0
		if not town.is_floor_at(pos + Vector3(cos(angle), 0.0, sin(angle)) * FIELD_EDGE):
			return true
	return false
