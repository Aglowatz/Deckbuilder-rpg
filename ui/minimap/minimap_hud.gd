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
## UI art kit: the round frame (UI-MINIMAP-FRAME) fits the 250x250 box; its transparent circle (centre x 0.5, y 0.533, radius 0.354 of the frame width) shows the map.
const FRAME_CENTER: Vector2 = Vector2(125.0, 133.3)
const FRAME_RADIUS: float = 88.0

var area_id: String = ""
var fog: FogOfWar
var raster: MapRaster
var pois: Array[MapPoi] = []

var _map: WalkableArea
var _player: TownPlayer
var _poi_source: Callable
var _reveal_timer: float = 0.0
var _poi_timer: float = 0.0
## Metres across the window: the whole area for tiny ones (the starting clearing), `VIEW_SPAN` otherwise.
var _view_span: float = VIEW_SPAN
var _framed: bool = false


func setup(zone_or_area_id: String, map: WalkableArea, hero: TownPlayer, poi_source: Callable = Callable()) -> void:
	area_id = zone_or_area_id
	_map = map
	_player = hero
	_poi_source = poi_source
	fog = Session.fog_for(area_id, map.map_bounds())
	var extent: Vector2 = map.map_bounds().size
	_view_span = clampf(maxf(extent.x, extent.y) + 6.0, 24.0, VIEW_SPAN)
	raster = MapRaster.build(map, fog)
	raster.apply_reveal(fog.reveal(Vector2(hero.position.x, hero.position.z)))
	_refresh_pois()


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	position = Vector2(1650, 20)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_framed = UiArt.has("UI-MINIMAP-FRAME")
	clip_contents = not _framed
	if _framed:
		_add_frame()
	visible = Settings.show_minimap
	Settings.minimap_toggled.connect(func(now: bool) -> void: visible = now)
	gui_input.connect(_on_gui_input)


func _add_frame() -> void:
	var mask: ShaderMaterial = ShaderMaterial.new()
	mask.shader = load("res://ui/shaders/circle_mask.gdshader") as Shader
	mask.set_shader_parameter("center", FRAME_CENTER)
	mask.set_shader_parameter("radius", FRAME_RADIUS)
	material = mask
	var frame: TextureRect = TextureRect.new()
	frame.texture = UiArt.texture("UI-MINIMAP-FRAME")
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.size = SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# A child does not inherit the mask: the frame is drawn whole, over the map.
	add_child(frame)


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
	if _framed:
		_draw_framed()
		return
	var scale_px: float = SIZE.x / _view_span
	var centre_xz: Vector2 = Vector2(_player.position.x, _player.position.z)
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.04, 0.05, 0.08, 0.82))
	var centre_px: Vector2 = raster.to_pixel(centre_xz)
	var half: Vector2 = Vector2(_view_span, _view_span) * 0.5
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


func _draw_framed() -> void:
	var window: Rect2 = Rect2(FRAME_CENTER - Vector2(FRAME_RADIUS, FRAME_RADIUS), Vector2(FRAME_RADIUS, FRAME_RADIUS) * 2.0)
	var scale_px: float = window.size.x / _view_span
	var centre_xz: Vector2 = Vector2(_player.position.x, _player.position.z)
	draw_rect(window, Color(0.04, 0.05, 0.08, 0.9))
	var centre_px: Vector2 = raster.to_pixel(centre_xz)
	var half: Vector2 = Vector2(_view_span, _view_span) * 0.5
	draw_texture_rect_region(raster.texture, window, Rect2(centre_px - half, half * 2.0))
	for poi: MapPoi in MapView.visible_pois(pois, fog):
		var offset: Vector2 = (Vector2(poi.pos.x, poi.pos.z) - centre_xz) * scale_px
		if offset.length() > FRAME_RADIUS - 8.0:
			continue
		MapDraw.poi(self, FRAME_CENTER + offset, poi, 8.0)
	MapDraw.arrow(self, FRAME_CENTER, _player.model.rotation.y, 9.0)
