class_name CapitalWasteland
extends RefCounted
## The decrepit outskirts (Brief 13, Part D): south of the city wall the land is barren and cracked. This adds what the layout does not: dead trees (bare trunks and
## branches), ruined walls, rubble and debris piles, cracked dark ground patches, stumps and broken carts, scattered where the hero can walk but away from the road,
## the anchors and the abandoned checkpoints. Seeded, quality scaled, built from `ProcMesh` primitives.

const Z_MIN: float = 66.0
const Z_MAX: float = 93.0
const ROAD_X0: float = 50.0
const ROAD_X1: float = 70.0

var root: Node3D
var count: int = 0
var _builder: CapitalBuilder
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _placed: Array[Vector2] = []
var _anchors: Array[Vector3] = []


static func build(parent: Node3D, builder: CapitalBuilder, layout: CapitalLayout, quality: int) -> CapitalWasteland:
	var wasteland: CapitalWasteland = CapitalWasteland.new()
	wasteland.root = Node3D.new()
	wasteland.root.name = "Wasteland"
	parent.add_child(wasteland.root)
	wasteland._builder = builder
	wasteland._rng.seed = 1313
	for key: Variant in layout.anchors.keys():
		wasteland._anchors.append(layout.anchors[key] as Vector3)
	var share: float = GraphicsQuality.foliage_density(quality)
	wasteland._cracks(int(26.0 * share))
	wasteland._scatter("dead_tree", int(34.0 * share), 4.5)
	wasteland._scatter("ruin", int(14.0 * share), 7.0)
	wasteland._scatter("debris", int(30.0 * share), 3.0)
	wasteland._scatter("stump", int(14.0 * share), 3.0)
	wasteland._scatter("cart", int(4.0 * share), 6.0)
	return wasteland


func _free(pos: Vector3, spacing: float) -> bool:
	if pos.x > ROAD_X0 and pos.x < ROAD_X1 and pos.z < Z_MAX:
		return false  # the road from town stays clear
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


func _scatter(kind: String, amount: int, spacing: float) -> void:
	var made: int = 0
	var tries: int = 0
	while made < amount and tries < amount * 40:
		tries += 1
		var pos: Vector3 = _random_pos()
		if not _free(pos, spacing):
			continue
		var node: Node3D = _make(kind)
		node.position = pos
		node.rotation_degrees.y = _rng.randf() * 360.0
		root.add_child(node)
		_placed.append(Vector2(pos.x, pos.z))
		if kind == "ruin" or kind == "cart":
			_builder.add_blocker(pos, 1.2)
		elif kind == "dead_tree" or kind == "stump":
			_builder.add_blocker(pos, 0.3)
		made += 1
		count += 1


func _cracks(amount: int) -> void:
	var material: ShaderMaterial = GroundDecals.material(GroundDecals.Pattern.DIRT, Color("5a5044"), Color("3e362e"), Color("1c1814"), GroundDecals.Shape.DISC, 1.0, 0.45, 9.0)
	var made: int = 0
	var tries: int = 0
	while made < amount and tries < amount * 20:
		tries += 1
		var pos: Vector3 = _random_pos()
		if not _builder.is_floor_at(pos) or (pos.x > ROAD_X0 and pos.x < ROAD_X1):
			continue
		GroundDecals.disc(root, pos, _rng.randf_range(1.5, 3.4), material, _rng.randf_range(0.4, 0.9), _rng.randf() * 180.0, 0.001 * float(made))
		made += 1


func _make(kind: String) -> Node3D:
	match kind:
		"dead_tree":
			return _dead_tree()
		"ruin":
			return _ruin()
		"debris":
			return _debris()
		"stump":
			return _stump()
	return _cart()


func _holder(mesh: ProcMesh, node_name: String) -> Node3D:
	var node: Node3D = Node3D.new()
	node.name = node_name
	node.add_child(mesh.build("Mesh"))
	return node


func _dead_tree() -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	var bark: Color = Color("4a4038").lerp(Color("2e2824"), _rng.randf())
	var height: float = _rng.randf_range(2.6, 4.6)
	mesh.frustum(0.0, height, 0.26, 0.07, 7, bark)
	for i: int in range(_rng.randi_range(3, 5)):
		var y: float = height * _rng.randf_range(0.45, 0.9)
		var tilt: float = _rng.randf_range(35.0, 70.0)
		var yaw: float = _rng.randf() * 360.0
		var length: float = _rng.randf_range(0.9, 1.7) * (1.2 - y / height * 0.5)
		var xform: Transform3D = Transform3D(Basis(Vector3.UP, deg_to_rad(yaw)) * Basis(Vector3(0, 0, 1), deg_to_rad(-tilt)), Vector3(0, y, 0))
		mesh.frustum(0.0, length, 0.07, 0.015, 5, bark.darkened(0.08), xform)
		var twig: Transform3D = Transform3D(xform.basis * Basis(Vector3(0, 0, 1), deg_to_rad(-30.0)), xform * Vector3(0, length * 0.7, 0))
		mesh.frustum(0.0, length * 0.5, 0.04, 0.01, 4, bark, twig)
	return _holder(mesh, "DeadTree")


func _ruin() -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	var stone: Color = Color("6a665e").lerp(Color("4a4640"), _rng.randf())
	var brick: Color = Color("6a4a42").lerp(Color("4a3a36"), _rng.randf())
	var length: float = _rng.randf_range(3.0, 5.5)
	var height: float = _rng.randf_range(1.4, 3.0)
	# a broken wall: a base slab, a jagged top of stepped blocks, and a window where the bricks fell out
	mesh.box(Vector3(0, height * 0.3, 0), Vector3(length, height * 0.6, 0.5), brick)
	var blocks: int = int(length / 0.5)
	for i: int in range(blocks):
		var top: float = height * _rng.randf_range(0.65, 1.0) if i % 3 != 1 else height * 0.62
		mesh.box(Vector3((float(i) - float(blocks) * 0.5 + 0.5) * 0.5, top * 0.5, 0), Vector3(0.5, top, 0.5), brick if i % 2 == 0 else stone)
	mesh.box(Vector3(length * 0.2, height * 0.45, 0.28), Vector3(0.7, 0.9, 0.1), Color("1c1a1e"))
	for i: int in range(5):
		var size: float = _rng.randf_range(0.2, 0.5)
		mesh.box(Vector3(_rng.randf_range(-length * 0.5, length * 0.5), size * 0.4, _rng.randf_range(0.5, 1.3)), Vector3(size, size * 0.8, size), stone)
	return _holder(mesh, "Ruin")


func _debris() -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	var tones: Array[Color] = [Color("5a5650"), Color("6a4a42"), Color("48443e"), Color("7a6a58")]
	for i: int in range(_rng.randi_range(4, 8)):
		var size: float = _rng.randf_range(0.15, 0.5)
		mesh.box(Vector3(_rng.randf_range(-0.7, 0.7), size * 0.4, _rng.randf_range(-0.7, 0.7)), Vector3(size * 1.4, size, size), tones[i % tones.size()])
	if _rng.randf() > 0.5:
		mesh.box(Vector3(0.0, 0.3, 0.0), Vector3(1.2, 0.08, 0.2), Color("4a3a2e"))
	return _holder(mesh, "Debris")


func _stump() -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	var height: float = _rng.randf_range(0.4, 1.1)
	mesh.frustum(0.0, height, 0.3, 0.22, 7, Color("4a4038"), Transform3D.IDENTITY, true, false, 1.0, Color("6a5a48"))
	mesh.frustum(0.0, 0.3, 0.38, 0.3, 7, Color("3e342c"))
	return _holder(mesh, "Stump")


func _cart() -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	var wood: Color = Color("4a3a2e")
	mesh.box(Vector3(0, 0.55, 0), Vector3(1.8, 0.12, 1.1), wood)
	mesh.box(Vector3(0, 0.8, 0.55), Vector3(1.8, 0.4, 0.08), wood.darkened(0.1))
	mesh.frustum(-0.3, 0.3, 0.45, 0.45, 10, Color("2c2824"), Transform3D(Basis(Vector3(1, 0, 0), PI * 0.5), Vector3(-0.5, 0.45, 0.62)), true, true)
	mesh.box(Vector3(1.4, 0.35, 0.0), Vector3(1.2, 0.08, 0.1), wood.darkened(0.2))
	return _holder(mesh, "BrokenCart")
