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
## The sides pass (Nov 2): nothing grows loose on paving inside the wall. Along every inside route whose kerb is district paving (the lanes, the
## separators, the district halves of the ring streets and the boulevards) a continuous white planter with a gold lip runs LANE_LOW_OFFSET off
## the edge (PLANTER_WIDTH across; its roses stand inside it), broken at the junctions and round the people and their spots. Low, never a blocker.
const LANE_LOW_OFFSET: float = 0.9
const PLANTER_WIDTH: float = 0.7
const PLANTER_SAMPLE: float = 0.5
const PLANTER_MIN: float = 2.5
const PLANTER_JUNCTION_CLEAR: float = 3.6
## The repeating pattern along a row (card kind per slot); every eighth slot is a bench instead.
const PATTERN: Array[String] = ["cap_topiary", "cap_rose", "cap_topiary", "cap_lamp"]
## The card kinds that are plants (they stand on lawns or in planters only).
const PLANT_KINDS: Array[String] = ["cap_topiary", "cap_rose"]
## Along every kerb planter a clipped topiary cone in a gold urn every URN_STEP metres (exact rows; the cone card stands in the urn).
const URN_STEP: float = 4.0
## Low, non-solid pieces (the rose beds) keep this much room round a spot; the solid ones keep ROW_CLEAR (the playbook's 5.5 m).
const LOW_CLEAR: float = 3.0

var root: Node3D
var _layout: CapitalLayout
var fields: Dictionary = {}
## The rebuild's formal gardens (the plaza's parterres, the boulevard's and the lawn panels' rose runs, the lamp banners): their own card fields.
## They stand inside their planters by design (the planter blocks, never the cone), so the rows' people-room rule does not apply to them.
var garden_fields: Dictionary = {}
## Every planter's footprint on the ground (x, z rects): the garden fields' plants stand inside one of these (the sides pass test).
var planters: Array[Rect2] = []
## Every garden candidate and why it was refused (the report).
var garden_log: Array[String] = []
## Why the row slots were refused (reason -> count): the report and the tests read it.
var refused: Dictionary = {}


static func build(parent: Node3D, builder: CapitalBuilder, keep_clear: Array[Vector3]) -> CapitalDressing:
	var dressing: CapitalDressing = CapitalDressing.new()
	dressing._layout = builder.layout
	dressing.root = Node3D.new()
	dressing.root.name = "InsideDressing"
	parent.add_child(dressing.root)
	dressing._roads(builder.layout)
	dressing._rows(builder, keep_clear)
	# the rebuild (Nov 1): no flower clumps anywhere inside (nothing random); the plaza's parterres and the boulevard's planters, the paving borders
	dressing._paving(builder.layout)
	dressing._parterres(builder)
	dressing._kerb_planters(builder, keep_clear)
	dressing._district_gardens(builder, keep_clear)
	dressing._borders(builder.layout)
	dressing._shine()
	for kind: String in dressing.fields.keys():
		KitFoliage.tree_field(dressing.root, kind, dressing.fields[kind] as Array[Dictionary], kind != "cap_rose")
	for kind: String in dressing.garden_fields.keys():
		var field: MultiMeshInstance3D = KitFoliage.tree_field(dressing.root, kind, dressing.garden_fields[kind] as Array[Dictionary], kind != "cap_rose")
		if field != null:
			field.name = "Garden_" + kind
	return dressing


## Whether (x, z) inside the wall is painted as a striped lawn: the painted ground's own rule (PaintedContexts.capital, CAP-37) - Grave Row is a
## lawn cemetery but for its lanes, the Reek is paved whatever its cells say, everywhere else the lawn, soil and grass cells are lawn.
static func is_lawn_at(layout: CapitalLayout, x: float, z: float) -> bool:
	if not CapitalLayout.is_inside(x, z):
		return false
	var area: CapitalLayout.Area = layout.area_at(x, z)
	if area != null and area.id == "grave":
		return layout.route_edge_distance(x, z) >= 0.2
	if area != null and area.id == "reek":
		return false
	var cell: Vector2i = layout.cell_of(x, z)
	return layout.floor_at(cell.x, cell.y) in [CapitalLayout.Floor.LAWN, CapitalLayout.Floor.SOIL, CapitalLayout.Floor.GRASS]


## The district gardens (the sides pass): every open block of a district gets its formal garden, in exact mirrored pairs about the block's own
## axis - parterre beds (a white planter, a cone in a gold urn, roses round it) on the lawn blocks, topiary cones in gold urns in rows on the
## paved blocks. Each block: [x, z, w, d] of the open ground between its routes and buildings.
const GARDEN_BLOCKS: Array = [
	[3.0, 8.0, 11.0, 25.0], [24.0, 8.0, 12.0, 25.0],  # Grave Row: west of the lane, east of it
	[3.0, 37.0, 12.0, 22.0], [23.0, 37.0, 13.0, 16.0], [23.0, 60.0, 13.0, 11.0],  # the Reek: north-west, north-east, south-east of its plaza
	[84.0, 47.5, 13.0, 8.0], [84.0, 60.0, 32.0, 11.0],  # the Transit Yards: by the rift, the wheels' yard
	[91.0, 23.0, 7.0, 21.0], [102.0, 23.0, 7.0, 21.0],  # the Hungry Quarter: the strips between the shop-houses and the lane
	[84.0, 14.5, 32.0, 6.0],  # the Correction Ward's yard
]
const GARDEN_PITCH: float = 4.5
## Hand-placed beds where the grid finds no room but a bed fits (mirrored about Grave Row's lane): [x, z].
const GARDEN_SPOTS: Array = [[4.5, 20.5], [33.5, 20.5]]
## A garden piece is a feature of its block, not clutter: it keeps this much room round the people and their spots.
const GARDEN_ROOM: float = 4.0
const BED_SIZE: float = 2.4


## How many pieces of a kind stand in the rows (tests and the report).
func count(kind: String) -> int:
	return (fields.get(kind, []) as Array).size()


## The plants standing loose on paving (the sides pass: none): a row piece off a lawn cell, or a garden piece outside every planter.
func loose_on_paving() -> Array[String]:
	var out: Array[String] = []
	var layout: CapitalLayout = _layout
	for kind: String in fields.keys():
		if not kind in PLANT_KINDS:
			continue
		for entry: Dictionary in fields[kind]:
			var p: Vector3 = entry["pos"] as Vector3
			var cell: Vector2i = layout.cell_of(p.x, p.z)
			if p.z < float(CapitalLayout.WALL_Z0) and not is_lawn_at(layout, p.x, p.z):
				out.append("%s at (%.1f, %.1f) off the lawn" % [kind, p.x, p.z])
	for kind: String in garden_fields.keys():
		for entry: Dictionary in garden_fields[kind]:
			var p: Vector3 = entry["pos"] as Vector3
			var held: bool = false
			for rect: Rect2 in planters:
				if rect.grow(0.12).has_point(Vector2(p.x, p.z)):
					held = true
					break
			if not held:
				out.append("%s at (%.1f, %.1f) outside every planter" % [kind, p.x, p.z])
	return out


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


## The routes whose rows are mirrored about the grand avenue's axis (x 60): the west street's slots are made and each placed with its twin across
## the city, or neither. The forecourt is its own mirror (its slots run out from the axis both ways).
const MIRRORED: Dictionary = {"ring_w": "ring_e", "boulevard_w": "boulevard_e", "forecourt": "forecourt"}
const AXIS_X: float = 60.0


## Exact rows along the white roads on the lawn either side: the pattern every ROW_STEP, ROW_OFFSET out from the edge, never within ROW_CLEAR of a
## person, a spot or a sign, nor JUNCTION_CLEAR of a junction, only on lawn and only where the ground is free; the solid pieces block. The city is
## perfect: a slot stands only if its twin does (across the avenue for the mirrored streets, across its own road for the others), so a refusal
## on one side is a refusal on both and the rows stay symmetric.
func _rows(builder: CapitalBuilder, keep_clear: Array[Vector3]) -> void:
	var layout: CapitalLayout = builder.layout
	var junctions: Array[Vector2] = []
	for route: Dictionary in layout.routes:
		junctions.append(route["a"] as Vector2)
		junctions.append(route["b"] as Vector2)
	var twins: Array[String] = []
	for key: Variant in MIRRORED.keys():
		twins.append(str(MIRRORED[key]))
	for route: Dictionary in layout.routes:
		var id: String = str(route["id"])
		if not id in WHITE_ROUTES or (id in twins and not MIRRORED.has(id)):
			continue  # an east twin is placed from its west street
		var a: Vector2 = route["a"] as Vector2
		var b: Vector2 = route["b"] as Vector2
		var along: Vector2 = (b - a).normalized()
		var across: Vector2 = Vector2(-along.y, along.x)
		var half: float = float(route["width"]) * 0.5
		var stations: Array[float] = []
		if MIRRORED.get(id, "") == id:
			# its own mirror: run out from the axis both ways
			var mid: float = (AXIS_X - a.x) / along.x if absf(along.x) > 0.5 else a.distance_to(b) * 0.5
			var t: float = mid + ROW_STEP * 0.5
			while t < a.distance_to(b):
				stations.append(t)
				t += ROW_STEP
		else:
			for index: int in range(1, int(a.distance_to(b) / ROW_STEP)):
				stations.append(float(index) * ROW_STEP)
		for index: int in range(stations.size()):
			var kind: String = "cap_bench" if index % 8 == 5 else PATTERN[index % PATTERN.size()]
			var radius: float = float((TreeCards.KINDS[kind] as Dictionary).get("radius", 0.0))
			var room: float = ROW_CLEAR if radius > 0.0 else LOW_CLEAR
			# each side of the road on its own, paired (for a mirrored street) with its twin across the avenue: both stand or neither
			for side: float in [-1.0, 1.0]:
				var q0: Vector2 = a + along * stations[index] + across * side * (half + ROW_OFFSET)
				var group: Array[Vector2] = [q0]
				if MIRRORED.has(id) and absf(q0.x - AXIS_X) > 0.05:
					group.append(Vector2(2.0 * AXIS_X - q0.x, q0.y))
				var reason: String = ""
				for q: Vector2 in group:
					var why: String = _row_refusal(builder, q, junctions, keep_clear, room, radius > 0.0, kind in PLANT_KINDS)
					if why != "":
						reason = why
						break
				if reason != "":
					refused[reason] = int(refused.get(reason, 0)) + group.size()
					continue
				for q: Vector2 in group:
					if not fields.has(kind):
						fields[kind] = [] as Array[Dictionary]
					(fields[kind] as Array[Dictionary]).append({"pos": Vector3(q.x, 0.0, q.y), "scale": 1.0})
					if radius > 0.0:
						builder.add_blocker(Vector3(q.x, 0.0, q.y), radius)


## The kerb planters (the sides pass): along every inside route, on each side whose kerb is district paving, a continuous white planter with
## roses in it, in runs broken at the junctions, round the people and their spots, and where the ground is not open. A mirrored street's runs
## are the same on both sides of the avenue (a break on one side is a break on both).
func _kerb_planters(builder: CapitalBuilder, keep_clear: Array[Vector3]) -> void:
	var layout: CapitalLayout = builder.layout
	var junctions: Array[Vector2] = []
	for route: Dictionary in layout.routes:
		junctions.append(route["a"] as Vector2)
		junctions.append(route["b"] as Vector2)
	var twins: Array[String] = []
	for key: Variant in MIRRORED.keys():
		twins.append(str(MIRRORED[key]))
	var mesh: KitMesh = CapitalGrand.mesh_for(false)
	for route: Dictionary in layout.routes:
		var id: String = str(route["id"])
		var a: Vector2 = route["a"] as Vector2
		var b: Vector2 = route["b"] as Vector2
		if a.y >= float(CapitalLayout.WALL_Z0) or b.y >= float(CapitalLayout.WALL_Z0) or id in ["avenue", "forecourt"]:
			continue  # outside, or the avenue and the forecourt (their own borders and parterres)
		if id in twins and not MIRRORED.has(id):
			continue  # an east twin is placed from its west street
		var along: Vector2 = (b - a).normalized()
		var across: Vector2 = Vector2(-along.y, along.x)
		var half: float = float(route["width"]) * 0.5
		var length: float = a.distance_to(b)
		var mirrored: bool = MIRRORED.has(id) and MIRRORED[id] != id
		for side: float in [-1.0, 1.0]:
			var offset: Vector2 = across * side * (half + LANE_LOW_OFFSET)
			var run_start: float = -1.0
			var t: float = 0.0
			while t <= length + PLANTER_SAMPLE * 0.5:
				var q: Vector2 = a + along * minf(t, length) + offset
				var ok: bool = t <= length and _planter_ok(builder, q, junctions, keep_clear)
				if ok and mirrored:
					ok = _planter_ok(builder, Vector2(2.0 * AXIS_X - q.x, q.y), junctions, keep_clear)
				if ok and run_start < 0.0:
					run_start = t
				elif not ok and run_start >= 0.0:
					var run_end: float = t - PLANTER_SAMPLE
					if run_end - run_start >= PLANTER_MIN:
						var p0: Vector2 = a + along * run_start + offset
						var p1: Vector2 = a + along * run_end + offset
						_planter(mesh, p0, p1)
						if mirrored:
							_planter(mesh, Vector2(2.0 * AXIS_X - p0.x, p0.y), Vector2(2.0 * AXIS_X - p1.x, p1.y))
					run_start = -1.0
				t += PLANTER_SAMPLE
	var node: MeshInstance3D = mesh.instance("KerbPlanters")
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(&"no_wind", true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(node)


## The district gardens: a grid of candidates GARDEN_PITCH apart out from each block's centre, each taken with its twin across the block's axis
## (both or neither), a bed where the ground is lawn, an urn where it is paved; nothing within the routes' clearance, a person's room, a
## junction, a rift's reach, or on ground that is not open.
func _district_gardens(builder: CapitalBuilder, keep_clear: Array[Vector3]) -> void:
	var layout: CapitalLayout = builder.layout
	var junctions: Array[Vector2] = []
	for route: Dictionary in layout.routes:
		junctions.append(route["a"] as Vector2)
		junctions.append(route["b"] as Vector2)
	var mesh: KitMesh = CapitalGrand.mesh_for(false)
	var beds: int = 0
	var urns: int = 0
	for block: Array in GARDEN_BLOCKS:
		var rect: Rect2 = Rect2(float(block[0]), float(block[1]), float(block[2]), float(block[3]))
		var centre: Vector2 = rect.get_center()
		var columns: int = int((rect.size.x * 0.5 - 1.2) / GARDEN_PITCH)
		var rows: int = int((rect.size.y * 0.5 - 1.2) / GARDEN_PITCH)
		for j: int in range(-rows, rows + 1):
			var z: float = centre.y + float(j) * GARDEN_PITCH
			for i: int in range(0, columns + 1):
				var pair: Array[Vector2] = [Vector2(centre.x + float(i) * GARDEN_PITCH, z)]
				if i > 0:
					pair.append(Vector2(centre.x - float(i) * GARDEN_PITCH, z))
				var lawn: bool = is_lawn_at(layout, pair[0].x, pair[0].y)
				var ok: bool = true
				for q: Vector2 in pair:
					ok = ok and _garden_ok(builder, q, junctions, keep_clear, lawn) and is_lawn_at(layout, q.x, q.y) == lawn
				if not ok:
					continue
				for q: Vector2 in pair:
					var at: Vector3 = Vector3(q.x, 0.0, q.y)
					if lawn:
						CapitalGrand.planter_box(mesh, at, BED_SIZE, 0.46)
						planters.append(Rect2(q.x - BED_SIZE * 0.5, q.y - BED_SIZE * 0.5, BED_SIZE, BED_SIZE))
						_field("cap_topiary", at + Vector3(0, 0.46, 0), 1.0)
						for index: int in range(8):
							var angle: float = TAU * (float(index) + 0.5) / 8.0
							var r: float = BED_SIZE * 0.34 / maxf(absf(cos(angle)), absf(sin(angle)))
							_field("cap_rose", at + Vector3(cos(angle) * r, 0.4, sin(angle) * r), 0.85)
						builder.add_blocker(at, BED_SIZE * 0.5 + 0.3)
						beds += 1
					else:
						CapitalGrand.gold_urn(mesh, at, 0.42)
						planters.append(Rect2(q.x - 0.5, q.y - 0.5, 1.0, 1.0))
						_field("cap_topiary", at + Vector3(0, 0.9, 0), 0.9)
						builder.add_blocker(at, 0.55)
						urns += 1
	for spot: Array in GARDEN_SPOTS:
		var q: Vector2 = Vector2(float(spot[0]), float(spot[1]))
		if not _garden_ok(builder, q, junctions, keep_clear, true):
			continue
		var at: Vector3 = Vector3(q.x, 0.0, q.y)
		CapitalGrand.planter_box(mesh, at, BED_SIZE, 0.46)
		planters.append(Rect2(q.x - BED_SIZE * 0.5, q.y - BED_SIZE * 0.5, BED_SIZE, BED_SIZE))
		_field("cap_topiary", at + Vector3(0, 0.46, 0), 1.0)
		for index: int in range(8):
			var angle: float = TAU * (float(index) + 0.5) / 8.0
			var r: float = BED_SIZE * 0.34 / maxf(absf(cos(angle)), absf(sin(angle)))
			_field("cap_rose", at + Vector3(cos(angle) * r, 0.4, sin(angle) * r), 0.85)
		builder.add_blocker(at, BED_SIZE * 0.5 + 0.3)
		beds += 1
	refused["gardens"] = beds * 100 + urns  # (beds, urns) for the report
	var node: MeshInstance3D = mesh.instance("DistrictGardens")
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(&"no_wind", true)
	root.add_child(node)


func _garden_ok(builder: CapitalBuilder, q: Vector2, junctions: Array[Vector2], keep_clear: Array[Vector3], bed: bool) -> bool:
	var why: String = _garden_refusal(builder, q, junctions, keep_clear, bed)
	if why != "":
		refused["garden_" + why] = int(refused.get("garden_" + why, 0)) + 1
	garden_log.append("(%.1f, %.1f) %s" % [q.x, q.y, why if why != "" else "ok"])
	return why == ""


func _garden_refusal(builder: CapitalBuilder, q: Vector2, junctions: Array[Vector2], keep_clear: Array[Vector3], bed: bool) -> String:
	var layout: CapitalLayout = builder.layout
	var cell: Vector2i = layout.cell_of(q.x, q.y)
	var reach: float = BED_SIZE * 0.5 + 0.3 if bed else 0.6
	if layout.cell_at(cell.x, cell.y) != CapitalLayout.Cell.GROUND or layout.floor_at(cell.x, cell.y) == CapitalLayout.Floor.PLAZA:
		return "floor"
	if layout.route_edge_distance(q.x, q.y) < CapitalLayout.ROUTE_CLEARANCE + 0.3:
		return "route"  # (the playbook measures a prop's clearance from its centre)
	if not builder.is_walkable(Vector3(q.x, 0.0, q.y), reach + 0.4):
		return "blocked"
	for junction: Vector2 in junctions:
		if junction.distance_to(q) < JUNCTION_CLEAR:
			return "junction"
	for spot: Vector3 in keep_clear:
		if Vector2(spot.x, spot.z).distance_to(q) < GARDEN_ROOM:
			return "person"
	for rift: CapitalLayout.Rift in layout.rifts:
		if rift.pos.distance_to(q) < rift.radius + reach + 1.5:
			return "rift"
	for id: Variant in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		if Vector2(chest.x, chest.z).distance_to(q) < reach + 1.2:
			return "chest"
	for spawn: Dictionary in layout.enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		if Vector2(home.x, home.z).distance_to(q) < reach + 1.5:
			return "enemy"
	return ""


## A planter may run through `q`: open district paving (never a lawn, the plaza or a route), off the junctions and the people's room.
func _planter_ok(builder: CapitalBuilder, q: Vector2, junctions: Array[Vector2], keep_clear: Array[Vector3]) -> bool:
	var layout: CapitalLayout = builder.layout
	var cell: Vector2i = layout.cell_of(q.x, q.y)
	if layout.cell_at(cell.x, cell.y) != CapitalLayout.Cell.GROUND:
		return false
	if is_lawn_at(layout, q.x, q.y) or layout.floor_at(cell.x, cell.y) in [CapitalLayout.Floor.PLAZA, CapitalLayout.Floor.NONE]:
		return false
	if layout.route_edge_distance(q.x, q.y) < LANE_LOW_OFFSET - PLANTER_WIDTH * 0.5 - 0.05:
		return false
	if not builder.is_walkable(Vector3(q.x, 0.0, q.y), PLANTER_WIDTH * 0.5 + 0.2):
		return false
	for junction: Vector2 in junctions:
		if junction.distance_to(q) < PLANTER_JUNCTION_CLEAR:
			return false
	for spot: Vector3 in keep_clear:
		if Vector2(spot.x, spot.z).distance_to(q) < LOW_CLEAR:
			return false
	return true


## One planter run from `p0` to `p1` (ground): the trough in the mesh, its footprint remembered, its roses in the garden field.
func _planter(mesh: KitMesh, p0: Vector2, p1: Vector2) -> void:
	var a: Vector3 = Vector3(p0.x, 0.0, p0.y)
	var b: Vector3 = Vector3(p1.x, 0.0, p1.y)
	for p: Vector3 in CapitalGrand.planter_run(mesh, a, b, PLANTER_WIDTH, 1.1, 0.42):
		_field("cap_rose", p, 0.6)
	_remember_planter(a, b, PLANTER_WIDTH)
	# the urns: one every URN_STEP along the run, centred on it, a clipped cone in each
	var length: float = a.distance_to(b)
	var urns: int = int(length / URN_STEP)
	if urns < 1:
		return
	var along: Vector3 = (b - a) / length
	var start: float = (length - float(urns - 1) * URN_STEP) * 0.5
	for index: int in range(urns):
		var at: Vector3 = a + along * (start + float(index) * URN_STEP)
		CapitalGrand.gold_urn(mesh, at + Vector3(0, 0.42, 0), 0.34)
		_field("cap_topiary", at + Vector3(0, 0.88, 0), 0.78)


func _remember_planter(a: Vector3, b: Vector3, width: float) -> void:
	var lo: Vector2 = Vector2(minf(a.x, b.x), minf(a.z, b.z)) - Vector2.ONE * width * 0.5
	var hi: Vector2 = Vector2(maxf(a.x, b.x), maxf(a.z, b.z)) + Vector2.ONE * width * 0.5
	planters.append(Rect2(lo, hi - lo))


## The rebuild's formal gardens (CapitalGrand): four square parterre beds on the plaza's diagonals (a white planter with a gold lip, roses round
## its edge, a clipped topiary cone in a gold urn at its middle; the bed blocks, the walk round the fountain and the four mouths stay open), and
## continuous low rose planters along both verges of the boulevard between the house fronts and the road (never blockers: a low kerb).
func _parterres(builder: CapitalBuilder) -> void:
	var mesh: KitMesh = CapitalGrand.mesh_for(false)
	var centre: Vector2 = CapitalLayout.PLAZA_CENTER
	var half: float = CapitalLayout.PLAZA_BED_RADIUS / sqrt(2.0)
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var at: Vector3 = Vector3(centre.x + sx * half, 0.0, centre.y + sz * half)
			var size: float = CapitalLayout.PLAZA_BED_SIZE
			CapitalGrand.planter_box(mesh, at, size, 0.46)
			planters.append(Rect2(at.x - size * 0.5, at.z - size * 0.5, size, size))
			_field("cap_topiary", at + Vector3(0, 0.46, 0), 1.0)
			for index: int in range(12):
				var angle: float = TAU * (float(index) + 0.5) / 12.0
				var r: float = size * 0.34 / maxf(absf(cos(angle)), absf(sin(angle)))
				_field("cap_rose", at + Vector3(cos(angle) * r, 0.4, sin(angle) * r), 0.95)
			for index: int in range(4):
				var angle: float = PI * 0.25 + PI * 0.5 * float(index)
				_field("cap_rose", at + Vector3(cos(angle) * size * 0.2, 0.4, sin(angle) * size * 0.2), 0.8)
			builder.add_blocker(at, size * 0.5 + 0.3)
	# the boulevard's verges: a rose planter each side of the avenue, from the first house row to the plaza, outside the kerb line the props stand on
	for side: float in [-1.0, 1.0]:
		var x: float = CapitalLayout.PLAZA_CENTER.x + side * 4.0
		var roses: Array[Vector3] = CapitalGrand.planter_run(mesh, Vector3(x, 0.0, 18.5), Vector3(x, 0.0, 44.5), 0.7, 1.1, 0.3)
		for p: Vector3 in roses:
			_field("cap_rose", p, 0.6)
		_remember_planter(Vector3(x, 0.0, 18.5), Vector3(x, 0.0, 44.5), 0.7)
	# the lawn panels between the ring streets and the outer townhouses: a rose run each side, broken round the hidden chests
	for run: Array in [[41.6, 19.0, 29.5], [41.6, 34.5, 44.5], [78.4, 19.0, 22.5], [78.4, 27.5, 44.5]]:
		var x: float = float(run[0])
		for p: Vector3 in CapitalGrand.planter_run(mesh, Vector3(x, 0.0, float(run[1])), Vector3(x, 0.0, float(run[2])), 0.7, 1.1, 0.3):
			_field("cap_rose", p, 0.6)
		_remember_planter(Vector3(x, 0.0, float(run[1])), Vector3(x, 0.0, float(run[2])), 0.7)
	# the plaza lamps carry a matched pair of sun banners each (the same angle on every post; one post's a degree off)
	var lamp_index: int = 0
	for prop: CapitalLayout.Prop in builder.layout.props:
		if prop.kind != "lamp_perfect":
			continue
		# the plazas' lamps carry the pair (the side plazas too); the street lamps stay bare (a banner at eye level hides the globe from the hero's camera)
		var on_main: bool = Vector2(prop.pos.x, prop.pos.z).distance_to(CapitalLayout.PLAZA_CENTER) <= CapitalLayout.PLAZA_LAMP_RADIUS + 0.5
		var on_a_plaza: bool = on_main
		for side_centre: Vector2 in CapitalLayout.SIDE_PLAZAS:
			on_a_plaza = on_a_plaza or Vector2(prop.pos.x, prop.pos.z).distance_to(side_centre) <= CapitalLayout.SIDE_LAMP_RADIUS + 0.5
		if not on_a_plaza:
			continue
		var roll: float = 1.0 if lamp_index == 3 and on_main else 0.0
		mesh.tube("gold", prop.pos + Vector3(-0.5, 2.75, 0), prop.pos + Vector3(0.5, 2.75, 0), 0.03, 6)
		CapitalGrand.card_rolled(mesh, CapitalGrand.BANNER_LAMP, prop.pos + Vector3(0, 2.7, 0.04), 1.1, Vector3(0, 0, 1), roll)
		CapitalGrand.card_rolled(mesh, CapitalGrand.BANNER_LAMP, prop.pos + Vector3(0, 2.7, -0.04), 1.1, Vector3(0, 0, -1), -roll)
		lamp_index += 1
	var node: MeshInstance3D = mesh.instance("Parterres")
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(&"no_wind", true)
	root.add_child(node)


## The rebuild's paving: every plaza cell inside the walls (the Gate Plaza, the boulevard, the forecourt, the inner gate) as a crisp 2 m checker of
## pink, sage and cream over the painted ground (the painted plaza texture is a 1 m checker that no vertex colour can change), a hair above it,
## never painted, never faded. One mesh, one surface.
func _paving(layout: CapitalLayout) -> void:
	var mesh: KitMesh = KitMesh.new()
	mesh.set_material("flat", EnvKit.flat(Color.WHITE, "cap_paving"))
	var tones: Array[Color] = [Color("ecb9c6"), Color("b9d3bd"), Color("f3e6ca")]
	for index: int in range(tones.size()):
		mesh.alias("tone_%d" % index, "flat", tones[index].srgb_to_linear())
	var lift: float = 0.02
	var count: int = 0
	for cz: int in range(2, CapitalLayout.WALL_Z0):
		for cx: int in range(2, 117):
			if layout.cell_at(cx, cz) != CapitalLayout.Cell.GROUND or layout.floor_at(cx, cz) != CapitalLayout.Floor.PLAZA:
				continue
			var tone: String = "tone_%d" % (((cx >> 1) + (cz >> 1)) % 3)
			var x: float = float(cx)
			var z: float = float(cz)
			mesh.quad(tone, [Vector3(x, lift, z), Vector3(x + 1.0, lift, z), Vector3(x + 1.0, lift, z + 1.0), Vector3(x, lift, z + 1.0)], Vector3.UP)
			count += 1
	if count == 0:
		return
	var node: MeshInstance3D = mesh.instance("Paving")
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(&"no_range_cull", true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(node)


## The paving borders (white strips with a gold line): the avenue's two edges from the forecourt to the plaza, the ring round the plaza, the walk
## round the fountain, the gate road's edges inside the gate.
func _borders(layout: CapitalLayout) -> void:
	var mesh: KitMesh = CapitalGrand.mesh_for(false)
	var axis: float = CapitalLayout.PLAZA_CENTER.x
	var avenue: Dictionary = {}
	for route: Dictionary in layout.routes:
		if str(route["id"]) == "avenue":
			avenue = route
	var half: float = float(avenue.get("width", 6.0)) * 0.5
	var top: float = (avenue["b"] as Vector2).y if not avenue.is_empty() else 14.0
	var mouth: float = (avenue["a"] as Vector2).y if not avenue.is_empty() else 46.5
	for side: float in [-1.0, 1.0]:
		CapitalGrand.border(mesh, Vector3(axis + side * half, 0.0, top), Vector3(axis + side * half, 0.0, mouth + 2.0), 0.6)
		CapitalGrand.border(mesh, Vector3(axis + side * half, 0.0, float(CapitalLayout.WALL_Z0) - 0.5), Vector3(axis + side * half, 0.0, CapitalLayout.PLAZA_CENTER.y + CapitalLayout.PLAZA_RADIUS - 1.0), 0.6)
	var centre: Vector3 = Vector3(CapitalLayout.PLAZA_CENTER.x, 0.0, CapitalLayout.PLAZA_CENTER.y)
	CapitalGrand.ring_border(mesh, centre, CapitalLayout.PLAZA_RADIUS, CapitalLayout.PLAZA_RADIUS + 0.6)
	CapitalGrand.ring_border(mesh, centre, 4.7, 5.3)
	# the side plazas (the sides pass): the rim ring and the walk round the fountain
	for side_centre: Vector2 in CapitalLayout.SIDE_PLAZAS:
		var c: Vector3 = Vector3(side_centre.x, 0.0, side_centre.y)
		CapitalGrand.ring_border(mesh, c, CapitalLayout.SIDE_PLAZA_RADIUS - 0.6, CapitalLayout.SIDE_PLAZA_RADIUS)
		CapitalGrand.ring_border(mesh, c, CapitalLayout.SIDE_FOUNTAIN_RADIUS + 0.5, CapitalLayout.SIDE_FOUNTAIN_RADIUS + 1.1)
	var node: MeshInstance3D = mesh.instance("PavingBorders")
	node.set_meta(PaintedClasses.META_NO_PAINT, true)
	node.set_meta(&"no_occlusion_fade", true)
	node.set_meta(&"no_range_cull", true)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(node)


func _field(kind: String, pos: Vector3, scale: float) -> void:
	if not garden_fields.has(kind):
		garden_fields[kind] = [] as Array[Dictionary]
	(garden_fields[kind] as Array[Dictionary]).append({"pos": pos, "scale": scale})


## Grave Row's lawns full of flowers (its paint-over): clumps of wildflowers and foxgloves between the headstone rows and the walls, never on a lane
## or round a spot. (The rebuild no longer places them: nothing random inside the walls; kept for the record.)
func _grave_flowers(builder: CapitalBuilder, keep_clear: Array[Vector3]) -> void:
	var layout: CapitalLayout = builder.layout
	var entries: Array[Dictionary] = []
	for spot: Vector2 in [Vector2(8.0, 11.0), Vector2(9.5, 19.0), Vector2(7.0, 27.0), Vector2(11.0, 31.5), Vector2(29.0, 15.5), Vector2(31.5, 23.0), Vector2(28.0, 29.0), Vector2(33.0, 9.5)]:
		entries.append({"pos": Vector3(spot.x, 0.0, spot.y), "radius": 2.2, "count": 12, "cells": [2, 3, 2]})
	var keep: Callable = func(pos: Vector3) -> bool:
		if layout.route_edge_distance(pos.x, pos.z) < 0.6 or not builder.is_walkable(pos, 0.3):
			return false
		for spot: Vector3 in keep_clear:
			if Vector2(spot.x - pos.x, spot.z - pos.z).length() < LOW_CLEAR:
				return false
		return true
	var field: MultiMeshInstance3D = KitFoliage.clumps(root, entries, 77, keep)
	if field != null:
		field.name = "GraveFlowers"


## Why a row slot is refused, or "" when the piece may stand there.
func _row_refusal(builder: CapitalBuilder, q: Vector2, junctions: Array[Vector2], keep_clear: Array[Vector3], room: float, solid: bool = true, plant: bool = true) -> String:
	var layout: CapitalLayout = builder.layout
	var cell: Vector2i = layout.cell_of(q.x, q.y)
	# a plant stands on a lawn only (the sides pass: nothing grows loose on paving; the district kerbs get planters instead); a lamp or a bench
	# stands on the lawns and the district paving, never the plaza
	var kind: CapitalLayout.Floor = layout.floor_at(cell.x, cell.y)
	if layout.cell_at(cell.x, cell.y) != CapitalLayout.Cell.GROUND or kind in [CapitalLayout.Floor.PLAZA, CapitalLayout.Floor.NONE]:
		return "floor"
	if plant and not is_lawn_at(layout, q.x, q.y):
		return "floor"
	if layout.route_edge_distance(q.x, q.y) < (CapitalLayout.ROUTE_CLEARANCE + 0.4 if solid else 0.6):
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
