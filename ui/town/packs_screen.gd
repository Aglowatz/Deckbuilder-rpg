class_name PacksScreen
extends OverlayScreen
## The Card Packs page (Menu > Packs, P). Overnight Nov 7-8, Part 5.2 (plan: docs/ui/card_packs_redesign.md): the Character page's look - a caps
## header, THE SHELF with each owned pack's painted art large on a wooden board (count badge, name, contents line, Open), an action bar with
## Open all, and LAST OPENED (the cards of the latest Open / Open all, with the hover zoom). Background UI-BG-PACKS once painted, else a dimmed
## UI-BG-CHARACTER. The opening ceremony plays on top as before.

const PANEL_FILL: Color = Color(0.07, 0.05, 0.12, 0.88)
const DIVIDER: Color = Color(0.91, 0.69, 0.29, 0.4)
const SHELF_RECT: Rect2 = Rect2(40, 110, 1840, 560)
const ACTION_RECT: Rect2 = Rect2(40, 684, 1840, 84)
const RESULTS_RECT: Rect2 = Rect2(40, 782, 1840, 268)
const PACK_SCALE: float = 0.55
const SLOT_WIDTH: float = 250.0
const RESULT_SCALE: float = 0.42

var _page: Control
var _shelf_row: HBoxContainer
var _board: Control
var _lip: Control
var _shelf_count: Label
var _header_count: Label
var _action_row: HBoxContainer
var _results_row: HBoxContainer
var _results_count: Label
var _results_preview: HoverPreview
## The openings shown under LAST OPENED (the latest Open all, or the latest single pack).
var last_openings: Array[PackOpening] = []


func _init() -> void:
	screen_title = ""
	title_icon_id = ""
	close_text = "Close (Esc)"
	background_id = ""


func _build() -> void:
	_add_backdrop()
	_page = Control.new()
	_page.name = "PacksPage"
	_page.size = Vector2(1920, 1080)
	_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_page)
	var title: Label = _text("CARD PACKS", 64, UIStyle.GOLD, Vector2(52, 14), 700)
	title.name = "PageTitle"
	title.add_theme_font_override("font", UIStyle.font_title())
	title.add_theme_color_override("font_outline_color", Color(0.12, 0.06, 0.02, 0.95))
	title.add_theme_constant_override("outline_size", 10)
	_page.add_child(title)
	_header_count = _text("", 24, UIStyle.PARCHMENT, Vector2(700, 40), 1000, HORIZONTAL_ALIGNMENT_RIGHT)
	_header_count.name = "HeaderCount"
	_page.add_child(_header_count)
	_build_shelf()
	_build_action_bar()
	_build_results()
	_refresh()
	# Fixes Oct 25, Part 6: the onboarding tip for the first pack (Make It Yours opens with one)
	TipPanel.show_once(self, &"tip_packs", "Opening packs", "Click [b]Open[/b] to tear a pack: its cards join your collection at once. A copy past its cap turns into essence and gold. Then put the new cards to work at the [b]Deck Station[/b].", Vector2(560, 860))


func _add_backdrop() -> void:
	var id: String = "UI-BG-PACKS" if UiArt.has("UI-BG-PACKS") else "UI-BG-CHARACTER"
	var texture: Texture2D = UiArt.texture(id) if UiArt.has(id) else null
	var back: Control = Control.new()
	back.name = "Backdrop"
	UIKit.full_rect(back)
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(back)
	for child: Node in get_children():
		if child is MarginContainer:
			move_child(back, child.get_index())
			break
	if texture == null:
		return
	var room: TextureRect = TextureRect.new()
	room.name = "Room"
	if id == "UI-BG-CHARACTER":
		var crop: AtlasTexture = AtlasTexture.new()
		crop.atlas = texture
		var scale_to_source: float = texture.get_size().x / 1536.0
		crop.region = Rect2(CharacterScreen.ROOM_REGION.position * scale_to_source, CharacterScreen.ROOM_REGION.size * scale_to_source)
		room.texture = crop
	else:
		room.texture = texture
	room.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	room.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(room)
	room.modulate = Color(0.42, 0.39, 0.44) if id == "UI-BG-CHARACTER" else Color(0.74, 0.72, 0.74)  # Import Nov 8: its own room, lightly dimmed for the panels
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.add_child(room)


func _build_shelf() -> void:
	var panel: Panel = _make_panel("Shelf", SHELF_RECT, true)
	var icon: TextureRect = IconArt.rect("ICON-UI-PACKS", 40.0)
	icon.position = Vector2(24, 16)
	panel.add_child(icon)
	panel.add_child(_heading("THE SHELF", Vector2(76, 14), 34))
	_shelf_count = _text("", 22, UIStyle.PARCHMENT, Vector2(SHELF_RECT.size.x - 424, 22), 400, HORIZONTAL_ALIGNMENT_RIGHT)
	panel.add_child(_shelf_count)
	_divider(panel, 66, SHELF_RECT.size.x)
	# the wooden board the packs stand on: Import Nov 8, the painted UI-PACK-SHELF (its brackets at the ends, the carved middle tiled), drawn
	# behind the packs with their feet on its top surface and ending above the names; the drawn strip without the art
	if UiArt.has(SHELF_ART):
		var painted: Control = painted_board(SHELF_RECT.size.x - 60.0, PAINTED_BOARD_HEIGHT)
		if painted != null:
			painted.position = Vector2(30, 80 + 4 + PackArt.SIZE.y * PACK_SCALE - PAINTED_BOARD_SINK)
			panel.add_child(painted)
			_board = painted
	var board: ColorRect = ColorRect.new()
	board.name = "ShelfBoard"
	board.color = Color("6b4426")
	board.position = Vector2(30, 80 + 6 + PackArt.SIZE.y * PACK_SCALE)  # right under the pack art (Fixes Nov 8: it sat on the names)
	board.size = Vector2(SHELF_RECT.size.x - 60, 16)
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _board == null:
		panel.add_child(board)
		_board = board
	var lip: ColorRect = ColorRect.new()
	lip.name = "ShelfLip"
	lip.color = Color("3d2614")
	lip.position = board.position + Vector2(0, 16)
	lip.size = Vector2(board.size.x, 6)
	lip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _board == board:
		panel.add_child(lip)
		_lip = lip
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "ShelfScroll"
	scroll.position = Vector2(30, 80)
	scroll.size = Vector2(SHELF_RECT.size.x - 60, SHELF_RECT.size.y - 92)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	_shelf_row = UIKit.hbox(18)
	scroll.add_child(_shelf_row)


## Import Nov 8 (Batch 13): the painted shelf board, trimmed to the board at import (about 1524 x 199).
const SHELF_ART: String = "UI-PACK-SHELF"
const PAINTED_BOARD_HEIGHT: float = 48.0
## How far the board's top rises behind the pack art (the packs' feet stand on its top surface).
const PAINTED_BOARD_SINK: float = 12.0
## The end caps (bracket and the scroll's start) as a fraction of the art's width; the middle between them tiles.
const SHELF_CAP: float = 0.16


## The painted shelf `width` x `height`: the art scaled to `height` (crisp, not squashed), its two ends kept and the middle tiled.
static func painted_board(width: float, height: float) -> Control:
	var texture: Texture2D = UiArt.texture(SHELF_ART)
	if texture == null:
		return null
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		return null
	if image.is_compressed():
		image.decompress()
	image.clear_mipmaps()
	var scaled_width: int = maxi(8, int(round(image.get_width() * height / float(image.get_height()))))
	image.resize(scaled_width, int(height), Image.INTERPOLATE_LANCZOS)
	var patch: NinePatchRect = NinePatchRect.new()
	patch.name = "ShelfBoard"
	patch.texture = ImageTexture.create_from_image(image)
	var cap: int = int(scaled_width * SHELF_CAP)
	patch.patch_margin_left = cap
	patch.patch_margin_right = cap
	patch.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	patch.size = Vector2(width, height)
	patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return patch


func _build_action_bar() -> void:
	var panel: Panel = _make_panel("ActionBar", ACTION_RECT, false)
	_action_row = UIKit.hbox(18)
	_action_row.position = Vector2(24, 14)
	panel.add_child(_action_row)


func _build_results() -> void:
	var panel: Panel = _make_panel("LastOpened", RESULTS_RECT, false)
	var icon: TextureRect = IconArt.rect("ICON-DECKBOX", 36.0)
	icon.position = Vector2(24, 14)
	panel.add_child(icon)
	panel.add_child(_heading("LAST OPENED", Vector2(72, 10), 30))
	_results_count = _text("", 20, UIStyle.PARCHMENT, Vector2(RESULTS_RECT.size.x - 424, 18), 400, HORIZONTAL_ALIGNMENT_RIGHT)
	panel.add_child(_results_count)
	_divider(panel, 56, RESULTS_RECT.size.x)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "ResultsScroll"
	scroll.position = Vector2(24, 64)
	scroll.size = Vector2(RESULTS_RECT.size.x - 48, RESULTS_RECT.size.y - 70)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	_results_row = UIKit.hbox(10)
	scroll.add_child(_results_row)
	_results_preview = HoverPreview.new()
	_results_preview.name = "ResultsPreview"
	add_child(_results_preview)


func _refresh() -> void:
	for row: Node in [_shelf_row, _action_row]:
		for child: Node in row.get_children():
			child.queue_free()
	var shown: int = 0
	var total: int = 0
	for pack: PackData in PackCatalog.all():
		var count: int = Session.profile.pack_count(pack.id)
		if count <= 0:
			continue
		shown += 1
		total += count
		_shelf_row.add_child(_shelf_slot(pack, count))
	if shown == 0:
		var empty: Label = UIKit.label("No unopened packs. Free a zone, finish quests, or visit Foil Fenwick on the square.", &"MutedLabel", 26)
		empty.name = "EmptyShelf"
		_shelf_row.add_child(empty)
	_shelf_count.text = "%d pack%s" % [total, "" if total == 1 else "s"]
	for strip: Control in [_board, _lip]:
		if strip != null:
			strip.visible = shown > 0
	_header_count.text = "%d unopened  ·  Foil Fenwick sells more on the square" % total
	# Overnight Oct 31 - Nov 1 (mid-game critic #13): with two or more plain packs, "Open all" opens them in one go with one summary;
	# gilded packs (a guaranteed Epic or Legendary) keep their ceremony.
	var plain: int = plain_pack_count()
	if plain >= 2:
		var all_button: FancyButton = FancyButton.make("Open all (%d packs)" % plain, &"PrimaryButton", Vector2(320, 56))
		all_button.name = "OpenAll"
		all_button.pressed.connect(func() -> void:
			Audio.sfx(&"ui_confirm")
			var openings: Array[PackOpening] = open_all()
			last_openings = openings
			_show_open_all(openings))
		_action_row.add_child(all_button)
		# Fix pass Nov 7 (item 8, C3 F4): say what Open all leaves out.
		if gilded_pack_count() > 0:
			var skipped: Label = UIKit.label("Gilded packs (%d, a sure Epic or Legendary) open one at a time on the shelf." % gilded_pack_count(), &"MutedLabel", 20)
			skipped.name = "OpenAllSkips"
			skipped.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			_action_row.add_child(skipped)
	else:
		var hint: Label = UIKit.label("Open a pack from the shelf: its cards join your collection at once." if shown > 0 else "Packs come from dungeons, quests, chests and Foil Fenwick's stall.", &"MutedLabel", 22)
		hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_action_row.add_child(hint)
	_refresh_results()


## One pack on the shelf: its painted art large with a gold count badge, the name, what it holds, and its Open button.
func _shelf_slot(pack: PackData, count: int) -> VBoxContainer:
	var slot: VBoxContainer = UIKit.vbox(6)
	slot.name = "Slot_%s" % pack.id
	slot.custom_minimum_size = Vector2(SLOT_WIDTH, 0)
	var art_holder: Control = Control.new()
	art_holder.custom_minimum_size = Vector2(SLOT_WIDTH, PackArt.SIZE.y * PACK_SCALE + (40.0 if UiArt.has(SHELF_ART) else 22.0))  # Import Nov 8: room for the painted board above the name
	art_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art: Control = PackArt.icon(pack, PACK_SCALE)
	art.position = Vector2((SLOT_WIDTH - PackArt.SIZE.x * PACK_SCALE) * 0.5, 4)
	art_holder.add_child(art)
	var badge: Label = UIKit.label("x%d" % count, &"", 24, Color("1d1408"), HORIZONTAL_ALIGNMENT_CENTER)
	badge.name = "CountBadge"
	badge.add_theme_font_override("font", UIStyle.font_bold())
	badge.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 10))
	badge.position = art.position + Vector2(PackArt.SIZE.x * PACK_SCALE - 30, -2)
	badge.size = Vector2(54, 34)
	art_holder.add_child(badge)
	slot.add_child(art_holder)
	var name_label: Label = UIKit.label(pack.display_name, &"", 24, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.add_theme_font_override("font", UIStyle.font_title())
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.custom_minimum_size = Vector2(SLOT_WIDTH, 0)
	slot.add_child(name_label)
	var what: Label = UIKit.label(PackShop.describe(pack), &"MutedLabel", 17, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	what.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	what.custom_minimum_size = Vector2(SLOT_WIDTH, 44)
	slot.add_child(what)
	var open: FancyButton = FancyButton.make("Open", &"PrimaryButton", Vector2(170, 50))
	open.name = "Open_%s" % pack.id
	open.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	open.pressed.connect(func() -> void:
		Audio.sfx(&"ui_confirm")
		PackOpeningScreen.open_from_inventory(self, pack.id, func() -> void:
			if PackOpeningScreen.last_opening != null:
				last_openings = [PackOpeningScreen.last_opening] as Array[PackOpening]
			_refresh()))
	slot.add_child(open)
	return slot


## LAST OPENED: the cards of `last_openings`, new ones first (one tile each; a copy past its cap dimmed), with the hover / focus zoom.
func _refresh_results() -> void:
	if _results_row == null:
		return
	for child: Node in _results_row.get_children():
		child.queue_free()
	if last_openings.is_empty():
		_results_count.text = ""
		var empty: Label = UIKit.label("Open a pack to see its cards here.", &"MutedLabel", 22)
		empty.name = "NoResults"
		_results_row.add_child(empty)
		return
	var entries: Array[PackOpening.Entry] = result_entries(last_openings)
	var fresh: int = 0
	for entry: PackOpening.Entry in entries:
		if entry.is_new:
			fresh += 1
		var tile: Control = _result_tile(entry, RESULT_SCALE)
		tile.name = "Last_%s" % entry.card.id
		var card: CardData = entry.card
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.focus_mode = Control.FOCUS_ALL
		tile.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
		tile.mouse_entered.connect(func() -> void: _results_preview.show_for(tile, card))
		tile.mouse_exited.connect(_results_preview.hide_preview)
		tile.focus_entered.connect(func() -> void: _results_preview.show_for(tile, card))
		tile.focus_exited.connect(_results_preview.hide_preview)
		_results_row.add_child(tile)
	_results_count.text = "%d card%s, %d new" % [entries.size(), "" if entries.size() == 1 else "s", fresh]


func _make_panel(panel_name: String, rect: Rect2, accent: bool) -> Panel:
	var panel: Panel = Panel.new()
	panel.name = panel_name
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	var style: StyleBoxFlat = UIStyle.box(PANEL_FILL, UIStyle.GOLD if accent else UIStyle.GOLD_DIM, 3 if accent else 2, 14)
	if accent:
		style.shadow_color = Color(UIStyle.GOLD, 0.25)
		style.shadow_size = 18
	panel.add_theme_stylebox_override("panel", style)
	_page.add_child(panel)
	return panel


func _text(value: String, font_size: int, colour: Color, at: Vector2, width: float, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label: Label = UIKit.label(value, &"", font_size, colour, align)
	label.position = at
	label.size = Vector2(width, float(font_size) * 1.4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _heading(value: String, at: Vector2, font_size: int) -> Label:
	var label: Label = _text(value, font_size, UIStyle.GOLD, at, 500)
	label.add_theme_font_override("font", UIStyle.font_title())
	return label


func _divider(parent: Control, y: float, width: float) -> void:
	var line: ColorRect = ColorRect.new()
	line.color = DIVIDER
	line.position = Vector2(24, y)
	line.size = Vector2(width - 48, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(line)


## How many packs "Open all" would open (every pack but the gilded ones).
static func plain_pack_count() -> int:
	var total: int = 0
	for pack: PackData in PackCatalog.all():
		if not pack.guarantee_epic_or_legendary:
			total += Session.profile.pack_count(pack.id)
	return total


## Fix pass Nov 7 (item 8): the gilded packs "Open all" leaves for their own ceremony.
static func gilded_pack_count() -> int:
	var total: int = 0
	for pack: PackData in PackCatalog.all():
		if pack.guarantee_epic_or_legendary:
			total += Session.profile.pack_count(pack.id)
	return total


## Opens every plain pack in the inventory (cards join the collection as with one pack at a time) and returns the openings.
static func open_all() -> Array[PackOpening]:
	var openings: Array[PackOpening] = []
	for pack: PackData in PackCatalog.all():
		if pack.guarantee_epic_or_legendary:
			continue
		while Session.profile.pack_count(pack.id) > 0:
			var opening: PackOpening = Session.open_pack(pack.id)
			if opening == null:
				break
			openings.append(opening)
	return openings


## The summary of an "Open all": how many packs and cards, the new cards by name, the rest with copy counts, and what extra copies became.
static func summary_lines(openings: Array[PackOpening]) -> PackedStringArray:
	var lines: PackedStringArray = []
	var cards: int = 0
	var new_names: PackedStringArray = []
	var other: Dictionary = {}
	var essence: int = 0
	var gold: int = 0
	for opening: PackOpening in openings:
		for entry: PackOpening.Entry in opening.entries:
			cards += 1
			if entry.is_new and not new_names.has(entry.card.display_name):
				new_names.append(entry.card.display_name)
			elif not entry.converted:
				other[entry.card.display_name] = int(other.get(entry.card.display_name, 0)) + 1
			for path: Variant in entry.essence.keys():
				essence += int(entry.essence[path])
			gold += entry.gold
	lines.append("Opened %d pack%s: %d cards." % [openings.size(), "" if openings.size() == 1 else "s", cards])
	if not new_names.is_empty():
		lines.append("[color=#ffcf70]New: %s[/color]" % ", ".join(new_names))
	if not other.is_empty():
		var parts: PackedStringArray = []
		for card_name: Variant in other.keys():
			parts.append("%s%s" % [card_name, "" if int(other[card_name]) == 1 else " x%d" % int(other[card_name])])
		lines.append("More copies: %s" % ", ".join(parts))
	if essence > 0 or gold > 0:
		lines.append("Extra copies past the cap became %d essence and %d gold." % [essence, gold])
	return lines


## Fix pass Nov 7 (item 8): every card of an Open all, the new ones first (one tile per card; a copy past its cap stays, dimmed).
static func result_entries(openings: Array[PackOpening]) -> Array[PackOpening.Entry]:
	var fresh: Array[PackOpening.Entry] = []
	var rest: Array[PackOpening.Entry] = []
	var seen_new: Dictionary = {}
	for opening: PackOpening in openings:
		for entry: PackOpening.Entry in opening.entries:
			if entry.is_new and not seen_new.has(entry.card.id):
				seen_new[entry.card.id] = true
				fresh.append(entry)
			else:
				rest.append(entry)
	fresh.append_array(rest)
	return fresh


func _result_tile(entry: PackOpening.Entry, card_scale: float = 0.5) -> Control:
	var holder: Control = CardView.wrapped(entry.card, card_scale)
	holder.name = "Result_%s" % entry.card.id
	if entry.converted:
		holder.modulate = Color(0.6, 0.6, 0.66)
	if entry.is_new:
		var badge: Label = UIKit.label("NEW", &"", 20, Color("1d1408"), HORIZONTAL_ALIGNMENT_CENTER)
		badge.name = "NewBadge"
		badge.add_theme_font_override("font", UIStyle.font_bold())
		badge.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 8))
		badge.position = Vector2(6, 6)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(badge)
	return holder


## Overnight Nov 7-8, Part 1.11: the Open-all grid's zoomed card (tests read it).
var open_all_preview: HoverPreview = null


func _show_open_all(openings: Array[PackOpening]) -> void:
	if openings.is_empty():
		return
	if AudioRegistry.has_id("STG-PACK-COMMON"):
		Audio.sting(&"STG-PACK-COMMON")
	var layer: Control = Control.new()
	layer.name = "OpenAllSummary"
	UIKit.full_rect(layer)
	layer.z_index = 200
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.8 if not UiArt.has("UI-BG-PACKS") else 0.62)  # Import Nov 8: the back room shows through the result
	UIKit.full_rect(shade)
	layer.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	layer.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(1500, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(14)
	panel.add_child(column)
	column.add_child(UIKit.label("Packs opened", &"HeadingLabel", 36, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	# Fix pass Nov 7 (item 8, C3 F4): the cards themselves, new ones first with a NEW badge, then the one-line totals.
	var lines: PackedStringArray = summary_lines(openings)
	var totals: Label = UIKit.label(lines[0], &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(totals)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "OpenAllCards"
	scroll.custom_minimum_size = Vector2(1460, 560)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	# Overnight Nov 7-8, Part 1.11: the result cards are small - hovering one (or focusing it with the keyboard or a pad) shows it whole and
	# readable beside it, like the Deck Station's hover.
	var preview: HoverPreview = HoverPreview.new()
	preview.name = "OpenAllPreview"
	layer.add_child(preview)
	open_all_preview = preview
	for entry: PackOpening.Entry in result_entries(openings):
		var tile: Control = _result_tile(entry)
		var card: CardData = entry.card
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.focus_mode = Control.FOCUS_ALL
		tile.focus_behavior_recursive = Control.FOCUS_BEHAVIOR_ENABLED
		tile.mouse_entered.connect(func() -> void: preview.show_for(tile, card))
		tile.mouse_exited.connect(preview.hide_preview)
		tile.focus_entered.connect(func() -> void:
			preview.show_for(tile, card)
			scroll.ensure_control_visible(tile))
		tile.focus_exited.connect(preview.hide_preview)
		grid.add_child(tile)
	var extra: PackedStringArray = []
	for index: int in range(1, lines.size()):
		if not lines[index].begins_with("[color=#ffcf70]New:") and not lines[index].begins_with("More copies:"):
			extra.append(lines[index])
	if not extra.is_empty():
		column.add_child(UIKit.label(" ".join(extra), &"MutedLabel", 19, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	if Session.toasts != null:
		Session.toasts.hold()  # Fix pass Nov 7 (item 8): no toast over the cards
		layer.tree_exiting.connect(func() -> void: Session.toasts.release())
	column.add_child(UIKit.label("Every card is in your collection now: build with them at the Deck Station (B).", &"MutedLabel", 19, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var done: FancyButton = FancyButton.make("Done", &"PrimaryButton", Vector2(220, 56))
	done.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	done.pressed.connect(func() -> void:
		layer.queue_free()
		_refresh())
	column.add_child(done)
	ConfirmKey.attach(layer, done)
	(func() -> void:
		if is_instance_valid(done) and done.focus_mode != Control.FOCUS_NONE and done.is_visible_in_tree():
			done.grab_focus()).call_deferred()  # keyboard mode keeps FancyButtons unfocusable (the old plain grab_focus warned)
