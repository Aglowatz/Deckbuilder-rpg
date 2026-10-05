class_name GainlandsDressing
extends RefCounted
## The hand-dressed pass for the Gainlands (Brief 12b): the sunny gym-park mood of docs/art/style_guide.md. Around the Swole Station hub and along the roads it adds red/gold pennant poles, kettlebell clusters,
## plate stacks, tire piles, punching bags and sunflower beds, all built from `ProcMesh` primitives in the zone palette. Placement is seeded and respects walkability and the zone's anchors;
## nothing sits on the roads between travel points. Scaled by the graphics quality.

const RED: Color = Color("e2493f")
const GOLD: Color = Color("f6c23c")
const BLUE: Color = Color("3d9be0")
const DARK: Color = Color("2c2840")
const CREAM: Color = Color("f1e6cf")

var root: Node3D
var _builder: GainlandsBuilder
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _placed: Array[Vector2] = []
var _anchors: Array[Vector3] = []
var count: int = 0


static func build(parent: Node3D, builder: GainlandsBuilder, quality: int) -> GainlandsDressing:
	var dressing: GainlandsDressing = GainlandsDressing.new()
	dressing.root = Node3D.new()
	dressing.root.name = "GainlandsDressing"
	parent.add_child(dressing.root)
	dressing._builder = builder
	dressing._rng.seed = 2468
	for key: String in ["spawn", "rift_station", "hub", "exit", "heal", "tony", "brenda", "gus", "station", "protein_stand", "flex_mirror", "quiz", "minigame", "puzzle", "run_wheel", "spot_me", "mini_dungeon", "main_dungeon"]:
		if builder.has_anchor(key):
			dressing._anchors.append(builder.anchor(key))
	var scale_factor: float = GraphicsQuality.foliage_density(quality)
	dressing._scatter_pennants(int(10.0 * scale_factor))
	dressing._scatter("kettlebells", int(14.0 * scale_factor), 4.5, 17.0)
	dressing._scatter("plates", int(8.0 * scale_factor), 5.0, 18.0)
	dressing._scatter("tires", int(6.0 * scale_factor), 6.0, 20.0)
	dressing._scatter("bag", int(4.0 * scale_factor), 6.0, 18.0)
	dressing._scatter("sunflowers", int(16.0 * scale_factor), 4.0, 20.0)
	return dressing


func _hub() -> Vector3:
	return _builder.anchor("hub")


func _free(pos: Vector3, clearance: float, spacing: float) -> bool:
	if not _builder.is_walkable(pos, 0.5):
		return false
	for anchor: Vector3 in _anchors:
		if Vector2(pos.x - anchor.x, pos.z - anchor.z).length() < clearance:
			return false
	for other: Vector2 in _placed:
		if other.distance_to(Vector2(pos.x, pos.z)) < spacing:
			return false
	return true


func _scatter(kind: String, amount: int, min_radius: float, max_radius: float) -> void:
	var made: int = 0
	var tries: int = 0
	while made < amount and tries < amount * 40:
		tries += 1
		var angle: float = _rng.randf() * TAU
		var distance: float = _rng.randf_range(min_radius, max_radius)
		var pos: Vector3 = _hub() + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance * 0.8)
		if not _free(pos, 3.2, 2.6):
			continue
		pos.y = _builder.height_at(pos)
		var node: Node3D = _make(kind)
		node.position = pos
		node.rotation_degrees.y = _rng.randf() * 360.0
		root.add_child(node)
		_placed.append(Vector2(pos.x, pos.z))
		if kind != "sunflowers" and kind != "kettlebells":
			_builder.add_blocker(pos, 0.5)
		made += 1
		count += 1


func _scatter_pennants(amount: int) -> void:
	var made: int = 0
	for i: int in range(amount * 4):
		if made >= amount:
			break
		var angle: float = TAU * float(i) / float(amount * 4) * 1.0 + 0.2
		var radius: float = _rng.randf_range(11.0, 15.0)
		var pos: Vector3 = _hub() + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius * 0.8)
		if not _free(pos, 3.4, 4.5):
			continue
		pos.y = _builder.height_at(pos)
		var node: Node3D = _pennant(made)
		node.position = pos
		node.rotation_degrees.y = _rng.randf() * 360.0
		root.add_child(node)
		_placed.append(Vector2(pos.x, pos.z))
		_builder.add_blocker(pos, 0.3)
		made += 1
		count += 1


func _make(kind: String) -> Node3D:
	match kind:
		"kettlebells":
			return _kettlebells()
		"plates":
			return _plates()
		"tires":
			return _tires()
		"bag":
			return _punching_bag()
		_:
			return _sunflowers()


func _holder(mesh: ProcMesh, node_name: String) -> Node3D:
	var node: Node3D = Node3D.new()
	node.name = node_name
	node.add_child(mesh.build("Mesh"))
	return node


func _pennant(index: int) -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	mesh.frustum(0.0, 3.2, 0.07, 0.05, 6, Color("6b4a3a"))
	mesh.sphere(Vector3(0, 3.28, 0), 0.1, 3, 6, GOLD)
	var colors: Array[Color] = [RED, GOLD, BLUE]
	var flag: Color = colors[index % 3]
	mesh.facing(Vector3(0, 0, 1))
	# a swallow-tail pennant streaming to +x (the toon shader's wind sways it: the node name contains "flag")
	mesh.quad(Vector3(0.05, 3.1, 0), Vector3(1.3, 3.0, 0), Vector3(1.3, 2.45, 0), Vector3(0.05, 2.45, 0), flag)
	mesh.tri(Vector3(1.3, 3.0, 0), Vector3(0.95, 2.72, 0), Vector3(1.3, 2.45, 0), flag.darkened(0.12))
	mesh.quad(Vector3(0.05, 2.62, 0), Vector3(1.1, 2.6, 0), Vector3(1.1, 2.5, 0), Vector3(0.05, 2.5, 0), CREAM)
	mesh.facing(Vector3(0, 0, -1))
	mesh.quad(Vector3(0.05, 3.1, 0), Vector3(1.3, 3.0, 0), Vector3(1.3, 2.45, 0), Vector3(0.05, 2.45, 0), flag.darkened(0.1))
	mesh.tri(Vector3(1.3, 3.0, 0), Vector3(0.95, 2.72, 0), Vector3(1.3, 2.45, 0), flag.darkened(0.2))
	return _holder(mesh, "flag_pole")


func _kettlebells() -> Node3D:
	var root_node: Node3D = Node3D.new()
	root_node.name = "Kettlebells"
	var tones: Array[Color] = [DARK, RED, Color("4a4a64")]
	for i: int in range(3):
		var mesh: ProcMesh = ProcMesh.new()
		var s: float = 0.28 + 0.06 * float(i)
		mesh.sphere(Vector3(0, s, 0), s, 4, 8, tones[(i + int(_rng.randf() * 3.0)) % 3], Transform3D.IDENTITY, 0.9)
		mesh.box(Vector3(-s * 0.55, s * 2.0 + 0.05, 0), Vector3(0.05, 0.16, 0.06), DARK)
		mesh.box(Vector3(s * 0.55, s * 2.0 + 0.05, 0), Vector3(0.05, 0.16, 0.06), DARK)
		mesh.box(Vector3(0, s * 2.0 + 0.13, 0), Vector3(s * 1.2, 0.05, 0.06), DARK)
		mesh.box(Vector3(0, s * 0.9, s * 0.88), Vector3(s * 0.7, s * 0.4, 0.02), GOLD)
		var bell: MeshInstance3D = mesh.build("Kettlebell")
		bell.position = Vector3(float(i) * 0.7 - 0.7, 0.0, _rng.randf_range(-0.15, 0.15))
		root_node.add_child(bell)
	return root_node


func _plates() -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	var tones: Array[Color] = [RED, BLUE, GOLD, DARK, CREAM]
	var height: float = 0.0
	for i: int in range(5):
		var thickness: float = 0.09 + 0.02 * float(i % 3)
		mesh.frustum(height, height + thickness, 0.5 - 0.05 * float(i), 0.5 - 0.05 * float(i), 12, tones[i % tones.size()])
		mesh.frustum(height, height + thickness + 0.005, 0.12, 0.12, 8, DARK)
		height += thickness
	mesh.frustum(0.0, height + 0.5, 0.06, 0.06, 6, Color("9aa0b0"))
	return _holder(mesh, "PlateStack")


func _tires() -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	for i: int in range(3):
		var y: float = 0.22 * float(i)
		mesh.ring(y, 0.2, 0.62 - 0.03 * float(i), 0.22, 14, DARK if i != 1 else Color("3a3a58"), Transform3D.IDENTITY, 1.0, DARK)
		mesh.ring(y + 0.2, 0.2, 0.62 - 0.03 * float(i), 0.02, 14, RED if i == 2 else Color("55557a"))
	return _holder(mesh, "TirePile")


func _punching_bag() -> Node3D:
	var mesh: ProcMesh = ProcMesh.new()
	mesh.frustum(0.0, 2.4, 0.07, 0.07, 6, Color("6b4a3a"))
	mesh.box(Vector3(0.45, 2.4, 0), Vector3(1.0, 0.08, 0.1), Color("6b4a3a"))
	mesh.frustum(1.0, 2.3, 0.27, 0.27, 10, RED, Transform3D(Basis.IDENTITY, Vector3(0.82, 0, 0)))
	mesh.frustum(1.0, 1.35, 0.272, 0.272, 10, GOLD, Transform3D(Basis.IDENTITY, Vector3(0.82, 0, 0)), false, false)
	mesh.frustum(2.3, 2.4, 0.04, 0.04, 6, DARK, Transform3D(Basis.IDENTITY, Vector3(0.82, 0, 0)))
	mesh.sphere(Vector3(0.82, 1.0, 0), 0.27, 3, 10, RED.darkened(0.15))
	return _holder(mesh, "PunchingBag")


func _sunflowers() -> Node3D:
	var root_node: Node3D = Node3D.new()
	root_node.name = "SunflowerBed_flower"
	for i: int in range(5):
		var mesh: ProcMesh = ProcMesh.new()
		var height: float = _rng.randf_range(0.8, 1.35)
		mesh.frustum(0.0, height, 0.03, 0.025, 5, Color("4f9a4a"))
		var tilt: Transform3D = Transform3D(Basis(Vector3(1, 0, 0), deg_to_rad(-62.0)), Vector3(0, height, 0))
		mesh.ring(0.0, 0.1, 0.3, 0.03, 10, GOLD, tilt)
		mesh.frustum(0.0, 0.05, 0.11, 0.1, 8, Color("6b4a3a"), tilt, true, false)
		for leaf: int in range(2):
			var a: float = float(leaf) * PI + float(i)
			mesh.tri(Vector3(0, height * 0.4, 0), Vector3(cos(a) * 0.3, height * 0.5, sin(a) * 0.3), Vector3(cos(a + 0.4) * 0.12, height * 0.35, sin(a + 0.4) * 0.12), Color("5fb04c"))
		var flower: MeshInstance3D = mesh.build("Sunflower")
		flower.position = Vector3(_rng.randf_range(-0.6, 0.6), 0.0, _rng.randf_range(-0.6, 0.6))
		root_node.add_child(flower)
	return root_node
