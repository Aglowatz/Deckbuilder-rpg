class_name HubRelics
extends RefCounted
## Crosspath pass, Part B: the hub's small story objects rebuilt from kit stone and timber instead of tinted KayKit blocks: the Restless Cairn (a
## dark stack of fieldstones), the graveyard's headstones, and the old lever that unseals the vault (an iron lever in a stone block). Each is
## one KitMesh, rigid, storybook scale (the cairn reaches the hero's chest, a headstone the hip, the lever post the shoulder).


static func _stone_mesh(tint: Color = Color.WHITE) -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION", false, tint))
	mesh.set_material("rock", BoundaryKit._rock_material())
	mesh.set_material("beam", EnvKit.material("ENV-BEAM"))
	mesh.set_material("iron", EnvKit.flat(Color("3a3430"), "iron"))
	mesh.set_material("moss", EnvKit.flat(Color("4f7a3a"), "moss"))
	return mesh


## The Restless Cairn: dark fieldstones piled to chest height, a flat capstone, moss in the cracks.
static func cairn() -> Node3D:
	var mesh: KitMesh = _stone_mesh(Color(0.42, 0.4, 0.46))
	mesh.set_material("rock", _dark_rock())
	var stones: Array = [
		[Vector3(0.0, 0.32, 0.0), Vector3(0.85, 0.42, 0.85)], [Vector3(0.35, 0.3, 0.42), Vector3(0.5, 0.32, 0.5)], [Vector3(-0.42, 0.28, 0.3), Vector3(0.48, 0.3, 0.48)],
		[Vector3(0.05, 0.78, 0.02), Vector3(0.6, 0.34, 0.6)], [Vector3(-0.05, 1.12, 0.0), Vector3(0.42, 0.26, 0.42)],
	]
	for entry: Array in stones:
		mesh.blob("rock", entry[0] as Vector3, entry[1] as Vector3, 4, 9, 0.7)
	mesh.box("stone", Vector3(0.0, 1.38, 0.0), Vector3(0.62, 0.12, 0.5), Basis(Vector3.UP, 0.3), 0.04, 0.8)
	mesh.blob("moss", Vector3(0.45, 0.5, 0.35), Vector3(0.2, 0.08, 0.2), 3, 6)
	return _finish(mesh, "RestlessCairn")


## A worn headstone with a rounded top, leaning a little.
static func headstone(seed_value: int) -> Node3D:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 900 + seed_value
	var mesh: KitMesh = _stone_mesh(Color(0.78, 0.78, 0.8))
	var lean: Basis = Basis(Vector3(1, 0, 0), rng.randf_range(-0.12, 0.08)) * Basis(Vector3.UP, rng.randf_range(-0.25, 0.25))
	var height: float = rng.randf_range(0.7, 0.95)
	mesh.box("stone", Vector3(0.0, height * 0.5, 0.0), Vector3(0.62, height, 0.16), lean, 0.05, 0.75)
	mesh.lathe("stone", lean * Vector3(0.0, height, 0.0), [Vector2(0.31, 0.0), Vector2(0.27, 0.12), Vector2(0.14, 0.24), Vector2(0.0, 0.28)], 10, 0.85)
	mesh.box("stone", Vector3(0.0, 0.05, 0.12), Vector3(0.8, 0.1, 0.5), Basis.IDENTITY, 0.03, 0.7)
	if rng.randf() < 0.6:
		mesh.blob("moss", Vector3(0.18, 0.12, 0.1), Vector3(0.16, 0.07, 0.16), 3, 6)
	return _finish(mesh, "Headstone")


## The old lever: a squared stone block with an iron slot, the lever arm thrown back, a timber handle.
static func lever() -> Node3D:
	var mesh: KitMesh = _stone_mesh()
	mesh.box("stone", Vector3(0.0, 0.35, 0.0), Vector3(0.7, 0.7, 0.6), Basis.IDENTITY, 0.06, 0.75)
	mesh.box("iron", Vector3(0.0, 0.71, 0.0), Vector3(0.14, 0.04, 0.46), Basis.IDENTITY, 0.0)
	var arm: Basis = Basis(Vector3(1, 0, 0), -0.45)
	mesh.box("iron", Vector3(0.0, 0.71, 0.0) + arm * Vector3(0.0, 0.42, 0.0), Vector3(0.07, 0.84, 0.07), arm, 0.01)
	mesh.box("beam", Vector3(0.0, 0.71, 0.0) + arm * Vector3(0.0, 0.9, 0.0), Vector3(0.12, 0.26, 0.12), arm, 0.03)
	mesh.blob("moss", Vector3(-0.28, 0.08, 0.28), Vector3(0.18, 0.08, 0.18), 3, 6)
	return _finish(mesh, "OldLever")


## The debug-only Dev Shrine (DevTools): a waist-high kit-stone plinth with a glowing crystal on it (the KayKit tower stood in for it).
static func dev_shrine() -> Node3D:
	var mesh: KitMesh = _stone_mesh()
	mesh.set_material("crystal", EnvKit.glow(Color("b48cff"), 1.6))
	mesh.box("stone", Vector3(0.0, 0.12, 0.0), Vector3(1.3, 0.24, 1.3), Basis.IDENTITY, 0.04, 0.75)
	mesh.lathe("stone", Vector3(0.0, 0.24, 0.0), [Vector2(0.42, 0.0), Vector2(0.34, 0.12), Vector2(0.3, 0.72), Vector2(0.5, 0.82), Vector2(0.5, 0.92)], 12, 0.85, false, true)
	mesh.lathe("crystal", Vector3(0.0, 1.16, 0.0), [Vector2(0.0, 0.0), Vector2(0.18, 0.2), Vector2(0.14, 0.62), Vector2(0.0, 0.84)], 6, 1.0, false, false)
	return _finish(mesh, "DevShrine")


static func _dark_rock() -> StandardMaterial3D:
	var material: StandardMaterial3D = BoundaryKit._rock_material()
	material.albedo_color = Color(0.36, 0.34, 0.4)
	return material


static func _finish(mesh: KitMesh, node_name: String) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_occlusion_fade", true)
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	return root
