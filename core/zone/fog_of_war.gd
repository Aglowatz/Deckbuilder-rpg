class_name FogOfWar
extends RefCounted
## Fog of war for one walkable area: a grid of 1 m cells, each revealed or not. Exploring reveals a
## disc around the player. Pure data (no scene tree) so reveal and persistence are unit-tested; the
## minimap only draws it. Saved per zone through `Session.map_fog` (see `to_dict` / `from_dict`).

const CELL: float = 1.0
## How far around the player the world is revealed, in metres.
const REVEAL_RADIUS: float = 9.0

var origin: Vector2 = Vector2.ZERO
var width: int = 0
var height: int = 0
var revealed: PackedByteArray = PackedByteArray()


static func for_bounds(bounds: Rect2) -> FogOfWar:
	var fog: FogOfWar = FogOfWar.new()
	fog.origin = Vector2(floorf(bounds.position.x), floorf(bounds.position.y))
	fog.width = maxi(1, int(ceilf(bounds.end.x - fog.origin.x)))
	fog.height = maxi(1, int(ceilf(bounds.end.y - fog.origin.y)))
	fog.revealed.resize(fog.width * fog.height)
	return fog


func cell_of(world_xz: Vector2) -> Vector2i:
	return Vector2i(int(floorf((world_xz.x - origin.x) / CELL)), int(floorf((world_xz.y - origin.y) / CELL)))


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func is_cell_revealed(cell: Vector2i) -> bool:
	return in_bounds(cell) and revealed[cell.y * width + cell.x] != 0


func is_revealed(world_xz: Vector2) -> bool:
	return is_cell_revealed(cell_of(world_xz))


func revealed_count() -> int:
	var count: int = 0
	for value: int in revealed:
		if value != 0:
			count += 1
	return count


## Reveals every cell whose centre is within `radius` of `world_xz`. Returns the newly revealed cells.
func reveal(world_xz: Vector2, radius: float = REVEAL_RADIUS) -> Array[Vector2i]:
	var fresh: Array[Vector2i] = []
	var low: Vector2i = cell_of(world_xz - Vector2(radius, radius))
	var high: Vector2i = cell_of(world_xz + Vector2(radius, radius))
	for cy: int in range(maxi(low.y, 0), mini(high.y, height - 1) + 1):
		for cx: int in range(maxi(low.x, 0), mini(high.x, width - 1) + 1):
			var centre: Vector2 = origin + Vector2(float(cx) + 0.5, float(cy) + 0.5) * CELL
			if centre.distance_squared_to(world_xz) > radius * radius:
				continue
			var index: int = cy * width + cx
			if revealed[index] == 0:
				revealed[index] = 1
				fresh.append(Vector2i(cx, cy))
	return fresh


func to_dict() -> Dictionary:
	return {
		"ox": origin.x, "oz": origin.y, "w": width, "h": height,
		"data": Marshalls.raw_to_base64(revealed.compress(FileAccess.COMPRESSION_DEFLATE)),
	}


## Restores a saved fog. If the area's size changed since the save (the map was edited), the saved
## cells are copied where they still overlap instead of being thrown away.
static func from_dict(data: Dictionary, bounds: Rect2) -> FogOfWar:
	var fog: FogOfWar = FogOfWar.for_bounds(bounds)
	if data.is_empty():
		return fog
	var saved_w: int = int(data.get("w", 0))
	var saved_h: int = int(data.get("h", 0))
	var packed: PackedByteArray = Marshalls.base64_to_raw(str(data.get("data", "")))
	if packed.is_empty() or saved_w <= 0 or saved_h <= 0:
		return fog
	var raw: PackedByteArray = packed.decompress(saved_w * saved_h, FileAccess.COMPRESSION_DEFLATE)
	if raw.size() != saved_w * saved_h:
		return fog
	var saved_origin: Vector2 = Vector2(float(data.get("ox", 0.0)), float(data.get("oz", 0.0)))
	for cy: int in range(saved_h):
		for cx: int in range(saved_w):
			if raw[cy * saved_w + cx] == 0:
				continue
			var cell: Vector2i = fog.cell_of(saved_origin + Vector2(float(cx) + 0.5, float(cy) + 0.5) * CELL)
			if fog.in_bounds(cell):
				fog.revealed[cell.y * fog.width + cell.x] = 1
	return fog
