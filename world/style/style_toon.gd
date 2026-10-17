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
## Set on a StandardMaterial3D to give its toon version its own distance haze instead of the world fog (`far_haze_shader`): a far landmark that must read
## through a thick mood fog (Primm's Castle over the great wall). The haze is the instance uniform `far_haze` on the mesh (rgb its colour, a its density per metre).
const META_FAR_HAZE: StringName = &"far_haze"

static var _shader: Shader
static var _shader_double: Shader
static var _cache: Dictionary = {}
static var _haze_shaders: Dictionary = {}


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
	if wind_for(mesh_instance, wind) > 0.0 and is_cloth(mesh_instance):
		set_hang(mesh_instance)
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
static func toon_for(source: Material, wind: float = -1.0, paint: bool = true) -> ShaderMaterial:
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
	if standard.has_meta(META_FAR_HAZE):
		material.shader = far_haze_shader(standard.cull_mode == BaseMaterial3D.CULL_DISABLED)
	material.set_shader_parameter("albedo", PALETTE_FIX.get(standard.resource_name, standard.albedo_color) if standard.albedo_texture == null else standard.albedo_color)
	var texture: Texture2D = standard.albedo_texture
	material.set_shader_parameter("use_texture", texture != null)
	if texture != null:
		material.set_shader_parameter("albedo_tex", texture)
	material.set_shader_parameter("use_normal_tex", standard.normal_enabled and standard.normal_texture != null)
	if standard.normal_enabled and standard.normal_texture != null:
		material.set_shader_parameter("normal_tex", standard.normal_texture)
		material.set_shader_parameter("normal_strength", standard.normal_scale)
	var rough_texture: Texture2D = standard.roughness_texture
	material.set_shader_parameter("use_rough_tex", rough_texture != null)
	if rough_texture != null:
		material.set_shader_parameter("rough_tex", rough_texture)
		material.set_shader_parameter("kit_sheen", 0.35)
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


## The toon shader (or its double-sided twin) with its own distance haze in place of the world fog: the fragment writes FOG (which replaces the built-in
## fog) from the instance uniform `far_haze`. Built once from the shader's own source, so it never drifts from the toon look.
static func far_haze_shader(double_sided: bool) -> Shader:
	if not _haze_shaders.has(double_sided):
		var code: String = (double_sided_shader() if double_sided else shader()).code
		code = code.replace("void fragment() {", "instance uniform vec4 far_haze : source_color = vec4(0.6, 0.6, 0.65, 0.0);\n\nvoid fragment() {\n\tFOG = vec4(far_haze.rgb, 1.0 - exp(-far_haze.a * length(VERTEX)));")
		var haze: Shader = Shader.new()
		haze.code = code
		_haze_shaders[double_sided] = haze
	return _haze_shaders[double_sided] as Shader


## The same shader with back faces drawn (leaves, cloth, flags).
static func double_sided_shader() -> Shader:
	if _shader_double == null:
		_shader_double = load("res://assets/shaders/style_toon_double.gdshader") as Shader
	return _shader_double


const FOLIAGE_WORDS: PackedStringArray = ["tree", "bush", "grass", "flower", "plant", "leaf", "leafs", "leaves", "hanging", "moss", "crop", "lily", "cactus", "banner", "flag", "cloth", "reed", "wheat", "corn", "fern", "vine", "ivy", "sunflower", "hay"]
## Crosspath pass, Part B: rigid things never sway, whatever else their name says (a "well_corner" cluster swayed for the "corn" in "corner", the pantry
## door's "DoorLeaves" for its "leaves"). A rigid word on the mesh or on a nearer ancestor than any foliage word wins.
const RIGID_WORDS: PackedStringArray = [
	"mountain", "hill", "cliff", "rock", "stone", "boulder", "ridge", "building", "house", "cottage", "hut", "shop", "hall", "chapel", "tower", "mill", "shed",
	"well", "lamp", "lantern", "post", "pole", "fence", "rail", "wall", "gate", "door", "roof", "beam", "barrel", "crate", "sack", "box", "cart", "bench", "stall",
	"sign", "signpost", "board", "chest", "bridge", "booth", "barrier", "statue", "fountain", "pot", "flowerpot", "planter", "table", "dock", "pier", "frame", "arch",
	"lever", "ladder", "cairn", "vault", "hatch", "boundary", "stack", "bale",
]


## The words of a node name: split at underscores, dashes, spaces, digits, "@" and lower-to-upper case changes, lower-cased ("tree_pineTallA2" -> tree, pine, tall, a).
static func name_words(node_name: String) -> PackedStringArray:
	var words: PackedStringArray = []
	var current: String = ""
	var previous_lower: bool = false
	for index: int in range(node_name.length()):
		var ch: String = node_name[index]
		var is_letter: bool = (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z")
		var is_upper: bool = ch >= "A" and ch <= "Z"
		if not is_letter or (is_upper and previous_lower):
			if current != "":
				words.append(current.to_lower())
			current = ""
		if is_letter:
			current += ch
		previous_lower = is_letter and not is_upper
	if current != "":
		words.append(current.to_lower())
	return words


## True when one word of `node_name` is a foliage word (whole words only: "corner" is not "corn").
static func is_foliage_name(node_name: String) -> bool:
	for word: String in name_words(node_name):
		if FOLIAGE_WORDS.has(word) or FOLIAGE_WORDS.has(word.trim_suffix("s")):
			return true
	return false


static func is_rigid_name(node_name: String) -> bool:
	for word: String in name_words(node_name):
		if RIGID_WORDS.has(word) or RIGID_WORDS.has(word.trim_suffix("s")) or RIGID_WORDS.has(word.trim_suffix("es")):
			return true
	return false


## Only foliage and cloth sways: the nearest of the mesh and its ancestors (up to the model root) whose name says what it is decides; rigid wins ties.
static func wind_for(mesh_instance: MeshInstance3D, wind: float) -> float:
	if wind <= 0.0:
		return -1.0
	var current: Node = mesh_instance
	var depth: int = 0
	while current != null and depth < 4:
		# meta `no_wind`: a built landmark whose name happens to mention a foliage word (the Sky Tree) must not sway
		if current.has_meta(&"no_wind"):
			return -1.0
		var node_name: String = String(current.name)
		if is_rigid_name(node_name):
			return -1.0
		if is_foliage_name(node_name):
			return wind
		current = current.get_parent()
		depth += 1
	return -1.0


## Gainlands v2, Part E: hanging cloth. Words that make a mesh a banner or flag hung from a bar (the toon shaders' hang mode: the top edge stays put, the swing
## grows towards the bottom, across the cloth only). A plant's "hanging" basket is foliage, not cloth.
const CLOTH_WORDS: PackedStringArray = ["banner", "flag", "cloth", "pennant", "bunting"]


## True when the nearest named node (the mesh, then its ancestors) that says what it is says cloth (rigid words win, as in wind_for).
static func is_cloth(mesh_instance: MeshInstance3D) -> bool:
	var current: Node = mesh_instance
	var depth: int = 0
	while current != null and depth < 4:
		var node_name: String = String(current.name)
		if is_rigid_name(node_name):
			return false
		for word: String in name_words(node_name):
			if CLOTH_WORDS.has(word) or CLOTH_WORDS.has(word.trim_suffix("s")):
				return true
		if is_foliage_name(node_name):
			return false
		current = current.get_parent()
		depth += 1
	return false


## The hang mode's per-instance parameters from the mesh's own bounds: the cloth's normal is its thinnest horizontal axis, its top edge the bounds' top,
## its length their height (meta "hang" = Vector2(top, length) overrides the bounds); the phase comes from the banner's own node (the mesh's parent), so
## every part of one banner (cloth, stripe, emblem) moves as one and two banners never move in step.
static func hang_params(mesh_instance: MeshInstance3D) -> Dictionary:
	var box: AABB = mesh_instance.mesh.get_aabb() if mesh_instance.mesh != null else AABB()
	var normal: Vector3 = Vector3(1, 0, 0) if box.size.x <= box.size.z else Vector3(0, 0, 1)
	var top: float = box.end.y
	var length: float = maxf(box.size.y, 0.1)
	if mesh_instance.has_meta(&"hang"):
		var given: Vector2 = mesh_instance.get_meta(&"hang") as Vector2
		top = given.x
		length = maxf(given.y, 0.1)
	if mesh_instance.has_meta(&"hang_normal"):
		normal = mesh_instance.get_meta(&"hang_normal") as Vector3
	var anchor: Node3D = mesh_instance.get_parent() as Node3D
	var origin: Vector3 = Vector3.ZERO
	if anchor != null:
		origin = anchor.global_position if anchor.is_inside_tree() else anchor.position
	return {"hang": Vector4(normal.x, normal.y, normal.z, length), "top": top, "phase": hang_phase(origin)}


## A banner's own phase (radians) from where its node stands: two banners never move in step.
static func hang_phase(origin: Vector3) -> float:
	return fposmod(sin(origin.x * 12.9898 + origin.z * 78.233) * 43758.5453, 1.0) * TAU


static func set_hang(mesh_instance: MeshInstance3D) -> void:
	var params: Dictionary = hang_params(mesh_instance)
	mesh_instance.set_instance_shader_parameter("hang", params["hang"])
	mesh_instance.set_instance_shader_parameter("hang_top_phase", Vector2(float(params["top"]), float(params["phase"])))


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
