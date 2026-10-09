class_name PaintedFlow
extends RefCounted
## Painted liquid with a gentle animated flow (docs/art/style_guide.md, "Painted textures"): the Buffet's gravy (TEX-BUFF-GRAVY). Null when the texture is missing.

const SHADER_PATH: String = "res://assets/shaders/style_painted_flow.gdshader"

static var _shader: Shader


static func material(texture_name: String, flow_dir: Vector2 = Vector2(1.0, 0.0), speed: float = 0.18, tile: float = 5.0, tint: Color = Color.WHITE, alpha: float = 0.95) -> ShaderMaterial:
	var texture: Texture2D = PaintedLibrary.albedo(texture_name)
	if texture == null:
		return null
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var result: ShaderMaterial = ShaderMaterial.new()
	result.shader = _shader
	result.set_shader_parameter("liquid_tex", texture)
	result.set_shader_parameter("flow_dir", flow_dir)
	result.set_shader_parameter("flow_speed", speed)
	result.set_shader_parameter("tile", tile)
	result.set_shader_parameter("tint", tint)
	result.set_shader_parameter("alpha", alpha)
	return result
