class_name TownDressing
extends RefCounted
## Brief 9: the town's two new buildings change with the campaign. Auntie Alembic's (the Alchemist) is shuttered with a
## sign until two zones are free, then glows with a bubbling cauldron; the Grand Clashatorium (the Arena) has its gate
## chained until the first zone is free, then burns torches and flies banners. Built from simple primitives, once, when
## the town scene is built (unlocking always happens in another scene, so it never needs to change live).


static func alchemist(parent: Node3D, anchors: Dictionary, unlocked: bool, story: StoryText) -> void:
	var door: Vector3 = anchors.get("alchemist_door", Vector3.ZERO) as Vector3
	var root: Node3D = Node3D.new()
	root.name = "AlchemistDressing"
	parent.add_child(root)
	root.position = door
	var plank: StandardMaterial3D = _material(Color("6b4a2c"), 0.9)
	if not unlocked:
		for index: int in range(3):
			var board: MeshInstance3D = _box(Vector3(1.5, 0.16, 0.06), plank, Vector3(0, 0.45 + 0.34 * float(index), 0.5))
			board.rotation_degrees.z = -14.0 + 14.0 * float(index)
			root.add_child(board)
		var note: Label3D = _label("CLOSED", Vector3(0, 1.6, 0.6), Color("f2e8c8"), 0.0042)
		root.add_child(note)
		root.add_child(_label("(not open yet)", Vector3(0, 1.18, 0.6), Color("b9d8a8"), 0.0032))
		return
	var iron: StandardMaterial3D = _material(Color("2a2a30"), 0.4)
	var pot: MeshInstance3D = _cylinder(0.42, 0.36, iron, Vector3(0.9, 0.18, 0.7))
	root.add_child(pot)
	var brew: MeshInstance3D = _cylinder(0.36, 0.04, _glow(Color("8fe86a"), 2.2), Vector3(0.9, 0.38, 0.7))
	root.add_child(brew)
	for index: int in range(3):
		var leg: MeshInstance3D = _cylinder(0.05, 0.22, iron, Vector3(0.9 + 0.3 * cos(float(index) * TAU / 3.0), 0.0, 0.7 + 0.3 * sin(float(index) * TAU / 3.0)))
		root.add_child(leg)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color("8fe86a")
	light.light_energy = 1.6
	light.omni_range = 3.6
	light.position = Vector3(0.9, 0.9, 0.7)
	root.add_child(light)
	root.add_child(_bubbles(Vector3(0.9, 0.42, 0.7), Color("8fe86a")))
	root.add_child(_label(story.text("town.alchemist.name"), Vector3(0, 1.9, 0.6), Color("b8f58f"), 0.0046))


## Chained gate and a "CLOSED" sign before the first zone is free; torches and banners after.
static func arena_gate(parent: Node3D, anchors: Dictionary, unlocked: bool, story: StoryText) -> void:
	var gate: Vector3 = anchors.get("arena_gate", Vector3.ZERO) as Vector3
	var root: Node3D = Node3D.new()
	root.name = "ArenaDressing"
	parent.add_child(root)
	root.position = gate
	var iron: StandardMaterial3D = _material(Color("23232a"), 0.35)
	if not unlocked:
		for index: int in range(2):
			var chain: MeshInstance3D = _box(Vector3(2.2, 0.1, 0.1), iron, Vector3(0, 0.9 + 0.35 * float(index), 0.15))
			chain.rotation_degrees.z = 12.0 if index == 0 else -12.0
			root.add_child(chain)
		root.add_child(_box(Vector3(0.34, 0.4, 0.14), iron, Vector3(0, 1.0, 0.2)))
		root.add_child(_label("CLOSED", Vector3(0, 2.6, 0.3), Color("f2e8c8"), 0.0058))
		root.add_child(_label("(until the first zone is free)", Vector3(0, 2.05, 0.3), Color("ffcf70"), 0.0034))
		return
	for side: int in [-1, 1]:
		var torch: Node3D = Node3D.new()
		torch.position = Vector3(float(side) * 1.5, 0.0, 0.2)
		root.add_child(torch)
		torch.add_child(_cylinder(0.05, 1.3, _material(Color("5a3d22"), 0.9), Vector3(0, 0.65, 0)))
		torch.add_child(_ball(0.16, _glow(Color("ff9a3a"), 3.0), Vector3(0, 1.38, 0)))
		var flame: OmniLight3D = OmniLight3D.new()
		flame.light_color = Color("ffa850")
		flame.light_energy = 1.8
		flame.omni_range = 4.0
		flame.position = Vector3(0, 1.5, 0)
		torch.add_child(flame)
		torch.add_child(_bubbles(Vector3(0, 1.45, 0), Color("ffb060")))
		var banner: MeshInstance3D = _box(Vector3(0.7, 1.7, 0.06), _material(Color("a8321f") if side < 0 else Color("1f4aa8"), 0.85), Vector3(float(side) * 2.2, 2.4, 0.1))
		root.add_child(banner)
	root.add_child(_label(story.text("town.arena.name"), Vector3(0, 3.1, 0.3), Color("ffd98a"), 0.0075))


static func _material(color: Color, rough: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = rough
	return material


static func _glow(color: Color, energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
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


static func _ball(radius: float, material: Material, pos: Vector3) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var instance: MeshInstance3D = MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	return instance


static func _label(text: String, pos: Vector3, color: Color, pixel_size: float) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font = UIStyle.font_title()
	label.font_size = 48
	label.pixel_size = pixel_size
	label.modulate = color
	label.outline_size = 10
	label.outline_modulate = Color(0.05, 0.04, 0.03, 0.95)
	label.position = pos
	label.double_sided = false
	return label


static func _bubbles(pos: Vector3, color: Color) -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.position = pos
	particles.amount = 14
	particles.lifetime = 1.8
	particles.direction = Vector3.UP
	particles.spread = 18.0
	particles.initial_velocity_min = 0.3
	particles.initial_velocity_max = 0.7
	particles.gravity = Vector3.ZERO
	var mote: SphereMesh = SphereMesh.new()
	mote.radius = 0.04
	mote.height = 0.08
	mote.material = _glow(color, 2.5)
	particles.mesh = mote
	return particles
