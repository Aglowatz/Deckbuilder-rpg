class_name DnaProps
extends RefCounted
## The D.N.A.'s few procedural set pieces, built from `KitMesh` primitives in the zone kit's surfaces (gray stone, brass trim, paneling, slate) so they read as one
## family with the hero landmarks (`DnaLandmarks`): the front and kitchen counters, the coffee machine, the breakroom table and bench, the Soul Routing console,
## Kyle's television, the elevator doors, the time clock, the suggestion box, the haunted printer and the icon boards. Origin on the ground at the centre, front +z.
## `piece(name, length)` is what `DnaBuilder` calls for a layout prop of kind "piece".

const GREY: Color = Color("6e7470")
const SLATE: Color = Color("3d4a44")
const PARCHMENT: Color = Color("c9c6b8")
const BRASS: Color = Color("b8945a")
const GHOST: Color = Color("4fbf7a")
const IRON: Color = Color("3a4144")
const WARM: Color = Color("ffd98a")


static func _mesh() -> KitMesh:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("grey", DnaLandmarks._surface("DNA-WALL-GREY", GREY))
	mesh.set_material("grey_dark", DnaLandmarks._surface("DNA-WALL-GREY", GREY, Color(0.74, 0.76, 0.76)))
	mesh.set_material("brass", DnaLandmarks._surface("DNA-TRIM-BRASS", BRASS))
	mesh.set_material("paneling", DnaLandmarks._surface("TEX-DNA-PANELING", SLATE.lightened(0.1)))
	mesh.set_material("marble", DnaLandmarks._surface("TEX-DNA-MARBLE", PARCHMENT.darkened(0.15)))
	mesh.set_material("slate", DnaLandmarks._surface("DNA-ROOF-SLATE", SLATE))
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "dna_props"))
	mesh.alias("dark", "flat", SLATE.srgb_to_linear())
	mesh.alias("iron", "flat", IRON.srgb_to_linear())
	mesh.alias("parchment", "flat", PARCHMENT.srgb_to_linear())
	mesh.alias("gold", "flat", BRASS.srgb_to_linear())
	mesh.alias("red", "flat", Color("8a2e2e").srgb_to_linear())
	mesh.alias("cabinet", "flat", Color("6b7572").srgb_to_linear())
	mesh.set_material("glow", EnvKit.glow(GHOST, 2.0))
	mesh.set_material("screen", EnvKit.glow(Color("8fe0a0"), 1.3))
	mesh.set_material("warm", EnvKit.glow(WARM, 1.4))
	return mesh


static func _finish(mesh: KitMesh, node_name: String) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = node_name
	var body: MeshInstance3D = mesh.instance("Body")
	body.set_meta(PaintedClasses.META_NO_PAINT, true)
	root.add_child(body)
	root.set_meta(&"no_wind", true)
	return root


## A layout piece by name; null for an unknown name.
static func piece(piece_name: String, length: float = 1.0) -> Node3D:
	match piece_name:
		"counter":
			return counter(length)
		"coffee_machine":
			return coffee_machine()
		"heal_couch":
			return heal_couch()
		"round_table":
			return round_table()
		"bench":
			return bench(length)
		"console":
			return console(length)
		"television":
			return television()
		"water_cooler":
			return water_cooler()
	return null


## A water cooler (Oct 19): a grey cabinet on a dark base, a brass tap, a translucent jug with a ghostly glow of water in it. 1.15 m tall, 0.5 m wide.
static func water_cooler() -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("dark", Vector3(0, 0.04, 0), Vector3(0.46, 0.08, 0.46), Basis.IDENTITY, 0.0, 0.9)
	mesh.box("grey", Vector3(0, 0.45, 0), Vector3(0.42, 0.74, 0.42), Basis.IDENTITY, 0.02, 0.82)
	mesh.box("paneling", Vector3(0, 0.46, 0.2), Vector3(0.36, 0.56, 0.03), Basis.IDENTITY, 0.0)
	mesh.box("gold", Vector3(0.08, 0.62, 0.23), Vector3(0.05, 0.05, 0.08), Basis.IDENTITY, 0.0)
	mesh.box("gold", Vector3(-0.08, 0.62, 0.23), Vector3(0.05, 0.05, 0.08), Basis.IDENTITY, 0.0)
	mesh.box("dark", Vector3(0, 0.84, 0), Vector3(0.44, 0.06, 0.44), Basis.IDENTITY, 0.0)
	mesh.set_material("water", EnvKit.glow(Color(0.55, 0.95, 0.85), 0.9))
	mesh.lathe("water", Vector3(0, 0.87, 0), [Vector2(0.0, 0.0), Vector2(0.15, 0.0), Vector2(0.17, 0.14), Vector2(0.16, 0.24), Vector2(0.09, 0.3), Vector2(0.0, 0.3)] as Array[Vector2], 12, 0.9, false, true)
	var root: Node3D = _finish(mesh, "WaterCooler")
	return root


## A paneled counter with a marble top and brass edge, `length` long (the front desk, the kitchen counter).
static func counter(length: float) -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("paneling", Vector3(0, 0.46, 0), Vector3(length, 0.92, 0.7), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("marble", Vector3(0, 0.95, 0), Vector3(length + 0.16, 0.06, 0.86), Basis.IDENTITY, 0.0)
	mesh.box("brass", Vector3(0, 0.98, 0.43), Vector3(length + 0.16, 0.04, 0.05), Basis.IDENTITY, 0.0)
	mesh.box("brass", Vector3(0, 0.1, 0.36), Vector3(length, 0.08, 0.03), Basis.IDENTITY, 0.0)
	var panels: int = maxi(1, int(length / 1.4))
	for index: int in range(panels):
		var x: float = -length * 0.5 + length * (float(index) + 0.5) / float(panels)
		mesh.box("brass", Vector3(x, 0.5, 0.36), Vector3(length / float(panels) * 0.7, 0.5, 0.02), Basis.IDENTITY, 0.0)
		mesh.box("paneling", Vector3(x, 0.5, 0.37), Vector3(length / float(panels) * 0.7 - 0.08, 0.42, 0.02), Basis.IDENTITY, 0.0)
	mesh.box("parchment", Vector3(-length * 0.3, 1.03, -0.05), Vector3(0.4, 0.1, 0.3), Basis(Vector3.UP, 0.2), 0.0)
	mesh.box("parchment", Vector3(length * 0.28, 1.06, 0.0), Vector3(0.36, 0.16, 0.28), Basis(Vector3.UP, -0.15), 0.0)
	return _finish(mesh, "Counter")


## The coffee machine: a brass-and-iron urn with a green pilot light, standing on a counter (origin at the counter top).
static func coffee_machine() -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("iron", Vector3(0, 0.98 + 0.22, 0), Vector3(0.5, 0.44, 0.4), Basis.IDENTITY, 0.02)
	mesh.lathe("brass", Vector3(0, 0.98 + 0.44, 0), [Vector2(0.18, 0.0), Vector2(0.2, 0.3), Vector2(0.16, 0.42), Vector2(0.05, 0.5)], 10, 1.0, false, true)
	mesh.tube("brass", Vector3(0.1, 1.2, 0.15), Vector3(0.1, 1.2, 0.32), 0.025, 5, true)
	mesh.box("glow", Vector3(-0.16, 1.26, 0.21), Vector3(0.05, 0.05, 0.02), Basis.IDENTITY, 0.0)
	mesh.box("parchment", Vector3(0.14, 1.0, 0.26), Vector3(0.09, 0.08, 0.09), Basis.IDENTITY, 0.0)
	return _finish(mesh, "CoffeeMachine")


## A round marble table on a brass pedestal.
static func round_table() -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.lathe("brass", Vector3.ZERO, [Vector2(0.3, 0.0), Vector2(0.28, 0.05), Vector2(0.06, 0.08), Vector2(0.06, 0.66)], 10, 0.9, true, true)
	mesh.lathe("marble", Vector3(0, 0.66, 0), [Vector2(0.6, 0.0), Vector2(0.62, 0.06)], 14, 1.0, true, true)
	mesh.lathe("brass", Vector3(0, 0.63, 0), [Vector2(0.63, 0.0), Vector2(0.63, 0.04)], 14, 1.0, false, false)
	mesh.box("parchment", Vector3(0.15, 0.74, -0.1), Vector3(0.14, 0.04, 0.14), Basis(Vector3.UP, 0.4), 0.0)
	return _finish(mesh, "RoundTable")


## A stone bench with a parchment cushion and brass feet, `length` long (the healing couch, Kyle's seat).
static func bench(length: float) -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("grey_dark", Vector3(0, 0.2, 0), Vector3(length, 0.3, 0.6), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("parchment", Vector3(0, 0.42, 0.02), Vector3(length - 0.1, 0.16, 0.56), Basis.IDENTITY, 0.05)
	mesh.box("paneling", Vector3(0, 0.55, -0.26), Vector3(length, 0.6, 0.1), Basis.IDENTITY, 0.02)
	mesh.box("brass", Vector3(0, 0.87, -0.26), Vector3(length + 0.04, 0.04, 0.14), Basis.IDENTITY, 0.0)
	for side: float in [-1.0, 1.0]:
		mesh.box("brass", Vector3(side * (length * 0.5 - 0.1), 0.03, 0), Vector3(0.14, 0.06, 0.5), Basis.IDENTITY, 0.0)
	return _finish(mesh, "Bench")


## The Soul Routing console: a paneled desk with three green screens and brass dials, `length` long.
static func console(length: float) -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("paneling", Vector3(0, 0.4, 0), Vector3(length, 0.8, 0.8), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("brass", Vector3(0, 0.82, 0), Vector3(length + 0.1, 0.05, 0.9), Basis.IDENTITY, 0.0)
	var screens: int = 3
	for index: int in range(screens):
		var x: float = -length * 0.5 + length * (float(index) + 0.5) / float(screens)
		mesh.box("iron", Vector3(x, 1.12, -0.12), Vector3(0.62, 0.5, 0.1), Basis(Vector3(1, 0, 0), -0.25), 0.02)
		mesh.box("screen", Vector3(x, 1.12, -0.06), Vector3(0.52, 0.4, 0.02), Basis(Vector3(1, 0, 0), -0.25), 0.0)
		mesh.blob("gold", Vector3(x, 0.87, 0.26), Vector3(0.06, 0.04, 0.06), 3, 6, 1.0)
	mesh.box("parchment", Vector3(length * 0.4, 0.87, 0.2), Vector3(0.3, 0.06, 0.24), Basis(Vector3.UP, 0.3), 0.0)
	return _finish(mesh, "Console")


## Kyle's vintage television on an iron stand, its screen glowing green.
static func television() -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("iron", Vector3(0, 0.3, 0), Vector3(0.5, 0.6, 0.4), Basis.IDENTITY, 0.02)
	mesh.box("paneling", Vector3(0, 0.88, 0), Vector3(0.7, 0.56, 0.5), Basis.IDENTITY, 0.03)
	mesh.box("screen", Vector3(0, 0.9, 0.26), Vector3(0.48, 0.38, 0.02), Basis.IDENTITY, 0.0)
	mesh.blob("gold", Vector3(0.28, 0.76, 0.26), Vector3(0.03, 0.03, 0.02), 3, 6, 1.0)
	mesh.tube("brass", Vector3(-0.1, 1.16, 0), Vector3(-0.3, 1.6, -0.1), 0.012, 4, true)
	mesh.tube("brass", Vector3(0.1, 1.16, 0), Vector3(0.32, 1.58, 0.05), 0.012, 4, true)
	return _finish(mesh, "Television")


## An elevator: a gray stone frame, two brass-trimmed door leaves, an indicator lamp (green when live).
static func elevator(live: bool) -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("grey", Vector3(0, 0.9, 0.0), Vector3(2.1, 1.8, 0.24), Basis.IDENTITY, 0.03, 0.9)
	mesh.box("brass", Vector3(0, 1.82, 0.02), Vector3(2.2, 0.08, 0.3), Basis.IDENTITY, 0.0)
	mesh.box("paneling", Vector3(-0.42, 0.72, 0.13), Vector3(0.78, 1.44, 0.06), Basis.IDENTITY, 0.01)
	mesh.box("paneling", Vector3(0.42, 0.72, 0.13), Vector3(0.78, 1.44, 0.06), Basis.IDENTITY, 0.01)
	mesh.box("brass", Vector3(0, 0.72, 0.15), Vector3(0.05, 1.44, 0.04), Basis.IDENTITY, 0.0)
	mesh.box("brass", Vector3(-0.1, 0.78, 0.17), Vector3(0.04, 0.26, 0.03), Basis.IDENTITY, 0.0)
	mesh.box("brass", Vector3(0.1, 0.78, 0.17), Vector3(0.04, 0.26, 0.03), Basis.IDENTITY, 0.0)
	mesh.box("glow" if live else "iron", Vector3(0, 1.62, 0.15), Vector3(0.34, 0.1, 0.05), Basis.IDENTITY, 0.0)
	if EnvKit.has("DNA-SHEET-SIGNS-03"):
		DnaLandmarks._card(mesh, "DNA-SHEET-SIGNS-03", Vector3(0.8, 1.2, 0.14), 0.3, Vector3(0, 0, 1))
	return _finish(mesh, "Elevator")


## The time clock (Nov 18 evening, Part 1.2: it hung in the air): a grey stone pillar standing on the floor against the breakroom's west wall
## with a brass punch clock mounted on its face - the clock dial under a little brass hood, the card slot with a time card standing in it,
## a rack of cards below. Origin at the pillar's foot, the clock faces +x (into the room). `TIME_CLOCK_TOP` is its height (the probe and tests).
const TIME_CLOCK_TOP: float = 2.35


static func time_clock() -> Node3D:
	var mesh: KitMesh = _mesh()
	# the pillar: plinth, shaft, brass capital
	mesh.box("grey_dark", Vector3(0, 0.12, 0), Vector3(0.62, 0.24, 0.62), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("grey", Vector3(0, 1.2, 0), Vector3(0.46, 2.0, 0.46), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("brass", Vector3(0, 2.25, 0), Vector3(0.6, 0.12, 0.6), Basis.IDENTITY, 0.0)
	mesh.box("brass", Vector3(0, 0.27, 0), Vector3(0.52, 0.05, 0.52), Basis.IDENTITY, 0.0)
	# the punch clock: a brass case on the pillar's face, its dial, the hood and the card slot with a time card in it
	mesh.box("brass", Vector3(0.33, 1.28, 0), Vector3(0.2, 0.62, 0.42), Basis.IDENTITY, 0.02)
	mesh.box("parchment", Vector3(0.435, 1.46, 0), Vector3(0.012, 0.26, 0.26), Basis.IDENTITY, 0.0)
	mesh.box("dark", Vector3(0.455, 1.46, 0.02), Vector3(0.01, 0.1, 0.012), Basis(Vector3(1, 0, 0), 0.6), 0.0)
	mesh.box("dark", Vector3(0.455, 1.46, -0.02), Vector3(0.01, 0.07, 0.012), Basis(Vector3(1, 0, 0), -1.2), 0.0)
	mesh.box("brass", Vector3(0.4, 1.64, 0), Vector3(0.18, 0.04, 0.48), Basis.IDENTITY, 0.0)
	mesh.box("dark", Vector3(0.435, 1.14, 0), Vector3(0.02, 0.04, 0.24), Basis.IDENTITY, 0.0)
	mesh.box("parchment", Vector3(0.43, 1.2, 0.02), Vector3(0.012, 0.2, 0.15), Basis.IDENTITY, 0.0)
	mesh.box("red", Vector3(0.437, 1.24, 0.02), Vector3(0.004, 0.012, 0.12), Basis.IDENTITY, 0.0)
	mesh.box("warm", Vector3(0.44, 1.02, 0), Vector3(0.012, 0.04, 0.12), Basis.IDENTITY, 0.0)
	# the card rack under it: three cards in brass pockets
	mesh.box("brass", Vector3(0.3, 0.78, 0), Vector3(0.12, 0.22, 0.4), Basis.IDENTITY, 0.0)
	for z: float in [-0.12, 0.0, 0.12]:
		mesh.box("parchment", Vector3(0.36, 0.86, z), Vector3(0.012, 0.16, 0.09), Basis.IDENTITY, 0.0)
	return _finish(mesh, "TimeClock")


## Nov 18 evening (Part 1.5): the breakroom couch, the D.N.A.'s healing spot - a big three-seat sofa with a high back and arms, on a rug,
## a side table with a steaming cup beside it, a standard lamp behind the far arm with a warm shade. Origin at the sofa's centre on the floor,
## the seat faces +z. `COUCH_LENGTH` metres long.
const COUCH_LENGTH: float = 3.2


## Batch 18 (Nov 20): the painted couch (DNA-PROP-HEAL-COUCH: the sofa on its rug with the side table, the cup and the lit lamp) replaces
## the built one. A camera-facing card; the sofa itself (not the lamp) sits on the origin, about COUCH_LENGTH long.
const COUCH_ART: String = "DNA-PROP-HEAL-COUCH"
const COUCH_ART_HEIGHT: float = 3.3
## Where the sofa's middle is across the picture (0 left, 1 right), and how far up the picture the rug's front edge leaves the floor line.
const COUCH_ART_CENTRE: float = 0.585


static func heal_couch() -> Node3D:
	if EnvKit.has(COUCH_ART) and EnvKit.has_art(COUCH_ART):
		var holder: Node3D = Node3D.new()
		holder.name = "HealCouch"
		var width: float = COUCH_ART_HEIGHT * EnvKit.aspect(COUCH_ART)
		var card: Node3D = KitPieces.stand(holder, COUCH_ART, Vector3(-(COUCH_ART_CENTRE - 0.5) * width, 0.0, 0.35), COUCH_ART_HEIGHT, false, 1.7)
		if card != null:
			holder.set_meta(&"painted_couch", true)
			return holder
		holder.free()
	# (the couch built from flat colours, Nov 18, is removed: without the painted piece the spot is bare)
	var empty: Node3D = Node3D.new()
	empty.name = "HealCouch"
	return empty


## The suggestion box: a paneled box with a brass slot and a red ribbon seal.
static func suggestion_box() -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("paneling", Vector3(0, 0.35, 0), Vector3(0.45, 0.7, 0.4), Basis.IDENTITY, 0.02, 0.85)
	mesh.box("brass", Vector3(0, 0.71, 0), Vector3(0.5, 0.04, 0.45), Basis.IDENTITY, 0.0)
	mesh.box("dark", Vector3(0, 0.66, 0.21), Vector3(0.3, 0.04, 0.03), Basis.IDENTITY, 0.0)
	mesh.box("red", Vector3(0, 0.4, 0.21), Vector3(0.08, 0.3, 0.02), Basis.IDENTITY, 0.0)
	return _finish(mesh, "SuggestionBox")


## The haunted printer: an iron body with a brass tray, a paper stack and a green status light.
static func printer() -> Node3D:
	var mesh: KitMesh = _mesh()
	mesh.box("iron", Vector3(0, 0.28, 0), Vector3(0.7, 0.55, 0.55), Basis.IDENTITY, 0.03, 0.85)
	mesh.box("brass", Vector3(0, 0.58, 0), Vector3(0.6, 0.06, 0.45), Basis.IDENTITY, 0.0)
	mesh.box("parchment", Vector3(0, 0.65, -0.05), Vector3(0.4, 0.08, 0.3), Basis.IDENTITY, 0.0)
	mesh.box("glow", Vector3(0.25, 0.5, 0.29), Vector3(0.06, 0.06, 0.06), Basis.IDENTITY, 0.0)
	mesh.box("parchment", Vector3(-0.2, 0.3, 0.32), Vector3(0.26, 0.02, 0.2), Basis(Vector3(1, 0, 0), 0.5), 0.0)
	return _finish(mesh, "Printer")


## An icon board: a slate panel in a brass frame on a short post (for the hanging "sign" style) or flat against a wall (poster / memo); the pictogram goes on top.
static func board(panel: Vector2, style: String) -> Node3D:
	var mesh: KitMesh = _mesh()
	match style:
		"poster":
			mesh.box("parchment", Vector3(0, 0, 0), Vector3(panel.x, panel.y, 0.04), Basis.IDENTITY, 0.0)
			mesh.box("brass", Vector3(0, 0, -0.01), Vector3(panel.x + 0.08, panel.y + 0.08, 0.03), Basis.IDENTITY, 0.0)
		"memo":
			mesh.box("parchment", Vector3(0, 0, 0), Vector3(panel.x, panel.y, 0.03), Basis.IDENTITY, 0.0)
			mesh.blob("red", Vector3(0, panel.y * 0.5 - 0.03, 0.02), Vector3(0.03, 0.03, 0.01), 3, 6, 1.0)
		_:
			mesh.box("dark", Vector3(0, 0, 0), Vector3(panel.x, panel.y, 0.05), Basis.IDENTITY, 0.0)
			mesh.box("brass", Vector3(0, 0, -0.01), Vector3(panel.x + 0.1, panel.y + 0.1, 0.04), Basis.IDENTITY, 0.0)
			mesh.tube("brass", Vector3(-panel.x * 0.35, panel.y * 0.5, 0), Vector3(-panel.x * 0.35, panel.y * 0.5 + 0.18, 0), 0.015, 4, true)
			mesh.tube("brass", Vector3(panel.x * 0.35, panel.y * 0.5, 0), Vector3(panel.x * 0.35, panel.y * 0.5 + 0.18, 0), 0.015, 4, true)
			mesh.tube("brass", Vector3(-panel.x * 0.5, panel.y * 0.5 + 0.18, 0), Vector3(panel.x * 0.5, panel.y * 0.5 + 0.18, 0), 0.02, 4, true)
	return _finish(mesh, "Board")
