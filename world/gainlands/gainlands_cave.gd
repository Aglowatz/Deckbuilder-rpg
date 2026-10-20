class_name GainlandsCave
extends RefCounted
## Gainlands v2, Part F: the Gainlands' two dungeon approaches (docs/art/gainlands_v2.md).
##  - `mouth()`: the Iron Cave's entrance in the north-west cliff face (STANDIN): a dark arched opening 5 m wide in rough sandstone, timber mine props with
##    an iron lintel, a big iron dumbbell bolted over the mouth (the leg-day emblem, no lettering), worn stone steps down into the dark, torches. The leg-day
##    kit beside it (squat racks, a leg press, plates, chalk) is a lifting yard of the layout. Origin at the foot of the cliff on the plateau, front +z.
##  - `swolympus_ridge(...)`: the land bridge from the right road's overlook toward Mount Swolympus: a narrow rock spine carrying a paved causeway with
##    parapet stubs and lamp posts, which ends at a collapsed span (a broken arch, a chasm, fallen blocks in the water) before the far spine reaches the
##    mountain's foot. A view: nothing on it is walkable; the sealed gate stands at its start.

const MOUTH_W: float = 5.0
const MOUTH_H: float = 4.6


static func mouth() -> Node3D:
	var mesh: KitMesh = GainlandsStructures._kit()
	mesh.alias("rubble", "sandstone", Color(0.86, 0.8, 0.72))
	var hw: float = MOUTH_W * 0.5
	# the dark: a deep recess, arched at the top (stacked courses narrowing like a rough vault)
	mesh.box("dark", Vector3(0, MOUTH_H * 0.36, -0.6), Vector3(MOUTH_W, MOUTH_H * 0.72, 1.2), Basis.IDENTITY, 0.0)
	for k: int in range(4):
		var t: float = float(k + 1) / 5.0
		var w: float = MOUTH_W * sqrt(1.0 - t * t)
		mesh.box("dark", Vector3(0, MOUTH_H * 0.72 + MOUTH_H * 0.07 * float(k) + 0.15, -0.6), Vector3(w, MOUTH_H * 0.075, 1.2), Basis.IDENTITY, 0.0)
	# the rough rock frame round the opening
	for k: int in range(11):
		var a: float = PI * float(k) / 10.0
		var r: float = hw + 0.65
		var c: Vector3 = Vector3(cos(a) * r, MOUTH_H * 0.7 + sin(a) * (MOUTH_H * 0.4 + 0.5), 0.15)
		if c.y < MOUTH_H * 0.7:
			c.y = MOUTH_H * 0.7 * (float(k % 2) * 0.3 + 0.55)
		var size: float = 0.75 + 0.35 * float((k * 7) % 3)
		mesh.blob("rock", c, Vector3(size, size * 0.85, size), 4, 8, 0.9)
	for side: float in [-1.0, 1.0]:
		for k: int in range(3):
			mesh.blob("rock", Vector3(side * (hw + 0.7), 0.5 + 1.1 * float(k), 0.2), Vector3(0.9, 0.8, 0.9), 4, 8, 0.88)
	# timber props with an iron lintel, studded
	for side: float in [-1.0, 1.0]:
		mesh.box("bleach_dark", Vector3(side * (hw - 0.25), MOUTH_H * 0.42, 0.25), Vector3(0.4, MOUTH_H * 0.84, 0.4), Basis.IDENTITY, 0.03)
		GainlandsLandmarks._torch(mesh, Vector3(side * (hw + 0.4), 2.4, 0.75), [] as Array[Dictionary], 0.9)
	mesh.box("iron", Vector3(0, MOUTH_H * 0.86, 0.3), Vector3(MOUTH_W + 0.6, 0.5, 0.5), Basis.IDENTITY, 0.03)
	for k: int in range(7):
		mesh.blob("brass", Vector3(-hw + MOUTH_W * float(k) / 6.0, MOUTH_H * 0.86, 0.57), Vector3(0.12, 0.12, 0.12), 3, 6, 1.0)
	# the leg-day emblem: a big iron dumbbell bolted over the mouth
	var bell: Vector3 = Vector3(0, MOUTH_H + 1.05, 0.55)
	mesh.tube("iron", bell + Vector3(-1.4, 0, 0), bell + Vector3(1.4, 0, 0), 0.12, 8, true)
	for side: float in [-1.0, 1.0]:
		mesh.tube("red", bell + Vector3(side * 1.05, 0, 0), bell + Vector3(side * 1.3, 0, 0), 0.62, 14, true)
		mesh.tube("iron", bell + Vector3(side * 1.32, 0, 0), bell + Vector3(side * 1.5, 0, 0), 0.45, 12, true)
	# Art import Oct 20 (the painted concept GAIN-HERO-IRON-CAVE): a timber banner post either side of the mouth, a red kit banner on each
	for side: float in [-1.0, 1.0]:
		var post: Vector3 = Vector3(side * (hw + 2.3), 0.0, 0.9)
		mesh.box("bleach_dark", post + Vector3(0, 1.8, 0), Vector3(0.26, 3.6, 0.26), Basis.IDENTITY, 0.03)
		mesh.tube("brass", post + Vector3(-0.55, 3.35, 0.16), post + Vector3(0.55, 3.35, 0.16), 0.05, 6, true)
		GainlandsLandmarks._card(mesh, "GAIN-SHEET-BANNERS-03" if side < 0.0 else "GAIN-SHEET-BANNERS-06", post + Vector3(0, 3.3, 0.2), 1.6, Vector3(0, 0, 1))
	# worn stone steps going down into the dark (each a little dished and chipped)
	for k: int in range(4):
		var z: float = 1.5 - 0.55 * float(k)
		var y: float = 0.12 - 0.22 * float(k)
		mesh.box("rubble", Vector3(0.1 * float(k % 2) - 0.05, y, z), Vector3(MOUTH_W - 0.8 - 0.2 * float(k), 0.24, 0.6), Basis(Vector3.UP, 0.03 * float(k % 3 - 1)), 0.08, 0.85)
	# loose plates and a fallen rock at the threshold
	mesh.blob("rubble", Vector3(-hw - 0.4, 0.35, 1.5), Vector3(0.7, 0.5, 0.7), 4, 8, 0.9)
	var root: Node3D = Node3D.new()
	root.name = "IronCaveMouth"
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_occlusion_fade", true)
	body.set_meta(&"no_range_cull", true)
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	root.set_meta("concept", "GAIN-HERO-IRON-CAVE")  # modelled after the painted concept (art import Oct 20; was a STANDIN)
	root.set_meta("height", MOUTH_H + 1.7)
	return root


## The land bridge toward Mount Swolympus: `start` (on the overlook's rim) to `break_at` (the near end of the collapse), then the chasm, then `far` to `foot`
## (the mountain's foot). Heights: the spines' tops at `deck_y`. Meta "gap" = the chasm's width (for the tests).
static func swolympus_ridge(start: Vector2, break_at: Vector2, far: Vector2, foot: Vector2, deck_y: float) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "SwolympusRidge"
	root.add_child(GainlandsTerrain.rock(_spine(start, break_at, 2.6), deck_y - 0.35, "RidgeNear"))
	root.add_child(GainlandsTerrain.rock(_spine(far, foot, 3.0), deck_y - 0.35, "RidgeFar"))
	var mesh: KitMesh = GainlandsStructures._kit()
	mesh.alias("rubble", "sandstone", Color(0.86, 0.8, 0.72))
	for segment: Array in [[start, break_at, false], [far, foot, true]]:
		var a: Vector2 = segment[0] as Vector2
		var b: Vector2 = segment[1] as Vector2
		var dir: Vector2 = (b - a).normalized()
		var across: Vector2 = Vector2(-dir.y, dir.x)
		var yaw: float = atan2(dir.x, dir.y)
		var length: float = a.distance_to(b)
		var steps: int = int(length / 1.2)
		for k: int in range(steps):
			var t: float = (float(k) + 0.5) / float(steps)
			var p: Vector2 = a.lerp(b, t)
			mesh.box("sandstone", Vector3(p.x, deck_y - 0.12, p.y), Vector3(2.6, 0.24, 1.15), Basis(Vector3.UP, yaw), 0.03, 0.9)
			if k % 3 == 0:
				for side: float in [-1.0, 1.0]:
					var q: Vector2 = p + across * side * 1.45
					mesh.box("cream_stone", Vector3(q.x, deck_y + 0.35, q.y), Vector3(0.4, 0.7, 0.4), Basis(Vector3.UP, yaw), 0.03)
		# lamp posts at the near end's start and the far end's foot
		var post: Vector2 = a + across * 1.6 if not bool(segment[2]) else b - across * 1.6
		mesh.tube("iron", Vector3(post.x, deck_y, post.y), Vector3(post.x, deck_y + 3.2, post.y), 0.08, 6, true)
		mesh.box("gold_glow", Vector3(post.x, deck_y + 3.35, post.y), Vector3(0.3, 0.45, 0.3), Basis.IDENTITY, 0.03)
	# the collapse: the near span's broken arch hanging over the chasm, fallen blocks in the water below
	var dir_near: Vector2 = (break_at - start).normalized()
	var lip: Vector2 = break_at + dir_near * 0.9
	mesh.box("sandstone", Vector3(lip.x, deck_y - 0.35, lip.y), Vector3(2.4, 0.5, 1.6), Basis(Vector3.UP, atan2(dir_near.x, dir_near.y)) * Basis(Vector3(1, 0, 0), 0.32), 0.05)
	var chasm: Vector2 = (break_at + far) * 0.5
	for k: int in range(5):
		var off: Vector2 = Vector2(cos(float(k) * 2.1), sin(float(k) * 2.1)) * (0.8 + 0.4 * float(k % 2))
		var c: Vector2 = chasm + off
		mesh.box("rubble", Vector3(c.x, -0.15 + 0.2 * float(k % 2), c.y), Vector3(1.2, 0.8, 0.9), Basis(Vector3(0.3, 1.0, 0.2).normalized(), float(k) * 0.9), 0.06, 0.8)
	var body: MeshInstance3D = mesh.instance("Causeway")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_occlusion_fade", true)
	body.set_meta(&"no_range_cull", true)
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	root.set_meta("gap", break_at.distance_to(far))
	return root


## A rock spine's outline: a strip `width` wide from `a` to `b`, its sides a little ragged.
static func _spine(a: Vector2, b: Vector2, width: float) -> PackedVector2Array:
	var dir: Vector2 = (b - a).normalized()
	var across: Vector2 = Vector2(-dir.y, dir.x)
	var points: PackedVector2Array = PackedVector2Array()
	var steps: int = maxi(2, int(a.distance_to(b) / 3.0))
	for k: int in range(steps + 1):
		var p: Vector2 = a.lerp(b, float(k) / float(steps))
		points.append(p + across * (width * 0.5 + 0.4 * GainlandsTerrain._noise(p.x, p.y)))
	for k: int in range(steps, -1, -1):
		var p: Vector2 = a.lerp(b, float(k) / float(steps))
		points.append(p - across * (width * 0.5 + 0.4 * GainlandsTerrain._noise(p.y, p.x)))
	return points
