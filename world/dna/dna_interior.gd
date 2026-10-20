class_name DnaInterior
extends RefCounted
## The D.N.A. as the inside of a huge government office building (Oct 19): full-height partition walls round every room (the former knee-high balustrades),
## frosted-glass office fronts on the cubicle farms and the elevator bank, and (overnight Oct 19) wall sconces on the room faces instead of the ceiling beams,
## light strips and doorway headers, which ran across the top of the view and hid the hero. Everything here is built into `DnaFadeMesh` chunks, so every piece
## fades on its own when it stands between the camera and the hero, and a wall near the lens cuts away over a wide reach (`near_reach`): the hero is never hidden.
##
## Wall styles come from the room the wall cell borders: marble wainscot and wallpaper in the lobby and on the executive floor, paneling and frosted glass round
## the cubicle farms and the elevator bank, checkertile wainscot in the breakroom and the mail room, grey stone in the filing canyons and the records basement.

## The interior height of the office, floor to the (implied) ceiling: the hero is 0.68 m, so about six and a half heroes - a huge civic building.
const WALL_HEIGHT: float = 4.5
const WAINSCOT_H: float = 1.0
const GLASS_TOP: float = 2.3
## The building's outer shell (the perimeter wall cells with nothing but void beyond them to the west, east or north): much taller, so the top edge of the view
## shows the far wall of the building, not the sky.
const SHELL_HEIGHT: float = 9.0
## A doorway spans at most this many cells (wider gaps are open plan, not doors).
const MAX_DOOR_CELLS: int = 8
## How far round the sight line a wall cut-away reaches when the wall stands at the lens (metres, shrinking to the normal reach at the hero).
const WALL_NEAR_REACH: float = 7.0
## A sconce on every SCONCE_STEP-th wall cell, its shade SCONCE_Y above the floor; the pooled lights take SCONCE_LIGHT when they hop onto one.
const SCONCE_STEP: int = 4
const SCONCE_Y: float = 2.5
const SCONCE_LIGHT: Color = Color(0.86, 1.0, 0.8)

const GLASS_ROOMS: Array[String] = ["farm_a", "farm_b", "bank"]
const MARBLE_ROOMS: Array[String] = ["lobby", "exec"]
const TILE_ROOMS: Array[String] = ["breakroom", "mail"]

const GREY: Color = Color("6e7470")
const WALLPAPER: Color = Color("8e9a94")
const PANELING: Color = Color("4a5a52")
const MARBLE: Color = Color("b5b3a6")
const TILE: Color = Color("9aa8a0")
const GLASS: Color = Color("c2e6dc")
const SHADE: Color = Color("e4f7d8")


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
	fade.set_slot("sconce", "", SHADE, 1.0, 1.8, WALL_NEAR_REACH)
	# the soft pool of light a sconce throws on its wall (a faint glowing plate just off the face)
	fade.set_slot("wash", "", SHADE, 0.16, 0.9, WALL_NEAR_REACH)
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


## The wall sconces (overnight Oct 19, replacing the ceiling strips): a brass backplate with a glowing frosted shade on the room face of every fourth wall cell,
## between the pilasters. Returns the light positions (a little into the room) for the pooled OmniLights. A wall cell between two rooms gets one on each face.
static func build_sconces(layout: DnaLayout, fade: DnaFadeMesh, wall_cells: Array, shell: Dictionary) -> Array[Vector3]:
	var lights: Array[Vector3] = []
	for cell: Variant in wall_cells:
		var c: Vector2i = cell as Vector2i
		if posmod(c.x + c.y, SCONCE_STEP) != 2:
			continue
		var center: Vector3 = DnaLayout.cell_center(c.x, c.y)
		var top: float = SHELL_HEIGHT if shell.has(c) else WALL_HEIGHT
		var piece: Vector4 = Vector4(center.x, center.z, 0.5, top)
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + step
			if not layout.is_floor(n.x, n.y):
				continue
			var out: Vector3 = Vector3(float(step.x), 0.0, float(step.y))
			var across_x: bool = step.x != 0
			var face: Vector3 = center + out * 0.5 + Vector3(0, SCONCE_Y, 0)
			fade.box("brass", piece, face + out * 0.03, Vector3(0.06, 0.56, 0.38) if across_x else Vector3(0.38, 0.56, 0.06))
			fade.box("wash", piece, face + out * 0.015 + Vector3(0, 0.2, 0), Vector3(0.01, 1.6, 1.1) if across_x else Vector3(1.1, 1.6, 0.01))
			fade.box("sconce", piece, face + out * 0.12, Vector3(0.18, 0.36, 0.3) if across_x else Vector3(0.3, 0.36, 0.18))
			fade.box("brass", piece, face + out * 0.12 + Vector3(0, 0.17, 0), Vector3(0.2, 0.04, 0.3) if across_x else Vector3(0.3, 0.04, 0.2))
			lights.append(face + out * 0.7)
	return lights
