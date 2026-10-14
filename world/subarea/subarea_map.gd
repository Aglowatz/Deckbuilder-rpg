class_name SubAreaMap
extends WalkableArea
## The geometry and walkability of one sub-area blockout (data/subareas/<area>/<sub>.json, see `SubAreaDefs`): a rectangular ground in the zone's kit surface, paths, ponds,
## kit buildings (`BuildingPresets`), hero landmark stand-ins (`LandmarkKit`), prop clusters and props (`PropClusters` / `PropKit`), painted trees (`TreeCards`) and a tree belt
## round the edge. Everything solid registers circle obstacles. Plain data in, nodes out: gameplay (spots, chests, exits) is read from the same dictionary by `SubAreaScene`.
##
## Data keys (all optional but `size`): size [w, d] (centred on the origin), ground {kind: grass|dirt|cobble}, spawn [x, z], paths [{kind, width, points [[x, z]...]}],
## water [{pos [x, z], size [w, d], color}], buildings [{preset, pos [x, z], yaw, overrides}], landmarks [{kind, pos, yaw, size [w, h, d], color, accent, glow, id}],
## clusters [{name, pos, yaw}], props [{name, pos, yaw, length}], trees [{kind, pos, scale}], edge {kind, spacing, scale}, flowers [{pos, radius, count}].

const EDGE_MARGIN: float = 1.4
## Trees stay 2.5-4 heroes tall (Art Bible G-01): the kit cards are 4.4-6.6 m, so their scale is kept in this range whatever a data file says.
const TREE_SCALE_MIN: float = 0.8
const TREE_SCALE_MAX: float = 1.25
const GROUND_KINDS: Dictionary = {
	"grass": "ENV-GROUND-GRASS-CALM",
	"dirt": "ENV-GROUND-DIRTPATH",
	"cobble": "ENV-GROUND-COBBLE",
	# zone grounds (the painted texture set through the zone kit aliases)
	"chalkdirt": "TEX-GAIN-CHALKDIRT",
	"gymmat": "TEX-GAIN-GYMMAT",
	"hay": "TEX-GAIN-HAY",
}

var data: Dictionary = {}
var half: Vector2 = Vector2(30.0, 30.0)
## (x, z, radius): solid circles (buildings, landmarks, trees, props, NPC bodies).
var obstacles: Array[Vector3] = []
## (x, z, w, d) rectangles nobody may walk on (ponds).
var no_walk: Array[Rect2] = []
var root: Node3D
## Tests: build without the barrier landmarks (levers open them) to check everything is reachable once they are gone.
var skip_barriers: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _flowers: Array[Dictionary] = []


func _init(def_data: Dictionary = {}) -> void:
	data = def_data
	var size: Array = data.get("size", [60.0, 60.0]) as Array
	half = Vector2(float(size[0]) * 0.5, float(size[1]) * 0.5)
	_rng.seed = hash(str(data.get("id", "sub")))


static func pos3(value: Variant) -> Vector3:
	var arr: Array = value as Array
	return Vector3(float(arr[0]), 0.0, float(arr[1]))


func spawn() -> Vector3:
	return pos3(data.get("spawn", [0.0, half.y - 6.0]))


func add_blocker(pos: Vector3, radius: float) -> void:
	obstacles.append(Vector3(pos.x, pos.z, radius))


func is_walkable(pos: Vector3, body_radius: float = StorybookScale.BODY_RADIUS) -> bool:
	if absf(pos.x) > half.x - EDGE_MARGIN or absf(pos.z) > half.y - EDGE_MARGIN:
		return false
	for rect: Rect2 in no_walk:
		if rect.grow(body_radius * 0.5).has_point(Vector2(pos.x, pos.z)):
			return false
	for obstacle: Vector3 in obstacles:
		var dx: float = pos.x - obstacle.x
		var dz: float = pos.z - obstacle.y
		var reach: float = obstacle.z + body_radius
		if dx * dx + dz * dz < reach * reach:
			return false
	return true


func is_floor_at(pos: Vector3) -> bool:
	return absf(pos.x) <= half.x and absf(pos.z) <= half.y


func map_bounds() -> Rect2:
	return Rect2(-half.x, -half.y, half.x * 2.0, half.y * 2.0)


func has_line_of_sight(a: Vector3, b: Vector3) -> bool:
	var steps: int = maxi(1, int(a.distance_to(b) / 0.8))
	for index: int in range(steps + 1):
		var p: Vector3 = a.lerp(b, float(index) / float(steps))
		for obstacle: Vector3 in obstacles:
			if Vector2(p.x - obstacle.x, p.z - obstacle.y).length() < obstacle.z * 0.8:
				return false
	return true


# ---- Building --------------------------------------------------------------------------------------------------------------------------


func build(parent: Node3D) -> void:
	root = Node3D.new()
	root.name = "SubArea_%s" % str(data.get("id", "sub"))
	parent.add_child(root)
	_ground()
	_paths()
	_plazas()
	_water()
	_buildings()
	_landmarks()
	_clusters()
	_props()
	_trees()
	_scatter()
	_edge()
	_flower_clumps()
	_decals()


func _ground() -> void:
	var kind: String = str((data.get("ground", {}) as Dictionary).get("kind", "grass"))
	var id: String = str(GROUND_KINDS.get(kind, GROUND_KINDS["grass"]))
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("ground", EnvKit.material(id))
	var tile: float = EnvKit.tile_size(ZoneStyles.swap(id))
	var tile_v: float = EnvKit.tile_size_v(ZoneStyles.swap(id))
	var rect: Array = [Vector2(-half.x, -half.y), Vector2(half.x, -half.y), Vector2(half.x, half.y), Vector2(-half.x, half.y)]
	var corners: Array[Vector3] = []
	var uvs: Array[Vector2] = []
	for corner: Variant in rect:
		var c: Vector2 = corner as Vector2
		corners.append(Vector3(c.x, 0.0, c.y))
		uvs.append(Vector2(c.x / tile, c.y / tile_v))
	mesh.quad("ground", corners, Vector3.UP, [], uvs)
	var apron: float = 220.0
	var apron_corners: Array[Vector3] = [Vector3(-apron, -0.06, -apron), Vector3(apron, -0.06, -apron), Vector3(apron, -0.06, apron), Vector3(-apron, -0.06, apron)]
	var apron_uvs: Array[Vector2] = []
	for corner: Vector3 in apron_corners:
		apron_uvs.append(Vector2(corner.x / tile, corner.z / tile_v))
	mesh.quad("ground", apron_corners, Vector3.UP, [], apron_uvs)
	var node: MeshInstance3D = mesh.instance("Ground")
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(node)


func _paths() -> void:
	var index: int = 0
	for item: Variant in data.get("paths", []) as Array:
		var entry: Dictionary = item as Dictionary
		var control: Array[Vector3] = []
		for point: Variant in entry.get("points", []) as Array:
			control.append(pos3(point))
		if control.size() < 2:
			continue
		PathTool.build(root, control, {"width": float(entry.get("width", 3.4)), "kind": str(entry.get("kind", "dirt")), "seed": 40 + index, "clumps": 0.6})
		index += 1


func _plazas() -> void:
	var index: int = 0
	for item: Variant in data.get("plazas", []) as Array:
		var entry: Dictionary = item as Dictionary
		PathTool.plaza(root, pos3(entry["pos"]), float(entry.get("radius", 8.0)), {"seed": 60 + index})
		index += 1


func _water() -> void:
	for item: Variant in data.get("water", []) as Array:
		var entry: Dictionary = item as Dictionary
		var pos: Vector3 = pos3(entry["pos"])
		var size_arr: Array = entry.get("size", [8.0, 8.0]) as Array
		var landmark: Node3D = LandmarkKit.build({"kind": "river", "size": [float(size_arr[0]), 0.1, float(size_arr[1])], "water": str(entry.get("color", "#6fb0d8")), "id": "water"})
		root.add_child(landmark)
		landmark.position = pos + Vector3(0, 0.03, 0)
		no_walk.append(Rect2(pos.x - float(size_arr[0]) * 0.5, pos.z - float(size_arr[1]) * 0.5, float(size_arr[0]), float(size_arr[1])))


func _buildings() -> void:
	for item: Variant in data.get("buildings", []) as Array:
		var entry: Dictionary = item as Dictionary
		var preset: String = str(entry.get("preset", "home_a"))
		var overrides: Dictionary = entry.get("overrides", {}) as Dictionary
		var building: Node3D = BuildingPresets.build(preset, overrides)
		var pos: Vector3 = pos3(entry["pos"])
		var yaw: float = float(entry.get("yaw", 0.0))
		root.add_child(building)
		building.position = pos
		building.rotation_degrees.y = yaw
		var spec: Dictionary = BuildingPresets.spec(preset, overrides)
		var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
		for circle: Vector3 in BuildingKit.obstacle_circles(spec, 0.05):
			var world: Vector3 = pos + basis * Vector3(circle.x, 0.0, circle.y)
			obstacles.append(Vector3(world.x, world.z, circle.z))
		TownKit.dress(root, building, spec)


func _landmarks() -> void:
	for item: Variant in data.get("landmarks", []) as Array:
		var entry: Dictionary = item as Dictionary
		if skip_barriers and entry.has("barrier"):
			continue
		var landmark: Node3D = LandmarkKit.build(entry)
		if entry.has("barrier"):
			landmark.set_meta("barrier", str(entry["barrier"]))
		var pos: Vector3 = pos3(entry["pos"])
		var yaw: float = float(entry.get("yaw", 0.0))
		root.add_child(landmark)
		landmark.position = pos + Vector3(0, float(entry.get("lift", 0.0)), 0)
		landmark.rotation_degrees.y = yaw
		if not bool(entry.get("no_collide", false)):
			_register_circles(landmark, pos, yaw)


func _clusters() -> void:
	var index: int = 0
	for item: Variant in data.get("clusters", []) as Array:
		var entry: Dictionary = item as Dictionary
		var cluster: Node3D = PropClusters.make(str(entry.get("name", "crates")), 900 + index)
		index += 1
		var pos: Vector3 = pos3(entry["pos"])
		var yaw: float = float(entry.get("yaw", 0.0))
		root.add_child(cluster)
		cluster.position = pos
		cluster.rotation_degrees.y = yaw
		_register_circles(cluster, pos, yaw)


func _props() -> void:
	var index: int = 0
	for item: Variant in data.get("props", []) as Array:
		var entry: Dictionary = item as Dictionary
		var prop: Node3D = PropKit.make(str(entry.get("name", "barrel")), float(entry.get("length", 3.2)), 700 + index)
		index += 1
		if prop == null:
			continue
		var pos: Vector3 = pos3(entry["pos"])
		var yaw: float = float(entry.get("yaw", 0.0))
		root.add_child(prop)
		prop.position = pos
		prop.rotation_degrees.y = yaw
		prop.scale = Vector3.ONE * float(entry.get("scale", 1.0))
		var radius: float = float(prop.get_meta("radius", 0.0)) * float(entry.get("scale", 1.0))
		if radius > 0.0 and not bool(entry.get("walk_through", false)):
			obstacles.append(Vector3(pos.x, pos.z, radius))
		_register_circles(prop, pos, yaw)


func _register_circles(node: Node3D, pos: Vector3, yaw: float) -> void:
	if not node.has_meta("circles"):
		return
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
	for circle: Variant in node.get_meta("circles") as Array:
		var local: Vector3 = circle as Vector3
		var world: Vector3 = pos + basis * Vector3(local.x, 0.0, local.y)
		obstacles.append(Vector3(world.x, world.z, local.z))


func _trees() -> void:
	for item: Variant in data.get("trees", []) as Array:
		var entry: Dictionary = item as Dictionary
		var kind: String = str(entry.get("kind", "oak"))
		var scale_value: float = clampf(float(entry.get("scale", 1.0)), TREE_SCALE_MIN, TREE_SCALE_MAX)
		var tree: Node3D = TreeCards.make(kind, scale_value, true)
		var pos: Vector3 = pos3(entry["pos"])
		root.add_child(tree)
		tree.position = pos
		obstacles.append(Vector3(pos.x, pos.z, float(tree.get_meta("radius", 0.4))))


## A belt of trees round the edge (the world beyond is the look rig's scenery): spacing and size vary so it never reads as a fence.
func _edge() -> void:
	var edge: Dictionary = data.get("edge", {}) as Dictionary
	var kind: String = str(edge.get("kind", "oak"))
	if kind == "none":
		return
	var spacing: float = float(edge.get("spacing", 6.5))
	var scale_range: Array = edge.get("scale", [1.1, 1.7]) as Array
	var kinds: Array = edge.get("kinds", [kind]) as Array
	var entries: Dictionary = {}
	var perimeter: Array[Vector3] = []
	var inset: float = EDGE_MARGIN + 0.8
	var x: float = -half.x + inset
	while x <= half.x - inset:
		perimeter.append(Vector3(x, 0.0, -half.y + inset))
		perimeter.append(Vector3(x, 0.0, half.y - inset))
		x += spacing * _rng.randf_range(0.75, 1.25)
	var z: float = -half.y + inset + spacing
	while z <= half.y - inset - spacing:
		perimeter.append(Vector3(-half.x + inset, 0.0, z))
		perimeter.append(Vector3(half.x - inset, 0.0, z))
		z += spacing * _rng.randf_range(0.75, 1.25)
	var clear_points: Array[Vector3] = [spawn()]
	for item: Variant in data.get("exits", []) as Array:
		clear_points.append(pos3((item as Dictionary)["pos"]))
	for point: Vector3 in perimeter:
		var blocked: bool = false
		for clear: Vector3 in clear_points:
			if Vector2(point.x - clear.x, point.z - clear.z).length() < 8.0:
				blocked = true
		if blocked:
			continue
		var jittered: Vector3 = point + Vector3(_rng.randf_range(-1.0, 1.0), 0.0, _rng.randf_range(-1.0, 1.0))
		var tree_kind: String = str(kinds[_rng.randi() % kinds.size()])
		if not entries.has(tree_kind):
			entries[tree_kind] = []
		(entries[tree_kind] as Array).append({"pos": jittered, "scale": clampf(_rng.randf_range(float(scale_range[0]), float(scale_range[1])), TREE_SCALE_MIN, TREE_SCALE_MAX)})
		obstacles.append(Vector3(jittered.x, jittered.z, 0.5))
	for tree_kind: Variant in entries.keys():
		var typed: Array[Dictionary] = []
		for entry: Variant in entries[tree_kind] as Array:
			typed.append(entry as Dictionary)
		KitFoliage.tree_field(root, str(tree_kind), typed, false)


## Seeded scatter (`scatter`: [{kind: tree|cluster|prop, name, count, rect [x, z, w, d], scale [min, max]?, gap?}]): items go where nothing solid, no path, no spawn,
## no point of interest and no exit is near, so a blockout needs no hand-placed filler. Props gather in loose groups (G-05), never an even spread.
func _scatter() -> void:
	var keep_clear: Array[Vector3] = [spawn()]
	for key: String in ["poi", "exits"]:
		for item: Variant in data.get(key, []) as Array:
			keep_clear.append(pos3((item as Dictionary)["pos"]))
	var path_points: Array[Vector3] = []
	for item: Variant in data.get("paths", []) as Array:
		var control: Array[Vector3] = []
		for point: Variant in (item as Dictionary).get("points", []) as Array:
			control.append(pos3(point))
		path_points.append_array(PathTool.smooth(control, 1.5))
	var tree_groups: Dictionary = {}
	var index: int = 0
	for item: Variant in data.get("scatter", []) as Array:
		var entry: Dictionary = item as Dictionary
		var rect_arr: Array = entry.get("rect", [-half.x * 2.0 / 3.0, -half.y * 2.0 / 3.0, half.x * 4.0 / 3.0, half.y * 4.0 / 3.0]) as Array
		var rect: Rect2 = Rect2(float(rect_arr[0]), float(rect_arr[1]), float(rect_arr[2]), float(rect_arr[3]))
		var kind: String = str(entry.get("kind", "tree"))
		var item_name: String = str(entry.get("name", "oak"))
		var scale_range: Array = entry.get("scale", [1.0, 1.0]) as Array
		var placed: int = 0
		var tries: int = 0
		var want: int = int(entry.get("count", 6))
		var gap: float = float(entry.get("gap", 3.0))
		var cluster_anchor: Vector3 = Vector3.ZERO
		while placed < want and tries < want * 40:
			tries += 1
			var p: Vector3 = Vector3(rect.position.x + _rng.randf() * rect.size.x, 0.0, rect.position.y + _rng.randf() * rect.size.y)
			if placed > 0 and bool(entry.get("grouped", kind != "tree")) and tries % 3 != 0:
				p = cluster_anchor + Vector3(_rng.randf_range(-5.0, 5.0), 0.0, _rng.randf_range(-5.0, 5.0))
			if not _scatter_ok(p, gap, keep_clear, path_points, float(entry.get("path_gap", 2.6))):
				continue
			if placed == 0 or tries % 3 == 0:
				cluster_anchor = p
			var yaw: float = _rng.randf_range(-25.0, 25.0) if kind == "cluster" else _rng.randf() * 360.0
			var scale_value: float = _rng.randf_range(float(scale_range[0]), float(scale_range[1]))
			if kind == "tree":
				scale_value = clampf(scale_value, TREE_SCALE_MIN, TREE_SCALE_MAX)
			match kind:
				"tree":
					if not tree_groups.has(item_name):
						tree_groups[item_name] = []
					(tree_groups[item_name] as Array).append({"pos": p, "scale": scale_value})
					obstacles.append(Vector3(p.x, p.z, 0.45 * scale_value))
				"cluster":
					var cluster: Node3D = PropClusters.make(item_name, 1300 + index)
					root.add_child(cluster)
					cluster.position = p
					cluster.rotation_degrees.y = yaw
					_register_circles(cluster, p, yaw)
				_:
					var prop: Node3D = PropKit.make(item_name, float(entry.get("length", 3.2)), 1700 + index)
					if prop == null:
						continue
					root.add_child(prop)
					prop.position = p
					prop.rotation_degrees.y = yaw
					prop.scale = Vector3.ONE * scale_value
					obstacles.append(Vector3(p.x, p.z, maxf(float(prop.get_meta("radius", 0.4)) * scale_value, 0.3)))
			index += 1
			placed += 1
	for tree_kind: Variant in tree_groups.keys():
		var typed: Array[Dictionary] = []
		for entry: Variant in tree_groups[tree_kind] as Array:
			typed.append(entry as Dictionary)
		var tree_root: Node3D = Node3D.new()
		tree_root.name = "ScatterTrees_%s" % str(tree_kind)
		root.add_child(tree_root)
		for tree_entry: Dictionary in typed:
			var tree: Node3D = TreeCards.make(str(tree_kind), float(tree_entry["scale"]), false)
			if tree != null:
				tree_root.add_child(tree)
				tree.position = tree_entry["pos"] as Vector3


func _scatter_ok(p: Vector3, gap: float, keep_clear: Array[Vector3], path_points: Array[Vector3], path_gap: float) -> bool:
	if absf(p.x) > half.x - EDGE_MARGIN - 2.5 or absf(p.z) > half.y - EDGE_MARGIN - 2.5:
		return false
	for clear: Vector3 in keep_clear:
		if Vector2(p.x - clear.x, p.z - clear.z).length() < 3.2:
			return false
	for obstacle: Vector3 in obstacles:
		if Vector2(p.x - obstacle.x, p.z - obstacle.y).length() < obstacle.z + gap:
			return false
	for rect: Rect2 in no_walk:
		if rect.grow(1.5).has_point(Vector2(p.x, p.z)):
			return false
	for point: Vector3 in path_points:
		if Vector2(p.x - point.x, p.z - point.z).length() < path_gap:
			return false
	return true


## Ground decals from the zone kit ("decals": [{id, pos [x, z], size (m), yaw}]): flat cut-out quads just above the ground (chalk, plates, sweat, wheel ruts), one surface per id.
func _decals() -> void:
	var by_id: Dictionary = {}
	for item: Variant in data.get("decals", []) as Array:
		var entry: Dictionary = item as Dictionary
		var id: String = str(entry.get("id", ""))
		if not EnvKit.has_art(id):
			continue
		if not by_id.has(id):
			by_id[id] = []
		(by_id[id] as Array).append(entry)
	if by_id.is_empty():
		return
	var mesh: KitMesh = KitMesh.new()
	for id: String in by_id.keys():
		var material: StandardMaterial3D = EnvKit.material(id, true).duplicate() as StandardMaterial3D
		material.render_priority = 4
		material.cull_mode = BaseMaterial3D.CULL_BACK
		mesh.set_material(id, material)
		var aspect: float = EnvKit.aspect(id)
		for item: Variant in by_id[id] as Array:
			var entry: Dictionary = item as Dictionary
			var pos: Vector3 = pos3(entry["pos"]) + Vector3(0, 0.05, 0)
			var size: float = float(entry.get("size", 2.0))
			var basis: Basis = Basis(Vector3.UP, deg_to_rad(float(entry.get("yaw", 0.0))))
			var hw: float = size * 0.5 * (aspect if aspect > 1.0 else 1.0)
			var hd: float = size * 0.5 * (1.0 / aspect if aspect < 1.0 else 1.0)
			var corners: Array[Vector3] = [pos + basis * Vector3(-hw, 0, hd), pos + basis * Vector3(hw, 0, hd), pos + basis * Vector3(hw, 0, -hd), pos + basis * Vector3(-hw, 0, -hd)]
			mesh.quad(id, corners, Vector3.UP, [], [Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)])
	var node: MeshInstance3D = mesh.instance("KitDecals")
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(node)


func _flower_clumps() -> void:
	var entries: Array[Dictionary] = []
	for item: Variant in data.get("flowers", []) as Array:
		var entry: Dictionary = item as Dictionary
		entries.append({"pos": pos3(entry["pos"]), "radius": float(entry.get("radius", 1.2)), "count": int(entry.get("count", 8)), "cells": entry.get("cells", [2, 0, 3])})
	# A few natural clumps at path edges and wall bases: seeded scatter near the spawn and each landmark.
	for item: Variant in data.get("landmarks", []) as Array:
		var entry: Dictionary = item as Dictionary
		var p: Vector3 = pos3(entry["pos"])
		entries.append({"pos": p + Vector3(_rng.randf_range(-3.0, 3.0), 0.0, 3.5 + _rng.randf_range(0.0, 2.0)), "radius": 1.3, "count": 7, "cells": [0, 2, 3]})
	if entries.is_empty() or str(data.get("flora", "on")) == "off":
		return
	KitFoliage.clumps(root, entries, hash(str(data.get("id", "sub"))) % 1000, func(pos: Vector3) -> bool: return is_walkable(pos, 0.0))
