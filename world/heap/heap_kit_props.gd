class_name HeapKitProps
extends RefCounted
## The Verdant Dump's dressing pieces built from its zone kit (docs/art/heap_slice.md, Art Part D): they replace the old procedural pieces in place (same
## positions, turns and blocking circles, which stay layout data) and add the walks. Every piece is a `KitMesh` with `HeapLandmarks`' kit materials (the
## DUMP-* surfaces, the palette flats, the sliced doors, windows and flags), painted cards for the kit's props and plants, and icon pictures only (G-03).
##   scrap_fence   the tyre wall and the district dividers as one knee-high fence of old doors and tin on posts with a rope rail (one mesh per run)
##   shack         a patched shack (the barns): mossy planks or old doors, a tin or reed roof, a sliced door and windows, rope trim, rag bunting, a lantern
##   stall         Granny Gristle's swap stall: a counter under a striped awning on a back wall, shelves of goods, an icon board, a lantern
##   board         the scrap sign board (salvaged planks tied to two posts) the icon pictures hang on
##   bridge        a sturdy plank bridge (the vine bridges' growth segments "Seg<n>"), wider-looking than the walk with beams, posts, rope and vines
##   walks         plank walkways (DUMP-PATH-PLANK) laid along stretches of the main routes, flat on the ground

const L = preload("res://world/heap/heap_landmarks.gd")


static func _mesh() -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	L._materials(mesh)
	return mesh


static func _instance(mesh: KitMesh, node_name: String, never_fade: bool) -> MeshInstance3D:
	var body: MeshInstance3D = mesh.instance(node_name)
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	if never_fade:
		body.set_meta(&"no_occlusion_fade", true)
	return body


## The fence along `points` (the layout's post positions, about a metre apart; a gap longer than 1.6 m starts a new run): door and tin panels 1.1 m high
## between posts every two metres, a rope rail on top, a tyre stack at each run's ends, moss and the odd flower crate. Knee to hip high: it never hides
## the hero, so it never fades. `ground` gives the height at a point.
static func scrap_fence(points: Array[Vector3], ground: Callable) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "ScrapFence"
	var mesh: KitMesh = _mesh()
	var runs: Array = []
	var run: Array[Vector3] = []
	for point: Vector3 in points:
		if not run.is_empty() and Vector2(point.x - run[run.size() - 1].x, point.z - run[run.size() - 1].z).length() > 1.6:
			runs.append(run)
			run = []
		run.append(point)
	if not run.is_empty():
		runs.append(run)
	var panel_index: int = 0
	for entry: Variant in runs:
		var line: Array[Vector3] = []
		line.assign(entry as Array)
		if line.size() < 2:
			continue
		var index: int = 0
		while index < line.size() - 1:
			var a: Vector3 = line[index]
			var b: Vector3 = line[mini(index + 2, line.size() - 1)]
			a.y = float(ground.call(a.x, a.z))
			b.y = float(ground.call(b.x, b.z))
			var mid: Vector3 = (a + b) * 0.5
			var along: Vector3 = (b - a)
			var length: float = Vector2(along.x, along.z).length()
			var yaw: float = atan2(along.x, along.z)
			var basis: Basis = Basis(Vector3.UP, yaw - PI * 0.5) * Basis(Vector3.FORWARD, 0.03 * float(panel_index % 3 - 1))
			var height: float = 1.0 + 0.12 * float(panel_index % 3)
			mesh.box("doors" if panel_index % 3 != 2 else "tin", mid + Vector3(0, height * 0.5 + 0.05, 0), Vector3(length + 0.05, height, 0.12), basis, 0.02, 0.85)
			mesh.tube("wood_dark", a + Vector3(0, -0.1, 0), a + Vector3(0, 1.35, 0), 0.08, 6, true)
			if panel_index % 4 == 1:
				mesh.blob("leaf" if panel_index % 8 == 1 else "leaf_dark", mid + Vector3(0, height + 0.08, 0), Vector3(0.5, 0.22, 0.3), 3, 6, 0.95)
			panel_index += 1
			index += 2
		# the rope rail along the run's tops and the tyre stacks at its ends
		for step: int in range(0, line.size() - 1):
			var a: Vector3 = line[step]
			var b: Vector3 = line[step + 1]
			a.y = float(ground.call(a.x, a.z)) + 1.3
			b.y = float(ground.call(b.x, b.z)) + 1.3
			mesh.tube("rope", a, b, 0.04, 4, false)
		for end: Vector3 in [line[0], line[line.size() - 1]]:
			var foot: Vector3 = Vector3(end.x, float(ground.call(end.x, end.z)), end.z)
			for ring: int in range(3):
				mesh.lathe("tyre", foot + Vector3(0, 0.3 * float(ring), 0), [Vector2(0.52, 0.0), Vector2(0.56, 0.15), Vector2(0.52, 0.3)], 12, 0.9, true, true)
			mesh.blob("leaf", foot + Vector3(0, 0.95, 0), Vector3(0.45, 0.3, 0.45), 3, 8, 0.95)
	var body: MeshInstance3D = _instance(mesh, "Fence", true)
	body.set_meta(&"no_range_cull", true)
	root.add_child(body)
	return root


## A patched shack `size` (w, h to the ridge, d), the door on +z: a plank plinth, walls of mossy planks (variant 0) or old doors (1) with tin patches, a
## tin (0) or reed (1) gable roof with rope trim at the eaves, a sliced door and two windows, rag bunting from the eaves, flower crates by the door, a
## lantern, moss on the roof. `icon` (an ICON-* id) hangs over the door.
static func shack(size: Vector3, variant: int, icon: String) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Shack"
	var mesh: KitMesh = _mesh()
	var w: float = size.x
	var d: float = size.z
	var eave: float = size.y * 0.62
	var ridge: float = size.y
	var wall: String = "mosswood" if variant % 2 == 0 else "doors"
	var roof: String = "tin" if variant % 2 == 0 else "reed"
	mesh.box("plank", Vector3(0, 0.12, 0), Vector3(w + 0.4, 0.24, d + 0.4), Basis.IDENTITY, 0.03, 0.9)
	mesh.box(wall, Vector3(0, 0.24 + (eave - 0.24) * 0.5, 0), Vector3(w, eave - 0.24, d), Basis.IDENTITY, 0.03, 0.85)
	for gz: float in [-1.0, 1.0]:
		mesh.tri(wall, [Vector3(-w * 0.5, eave, gz * d * 0.5), Vector3(w * 0.5, eave, gz * d * 0.5), Vector3(0, ridge, gz * d * 0.5)], Vector3(0, 0, gz))
	var slope: float = atan2(ridge - eave, w * 0.5)
	var rafter: float = Vector2(w * 0.5, ridge - eave).length() + 0.5
	for side: float in [-1.0, 1.0]:
		var centre: Vector3 = Vector3(side * w * 0.25, (eave + ridge) * 0.5 + 0.12, 0)
		mesh.box(roof, centre, Vector3(rafter, 0.16, d + 0.8), Basis(Vector3.FORWARD, side * slope), 0.0, 0.9)
		mesh.box("rope", Vector3(side * (w * 0.5 + 0.18), eave - 0.02, 0), Vector3(0.14, 0.16, d + 0.8), Basis(Vector3.FORWARD, side * slope), 0.0)
		mesh.blob("leaf" if side < 0.0 else "leaf_dark", Vector3(side * w * 0.22, (eave + ridge) * 0.5 + 0.35, d * 0.15), Vector3(0.8, 0.25, 0.7), 3, 8, 0.95)
	# tin patches and the door and windows on the front
	for index: int in range(3):
		var x: float = -w * 0.35 + float(index) * w * 0.35
		mesh.box("tin" if wall == "mosswood" else "mosswood", Vector3(x, 0.9 + float(index % 2) * 0.8, -d * 0.5 - 0.03), Vector3(0.9, 0.8, 0.05), Basis.IDENTITY, 0.0)
	L._card(mesh, "DUMP-SHEET-DOORS-0%d" % (2 + variant % 4), Vector3(0, 0.24, d * 0.5 + 0.04), minf(2.3, eave - 0.3), Vector3(0, 0, 1))
	for wx: float in [-1.0, 1.0]:
		L._card(mesh, "DUMP-SHEET-WINDOWS-0%d" % (1 + (variant + int(wx + 1.0)) % 6), Vector3(wx * w * 0.32, eave * 0.42, d * 0.5 + 0.04), 1.1, Vector3(0, 0, 1))
	# bunting from the eaves' front corners to a pole, flower crates and a lantern by the door
	var pole: Vector3 = Vector3(w * 0.5 + 1.2, 0.0, d * 0.5 + 1.0)
	mesh.tube("wood_dark", pole, pole + Vector3(0, eave + 0.6, 0), 0.07, 5, true)
	var top_a: Vector3 = Vector3(-w * 0.5, eave, d * 0.5 + 0.3)
	var top_b: Vector3 = pole + Vector3(0, eave + 0.5, 0)
	mesh.tube("rope", top_a, top_b, 0.03, 4, false)
	var flags: int = int((top_b - top_a).length() / 0.7)
	for flag: int in range(flags):
		var at: Vector3 = top_a.lerp(top_b, (float(flag) + 0.5) / float(flags)) + Vector3(0, -0.05, 0.02)
		var tint: String = ["cloth_red", "cloth_cream", "cloth_teal", "cloth_green", "cloth_rust"][flag % 5]
		mesh.tri(tint, [at + Vector3(-0.2, 0, 0), at + Vector3(0.2, 0, 0), at + Vector3(0, -0.45, 0)], Vector3(0, 0, 1))
		mesh.tri(tint, [at + Vector3(0.2, 0, 0), at + Vector3(-0.2, 0, 0), at + Vector3(0, -0.45, 0)], Vector3(0, 0, -1))
	L._card(mesh, "DUMP-PLANT-WILD", Vector3(-1.4, 0.24, d * 0.5 + 0.45), 1.0, Vector3(0, 0, 1))
	L._card(mesh, "DUMP-PLANT-WILD", Vector3(1.4, 0.24, d * 0.5 + 0.45), 0.9, Vector3(0, 0, 1))
	mesh.tube("wood_dark", Vector3(1.0, 2.35, d * 0.5 + 0.05), Vector3(1.0, 2.35, d * 0.5 + 0.45), 0.04, 4, false)
	mesh.box("lantern", Vector3(1.0, 2.1, d * 0.5 + 0.45), Vector3(0.28, 0.38, 0.28), Basis.IDENTITY, 0.03)
	root.add_child(_instance(mesh, "Body", false))
	if icon != "":
		IconSign.attach(root, icon, Vector3(0, minf(2.3, eave - 0.3) + 0.55, d * 0.5 + 0.08), 0.8)
	return root


## Granny Gristle's swap stall (the front +z faces the plaza): a back wall of old doors, a plank counter, shelves of jars and crates, a striped awning on
## two posts, a tin roof over it, the vendor's icon on a board above, a lantern and a tyre garden at one end.
static func stall() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "SwapStall"
	var mesh: KitMesh = _mesh()
	var w: float = 3.6
	mesh.box("doors", Vector3(0, 1.3, -0.9), Vector3(w, 2.6, 0.2), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("plank", Vector3(0, 0.5, 0.3), Vector3(w - 0.3, 1.0, 0.7), Basis.IDENTITY, 0.03, 0.9)
	mesh.box("wood", Vector3(0, 1.04, 0.3), Vector3(w - 0.1, 0.08, 0.85), Basis.IDENTITY, 0.02)
	for shelf: float in [1.4, 2.0]:
		mesh.box("wood_dark", Vector3(0, shelf, -0.7), Vector3(w - 0.5, 0.06, 0.3), Basis.IDENTITY, 0.0)
		for index: int in range(6):
			var x: float = -w * 0.38 + float(index) * w * 0.15
			if index % 3 == 0:
				mesh.box("plank", Vector3(x, shelf + 0.16, -0.7), Vector3(0.3, 0.28, 0.24), Basis.IDENTITY, 0.02)
			else:
				mesh.lathe(["cloth_teal", "gold", "cloth_green"][index % 3], Vector3(x, shelf + 0.03, -0.7), [Vector2(0.1, 0.0), Vector2(0.11, 0.2), Vector2(0.05, 0.28)], 8, 1.0, false, true)
	# goods on the counter: a kettle, cogs, a jar
	mesh.lathe("metal", Vector3(-1.0, 1.08, 0.35), [Vector2(0.18, 0.0), Vector2(0.2, 0.16), Vector2(0.06, 0.3)], 10, 0.9, false, true)
	mesh.tube("rust", Vector3(0.6, 1.1, 0.4), Vector3(0.6, 1.14, 0.4), 0.22, 10, true)
	mesh.lathe("cloth_teal", Vector3(1.1, 1.08, 0.3), [Vector2(0.12, 0.0), Vector2(0.13, 0.3), Vector2(0.06, 0.38)], 8, 1.0, false, true)
	# the awning: posts, a striped cloth slope, a tin roof behind it
	for side: float in [-1.0, 1.0]:
		mesh.tube("wood_dark", Vector3(side * (w * 0.5 - 0.1), 0.0, 1.0), Vector3(side * (w * 0.5 - 0.1), 2.3, 1.0), 0.07, 5, true)
	var stripes: int = 6
	for index: int in range(stripes):
		var x0: float = -w * 0.5 + w * float(index) / float(stripes)
		var x1: float = x0 + w / float(stripes)
		mesh.quad("cloth_rust" if index % 2 == 0 else "cloth_cream", [Vector3(x0, 2.3, 1.15), Vector3(x1, 2.3, 1.15), Vector3(x1, 2.75, -0.2), Vector3(x0, 2.75, -0.2)], Vector3(0, 0.95, 0.3).normalized())
	mesh.box("tin", Vector3(0, 2.8, -0.55), Vector3(w + 0.3, 0.12, 0.9), Basis(Vector3.RIGHT, -0.15), 0.0)
	mesh.box("plank", Vector3(0, 3.15, -0.85), Vector3(1.2, 0.8, 0.08), Basis.IDENTITY, 0.02)
	mesh.box("lantern", Vector3(w * 0.5 - 0.1, 2.05, 1.05), Vector3(0.26, 0.34, 0.26), Basis.IDENTITY, 0.03)
	L._card(mesh, "DUMP-PROP-TYRE", Vector3(-w * 0.5 - 0.6, 0.0, 0.2), 1.1, Vector3(0, 0, 1))
	root.add_child(_instance(mesh, "Body", false))
	IconSign.attach(root, "ICON-MAP-VENDOR", Vector3(0, 3.15, -0.8), 0.62)
	return root


## The scrap sign board (`width` x `height`, its face +z at 1.45 m like `HeapProps.sign_post`): a salvaged plank board with a rope binding on two posts.
static func board(width: float, height: float) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "ScrapBoard"
	var mesh: KitMesh = _mesh()
	mesh.box("plank", Vector3(0, 1.45 + height * 0.5, 0), Vector3(width, height, 0.1), Basis.IDENTITY, 0.02, 0.92)
	mesh.box("cloth_cream", Vector3(0, 1.45 + height * 0.5, 0.055), Vector3(width * 0.82, height * 0.82, 0.01), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		mesh.tube("wood_dark", Vector3(side * width * 0.36, 0.0, -0.06), Vector3(side * width * 0.36, 1.6 + height, -0.06), 0.07, 6, true)
		mesh.box("rope", Vector3(side * width * 0.36, 1.45 + height * 0.8, 0.0), Vector3(0.16, 0.12, 0.16), Basis.IDENTITY, 0.0)
	root.add_child(_instance(mesh, "Body", false))
	return root


## A sturdy plank bridge `length` metres along -z (the south end at the origin), cut into growth segments "Seg<n>" of 0.9 m like the vine bridge it
## replaces (the builder grows them one after another): a plank deck a little wider than the walk on two beams, posts with rope rails, vines and a few
## blooms on the rails; the walk itself (the layout's bridge strip) is unchanged.
static func bridge(length: float) -> Node3D:
	var root: Node3D = Node3D.new()
	var count: int = int(ceilf(length / 0.9))
	for index: int in range(count):
		var segment: Node3D = Node3D.new()
		segment.name = "Seg%d" % index
		segment.position = Vector3(0.0, 0.0, -float(index) * 0.9)
		root.add_child(segment)
		var mesh: KitMesh = _mesh()
		mesh.box("plank", Vector3(0, 0.0, 0.0), Vector3(3.1, 0.16, 0.86), Basis(Vector3.UP, 0.02 * float(index % 3 - 1)), 0.02, 0.92)
		for side: float in [-1.0, 1.0]:
			mesh.box("wood_dark", Vector3(side * 1.25, -0.22, 0.0), Vector3(0.26, 0.3, 0.92), Basis.IDENTITY, 0.02, 0.85)
			mesh.box("wood_dark", Vector3(side * 1.62, 0.02, 0.0), Vector3(0.14, 0.12, 0.92), Basis.IDENTITY, 0.0)
			if index % 2 == 0:
				mesh.tube("wood_dark", Vector3(side * 1.62, -0.1, 0.0), Vector3(side * 1.62, 1.05, 0.0), 0.08, 6, true)
				mesh.blob("leaf", Vector3(side * 1.62, 0.35 + 0.2 * float(index % 4), 0.06), Vector3(0.16, 0.24, 0.14), 3, 6, 0.95)
			mesh.tube("rope", Vector3(side * 1.62, 0.98, 0.46), Vector3(side * 1.62, 0.98, -0.46), 0.045, 4, false)
			if index % 3 == 1:
				mesh.blob("leaf_light", Vector3(side * 1.62, 1.0, 0.0), Vector3(0.2, 0.12, 0.3), 3, 6, 1.0)
				mesh.blob("sunflower" if side < 0.0 else "petal_violet", Vector3(side * 1.62, 1.08, 0.12), Vector3(0.09, 0.09, 0.09), 2, 6, 1.0)
		segment.add_child(_instance(mesh, "Body", true))
	return root


## Plank walkways along stretches of the routes: `lines` are polylines (x, z); boards about 0.8 m deep and `width` across, laid every 0.85 m, following
## the ground (`ground`), a little uneven. One mesh, flat, walked on (never fades, casts no shadow).
static func walks(lines: Array, width: float, ground: Callable) -> MeshInstance3D:
	var mesh: KitMesh = _mesh()
	var count: int = 0
	for entry: Variant in lines:
		var line: PackedVector2Array = entry as PackedVector2Array
		for index: int in range(line.size() - 1):
			var a: Vector2 = line[index]
			var b: Vector2 = line[index + 1]
			var length: float = a.distance_to(b)
			var steps: int = int(length / 0.85)
			var yaw: float = atan2(b.x - a.x, b.y - a.y)
			for step: int in range(steps):
				var p: Vector2 = a.lerp(b, (float(step) + 0.5) / float(steps))
				var y: float = float(ground.call(p.x, p.y))
				var jitter: float = 0.03 * float((count * 7) % 5 - 2)
				mesh.box("plank", Vector3(p.x, y + 0.05, p.y), Vector3(width - 0.2 * float(count % 2), 0.1, 0.78), Basis(Vector3.UP, yaw + jitter), 0.015, 0.95)
				count += 1
	var body: MeshInstance3D = _instance(mesh, "PlankWalks", true)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.set_meta(&"no_range_cull", true)
	return body


## Druid Thistlewick's grove (the appliance ring, the quiz spot at its centre): nine old appliances in a ring of 3.4 m, now rusted tin and old-door panels
## grown over with vines, moss and flowers (the white boxes read as blanks from the farm camera), a wildflower crate between each pair.
static func appliance_grove() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "ApplianceGrove"
	var mesh: KitMesh = _mesh()
	for index: int in range(9):
		var angle: float = TAU * (float(index) + 0.5) / 10.0 + 0.5
		var pos: Vector3 = Vector3(cos(angle) * 3.4, 0.0, sin(angle) * 3.4)
		var basis: Basis = Basis(Vector3.UP, -angle + PI * 0.5)
		var tall: bool = index % 3 != 1
		var h: float = 2.0 if tall else 1.1
		mesh.box("tin" if index % 2 == 0 else "doors", pos + Vector3(0, h * 0.5, 0), Vector3(1.1, h, 1.0), basis, 0.06, 0.85)
		mesh.box("metal_dark", pos + basis * Vector3(0.0, h * 0.75 - pos.y, 0.52) + Vector3(0, 0, 0), Vector3(0.9, 0.05, 0.05), basis, 0.0)
		if not tall:
			mesh.tube("metal_dark", pos + basis * Vector3(0, 0.6, 0.5), pos + basis * Vector3(0, 0.6, 0.56), 0.35, 10, true)
		for leaf: int in range(3):
			mesh.blob("leaf" if leaf % 2 == 0 else "leaf_dark", pos + basis * Vector3(0.3 - 0.3 * float(leaf), h + 0.05 - 0.4 * float(leaf), 0.4), Vector3(0.35, 0.25, 0.2), 3, 6, 0.95)
		var gap: Vector3 = Vector3(cos(angle + TAU / 20.0) * 3.6, 0.0, sin(angle + TAU / 20.0) * 3.6)
		if index % 2 == 0:
			root.add_child(_flower_card(gap, 0.9))
	root.add_child(_instance(mesh, "Body", false))
	return root


static func _flower_card(pos: Vector3, height: float) -> MeshInstance3D:
	var card: MeshInstance3D = KitFoliage.card("DUMP-PLANT-WILD", Vector2(height * EnvKit.aspect("DUMP-PLANT-WILD"), height), false)
	card.position = pos
	return card


## A compost pit's rim (the hazard is the layout's; this is how it reads): a ring of plank stakes leaning outward and reeds on its far side.
static func pit_rim(radius: float) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "PitRim"
	var mesh: KitMesh = _mesh()
	var stakes: int = int(TAU * radius / 0.9)
	for index: int in range(stakes):
		var a: float = TAU * float(index) / float(stakes)
		var out: Vector3 = Vector3(cos(a), 0, sin(a))
		var base: Vector3 = out * (radius + 0.75)
		var height: float = 0.5 + 0.25 * float(index % 3)
		mesh.box("plank" if index % 4 != 0 else "wood_dark", base + Vector3(0, height * 0.5 - 0.2, 0), Vector3(0.36, height, 0.1), Basis(Vector3.UP, -a + PI * 0.5) * Basis(Vector3.RIGHT, -0.2), 0.01, 0.9)
	root.add_child(_instance(mesh, "Body", true))
	for index: int in range(3):
		var a: float = -PI * 0.5 + (float(index) - 1.0) * 0.6
		var card: MeshInstance3D = KitFoliage.card("DUMP-PLANT-REED", Vector2(1.4, 2.0), false)
		card.position = Vector3(cos(a), 0, sin(a)) * (radius + 1.4)
		root.add_child(card)
	return root


## The fridge in the secret corner (its chest's lore piece): a rounded retro fridge in faded green with rust blooms, its door hanging open, vines and a
## wildflower crate on top (the cream box read as a blank slab from the junk peaks camera).
static func fridge() -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Fridge"
	var mesh: KitMesh = _mesh()
	mesh.box("cloth_green", Vector3(0, 1.2, 0), Vector3(1.4, 2.4, 1.2), Basis.IDENTITY, 0.18, 0.85)
	mesh.box("metal_dark", Vector3(0, 1.62, 0.61), Vector3(1.2, 0.05, 0.03), Basis.IDENTITY, 0.0)
	for patch: Vector3 in [Vector3(-0.4, 0.5, 0.61), Vector3(0.45, 1.9, 0.61), Vector3(-0.3, 2.1, 0.61)]:
		mesh.box("rust", patch, Vector3(0.4, 0.28, 0.02), Basis(Vector3.FORWARD, patch.x), 0.0)
	mesh.box("cloth_green", Vector3(0.95, 1.2, 0.95), Vector3(0.1, 2.2, 1.0), Basis(Vector3.UP, deg_to_rad(-50.0)), 0.04, 0.85)
	for leaf: int in range(5):
		mesh.blob("leaf" if leaf % 2 == 0 else "leaf_dark", Vector3(-0.72, 0.4 + 0.45 * float(leaf), 0.3 - 0.12 * float(leaf)), Vector3(0.2, 0.3, 0.26), 3, 6, 0.95)
	root.add_child(_instance(mesh, "Body", false))
	root.add_child(_flower_card(Vector3(0.0, 2.4, 0.0), 0.9))
	return root
