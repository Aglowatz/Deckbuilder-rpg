class_name PaintedTriplanar
extends RefCounted
## Triplanar painted materials for surfaces without good UVs (docs/art/style_guide.md, "Painted textures"): cliffs and boulders (TEX-MAT-ROCK), floating-island undersides
## (TEX-GAIN-ISLANDROCK), cheese (TEX-BUFF-CHEESE), rusted junk (TEX-DUMP-RUSTMETAL). `material` returns null when the texture is missing (the caller keeps its flat material).

const SHADER_PATH: String = "res://assets/shaders/style_painted_triplanar.gdshader"

static var _shader: Shader
static var _cache: Dictionary = {}


## `flat_color`: the flat colour the surface had (it stays as a subtle hue when `keep_hue` > 0 and is what the debug toggle shows when painted textures are off).
static func material(texture_name: String, tile: float = 4.0, flat_color: Color = Color(0.6, 0.6, 0.6), keep_hue: float = 0.3, tint: Color = Color.WHITE, gloss: float = 0.0) -> ShaderMaterial:
	var key: String = "%s|%s|%s|%s|%s|%s" % [texture_name, tile, flat_color.to_html(), keep_hue, tint.to_html(), gloss]
	if _cache.has(key):
		return _cache[key] as ShaderMaterial
	var texture: Texture2D = PaintedLibrary.albedo(texture_name)
	if texture == null:
		return null
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var result: ShaderMaterial = ShaderMaterial.new()
	result.shader = _shader
	result.set_shader_parameter("albedo_tex", texture)
	result.set_shader_parameter("flat_tex", texture)
	result.set_shader_parameter("tile", tile)
	result.set_shader_parameter("flat_color", flat_color)
	result.set_shader_parameter("keep_hue", keep_hue)
	result.set_shader_parameter("tint", tint)
	result.set_shader_parameter("gloss", gloss)
	_cache[key] = result
	return result


static func clear_cache() -> void:
	_cache.clear()


## A two-band wall (the D.N.A.): `lower` below `split_y`, `upper` above it, a thin trim strip between and a plain cap on top faces. Null when a texture is missing.
static func wall_material(lower: String, upper: String, tile: float, split_y: float, trim: Color, cap: Color, brightness: float = 1.0) -> ShaderMaterial:
	var key: String = "wall|%s|%s|%s|%s|%s|%s|%s" % [lower, upper, tile, split_y, trim.to_html(), cap.to_html(), brightness]
	if _cache.has(key):
		return _cache[key] as ShaderMaterial
	var lower_texture: Texture2D = PaintedLibrary.albedo(lower)
	var upper_texture: Texture2D = PaintedLibrary.albedo(upper)
	if lower_texture == null or upper_texture == null:
		return null
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var result: ShaderMaterial = ShaderMaterial.new()
	result.shader = _shader
	result.set_shader_parameter("albedo_tex", lower_texture)
	result.set_shader_parameter("flat_tex", lower_texture)
	result.set_shader_parameter("upper_tex", upper_texture)
	result.set_shader_parameter("use_split", true)
	result.set_shader_parameter("tile", tile)
	result.set_shader_parameter("split_y", split_y)
	result.set_shader_parameter("trim_color", trim)
	result.set_shader_parameter("cap_color", cap)
	result.set_shader_parameter("brightness", brightness)
	_cache[key] = result
	return result
