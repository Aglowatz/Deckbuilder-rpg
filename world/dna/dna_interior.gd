class_name DnaInterior
extends RefCounted
## The D.N.A. as the inside of a huge government office building (Oct 19): full-height partition walls round every room (the former knee-high balustrades),
## doorway headers over every opening, ceiling beams and fluorescent light strips over every room (the ceiling is implied at the top edge of the view) and
## frosted-glass office fronts on the cubicle farms and the elevator bank. Everything here is built into `DnaFadeMesh` chunks, so every piece fades on its own
## when it stands between the camera and the hero, and a wall near the lens cuts away over a wide reach (`near_reach`): the hero is never hidden.
##
## Wall styles come from the room the wall cell borders: marble wainscot and wallpaper in the lobby and on the executive floor, paneling and frosted glass round
## the cubicle farms and the elevator bank, checkertile wainscot in the breakroom and the mail room, grey stone in the filing canyons and the records basement.

## The interior height of the office (the hero is 0.68 m: about four and a half heroes, a huge civic building).
const WALL_HEIGHT: float = 3.0
## Where the ceiling beams run and the light strips hang.
const BEAM_Y: float = WALL_HEIGHT + 0.12
const STRIP_Y: float = WALL_HEIGHT - 0.28
const WAINSCOT_H: float = 1.0
const GLASS_TOP: float = 2.3
## Beams every BEAM_STEP metres across a room, split into pieces at most BEAM_PIECE long (each piece fades on its own); a light strip every STRIP_STEP along a beam.
const BEAM_STEP: int = 4
const BEAM_PIECE: float = 3.0
const STRIP_STEP: int = 4
## The building's outer shell (the perimeter wall cells with nothing but void beyond them to the west, east or north): much taller, so the top edge of the view
## shows the far wall of the building, not the sky.
const SHELL_HEIGHT: float = 9.0
## A doorway header spans at most this many cells (wider gaps are open plan, not doors).
const MAX_DOOR_CELLS: int = 8
## How far round the sight line a wall cut-away reaches when the wall stands at the lens (metres, shrinking to the normal reach at the hero).
const WALL_NEAR_REACH: float = 7.0
const BEAM_NEAR_REACH: float = 3.0

const GLASS_ROOMS: Array[String] = ["farm_a", "farm_b", "bank"]
const MARBLE_ROOMS: Array[String] = ["lobby", "exec"]
const TILE_ROOMS: Array[String] = ["breakroom", "mail"]

const GREY: Color = Color("6e7470")
const WALLPAPER: Color = Color("8e9a94")
const PANELING: Color = Color("4a5a52")
const MARBLE: Color = Color("b5b3a6")
const TILE: Color = Color("9aa8a0")
const BEAM: Color = Color("8c948e")
const GLASS: Color = Color("c2e6dc")
const TUBE: Color = Color("bfe9d2")


## A fade mesh with every interior slot.
static func mesh() -> DnaFadeMesh:
	var fade: DnaFadeMesh = DnaFadeMesh.new()
	fade.set_slot("wallpaper", "TEX-DNA-WALLPAPER", WALLPAPER, 1.0, 0.0, WALL_NEAR_REACH, 1.5)
	fade.set_slot("paneling", "TEX-DNA-PANELING", Color.WHITE, 1.0, 0.0, WALL_NEAR_REACH)
	fade.set_slot("marble", "TEX-DNA-MARBLE", Color.WHITE, 1.0, 0.0, WALL_NEAR_REACH)
	fade.set_slot("tile", "TEX-DNA-CHECKERTILE", Color.WHITE, 1.0, 0.0, WALL_NEAR_REACH)
	fade.set_slot("grey", "DNA-WALL-GREY", Color.WHITE, 1.0, 0.0, WALL_NEAR_REACH)
	fade.set_slot("shell", "DNA-WALL-GREY", Color(0.9, 0.92, 0.9), 1.0, 0.0, WALL_NEAR_REACH, 3.0)
	fade.set_slot("brass", "DNA-TRIM-BRASS", Color.WHITE, 1.0, 0.0, WALL_NEAR_REACH)
	fade.set_slot("glass", "", GLASS, 0.42, 0.12, WALL_NEAR_REACH)
	fade.set_slot("beam", "DNA-WALL-GREY", BEAM, 1.0, 0.0, BEAM_NEAR_REACH)
	fade.set_slot("housing", "", Color("4a5456"), 1.0, 0.0, BEAM_NEAR_REACH)
	fade.set_slot("tube", "", TUBE, 1.0, 0.6, BEAM_NEAR_REACH)
	return fade


## The id of the room a wall cell borders ("" for a wall along the approach causeway or a corridor).
static func room_beside(layout: DnaLayout, c: Vector2i) -> String:
	for ring: Array in [[Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)], [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]]:
		for step: Vector2i in ring:
			var n: Vector2i = c + step
			if layout.is_floor(n.x, n.y) or layout.cell_at(n.x, n.y) == DnaLayout.Cell.SOLID:
				var room: DnaLayout.Room = layout.room_at(DnaLayout.cell_center(n.x, n.y))
				if room != null:
					return room.id
	return ""


## The wall style of a room: "marble", "glass", "tile" or "grey".
static func style_for(room_id: String) -> String:
	if MARBLE_ROOMS.has(room_id):
		return "marble"
	if GLASS_ROOMS.has(room_id):
		return "glass"
	if TILE_ROOMS.has(room_id):
		return "tile"
	return "grey"


## The full-height walls of one chunk: a wall cell is one fading piece (centre, half width 0.5, top WALL_HEIGHT) built from a few boxes in the room's style.
static func build_walls(layout: DnaLayout, fade: DnaFadeMesh, wall_cells: Array, shell: Dictionary) -> void:
	for cell: Variant in wall_cells:
		var c: Vector2i = cell as Vector2i
		if shell.has(c):
			build_shell_wall(fade, c)
			continue
		var center: Vector3 = DnaLayout.cell_center(c.x, c.y)
		var piece: Vector4 = Vector4(center.x, center.z, 0.5, WALL_HEIGHT)
		var style: String = style_for(room_beside(layout, c))
		var pilaster: bool = (c.x + c.y) % 4 == 0
		match style:
			"marble":
				fade.box("wallpaper", piece, center + Vector3(0, WALL_HEIGHT * 0.5, 0), Vector3(1.0, WALL_HEIGHT, 1.0), Color.WHITE, 0.9)
				fade.box("marble", piece, center + Vector3(0, WAINSCOT_H * 0.5, 0), Vector3(1.06, WAINSCOT_H, 1.06), Color.WHITE, 0.8)
				fade.box("brass", piece, center + Vector3(0, WAINSCOT_H + 0.03, 0), Vector3(1.1, 0.06, 1.1))
				if pilaster:
					fade.box("marble", piece, center + Vector3(0, WALL_HEIGHT * 0.5, 0), Vector3(0.7, WALL_HEIGHT, 1.12), Color(0.96, 0.96, 0.94), 0.85)
			"glass":
				fade.box("paneling", piece, center + Vector3(0, WAINSCOT_H * 0.5, 0), Vector3(1.0, WAINSCOT_H, 1.0), Color.WHITE, 0.8)
				fade.box("brass", piece, center + Vector3(0, WAINSCOT_H + 0.03, 0), Vector3(1.04, 0.06, 1.04))
				fade.box("glass", piece, center + Vector3(0, (WAINSCOT_H + GLASS_TOP) * 0.5, 0), Vector3(1.0, GLASS_TOP - WAINSCOT_H, 0.5))
				fade.box("brass", piece, center + Vector3(0, (WAINSCOT_H + GLASS_TOP) * 0.5, 0), Vector3(0.08, GLASS_TOP - WAINSCOT_H, 0.64))
				fade.box("brass", piece, center + Vector3(0, GLASS_TOP + 0.03, 0), Vector3(1.04, 0.06, 1.04))
				fade.box("wallpaper", piece, center + Vector3(0, (GLASS_TOP + WALL_HEIGHT) * 0.5, 0), Vector3(1.0, WALL_HEIGHT - GLASS_TOP, 1.0), Color.WHITE, 1.0)
			"tile":
				fade.box("wallpaper", piece, center + Vector3(0, WALL_HEIGHT * 0.5, 0), Vector3(1.0, WALL_HEIGHT, 1.0), Color.WHITE, 0.9)
				fade.box("tile", piece, center + Vector3(0, WAINSCOT_H * 0.55, 0), Vector3(1.04, WAINSCOT_H * 1.1, 1.04), Color.WHITE, 0.8)
				fade.box("brass", piece, center + Vector3(0, WAINSCOT_H * 1.1 + 0.03, 0), Vector3(1.08, 0.05, 1.08))
			_:
				fade.box("grey", piece, center + Vector3(0, WALL_HEIGHT * 0.5, 0), Vector3(1.0, WALL_HEIGHT, 1.0), Color.WHITE, 0.82)
				fade.box("brass", piece, center + Vector3(0, WAINSCOT_H + 0.03, 0), Vector3(1.06, 0.05, 1.06))
				if pilaster:
					fade.box("grey", piece, center + Vector3(0, WALL_HEIGHT * 0.5, 0), Vector3(0.6, WALL_HEIGHT, 1.1), Color(1.08, 1.08, 1.06), 0.85)
		# the cap along the top of every wall
		fade.box("brass", piece, center + Vector3(0, WALL_HEIGHT + 0.03, 0), Vector3(1.06, 0.06, 1.06))


## The wall cells of the building's outer shell: Vector2i -> true. A wall cell is shell when no floor lies west, east or north of it within a band of SHELL_WINDOW
## rows (or columns) either side, so the gaps between rooms never count as outside, only the building's outline does (the south is where the way in is and where
## the camera stands: never shell).
const SHELL_WINDOW: int = 6


static func shell_cells(layout: DnaLayout) -> Dictionary:
	var row_min: PackedInt32Array = PackedInt32Array()
	var row_max: PackedInt32Array = PackedInt32Array()
	var col_min: PackedInt32Array = PackedInt32Array()
	row_min.resize(DnaLayout.H)
	row_max.resize(DnaLayout.H)
	col_min.resize(DnaLayout.W)
	for cz: int in range(DnaLayout.H):
		row_min[cz] = 99999
		row_max[cz] = -1
	for cx: int in range(DnaLayout.W):
		col_min[cx] = 99999
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			var kind: DnaLayout.Cell = layout.cell_at(cx, cz)
			if kind == DnaLayout.Cell.FLOOR or kind == DnaLayout.Cell.SOLID:
				row_min[cz] = mini(row_min[cz], cx)
				row_max[cz] = maxi(row_max[cz], cx)
				col_min[cx] = mini(col_min[cx], cz)
	var result: Dictionary = {}
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			if layout.cell_at(cx, cz) != DnaLayout.Cell.WALL:
				continue
			var west: int = 99999
			var east: int = -1
			for dz: int in range(-SHELL_WINDOW, SHELL_WINDOW + 1):
				if cz + dz >= 0 and cz + dz < DnaLayout.H:
					west = mini(west, row_min[cz + dz])
					east = maxi(east, row_max[cz + dz])
			var north: int = 99999
			for dx: int in range(-SHELL_WINDOW, SHELL_WINDOW + 1):
				if cx + dx >= 0 and cx + dx < DnaLayout.W:
					north = mini(north, col_min[cx + dx])
			if cx < west or cx > east or cz < north:
				result[Vector2i(cx, cz)] = true
	return result


## The outer shell on a wall cell: a SHELL_HEIGHT stone wall with a brass rail every three metres and a frosted clerestory band near the top.
static func build_shell_wall(fade: DnaFadeMesh, c: Vector2i) -> void:
	var center: Vector3 = DnaLayout.cell_center(c.x, c.y)
	var piece: Vector4 = Vector4(center.x, center.z, 0.5, SHELL_HEIGHT)
	fade.box("shell", piece, center + Vector3(0, SHELL_HEIGHT * 0.5, 0), Vector3(1.0, SHELL_HEIGHT, 1.0), Color.WHITE, 0.8)
	for rail_y: float in [3.0, 6.0]:
		fade.box("brass", piece, center + Vector3(0, rail_y + 0.03, 0), Vector3(1.08, 0.08, 1.08))
	fade.box("glass", piece, center + Vector3(0, 7.2, 0), Vector3(1.0, 1.6, 1.12))
	fade.box("brass", piece, center + Vector3(0, 7.2, 0), Vector3(0.1, 1.6, 1.16))
	fade.box("brass", piece, center + Vector3(0, SHELL_HEIGHT + 0.04, 0), Vector3(1.1, 0.08, 1.1))


## The doorway openings in the wall lines: [{"a": Vector2i, "b": Vector2i}] (the first and last floor cell of a gap between two wall cells that continue the same
## straight wall line, at most MAX_DOOR_CELLS wide). The gate's opening is skipped (the gate landmark stands there).
static func doorways(layout: DnaLayout) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var gate_cell: Vector2i = DnaLayout.world_to_cell(layout.anchors.get("gate", Vector3(-100, 0, -100)) as Vector3)
	for cz: int in range(DnaLayout.H):
		for cx: int in range(DnaLayout.W):
			if layout.cell_at(cx, cz) != DnaLayout.Cell.WALL:
				continue
			for step: Vector2i in [Vector2i(1, 0), Vector2i(0, 1)]:
				var start: Vector2i = Vector2i(cx, cz)
				if layout.cell_at(start.x - step.x, start.y - step.y) != DnaLayout.Cell.WALL:
					continue
				var n: Vector2i = start + step
				var count: int = 0
				var crosses_gate: bool = false
				while layout.is_floor(n.x, n.y) and count <= MAX_DOOR_CELLS:
					if n == gate_cell:
						crosses_gate = true
					n += step
					count += 1
				if count < 2 or count > MAX_DOOR_CELLS or crosses_gate:
					continue
				if layout.cell_at(n.x, n.y) != DnaLayout.Cell.WALL or layout.cell_at(n.x + step.x, n.y + step.y) != DnaLayout.Cell.WALL:
					continue
				result.append({"a": start + step, "b": n - step})
	return result


## A header over a doorway: the wall continues above the opening, with a brass lintel under it.
static func build_header(fade: DnaFadeMesh, layout: DnaLayout, door: Dictionary) -> Vector3:
	var a: Vector3 = DnaLayout.cell_center((door["a"] as Vector2i).x, (door["a"] as Vector2i).y)
	var b: Vector3 = DnaLayout.cell_center((door["b"] as Vector2i).x, (door["b"] as Vector2i).y)
	var mid: Vector3 = (a + b) * 0.5
	var along_x: bool = absf(b.x - a.x) >= absf(b.z - a.z)
	var length: float = a.distance_to(b) + 1.0
	var style: String = style_for(room_beside(layout, door["a"] as Vector2i))
	var slot: String = "marble" if style == "marble" else ("grey" if style == "grey" else "wallpaper")
	var piece: Vector4 = Vector4(mid.x, mid.z, length * 0.5, WALL_HEIGHT)
	var head_h: float = WALL_HEIGHT - 2.2
	var size: Vector3 = Vector3(length, head_h, 1.0) if along_x else Vector3(1.0, head_h, length)
	fade.box(slot, piece, mid + Vector3(0, 2.2 + head_h * 0.5, 0), size, Color.WHITE, 0.9, 2.16)
	fade.box("brass", piece, mid + Vector3(0, 2.2 - 0.04, 0), Vector3(length + 0.1, 0.08, 1.08) if along_x else Vector3(1.08, 0.08, length + 0.1), Color.WHITE, 1.0, 2.16)
	fade.box("brass", piece, mid + Vector3(0, WALL_HEIGHT + 0.03, 0), Vector3(length + 0.06, 0.06, 1.06) if along_x else Vector3(1.06, 0.06, length + 0.06), Color.WHITE, 1.0, 2.16)
	return mid


## Ceiling beams across a room every BEAM_STEP metres, in pieces, with a fluorescent strip (housing + tube) every STRIP_STEP metres along each beam. Returns the
## pieces as {"pos": Vector3, "fn": Callable(fade)} so the builder can put each into the chunk mesh its centre falls in.
static func ceiling_pieces(room: DnaLayout.Room) -> Array[Dictionary]:
	var pieces: Array[Dictionary] = []
	var r: Rect2i = room.rect
	var z: int = r.position.y + BEAM_STEP / 2
	while z < r.end.y:
		var beam_z: float = float(z)
		var x: float = float(r.position.x)
		var x_end: float = float(r.end.x)
		while x < x_end - 0.01:
			var length: float = minf(BEAM_PIECE, x_end - x)
			var mid: Vector3 = Vector3(x + length * 0.5, BEAM_Y, beam_z)
			pieces.append({"pos": mid, "kind": "beam", "length": length})
			x += length
		var sx: int = r.position.x + STRIP_STEP / 2
		while sx < r.end.x - 1:
			pieces.append({"pos": Vector3(float(sx) + 0.5, STRIP_Y, beam_z), "kind": "strip", "length": 2.2})
			sx += STRIP_STEP
		z += BEAM_STEP
	return pieces


static func build_ceiling_piece(fade: DnaFadeMesh, entry: Dictionary) -> void:
	var pos: Vector3 = entry["pos"] as Vector3
	var length: float = float(entry["length"])
	match str(entry["kind"]):
		"beam":
			var piece: Vector4 = Vector4(pos.x, pos.z, length * 0.5, pos.y + 0.17)
			fade.box("beam", piece, pos, Vector3(length, 0.34, 0.45), Color.WHITE, 0.9, pos.y - 0.17)
		"strip":
			var piece: Vector4 = Vector4(pos.x, pos.z, length * 0.5, BEAM_Y)
			var bottom: float = pos.y - 0.04
			fade.box("housing", piece, pos + Vector3(0, -0.02, 0), Vector3(length + 0.2, 0.06, 0.74), Color.WHITE, 1.0, bottom)
			fade.box("tube", piece, pos + Vector3(0, 0.04, 0), Vector3(length, 0.1, 0.6), Color.WHITE, 1.0, bottom)
			# the hangers up to the beam
			for sign_value: float in [-1.0, 1.0]:
				fade.box("housing", piece, pos + Vector3(sign_value * (length * 0.5 - 0.15), (BEAM_Y - pos.y) * 0.5, 0), Vector3(0.05, BEAM_Y - pos.y, 0.05), Color.WHITE, 1.0, bottom)
