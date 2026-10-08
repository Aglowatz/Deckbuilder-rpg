class_name TortoiseKit
extends RefCounted
## Elder Maren is a tortoise. Until a tortoise model exists (docs/assets_wanted.md) the stand-in is the Mage character wearing a code-drawn shell on the
## back and a little hat-brim of moss: enough to read as "the tortoise" at town-camera distance.


## Adds the shell to a character model (root of the `ModelKit.character` scene, before scaling).
static func add_shell(model: Node3D) -> void:
	var shell: Node3D = Node3D.new()
	shell.name = "TortoiseShell"
	shell.position = Vector3(0.0, 1.1, -0.35)
	model.add_child(shell)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.7
	sphere.height = 1.0
	dome.mesh = sphere
	dome.scale = Vector3(1.0, 0.95, 0.8)
	dome.material_override = _material(Color("93b84e"))
	shell.add_child(dome)
	# Six pale plates and a dark rim give the shell its pattern.
	for index: int in range(6):
		var plate: MeshInstance3D = MeshInstance3D.new()
		var disc: CylinderMesh = CylinderMesh.new()
		disc.top_radius = 0.15
		disc.bottom_radius = 0.18
		disc.height = 0.05
		plate.mesh = disc
		var angle: float = TAU * float(index) / 6.0
		var ring: Vector3 = Vector3(cos(angle) * 0.36, 0.28, sin(angle) * 0.27)
		plate.position = ring
		plate.look_at_from_position(ring, ring * 2.0 + Vector3(0.0, 1.0, 0.0), Vector3.UP)
		plate.material_override = _material(Color("f0dc8a"))
		shell.add_child(plate)
	var rim: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.56
	torus.outer_radius = 0.66
	rim.mesh = torus
	rim.scale = Vector3(1.0, 0.6, 0.8)
	rim.position = Vector3(0.0, -0.08, 0.0)
	rim.material_override = _material(Color("4a3a22"))
	shell.add_child(rim)


static func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material
