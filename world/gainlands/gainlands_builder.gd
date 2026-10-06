class_name GainlandsBuilder
extends ZoneMap
## Turns a `GainlandsLayout` into the Gainlands' 3D world and answers walkability queries: the
## rolling faceted main land (a polar mesh so its edge is exactly the walkable edge), the floating
## islands with rocky undersides, a sea of clouds, KayKit mills/trees/rocks plus the procedural
## wheels, gym equipment and stages of `GainlandsProps`, copper energy pipes with travelling
## pulses, signs, and the hidden chests. `animate()` moves everything that moves.

const M = preload("res://world/gainlands/gainlands_materials.gd")
const KAYKIT_TREES: Array[String] = ["tree_single_A", "tree_single_B"]
const KAYKIT_ROCKS: Array[String] = ["rock_single_A", "rock_single_B", "rock_single_C", "rock_single_D", "rock_single_E"]
const RINGS: int = 38
const SECTORS: int = 132

var layout: GainlandsLayout = GainlandsLayout.new()
var root: Node3D
var story: ZoneStoryText
## 1.0 = idle; the wheels spin faster once the grid is powered.
var wheel_speed: float = 0.45

var _buckets: Dictionary = {}
var _spinners: Array[Node3D] = []
var _fans: Array[Node3D] = []
var _bobbers: Array[Node3D] = []
var _y_spinners: Array[Node3D] = []
var _z_spinners: Array[Node3D] = []
var _screens: Array[MeshInstance3D] = []
var _clouds: Array[Node3D] = []
var _pulses: Array[Dictionary] = []
var _hamsters: Array[Node3D] = []
var _time: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func build(parent: Node3D) -> void:
	_rng.seed = 77
	layout.build()
	story = ZoneStoryText.for_zone(GainlandsZone.ID)
	root = Node3D.new()
	root.name = "Gainlands"
	parent.add_child(root)
	_build_main_land()
	_build_islands()
	_build_clouds()
	_build_props()
	_build_pipes()
	_build_signs()
	_build_chests()
	_index_obstacles()


# ---- Queries (the ZoneMap interface) ------------------------------------------------------------


func anchor(anchor_name: String) -> Vector3:
	var base: Vector3 = layout.anchors.get(anchor_name, Vector3.ZERO) as Vector3
	return Vector3(base.x, layout.ground_height(base.x, base.z), base.z)


func has_anchor(anchor_name: String) -> bool:
	return layout.anchors.has(anchor_name)


func chest_positions() -> Dictionary:
	var result: Dictionary = {}
	for id: Variant in layout.chests.keys():
		var base: Vector3 = layout.chests[id] as Vector3
		result[str(id)] = Vector3(base.x, layout.ground_height(base.x, base.z), base.z)
	return result


func enemy_spawns() -> Array[Dictionary]:
	return layout.enemy_spawns


func height_at(pos: Vector3) -> float:
	return layout.ground_height(pos.x, pos.z)


func area_at(pos: Vector3) -> Array[String]:
	var area: GainlandsLayout.Area = layout.area_at(pos.x, pos.z)
	if area == null:
		return [] as Array[String]
	return [area.id, area.title] as Array[String]


func is_floor_at(pos: Vector3) -> bool:
	var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
	return surface == GainlandsLayout.Surface.GROUND or surface == GainlandsLayout.Surface.ISLAND


func map_bounds() -> Rect2:
	var bounds: Rect2 = Rect2(GainlandsLayout.CENTER - GainlandsLayout.RADII * 1.1, GainlandsLayout.RADII * 2.2)
	for island: GainlandsLayout.Island in layout.islands:
		bounds = bounds.merge(Rect2(island.center - Vector2(island.radius, island.radius), Vector2(island.radius, island.radius) * 2.0))
	return bounds


## The island whose rim the player is standing past (stepping there means falling), or null.
func fall_island(pos: Vector3) -> GainlandsLayout.Island:
	if layout.surface_at(pos.x, pos.z) == GainlandsLayout.Surface.RIM:
		return layout.island_at(pos.x, pos.z)
	return null


## The island the player is standing on (its top), or null on the main land.
func island_under(pos: Vector3) -> GainlandsLayout.Island:
	var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface == GainlandsLayout.Surface.ISLAND or surface == GainlandsLayout.Surface.RIM:
		return layout.island_at(pos.x, pos.z)
	return null


func add_blocker(pos: Vector3, radius: float) -> void:
	_add_obstacle(Vector3(pos.x, pos.z, radius))


func is_walkable(pos: Vector3, body_radius: float = 0.22) -> bool:
	var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
	if surface == GainlandsLayout.Surface.VOID:
		return false
	if surface == GainlandsLayout.Surface.GROUND and layout.main_edge_distance(pos.x, pos.z) < 0.35:
		return false
	return not _hits_obstacle(pos, body_radius)


func has_line_of_sight(a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(1, int(a.distance_to(b) / 0.6))
	for i: int in range(steps + 1):
		var point: Vector3 = a.lerp(b, float(i) / float(steps))
		var surface: GainlandsLayout.Surface = layout.surface_at(point.x, point.z)
		if surface == GainlandsLayout.Surface.VOID or surface == GainlandsLayout.Surface.RIM:
			return false
		if _hits_obstacle(point, 0.1):
			return false
	return true


func _bucket_key(x: float, z: float) -> Vector2i:
	return Vector2i(int(floorf(x / 4.0)), int(floorf(z / 4.0)))


func _add_obstacle(obstacle: Vector3) -> void:
	var key: Vector2i = _bucket_key(obstacle.x, obstacle.y)
	var list: Array = _buckets.get(key, []) as Array
	list.append(obstacle)
	_buckets[key] = list


func _hits_obstacle(pos: Vector3, radius: float) -> bool:
	var key: Vector2i = _bucket_key(pos.x, pos.z)
	for dz: int in range(-1, 2):
		for dx: int in range(-1, 2):
			var list: Variant = _buckets.get(key + Vector2i(dx, dz))
			if list == null:
				continue
			for obstacle: Vector3 in (list as Array):
				var ox: float = pos.x - obstacle.x
				var oz: float = pos.z - obstacle.y
				var reach: float = obstacle.z + radius
				if ox * ox + oz * oz < reach * reach:
					return true
	return false


func _index_obstacles() -> void:
	for prop: GainlandsLayout.Prop in layout.props:
		if prop.radius > 0.0:
			_add_obstacle(Vector3(prop.pos.x, prop.pos.z, prop.radius))
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		_add_obstacle(Vector3(chest.x, chest.z, 0.18))


# ---- Terrain ----------------------------------------------------------------------------------------


static func _noise(x: float, z: float) -> float:
	return fposmod(sin(x * 12.9898 + z * 78.233) * 43758.5453, 1.0)


func _tri(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	for vertex: Vector3 in [a, b, c]:
		surface.set_color(color)
		surface.add_vertex(vertex)


func _land_point(ring: int, sector: int, rings: int, sectors: int) -> Vector3:
	var fraction: float = float(ring) / float(rings)
	var angle: float = TAU * float(sector % sectors) / float(sectors)
	var factor: float = GainlandsLayout.radius_factor(angle)
	var x: float = GainlandsLayout.CENTER.x + cos(angle) * GainlandsLayout.RADII.x * factor * fraction
	var z: float = GainlandsLayout.CENTER.y + sin(angle) * GainlandsLayout.RADII.y * factor * fraction
	return Vector3(x, layout.ground_height(x, z), z)


func _grass_color(p: Vector3, centroid: Vector3) -> Color:
	var shade: float = clampf((centroid.y + 1.6) / 3.2, 0.0, 1.0)
	var color: Color = M.GRASS_LOW.lerp(M.GRASS_HIGH, shade)
	color = color.lightened((_noise(centroid.x * 0.7, centroid.z * 0.7) - 0.5) * 0.04)
	var path: float = layout.path_weight(centroid.x, centroid.z)
	if path > 0.0:
		color = color.lerp(M.PATH.lightened((_noise(p.x, p.z) - 0.5) * 0.08), path)
	var hub_distance: float = Vector2(centroid.x - 52.0, centroid.z - 64.0).length()
	if hub_distance < 9.0:
		color = color.lerp(Color(0.93, 0.86, 0.7), 1.0 - smoothstep(6.5, 9.0, hub_distance))
	return color


func _build_main_land() -> void:
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	for ring: int in range(RINGS):
		for sector: int in range(SECTORS):
			var p00: Vector3 = _land_point(ring, sector, RINGS, SECTORS)
			var p01: Vector3 = _land_point(ring, sector + 1, RINGS, SECTORS)
			var p10: Vector3 = _land_point(ring + 1, sector, RINGS, SECTORS)
			var p11: Vector3 = _land_point(ring + 1, sector + 1, RINGS, SECTORS)
			if ring == 0:
				var centroid: Vector3 = (p00 + p10 + p11) / 3.0
				_tri(surface, p00, p11, p10, _grass_color(p00, centroid))
			else:
				var c1: Vector3 = (p00 + p10 + p11) / 3.0
				var c2: Vector3 = (p00 + p11 + p01) / 3.0
				_tri(surface, p00, p11, p10, _grass_color(p00, c1))
				_tri(surface, p00, p01, p11, _grass_color(p00, c2))
	# The cliff skirt and rocky underside hang from the outer ring.
	var previous: Array[Vector3] = []
	for sector: int in range(SECTORS):
		previous.append(_land_point(RINGS, sector, RINGS, SECTORS))
	var layers: int = 6
	for layer: int in range(1, layers + 1):
		var t: float = float(layer) / float(layers)
		var current: Array[Vector3] = []
		for sector: int in range(SECTORS):
			var top: Vector3 = _land_point(RINGS, sector, RINGS, SECTORS)
			var inward: float = lerpf(1.0, 0.12, pow(t, 1.4))
			var depth: float = -GainlandsLayout.CLIFF_DEPTH * 0.6 * t - 24.0 * pow(maxf(t - 0.35, 0.0), 1.2)
			var jitter: float = (_noise(float(sector) * 3.1, float(layer) * 7.7) - 0.5) * 2.4
			var base_x: float = GainlandsLayout.CENTER.x + (top.x - GainlandsLayout.CENTER.x) * inward
			var base_z: float = GainlandsLayout.CENTER.y + (top.z - GainlandsLayout.CENTER.y) * inward
			current.append(Vector3(base_x, depth + jitter * t, base_z))
		for sector: int in range(SECTORS):
			var next: int = (sector + 1) % SECTORS
			var rock: Color = M.ROCK.lerp(M.ROCK_DARK, t).lightened((_noise(float(sector), float(layer)) - 0.5) * 0.12)
			if layer == 1:
				rock = Color(0.52, 0.42, 0.3).lerp(M.ROCK, 0.3).lightened((_noise(float(sector), 3.3) - 0.5) * 0.1)
			_tri(surface, previous[sector], previous[next], current[sector], rock)
			_tri(surface, previous[next], current[next], current[sector], rock.darkened(0.04))
		previous = current
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	surface.generate_normals()  # without normals the terrain ignores every directional light and shows only the ambient colour
	mesh_instance.mesh = surface.commit()
	mesh_instance.material_override = M.terrain()
	mesh_instance.set_meta(StyleToon.META_NO_TOON, true)  # the vertex-coloured terrain keeps its own material (the double-sided toon variant draws nothing on it)
	mesh_instance.name = "MainLand"
	root.add_child(mesh_instance)


func _build_islands() -> void:
	for island: GainlandsLayout.Island in layout.islands:
		var surface: SurfaceTool = SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_smooth_group(-1)
		var sectors: int = 30
		var rings: int = 5
		var height: float = island.height
		for ring: int in range(rings):
			for sector: int in range(sectors):
				var points: Array[Vector3] = []
				for pair: Vector2i in [Vector2i(ring, sector), Vector2i(ring, sector + 1), Vector2i(ring + 1, sector), Vector2i(ring + 1, sector + 1)]:
					var fraction: float = float(pair.x) / float(rings)
					var angle: float = TAU * float(pair.y % sectors) / float(sectors)
					var wobble: float = 1.0 - 0.05 * _noise(float(pair.y % sectors), island.center.x) * smoothstep(0.7, 1.0, fraction)
					points.append(Vector3(island.center.x + cos(angle) * island.radius * fraction * wobble, height, island.center.y + sin(angle) * island.radius * fraction * wobble))
				var tint: float = _noise(points[0].x, points[0].z)
				var color: Color = M.GRASS_HIGH.lerp(M.GRASS_LOW, tint * 0.6)
				if ring == 0:
					_tri(surface, points[0], points[3], points[2], color)
				else:
					_tri(surface, points[0], points[3], points[2], color)
					_tri(surface, points[0], points[1], points[3], color.lightened(0.03))
		var previous: Array[Vector3] = []
		for sector: int in range(sectors):
			var angle: float = TAU * float(sector) / float(sectors)
			var wobble: float = 1.0 - 0.05 * _noise(float(sector), island.center.x)
			previous.append(Vector3(island.center.x + cos(angle) * island.radius * wobble, height, island.center.y + sin(angle) * island.radius * wobble))
		var layers: int = 5
		for layer: int in range(1, layers + 1):
			var t: float = float(layer) / float(layers)
			var current: Array[Vector3] = []
			for sector: int in range(sectors):
				var angle: float = TAU * float(sector) / float(sectors)
				var inward: float = lerpf(1.0, 0.06, pow(t, 1.3))
				var depth: float = height - 1.4 * minf(t * 3.0, 1.0) - island.radius * 1.25 * pow(t, 1.25)
				var jitter: float = (_noise(float(sector) * 2.3, float(layer) + island.center.y) - 0.5) * 1.2
				current.append(Vector3(island.center.x + cos(angle) * island.radius * inward, depth + jitter * t, island.center.y + sin(angle) * island.radius * inward))
			for sector: int in range(sectors):
				var next: int = (sector + 1) % sectors
				var rock: Color = Color(0.5, 0.38, 0.26).lerp(M.ROCK_DARK, t) if layer == 1 else M.ROCK.lerp(M.ROCK_DARK, t)
				rock = rock.lightened((_noise(float(sector), float(layer) * 5.0) - 0.5) * 0.14)
				_tri(surface, previous[sector], previous[next], current[sector], rock)
				_tri(surface, previous[next], current[next], current[sector], rock.darkened(0.05))
			previous = current
		var instance: MeshInstance3D = MeshInstance3D.new()
		surface.generate_normals()
		instance.mesh = surface.commit()
		instance.material_override = M.terrain()
		instance.set_meta(StyleToon.META_NO_TOON, true)
		instance.name = "Island_" + island.id
		root.add_child(instance)


## The cloud models (adopted by a `CloudFader` so none can block the view).
func cloud_nodes() -> Array[Node3D]:
	return _clouds


func _build_clouds() -> void:
	var specs: Array[Vector4] = []
	var tries: int = 0
	while specs.size() < 34 and tries < 400:
		tries += 1
		var x: float = _rng.randf_range(-30.0, 135.0)
		var z: float = _rng.randf_range(-22.0, 105.0)
		if GainlandsLayout.main_depth(x, z) < 1.25:
			continue
		var blocked: bool = false
		for island: GainlandsLayout.Island in layout.islands:
			if Vector2(x - island.center.x, z - island.center.y).length() < island.radius + 6.0:
				blocked = true
		if blocked:
			continue
		specs.append(Vector4(x, _rng.randf_range(-30.0, -4.0), z, _rng.randf_range(3.5, 7.0)))
	# A thick layer well below the main land so the plateau floats in a sea of cloud.
	for index: int in range(16):
		var angle: float = TAU * float(index) / 16.0 + _rng.randf() * 0.3
		var distance: float = _rng.randf_range(10.0, 60.0)
		specs.append(Vector4(GainlandsLayout.CENTER.x + cos(angle) * distance, _rng.randf_range(-44.0, -34.0), GainlandsLayout.CENTER.y + sin(angle) * distance * 0.8, _rng.randf_range(10.0, 16.0)))
	for spec: Vector4 in specs:
		var cloud: Node3D = ModelKit.nature("cloud_big" if spec.w > 6.0 else "cloud_small")
		ModelKit.place(root, cloud, Vector3(spec.x, spec.y, spec.z), _rng.randf() * 360.0, spec.w)
		_clouds.append(cloud)


# ---- Props ----------------------------------------------------------------------------------------------


func _ground(x: float, z: float) -> Vector3:
	return Vector3(x, layout.ground_height(x, z), z)


func _build_props() -> void:
	var tree_transforms: Dictionary = {0: [], 1: []}
	var rock_transforms: Dictionary = {0: [], 1: [], 2: [], 3: [], 4: []}
	for prop: GainlandsLayout.Prop in layout.props:
		var pos: Vector3 = _ground(prop.pos.x, prop.pos.z)
		match prop.kind:
			"tree":
				var basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw)).scaled(Vector3.ONE * prop.model_scale * 1.15)
				(tree_transforms[prop.variant % 2] as Array).append(Transform3D(basis, pos))
			"boulder":
				var rock_scale: float = prop.model_scale * (1.9 if prop.radius > 0.9 else 1.35)
				var rock_basis: Basis = Basis(Vector3.UP, deg_to_rad(prop.yaw)).scaled(Vector3.ONE * rock_scale)
				(rock_transforms[prop.variant % 5] as Array).append(Transform3D(rock_basis, pos - Vector3(0, 0.1, 0)))
			_:
				_place_feature(prop, pos)
	for variant: int in tree_transforms.keys():
		_add_multimesh(KAYKIT_TREES[variant], "nature", tree_transforms[variant] as Array)
	for variant: int in rock_transforms.keys():
		_add_multimesh(KAYKIT_ROCKS[variant], "nature", rock_transforms[variant] as Array)


## One shared mesh drawn many times (trees, rocks): a MultiMesh built from a KayKit model's mesh.
func _add_multimesh(model: String, folder: String, transforms: Array) -> void:
	if transforms.is_empty():
		return
	var source: Node3D = ModelKit.hex_model("decoration/%s" % folder, model)
	var found: Array[Node] = source.find_children("*", "MeshInstance3D", true, false)
	if found.is_empty():
		source.queue_free()
		return
	var mesh_instance: MeshInstance3D = found[0] as MeshInstance3D
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh_instance.mesh
	multimesh.instance_count = transforms.size()
	for index: int in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index] as Transform3D)
	var holder: MultiMeshInstance3D = MultiMeshInstance3D.new()
	holder.multimesh = multimesh
	holder.name = "MM_" + model
	root.add_child(holder)
	source.queue_free()


func _place_feature(prop: GainlandsLayout.Prop, pos: Vector3) -> void:
	var node: Node3D = null
	var kind_scale: float = prop.model_scale
	match prop.kind:
		"mill":
			node = ModelKit.building("windmill")
			ModelKit.tint(node, Color(1.05, 1.0, 0.9))
			var fan: Node = node.find_child("building_windmill_top_fan_blue", true, false)
			if fan is Node3D:
				_fans.append(fan as Node3D)
		"station":
			node = ModelKit.building("tavern")
			kind_scale = 2.5
		"wheel":
			node = GainlandsProps.wheel(4.2, prop.variant > 0)
			var spinner: Node3D = node.get_meta("spinner") as Node3D
			spinner.set_meta("phase", float(prop.variant) * 1.3)
			spinner.set_meta("direction", -1.0 if prop.variant == 1 else 1.0)
			_spinners.append(spinner)
			if node.has_meta("bobber"):
				_hamsters.append(node.get_meta("bobber") as Node3D)
		"bench_press":
			node = GainlandsProps.bench_press()
		"log_rack":
			node = GainlandsProps.log_rack()
		"dumbbell_rack":
			node = GainlandsProps.dumbbell_rack()
		"barbell":
			node = GainlandsProps.lying_barbell()
		"tub":
			node = GainlandsProps.tub()
			if node.has_meta("bobber"):
				_bobbers.append(node.get_meta("bobber") as Node3D)
		"stall":
			node = GainlandsProps.stall(M.CLOTH_RED if prop.variant == 0 else M.CLOTH_BLUE)
		"arch":
			node = GainlandsProps.arch()
			if node.has_meta("spinner_z"):
				_z_spinners.append(node.get_meta("spinner_z") as Node3D)
		"gate":
			node = GainlandsProps.gate()
		"cavern":
			var mountain: Node3D = ModelKit.nature("mountain_A")
			ModelKit.place(root, mountain, pos + Vector3(0, -0.4, -1.8), 0.0, 3.4)
			node = GainlandsProps.cavern_mouth()
			node.position = pos + Vector3(0, 0, 2.2)
			root.add_child(node)
			return
		"stage":
			node = GainlandsProps.stage()
			if node.has_meta("screen"):
				_screens.append(node.get_meta("screen") as MeshInstance3D)
		"mirror":
			node = GainlandsProps.mirror()
		"hut":
			node = GainlandsProps.lecture_log()
		"crystal":
			node = GainlandsProps.crystal()
			if node.has_meta("bobber"):
				_bobbers.append(node.get_meta("bobber") as Node3D)
			if node.has_meta("spinner_y"):
				_y_spinners.append(node.get_meta("spinner_y") as Node3D)
		"pylon":
			return
		_:
			return
	root.add_child(node)
	node.position = pos
	node.rotation_degrees.y = prop.yaw
	if prop.kind in ["mill", "station"]:
		node.scale = Vector3.ONE * kind_scale
	elif prop.kind == "wheel":
		node.scale = Vector3.ONE * kind_scale
	else:
		node.scale = Vector3.ONE * (kind_scale if kind_scale != 1.0 else 1.0)


# ---- Energy pipes -----------------------------------------------------------------------------------


func _build_pipes() -> void:
	for line: PackedVector2Array in layout.pipes:
		var points: Array[Vector3] = []
		var length: float = 0.0
		for i: int in range(line.size() - 1):
			var a: Vector2 = line[i]
			var b: Vector2 = line[i + 1]
			var count: int = maxi(1, int(a.distance_to(b) / 1.6))
			for step: int in range(count):
				var p: Vector2 = a.lerp(b, float(step) / float(count))
				points.append(Vector3(p.x, layout.ground_height(p.x, p.y) + 0.4, p.y))
		var last: Vector2 = line[line.size() - 1]
		points.append(Vector3(last.x, layout.ground_height(last.x, last.y) + 0.4, last.y))
		var cumulative: PackedFloat32Array = PackedFloat32Array([0.0])
		for i: int in range(points.size() - 1):
			GainlandsProps.pipe_segment(root, points[i], points[i + 1])
			length += points[i].distance_to(points[i + 1])
			cumulative.append(length)
			if i % 3 == 0:
				var post: MeshInstance3D = MeshInstance3D.new()
				var post_mesh: BoxMesh = BoxMesh.new()
				post_mesh.size = Vector3(0.18, 0.6, 0.18)
				post.mesh = post_mesh
				post.material_override = M.flat(M.WOOD_DARK)
				post.position = points[i] - Vector3(0, 0.3, 0)
				root.add_child(post)
		for k: int in range(3):
			var pulse: MeshInstance3D = MeshInstance3D.new()
			var sphere: SphereMesh = SphereMesh.new()
			sphere.radius = 0.26
			sphere.height = 0.52
			sphere.radial_segments = 6
			sphere.rings = 3
			pulse.mesh = sphere
			pulse.material_override = M.glow(M.ENERGY, 3.2)
			root.add_child(pulse)
			_pulses.append({"node": pulse, "points": points, "cumulative": cumulative, "length": length, "offset": length * float(k) / 3.0, "speed": 3.2})


# ---- Signs and chests -----------------------------------------------------------------------------------


func _build_signs() -> void:
	for sign: GainlandsLayout.Sign in layout.signs:
		var lines: Array[String] = story.get_lines(sign.key)
		var longest: int = 0
		for line: String in lines:
			longest = maxi(longest, line.length())
		var width: float = clampf(float(longest) * 0.07 * sign.size + 0.7, 1.8, 3.8)
		var wrapped: int = 0
		for line: String in lines:
			wrapped += maxi(1, int(ceilf(float(line.length()) * 0.07 * sign.size / (width - 0.5))))
		var height: float = clampf(0.5 + 0.34 * float(wrapped) * sign.size, 0.9, 3.0)
		var node: Node3D = GainlandsProps.sign_post(width, height, sign.style)
		node.scale = Vector3.ONE * 0.8
		var pos: Vector3 = _ground(sign.pos.x, sign.pos.z)
		root.add_child(node)
		node.position = pos
		node.rotation_degrees.y = sign.yaw + 180.0
		var label: Label3D = Label3D.new()
		label.text = "\n".join(lines)
		label.font = UIStyle.font_title()
		label.font_size = 40
		label.pixel_size = 0.0058 * sign.size
		label.modulate = Color(0.2, 0.1, 0.04)
		label.outline_size = 0
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.width = (width - 0.4) / label.pixel_size
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.double_sided = false
		var mid: float = 1.45 + height * 0.5
		if sign.style == "poster":
			mid = 1.4 + height * 0.5
		elif sign.style == "memo":
			mid = 1.1 + height * 0.5
		label.position = Vector3(0, mid, 0.1)
		node.add_child(label)


var _chest_visible_count: int = 0


func _build_chests() -> void:
	var positions: Dictionary = chest_positions()
	for id: String in positions.keys():
		var pos: Vector3 = positions[id] as Vector3
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		root.add_child(chest)
		chest.position = pos
		chest.rotation_degrees.y = _rng.randf() * 360.0
		chest.scale = Vector3.ONE * 0.225
		chest_nodes[id] = chest


# ---- Animation -----------------------------------------------------------------------------------------


func animate(delta: float) -> void:
	_time += delta
	for spinner: Node3D in _spinners:
		var direction: float = float(spinner.get_meta("direction", 1.0))
		spinner.rotation.z += wheel_speed * direction * delta
	for hamster: Node3D in _hamsters:
		hamster.position.y = 0.9 + absf(sin(_time * 9.0)) * 0.12
	for fan: Node3D in _fans:
		fan.rotate_object_local(Vector3.FORWARD, 0.7 * delta)
	for bobber: Node3D in _bobbers:
		bobber.position.y += sin(_time * 1.7 + bobber.position.x) * 0.002
	for spinner_y: Node3D in _y_spinners:
		spinner_y.rotation.y += 1.1 * delta
	for spinner_z: Node3D in _z_spinners:
		spinner_z.rotation.y += 0.8 * delta
	for screen: MeshInstance3D in _screens:
		var hue: float = fposmod(_time * 0.12, 1.0)
		screen.material_override = M.glow(Color.from_hsv(hue, 0.55, 1.0), 1.2)
	for cloud: Node3D in _clouds:
		cloud.position.x += 0.35 * delta
		if cloud.position.x > 150.0:
			cloud.position.x = -45.0
	for pulse: Dictionary in _pulses:
		var distance: float = fposmod(float(pulse["offset"]) + _time * float(pulse["speed"]), float(pulse["length"]))
		var cumulative: PackedFloat32Array = pulse["cumulative"] as PackedFloat32Array
		var points: Array = pulse["points"] as Array
		var index: int = 0
		while index < cumulative.size() - 2 and cumulative[index + 1] < distance:
			index += 1
		var span: float = maxf(cumulative[index + 1] - cumulative[index], 0.001)
		var along: float = clampf((distance - cumulative[index]) / span, 0.0, 1.0)
		(pulse["node"] as Node3D).position = (points[index] as Vector3).lerp(points[index + 1] as Vector3, along) + Vector3(0, 0.1, 0)
