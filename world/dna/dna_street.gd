class_name DnaStreet
extends RefCounted
## Nov 18 evening (Part 1.1, the owner: "the building fronts read as randomly textured free-standing walls with the skyline right behind"):
## a street of fake civic buildings behind the D.N.A.'s painted building fronts (DNA-WALL-HALL-A / -B / -NARROW, `DnaHall.is_front`).
##
## Behind each front run the open ground is cut into buildings 5-9 m wide and 6.5-8.5 m deep: a body in DNA-WALL-EXTERIOR or DNA-WALL-GREY
## rising a little or a storey above the front's cornice (heights vary, so the roof line steps), a brass cornice and a parapet
## (DNA-TRIM-BRASS), a slate roof (DNA-ROOF-SLATE: hipped, mansard or gabled) with chimneys or dormers, a small tower on one building of
## each long row, and lit windows (DNA-SHEET-WINDOWS) on the sides, the backs and the upper floors. Every building is a closed box, so the
## ends of a row show a proper corner, never a wall's thin edge. Nothing here is walkable (the walk grid is unchanged); the buildings stand
## outside it, clear of the Hall of Final Approvals, its stair and the clock tower (`RESERVED`). Each building is its own node (the camera's
## cut-away dissolves a row whole; one mesh per row keeps the draw calls down). `footprints()` is what the wasteland keeps clear of and what the prop probe tests against.

const DEPTH_MIN: float = 6.5
const DEPTH_MAX: float = 8.5
## A front with less open ground than this behind it is drawn as a partition instead (DnaHall.is_front): no room for a building.
const MIN_GROUND_BEHIND: int = 7
const WIDTH_MIN: float = 5.0
const WIDTH_MAX: float = 9.0
## Heights above the front's cornice (HALL_H) for the bodies, in turn with the rng.
const RISES: Array[float] = [0.9, 3.4, 1.8, 4.6, 2.6, 1.2]
const ROOFS: Array[String] = ["hip", "mansard", "gable", "hip", "mansard"]
## Ground the buildings never take (x, z, w, d): the Hall of Final Approvals with its forecourt, stair and pylons, the clock tower.
const RESERVED: Array[Rect2] = [Rect2(12.5, -31.0, 66.0, 25.2), Rect2(36.5, -10.0, 18.0, 12.0), Rect2(32.0, -6.5, 8.2, 8.2)]

var buildings: Array[Dictionary] = []
var root: Node3D
static var _footprints: Array[Rect2] = []


## The footprints (xz) of the last street built or planned: the wasteland and the probe keep clear of them.
static func footprints() -> Array[Rect2]:
	return _footprints


## How many cells of open ground lie behind a front cell in `dir` (out of the map counts as open), capped at 40.
static func ground_behind(hall: DnaHall, c: Vector2i, dir: Vector2i) -> int:
	var d: int = 0
	var p: Vector2i = c + dir
	while hall.is_outside(p) and d < 40:
		d += 1
		p += dir
	return d


## The buildings behind every front run: [{"rect": Rect2 (xz), "face": Vector2i (the way the street faces: towards the plaza), "h": body
## height, "roof": kind, "tower": bool, "seed": int}].
static func plan(hall: DnaHall) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1811
	var run_index: int = 0
	for run: Dictionary in hall.outline_runs():
		if bool(run["inside"]):
			continue
		var cells: Array = run["cells"] as Array
		var dir: Vector2i = run["dir"] as Vector2i
		if cells.size() < 3:
			continue
		# only the long faces of a row: the run runs across `dir`
		var along_x: bool = dir.y != 0
		var depth_cells: int = 99
		for c: Variant in cells:
			depth_cells = mini(depth_cells, ground_behind(hall, c as Vector2i, dir))
		var depth: float = clampf(float(depth_cells) - 0.5, 0.0, DEPTH_MAX)
		if depth < DEPTH_MIN - 0.01:
			continue
		var first: Vector2i = cells[0] as Vector2i
		var last: Vector2i = cells[cells.size() - 1] as Vector2i
		var u0: float = float(first.x if along_x else first.y)
		var u1: float = float((last.x if along_x else last.y) + 1)
		# the face plane: the cell edge on the outside
		var face: float = float(first.y if along_x else first.x) + (1.0 if (dir.y > 0 or dir.x > 0) else 0.0)
		var row: Array[Dictionary] = []
		var u: float = u0
		while u1 - u >= 3.0:
			var width: float = rng.randf_range(WIDTH_MIN, WIDTH_MAX)
			if u1 - (u + width) < WIDTH_MIN * 0.6:
				width = u1 - u
			var d: float = DEPTH_MIN + rng.randf() * (depth - DEPTH_MIN)
			var rect: Rect2 = _rect(along_x, dir, face, u, u + width, d)
			rect = _clear_of_reserved(rect, along_x)
			if rect.size.x >= 3.0 and rect.size.y >= 3.0:
				var index: int = result.size() + row.size()
				row.append({"rect": rect, "face": -dir, "h": DnaHall.HALL_H + RISES[index % RISES.size()], "roof": ROOFS[(index + run_index) % ROOFS.size()],
					"tower": false, "seed": 7000 + index, "along_x": along_x, "row": run_index})
			u += width
		if row.size() >= 3:
			row[row.size() / 2]["tower"] = true
		result.append_array(row)
		run_index += 1
	_footprints = []
	for b: Dictionary in result:
		_footprints.append(b["rect"] as Rect2)
	return result


static func _rect(along_x: bool, dir: Vector2i, face: float, ua: float, ub: float, depth: float) -> Rect2:
	var gap: float = 0.02
	if along_x:
		var z0: float = face - depth - gap if dir.y < 0 else face + gap
		return Rect2(ua, z0, ub - ua, depth)
	var x0: float = face - depth - gap if dir.x < 0 else face + gap
	return Rect2(x0, ua, depth, ub - ua)


## Shortens a building along its row until it is clear of the reserved ground (the Hall, its stair, the clock tower).
static func _clear_of_reserved(rect: Rect2, along_x: bool) -> Rect2:
	var out: Rect2 = rect
	for keep: Rect2 in RESERVED:
		if not out.intersects(keep):
			continue
		if along_x:
			var left: float = keep.position.x - out.position.x
			var right: float = out.end.x - keep.end.x
			if left >= right:
				out = Rect2(out.position.x, out.position.y, maxf(left, 0.0), out.size.y)
			else:
				out = Rect2(keep.end.x, out.position.y, maxf(right, 0.0), out.size.y)
		else:
			var top: float = keep.position.y - out.position.y
			var bottom: float = out.end.y - keep.end.y
			if top >= bottom:
				out = Rect2(out.position.x, out.position.y, out.size.x, maxf(top, 0.0))
			else:
				out = Rect2(out.position.x, keep.end.y, out.size.x, maxf(bottom, 0.0))
	return out


## Builds the planned street under `parent` (one node per building, never range-culled: the street is seen from across the plaza).
static func build(parent: Node3D, hall: DnaHall) -> DnaStreet:
	var street: DnaStreet = DnaStreet.new()
	street.root = Node3D.new()
	street.root.name = "DnaStreet"
	parent.add_child(street.root)
	street.buildings = plan(hall)
	# one mesh per row (a handful of draw calls for the whole street; each row is one node, so the camera's cut-away takes a row together)
	var rows: Dictionary = {}
	for index: int in range(street.buildings.size()):
		var spec: Dictionary = street.buildings[index]
		var key: int = int(spec["row"])
		if not rows.has(key):
			var mesh: KitMesh = KitMesh.new()
			DnaLandmarks._materials(mesh)
			mesh.set_material("exterior", DnaLandmarks._surface("DNA-WALL-EXTERIOR", DnaLandmarks.GREY))
			rows[key] = mesh
		street._building(spec, index, rows[key] as KitMesh)
	for key: Variant in rows.keys():
		var body: MeshInstance3D = (rows[key] as KitMesh).instance("Body")
		body.set_meta(&"no_range_cull", true)
		body.set_meta(PaintedClasses.META_NO_PAINT, true)
		var node: Node3D = Node3D.new()
		node.name = "StreetRow_%d" % int(key)
		node.add_child(body)
		street.root.add_child(node)
	return street


func _building(spec: Dictionary, index: int, mesh: KitMesh) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = int(spec["seed"])
	var rect: Rect2 = spec["rect"] as Rect2
	var face: Vector2i = spec["face"] as Vector2i
	var h: float = float(spec["h"])
	var wall_slot: String = "exterior" if index % 3 != 1 else "grey"
	var cx: float = rect.get_center().x
	var cz: float = rect.get_center().y
	var front_n: Vector3 = Vector3(float(face.x), 0.0, float(face.y))
	# the body: up to the front's cornice the full footprint, above it a storey set back from the front
	var low_h: float = DnaHall.HALL_H + 0.3
	mesh.box("grey_dark", Vector3(cx, 0.6, cz), Vector3(rect.size.x + 0.3, 1.2, rect.size.y + 0.3), Basis.IDENTITY, 0.04, 0.85)
	mesh.box(wall_slot, Vector3(cx, low_h * 0.5, cz), Vector3(rect.size.x, low_h, rect.size.y), Basis.IDENTITY, 0.05, 0.88)
	var upper: Rect2 = rect
	if h > low_h + 0.6:
		upper = _shrink_from(rect, face, 0.9)
		mesh.box(wall_slot, Vector3(upper.get_center().x, (low_h + h) * 0.5, upper.get_center().y), Vector3(upper.size.x, h - low_h, upper.size.y), Basis.IDENTITY, 0.04, 0.95)
		mesh.box("brass", Vector3(cx, low_h + 0.08, cz), Vector3(rect.size.x + 0.24, 0.16, rect.size.y + 0.24), Basis.IDENTITY, 0.0)
	# the cornice and the parapet round the top
	mesh.box("brass", Vector3(upper.get_center().x, h + 0.1, upper.get_center().y), Vector3(upper.size.x + 0.3, 0.2, upper.size.y + 0.3), Basis.IDENTITY, 0.0)
	mesh.box("grey_light", Vector3(upper.get_center().x, h + 0.42, upper.get_center().y), Vector3(upper.size.x + 0.1, 0.44, upper.size.y + 0.1), Basis.IDENTITY, 0.02)
	var roof_y: float = h + 0.64
	var roof_kind: String = str(spec["roof"])
	var roof_area: Rect2 = upper.grow(-0.15)
	match roof_kind:
		"gable":
			_gable(mesh, roof_area, roof_y, minf(roof_area.size.x, roof_area.size.y) * 0.42, bool(spec["along_x"]), wall_slot)
		"mansard":
			_hip(mesh, roof_area, roof_y, 2.2, 0.32, true)
		_:
			_hip(mesh, roof_area, roof_y, minf(roof_area.size.x, roof_area.size.y) * 0.36, 0.5, false)
	# chimneys (two at most), dormers on the roof slope facing the plaza
	for i: int in range(1 + rng.randi() % 2):
		var at: Vector2 = Vector2(rng.randf_range(roof_area.position.x + 0.8, roof_area.end.x - 0.8), rng.randf_range(roof_area.position.y + 0.8, roof_area.end.y - 0.8))
		mesh.box("grey_dark", Vector3(at.x, roof_y + 1.0, at.y), Vector3(0.6, 2.2, 0.6), Basis.IDENTITY, 0.02)
		mesh.box("brass", Vector3(at.x, roof_y + 2.15, at.y), Vector3(0.74, 0.1, 0.74), Basis.IDENTITY, 0.0)
	if roof_kind != "gable":
		var along: Vector3 = Vector3(absf(front_n.z), 0.0, absf(front_n.x))
		var span: float = rect.size.x if along.x > 0.5 else rect.size.y
		var front_edge: Vector3 = Vector3(roof_area.get_center().x, 0.0, roof_area.get_center().y) + front_n * ((roof_area.size.y if along.x > 0.5 else roof_area.size.x) * 0.5 - 0.7)
		var dormers: int = clampi(int(span / 3.0), 1, 3)
		for i: int in range(dormers):
			var t: float = (float(i) + 0.5) / float(dormers) - 0.5
			var p: Vector3 = front_edge + along * (t * (span - 2.0)) + Vector3(0, roof_y + 0.55, 0)
			mesh.box(wall_slot, p, Vector3(1.0, 1.1, 1.0), Basis.IDENTITY, 0.02)
			mesh.box("window_glow", p + front_n * 0.51, Vector3(0.5, 0.6, 0.5) * Vector3(along.x + absf(front_n.x) * 0.04, 1.0, along.z + absf(front_n.z) * 0.04), Basis.IDENTITY, 0.0)
			mesh.box("slate", p + Vector3(0, 0.66, 0), Vector3(1.2, 0.22, 1.2), Basis.IDENTITY, 0.02)
	if bool(spec["tower"]):
		var t_at: Vector3 = Vector3(rect.get_center().x, 0.0, rect.get_center().y) - front_n * (minf(rect.size.x, rect.size.y) * 0.18)
		var tw: float = 3.2
		var top: float = h + 5.4
		mesh.box(wall_slot, Vector3(t_at.x, (roof_y + top) * 0.5, t_at.z), Vector3(tw, top - roof_y, tw), Basis.IDENTITY, 0.04)
		mesh.box("brass", Vector3(t_at.x, top + 0.1, t_at.z), Vector3(tw + 0.3, 0.2, tw + 0.3), Basis.IDENTITY, 0.0)
		_hip(mesh, Rect2(t_at.x - tw * 0.5 - 0.1, t_at.z - tw * 0.5 - 0.1, tw + 0.2, tw + 0.2), top + 0.2, 3.0, 0.5, false)
		mesh.blob("gold", Vector3(t_at.x, top + 3.35, t_at.z), Vector3.ONE * 0.22, 3, 6, 1.0)
		_windows_on(mesh, Rect2(t_at.x - tw * 0.5, t_at.z - tw * 0.5, tw, tw), top - 2.4, top - 0.6, 1, rng, face)
	# lit windows: the sides, the back, the upper floor's front
	_windows_on(mesh, rect, 2.0, low_h - 1.2, 3, rng, Vector2i.ZERO, face)
	if h > low_h + 1.8:
		_windows_on(mesh, upper, low_h + 0.6, h - 0.4, 1, rng, face)


## `rect` with `amount` taken off the side facing `face`.
static func _shrink_from(rect: Rect2, face: Vector2i, amount: float) -> Rect2:
	var r: Rect2 = rect
	if face.y > 0:
		r.size.y -= amount
	elif face.y < 0:
		r.position.y += amount
		r.size.y -= amount
	elif face.x > 0:
		r.size.x -= amount
	else:
		r.position.x += amount
		r.size.x -= amount
	return r


## Window cards on the faces of `rect` between heights y0 and y1 (`floors` rows). `only` = (0,0): every face except `skip`; else just that face.
func _windows_on(mesh: KitMesh, rect: Rect2, y0: float, y1: float, floors: int, rng: RandomNumberGenerator, only: Vector2i, skip: Vector2i = Vector2i(9, 9)) -> void:
	var ids: Array[String] = []
	for id: String in ["DNA-SHEET-WINDOWS-02", "DNA-SHEET-WINDOWS-03", "DNA-SHEET-WINDOWS-01", "DNA-SHEET-WINDOWS-04"]:
		if EnvKit.has(id):
			ids.append(id)
	if ids.is_empty():
		return
	for step: Vector2i in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if only != Vector2i.ZERO and step != only:
			continue
		if only == Vector2i.ZERO and step == skip:
			continue
		var n: Vector3 = Vector3(float(step.x), 0.0, float(step.y))
		var span: float = rect.size.x if step.y != 0 else rect.size.y
		var center: Vector3 = Vector3(rect.get_center().x, 0.0, rect.get_center().y) + n * ((rect.size.y if step.y != 0 else rect.size.x) * 0.5 + 0.03)
		var along: Vector3 = Vector3(1, 0, 0) if step.y != 0 else Vector3(0, 0, 1)
		var cols: int = maxi(1, int(span / 2.6))
		var win_h: float = clampf((y1 - y0) / float(floors) - 0.7, 1.2, 2.4)
		for f: int in range(floors):
			var y: float = y0 + (float(f) + 0.5) * (y1 - y0) / float(floors) - win_h * 0.5
			for col: int in range(cols):
				if rng.randf() < 0.18:
					continue  # a dark gap here and there
				var t: float = (float(col) + 0.5) / float(cols) - 0.5
				var p: Vector3 = center + along * (t * (span - 1.2)) + Vector3(0, y, 0)
				var lit: bool = rng.randf() < 0.62
				if lit:
					mesh.box("window_glow", p + Vector3(0, win_h * 0.5, 0) - n * 0.01, Vector3(0.7, win_h * 0.8, 0.7) * Vector3(along.x + absf(n.x) * 0.03, 1.0, along.z + absf(n.z) * 0.03), Basis.IDENTITY, 0.0)
				DnaLandmarks._card(mesh, ids[(col + f) % ids.size()], p + n * 0.01, win_h, n)


## A hipped (or mansard) slate roof over `r` from height y: four slopes rising `rise` to a top inset by `inset` (a share of each side; 0.5 =
## a ridge or a point); a mansard is steep then flat-topped.
static func _hip(mesh: KitMesh, r: Rect2, y: float, rise: float, inset: float, mansard: bool) -> void:
	var ix: float = r.size.x * minf(inset, 0.5)
	var iz: float = r.size.y * minf(inset, 0.5)
	if not mansard:
		# a hip ends in a ridge along the longer side
		if r.size.x >= r.size.y:
			iz = r.size.y * 0.5
			ix = minf(ix, r.size.x * 0.5 - 0.01)
		else:
			ix = r.size.x * 0.5
			iz = minf(iz, r.size.y * 0.5 - 0.01)
	var b: Array[Vector3] = [Vector3(r.position.x, y, r.position.y), Vector3(r.end.x, y, r.position.y), Vector3(r.end.x, y, r.end.y), Vector3(r.position.x, y, r.end.y)]
	var t: Array[Vector3] = [Vector3(r.position.x + ix, y + rise, r.position.y + iz), Vector3(r.end.x - ix, y + rise, r.position.y + iz), Vector3(r.end.x - ix, y + rise, r.end.y - iz), Vector3(r.position.x + ix, y + rise, r.end.y - iz)]
	var outs: Array[Vector3] = [Vector3(0, 0.6, -1).normalized(), Vector3(1, 0.6, 0).normalized(), Vector3(0, 0.6, 1).normalized(), Vector3(-1, 0.6, 0).normalized()]
	for i: int in range(4):
		var j: int = (i + 1) % 4
		mesh.quad("slate", [b[i], b[j], t[j], t[i]], outs[i])
	if mansard:
		mesh.quad("slate", [t[0], t[1], t[2], t[3]], Vector3.UP)


## A gabled slate roof: the ridge runs along the row (`along_x`), vertical gable ends in the wall's stone.
static func _gable(mesh: KitMesh, r: Rect2, y: float, rise: float, along_x: bool, wall_slot: String) -> void:
	if along_x:
		var zm: float = r.get_center().y
		var a: Vector3 = Vector3(r.position.x, y + rise, zm)
		var b: Vector3 = Vector3(r.end.x, y + rise, zm)
		mesh.quad("slate", [Vector3(r.position.x, y, r.position.y), Vector3(r.end.x, y, r.position.y), b, a], Vector3(0, 0.7, -1).normalized())
		mesh.quad("slate", [Vector3(r.end.x, y, r.end.y), Vector3(r.position.x, y, r.end.y), a, b], Vector3(0, 0.7, 1).normalized())
		mesh.tri(wall_slot, [Vector3(r.position.x, y, r.end.y), Vector3(r.position.x, y, r.position.y), a], Vector3(-1, 0, 0))
		mesh.tri(wall_slot, [Vector3(r.end.x, y, r.position.y), Vector3(r.end.x, y, r.end.y), b], Vector3(1, 0, 0))
	else:
		var xm: float = r.get_center().x
		var a2: Vector3 = Vector3(xm, y + rise, r.position.y)
		var b2: Vector3 = Vector3(xm, y + rise, r.end.y)
		mesh.quad("slate", [Vector3(r.position.x, y, r.end.y), Vector3(r.position.x, y, r.position.y), a2, b2], Vector3(-1, 0.7, 0).normalized())
		mesh.quad("slate", [Vector3(r.end.x, y, r.position.y), Vector3(r.end.x, y, r.end.y), b2, a2], Vector3(1, 0.7, 0).normalized())
		mesh.tri(wall_slot, [Vector3(r.position.x, y, r.position.y), Vector3(r.end.x, y, r.position.y), a2], Vector3(0, 0, -1))
		mesh.tri(wall_slot, [Vector3(r.end.x, y, r.end.y), Vector3(r.position.x, y, r.end.y), b2], Vector3(0, 0, 1))
