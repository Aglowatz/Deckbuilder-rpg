class_name StyleWater
extends RefCounted
## The shared toon water (`assets/shaders/style_water.gdshader`): one cached ShaderMaterial per colour pair, used by the hex water tiles (town lake, ocean, battle
## backdrop) and any other water surface. Quality: Low drops the depth-texture read (no real shoreline foam, a noise-based fake instead).

const SHADER_PATH: String = "res://assets/shaders/style_water.gdshader"

static var _shader: Shader
static var _cache: Dictionary = {}


## The water material; `shallow` / `deep` tint the gradient.
static func material(shallow: Color = Color("5cc8e6"), deep: Color = Color("1f72c4")) -> ShaderMaterial:
	var key: String = "%s|%s|%d" % [shallow.to_html(), deep.to_html(), Settings.graphics_quality]
	if _cache.has(key):
		return _cache[key] as ShaderMaterial
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var result: ShaderMaterial = ShaderMaterial.new()
	result.shader = _shader
	result.set_shader_parameter("shallow_color", shallow)
	result.set_shader_parameter("deep_color", deep)
	result.set_shader_parameter("use_depth", Settings.graphics_quality >= GraphicsQuality.Level.MEDIUM)
	# Graphics Tier 2: the bed shows through the shallows with a gentle wobble (the screen copy + a depth read: Medium and up, never on Low).
	result.set_shader_parameter("use_refraction", GraphicsQuality.water_refraction(Settings.graphics_quality))
	result.set_shader_parameter("sparkle_amount", 0.0 if Settings.graphics_quality == GraphicsQuality.Level.LOW else 1.0)
	_cache[key] = result
	return result


## A copy of the toon water with a painted surface layer (texture_id, a kit or zone-kit surface) under it; the plain material when the art is missing.
static func painted(texture_id: String, shallow: Color, deep: Color, tile: float = 6.0, amount: float = 0.6) -> ShaderMaterial:
	var base: ShaderMaterial = material(shallow, deep)
	if not EnvKit.has_art(texture_id):
		return base
	var key: String = "%s|paint:%s" % [base.get_instance_id(), texture_id]
	if _cache.has(key):
		return _cache[key] as ShaderMaterial
	var result: ShaderMaterial = base.duplicate() as ShaderMaterial
	result.set_shader_parameter("paint_tex", EnvKit.texture(texture_id))
	result.set_shader_parameter("use_paint", true)
	result.set_shader_parameter("paint_tile", tile)
	result.set_shader_parameter("paint_amount", amount)
	_cache[key] = result
	return result


## Replaces every surface material under `node` with the toon water.
static func apply(node: Node, shallow: Color = Color("5cc8e6"), deep: Color = Color("1f72c4")) -> void:
	var water: ShaderMaterial = material(shallow, deep)
	for child: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		mesh_instance.material_override = water
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh_instance.set_meta(StyleToon.META_NO_TOON, true)
