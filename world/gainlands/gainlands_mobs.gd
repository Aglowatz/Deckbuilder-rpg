class_name GainlandsMobs
extends RefCounted
## Procedural models of the Gainlands' two non-humanoid roaming enemies (the Flexing Brute reuses the
## KayKit Barbarian). Built from primitives in the shared palette, facing +z, standing on the ground.

const M = preload("res://world/gainlands/gainlands_materials.gd")


static func build(model: String) -> Node3D:
	match model:
		"proc:golem":
			return golem()
		"proc:sprite":
			return sprite()
	return Node3D.new()


static func _mesh(parent: Node3D, mesh: Mesh, material: Material, pos: Vector3, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scl
	parent.add_child(instance)
	return instance


static func _ball(parent: Node3D, radius: float, pos: Vector3, material: Material, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	return _mesh(parent, mesh, material, pos, scl)


## The Protein Shake Golem: a tub of powder with boulder fists and a scoop for a hat.
static func golem() -> Node3D:
	var root: Node3D = Node3D.new()
	var tub: CylinderMesh = CylinderMesh.new()
	tub.top_radius = 0.5
	tub.bottom_radius = 0.42
	tub.height = 1.0
	tub.radial_segments = 10
	tub.rings = 1
	_mesh(root, tub, M.flat(Color(0.96, 0.9, 0.78)), Vector3(0, 0.75, 0))
	var label: CylinderMesh = CylinderMesh.new()
	label.top_radius = 0.51
	label.bottom_radius = 0.5
	label.height = 0.4
	label.radial_segments = 10
	label.rings = 1
	_mesh(root, label, M.flat(M.PINK), Vector3(0, 0.75, 0))
	_mesh(root, tub, M.flat(Color(0.8, 0.75, 0.65)), Vector3(0, 1.38, 0), Vector3(0.9, 0.18, 0.9))
	# Boulder fists and arms.
	for side: float in [-1.0, 1.0]:
		_ball(root, 0.22, Vector3(side * 0.62, 1.0, 0.1), M.flat(M.ROCK), Vector3(1, 1.2, 1))
		_ball(root, 0.3, Vector3(side * 0.72, 0.5, 0.25), M.flat(M.ROCK_DARK))
	# Face: two eyes on the front of the tub.
	for side: float in [-1.0, 1.0]:
		_ball(root, 0.09, Vector3(side * 0.2, 1.05, 0.46), M.flat(Color(1, 1, 1)))
		_ball(root, 0.045, Vector3(side * 0.2, 1.05, 0.54), M.flat(Color(0.05, 0.05, 0.1)))
	# A scoop as a jaunty hat, and legs.
	_ball(root, 0.2, Vector3(0.1, 1.62, 0), M.flat(M.YELLOW), Vector3(1.2, 0.7, 1.2))
	for side: float in [-0.22, 0.22]:
		_ball(root, 0.2, Vector3(side, 0.18, 0.0), M.flat(M.ROCK_DARK), Vector3(1, 0.9, 1.2))
	root.scale = Vector3.ONE * 0.85
	return root


## The Sprinting Energy Sprite: a glowing core with crackling prongs.
static func sprite() -> Node3D:
	var root: Node3D = Node3D.new()
	var core: MeshInstance3D = _ball(root, 0.26, Vector3(0, 0.5, 0), M.glow(Color(1.0, 0.95, 0.4), 2.6))
	core.name = "Core"
	_ball(root, 0.38, Vector3(0, 0.5, 0), M.translucent(Color(1.0, 0.9, 0.3), 0.3, 1.2))
	for index: int in range(6):
		var angle: float = TAU * float(index) / 6.0
		var prong: BoxMesh = BoxMesh.new()
		prong.size = Vector3(0.06, 0.34, 0.06)
		var instance: MeshInstance3D = _mesh(root, prong, M.glow(M.ENERGY, 2.2), Vector3(cos(angle) * 0.42, 0.5 + sin(angle * 2.0) * 0.12, sin(angle) * 0.42))
		instance.rotation = Vector3(angle, angle * 0.7, angle * 1.3)
	# Eyes.
	for side: float in [-1.0, 1.0]:
		_ball(root, 0.06, Vector3(side * 0.1, 0.56, 0.22), M.flat(Color(0.05, 0.05, 0.1)))
	# A speed streak behind it.
	var streak: BoxMesh = BoxMesh.new()
	streak.size = Vector3(0.18, 0.1, 0.8)
	_mesh(root, streak, M.translucent(M.ENERGY, 0.35, 1.5), Vector3(0, 0.5, -0.65))
	return root
