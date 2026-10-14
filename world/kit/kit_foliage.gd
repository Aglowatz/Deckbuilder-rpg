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
	id = ZoneStyles.swap(id)
	var cache_key: String = "%s|%s" % [id, ZoneStyles.current]
	if _card_cache.has(cache_key):
		return _card_cache[cache_key] as ShaderMaterial
	var material_value: ShaderMaterial = ShaderMaterial.new()
	material_value.shader = load(CARD_SHADER) as Shader
	material_value.set_shader_parameter("card_tex", EnvKit.texture(id))
	material_value.set_shader_parameter("light_color", _sun)
	material_value.set_shader_parameter("ambient_color", _ambient)
	material_value.set_shader_parameter("mood_tint", ZoneStyles.tint("tree"))
	_materials.append(material_value)
	_card_cache[cache_key] = material_value
	return material_value


## A one-card tree (or any card): `size` metres wide and tall, base at the node origin.
static func card(id: String, size: Vector2, shadow: bool = true) -> MeshInstance3D:
	id = ZoneStyles.swap(id)
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = quad
	instance.material_override = card_material(id)
	var final_size: Vector2 = size
	if (id.begins_with("ENV-TREE-") or EnvKit.zone_of(id) != "") and EnvKit.has_art(id):
		# painted trees keep their own proportions, with the trunk base (not the card centre) on the node origin
		final_size.x = size.y * EnvKit.aspect(id)
		instance.position.x = (0.5 - EnvKit.pivot(id).x) * final_size.x
	instance.scale = Vector3(final_size.x, final_size.y, 1.0)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 2.0
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	return instance


## Natural clumps of grass and flowers: every entry {"pos": Vector3, "radius": float, "count": int, "cells": Array} scatters `count` plants inside the circle.
## Returns the MultiMeshInstance3D (null when empty). Never uniform: sizes, spacing and flips vary.
static func clumps(parent: Node3D, entries: Array[Dictionary], seed_value: int = 1, keep: Callable = Callable()) -> MultiMeshInstance3D:
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
			if keep.is_valid() and not bool(keep.call(pos)):
				continue
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
	var points: Array[Vector3] = []
	var heights: Array[float] = []
	for transform_value: Transform3D in transforms:
		points.append(transform_value.origin)
		heights.append(transform_value.basis.get_scale().y)
	instance.set_meta("points", points)
	instance.set_meta("heights", heights)
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 4.0
	instance.set_meta(StyleToon.META_NO_TOON, true)
	parent.add_child(instance)
	return instance


## Re-tints the tree cards for the current area (hot reload of a style file).
static func retint() -> void:
	var tint: Color = ZoneStyles.tint("tree")
	for material_value: ShaderMaterial in _materials:
		if material_value != null:
			material_value.set_shader_parameter("mood_tint", tint)


static func clear_cache() -> void:
	_materials.clear()
	_card_cache.clear()


## Many trees of one kind as ONE MultiMesh (one draw call and one shadow draw instead of one per tree). `entries`: [{"pos": Vector3, "scale": float}].
static func tree_field(parent: Node3D, tree_kind: String, entries: Array[Dictionary], shadow: bool) -> MultiMeshInstance3D:
	if entries.is_empty() or not TreeCards.KINDS.has(tree_kind):
		return null
	var data: Dictionary = TreeCards.KINDS[tree_kind] as Dictionary
	var size: Vector2 = data["size"] as Vector2
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = quad
	multimesh.instance_count = entries.size()
	for index: int in range(entries.size()):
		var s: float = float(entries[index].get("scale", 1.0))
		multimesh.set_instance_transform(index, Transform3D(Basis.from_scale(Vector3(size.x * s, size.y * s, 1.0)), entries[index]["pos"] as Vector3))
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "Trees_%s_%s" % [tree_kind, "shadow" if shadow else "far"]
	instance.multimesh = multimesh
	instance.material_override = card_material(str(data["id"]))
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.extra_cull_margin = 8.0
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta("points", entries)
	parent.add_child(instance)
	return instance
