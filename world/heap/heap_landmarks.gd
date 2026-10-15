class_name HeapLandmarks
extends RefCounted
## Stand-ins of the right size and silhouette for the Verdant Dump's landmarks until their concept art exists (docs/art/heap_slice.md): the
## greenhouse centrepiece of the Compost Commons, the Trash Panda Throne (the side dungeon's door, beyond the north-west rim), the Rotheart's root
## gate (the main dungeon's door at the foot of the colossal tree beyond the north rim), the farm rows' rusty windmill, and the entrance bridge from
## town. The Rotheart itself and Junk Mountain are `LandmarkKit` giant_tree / mound stand-ins in the zone's colours (`rotheart`, `junk_mountain`).
## Every piece is one `KitMesh` body whose meta carries "circles" (local x, z, radius) so the builder can make it solid. The front is +z (south).

const H = preload("res://world/heap/heap_materials.gd")
const P = preload("res://world/heap/heap_props.gd")


static func _materials(mesh: KitMesh) -> void:
	mesh.set_material("wood", H.flat(H.WOOD))
	mesh.set_material("wood_dark", H.flat(H.WOOD_DARK))
	mesh.set_material("rust", H.flat(H.RUST))
	mesh.set_material("rust_dark", H.flat(H.RUST_DARK))
	mesh.set_material("metal", H.flat(H.METAL))
	mesh.set_material("metal_dark", H.flat(H.METAL_DARK))
	mesh.set_material("tyre", H.flat(H.TIRE))
	mesh.set_material("moss", H.flat(H.MOSS))
	mesh.set_material("straw", H.flat(H.STRAW))
	mesh.set_material("glass", H.translucent(Color(0.72, 0.9, 0.84), 0.45, 0.25, 0.2))
	mesh.set_material("lid", H.flat(Color(0.3, 0.46, 0.32)))
	mesh.set_material("tin", H.flat(Color(0.7, 0.72, 0.74)))
	mesh.set_material("bark", H.flat(Color(0.27, 0.19, 0.31)))
	mesh.set_material("bark_light", H.flat(Color(0.38, 0.28, 0.42)))
	mesh.set_material("hollow", H.glow(Color(0.32, 0.12, 0.42), 0.5))
	mesh.set_material("fungus", H.glow(Color(0.72, 0.42, 0.92), 0.9))
	mesh.set_material("cap_red", H.flat(Color(0.8, 0.25, 0.2)))
	mesh.set_material("cap_blue", H.flat(Color(0.25, 0.4, 0.8)))
	mesh.set_material("cap_yellow", H.flat(Color(0.9, 0.75, 0.2)))
	mesh.set_material("pumpkin", H.flat(Color(0.9, 0.5, 0.15)))


static func _finish(mesh: KitMesh, root_name: String, circles: Array[Vector3], size: Vector3, never_fade: bool) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = root_name
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	if never_fade:
		body.set_meta(&"no_occlusion_fade", true)
	root.add_child(body)
	root.set_meta("circles", circles)
	root.set_meta("footprint", Vector2(size.x, size.z))
	root.set_meta("height", size.y)
	root.set_meta("triangles", mesh.triangle_count())
	return root


## The Compost Commons' centrepiece: a glass house on a rusty-brick base with a ridge roof, a plank door on the south side and vegetables inside.
static func greenhouse(size: Vector3) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var w: float = size.x
	var h: float = size.y
	var d: float = size.z
	var eave: float = h * 0.58
	mesh.box("rust_dark", Vector3(0.0, 0.3, 0.0), Vector3(w + 0.4, 0.6, d + 0.4), Basis.IDENTITY, 0.04, 0.85)
	mesh.box("moss", Vector3(0.0, 0.62, 0.0), Vector3(w + 0.1, 0.06, d + 0.1), Basis.IDENTITY, 0.0)
	# the glass walls (the south one in two panels round the door)
	mesh.box("glass", Vector3(0.0, 0.6 + (eave - 0.6) * 0.5, -d * 0.5), Vector3(w, eave - 0.6, 0.08), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		mesh.box("glass", Vector3(side * w * 0.5, 0.6 + (eave - 0.6) * 0.5, 0.0), Vector3(0.08, eave - 0.6, d), Basis.IDENTITY, 0.0)
		var panel_w: float = (w - 1.4) * 0.5
		mesh.box("glass", Vector3(side * (0.7 + panel_w * 0.5), 0.6 + (eave - 0.6) * 0.5, d * 0.5), Vector3(panel_w, eave - 0.6, 0.08), Basis.IDENTITY, 0.0)
	mesh.box("wood_dark", Vector3(0.0, 0.6 + 1.1, d * 0.5 + 0.05), Vector3(1.3, 2.2, 0.12), Basis.IDENTITY, 0.02)
	mesh.box("wood", Vector3(0.0, 0.6 + 2.35, d * 0.5 + 0.02), Vector3(1.5, 0.3, 0.14), Basis.IDENTITY, 0.02)
	# the frame: corner posts, the eave beams, rafters to the ridge
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			mesh.tube("metal_dark", Vector3(sx * w * 0.5, 0.6, sz * d * 0.5), Vector3(sx * w * 0.5, eave, sz * d * 0.5), 0.1, 6, true)
		mesh.tube("metal_dark", Vector3(-w * 0.5, eave, sx * d * 0.5), Vector3(w * 0.5, eave, sx * d * 0.5), 0.09, 6, true)
	mesh.tube("rust", Vector3(-w * 0.5 - 0.3, h, 0.0), Vector3(w * 0.5 + 0.3, h, 0.0), 0.12, 6, true)
	var rafters: int = maxi(3, int(w / 1.5))
	for index: int in range(rafters + 1):
		var x: float = -w * 0.5 + w * float(index) / float(rafters)
		for sz: float in [-1.0, 1.0]:
			mesh.tube("metal_dark", Vector3(x, eave, sz * d * 0.5), Vector3(x, h, 0.0), 0.07, 5, true)
	# the roof panes
	mesh.quad("glass", [Vector3(-w * 0.5 - 0.2, eave, d * 0.5 + 0.2), Vector3(w * 0.5 + 0.2, eave, d * 0.5 + 0.2), Vector3(w * 0.5 + 0.2, h, 0.0), Vector3(-w * 0.5 - 0.2, h, 0.0)], Vector3(0.0, 0.6, 0.8).normalized())
	mesh.quad("glass", [Vector3(w * 0.5 + 0.2, eave, -d * 0.5 - 0.2), Vector3(-w * 0.5 - 0.2, eave, -d * 0.5 - 0.2), Vector3(-w * 0.5 - 0.2, h, 0.0), Vector3(w * 0.5 + 0.2, h, 0.0)], Vector3(0.0, 0.6, -0.8).normalized())
	# what grows inside: two rows of green with pumpkins
	for row: float in [-1.0, 1.0]:
		var z: float = row * d * 0.22
		var count: int = maxi(3, int(w / 1.6))
		for index: int in range(count):
			var x: float = -w * 0.5 + 1.0 + (w - 2.0) * float(index) / float(maxi(count - 1, 1))
			mesh.blob("moss", Vector3(x, 1.0, z), Vector3(0.55, 0.45, 0.5), 4, 8, 0.9)
			if index % 2 == 0:
				mesh.blob("pumpkin", Vector3(x + 0.35, 0.85, z + 0.4), Vector3(0.28, 0.24, 0.28), 4, 8, 0.95)
	# a rain barrel and a stack of pots by the door corner
	mesh.lathe("rust", Vector3(w * 0.5 + 0.9, 0.0, d * 0.5 - 0.6), [Vector2(0.5, 0.0), Vector2(0.55, 0.6), Vector2(0.5, 1.2)], 10, 0.9, true, true)
	var step: float = w / 3.0
	for index: int in range(3):
		circles.append(Vector3(-w * 0.5 + step * (float(index) + 0.5), 0.0, maxf(d * 0.5 - 0.6, step * 0.5)))
	return _finish(mesh, "Greenhouse", circles, size, false)


## The Trash Panda Throne beyond the north-west rim: a dumpster-lid dais on tin-can towers, a tin throne with raccoon ears, bottle-cap banners, steps
## down to the land where the side dungeon's door spot stands.
static func throne(size: Vector3) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var w: float = size.x
	var h: float = size.y
	var d: float = size.z
	var dais: float = 1.4
	# the dais: a dumpster lid with a tin lip, on four can towers and a heap of bags underneath
	mesh.box("lid", Vector3(0.0, dais * 0.5, 0.0), Vector3(w, dais, d), Basis.IDENTITY, 0.12, 0.9)
	mesh.box("tin", Vector3(0.0, dais + 0.08, 0.0), Vector3(w + 0.3, 0.16, d + 0.3), Basis.IDENTITY, 0.02)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var foot: Vector3 = Vector3(sx * (w * 0.5 - 1.6), -4.0, sz * (d * 0.5 - 1.6))
			mesh.lathe("tin", foot, [Vector2(1.4, 0.0), Vector2(1.45, 2.0), Vector2(1.4, 4.0)], 12, 0.9, true, true)
			mesh.lathe("rust", foot + Vector3(0.0, 1.9, 0.0), [Vector2(1.5, 0.0), Vector2(1.5, 0.3)], 12, 0.9, false, false)
	mesh.blob("tyre", Vector3(0.0, -1.6, 0.0), Vector3(w * 0.42, 2.4, d * 0.42), 5, 12, 0.85)
	# the throne at the back: a tin seat and a tall back with raccoon ears, armrests of cans
	var back_z: float = -d * 0.5 + 1.6
	mesh.box("tin", Vector3(0.0, dais + 0.9, back_z + 2.2), Vector3(5.0, 1.8, 3.2), Basis.IDENTITY, 0.1, 0.9)
	mesh.box("metal_dark", Vector3(0.0, dais + 1.0 + (h - dais - 2.0) * 0.5, back_z), Vector3(6.0, h - dais - 2.0, 1.4), Basis.IDENTITY, 0.12, 0.9)
	for side: float in [-1.0, 1.0]:
		var ear: Vector3 = Vector3(side * 2.2, h - 1.2, back_z)
		mesh.tri("metal_dark", [ear + Vector3(-1.1, 0.0, 0.7), ear + Vector3(1.1, 0.0, 0.7), ear + Vector3(0.0, 2.2, 0.7)], Vector3(0.0, 0.0, 1.0))
		mesh.tri("metal_dark", [ear + Vector3(1.1, 0.0, -0.7), ear + Vector3(-1.1, 0.0, -0.7), ear + Vector3(0.0, 2.2, -0.7)], Vector3(0.0, 0.0, -1.0))
		mesh.lathe("rust", Vector3(side * 3.0, dais, back_z + 2.4), [Vector2(0.5, 0.0), Vector2(0.5, 2.6)], 10, 0.9, false, true)
	# a bottle-cap mask on the back and two banner poles with rag flags at the front corners
	mesh.lathe("cap_yellow", Vector3(0.0, h * 0.62, back_z + 0.75), [Vector2(1.2, 0.0), Vector2(1.2, 0.12)], 14, 0.9, false, true)
	mesh.box("tyre", Vector3(0.0, h * 0.62, back_z + 0.85), Vector3(1.6, 0.4, 0.06), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		var pole: Vector3 = Vector3(side * (w * 0.5 - 0.6), dais, d * 0.5 - 0.6)
		mesh.tube("wood_dark", pole, pole + Vector3(0.0, h * 0.6, 0.0), 0.12, 6, true)
		var top: Vector3 = pole + Vector3(0.0, h * 0.6, 0.0)
		mesh.tri("cap_red" if side < 0.0 else "cap_blue", [top, top + Vector3(0.0, -2.2, 0.0), top + Vector3(side * 2.4, -1.1, 0.0)], Vector3(0.0, 0.0, 1.0))
		mesh.tri("cap_red" if side < 0.0 else "cap_blue", [top, top + Vector3(side * 2.4, -1.1, 0.0), top + Vector3(0.0, -2.2, 0.0)], Vector3(0.0, 0.0, -1.0))
	# pizza-box and can heaps along the dais sides
	for index: int in range(6):
		var x: float = -w * 0.5 + 2.5 + (w - 5.0) * float(index) / 5.0
		var z: float = (d * 0.5 - 1.2) * (1.0 if index % 2 == 0 else -1.0)
		mesh.box("straw" if index % 3 != 1 else "cap_red", Vector3(x, dais + 0.3, z), Vector3(1.4, 0.5, 1.2), Basis(Vector3.UP, float(index) * 0.7), 0.04)
	# the steps down to the land (south), two treads and a landing lip
	mesh.box("tin", Vector3(0.0, dais * 0.5, d * 0.5 + 1.2), Vector3(6.0, dais, 2.4), Basis.IDENTITY, 0.06, 0.9)
	mesh.box("tin", Vector3(0.0, dais * 0.25, d * 0.5 + 3.2), Vector3(6.0, dais * 0.5, 1.8), Basis.IDENTITY, 0.06, 0.9)
	mesh.box("rust", Vector3(0.0, 0.1, d * 0.5 + 4.6), Vector3(6.4, 0.2, 1.4), Basis.IDENTITY, 0.02)
	circles.append(Vector3(-w * 0.25, 0.0, d * 0.5))
	circles.append(Vector3(w * 0.25, 0.0, d * 0.5))
	circles.append(Vector3(0.0, d * 0.5 + 2.7, 2.4))
	return _finish(mesh, "TrashPandaThrone", circles, size, true)


## The Rotheart's root gate on the land at the foot of the tree: two great roots arching over a dark hollow, roots spreading over the ground, violet
## fungus on them. The main_dungeon spot stands in front of the hollow (south).
static func root_gate(size: Vector3) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var w: float = size.x
	var h: float = size.y
	var span: float = w * 0.35
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * span, 0.0, 0.0)
		mesh.lathe("bark", foot, [Vector2(1.9, 0.0), Vector2(1.5, h * 0.35), Vector2(1.1, h * 0.7), Vector2(0.9, h * 0.9)], 10, 0.9, true, true)
		# roots spreading from the foot: out to the side and back, never south where the hero stands
		for index: int in range(4):
			var a: float = PI * (0.1 + 0.27 * float(index))
			var direction: Vector3 = Vector3(side * cos(a), 0.0, -sin(a))
			mesh.tube("bark_light", foot + Vector3(0.0, 0.35, 0.0), foot + direction * (3.2 + float(index % 2) * 1.2) + Vector3(0.0, -0.1, 0.0), 0.3, 6, true)
		mesh.blob("fungus", foot + Vector3(side * 1.0, h * 0.45, 1.3), Vector3(0.5, 0.25, 0.4), 4, 8, 0.9)
		mesh.blob("fungus", foot + Vector3(side * -0.4, h * 0.72, 1.0), Vector3(0.35, 0.2, 0.3), 4, 8, 0.9)
	# the arch over the hollow and the hollow itself
	mesh.tube("bark", Vector3(-span, h * 0.88, 0.0), Vector3(0.0, h, 0.0), 0.8, 8, true)
	mesh.tube("bark", Vector3(0.0, h, 0.0), Vector3(span, h * 0.88, 0.0), 0.8, 8, true)
	mesh.tube("bark_light", Vector3(-span * 0.6, h * 0.95, 0.5), Vector3(span * 0.6, h * 0.95, 0.5), 0.35, 6, true)
	mesh.lathe("bark", Vector3(0.0, 0.0, -1.5), [Vector2(2.1, 0.0), Vector2(2.0, h * 0.6), Vector2(1.2, h * 0.9)], 12, 0.9, true, true)
	mesh.box("hollow", Vector3(0.0, h * 0.4, 0.4), Vector3(span * 0.9, h * 0.62, 0.3), Basis.IDENTITY, 0.0)
	circles.append(Vector3(-span, 0.0, 1.8))
	circles.append(Vector3(0.0, -1.5, 2.0))
	circles.append(Vector3(span, 0.0, 1.8))
	return _finish(mesh, "RootGate", circles, size, false)


## The farm rows' rusty windmill: a patched plank tower with a tin cap, four rag sails on a separate "Sails" child the builder spins (meta "spinner").
static func windmill(size: Vector3) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var r: float = size.x * 0.5
	var h: float = size.y
	var cap: float = h * 0.78
	mesh.lathe("wood", Vector3.ZERO, [Vector2(r, 0.0), Vector2(r * 0.72, cap)], 12, 0.9, true, false)
	mesh.lathe("rust", Vector3(0.0, cap, 0.0), [Vector2(r * 0.9, 0.0), Vector2(r * 0.85, 0.35), Vector2(0.0, h - cap)], 12, 0.9, false, false)
	for index: int in range(5):
		var a: float = float(index) * 1.3 + 0.4
		var y: float = 1.0 + float(index) * (cap - 2.0) / 5.0
		mesh.box("metal" if index % 2 == 0 else "rust_dark", Vector3(cos(a) * r * (0.9 - 0.2 * y / cap), y, sin(a) * r * (0.9 - 0.2 * y / cap)), Vector3(1.1, 0.8, 0.12), Basis(Vector3.UP, -a + PI * 0.5), 0.02)
	mesh.box("wood_dark", Vector3(0.0, 1.1, r * 0.95), Vector3(1.2, 2.2, 0.16), Basis.IDENTITY, 0.02)
	mesh.box("metal_dark", Vector3(0.0, cap * 0.6, r * 0.8), Vector3(0.8, 0.8, 0.1), Basis.IDENTITY, 0.0)
	mesh.tube("metal_dark", Vector3(0.0, cap - 0.3, 0.0), Vector3(0.0, cap - 0.3, r * 0.75 + 0.6), 0.22, 8, true)
	circles.append(Vector3(0.0, 0.0, r))
	var root: Node3D = _finish(mesh, "RustyWindmill", circles, size, false)
	var sails: KitMesh = KitMesh.new()
	_materials(sails)
	var reach: float = h * 0.48
	sails.lathe("rust", Vector3.ZERO, [Vector2(0.4, -0.3), Vector2(0.4, 0.3)], 10, 0.9, true, true)
	for blade: int in range(4):
		var a: float = float(blade) * PI * 0.5 + 0.35
		var tip: Vector3 = Vector3(cos(a), sin(a), 0.0) * reach
		sails.tube("wood_dark", Vector3.ZERO, tip, 0.1, 5, true)
		var mid: Vector3 = Vector3(cos(a), sin(a), 0.0) * reach * 0.58
		sails.box("straw" if blade % 2 == 0 else "metal", mid + Vector3(0.0, 0.0, 0.12), Vector3(reach * 0.62, 0.9, 0.05), Basis(Vector3(0.0, 0.0, 1.0), a), 0.0)
	var sail_node: MeshInstance3D = sails.instance("Sails")
	sail_node.set_meta(PaintedClasses.META_NO_PAINT, true)
	sail_node.position = Vector3(0.0, cap - 0.3, r * 0.75 + 0.7)
	root.add_child(sail_node)
	root.set_meta("spinner", sail_node)
	return root


## The way in from town: a plank bridge on rusty girders out over the overflow pool, tyre kerbs, rope rails on scrap posts, a gate of stacked tyres with
## a rusty beam (the zone's icon on it) at the land end and a landing with two rag-flag posts at the town end. Along +z from the origin.
static func entrance_bridge(length: float, width: float) -> Node3D:
	var mesh: KitMesh = KitMesh.new()
	_materials(mesh)
	var circles: Array[Vector3] = []
	var half: float = width * 0.5
	for side: float in [-1.0, 1.0]:
		mesh.box("rust", Vector3(side * (half - 0.35), -0.36, length * 0.5), Vector3(0.4, 0.5, length), Basis.IDENTITY, 0.03, 0.85)
	var plank: float = 1.0
	var count: int = int(ceilf(length / plank))
	for index: int in range(count):
		var z: float = plank * (float(index) + 0.5)
		mesh.box("wood" if index % 3 != 1 else "wood_dark", Vector3(0.0, -0.08, minf(z, length - plank * 0.5)), Vector3(width, 0.16, plank - 0.1), Basis.IDENTITY, 0.02, 0.92)
	for side: float in [-1.0, 1.0]:
		mesh.box("tyre", Vector3(side * (half - 0.15), 0.12, length * 0.5), Vector3(0.3, 0.3, length), Basis.IDENTITY, 0.04)
	# posts with rope between them, girder pillars down into the pool
	var post_step: float = 3.6
	var posts: int = maxi(2, int(round(length / post_step)))
	var previous: Dictionary = {}
	for index: int in range(1, posts):
		var z: float = length * float(index) / float(posts)
		for side: float in [-1.0, 1.0]:
			var base: Vector3 = Vector3(side * (half + 0.3), 0.0, z)
			mesh.tube("wood_dark", base, base + Vector3(0.0, 1.3, 0.0), 0.11, 6, true)
			mesh.lathe("rust", base + Vector3(0.0, 1.3, 0.0), [Vector2(0.16, 0.0), Vector2(0.0, 0.2)], 6, 0.9, false, false)
			if previous.has(side):
				mesh.tube("straw", (previous[side] as Vector3) + Vector3(0.0, 1.15, 0.0), base + Vector3(0.0, 1.15, 0.0), 0.04, 4, false)
			previous[side] = base
		mesh.tube("rust_dark", Vector3(0.0, -4.0, z), Vector3(0.0, -0.3, z), 0.32, 8, true)
		mesh.box("rust_dark", Vector3(0.0, -0.75, z), Vector3(width + 0.2, 0.22, 0.4), Basis.IDENTITY, 0.0)
	# the gate at the land end: stacked-tyre pillars with a rusty beam, moss and flowers on it
	var gate_h: float = 3.8
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.55), 0.0, 0.4)
		for index: int in range(5):
			mesh.lathe("tyre", foot + Vector3(0.0, float(index) * 0.5, 0.0), [Vector2(0.78, 0.0), Vector2(0.82, 0.25), Vector2(0.78, 0.5)], 12, 0.9, true, true)
			mesh.lathe("metal_dark", foot + Vector3(0.0, float(index) * 0.5, 0.0), [Vector2(0.34, 0.0), Vector2(0.34, 0.52)], 8, 0.9, false, true)
		mesh.box("metal", foot + Vector3(0.0, 2.5 + 0.7, 0.0), Vector3(0.5, 1.4, 0.5), Basis.IDENTITY, 0.03)
		circles.append(Vector3(foot.x, foot.z, 0.75))
	mesh.box("rust", Vector3(0.0, gate_h, 0.4), Vector3(width + 2.6, 0.7, 0.5), Basis.IDENTITY, 0.03)
	mesh.box("rust_dark", Vector3(0.0, gate_h - 0.45, 0.4), Vector3(width + 2.2, 0.12, 0.52), Basis.IDENTITY, 0.0)
	for index: int in range(1, 6):
		var x: float = -(half + 0.55) + (width + 1.1) * float(index) / 6.0
		mesh.tri("cap_red" if index % 2 == 0 else "cap_yellow", [Vector3(x - 0.25, gate_h - 0.52, 0.7), Vector3(x + 0.25, gate_h - 0.52, 0.7), Vector3(x, gate_h - 1.0, 0.7)], Vector3(0.0, 0.0, 1.0))
	# the far landing: a plank square with two rag-flag posts, where the way to town begins
	var landing_z: float = length + 1.6
	mesh.box("rust", Vector3(0.0, -0.36, landing_z), Vector3(width + 1.6, 0.42, 3.6), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("wood", Vector3(0.0, -0.08, landing_z), Vector3(width + 1.2, 0.16, 3.4), Basis.IDENTITY, 0.03, 0.92)
	for side: float in [-1.0, 1.0]:
		var foot: Vector3 = Vector3(side * (half + 0.4), 0.0, landing_z + 1.5)
		mesh.tube("wood_dark", foot, foot + Vector3(0.0, 2.9, 0.0), 0.14, 6, true)
		mesh.tri("cap_blue", [foot + Vector3(0.0, 2.9, 0.0), foot + Vector3(0.0, 2.0, 0.0), foot + Vector3(side * 1.1, 2.45, 0.0)], Vector3(0.0, 0.0, 1.0))
		mesh.tri("cap_blue", [foot + Vector3(0.0, 2.9, 0.0), foot + Vector3(side * 1.1, 2.45, 0.0), foot + Vector3(0.0, 2.0, 0.0)], Vector3(0.0, 0.0, -1.0))
		circles.append(Vector3(foot.x, foot.z, 0.5))
		mesh.tube("rust_dark", Vector3(side * (half + 0.2), -4.0, landing_z), Vector3(side * (half + 0.2), -0.3, landing_z), 0.3, 8, true)
	var root: Node3D = _finish(mesh, "Bridge", circles, Vector3(width, gate_h, length), true)
	(root.get_child(0) as MeshInstance3D).set_meta(&"no_range_cull", true)
	IconSign.attach(root, "ICON-ENERGY-R", Vector3(0.0, gate_h, 0.7), 1.2)
	P.moss_patches(root, 10, 3.6, gate_h + 0.2, 2)
	P.flowers_on(root, 8, 3.4, gate_h + 0.3)
	return root


## The Rotheart: a colossal, sickly tree beyond the north rim (a `LandmarkKit` giant_tree in the Rot's violet and a mould green), castle scale.
static func rotheart(size: Vector3) -> Node3D:
	return LandmarkKit.build({"id": "HEAP-HERO-ROTHEART", "kind": "giant_tree", "size": [size.x, size.y, size.z], "color": "#586a44", "accent": "#3a2a40", "no_fade": true})


## Junk Mountain: a mound of scrap beyond the north-east corner, over the scree.
static func junk_mountain(size: Vector3) -> Node3D:
	return LandmarkKit.build({"id": "HEAP-HERO-JUNK-MOUNTAIN", "kind": "mound", "size": [size.x, size.y, size.z], "color": "#6e6050", "accent": "#b5552d", "no_fade": true})
