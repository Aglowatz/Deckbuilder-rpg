class_name KitAO
extends RefCounted
## Contact ambient occlusion pools for the kit (vertical slice, Part D): `footprint()` under a building, `blob()` under a prop or a tree trunk. Baked-look, unlit, one quad each
## (see kit_ao.gdshader). Together with the vertex-colour AO of the kit meshes this gives the darker corners, eaves and gaps of a baked lightmap on Medium, where SSAO is off.
## LightmapGI is not used: the kit geometry is generated at run time (no UV2, no bake step), and a baked lightmap would not follow the moved / swapped buildings.

const SHADER: String = "res://world/kit/kit_ao.gdshader"
const LIFT: float = 0.041

static var _shader: Shader


static func _material(half_size: Vector2, margin: float, strength: float, round_shape: bool) -> ShaderMaterial:
	if _shader == null:
		_shader = load(SHADER) as Shader
	var material_value: ShaderMaterial = ShaderMaterial.new()
	material_value.shader = _shader
	material_value.set_shader_parameter("half_size", half_size)
	material_value.set_shader_parameter("margin", margin)
	material_value.set_shader_parameter("strength", strength)
	material_value.set_shader_parameter("round_shape", round_shape)
	material_value.render_priority = -30
	return material_value


static func _quad(parent: Node3D, pos: Vector3, extent: Vector2, yaw_degrees: float, material_value: ShaderMaterial, node_name: String) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = extent
	quad.orientation = PlaneMesh.FACE_Y
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = quad
	instance.material_override = material_value
	instance.position = Vector3(pos.x, LIFT, pos.z)
	instance.rotation_degrees.y = yaw_degrees
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	parent.add_child(instance)
	return instance


## A rounded dark skirt under a building of `size` (width, depth), rotated by `yaw_degrees`.
static func footprint(parent: Node3D, center: Vector3, size: Vector2, yaw_degrees: float, strength: float = 0.42, margin: float = 1.1) -> MeshInstance3D:
	var extent: Vector2 = size + Vector2(margin * 2.4, margin * 2.4)
	return _quad(parent, center, extent, yaw_degrees, _material(size * 0.5, margin, strength, false), "AO")


## A round dark pool under a prop of ground `radius`.
static func blob(parent: Node3D, center: Vector3, radius: float, strength: float = 0.34, margin: float = 0.35) -> MeshInstance3D:
	var extent: Vector2 = Vector2.ONE * (radius + margin) * 2.2
	return _quad(parent, center, extent, 0.0, _material(Vector2(radius, radius), margin, strength, true), "AO")
