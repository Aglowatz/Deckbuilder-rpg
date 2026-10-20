class_name CodexScreen
extends OverlayScreen
## The Collection Book (Overnight Oct 17, Part 10; the old card Codex). Two tabs:
## - Cards: every card, organized by Path (left column, each with its completion bar) and by rarity (sections), a silhouette (a
##   face-down card) until found (`Session.has_seen`: owned, bought or met in battle), "Own x/cap" under every found card, filters
##   (rarity, owned only) and sort (cost, name, rarity), and an inspect zoom (click a card).
## - Bestiary: every enemy and boss (`Bestiary`), unknown until met, then its icon, a fun line, where it lives and how often it was
##   beaten; discovery milestones pay rewards.
## - Gear (Overnight Oct 19-20): every equipment piece (`GearCatalog`), grouped by slot (Helm, Weapon, Armor, Boots, Relic); an owned piece
##   shows its icon, name, rarity and effect line, one not found yet is a dark silhouette with "???" and where it comes from.
## Everything is a focusable button, so it works with the keyboard as well as the mouse.

const COLUMNS: int = 7
const CARD_SCALE: float = 0.56
const BEAST_COLUMNS: int = 6
const GEAR_COLUMNS: int = 8
const GEAR_TILE: Vector2 = Vector2(196, 226)
const GEAR_ICON_PX: float = 72.0
const TABS: Array[String] = ["Cards", "Bestiary", "Gear"]
const PATH_ROWS: Array[Dictionary] = [
	{"key": "all", "label": "All Paths"},
	{"key": "neutral", "label": "Colorless"},
	{"key": "beefcake", "label": "Beefcake", "path": Affinity.Type.BEEFCAKE},
	{"key": "gourmand", "label": "Gourmand", "path": Affinity.Type.GOURMAND},
	{"key": "refusemancer", "label": "Refusemancer", "path": Affinity.Type.REFUSEMANCER},
	{"key": "necrocrat", "label": "Necrocrat", "path": Affinity.Type.NECROCRAT},
	{"key": "multi", "label": "Multi-Path"},
]
const SORTS: Array[String] = ["Cost", "Name", "Rarity"]

var _preview: HoverPreview
var _progress_label: Label
var _tab_buttons: Dictionary = {}
var _cards_page: HBoxContainer
var _beasts_page: HBoxContainer
var _grid_box: VBoxContainer
var _path_key: String = "all"
var _rarity_filter: int = -1
var _owned_only: bool = false
var _sort: int = 0
var _path_buttons: Dictionary = {}
var _rarity_buttons: Array[Button] = []
var _zoom: Control
var _beast_detail: VBoxContainer
var _beast_grid: GridContainer
var _all_cards: Array[CardData] = []
var _gear_page: HBoxContainer
var _gear_box: VBoxContainer
var _all_gear: Array[EquipmentData] = []


func _ready() -> void:
	screen_title = "Collection Book"
	title_icon_id = "ICON-UI-COLLECTION"
	close_text = "Close (Esc)"
	background_id = "UI-BG-DECKBUILDER"
	super._ready()


## The collection browser shares the deck station's theme.
func music_cue() -> String:
	return MusicDirector.deck_station()


func _build() -> void:
	_preview = HoverPreview.new()
	add_child(_preview)
	for id: Variant in Session.content.cards.keys():
		var card: CardData = Session.content.card(str(id))
		if card != null and not card.is_token:
			_all_cards.append(card)
	for tab: String in TABS:
		var button: FancyButton = FancyButton.make(tab, &"GhostButton", Vector2(150, 48))
		button.name = "Tab%s" % tab
		button.pressed.connect(func() -> void: show_tab(tab))
		header_extra.add_child(button)
		button.focus_mode = Control.FOCUS_ALL
		_tab_buttons[tab] = button
	_progress_label = UIKit.label("", &"", 24, UIStyle.GOLD)
	# It sits on the bright candle of the painting: a dark outline keeps it readable (Phase 2 cycle 6).
	_progress_label.add_theme_constant_override("outline_size", 8)
	_progress_label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.02, 0.95))
	header_extra.add_child(_progress_label)
	_cards_page = UIKit.hbox(18)
	_cards_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_cards_page)
	_build_cards_page()
	_beasts_page = UIKit.hbox(18)
	_beasts_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_beasts_page)
	_gear_page = UIKit.hbox(18)
	_gear_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_gear_page)
	# Overnight Oct 17 (Phase 2 cycle 14, performance): the Bestiary page (90 tiles) is built the first time its tab is shown, not on every open.
	# The Gear page likewise.
	show_tab("Cards")
	Session.pay_completion_milestones()


func show_tab(tab: String) -> void:
	if tab == "Bestiary" and _beast_grid == null:
		_build_beasts_page()
	if tab == "Gear" and _gear_box == null:
		_build_gear_page()
	_cards_page.visible = tab == "Cards"
	_beasts_page.visible = tab == "Bestiary"
	_gear_page.visible = tab == "Gear"
	for key: Variant in _tab_buttons.keys():
		var button: FancyButton = _tab_buttons[key] as FancyButton
		button.modulate = Color.WHITE if str(key) == tab else Color(1, 1, 1, 0.6)
	_update_progress(tab)
	if tab == "Bestiary" and _beast_grid != null and _beast_grid.get_child_count() > 0:
		(_beast_grid.get_child(0) as Control).call_deferred(&"grab_focus")
	if tab == "Gear" and _gear_box != null:
		var first: Control = _gear_box.find_child("Gear_*", true, false) as Control
		if first != null:
			first.call_deferred(&"grab_focus")


func _update_progress(tab: String) -> void:
	if tab == "Cards":
		var found: Vector2i = card_progress("all")
		_progress_label.text = "Found %d / %d  (%d%%)" % [found.x, found.y, _pct(found)]
	elif tab == "Gear":
		var owned: Vector2i = gear_progress()
		_progress_label.text = "Gear %d / %d  (%d%%)" % [owned.x, owned.y, _pct(owned)]
	else:
		var known: Vector2i = Bestiary.progress(Session.counters)
		_progress_label.text = "Met %d / %d  (%d%%)" % [known.x, known.y, _pct(known)]


static func _pct(value: Vector2i) -> int:
	return 0 if value.y == 0 else int(floor(100.0 * float(value.x) / float(value.y)))


# ---- Cards ------------------------------------------------------------------------------------------------------


## (found, total) for one Path row ("all", "neutral", "multi" or a Path key).
func card_progress(key: String) -> Vector2i:
	var found: int = 0
	var total: int = 0
	for card: CardData in _all_cards:
		if not _in_path(card, key):
			continue
		total += 1
		if Session.has_seen(card.id):
			found += 1
	return Vector2i(found, total)


func _in_path(card: CardData, key: String) -> bool:
	match key:
		"all":
			return true
		"neutral":
			return card.paths().is_empty()
		"multi":
			return card.paths().size() >= 2
	for row: Dictionary in PATH_ROWS:
		if str(row["key"]) == key and row.has("path"):
			return card.paths().size() == 1 and card.paths()[0] == (row["path"] as Affinity.Type)
	return false


func _build_cards_page() -> void:
	var side: VBoxContainer = UIKit.vbox(8)
	side.custom_minimum_size = Vector2(300, 0)
	_cards_page.add_child(side)
	side.add_child(UIKit.label("Paths", &"HeadingLabel", 26))
	for row: Dictionary in PATH_ROWS:
		var key: String = str(row["key"])
		var button: FancyButton = FancyButton.make("", &"GhostButton", Vector2(300, 62))
		button.name = "Path_%s" % key
		button.pressed.connect(func() -> void: _pick_path(key))
		var column: VBoxContainer = UIKit.vbox(2)
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.position = Vector2(12, 6)
		column.size = Vector2(276, 52)
		button.add_child(column)
		var progress: Vector2i = card_progress(key)
		var title: Label = UIKit.label("%s   %d%%" % [str(row["label"]), _pct(progress)], &"", 20, UIStyle.affinity_color(row["path"] as Affinity.Type).lightened(0.45) if row.has("path") else UIStyle.PARCHMENT)
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(title)
		var bar: ProgressBar = ProgressBar.new()
		bar.show_percentage = false
		bar.max_value = maxf(1.0, float(progress.y))
		bar.value = float(progress.x)
		bar.custom_minimum_size = Vector2(270, 10)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_theme_stylebox_override("background", UIStyle.box(Color(0, 0, 0, 0.45), Color(0, 0, 0, 0), 0, 5))
		bar.add_theme_stylebox_override("fill", UIStyle.box(UIStyle.affinity_color(row["path"] as Affinity.Type) if row.has("path") else UIStyle.GOLD, Color(0, 0, 0, 0), 0, 5))
		column.add_child(bar)
		side.add_child(button)
		button.focus_mode = Control.FOCUS_ALL
		_path_buttons[key] = button
	var main: VBoxContainer = UIKit.vbox(10)
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards_page.add_child(main)
	var filters: HBoxContainer = UIKit.hbox(8)
	main.add_child(filters)
	filters.add_child(UIKit.label("Rarity", &"MutedLabel", 18, UIStyle.MUTED))
	for rarity: int in range(-1, CardEnums.Rarity.size()):
		var label: String = "All" if rarity < 0 else CardView.RARITY_NAMES[rarity]
		var chip: FancyButton = FancyButton.make(label, &"GhostButton", Vector2(0, 40))
		chip.add_theme_font_size_override("font_size", 18)
		if rarity >= 0:
			chip.add_theme_color_override("font_color", CardView.RARITY_COLORS[rarity].lightened(0.25))
		chip.pressed.connect(func() -> void:
			_rarity_filter = rarity
			_refresh_grid())
		filters.add_child(chip)
		chip.focus_mode = Control.FOCUS_ALL
		_rarity_buttons.append(chip)
	filters.add_child(UIKit.filler())
	var owned: FancyButton = FancyButton.make("Owned only: off", &"GhostButton", Vector2(170, 40))
	owned.name = "OwnedOnly"
	owned.add_theme_font_size_override("font_size", 18)
	owned.pressed.connect(func() -> void:
		_owned_only = not _owned_only
		owned.text = "Owned only: %s" % ("on" if _owned_only else "off")
		_refresh_grid())
	filters.add_child(owned)
	owned.focus_mode = Control.FOCUS_ALL
	var sort: FancyButton = FancyButton.make("Sort: Cost", &"GhostButton", Vector2(150, 40))
	sort.name = "SortButton"
	sort.add_theme_font_size_override("font_size", 18)
	sort.pressed.connect(func() -> void:
		_sort = (_sort + 1) % SORTS.size()
		sort.text = "Sort: %s" % SORTS[_sort]
		_refresh_grid())
	filters.add_child(sort)
	sort.focus_mode = Control.FOCUS_ALL
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	main.add_child(scroll)
	_grid_box = UIKit.vbox(10)
	_grid_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_grid_box)
	_refresh_grid()


func _pick_path(key: String) -> void:
	_path_key = key
	Audio.sfx(&"ui_select")
	_refresh_grid()


func _sorted(cards: Array[CardData]) -> Array[CardData]:
	var result: Array[CardData] = cards.duplicate()
	match _sort:
		0:
			result.sort_custom(func(a: CardData, b: CardData) -> bool:
				return a.display_name < b.display_name if a.energy_value() == b.energy_value() else a.energy_value() < b.energy_value())
		1:
			result.sort_custom(func(a: CardData, b: CardData) -> bool: return a.display_name < b.display_name)
		2:
			result.sort_custom(func(a: CardData, b: CardData) -> bool:
				return a.display_name < b.display_name if a.rarity == b.rarity else int(a.rarity) > int(b.rarity))
	return result


## Rebuilds the grid: the selected Path's cards in one section per rarity (rarest last), each section with its own count.
func _refresh_grid() -> void:
	for key: Variant in _path_buttons.keys():
		(_path_buttons[key] as FancyButton).modulate = Color.WHITE if str(key) == _path_key else Color(0.85, 0.85, 0.85, 0.85)
	for index: int in range(_rarity_buttons.size()):
		_rarity_buttons[index].modulate = Color.WHITE if index - 1 == _rarity_filter else Color(0.85, 0.85, 0.85, 0.8)
	for child: Node in _grid_box.get_children():
		_grid_box.remove_child(child)
		child.queue_free()
	_pending.clear()
	var built: int = 0
	for rarity: int in range(CardEnums.Rarity.size()):
		if _rarity_filter >= 0 and rarity != _rarity_filter:
			continue
		var cards: Array[CardData] = []
		for card: CardData in _all_cards:
			if int(card.rarity) != rarity or not _in_path(card, _path_key):
				continue
			if _owned_only and Session.owned_count(card.id) == 0 and not card.is_unlimited():
				continue
			cards.append(card)
		if cards.is_empty():
			continue
		var found: int = 0
		for card: CardData in cards:
			if Session.has_seen(card.id):
				found += 1
		var heading: Label = UIKit.label("%s  -  %d / %d found" % [CardView.RARITY_NAMES[rarity], found, cards.size()], &"", 24, CardView.RARITY_COLORS[rarity])
		heading.add_theme_font_override("font", UIStyle.font_title())
		_grid_box.add_child(heading)
		var grid: GridContainer = GridContainer.new()
		grid.columns = COLUMNS
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		_grid_box.add_child(grid)
		for card: CardData in _sorted(cards):
			if built < FIRST_TILES:
				_add_tile(grid, card)
				built += 1
			else:
				_pending.append([grid, card])
	if _grid_box.get_child_count() == 0:
		_grid_box.add_child(UIKit.label("Nothing here yet.", &"MutedLabel", 22, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))


## Overnight Oct 17 (Phase 2, performance): the first tiles are built at once, the rest a few per frame (no long frame on opening).
const FIRST_TILES: int = 0  # Overnight Oct 18 cycle 34: was 8 - the opening frame 73-82 -> ~17 ms, the cards start on the next frame
const TILES_PER_FRAME: int = 3
var _pending: Array[Array] = []


func _add_tile(grid: GridContainer, card: CardData) -> void:
	var tile: Button = _card_tile(card)
	grid.add_child(tile)
	tile.focus_mode = Control.FOCUS_ALL


## True while card tiles are still being added.
func is_building() -> bool:
	return not _pending.is_empty()


func _process(_delta: float) -> void:
	for _step: int in range(TILES_PER_FRAME):
		if _pending.is_empty():
			return
		var next: Array = _pending.pop_front()
		var grid: GridContainer = next[0] as GridContainer
		if is_instance_valid(grid) and not grid.is_queued_for_deletion():
			_add_tile(grid, next[1] as CardData)


func _card_tile(card: CardData) -> Button:
	var seen: bool = Session.has_seen(card.id)
	var tile: Button = Button.new()
	tile.flat = true
	tile.name = "Card_%s" % card.id
	tile.custom_minimum_size = CardView.SIZE * CARD_SCALE + Vector2(0, 28)
	tile.add_theme_stylebox_override("focus", UIStyle.box(Color(0, 0, 0, 0), Color("ffe08a"), 3, 12))
	var view: CardView = CardView.create(card, CardView.Mode.FULL if seen else CardView.Mode.BACK, true)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(view)
	CardView.fit(view, CARD_SCALE)
	for child: Node in view.find_children("*", "Control", true, false):
		(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line: Label = UIKit.label("", &"", 17, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.position = Vector2(0, CardView.SIZE.y * CARD_SCALE + 2)
	line.size = Vector2(CardView.SIZE.x * CARD_SCALE, 24)
	tile.add_child(line)
	if seen:
		var owned: int = Session.owned_count(card.id)
		line.text = "Infrastructure" if card.is_unlimited() else "Own %s" % CopyCaps.ratio_text(owned, card, Session.profile.level)
		line.add_theme_color_override("font_color", UIStyle.GOOD if owned > 0 or card.is_unlimited() else UIStyle.MUTED)
		tile.tooltip_text = card.display_name
		tile.mouse_entered.connect(func() -> void: _preview.show_for(tile, card))
		tile.mouse_exited.connect(_preview.hide_preview)
		tile.pressed.connect(func() -> void: inspect(card))
	else:
		view.modulate = Color(0.45, 0.45, 0.52)
		line.text = "???"
		line.add_theme_color_override("font_color", UIStyle.MUTED)
		tile.tooltip_text = "Not found yet."
	return tile


## The inspect zoom: the card big, its rarity, Path and how many you own against the cap. Click or Esc closes it.
func inspect(card: CardData) -> void:
	_close_zoom()
	_preview.hide_preview()
	Audio.sfx(&"ui_open", -6.0)
	_zoom = Control.new()
	_zoom.name = "CardZoom"
	UIKit.full_rect(_zoom)
	_zoom.z_index = 200
	_zoom.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_zoom)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.85)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom.add_child(shade)
	var holder: Control = Control.new()
	holder.position = Vector2(560, 120)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom.add_child(holder)
	var view: CardView = CardView.create(card, CardView.Mode.FULL)
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(view)
	CardView.fit(view, 1.75)
	var info: VBoxContainer = UIKit.vbox(10)
	info.position = Vector2(1120, 300)
	info.size = Vector2(560, 400)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zoom.add_child(info)
	var title: Label = UIKit.label(card.display_name, &"TitleLabel", 44, UIStyle.GOLD)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.custom_minimum_size = Vector2(540, 0)
	info.add_child(title)
	info.add_child(UIKit.label(CardView.RARITY_NAMES[int(card.rarity)], &"", 26, CardView.RARITY_COLORS[int(card.rarity)]))
	var paths: PackedStringArray = []
	for path: Affinity.Type in card.paths():
		paths.append(UIStyle.affinity_name(path))
	info.add_child(UIKit.label("Path: %s" % (" / ".join(paths) if not paths.is_empty() else "Colorless"), &"", 22, UIStyle.PARCHMENT))
	if not card.is_unlimited():
		var owned: int = Session.owned_count(card.id)
		info.add_child(UIKit.label("You own %s" % CopyCaps.ratio_text(owned, card, Session.profile.level), &"", 22, UIStyle.PARCHMENT))
		var cap: int = CopyCaps.for_card(card, Session.profile.level)
		if cap < CopyCaps.ABSOLUTE_MAX:
			var hint: Label = UIKit.label(CopyCaps.reason(card, Session.profile.level), &"MutedLabel", 18, UIStyle.MUTED)
			hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hint.custom_minimum_size = Vector2(540, 0)
			info.add_child(hint)
	info.add_child(UIKit.spacer(10))
	var back: FancyButton = FancyButton.make("Back (Esc)", &"PrimaryButton", Vector2(200, 54))
	back.pressed.connect(_close_zoom)
	info.add_child(back)
	back.focus_mode = Control.FOCUS_ALL
	back.call_deferred(&"grab_focus")
	UIKit.pop_in(holder)


func _close_zoom() -> void:
	if _zoom != null and is_instance_valid(_zoom):
		_zoom.queue_free()
	_zoom = null


func request_close() -> void:
	if _zoom != null and is_instance_valid(_zoom) and not _zoom.is_queued_for_deletion():
		_close_zoom()
		return
	super.request_close()


# ---- Bestiary ---------------------------------------------------------------------------------------------------


func _build_beasts_page() -> void:
	var left: VBoxContainer = UIKit.vbox(10)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_beasts_page.add_child(left)
	var milestones: HBoxContainer = UIKit.hbox(12)
	left.add_child(milestones)
	for milestone: Dictionary in Bestiary.MILESTONES:
		var reached: bool = Session.flag(StringName("bestiary_%d" % int(milestone["percent"])))
		var reward: String = "%d gold" % int(milestone["gold"]) if milestone.has("gold") else ("a Gilded Pack" if str(milestone.get("pack", "")) == "gilded" else "a Path Pack")
		var chip: Label = UIKit.label("%d%%: %s%s" % [int(milestone["percent"]), reward, "  (done)" if reached else ""], &"", 17, UIStyle.GOOD if reached else UIStyle.MUTED)
		chip.add_theme_stylebox_override("normal", UIStyle.box(Color(0, 0, 0, 0.35), UIStyle.GOOD if reached else Color(1, 1, 1, 0.15), 1, 8))
		milestones.add_child(chip)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	left.add_child(scroll)
	_beast_grid = GridContainer.new()
	_beast_grid.columns = BEAST_COLUMNS
	_beast_grid.add_theme_constant_override("h_separation", 10)
	_beast_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_beast_grid)
	for entry: Bestiary.Entry in Bestiary.all():
		var tile: Button = _beast_tile(entry)
		_beast_grid.add_child(tile)
		tile.focus_mode = Control.FOCUS_ALL
	var detail_panel: PanelContainer = UIKit.panel()
	detail_panel.custom_minimum_size = Vector2(520, 0)
	_beasts_page.add_child(detail_panel)
	_beast_detail = UIKit.vbox(12)
	detail_panel.add_child(UIKit.margin(_beast_detail, 18))
	_beast_detail.add_child(UIKit.label("Pick an entry.", &"MutedLabel", 22, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))


func _beast_tile(entry: Bestiary.Entry) -> Button:
	var known: bool = Bestiary.is_known(Session.counters, entry.name)
	var tile: Button = Button.new()
	tile.name = "Beast_%s" % entry.name.validate_node_name()
	tile.custom_minimum_size = Vector2(176, 168)
	UiSkin.choice_tile(tile, Color("ff9c3a") if entry.is_boss() and known else UIStyle.GOLD, false, not known)
	var icon: TextureRect = beast_picture(entry, known, 84.0)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.position = Vector2(46, 14)
	icon.size = Vector2(84, 84)
	tile.add_child(icon)
	var name_label: Label = UIKit.label(entry.name if known else "???", &"", 16, UIStyle.PARCHMENT if known else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.position = Vector2(6, 104)
	name_label.size = Vector2(164, 56)
	tile.add_child(name_label)
	if entry.is_boss():
		var badge: Label = UIKit.label("BOSS", &"", 13, UIStyle.INK, HORIZONTAL_ALIGNMENT_CENTER)
		badge.add_theme_stylebox_override("normal", UIStyle.box(Color("ff9c3a") if known else Color(0.4, 0.35, 0.3), Color(0, 0, 0, 0), 0, 6))
		badge.position = Vector2(118, 6)
		badge.size = Vector2(52, 20)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(badge)
	tile.pressed.connect(func() -> void: show_beast(entry))
	tile.focus_entered.connect(func() -> void: show_beast(entry))
	return tile


## The entry's picture when one has been made (Bestiary.art; a dark silhouette until met), else its tinted icon.
static func beast_picture(entry: Bestiary.Entry, known: bool, px: float) -> TextureRect:
	var art: Texture2D = Bestiary.art(entry.name)
	if art == null:
		return CardIcons.glyph(beast_icon(entry), (Color("ffb070") if entry.is_boss() else UIStyle.PARCHMENT) if known else Color(0.12, 0.1, 0.16), Vector2(px, px))
	var picture: TextureRect = TextureRect.new()
	picture.name = "BeastArt"
	picture.texture = art
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size = Vector2(px, px)
	picture.size = Vector2(px, px)
	if not known:
		picture.modulate = Color(0.06, 0.05, 0.09, 0.95)
	return picture


static func beast_icon(entry: Bestiary.Entry) -> Texture2D:
	var texture: Texture2D = CardIcons.named(entry.icon) if ResourceLoader.exists(CardIcons.BASE + entry.icon + ".svg") else null
	return texture if texture != null else CardIcons.named(Bestiary.FALLBACK_ICON)


## The detail panel: picture, name, where, the fun line and how often it was beaten (or "Not met yet").
func show_beast(entry: Bestiary.Entry) -> void:
	for child: Node in _beast_detail.get_children():
		child.queue_free()
	var known: bool = Bestiary.is_known(Session.counters, entry.name)
	var icon: TextureRect = beast_picture(entry, known, 180.0)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_beast_detail.add_child(icon)
	var title: Label = UIKit.label(entry.name if known else "???", &"TitleLabel", 34, Color("ffb070") if entry.is_boss() and known else UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.custom_minimum_size = Vector2(480, 0)
	_beast_detail.add_child(title)
	_beast_detail.add_child(UIKit.label(("Boss" if entry.is_boss() else ("Roamer" if entry.kind == "roamer" else "Foe")) + "  -  " + entry.where, &"MutedLabel", 19, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var blurb: Label = UIKit.label(entry.blurb if known else "Not met yet. Somewhere out there, it is waiting. Probably doing push-ups.", &"", 22, UIStyle.PARCHMENT if known else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(480, 0)
	_beast_detail.add_child(blurb)
	if known:
		var wins: int = Bestiary.won_count(Session.counters, entry.name)
		_beast_detail.add_child(UIKit.label("Defeated %d time%s" % [wins, "" if wins == 1 else "s"], &"", 22, UIStyle.GOOD if wins > 0 else UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))


# ---- Gear -------------------------------------------------------------------------------------------------------


## Every piece the game has, in slot order (built once).
func all_gear() -> Array[EquipmentData]:
	if _all_gear.is_empty():
		_all_gear = GearCatalog.all_pieces(Session.content)
	return _all_gear


## (owned, total) over every piece.
func gear_progress() -> Vector2i:
	return GearCatalog.progress(all_gear(), Session.owned_equipment_ids())


## One section per slot (Helm, Weapon, Armor, Boots, Relic), each with its own count. There is no gear zoom: a found tile's tooltip
## carries the full text (`EquipmentData.tooltip_text`).
func _build_gear_page() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	_gear_page.add_child(scroll)
	_gear_box = UIKit.vbox(10)
	_gear_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_gear_box)
	var owned_ids: Array[String] = Session.owned_equipment_ids()
	var quests: Array[QuestData] = QuestCatalog.all()
	for slot: EquipmentData.Slot in GearCatalog.SLOT_ORDER:
		var pieces: Array[EquipmentData] = GearCatalog.of_slot(all_gear(), slot)
		if pieces.is_empty():
			continue
		var found: Vector2i = GearCatalog.progress(pieces, owned_ids)
		var heading: Label = UIKit.label("%s  -  %d / %d found" % [EquipmentData.slot_name(slot), found.x, found.y], &"", 24, UIStyle.GOLD)
		heading.name = "GearHeading_%s" % EquipmentData.slot_name(slot)
		heading.add_theme_font_override("font", UIStyle.font_title())
		_gear_box.add_child(heading)
		var grid: GridContainer = GridContainer.new()
		grid.name = "GearGrid_%s" % EquipmentData.slot_name(slot)
		grid.columns = GEAR_COLUMNS
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		_gear_box.add_child(grid)
		for piece: EquipmentData in pieces:
			var owned: bool = owned_ids.has(piece.id)
			var tile: Button = _gear_tile(piece, owned, "" if owned else GearCatalog.source_hint(piece, Session.content, quests))
			grid.add_child(tile)
			tile.focus_mode = Control.FOCUS_ALL


func _gear_tile(piece: EquipmentData, owned: bool, hint: String) -> Button:
	var rarity: int = clampi(int(piece.rarity), 0, CardView.RARITY_COLORS.size() - 1)
	var tile: Button = Button.new()
	tile.name = "Gear_%s" % piece.id
	tile.custom_minimum_size = GEAR_TILE
	UiSkin.choice_tile(tile, CardView.RARITY_COLORS[rarity] if owned else UIStyle.GOLD, false, not owned)
	var icon: TextureRect = gear_picture(piece, owned, GEAR_ICON_PX)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.position = Vector2((GEAR_TILE.x - GEAR_ICON_PX) * 0.5, 10)
	icon.size = Vector2(GEAR_ICON_PX, GEAR_ICON_PX)
	tile.add_child(icon)
	var name_label: Label = UIKit.label(piece.source_name if owned else "???", &"", 16, UIStyle.PARCHMENT if owned else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.name = "GearName"
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.max_lines_visible = 2
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.position = Vector2(6, 86)
	name_label.size = Vector2(GEAR_TILE.x - 12, 40)
	tile.add_child(name_label)
	if owned:
		var badge: Label = UIKit.label(EquipmentRarity.display_name(rarity), &"", 14, CardView.RARITY_COLORS[rarity], HORIZONTAL_ALIGNMENT_CENTER)
		badge.name = "GearRarity"
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.position = Vector2(6, 126)
		badge.size = Vector2(GEAR_TILE.x - 12, 20)
		tile.add_child(badge)
		var effect: Label = UIKit.label(piece.description, &"", 13, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		effect.name = "GearEffect"
		effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		effect.max_lines_visible = 4
		effect.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		effect.position = Vector2(8, 148)
		effect.size = Vector2(GEAR_TILE.x - 16, 70)
		tile.add_child(effect)
		tile.tooltip_text = piece.tooltip_text()
	else:
		var where: Label = UIKit.label(hint, &"", 14, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		where.name = "GearHint"
		where.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		where.max_lines_visible = 4
		where.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		where.mouse_filter = Control.MOUSE_FILTER_IGNORE
		where.position = Vector2(8, 132)
		where.size = Vector2(GEAR_TILE.x - 16, 86)
		tile.add_child(where)
		tile.tooltip_text = "Not found yet.\n%s" % hint
	return tile


## The piece's full-colour icon (game-icons fallback otherwise); a dark silhouette until owned.
static func gear_picture(piece: EquipmentData, owned: bool, px: float) -> TextureRect:
	var picture: TextureRect = IconArt.equipment_glyph(piece, UIStyle.PARCHMENT if owned else Color(0.12, 0.1, 0.16), px)
	picture.name = "GearIcon"
	picture.custom_minimum_size = Vector2(px, px)
	if not owned and IconArt.has_equipment_icon(piece):
		picture.modulate = Color(0.06, 0.05, 0.09, 0.95)
	return picture
