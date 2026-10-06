class_name GainlandsMaterials
extends RefCounted
## The Gainlands' shared palette: every procedural prop (wheels, gym equipment, pipes, islands, stages)
## draws from these few flat-shaded materials so the zone reads as one cohesive, bright, low-poly
## family alongside the KayKit models. Cached; never create one-off materials in the builders.

static var _cache: Dictionary = {}

const GRASS_LOW: Color = Color(0.36, 0.74, 0.30)
const GRASS_HIGH: Color = Color(0.56, 0.86, 0.34)
const PATH: Color = Color(0.86, 0.72, 0.46)
const ROCK: Color = Color(0.58, 0.54, 0.52)
const ROCK_DARK: Color = Color(0.36, 0.33, 0.34)
const WOOD: Color = Color(0.62, 0.42, 0.24)
const WOOD_DARK: Color = Color(0.40, 0.26, 0.15)
const METAL: Color = Color(0.74, 0.77, 0.82)
const COPPER: Color = Color(0.92, 0.52, 0.26)
const ENERGY: Color = Color(0.25, 0.95, 1.0)
const PINK: Color = Color(1.0, 0.38, 0.72)
const YELLOW: Color = Color(1.0, 0.85, 0.2)
const WATER: Color = Color(0.3, 0.7, 1.0)
const CLOTH_RED: Color = Color(0.9, 0.22, 0.22)
const CLOTH_BLUE: Color = Color(0.25, 0.5, 0.95)


static func flat(color: Color, roughness: float = 0.9) -> StandardMaterial3D:
	var key: String = "flat:%s:%s" % [color.to_html(), roughness]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = roughness
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


static func translucent(color: Color, alpha: float, energy: float = 0.8) -> StandardMaterial3D:
	var key: String = "tr:%s:%s:%s" % [color.to_html(), alpha, energy]
	if not _cache.has(key):
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color(color.r, color.g, color.b, alpha)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = energy
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.roughness = 0.3
		_cache[key] = material
	return _cache[key] as StandardMaterial3D


## Vertex-coloured, double-sided terrain material (the colours are painted per triangle).
static func terrain() -> Material:
	return StyleTerrain.material(0.2, 0.1)
