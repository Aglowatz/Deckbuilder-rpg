class_name GroundDecals
extends RefCounted
## Flat, soft-edged ground treatments laid just above the hex tiles (cobbles, dirt, moss, flowerbed soil): discs and ribbons using
## `assets/shaders/style_ground.gdshader`, plus an additive glow for lantern light pools.

const SHADER_PATH: String = "res://assets/shaders/style_ground.gdshader"
const LIFT: float = 0.025

enum Pattern { COBBLE, DIRT, MOSS, SOIL }
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
