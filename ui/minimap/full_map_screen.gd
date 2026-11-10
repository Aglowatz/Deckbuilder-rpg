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
## Overnight Oct 30-31, Part 3: the Rift Express station of this area (FastTravel.TOWN or a zone id) when the map may offer fast travel
## ("" = no button: the forest before the postgame, scripted moments). The scene opens the travel list on `travel_requested`.
var travel_from: String = ""

signal travel_requested

## Overnight Oct 31 - Nov 1 (wish list): the place picked in "Where to?" pulses on the map for a few seconds.
const WHERE_TO_KINDS: Array[MapPoi.Kind] = [MapPoi.Kind.DUNGEON, MapPoi.Kind.MINI_DUNGEON, MapPoi.Kind.GATE, MapPoi.Kind.VENDOR, MapPoi.Kind.HEAL, MapPoi.Kind.ARENA,
	MapPoi.Kind.QUEST_GIVER, MapPoi.Kind.CHALLENGE, MapPoi.Kind.EXIT, MapPoi.Kind.TRAVEL_PORTAL, MapPoi.Kind.INTERACTABLE]
const WHERE_TO_MAX: int = 16
const PING_SECONDS: float = 4.0
var _ping: MapPoi = null
var _ping_left: float = 0.0


func setup(area_id: String, map: WalkableArea, hero: TownPlayer, points: Array[MapPoi], area_name: String) -> void:
	_area_id = area_id
	_map = map
	_player = hero
	_pois = points
	_area_name = area_name
	screen_title = "Map - %s" % area_name
	title_icon_id = "ICON-UI-MAP"
	close_text = "Close ({open_map})"
	background_id = "UI-BG-WORLDMAP"


func _build() -> void:
	_fog = Session.fog_for(_area_id, _map.map_bounds())
	_raster = MapRaster.build(_map, _fog, MapRaster.shows_outline(_area_id))
	# finish sorting the cells quickly while the map is open (the minimap usually has already)
	set_process(true)
	var row: HBoxContainer = UIKit.hbox(24)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	var canvas: MapCanvas = MapCanvas.new()  # Day pass Nov 9: a dungeon's level hint as a tooltip on its icon
	canvas.screen = self
	_canvas = canvas
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
	if IconArt.has("ICON-MAP-TURNIN"):
		var turn_row: HBoxContainer = UIKit.hbox(12)
		var turn_badge: Control = Control.new()
		turn_badge.custom_minimum_size = Vector2(34, 34)
		var turn_sample: MapPoi = MapPoi.make(MapPoi.Kind.QUEST_GIVER, Vector3.ZERO, "", true)
		turn_sample.turn_in = true
		turn_badge.draw.connect(func() -> void: MapDraw.poi(turn_badge, Vector2(15, 19), turn_sample, 12.0))
		turn_row.add_child(turn_badge)
		turn_row.add_child(UIKit.label("Quest ready to hand in", &"", 22))
		column.add_child(turn_row)
	# Overnight Oct 30-31, Part 2: the goals on this map by quest name (gold = main line, blue = side quest).
	for goal: MapPoi in _pois:
		if not goal.objective:
			continue
		var goal_row: HBoxContainer = UIKit.hbox(12)
		var ring: Control = Control.new()
		ring.custom_minimum_size = Vector2(34, 34)
		ring.draw.connect(func() -> void: MapDraw.poi(ring, Vector2(17, 17), goal, 11.0))
		goal_row.add_child(ring)
		var goal_label: Label = UIKit.label("Goal: %s" % goal.label, &"", 22)
		goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		goal_label.custom_minimum_size = Vector2(300, 0)
		goal_row.add_child(goal_label)
		column.add_child(goal_row)
	# Mid-game critic #11 (Oct 31 - Nov 1): the list names every place, walked to or not (the fog hides the ground, not the directory).
	var places: Array[MapPoi] = where_to_places(_pois)
	if not places.is_empty():
		var where: OptionButton = OptionButton.new()
		where.name = "WhereTo"
		where.add_theme_font_size_override("font_size", 20)
		where.custom_minimum_size = Vector2(300, 44)
		SettingsPanel.theme_popup(where)  # Fix pass Nov 7 (Part 5)
		where.add_item("Point me to...")  # Overnight Nov 9-10 (RC1 critic #8): it sets a pointer, it does not travel
		where.tooltip_text = "Pick a place: a white arrow leads you there after you close the map."
		for place: MapPoi in places:
			# Day pass Nov 9: a dungeon says its usual traveller level ("The Iron Cave (Mini dungeon, usually level 6)").
			var level_note: String = LevelHints.short_text(place.dungeon_id)
			where.add_item("%s (%s)" % [place.label, MapPoi.kind_name(place.kind) if level_note.is_empty() else "%s, %s" % [MapPoi.kind_name(place.kind), level_note]])
		where.item_selected.connect(func(index: int) -> void:
			if index > 0:
				ping(places[index - 1]))
		column.add_child(where)
	column.add_child(UIKit.label("Dark areas are unexplored. Walk around to reveal them.", &"MutedLabel", 18))
	if travel_from != "" and not FastTravel.destinations(Session.flags, travel_from).is_empty():
		var travel: FancyButton = FancyButton.make("Fast travel...", &"PrimaryButton", Vector2(300, 56))
		travel.name = "MapFastTravel"
		travel.pressed.connect(func() -> void: travel_requested.emit())
		column.add_child(travel)
		var travel_note: Label = UIKit.label("To a Rift Express station you have reached: Crosspath and the zones' towns (never into a dungeon).", &"MutedLabel", 17)
		travel_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		travel_note.custom_minimum_size = Vector2(340, 0)
		column.add_child(travel_note)
	return panel


## The named places a player looks for on this map, revealed or not: dungeons first, then vendors, healers, the Arena, quest givers, challengers,
## exits and the rest (the Deck Station, the Hall of Records, people), one per name, at most WHERE_TO_MAX.
static func where_to_places(points: Array[MapPoi]) -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	var names: Dictionary = {}
	for kind: MapPoi.Kind in WHERE_TO_KINDS:
		for poi: MapPoi in points:
			if poi.kind != kind or poi.objective or poi.label.strip_edges() == "" or names.has(poi.label):
				continue
			names[poi.label] = true
			result.append(poi)
			if result.size() >= WHERE_TO_MAX:
				return result
	return result


## Makes `poi` pulse on the map for PING_SECONDS.
func ping(poi: MapPoi) -> void:
	_ping = poi
	_ping_left = PING_SECONDS
	Session.where_to_target = {"area": _area_id, "pos": poi.pos, "label": poi.label}  # Fix pass Nov 7 (item 7): the arrow after the map closes
	Audio.sfx(&"ui_select")
	if _canvas != null:
		_canvas.queue_redraw()


func _draw_map() -> void:
	var area: Vector2 = _canvas.size
	var cells: Vector2 = Vector2(float(_fog.width), float(_fog.height))
	var scale_px: float = minf(area.x / cells.x, area.y / cells.y)
	var drawn: Vector2 = cells * scale_px
	var top_left: Vector2 = (area - drawn) * 0.5
	# Phase 2 cycle 17: only the map itself sits on a dark board with a soft shadow; the whole canvas used to be filled, leaving dead dark
	# strips either side of a square map.
	for step: int in range(4):
		var grow: float = 6.0 + float(step) * 6.0
		_canvas.draw_rect(Rect2(top_left - Vector2(grow, grow) + Vector2(0.0, 6.0), drawn + Vector2(grow, grow) * 2.0), Color(0.0, 0.0, 0.0, 0.1))
	_canvas.draw_rect(Rect2(top_left, drawn), Color(0.04, 0.05, 0.08, 0.95))
	var source: Rect2 = Rect2(Vector2(MapRaster.PAD, MapRaster.PAD), cells)
	_canvas.draw_texture_rect_region(_raster.texture, Rect2(top_left, drawn), source)
	_canvas.draw_rect(Rect2(top_left, drawn), Color(0.82, 0.68, 0.32, 0.9), false, 2.0)
	var icon_radius: float = clampf(scale_px * 2.2, 9.0, 16.0)
	var shown: Array[MapPoi] = MapView.visible_pois(_pois, _fog)
	_hint_spots = []
	for poi: MapPoi in shown:
		var at: Vector2 = top_left + (Vector2(poi.pos.x, poi.pos.z) - _fog.origin) / FogOfWar.CELL * scale_px
		if not poi.dungeon_id.is_empty():
			_hint_spots.append({"at": at, "radius": icon_radius * 1.35 + 8.0, "id": poi.dungeon_id})
		if poi.kind == MapPoi.Kind.DUNGEON:
			# Overnight Oct 31 - Nov 1 (wish list): the dungeon entrance stands out - a bigger icon on a red-gold ring.
			var ring: float = icon_radius * 1.35 * MapDraw.ICON_SCALE * 0.5 + 6.0
			_canvas.draw_circle(at, ring, Color(0.55, 0.1, 0.12, 0.9))
			_canvas.draw_arc(at, ring, 0.0, TAU, 40, UIStyle.GOLD, 3.0, true)
			MapDraw.poi(_canvas, at, poi, icon_radius * 1.35)
		else:
			MapDraw.poi(_canvas, at, poi, icon_radius)
	if _ping != null and _ping_left > 0.0:
		var ping_at: Vector2 = top_left + (Vector2(_ping.pos.x, _ping.pos.z) - _fog.origin) / FogOfWar.CELL * scale_px
		var phase: float = fmod(PING_SECONDS - _ping_left, 1.0)
		_canvas.draw_arc(ping_at, icon_radius * (1.4 + phase * 2.2), 0.0, TAU, 48, Color(1.0, 0.85, 0.35, 1.0 - phase), 4.0, true)
		_canvas.draw_arc(ping_at, icon_radius * 1.4, 0.0, TAU, 48, Color(1.0, 0.85, 0.35, 0.9), 3.0, true)
		if not shown.has(_ping):
			# Not walked to yet: the picked place shows its icon and name through the fog while it pulses.
			MapDraw.poi(_canvas, ping_at, _ping, icon_radius)
			var ping_font: Font = UIStyle.font_bold()
			var width: float = ping_font.get_string_size(_ping.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
			var at_text: Vector2 = ping_at + Vector2(-width * 0.5, icon_radius + 16.0)
			_canvas.draw_string_outline(ping_font, at_text, _ping.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 5, Color(0.03, 0.02, 0.05, 0.95))
			_canvas.draw_string(ping_font, at_text, _ping.label, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, UIStyle.GOLD)
	# Overnight Oct 30-31 (mid-game critic #9): every revealed place is named under its icon (vendors, the Hall of Records, roads, dungeons),
	# skipping a name that would overlap one already written.
	var font: Font = UIStyle.font_bold()
	var taken: Array[Rect2] = []
	for poi: MapPoi in shown:
		if poi.objective or poi.label.strip_edges() == "":
			continue
		var at: Vector2 = top_left + (Vector2(poi.pos.x, poi.pos.z) - _fog.origin) / FogOfWar.CELL * scale_px
		var text: String = poi.label
		var extent: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
		var box: Rect2 = place_label(at, extent + Vector2(0, 4), icon_radius, Rect2(top_left, drawn), taken)
		if box.size == Vector2.ZERO:
			continue
		taken.append(box)
		_canvas.draw_string_outline(font, box.position + Vector2(0, extent.y - 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 5, Color(0.03, 0.02, 0.05, 0.95))
		_canvas.draw_string(font, box.position + Vector2(0, extent.y - 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, UIStyle.PARCHMENT)
	var here: Vector2 = top_left + (Vector2(_player.position.x, _player.position.z) - _fog.origin) / FogOfWar.CELL * scale_px
	MapDraw.arrow(_canvas, here, _player.model.rotation.y, icon_radius)


## Fix pass Nov 7 (item 7, C7 F5): a place name's box - under its icon, else above, right or left of it - kept inside the map's frame and
## clear of the names already written. Rect2() when every spot is taken.
static func place_label(at: Vector2, extent: Vector2, icon_radius: float, frame: Rect2, taken: Array[Rect2]) -> Rect2:
	var gap: float = icon_radius + 3.0
	var candidates: Array[Vector2] = [
		at + Vector2(-extent.x * 0.5, gap), at + Vector2(-extent.x * 0.5, -gap - extent.y),
		at + Vector2(gap, -extent.y * 0.5), at + Vector2(-gap - extent.x, -extent.y * 0.5),
	]
	var inner: Rect2 = frame.grow(-4.0)
	for corner: Vector2 in candidates:
		var box: Rect2 = Rect2(corner, extent)
		box.position.x = clampf(box.position.x, inner.position.x, maxf(inner.position.x, inner.end.x - extent.x))
		box.position.y = clampf(box.position.y, inner.position.y, maxf(inner.position.y, inner.end.y - extent.y))
		var clash: bool = false
		for other: Rect2 in taken:
			if other.intersects(box):
				clash = true
				break
		if not clash:
			return box
	return Rect2()


## Day pass Nov 9: where the dungeon icons were drawn ({at, radius, id}), for the canvas tooltip.
var _hint_spots: Array[Dictionary] = []


## The level hint for the dungeon icon under `at` (canvas coordinates): {"text", "colour"}, or {} when the mouse is on no dungeon.
func hint_at(at: Vector2) -> Dictionary:
	var level: int = Session.profile.level if Session.profile != null else 1
	for spot: Dictionary in _hint_spots:
		if at.distance_to(spot["at"] as Vector2) <= float(spot["radius"]):
			var text: String = LevelHints.text(str(spot["id"]))
			if text.is_empty():
				return {}
			return {"text": text, "colour": LevelHints.colour(str(spot["id"]), level)}
	return {}


## The map canvas: draws through the screen's `_draw_map` and answers a hover over a dungeon icon with its level hint (amber when the
## player is two or more levels under).
class MapCanvas extends Control:
	var screen: FullMapScreen
	var _hint_colour: Color = LevelHints.MUTED

	func _get_tooltip(at_position: Vector2) -> String:
		var hint: Dictionary = screen.hint_at(at_position) if screen != null else {}
		_hint_colour = hint.get("colour", LevelHints.MUTED) as Color
		return str(hint.get("text", ""))

	func _make_custom_tooltip(for_text: String) -> Object:
		var note: Label = Label.new()
		note.text = for_text
		note.add_theme_font_size_override("font_size", 18)
		note.add_theme_color_override("font_color", _hint_colour)
		return note


func _process(delta: float) -> void:
	if _raster != null and not _raster.refined:
		_raster.refine(8000)
		_canvas.queue_redraw()
	if _ping_left > 0.0:
		_ping_left -= delta
		_canvas.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_map"):
		get_viewport().set_input_as_handled()
		request_close()
		return
	super._unhandled_input(event)
