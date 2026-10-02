class_name GainlandsProps
extends RefCounted
## Procedural props of the Gainlands, built from a handful of primitives and the shared palette
## (`GainlandsMaterials`): colossal hamster wheels, boulder-and-log gym equipment, the hot tub, the
## vendor stalls, the arch back to the Beefcake Path, the Leg Day gate, the studio stage, the flex
## mirror, energy crystals. All dimensions are metres; every prop is built around its own origin on
## the ground, facing +z. Animated parts register themselves in the returned node's meta
## ("spinner", "screen", "bobber") for `GainlandsBuilder.animate`.

const M = preload("res://world/gainlands/gainlands_materials.gd")


static func _mesh(parent: Node3D, mesh: Mesh, material: Material, pos: Vector3 = Vector3.ZERO, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.rotation_degrees = rot_deg
	instance.scale = scl
	parent.add_child(instance)
	return instance


static func _box(parent: Node3D, size: Vector3, pos: Vector3, material: Material, rot_deg: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	return _mesh(parent, mesh, material, pos, rot_deg)


static func _cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, material: Material, rot_deg: Vector3 = Vector3.ZERO, segments: int = 10) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	return _mesh(parent, mesh, material, pos, rot_deg)


## A chunky low-poly boulder (a faceted, squashed sphere).
static func boulder(parent: Node3D, radius: float, pos: Vector3, color: Color = M.ROCK, squash: float = 0.78) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 7
	mesh.rings = 4
	var instance: MeshInstance3D = _mesh(parent, mesh, M.flat(color), pos, Vector3(0, pos.x * 53.0 + pos.z * 31.0, 0), Vector3(1.0, squash, 1.0))
	instance.position.y = pos.y + radius * squash
	return instance


# ---- Energy -----------------------------------------------------------------------------------


## A colossal hamster wheel. The returned node has meta "spinner" (the rotating part). `radius` is
## the wheel's outer radius; the axle sits `radius + 0.5` above the ground, the axis along local z.
static func wheel(radius: float = 4.2, with_hamster: bool = false) -> Node3D:
	var root: Node3D = Node3D.new()
	var axle_height: float = radius + 0.5
	var spinner: Node3D = Node3D.new()
	spinner.position = Vector3(0, axle_height, 0)
	root.add_child(spinner)
	root.set_meta("spinner", spinner)
	root.set_meta("radius", radius)
	var rim_material: StandardMaterial3D = M.flat(M.WOOD_DARK)
	for side: float in [-1.15, 1.15]:
		var rim: TorusMesh = TorusMesh.new()
		rim.inner_radius = radius - 0.34
		rim.outer_radius = radius
		rim.rings = 20
		rim.ring_segments = 5
		_mesh(spinner, rim, rim_material, Vector3(0, 0, side), Vector3(90, 0, 0))
		# Spokes only on the back side so the camera (to the south) can see into the drum.
		for spoke: int in range(8 if side < 0.0 else 0):
			var angle: float = TAU * float(spoke) / 8.0
			var length: float = radius - 0.3
			_box(spinner, Vector3(0.22, length, 0.2), Vector3(sin(angle), cos(angle), 0.0) * length * 0.5 + Vector3(0, 0, side), M.flat(M.WOOD), Vector3(0, 0, -rad_to_deg(angle)))
	for slat: int in range(22):
		var angle: float = TAU * float(slat) / 22.0
		_box(spinner, Vector3(0.34, 0.12, 2.5), Vector3(sin(angle), cos(angle), 0.0) * (radius - 0.18), M.flat(M.WOOD), Vector3(0, 0, -rad_to_deg(angle)))
	_cylinder(spinner, 0.3, 3.2, Vector3.ZERO, M.flat(M.ROCK_DARK, 0.5), Vector3(90, 0, 0), 12)
	_cylinder(spinner, 0.22, 0.6, Vector3(0, 0, 1.7), M.flat(M.COPPER), Vector3(90, 0, 0), 8)
	# Stands: a post and a brace on each side, standing on the ground.
	for side: float in [-1.7, 1.7]:
		if side < 0.0:
			_box(root, Vector3(0.5, axle_height + 0.2, 0.5), Vector3(0, (axle_height + 0.2) * 0.5, side), M.flat(M.WOOD))
		for lean: float in [-1.0, 1.0]:
			_box(root, Vector3(0.36, axle_height * 1.05, 0.36), Vector3(lean * axle_height * 0.32, axle_height * 0.5, side), M.flat(M.WOOD_DARK), Vector3(0, 0, lean * 17.0))
		_box(root, Vector3(axle_height * 1.0, 0.3, 0.8), Vector3(0, 0.15, side), M.flat(M.ROCK_DARK))
	if with_hamster:
		var hamster: Node3D = Node3D.new()
		hamster.position = Vector3(0, 0.9, 0)
		root.add_child(hamster)
		boulder(hamster, 0.42, Vector3(0, -0.2, 0), Color(1.0, 0.7, 0.35), 0.9)
		boulder(hamster, 0.22, Vector3(0, 0.3, 0.3), Color(1.0, 0.82, 0.55), 0.95)
		for ear: float in [-0.14, 0.14]:
			boulder(hamster, 0.07, Vector3(ear, 0.55, 0.3), Color(1.0, 0.55, 0.6), 1.0)
		root.set_meta("bobber", hamster)
	return root


## A thick copper pipe segment between two points (for the energy lines).
static func pipe_segment(parent: Node3D, a: Vector3, b: Vector3, radius: float = 0.2) -> void:
	var length: float = a.distance_to(b)
	if length < 0.01:
		return
	var mid: Vector3 = (a + b) * 0.5
	var instance: MeshInstance3D = _cylinder(parent, radius, length, mid, M.flat(M.COPPER, 0.45), Vector3.ZERO, 8)
	instance.basis = Basis(Quaternion(Vector3.UP, (b - a).normalized()))
	# A glowing band mid-way so the line reads as "energy".
	var band: MeshInstance3D = _cylinder(parent, radius * 1.12, minf(0.35, length * 0.4), mid, M.glow(M.ENERGY, 1.4), Vector3.ZERO, 8)
	band.basis = Basis(Quaternion(Vector3.UP, (b - a).normalized()))


static func crystal() -> Node3D:
	var root: Node3D = Node3D.new()
	var upper: CylinderMesh = CylinderMesh.new()
	upper.top_radius = 0.0
	upper.bottom_radius = 0.4
	upper.height = 1.1
	upper.radial_segments = 5
	upper.rings = 1
	var glow_material: StandardMaterial3D = M.translucent(M.ENERGY, 0.85, 1.6)
	var holder: Node3D = Node3D.new()
	holder.position = Vector3(0, 1.4, 0)
	root.add_child(holder)
	_mesh(holder, upper, glow_material, Vector3(0, 0.55, 0))
	_mesh(holder, upper, glow_material, Vector3(0, -0.55, 0), Vector3(180, 0, 0))
	root.set_meta("bobber", holder)
	root.set_meta("spinner_y", holder)
	return root


# ---- Gym equipment: boulders and logs -----------------------------------------------------------


static func barbell_bar(parent: Node3D, pos: Vector3, bar_length: float, plate_radius: float, plate_color: Color = M.ROCK) -> void:
	_cylinder(parent, 0.07, bar_length, pos, M.flat(M.METAL, 0.4), Vector3(0, 0, 90), 8)
	for side: float in [-1.0, 1.0]:
		boulder(parent, plate_radius, pos + Vector3(side * (bar_length * 0.5 - plate_radius * 0.6), -plate_radius * 0.78, 0.0), plate_color, 1.0)


static func bench_press() -> Node3D:
	var root: Node3D = Node3D.new()
	_cylinder(root, 0.34, 2.6, Vector3(0, 0.62, 0), M.flat(M.WOOD), Vector3(0, 0, 90), 9)
	for side: float in [-1.0, 1.0]:
		boulder(root, 0.46, Vector3(side * 1.05, 0, 0), M.ROCK_DARK)
		_box(root, Vector3(0.16, 1.5, 0.16), Vector3(side * 0.95, 1.05, -0.45), M.flat(M.WOOD_DARK))
		_box(root, Vector3(0.16, 1.5, 0.16), Vector3(side * 0.95, 1.05, 0.45), M.flat(M.WOOD_DARK))
	barbell_bar(root, Vector3(0, 1.7, 0), 3.4, 0.42, M.ROCK)
	return root


static func log_rack() -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		_cylinder(root, 0.2, 2.8, Vector3(side * 1.1, 1.4, 0), M.flat(M.WOOD), Vector3.ZERO, 8)
		boulder(root, 0.38, Vector3(side * 1.1, 0, 0.0), M.ROCK_DARK)
	_cylinder(root, 0.12, 2.5, Vector3(0, 2.7, 0), M.flat(M.WOOD_DARK), Vector3(0, 0, 90), 8)
	_cylinder(root, 0.04, 0.9, Vector3(0.4, 2.2, 0), M.flat(M.METAL), Vector3.ZERO, 6)
	boulder(root, 0.22, Vector3(0.4, 1.4, 0), M.ROCK, 1.0)
	return root


static func dumbbell_rack() -> Node3D:
	var root: Node3D = Node3D.new()
	_box(root, Vector3(3.0, 0.2, 0.9), Vector3(0, 0.6, 0), M.flat(M.WOOD))
	for leg: float in [-1.3, 1.3]:
		_box(root, Vector3(0.2, 0.6, 0.7), Vector3(leg, 0.3, 0), M.flat(M.WOOD_DARK))
	for index: int in range(4):
		var x: float = -1.05 + 0.7 * float(index)
		var size: float = 0.16 + 0.05 * float(index)
		_cylinder(root, 0.04, 0.5, Vector3(x, 0.9 + size * 0.5, 0), M.flat(M.METAL), Vector3(0, 0, 90), 6)
		for side: float in [-0.22, 0.22]:
			boulder(root, size, Vector3(x + side * 0.9, 0.7, 0.0), [M.ROCK, M.ROCK_DARK, M.COPPER, M.PINK][index], 1.0)
	return root


static func lying_barbell() -> Node3D:
	var root: Node3D = Node3D.new()
	barbell_bar(root, Vector3(0, 0.45, 0), 3.2, 0.45, M.ROCK_DARK)
	return root


# ---- The hub --------------------------------------------------------------------------------------


static func tub() -> Node3D:
	var root: Node3D = Node3D.new()
	_cylinder(root, 1.7, 0.85, Vector3(0, 0.42, 0), M.flat(M.WOOD), Vector3.ZERO, 14)
	var water: MeshInstance3D = _cylinder(root, 1.5, 0.05, Vector3(0, 0.78, 0), M.translucent(M.WATER, 0.8, 0.5), Vector3.ZERO, 14)
	root.set_meta("bobber", water)
	for index: int in range(10):
		var angle: float = TAU * float(index) / 10.0
		_box(root, Vector3(0.22, 1.0, 0.32), Vector3(cos(angle), 0.45, sin(angle)) * 1.72 * Vector3(1, 1, 1), M.flat(M.WOOD_DARK), Vector3(0, -rad_to_deg(angle), 0))
	boulder(root, 0.4, Vector3(1.0, 0.7, -0.9), M.ROCK, 0.7)
	_cylinder(root, 0.22, 1.0, Vector3(-2.2, 0.22, 0.6), M.flat(M.PINK), Vector3(0, 0, 90), 8)
	var steam: CPUParticles3D = CPUParticles3D.new()
	steam.amount = 14
	steam.lifetime = 2.4
	steam.direction = Vector3.UP
	steam.spread = 15.0
	steam.initial_velocity_min = 0.4
	steam.initial_velocity_max = 0.7
	steam.gravity = Vector3.ZERO
	steam.scale_amount_min = 0.5
	steam.scale_amount_max = 0.9
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.2
	puff.height = 0.4
	puff.radial_segments = 6
	puff.rings = 3
	steam.mesh = puff
	steam.material_override = M.translucent(Color(1, 1, 1), 0.35, 0.2)
	steam.position = Vector3(0, 0.9, 0)
	root.add_child(steam)
	return root


static func stall(awning_a: Color = M.CLOTH_RED, awning_b: Color = Color(1, 1, 1)) -> Node3D:
	var root: Node3D = Node3D.new()
	_box(root, Vector3(3.0, 1.0, 1.1), Vector3(0, 0.5, 0), M.flat(M.WOOD))
	_box(root, Vector3(3.2, 0.12, 1.3), Vector3(0, 1.05, 0), M.flat(M.WOOD_DARK))
	for side: float in [-1.45, 1.45]:
		_cylinder(root, 0.08, 2.6, Vector3(side, 1.3, -0.5), M.flat(M.WOOD_DARK), Vector3.ZERO, 6)
	for stripe: int in range(8):
		var color: Color = awning_a if stripe % 2 == 0 else awning_b
		_box(root, Vector3(0.42, 0.08, 1.8), Vector3(-1.45 + 0.42 * float(stripe) + 0.2, 2.5 - 0.0, -0.1), M.flat(color), Vector3(-16, 0, 0))
	for index: int in range(5):
		_cylinder(root, 0.16, 0.34, Vector3(-1.1 + 0.55 * float(index), 1.28, 0.0), M.flat([M.PINK, M.YELLOW, M.WATER, M.CLOTH_RED, M.GRASS_HIGH][index]), Vector3.ZERO, 8)
	return root


static func arch() -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		_cylinder(root, 0.4, 4.4, Vector3(side * 2.4, 2.2, 0), M.flat(M.WOOD), Vector3.ZERO, 9)
		boulder(root, 0.9, Vector3(side * 2.4, 0, 0), M.ROCK_DARK)
	_cylinder(root, 0.34, 6.2, Vector3(0, 4.4, 0), M.flat(M.WOOD_DARK), Vector3(0, 0, 90), 9)
	_box(root, Vector3(1.4, 0.7, 0.3), Vector3(0, 5.1, 0.1), M.flat(M.COPPER))
	var swirl: MeshInstance3D = _cylinder(root, 2.1, 0.06, Vector3(0, 2.3, 0), M.translucent(M.ENERGY, 0.55, 1.2), Vector3(90, 0, 0), 16)
	root.set_meta("spinner_z", swirl)
	return root


static func gate() -> Node3D:
	var root: Node3D = Node3D.new()
	for side: float in [-1.0, 1.0]:
		_box(root, Vector3(2.2, 8.0, 2.2), Vector3(side * 4.1, 4.0, 0), M.flat(M.ROCK))
		boulder(root, 1.4, Vector3(side * 4.1, 7.8, 0), M.ROCK_DARK, 0.8)
	_box(root, Vector3(10.4, 1.6, 2.2), Vector3(0, 8.4, 0), M.flat(M.ROCK_DARK))
	_box(root, Vector3(6.0, 7.2, 0.7), Vector3(0, 3.6, 0), M.flat(M.WOOD_DARK))
	for plank: int in range(5):
		_box(root, Vector3(6.2, 0.35, 0.2), Vector3(0, 1.0 + 1.3 * float(plank), 0.5), M.flat(M.WOOD))
	for tape: int in range(8):
		_box(root, Vector3(0.9, 0.35, 0.12), Vector3(-3.4 + 0.97 * float(tape), 5.8, 0.65), M.flat(M.YELLOW if tape % 2 == 0 else Color(0.1, 0.1, 0.12)), Vector3(0, 0, 18))
	for cone: float in [-2.6, 2.6]:
		var mesh: CylinderMesh = CylinderMesh.new()
		mesh.top_radius = 0.0
		mesh.bottom_radius = 0.4
		mesh.height = 0.9
		mesh.radial_segments = 8
		mesh.rings = 1
		_mesh(root, mesh, M.flat(Color(1.0, 0.5, 0.1)), Vector3(cone, 0.45, 2.2))
	# A neglected pair of boulder dumbbells on the doorstep.
	barbell_bar(root, Vector3(0, 0.55, 3.4), 2.2, 0.5, M.ROCK_DARK)
	return root


static func stage() -> Node3D:
	var root: Node3D = Node3D.new()
	_box(root, Vector3(6.0, 0.5, 3.6), Vector3(0, 0.25, 0), M.flat(M.PINK))
	_box(root, Vector3(6.0, 0.06, 3.6), Vector3(0, 0.53, 0), M.flat(Color(0.2, 0.9, 0.95)))
	_box(root, Vector3(6.0, 3.6, 0.3), Vector3(0, 2.3, -1.65), M.flat(Color(0.25, 0.1, 0.45)))
	var screen: MeshInstance3D = _box(root, Vector3(4.2, 2.2, 0.1), Vector3(0, 2.4, -1.45), M.glow(M.PINK, 1.1))
	root.set_meta("screen", screen)
	for side: float in [-1.0, 1.0]:
		_box(root, Vector3(0.9, 1.4, 0.8), Vector3(side * 2.7, 1.2, -0.9), M.flat(Color(0.15, 0.15, 0.2)))
		_cylinder(root, 0.28, 0.1, Vector3(side * 2.7, 1.5, -0.46), M.flat(M.METAL), Vector3(90, 0, 0), 10)
		_cylinder(root, 0.1, 3.4, Vector3(side * 2.9, 1.7, 1.5), M.flat(M.WOOD_DARK), Vector3.ZERO, 6)
	for bulb: int in range(9):
		var x: float = -2.9 + 0.72 * float(bulb)
		var colour: Color = [M.YELLOW, M.PINK, M.ENERGY][bulb % 3]
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = 0.1
		mesh.height = 0.2
		mesh.radial_segments = 6
		mesh.rings = 3
		_mesh(root, mesh, M.glow(colour, 2.0), Vector3(x, 3.2 + sin(float(bulb)) * 0.1, 1.5))
	# Yoga mats and a stack of legwarmers.
	for mat: int in range(3):
		_box(root, Vector3(0.9, 0.05, 2.0), Vector3(-2.2 + 1.1 * float(mat), 0.06, 3.0), M.flat([M.CLOTH_BLUE, M.YELLOW, M.CLOTH_RED][mat]))
	return root


static func mirror() -> Node3D:
	var root: Node3D = Node3D.new()
	_box(root, Vector3(2.0, 3.0, 0.2), Vector3(0, 1.7, 0), M.flat(M.WOOD_DARK))
	_box(root, Vector3(1.7, 2.7, 0.06), Vector3(0, 1.7, 0.12), M.translucent(Color(0.7, 0.95, 1.0), 0.75, 0.6))
	for side: float in [-0.8, 0.8]:
		_cylinder(root, 0.08, 0.4, Vector3(side, 0.2, 0.0), M.flat(M.WOOD), Vector3.ZERO, 6)
	boulder(root, 0.3, Vector3(1.4, 0, 0.5), M.ROCK_DARK, 0.7)
	return root


static func lecture_log() -> Node3D:
	var root: Node3D = Node3D.new()
	_cylinder(root, 0.65, 3.4, Vector3(0, 0.65, 0), M.flat(M.WOOD), Vector3(0, 0, 90), 10)
	_box(root, Vector3(1.2, 1.2, 0.8), Vector3(-1.9, 0.6, 1.4), M.flat(M.WOOD_DARK))
	for seat: int in range(3):
		_cylinder(root, 0.4, 0.5, Vector3(-1.5 + 1.5 * float(seat), 0.25, 2.2), M.flat(M.WOOD_DARK), Vector3.ZERO, 8)
	_box(root, Vector3(1.4, 0.9, 0.12), Vector3(1.3, 1.9, -0.2), M.flat(Color(0.12, 0.3, 0.2)), Vector3(0, 0, 0))
	return root


## A decorated cave mouth in front of a KayKit mountain (the mountain is added by the builder).
static func cavern_mouth() -> Node3D:
	var root: Node3D = Node3D.new()
	_box(root, Vector3(3.2, 3.0, 0.5), Vector3(0, 1.5, 0), M.flat(Color(0.05, 0.04, 0.07)))
	for side: float in [-1.0, 1.0]:
		_cylinder(root, 0.22, 3.4, Vector3(side * 1.8, 1.7, 0.3), M.flat(M.WOOD), Vector3.ZERO, 8)
	_cylinder(root, 0.2, 4.0, Vector3(0, 3.3, 0.3), M.flat(M.WOOD_DARK), Vector3(0, 0, 90), 8)
	barbell_bar(root, Vector3(0, 3.9, 0.3), 3.6, 0.36, M.ROCK_DARK)
	for torch: float in [-2.2, 2.2]:
		_cylinder(root, 0.07, 1.6, Vector3(torch, 0.8, 0.9), M.flat(M.WOOD_DARK), Vector3.ZERO, 6)
		var flame: SphereMesh = SphereMesh.new()
		flame.radius = 0.2
		flame.height = 0.4
		flame.radial_segments = 6
		flame.rings = 3
		_mesh(root, flame, M.glow(Color(1.0, 0.6, 0.15), 2.4), Vector3(torch, 1.7, 0.9))
	return root


## A hanging post sign: a board on a post, text added by the builder.
static func sign_post(width: float, height: float, style: String) -> Node3D:
	var root: Node3D = Node3D.new()
	var post_color: StandardMaterial3D = M.flat(M.WOOD_DARK)
	match style:
		"poster":
			for side: float in [-1.0, 1.0]:
				_cylinder(root, 0.07, height + 1.0, Vector3(side * (width * 0.5 + 0.1), (height + 1.0) * 0.5, 0), post_color, Vector3.ZERO, 6)
			_box(root, Vector3(width + 0.14, height + 0.14, 0.08), Vector3(0, 1.4 + height * 0.5, 0), M.flat(M.COPPER))
			_box(root, Vector3(width, height, 0.1), Vector3(0, 1.4 + height * 0.5, 0.01), M.flat(Color(0.98, 0.93, 0.8)))
		"memo":
			_cylinder(root, 0.06, 1.1, Vector3(0, 0.55, 0), post_color, Vector3.ZERO, 6)
			_box(root, Vector3(width, height, 0.06), Vector3(0, 1.1 + height * 0.5, 0.0), M.flat(Color(1.0, 0.95, 0.65)))
		_:
			for side: float in [-1.0, 1.0]:
				_cylinder(root, 0.08, 1.9, Vector3(side * (width * 0.5 - 0.1), 0.95, 0), post_color, Vector3.ZERO, 6)
			_box(root, Vector3(width, height, 0.14), Vector3(0, 1.45 + height * 0.5, 0.0), M.flat(Color(0.85, 0.66, 0.42)))
			_box(root, Vector3(width + 0.16, height + 0.16, 0.08), Vector3(0, 1.45 + height * 0.5, -0.03), post_color)
	return root
