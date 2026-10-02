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


## World-space xz bounds (with a one-tile margin) of a set of cells (`Array` of `Vector2i`).
static func bounds_of(cells: Array) -> Rect2:
	if cells.is_empty():
		return Rect2()
	var low: Vector2 = Vector2(1e9, 1e9)
	var high: Vector2 = Vector2(-1e9, -1e9)
	for cell: Variant in cells:
		var pos: Vector3 = cell_to_world((cell as Vector2i).x, (cell as Vector2i).y)
		low = Vector2(minf(low.x, pos.x), minf(low.y, pos.z))
		high = Vector2(maxf(high.x, pos.x), maxf(high.y, pos.z))
	return Rect2(low - Vector2(WIDTH, WIDTH), high - low + Vector2(WIDTH, WIDTH) * 2.0)
