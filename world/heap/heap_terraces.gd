class_name HeapTerraces
extends RefCounted
## The Verdant Dump v2's ways between the terraces and the pieces built into its cliffs (docs/art/verdant_dump_v2.md, Part B): stone stairs matching
## the layout's stepped ramps, the giant root ramp, the vine ladders, the scree slope's junk, vines draped down the cliff faces, rope fences along the
## lips, the rusty water wheels in the gorge, the culvert pipe the river springs from and the junk-choked drain grate. Every piece is a `KitMesh` in
## the kit's materials (`HeapLandmarks._materials`); the walk itself is always the layout's (`HeapLayout.Ramp`), these are what the eye sees.

const L = preload("res://world/heap/heap_landmarks.gd")


static func _mesh() -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	L._materials(mesh)
	# the stairs' dressed stone: the shared kit's foundation stone, cooled toward the cliffs' grey-violet
	mesh.set_material("stone", EnvKit.material("ENV-WALL-FOUNDATION", false, Color(0.86, 0.84, 0.96)))
	mesh.set_material("stone_dark", EnvKit.material("ENV-WALL-FOUNDATION", false, Color(0.62, 0.6, 0.72)))
	# the blossoms: plain violets (the glowing wisteria slot blows out to white on a big clump)
	mesh.alias("bloom_violet", "flat", Color("9a66d6").srgb_to_linear())
	mesh.alias("bloom_light", "flat", Color("c09ae6").srgb_to_linear())
	mesh.alias("bloom_blue", "flat", Color("5c78d8").srgb_to_linear())
	return mesh


static func _instance(mesh: KitMesh, node_name: String, never_fade: bool = true) -> MeshInstance3D:
	var body: MeshInstance3D = mesh.instance(node_name)
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	body.set_meta(&"no_range_cull", true)
	if never_fade:
		body.set_meta(&"no_occlusion_fade", true)
	return body


static func _finish(mesh: KitMesh, node_name: String, never_fade: bool = true) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	root.add_child(_instance(mesh, "Body", never_fade))
	return root


## Stone stairs filling a stepped ramp: a stone tread per layout step from the lower terrace up to the upper, low cheek walls of stacked stone either
## side with moss and the odd violet bloom, a landing slab at the top. Built in world space (the ramp's rectangle).
static func stairs(ramp: HeapLayout.Ramp) -> Node3D:
	var mesh: KitMesh = _mesh()
	if EnvKit.has_art("DUMP-PROP-STAIRS"):
		# art import Oct 20: the painted mossy stair stone on the treads and cheek walls (was the kit's foundation stone, cooled)
		mesh.set_material("stone", EnvKit.material("DUMP-PROP-STAIRS"))
		mesh.set_material("stone_dark", EnvKit.material("DUMP-PROP-STAIRS", false, Color(0.78, 0.76, 0.86)))
	var rect: Rect2 = ramp.rect
	var steps: int = maxi(2, int(ceilf(rect.size.y / HeapLayout.RAMP_STEP_DEPTH)))
	var depth: float = rect.size.y / float(steps)
	var low: float = minf(ramp.y0, ramp.y1) - 0.8
	var cx: float = rect.get_center().x
	for step: int in range(steps + 1):
		var z: float = rect.end.y - (float(step) + 0.5) * depth
		if step == steps:
			z = rect.position.y + 0.2
		var top: float = ramp.height_at(clampf(z, rect.position.y, rect.end.y))
		var size: Vector3 = Vector3(rect.size.x - 0.1, top - low, depth + 0.06)
		var tint: Color = Color(1, 1, 1).lerp(Color(0.86, 0.9, 0.86), float(step % 3) * 0.5)
		mesh.box("stone", Vector3(cx, (top + low) * 0.5, z), size, Basis.IDENTITY, 0.04, 0.9)
		if step % 4 == 1:
			mesh.blob("leaf_dark", Vector3(cx + (rect.size.x * 0.5 - 0.3) * (1.0 if step % 8 == 1 else -1.0), top + 0.04, z), Vector3(0.28, 0.08, 0.24), 3, 6, 1.0, tint)
	# the cheek walls: stacked stone courses either side, rising with the steps, a cap of moss
	for side: float in [-1.0, 1.0]:
		var x: float = cx + side * (rect.size.x * 0.5 + 0.22)
		var courses: int = maxi(2, int(rect.size.y / 1.2))
		for course: int in range(courses):
			var z0: float = rect.end.y - float(course) * rect.size.y / float(courses)
			var z1: float = z0 - rect.size.y / float(courses)
			var zm: float = (z0 + z1) * 0.5
			var top: float = ramp.height_at(clampf(zm, rect.position.y, rect.end.y)) + 0.75
			mesh.box("stone_dark" if course % 2 == 0 else "stone", Vector3(x, (top + low) * 0.5, zm), Vector3(0.5, top - low, absf(z0 - z1) + 0.02), Basis(Vector3.UP, 0.02 * float(course % 3 - 1)), 0.03, 0.88)
			mesh.blob("leaf" if course % 2 == 0 else "leaf_light", Vector3(x, top + 0.05, zm), Vector3(0.3, 0.12, 0.4), 3, 6, 1.0)
			if course % 3 == 1:
				mesh.blob("petal_violet", Vector3(x + side * 0.1, top + 0.18, zm + 0.2), Vector3(0.1, 0.1, 0.1), 2, 5, 1.0)
	return _finish(mesh, "Stairs_%s" % ramp.id)


## The giant root ramp: a broad bark slab laid along the slope (the walk), ridged with long root strands, knots and moss, smaller roots splaying out
## at its foot and its head, violet veins where the corruption reaches it.
static func root_ramp(ramp: HeapLayout.Ramp, twist: float) -> Node3D:
	var mesh: KitMesh = _mesh()
	var rect: Rect2 = ramp.rect
	var cx: float = rect.get_center().x
	var length: float = rect.size.y
	var rise: float = ramp.y1 - ramp.y0
	var angle: float = atan2(rise, length)
	var centre: Vector3 = Vector3(cx, (ramp.y0 + ramp.y1) * 0.5 - 0.3, rect.get_center().y)
	var basis: Basis = Basis(Vector3.RIGHT, -angle)
	var slope_len: float = sqrt(length * length + rise * rise)
	mesh.box("bark", centre, Vector3(rect.size.x + 0.6, 0.7, slope_len + 1.0), basis, 0.12, 0.85)
	var up_slope: Vector3 = Vector3(0.0, rise, -length).normalized()
	var foot: Vector3 = Vector3(cx, ramp.y0 + 0.02, rect.end.y + 0.3)
	for strand: int in range(5):
		var ox: float = -rect.size.x * 0.42 + rect.size.x * 0.84 * float(strand) / 4.0
		var wobble: float = 0.25 * sin(float(strand) * 1.7)
		var a: Vector3 = foot + Vector3(ox, 0.0, 0.0)
		var b: Vector3 = a + up_slope * (slope_len + 0.6) + Vector3(wobble, 0.0, 0.0)
		mesh.tube("bark_dark" if strand % 2 == 0 else "bark", a + Vector3(0, 0.08, 0), b + Vector3(0, 0.08, 0), 0.16 + 0.05 * float(strand % 2), 7, true)
		if twist > 0.3:
			mesh.tube("veins", a + Vector3(0.05, 0.14, 0), b + Vector3(0.05, 0.14, 0), 0.04, 4, false)
	# knots and moss on the slab, splayed roots at both ends
	for knot: int in range(6):
		var t: float = (float(knot) + 0.5) / 6.0
		var p: Vector3 = foot.lerp(foot + up_slope * slope_len, t) + Vector3(rect.size.x * 0.5 * sin(float(knot) * 2.3), 0.12, 0.0)
		mesh.blob("bark_dark", p, Vector3(0.35, 0.18, 0.3), 3, 7, 0.9)
		mesh.blob("leaf" if knot % 2 == 0 else "hanging_moss", p + Vector3(0.1, 0.12, 0.1), Vector3(0.3, 0.12, 0.28), 3, 6, 1.0)
	for end: int in range(2):
		var origin: Vector3 = foot if end == 0 else foot + up_slope * slope_len
		for root_index: int in range(4):
			var a: float = PI * (0.15 + 0.7 * float(root_index) / 3.0) + (PI if end == 1 else 0.0)
			var tip: Vector3 = origin + Vector3(cos(a) * 3.0, -0.4, sin(a) * 3.0 * (1.0 if end == 0 else -1.0))
			mesh.tube("bark", origin + Vector3(0, 0.2, 0), tip, 0.22, 6, true)
	var root: Node3D = _finish(mesh, "RootRamp_%s" % ramp.id)
	# rope rails on posts either side so the edge reads from above
	root.add_child(rope_fence([Vector3(rect.position.x - 0.4, ramp.y0, rect.end.y), Vector3(rect.position.x - 0.4, ramp.y1, rect.position.y)], 2.2))
	root.add_child(rope_fence([Vector3(rect.end.x + 0.4, ramp.y0, rect.end.y), Vector3(rect.end.x + 0.4, ramp.y1, rect.position.y)], 2.2))
	return root


## A vine ladder up a cliff face: two thick living vines up the steep strip with rung vines every half metre, leaves and purple blossoms, the ends
## rooting into the ground above and below. Sturdy and green, so it reads as safe.
static func vine_ladder(ramp: HeapLayout.Ramp) -> Node3D:
	var mesh: KitMesh = _mesh()
	var rect: Rect2 = ramp.rect
	var cx: float = rect.get_center().x
	var foot: Vector3 = Vector3(cx, ramp.y0, rect.end.y + 0.3)
	var head: Vector3 = Vector3(cx, ramp.y1, rect.position.y - 0.4)
	var half: float = rect.size.x * 0.5 - 0.25
	for side: float in [-1.0, 1.0]:
		var a: Vector3 = foot + Vector3(side * half, 0.05, 0.0)
		var b: Vector3 = head + Vector3(side * half * 0.9, 0.05, 0.0)
		mesh.tube("leaf_dark", a, b, 0.17, 7, true)
		mesh.tube("leaf", a + Vector3(side * 0.12, 0.1, 0.0), b + Vector3(side * 0.12, 0.1, 0.0), 0.1, 5, true)
		# the roots at both ends
		for r: int in range(3):
			var ang: float = -0.6 + 0.6 * float(r)
			mesh.tube("leaf_dark", a, a + Vector3(side * (0.6 + 0.3 * float(r)) * cos(ang), -0.1, 0.9 * sin(ang) + 0.6), 0.09, 5, true)
			mesh.tube("leaf_dark", b, b + Vector3(side * (0.6 + 0.3 * float(r)) * cos(ang), 0.05, -0.9 * sin(ang) - 0.6), 0.09, 5, true)
	var count: int = maxi(3, int(foot.distance_to(head) / 0.5))
	for rung: int in range(1, count):
		var t: float = float(rung) / float(count)
		var c: Vector3 = foot.lerp(head, t) + Vector3(0, 0.12, 0)
		mesh.tube("leaf", c + Vector3(-half, 0, 0), c + Vector3(half, 0, 0), 0.09, 5, true)
		if rung % 2 == 0:
			mesh.blob("leaf_light", c + Vector3(half * (0.5 if rung % 4 == 0 else -0.5), 0.14, 0.0), Vector3(0.26, 0.1, 0.3), 3, 6, 1.0)
		if rung % 3 == 1:
			mesh.blob("petal_violet", c + Vector3(half * (1.0 if rung % 2 == 0 else -1.0), 0.2, 0.0), Vector3(0.11, 0.11, 0.11), 2, 5, 1.0)
	var ladder: Node3D = _finish(mesh, "VineLadder_%s" % ramp.id)
	ladder.set_meta(&"no_wind", true)  # a walkable thing never sways, whatever its name says
	return ladder


## The scree slope's junk: tyres, scrap and rocks lying on the slope between its kerbs (nothing solid: the slope is only a mount's ground anyway).
static func scree_slope(ramp: HeapLayout.Ramp) -> Node3D:
	var mesh: KitMesh = _mesh()
	var rect: Rect2 = ramp.rect
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 77
	for index: int in range(26):
		var x: float = rng.randf_range(rect.position.x + 0.5, rect.end.x - 0.5)
		var z: float = rng.randf_range(rect.position.y + 0.5, rect.end.y - 0.5)
		var y: float = ramp.height_at(z)
		match index % 4:
			0:
				mesh.lathe("tyre", Vector3(x, y - 0.05, z), [Vector2(0.4, 0.0), Vector2(0.44, 0.14), Vector2(0.4, 0.28)], 10, 0.9, true, true)
			1:
				mesh.box("rust", Vector3(x, y + 0.08, z), Vector3(rng.randf_range(0.4, 0.9), 0.14, rng.randf_range(0.4, 0.9)), Basis(Vector3.UP, rng.randf() * TAU), 0.02, 0.9)
			2:
				mesh.blob("stone", Vector3(x, y + 0.08, z), Vector3(rng.randf_range(0.25, 0.5), 0.2, rng.randf_range(0.25, 0.5)), 3, 7, 0.9)
			_:
				mesh.blob("leaf_dark", Vector3(x, y + 0.05, z), Vector3(0.3, 0.14, 0.3), 3, 6, 1.0)
	for side: float in [-1.0, 1.0]:
		var x: float = rect.get_center().x + side * (rect.size.x * 0.5 + 0.3)
		for k: int in range(4):
			var z: float = rect.position.y + rect.size.y * (float(k) + 0.5) / 4.0
			mesh.box("doors", Vector3(x, ramp.height_at(z) + 0.4, z), Vector3(0.14, 0.9, 1.2), Basis(Vector3.UP, 0.1 * float(k % 2) - 0.05), 0.02, 0.9)
	return _finish(mesh, "Scree_%s" % ramp.id)


## Vines draped down a cliff face from a lip: `drapes` is a list of [top (Vector3 world), length, yaw degrees of the face's outward side]. Leaves along
## the strands and purple blossoms at the ends; swaying is left to the wind shader by name.
static func cliff_vines(drapes: Array) -> Node3D:
	var mesh: KitMesh = _mesh()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 909
	var painted: bool = EnvKit.has_art("DUMP-DEC-VINES-01")
	for entry: Variant in drapes:
		var d: Array = entry as Array
		var top: Vector3 = d[0] as Vector3
		var length: float = float(d[1])
		var out: Vector3 = Vector3(sin(deg_to_rad(float(d[2]))), 0.0, cos(deg_to_rad(float(d[2]))))
		if painted:
			# art import Oct 20: a painted vine drape (DUMP-DEC-VINES, one of six) hung flat against the face from the lip, replacing the tube strands
			var id: String = "DUMP-DEC-VINES-0%d" % (1 + rng.randi() % 6)
			if EnvKit.has_art(id):
				var height: float = length * 1.1
				L._card(mesh, id, top + out * 0.18 - Vector3(0.0, EnvKit.pivot(id).y * height, 0.0), height, out)
		var strands: int = 0 if painted else 2 + rng.randi() % 3
		for s: int in range(strands):
			var a: Vector3 = top + out * 0.25 + Vector3(rng.randf_range(-0.6, 0.6), 0.1, 0.0) * (1.0 - absf(out.x)) + Vector3(0.0, 0.1, rng.randf_range(-0.6, 0.6)) * absf(out.x)
			var b: Vector3 = a + Vector3(rng.randf_range(-0.3, 0.3), -length * rng.randf_range(0.6, 1.0), rng.randf_range(-0.3, 0.3)) + out * 0.15
			mesh.tube("leaf_dark", a, b, 0.07, 5, true)
			var leaves: int = 2 + rng.randi() % 3
			for k: int in range(leaves):
				var p: Vector3 = a.lerp(b, (float(k) + 0.6) / float(leaves + 1)) + out * 0.12
				mesh.blob("leaf" if k % 2 == 0 else "leaf_light", p, Vector3(0.22, 0.14, 0.22), 3, 6, 1.0)
			if s % 2 == 0:
				mesh.blob("petal_violet", b + out * 0.1, Vector3(0.14, 0.2, 0.14), 3, 6, 1.0)
		mesh.blob("hanging_moss", top + out * 0.2, Vector3(0.6, 0.18, 0.4), 3, 7, 1.0)
		# moss cushions and a fern or two on the face itself, so the stone is never bare between the drapes
		for cushion: int in range(2):
			var down: float = rng.randf_range(0.6, maxf(length - 0.4, 0.8))
			var across: Vector3 = Vector3(-out.z, 0.0, out.x) * rng.randf_range(-1.6, 1.6)
			mesh.blob("leaf_dark" if cushion % 2 == 0 else "leaf", top + across + out * 0.25 - Vector3(0.0, down, 0.0), Vector3(0.45, 0.28, 0.45), 3, 6, 0.9)
	var root: Node3D = _finish(mesh, "CliffVines")
	root.get_child(0).name = "CliffVineLeaves"  # named like foliage so the toon shader sways it
	return root


## A rope fence along `points` (world, with heights): posts every ~2 m and two sagging ropes between them. Low, never blocks (the cliff lip does).
static func rope_fence(points: Array, post_step: float = 2.2) -> Node3D:
	var mesh: KitMesh = _mesh()
	for index: int in range(points.size() - 1):
		var a: Vector3 = points[index] as Vector3
		var b: Vector3 = points[index + 1] as Vector3
		var count: int = maxi(1, int(round(a.distance_to(b) / post_step)))
		var previous: Vector3 = a
		for k: int in range(count + 1):
			var p: Vector3 = a.lerp(b, float(k) / float(count))
			mesh.tube("wood_dark", p, p + Vector3(0, 1.05, 0), 0.08, 6, true)
			mesh.lathe("rust", p + Vector3(0, 1.05, 0), [Vector2(0.11, 0.0), Vector2(0.0, 0.12)], 6, 0.9, false, false)
			if k > 0:
				for height: float in [0.95, 0.55]:
					var mid: Vector3 = (previous + p) * 0.5 + Vector3(0, height - 0.08, 0)
					mesh.tube("rope", previous + Vector3(0, height, 0), mid, 0.035, 4, false)
					mesh.tube("rope", mid, p + Vector3(0, height, 0), 0.035, 4, false)
			previous = p
	return _finish(mesh, "RopeFence")


## A rusty water wheel of `radius` standing in the gorge: a rim of tin, spokes, paddles, an axle on a timber frame bolted to the cliff, moss and
## dripping vines. The wheel's local z is its axle; meta "spinner" turns it (`HeapBuilder.animate`, like the windmill's sails).
static func water_wheel(radius: float) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "WaterWheel"
	if EnvKit.has_art("DUMP-PROP-WATERWHEEL"):
		# art import Oct 20: the painted rusty wheel on its frame (DUMP-PROP-WATERWHEEL) replaces the built STANDIN; still (the painting has its own pour)
		var card: MeshInstance3D = KitFoliage.card("DUMP-PROP-WATERWHEEL", Vector2(radius * 2.4, radius * 2.4), false, true)
		card.name = "WheelCard"
		card.position.y -= radius * 1.15
		card.set_meta(&"no_range_cull", true)
		root.add_child(card)
		var still: Node3D = Node3D.new()
		still.name = "Wheel"
		root.add_child(still)
		root.set_meta("spinner", still)
		return root
	var wheel_mesh: KitMesh = _mesh()
	var segments: int = 14
	for ring_r: float in [radius, radius - 0.9]:
		for s: int in range(segments):
			var a0: float = TAU * float(s) / float(segments)
			var a1: float = TAU * float(s + 1) / float(segments)
			for dz: float in [-0.55, 0.55]:
				wheel_mesh.tube("rust" if s % 2 == 0 else "rust_dark", Vector3(cos(a0) * ring_r, sin(a0) * ring_r, dz), Vector3(cos(a1) * ring_r, sin(a1) * ring_r, dz), 0.09, 5, true)
	for s: int in range(segments):
		var a: float = TAU * (float(s) + 0.5) / float(segments)
		var out: Vector3 = Vector3(cos(a), sin(a), 0.0)
		# a paddle between the rims, a spoke to the hub
		wheel_mesh.box("doors" if s % 3 == 0 else "mosswood", out * (radius - 0.45), Vector3(0.9, 0.08, 1.1), Basis(Vector3.BACK, a + PI * 0.5), 0.0, 0.9)
		if s % 2 == 0:
			wheel_mesh.tube("rust_dark", Vector3(0, 0, 0.3 * float(s % 4 - 1)), out * (radius - 0.9), 0.07, 5, true)
	wheel_mesh.tube("metal_dark", Vector3(0, 0, -1.0), Vector3(0, 0, 1.0), 0.18, 8, true)
	wheel_mesh.blob("leaf", Vector3(radius * 0.7, radius * 0.6, 0.6), Vector3(0.3, 0.16, 0.25), 3, 6, 1.0)
	var wheel: MeshInstance3D = _instance(wheel_mesh, "Wheel")
	root.add_child(wheel)
	root.set_meta("spinner", wheel)
	# the frame: two timber uprights and a cross beam behind the axle, bolted into the cliff
	var frame: KitMesh = _mesh()
	for side: float in [-1.0, 1.0]:
		frame.box("wood_dark", Vector3(0.0, -radius * 0.5, side * 1.1), Vector3(0.3, radius + 1.4, 0.3), Basis.IDENTITY, 0.03, 0.85)
		frame.box("rust", Vector3(0.0, 0.0, side * 1.1), Vector3(0.5, 0.5, 0.2), Basis.IDENTITY, 0.02)
	frame.box("wood_dark", Vector3(0.0, 0.35, 0.0), Vector3(0.3, 0.3, 2.5), Basis.IDENTITY, 0.03, 0.85)
	frame.blob("hanging_moss", Vector3(0.1, 0.55, 0.0), Vector3(0.5, 0.2, 0.6), 3, 7, 1.0)
	root.add_child(_instance(frame, "Frame"))
	return root


## The culvert the river springs from: a rusty pipe out of the cliff with a bracket, moss round its mouth.
static func pipe_spout(radius: float) -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.tube("rust_dark", Vector3(0, 0, -2.4), Vector3(0, 0, 0.6), radius, 10, false)
	mesh.lathe("rust", Vector3(0, 0, 0.4), [Vector2(radius + 0.1, 0.0), Vector2(radius + 0.1, 0.3)], 10, 0.9, false, false)
	mesh.blob("hanging_moss", Vector3(0, radius + 0.1, 0.1), Vector3(radius * 1.2, 0.3, 0.6), 3, 7, 1.0)
	mesh.blob("leaf", Vector3(radius * 0.8, radius * 0.5, 0.3), Vector3(0.35, 0.2, 0.3), 3, 6, 1.0)
	mesh.blob("petal_violet", Vector3(-radius * 0.7, radius * 0.7, 0.3), Vector3(0.14, 0.14, 0.14), 2, 5, 1.0)
	return _finish(mesh, "PipeSpout")


## The junk-choked drain at the ravine's east end: a rusty grate of bars over the pool with scrap and tyres caught in it.
static func drain_grate(radius: float) -> Node3D:
	var mesh: KitMesh = _mesh()
	var bars: int = int(radius * 2.0 / 0.6)
	for index: int in range(bars + 1):
		var x: float = -radius + float(index) * radius * 2.0 / float(bars)
		var half: float = sqrt(maxf(radius * radius - x * x, 0.0))
		if half < 0.3:
			continue
		mesh.box("rust_dark", Vector3(x, 0.0, 0.0), Vector3(0.12, 0.12, half * 2.0), Basis.IDENTITY, 0.0)
	mesh.box("rust_dark", Vector3(0.0, 0.0, 0.0), Vector3(radius * 2.0, 0.12, 0.12), Basis.IDENTITY, 0.0)
	var segments: int = 16
	for s: int in range(segments):
		var a0: float = TAU * float(s) / float(segments)
		var a1: float = TAU * float(s + 1) / float(segments)
		mesh.tube("rust", Vector3(cos(a0) * radius, 0.0, sin(a0) * radius), Vector3(cos(a1) * radius, 0.0, sin(a1) * radius), 0.1, 5, true)
	mesh.lathe("tyre", Vector3(radius * 0.4, 0.05, radius * 0.2), [Vector2(0.5, 0.0), Vector2(0.55, 0.16), Vector2(0.5, 0.32)], 10, 0.9, true, true)
	mesh.box("doors", Vector3(-radius * 0.3, 0.2, -radius * 0.3), Vector3(1.2, 0.1, 0.8), Basis(Vector3.UP, 0.6), 0.02)
	mesh.blob("leaf_dark", Vector3(radius * 0.2, 0.2, -radius * 0.5), Vector3(0.5, 0.2, 0.4), 3, 6, 1.0)
	return _finish(mesh, "DrainGrate")


## The purple flowering trees (the reference's wisteria and jacaranda, VD-12): one mesh for all of them, each a leaning trunk with three or four
## branches, a crown of violet blossom clumps (the Rotheart's wisteria glow, lit a little from inside) over a few green leaf clumps, and blossom
## drapes hanging off the lower branches. `trees` is a list of [pos (Vector3, the ground), scale, seed]. Never faded (they stand at the edges).
static func jacaranda_field(trees: Array) -> Node3D:
	if EnvKit.has_art("DUMP-TREE-WISTERIA"):
		# art import Oct 20: the painted wisteria tree (DUMP-TREE-WISTERIA) replaces the built STANDIN, about 5 m at scale 1
		var spots: Array = []
		for entry: Variant in trees:
			var t: Array = entry as Array
			spots.append([t[0], 5.0 * float(t[1])])
		return _card_field("DUMP-TREE-WISTERIA", spots, "Jacarandas")
	var mesh: KitMesh = _mesh()
	for entry: Variant in trees:
		var t: Array = entry as Array
		var base: Vector3 = t[0] as Vector3
		var s: float = float(t[1])
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = int(t[2])
		var lean: Vector3 = Vector3(rng.randf_range(-0.5, 0.5), 0.0, rng.randf_range(-0.4, 0.4)) * s
		var top: Vector3 = base + Vector3(0.0, 2.6 * s, 0.0) + lean
		mesh.tube("bark", base, top, 0.26 * s, 7, true)
		mesh.tube("bark_dark", base + Vector3(0.12 * s, 0.0, 0.0), top + Vector3(0.08 * s, -0.3 * s, 0.0), 0.12 * s, 5, true)
		var branches: int = 3 + rng.randi() % 2
		for b: int in range(branches):
			var a: float = rng.randf() * TAU
			var tip: Vector3 = top + Vector3(cos(a) * 1.5 * s, rng.randf_range(0.8, 1.5) * s, sin(a) * 1.5 * s)
			mesh.tube("bark", top - Vector3(0, 0.3 * s, 0), tip, 0.12 * s, 5, true)
			# a crown clump at the tip: a few blossom lobes of two violets over a little leaf, shaded underneath so it reads as a mass, not a sheet
			mesh.blob("leaf", tip - Vector3(0, 0.3 * s, 0), Vector3(0.9, 0.45, 0.9) * s, 4, 9, 0.9)
			for lobe: int in range(4):
				var la: float = float(lobe) * 1.57 + rng.randf() * 0.6
				var lp: Vector3 = tip + Vector3(cos(la) * 0.55 * s, 0.15 * s * float(lobe % 2), sin(la) * 0.55 * s)
				mesh.blob("bloom_violet" if lobe % 2 == 0 else "bloom_light", lp, Vector3(0.7 + 0.15 * rng.randf(), 0.5, 0.7 + 0.15 * rng.randf()) * s, 4, 8, 0.8)
			mesh.blob("bloom_light", tip + Vector3(0.0, 0.45 * s, 0.0), Vector3(0.55, 0.35, 0.55) * s, 3, 8, 0.85)
			if b % 2 == 0:
				var hang: Vector3 = tip + Vector3(cos(a) * 0.9 * s, -0.4 * s, sin(a) * 0.9 * s)
				mesh.tube("bloom_violet", hang, hang + Vector3(0.0, -1.1 * s, 0.0), 0.16 * s, 5, true)
				mesh.blob("bloom_light", hang + Vector3(0.0, -1.2 * s, 0.0), Vector3(0.2, 0.3, 0.2) * s, 3, 6, 1.0)
		mesh.blob("bloom_violet", top + Vector3(0.0, 1.2 * s, 0.0), Vector3(1.05, 0.7, 1.05) * s, 4, 10, 0.8)
		mesh.blob("bloom_light", top + Vector3(-0.4 * s, 1.75 * s, 0.3 * s), Vector3(0.6, 0.4, 0.6) * s, 3, 8, 0.85)
		mesh.blob("bloom_violet", top + Vector3(0.5 * s, 1.65 * s, -0.3 * s), Vector3(0.55, 0.35, 0.55) * s, 3, 8, 0.85)
		for r: int in range(3):
			var a: float = rng.randf() * TAU
			mesh.tube("bark_dark", base + Vector3(0, 0.15 * s, 0), base + Vector3(cos(a) * 0.9 * s, -0.1, sin(a) * 0.9 * s), 0.1 * s, 5, true)
	var root: Node3D = _finish(mesh, "Jacarandas")
	root.get_child(0).set_meta(&"no_wind", true)
	return root


## The same field for the builder and the dressing (art import Oct 22: the lily pads and the lupins).
static func card_field(id: String, spots: Array, node_name: String) -> Node3D:
	return _card_field(id, spots, node_name)


## Many camera-facing cards of one painted kit piece as ONE MultiMesh under a Node3D called node_name (one draw call): spots are [base (Vector3), height].
## The painting keeps its own aspect, its pivot on the base.
static func _card_field(id: String, spots: Array, node_name: String) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.center_offset = Vector3(0.5 - EnvKit.pivot(id).x, 0.5, 0.0)
	var multimesh: MultiMesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = quad
	multimesh.instance_count = spots.size()
	var aspect: float = EnvKit.aspect(id)
	for index: int in range(spots.size()):
		var height: float = float((spots[index] as Array)[1])
		multimesh.set_instance_transform(index, Transform3D(Basis.from_scale(Vector3(height * aspect, height, 1.0)), (spots[index] as Array)[0] as Vector3))
	var instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
	instance.name = "Cards"
	instance.multimesh = multimesh
	instance.material_override = KitFoliage.card_material(id)
	instance.extra_cull_margin = 6.0
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.set_meta(&"no_range_cull", true)  # one field spans the zone: the range cull measures to its centre (GC-9)
	instance.set_meta(StyleToon.META_NO_TOON, true)
	instance.set_meta(PaintedClasses.META_NO_PAINT, true)
	instance.set_meta(&"no_occlusion_fade", true)
	root.add_child(instance)
	return root


## Clumps of violet and blue blossoms (the reference's foreground flowers): one mesh for all, each clump a bed of leaf blobs with a dozen blossoms in
## violet, blue and cream on short stems. `clumps` is a list of [pos (Vector3, the ground), spread, seed].
static func bloom_clumps(clumps: Array) -> Node3D:
	if EnvKit.has_art("DUMP-PLANT-VIOLETS"):
		# art import Oct 20: the painted violet-and-blue clump (DUMP-PLANT-VIOLETS) replaces the built blossoms, a little taller than its spread
		var spots: Array = []
		for entry: Variant in clumps:
			var c: Array = entry as Array
			spots.append([c[0], clampf(float(c[1]) * 1.3, 0.7, 1.6)])
		return _card_field("DUMP-PLANT-VIOLETS", spots, "BloomClumps")
	var mesh: KitMesh = _mesh()
	var tints: Array[String] = ["bloom_violet", "bloom_blue", "bloom_light", "cloth_cream", "bloom_violet", "bloom_blue"]
	for entry: Variant in clumps:
		var c: Array = entry as Array
		var base: Vector3 = c[0] as Vector3
		var spread: float = float(c[1])
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = int(c[2])
		# cheap geometry: two leaf blobs, six to eight blossoms on three-sided stems (about 250 triangles a clump; a hundred clumps stand in the zone)
		for leaf: int in range(2):
			var p: Vector3 = base + Vector3(rng.randf_range(-spread, spread), 0.05, rng.randf_range(-spread, spread)) * 0.5
			mesh.blob("leaf" if leaf % 2 == 0 else "leaf_dark", p, Vector3(spread * 0.6, 0.22, spread * 0.55), 2, 6, 0.95)
		var count: int = 6 + rng.randi() % 3
		for f: int in range(count):
			var a: float = rng.randf() * TAU
			var d: float = rng.randf() * spread
			var foot: Vector3 = base + Vector3(cos(a) * d, 0.1, sin(a) * d)
			var h: float = rng.randf_range(0.35, 0.8)
			mesh.tube("leaf_dark", foot, foot + Vector3(0, h, 0), 0.025, 3, false)
			var r: float = rng.randf_range(0.12, 0.21)
			mesh.blob(tints[f % tints.size()], foot + Vector3(0, h + r * 0.6, 0), Vector3(r, r * 0.7, r), 2, 5, 1.0)
	var root: Node3D = _finish(mesh, "BloomClumps")
	return root


## A vine bridge's abutment, standing whether or not the bridge has grown: two mossy posts wrapped in vines either side of the walk with a rope
## between, a stub of planks and blossom, so an ungrown crossing reads as "a bridge grows here". Local -z is the bridge's direction.
static func bridge_abutment() -> Node3D:
	var mesh: KitMesh = _mesh()
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (HeapLayout.BRIDGE_HALF_WIDTH + 0.35), -0.3, 0.3)
		mesh.box("mosswood", foot + Vector3(0.0, 1.5, 0.0), Vector3(0.36, 3.0, 0.36), Basis(Vector3.UP, 0.15 * side), 0.03, 0.85)
		mesh.lathe("tin", foot + Vector3(0.0, 3.0, 0.0), [Vector2(0.3, 0.0), Vector2(0.0, 0.3)], 6, 0.9, true, false)
		for leaf: int in range(4):
			mesh.blob("leaf" if leaf % 2 == 0 else "leaf_dark", foot + Vector3(0.16 * side, 0.6 + 0.6 * float(leaf), 0.18), Vector3(0.24, 0.3, 0.18), 4, 8, 0.95)
		mesh.tube("leaf_dark", foot + Vector3(0.2 * side, 0.2, 0.2), foot + Vector3(-0.1 * side, 2.9, -0.15), 0.06, 5, true)
		mesh.blob("bloom_light", foot + Vector3(0.1 * side, 2.4, 0.25), Vector3(0.14, 0.22, 0.14), 3, 6, 1.0)
	var sag: int = 8
	var previous: Vector3 = Vector3.ZERO
	for index: int in range(sag + 1):
		var t: float = float(index) / float(sag)
		var point: Vector3 = Vector3(lerpf(-(HeapLayout.BRIDGE_HALF_WIDTH + 0.35), HeapLayout.BRIDGE_HALF_WIDTH + 0.35, t), 2.7 - sin(t * PI) * 0.35, 0.3)
		if index > 0:
			mesh.tube("rope", previous, point, 0.035, 4, false)
		previous = point
	mesh.box("plank", Vector3(0.0, -0.08, -0.3), Vector3(HeapLayout.BRIDGE_HALF_WIDTH * 2.0 + 0.4, 0.16, 0.9), Basis.IDENTITY, 0.02, 0.92)
	return _finish(mesh, "Abutment")
