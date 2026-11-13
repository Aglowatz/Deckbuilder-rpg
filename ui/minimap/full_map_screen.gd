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
## Place names on the map: the landmark kinds are always written; the minor kinds (interactables, pads, rafts...) only when the map is drawn
## large enough (`MINOR_LABEL_MIN_SCALE` pixels per metre) and there is room - hovering any icon shows its name.
const MAJOR_LABEL_KINDS: Array[MapPoi.Kind] = [MapPoi.Kind.DUNGEON, MapPoi.Kind.MINI_DUNGEON, MapPoi.Kind.EXIT, MapPoi.Kind.VENDOR, MapPoi.Kind.HEAL,
	MapPoi.Kind.QUEST_GIVER, MapPoi.Kind.TRAVEL_PORTAL, MapPoi.Kind.GATE, MapPoi.Kind.ARENA, MapPoi.Kind.CHALLENGE]
const MINOR_LABEL_MIN_SCALE: float = 5.5
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
	# Mid-game critic #11 (Oct 31 - Nov 1): the list names every place, walked to or not (the fog hides the ground, not the directory).
	# Fable pass Nov 10 (Part 1.1): every active quest's goal comes first ("Goal - Mend the Meatloaf: Sea Salt Crystals"), then the places.
	var places: Array[MapPoi] = where_to_entries(_pois)
	if not places.is_empty():
		# Fable pass Nov 10 (Part 1.4): a button opens the list as a panel over the map's right edge (a Window popup landed over the legend
		# whatever it was told), so the legend stays readable while you choose; the list scrolls, closes on a pick or Escape, and takes
		# keyboard and pad focus.
		var where: FancyButton = FancyButton.make("Point me to...", &"", Vector2(300, 44))
		where.name = "WhereTo"
		where.tooltip_text = "Pick a place: a white arrow leads you there after you close the map."
		_where_places = places
		where.pressed.connect(_toggle_where_list)
		column.add_child(where)
	# Overnight Oct 30-31, Part 2: the goals on this map by quest name (gold = main line, blue = side quest). Fable pass Nov 10 (Part 1.1/1.4):
	# one line per quest with how many places it marks (the "Point me to..." list above names every place), so the legend never outgrows
	# the panel.
	var goal_lines: Array[Dictionary] = []
	var by_quest: Dictionary = {}
	for goal: MapPoi in _pois:
		if not goal.objective:
			continue
		var quest_name: String = goal.label.split(":")[0]
		if not by_quest.has(quest_name):
			by_quest[quest_name] = {"poi": goal, "count": 0, "names": {}}
		var entry: Dictionary = by_quest[quest_name]
		entry["count"] = int(entry["count"]) + 1
	for quest_name: Variant in by_quest.keys():
		goal_lines.append({"name": str(quest_name), "poi": (by_quest[quest_name] as Dictionary)["poi"], "count": int((by_quest[quest_name] as Dictionary)["count"])})
	for line: Dictionary in goal_lines:
		var goal_row: HBoxContainer = UIKit.hbox(12)
		var ring: Control = Control.new()
		ring.custom_minimum_size = Vector2(34, 34)
		var sample: MapPoi = line["poi"] as MapPoi
		ring.draw.connect(func() -> void: MapDraw.poi(ring, Vector2(17, 17), sample, 11.0))
		goal_row.add_child(ring)
		var count: int = int(line["count"])
		var goal_label: Label = UIKit.label("Goal: %s%s" % [str(line["name"]), (" (%d places)" % count) if count > 1 else ""], &"", 22)
		goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		goal_label.custom_minimum_size = Vector2(300, 0)
		goal_row.add_child(goal_label)
		# Overnight Nov 10-11 (Part 2.2, the wayfinding critic): a legend goal row looks like a button, so it is one - a click points the
		# arrow at that quest's nearest place, as the "Point me to..." list does.
		goal_row.mouse_filter = Control.MOUSE_FILTER_STOP
		goal_row.tooltip_text = "Click: point me to %s" % str(line["name"])
		goal_label.mouse_filter = Control.MOUSE_FILTER_PASS
		goal_row.gui_input.connect(func(event: InputEvent) -> void:
			var click: InputEventMouseButton = event as InputEventMouseButton
			if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
				ping(sample)
				goal_row.accept_event())
		column.add_child(goal_row)
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
				break
		if result.size() >= WHERE_TO_MAX:
			break
	# Overnight Nov 10-11 (Part 1.8, the exported-build critic's #9): the places in one fixed order - alphabetical - so the list never
	# reorders between opens (the layer listed them in the order it met them; a row that said Tarragon pointed at Mirepoix next time).
	result.sort_custom(func(a: MapPoi, b: MapPoi) -> bool: return a.label.naturalnocasecmp_to(b.label) < 0)
	return result


## Fable pass Nov 10 (Part 1.1): the goals of every active quest (one per place, in the layer's order: the tracked quest first) followed by
## `where_to_places`.
static func where_to_entries(points: Array[MapPoi]) -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	var by_label: Dictionary = {}
	for poi: MapPoi in points:
		if not poi.objective:
			continue
		# Fable pass Nov 10 (Part 1.6): goals of one name make ONE row ("A hidden stash (any)" x14 buried the three Meatloaf rows); the same
		# place named twice (two quests' dots on one spot) is one goal, not two
		if by_label.has(poi.label):
			var places: Array = by_label[poi.label]["places"] as Array
			var fresh: bool = true
			for seen: Vector3 in places:
				if Vector2(seen.x - poi.pos.x, seen.z - poi.pos.z).length() < 0.8:
					fresh = false
			if fresh:
				places.append(poi.pos)
				(by_label[poi.label]["poi"] as MapPoi).group_count += 1
			continue
		poi.group_count = 1
		by_label[poi.label] = {"poi": poi, "places": [poi.pos]}
		result.append(poi)
	result.append_array(where_to_places(points))
	return result


## One line of the "Point me to..." list: "Goal - Mend the Meatloaf: Sea Salt Crystals" for a goal; "The Iron Cave (Mini dungeon, usually level 6)" for a place.
static func where_to_text(place: MapPoi) -> String:
	if place.objective:
		return "Goal - %s%s" % [place.label, " (one of %d)" % place.group_count if place.group_count > 1 else ""]
	# Day pass Nov 9: a dungeon says its usual traveller level.
	var level_note: String = LevelHints.short_text(place.dungeon_id)
	return "%s (%s)" % [place.label, MapPoi.kind_name(place.kind) if level_note.is_empty() else "%s, %s" % [MapPoi.kind_name(place.kind), level_note]]


## The "Point me to..." places (goals first) and the panel that lists them over the map's right edge.
var _where_places: Array[MapPoi] = []
var _where_panel: PanelContainer
var _where_list: ItemList
const WHERE_LIST_WIDTH: float = 640.0


func _toggle_where_list() -> void:
	if _where_panel != null and _where_panel.visible:
		_hide_where_list()
		return
	if _where_panel == null:
		_where_panel = UIKit.panel(&"DarkPanel")
		_where_panel.name = "WhereToPanel"
		var box: VBoxContainer = UIKit.vbox(8)
		_where_panel.add_child(box)
		box.add_child(UIKit.label("Point me to...", &"HeadingLabel", 26))
		_where_list = ItemList.new()
		_where_list.name = "WhereToList"
		_where_list.add_theme_font_size_override("font_size", 20)
		_where_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_where_list.allow_reselect = true
		for place: MapPoi in _where_places:
			_where_list.add_item(where_to_text(place))
		_where_list.item_selected.connect(func(index: int) -> void:
			if index >= 0 and index < _where_places.size():
				ping(_where_places[index])
			_hide_where_list())
		_where_list.item_activated.connect(func(index: int) -> void:
			if index >= 0 and index < _where_places.size():
				ping(_where_places[index])
			_hide_where_list())
		box.add_child(_where_list)
		_canvas.add_child(_where_panel)
	var height: float = minf(_canvas.size.y - 20.0, 70.0 + 30.0 * float(_where_places.size()))
	_where_panel.size = Vector2(WHERE_LIST_WIDTH, height)
	_where_panel.position = Vector2(maxf(0.0, _canvas.size.x - WHERE_LIST_WIDTH - 10.0), 10.0)
	_where_panel.visible = true
	_where_list.grab_focus()
	if _where_list.item_count > 0 and _where_list.get_selected_items().is_empty():
		_where_list.select(0)
		_where_list.ensure_current_is_visible()
	Audio.sfx(&"ui_tick", -8.0)


func _hide_where_list() -> void:
	if _where_panel == null:
		return
	_where_panel.visible = false
	var button: Control = find_child("WhereTo", true, false) as Control
	if button != null:
		button.grab_focus()


## True while the list is open (the tests and Escape read it).
func where_list_open() -> bool:
	return _where_panel != null and _where_panel.visible


## The current scene's quest marker layer (its routes are drawn on the map), or null.
func _route_markers() -> QuestMarkerLayer:
	var scene: Node = get_tree().current_scene if is_inside_tree() else null
	return scene.get("quest_markers") as QuestMarkerLayer if scene != null else null


## Makes `poi` pulse on the map for PING_SECONDS.
func ping(poi: MapPoi) -> void:
	_ping = poi
	_ping_left = PING_SECONDS
	Session.where_to_target = {"area": _area_id, "pos": poi.pos, "label": poi.label}  # Fix pass Nov 7 (item 7): the arrow after the map closes
	var markers: QuestMarkerLayer = _route_markers()
	if markers != null:
		markers.plan_where_to_now()  # Fable pass Nov 10 (Part 1.6): the route starts planning at once, so the map shows it while the ping pulses
	Audio.sfx(&"ui_select")
	if _canvas != null:
		_canvas.queue_redraw()


## Batch 15 pass (Part 3.5, the Capital's map). `districts`: the named parts of the area ({"name", "rect": Rect2 in world x / z}); each
## name is written across its district once any of it is revealed. `inset`: a part of the area that lies apart from the rest and is drawn
## as its own framed map beside the main one ({"name", "note", "rect": Rect2 in world x / z}; it must be the southern end of the grid):
## the Crease lies under the city, and drawn in place it was a little box in the corner of the surface map with its names piled up.
var districts: Array[Dictionary] = []
var inset: Dictionary = {}
## How much larger than the main map the inset is drawn, the gap between the two and the room for the inset's title.
const INSET_ZOOM: float = 1.7
const INSET_GAP: float = 34.0
const INSET_TITLE: float = 30.0
const DISTRICT_FONT: int = 19
## The last layout drawn: the main map's and the inset's cells (in fog cells) and where they are on the canvas.
var _main_cells: Rect2 = Rect2()
var _main_screen: Rect2 = Rect2()
var _inset_cells: Rect2 = Rect2()
var _inset_screen: Rect2 = Rect2()


## Where the main map and the inset are drawn on a canvas `area` big: {"main_cells", "main_screen", "inset_cells", "inset_screen"} (the
## inset rects are empty without one). Pure: the fog grid's size, the inset's world rect and the canvas size decide it.
static func map_layout(area: Vector2, fog_origin: Vector2, fog_size: Vector2, inset_world: Rect2) -> Dictionary:
	var main_cells: Rect2 = Rect2(Vector2.ZERO, fog_size)
	var inset_cells: Rect2 = Rect2()
	if inset_world.size.x > 0.0 and inset_world.size.y > 0.0:
		inset_cells = Rect2((inset_world.position - fog_origin) / FogOfWar.CELL, inset_world.size / FogOfWar.CELL).intersection(main_cells)
	if inset_cells.size.x <= 0.0 or inset_cells.size.y <= 0.0:
		var scale_only: float = minf(area.x / fog_size.x, area.y / fog_size.y)
		var drawn_only: Vector2 = fog_size * scale_only
		return {"main_cells": main_cells, "main_screen": Rect2((area - drawn_only) * 0.5, drawn_only), "inset_cells": Rect2(), "inset_screen": Rect2()}
	# the main map ends above the inset (the rows between them are empty ground)
	main_cells.size.y = maxf(1.0, inset_cells.position.y - 2.0)
	var scale_px: float = minf(area.y / main_cells.size.y, (area.x - INSET_GAP) / (main_cells.size.x + inset_cells.size.x * INSET_ZOOM))
	scale_px = minf(scale_px, (area.y - INSET_TITLE) / (inset_cells.size.y * INSET_ZOOM))
	var main_size: Vector2 = main_cells.size * scale_px
	var inset_size: Vector2 = inset_cells.size * scale_px * INSET_ZOOM
	var left: float = (area.x - main_size.x - INSET_GAP - inset_size.x) * 0.5
	var top: float = (area.y - main_size.y) * 0.5
	var main_screen: Rect2 = Rect2(Vector2(left, top), main_size)
	var inset_screen: Rect2 = Rect2(Vector2(main_screen.end.x + INSET_GAP, main_screen.end.y - inset_size.y), inset_size)
	return {"main_cells": main_cells, "main_screen": main_screen, "inset_cells": inset_cells, "inset_screen": inset_screen}


## Where the world point (x, z) is on the canvas: on the inset when it lies in the inset's part of the grid, else on the main map.
func _to_screen(world_xz: Vector2) -> Vector2:
	var cell: Vector2 = (world_xz - _fog.origin) / FogOfWar.CELL
	if _inset_cells.size.x > 0.0 and _inset_cells.grow(0.5).has_point(cell):
		return _inset_screen.position + (cell - _inset_cells.position) * (_inset_screen.size.x / _inset_cells.size.x)
	return _main_screen.position + (cell - _main_cells.position) * (_main_screen.size.x / _main_cells.size.x)


## The frame (main map or inset) the world point (x, z) is drawn in: names stay inside it.
func _frame_of(world_xz: Vector2) -> Rect2:
	var cell: Vector2 = (world_xz - _fog.origin) / FogOfWar.CELL
	return _inset_screen if _inset_cells.size.x > 0.0 and _inset_cells.grow(0.5).has_point(cell) else _main_screen


func _draw_board(cells: Rect2, screen: Rect2) -> void:
	# Phase 2 cycle 17: only the map itself sits on a dark board with a soft shadow; the whole canvas used to be filled, leaving dead dark
	# strips either side of a square map.
	for step: int in range(4):
		var grow: float = 6.0 + float(step) * 6.0
		_canvas.draw_rect(Rect2(screen.position - Vector2(grow, grow) + Vector2(0.0, 6.0), screen.size + Vector2(grow, grow) * 2.0), Color(0.0, 0.0, 0.0, 0.1))
	_canvas.draw_rect(screen, Color(0.04, 0.05, 0.08, 0.95))
	_canvas.draw_texture_rect_region(_raster.texture, screen, Rect2(Vector2(MapRaster.PAD, MapRaster.PAD) + cells.position, cells.size))
	_canvas.draw_rect(screen, Color(0.82, 0.68, 0.32, 0.9), false, 2.0)


## True once any of the world rect `rect` (x / z) has been revealed (its centre, its corners' quarter points).
func _part_revealed(rect: Rect2) -> bool:
	for u: float in [0.5, 0.25, 0.75]:
		for v: float in [0.5, 0.25, 0.75]:
			if _fog.is_revealed(rect.position + rect.size * Vector2(u, v)):
				return true
	return false


func _draw_map() -> void:
	var placed: Dictionary = map_layout(_canvas.size, _fog.origin, Vector2(float(_fog.width), float(_fog.height)), inset.get("rect", Rect2()) as Rect2)
	_main_cells = placed["main_cells"] as Rect2
	_main_screen = placed["main_screen"] as Rect2
	_inset_cells = placed["inset_cells"] as Rect2
	_inset_screen = placed["inset_screen"] as Rect2
	var scale_px: float = _main_screen.size.x / _main_cells.size.x
	_draw_board(_main_cells, _main_screen)
	var title_font: Font = UIStyle.font_bold()
	var taken: Array[Rect2] = []
	if _inset_cells.size.x > 0.0:
		_draw_board(_inset_cells, _inset_screen)
		var inset_title: String = str(inset.get("name", ""))
		var note: String = str(inset.get("note", ""))
		var title_at: Vector2 = _inset_screen.position + Vector2(2.0, -10.0)
		_canvas.draw_string_outline(title_font, title_at, inset_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, 5, Color(0.03, 0.02, 0.05, 0.95))
		_canvas.draw_string(title_font, title_at, inset_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, UIStyle.GOLD)
		if not note.is_empty():
			var note_at: Vector2 = title_at + Vector2(title_font.get_string_size(inset_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 10.0, 0.0)
			_canvas.draw_string_outline(title_font, note_at, note, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Color(0.03, 0.02, 0.05, 0.9))
			_canvas.draw_string(title_font, note_at, note, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, UIStyle.PARCHMENT)
	# the district names, written across each district clear of the icons (a quiet, wide-set label; the place names keep clear of them)
	var early_radius: float = clampf(scale_px * 2.2, 9.0, 16.0)
	for poi: MapPoi in MapView.visible_pois(_pois, _fog):
		var icon_at: Vector2 = _to_screen(Vector2(poi.pos.x, poi.pos.z))
		taken.append(Rect2(icon_at - Vector2(early_radius, early_radius) * 0.9, Vector2(early_radius, early_radius) * 1.8))
	for district: Dictionary in districts:
		var world: Rect2 = district.get("rect", Rect2()) as Rect2
		if world.size.x <= 0.0 or not _part_revealed(world):
			continue
		var name_text: String = str(district.get("name", "")).to_upper()
		var size: Vector2 = title_font.get_string_size(name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, DISTRICT_FONT)
		var frame: Rect2 = _frame_of(world.get_center()).grow(-4.0)
		var corner: Vector2 = _to_screen(world.get_center()) - Vector2(size.x * 0.5, size.y * 0.5)
		corner.x = clampf(corner.x, frame.position.x, maxf(frame.position.x, frame.end.x - size.x))
		corner.y = clampf(corner.y, frame.position.y, maxf(frame.position.y, frame.end.y - size.y))
		var name_box: Rect2 = Rect2(corner, size)
		# its centre first, then steps up and down from it until it is clear of the icons and the other names
		var home_y: float = name_box.position.y
		for attempt: int in range(9):
			name_box.position.y = clampf(home_y + float((attempt + 1) / 2) * (size.y + 3.0) * (1.0 if attempt % 2 == 1 else -1.0), frame.position.y, maxf(frame.position.y, frame.end.y - size.y))
			var clash: bool = false
			for other: Rect2 in taken:
				if other.intersects(name_box):
					clash = true
					break
			if not clash:
				break
		taken.append(name_box)
		_canvas.draw_string_outline(title_font, name_box.position + Vector2(0, size.y - 4.0), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, DISTRICT_FONT, 6, Color(0.03, 0.02, 0.05, 0.85))
		_canvas.draw_string(title_font, name_box.position + Vector2(0, size.y - 4.0), name_text, HORIZONTAL_ALIGNMENT_LEFT, -1, DISTRICT_FONT, Color(0.98, 0.9, 0.66, 0.92))
	var icon_radius: float = clampf(scale_px * 2.2, 9.0, 16.0)
	var shown: Array[MapPoi] = MapView.visible_pois(_pois, _fog)
	_hint_spots = []
	for poi: MapPoi in shown:
		var at: Vector2 = _to_screen(Vector2(poi.pos.x, poi.pos.z))
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
	# Fable pass Nov 10 (Part 1.6, the wayfinding critic): the route the arrows follow, as a dotted line over the map - the "Point me to..."
	# pick's in white, the tracked goal's in gold - so the way round a river, a wall or a desk is on the map, not only in the arrow.
	var markers: QuestMarkerLayer = _route_markers()
	if markers != null:
		for slot: int in [0, 1]:
			var points: PackedVector3Array = markers.route_points(slot)
			if points.size() < 2:
				continue
			var colour: Color = Color(1.0, 1.0, 1.0, 0.9) if slot == 1 else Color(UIStyle.GOLD, 0.85)
			var last: Vector2 = _to_screen(Vector2(points[0].x, points[0].z))
			for index: int in range(1, points.size()):
				var next: Vector2 = _to_screen(Vector2(points[index].x, points[index].z))
				_canvas.draw_dashed_line(last, next, colour, 2.5, 6.0, true)
				last = next
	if _ping != null and _ping_left > 0.0:
		var ping_at: Vector2 = _to_screen(Vector2(_ping.pos.x, _ping.pos.z))
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
	# skipping a name that would overlap one already written. Fable pass Nov 10 (Part 1.4): landmarks are named first (they win the room);
	# minor places are named only when the map is drawn large enough, and every icon says its name on hover.
	var font: Font = UIStyle.font_bold()
	_name_spots = []
	var ordered: Array[MapPoi] = label_order(shown)
	# Batch 15 pass (Part 3.5): no name is written over an icon (every icon's box was taken before the district names were placed), and a name
	# that several places share (two complaint boxes, three shafts) is written once per map, at the first of them.
	var written: Dictionary = {}
	for poi: MapPoi in ordered:
		if poi.objective or poi.label.strip_edges() == "":
			continue
		var at: Vector2 = _to_screen(Vector2(poi.pos.x, poi.pos.z))
		_name_spots.append({"at": at, "radius": icon_radius * 1.35 + 6.0, "label": poi.label})
		if not MAJOR_LABEL_KINDS.has(poi.kind) and scale_px < MINOR_LABEL_MIN_SCALE:
			continue
		var text: String = poi.label
		var frame_now: Rect2 = _frame_of(Vector2(poi.pos.x, poi.pos.z))
		var name_key: String = "%s|%s" % [text, "inset" if frame_now == _inset_screen else "main"]
		if written.has(name_key):
			continue
		var extent: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
		var box: Rect2 = place_label(at, extent + Vector2(0, 4), icon_radius, frame_now, taken)
		if box.size == Vector2.ZERO:
			continue
		taken.append(box)
		written[name_key] = true
		_canvas.draw_string_outline(font, box.position + Vector2(0, extent.y - 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 5, Color(0.03, 0.02, 0.05, 0.95))
		_canvas.draw_string(font, box.position + Vector2(0, extent.y - 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, UIStyle.PARCHMENT)
	var here: Vector2 = _to_screen(Vector2(_player.position.x, _player.position.z))
	MapDraw.arrow(_canvas, here, _player.model.rotation.y, icon_radius)


## Fix pass Nov 7 (item 7, C7 F5): a place name's box - under its icon, else above, right or left of it - kept inside the map's frame and
## clear of the names already written. Rect2() when every spot is taken.
static func place_label(at: Vector2, extent: Vector2, icon_radius: float, frame: Rect2, taken: Array[Rect2]) -> Rect2:
	var gap: float = icon_radius + 3.0
	var candidates: Array[Vector2] = [
		at + Vector2(-extent.x * 0.5, gap), at + Vector2(-extent.x * 0.5, -gap - extent.y),
		at + Vector2(gap, -extent.y * 0.5), at + Vector2(-gap - extent.x, -extent.y * 0.5),
		at + Vector2(gap * 0.7, gap * 0.7), at + Vector2(-gap * 0.7 - extent.x, gap * 0.7),
		at + Vector2(gap * 0.7, -gap * 0.7 - extent.y), at + Vector2(-gap * 0.7 - extent.x, -gap * 0.7 - extent.y),
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


## The order names are written in: landmark kinds first (dungeons, exits, shops, healers, quest givers...), then the minor places. Pure.
static func label_order(points: Array[MapPoi]) -> Array[MapPoi]:
	var major: Array[MapPoi] = []
	var minor: Array[MapPoi] = []
	for poi: MapPoi in points:
		if MAJOR_LABEL_KINDS.has(poi.kind):
			major.append(poi)
		else:
			minor.append(poi)
	return major + minor


## Where every named icon was drawn ({at, radius, label}): hovering one shows its name (the minor names hide on a small map).
var _name_spots: Array[Dictionary] = []


## Day pass Nov 9: where the dungeon icons were drawn ({at, radius, id}), for the canvas tooltip.
var _hint_spots: Array[Dictionary] = []


## The level hint for the dungeon icon under `at` (canvas coordinates): {"text", "colour"}; the place's name for any other icon; {} when the
## mouse is on nothing.
func hint_at(at: Vector2) -> Dictionary:
	var level: int = Session.profile.level if Session.profile != null else 1
	for spot: Dictionary in _hint_spots:
		if at.distance_to(spot["at"] as Vector2) <= float(spot["radius"]):
			var text: String = LevelHints.text(str(spot["id"]))
			if text.is_empty():
				return {}
			return {"text": text, "colour": LevelHints.colour(str(spot["id"]), level)}
	var best: Dictionary = {}
	var best_distance: float = INF
	for spot: Dictionary in _name_spots:
		var distance: float = at.distance_to(spot["at"] as Vector2)
		if distance <= float(spot["radius"]) and distance < best_distance:
			best_distance = distance
			best = spot
	if best.is_empty():
		return {}
	return {"text": str(best["label"]), "colour": UIStyle.PARCHMENT}


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
	if where_list_open() and (event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"open_map")):
		# Fable pass Nov 10 (Part 1.6): the list closes AND the map (the critic walked a whole run under a map it thought was shut)
		_hide_where_list()
	if event.is_action_pressed(&"open_map"):
		get_viewport().set_input_as_handled()
		request_close()
		return
	super._unhandled_input(event)
