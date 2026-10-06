class_name StyleGrass
extends RefCounted
## Real grass for the ground cover: a clump of tapered blades (one cached mesh) drawn as a MultiMesh with `assets/shaders/style_grass.gdshader`
## (base-to-tip gradient, wind gusts, the hero tramples it). Replaces the confetti-like Kenney `grass_leafs` tufts: callers keep their own placement and
## hand the transforms to `multimesh_instance`.

const SHADER_PATH: String = "res://assets/shaders/style_grass.gdshader"
## The Kenney model name this system stands in for.
const REPLACES: String = "grass_leafs"
const BLADES: int = 7

static var _shader: Shader
static var _mesh: ArrayMesh
static var _materials: Dictionary = {}


static func replaces(model: String) -> bool:
	return model == REPLACES


## One clump: `BLADES` tapered blades fanned around the centre, leaning outward; UV.y is the height along the blade (0 base, 1 tip).
## About 0.26 m tall, so the callers' tuft scales (1.4 to 2.4) give 0.35 to 0.6 m grass.
static func clump_mesh() -> ArrayMesh:
	if _mesh != null:
		return _mesh
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4242
	var vertices: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	for blade: int in range(BLADES):
		var angle: float = TAU * float(blade) / float(BLADES) + rng.randf_range(-0.3, 0.3)
		var radial: Vector3 = Vector3(cos(angle), 0.0, sin(angle))
		var side: Vector3 = Vector3(-radial.z, 0.0, radial.x)
		var root_pos: Vector3 = radial * rng.randf_range(0.02, 0.07)
		var height: float = rng.randf_range(0.17, 0.27)
		var width: float = rng.randf_range(0.022, 0.034)
		var lean: float = rng.randf_range(0.04, 0.12)
		var base_index: int = vertices.size()
		vertices.append(root_pos - side * width)
		vertices.append(root_pos + side * width)
		vertices.append(root_pos + radial * lean * 0.55 - side * width * 0.55 + Vector3(0.0, height * 0.55, 0.0))
		vertices.append(root_pos + radial * lean * 0.55 + side * width * 0.55 + Vector3(0.0, height * 0.55, 0.0))
		vertices.append(root_pos + radial * lean + Vector3(0.0, height, 0.0))
		uvs.append(Vector2(0.0, 0.0))
		uvs.append(Vector2(1.0, 0.0))
		uvs.append(Vector2(0.0, 0.55))
		uvs.append(Vector2(1.0, 0.55))
		uvs.append(Vector2(0.5, 1.0))
		for i: int in range(5):
			normals.append(Vector3.UP)
		indices.append_array([base_index, base_index + 1, base_index + 2, base_index + 1, base_index + 3, base_index + 2, base_index + 2, base_index + 3, base_index + 4])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	_mesh = ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return _mesh


## The grass material for a base/tip colour pair (cached).
static func material(base: Color, tip: Color) -> ShaderMaterial:
	var key: String = "%s|%s" % [base.to_html(), tip.to_html()]
	if _materials.has(key):
		return _materials[key] as ShaderMaterial
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var result: ShaderMaterial = ShaderMaterial.new()
	result.shader = _shader
	result.set_shader_parameter("base_color", base)
	result.set_shader_parameter("tip_color", tip)
	_materials[key] = result
	return result


## Base/tip colours from a zone's ground patch colours (the first patch colour is the field, darkened at the root and lightened at the tip).
static func colors_for(patches: Array) -> Array[Color]:
	var field: Color = patches[0] as Color if not patches.is_empty() else Color("6fae62")
	var base: Color = Color.from_hsv(field.h, minf(1.0, field.s * 1.3), field.v * 0.55)
	var tip: Color = Color.from_hsv(fposmod(field.h - 0.02, 1.0), minf(1.0, field.s * 1.05), minf(1.0, field.v * 1.12))
	return [base, tip] as Array[Color]


## A MultiMeshInstance3D of grass clumps at `transforms`.
static func multimesh_instance(transforms: Array[Transform3D], base: Color, tip: Color) -> MultiMeshInstance3D:
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = clump_mesh()
	multimesh.instance_count = transforms.size()
	for i: int in range(transforms.size()):
		multimesh.set_instance_transform(i, transforms[i])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	instance.material_override = material(base, tip)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	return instance
