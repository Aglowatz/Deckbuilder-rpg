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
	# the market terrace: by the barn door, behind the stall, the compost bin, the trough and the shrine, the east corner
	["tyre_garden", Vector2(33.0, 108.0), 200.0],
	["scrap_sorting", Vector2(69.0, 112.0), 200.0],
	["compost_corner", Vector2(61.5, 132.0), 180.0],
	["goat_cart", Vector2(68.0, 133.0), 190.0],
	["tyre_garden", Vector2(74.5, 126.0), 180.0],
	["bottle_wall", Vector2(21.5, 128.0), 90.0],
	# the farm terrace: the crop row's west end, the grove, the goat stable's yard, the fair's back
	["compost_corner", Vector2(26.5, 70.0), 270.0],
	["bottle_wall", Vector2(40.0, 86.0), 180.0],
	["goat_cart", Vector2(26.5, 86.0), 90.0],
	["scrap_sorting", Vector2(56.0, 80.0), 160.0],
	["tyre_garden", Vector2(74.0, 90.0), 180.0],
	# art import Oct 23: the little patched windmills (DUMP-PROP-WINDMILL) pumping water for the crop rows and the market gardens
	["windmill_plot", Vector2(37.0, 79.0), 180.0],
	["windmill_plot", Vector2(64.0, 76.0), 200.0],
	["windmill_plot", Vector2(52.0, 97.0), 180.0],
	# the compost terrace: the landing's shoulders, the machinery by the gorge, the east pocket
	["bottle_wall", Vector2(44.0, 53.0), 180.0],
	["compost_corner", Vector2(32.0, 58.0), 270.0],
	["scrap_sorting", Vector2(80.0, 50.0), 160.0],
	# the plateau: the throne avenue and the barricade's shoulders
	["tyre_garden", Vector2(36.0, 20.0), 90.0],
	["scrap_sorting", Vector2(42.0, 10.0), 270.0],
	["bottle_wall", Vector2(53.0, 48.0), 180.0],
]
## Wet and sick ground (non-solid): reeds along both lips of the ravine and the gorge, fungus on the plateau toward the roots and in the cliffs' shade.
const SOFT_CLUSTERS: Array = [
	["reed_bank", Vector2(24.0, 0.0), 0.0], ["reed_bank", Vector2(36.0, 0.0), 0.0], ["reed_bank", Vector2(56.0, 0.0), 0.0], ["reed_bank", Vector2(66.0, 0.0), 0.0],
	["reed_bank", Vector2(33.0, 0.0), 180.0], ["reed_bank", Vector2(40.0, 0.0), 180.0], ["reed_bank", Vector2(60.0, 0.0), 180.0], ["reed_bank", Vector2(70.0, 0.0), 180.0],
	["reed_bank", Vector2(25.5, 70.0), 90.0], ["reed_bank", Vector2(25.5, 56.0), 90.0],
	["fungus_patch", Vector2(43.0, 18.5), 90.0], ["fungus_patch", Vector2(57.5, 17.0), 270.0], ["fungus_patch", Vector2(44.0, 11.0), 60.0], ["fungus_patch", Vector2(56.5, 12.0), 300.0],
	["fungus_patch", Vector2(41.0, 25.0), 90.0], ["fungus_patch", Vector2(59.5, 20.5), 270.0], ["fungus_patch", Vector2(54.0, 42.0), 90.0], ["fungus_patch", Vector2(30.0, 40.0), 270.0],
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
		if name == "reed_bank" and at.y == 0.0:
			# along the ravine's lips: the centre line plus the half width, the bank and a little, north (180) or south (0) of the water
			var side: float = 1.0 if float(entry[2]) < 90.0 else -1.0
			at = Vector2(at.x, HeapLayout.stream_z(at.x) + side * (HeapLayout.STREAM_HALF_WIDTH + HeapLayout.BANK_WIDTH + 1.1))
		elif builder.freed:
			name = "tyre_garden"
		dressing._place(name, at, float(entry[2]), 900 + index, 2.5)
	dressing._place_lupins()
	return dressing


const LUPIN: String = "DUMP-PLANT-LUPIN"


## Lupin and bluebell clumps framing the routes in the healthy regions (art import Oct 22, DUMP-PLANT-LUPIN; there were none): along every route about
## every seven metres, the sides taken in turn, a metre past the edge; only on healthy land (corruption under 0.15), on walkable ground off every route,
## bridge and stair, and on ground `_free` keeps clear (non-solid: no blockers), 4 m apart. 1.0 to 1.24 m tall, one card field (one draw call, no
## shadows; the cards fade themselves when they stand between the camera and the hero). Nothing while the plant has no art.
func _place_lupins() -> void:
	if not EnvKit.has_art(LUPIN):
		return
	var layout: HeapLayout = _builder.layout
	var spots: Array = []
	var taken: Array[Vector2] = []
	var step: int = 0
	for path: Dictionary in layout.paths:
		var line: PackedVector2Array = path["line"] as PackedVector2Array
		var half: float = float(path["width"]) * 0.5
		for i: int in range(line.size() - 1):
			var a: Vector2 = line[i]
			var b: Vector2 = line[i + 1]
			var length: float = a.distance_to(b)
			if length < 1.0:
				continue
			var along: Vector2 = (b - a) / length
			var normal: Vector2 = Vector2(-along.y, along.x)
			var d: float = 2.5
			while d < length - 1.0:
				step += 1
				var at: Vector2 = a + along * d + normal * (1.0 if step % 2 == 0 else -1.0) * (half + 1.0)
				d += 6.0 + 1.5 * float(step % 3)
				if layout.corruption_at(at.x, at.y) > 0.15 or layout.path_edge_distance(at.x, at.y) < 0.6:
					continue
				if layout.bridge_at(at.x, at.y) != null or layout.ramp_at(at.x, at.y) != null:
					continue
				var pos: Vector3 = Vector3(at.x, layout.ground_height(at.x, at.y), at.y)
				if not _builder.is_walkable(pos, 0.3) or not _free(pos, 2.0, 2.0, false):
					continue
				var crowded: bool = false
				for other: Vector2 in taken:
					if other.distance_to(at) < 4.0:
						crowded = true
						break
				if crowded:
					continue
				taken.append(at)
				spots.append([pos, 1.0 + 0.12 * float(step % 3)])
	if not spots.is_empty():
		root.add_child(HeapTerraces.card_field(LUPIN, spots, "Lupins"))


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
