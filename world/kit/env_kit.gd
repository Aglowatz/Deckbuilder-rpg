class_name EnvKit
extends RefCounted
## The Environment Kit registry (data/art/environment_kit.json): every kit asset ID of the designer's sheet mapped to its slot and its placeholder. `texture(id)` is the real painted art when
## `assets/art/env_kit/<ID>.webp|.png` exists, otherwise the placeholder (a TEX-MAT-* / TEX-TOWN-* texture, or a generated stand-in from `KitTextures`). `material(id)` wraps it in a
## material the toon pipeline converts. Nothing else in the building / prop / tree / path code names a texture: dropping art in the folder is the whole integration.

const DATA_PATH: String = "res://data/art/environment_kit.json"
const ART_DIR: String = "res://assets/art/env_kit/"

static var _entries: Dictionary = {}
static var _order: Array[String] = []
static var _loaded: bool = false
static var _materials: Dictionary = {}


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("EnvKit: %s missing" % DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return
	for item: Variant in (parsed as Dictionary).get("items", []) as Array:
		var entry: Dictionary = item as Dictionary
		var id: String = str(entry.get("id", ""))
		if id != "":
			_entries[id] = entry
			_order.append(id)


static func ids() -> Array[String]:
	_load()
	return _order.duplicate()


static func has(id: String) -> bool:
	_load()
	return _entries.has(id)


static func entry(id: String) -> Dictionary:
	_load()
	return _entries.get(id, {}) as Dictionary


## The slot name of `id` ("wall.main", "door.a" ...), "" for an unknown id.
static func slot(id: String) -> String:
	return str(entry(id).get("slot", ""))


static func tile_size(id: String) -> float:
	return float(entry(id).get("tile", 2.0))


## The path of the real art file of `id`, or "" while it is still a placeholder.
static func art_path(id: String) -> String:
	for ext: String in ["webp", "png"]:
		var path: String = "%s%s.%s" % [ART_DIR, id, ext]
		if ResourceLoader.exists(path):
			return path
	return ""


static func has_art(id: String) -> bool:
	return art_path(id) != ""


## "art" when the real file exists, "placeholder" otherwise, "unknown" for an id that is not in the data file.
static func status(id: String) -> String:
	if not has(id):
		return "unknown"
	return "art" if has_art(id) else "placeholder"


## The kit texture of `id` (real art, else the placeholder), or null when neither can be loaded.
static func texture(id: String) -> Texture2D:
	var path: String = art_path(id)
	if path != "":
		return load(path) as Texture2D
	var placeholder: String = str(entry(id).get("placeholder", ""))
	if placeholder.begins_with("tex:"):
		return PaintedLibrary.albedo(placeholder.trim_prefix("tex:"))
	if placeholder.begins_with("gen:"):
		return KitTextures.texture(placeholder.trim_prefix("gen:"))
	return null


## The placeholder generator name ("window_cross", "sign_cards", ...), "" when the id is textured by a file or a TEX- name. Geometry styles (windows) read it.
static func generator(id: String) -> String:
	var placeholder: String = str(entry(id).get("placeholder", ""))
	return placeholder.trim_prefix("gen:") if placeholder.begins_with("gen:") else ""


static func tint(id: String) -> Color:
	return Color.html(str(entry(id).get("tint", "#ffffff")))


## A cached tileable material for `id`. `cut` makes it an alpha-scissor cut-out (signs, trees, ivy) drawn on both sides; `mul` multiplies the kit tint (grading per building).
static func material(id: String, cut: bool = false, mul: Color = Color.WHITE) -> StandardMaterial3D:
	_load()
	var key: String = "%s|%s|%s" % [id, str(cut), mul.to_html()]
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D
	var material_value: StandardMaterial3D = StandardMaterial3D.new()
	material_value.resource_name = id
	var texture_value: Texture2D = texture(id)
	if texture_value != null:
		material_value.albedo_texture = texture_value
	var real: bool = has_art(id)
	# A real painted asset keeps its own colours; only the placeholders are tinted.
	material_value.albedo_color = (Color.WHITE if real else tint(id)) * mul
	material_value.roughness = 1.0
	material_value.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	# Vertex colours carry the baked ambient occlusion of the kit meshes (KitMesh).
	material_value.vertex_color_use_as_albedo = true
	var tile: float = tile_size(id)
	if not cut and tile > 0.0:
		# Kit meshes carry UVs in metres, so one texture repeat covers `tile` metres.
		material_value.uv1_scale = Vector3(1.0 / tile, 1.0 / tile, 1.0)
	if cut:
		material_value.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material_value.alpha_scissor_threshold = 0.5
		material_value.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_value.set_meta(PaintedClasses.META_NO_PAINT, true)
	material_value.vertex_color_use_as_albedo = true
	_materials[key] = material_value
	return material_value


## A flat-colour kit material (iron, glass frame, soil) that is not an asset of the sheet.
static func flat(color: Color, key: String = "") -> StandardMaterial3D:
	var cache_key: String = "flat|%s|%s" % [color.to_html(), key]
	if _materials.has(cache_key):
		return _materials[cache_key] as StandardMaterial3D
	var material_value: StandardMaterial3D = StandardMaterial3D.new()
	material_value.albedo_color = color
	material_value.roughness = 1.0
	material_value.set_meta(PaintedClasses.META_NO_PAINT, true)
	material_value.vertex_color_use_as_albedo = true
	_materials[cache_key] = material_value
	return material_value


## A warm glowing material (lit window glass, lantern panes) the toon shader renders with emission so the bloom picks it up.
static func glow(color: Color, energy: float = 1.6) -> StandardMaterial3D:
	var cache_key: String = "glow|%s|%s" % [color.to_html(), str(energy)]
	if _materials.has(cache_key):
		return _materials[cache_key] as StandardMaterial3D
	var material_value: StandardMaterial3D = StandardMaterial3D.new()
	material_value.albedo_color = color
	material_value.emission_enabled = true
	material_value.emission = color
	material_value.emission_energy_multiplier = energy
	material_value.roughness = 1.0
	material_value.set_meta(PaintedClasses.META_NO_PAINT, true)
	material_value.vertex_color_use_as_albedo = true
	_materials[cache_key] = material_value
	return material_value


static func clear_cache() -> void:
	_materials.clear()
	KitTextures.clear()
	_loaded = false
	_entries.clear()
	_order.clear()
