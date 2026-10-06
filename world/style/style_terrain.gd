class_name StyleTerrain
extends RefCounted
## The shared painted-terrain material (`assets/shaders/style_terrain.gdshader`) for the zones that build vertex-coloured ground (Gainlands, Buffet, Dump):
## world-space value/tint patches, brush grain, optional mowed stripes, flattened normals so the triangles stop showing. One cached material per setup.

const SHADER_PATH: String = "res://assets/shaders/style_terrain.gdshader"

static var _shader: Shader
static var _cache: Dictionary = {}


## `macro`: strength of the value patches; `stripes`: mowed-stripe contrast (0 = none); `grain`: brush grain.
static func material(macro: float = 0.12, stripes: float = 0.0, grain: float = 0.05, flatten: float = 0.8) -> ShaderMaterial:
	var key: String = "%s|%s|%s|%s" % [macro, stripes, grain, flatten]
	if _cache.has(key):
		return _cache[key] as ShaderMaterial
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var result: ShaderMaterial = ShaderMaterial.new()
	result.shader = _shader
	result.set_shader_parameter("macro_amount", macro)
	result.set_shader_parameter("stripe_amount", stripes)
	result.set_shader_parameter("grain_amount", grain)
	result.set_shader_parameter("flatten", flatten)
	_cache[key] = result
	return result
