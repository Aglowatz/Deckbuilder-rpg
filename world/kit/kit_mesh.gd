class_name KitMesh
extends RefCounted
## A small procedural mesh builder for the kit: one SurfaceTool per material slot (so a whole building is a handful of surfaces and one draw call per slot), flat-shaded quads with
## UVs in metres (so `EnvKit.material` tiles by its `tile` size) and per-vertex colours for baked ambient occlusion. Everything outputs clockwise-wound front faces whatever order
## the caller lists the corners in: `quad()` takes the outward direction and fixes the winding.

var _tools: Dictionary = {}
var _order: Array[String] = []
var _materials: Dictionary = {}
var _triangles: int = 0


func set_material(slot: String, material: Material) -> void:
	_materials[slot] = material


func has_slot(slot: String) -> bool:
	return _tools.has(slot)


func triangle_count() -> int:
	return _triangles


func _tool(slot: String) -> SurfaceTool:
	if not _tools.has(slot):
		var st: SurfaceTool = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		_tools[slot] = st
		_order.append(slot)
	return _tools[slot] as SurfaceTool


## UV in metres projected along the face normal: tops use (x, z), everything else a horizontal tangent and the face's "up the slope" direction.
static func planar_uv(p: Vector3, n: Vector3) -> Vector2:
	if absf(n.y) > 0.9:
		return Vector2(p.x, p.z)
	var tangent: Vector3 = Vector3.UP.cross(n).normalized()
	var up: Vector3 = n.cross(tangent).normalized()
	return Vector2(p.dot(tangent), p.dot(up))


## One quad. `corners` has four points; `outward` is the side that must be the front. `colors` (optional, 4) are per-vertex multipliers (ambient occlusion). `uvs` (optional, 4) override the planar UVs.
func quad(slot: String, corners: Array[Vector3], outward: Vector3, colors: Array[Color] = [], uvs: Array[Vector2] = []) -> void:
	var pts: Array[Vector3] = corners.duplicate()
	var cols: Array[Color] = colors.duplicate()
	var tex: Array[Vector2] = uvs.duplicate()
	var cross: Vector3 = (pts[1] - pts[0]).cross(pts[2] - pts[0])
	if cross.length_squared() < 1.0e-10:
		cross = (pts[2] - pts[0]).cross(pts[3] - pts[0])
	if cross.dot(outward) < 0.0:
		pts.reverse()
		cols.reverse()
		tex.reverse()
		cross = -cross
	var n: Vector3 = cross.normalized()
	_emit(slot, [pts[0], pts[1], pts[2]], n, _pick(cols, [0, 1, 2]), _pick(tex, [0, 1, 2]))
	_emit(slot, [pts[0], pts[2], pts[3]], n, _pick(cols, [0, 2, 3]), _pick(tex, [0, 2, 3]))


static func _pick(values: Array, indices: Array[int]) -> Array:
	var result: Array = []
	if values.is_empty():
		return result
	for index: int in indices:
		result.append(values[index])
	return result


func tri(slot: String, corners: Array[Vector3], outward: Vector3, colors: Array[Color] = [], uvs: Array[Vector2] = []) -> void:
	var pts: Array[Vector3] = corners.duplicate()
	var cols: Array[Color] = colors.duplicate()
	var tex: Array[Vector2] = uvs.duplicate()
	var cross: Vector3 = (pts[1] - pts[0]).cross(pts[2] - pts[0])
	if cross.dot(outward) < 0.0:
		pts.reverse()
		cols.reverse()
		tex.reverse()
		cross = -cross
	_emit(slot, pts, cross.normalized(), cols, tex)


## Emits one triangle given in counter-clockwise (viewed from outside) order; Godot wants clockwise, so the vertices go out reversed.
func _emit(slot: String, pts: Array, n: Vector3, cols: Array, tex: Array) -> void:
	var st: SurfaceTool = _tool(slot)
	for index: int in [0, 2, 1]:
		var p: Vector3 = pts[index] as Vector3
		st.set_normal(n)
		st.set_color(cols[index] as Color if not cols.is_empty() else Color.WHITE)
		st.set_uv(tex[index] as Vector2 if not tex.is_empty() else planar_uv(p, n))
		st.add_vertex(p)
	_triangles += 1


## A box (optionally rotated by `basis` about `center`) with chamfered edges of width `bevel`; `ao` darkens the bottom vertices (1 = off).
func box(slot: String, center: Vector3, size: Vector3, basis: Basis = Basis.IDENTITY, bevel: float = 0.0, ao: float = 1.0) -> void:
	var half: Vector3 = size * 0.5
	var b: float = minf(bevel, minf(half.x, minf(half.y, half.z)) * 0.9)
	var hi: Vector3 = half - Vector3(b, b, b)
	var corner_color: Callable = func(local: Vector3) -> Color:
		var t: float = clampf((local.y + half.y) / maxf(size.y, 0.001), 0.0, 1.0)
		var v: float = lerpf(ao, 1.0, minf(t * 3.0, 1.0))
		return Color(v, v, v, 1.0)
	# six faces
	for axis: int in range(3):
		for sign_value: int in [-1, 1]:
			var normal: Vector3 = Vector3.ZERO
			normal[axis] = float(sign_value)
			var u_axis: int = (axis + 1) % 3
			var v_axis: int = (axis + 2) % 3
			var pts: Array[Vector3] = []
			var cols: Array[Color] = []
			for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				var local: Vector3 = Vector3.ZERO
				local[axis] = half[axis] * float(sign_value)
				local[u_axis] = hi[u_axis] * corner.x
				local[v_axis] = hi[v_axis] * corner.y
				pts.append(center + basis * local)
				cols.append(corner_color.call(local) as Color)
			quad(slot, pts, basis * normal, cols)
	if b <= 0.0001:
		return
	# twelve edge strips
	for axis: int in range(3):
		var u_axis: int = (axis + 1) % 3
		var v_axis: int = (axis + 2) % 3
		for su: int in [-1, 1]:
			for sv: int in [-1, 1]:
				var pts: Array[Vector3] = []
				var cols: Array[Color] = []
				for along: int in [-1, 1]:
					for face: int in range(2):
						var local: Vector3 = Vector3.ZERO
						local[axis] = hi[axis] * float(along)
						if face == 0:
							local[u_axis] = half[u_axis] * float(su)
							local[v_axis] = hi[v_axis] * float(sv)
						else:
							local[u_axis] = hi[u_axis] * float(su)
							local[v_axis] = half[v_axis] * float(sv)
						pts.append(center + basis * local)
						cols.append(corner_color.call(local) as Color)
				var local_n: Vector3 = Vector3.ZERO
				local_n[u_axis] = float(su)
				local_n[v_axis] = float(sv)
				quad(slot, [pts[0], pts[1], pts[3], pts[2]], basis * local_n.normalized(), [cols[0], cols[1], cols[3], cols[2]])
	# eight corner triangles
	for sx: int in [-1, 1]:
		for sy: int in [-1, 1]:
			for sz: int in [-1, 1]:
				var a: Vector3 = Vector3(half.x * sx, hi.y * sy, hi.z * sz)
				var c: Vector3 = Vector3(hi.x * sx, half.y * sy, hi.z * sz)
				var d: Vector3 = Vector3(hi.x * sx, hi.y * sy, half.z * sz)
				tri(slot, [center + basis * a, center + basis * c, center + basis * d], basis * Vector3(sx, sy, sz).normalized(), [corner_color.call(a) as Color, corner_color.call(c) as Color, corner_color.call(d) as Color])


## A lathed solid of revolution about the y axis through `center`: `profile` is a list of (radius, height) from the bottom up. Open top/bottom are capped by the first/last radius.
## UVs wrap once round (u in metres of circumference) and run up in metres.
func lathe(slot: String, center: Vector3, profile: Array[Vector2], segments: int = 14, ao: float = 1.0, cap_bottom: bool = false, cap_top: bool = true) -> void:
	var count: int = maxi(segments, 3)
	for ring: int in range(profile.size() - 1):
		var low: Vector2 = profile[ring]
		var high: Vector2 = profile[ring + 1]
		for step: int in range(count):
			var a0: float = TAU * float(step) / float(count)
			var a1: float = TAU * float(step + 1) / float(count)
			var d0: Vector3 = Vector3(cos(a0), 0.0, sin(a0))
			var d1: Vector3 = Vector3(cos(a1), 0.0, sin(a1))
			var mid_dir: Vector3 = (d0 + d1).normalized()
			var slope: float = (low.x - high.x) / maxf(high.y - low.y, 0.0001)
			var outward: Vector3 = (mid_dir + Vector3.UP * slope).normalized()
			var circumference: float = TAU * maxf(low.x, high.x)
			var u0: float = circumference * float(step) / float(count)
			var u1: float = circumference * float(step + 1) / float(count)
			var shade_low: float = lerpf(ao, 1.0, clampf((low.y - profile[0].y) * 2.5, 0.0, 1.0))
			var shade_high: float = lerpf(ao, 1.0, clampf((high.y - profile[0].y) * 2.5, 0.0, 1.0))
			quad(slot, [center + d0 * low.x + Vector3(0, low.y, 0), center + d1 * low.x + Vector3(0, low.y, 0), center + d1 * high.x + Vector3(0, high.y, 0), center + d0 * high.x + Vector3(0, high.y, 0)], outward,
				[Color(shade_low, shade_low, shade_low), Color(shade_low, shade_low, shade_low), Color(shade_high, shade_high, shade_high), Color(shade_high, shade_high, shade_high)],
				[Vector2(u0, low.y), Vector2(u1, low.y), Vector2(u1, high.y), Vector2(u0, high.y)])
	var first: Vector2 = profile[0]
	var last: Vector2 = profile[profile.size() - 1]
	for step: int in range(count):
		var a0: float = TAU * float(step) / float(count)
		var a1: float = TAU * float(step + 1) / float(count)
		if cap_top and last.x > 0.001:
			var top: Vector3 = center + Vector3(0, last.y, 0)
			tri(slot, [top, top + Vector3(cos(a0), 0, sin(a0)) * last.x, top + Vector3(cos(a1), 0, sin(a1)) * last.x], Vector3.UP)
		if cap_bottom and first.x > 0.001:
			var bottom: Vector3 = center + Vector3(0, first.y, 0)
			tri(slot, [bottom, bottom + Vector3(cos(a0), 0, sin(a0)) * first.x, bottom + Vector3(cos(a1), 0, sin(a1)) * first.x], Vector3.DOWN)


## A straight cylinder (no bevel) between two points with `segments` sides; used for poles, hoops, rails.
func tube(slot: String, from: Vector3, to: Vector3, radius: float, segments: int = 8, cap: bool = true) -> void:
	var axis: Vector3 = to - from
	var length: float = axis.length()
	if length < 0.0001:
		return
	var dir: Vector3 = axis / length
	var helper: Vector3 = Vector3.UP if absf(dir.y) < 0.95 else Vector3.RIGHT
	var u: Vector3 = dir.cross(helper).normalized()
	var v: Vector3 = dir.cross(u).normalized()
	for step: int in range(segments):
		var a0: float = TAU * float(step) / float(segments)
		var a1: float = TAU * float(step + 1) / float(segments)
		var r0: Vector3 = (u * cos(a0) + v * sin(a0)) * radius
		var r1: Vector3 = (u * cos(a1) + v * sin(a1)) * radius
		var outward: Vector3 = (r0 + r1).normalized()
		var circumference: float = TAU * radius
		quad(slot, [from + r0, from + r1, to + r1, to + r0], outward, [], [Vector2(circumference * float(step) / float(segments), 0), Vector2(circumference * float(step + 1) / float(segments), 0), Vector2(circumference * float(step + 1) / float(segments), length), Vector2(circumference * float(step) / float(segments), length)])
		if cap:
			tri(slot, [to, to + r0, to + r1], dir)
			tri(slot, [from, from + r0, from + r1], -dir)


## An axis-aligned sphere-ish blob (a lat/long sphere) for lumps, bulbs and bushes.
func blob(slot: String, center: Vector3, radii: Vector3, rings: int = 5, segments: int = 8, ao: float = 1.0) -> void:
	var profile: Array[Vector2] = []
	for ring: int in range(rings + 1):
		var t: float = float(ring) / float(rings)
		var angle: float = lerpf(-PI * 0.5, PI * 0.5, t)
		profile.append(Vector2(maxf(cos(angle), 0.0) * 1.0, sin(angle)))
	# scale the unit profile; the lathe is circular so stretch x by the larger horizontal radius and bake the z squash in afterwards
	var scaled: Array[Vector2] = []
	for point: Vector2 in profile:
		scaled.append(Vector2(point.x * radii.x, point.y * radii.y))
	lathe(slot, center, scaled, segments, ao, true, true)


## Commits the surfaces. The returned mesh's surface i uses the slot material registered for it.
func build() -> ArrayMesh:
	var mesh: ArrayMesh = ArrayMesh.new()
	for slot: String in _order:
		var st: SurfaceTool = _tools[slot] as SurfaceTool
		var before: int = mesh.get_surface_count()
		st.commit(mesh)
		if mesh.get_surface_count() > before:
			var material: Material = _materials.get(slot) as Material
			if material != null:
				mesh.surface_set_material(mesh.get_surface_count() - 1, material)
			mesh.surface_set_name(mesh.get_surface_count() - 1, slot)
	return mesh


## Convenience: a MeshInstance3D of the built mesh.
func instance(node_name: String = "KitMesh") -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	node.name = node_name
	node.mesh = build()
	return node
