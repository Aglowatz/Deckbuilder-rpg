class_name GainlandsGym
extends RefCounted
## Gainlands v2, Part D: gym equipment as the zone's main decoration (docs/art/gainlands_v2.md). Every piece is built into a shared KitMesh at storybook scale
## (hero 1.7 m, props slightly oversized: a squat rack's bar at 1.45 m, plates up to 0.6 m across, a kettlebell knee-high), so a whole lifting yard is one
## mesh. The layout lists each yard's items (`GainlandsLayout.yard_items`: kind, position, yaw, blocking radius); `yard(items)` builds them, and the zone
## builder indexes their circles. Kinds: squat_rack, bench, dumbbell_rack, kettlebell_rack, atlas_stones, tire, tire_pair, sled_track, pullup_frame,
## rope_station, plate_stack, chalk_bucket, leg_press (the Iron Cave's leg-day kit).

const KINDS: Array[String] = ["squat_rack", "bench", "dumbbell_rack", "kettlebell_rack", "atlas_stones", "tire", "tire_pair", "sled_track", "pullup_frame", "rope_station", "plate_stack", "chalk_bucket", "leg_press"]


static func materials(mesh: KitMesh) -> void:
	mesh.set_material("iron", EnvKit.material("GAIN-WALL-IRON") if EnvKit.has("GAIN-WALL-IRON") else EnvKit.flat(Color("4a4a54"), "gym_iron"))
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "gym"))
	mesh.alias("steel", "flat", Color("8f939e"))
	mesh.alias("black", "flat", Color("2d2a30"))
	mesh.alias("rubber", "flat", Color("3a3436"))
	mesh.alias("red", "flat", Color("d9483b"))
	mesh.alias("blue", "flat", Color("3d6fd0"))
	mesh.alias("gold", "flat", Color("f2c14e"))
	mesh.alias("chalk", "flat", Color("f4f1ea"))
	mesh.alias("leather", "flat", Color("8a3a2c"))
	mesh.alias("rope", "flat", Color("c9a46a"))
	mesh.alias("stone", "flat", Color("b8aa98"))
	mesh.alias("wood", "flat", Color("9a6a42"))


## One yard: every item of `items` ([{kind, pos (local to `origin`), yaw}]) in one mesh under a Node3D at `origin`.
static func yard(items: Array, origin: Vector3, node_name: String) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	materials(mesh)
	for entry: Variant in items:
		var item: Dictionary = entry as Dictionary
		build_item(mesh, str(item["kind"]), (item["pos"] as Vector3) - origin, float(item.get("yaw", 0.0)))
	var root: Node3D = Node3D.new()
	root.name = node_name
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	root.set_meta("triangles", mesh.triangle_count())
	root.position = origin
	return root


## A point of an item: `local` turned by `yaw` (degrees) round `at`.
static func _p(at: Vector3, yaw: float, local: Vector3) -> Vector3:
	return at + Basis(Vector3.UP, deg_to_rad(yaw)) * local


static func build_item(mesh: KitMesh, kind: String, at: Vector3, yaw: float) -> void:
	var turn: Basis = Basis(Vector3.UP, deg_to_rad(yaw))
	match kind:
		"squat_rack":
			for side: float in [-1.0, 1.0]:
				for z: float in [-0.5, 0.5]:
					mesh.box("iron", _p(at, yaw, Vector3(side * 0.8, 1.2, z)), Vector3(0.12, 2.4, 0.12), turn, 0.0)
				mesh.box("iron", _p(at, yaw, Vector3(side * 0.8, 2.36, 0)), Vector3(0.14, 0.1, 1.1), turn, 0.0)
				mesh.box("iron", _p(at, yaw, Vector3(side * 0.8, 0.85, 0.25)), Vector3(0.12, 0.09, 0.8), turn, 0.0)
				mesh.box("rubber", _p(at, yaw, Vector3(side * 0.8, 0.04, 0)), Vector3(0.5, 0.08, 1.4), turn, 0.0)
			_bar(mesh, at, yaw, 1.45, 1.35, 0.3)
		"bench":
			mesh.box("leather", _p(at, yaw, Vector3(0, 0.5, 0)), Vector3(0.46, 0.14, 1.35), turn, 0.04)
			for z: float in [-0.5, 0.5]:
				mesh.box("steel", _p(at, yaw, Vector3(0, 0.23, z)), Vector3(0.38, 0.46, 0.08), turn, 0.0)
		"dumbbell_rack":
			for tier: int in range(2):
				var y: float = 0.5 + 0.42 * float(tier)
				var z: float = 0.12 * float(1 - tier)
				mesh.box("iron", _p(at, yaw, Vector3(0, y, z)), Vector3(2.2, 0.08, 0.5), turn * Basis(Vector3(1, 0, 0), -0.25), 0.0)
				for k: int in range(5):
					var x: float = -0.9 + 0.45 * float(k)
					var r: float = 0.11 + 0.02 * float(k)
					for pair: float in [-0.1, 0.1]:
						var c: Vector3 = Vector3(x + pair, y + r + 0.04, z)
						mesh.tube("steel", _p(at, yaw, c + Vector3(0, 0, -0.14)), _p(at, yaw, c + Vector3(0, 0, 0.14)), 0.03, 5, false)
						mesh.tube("black", _p(at, yaw, c + Vector3(0, 0, -0.24)), _p(at, yaw, c + Vector3(0, 0, -0.13)), r, 8, true)
						mesh.tube("black", _p(at, yaw, c + Vector3(0, 0, 0.13)), _p(at, yaw, c + Vector3(0, 0, 0.24)), r, 8, true)
			for x: float in [-1.1, 1.1]:
				mesh.box("iron", _p(at, yaw, Vector3(x, 0.5, 0)), Vector3(0.1, 1.0, 0.6), turn, 0.0)
		"kettlebell_rack":
			mesh.box("wood", _p(at, yaw, Vector3(0, 0.3, 0)), Vector3(1.8, 0.08, 0.55), turn, 0.02)
			for x: float in [-0.85, 0.85]:
				mesh.box("iron", _p(at, yaw, Vector3(x, 0.15, 0)), Vector3(0.08, 0.3, 0.5), turn, 0.0)
			for k: int in range(4):
				var x: float = -0.66 + 0.44 * float(k)
				var r: float = 0.13 + 0.02 * float(k % 3)
				var c: Vector3 = _p(at, yaw, Vector3(x, 0.34 + r, 0))
				mesh.blob("black" if k % 2 == 0 else "red", c, Vector3(r, r, r), 4, 9, 0.95)
				mesh.tube("black", c + Vector3(0, r * 0.7, 0) + turn * Vector3(-r * 0.6, 0, 0), c + Vector3(0, r * 1.5, 0), 0.03, 4, false)
				mesh.tube("black", c + Vector3(0, r * 1.5, 0), c + Vector3(0, r * 0.7, 0) + turn * Vector3(r * 0.6, 0, 0), 0.03, 4, false)
		"atlas_stones":
			var sizes: Array[float] = [0.32, 0.4, 0.48, 0.56]
			for k: int in range(4):
				var x: float = -1.5 + 1.0 * float(k)
				mesh.lathe("stone", _p(at, yaw, Vector3(x, 0.0, 0)), [Vector2(0.42, 0.0), Vector2(0.42, 0.18), Vector2(0.0, 0.18)], 10, 0.9, false, true)
				mesh.blob("stone", _p(at, yaw, Vector3(x, 0.18 + sizes[k], 0)), Vector3(sizes[k], sizes[k], sizes[k]), 5, 10, 0.92)
		"tire":
			_tire(mesh, at, 0.0)
		"tire_pair":
			_tire(mesh, _p(at, yaw, Vector3(-0.85, 0, 0)), 0.0)
			_tire(mesh, _p(at, yaw, Vector3(0.75, 0, 0.2)), 0.0)
			_tire(mesh, _p(at, yaw, Vector3(-0.05, 0.42, 0.1)), 0.0)
		"sled_track":
			for side: float in [-0.7, 0.7]:
				mesh.box("rubber", _p(at, yaw, Vector3(0, 0.03, side)), Vector3(7.0, 0.06, 0.5), turn, 0.0)
				mesh.box("chalk", _p(at, yaw, Vector3(0, 0.065, side)), Vector3(7.0, 0.01, 0.05), turn, 0.0)
			var sled: Vector3 = Vector3(-2.4, 0, 0)
			mesh.box("iron", _p(at, yaw, sled + Vector3(0, 0.12, 0)), Vector3(1.0, 0.16, 1.1), turn, 0.03)
			mesh.tube("steel", _p(at, yaw, sled + Vector3(0.4, 0.2, -0.4)), _p(at, yaw, sled + Vector3(0.5, 1.15, -0.4)), 0.04, 5, true)
			mesh.tube("steel", _p(at, yaw, sled + Vector3(0.4, 0.2, 0.4)), _p(at, yaw, sled + Vector3(0.5, 1.15, 0.4)), 0.04, 5, true)
			mesh.tube("steel", _p(at, yaw, sled + Vector3(0.5, 1.15, -0.45)), _p(at, yaw, sled + Vector3(0.5, 1.15, 0.45)), 0.04, 5, true)
			for k: int in range(3):
				mesh.lathe("red" if k == 1 else "black", _p(at, yaw, sled + Vector3(-0.15, 0.2 + 0.08 * float(k), 0)), [Vector2(0.3 - 0.03 * float(k), 0.0), Vector2(0.3 - 0.03 * float(k), 0.07), Vector2(0.05, 0.07)], 12, 1.0, true, true)
		"pullup_frame":
			for side: float in [-1.0, 1.0]:
				mesh.box("iron", _p(at, yaw, Vector3(side * 1.1, 1.35, 0)), Vector3(0.14, 2.7, 0.14), turn, 0.0)
				mesh.box("iron", _p(at, yaw, Vector3(side * 1.1, 0.06, 0)), Vector3(0.3, 0.12, 0.9), turn, 0.0)
			mesh.tube("steel", _p(at, yaw, Vector3(-1.2, 2.55, 0)), _p(at, yaw, Vector3(1.2, 2.55, 0)), 0.04, 6, true)
			for x: float in [-0.35, 0.35]:
				mesh.tube("rope", _p(at, yaw, Vector3(x, 2.55, 0)), _p(at, yaw, Vector3(x, 1.95, 0)), 0.025, 4, false)
				mesh.lathe("black", _p(at, yaw, Vector3(x, 1.85, 0)), [Vector2(0.09, 0.0), Vector2(0.09, 0.1), Vector2(0.06, 0.1)], 8, 1.0, true, true)
		"rope_station":
			mesh.box("wood", _p(at, yaw, Vector3(-0.9, 1.5, 0)), Vector3(0.22, 3.0, 0.22), turn, 0.02)
			mesh.box("wood", _p(at, yaw, Vector3(-0.35, 2.95, 0)), Vector3(1.3, 0.2, 0.2), turn, 0.02)
			mesh.tube("rope", _p(at, yaw, Vector3(0.2, 2.9, 0)), _p(at, yaw, Vector3(0.25, 0.4, 0.1)), 0.06, 6, false)
			mesh.lathe("rope", _p(at, yaw, Vector3(0.45, 0.0, 0.2)), [Vector2(0.38, 0.0), Vector2(0.4, 0.12), Vector2(0.3, 0.28), Vector2(0.12, 0.28)], 10, 0.95, false, true)
		"plate_stack":
			var y: float = 0.0
			for k: int in range(6):
				var r: float = 0.3 - 0.025 * float(k)
				var slot: String = ["black", "red", "blue", "black", "gold", "black"][k]
				mesh.lathe(slot, _p(at, yaw, Vector3(0, y, 0)), [Vector2(r, 0.0), Vector2(r, 0.075), Vector2(0.05, 0.075)], 14, 1.0, true, true)
				y += 0.085
			mesh.tube("steel", _p(at, yaw, Vector3(0, 0, 0)), _p(at, yaw, Vector3(0, y + 0.25, 0)), 0.04, 5, true)
		"chalk_bucket":
			mesh.lathe("blue", at, [Vector2(0.2, 0.0), Vector2(0.24, 0.4), Vector2(0.22, 0.4)], 10, 0.95, true, false)
			mesh.lathe("chalk", at + Vector3(0, 0.36, 0), [Vector2(0.21, 0.0), Vector2(0.12, 0.08), Vector2(0.0, 0.1)], 10, 1.0, false, true)
		"leg_press":
			# a sled leg press: a sloped iron frame, the carriage with plates on its horns, a padded seat at the low end
			var slope: Basis = turn * Basis(Vector3(1, 0, 0), deg_to_rad(-40.0))
			mesh.box("iron", _p(at, yaw, Vector3(0, 0.12, 0)), Vector3(1.2, 0.24, 2.6), turn, 0.02)
			for side: float in [-0.45, 0.45]:
				mesh.box("iron", _p(at, yaw, Vector3(side, 1.0, -0.35)), Vector3(0.12, 0.12, 2.5), slope, 0.0)
			mesh.box("steel", _p(at, yaw, Vector3(0, 1.45, -0.85)), Vector3(1.0, 0.7, 0.12), slope, 0.02)
			for side: float in [-1.0, 1.0]:
				mesh.tube("steel", _p(at, yaw, Vector3(side * 0.5, 1.5, -0.95)), _p(at, yaw, Vector3(side * 0.85, 1.55, -0.98)), 0.04, 5, true)
				mesh.tube("red", _p(at, yaw, Vector3(side * 0.62, 1.52, -0.96)), _p(at, yaw, Vector3(side * 0.72, 1.53, -0.97)), 0.28, 12, true)
			mesh.box("leather", _p(at, yaw, Vector3(0, 0.5, 0.95)), Vector3(0.6, 0.14, 0.7), turn * Basis(Vector3(1, 0, 0), deg_to_rad(15.0)), 0.04)
			mesh.box("leather", _p(at, yaw, Vector3(0, 0.85, 1.3)), Vector3(0.6, 0.6, 0.14), turn * Basis(Vector3(1, 0, 0), deg_to_rad(-20.0)), 0.04)


## A loaded barbell `length` long at `height`, plates `plate_r` in radius, along the item's x.
static func _bar(mesh: KitMesh, at: Vector3, yaw: float, height: float, half_length: float, plate_r: float) -> void:
	mesh.tube("steel", _p(at, yaw, Vector3(-half_length, height, 0)), _p(at, yaw, Vector3(half_length, height, 0)), 0.035, 6, true)
	for side: float in [-1.0, 1.0]:
		for k: int in range(2):
			var x: float = side * (half_length - 0.32 + 0.09 * float(k))
			mesh.tube("red" if k == 0 else "black", _p(at, yaw, Vector3(x - 0.04, height, 0)), _p(at, yaw, Vector3(x + 0.04, height, 0)), plate_r - 0.05 * float(k), 14, true)


## A tractor tyre lying flat: a fat black ring with a tread line, 1.5 m across.
static func _tire(mesh: KitMesh, at: Vector3, _yaw: float) -> void:
	mesh.lathe("black", at, [Vector2(0.42, 0.0), Vector2(0.75, 0.02), Vector2(0.78, 0.2), Vector2(0.75, 0.38), Vector2(0.42, 0.4), Vector2(0.38, 0.2), Vector2(0.42, 0.0)], 16, 0.95, false, false)
	mesh.lathe("rubber", at + Vector3(0, 0.36, 0), [Vector2(0.42, 0.0), Vector2(0.4, 0.02), Vector2(0.0, 0.02)], 16, 1.0, false, true)
