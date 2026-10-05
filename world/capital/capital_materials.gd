class_name CapitalMaterials
extends RefCounted
## The Capital's palette and cached materials. Two moods side by side: the facade is spotless (warm white, saturated artificial
## green, regulation red roofs, polished gold) and everything outside it is gray, cracked and wrong (cold stone, soot, dead
## brick, rift violet). Materials are cached so thousands of props share a handful.

const WHITE: Color = Color(0.96, 0.95, 0.92)
const ROOF_RED: Color = Color(0.82, 0.22, 0.24)
const LAWN_GREEN: Color = Color(0.3, 0.8, 0.28)
const PLAZA_STONE: Color = Color(0.82, 0.8, 0.74)
const GOLD: Color = Color(0.96, 0.78, 0.22)
const STONE_GRAY: Color = Color(0.46, 0.46, 0.52)
const STONE_DARK: Color = Color(0.26, 0.26, 0.31)
const BRICK_DEAD: Color = Color(0.42, 0.3, 0.28)
const SOOT: Color = Color(0.12, 0.12, 0.14)
const ROAD: Color = Color(0.36, 0.36, 0.4)
const GRAVEL: Color = Color(0.5, 0.47, 0.42)
const SOIL: Color = Color(0.36, 0.3, 0.24)
const METAL: Color = Color(0.5, 0.52, 0.56)
const TILE_A: Color = Color(0.6, 0.58, 0.54)
const TILE_B: Color = Color(0.45, 0.44, 0.42)
const HUB_WOOD: Color = Color(0.4, 0.28, 0.2)
const RIFT_VIOLET: Color = Color(0.72, 0.3, 1.0)
const RIFT_CYAN: Color = Color(0.4, 0.95, 1.0)
const WOOD: Color = Color(0.5, 0.34, 0.2)
const WOOD_DARK: Color = Color(0.32, 0.21, 0.12)
const PAPER: Color = Color(0.96, 0.92, 0.8)
const LANTERN: Color = Color(1.0, 0.78, 0.4)

static var _cache: Dictionary = {}


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
		material.metallic = 0.45
		material.metallic_specular = 0.8
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


static func glow(color: Color, energy: float = 1.8) -> StandardMaterial3D:
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


static func translucent(color: Color, alpha: float, energy: float = 0.5) -> StandardMaterial3D:
	var key: String = "tr:%s:%s:%s" % [color.to_html(), alpha, energy]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(color.r, color.g, color.b, alpha)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.emission_enabled = energy > 0.0
		material.emission = color
		material.emission_energy_multiplier = energy
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.roughness = 0.2
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


## Per-vertex-coloured terrain.
static func terrain() -> StandardMaterial3D:
	if not _cache.has("terrain"):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.vertex_color_use_as_albedo = true
		material.vertex_color_is_srgb = true
		material.roughness = 0.92
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_cache["terrain"] = material
	return _cache["terrain"] as StandardMaterial3D


## A material whose colour comes from the instance colour (MultiMesh with `use_colors`).
static func instanced(roughness: float = 0.9) -> StandardMaterial3D:
	var key: String = "instanced:%s" % roughness
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.vertex_color_use_as_albedo = true
		material.roughness = roughness
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


## An image on a quad (the portraits).
static func textured(texture: Texture2D, tint: Color = Color.WHITE) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_texture = texture
	material.albedo_color = tint
	material.roughness = 0.6
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material
