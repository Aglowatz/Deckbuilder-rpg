class_name DnaRoomCut
extends RefCounted
## Fixes Oct 27, Part 2: which floor the D.N.A.'s full-height walls cut away for (world/dna/dna_fade.gdshader, `room_cut`). The hero's region is the room they
## stand in, else the corridor or doorway (DnaLayout.links); the walls standing between the camera and that region's floor fade, every other wall stays up.
## Walking into another region eases the cut: the new region's weight rises to 1 over EASE_TIME while the others share what is left, so no wall pops, even
## through a one-metre doorway crossed faster than the ease (up to SLOTS regions blend at once). A cell that belongs to no region keeps the current one.

const EASE_TIME: float = 0.6
const SLOTS: int = 3
## No region: an empty rectangle (the shader cuts nothing for it).
const NONE: Rect2 = Rect2(0.0, 0.0, -1.0, -1.0)

var layout: DnaLayout
## The regions being shown and their weights (summing to 1); the hero's own region is `current`.
var regions: Array[Rect2] = []
var weights: Array[float] = []
var current: Rect2 = NONE


func _init(source: DnaLayout) -> void:
	layout = source


## The floor rectangle (world metres) of the region at `pos`: a room first, then a corridor / doorway; NONE when on neither.
func region_at(pos: Vector3) -> Rect2:
	var cell: Vector2i = DnaLayout.world_to_cell(pos)
	for room: DnaLayout.Room in layout.rooms:
		if room.rect.has_point(cell):
			return Rect2(room.rect.position, room.rect.size)
	for link: Rect2i in layout.links:
		if link.has_point(cell):
			return Rect2(link.position, link.size)
	return NONE


## Shows `region` at once (a teleport, the first frame).
func snap(region: Rect2) -> void:
	current = region
	regions = [region] as Array[Rect2]
	weights = [1.0] as Array[float]


## Follows the hero; returns true when the region changed this call.
func update(pos: Vector3, delta: float) -> bool:
	var region: Rect2 = region_at(pos)
	var changed: bool = false
	if region != NONE and region != current:
		changed = true
		current = region
		if regions.is_empty():
			snap(region)
		elif not regions.has(region):
			regions.append(region)
			weights.append(0.0)
			while regions.size() > SLOTS:
				# the least shown one goes (it is nearly gone by then: a third doorway inside one ease)
				var least: int = 0
				for i: int in range(weights.size()):
					if weights[i] < weights[least]:
						least = i
				regions.remove_at(least)
				weights.remove_at(least)
	if regions.is_empty():
		return changed
	var index: int = regions.find(current)
	var before: float = weights[index]
	var after: float = minf(1.0, before + delta / EASE_TIME)
	var others: float = 1.0 - before
	for i: int in range(weights.size()):
		weights[i] = after if i == index else (weights[i] * (1.0 - after) / others if others > 0.0001 else 0.0)
	for i: int in range(weights.size() - 1, -1, -1):
		if i != regions.find(current) and weights[i] < 0.001:
			regions.remove_at(i)
			weights.remove_at(i)
	return changed


## A rectangle as the shader's vec4 (min x, min z, max x, max z).
static func to_vec4(rect: Rect2) -> Vector4:
	return Vector4(rect.position.x, rect.position.y, rect.end.x, rect.end.y)


## Pushes the cut into every fade material (walls only read it: `room_cut`).
func apply() -> void:
	var rects: Array[Vector4] = []
	var w: Vector3 = Vector3.ZERO
	for i: int in range(SLOTS):
		rects.append(to_vec4(regions[i]) if i < regions.size() else to_vec4(NONE))
		w[i] = weights[i] if i < weights.size() else 0.0
	DnaMaterials.set_room_cut(rects, w)


# ---- The shader's room cut, in GDScript (world/dna/dna_fade.gdshader `room_fade`; keep the two the same) -------------------------------------------------------
# Used by tests/world/test_dna_room_cut.gd to walk every room at every zoom and angle: what fades, what stays, and that nothing jumps from one frame to the next.


## How much a wall piece centred at `q` (x, z) hides the floor rectangle `rect` from the camera at `cam` (x, z): 0 = not at all, 1 = fully in the way. The
## union of the triangles (camera, edge) over the edges facing the camera, each weighted by how far the camera stands outside that edge's line (see the shader).
static func piece_fade(q: Vector2, cam: Vector2, rect: Rect2) -> float:
	if rect.size.x < 0.0 or rect.size.y < 0.0:
		return 0.0
	var lo: Vector2 = rect.position
	var hi: Vector2 = rect.end
	var inset: float = minf(0.25, 0.25 * minf(rect.size.x, rect.size.y))
	var starts: Array[Vector2] = [Vector2(lo.x + inset, lo.y), Vector2(hi.x, lo.y + inset), Vector2(hi.x - inset, hi.y), Vector2(lo.x, hi.y - inset)]
	var ends: Array[Vector2] = [Vector2(hi.x - inset, lo.y), Vector2(hi.x, hi.y - inset), Vector2(lo.x + inset, hi.y), Vector2(lo.x, lo.y + inset)]
	var outside: Array[float] = [lo.y - cam.y, cam.x - hi.x, cam.y - hi.y, lo.x - cam.x]
	var fade: float = 0.0
	for k: int in range(4):
		var weight: float = smoothstep(-0.35, 0.65, outside[k])
		if weight <= 0.0:
			continue
		var dist: float = tri_distance(q, cam, starts[k], ends[k])
		fade = maxf(fade, weight * (1.0 - smoothstep(0.5, 1.3, dist)))
	return fade


## Signed distance from `p` to the triangle (a, b, c), negative inside (the shader's tri_distance).
static func tri_distance(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> float:
	var e0: Vector2 = b - a
	var e1: Vector2 = c - b
	var e2: Vector2 = a - c
	var v0: Vector2 = p - a
	var v1: Vector2 = p - b
	var v2: Vector2 = p - c
	var p0: Vector2 = v0 - e0 * clampf(v0.dot(e0) / maxf(e0.dot(e0), 1e-6), 0.0, 1.0)
	var p1: Vector2 = v1 - e1 * clampf(v1.dot(e1) / maxf(e1.dot(e1), 1e-6), 0.0, 1.0)
	var p2: Vector2 = v2 - e2 * clampf(v2.dot(e2) / maxf(e2.dot(e2), 1e-6), 0.0, 1.0)
	var s: float = 1.0 if e0.cross(e2) >= 0.0 else -1.0
	var d: Vector2 = Vector2(p0.dot(p0), s * v0.cross(e0))
	var d1: Vector2 = Vector2(p1.dot(p1), s * v1.cross(e1))
	var d2: Vector2 = Vector2(p2.dot(p2), s * v2.cross(e2))
	d = Vector2(minf(minf(d.x, d1.x), d2.x), minf(minf(d.y, d1.y), d2.y))
	return -sqrt(d.x) * signf(d.y)


## The fade a wall piece shows right now (the weighted blend of the regions), as the shader computes it.
func fade_now(q: Vector2, cam: Vector2) -> float:
	var fade: float = 0.0
	for i: int in range(regions.size()):
		fade += weights[i] * piece_fade(q, cam, regions[i])
	return fade
