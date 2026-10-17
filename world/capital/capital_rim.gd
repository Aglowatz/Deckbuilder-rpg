class_name CapitalRim
extends RefCounted
## The Capital pass (Oct 17), Parts B and E: the land round the walkable map, so no edge is ever seen. One heightfield ring of rough ash ground
## round the outside half and the hidden strip west of the city: its height grows with the distance from the nearest ground the hero can reach
## outside the city (a chamfer distance field on the layout's 1 m grid), so every corner, the strip's dead end and the road corridor fall out of
## one rule. Flush at the walkable edge, rising to ridges a few metres out (the rocks, rubble and dead trees on them are the blockers you see),
## falling back to the far plain at the ring's outer edge under the haze and the backdrop cards. The camera always trails south of the hero, so
## wherever walkable ground lies just north of the rim (the south edge, the strip's pocket) the rise stays under the camera's line to the hero
## (`north_cap`) and carries no trees: the hills climb out of the frame, never into it. The road from Crosspath runs on south between the hills
## (`ROAD`). Nothing here is walkable (the layout's VOID cells). The ground is one mesh ("RimGround", painted with the wasteland's own painted
## material, `PaintedContexts.capital`), the rocks, rubble and trees another ("RimDressing"). Behind the city's other walls, where the inside looks
## out, a belt of dark pines (`pines`) stands on the meadow and the castle hill, the paint-overs' dark accents over the white walls.

const K = preload("res://world/capital/capital_kit.gd")
## The ring's reach beyond the last walkable cell (metres) and the ridges' height.
const REACH: float = 26.0
const PEAK: float = 4.4
## The grid the ring covers: round the whole outside, stopping short of the underground hideout's hall (z 133 on).
const AREA: Rect2i = Rect2i(-34, 16, 188, 116)
## The road to Crosspath beyond the map's south edge: a corridor of flat ground through the hills (cells); its first rows are the layout's view
## floor (`CapitalLayout.ROAD_BEYOND`, painted like the road), the rest a road strip here.
const ROAD: Rect2i = Rect2i(57, 122, 6, 10)
## The city and its walls (x -1.25 .. 120.25, z -1 .. 76): no rim ground there.
const CITY: Rect2 = Rect2(-1.25, -1.0, 121.5, 77.0)
## How far north of a rim cell walkable ground still counts as "in front of the camera" (metres), and the rise allowed per metre of that distance.
const NORTH_REACH: int = 20
const NORTH_SLOPE: float = 0.4
## Dead trees stand only where the rise may reach this high (they never come between the camera and the hero).
const TREE_ROOM: float = 5.6

## What the rim's tests and the report read: the dressing's counts and the heights by vertex.
var rocks: int = 0
var trees: int = 0
var rubble: int = 0
var heights: Dictionary = {}
var _dist: PackedFloat32Array = PackedFloat32Array()
var _north: PackedFloat32Array = PackedFloat32Array()


static func build(parent: Node3D, layout: CapitalLayout) -> CapitalRim:
	var rim: CapitalRim = CapitalRim.new()
	rim._distance_field(layout)
	var node: Node3D = Node3D.new()
	node.name = "Rim"
	node.set_meta(&"no_wind", true)
	parent.add_child(node)
	var ground: KitMesh = KitMesh.new()
	ground.set_material("rim_ground", _ground_material("TEX-CAP-ASH", 6.0))
	rim._ground(ground)
	node.add_child(_finish(ground.instance("RimGround")))
	var dressing: KitMesh = KitMesh.new()
	K.materials(dressing)
	dressing.set_material("rim_road", _ground_material("TEX-CAP-CRACKEDROAD", 3.4))
	rim._road(dressing)
	rim._dressing(dressing)
	node.add_child(_finish(dressing.instance("RimDressing")))
	return rim


static func _finish(body: MeshInstance3D) -> MeshInstance3D:
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_range_cull", true)
	body.set_meta(&"no_occlusion_fade", true)
	body.set_meta(&"no_wind", true)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return body


static func _ground_material(id: String, tile: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = EnvKit.material(id).duplicate() as StandardMaterial3D
	material.uv1_scale = Vector3(1.0 / tile, 1.0 / tile, 1.0)
	material.vertex_color_use_as_albedo = true
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	return material


# ---- the distance fields -----------------------------------------------------------------------------------------------------------------


func _index(cx: int, cz: int) -> int:
	return (cz - AREA.position.y) * AREA.size.x + (cx - AREA.position.x)


func _in_area(cx: int, cz: int) -> bool:
	return cx >= AREA.position.x and cz >= AREA.position.y and cx < AREA.end.x and cz < AREA.end.y


## The walkable ground the hero reaches outside the city (and the road on to Crosspath) is where the rim starts.
static func _is_source(layout: CapitalLayout, cx: int, cz: int) -> bool:
	if ROAD.has_point(Vector2i(cx, cz)):
		return true
	return layout.cell_at(cx, cz) == CapitalLayout.Cell.GROUND and not CapitalLayout.is_inside(float(cx) + 0.5, float(cz) + 0.5)


static func _in_city(cx: int, cz: int) -> bool:
	return CITY.has_point(Vector2(float(cx) + 0.5, float(cz) + 0.5))


func _distance_field(layout: CapitalLayout) -> void:
	_dist.resize(AREA.size.x * AREA.size.y)
	_north.resize(AREA.size.x * AREA.size.y)
	for cz: int in range(AREA.position.y, AREA.end.y):
		for cx: int in range(AREA.position.x, AREA.end.x):
			_dist[_index(cx, cz)] = 0.0 if _is_source(layout, cx, cz) else 999.0
	# two chamfer passes (1, sqrt 2): close enough to the true distance for hills
	var diagonal: float = 1.41421
	for cz: int in range(AREA.position.y, AREA.end.y):
		for cx: int in range(AREA.position.x, AREA.end.x):
			var best: float = _dist[_index(cx, cz)]
			for step: Vector3 in [Vector3(-1, 0, 1.0), Vector3(0, -1, 1.0), Vector3(-1, -1, diagonal), Vector3(1, -1, diagonal)]:
				var nx: int = cx + int(step.x)
				var nz: int = cz + int(step.y)
				if _in_area(nx, nz):
					best = minf(best, _dist[_index(nx, nz)] + step.z)
			_dist[_index(cx, cz)] = best
	for cz: int in range(AREA.end.y - 1, AREA.position.y - 1, -1):
		for cx: int in range(AREA.end.x - 1, AREA.position.x - 1, -1):
			var best: float = _dist[_index(cx, cz)]
			for step: Vector3 in [Vector3(1, 0, 1.0), Vector3(0, 1, 1.0), Vector3(1, 1, diagonal), Vector3(-1, 1, diagonal)]:
				var nx: int = cx + int(step.x)
				var nz: int = cz + int(step.y)
				if _in_area(nx, nz):
					best = minf(best, _dist[_index(nx, nz)] + step.z)
			_dist[_index(cx, cz)] = best
	# how far north of each cell the nearest walkable ground lies (within a camera's trail, a cell either side)
	for cz: int in range(AREA.position.y, AREA.end.y):
		for cx: int in range(AREA.position.x, AREA.end.x):
			var gap: float = 99.0
			for k: int in range(1, NORTH_REACH + 1):
				var found: bool = false
				for dx: int in [-1, 0, 1]:
					var nx: int = cx + dx
					var nz: int = cz - k
					if _in_area(nx, nz) and _dist[_index(nx, nz)] <= 0.0:
						found = true
				if found:
					gap = float(k)
					break
			_north[_index(cx, cz)] = gap


## The distance (metres) from cell (cx, cz) to the nearest walkable ground outside the city; INF off the area.
func distance_at(cx: int, cz: int) -> float:
	if not _in_area(cx, cz):
		return INF
	return _dist[_index(cx, cz)]


## The highest the rim may rise at cell (cx, cz): low where walkable ground lies just north of it (the camera's line to the hero passes over it).
func north_cap(cx: int, cz: int) -> float:
	if not _in_area(cx, cz):
		return INF
	return 0.35 + NORTH_SLOPE * _north[_index(cx, cz)]


## A vertex's distance and cap: the least of the cells round it that carry rim ground or are walkable (a vertex on the walkable edge is 0).
func _vertex_distance(vx: int, vz: int) -> float:
	var best: float = INF
	for offset: Vector2i in [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]:
		var cx: int = vx + offset.x
		var cz: int = vz + offset.y
		if not _in_area(cx, cz) or _in_city(cx, cz):
			continue
		best = minf(best, _dist[_index(cx, cz)])
	return best


func _vertex_cap(vx: int, vz: int) -> float:
	var best: float = INF
	for offset: Vector2i in [Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)]:
		best = minf(best, north_cap(vx + offset.x, vz + offset.y))
	return best


## Smooth value noise in [0, 1] (seeded by position; no texture lookups at build).
static func noise(x: float, z: float) -> float:
	var ix: float = floorf(x)
	var iz: float = floorf(z)
	var fx: float = x - ix
	var fz: float = z - iz
	var a: float = _hash(ix, iz)
	var b: float = _hash(ix + 1.0, iz)
	var c: float = _hash(ix, iz + 1.0)
	var d: float = _hash(ix + 1.0, iz + 1.0)
	var ux: float = fx * fx * (3.0 - 2.0 * fx)
	var uz: float = fz * fz * (3.0 - 2.0 * fz)
	return lerpf(lerpf(a, b, ux), lerpf(c, d, ux), uz)


static func _hash(x: float, z: float) -> float:
	return fposmod(sin(x * 127.1 + z * 311.7) * 43758.5453, 1.0)


## The rim's height at a vertex `distance` metres from the walkable ground: flush at the edge, a ridge 4-5 m up a few metres out (rolling with
## the noise), falling back to the far plain (-0.45, the plane beyond the map) at the ring's reach.
static func height_for(distance: float, x: float, z: float) -> float:
	if distance <= 0.05:
		return 0.0
	var roll: float = 0.62 + 0.55 * noise(x / 9.0, z / 9.0) + 0.18 * noise(x / 2.7 + 31.0, z / 2.7)
	var rise: float = smoothstep(0.35, 6.5, distance)
	var h: float = PEAK * rise * roll
	return lerpf(h, -0.45, smoothstep(REACH - 9.0, REACH, distance))


## The height of the rim at vertex (vx, vz), capped in front of the camera.
func height_at(vx: int, vz: int) -> float:
	var key: Vector2i = Vector2i(vx, vz)
	if heights.has(key):
		return heights[key] as float
	var distance: float = _vertex_distance(vx, vz)
	var h: float = -0.45 if distance == INF else minf(height_for(distance, float(vx), float(vz)), _vertex_cap(vx, vz))
	heights[key] = h
	return h


# ---- the ground, the road and the dressing --------------------------------------------------------------------------------------------------


func _ground(mesh: KitMesh) -> void:
	for cz: int in range(AREA.position.y, AREA.end.y):
		for cx: int in range(AREA.position.x, AREA.end.x):
			var distance: float = _dist[_index(cx, cz)]
			if distance <= 0.0 or distance > REACH + 1.0 or _in_city(cx, cz):
				continue
			var p00: Vector3 = Vector3(cx, height_at(cx, cz), cz)
			var p10: Vector3 = Vector3(cx + 1, height_at(cx + 1, cz), cz)
			var p01: Vector3 = Vector3(cx, height_at(cx, cz + 1), cz + 1)
			var p11: Vector3 = Vector3(cx + 1, height_at(cx + 1, cz + 1), cz + 1)
			for tri: Array in [[p00, p11, p10], [p00, p01, p11]]:
				var a: Vector3 = tri[0] as Vector3
				var b: Vector3 = tri[1] as Vector3
				var c: Vector3 = tri[2] as Vector3
				var normal: Vector3 = (b - a).cross(c - a).normalized()
				if normal.y < 0.0:
					normal = -normal
				mesh.tri("rim_ground", [a, b, c], normal, [_shade(a), _shade(b), _shade(c)])


## Darker at the foot of the rise (the shadow line the eye reads as an edge), lighter up the crests.
static func _shade(p: Vector3) -> Color:
	var v: float = 0.7 + 0.3 * clampf(p.y / PEAK, 0.0, 1.0)
	return Color(v, v * 0.97, v * 0.95)


## The road on to Crosspath beyond the layout's view floor: flat cracked road between the hills, a hair over the plain.
func _road(mesh: KitMesh) -> void:
	var x0: float = float(ROAD.position.x)
	var x1: float = float(ROAD.end.x)
	var z0: float = float(CapitalLayout.ROAD_BEYOND.end.y)
	var z1: float = float(ROAD.end.y) + 6.0
	mesh.quad("rim_road", [Vector3(x0, 0.0, z0), Vector3(x1, 0.0, z0), Vector3(x1, 0.0, z1), Vector3(x0, 0.0, z1)], Vector3.UP)


## Rocks, rubble and dead trees on the rise: the blockers the eye reads, gathered on the ridges (a jittered grid, never on the walkable ground or
## the road), the rocks and rubble at the foot of the rise, the trees up it where they never come between the camera and the hero.
func _dressing(mesh: KitMesh) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7171
	var step: float = 3.0
	var z: float = float(AREA.position.y)
	while z < float(AREA.end.y):
		var x: float = float(AREA.position.x)
		while x < float(AREA.end.x):
			var px: float = x + rng.randf_range(0.0, step)
			var pz: float = z + rng.randf_range(0.0, step)
			var cx: int = int(floorf(px))
			var cz: int = int(floorf(pz))
			x += step
			if not _in_area(cx, cz) or _in_city(cx, cz) or ROAD.grow(2).has_point(Vector2i(cx, cz)):
				continue
			var distance: float = _dist[_index(cx, cz)]
			if distance < 1.2 or distance > 14.0:
				continue
			var ground: float = height_at(cx, cz)
			var room: float = north_cap(cx, cz)
			var pick: float = rng.randf()
			if distance < 4.0 and pick < 0.3:
				# a boulder at the foot of the rise, half sunk: the first thing past the walkable edge
				var r: float = minf(rng.randf_range(0.45, 0.95), room * 0.8)
				rock(mesh, ["ash", "ash_flat", "stone_dark"][rng.randi() % 3], Vector3(px, ground - r * 0.35, pz), Vector3(r * rng.randf_range(1.0, 1.4), r * rng.randf_range(0.55, 0.8), r), rng.randi())
				rocks += 1
			elif distance < 5.0 and pick < 0.6:
				var height: float = minf(rng.randf_range(0.9, 1.4), room)
				K.card(mesh, ["CAP-SHEET-RUBBLE-01", "CAP-SHEET-RUBBLE-04", "CAP-SHEET-RUBBLE-06"][rng.randi() % 3], Vector3(px, ground - 0.1, pz), height, Vector3(0, 0, 1), rng.randf() < 0.5)
				rubble += 1
			elif distance >= 2.5 and room >= TREE_ROOM and pick < 0.9:
				K.card(mesh, "CAP-TREE-DEAD", Vector3(px, ground - 0.15, pz), rng.randf_range(3.2, 5.0), Vector3(0, 0, 1), rng.randf() < 0.5)
				trees += 1
			elif distance >= 3.0 and room >= 2.0:
				var r2: float = rng.randf_range(0.8, 1.4)
				rock(mesh, ["ash", "stone_dark"][rng.randi() % 2], Vector3(px, ground - r2 * 0.35, pz), Vector3(r2 * 1.3, r2 * 0.7, r2), rng.randi())
				rocks += 1
		z += step


## An irregular rock: a lumpy lat-long boulder whose radius wobbles per vertex (seeded, no two alike), flat-shaded facets, darker underneath.
static func rock(mesh: KitMesh, slot: String, center: Vector3, radii: Vector3, seed_value: int, rings: int = 5, segments: int = 9) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var rows: Array = []
	for r: int in range(rings + 1):
		var phi: float = PI * float(r) / float(rings)
		var row: Array[Vector3] = []
		for s: int in range(segments):
			var theta: float = TAU * float(s) / float(segments) + (0.3 if r % 2 == 1 else 0.0)
			var k: float = 1.0 if r == 0 or r == rings else rng.randf_range(0.72, 1.18)
			# a flatter, weathered top
			var y: float = cos(phi) * radii.y * (0.8 if r <= 1 else 1.0)
			row.append(center + Vector3(sin(phi) * cos(theta) * radii.x * k, y, sin(phi) * sin(theta) * radii.z * k))
		rows.append(row)
	for r: int in range(rings):
		var upper: Array[Vector3] = rows[r]
		var lower: Array[Vector3] = rows[r + 1]
		var shade_top: float = lerpf(1.0, 0.6, float(r) / float(rings))
		var shade_bottom: float = lerpf(1.0, 0.6, float(r + 1) / float(rings))
		var top_color: Color = Color(shade_top, shade_top, shade_top)
		var bottom_color: Color = Color(shade_bottom, shade_bottom, shade_bottom)
		for s: int in range(segments):
			var a: Vector3 = upper[s]
			var b: Vector3 = upper[(s + 1) % segments]
			var c: Vector3 = lower[(s + 1) % segments]
			var d: Vector3 = lower[s]
			var out: Vector3 = ((a + b + c + d) * 0.25 - center).normalized()
			if r == 0:
				mesh.tri(slot, [a, c, d], out, [top_color, bottom_color, bottom_color])
			elif r == rings - 1:
				mesh.tri(slot, [a, b, d], out, [top_color, top_color, bottom_color])
			else:
				mesh.quad(slot, [a, b, c, d], out, [top_color, top_color, bottom_color, bottom_color])


## The dark pines beyond the city's walls (seen over them from inside, the paint-overs' green accents): rows on the meadow east of the city and
## on the castle hill either side of the palace, camera-facing cards in one field.
static func pines(parent: Node3D) -> MultiMeshInstance3D:
	var entries: Array[Dictionary] = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 8282
	# east of the city: three staggered rows behind the east wall, north of the ash hills that rise toward the outside
	for row: int in range(3):
		var z: float = 3.0 + float(row) * 1.6
		while z < 44.0:
			entries.append({"pos": Vector3(124.0 + float(row) * 3.4, 0.0, z), "scale": rng.randf_range(0.9, 1.15)})
			z += 4.2
	# on the castle hill (7 m up) behind the north wall, either side of the palace's towers: two rows each side
	for side: float in [-1.0, 1.0]:
		for row: int in range(2):
			var z: float = -3.0 - float(row) * 3.6
			var x: float = 60.0 + side * 44.0
			while absf(x - 60.0) < 50.0:
				entries.append({"pos": Vector3(x + side * float(row) * 1.8, CapitalCastle.TOP, z), "scale": rng.randf_range(0.95, 1.2)})
				x += side * 3.6
	var field: MultiMeshInstance3D = KitFoliage.tree_field(parent, "pine", entries, false)
	if field != null:
		field.name = "CityPines"
		field.set_meta(&"no_range_cull", true)
		field.set_meta(&"no_occlusion_fade", true)
	return field
