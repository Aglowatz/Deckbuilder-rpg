class_name HeapMaterials
extends RefCounted
## The Verdant Heap's shared palette: earthy greens and browns with rust oranges. Every procedural prop, the terrain
## and the golems draw from these few flat-shaded materials so the zone reads as one cohesive low-poly family
## alongside the Kenney Nature / Survival / Car / Cube Pets models. Cached; never create one-off materials.

static var _cache: Dictionary = {}

const GRASS: Color = Color(0.42, 0.62, 0.24)
const GRASS_DARK: Color = Color(0.3, 0.5, 0.2)
const MEADOW: Color = Color(0.58, 0.72, 0.3)
const DIRT: Color = Color(0.5, 0.36, 0.22)
const DIRT_DARK: Color = Color(0.36, 0.25, 0.15)
const STRAW: Color = Color(0.9, 0.76, 0.38)
const GOLD_FIELD: Color = Color(0.86, 0.7, 0.28)
const RUST: Color = Color(0.72, 0.36, 0.18)
const RUST_DARK: Color = Color(0.48, 0.24, 0.12)
const METAL: Color = Color(0.62, 0.64, 0.66)
const METAL_DARK: Color = Color(0.38, 0.4, 0.42)
const MOSS: Color = Color(0.36, 0.55, 0.22)
const VINE: Color = Color(0.22, 0.5, 0.2)
const BLOOM: Color = Color(1.0, 0.55, 0.75)
const WOOD: Color = Color(0.6, 0.4, 0.22)
const WOOD_DARK: Color = Color(0.4, 0.26, 0.14)
const STONE: Color = Color(0.52, 0.5, 0.46)
const SLUDGE: Color = Color(0.28, 0.32, 0.12)
const RECYCLED_WATER: Color = Color(0.13, 0.46, 0.5)
const TIRE: Color = Color(0.16, 0.16, 0.18)


static func flat(color: Color, roughness: float = 0.9) -> StandardMaterial3D:
	var key: String = "flat:%s:%s" % [color.to_html(), roughness]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = roughness
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


static func shiny(color: Color, roughness: float = 0.3) -> StandardMaterial3D:
	var key: String = "shiny:%s:%s" % [color.to_html(), roughness]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = roughness
		material.metallic = 0.3
		material.metallic_specular = 0.7
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


static func terrain() -> StandardMaterial3D:
	if not _cache.has("terrain"):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.vertex_color_use_as_albedo = true
		material.vertex_color_is_srgb = true
		material.roughness = 0.9
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_cache["terrain"] = material
	return _cache["terrain"] as StandardMaterial3D


## The recycling stream: glossy teal water that glints.
static func water() -> StandardMaterial3D:
	if not _cache.has("water"):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(RECYCLED_WATER.r, RECYCLED_WATER.g, RECYCLED_WATER.b, 0.88)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.roughness = 0.08
		material.metallic = 0.2
		material.metallic_specular = 0.9
		material.emission_enabled = true
		material.emission = RECYCLED_WATER
		material.emission_energy_multiplier = 0.1
		_cache["water"] = material
	return _cache["water"] as StandardMaterial3D


## The compost pits: thick, dark, faintly glowing green sludge.
static func sludge() -> StandardMaterial3D:
	if not _cache.has("sludge"):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(SLUDGE.r, SLUDGE.g, SLUDGE.b, 0.95)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.roughness = 0.25
		material.emission_enabled = true
		material.emission = Color(0.4, 0.6, 0.1)
		material.emission_energy_multiplier = 0.2
		_cache["sludge"] = material
	return _cache["sludge"] as StandardMaterial3D
