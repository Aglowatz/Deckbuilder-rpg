class_name StartingForest
extends Node3D
## Polish round, Group C: the endless forest around the starting clearing, so a fully zoomed-out camera never sees the edge of the world.
## Visual only (nothing here is walkable or collides): a huge mossy forest floor, three layers of trees that get taller and plainer with distance
## (real Kenney pines near, bigger pines in the middle, cheap unshaded cone silhouettes far away that melt into the fog), undergrowth, a ring of
## far mountains, slanted light shafts and drifting fireflies. Everything is MultiMesh so the whole forest is a handful of draw calls.
## Deterministic (seeded) and scaled by the graphics quality.

const NATURE: String = ModelKit.KENNEY_NATURE
const FLOOR_SIZE: float = 900.0
const SHAFT_SHADER: String = "res://assets/shaders/style_lightshaft.gdshader"

## The near layer: tall pines (model, height in metres at scale 1).
const NEAR_TREES: Array[Array] = [["tree_pineTallA", 1.53], ["tree_pineTallB", 1.93], ["tree_pineTallC", 1.67], ["tree_pineTallD", 2.07], ["tree_pineTallA_detailed", 1.53], ["tree_cone", 1.43], ["tree_cone_dark", 1.43]]
## The middle layer: the biggest silhouettes.
const MID_TREES: Array[Array] = [["tree_pineTallB", 1.93], ["tree_pineTallD", 2.07], ["tree_pineTallC", 1.67], ["tree_cone_dark", 1.43]]

var center: Vector2 = Vector2.ZERO
var keep_out: Rect2 = Rect2()
var spawn: Vector2 = Vector2.ZERO
var quality: int = GraphicsQuality.Level.MEDIUM
## Where every tree stands (readable headless, where MultiMesh buffers are not): layer name -> Array[Vector2].
var tree_points: Dictionary = {"near": [], "mid": [], "far": []}
var firefly_count: int = 0
var shaft_count: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _fireflies: MultiMesh
var _firefly_base: PackedVector3Array = PackedVector3Array()
var _firefly_phase: PackedFloat32Array = PackedFloat32Array()
var _time: float = 0.0


## `area_cells`: every hex cell of the clearing (walkable or not), in grid coordinates.
static func build(parent: Node3D, area_cells: Array, spawn_pos: Vector3, quality_level: int) -> StartingForest:
	var forest: StartingForest = StartingForest.new()
	forest.name = "StartingForest"
	forest.quality = quality_level
	forest.spawn = Vector2(spawn_pos.x, spawn_pos.z)
	var bounds: Rect2 = HexGrid.bounds_of(area_cells)
	forest.keep_out = bounds.grow(0.4)
	forest.center = bounds.get_center()
	forest._rng.seed = 2026
	parent.add_child(forest)
	forest._floor()
	forest._trees()
	forest._undergrowth()
	forest._mountains()
	forest._shafts()
	forest._fireflies_build()
	return forest


func _process(delta: float) -> void:
	if _fireflies == null:
		return
	_time += delta
	for i: int in range(firefly_count):
		var phase: float = _firefly_phase[i]
		var base: Vector3 = _firefly_base[i]
		var drift: Vector3 = Vector3(sin(_time * 0.37 + phase) * 1.1, sin(_time * 0.61 + phase * 1.9) * 0.35, cos(_time * 0.29 + phase * 1.3) * 1.1)
		var blink: float = 0.25 + 0.75 * smoothstep(0.1, 0.9, 0.5 + 0.5 * sin(_time * (0.9 + fmod(phase, 0.7)) + phase * 3.0))
		_fireflies.set_instance_transform(i, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * blink), base + drift))


# ---- placement helpers ----------------------------------------------------------------------------------------------------------------


func _density() -> float:
	return GraphicsQuality.foliage_density(quality)


## Jittered-grid points between `inner` and `outer` metres from the clearing's centre, outside the clearing itself.
func _ring(inner: float, outer: float, spacing: float, jitter: float) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var steps: int = int(ceil(outer / spacing))
	for ix: int in range(-steps, steps + 1):
		for iz: int in range(-steps, steps + 1):
			var p: Vector2 = center + Vector2(float(ix), float(iz)) * spacing + Vector2(_rng.randf_range(-jitter, jitter), _rng.randf_range(-jitter, jitter))
			var distance: float = p.distance_to(center)
			if distance < inner or distance > outer or keep_out.has_point(p):
				continue
			points.append(p)
	return points


## Tallest a tree may be at `p`: the strip of forest between the clearing and the camera (south of the hero) is kept low enough to look over.
func _height_cap(p: Vector2) -> float:
	if p.y > spawn.y and absf(p.x - spawn.x) < 3.8:
		return 1.0 + 0.9 * (p.y - spawn.y)
	# Anything else on the camera's side stays under about 3 m so the foreground never swallows the view.
	if p.y > spawn.y - 1.0 and p.distance_to(center) < 22.0:
		return 3.0
	return 1.0e9


func _toon_mesh(model: String) -> Mesh:
	var source: Mesh = ModelKit.kit_mesh(NATURE, model)
	if source == null:
		return null
	var mesh: Mesh = source.duplicate() as Mesh
	for surface: int in range(mesh.get_surface_count()):
		var toon: ShaderMaterial = StyleToon.toon_for(source.surface_get_material(surface), 0.35)
		if toon != null:
			mesh.surface_set_material(surface, toon)
	return mesh


func _add_multimesh(mesh: Mesh, transforms: Array[Transform3D], shadows: bool, material: Material = null) -> MultiMeshInstance3D:
	if mesh == null or transforms.is_empty():
		return null
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for i: int in range(transforms.size()):
		multimesh.set_instance_transform(i, transforms[i])
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	if material != null:
		instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	add_child(instance)
	return instance


# ---- the floor --------------------------------------------------------------------------------------------------------------------------


func _floor() -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(FLOOR_SIZE, FLOOR_SIZE)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color("5f9150")
	material.roughness = 1.0
	material.set_meta(StyleToon.META_FLAT_UP, true)
	var floor_node: MeshInstance3D = MeshInstance3D.new()
	floor_node.name = "ForestFloor"
	floor_node.mesh = plane
	floor_node.material_override = material
	floor_node.position = Vector3(center.x, -0.06, center.y)
	floor_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(floor_node)
	# Mossy blotches in three greens so the floor is not one flat colour.
	var darks: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("2a5a48"), Color("22503f"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.7, 4.0)
	var lights: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("4a8a62"), Color("3d7a58"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.7, 5.0)
	var needles: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.MOSS, Color("6a7a4a"), Color("58704a"), Color.BLACK, GroundDecals.Shape.DISC, 1.0, 0.6, 6.0)
	var blotches: int = int(46.0 * _density())
	for i: int in range(blotches):
		var angle: float = _rng.randf() * TAU
		var distance: float = _rng.randf_range(5.0, 34.0)
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * distance
		if keep_out.has_point(pos):
			continue
		var mat: ShaderMaterial = [darks, lights, needles][i % 3]
		GroundDecals.disc(self, Vector3(pos.x, -0.03, pos.y), _rng.randf_range(2.0, 5.5), mat, _rng.randf_range(0.6, 1.0), _rng.randf() * 180.0, 0.0004 * float(i % 6))


# ---- trees: near, middle, far --------------------------------------------------------------------------------------------------------


func _trees() -> void:
	var density: float = _density()
	_tree_layer("near", NEAR_TREES, _ring(0.0, 24.0, 2.0 / sqrt(density), 0.9), Vector2(1.7, 2.7), true)
	_tree_layer("mid", MID_TREES, _ring(24.0, 58.0, 3.5 / sqrt(density), 1.5), Vector2(3.2, 5.6), false)
	_far_trees(_ring(58.0, 130.0, 4.8 / sqrt(density), 2.1))


func _tree_layer(layer: String, models: Array[Array], points: Array[Vector2], scale_range: Vector2, shadows: bool) -> void:
	var by_model: Dictionary = {}
	for p: Vector2 in points:
		var pick: int = _rng.randi() % models.size()
		var model: String = str(models[pick][0])
		var model_height: float = float(models[pick][1])
		var scale_value: float = _rng.randf_range(scale_range.x, scale_range.y)
		scale_value = minf(scale_value, _height_cap(p) / model_height)
		var basis: Basis = Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * scale_value)
		var list: Array = by_model.get(model, []) as Array
		list.append(Transform3D(basis, Vector3(p.x, -0.05, p.y)))
		by_model[model] = list
		(tree_points[layer] as Array).append(p)
	for model: String in by_model.keys():
		var transforms: Array[Transform3D] = []
		transforms.assign(by_model[model] as Array)
		_add_multimesh(_toon_mesh(model), transforms, shadows)


## The far forest: one cheap unshaded cone mesh in a few tints, so a thousand distant pines cost one draw call and the fog does the rest.
func _far_trees(points: Array[Vector2]) -> void:
	var cone: CylinderMesh = CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.9
	cone.height = 4.2
	cone.radial_segments = 6
	cone.rings = 1
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("2f6b5e")
	material.set_meta(StyleToon.META_NO_TOON, true)
	var transforms: Array[Transform3D] = []
	for p: Vector2 in points:
		var scale_value: float = _rng.randf_range(4.5, 8.5)
		var basis: Basis = Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3(scale_value * 0.7, scale_value, scale_value * 0.7))
		transforms.append(Transform3D(basis, Vector3(p.x, scale_value * cone.height * 0.5 - 0.1, p.y)))
		(tree_points["far"] as Array).append(p)
	_add_multimesh(cone, transforms, false, material)


# ---- undergrowth: bushes, grass, mushrooms, stumps, logs, small rocks ---------------------------------------------------------------


func _undergrowth() -> void:
	var density: float = _density()
	var groups: Array[Dictionary] = [
		{"model": "plant_bushLarge", "count": 120, "scale": Vector2(1.6, 2.7)},
		{"model": "plant_bush", "count": 120, "scale": Vector2(1.6, 2.6)},
		{"model": "plant_flatTall", "count": 120, "scale": Vector2(1.6, 2.8)},
		{"model": "mushroom_redGroup", "count": 26, "scale": Vector2(1.1, 1.9)},
		{"model": "mushroom_tanGroup", "count": 18, "scale": Vector2(1.1, 1.9)},
		{"model": "stump_old", "count": 14, "scale": Vector2(1.8, 2.8)},
		{"model": "log_large", "count": 10, "scale": Vector2(1.3, 2.0)},
		{"model": "rock_smallA", "count": 30, "scale": Vector2(1.4, 2.6)},
		{"model": "rock_largeA", "count": 10, "scale": Vector2(1.2, 2.2)},
	]
	for group: Dictionary in groups:
		var transforms: Array[Transform3D] = []
		var target: int = int(float(group["count"]) * density)
		var tries: int = 0
		while transforms.size() < target and tries < target * 12:
			tries += 1
			var angle: float = _rng.randf() * TAU
			var distance: float = _rng.randf_range(3.0, 26.0)
			var pos: Vector2 = center + Vector2(cos(angle), sin(angle) * 0.85) * distance
			if keep_out.has_point(pos):
				continue
			var range_scale: Vector2 = group["scale"] as Vector2
			var s: float = _rng.randf_range(range_scale.x, range_scale.y)
			transforms.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * s), Vector3(pos.x, -0.05, pos.y)))
		_add_multimesh(_toon_mesh(str(group["model"])), transforms, false)
	# A skirt of bushes hugging the clearing's outer edge so the hex tiles never read as an island.
	var skirt: Array[Transform3D] = []
	var skirt_ring: Rect2 = keep_out.grow(2.2)
	var skirt_tries: int = 0
	while skirt.size() < int(110.0 * density) and skirt_tries < 1500:
		skirt_tries += 1
		var sp: Vector2 = Vector2(_rng.randf_range(skirt_ring.position.x, skirt_ring.end.x), _rng.randf_range(skirt_ring.position.y, skirt_ring.end.y))
		if keep_out.has_point(sp):
			continue
		skirt.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * _rng.randf_range(2.0, 3.4)), Vector3(sp.x, -0.05, sp.y)))
	_add_multimesh(_toon_mesh("plant_bushLarge"), skirt, false)
	# Real grass clumps (the town's wind-swaying kind) under and between the trees.
	var grass_transforms: Array[Transform3D] = []
	var grass_target: int = int(900.0 * density)
	var attempts: int = 0
	while grass_transforms.size() < grass_target and attempts < grass_target * 6:
		attempts += 1
		var a: float = _rng.randf() * TAU
		var d: float = sqrt(_rng.randf()) * 24.0
		var gp: Vector2 = center + Vector2(cos(a), sin(a)) * d
		if keep_out.has_point(gp):
			continue
		grass_transforms.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * _rng.randf_range(1.8, 3.2)), Vector3(gp.x, -0.04, gp.y)))
	var colors: Array[Color] = StyleGrass.colors_for([Color("4f9a6a")])
	add_child(StyleGrass.multimesh_instance(grass_transforms, colors[0], colors[1]))


# ---- far mountains ---------------------------------------------------------------------------------------------------------------------------


func _mountains() -> void:
	var models: Array[String] = ["mountain_A_grass_trees", "mountain_B_grass_trees", "mountain_C_grass_trees"]
	for i: int in range(14):
		var angle: float = TAU * float(i) / 14.0 + _rng.randf_range(-0.12, 0.12)
		var distance: float = _rng.randf_range(105.0, 135.0)
		var node: Node3D = ModelKit.nature(models[i % models.size()])
		var scale_value: float = _rng.randf_range(24.0, 38.0)
		ModelKit.place(self, node, Vector3(center.x + cos(angle) * distance, -0.2, center.y + sin(angle) * distance), _rng.randf() * 360.0, scale_value)


# ---- light shafts and fireflies -------------------------------------------------------------------------------------------------------


func _shafts() -> void:
	var shader: Shader = load(SHAFT_SHADER) as Shader
	if shader == null:
		return
	var count: int = [4, 7, 10][clampi(quality, 0, 2)]
	for i: int in range(count):
		var angle: float = TAU * (float(i) + _rng.randf()) / float(count)
		var distance: float = _rng.randf_range(9.0, 22.0)
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * distance
		var mesh: CylinderMesh = CylinderMesh.new()
		mesh.top_radius = _rng.randf_range(0.2, 0.4)
		mesh.bottom_radius = _rng.randf_range(0.6, 1.1)
		mesh.height = 12.0
		mesh.radial_segments = 14
		mesh.rings = 1
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("phase", _rng.randf() * TAU)
		material.set_shader_parameter("half_height", 6.0)
		var shaft: MeshInstance3D = MeshInstance3D.new()
		shaft.name = "LightShaft%d" % i
		shaft.mesh = mesh
		shaft.material_override = material
		shaft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shaft.set_meta(StyleToon.META_NO_TOON, true)
		shaft.position = Vector3(pos.x, 5.4, pos.y)
		# Slanted the way the sun falls (the START preset's key light comes from the upper left).
		shaft.rotation_degrees = Vector3(0.0, 0.0, -24.0)
		shaft.rotate_y(_rng.randf_range(-0.35, 0.35))
		add_child(shaft)
		shaft_count += 1


func _fireflies_build() -> void:
	firefly_count = int(70.0 * _density())
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.07
	sphere.height = 0.14
	sphere.radial_segments = 6
	sphere.rings = 3
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.5, 1.45, 0.65)
	material.set_meta(StyleToon.META_NO_TOON, true)
	_fireflies = MultiMesh.new()
	_fireflies.transform_format = MultiMesh.TRANSFORM_3D
	_fireflies.mesh = sphere
	_fireflies.instance_count = firefly_count
	for i: int in range(firefly_count):
		var angle: float = _rng.randf() * TAU
		var distance: float = sqrt(_rng.randf()) * 30.0
		_firefly_base.append(Vector3(center.x + cos(angle) * distance, _rng.randf_range(0.4, 3.2), center.y + sin(angle) * distance))
		_firefly_phase.append(_rng.randf() * TAU)
		_fireflies.set_instance_transform(i, Transform3D(Basis.IDENTITY, _firefly_base[i]))
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "Fireflies"
	instance.multimesh = _fireflies
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(StyleToon.META_NO_TOON, true)
	add_child(instance)
