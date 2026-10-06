class_name BuffetMaterials
extends RefCounted
## The Endless Buffet's shared palette: every procedural prop, the terrain and the golems draw from these few
## flat-shaded materials so the zone reads as one warm, saturated, appetizing low-poly family alongside the
## Kenney Food Kit and KayKit Restaurant Bits models. Cached; never create one-off materials in the builders.

static var _cache: Dictionary = {}

const CREAM: Color = Color(0.9, 0.78, 0.5)
const CREAM_SHADE: Color = Color(0.82, 0.64, 0.38)
const BUTTER: Color = Color(1.0, 0.89, 0.38)
const GRAVY: Color = Color(0.52, 0.27, 0.1)
const GRAVY_DEEP: Color = Color(0.34, 0.17, 0.07)
const LETTUCE: Color = Color(0.45, 0.76, 0.3)
const BROCCOLI: Color = Color(0.3, 0.62, 0.2)
const PANCAKE: Color = Color(0.9, 0.64, 0.32)
const PANCAKE_DARK: Color = Color(0.72, 0.46, 0.2)
const CHEESE: Color = Color(1.0, 0.82, 0.25)
const CHEESE_DARK: Color = Color(0.9, 0.62, 0.12)
const PINK: Color = Color(1.0, 0.62, 0.78)
const MINT: Color = Color(0.62, 0.98, 0.78)
const VANILLA: Color = Color(1.0, 0.96, 0.82)
const CHOCOLATE: Color = Color(0.4, 0.23, 0.14)
const STEEL: Color = Color(0.82, 0.85, 0.9)
const COPPER: Color = Color(0.9, 0.52, 0.26)
const BRICK: Color = Color(0.78, 0.36, 0.26)
const TOAST: Color = Color(0.92, 0.7, 0.36)
const TOAST_DARK: Color = Color(0.74, 0.5, 0.2)
const CLOTH_RED: Color = Color(0.92, 0.22, 0.24)
const WOOD: Color = Color(0.66, 0.44, 0.25)
const WOOD_DARK: Color = Color(0.42, 0.27, 0.15)
const MEAT: Color = Color(0.62, 0.3, 0.2)
const JELLY_RED: Color = Color(1.0, 0.3, 0.45)
const SYRUP: Color = Color(0.7, 0.36, 0.1)


static func flat(color: Color, roughness: float = 0.9) -> StandardMaterial3D:
	var key: String = "flat:%s:%s" % [color.to_html(), roughness]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = roughness
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


static func shiny(color: Color, roughness: float = 0.25) -> StandardMaterial3D:
	var key: String = "shiny:%s:%s" % [color.to_html(), roughness]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = roughness
		material.metallic = 0.2
		material.metallic_specular = 0.8
		material.set_meta(StyleToon.META_GLOSS, 0.45)
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


static func glow(color: Color, energy: float = 1.6) -> StandardMaterial3D:
	var key: String = "glow:%s:%s" % [color.to_html(), energy]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = energy
		material.roughness = 0.4
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


static func translucent(color: Color, alpha: float, energy: float = 0.4, roughness: float = 0.15) -> StandardMaterial3D:
	var key: String = "tr:%s:%s:%s:%s" % [color.to_html(), alpha, energy, roughness]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(color.r, color.g, color.b, alpha)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.emission_enabled = energy > 0.0
		material.emission = color
		material.emission_energy_multiplier = energy
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.roughness = roughness
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


## Vertex-coloured, double-sided terrain material (the colours are painted per triangle).
static func terrain() -> Material:
	return StyleTerrain.material(0.1, 0.0)


## The gravy: a glossy, slightly glowing brown that reads as hot soup.
static func soup(color: Color = GRAVY) -> StandardMaterial3D:
	var key: String = "soup:%s" % color.to_html()
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(color.r, color.g, color.b, 0.93)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.roughness = 0.12
		material.metallic = 0.15
		material.metallic_specular = 0.9
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 0.18
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


## A big red-and-white gingham tablecloth far below the table (the void under the zone).
static func tablecloth() -> StandardMaterial3D:
	if not _cache.has("tablecloth"):
		var image: Image = Image.create(64, 64, false, Image.FORMAT_RGB8)
		for y: int in range(64):
			for x: int in range(64):
				var stripe_x: bool = (x / 16) % 2 == 0
				var stripe_y: bool = (y / 16) % 2 == 0
				var color: Color = Color(1.0, 0.96, 0.92)
				if stripe_x and stripe_y:
					color = Color(0.86, 0.14, 0.2)
				elif stripe_x or stripe_y:
					color = Color(0.98, 0.62, 0.64)
				image.set_pixel(x, y, color)
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_texture = ImageTexture.create_from_image(image)
		material.uv1_scale = Vector3(30.0, 30.0, 1.0)
		material.texture_repeat = true
		material.roughness = 1.0
		_cache["tablecloth"] = material
	return _cache["tablecloth"] as StandardMaterial3D
