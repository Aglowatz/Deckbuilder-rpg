class_name DnaHall
extends RefCounted
## Overnight Nov 18 (owner's choice, Batch 17A): the D.N.A. is ONE enormous grand hall, indoors - a cathedral-sized haunted government lobby
## at night (target: `Approved_ZoneKits/DNA/Haunted Office of Necrotic Affairs.png`, layout `PAINTOVER-DNA-HUB.png`). Only the look changes:
## the walk grid, the rooms, routes, NPCs, doors, quests and every interaction are `DnaLayout`'s as before.
##
## - The building's outline (every wall cell that touches the outside: the old shell plus the south faces) is a two-storey painted hall wall
##   on its inside: DNA-WALL-HALL-A and -B alternating bay by bay (never the same twice in a row), DNA-WALL-HALL-NARROW for short runs and
##   run ends, every bay drawn with the same three height bands so the wainscot, the gallery and the cornice run level all round
##   (`BANDS`). Its outside faces are DNA-WALL-EXTERIOR. Above the cornice a dark vault band rises to the ceiling.
## - Every other wall cell (the old full-height room and corridor walls) is a waist-high partition (DNA-RAIL-PARTITION) on the same
##   footprint - the same cells, so the same collision - with DNA-RAIL-POST at every end and join. The camera sees over them.
## - Enclosed gaps between rooms (void cells walled in on every side) are hall floor too: marble you cannot walk on, where the booths,
##   columns and desks stand.
## - Nov 18 day (the owner's playtest: "it never rains there, so it can be outdoors"): no ceiling and no end bay. The D.N.A. is an open-air
##   civic plaza at night under DNA-SKY-GLOOM. Only the north side and the west long side keep the two-storey painted walls, as building
##   fronts capped at HALL_H (`is_front`); every other outline cell is a waist-high partition like the inner walls, so the player sees out
##   over the grey wasteland to the skyline (DNA-BD-TOWERS).
## Everything wall-like is built into the chunk's `DnaFadeMesh` ("Interior"), one piece per wall cell, so the room cut (DnaRoomCut) still
## clears the walls between the camera and the hero's room.

## The painted bay: height of the outline walls (and the width of a square A / B bay; NARROW is half as wide).
const HALL_H: float = 11.0
## The ceiling (the top of the vault band).
const VAULT_H: float = 16.5
## The partitions on the old wall footprints.
const PARTITION_H: float = 1.15
const PARTITION_T: float = 0.34
## One partition texture repeat along a run (the painting is 2172 x 416 px, drawn PARTITION_H tall).
const PARTITION_REPEAT: float = PARTITION_H * 2172.0 / 416.0
## The bays' shared height bands: each texture's v at the wainscot top and the gallery rail top (measured on the paintings), drawn at the
## same wall heights (fractions of HALL_H) so the lines run level from bay to bay.
const BANDS: Dictionary = {
	"hall_a": [0.79, 0.384], "hall_b": [0.79, 0.384], "hall_n": [0.74, 0.301],
}
const BAND_HEIGHTS: Array[float] = [0.21, 0.616]
const EXTERIOR_BAY: float = 11.0
## The lens cut-away of the hall walls: fully gone within 45 % of this of the camera, back at this (a two-storey wall must never fill the view).
const HALL_LENS_REACH: float = 10.0
const VAULT: Color = Color(0.055, 0.04, 0.032)
const CAP: Color = Color(0.2, 0.12, 0.08)
## The red runners: the central axis from the gate to the Hall's stair, and branches to the lobby's neighbours.
const RUNNER_W: float = 2.4
const RUNNERS: Array[Array] = [
	[Vector2(45.5, 59.6), Vector2(45.5, 2.2)],
	[Vector2(46.7, 53.5), Vector2(51.4, 53.5)],
	[Vector2(44.3, 52.5), Vector2(28.5, 52.5)],
	[Vector2(44.3, 34.5), Vector2(36.6, 34.5)],
	[Vector2(46.7, 34.5), Vector2(53.4, 34.5)],
]

enum Kind { NONE, INSIDE_VOID, OUTLINE, PARTITION }

var layout: DnaLayout
## Vector2i -> Kind for every cell that is not plain floor / solid.
var kinds: Dictionary = {}
var _outside: Dictionary = {}
var bay_count: Dictionary = {"hall_a": 0, "hall_b": 0, "hall_n": 0}


func _init(source: DnaLayout) -> void:
	layout = source
	_classify()


## Void cells drawn as hall wall although the layout leaves them open: the notch between Cubicle Farm A and the Breakroom (z 45-46) is
## walled in at its west and south ends, so it is hall floor and the walls round it are partitions, not outside faces seen from the lobby.
static func seals() -> Dictionary:
	var result: Dictionary = {Vector2i(1, 45): true, Vector2i(1, 46): true}
	for x: int in range(1, 17):
		result[Vector2i(x, 47)] = true
	return result


## The outside: void cells reachable from the map's border through void (the wasteland, the approach's sides). Everything walled in is hall.
func _classify() -> void:
	var sealed: Dictionary = seals()
	var queue: Array[Vector2i] = []
	for cx: int in range(-1, DnaLayout.W + 1):
		for cz: int in [-1, DnaLayout.H]:
			queue.append(Vector2i(cx, cz))
	for cz: int in range(0, DnaLayout.H):
		for cx: int in [-1, DnaLayout.W]:
			queue.append(Vector2i(cx, cz))
	for c: Vector2i in queue:
		_outside[c] = true
	var head: int = 0
	while head < queue.size():
		var c: Vector2i = queue[head]
		head += 1
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + step
			if _outside.has(n) or not layout.in_bounds(n.x, n.y):
				continue
			if layout.cell_at(n.x, n.y) != DnaLayout.Cell.VOID or layout.open_edges.has(n) or sealed.has(n):
				continue
			_outside[n] = true
			queue.append(n)
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			var c: Vector2i = Vector2i(cx, cz)
			if sealed.has(c) and layout.cell_at(cx, cz) == DnaLayout.Cell.VOID:
				kinds[c] = Kind.OUTLINE if _touches_outside(c) else Kind.PARTITION
				continue
			match layout.cell_at(cx, cz):
				DnaLayout.Cell.VOID:
					if not _outside.has(c) and not layout.open_edges.has(c):
						kinds[c] = Kind.INSIDE_VOID
				DnaLayout.Cell.WALL:
					kinds[c] = Kind.OUTLINE if _touches_outside(c) else Kind.PARTITION
	# Nov 18 day (Part 6.1): open sides - outline cells that are not building fronts become partitions (same cells, same collision)
	for c: Vector2i in kinds.keys():
		if kinds[c] == Kind.OUTLINE and not is_front(c):
			kinds[c] = Kind.PARTITION


## Nov 18 day (Part 6.1): the outline cells that stay two-storey building fronts - the north side (an outside neighbour to the north, in the
## northern rooms), the west long side (an outside neighbour to the west, at the map's west edge) and the short returns of the executive
## floor's bay. Everything else on the outline is drawn as a partition.
const FRONT_NORTH_MAX_Z: int = 30
const FRONT_WEST_MAX_X: int = 6


func is_front(c: Vector2i) -> bool:
	if is_outside(c + Vector2i(0, -1)) and c.y <= FRONT_NORTH_MAX_Z:
		return true
	if is_outside(c + Vector2i(-1, 0)) and c.x <= FRONT_WEST_MAX_X:
		return true
	if c.y < 16 and c.x > 30 and c.x < 60 and (is_outside(c + Vector2i(1, 0)) or is_outside(c + Vector2i(-1, 0))):
		return true
	return false


func is_outside(c: Vector2i) -> bool:
	return _outside.has(c) or not layout.in_bounds(c.x, c.y)


func _touches_outside(c: Vector2i) -> bool:
	for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if is_outside(c + step):
			return true
	return false


func kind_at(c: Vector2i) -> Kind:
	return kinds.get(c, Kind.NONE) as Kind


## Hall floor that nobody walks on (the walled-in gaps between rooms).
func inside_void_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for c: Vector2i in kinds.keys():
		if kinds[c] == Kind.INSIDE_VOID:
			result.append(c)
	return result


## The slots of a chunk's interior fade mesh.
static func mesh() -> DnaFadeMesh:
	var fade: DnaFadeMesh = DnaFadeMesh.new()
	var reach: float = HALL_LENS_REACH
	fade.set_slot("hall_a", "DNA-WALL-HALL-A", Color.WHITE, 1.0, 0.12, reach, 1.0)
	fade.set_slot("hall_b", "DNA-WALL-HALL-B", Color.WHITE, 1.0, 0.12, reach, 1.0)
	fade.set_slot("hall_n", "DNA-WALL-HALL-NARROW", Color.WHITE, 1.0, 0.12, reach, 1.0)
	fade.set_slot("exterior", "DNA-WALL-EXTERIOR", Color.WHITE, 1.0, 0.08, reach, 1.0)
	fade.set_slot("roof", "DNA-ROOF-SLATE", Color(0.55, 0.55, 0.6), 1.0, 0.0, reach)
	fade.set_slot("vault", "", VAULT, 1.0, 0.0, reach)
	fade.set_slot("partition", "DNA-RAIL-PARTITION", Color.WHITE, 1.0, 0.05, 0.0, 1.0)
	fade.use_texture_alpha("partition")
	fade.set_slot("cap", "", CAP, 1.0, 0.0, 0.0)
	fade.set_slot("banner_1", "DNA-BANNER-STAMP-01", Color.WHITE, 1.0, 0.1, reach, 1.0)
	fade.use_texture_alpha("banner_1")
	fade.set_slot("banner_2", "DNA-BANNER-STAMP-02", Color.WHITE, 1.0, 0.1, reach, 1.0)
	fade.use_texture_alpha("banner_2")
	return fade


# ---- The outline: painted hall walls inside, the exterior outside ----------------------------------------------------------------


## The faces of the outline: [{"cell", "dir" (Vector2i towards the face's side), "inside": bool}] grouped into straight runs:
## [{"dir", "inside", "cells": Array[Vector2i] in order along the run}].
func outline_runs() -> Array[Dictionary]:
	var faces: Dictionary = {}  # "dx,dz,inside" -> {line -> [along...]}
	for c: Vector2i in kinds.keys():
		if kinds[c] != Kind.OUTLINE:
			continue
		if c.y >= DnaLayout.APPROACH_Z0 and DnaInterior.room_beside(layout, c) == "":
			continue  # the causeway's parapets stay knee-high (DnaBuilder._build_balustrades)
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + step
			var nk: Kind = kind_at(n)
			if nk == Kind.OUTLINE:
				continue
			var inside: bool = not is_outside(n)
			var key: String = "%d,%d,%s" % [step.x, step.y, "in" if inside else "out"]
			var by_line: Dictionary = faces.get(key, {}) as Dictionary
			var line: int = c.x if step.x != 0 else c.y
			var along: int = c.y if step.x != 0 else c.x
			var list: Array = by_line.get(line, []) as Array
			list.append(along)
			by_line[line] = list
			faces[key] = by_line
	var runs: Array[Dictionary] = []
	for key: String in faces.keys():
		var parts: PackedStringArray = key.split(",")
		var step: Vector2i = Vector2i(int(parts[0]), int(parts[1]))
		var inside: bool = parts[2] == "in"
		var by_line: Dictionary = faces[key] as Dictionary
		for line: int in by_line.keys():
			var alongs: Array = by_line[line] as Array
			alongs.sort()
			var current: Array[Vector2i] = []
			var last: int = -999
			for a: int in alongs:
				if a != last + 1 and not current.is_empty():
					runs.append({"dir": step, "inside": inside, "cells": current})
					current = []
				current.append(Vector2i(line, a) if step.x != 0 else Vector2i(a, line))
				last = a
			if not current.is_empty():
				runs.append({"dir": step, "inside": inside, "cells": current})
	return runs


## The bays of a run `length` metres long: [{"slot", "x0", "x1", "u0", "u1"}] (x along the run). Full A / B bays alternate (the start
## alternates by run so neighbouring runs differ too); one NARROW takes up the leftover; a run shorter than a narrow bay shows the narrow
## bay's middle.
func bays_for(length: float, run_index: int) -> Array[Dictionary]:
	var half: float = HALL_H * 0.5
	var units: int = int(round(length / half))
	var result: Array[Dictionary] = []
	if units <= 1:
		if length < half * 0.8:
			var crop: float = length / half
			result.append({"slot": "hall_n", "x0": 0.0, "x1": length, "u0": 0.5 - crop * 0.5, "u1": 0.5 + crop * 0.5})
		else:
			result.append({"slot": "hall_n", "x0": 0.0, "x1": length, "u0": 0.0, "u1": 1.0})
		bay_count["hall_n"] += 1
		return result
	var full: int = units / 2
	var narrow: int = units % 2
	var scale_value: float = length / (float(full) * HALL_H + float(narrow) * half)
	var x: float = 0.0
	# the narrow bay goes at the run's end that faces south or east (a corner), so long runs open with a full bay
	for i: int in range(full):
		var slot: String = "hall_a" if (i + run_index) % 2 == 0 else "hall_b"
		result.append({"slot": slot, "x0": x, "x1": x + HALL_H * scale_value, "u0": 0.0, "u1": 1.0})
		bay_count[slot] += 1
		x += HALL_H * scale_value
	if narrow == 1:
		result.append({"slot": "hall_n", "x0": x, "x1": length, "u0": 0.0, "u1": 1.0})
		bay_count["hall_n"] += 1
	return result


## The v of a painted bay at wall height `y` (piecewise: floor..wainscot, wainscot..rail, rail..top map the texture's own bands).
static func band_v(slot: String, y: float) -> float:
	var bands: Array = BANDS.get(slot, [0.79, 0.384]) as Array
	var h0: float = BAND_HEIGHTS[0] * HALL_H
	var h1: float = BAND_HEIGHTS[1] * HALL_H
	if y <= h0:
		return lerpf(1.0, float(bands[0]), y / h0)
	if y <= h1:
		return lerpf(float(bands[0]), float(bands[1]), (y - h0) / (h1 - h0))
	return lerpf(float(bands[1]), 0.0, (y - h1) / (HALL_H - h1))


## Builds every outline face of the chunk `chunk_key` (cells grouped by DnaBuilder's chunks) into `fade`. `chunk_of` maps a cell to its
## chunk key. Returns the sconce / banner spots on the inside faces: [{"pos", "normal"}] (one per bay join).
func build_outline(fade: DnaFadeMesh, chunk_key: Vector2i, chunk_of: Callable, runs: Array[Dictionary]) -> Array[Dictionary]:
	var joins: Array[Dictionary] = []
	for run_index: int in range(runs.size()):
		var run: Dictionary = runs[run_index]
		var cells: Array = run["cells"] as Array
		var step: Vector2i = run["dir"] as Vector2i
		var inside: bool = bool(run["inside"])
		var normal: Vector3 = Vector3(float(step.x), 0.0, float(step.y))
		var along_x: bool = step.y != 0
		var first: Vector2i = cells[0] as Vector2i
		var length: float = float(cells.size())
		var bays: Array[Dictionary] = []
		if inside:
			bays = bays_for(length, run_index)
		# the face plane: the cell edge on the face's side; the run starts at the first cell's low edge
		var origin: Vector3 = Vector3(float(first.x), 0.0, float(first.y))
		if step.x > 0 or step.y > 0:
			origin += Vector3(float(maxi(step.x, 0)), 0.0, float(maxi(step.y, 0)))
		var dir_along: Vector3 = Vector3(1, 0, 0) if along_x else Vector3(0, 0, 1)
		for i: int in range(cells.size()):
			var c: Vector2i = cells[i] as Vector2i
			if chunk_of.call(c) != chunk_key:
				continue
			var center: Vector3 = DnaLayout.cell_center(c.x, c.y)
			var piece: Vector4 = Vector4(center.x, center.z, 0.5, HALL_H + 0.3)
			var lift: Vector3 = normal * 0.002
			var x0: float = float(i)
			var x1: float = float(i + 1)
			if inside:
				for bay: Dictionary in bays:
					var a: float = maxf(x0, float(bay["x0"]))
					var b: float = minf(x1, float(bay["x1"]))
					if b <= a + 0.0001:
						continue
					var slot: String = str(bay["slot"])
					var span: float = float(bay["x1"]) - float(bay["x0"])
					var ua: float = lerpf(float(bay["u0"]), float(bay["u1"]), (a - float(bay["x0"])) / span)
					var ub: float = lerpf(float(bay["u0"]), float(bay["u1"]), (b - float(bay["x0"])) / span)
					# the painting reads left to right as seen from the room: faces looking south or west run with the axis, the others mirror
					if step == Vector2i(0, -1) or step == Vector2i(1, 0):
						ua = float(bay["u1"]) + float(bay["u0"]) - ua
						ub = float(bay["u1"]) + float(bay["u0"]) - ub
					var heights: Array[float] = [0.0, BAND_HEIGHTS[0] * HALL_H, BAND_HEIGHTS[1] * HALL_H, HALL_H]
					for h: int in range(3):
						var y0: float = heights[h]
						var y1: float = heights[h + 1]
						var p0: Vector3 = origin + dir_along * a + Vector3(0, y0, 0) + lift
						var p1: Vector3 = origin + dir_along * b + Vector3(0, y0, 0) + lift
						var p2: Vector3 = origin + dir_along * b + Vector3(0, y1, 0) + lift
						var p3: Vector3 = origin + dir_along * a + Vector3(0, y1, 0) + lift
						fade.quad(slot, piece, [p0, p1, p2, p3], [Vector2(ua, band_v(slot, y0)), Vector2(ub, band_v(slot, y0)), Vector2(ub, band_v(slot, y1)), Vector2(ua, band_v(slot, y1))], normal)
				# Nov 18 day: open air - no dark vault above the cornice (the wall ends in its cap at HALL_H)
			else:
				var u0: float = float(i) / EXTERIOR_BAY
				var u1: float = float(i + 1) / EXTERIOR_BAY
				if step == Vector2i(0, -1) or step == Vector2i(1, 0):
					u0 = -u0
					u1 = -u1
				var e0: Vector3 = origin + dir_along * x0 + lift
				var e1: Vector3 = origin + dir_along * x1 + lift
				var top: Vector3 = Vector3(0, HALL_H, 0)
				fade.quad("exterior", piece, [e0, e1, e1 + top, e0 + top], [Vector2(u0, 1.0), Vector2(u1, 1.0), Vector2(u1, 0.0), Vector2(u0, 0.0)], normal)
			# the top of the wall cell: a brass-capped cornice at HALL_H (open air: seen from the plaza against the sky)
			fade.box("cap", piece, center + Vector3(0, HALL_H + 0.12, 0), Vector3(1.12, 0.24, 1.12))
		if inside and chunk_of.call(first) == chunk_key:
			for bay: Dictionary in bays:
				var at: float = float(bay["x0"])
				if at <= 0.5:
					continue
				var p: Vector3 = origin + dir_along * at + normal * 0.05
				joins.append({"pos": p, "normal": normal, "run": run_index, "length": length})
	return joins


# ---- Partitions ----------------------------------------------------------------------------------------------------------------


func _is_partition(c: Vector2i) -> bool:
	return kind_at(c) == Kind.PARTITION or kind_at(c) == Kind.OUTLINE


## Builds the partition on every partition cell of `cells` into `fade`; returns the post positions (run ends and joins).
func build_partitions(fade: DnaFadeMesh, cells: Array) -> Array[Vector3]:
	var posts: Array[Vector3] = []
	for cell: Variant in cells:
		var c: Vector2i = cell as Vector2i
		if kind_at(c) != Kind.PARTITION:
			continue
		var center: Vector3 = DnaLayout.cell_center(c.x, c.y)
		var piece: Vector4 = Vector4(center.x, center.z, 0.5, PARTITION_H)
		var east: bool = _is_partition(c + Vector2i(1, 0))
		var west: bool = _is_partition(c + Vector2i(-1, 0))
		var south: bool = _is_partition(c + Vector2i(0, 1))
		var north: bool = _is_partition(c + Vector2i(0, -1))
		# a two-cell-thick wall: the twin row (or column) beside a run is not a join - drop the link to it, so a thick wall reads as two
		# parallel partitions with posts only at their ends
		if (east or west) and north and _runs_x(c + Vector2i(0, -1)):
			north = false
		if (east or west) and south and _runs_x(c + Vector2i(0, 1)):
			south = false
		if (north or south) and east and _runs_z(c + Vector2i(1, 0)):
			east = false
		if (north or south) and west and _runs_z(c + Vector2i(-1, 0)):
			west = false
		var links: int = int(east) + int(west) + int(south) + int(north)
		var horizontal: bool = east or west
		var vertical: bool = north or south
		if not horizontal and not vertical:
			horizontal = true
		if horizontal:
			var x0: float = float(c.x) if west else center.x - PARTITION_T * 0.5
			var x1: float = float(c.x + 1) if east else center.x + PARTITION_T * 0.5
			_partition_span(fade, piece, Vector3(x0, 0, center.z), Vector3(x1, 0, center.z), true)
		if vertical:
			var z0: float = float(c.y) if north else center.z - PARTITION_T * 0.5
			var z1: float = float(c.y + 1) if south else center.z + PARTITION_T * 0.5
			_partition_span(fade, piece, Vector3(center.x, 0, z0), Vector3(center.x, 0, z1), false)
		var straight: bool = (links == 2 and ((east and west) or (north and south)))
		if not straight:
			posts.append(center)
	return posts


func _runs_x(c: Vector2i) -> bool:
	return _is_partition(c + Vector2i(1, 0)) and _is_partition(c + Vector2i(-1, 0))


func _runs_z(c: Vector2i) -> bool:
	return _is_partition(c + Vector2i(0, 1)) and _is_partition(c + Vector2i(0, -1))


func _partition_span(fade: DnaFadeMesh, piece: Vector4, a: Vector3, b: Vector3, along_x: bool) -> void:
	var half_t: float = PARTITION_T * 0.5
	var side: Vector3 = Vector3(0, 0, half_t) if along_x else Vector3(half_t, 0, 0)
	var ua: float = (a.x if along_x else a.z) / PARTITION_REPEAT
	var ub: float = (b.x if along_x else b.z) / PARTITION_REPEAT
	var top: Vector3 = Vector3(0, PARTITION_H, 0)
	for sgn: float in [1.0, -1.0]:
		var off: Vector3 = side * sgn
		var normal: Vector3 = off.normalized()
		var mirror: bool = normal.x > 0.5 or normal.z < -0.5
		var u0: float = -ua if mirror else ua
		var u1: float = -ub if mirror else ub
		fade.quad("partition", piece, [a + off, b + off, b + off + top, a + off + top], [Vector2(u0, 1.0), Vector2(u1, 1.0), Vector2(u1, 0.0), Vector2(u0, 0.0)], normal)
	fade.box("cap", piece, (a + b) * 0.5 + Vector3(0, PARTITION_H + 0.03, 0), Vector3(absf(b.x - a.x) + (0.06 if along_x else PARTITION_T + 0.08), 0.06, absf(b.z - a.z) + (PARTITION_T + 0.08 if along_x else 0.06)))


# ---- Floor, runners, ceiling ---------------------------------------------------------------------------------------------------


static var _marble: ShaderMaterial
static var _runner: ShaderMaterial


static func marble_material() -> ShaderMaterial:
	if _marble == null:
		_marble = ShaderMaterial.new()
		_marble.shader = load("res://world/dna/dna_hall_floor.gdshader") as Shader
		_marble.set_shader_parameter("albedo_tex", EnvKit.texture("DNA-FLOOR-MARBLE"))
		_marble.set_shader_parameter("tile", 2.6)
		_marble.set_shader_parameter("tint", Color(0.92, 0.9, 0.86))
		_marble.set_meta(PaintedClasses.META_NO_PAINT, true)
		_marble.set_meta(StyleToon.META_NO_TOON, true)
	return _marble


static func runner_material() -> ShaderMaterial:
	if _runner == null:
		_runner = ShaderMaterial.new()
		_runner.shader = load("res://world/dna/dna_hall_floor.gdshader") as Shader
		_runner.set_shader_parameter("albedo_tex", EnvKit.texture("DNA-FLOOR-RUNNER"))
		_runner.set_shader_parameter("world_uv", false)
		_runner.set_shader_parameter("roughness_value", 0.9)
		_runner.set_shader_parameter("specular_value", 0.15)
		_runner.set_meta(PaintedClasses.META_NO_PAINT, true)
		_runner.set_meta(StyleToon.META_NO_TOON, true)
	return _runner


static func reset_cache() -> void:
	_marble = null
	_runner = null


## The runners as one mesh (y just above the floor; v runs along in RUNNER_W * 2 m repeats).
static func runner_mesh() -> ArrayMesh:
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	tool.set_normal(Vector3.UP)
	for run: Array in RUNNERS:
		var a: Vector2 = run[0] as Vector2
		var b: Vector2 = run[1] as Vector2
		var d: Vector2 = (b - a).normalized()
		var n: Vector2 = Vector2(-d.y, d.x) * RUNNER_W * 0.5
		var length: float = a.distance_to(b)
		var v1: float = length / (RUNNER_W * 2.0)
		var pts: Array[Vector3] = [Vector3(a.x - n.x, 0.012, a.y - n.y), Vector3(a.x + n.x, 0.012, a.y + n.y), Vector3(b.x + n.x, 0.012, b.y + n.y), Vector3(b.x - n.x, 0.012, b.y - n.y)]
		var uvs: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(1, v1), Vector2(0, v1)]
		var order: Array[int] = [0, 1, 2, 0, 2, 3]
		if (pts[1] - pts[0]).cross(pts[2] - pts[0]).y < 0.0:
			order = [0, 3, 2, 0, 2, 1]
		for k: int in range(order.size() - 1, -1, -1):
			tool.set_uv(uvs[order[k]])
			tool.add_vertex(pts[order[k]])
	return tool.commit()


## True when the floor cell lies on a runner (the props keep off it).
static func on_runner(x: float, z: float) -> bool:
	for run: Array in RUNNERS:
		var a: Vector2 = run[0] as Vector2
		var b: Vector2 = run[1] as Vector2
		var p: Vector2 = Vector2(x, z)
		var t: float = clampf((p - a).dot(b - a) / maxf((b - a).length_squared(), 0.001), 0.0, 1.0)
		if p.distance_to(a + (b - a) * t) < RUNNER_W * 0.5 + 0.2:
			return true
	return false
