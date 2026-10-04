class_name ArenaBuilding
extends RefCounted
## The Grand Clashatorium (Part G): a big colosseum in Concord Crossing, built from simple primitives (a ring of two
## tiers of arches, a sand floor with tiered seats inside, banners on the rim) with its main gate facing north (-z),
## where the interaction spot and the dressing (chains / torches, see `TownDressing.arena_gate`) go.

const RADIUS: float = 2.7
const SEGMENTS: int = 22


## Builds the colosseum under `parent` centred on `center`; returns its root.
static func build(parent: Node3D, center: Vector3) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "GrandClashatorium"
	parent.add_child(root)
	root.position = center
	var stone: StandardMaterial3D = _material(Color("d9c79a"), 0.85)
	var dark: StandardMaterial3D = _material(Color("8a7650"), 0.9)
	var sand: StandardMaterial3D = _material(Color("e8d6a2"), 1.0)
	var shadow: StandardMaterial3D = _material(Color("2a2118"), 1.0)
	# The sand floor.
	root.add_child(_cylinder(RADIUS - 0.25, 0.12, sand, Vector3(0, 0.06, 0)))
	# Tiered seats inside, rising toward the wall.
	for tier: int in range(3):
		root.add_child(_ring(RADIUS - 0.55 - 0.3 * float(tier), 0.3, 0.45 + 0.45 * float(tier), dark, SEGMENTS * 2, -1.0))
	for tier: int in range(2):
		var base_height: float = 0.0 if tier == 0 else 1.65
		# Pillars and lintels of one tier of arches (the gate gap is at angle PI/2, facing -z).
		for index: int in range(SEGMENTS):
			var angle: float = TAU * float(index) / float(SEGMENTS)
			if _is_gate(angle) and tier == 0:
				continue
			var radius: float = RADIUS - 0.05 * float(tier)
			var pillar_pos: Vector3 = Vector3(cos(angle) * radius, base_height + 0.8, sin(angle) * radius)
			var pillar: MeshInstance3D = _box(Vector3(0.34, 1.6, 0.34), stone, pillar_pos)
			pillar.rotation.y = -angle
			root.add_child(pillar)
			var next_angle: float = TAU * (float(index) + 0.5) / float(SEGMENTS)
			var lintel_pos: Vector3 = Vector3(cos(next_angle) * radius, base_height + 1.45, sin(next_angle) * radius)
			var lintel: MeshInstance3D = _box(Vector3(0.62, 0.3, 0.38), stone, lintel_pos)
			lintel.rotation.y = -next_angle - PI * 0.5
			root.add_child(lintel)
			# The dark arch opening behind each bay.
			var bay_pos: Vector3 = Vector3(cos(next_angle) * (radius - 0.06), base_height + 0.75, sin(next_angle) * (radius - 0.06))
			var bay: MeshInstance3D = _box(Vector3(0.44, 1.0, 0.1), shadow, bay_pos)
			bay.rotation.y = -next_angle - PI * 0.5
			root.add_child(bay)
	# The rim, banners and the gate arch.
	root.add_child(_ring(RADIUS + 0.05, 0.28, 3.35, stone, SEGMENTS, -1.0))
	var banner_colors: Array[Color] = [Color("a8321f"), Color("1f4aa8"), Color("2f7a3a"), Color("6a2a7a")]
	for index: int in range(8):
		var angle: float = TAU * (float(index) + 0.5) / 8.0
		if _is_gate(angle):
			continue
		var banner: MeshInstance3D = _box(Vector3(0.45, 1.1, 0.05), _material(banner_colors[index % 4], 0.9), Vector3(cos(angle) * (RADIUS + 0.1), 3.9, sin(angle) * (RADIUS + 0.1)))
		banner.rotation.y = -angle - PI * 0.5
		root.add_child(banner)
	var gate_angle: float = PI * 0.5
	root.add_child(_box(Vector3(1.55, 0.35, 0.5), stone, Vector3(cos(gate_angle) * (RADIUS + 0.02), 1.75, sin(gate_angle) * (RADIUS + 0.02))))
	root.add_child(_box(Vector3(1.2, 1.7, 0.2), shadow, Vector3(cos(gate_angle) * (RADIUS - 0.05), 0.85, sin(gate_angle) * (RADIUS - 0.05))))
	return root


static func _is_gate(angle: float) -> bool:
	return absf(wrapf(angle - PI * 0.5, -PI, PI)) < TAU / float(SEGMENTS) * 0.9


## A ring of `segments` blocks of `height`, `thickness` deep, at `radius` and `y`.
static func _ring(radius: float, thickness: float, y: float, material: StandardMaterial3D, segments: int, _unused: float) -> Node3D:
	var ring: Node3D = Node3D.new()
	var width: float = TAU * radius / float(segments) * 1.05
	for index: int in range(segments):
		var angle: float = TAU * float(index) / float(segments)
		if _is_gate(angle) and y < 2.0:
			continue
		var block: MeshInstance3D = _box(Vector3(width, 0.3, thickness), material, Vector3(cos(angle) * radius, y, sin(angle) * radius))
		block.rotation.y = -angle - PI * 0.5
		ring.add_child(block)
	return ring


static func _material(color: Color, rough: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = rough
	return material


static func _box(size: Vector3, material: Material, pos: Vector3) -> MeshInstance3D:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	return instance


static func _cylinder(radius: float, height: float, material: Material, pos: Vector3) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	return instance
