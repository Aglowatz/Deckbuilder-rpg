class_name ProcMesh
extends RefCounted
## A tiny low-poly mesh builder for the hats and cloaks: flat-shaded, vertex-coloured shapes (frustums, discs, spheres, boxes, panels) merged into one
## surface. Shapes take an optional Transform3D so they can be tilted and offset. Built in the style guide (chunky, saturated, simple).

var _vertices: PackedVector3Array = PackedVector3Array()
var _colors: PackedColorArray = PackedColorArray()
var _normals: PackedVector3Array = PackedVector3Array()


## The point a solid shape is centred on (triangles are wound so they face away from it) and, for cloth, a fixed outward direction.
var _center: Vector3 = Vector3.ZERO
var _dir: Vector3 = Vector3.ZERO
var _use_dir: bool = false


## A flat triangle. It is re-wound clockwise as seen from outside (Godot's front face) using `_center` / `_dir`, and its normal points outward.
func tri(a: Vector3, b: Vector3, c: Vector3, color: Color, xform: Transform3D = Transform3D.IDENTITY) -> void:
	var pa: Vector3 = xform * a
	var pb: Vector3 = xform * b
	var pc: Vector3 = xform * c
	var out: Vector3 = xform.basis * _dir if _use_dir else ((pa + pb + pc) / 3.0 - xform * _center)
	var ccw: Vector3 = (pb - pa).cross(pc - pa)
	if ccw.dot(out) > 0.0:
		var swap: Vector3 = pb
		pb = pc
		pc = swap
		ccw = -ccw
	var normal: Vector3 = -ccw.normalized() if ccw.length() > 0.000001 else Vector3.UP
	for point: Vector3 in [pa, pb, pc]:
		_vertices.append(point)
		_colors.append(color)
		_normals.append(normal)


## Centres the next solid shapes (frustum, ring, sphere, box) on `center` (shape-local space).
func solid_around(center: Vector3) -> void:
	_center = center
	_use_dir = false


## Cloth faces: the next triangles face `direction` (shape-local space) on their outer side.
func facing(direction: Vector3) -> void:
	_dir = direction
	_use_dir = true


func quad(a: Vector3, b: Vector3, c: Vector3, d: Vector3, color: Color, xform: Transform3D = Transform3D.IDENTITY) -> void:
	tri(a, b, c, color, xform)
	tri(a, c, d, color, xform)


## A vertical truncated cone from y0 (radius r0) to y1 (radius r1); r1 = 0 makes a cone. `squash` scales z.
func frustum(y0: float, y1: float, r0: float, r1: float, segments: int, color: Color, xform: Transform3D = Transform3D.IDENTITY, cap_top: bool = true, cap_bottom: bool = false, squash: float = 1.0, top_color: Color = Color(0, 0, 0, 0)) -> void:
	solid_around(Vector3(0, (y0 + y1) * 0.5, 0))
	var top: Color = color if top_color.a == 0.0 else top_color
	for i: int in range(segments):
		var a0: float = TAU * float(i) / float(segments)
		var a1: float = TAU * float(i + 1) / float(segments)
		var p0: Vector3 = Vector3(cos(a0) * r0, y0, sin(a0) * r0 * squash)
		var p1: Vector3 = Vector3(cos(a1) * r0, y0, sin(a1) * r0 * squash)
		var q0: Vector3 = Vector3(cos(a0) * r1, y1, sin(a0) * r1 * squash)
		var q1: Vector3 = Vector3(cos(a1) * r1, y1, sin(a1) * r1 * squash)
		if r1 > 0.0001:
			quad(p0, q0, q1, p1, color, xform)
		else:
			tri(p0, q0, p1, color, xform)
		if cap_top and r1 > 0.0001:
			tri(Vector3(0, y1, 0), q1, q0, top, xform)
		if cap_bottom:
			tri(Vector3(0, y0, 0), p0, p1, color.darkened(0.2), xform)


## A flat ring (a brim): from r_in to r_out at height y, `thickness` tall.
func ring(y: float, r_in: float, r_out: float, thickness: float, segments: int, color: Color, xform: Transform3D = Transform3D.IDENTITY, squash: float = 1.0, under_color: Color = Color(0, 0, 0, 0)) -> void:
	solid_around(Vector3(0, y + thickness * 0.5, 0))
	var under: Color = color.darkened(0.25) if under_color.a == 0.0 else under_color
	for i: int in range(segments):
		var a0: float = TAU * float(i) / float(segments)
		var a1: float = TAU * float(i + 1) / float(segments)
		var c0: float = cos(a0)
		var s0: float = sin(a0)
		var c1: float = cos(a1)
		var s1: float = sin(a1)
		var top0_in: Vector3 = Vector3(c0 * r_in, y + thickness, s0 * r_in * squash)
		var top1_in: Vector3 = Vector3(c1 * r_in, y + thickness, s1 * r_in * squash)
		var top0_out: Vector3 = Vector3(c0 * r_out, y + thickness, s0 * r_out * squash)
		var top1_out: Vector3 = Vector3(c1 * r_out, y + thickness, s1 * r_out * squash)
		var bot0_in: Vector3 = Vector3(c0 * r_in, y, s0 * r_in * squash)
		var bot1_in: Vector3 = Vector3(c1 * r_in, y, s1 * r_in * squash)
		var bot0_out: Vector3 = Vector3(c0 * r_out, y, s0 * r_out * squash)
		var bot1_out: Vector3 = Vector3(c1 * r_out, y, s1 * r_out * squash)
		quad(top0_in, top0_out, top1_out, top1_in, color, xform)
		quad(bot0_in, bot1_in, bot1_out, bot0_out, under, xform)
		quad(top0_out, bot0_out, bot1_out, top1_out, color.darkened(0.12), xform)


## A low-poly sphere (an ellipsoid with `squash_y` / `squash_z`).
func sphere(center: Vector3, radius: float, rings: int, segments: int, color: Color, xform: Transform3D = Transform3D.IDENTITY, squash_y: float = 1.0, squash_z: float = 1.0) -> void:
	solid_around(center)
	for ring_index: int in range(rings):
		var t0: float = PI * float(ring_index) / float(rings)
		var t1: float = PI * float(ring_index + 1) / float(rings)
		for i: int in range(segments):
			var a0: float = TAU * float(i) / float(segments)
			var a1: float = TAU * float(i + 1) / float(segments)
			var p00: Vector3 = center + Vector3(sin(t0) * cos(a0), cos(t0) * squash_y, sin(t0) * sin(a0) * squash_z) * radius
			var p01: Vector3 = center + Vector3(sin(t0) * cos(a1), cos(t0) * squash_y, sin(t0) * sin(a1) * squash_z) * radius
			var p10: Vector3 = center + Vector3(sin(t1) * cos(a0), cos(t1) * squash_y, sin(t1) * sin(a0) * squash_z) * radius
			var p11: Vector3 = center + Vector3(sin(t1) * cos(a1), cos(t1) * squash_y, sin(t1) * sin(a1) * squash_z) * radius
			if ring_index == 0:
				tri(p00, p11, p10, color, xform)
			elif ring_index == rings - 1:
				tri(p00, p01, p10, color, xform)
			else:
				quad(p00, p01, p11, p10, color, xform)


func box(center: Vector3, size: Vector3, color: Color, xform: Transform3D = Transform3D.IDENTITY) -> void:
	solid_around(center)
	var h: Vector3 = size * 0.5
	var c: Vector3 = center
	var corners: Array[Vector3] = []
	for sx: float in [-1.0, 1.0]:
		for sy: float in [-1.0, 1.0]:
			for sz: float in [-1.0, 1.0]:
				corners.append(c + Vector3(h.x * sx, h.y * sy, h.z * sz))
	# index = (sx>0)*4 + (sy>0)*2 + (sz>0)
	quad(corners[4], corners[5], corners[7], corners[6], color.lightened(0.05), xform)  # +x
	quad(corners[0], corners[2], corners[3], corners[1], color.darkened(0.05), xform)  # -x
	quad(corners[2], corners[6], corners[7], corners[3], color.lightened(0.12), xform)  # +y
	quad(corners[0], corners[1], corners[5], corners[4], color.darkened(0.2), xform)  # -y
	quad(corners[1], corners[3], corners[7], corners[5], color, xform)  # +z
	quad(corners[0], corners[4], corners[6], corners[2], color.darkened(0.08), xform)  # -z


## A curved cloth panel hanging from y_top to y_bottom: `w_top` / `w_bottom` wide, bowed around the body by `curve`, optionally with a ragged bottom edge.
func panel(y_top: float, y_bottom: float, w_top: float, w_bottom: float, z: float, curve: float, columns: int, color: Color, xform: Transform3D = Transform3D.IDENTITY, jagged: float = 0.0, color_b: Color = Color(0, 0, 0, 0), stripes: int = 0) -> void:
	_dir = Vector3(0, 0, -1)
	_use_dir = true
	for i: int in range(columns):
		var u0: float = float(i) / float(columns) - 0.5
		var u1: float = float(i + 1) / float(columns) - 0.5
		var x_top0: float = u0 * w_top
		var x_top1: float = u1 * w_top
		var x_bot0: float = u0 * w_bottom
		var x_bot1: float = u1 * w_bottom
		var z0: float = z + curve * (u0 * 2.0) * (u0 * 2.0)
		var z1: float = z + curve * (u1 * 2.0) * (u1 * 2.0)
		var drop0: float = 0.0
		var drop1: float = 0.0
		if jagged > 0.0:
			drop0 = jagged * (0.5 + 0.5 * sin(float(i) * 2.3 + 1.0)) * (1.0 if i % 2 == 0 else 0.35)
			drop1 = jagged * (0.5 + 0.5 * sin(float(i + 1) * 2.3 + 1.0)) * (1.0 if (i + 1) % 2 == 0 else 0.35)
		var tint: Color = color
		if stripes > 0 and color_b.a > 0.0:
			tint = color if (i / maxi(1, columns / stripes)) % 2 == 0 else color_b
		_dir = Vector3(0, 0, -1)
		quad(Vector3(x_top0, y_top, z0), Vector3(x_top1, y_top, z1), Vector3(x_bot1, y_bottom + drop1, z1), Vector3(x_bot0, y_bottom + drop0, z0), tint, xform)


func is_empty() -> bool:
	return _vertices.is_empty()


## The finished MeshInstance3D (double-sided, vertex-coloured; the toon pass converts the material).
func build(node_name: String = "Part") -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = node_name
	if _vertices.is_empty():
		return instance
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _vertices
	arrays[Mesh.ARRAY_NORMAL] = _normals
	arrays[Mesh.ARRAY_COLOR] = _colors
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_set_material(0, material)
	instance.mesh = mesh
	return instance
