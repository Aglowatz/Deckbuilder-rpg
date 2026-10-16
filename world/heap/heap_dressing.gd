class_name HeapDressing
extends RefCounted
## The hand-dressed pass for the Verdant Dump (docs/art/heap_slice.md, Art Part D): the zone kit's clusters (data/art/zone_kits/heap_clusters.json) at the
## shacks' doors, the hub's rim, the farm, Gristle's stall, the fair, the tyre wall, the throne avenue and the goat stable, reeds along the stream banks and
## violet fungus in the wetlands (those two only while the zone is not freed: freed, the fungus gives way to tyre gardens). Nothing goes on a route, in
## the plaza, on the entrance bridge, within reach of an anchor or a chest, or within 2.5 m of another cluster; solid pieces register blockers. The generic
## dressing keeps only its grass carpet (VD-5).

var root: Node3D
var count: int = 0
var _builder: HeapBuilder
var _anchors: Array[Vector3] = []
var _chests: Array[Vector3] = []
var _placed: Array[Vector2] = []

## cluster, world position (x, z), yaw (the back of the cluster faces -z rotated by yaw).
const KIT_CLUSTERS: Array = [
	# the Commons: by the barn door, the stall, the compost bin, the trough and the shrine
	["tyre_garden", Vector2(33.6, 61.2), 200.0],
	["scrap_sorting", Vector2(67.8, 56.0), 200.0],
	["compost_corner", Vector2(61.5, 75.2), 180.0],
	["goat_cart", Vector2(67.0, 75.6), 190.0],
	["tyre_garden", Vector2(73.6, 74.6), 180.0],
	# the farm rows: the crop row's end and the grove
	["compost_corner", Vector2(27.6, 59.2), 270.0],
	["bottle_wall", Vector2(13.8, 61.2), 180.0],
	# the junk peaks: the fair's back and the secret corner
	["scrap_sorting", Vector2(68.4, 52.6), 160.0],
	["bottle_wall", Vector2(84.0, 75.0), 180.0],
	# the stream: the goat stable's yard
	["goat_cart", Vector2(8.2, 42.0), 90.0],
	# the tyre wall's south face either side of the barricade gap, and the throne avenue
	["bottle_wall", Vector2(44.6, 31.8), 180.0],
	["bottle_wall", Vector2(56.2, 31.8), 180.0],
	["tyre_garden", Vector2(26.6, 19.2), 90.0],
	["scrap_sorting", Vector2(35.8, 17.0), 270.0],
]
## Wet and sick ground (non-solid): reeds along both banks of the stream, fungus in the wetlands toward the roots.
const SOFT_CLUSTERS: Array = [
	["reed_bank", Vector2(9.0, 0.0), 0.0], ["reed_bank", Vector2(29.0, 0.0), 0.0], ["reed_bank", Vector2(42.0, 0.0), 0.0], ["reed_bank", Vector2(58.0, 0.0), 0.0],
	["reed_bank", Vector2(70.0, 0.0), 0.0], ["reed_bank", Vector2(88.0, 0.0), 0.0], ["reed_bank", Vector2(15.0, 0.0), 180.0], ["reed_bank", Vector2(36.0, 0.0), 180.0],
	["reed_bank", Vector2(63.0, 0.0), 180.0], ["reed_bank", Vector2(84.0, 0.0), 180.0],
	["fungus_patch", Vector2(43.0, 18.5), 90.0], ["fungus_patch", Vector2(57.5, 17.0), 270.0], ["fungus_patch", Vector2(44.0, 11.0), 60.0], ["fungus_patch", Vector2(56.5, 12.0), 300.0],
	["fungus_patch", Vector2(41.0, 23.0), 90.0], ["fungus_patch", Vector2(59.5, 22.5), 270.0],
]


static func build(parent: Node3D, builder: HeapBuilder, _quality: int) -> HeapDressing:
	var dressing: HeapDressing = HeapDressing.new()
	dressing.root = Node3D.new()
	dressing.root.name = "HeapDressing"
	parent.add_child(dressing.root)
	dressing._builder = builder
	for key: Variant in builder.layout.anchors.keys():
		dressing._anchors.append(builder.anchor(str(key)))
	for pos: Variant in builder.layout.chests.values():
		dressing._chests.append(pos as Vector3)
	var index: int = 0
	for entry: Array in KIT_CLUSTERS:
		index += 1
		dressing._place(str(entry[0]), entry[1] as Vector2, float(entry[2]), 900 + index, 4.0)
	for entry: Array in SOFT_CLUSTERS:
		index += 1
		var name: String = str(entry[0])
		var at: Vector2 = entry[1] as Vector2
		if name == "reed_bank":
			# along the bank: the stream's centre line plus the half width and a little, north (180) or south (0) of the water
			var side: float = 1.0 if float(entry[2]) < 90.0 else -1.0
			at = Vector2(at.x, HeapLayout.stream_z(at.x) + side * (HeapLayout.STREAM_HALF_WIDTH + 0.9))
		elif builder.freed:
			name = "tyre_garden"
		dressing._place(name, at, float(entry[2]), 900 + index, 2.5)
	return dressing


func _place(cluster_name: String, at: Vector2, yaw: float, seed_value: int, clearance: float) -> void:
	var pos: Vector3 = Vector3(at.x, _builder.layout.ground_height(at.x, at.y), at.y)
	var cluster: Node3D = PropClusters.make(cluster_name, seed_value)
	if cluster == null:
		return
	var solid: bool = not (cluster.get_meta("circles", []) as Array).is_empty()
	if not _free(pos, clearance if solid else 2.0, 2.5, solid):
		cluster.free()
		return
	cluster.name = "Cluster_%s_%d" % [cluster_name, seed_value]
	root.add_child(cluster)
	cluster.position = pos
	cluster.rotation_degrees.y = yaw
	_placed.append(at)
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
	for circle: Variant in cluster.get_meta("circles", []) as Array:
		var local: Vector3 = circle as Vector3
		var world: Vector3 = pos + basis * Vector3(local.x, 0.0, local.y)
		_builder.add_blocker(Vector3(world.x, 0.0, world.z), local.z)
	count += 1


## Free ground for a cluster: on the land and walkable (a reed bank may stand on the bank's slope), off the routes (solid pieces), off the plaza and the entrance,
## `clearance` from every anchor, 2 m from every chest, `spacing` from the other clusters, never inside a landmark's kept-clear spot.
func _free(pos: Vector3, clearance: float, spacing: float, solid: bool) -> bool:
	var layout: HeapLayout = _builder.layout
	if HeapLayout.edge_distance(pos.x, pos.z) < 1.5:
		return false
	if solid and (not _builder.is_walkable(pos, 0.6) or layout.path_edge_distance(pos.x, pos.z) < HeapLayout.PATH_CLEARANCE):
		return false
	if not solid and layout.path_edge_distance(pos.x, pos.z) < 0.6:
		return false
	if Vector2(pos.x - HeapLayout.PLAZA_CENTER.x, pos.z - HeapLayout.PLAZA_CENTER.y).length() < HeapLayout.PLAZA_RADIUS + 1.0:
		return false
	if HeapLayout.on_entrance(pos.x, pos.z):
		return false
	for spot: Vector3 in HeapLayout.LANDMARK_SPOTS:
		if Vector2(pos.x - spot.x, pos.z - spot.y).length() < spot.z:
			return false
	for anchor: Vector3 in _anchors:
		if Vector2(pos.x - anchor.x, pos.z - anchor.z).length() < clearance:
			return false
	for chest: Vector3 in _chests:
		if Vector2(pos.x - chest.x, pos.z - chest.z).length() < 2.0:
			return false
	for other: Vector2 in _placed:
		if other.distance_to(Vector2(pos.x, pos.z)) < spacing:
			return false
	return true
