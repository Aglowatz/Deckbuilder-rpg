class_name HexGrid
extends RefCounted
## Pointy-top hexagon grid matching the KayKit hex tiles (2.0 wide flat-to-flat, top at y = 0).
## Cells use "odd-r" offset coordinates: (col, row), odd rows shifted half a tile to the right.

const WIDTH: float = 2.0
const RADIUS: float = 2.0 / 1.7320508
const ROW_SPACING: float = 1.5 * RADIUS


static func cell_to_world(col: int, row: int) -> Vector3:
	var x: float = WIDTH * (float(col) + 0.5 * float(row & 1))
	return Vector3(x, 0.0, ROW_SPACING * float(row))


## Which cell contains the world position (x, z)?
static func world_to_cell(pos: Vector3) -> Vector2i:
	var r: float = pos.z / ROW_SPACING
	var q: float = pos.x / WIDTH - r * 0.5
	var s: float = -q - r
	var rq: float = roundf(q)
	var rs: float = roundf(s)
	var rr: float = roundf(r)
	var dq: float = absf(rq - q)
	var ds: float = absf(rs - s)
	var dr: float = absf(rr - r)
	if dq > ds and dq > dr:
		rq = -rs - rr
	elif ds > dr:
		rs = -rq - rr
	else:
		rr = -rq - rs
	var row: int = int(rr)
	var col: int = int(rq) + (row - (row & 1)) / 2
	return Vector2i(col, row)
