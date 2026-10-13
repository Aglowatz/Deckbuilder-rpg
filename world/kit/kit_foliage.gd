class_name KitFoliage
extends RefCounted
## Camera-facing painted cards of the Environment Kit: trees (ENV-TREE-*, one card per tree) and hand-placed flower / grass clumps (the foliage atlas, one MultiMesh per call).
## They share the light colours of the zone: `set_light` re-tints every card material created so far (the look rig calls it with the zone sun and ambient).

const CARD_SHADER: String = "res://world/kit/kit_card.gdshader"
const CLUMP_SHADER: String = "res://world/look/world_foliage.gdshader"
const CLUMP_ATLAS: String = "res://assets/art/world_test/foliage/atlas.png"
## Atlas cell -> [min, max] plant height in metres (cells: 0 grass, 1 seed-head grass, 2 wildflowers, 3 foxgloves, 4 berry bush, 5 fern).
const CELL_HEIGHTS: Array[Vector2] = [Vector2(0.4, 0.7), Vector2(0.4, 0.7), Vector2(0.45, 0.7), Vector2(0.8, 1.15), Vector2(0.65, 1.0), Vector2(0.5, 0.8)]

static var _materials: Array[ShaderMaterial] = []
static var _sun: Color = Color(1.0, 0.92, 0.78)
static var _ambient: Color = Color(0.55, 0.6, 0.78)
static var _card_cache: Dictionary = {}


static func set_light(sun_color: Color, ambient_color: Color) -> void:
	_sun = sun_color
	_ambient = ambient_color
	for material_value: ShaderMaterial in _materials:
		if material_value != null:
			material_value.set_shader_parameter("light_color", sun_color)
			material_value.set_shader_parameter("ambient_color", ambient_color)


## The shared card material of a kit id (e.g. ENV-TREE-OAK): the real art when it exists, else the placeholder texture.
static func card_material(id: String) -> ShaderMaterial:
	if _card_cache.has(id):
		return _card_cache[id] as ShaderMaterial
	var material_value: ShaderMaterial = ShaderMaterial.new()
	material_value.shader = load(CARD_SHADER) as Shader
	material_value.set_shader_parameter("card_tex", EnvKit.texture(id))
	material_value.set_shader_parameter("light_color", _sun)
	material_value.set_shader_parameter("ambient_color", _ambient)
	_materials.append(material_value)
	_card_cache[id] = material_value
	return material_value


## A one-card tree (or any card): `size` metres wide and tall, base at the node origin.
static func card(id: String, size: Vector2, shadow: bool = true) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = quad
	instance.material_override = card_material(id)
	instance.scale = Vector3(size.x, size.y, 1.0)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 2.0
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	return instance


## Natural clumps of grass and flowers: every entry {"pos": Vector3, "radius": float, "count": int, "cells": Array} scatters `count` plants inside the circle.
## Returns the MultiMeshInstance3D (null when empty). Never uniform: sizes, spacing and flips vary.
static func clumps(parent: Node3D, entries: Array[Dictionary], seed_value: int = 1) -> MultiMeshInstance3D:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5000 + seed_value
	var transforms: Array[Transform3D] = []
	var datas: Array[Color] = []
	for entry: Dictionary in entries:
		var center: Vector3 = entry["pos"] as Vector3
		var radius: float = float(entry.get("radius", 0.8))
		var cells: Array = entry.get("cells", [2, 0, 3]) as Array
		var count: int = int(entry.get("count", 6))
		for index: int in range(count):
			var angle: float = rng.randf() * TAU
			var distance: float = sqrt(rng.randf()) * radius
			var cell: int = int(cells[rng.randi() % cells.size()])
			var height_range: Vector2 = CELL_HEIGHTS[clampi(cell, 0, CELL_HEIGHTS.size() - 1)]
			var height: float = rng.randf_range(height_range.x, height_range.y) * (1.0 - 0.35 * (distance / maxf(radius, 0.01)))
			var s: float = height * 1.06
			var pos: Vector3 = center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
			transforms.append(Transform3D(Basis.from_scale(Vector3(s * (1.0 if rng.randf() > 0.5 else -1.0), s, 1.0)), pos))
			datas.append(Color(float(cell), rng.randf(), rng.randf(), 0.0))
	if transforms.is_empty():
		return null
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	var material_value: ShaderMaterial = ShaderMaterial.new()
	material_value.shader = load(CLUMP_SHADER) as Shader
	material_value.set_shader_parameter("atlas", load(CLUMP_ATLAS))
	material_value.set_shader_parameter("light_color", _sun)
	material_value.set_shader_parameter("ambient_color", _ambient)
	_materials.append(material_value)
	quad.material = material_value
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.mesh = quad
	multimesh.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index])
		multimesh.set_instance_custom_data(index, datas[index])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "Clumps"
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 4.0
	instance.set_meta(StyleToon.META_NO_TOON, true)
	parent.add_child(instance)
	return instance


static func clear_cache() -> void:
	_materials.clear()
	_card_cache.clear()
