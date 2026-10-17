class_name CapitalWasteland
extends RefCounted
## The decrepit outside (Brief 13, Part D; decluttered in the Capital layout pass; dressed from the zone kit in the art pass): south of the city wall
## the land is barren and cracked. This adds what the layout does not: dead trees (CAP-TREE-DEAD), ruined walls of ash-blackened stone with the outpost
## sheet's broken and boarded windows, rubble and wreckage from the rubble sheet (the white stone pile, the broken cart, the fallen striped barrier, the
## toppled lamppost, the broken statue head, the scattered crates) and soft ash drifts (CAP-DEC-ASH), gathered in the layout's few edge clusters
## (`CapitalLayout.wasteland_clusters`), never on a road or round the people. Seeded and quality scaled; the cards are the kit's painted cut-outs.

const K = preload("res://world/capital/capital_kit.gd")
const Z_MIN: float = float(CapitalLayout.WALL_Z1) + 2.0
const Z_MAX: float = float(CapitalLayout.OUT_Z1)
## The pieces of one cluster at full density, in this order.
const CLUSTER_KINDS: Array[String] = ["dead_tree", "ruin", "debris", "stump", "debris", "cart"]
## The rubble sheet's pieces that lie loose round a cluster (01 the white stone pile, 03 the fallen barrier, 04 the toppled lamppost, 05 the broken statue
## head, 06 the scattered crates) and their heights in metres; 02, the broken cart, is the cluster's "cart".
const DEBRIS: Array[Array] = [["CAP-SHEET-RUBBLE-01", 1.2], ["CAP-SHEET-RUBBLE-03", 0.9], ["CAP-SHEET-RUBBLE-04", 0.8], ["CAP-SHEET-RUBBLE-05", 1.1], ["CAP-SHEET-RUBBLE-06", 1.0]]

var root: Node3D
var count: int = 0
var _builder: CapitalBuilder
var _layout: CapitalLayout
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _placed: Array[Vector2] = []
var _anchors: Array[Vector3] = []
var _ground: KitMesh


static func build(parent: Node3D, builder: CapitalBuilder, layout: CapitalLayout, quality: int) -> CapitalWasteland:
	var wasteland: CapitalWasteland = CapitalWasteland.new()
	wasteland.root = Node3D.new()
	wasteland.root.name = "Wasteland"
	parent.add_child(wasteland.root)
	wasteland._builder = builder
	wasteland._layout = layout
	wasteland._rng.seed = 1313
	for key: Variant in layout.anchors.keys():
		wasteland._anchors.append(layout.anchors[key] as Vector3)
	wasteland._ground = KitMesh.new()
	K.materials(wasteland._ground)
	var share: float = GraphicsQuality.foliage_density(quality)
	wasteland._drifts(int(16.0 * share))
	for spot: Vector3 in layout.wasteland_clusters:
		wasteland._cluster(spot, maxi(2, int(round(float(CLUSTER_KINDS.size()) * share))))
	var drifts: MeshInstance3D = wasteland._ground.instance("AshDrifts")
	drifts.set_meta(&"no_occlusion_fade", true)
	drifts.set_meta(&"no_range_cull", true)
	drifts.set_meta(PaintedClasses.META_NO_PAINT, true)
	drifts.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	wasteland.root.add_child(drifts)
	return wasteland


## One vignette at a cluster spot (x, z, radius), composed, never scattered: a stretch of ruined wall square to the nearest road (its length along
## the road), a dead tree behind it, debris and a stump at its foot, a broken cart beside it, an ash drift under it; each piece only where the
## ground is free, nothing turned at random.
func _cluster(spot: Vector3, amount: int) -> void:
	var at: Vector2 = Vector2(spot.x, spot.y)
	var face: Vector2 = _road_side(at)
	var along: Vector2 = Vector2(-face.y, face.x)
	K.ground_card(_ground, "CAP-DEC-ASH", Vector3(spot.x, 0.04, spot.y), spot.z * 1.6 + 2.0, atan2(along.y, along.x))
	var plan: Array[Array] = [
		["ruin", at - face * 0.5],
		["dead_tree", at - face * 1.9 + along * 1.5],
		["debris", at + face * 0.9 - along * 1.0],
		["stump", at - face * 1.7 - along * 1.7],
		["debris", at + face * 0.8 + along * 1.4],
		["cart", at - along * 2.6 + face * 0.2],
	]
	for index: int in range(mini(amount, plan.size())):
		var p: Vector2 = plan[index][1] as Vector2
		var pos: Vector3 = Vector3(p.x, 0.0, p.y)
		if _free(pos, 1.0):
			_place(str(plan[index][0]), pos, along)


## The way from a cluster spot to its nearest road, snapped to the map's axes (the roads run north-south and east-west).
func _road_side(at: Vector2) -> Vector2:
	var best: Vector2 = Vector2.ZERO
	var best_distance: float = INF
	for route: Dictionary in _layout.routes:
		var q: Vector2 = Geometry2D.get_closest_point_to_segment(at, route["a"] as Vector2, route["b"] as Vector2)
		if q.distance_to(at) < best_distance:
			best_distance = q.distance_to(at)
			best = q - at
	if absf(best.x) > absf(best.y):
		return Vector2(signf(best.x), 0.0)
	return Vector2(0.0, signf(best.y) if best.y != 0.0 else 1.0)


func _free(pos: Vector3, spacing: float) -> bool:
	if _layout.route_edge_distance(pos.x, pos.z) < CapitalLayout.ROUTE_CLEARANCE:
		return false  # the roads stay clear
	if not _builder.is_walkable(pos, 0.6):
		return false
	for anchor: Vector3 in _anchors:
		if Vector2(pos.x - anchor.x, pos.z - anchor.z).length() < 4.0:
			return false
	for other: Vector2 in _placed:
		if other.distance_to(Vector2(pos.x, pos.z)) < spacing:
			return false
	return true


func _random_pos() -> Vector3:
	return Vector3(_rng.randf_range(3.0, 116.0), 0.0, _rng.randf_range(Z_MIN, Z_MAX))


func _place(kind: String, pos: Vector3, along: Vector2 = Vector2.RIGHT) -> void:
	var node: Node3D = _make(kind)
	node.position = pos
	# square to its road: a ruin's face and a cart's side run along it (the cards face the camera whatever the turn)
	node.rotation.y = -atan2(along.y, along.x)
	root.add_child(node)
	_placed.append(Vector2(pos.x, pos.z))
	if kind == "ruin" or kind == "cart":
		_builder.add_blocker(pos, 1.2)
	elif kind == "dead_tree" or kind == "stump":
		_builder.add_blocker(pos, 0.3)
	count += 1


## Soft ash drifts blown against the roads' kerbs (never on a road), the kit's CAP-DEC-ASH lying flat along the road.
func _drifts(amount: int) -> void:
	var made: int = 0
	var tries: int = 0
	while made < amount and tries < amount * 40:
		tries += 1
		var pos: Vector3 = _random_pos()
		var edge: float = _layout.route_edge_distance(pos.x, pos.z)
		if not _builder.is_floor_at(pos) or edge < 0.5 or edge > 2.0:
			continue
		var side: Vector2 = _road_side(Vector2(pos.x, pos.z))
		K.ground_card(_ground, "CAP-DEC-ASH", Vector3(pos.x, 0.035 + 0.001 * float(made), pos.z), _rng.randf_range(2.2, 4.0), atan2(side.x, -side.y))
		made += 1


func _make(kind: String) -> Node3D:
	var node: Node3D = Node3D.new()
	match kind:
		"dead_tree":
			node.name = "DeadTree"
			K.tree_card(node, "CAP-TREE-DEAD", Vector3.ZERO, _rng.randf_range(3.0, 4.6))
		"stump":
			node.name = "DeadTreeSmall"
			K.tree_card(node, "CAP-TREE-DEAD", Vector3.ZERO, _rng.randf_range(1.6, 2.3))
		"debris":
			node.name = "Debris"
			var piece: Array = DEBRIS[_rng.randi() % DEBRIS.size()]
			K.tree_card(node, str(piece[0]), Vector3.ZERO, float(piece[1]) * _rng.randf_range(0.9, 1.2))
		"ruin":
			node.name = "Ruin"
			node.add_child(CapitalLandmarks.ruin_fragment(_rng.randf_range(3.0, 5.5), _rng.randf_range(1.6, 3.0), _rng.randi() % 1000))
		_:
			node.name = "BrokenCart"
			K.tree_card(node, "CAP-SHEET-RUBBLE-02", Vector3.ZERO, _rng.randf_range(1.4, 1.7))
	return node
