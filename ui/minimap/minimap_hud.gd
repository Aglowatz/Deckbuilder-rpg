class_name MinimapHud
extends Control
## The HUD minimap (north-up): a window of the explored map around the player with the fog of war,
## points of interest once revealed, and an arrow showing which way the hero faces. North-up was
## chosen over a rotating map because the game camera never rotates - up on the map is up on screen.
## Exploring reveals the world (`FogOfWar`, saved per area in `Session.map_fog`). Click it or press
## M for the full map. Hidden in Settings -> "Show minimap".

signal full_map_requested

const SIZE: Vector2 = Vector2(250, 250)
## Metres across the window.
const VIEW_SPAN: float = 42.0
const REVEAL_INTERVAL: float = 0.12
const POI_INTERVAL: float = 0.5

var area_id: String = ""
var fog: FogOfWar
var raster: MapRaster
var pois: Array[MapPoi] = []

var _map: WalkableArea
var _player: TownPlayer
var _poi_source: Callable
var _reveal_timer: float = 0.0
var _poi_timer: float = 0.0


func setup(zone_or_area_id: String, map: WalkableArea, hero: TownPlayer, poi_source: Callable = Callable()) -> void:
	area_id = zone_or_area_id
	_map = map
	_player = hero
	_poi_source = poi_source
	fog = Session.fog_for(area_id, map.map_bounds())
	raster = MapRaster.build(map, fog)
	raster.apply_reveal(fog.reveal(Vector2(hero.position.x, hero.position.z)))
	_refresh_pois()


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	position = Vector2(1640, 318)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	visible = Settings.show_minimap
	Settings.minimap_toggled.connect(func(now: bool) -> void: visible = now)
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		full_map_requested.emit()


func _refresh_pois() -> void:
	if _poi_source.is_valid():
		pois = _poi_source.call() as Array[MapPoi]


func _process(delta: float) -> void:
	if _player == null or fog == null:
		return
	_reveal_timer -= delta
	if _reveal_timer <= 0.0:
		_reveal_timer = REVEAL_INTERVAL
		raster.apply_reveal(fog.reveal(Vector2(_player.position.x, _player.position.z)))
	_poi_timer -= delta
	if _poi_timer <= 0.0:
		_poi_timer = POI_INTERVAL
		_refresh_pois()
	if visible:
		queue_redraw()


func _draw() -> void:
	if raster == null or _player == null:
		return
	var scale_px: float = SIZE.x / VIEW_SPAN
	var centre_xz: Vector2 = Vector2(_player.position.x, _player.position.z)
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.04, 0.05, 0.08, 0.82))
	var centre_px: Vector2 = raster.to_pixel(centre_xz)
	var half: Vector2 = Vector2(VIEW_SPAN, VIEW_SPAN) * 0.5
	draw_texture_rect_region(raster.texture, Rect2(Vector2.ZERO, SIZE), Rect2(centre_px - half, half * 2.0))
	for poi: MapPoi in MapView.visible_pois(pois, fog):
		var offset: Vector2 = (Vector2(poi.pos.x, poi.pos.z) - centre_xz) * scale_px
		var at: Vector2 = SIZE * 0.5 + offset
		if at.x < 8.0 or at.y < 8.0 or at.x > SIZE.x - 8.0 or at.y > SIZE.y - 8.0:
			continue
		MapDraw.poi(self, at, poi, 8.0)
	MapDraw.arrow(self, SIZE * 0.5, _player.model.rotation.y, 9.0)
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.82, 0.68, 0.32, 0.95), false, 3.0)
	draw_string(UIStyle.font_bold(), Vector2(SIZE.x * 0.5 - 6.0, 18.0), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1, 0.8))
	draw_string(UIStyle.font_bold(), Vector2(SIZE.x - 62.0, SIZE.y - 8.0), "M: map", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 1, 1, 0.75))
