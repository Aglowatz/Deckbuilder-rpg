class_name GroundDecals
extends RefCounted
## Flat, soft-edged ground treatments laid just above the hex tiles (cobbles, dirt, moss, flowerbed soil): discs and ribbons using
## `assets/shaders/style_ground.gdshader`, plus an additive glow for lantern light pools.

const SHADER_PATH: String = "res://assets/shaders/style_ground.gdshader"
const LIFT: float = 0.025

enum Pattern { COBBLE, DIRT, MOSS, SOIL, CRACKS, PUDDLE, STAIN, LEAVES, CHALK, SCORCH, FOOTPRINTS }
enum Shape { DISC, RIBBON }

static var _shader: Shader


static func material(pattern: Pattern, color_a: Color, color_b: Color, gap: Color, shape: Shape, scale_value: float = 2.2, soft: float = 0.28, seed_value: float = 0.0) -> ShaderMaterial:
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var result: ShaderMaterial = ShaderMaterial.new()
	result.shader = _shader
	result.set_shader_parameter("pattern", int(pattern))
	result.set_shader_parameter("shape", int(shape))
	result.set_shader_parameter("color_a", color_a)
	result.set_shader_parameter("color_b", color_b)
	result.set_shader_parameter("gap_color", gap)
	result.set_shader_parameter("scale", scale_value)
	result.set_shader_parameter("edge_soft", soft)
	result.set_shader_parameter("seed", seed_value)
	return result


## An elliptical patch centred on `center` (x/z), `radius` across, squashed by `stretch` along z, rotated by `yaw` degrees.
static func disc(parent: Node3D, center: Vector3, radius: float, mat: ShaderMaterial, stretch: float = 1.0, yaw: float = 0.0, lift: float = 0.0) -> MeshInstance3D:
	var segments: int = 28
	var vertices: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	vertices.append(Vector3.ZERO)
	uvs.append(Vector2(0.5, 0.5))
	normals.append(Vector3.UP)
	for i: int in range(segments):
		var angle: float = TAU * float(i) / float(segments)
		vertices.append(Vector3(cos(angle) * radius, 0.0, sin(angle) * radius * stretch))
		uvs.append(Vector2(0.5 + 0.5 * cos(angle), 0.5 + 0.5 * sin(angle)))
		normals.append(Vector3.UP)
	for i: int in range(segments):
		indices.append(0)
		indices.append(1 + i)
		indices.append(1 + (i + 1) % segments)
	return _instance(parent, vertices, uvs, normals, indices, mat, center + Vector3(0.0, LIFT + lift, 0.0), yaw)


## A ribbon following `points` (x/z) `width` wide, soft at both edges.
static func ribbon(parent: Node3D, points: Array[Vector3], width: float, mat: ShaderMaterial, lift: float = 0.0) -> MeshInstance3D:
	var vertices: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	var run: float = 0.0
	for i: int in range(points.size()):
		var previous: Vector3 = points[maxi(i - 1, 0)]
		var next: Vector3 = points[mini(i + 1, points.size() - 1)]
		var direction: Vector3 = next - previous
		direction.y = 0.0
		direction = direction.normalized()
		var side: Vector3 = Vector3(-direction.z, 0.0, direction.x) * width * 0.5
		if i > 0:
			run += points[i].distance_to(points[i - 1])
		vertices.append(points[i] - side)
		vertices.append(points[i] + side)
		uvs.append(Vector2(0.0, run / width))
		uvs.append(Vector2(1.0, run / width))
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
	for i: int in range(points.size() - 1):
		var base: int = i * 2
		indices.append_array([base, base + 2, base + 1, base + 1, base + 2, base + 3])
	return _instance(parent, vertices, uvs, normals, indices, mat, Vector3(0.0, LIFT + lift, 0.0), 0.0)


static func _instance(parent: Node3D, vertices: PackedVector3Array, uvs: PackedVector2Array, normals: PackedVector3Array, indices: PackedInt32Array, mat: ShaderMaterial, position: Vector3, yaw: float) -> MeshInstance3D:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = mat
	instance.position = position
	instance.rotation_degrees.y = yaw
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	parent.add_child(instance)
	return instance


## An additive warm glow on the ground: the visible part of a lantern light pool, which also shows on Low where real lights are limited.
static func glow(parent: Node3D, center: Vector3, radius: float, color: Color, strength: float = 0.55) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(radius * 2.0, radius * 2.0)
	quad.orientation = PlaneMesh.FACE_Y
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.albedo_texture = StyleAmbience.soft_texture()
	material.albedo_color = Color(color.r, color.g, color.b, strength)
	material.disable_receive_shadows = true
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = quad
	instance.material_override = material
	instance.position = center + Vector3(0.0, LIFT + 0.02, 0.0)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	parent.add_child(instance)
	return instance


# ---- Authoring API (G-09): kinds with default palettes, soft edges and a per-quality budget ---------------------------------------------

## Higher-level decal kinds; each maps to a shader pattern with its own default palette (`palette` overrides: [color_a, color_b, gap]).
enum Kind { CRACKS, PUDDLE, STAIN, LEAF_PILE, CHALK, SCORCH, FOOTPRINTS, MOSS_PATCH, DIRT_PATCH, WORN_PATH }

## The most decals one scene may add per graphics quality level (Low / Medium / High).
const BUDGETS: Array[int] = [40, 120, 260]

static var _budget_left: int = 120
static var _added: Dictionary = {}


## Call once when building a scene: resets the budget for `level` and the per-kind report.
static func begin(level: int) -> void:
	_budget_left = BUDGETS[clampi(level, 0, BUDGETS.size() - 1)]
	_added.clear()


## How many decals of each kind were added since `begin` (Kind name -> count), for tests and the debug overlay.
static func report() -> Dictionary:
	return _added.duplicate()


static func budget_left() -> int:
	return _budget_left


static func _kind_material(kind: Kind, palette: Array[Color], shape: Shape, seed_value: float) -> ShaderMaterial:
	var a: Color = palette[0] if palette.size() > 0 else Color.WHITE
	var b: Color = palette[1] if palette.size() > 1 else a
	var gap: Color = palette[2] if palette.size() > 2 else a.darkened(0.5)
	match kind:
		Kind.CRACKS:
			return material(Pattern.CRACKS, a, b, palette[2] if palette.size() > 2 else Color(0.12, 0.1, 0.12), shape, 0.9, 0.1, seed_value)
		Kind.PUDDLE:
			var puddle: ShaderMaterial = material(Pattern.PUDDLE, palette[0] if palette.size() > 0 else Color("6fb8d8"), palette[1] if palette.size() > 1 else Color("3f7fb0"), gap, shape, 1.0, 0.35, seed_value)
			return puddle
		Kind.STAIN:
			return material(Pattern.STAIN, palette[0] if palette.size() > 0 else Color("5a3d2e"), palette[1] if palette.size() > 1 else Color("7a5a44"), gap, shape, 0.6, 0.6, seed_value)
		Kind.LEAF_PILE:
			return material(Pattern.LEAVES, palette[0] if palette.size() > 0 else Color("c9803a"), palette[1] if palette.size() > 1 else Color("a85a2a"), gap, shape, 2.6, 0.4, seed_value)
		Kind.CHALK:
			return material(Pattern.CHALK, palette[0] if palette.size() > 0 else Color("f2eee0"), b, gap, shape, 1.0, 0.2, seed_value)
		Kind.SCORCH:
			return material(Pattern.SCORCH, palette[0] if palette.size() > 0 else Color("3a3028"), b, palette[2] if palette.size() > 2 else Color("120e0c"), shape, 1.0, 0.5, seed_value)
		Kind.FOOTPRINTS:
			return material(Pattern.FOOTPRINTS, palette[0] if palette.size() > 0 else Color("6a5238"), b, gap, shape, 1.0, 0.15, seed_value)
		Kind.MOSS_PATCH:
			return material(Pattern.MOSS, palette[0] if palette.size() > 0 else Color("5f9a4a"), palette[1] if palette.size() > 1 else Color("7aa850"), gap, shape, 1.0, 0.7, seed_value)
		Kind.DIRT_PATCH:
			return material(Pattern.DIRT, palette[0] if palette.size() > 0 else Color("a9835a"), palette[1] if palette.size() > 1 else Color("8a6a46"), palette[2] if palette.size() > 2 else Color("5e4630"), shape, 1.0, 0.5, seed_value)
		_:
			return material(Pattern.DIRT, palette[0] if palette.size() > 0 else Color("b79a64"), palette[1] if palette.size() > 1 else Color("9c8157"), palette[2] if palette.size() > 2 else Color("6e5a3c"), shape, 1.0, 0.3, seed_value)


## A decal patch of `kind` centred on `center` (x/z; y is the ground height), `radius` across. Returns null when the budget is spent.
static func add_patch(parent: Node3D, center: Vector3, radius: float, kind: Kind, palette: Array[Color] = [], seed_value: float = 0.0, stretch: float = 1.0, yaw: float = 0.0) -> MeshInstance3D:
	if _budget_left <= 0:
		return null
	_budget_left -= 1
	_added[Kind.keys()[kind]] = int(_added.get(Kind.keys()[kind], 0)) + 1
	var mat: ShaderMaterial = _kind_material(kind, palette, Shape.DISC, seed_value)
	return disc(parent, center, radius, mat, stretch, yaw, 0.001 * float(_added.size()) + 0.0004 * float(kind))


## A decal ribbon of `kind` along `points`, `width` wide (paths, tracks, chalk lines, footprints). Returns null when the budget is spent.
static func add_path(parent: Node3D, points: Array[Vector3], kind: Kind, width: float = 1.0, palette: Array[Color] = [], seed_value: float = 0.0) -> MeshInstance3D:
	if _budget_left <= 0 or points.size() < 2:
		return null
	_budget_left -= 1
	_added[Kind.keys()[kind]] = int(_added.get(Kind.keys()[kind], 0)) + 1
	var mat: ShaderMaterial = _kind_material(kind, palette, Shape.RIBBON, seed_value)
	return ribbon(parent, points, width, mat, 0.001 * float(_added.size()) + 0.0004 * float(kind))
