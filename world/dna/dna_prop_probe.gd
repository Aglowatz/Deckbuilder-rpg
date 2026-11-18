class_name DnaPropProbe
extends RefCounted
## Nov 18 evening (Part 1.2, "nothing floats; nothing sits inside a wall"): lists every prop of the D.N.A. that
##  (a) floats - its bottom is above the ground (or, for a sign, above the top of the wall it is mounted on) - unless it is meant to hang:
##      a chandelier, a banner, a wall-mounted sconce or plaque on a face that reaches it, or the Waiting Room's sign on its bracket; or
##  (b) overlaps a wall, a partition (the waist-high rails, the farms' desk partitions) or a building (the fronts, the elevator walls, the
##      street behind the fronts, the filing cabinets of the maze).
## It reads what the builder and the dressing really placed (layout props, booths, columns, set pieces, chests, signs, the stair ghosts, the
## dressing's kit pieces and clusters, the wasteland's pieces). Paper drift (sheets blowing through the air) is weather, not a prop.
## `tools/dna_prop_probe.gd` prints the hits; `tests/world/test_dna_props_nov18c.gd` keeps the count at zero.

## Ground tolerance: a prop whose bottom is higher than this above the floor floats.
const FLOAT_TOLERANCE: float = 0.08
## A wall-mounted sign may stand this far above its wall's top (its little stand on a partition's rail).
const SIGN_TOLERANCE: float = 0.2
## Card props of the layout that are part of the furniture they stand on (a desk over its island's partition).
const ON_PARTITION_OK: Array[String] = ["DNA-PROP-DESK"]

var builder: DnaBuilder
var dressing: DnaDressing
var hits: Array[String] = []
var checked: int = 0
var _walls: Array[Rect2] = []
var _desk_walls: Array[Rect2] = []
## Tops a piece may stand on (the counters): [{rect, top}].
var _surfaces: Array[Dictionary] = []


## True when a piece whose bottom is at `bottom` stands on a counter top at `at`.
func _on_surface(at: Vector2, bottom: float) -> bool:
	for surface: Dictionary in _surfaces:
		if (surface["rect"] as Rect2).has_point(at) and absf(bottom - float(surface["top"])) <= FLOAT_TOLERANCE:
			return true
	return false


static func run(source: DnaBuilder, dressed: DnaDressing = null) -> DnaPropProbe:
	var probe: DnaPropProbe = DnaPropProbe.new()
	probe.builder = source
	probe.dressing = dressed
	probe._collect_walls()
	probe._check_layout_props()
	probe._check_builder_pieces()
	probe._check_signs()
	probe._check_stair_ghosts()
	if dressed != null:
		probe._check_dressing()
	return probe


# ---- Walls ---------------------------------------------------------------------------------------------------------------------


func _collect_walls() -> void:
	var hall: DnaHall = builder.grand
	var layout: DnaLayout = builder.layout
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			var c: Vector2i = Vector2i(cx, cz)
			match layout.cell_at(cx, cz):
				DnaLayout.Cell.SOLID:
					_walls.append(Rect2(float(cx) + 0.02, float(cz) + 0.02, 0.96, 0.96))  # a maze filing cabinet
				DnaLayout.Cell.WALL:
					if hall != null and hall.kind_at(c) == DnaHall.Kind.OUTLINE:
						_walls.append(Rect2(float(cx), float(cz), 1.0, 1.0))  # a two-storey front
					elif hall != null:
						_walls.append_array(hall.partition_rects(c))
	for span: Vector2 in DnaBuilder.ELEVATOR_WALL_SPANS:
		_walls.append(Rect2(span.x, 14.0, span.y - span.x, DnaLayout.ELEVATOR_WALL_Z - 14.0))
	_walls.append_array(DnaStreet.footprints())
	for seg: Vector4 in layout.partitions:
		var a: Vector2 = Vector2(seg.x, seg.y)
		var b: Vector2 = Vector2(seg.z, seg.w)
		_desk_walls.append(Rect2(minf(a.x, b.x) - 0.04, minf(a.y, b.y) - 0.04, absf(b.x - a.x) + 0.08, absf(b.y - a.y) + 0.08))


## The first wall a circle (x, z, radius) overlaps, as text; "" when clear. `desks` also tests the farms' desk partitions.
func _wall_hit(center: Vector2, radius: float, desks: bool = true) -> String:
	for rect: Rect2 in _walls:
		if _circle_hits(center, radius, rect):
			return "wall at %s" % _rect_text(rect)
	if desks:
		for rect: Rect2 in _desk_walls:
			if _circle_hits(center, radius, rect):
				return "desk partition at %s" % _rect_text(rect)
	return ""


static func _circle_hits(center: Vector2, radius: float, rect: Rect2) -> bool:
	var nearest: Vector2 = Vector2(clampf(center.x, rect.position.x, rect.end.x), clampf(center.y, rect.position.y, rect.end.y))
	return nearest.distance_to(center) < radius - 0.01


static func _rect_text(rect: Rect2) -> String:
	return "(%.1f-%.1f, %.1f-%.1f)" % [rect.position.x, rect.end.x, rect.position.y, rect.end.y]


func _hit(what: String, pos: Vector3, why: String) -> void:
	hits.append("%s at (%.1f, %.2f, %.1f): %s" % [what, pos.x, pos.y, pos.z, why])


# ---- The props ---------------------------------------------------------------------------------------------------------------------


func _check_layout_props() -> void:
	for prop: DnaLayout.Prop in builder.layout.props:
		if prop.kind == "piece" and prop.model == "counter":
			_surfaces.append({"rect": Rect2(prop.pos.x - prop.model_scale * 0.5 - 0.1, prop.pos.z - 0.45, prop.model_scale + 0.2, 0.9), "top": 0.98})
	for prop: DnaLayout.Prop in builder.layout.props:
		match prop.kind:
			"card":
				checked += 1
				var kind: String = str(DnaBuilder.CARD_KINDS.get(prop.model, ""))
				var width: float = 0.6
				if TreeCards.KINDS.has(kind):
					var size: Vector2 = (TreeCards.KINDS[kind] as Dictionary)["size"] as Vector2
					width = size.x * prop.model_scale / maxf(size.y, 0.01)
				if prop.pos.y > FLOAT_TOLERANCE:
					_hit(prop.model, prop.pos, "floats %.2f m up" % prop.pos.y)
				var why: String = _wall_hit(Vector2(prop.pos.x, prop.pos.z), maxf(width * 0.3, 0.16), not ON_PARTITION_OK.has(prop.model))
				if why != "":
					_hit(prop.model, prop.pos, why)
			"piece":
				checked += 1
				var node: Node3D = DnaProps.piece(prop.model, prop.model_scale)
				if node == null:
					continue
				_check_node_box(prop.model, node, Transform3D(Basis(Vector3.UP, deg_to_rad(prop.yaw)), prop.pos))
				node.free()
			"model":
				checked += 1
				if prop.pos.y > FLOAT_TOLERANCE:
					_hit(prop.model, prop.pos, "floats %.2f m up" % prop.pos.y)
				var why2: String = _wall_hit(Vector2(prop.pos.x, prop.pos.z), maxf(prop.radius, 0.25), prop.model != "coffin_decorated")
				if why2 != "":
					_hit(prop.model, prop.pos, why2)


## A built piece: its mesh box placed by `xform` - its bottom on the ground, its footprint (shrunk 5 cm) clear of every wall.
func _check_node_box(what: String, node: Node3D, xform: Transform3D) -> void:
	var box: AABB = AABB()
	var first: bool = true
	for child: Node in [node] + node.find_children("*", "MeshInstance3D", true, false):
		if not child is MeshInstance3D or (child as MeshInstance3D).mesh == null:
			continue
		var local: Transform3D = Transform3D.IDENTITY
		var walker: Node = child
		while walker != null and walker != node:
			local = (walker as Node3D).transform * local
			walker = walker.get_parent()
		var part: AABB = (xform * local) * (child as MeshInstance3D).mesh.get_aabb()
		box = part if first else box.merge(part)
		first = false
	if first:
		return
	if box.position.y > FLOAT_TOLERANCE and not _on_surface(Vector2(xform.origin.x, xform.origin.z), box.position.y):
		_hit(what, xform.origin, "floats: its bottom is %.2f m up" % box.position.y)
	var foot: Rect2 = Rect2(box.position.x + 0.05, box.position.z + 0.05, maxf(box.size.x - 0.1, 0.02), maxf(box.size.z - 0.1, 0.02))
	for rect: Rect2 in _walls:
		if foot.intersects(rect):
			_hit(what, xform.origin, "inside the wall at %s" % _rect_text(rect))
			return


func _check_builder_pieces() -> void:
	# the office booths (cards on the floor) and the columns along the fronts
	for kind: String in ["dna_booth_1", "dna_booth_2"]:
		for entry: Variant in builder.booth_entries(kind):
			checked += 1
			var at: Vector3 = (entry as Dictionary)["pos"] as Vector3
			var size: Vector2 = (TreeCards.KINDS[kind] as Dictionary)["size"] as Vector2
			var foot: Rect2 = Rect2(at.x - size.x * 0.45, at.z - 0.5, size.x * 0.9, 1.0)
			for rect: Rect2 in _walls + _desk_walls:
				if foot.intersects(rect):
					_hit(kind, at, "inside the wall at %s" % _rect_text(rect))
					break
	for at: Vector3 in builder.hall_columns:
		checked += 1
		var why2: String = _wall_hit(Vector2(at.x, at.z), 0.3)
		if why2 != "":
			_hit("hall column", at, why2)
	# the set pieces: the time clock on its pillar, the suggestion box, the printer
	checked += 3
	var clock: Node3D = DnaProps.time_clock()
	_check_node_box("time clock", clock, Transform3D(Basis.IDENTITY, DnaLayout.TIME_CLOCK_POST))
	clock.free()
	var box: Node3D = DnaProps.suggestion_box()
	_check_node_box("suggestion box", box, Transform3D(Basis.IDENTITY, builder.anchor("suggestion")))
	box.free()
	var printer: Node3D = DnaProps.printer()
	_check_node_box("printer", printer, Transform3D(Basis(Vector3.UP, deg_to_rad(90.0)), builder.anchor("printer")))
	printer.free()
	for id: Variant in builder.layout.chests.keys():
		checked += 1
		var at3: Vector3 = builder.layout.chests[id] as Vector3
		var why3: String = _wall_hit(Vector2(at3.x, at3.z), ChestKit.FOOTPRINT)
		if why3 != "":
			_hit("chest %s" % str(id), at3, why3)


## A sign floats when its bottom is well above the top of the wall it hangs on (the Waiting Room's sign hangs from its bracket).
func _check_signs() -> void:
	for spot: Dictionary in builder.sign_spots:
		checked += 1
		var bottom: float = float(spot["bottom"])
		var top: float = float(spot["mount_top"])
		if bottom > top + SIGN_TOLERANCE:
			_hit("sign %s" % str(spot["key"]), spot["pos"] as Vector3, "hangs in the air (its bottom %.2f m, the wall's top %.2f m)" % [bottom, top])


func _check_stair_ghosts() -> void:
	for ghost: Dictionary in builder.stair_ghosts:
		checked += 1
		var at: Vector3 = ghost["pos"] as Vector3
		var tread: float = float(ghost["tread"])
		if at.y < tread - 0.01:
			_hit("stair ghost", at, "sunk %.2f m into the step" % (tread - at.y))
		elif at.y > tread + FLOAT_TOLERANCE:
			_hit("stair ghost", at, "floats %.2f m over its step" % (at.y - tread))


## The dressing's kit pieces and clusters (each a node standing on the floor) and the wasteland's pieces (clear of the street and the fronts).
func _check_dressing() -> void:
	for child: Node in dressing.root.get_children():
		if not child is Node3D or child.name.begins_with("Decals_"):
			continue
		if dressing.wasteland != null and child == dressing.wasteland.root:
			continue
		var node: Node3D = child as Node3D
		if node.name.begins_with("Kit_") or node.name.begins_with("Cluster_"):
			checked += 1
			var radius: float = 0.3
			if node.has_meta("circles"):
				for circle: Variant in node.get_meta("circles") as Array:
					var local: Vector3 = circle as Vector3
					var world: Vector3 = node.position + Basis(Vector3.UP, node.rotation.y) * Vector3(local.x, 0.0, local.y)
					var why: String = _wall_hit(Vector2(world.x, world.z), local.z)
					if why != "":
						_hit(str(node.name), world, why)
				continue
			if node.position.y > FLOAT_TOLERANCE:
				_hit(str(node.name), node.position, "floats %.2f m up" % node.position.y)
			var why2: String = _wall_hit(Vector2(node.position.x, node.position.z), radius)
			if why2 != "":
				_hit(str(node.name), node.position, why2)
	if dressing.wasteland == null:
		return
	for kind: Variant in dressing.wasteland.placed.keys():
		for at: Variant in dressing.wasteland.placed[kind] as Array:
			if not at is Vector3:
				continue
			checked += 1
			var p: Vector3 = at as Vector3
			for rect: Rect2 in DnaStreet.footprints():
				if rect.grow(0.4).has_point(Vector2(p.x, p.z)):
					_hit("wasteland %s" % str(kind), p, "inside the street building at %s" % _rect_text(rect))
					break
