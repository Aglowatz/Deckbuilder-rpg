class_name PaintedLibrary
extends RefCounted
## The painted texture system's shared state (docs/art/style_guide.md, "Painted textures"): loads the imported textures/decals by name (a missing one is reported and falls back
## to the current flat look), reads the per-zone presets from data/art/texture_presets.json, builds the shared material texture array used by the building/prop materials,
## and holds the global on/off switch (debug toggle: `set_enabled`, shader global `style_paint`).

const TEXTURES: String = "res://assets/art/textures/"
const DECALS: String = "res://assets/art/decals/"
const PRESETS_PATH: String = "res://data/art/texture_presets.json"
const ARRAY_SIZE: int = 512
## Layers darker than this average luminance are lifted towards it (max x1.8).
const LUMA_TARGET: float = 0.4

## Order of the layers in the shared material array (a `layer` index in the shaders). The first twelve are the TEX-MAT set; the rest are zone-specific prop materials.
const MATERIAL_LAYERS: Array[String] = [
	"mat_woodplanks", "mat_timber", "mat_stonewall", "mat_brick", "mat_plaster", "mat_roof_red", "mat_roof_blue", "mat_thatch", "mat_metal", "mat_rock", "mat_bark", "mat_leaves",
	"dump_rustmetal", "cap_whitewall", "dna_paneling", "dna_wallpaper", "buff_frosting", "buff_cheese", "gain_islandrock", "gain_gymmat",
]

static var enabled: bool = true
static var missing: Dictionary = {}
static var used: Dictionary = {}
static var _textures: Dictionary = {}
static var _presets: Dictionary = {}
static var _array: Texture2DArray
static var _loaded_presets: bool = false


static func set_enabled(value: bool) -> void:
	enabled = value
	RenderingServer.global_shader_parameter_set("style_paint", 1.0 if value else 0.0)


## The albedo texture of `name` (e.g. "town_grass"), or null (reported once in `missing`).
static func albedo(name: String) -> Texture2D:
	return _load("%s%s_albedo.webp" % [TEXTURES, name], name)


## The normal(RG)+roughness(B) pack of `name`, or null.
static func normal_rough(name: String) -> Texture2D:
	return _load("%s%s_nr.webp" % [TEXTURES, name], name)


static func decal(name: String) -> Texture2D:
	return _load("%s%s.webp" % [DECALS, name], "decal:%s" % name)


static func _load(path: String, key: String) -> Texture2D:
	if _textures.has(path):
		return _textures[path] as Texture2D
	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	if texture == null:
		if not missing.has(key):
			missing[key] = true
			push_warning("PaintedLibrary: missing texture %s (falls back to the flat look)" % key)
	else:
		used[key.trim_prefix("decal:")] = true
	_textures[path] = texture
	return texture


## A white 4x4 stand-in so a layer slot is never an unbound sampler.
static func white() -> Texture2D:
	if not _textures.has("white"):
		var image: Image = Image.create(4, 4, false, Image.FORMAT_RGB8)
		image.fill(Color(0.5, 0.5, 0.5))
		_textures["white"] = ImageTexture.create_from_image(image)
	return _textures["white"] as Texture2D


## A flat normal+roughness stand-in.
static func flat_nr() -> Texture2D:
	if not _textures.has("flat_nr"):
		var image: Image = Image.create(4, 4, false, Image.FORMAT_RGB8)
		image.fill(Color(0.5, 0.5, 0.9))
		_textures["flat_nr"] = ImageTexture.create_from_image(image)
	return _textures["flat_nr"] as Texture2D


static func layer_index(name: String) -> int:
	return MATERIAL_LAYERS.find(name)


## The shared material texture array (every entry of MATERIAL_LAYERS, 512 px, mip-mapped); a texture that is missing is a neutral gray layer.
static func material_array() -> Texture2DArray:
	if _array != null:
		return _array
	var images: Array[Image] = []
	for name: String in MATERIAL_LAYERS:
		var source: Texture2D = albedo(name)
		var image: Image = null
		if source != null:
			image = source.get_image()
			if image.is_compressed():
				image.decompress()
			image.convert(Image.FORMAT_RGBA8)
			image.resize(ARRAY_SIZE, ARRAY_SIZE, Image.INTERPOLATE_BILINEAR)
			# Dark materials (timber, slate, paneling) are lifted a little: under the toon bands they otherwise swallow the hue of the building they sit on.
			var average: float = 0.0
			for y: int in range(0, ARRAY_SIZE, 16):
				for x: int in range(0, ARRAY_SIZE, 16):
					average += image.get_pixel(x, y).get_luminance()
			average /= float((ARRAY_SIZE / 16) * (ARRAY_SIZE / 16))
			var gain: float = clampf(LUMA_TARGET / maxf(average, 0.02), 1.0, 1.8)
			if gain > 1.01:
				image.adjust_bcs(gain, 1.0, 1.0)
			if OS.get_environment("PAINT_DEBUG") != "":
				print("material layer %s: average luminance %.2f gain %.2f" % [name, average, gain])
		else:
			image = Image.create(ARRAY_SIZE, ARRAY_SIZE, false, Image.FORMAT_RGBA8)
			image.fill(Color(0.5, 0.5, 0.5))
		image.generate_mipmaps()
		images.append(image)
	_array = Texture2DArray.new()
	_array.create_from_images(images)
	return _array


# ---- Presets ----------------------------------------------------------------------------------------------


## The preset dictionary of a style preset id (StylePresets.TOWN ...); {} when the zone has none (it keeps its flat look).
static func preset(id: StringName) -> Dictionary:
	if not _loaded_presets:
		_loaded_presets = true
		var file: FileAccess = FileAccess.open(PRESETS_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_presets = parsed as Dictionary
	var entry: Variant = _presets.get(str(id), {})
	if entry is Dictionary and (entry as Dictionary).has("inherit"):
		var merged: Dictionary = preset(StringName(str((entry as Dictionary)["inherit"]))).duplicate(true)
		merged.merge(entry as Dictionary, true)
		return merged
	return entry as Dictionary if entry is Dictionary else {}


static func color_of(value: Variant, fallback: Color = Color.WHITE) -> Color:
	if value is String:
		return Color.html(str(value))
	if value is Array and (value as Array).size() >= 3:
		return Color(float((value as Array)[0]), float((value as Array)[1]), float((value as Array)[2]))
	return fallback


## sRGB colour to the linear value the shaders compare against.
static func linear(color: Color) -> Color:
	return color.srgb_to_linear()


static func reset_for_tests() -> void:
	_textures.clear()
	_presets.clear()
	_loaded_presets = false
	missing.clear()
	used.clear()
	_array = null
	enabled = true


## A 64x64 lattice of random values (seeded, so every run paints the same ground): the terrain shader's one-tap value noise.
static func noise() -> Texture2D:
	if not _textures.has("noise"):
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 20261009
		var image: Image = Image.create(64, 64, false, Image.FORMAT_L8)
		for y: int in range(64):
			for x: int in range(64):
				var value: float = rng.randf()
				image.set_pixel(x, y, Color(value, value, value))
		_textures["noise"] = ImageTexture.create_from_image(image)
	return _textures["noise"] as Texture2D
