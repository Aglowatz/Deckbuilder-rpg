class_name GainlandsTerrain
extends RefCounted
## Gainlands v2, Part B: the sandstone plateau as meshes, from `GainlandsLayout`'s land polygons (docs/art/gainlands_v2.md).
##  - `land(layout)`: the flat tops (a 1 m grid, cells on an edge clipped to the polygon exactly, so the mesh edge IS the walkable edge) and the cliff walls
##    hanging from every outer edge down into the sea (four ragged layers, sandstone strata in the vertex colours); one vertex-coloured MeshInstance3D with the
##    shared terrain material, so the painted terrain (sandy ground, paved roads, dry scrub, the triplanar `gain_islandrock` strata on steep faces) applies.
##  - `rock(points, top, seed)`: a flat-topped sandstone column of the same material (background mesas in the sea, the Iron Cave's cliff, the fortress rock).
##  - `stairs()` and `span(rect)`: the wide stone stairs up the mesa and the stone bridges over the canyons (KitMesh, the zone kit's stone).
## Nothing here decides walkability: the layout does.

const CELL: float = 1.0
## The cliff walls reach this far down (below the sea plane at -0.36, so no gap shows at the waterline).
const CLIFF_BOTTOM: float = -3.0
const SAND: Color = Color(0.88, 0.72, 0.52)
const SAND_DARK: Color = Color(0.8, 0.62, 0.44)
const ROAD: Color = Color(0.8, 0.74, 0.66)
const STRATA_LIGHT: Color = Color(0.93, 0.72, 0.5)
const STRATA_DARK: Color = Color(0.78, 0.52, 0.34)
const WET: Color = Color(0.46, 0.36, 0.3)


static func _noise(x: float, z: float) -> float:
	return fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)


## The tops and cliffs of every land polygon, in one mesh.
static func land(layout: GainlandsLayout) -> MeshInstance3D:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var polygons: Array[PackedVector2Array] = GainlandsLayout.land_polygons()
	var stairs: PackedVector2Array = _rect_points(GainlandsLayout.STAIRS)
	var heights: Dictionary = {}
	for index: int in range(polygons.size()):
		var level: int = GainlandsLayout.land_level(index)
		for piece: PackedVector2Array in Geometry2D.clip_polygons(polygons[index], stairs):
			if _area(piece) < 0.01:
				continue
			_tops(surface, layout, piece, heights)
			_walls(surface, layout, piece, level)
	surface.generate_normals()
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.material_override = GainlandsMaterials.terrain()
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.name = "MainLand"
	instance.set_meta(&"no_occlusion_fade", true)  # terrain never dissolves
	instance.set_meta(&"no_range_cull", true)  # one huge mesh: the 48 m range cull measures to its centre (GC-9)
	return instance


static func _rect_points(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])


static func _area(points: PackedVector2Array) -> float:
	var total: float = 0.0
	for i: int in range(points.size()):
		var a: Vector2 = points[i]
		var b: Vector2 = points[(i + 1) % points.size()]
		total += a.x * b.y - b.x * a.y
	return absf(total) * 0.5


static func _height(layout: GainlandsLayout, x: float, z: float, cache: Dictionary) -> float:
	var key: Vector2i = Vector2i(roundi(x * 8.0), roundi(z * 8.0))
	if cache.has(key):
		return float(cache[key])
	var h: float = layout.ground_height(x, z)
	cache[key] = h
	return h


## The ground colour: sand with a soft mottle, the paved roads lighter and greyer (the painted terrain keys its layers on these hues).
static func _top_color(layout: GainlandsLayout, x: float, z: float) -> Color:
	var mottle: float = _noise(floorf(x * 0.35), floorf(z * 0.35))
	var color: Color = SAND.lerp(SAND_DARK, mottle * 0.5)
	var road: float = layout.path_weight(x, z)
	if road > 0.0:
		color = color.lerp(ROAD, road)
	return color


static func _tops(surface: SurfaceTool, layout: GainlandsLayout, polygon: PackedVector2Array, heights: Dictionary) -> void:
	var bounds: Rect2 = Rect2(polygon[0], Vector2.ZERO)
	for point: Vector2 in polygon:
		bounds = bounds.expand(point)
	# cells an edge passes through are clipped exactly; the others are inside or outside whole
	var touched: Dictionary = {}
	for i: int in range(polygon.size()):
		var a: Vector2 = polygon[i]
		var b: Vector2 = polygon[(i + 1) % polygon.size()]
		var steps: int = maxi(1, int(a.distance_to(b) / (CELL * 0.25)))
		for step: int in range(steps + 1):
			var p: Vector2 = a.lerp(b, float(step) / float(steps))
			touched[Vector2i(int(floorf(p.x / CELL)), int(floorf(p.y / CELL)))] = true
	var x0: int = int(floorf(bounds.position.x / CELL))
	var z0: int = int(floorf(bounds.position.y / CELL))
	var x1: int = int(ceilf(bounds.end.x / CELL))
	var z1: int = int(ceilf(bounds.end.y / CELL))
	for gz: int in range(z0, z1):
		for gx: int in range(x0, x1):
			var square: PackedVector2Array = PackedVector2Array([Vector2(gx, gz) * CELL, Vector2(gx + 1, gz) * CELL, Vector2(gx + 1, gz + 1) * CELL, Vector2(gx, gz + 1) * CELL])
			if touched.has(Vector2i(gx, gz)):
				for piece: PackedVector2Array in Geometry2D.intersect_polygons(square, polygon):
					var indices: PackedInt32Array = Geometry2D.triangulate_polygon(piece)
					for t: int in range(0, indices.size(), 3):
						_top_tri(surface, layout, piece[indices[t]], piece[indices[t + 1]], piece[indices[t + 2]], heights)
			elif Geometry2D.is_point_in_polygon(square[0] + Vector2(CELL, CELL) * 0.5, polygon):
				_top_tri(surface, layout, square[0], square[1], square[2], heights)
				_top_tri(surface, layout, square[0], square[2], square[3], heights)


static func _top_tri(surface: SurfaceTool, layout: GainlandsLayout, a: Vector2, b: Vector2, c: Vector2, heights: Dictionary) -> void:
	var points: Array[Vector3] = []
	for p: Vector2 in [a, b, c]:
		points.append(Vector3(p.x, _height(layout, p.x, p.y, heights), p.y))
	# counter-clockwise seen from above (the normal up)
	if (points[1] - points[0]).cross(points[2] - points[0]).y < 0.0:
		var swap: Vector3 = points[1]
		points[1] = points[2]
		points[2] = swap
	for point: Vector3 in points:
		surface.set_color(_top_color(layout, point.x, point.z))
		surface.add_vertex(point)


## The cliff walls of one polygon: every edge piece whose outside is open (the sea, a canyon, a lower level) hangs a ragged sandstone face to CLIFF_BOTTOM.
## The outward normal of edge i (right of the edge for a counter-clockwise polygon) and the mitred normal at each corner, so the faces of two edges meet
## at a corner with no gap.
static func _edge_normal(polygon: PackedVector2Array, i: int, clockwise: bool) -> Vector2:
	var along: Vector2 = (polygon[(i + 1) % polygon.size()] - polygon[i]).normalized()
	return Vector2(along.y, -along.x) if not clockwise else Vector2(-along.y, along.x)


static func _corner_normal(polygon: PackedVector2Array, i: int, clockwise: bool) -> Vector2:
	var count: int = polygon.size()
	var sum: Vector2 = _edge_normal(polygon, (i - 1 + count) % count, clockwise) + _edge_normal(polygon, i, clockwise)
	return sum.normalized() if sum.length() > 0.01 else _edge_normal(polygon, i, clockwise)


static func _walls(surface: SurfaceTool, layout: GainlandsLayout, polygon: PackedVector2Array, level: int) -> void:
	var clockwise: bool = Geometry2D.is_polygon_clockwise(polygon)
	var count: int = polygon.size()
	for i: int in range(count):
		var a: Vector2 = polygon[i]
		var b: Vector2 = polygon[(i + 1) % count]
		var length: float = a.distance_to(b)
		if length < 0.01:
			continue
		var outward: Vector2 = _edge_normal(polygon, i, clockwise)
		var pieces: int = maxi(1, int(ceilf(length / 1.6)))
		for k: int in range(pieces):
			var p0: Vector2 = a.lerp(b, float(k) / float(pieces))
			var p1: Vector2 = a.lerp(b, float(k + 1) / float(pieces))
			var mid: Vector2 = (p0 + p1) * 0.5 + outward * 0.3
			if GainlandsLayout.on_stairs(mid.x, mid.y):
				continue
			var beyond: int = GainlandsLayout.level_at(mid.x, mid.y)
			if beyond >= level:
				continue  # a shared edge (the land goes on) or the foot of something higher
			var out0: Vector2 = _corner_normal(polygon, i, clockwise) if k == 0 else outward
			var out1: Vector2 = _corner_normal(polygon, (i + 1) % count, clockwise) if k == pieces - 1 else outward
			_wall_piece(surface, layout, p0, p1, out0, out1, outward)


## Wall layers: the lip, the upper face, a ledge, the lower face, the talus at the waterline; each pushed in or out by its own noise (overhangs and shelves).
const WALL_DROPS: Array[float] = [0.0, 0.9, 2.1, 2.6, 4.2, 99.0]
const WALL_PUSH: Array[float] = [0.0, 0.25, 0.1, 0.75, 0.55, 1.4]


static func _wall_column(layout: GainlandsLayout, p: Vector2, outward: Vector2) -> Array[Vector3]:
	var top: float = layout.ground_height(p.x - outward.x * 0.05, p.y - outward.y * 0.05)
	var column: Array[Vector3] = []
	for layer: int in range(WALL_DROPS.size()):
		var y: float = maxf(top - WALL_DROPS[layer], CLIFF_BOTTOM)
		var jitter: float = (_noise(p.x * 0.7 + float(layer) * 3.1, p.y * 0.7) - 0.5) * 0.8 if layer > 0 else 0.0
		var push: float = WALL_PUSH[layer] + jitter
		column.append(Vector3(p.x + outward.x * push, y, p.y + outward.y * push))
	return column


static func _strata(y: float, x: float, z: float) -> Color:
	var band: float = sin((y + _noise(floorf(x * 0.2), floorf(z * 0.2)) * 0.6) * 3.4) * 0.5 + 0.5
	var color: Color = STRATA_DARK.lerp(STRATA_LIGHT, band)
	if y < 0.4:
		color = color.lerp(WET, clampf((0.4 - y) / 1.2, 0.0, 1.0))
	return color


static func _wall_piece(surface: SurfaceTool, layout: GainlandsLayout, p0: Vector2, p1: Vector2, out0: Vector2, out1: Vector2, outward: Vector2) -> void:
	var left: Array[Vector3] = _wall_column(layout, p0, out0)
	var right: Array[Vector3] = _wall_column(layout, p1, out1)
	for layer: int in range(left.size() - 1):
		var a: Vector3 = left[layer]
		var b: Vector3 = right[layer]
		var c: Vector3 = right[layer + 1]
		var d: Vector3 = left[layer + 1]
		_face(surface, a, b, c, outward)
		_face(surface, a, c, d, outward)


## A triangle turned to face `outward` (so the generated normals point out of the cliff).
static func _face(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, outward: Vector2) -> void:
	var normal: Vector3 = (b - a).cross(c - a)
	if normal.x * outward.x + normal.z * outward.y < 0.0:
		var swap: Vector3 = b
		b = c
		c = swap
	for p: Vector3 in [a, b, c]:
		surface.set_color(_strata(p.y, p.x, p.z))
		surface.add_vertex(p)


## A sandstone column with a flat top at `top` (background mesas, the cave cliff, the fortress rock): the same faces as the land's cliffs, walls to the sea.
## A terraced column: the base rock and, when tiers > 1, smaller flat-topped rocks stacked on it (each inset and taller), so a mesa reads as layered sandstone.
static func terraced(center: Vector2, radii: Vector2, top: float, tiers: int, node_name: String, seed_value: float) -> Node3D:
	var holder: Node3D = Node3D.new()
	holder.name = node_name
	for tier: int in range(tiers):
		var shrink: float = 1.0 - 0.3 * float(tier)
		var offset: Vector2 = Vector2(_noise(seed_value, float(tier)) - 0.5, _noise(float(tier), seed_value) - 0.5) * radii.x * 0.3 * float(tier)
		var outline: PackedVector2Array = blob_outline(center + offset, radii * shrink, 11, seed_value + float(tier) * 5.1)
		holder.add_child(rock(outline, top + 3.2 * float(tier), "%sTier%d" % [node_name, tier]))
	return holder


## `sheer`: a near-vertical face (the Iron Cave's cliff, the fortress rock: something stands against it), no talus bulging out at its foot.
static func rock(points: PackedVector2Array, top: float, node_name: String, top_color: Color = SAND, sheer: bool = false) -> MeshInstance3D:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	var indices: PackedInt32Array = Geometry2D.triangulate_polygon(points)
	for t: int in range(0, indices.size(), 3):
		var tri: Array[Vector3] = []
		for k: int in range(3):
			var p: Vector2 = points[indices[t + k]]
			tri.append(Vector3(p.x, top, p.y))
		if (tri[1] - tri[0]).cross(tri[2] - tri[0]).y < 0.0:
			var swap: Vector3 = tri[1]
			tri[1] = tri[2]
			tri[2] = swap
		for p3: Vector3 in tri:
			surface.set_color(top_color.lerp(SAND_DARK, _noise(p3.x, p3.z) * 0.4))
			surface.add_vertex(p3)
	var clockwise: bool = Geometry2D.is_polygon_clockwise(points)
	var drops: Array[float] = [0.0, 1.4, 3.4, 4.0, 7.0, 999.0]
	var count: int = points.size()
	var pushes: Array[float] = [0.0, 0.4, 0.2, 1.0, 0.8, 2.2]
	if sheer:
		pushes = [0.0, 0.15, 0.05, 0.25, 0.1, 0.3]
	for i: int in range(points.size()):
		var a: Vector2 = points[i]
		var b: Vector2 = points[(i + 1) % points.size()]
		var length: float = a.distance_to(b)
		if length < 0.01:
			continue
		var outward: Vector2 = _edge_normal(points, i, clockwise)
		var pieces: int = maxi(1, int(ceilf(length / 2.2)))
		for k: int in range(pieces):
			var columns: Array = []
			for end: int in range(2):
				var p: Vector2 = a.lerp(b, float(k + end) / float(pieces))
				var push_dir: Vector2 = outward
				if k + end == 0:
					push_dir = _corner_normal(points, i, clockwise)
				elif k + end == pieces:
					push_dir = _corner_normal(points, (i + 1) % count, clockwise)
				var column: Array[Vector3] = []
				for layer: int in range(drops.size()):
					var jitter: float = (_noise(p.x * 0.5 + float(layer) * 2.3, p.y * 0.5) - 0.5) * (0.3 if sheer else 1.1) if layer > 0 else 0.0
					var push: float = pushes[layer] + jitter
					column.append(Vector3(p.x + push_dir.x * push, maxf(top - drops[layer], CLIFF_BOTTOM), p.y + push_dir.y * push))
				columns.append(column)
			var left: Array[Vector3] = columns[0] as Array[Vector3]
			var right: Array[Vector3] = columns[1] as Array[Vector3]
			for layer: int in range(drops.size() - 1):
				_face(surface, left[layer], right[layer], right[layer + 1], outward)
				_face(surface, left[layer], right[layer + 1], left[layer + 1], outward)
	surface.generate_normals()
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.material_override = GainlandsMaterials.terrain()
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.name = node_name
	instance.set_meta(&"no_occlusion_fade", true)
	instance.set_meta(&"no_range_cull", true)
	return instance


## An irregular blob outline round `center` (radii x/z), `sides` corners: the footprint of a background mesa.
static func blob_outline(center: Vector2, radii: Vector2, sides: int, seed_value: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in range(sides):
		var angle: float = TAU * float(i) / float(sides)
		var wobble: float = 0.82 + 0.3 * _noise(seed_value + float(i) * 1.7, seed_value * 0.3)
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y) * wobble)
	return points


static func _stone_mesh() -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	# dressed sandstone blocks (clean faces read as cut steps; the cobble texture read as rubble)
	mesh.set_material("stone", EnvKit.flat(Color("dcc19a"), "gl2_sandstone_block"))
	mesh.set_material("cap", EnvKit.flat(Color("ecd8b4"), "gl2_sandstone_cap"))
	mesh.set_material("iron", EnvKit.material("GAIN-WALL-IRON" if EnvKit.has("GAIN-WALL-IRON") else "ENV-WALL-FOUNDATION"))
	return mesh


## The wide stairs up the mesa's south face: twelve stone steps between two cheek walls with brass-capped posts, from the forecourt to the mesa top.
static func stairs() -> Node3D:
	var rect: Rect2 = GainlandsLayout.STAIRS
	var mesh: KitMesh = _stone_mesh()
	var steps: int = 12
	var depth: float = rect.size.y / float(steps)
	for step: int in range(steps):
		var z: float = rect.position.y + (float(step) + 0.5) * depth
		var top: float = GainlandsLayout.stairs_height(z)
		var bottom: float = GainlandsLayout.PLATEAU_Y - 0.6
		mesh.box("stone", Vector3(rect.get_center().x, (top + bottom) * 0.5, z), Vector3(rect.size.x - 0.2, top - bottom, depth + 0.04), Basis.IDENTITY, 0.03, 0.92)
	for side: float in [rect.position.x + 0.25, rect.end.x - 0.25]:
		for step: int in range(steps):
			var z: float = rect.position.y + (float(step) + 0.5) * depth
			var top: float = GainlandsLayout.stairs_height(z) + 0.85
			mesh.box("cap", Vector3(side, (top + GainlandsLayout.PLATEAU_Y - 0.6) * 0.5, z), Vector3(0.6, top - GainlandsLayout.PLATEAU_Y + 0.6, depth + 0.02), Basis.IDENTITY, 0.02, 0.9)
	var root: Node3D = Node3D.new()
	root.name = "MesaStairs"
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(&"no_occlusion_fade", true)
	body.set_meta(&"no_range_cull", true)
	root.add_child(body)
	return root


## A stone bridge over a canyon (`rect` in the layout's SPANS): a slab deck, low parapets, two arches down to the water, posts at the ends.
static func span(rect: Rect2) -> Node3D:
	var mesh: KitMesh = _stone_mesh()
	var deck_y: float = GainlandsLayout.PLATEAU_Y + 0.05
	var centre: Vector2 = rect.get_center()
	mesh.box("stone", Vector3(centre.x, deck_y - 0.4, centre.y), Vector3(rect.size.x, 0.8, rect.size.y - 0.1), Basis.IDENTITY, 0.03, 0.92)
	for side: float in [-1.0, 1.0]:
		var z: float = centre.y + side * (rect.size.y * 0.5 - 0.2)
		mesh.box("cap", Vector3(centre.x, deck_y + 0.35, z), Vector3(rect.size.x, 0.7, 0.4), Basis.IDENTITY, 0.03, 0.9)
		for end: float in [-1.0, 1.0]:
			mesh.box("cap", Vector3(centre.x + end * (rect.size.x * 0.5 - 0.3), deck_y + 0.6, z), Vector3(0.6, 1.2, 0.6), Basis.IDENTITY, 0.04, 0.9)
	# the piers under the middle, down into the water
	mesh.box("stone", Vector3(centre.x, (deck_y - 0.8 + CLIFF_BOTTOM) * 0.5, centre.y), Vector3(1.6, deck_y - 0.8 - CLIFF_BOTTOM, rect.size.y - 0.6), Basis.IDENTITY, 0.05, 0.75)
	var root: Node3D = Node3D.new()
	root.name = "StoneSpan"
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(&"no_occlusion_fade", true)
	body.set_meta(&"no_range_cull", true)
	root.add_child(body)
	return root
