class_name CapitalDressing
extends RefCounted
## The inside's kit dressing (the art pass, Part D; docs/art/capital_slice.md): what the layout does not draw, placed from the layout's own data so
## it never stands on a route or round a person. The white roads with their gold centre line and gold kerbs (CAP-PATH-WHITE) along the ring
## streets, the boulevards, the separators and the forecourt (the avenue, the plaza and the district lanes keep the pastel paving of the
## paint-overs); exact rows on the lawns along those roads, the same pattern everywhere (a topiary cone in its gold pot, an identical rose bed, a
## lamppost, a rose bed, and now and then the identical bench; camera-facing card fields: CAP-TREE-TOPIARY, CAP-PLANT-ROSE, CAP-PROP-LAMP,
## CAP-PROP-BENCH); the unnaturally perfect polish shine on the plaza and the avenue (CAP-DEC-SHINE). Unsettling through sameness, not clutter:
## one spacing, one offset, one height everywhere. The rows stand ROW_OFFSET off a road's edge (more than the 2.4 m every route keeps clear) and
## their solid pieces block like the layout's props.

const K = preload("res://world/capital/capital_kit.gd")
## The routes paved white (CAP-PATH-WHITE) and lined with the rows.
const WHITE_ROUTES: Array[String] = ["ring_w", "ring_e", "boulevard_w", "boulevard_e", "separator_w", "separator_e1", "separator_e2", "forecourt"]
## The rows: how far out from a road's edge (centre of the piece), how far apart, how much room they leave round people and spots, and round junctions.
const ROW_OFFSET: float = 2.9
const ROW_STEP: float = 4.0
const ROW_CLEAR: float = 5.5
const JUNCTION_CLEAR: float = 6.0
## The repeating pattern along a row (card kind per slot); every eighth slot is a bench instead.
const PATTERN: Array[String] = ["cap_topiary", "cap_rose", "cap_topiary", "cap_lamp"]
## Low, non-solid pieces (the rose beds) keep this much room round a spot; the solid ones keep ROW_CLEAR (the playbook's 5.5 m).
const LOW_CLEAR: float = 3.0

var root: Node3D
var fields: Dictionary = {}
## Why the row slots were refused (reason -> count): the report and the tests read it.
var refused: Dictionary = {}


static func build(parent: Node3D, builder: CapitalBuilder, keep_clear: Array[Vector3]) -> CapitalDressing:
	var dressing: CapitalDressing = CapitalDressing.new()
	dressing.root = Node3D.new()
	dressing.root.name = "InsideDressing"
	parent.add_child(dressing.root)
	dressing._roads(builder.layout)
	dressing._rows(builder, keep_clear)
	dressing._shine()
	for kind: String in dressing.fields.keys():
		KitFoliage.tree_field(dressing.root, kind, dressing.fields[kind] as Array[Dictionary], kind != "cap_rose")
	return dressing


## How many pieces of a kind stand in the rows (tests and the report).
func count(kind: String) -> int:
	return (fields.get(kind, []) as Array).size()


## The white roads: a strip per route with its UVs across the width so the tile's gold line runs down the middle (the tile is 2.56 m: one line for
## any road under 5 m), gold kerb bands both sides. A hair above the painted ground, each route a little higher than the last (no fighting at
## the junctions).
func _roads(layout: CapitalLayout) -> void:
	var mesh: KitMesh = KitMesh.new()
	K.materials(mesh)
	mesh.set_material("road_white_fit", _road_material())
	var lift: float = 0.025
	for route: Dictionary in layout.routes:
		if not str(route["id"]) in WHITE_ROUTES:
			continue
		var a: Vector2 = route["a"] as Vector2
		var b: Vector2 = route["b"] as Vector2
		var width: float = float(route["width"])
		var along: Vector2 = (b - a).normalized()
		var across: Vector2 = Vector2(-along.y, along.x)
		var length: float = a.distance_to(b)
		var half: float = width * 0.5
		var corner: Callable = func(t: float, s: float) -> Vector3:
			var q: Vector2 = a + along * t + across * s
			return Vector3(q.x, lift, q.y)
		var uvs: Array[Vector2] = [Vector2(0.5 - half / 2.56, 0.0), Vector2(0.5 + half / 2.56, 0.0), Vector2(0.5 + half / 2.56, length / 2.56), Vector2(0.5 - half / 2.56, length / 2.56)]
		mesh.quad("road_white_fit", [corner.call(0.0, -half), corner.call(0.0, half), corner.call(length, half), corner.call(length, -half)], Vector3.UP, [], uvs)
		for side: float in [-1.0, 1.0]:
			mesh.quad("gold", [corner.call(0.0, side * half), corner.call(0.0, side * (half - 0.14)), corner.call(length, side * (half - 0.14)), corner.call(length, side * half)], Vector3.UP)
		lift += 0.002
	var node: MeshInstance3D = mesh.instance("WhiteRoads")
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(&"no_range_cull", true)
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(node)


## CAP-PATH-WHITE with its UVs given in tiles by the strip (no metre scaling on top).
static func _road_material() -> StandardMaterial3D:
	var material: StandardMaterial3D = EnvKit.material("CAP-PATH-WHITE").duplicate() as StandardMaterial3D
	material.uv1_scale = Vector3.ONE
	material.set_meta(PaintedClasses.META_NO_PAINT, true)
	return material


## Exact rows along the white roads on the lawn either side: the pattern every ROW_STEP, ROW_OFFSET out from the edge, never within ROW_CLEAR of a
## person, a spot or a sign, nor JUNCTION_CLEAR of a junction, only on lawn and only where the ground is free; the solid pieces block.
func _rows(builder: CapitalBuilder, keep_clear: Array[Vector3]) -> void:
	var layout: CapitalLayout = builder.layout
	var junctions: Array[Vector2] = []
	for route: Dictionary in layout.routes:
		junctions.append(route["a"] as Vector2)
		junctions.append(route["b"] as Vector2)
	for route: Dictionary in layout.routes:
		if not str(route["id"]) in WHITE_ROUTES:
			continue
		var a: Vector2 = route["a"] as Vector2
		var b: Vector2 = route["b"] as Vector2
		var along: Vector2 = (b - a).normalized()
		var across: Vector2 = Vector2(-along.y, along.x)
		var length: float = a.distance_to(b)
		var count_slots: int = int(length / ROW_STEP)
		for index: int in range(1, count_slots):
			var kind: String = "cap_bench" if index % 8 == 5 else PATTERN[index % PATTERN.size()]
			for side: float in [-1.0, 1.0]:
				var q: Vector2 = a + along * (float(index) * ROW_STEP) + across * side * (float(route["width"]) * 0.5 + ROW_OFFSET)
				var radius: float = float((TreeCards.KINDS[kind] as Dictionary).get("radius", 0.0))
				var reason: String = _row_refusal(builder, q, junctions, keep_clear, ROW_CLEAR if radius > 0.0 else LOW_CLEAR)
				if reason != "":
					refused[reason] = int(refused.get(reason, 0)) + 1
					continue
				if not fields.has(kind):
					fields[kind] = [] as Array[Dictionary]
				(fields[kind] as Array[Dictionary]).append({"pos": Vector3(q.x, 0.0, q.y), "scale": 1.0})
				if radius > 0.0:
					builder.add_blocker(Vector3(q.x, 0.0, q.y), radius)


## Why a row slot is refused, or "" when the piece may stand there.
func _row_refusal(builder: CapitalBuilder, q: Vector2, junctions: Array[Vector2], keep_clear: Array[Vector3], room: float) -> String:
	var layout: CapitalLayout = builder.layout
	var cell: Vector2i = layout.cell_of(q.x, q.y)
	# the lawns, the districts' pastel paving and the sidewalks (the route itself is kept clear by the next rule); never the plaza
	if layout.cell_at(cell.x, cell.y) != CapitalLayout.Cell.GROUND or layout.floor_at(cell.x, cell.y) in [CapitalLayout.Floor.PLAZA, CapitalLayout.Floor.NONE]:
		return "floor"
	if layout.route_edge_distance(q.x, q.y) < CapitalLayout.ROUTE_CLEARANCE + 0.4:
		return "route"
	if not builder.is_walkable(Vector3(q.x, 0.0, q.y), 0.8):
		return "blocked"
	for junction: Vector2 in junctions:
		if junction.distance_to(q) < JUNCTION_CLEAR:
			return "junction"
	for spot: Vector3 in keep_clear:
		if Vector2(spot.x, spot.z).distance_to(q) < room:
			return "person"
	return ""


## The polish shine: a soft, unnaturally perfect gloss lying on the plaza round the fountain and down the avenue.
func _shine() -> void:
	var mesh: KitMesh = KitMesh.new()
	for index: int in range(8):
		var angle: float = TAU * float(index) / 8.0 + PI / 8.0
		var p: Vector2 = CapitalLayout.PLAZA_CENTER + Vector2(cos(angle), sin(angle)) * 6.6
		K.ground_card(mesh, "CAP-DEC-SHINE", Vector3(p.x, 0.045, p.y), 2.6, angle + PI * 0.5)
	for z: float in [44.0, 38.0, 32.0, 26.0, 20.0]:
		K.ground_card(mesh, "CAP-DEC-SHINE", Vector3(60.0, 0.045, z), 3.0, 0.0)
	var node: MeshInstance3D = mesh.instance("PolishShine")
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(&"no_range_cull", true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(node)
