class_name StyleToon
extends RefCounted
## The unified toon material (assets/shaders/style_toon.gdshader). `apply` swaps every StandardMaterial3D under a node for a toon ShaderMaterial built from it
## (same atlas texture, albedo colour, vertex colours, emission, alpha scissor), so every imported pack renders in one style.
## Skips unshaded and blended materials (glows, labels, FX) and anything marked with the meta `no_toon`.

const SHADER_PATH: String = "res://assets/shaders/style_toon.gdshader"
const META_NO_TOON: StringName = &"no_toon"

static var _shader: Shader
static var _shader_double: Shader
static var _cache: Dictionary = {}


static func shader() -> Shader:
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	return _shader


## Converts all eligible meshes under `root`; returns how many surfaces were converted.
static func apply(root: Node, wind: float = -1.0) -> int:
	var converted: int = 0
	var meshes: Array[Node] = root.find_children("*", "MeshInstance3D", true, false)
	if root is MeshInstance3D:
		meshes.append(root)
	for node: Node in meshes:
		converted += apply_mesh(node as MeshInstance3D, wind)
	return converted


static func apply_mesh(mesh_instance: MeshInstance3D, wind: float = -1.0) -> int:
	if mesh_instance.mesh == null or _is_excluded(mesh_instance):
		return 0
	var converted: int = 0
	for surface: int in range(mesh_instance.mesh.get_surface_count()):
		var source: Material = mesh_instance.get_active_material(surface)
		var toon: ShaderMaterial = toon_for(source, wind)
		if toon != null:
			mesh_instance.set_surface_override_material(surface, toon)
			converted += 1
	return converted


static func _is_excluded(node: Node) -> bool:
	var current: Node = node
	while current != null:
		if current.has_meta(META_NO_TOON):
			return true
		current = current.get_parent()
	return false


## The toon version of `source`, or null when it should stay as it is. Cached per source material.
static func toon_for(source: Material, wind: float = -1.0) -> ShaderMaterial:
	var standard: StandardMaterial3D = source as StandardMaterial3D
	if standard == null:
		return null
	if standard.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED or standard.has_meta(META_NO_TOON):
		return null
	var scissor: bool = standard.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	if standard.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and not scissor:
		return null
	var key: String = "%d|%s" % [standard.get_instance_id(), str(wind)]
	if _cache.has(key):
		return _cache[key] as ShaderMaterial
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = double_sided_shader() if standard.cull_mode == BaseMaterial3D.CULL_DISABLED else shader()
	material.set_shader_parameter("albedo", standard.albedo_color)
	var texture: Texture2D = standard.albedo_texture
	material.set_shader_parameter("use_texture", texture != null)
	if texture != null:
		material.set_shader_parameter("albedo_tex", texture)
	material.set_shader_parameter("use_vertex_color", standard.vertex_color_use_as_albedo)
	material.set_shader_parameter("uv1_scale", standard.uv1_scale)
	material.set_shader_parameter("uv1_offset", standard.uv1_offset)
	if standard.emission_enabled:
		material.set_shader_parameter("emission_color", standard.emission)
		material.set_shader_parameter("emission_energy", standard.emission_energy_multiplier)
	if scissor:
		material.set_shader_parameter("alpha_scissor", standard.alpha_scissor_threshold)
	if wind >= 0.0:
		material.set_shader_parameter("wind_amount", wind)
	_cache[key] = material
	return material


## Per-instance: keep this object's colours in the monochrome zones and optionally give it the zone's accent rim (interactables, enemies, the player).
static func keep_colour(node: Node, accent: float = 0.0) -> void:
	var meshes: Array[Node] = node.find_children("*", "GeometryInstance3D", true, false)
	if node is GeometryInstance3D:
		meshes.append(node)
	for mesh: Node in meshes:
		var geometry: GeometryInstance3D = mesh as GeometryInstance3D
		geometry.set_instance_shader_parameter("colour_keep", 1.0)
		geometry.set_instance_shader_parameter("accent_mix", accent)


static func clear_cache() -> void:
	_cache.clear()


## The same shader with back faces drawn (leaves, cloth, flags).
static func double_sided_shader() -> Shader:
	if _shader_double == null:
		_shader_double = Shader.new()
		_shader_double.code = shader().code.replace("cull_back", "cull_disabled")
	return _shader_double
