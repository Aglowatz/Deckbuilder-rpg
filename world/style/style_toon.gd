class_name StyleToon
extends RefCounted
## The unified toon material (assets/shaders/style_toon.gdshader). `apply` swaps every StandardMaterial3D under a node for a toon ShaderMaterial built from it
## (same atlas texture, albedo colour, vertex colours, emission, alpha scissor), so every imported pack renders in one style.
## Skips unshaded and blended materials (glows, labels, FX) and anything marked with the meta `no_toon`.

const SHADER_PATH: String = "res://assets/shaders/style_toon.gdshader"
const META_NO_TOON: StringName = &"no_toon"
## Set on a StandardMaterial3D (float 0..1) to give its toon version the glossy highlight band.
const META_GLOSS: StringName = &"toon_gloss"
const META_FLAT_UP: StringName = &"toon_flat_up"

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
	var paint: bool = PaintedClasses.active and PaintedClasses.allowed_for(mesh_instance)
	if mesh_instance.material_override != null:
		var override_toon: ShaderMaterial = toon_for(mesh_instance.material_override, wind_for(mesh_instance, wind), paint)
		if override_toon != null:
			mesh_instance.material_override = override_toon
			converted += 1
		else:
			return 0
	for surface: int in range(mesh_instance.mesh.get_surface_count()):
		var source: Material = mesh_instance.get_active_material(surface)
		var toon: ShaderMaterial = toon_for(source, wind_for(mesh_instance, wind), paint)
		if toon != null and paint and toon.get_shader_parameter("paint_on") == true:
			mesh_instance.set_instance_shader_parameter("roof_variant", PaintedClasses.roof_value(mesh_instance))
		if toon != null:
			mesh_instance.set_surface_override_material(surface, toon)
			converted += 1
	if converted > 0 and mesh_instance.is_inside_tree() and (small_prop(mesh_instance) or heavy_backdrop(mesh_instance)):
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return converted


static func _is_excluded(node: Node) -> bool:
	var current: Node = node
	while current != null:
		if current.has_meta(META_NO_TOON):
			return true
		current = current.get_parent()
	return false


## The toon version of `source`, or null when it should stay as it is. Cached per source material.
static func toon_for(source: Material, wind: float = -1.0, paint: bool = false) -> ShaderMaterial:
	var standard: StandardMaterial3D = source as StandardMaterial3D
	if standard == null:
		return null
	if standard.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED or standard.has_meta(META_NO_TOON):
		return null
	var scissor: bool = standard.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	if standard.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED and not scissor:
		return null
	var key: String = "%d|%s|%s" % [standard.get_instance_id(), str(wind), str(paint)]
	if _cache.has(key):
		return _cache[key] as ShaderMaterial
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = double_sided_shader() if (standard.cull_mode == BaseMaterial3D.CULL_DISABLED) else shader()
	material.set_shader_parameter("albedo", PALETTE_FIX.get(standard.resource_name, standard.albedo_color) if standard.albedo_texture == null else standard.albedo_color)
	var texture: Texture2D = standard.albedo_texture
	material.set_shader_parameter("use_texture", texture != null)
	if texture != null:
		material.set_shader_parameter("albedo_tex", texture)
	material.set_shader_parameter("use_vertex_color", standard.vertex_color_use_as_albedo)
	material.set_shader_parameter("vertex_color_srgb", standard.vertex_color_is_srgb)
	material.set_shader_parameter("uv1_scale", standard.uv1_scale)
	material.set_shader_parameter("uv1_offset", standard.uv1_offset)
	if standard.emission_enabled:
		material.set_shader_parameter("emission_color", standard.emission)
		material.set_shader_parameter("emission_energy", standard.emission_energy_multiplier)
	if scissor:
		material.set_shader_parameter("alpha_scissor", standard.alpha_scissor_threshold)
	if standard.has_meta(META_FLAT_UP):
		material.set_shader_parameter("flat_up", true)
	if standard.has_meta(META_GLOSS):
		material.set_shader_parameter("gloss", float(standard.get_meta(META_GLOSS)))
	if paint:
		PaintedClasses.configure(material, standard)
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
		_shader_double = load("res://assets/shaders/style_toon_double.gdshader") as Shader
	return _shader_double


const FOLIAGE_WORDS: PackedStringArray = ["tree", "bush", "grass", "flower", "plant", "leaf", "leaves", "hanging", "moss", "crop", "lily", "cactus", "banner", "flag", "cloth", "reed", "wheat", "corn", "fern", "mushroom_x"]


## Only foliage and cloth sways: a mesh whose own name or one of its ancestors up to the model root mentions a foliage word.
static func wind_for(mesh_instance: MeshInstance3D, wind: float) -> float:
	if wind <= 0.0:
		return -1.0
	var current: Node = mesh_instance
	var depth: int = 0
	while current != null and depth < 4:
		var lower: String = String(current.name).to_lower()
		for word: String in ["mountain", "hill", "cliff", "rock", "stone", "building", "house"]:
			if lower.contains(word):
				return -1.0
		for word: String in FOLIAGE_WORDS:
			if lower.contains(word):
				return wind
		current = current.get_parent()
		depth += 1
	return -1.0


## The Kenney Nature kit ships washed-out pastel flat colours (grass is mint, wood is peach). They are re-graded to the style guide palette
## (saturated but harmonious, section 4) by material name; textured materials are untouched.
const PALETTE_FIX: Dictionary = {
	"grass": Color("5fae4c"), "leafsGreen": Color("5fb04c"), "leafsDark": Color("3f8a52"), "leafsFall": Color("ee9a3c"),
	"wood": Color("c98f5e"), "woodDark": Color("9a6a46"), "woodBark": Color("ad7d54"), "woodBarkDark": Color("7d5538"),
	"woodBirch": Color("e8dfcd"), "woodInner": Color("e9c99a"),
	"stone": Color("b2a9bc"), "stoneDark": Color("7f7894"), "dirt": Color("bd8658"), "dirtDark": Color("8d6044"),
	"colorRed": Color("e2493f"), "colorRedDark": Color("b93a3e"), "colorYellow": Color("f6c23c"), "colorPurple": Color("8f6dd8"),
	"colorTan": Color("dcb68c"), "colorWhite": Color("f3ede1"), "corn": Color("e9c35c"), "water": Color("6cc4e8"),
}


## Small props (flowers, barrels, bottles) do not play shadows: the shadow pass is the most expensive part of the look on the dev PC
## and tiny shadows add little (docs/design/open_questions.md Q8).
const SMALL_PROP_SIZE: float = 0.75


static func small_prop(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance.mesh == null:
		return false
	var size: Vector3 = mesh_instance.mesh.get_aabb().size * mesh_instance.global_transform.basis.get_scale()
	return size.length() < SMALL_PROP_SIZE


## Big, far, low-value shadow casters: mountains, hills, clouds and cliffs (many thousands of triangles each).
static func heavy_backdrop(mesh_instance: MeshInstance3D) -> bool:
	var current: Node = mesh_instance
	var depth: int = 0
	while current != null and depth < 4:
		var lower: String = String(current.name).to_lower()
		for word: String in ["mountain", "hill", "cloud", "cliff"]:
			if lower.contains(word):
				return true
		current = current.get_parent()
		depth += 1
	return false
