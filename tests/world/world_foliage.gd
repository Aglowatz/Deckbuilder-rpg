class_name WorldFoliage
extends Node3D
## Painted foliage for the World Look Test (docs/art/world_look_test.md): grass, flowers, bushes and ferns (the FOL- sprites, packed in one atlas by tools/world_test_import.gd)
## scattered over the town ground in ONE MultiMesh. Densest along the water and the edges of the land and beside buildings (gardens), never on the roads, the plaza or at
## a doorstep, and swaying in the wind (world_foliage.gdshader). The cards are camera-facing (they turn round the vertical axis): at low camera angles crossed quads
## showed their thin edge for half of all viewing angles, the facing cards always show the whole plant.

const SHADER: String = "res://tests/world/world_foliage.gdshader"
const ATLAS: String = "res://assets/art/world_test/foliage/atlas.png"
const GRID_STEP: float = 0.8
const ROAD_CLEARANCE: float = 1.75
const PLAZA_CLEARANCE: float = 0.4
const DOOR_CLEARANCE: float = 1.5
## Atlas cell -> [min height, max height] of the plant in metres. Cells: 0 grass, 1 grass with seed heads, 2 wildflowers, 3 tall flowers, 4 bush, 5 fern.
const SIZES: Array[Vector2] = [Vector2(0.4, 0.7), Vector2(0.4, 0.7), Vector2(0.38, 0.6), Vector2(0.75, 1.1), Vector2(0.6, 0.95), Vector2(0.45, 0.75)]
const MAX_INSTANCES: int = 6500

var instance_count: int = 0
var _material: ShaderMaterial
var _instance: MultiMeshInstance3D


func setup(town: TownBuilder, _square: TownSquare, _camera: Camera3D, _sun: Vector3) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 33
	var road_grid: Dictionary = _bucket_points(TownLayout.road_points(0.9), 3.0)
	var blocked_grid: Dictionary = _bucket_points(_door_points(town), 3.0)
	var obstacle_grid: Dictionary = {}
	for obstacle: Vector3 in town.obstacles:
		var obstacle_key: Vector2i = Vector2i(floori(obstacle.x / 4.0), floori(obstacle.y / 4.0))
		if not obstacle_grid.has(obstacle_key):
			obstacle_grid[obstacle_key] = [] as Array[Vector3]
		(obstacle_grid[obstacle_key] as Array[Vector3]).append(obstacle)
	var bounds: Rect2 = town.map_bounds().grow(2.0)
	var density_scale: float = GraphicsQuality.foliage_density(Settings.graphics_quality)
	var transforms: Array[Transform3D] = []
	var datas: Array[Color] = []
	var z: float = bounds.position.y
	while z < bounds.end.y and transforms.size() < MAX_INSTANCES:
		var x: float = bounds.position.x
		while x < bounds.end.x:
			var p: Vector3 = Vector3(x + rng.randf_range(-0.38, 0.38), 0.0, z + rng.randf_range(-0.38, 0.38))
			x += GRID_STEP
			if not town.is_floor_at(p):
				continue
			if Vector2(p.x - TownLayout.PLAZA.x, p.z - TownLayout.PLAZA.z).length() < TownLayout.PLAZA_RADIUS + PLAZA_CLEARANCE:
				continue
			if _near(road_grid, p, 3.0, ROAD_CLEARANCE) or _near(blocked_grid, p, 3.0, DOOR_CLEARANCE):
				continue
			var solid: bool = false
			var garden: float = 0.0
			var key: Vector2i = Vector2i(floori(p.x / 4.0), floori(p.z / 4.0))
			for dz: int in range(-1, 2):
				for dx: int in range(-1, 2):
					var cell_key: Vector2i = Vector2i(key.x + dx, key.y + dz)
					if not obstacle_grid.has(cell_key):
						continue
					for obstacle: Vector3 in obstacle_grid[cell_key] as Array[Vector3]:
						var d: float = Vector2(p.x - obstacle.x, p.z - obstacle.y).length()
						if d < obstacle.z * 0.85:
							solid = true
						elif obstacle.z >= 0.9 and d < obstacle.z + 3.0:
							garden = maxf(garden, 1.0 - (d - obstacle.z) / 3.0)
			if solid:
				continue
			# How close the edge of the land is: the fraction of ring samples that are not ground.
			var off: int = 0
			for i: int in range(6):
				var angle: float = float(i) / 6.0 * TAU + 0.4
				if not town.is_floor_at(p + Vector3(cos(angle), 0.0, sin(angle)) * 2.4):
					off += 1
			var edge: float = float(off) / 6.0
			var chance: float = (0.26 + edge * 0.55 + garden * 0.32) * density_scale
			if rng.randf() > chance:
				continue
			var cell: int = _pick_cell(rng, edge, garden)
			var size_range: Vector2 = SIZES[cell]
			var height: float = rng.randf_range(size_range.x, size_range.y) * (1.12 if edge > 0.3 else 1.0)
			var s: float = height * 1.06
			transforms.append(Transform3D(Basis.from_scale(Vector3(s * (1.0 if rng.randf() > 0.5 else -1.0), s, 1.0)), p))
			datas.append(Color(float(cell), rng.randf(), rng.randf(), 0.0))
			if transforms.size() >= MAX_INSTANCES:
				break
		z += GRID_STEP
	_build(transforms, datas)
	print("world_look: foliage %d cards" % instance_count)


func _pick_cell(rng: RandomNumberGenerator, edge: float, garden: float) -> int:
	var roll: float = rng.randf()
	if garden > 0.35:
		if roll < 0.34:
			return 2
		if roll < 0.52:
			return 3
		if roll < 0.74:
			return 4
		if roll < 0.86:
			return 5
		return 0
	if edge > 0.3:
		if roll < 0.3:
			return 0
		if roll < 0.52:
			return 1
		if roll < 0.7:
			return 5
		if roll < 0.82:
			return 4
		return 2
	if roll < 0.34:
		return 0
	if roll < 0.6:
		return 1
	if roll < 0.78:
		return 2
	if roll < 0.86:
		return 3
	if roll < 0.92:
		return 5
	return 4


func _door_points(town: TownBuilder) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for anchor: Variant in town.anchors.values():
		if anchor is Vector3:
			result.append(anchor as Vector3)
	return result


func _bucket_points(points: Array[Vector3], cell: float) -> Dictionary:
	var grid: Dictionary = {}
	for point: Vector3 in points:
		var key: Vector2i = Vector2i(floori(point.x / cell), floori(point.z / cell))
		if not grid.has(key):
			grid[key] = [] as Array[Vector3]
		(grid[key] as Array[Vector3]).append(point)
	return grid


func _near(grid: Dictionary, p: Vector3, cell: float, distance: float) -> bool:
	var key: Vector2i = Vector2i(floori(p.x / cell), floori(p.z / cell))
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var cell_key: Vector2i = Vector2i(key.x + dx, key.y + dz)
			if not grid.has(cell_key):
				continue
			for point: Vector3 in grid[cell_key] as Array[Vector3]:
				if Vector2(p.x - point.x, p.z - point.z).length() < distance:
					return true
	return false


func _build(transforms: Array[Transform3D], datas: Array[Color]) -> void:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.0, 0.5, 0.0)
	_material = ShaderMaterial.new()
	_material.shader = load(SHADER) as Shader
	_material.set_shader_parameter("atlas", load(ATLAS))
	quad.material = _material
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.mesh = quad
	multimesh.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index])
		multimesh.set_instance_custom_data(index, datas[index])
	instance_count = transforms.size()
	_instance = MultiMeshInstance3D.new()
	_instance.multimesh = multimesh
	_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_instance.extra_cull_margin = 4.0
	add_child(_instance)


## The colours the cards are lit with (the town sun and ambient), set by the scene once its style rig exists.
func set_light(sun_color: Color, ambient: Color) -> void:
	if _material == null:
		return
	_material.set_shader_parameter("light_color", sun_color)
	_material.set_shader_parameter("ambient_color", ambient)
