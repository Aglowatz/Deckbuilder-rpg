class_name FullMapScreen
extends OverlayScreen
## The full-screen map (M): the whole explored area with the fog of war, every revealed point of
## interest, the player's arrow and a legend of the icon kinds currently on the map.

var _area_id: String = ""
var _map: WalkableArea
var _player: TownPlayer
var _pois: Array[MapPoi] = []
var _canvas: Control
var _raster: MapRaster
var _fog: FogOfWar
var _area_name: String = ""


func setup(area_id: String, map: WalkableArea, hero: TownPlayer, points: Array[MapPoi], area_name: String) -> void:
	_area_id = area_id
	_map = map
	_player = hero
	_pois = points
	_area_name = area_name
	screen_title = "Map - %s" % area_name
	close_text = "Close (M)"
	background_id = "UI-BG-WORLDMAP"


func _build() -> void:
	_fog = Session.fog_for(_area_id, _map.map_bounds())
	_raster = MapRaster.build(_map, _fog)
	var row: HBoxContainer = UIKit.hbox(24)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	_canvas = Control.new()
	_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.draw.connect(_draw_map)
	row.add_child(_canvas)
	row.add_child(_legend())


func _legend() -> Control:
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.custom_minimum_size = Vector2(380, 0)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label("Legend", &"HeadingLabel", 30))
	var visible_points: Array[MapPoi] = MapView.visible_pois(_pois, _fog)
	var kinds: Array[MapPoi.Kind] = MapView.legend_kinds(visible_points)
	var arrow_row: HBoxContainer = UIKit.hbox(12)
	var arrow_icon: Control = Control.new()
	arrow_icon.custom_minimum_size = Vector2(34, 34)
	arrow_icon.draw.connect(func() -> void: MapDraw.arrow(arrow_icon, Vector2(17, 17), PI, 12.0))
	arrow_row.add_child(arrow_icon)
	arrow_row.add_child(UIKit.label("You (arrow = facing)", &"", 22))
	column.add_child(arrow_row)
	for kind: MapPoi.Kind in kinds:
		var entry: HBoxContainer = UIKit.hbox(12)
		var icon: Control = Control.new()
		icon.custom_minimum_size = Vector2(34, 34)
		var sample: MapPoi = MapPoi.make(kind, Vector3.ZERO, "")
		icon.draw.connect(func() -> void: MapDraw.poi(icon, Vector2(17, 17), sample, 13.0))
		entry.add_child(icon)
		entry.add_child(UIKit.label(MapPoi.kind_name(kind), &"", 22))
		column.add_child(entry)
	var badge_row: HBoxContainer = UIKit.hbox(12)
	var badge: Control = Control.new()
	badge.custom_minimum_size = Vector2(34, 34)
	var quest_sample: MapPoi = MapPoi.make(MapPoi.Kind.QUEST_GIVER, Vector3.ZERO, "", true)
	badge.draw.connect(func() -> void: MapDraw.poi(badge, Vector2(15, 19), quest_sample, 12.0))
	badge_row.add_child(badge)
	badge_row.add_child(UIKit.label("Quest available", &"", 22))
	column.add_child(badge_row)
	column.add_child(UIKit.label("Dark areas are unexplored. Walk around to reveal them.", &"MutedLabel", 18))
	return panel


func _draw_map() -> void:
	var area: Vector2 = _canvas.size
	_canvas.draw_rect(Rect2(Vector2.ZERO, area), Color(0.04, 0.05, 0.08, 0.9))
	var cells: Vector2 = Vector2(float(_fog.width), float(_fog.height))
	var scale_px: float = minf(area.x / cells.x, area.y / cells.y)
	var drawn: Vector2 = cells * scale_px
	var top_left: Vector2 = (area - drawn) * 0.5
	var source: Rect2 = Rect2(Vector2(MapRaster.PAD, MapRaster.PAD), cells)
	_canvas.draw_texture_rect_region(_raster.texture, Rect2(top_left, drawn), source)
	_canvas.draw_rect(Rect2(top_left, drawn), Color(0.82, 0.68, 0.32, 0.9), false, 2.0)
	var icon_radius: float = clampf(scale_px * 2.2, 9.0, 16.0)
	for poi: MapPoi in MapView.visible_pois(_pois, _fog):
		var at: Vector2 = top_left + (Vector2(poi.pos.x, poi.pos.z) - _fog.origin) / FogOfWar.CELL * scale_px
		MapDraw.poi(_canvas, at, poi, icon_radius)
	var here: Vector2 = top_left + (Vector2(_player.position.x, _player.position.z) - _fog.origin) / FogOfWar.CELL * scale_px
	MapDraw.arrow(_canvas, here, _player.model.rotation.y, icon_radius)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_M:
		get_viewport().set_input_as_handled()
		request_close()
		return
	super._unhandled_input(event)
