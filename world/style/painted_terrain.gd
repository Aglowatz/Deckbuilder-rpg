class_name PaintedTerrain
extends RefCounted
## Builds the reusable painted-terrain material (`assets/shaders/style_painted_terrain.gdshader`) from a zone preset in data/art/texture_presets.json (docs/art/style_guide.md).
## Layer fields: tex, tile (metres per repeat), mode = base | key | noise | mask, plus per mode: key (hex) + radius + soft (key), scale + threshold + seed + soft (noise),
## mask (name of a mask Callable(Vector2 xz) -> 0..1 supplied by the scene, painted into a splat texture) + soft (mask); `warp` roughens the mask edge, `ref` + `keep` keep the
## builder's own hue as a tint. A zone that cannot be painted (missing base texture) returns null and keeps its flat look.

const SHADER_PATH: String = "res://assets/shaders/style_painted_terrain.gdshader"
const MAX_LAYERS: int = 5
const MODES: Dictionary = {"base": 0, "key": 1, "noise": 2, "mask": 3}

static var _shader: Shader


static func shader() -> Shader:
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	return _shader


## `context`: {"masks": {name: Callable}, "bounds": Rect2 (x/z area the masks cover), "overrides": {param: value}}.
static func material(preset: Dictionary, context: Dictionary = {}) -> ShaderMaterial:
	var layers: Array = preset.get("layers", []) as Array
	if layers.is_empty():
		return null
	var result: ShaderMaterial = ShaderMaterial.new()
	result.shader = shader()
	result.set_shader_parameter("noise_tex", PaintedLibrary.noise())
	var modes: PackedVector4Array = PackedVector4Array()
	var keys: PackedVector4Array = PackedVector4Array()
	var noises: PackedVector4Array = PackedVector4Array()
	var refs: PackedVector4Array = PackedVector4Array()
	var tiles: PackedFloat32Array = PackedFloat32Array()
	var count: int = 0
	var masks: Dictionary = context.get("masks", {}) as Dictionary
	var mask_callables: Array[Callable] = []
	for entry: Variant in layers:
		var layer: Dictionary = entry as Dictionary
		if count >= MAX_LAYERS:
			break
		var albedo: Texture2D = PaintedLibrary.albedo(str(layer["tex"]))
		if albedo == null:
			if count == 0:
				return null
			continue
		var mode_name: String = str(layer.get("mode", "base" if count == 0 else "noise"))
		if mode_name == "mask" and not masks.has(str(layer.get("mask", ""))):
			continue
		var mode: int = int(MODES.get(mode_name, 0))
		var slot: String = "l%d" % count
		result.set_shader_parameter("%s_a" % slot, albedo)
		var nr: Texture2D = PaintedLibrary.normal_rough(str(layer["tex"]))
		result.set_shader_parameter("%s_n" % slot, nr if nr != null else PaintedLibrary.flat_nr())
		var key: Color = PaintedLibrary.linear(PaintedLibrary.color_of(layer.get("key", "#000000")))
		var mask_channel: int = 0
		if mode == 3:
			mask_callables.append(masks[str(layer["mask"])] as Callable)
			mask_channel = mask_callables.size() - 1
		modes.append(Vector4(float(mode), float(mask_channel), float(layer.get("soft", 0.15)), float(layer.get("warp", 0.0))))
		keys.append(Vector4(key.r, key.g, key.b, float(layer.get("radius", 0.2))))
		noises.append(Vector4(float(layer.get("scale", 0.075)), float(layer.get("threshold", 0.55)), float(layer.get("seed", 3.0)), float(layer.get("bright", 1.0))))
		var ref_value: Variant = layer.get("ref", layer.get("key", "#ffffff"))
		var ref: Color = PaintedLibrary.linear(PaintedLibrary.color_of(ref_value))
		refs.append(Vector4(ref.r, ref.g, ref.b, float(layer.get("keep", 0.0))))
		tiles.append(float(layer.get("tile", 6.0)))
		count += 1
	# Splat channel k of the mask texture belongs to the k-th mask layer; the shader reads channel (layer index - 1), so mask layers are remapped to their layer index.
	while modes.size() < MAX_LAYERS:
		modes.append(Vector4.ZERO)
		keys.append(Vector4.ZERO)
		noises.append(Vector4(0, 0, 0, 1))
		refs.append(Vector4(1, 1, 1, 0))
		tiles.append(6.0)
	for slot_index: int in range(count, MAX_LAYERS):
		result.set_shader_parameter("l%d_a" % slot_index, PaintedLibrary.white())
		result.set_shader_parameter("l%d_n" % slot_index, PaintedLibrary.flat_nr())
	result.set_shader_parameter("layer_count", count)
	result.set_shader_parameter("layer_mode", modes)
	result.set_shader_parameter("layer_key", keys)
	result.set_shader_parameter("layer_noise", noises)
	result.set_shader_parameter("layer_ref", refs)
	result.set_shader_parameter("layer_tile", tiles)
	var cliff: Dictionary = preset.get("cliff", {}) as Dictionary
	var cliff_texture: Texture2D = PaintedLibrary.albedo(str(cliff.get("tex", "mat_rock"))) if not cliff.is_empty() else null
	result.set_shader_parameter("cliff_a", cliff_texture if cliff_texture != null else PaintedLibrary.white())
	result.set_shader_parameter("cliff_tile", float(cliff.get("tile", 4.0)))
	result.set_shader_parameter("cliff_tint", PaintedLibrary.color_of(cliff.get("tint", "#ffffff")))
	result.set_shader_parameter("cliff_keep", float(cliff.get("keep", 0.25)))
	for param: String in ["macro", "tint", "brightness", "normal", "sheen", "flatten", "grain", "flow", "normal_far", "stochastic_far", "far_start", "far_end"]:
		if preset.has(param):
			var shader_name: String = {"macro": "macro_amount", "tint": "tint_amount", "normal": "normal_strength", "grain": "brush_grain", "flow": "flow_speed", "far_start": "far_blend_start", "far_end": "far_blend_end"}.get(param, param) as String
			result.set_shader_parameter(shader_name, float(preset[param]))
	if preset.has("color"):
		var mul: Color = PaintedLibrary.color_of(preset["color"])
		result.set_shader_parameter("color_mul", Vector3(mul.r, mul.g, mul.b))
	var overrides: Dictionary = context.get("overrides", {}) as Dictionary
	for param: String in overrides.keys():
		result.set_shader_parameter(param, overrides[param])
	_paint_splat(result, mask_callables, context.get("bounds", Rect2(-50, -50, 100, 100)) as Rect2, layers, count, modes)
	return result


## Paints the named masks into an RGBA splat texture (channel = layer index - 1) covering `bounds`.
static func _paint_splat(result: ShaderMaterial, callables: Array[Callable], bounds: Rect2, _layers: Array, count: int, modes: PackedVector4Array) -> void:
	if callables.is_empty():
		result.set_shader_parameter("splat", PaintedLibrary.white())
		return
	var step: float = maxf(0.5, maxf(bounds.size.x, bounds.size.y) / 256.0)
	var width: int = int(ceil(bounds.size.x / step))
	var height: int = int(ceil(bounds.size.y / step))
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	var by_channel: Dictionary = {}
	for layer_index: int in range(1, count):
		if int(modes[layer_index].x) == 3 and layer_index - 1 < 4:
			by_channel[layer_index - 1] = callables[int(modes[layer_index].y)]
			# The shader reads the splat channel of layer i as (i - 1).
	for y: int in range(height):
		for x: int in range(width):
			var p: Vector2 = bounds.position + Vector2((float(x) + 0.5) * step, (float(y) + 0.5) * step)
			var color: Color = Color(0, 0, 0, 0)
			for channel: int in by_channel.keys():
				var value: float = clampf(float((by_channel[channel] as Callable).call(p)), 0.0, 1.0)
				match channel:
					0:
						color.r = value
					1:
						color.g = value
					2:
						color.b = value
					_:
						color.a = value
			image.set_pixel(x, y, color)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	result.set_shader_parameter("splat", texture)
	result.set_shader_parameter("has_splat", true)
	result.set_shader_parameter("splat_rect", Vector4(bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y))
