class_name PathTool
extends RefCounted
## The path tool (vertical slice, Part C): draws a dirt or cobble path along a curve of control points with a soft, irregular edge that melts into the grass (ENV-GROUND-DIRTPATH /
## ENV-GROUND-COBBLE for the surface, DEC-PATHEDGE strips along both sides), worn patches (DEC-WORNPATCH) at doorsteps and junctions and natural clumps of grass and flowers
## along the edges (never evenly spaced). `build()` returns a Node3D whose meta lists what it made so the caller can register obstacles / foliage:
##   "points" (the smoothed centre line), "width", "wear" (positions), "clumps" (entries for KitFoliage.clumps).
##
## opts: width (m, 3.4), kind "dirt" | "cobble", seed (int), lift (m above the ground, 0.034), edge (bool), wear (bool), clumps (float, density 0..2),
##       is_floor (Callable(Vector3) -> bool: land only), avoid (Callable(Vector3) -> bool: keep clumps off), step (m between samples, 0.7), wobble (0..1 width variation).

const SHADER: String = "res://world/kit/kit_path.gdshader"
const KINDS: Dictionary = {
	"dirt": {"id": "ENV-GROUND-DIRTPATH", "soft": 0.34, "noise": 0.42, "tint": Color(1.35, 1.25, 1.1)},
	"cobble": {"id": "ENV-GROUND-COBBLE", "soft": 0.1, "noise": 0.16, "tint": Color(0.97, 0.93, 0.88)},
}

static var _shader: Shader


static func shader() -> Shader:
	if _shader == null:
		_shader = load(SHADER) as Shader
	return _shader


## Catmull-Rom through the control points, sampled about every `step` metres.
static func smooth(control: Array[Vector3], step: float = 0.7) -> Array[Vector3]:
	var result: Array[Vector3] = []
	if control.size() < 2:
		return control.duplicate()
	for index: int in range(control.size() - 1):
		var p0: Vector3 = control[maxi(index - 1, 0)]
		var p1: Vector3 = control[index]
		var p2: Vector3 = control[index + 1]
		var p3: Vector3 = control[mini(index + 2, control.size() - 1)]
		var segments: int = maxi(1, int(ceil(p1.distance_to(p2) / step)))
		for s: int in range(segments):
			var t: float = float(s) / float(segments)
			var t2: float = t * t
			var t3: float = t2 * t
			result.append(0.5 * ((2.0 * p1) + (-p0 + p2) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3))
	result.append(control[control.size() - 1])
	return result


static func surface_material(kind: String, seed_value: int = 0) -> ShaderMaterial:
	var data: Dictionary = KINDS.get(kind, KINDS["dirt"]) as Dictionary
	var id: String = str(data["id"])
	var material_value: ShaderMaterial = ShaderMaterial.new()
	material_value.shader = shader()
	material_value.set_shader_parameter("mode", 0)
	material_value.set_shader_parameter("surface_tex", EnvKit.texture(id))
	material_value.set_shader_parameter("tint", (EnvKit.tint(id) if not EnvKit.has_art(id) else Color.WHITE) * (data["tint"] as Color))
	material_value.set_shader_parameter("tile", EnvKit.tile_size(id))
	material_value.set_shader_parameter("edge_soft", float(data["soft"]))
	material_value.set_shader_parameter("edge_noise", float(data["noise"]))
	material_value.set_shader_parameter("seed", float(seed_value))
	material_value.render_priority = -40
	return material_value


static func edge_material(kind: String, seed_value: int = 0) -> ShaderMaterial:
	var material_value: ShaderMaterial = surface_material(kind, seed_value)
	material_value.set_shader_parameter("mode", 1)
	material_value.set_shader_parameter("edge_tex", EnvKit.texture("DEC-PATHEDGE"))
	material_value.set_shader_parameter("edge_rgb", EnvKit.has_art("DEC-PATHEDGE"))
	material_value.render_priority = -39
	return material_value


static func patch_material(kind: String, seed_value: int = 0) -> ShaderMaterial:
	var material_value: ShaderMaterial = surface_material(kind, seed_value)
	material_value.set_shader_parameter("mode", 2)
	material_value.set_shader_parameter("edge_tex", EnvKit.texture("DEC-WORNPATCH"))
	material_value.set_shader_parameter("edge_rgb", EnvKit.has_art("DEC-WORNPATCH"))
	material_value.set_shader_parameter("opacity", 0.9)
	material_value.render_priority = -38
	return material_value


static func build(parent: Node3D, control: Array[Vector3], opts: Dictionary = {}) -> Node3D:
	var width: float = float(opts.get("width", 3.4))
	var kind: String = str(opts.get("kind", "dirt"))
	var seed_value: int = int(opts.get("seed", 1))
	var lift: float = float(opts.get("lift", 0.034))
	var step: float = float(opts.get("step", 0.7))
	var wobble: float = float(opts.get("wobble", 0.12))
	var is_floor: Callable = opts.get("is_floor", Callable()) as Callable
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7000 + seed_value
	var points: Array[Vector3] = smooth(control, step)
	var root: Node3D = Node3D.new()
	root.name = "Path_%s_%d" % [kind, seed_value]
	parent.add_child(root)
	# Samples that lie on land (a path stops at the shore instead of hanging over the water).
	var kept: Array[Vector3] = []
	for point: Vector3 in points:
		if not is_floor.is_valid() or bool(is_floor.call(point)):
			kept.append(point)
	root.set_meta("points", kept)
	root.set_meta("width", width)
	if kept.size() < 2:
		return root
	var lefts: Array[Vector3] = []
	var rights: Array[Vector3] = []
	var half_widths: Array[float] = []
	var lengths: Array[float] = []
	var run: float = 0.0
	for index: int in range(kept.size()):
		var prev: Vector3 = kept[maxi(index - 1, 0)]
		var next: Vector3 = kept[mini(index + 1, kept.size() - 1)]
		var tangent: Vector3 = (next - prev)
		tangent.y = 0.0
		tangent = tangent.normalized()
		var normal: Vector3 = Vector3(-tangent.z, 0.0, tangent.x)
		var factor: float = 1.0 + wobble * (sin(float(index) * 0.53 + float(seed_value)) * 0.6 + sin(float(index) * 1.37 + 2.0) * 0.4)
		var half: float = width * 0.5 * factor
		half_widths.append(half)
		lefts.append(kept[index] + normal * half)
		rights.append(kept[index] - normal * half)
		if index > 0:
			run += kept[index].distance_to(kept[index - 1])
		lengths.append(run)
	var surface: MeshInstance3D = _ribbon(lefts, rights, lengths, lift, 1.0)
	surface.name = "Surface"
	surface.material_override = surface_material(kind, seed_value)
	root.add_child(surface)
	if bool(opts.get("edge", true)):
		var edge_width: float = clampf(width * 0.3, 0.55, 1.0)
		for side: float in [1.0, -1.0]:
			var inner: Array[Vector3] = []
			var outer: Array[Vector3] = []
			for index: int in range(kept.size()):
				var base: Vector3 = (lefts[index] if side > 0.0 else rights[index])
				var out_dir: Vector3 = (base - kept[index]).normalized()
				inner.append(base - out_dir * 0.3 + Vector3(0, 0, 0))
				outer.append(base + out_dir * edge_width)
			var strip: MeshInstance3D = _ribbon(inner, outer, lengths, lift + 0.001, 1.0)
			strip.name = "Edge_%s" % ("L" if side > 0.0 else "R")
			strip.material_override = edge_material(kind, seed_value)
			root.add_child(strip)
	for node: Node in root.get_children():
		var mesh_node: MeshInstance3D = node as MeshInstance3D
		if mesh_node != null:
			mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mesh_node.set_meta(StyleToon.META_NO_TOON, true)
	# Worn patches where the path bends hard and every so often, plus clumps along both edges at irregular gaps.
	var wear: Array[Vector3] = []
	if bool(opts.get("wear", true)):
		var since: float = 0.0
		for index: int in range(1, kept.size() - 1):
			var a: Vector3 = (kept[index] - kept[index - 1]).normalized()
			var b: Vector3 = (kept[index + 1] - kept[index]).normalized()
			since += kept[index].distance_to(kept[index - 1])
			if a.dot(b) < 0.97 and since > 4.0:
				wear.append(kept[index])
				since = 0.0
	root.set_meta("wear", wear)
	for position_value: Vector3 in wear:
		patch(root, position_value, width * 0.7, kind, rng.randf() * 360.0, seed_value + wear.find(position_value))
	root.set_meta("clumps", edge_clumps(kept, lefts, rights, float(opts.get("clumps", 1.0)), rng, opts.get("avoid", Callable()) as Callable, is_floor))
	return root


## Flower and grass clumps along the path edges: irregular gaps (some long bare stretches), clump size and kind vary.
static func edge_clumps(kept: Array[Vector3], lefts: Array[Vector3], rights: Array[Vector3], density: float, rng: RandomNumberGenerator, avoid: Callable, is_floor: Callable) -> Array[Dictionary]:
	var clumps: Array[Dictionary] = []
	if density <= 0.0:
		return clumps
	for side: float in [1.0, -1.0]:
		var edge: Array[Vector3] = lefts if side > 0.0 else rights
		var index: int = rng.randi_range(0, 4)
		while index < kept.size():
			var out_dir: Vector3 = (edge[index] - kept[index]).normalized()
			var pos: Vector3 = edge[index] + out_dir * rng.randf_range(0.25, 1.1)
			var ok: bool = true
			if is_floor.is_valid() and not bool(is_floor.call(pos)):
				ok = false
			if ok and avoid.is_valid() and bool(avoid.call(pos)):
				ok = false
			if ok:
				var flowery: bool = rng.randf() < 0.45
				clumps.append({
					"pos": pos,
					"radius": rng.randf_range(0.5, 1.1),
					"count": rng.randi_range(3, 7) if not flowery else rng.randi_range(5, 10),
					"cells": [2, 3, 0, 5] if flowery else [0, 1, 0, 5],
				})
			# irregular gaps: mostly short, sometimes a long bare stretch
			index += int(rng.randf_range(2.0, 6.0) / maxf(density, 0.2) * (3.0 if rng.randf() < 0.18 else 1.0))
	return clumps


## A round worn patch (DEC-WORNPATCH) at `pos`.
static func patch(parent: Node3D, pos: Vector3, radius: float, kind: String, yaw_degrees: float, seed_value: int = 0) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(radius * 2.0, radius * 1.6)
	quad.orientation = PlaneMesh.FACE_Y
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = "WornPatch"
	instance.mesh = quad
	instance.material_override = patch_material(kind, seed_value)
	instance.position = Vector3(pos.x, 0.036, pos.z)
	instance.rotation_degrees.y = yaw_degrees
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	parent.add_child(instance)
	return instance


## A cobbled plaza: an irregular-edged disc with a stone curb ring (ENV-GROUND-COBBLE).
static func plaza(parent: Node3D, center: Vector3, radius: float, opts: Dictionary = {}) -> Node3D:
	var seed_value: int = int(opts.get("seed", 3))
	var lift: float = float(opts.get("lift", 0.038))
	var root: Node3D = Node3D.new()
	root.name = "Plaza"
	parent.add_child(root)
	var segments: int = 40
	var inner: Array[Vector3] = []
	var rim: Array[Vector3] = []
	var lengths: Array[float] = []
	for step: int in range(segments + 1):
		var angle: float = TAU * float(step) / float(segments)
		var r: float = radius * (1.0 + 0.035 * sin(angle * 5.0 + float(seed_value)) + 0.02 * sin(angle * 11.0))
		inner.append(center + Vector3(cos(angle), 0.0, sin(angle)) * (r - 0.0))
		rim.append(center + Vector3(cos(angle), 0.0, sin(angle)) * (r + 0.7))
		lengths.append(float(step) * radius * TAU / float(segments))
	var disc: MeshInstance3D = MeshInstance3D.new()
	disc.name = "Cobbles"
	var arrays_vertices: PackedVector3Array = PackedVector3Array()
	var arrays_uvs: PackedVector2Array = PackedVector2Array()
	var arrays_normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	arrays_vertices.append(center)
	arrays_uvs.append(Vector2(0.5, 0.0))
	arrays_normals.append(Vector3.UP)
	for step: int in range(segments + 1):
		arrays_vertices.append(inner[step])
		arrays_uvs.append(Vector2(0.5, 0.0))
		arrays_normals.append(Vector3.UP)
	for step: int in range(segments):
		indices.append_array(PackedInt32Array([0, step + 1, step + 2]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = arrays_vertices
	arrays[Mesh.ARRAY_NORMAL] = arrays_normals
	arrays[Mesh.ARRAY_TEX_UV] = arrays_uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	disc.mesh = mesh
	var cobble_material: ShaderMaterial = surface_material("cobble", seed_value)
	cobble_material.set_shader_parameter("mode", 2)
	# mode 2 reads alpha from edge_tex: for the plaza the whole disc is opaque, so use a solid mask
	cobble_material.set_shader_parameter("edge_tex", _opaque())
	disc.material_override = cobble_material
	disc.position = Vector3(0, lift, 0)
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	disc.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(disc)
	# the soft, irregular fringe of the plaza (a ring ribbon fading into the grass)
	var fringe: MeshInstance3D = _ribbon(inner, rim, lengths, lift - 0.001, 1.0)
	fringe.name = "Fringe"
	fringe.material_override = edge_material("cobble", seed_value + 1)
	fringe.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fringe.set_meta(StyleToon.META_NO_TOON, true)
	root.add_child(fringe)
	return root


static var _opaque_texture: Texture2D


static func _opaque() -> Texture2D:
	if _opaque_texture == null:
		var image: Image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
		image.fill(Color(1, 1, 1, 1))
		_opaque_texture = ImageTexture.create_from_image(image)
	return _opaque_texture


## A triangle-strip ribbon between two polylines: UV.x runs 0 (first line) to 1 (second line), UV.y is the distance along in metres.
static func _ribbon(first: Array[Vector3], second: Array[Vector3], lengths: Array[float], lift: float, _unused: float) -> MeshInstance3D:
	var vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var indices: PackedInt32Array = PackedInt32Array()
	for index: int in range(first.size()):
		vertices.append(first[index])
		vertices.append(second[index])
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		uvs.append(Vector2(0.0, lengths[index]))
		uvs.append(Vector2(1.0, lengths[index]))
	for index: int in range(first.size() - 1):
		var a: int = index * 2
		indices.append_array(PackedInt32Array([a, a + 1, a + 2, a + 1, a + 3, a + 2]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = Vector3(0.0, lift, 0.0)
	return instance
