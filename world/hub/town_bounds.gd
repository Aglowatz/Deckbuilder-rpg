class_name TownBounds
extends RefCounted
## Crosspath pass, Part D: where the hero may walk in the hub, as data. One closed outline (x, z) round the whole town, its fields, the lakeshore
## and the woods, every edge labelled with the kind of blocker that stands on it (`BoundaryKit` builds it), so nothing invisible ever stops the
## hero in open-looking ground and nothing open-looking is out of reach. The zone passages are the only gaps (kind "passage": the passage posts and
## the obstacle stand there). The town's lake and its docks, and the Gainlands gorge beyond the south edge, are the water and the drop. Pure data
## and geometry: no scene tree, so the walkability tests read it directly.
##
##   north: a rock ridge either side of the imperial road, deep woods to the east
##   east:  the orchard wall with the great pantry door, then the lake's shore
##   south: the gorge lip, the lake running into it at the south-east
##   west:  the thorn woods round the thorn wall, a fence and a stone wall beside the D.N.A. checkpoint, a hedge round the south-west field

## The outline, clockwise from the north-west corner: each entry starts an edge (to the next entry) of the given kind.
const OUTLINE: Array = [
	[Vector2(-23.0, -17.2), "ridge"],
	[Vector2(13.4, -17.2), "passage"],
	[Vector2(19.0, -17.2), "ridge"],
	[Vector2(38.0, -17.2), "forest"],
	[Vector2(73.2, -17.2), "orchard_wall"],
	[Vector2(73.2, 8.2), "passage"],
	[Vector2(73.2, 16.8), "orchard_wall"],
	[Vector2(73.2, 21.4), "water"],
	# the lake's north shore, running west, then its west shore south (the chest's peninsula and the dock reach out into it)
	[Vector2(66.0, 21.0), "water"],
	[Vector2(59.5, 22.2), "water"],
	[Vector2(55.6, 25.4), "water"],
	[Vector2(54.6, 30.0), "water"],
	[Vector2(55.2, 35.4), "water"],
	[Vector2(62.6, 36.0), "water"],
	[Vector2(64.0, 35.6), "water"],
	[Vector2(66.4, 36.4), "water"],
	[Vector2(66.8, 38.8), "water"],
	[Vector2(64.6, 40.0), "water"],
	[Vector2(62.4, 38.8), "water"],
	[Vector2(55.8, 38.6), "water"],
	[Vector2(55.4, 44.2), "water"],
	[Vector2(56.0, 46.8), "water"],
	[Vector2(62.6, 47.0), "water"],
	[Vector2(62.6, 48.8), "water"],
	[Vector2(56.2, 49.0), "water"],
	[Vector2(55.0, 54.4), "water"],
	[Vector2(55.8, 60.6), "water"],
	[Vector2(58.4, 66.0), "water"],
	[Vector2(59.0, 71.0), "gorge"],
	[Vector2(27.6, 71.0), "passage"],
	[Vector2(22.8, 71.0), "gorge"],
	[Vector2(-4.4, 71.0), "hedge"],
	[Vector2(-4.4, 46.4), "wall"],
	[Vector2(-21.4, 46.4), "wall"],
	[Vector2(-21.4, 37.4), "passage"],
	[Vector2(-21.4, 31.2), "fence"],
	[Vector2(-23.0, 22.8), "thorns"],
	[Vector2(-23.0, 15.6), "passage"],
	[Vector2(-23.0, 9.4), "thorns"],
]

## The lake (drawn as natural shore; the outline above keeps the hero a little inside its water line): a closed shape a few metres beyond the
## walkable shore, running out east past the orchard wall and south into the gorge.
const LAKE: PackedVector2Array = [
	Vector2(66.0, 19.4), Vector2(75.0, 18.6), Vector2(86.0, 22.0), Vector2(92.0, 32.0), Vector2(90.0, 46.0), Vector2(84.0, 58.0), Vector2(74.0, 66.0),
	Vector2(66.0, 71.4), Vector2(61.6, 71.4), Vector2(60.2, 66.0), Vector2(57.6, 60.6), Vector2(56.8, 54.4), Vector2(57.4, 50.2), Vector2(57.6, 45.6),
	Vector2(57.2, 41.6), Vector2(62.0, 41.4), Vector2(65.0, 42.0), Vector2(68.6, 39.6), Vector2(68.2, 35.0),
	Vector2(64.0, 33.8), Vector2(57.2, 33.6), Vector2(56.6, 30.0), Vector2(57.4, 26.6), Vector2(60.6, 24.0),
]

## The dock (a walkable deck over the water): centre x, z, width (across), length (out into the lake), drawn by `BoundaryKit`.
const DOCK: Rect2 = Rect2(55.6, 46.8, 7.0, 2.2)

## Kinds of edge and what they look like (BoundaryKit): tall pieces never stand on the camera side of the town (the camera looks north).
const KINDS: PackedStringArray = ["forest", "thorns", "ridge", "orchard_wall", "wall", "fence", "hedge", "gorge", "water", "passage"]


## The outline's corner points.
static func points() -> PackedVector2Array:
	var result: PackedVector2Array = []
	for entry: Array in OUTLINE:
		result.append(entry[0] as Vector2)
	return result


## Every edge as {"a": Vector2, "b": Vector2, "kind": String}.
static func edges() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index: int in range(OUTLINE.size()):
		var entry: Array = OUTLINE[index] as Array
		var next: Array = OUTLINE[(index + 1) % OUTLINE.size()] as Array
		result.append({"a": entry[0] as Vector2, "b": next[0] as Vector2, "kind": str(entry[1])})
	return result


## True inside the outline (the walkable country, before props and buildings).
static func contains(pos: Vector3) -> bool:
	return Geometry2D.is_point_in_polygon(Vector2(pos.x, pos.z), points())


## True on the lake's water (the dock deck excluded).
static func in_lake(pos: Vector3) -> bool:
	return Geometry2D.is_point_in_polygon(Vector2(pos.x, pos.z), LAKE) and not on_dock(pos)


static func on_dock(pos: Vector3) -> bool:
	return DOCK.has_point(Vector2(pos.x, pos.z))


## Distance from `pos` to the outline (positive inside) and the kind of the nearest edge.
static func nearest_edge(pos: Vector3) -> Dictionary:
	var flat: Vector2 = Vector2(pos.x, pos.z)
	var best: float = 1.0e9
	var kind: String = ""
	for edge: Dictionary in edges():
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(flat, edge["a"] as Vector2, edge["b"] as Vector2)
		var d: float = flat.distance_to(closest)
		if d < best:
			best = d
			kind = str(edge["kind"])
	return {"distance": best if contains(pos) else -best, "kind": kind}


## Points every `step` metres along every edge of the given kinds (all kinds when empty), each with its outward normal:
## {"pos": Vector3, "out": Vector3, "kind": String, "t": float (0..1 along its edge), "edge": int}.
static func samples(step: float, kinds: PackedStringArray = []) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var list: Array[Dictionary] = edges()
	for index: int in range(list.size()):
		var edge: Dictionary = list[index]
		var kind: String = str(edge["kind"])
		if not kinds.is_empty() and not kinds.has(kind):
			continue
		var a: Vector2 = edge["a"] as Vector2
		var b: Vector2 = edge["b"] as Vector2
		var length: float = a.distance_to(b)
		var count: int = maxi(1, int(ceil(length / step)))
		var dir: Vector2 = (b - a) / maxf(length, 0.001)
		# clockwise in (x, z) with z pointing south: the outside is to the left of the walking direction
		var out: Vector2 = Vector2(dir.y, -dir.x)
		for i: int in range(count + 1):
			var t: float = float(i) / float(count)
			var p: Vector2 = a.lerp(b, t)
			result.append({"pos": Vector3(p.x, 0.0, p.y), "out": Vector3(out.x, 0.0, out.y), "kind": kind, "t": t, "edge": index, "length": length})
	return result


## The bounding rectangle of the outline (the minimap and the probes).
static func rect() -> Rect2:
	var pts: PackedVector2Array = points()
	var r: Rect2 = Rect2(pts[0], Vector2.ZERO)
	for p: Vector2 in pts:
		r = r.expand(p)
	return r
