class_name WardrobeScreen
extends OverlayScreen
## The wardrobe (hotkey T, HUD button). Overnight Nov 7-8, Part 5: redesigned to the Character page's look - dark panels with gold frames,
## caps headers with painted icons, clear grouping. A large framed hero preview on its stage (left); Hats and Cloaks as grids of painted
## tiles with names, owned / worn states and a detail line (right); the cloak dyes at the bottom, greyed out with "Dyes work on the Plain
## Cloak" while another cloak is worn (dyes only colour the Plain Cloak: `SpriteCosmetics.dye_applies`). Purely cosmetic; every change is
## applied and saved at once. Background: UI-BG-WARDROBE when it arrives (art list), the Character page's UI-BG-CHARACTER until then.

const PANEL_FILL: Color = Color(0.07, 0.05, 0.12, 0.88)
const TILE_FILL: Color = Color(0.11, 0.08, 0.17, 0.94)
const ACCENT: Color = Color("f2c35a")
const DIVIDER: Color = Color(0.91, 0.69, 0.29, 0.4)
const TILE_SIZE: Vector2 = Vector2(150, 176)
const ICON_SIZE: float = 104.0
## Page layout (1920 x 1080 design space).
const STAGE_RECT: Rect2 = Rect2(40, 110, 640, 930)
const HATS_RECT: Rect2 = Rect2(710, 110, 1170, 372)
const CLOAKS_RECT: Rect2 = Rect2(710, 498, 1170, 372)
const DYES_RECT: Rect2 = Rect2(710, 886, 1170, 154)

var _look: CosmeticState
var _preview: HeroPreview
var _item_tiles: Dictionary = {}  # "hat|<id>" / "cloak|<id>" -> Button
var _dye_buttons: Dictionary = {}
var _hat_detail: Label
var _cloak_detail: Label
var _stage_caption: Label
var _dye_panel: Panel
var _dye_note: Label
var _status: Label
var _page: Control


func _init() -> void:
	screen_title = ""
	title_icon_id = ""
	close_text = "Close (Esc)"
	background_id = ""


func _build() -> void:
	_look = Session.cosmetics.duplicate_state()
	_add_backdrop()
	_page = Control.new()
	_page.name = "WardrobePage"
	_page.size = Vector2(1920, 1080)
	_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_page)
	var title: Label = _text("WARDROBE", 64, UIStyle.GOLD, Vector2(52, 14), 700)
	title.name = "PageTitle"
	title.add_theme_font_override("font", UIStyle.font_title())
	title.add_theme_color_override("font_outline_color", Color(0.12, 0.06, 0.02, 0.95))
	title.add_theme_constant_override("outline_size", 10)
	_page.add_child(title)
	_build_stage()
	_build_grid(CosmeticData.Slot.HAT, HATS_RECT, "HATS", "ICON-UI-WARDROBE")
	_build_grid(CosmeticData.Slot.CLOAK, CLOAKS_RECT, "CLOAKS", "ICON-UI-CHARACTER")
	_build_dyes()
	_refresh()


## The room behind the page: UI-BG-WARDROBE once it is painted, else the Character page's room, dimmed; a plain shade without either.
func _add_backdrop() -> void:
	var id: String = "UI-BG-WARDROBE" if UiArt.has("UI-BG-WARDROBE") else "UI-BG-CHARACTER"
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


# ---- The stage ------------------------------------------------------------------------------------------------------------------------


func _build_stage() -> void:
	var stage: Panel = _make_panel("Stage", STAGE_RECT, true)
	var heading: Label = _heading("YOUR LOOK", Vector2(28, 18), 34)
	stage.add_child(heading)
	var icon: TextureRect = IconArt.rect("ICON-UI-WARDROBE", 40.0)
	icon.position = Vector2(STAGE_RECT.size.x - 70, 18)
	stage.add_child(icon)
	_divider(stage, 70, STAGE_RECT.size.x)
	# the stage itself: a warm spotlight wash behind the turning hero (HeroPreview has its own plinth)
	var wash: ColorRect = ColorRect.new()
	wash.name = "StageWash"
	wash.color = Color(0.95, 0.75, 0.4, 0.07)
	wash.position = Vector2(22, 84)
	wash.size = Vector2(STAGE_RECT.size.x - 44, 760)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(wash)
	_preview = HeroPreview.new()
	_preview.name = "HeroPreview"
	_preview.look = _look
	_preview.position = Vector2(0, 84)
	_preview.custom_minimum_size = Vector2(STAGE_RECT.size.x, 760)
	_preview.size = Vector2(STAGE_RECT.size.x, 760)
	stage.add_child(_preview)
	_stage_caption = _text("", 24, UIStyle.PARCHMENT, Vector2(24, 852), STAGE_RECT.size.x - 48, HORIZONTAL_ALIGNMENT_CENTER)
	_stage_caption.name = "StageCaption"
	stage.add_child(_stage_caption)
	_status = _text("Drag the hero to turn them round.", 18, UIStyle.MUTED, Vector2(24, 888), STAGE_RECT.size.x - 48, HORIZONTAL_ALIGNMENT_CENTER)
	stage.add_child(_status)


# ---- Hats and cloaks ------------------------------------------------------------------------------------------------------------------


func _build_grid(slot: CosmeticData.Slot, rect: Rect2, title: String, icon_id: String) -> void:
	var key: String = "hat" if slot == CosmeticData.Slot.HAT else "cloak"
	var panel: Panel = _make_panel("%sPanel" % title.capitalize(), rect, false)
	var icon: TextureRect = IconArt.rect(icon_id, 40.0)
	icon.position = Vector2(24, 16)
	panel.add_child(icon)
	panel.add_child(_heading(title, Vector2(76, 14), 34))
	var owned: int = 0
	var total: int = 1
	for item: CosmeticData in CosmeticCatalog.in_slot(slot):
		total += 1
		if _look.owns(item.id):
			owned += 1
	var count: Label = _text("%d of %d owned" % [owned + 1, total], 20, UIStyle.PARCHMENT, Vector2(rect.size.x - 324, 24), 300, HORIZONTAL_ALIGNMENT_RIGHT)
	count.name = "OwnedCount"
	panel.add_child(count)
	_divider(panel, 66, rect.size.x)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "Grid"
	scroll.position = Vector2(20, 76)
	scroll.size = Vector2(rect.size.x - 40, TILE_SIZE.y + 12)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var row: HBoxContainer = UIKit.hbox(12)
	scroll.add_child(row)
	var first_name: String = "No hat" if slot == CosmeticData.Slot.HAT else TailorScreen.PLAIN_CLOAK
	row.add_child(_tile(slot, "", first_name, null, true, "Nothing on your head. The wind approves." if slot == CosmeticData.Slot.HAT else "The cloak you woke up in. The only one the dyes colour."))
	for item: CosmeticData in CosmeticCatalog.in_slot(slot):
		var art: Texture2D = IconArt.cosmetic_texture(item, ICON_SIZE)
		if art == null and SpriteCosmetics.art_ready(item):
			art = SpriteLibrary.item_icon(slot == CosmeticData.Slot.HAT, item.art_name)
		row.add_child(_tile(slot, item.id, item.display_name, art, _look.owns(item.id) and SpriteCosmetics.art_ready(item), item.description))
	var detail: Label = _text("", 22, UIStyle.PARCHMENT, Vector2(24, rect.size.y - 92), rect.size.x - 48)
	detail.name = "Detail"
	detail.add_theme_font_override("font", UIStyle.font_italic())
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.size = Vector2(rect.size.x - 48, 64)
	panel.add_child(detail)
	if slot == CosmeticData.Slot.HAT:
		_hat_detail = detail
	else:
		_cloak_detail = detail


## One painted tile: the item's icon (or a plain mark for "No hat" / the Plain Cloak), its name, and its state - worn (gold frame and a
## tick), owned, or not owned yet (dimmed, a padlock, "Pip sells it"). Hover or focus writes the section's detail line.
func _tile(slot: CosmeticData.Slot, item_id: String, title: String, art: Texture2D, usable: bool, description: String) -> Button:
	var key: String = "hat" if slot == CosmeticData.Slot.HAT else "cloak"
	var tile: Button = Button.new()
	tile.name = "Tile_%s_%s" % [key, item_id if not item_id.is_empty() else "none"]
	tile.custom_minimum_size = TILE_SIZE
	tile.focus_mode = Control.FOCUS_ALL
	tile.set_meta("usable", usable)
	tile.set_meta("description", "%s: %s" % [title, description] if usable else "%s: not in your wardrobe yet. Pip Threadwell sells it in Crosspath." % title)
	var icon: TextureRect = _icon_rect(Vector2((TILE_SIZE.x - ICON_SIZE) * 0.5, 12), Vector2(ICON_SIZE, ICON_SIZE))
	icon.name = "Icon"
	if art != null:
		icon.texture = art
	elif item_id.is_empty():
		icon.texture = IconArt.texture("ICON-UI-WARDROBE", ICON_SIZE) if slot == CosmeticData.Slot.HAT and IconArt.has("ICON-UI-WARDROBE") else IconArt.texture("ICON-UI-CHARACTER", ICON_SIZE) if IconArt.has("ICON-UI-CHARACTER") else null
		icon.modulate = Color(1, 1, 1, 0.55)
	tile.add_child(icon)
	var name_label: Label = _text(title, 18, UIStyle.PARCHMENT, Vector2(6, 120), TILE_SIZE.x - 12, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.name = "Name"
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.size = Vector2(TILE_SIZE.x - 12, 50)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	tile.add_child(name_label)
	if not usable:
		var lock: TextureRect = _icon_rect(Vector2(TILE_SIZE.x - 40, 8), Vector2(30, 30))
		lock.name = "Lock"
		lock.texture = IconArt.texture("ICON-PADLOCK", 30.0) if IconArt.has("ICON-PADLOCK") else CardIcons.ui("lock")
		tile.add_child(lock)
		icon.modulate = Color(0.45, 0.42, 0.5, 0.8)
		name_label.add_theme_color_override("font_color", UIStyle.MUTED)
	var tick: Label = _text("✓", 22, Color("2b1a00"), Vector2(6, 6), 28, HORIZONTAL_ALIGNMENT_CENTER)
	tick.name = "WornTick"
	tick.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 8))
	tick.size = Vector2(28, 28)
	tick.visible = false
	tile.add_child(tick)
	tile.pressed.connect(func() -> void:
		if usable:
			_equip(slot, item_id)
		else:
			Audio.sfx(&"ui_error", -6.0)
		_show_detail(slot, tile))
	tile.mouse_entered.connect(func() -> void: _show_detail(slot, tile))
	tile.focus_entered.connect(func() -> void: _show_detail(slot, tile))
	_item_tiles["%s|%s" % [key, item_id]] = tile
	return tile


func _show_detail(slot: CosmeticData.Slot, tile: Button) -> void:
	var label: Label = _hat_detail if slot == CosmeticData.Slot.HAT else _cloak_detail
	if label != null:
		label.text = str(tile.get_meta("description", ""))


# ---- Dyes -----------------------------------------------------------------------------------------------------------------------------


func _build_dyes() -> void:
	_dye_panel = _make_panel("DyesPanel", DYES_RECT, false)
	_dye_panel.add_child(_heading("CLOAK DYES", Vector2(24, 12), 30))
	_dye_note = _text("", 20, UIStyle.PARCHMENT, Vector2(300, 20), DYES_RECT.size.x - 324, HORIZONTAL_ALIGNMENT_RIGHT)
	_dye_note.name = "DyeNote"
	_dye_panel.add_child(_dye_note)
	var row: HBoxContainer = UIKit.hbox(10)
	row.position = Vector2(24, 66)
	_dye_panel.add_child(row)
	for index: int in range(Dye.NATURAL, Dye.count()):
		var swatch: Button = Button.new()
		swatch.name = "Dye_cloak_%d" % index
		swatch.custom_minimum_size = Vector2(62, 62)
		swatch.tooltip_text = Dye.dye_name(index)
		swatch.focus_mode = Control.FOCUS_ALL
		if index == Dye.NATURAL:
			swatch.text = "A"
		swatch.pressed.connect(func() -> void: _dye(index))
		row.add_child(swatch)
		_dye_buttons[index] = swatch


# ---- Changes --------------------------------------------------------------------------------------------------------------------------


func _equip(slot: CosmeticData.Slot, item_id: String) -> void:
	_look.equip(slot, item_id)
	_apply()


func _dye(index: int) -> void:
	_look.set_dye(CosmeticData.Slot.CLOAK, index)
	_apply()


func _apply() -> void:
	_preview.set_look(_look)
	Session.apply_look(_look)
	Audio.sfx(&"ui_tick")
	_refresh()


## True while the dyes can colour the worn cloak (only the Plain Cloak takes a dye).
func dyes_active() -> bool:
	return SpriteCosmetics.dye_applies(_look)


func _refresh() -> void:
	for key: Variant in _item_tiles.keys():
		var tile: Button = _item_tiles[key] as Button
		if tile == null:
			continue
		var parts: PackedStringArray = str(key).split("|")
		var slot: CosmeticData.Slot = CosmeticData.Slot.HAT if parts[0] == "hat" else CosmeticData.Slot.CLOAK
		var worn: bool = _look.equipped_id(slot) == parts[1]
		var usable: bool = bool(tile.get_meta("usable", false))
		var fill: Color = TILE_FILL.lightened(0.05) if worn else TILE_FILL
		var border: Color = ACCENT if worn else (UIStyle.GOLD_DIM if usable else Color(0.35, 0.3, 0.4, 0.6))
		for state: String in ["normal", "pressed", "disabled"]:
			tile.add_theme_stylebox_override(state, UIStyle.box(fill, border, 4 if worn else 2, 12))
		tile.add_theme_stylebox_override("hover", UIStyle.box(fill.lightened(0.06), UIStyle.GOLD, 3, 12))
		tile.add_theme_stylebox_override("focus", UIStyle.focus_ring())
		var tick: Label = tile.get_node_or_null("WornTick") as Label
		if tick != null:
			tick.visible = worn
	var active: bool = dyes_active()
	_dye_note.text = "Click a colour to dye the Plain Cloak." if active else "Dyes work on the Plain Cloak."
	_dye_panel.modulate = Color(1, 1, 1, 1.0) if active else Color(0.62, 0.6, 0.66, 0.75)
	for index: Variant in _dye_buttons:
		var swatch: Button = _dye_buttons[index] as Button
		var selected_dye: bool = _look.cloak_dye == int(index)
		var owned_dye: bool = Session.cosmetics.owns_dye(int(index))
		swatch.disabled = not active or not owned_dye
		swatch.tooltip_text = (Dye.dye_name(int(index)) if owned_dye else "%s: buy it at Pip Threadwell's" % Dye.dye_name(int(index))) if active else "Dyes work on the Plain Cloak"
		swatch.modulate.a = 1.0 if active and owned_dye else 0.45
		for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
			var box: StyleBoxFlat = StyleBoxFlat.new()
			box.bg_color = Dye.primary(int(index)) if int(index) >= 0 else Color("3a3550")
			box.set_corner_radius_all(12)
			box.set_border_width_all(4 if selected_dye else 2)
			box.border_color = UIStyle.GOLD if selected_dye else Color(0, 0, 0, 0.55)
			swatch.add_theme_stylebox_override(state, box)
	var hat: CosmeticData = CosmeticCatalog.find(_look.hat_id)
	var cloak: CosmeticData = CosmeticCatalog.find(_look.cloak_id)
	_stage_caption.text = "%s  ·  %s%s" % [hat.display_name if hat != null else "No hat", cloak.display_name if cloak != null else TailorScreen.PLAIN_CLOAK, " (%s)" % Dye.dye_name(_look.cloak_dye) if active else ""]


# ---- Small builders (as on the Character page) ----------------------------------------------------------------------------------------


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


func _icon_rect(at: Vector2, rect_size: Vector2) -> TextureRect:
	var icon: TextureRect = TextureRect.new()
	icon.position = at
	icon.size = rect_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon
