class_name EnvKit
extends RefCounted
## The Environment Kit registry (data/art/environment_kit.json): every kit asset ID of the designer's sheet mapped to its slot and its placeholder. `texture(id)` is the real painted art when
## `assets/art/env_kit/<ID>.webp|.png` exists, otherwise the placeholder (a TEX-MAT-* / TEX-TOWN-* texture, or a generated stand-in from `KitTextures`). `material(id)` wraps it in a
## material the toon pipeline converts. Nothing else in the building / prop / tree / path code names a texture: dropping art in the folder is the whole integration.

const DATA_PATH: String = "res://data/art/environment_kit.json"
const ART_DIR: String = "res://assets/art/env_kit/"
## `ENV_KIT_ART_DIR` (an absolute folder or res:// path) previews art from another folder without committing it.

static var _entries: Dictionary = {}
static var _order: Array[String] = []
static var _loaded: bool = false
static var _materials: Dictionary = {}
static var _prep: Dictionary = {}
const PREP_PATH: String = "res://data/art/env_kit_prep.json"
## Zone kits (tools/import_zone_kit.gd): data/art/zone_kits/<zone>.json registers every id of a zone's own kit (GAIN-WALL-BRICK ...) with its prep numbers in the entry
## itself; the art lives in assets/art/zone_kits/<zone>/<ID>.webp. They resolve through the same calls as the Environment Kit ids and are the targets of a zone's material swaps.
const ZONE_DIR: String = "res://data/art/zone_kits/"
const ZONE_ART_DIR: String = "res://assets/art/zone_kits/"
static var _zone_entries: Dictionary = {}
static var _zone_order: Dictionary = {}


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	var prep_text: String = FileAccess.get_file_as_string(PREP_PATH) if FileAccess.file_exists(PREP_PATH) else ""
	var prep_parsed: Variant = JSON.parse_string(prep_text) if prep_text != "" else null
	if prep_parsed is Dictionary:
		_prep = (prep_parsed as Dictionary).get("items", {}) as Dictionary
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
	_load_zones()


static func _load_zones() -> void:
	var dir: DirAccess = DirAccess.open(ZONE_DIR)
	if dir == null:
		return
	var files: PackedStringArray = dir.get_files()
	files.sort()
	for file_name: String in files:
		if file_name.get_extension() != "json" or file_name.ends_with("_clusters.json"):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ZONE_DIR + file_name))
		if not (parsed is Dictionary):
			continue
		var zone: String = str((parsed as Dictionary).get("zone", file_name.get_basename()))
		var ids_of_zone: Array[String] = []
		for key: Variant in ((parsed as Dictionary).get("items", {}) as Dictionary).keys():
			var entry: Dictionary = ((parsed as Dictionary)["items"] as Dictionary)[key] as Dictionary
			entry["zone"] = str(entry.get("zone", zone))
			_zone_entries[str(key)] = entry
			ids_of_zone.append(str(key))
		_zone_order[zone] = ids_of_zone


## The ids of one zone kit (data/art/zone_kits/<zone>.json), sheet order of the registry.
static func zone_ids(zone: String) -> Array[String]:
	_load()
	var result: Array[String] = []
	result.assign(_zone_order.get(zone, []) as Array)
	return result


## The zone a kit id belongs to ("" for the shared Environment Kit).
static func zone_of(id: String) -> String:
	_load()
	return str((_zone_entries.get(id, {}) as Dictionary).get("zone", ""))


## The prep numbers of `id` (trimmed size, pivot, tile, aspect): the env kit's prep file, or the zone entry itself.
static func _info(id: String) -> Dictionary:
	_load()
	if _zone_entries.has(id):
		return _zone_entries[id] as Dictionary
	return _prep.get(id, {}) as Dictionary


static func ids() -> Array[String]:
	_load()
	return _order.duplicate()


static func has(id: String) -> bool:
	_load()
	return _entries.has(id) or _zone_entries.has(id)


static func entry(id: String) -> Dictionary:
	_load()
	if _entries.has(id):
		return _entries[id] as Dictionary
	return _zone_entries.get(id, {}) as Dictionary


## The slot name of `id` ("wall.main", "door.a" ...), "" for an unknown id.
static func slot(id: String) -> String:
	return str(entry(id).get("slot", ""))


static func tile_size(id: String) -> float:
	var info: Dictionary = _info(id)
	if has_art(id) and info.has("tile_u"):
		return float(info["tile_u"])
	return float(entry(id).get("tile", 2.0))


## The vertical tile size in metres (a 1024x512 band is half as tall as it is wide at the one shared texel density).
static func tile_size_v(id: String) -> float:
	var info: Dictionary = _info(id)
	if has_art(id) and info.has("tile_v"):
		return float(info["tile_v"])
	return tile_size(id)


## Pivot of a prepared cut-out (0..1 of the trimmed image: doors / windows bottom centre, signs at their wall bracket, trees at the trunk base).
static func pivot(id: String) -> Vector2:
	var raw: Array = _info(id).get("pivot", [0.5, 1.0]) as Array
	return Vector2(float(raw[0]), float(raw[1]))


## Width / height of the trimmed art (1.0 for a placeholder).
static func aspect(id: String) -> float:
	var info: Dictionary = _info(id)
	if has_art(id) and info.has("aspect"):
		return float(info["aspect"])
	var px: Array = info.get("px", [1, 1]) as Array
	return float(px[0]) / maxf(float(px[1]), 1.0) if has_art(id) else 1.0


## The sibling map `<ID>_n` / `<ID>_r` of a real surface, or null.
static func map_texture(id: String, suffix: String) -> Texture2D:
	var path: String = art_path(id)
	if path == "" or not (path.begins_with(ART_DIR) or path.begins_with(ZONE_ART_DIR)):
		return null
	var map_path: String = path.get_basename() + "_" + suffix + ".webp"
	return load(map_path) as Texture2D if ResourceLoader.exists(map_path) else null


## The path of the real art file of `id`, or "" while it is still a placeholder.
static func art_path(id: String) -> String:
	_load()
	if _zone_entries.has(id):
		var zone_path: String = "%s%s/%s.webp" % [ZONE_ART_DIR, str((_zone_entries[id] as Dictionary).get("zone", "")), id]
		return zone_path if ResourceLoader.exists(zone_path) else ""
	var dir: String = OS.get_environment("ENV_KIT_ART_DIR")
	if dir == "":
		dir = ART_DIR
	if not dir.ends_with("/"):
		dir += "/"
	for ext: String in ["webp", "png"]:
		var path: String = "%s%s.%s" % [dir, id, ext]
		if dir == ART_DIR:
			if ResourceLoader.exists(path):
				return path
		elif FileAccess.file_exists(ProjectSettings.globalize_path(path)):
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
		if path.begins_with(ART_DIR) or path.begins_with(ZONE_ART_DIR):
			return load(path) as Texture2D
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
		if image != null and not image.is_empty():
			image.generate_mipmaps()
			return ImageTexture.create_from_image(image)
		return null
	var placeholder: String = str(entry(id).get("placeholder", ""))
	if placeholder.begins_with("tex:"):
		return PaintedLibrary.albedo(placeholder.trim_prefix("tex:"))
	if placeholder.begins_with("dec:"):
		return PaintedLibrary.decal(placeholder.trim_prefix("dec:"))
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
	# Layer 2 of the Art Bible (G-08): the zone swaps a kit surface for another and tints neutral textures from its palette.
	id = ZoneStyles.swap(id)
	# A zone's own kit art is painted in the zone's palette already: no palette tint on top (the registry says `tinted: false`).
	var zone_tint: Color = ZoneStyles.tint(tint_group(id)) if bool(entry(id).get("tinted", true)) else Color.WHITE
	var key: String = "%s|%s|%s|%s" % [id, str(cut), mul.to_html(), zone_tint.to_html()]
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D
	var material_value: StandardMaterial3D = StandardMaterial3D.new()
	material_value.resource_name = id
	var texture_value: Texture2D = texture(id)
	if texture_value != null:
		material_value.albedo_texture = texture_value
	var real: bool = has_art(id)
	# A real painted asset keeps its own colours; only the placeholders are tinted.
	var base_color: Color = (Color.WHITE if real else tint(id)) * mul
	material_value.albedo_color = base_color * zone_tint
	material_value.set_meta(&"zone_base", base_color)
	material_value.set_meta(&"zone_group", tint_group(id))
	material_value.set_meta(&"zone_key", "%s|%s|%s" % [id, str(cut), mul.to_html()])
	material_value.roughness = 1.0
	material_value.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	# Vertex colours carry the baked ambient occlusion of the kit meshes (KitMesh).
	material_value.vertex_color_use_as_albedo = true
	var tile: float = tile_size(id)
	var tile_v: float = tile_size_v(id)
	if not cut and tile > 0.0:
		# Kit meshes carry UVs in metres, so one texture repeat covers `tile` metres.
		material_value.uv1_scale = Vector3(1.0 / tile, 1.0 / tile_v, 1.0)
		var normal_map: Texture2D = map_texture(id, "n")
		if normal_map != null:
			material_value.normal_enabled = true
			material_value.normal_texture = normal_map
			material_value.normal_scale = 0.7
		var rough_map: Texture2D = map_texture(id, "r")
		if rough_map != null:
			material_value.roughness_texture = rough_map
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
	_prep.clear()
	_zone_entries.clear()
	_zone_order.clear()
	KitTextures.clear()
	_loaded = false
	_entries.clear()
	_order.clear()


## A material whose UVs are 0..1 over the whole image (one face of a crate, one wrap of a barrel): for props that are modelled with `fit_uv` and not tiled.
static func fitted(id: String, mul: Color = Color.WHITE) -> StandardMaterial3D:
	var key: String = "fit|%s|%s|%s" % [id, mul.to_html(), ZoneStyles.current]
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D
	var material_value: StandardMaterial3D = material(id, false, mul).duplicate() as StandardMaterial3D
	material_value.uv1_scale = Vector3.ONE
	material_value.texture_repeat = false
	material_value.set_meta(&"zone_key", "fit|%s|%s|%s" % [id, mul.to_html(), ZoneStyles.current])
	material_value.set_meta(PaintedClasses.META_NO_PAINT, true)
	_materials[key] = material_value
	return material_value


## The tint key of `id`: its slot's family ("awning" of "awning.a") when the style names it, else the sheet group ("trim", "wall"...).
static func tint_group(id: String) -> String:
	var slot_name: String = slot(id)
	var family: String = slot_name.get_slice(".", 0)
	var tints: Dictionary = ZoneStyles.style(ZoneStyles.current).get("tints", {}) as Dictionary
	if family != "" and tints.has(family):
		return family
	return str(entry(id).get("group", family))


## Re-tints every cached kit material for the current area (hot reload of a style file; no scene rebuild needed).
static func retint() -> void:
	var fresh: Dictionary = {}
	for key: Variant in _materials.keys():
		var m: StandardMaterial3D = _materials[key] as StandardMaterial3D
		if m == null or not m.has_meta(&"zone_group"):
			fresh[key] = _materials[key]
			continue
		var tint_now: Color = ZoneStyles.tint(str(m.get_meta(&"zone_group")))
		m.albedo_color = (m.get_meta(&"zone_base") as Color) * tint_now
		fresh["%s|%s" % [str(m.get_meta(&"zone_key")), tint_now.to_html()]] = m
	_materials = fresh
