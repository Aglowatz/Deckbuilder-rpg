class_name FourSealVault
extends RefCounted
## Brief 16, Group G: the Four-Seal Vault in the main town - a stone door set in the south face of a mountain, framed by two pillars and a lintel that carries four seal discs, one
## per Path (Gainlands, Endless Buffet, Verdant Dump, D.N.A.). A seal is dark, grey and cracked until its lever is pulled; then it lights up in its Path colour. With all four lit
## the door glows; once the Warden is beaten the door slides down for good. The node is built from the save's flags, so the vault visibly changes after each lever.

const DOOR_NODE: String = "Door"
const SEAL_PREFIX: String = "Seal_"
const DOOR_DOWN_Y: float = -3.4


## Builds the vault at `position` (the foot of the door, facing +z) under `parent` and applies the current state.
static func build(parent: Node3D, position: Vector3) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "FourSealVault"
	root.position = position
	parent.add_child(root)
	var stone: Color = Color("6b6878")
	var dark: Color = Color("3b3947")
	var gold: Color = Color("c9a24a")
	var frame: ProcMesh = ProcMesh.new()
	for side: float in [-1.0, 1.0]:
		frame.box(Vector3(side * 1.65, 1.9, 0.1), Vector3(0.8, 3.8, 0.9), stone)
		frame.box(Vector3(side * 1.65, 3.9, 0.1), Vector3(1.0, 0.3, 1.1), dark)
		frame.box(Vector3(side * 1.65, 0.15, 0.1), Vector3(1.0, 0.3, 1.1), dark)
	frame.box(Vector3(0.0, 4.15, 0.1), Vector3(4.6, 0.9, 1.0), stone)
	frame.box(Vector3(0.0, 4.65, 0.1), Vector3(4.8, 0.2, 1.1), gold)
	frame.box(Vector3(0.0, 3.62, 0.62), Vector3(3.9, 0.12, 0.16), gold)
	root.add_child(frame.build("Frame"))
	var door: MeshInstance3D = _door_mesh().build(DOOR_NODE)
	door.position = Vector3(0.0, 0.0, 0.0)
	root.add_child(door)
	for index: int in range(VaultGuardian.ZONE_IDS.size()):
		var zone_id: String = VaultGuardian.ZONE_IDS[index]
		var seal: MeshInstance3D = MeshInstance3D.new()
		seal.name = SEAL_PREFIX + zone_id
		var disc: CylinderMesh = CylinderMesh.new()
		disc.top_radius = 0.36
		disc.bottom_radius = 0.36
		disc.height = 0.14
		seal.mesh = disc
		seal.rotation_degrees.x = 90.0
		seal.position = Vector3(-1.5 + 1.0 * float(index), 4.15, 0.66)
		seal.set_meta(StyleToon.META_NO_TOON, true)
		root.add_child(seal)
		var light: OmniLight3D = OmniLight3D.new()
		light.name = "Light_" + zone_id
		light.position = seal.position + Vector3(0.0, 0.0, 0.5)
		light.omni_range = 2.6
		light.light_energy = 0.0
		root.add_child(light)
	refresh(root)
	return root


static func _door_mesh() -> ProcMesh:
	var mesh: ProcMesh = ProcMesh.new()
	mesh.box(Vector3(0.0, 1.6, 0.0), Vector3(2.5, 3.2, 0.34), Color("55525f"))
	mesh.box(Vector3(0.0, 1.6, 0.18), Vector3(0.14, 3.0, 0.06), Color("2f2d39"))
	for row: int in range(4):
		mesh.box(Vector3(-0.62, 0.55 + 0.7 * float(row), 0.2), Vector3(0.9, 0.4, 0.05), Color("46434f"))
		mesh.box(Vector3(0.62, 0.55 + 0.7 * float(row), 0.2), Vector3(0.9, 0.4, 0.05), Color("46434f"))
	return mesh


## Shows the save's state: which seals are lit, a glowing door once all four are, and a lowered door after the Warden fell.
static func refresh(root: Node3D) -> void:
	var lit: int = 0
	for zone_id: String in VaultGuardian.ZONE_IDS:
		var pulled: bool = Session.vault_lever_pulled(zone_id)
		if pulled:
			lit += 1
		set_seal(root, zone_id, pulled)
	var door: Node3D = root.get_node_or_null(DOOR_NODE) as Node3D
	if door == null:
		return
	door.position.y = DOOR_DOWN_Y if Session.vault_defeated() else 0.0
	var glowing: bool = lit == VaultGuardian.ZONE_IDS.size() and not Session.vault_defeated()
	var material: StandardMaterial3D = door.get_meta(&"glow_material") as StandardMaterial3D if door.has_meta(&"glow_material") else null
	if glowing and material == null:
		material = StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		material.albedo_color = Color(1.0, 0.85, 0.45, 0.22)
		var halo: MeshInstance3D = MeshInstance3D.new()
		halo.name = "DoorGlow"
		var quad: QuadMesh = QuadMesh.new()
		quad.size = Vector2(2.9, 3.6)
		halo.mesh = quad
		halo.material_override = material
		halo.position = Vector3(0.0, 1.8, 0.42)
		halo.set_meta(StyleToon.META_NO_TOON, true)
		root.add_child(halo)
		door.set_meta(&"glow_material", material)
	var existing: Node = root.get_node_or_null("DoorGlow")
	if existing != null:
		(existing as Node3D).visible = glowing


static func set_seal(root: Node3D, zone_id: String, lit: bool) -> void:
	var seal: MeshInstance3D = root.get_node_or_null(SEAL_PREFIX + zone_id) as MeshInstance3D
	if seal == null:
		return
	var color: Color = VaultLeverEvent.seal_color(zone_id)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	if lit:
		material.albedo_color = color
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 2.2
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	else:
		material.albedo_color = Color("3a3845")
		material.roughness = 0.95
	seal.material_override = material
	var light: OmniLight3D = root.get_node_or_null("Light_" + zone_id) as OmniLight3D
	if light != null:
		light.light_color = color
		light.light_energy = 0.9 if lit else 0.0
