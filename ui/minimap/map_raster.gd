class_name MapRaster
extends RefCounted
## The picture behind the minimap and the full map: one pixel per 1 m cell of the area. Unrevealed
## cells are transparent (fog), revealed ground is light with a darker rim, revealed non-ground is
## dim. The image is padded so a minimap window centred on any ground position stays inside it.
## Overnight Oct 17 (Phase 2 cycle 24): the ground is drawn in three shades - open ground, paths (cobble, stone, wood and the like) and
## blocked ground (buildings, walls, props) - so the map reads like a map. Telling them apart is slow (a walkability test per cell, ~0.5 s for the
## town), so `build` draws plain ground first and `refine` sorts the cells a few rows per frame; the result is kept per area and reused.

const PAD: int = 32
const COLOR_FLOOR: Color = Color(0.86, 0.80, 0.62, 0.95)
const COLOR_RIM: Color = Color(0.45, 0.38, 0.24, 0.95)
const COLOR_OFF: Color = Color(0.10, 0.12, 0.16, 0.80)
const COLOR_FOG: Color = Color(0, 0, 0, 0)
## Fix pass Nov 7 (owner decision D5): roads read as roads - a darker, warmer band than open ground - and show through the fog as a faint
## skeleton, so the way to a shop or an exit can be seen before it is walked. A zone (`outline`) also shows its walkable outline under the
## fog from the first arrival; towns stay black until explored.
const COLOR_PATH: Color = Color(0.62, 0.48, 0.30, 0.97)
const COLOR_ROAD_FOG: Color = Color(0.58, 0.46, 0.30, 0.5)
const COLOR_OUTLINE_FOG: Color = Color(0.70, 0.62, 0.44, 0.42)
const COLOR_BLOCK: Color = Color(0.5, 0.4, 0.28, 0.95)
## Cell kinds in `floor_cells`.
const NONE: int = 0
const GROUND: int = 1
const PATH: int = 2
const BLOCKED: int = 3
const PATH_SURFACES: Array[StringName] = [&"cobble", &"stone", &"marble", &"tile", &"wood", &"carpet", &"metal"]
## area instance id + bounds -> its cell kinds (the minimap and the full map of one visit share them).
static var _kind_cache: Dictionary = {}

var fog: FogOfWar
var texture: ImageTexture
var image: Image
## Whether each cell (fog grid, unpadded) is ground.
var floor_cells: PackedByteArray = PackedByteArray()


static func build(map: WalkableArea, fog_of_war: FogOfWar, outline: bool = false) -> MapRaster:
	var raster: MapRaster = MapRaster.new()
	raster.fog = fog_of_war
	raster.outline = outline
	raster._map = map
	raster._key = "%d|%s|%d|%d" % [map.get_instance_id(), str(fog_of_war.origin), fog_of_war.width, fog_of_war.height]
	if _kind_cache.has(raster._key):
		raster.floor_cells = _kind_cache[raster._key] as PackedByteArray
		raster.refined = true
	else:
		raster.floor_cells.resize(fog_of_war.width * fog_of_war.height)
		for cy: int in range(fog_of_war.height):
			for cx: int in range(fog_of_war.width):
				var centre: Vector2 = fog_of_war.origin + Vector2(float(cx) + 0.5, float(cy) + 0.5) * FogOfWar.CELL
				if map.is_floor_at(Vector3(centre.x, 0.0, centre.y)):
					raster.floor_cells[cy * fog_of_war.width + cx] = GROUND
	raster.image = Image.create(fog_of_war.width + PAD * 2, fog_of_war.height + PAD * 2, false, Image.FORMAT_RGBA8)
	raster.image.fill(COLOR_FOG)
	for cy: int in range(fog_of_war.height):
		for cx: int in range(fog_of_war.width):
			raster._paint(cx, cy)
	raster.texture = ImageTexture.create_from_image(raster.image)
	return raster


## Batch 15 pass (Part 3.6): the minimap draws a smoothed copy of the picture, DISPLAY_SCALE pixels per cell (a cubic enlargement made on
## the CPU when the picture changed, at most every DISPLAY_INTERVAL_MSEC). One pixel per metre stretched by the GPU was a blur in the small
## forest (a cell is ten screen pixels there) and stair-stepped blocks in the Capital; the enlarged copy keeps edges a third of a cell wide
## and rounds the steps. The full map keeps the plain picture (it is drawn nearer one to one).
const DISPLAY_SCALE: int = 3
const DISPLAY_INTERVAL_MSEC: int = 250
var _display: ImageTexture
var _display_dirty: bool = true
var _display_at: int = -100000


## The smoothed picture for the minimap (see DISPLAY_SCALE); a pixel of it is 1 / DISPLAY_SCALE of a cell.
func display_texture() -> Texture2D:
	var now: int = Time.get_ticks_msec()
	if _display == null or (_display_dirty and now - _display_at >= DISPLAY_INTERVAL_MSEC):
		var big: Image = image.duplicate() as Image
		big.resize(image.get_width() * DISPLAY_SCALE, image.get_height() * DISPLAY_SCALE, Image.INTERPOLATE_CUBIC)
		if _display == null:
			_display = ImageTexture.create_from_image(big)
		else:
			_display.update(big)
		_display_dirty = false
		_display_at = now
	return _display


## The region of `display_texture` that shows the cells of `cells` (a rect in the picture's own pixels).
static func display_region(cells: Rect2) -> Rect2:
	return Rect2(cells.position * float(DISPLAY_SCALE), cells.size * float(DISPLAY_SCALE))


var _map: WalkableArea
var _key: String = ""
## Fix pass Nov 7 (D5): draw the area's walkable outline under the fog (zones; never the towns).
var outline: bool = false
var _refine_row: int = 0
## True once every ground cell is sorted into open ground, path or blocked.
var refined: bool = false


## Sorts ground cells into open ground / path / blocked for up to `budget_usec` (whole rows), repaints what it sorted and uploads.
## Returns true when there is nothing left to do.
func refine(budget_usec: int = 3000) -> bool:
	if refined or _map == null:
		return true
	var started: int = Time.get_ticks_usec()
	var first_row: int = _refine_row
	while _refine_row < fog.height and Time.get_ticks_usec() - started < budget_usec:
		var cy: int = _refine_row
		for cx: int in range(fog.width):
			var index: int = cy * fog.width + cx
			if floor_cells[index] == NONE:
				continue
			var centre: Vector2 = fog.origin + Vector2(float(cx) + 0.5, float(cy) + 0.5) * FogOfWar.CELL
			var pos: Vector3 = Vector3(centre.x, 0.0, centre.y)
			var kind: int = GROUND
			if not _map.is_walkable(pos, 0.15):
				kind = BLOCKED
			elif PATH_SURFACES.has(_map.surface_at(pos)):
				kind = PATH
			floor_cells[index] = kind
		_refine_row += 1
	for cy: int in range(maxi(first_row - 1, 0), mini(_refine_row + 1, fog.height)):
		for cx: int in range(fog.width):
			_paint(cx, cy)
	texture.update(image)
	_display_dirty = true
	if _refine_row >= fog.height:
		refined = true
		if _kind_cache.size() > 8:
			_kind_cache.clear()
		_kind_cache[_key] = floor_cells
	return refined


func is_floor(cx: int, cy: int) -> bool:
	return cx >= 0 and cy >= 0 and cx < fog.width and cy < fog.height and floor_cells[cy * fog.width + cx] != NONE


func kind_at(cx: int, cy: int) -> int:
	return floor_cells[cy * fog.width + cx] if cx >= 0 and cy >= 0 and cx < fog.width and cy < fog.height else NONE


func _paint(cx: int, cy: int) -> void:
	var color: Color = COLOR_FOG
	if not fog.is_cell_revealed(Vector2i(cx, cy)):
		if kind_at(cx, cy) == PATH:
			color = COLOR_ROAD_FOG
		elif outline and is_floor(cx, cy) and not (is_floor(cx - 1, cy) and is_floor(cx + 1, cy) and is_floor(cx, cy - 1) and is_floor(cx, cy + 1)):
			color = COLOR_OUTLINE_FOG
	else:
		if not is_floor(cx, cy):
			color = COLOR_OFF
		else:
			var rim: bool = not (is_floor(cx - 1, cy) and is_floor(cx + 1, cy) and is_floor(cx, cy - 1) and is_floor(cx, cy + 1))
			var kind: int = kind_at(cx, cy)
			color = COLOR_RIM if rim else (COLOR_BLOCK if kind == BLOCKED else (COLOR_PATH if kind == PATH else COLOR_FLOOR))
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
	_display_dirty = true


## Fix pass Nov 7 (D5): the towns (Crosspath, the Capital) are explored; every other area shows its outline from the first arrival.
static func shows_outline(area_id: String) -> bool:
	return not (area_id in ["town", "capital", CapitalZone.ID])


## Pixel position of a world xz point in the padded image.
func to_pixel(world_xz: Vector2) -> Vector2:
	return (world_xz - fog.origin) / FogOfWar.CELL + Vector2(PAD, PAD)
