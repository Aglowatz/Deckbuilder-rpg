class_name MapRaster
extends RefCounted
## The picture behind the minimap and the full map: one pixel per 1 m cell of the area. Unrevealed
## cells are transparent (fog), revealed ground is light with a darker rim, revealed non-ground is
## dim. The image is padded so a minimap window centred on any ground position stays inside it.

const PAD: int = 32
const COLOR_FLOOR: Color = Color(0.86, 0.80, 0.62, 0.95)
const COLOR_RIM: Color = Color(0.45, 0.38, 0.24, 0.95)
const COLOR_OFF: Color = Color(0.10, 0.12, 0.16, 0.80)
const COLOR_FOG: Color = Color(0, 0, 0, 0)

var fog: FogOfWar
var texture: ImageTexture
var image: Image
## Whether each cell (fog grid, unpadded) is ground.
var floor_cells: PackedByteArray = PackedByteArray()


static func build(map: WalkableArea, fog_of_war: FogOfWar) -> MapRaster:
	var raster: MapRaster = MapRaster.new()
	raster.fog = fog_of_war
	raster.floor_cells.resize(fog_of_war.width * fog_of_war.height)
	for cy: int in range(fog_of_war.height):
		for cx: int in range(fog_of_war.width):
			var centre: Vector2 = fog_of_war.origin + Vector2(float(cx) + 0.5, float(cy) + 0.5) * FogOfWar.CELL
			if map.is_floor_at(Vector3(centre.x, 0.0, centre.y)):
				raster.floor_cells[cy * fog_of_war.width + cx] = 1
	raster.image = Image.create(fog_of_war.width + PAD * 2, fog_of_war.height + PAD * 2, false, Image.FORMAT_RGBA8)
	raster.image.fill(COLOR_FOG)
	for cy: int in range(fog_of_war.height):
		for cx: int in range(fog_of_war.width):
			raster._paint(cx, cy)
	raster.texture = ImageTexture.create_from_image(raster.image)
	return raster


func is_floor(cx: int, cy: int) -> bool:
	return cx >= 0 and cy >= 0 and cx < fog.width and cy < fog.height and floor_cells[cy * fog.width + cx] != 0


func _paint(cx: int, cy: int) -> void:
	var color: Color = COLOR_FOG
	if fog.is_cell_revealed(Vector2i(cx, cy)):
		if not is_floor(cx, cy):
			color = COLOR_OFF
		else:
			var rim: bool = not (is_floor(cx - 1, cy) and is_floor(cx + 1, cy) and is_floor(cx, cy - 1) and is_floor(cx, cy + 1))
			color = COLOR_RIM if rim else COLOR_FLOOR
	image.set_pixel(cx + PAD, cy + PAD, color)


## Repaints newly revealed cells (and their neighbours, whose rims may change) and uploads.
func apply_reveal(cells: Array[Vector2i]) -> void:
	if cells.is_empty():
		return
	for cell: Vector2i in cells:
		for dy: int in range(-1, 2):
			for dx: int in range(-1, 2):
				var target: Vector2i = cell + Vector2i(dx, dy)
				if fog.in_bounds(target):
					_paint(target.x, target.y)
	texture.update(image)


## Pixel position of a world xz point in the padded image.
func to_pixel(world_xz: Vector2) -> Vector2:
	return (world_xz - fog.origin) / FogOfWar.CELL + Vector2(PAD, PAD)
