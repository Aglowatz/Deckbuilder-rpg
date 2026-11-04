class_name CharacterScreen
extends OverlayScreen
## The Character page (Overnight Nov 3-4, Part C - spec docs/ui/character_menu_spec.md, target docs/ui/ref/character_menu_target.png):
## the parchment figure with the five equipment slots on the left, LEVEL and CARD PACKS in the middle, and the ITEMS panel - the page's
## focus - on the right: four positional item slots (locked ones say the level that opens them), the inventory grid with charges, and a
## detail row with Equip / Unequip. Clicking an equipment slot opens the Equipment selection page in the Items panel's style.
## Reachable with the C hotkey or the HUD menu in town, or right after leveling up. No new art: UI-BG-CHARACTER is drawn twice (a dimmed
## crop of the room behind everything, the poster with the silhouette on the left), the panels are StyleBoxes.

signal item_equipped(item: ItemData)
signal equipment_equipped(piece: EquipmentData)

## The page in the 1920 x 1080 design space (spec sections 1-6).
const ROOM_REGION: Rect2 = Rect2(836, 0, 700, 864)
const POSTER_REGION: Rect2 = Rect2(245, 0, 590, 760)
const POSTER_POS: Vector2 = Vector2(10, 95)
const POSTER_SCALE: float = 1.1
const SLOT_SIZE: float = 124.0
const EQUIP_CENTERS: Dictionary = {
	EquipmentData.Slot.HELM: Vector2(363, 200),
	EquipmentData.Slot.ARMOR: Vector2(363, 400),
	EquipmentData.Slot.WEAPON: Vector2(193, 590),
	EquipmentData.Slot.RELIC: Vector2(533, 590),
	EquipmentData.Slot.BOOTS: Vector2(363, 835),
}
const SLOT_ORDER: Array[EquipmentData.Slot] = [
	EquipmentData.Slot.HELM, EquipmentData.Slot.ARMOR, EquipmentData.Slot.WEAPON, EquipmentData.Slot.RELIC, EquipmentData.Slot.BOOTS,
]
const SLOT_KEYS: Dictionary = {
	EquipmentData.Slot.HELM: "helm", EquipmentData.Slot.WEAPON: "weapon", EquipmentData.Slot.ARMOR: "armor",
	EquipmentData.Slot.BOOTS: "boots", EquipmentData.Slot.RELIC: "relic",
}
const PILL_RECT: Rect2 = Rect2(105, 935, 505, 48)
const LEVEL_RECT: Rect2 = Rect2(672, 95, 412, 420)
const PACKS_RECT: Rect2 = Rect2(672, 530, 412, 485)
const ITEMS_RECT: Rect2 = Rect2(1112, 95, 775, 920)
const EQUIP_PAGE_RECT: Rect2 = Rect2(672, 95, 1215, 920)
const ITEM_SLOT_SIZE: Vector2 = Vector2(162, 140)
const ITEM_SLOT_GAP: float = 22.0
const ITEM_SLOTS_Y: float = 165.0
const CELL_SIZE: Vector2 = Vector2(128, 116)
const CELL_GAP: int = 12
const GRID_COLUMNS: int = 5
const MAX_ITEM_SLOTS: int = 4

const PANEL_FILL: Color = Color(0.07, 0.05, 0.12, 0.86)
const SLOT_FILL: Color = Color(0.11, 0.08, 0.17, 0.92)
const ACCENT: Color = Color("f2c35a")
const LOCKED_FILL: Color = Color(0.06, 0.05, 0.09, 0.85)
const DIVIDER: Color = Color(0.91, 0.69, 0.29, 0.4)

const SUBTITLE: String = "Equip up to 4 single-use items"
const SLOTS_NOTE: String = "Additional slots unlock as you level up. One charge is consumed per use."
const FOOTER: String = "Select an item, then choose an empty slot to equip."
const PACKS_EMPTY: String = "No unopened packs"
const PACKS_HINT: String = "Find packs in dungeons, quests and shops."

var _page: Control
var _equip_buttons: Dictionary = {}
var _unlock_pill: Control
var _level_title: Label
var _xp_label: Label
var _xp_bar: ProgressBar
var _stat_values: Dictionary = {}
var _essence_values: Dictionary = {}
var _packs_list: VBoxContainer
var _items_panel: Panel
var _unlocked_label: Label
var _item_slot_buttons: Array[Button] = []
var _item_types_label: Label
var _grid: GridContainer
var _detail_icon: TextureRect
var _detail_name: Label
var _detail_meta: Label
var _detail_effect: Label
var _detail_status: Label
var _detail_button: FancyButton
var _use_button: FancyButton
var _selected_item: ItemData
var _equipment_page: Control
var _equipment_slot: EquipmentData.Slot = EquipmentData.Slot.HELM
var _selected_piece: EquipmentData
var _toast: Label
var _highlights: Array[Control] = []
var _highlight_time: float = 0.0


func _init() -> void:
	screen_title = ""
	title_icon_id = ""
	close_text = "Close (Esc)"
	background_id = ""


# ---- Build ------------------------------------------------------------------------------------------------------------------------


func _build() -> void:
	_add_backdrop()
	_page = Control.new()
	_page.name = "CharacterPage"
	_page.position = Vector2.ZERO
	_page.size = Vector2(1920, 1080)
	_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_page)
	var title: Label = _text("CHARACTER", 64, UIStyle.GOLD, Vector2(52, 14), 600)
	title.name = "PageTitle"
	title.add_theme_font_override("font", UIStyle.font_title())
	title.add_theme_color_override("font_outline_color", Color(0.12, 0.06, 0.02, 0.95))
	title.add_theme_constant_override("outline_size", 10)
	_page.add_child(title)
	_build_equipment()
	_build_level_panel()
	_build_packs_panel()
	_build_items_panel()
	_toast = _text("", 24, UIStyle.PARCHMENT, Vector2(560, 1028), 800, HORIZONTAL_ALIGNMENT_CENTER)
	_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.modulate.a = 0.0
	_page.add_child(_toast)
	_refresh()


## The room behind everything (a dimmed crop of the background's right half, no second poster peeking out) and the poster with the
## silhouette on the left (spec 1). Plain dark shade when the background art is missing.
func _add_backdrop() -> void:
	var texture: Texture2D = UiArt.texture("UI-BG-CHARACTER") if UiArt.has("UI-BG-CHARACTER") else null
	var back: Control = Control.new()
	back.name = "Backdrop"
	UIKit.full_rect(back)
	back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(back)
	# above the OverlayScreen's own dark shade and glow, below its header (the close button) and the page
	for child: Node in get_children():
		if child is MarginContainer:
			move_child(back, child.get_index())
			break
	if texture == null:
		return
	var tex_size: Vector2 = texture.get_size()
	var scale_to_source: float = tex_size.x / 1536.0
	var room: AtlasTexture = AtlasTexture.new()
	room.atlas = texture
	room.region = Rect2(ROOM_REGION.position * scale_to_source, ROOM_REGION.size * scale_to_source)
	var room_rect: TextureRect = TextureRect.new()
	room_rect.texture = room
	room_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	room_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(room_rect)
	room_rect.modulate = Color(0.45, 0.42, 0.45)
	room_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.add_child(room_rect)
	var poster: AtlasTexture = AtlasTexture.new()
	poster.atlas = texture
	poster.region = Rect2(POSTER_REGION.position * scale_to_source, POSTER_REGION.size * scale_to_source)
	var poster_rect: TextureRect = TextureRect.new()
	poster_rect.name = "Poster"
	poster_rect.texture = poster
	poster_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poster_rect.stretch_mode = TextureRect.STRETCH_SCALE
	poster_rect.position = POSTER_POS
	poster_rect.size = POSTER_REGION.size * POSTER_SCALE
	poster_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back.add_child(poster_rect)


func _build_equipment() -> void:
	var stage: Control = Control.new()
	stage.name = "EquipmentStage"
	stage.size = Vector2(1920, 1080)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page.add_child(stage)
	for slot: EquipmentData.Slot in SLOT_ORDER:
		var button: Button = Button.new()
		button.name = "EquipSlot_%s" % str(SLOT_KEYS[slot])
		button.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		button.custom_minimum_size = button.size
		button.position = (EQUIP_CENTERS[slot] as Vector2) - button.size * 0.5
		button.focus_mode = Control.FOCUS_ALL
		button.add_theme_stylebox_override("focus", UIStyle.focus_ring())
		var icon: TextureRect = _icon_rect(Vector2(SLOT_SIZE, SLOT_SIZE) * 0.18, Vector2(SLOT_SIZE, SLOT_SIZE) * 0.64)
		icon.name = "Icon"
		button.add_child(icon)
		var caption: Label = _text(EquipmentData.slot_name(slot), 22, UIStyle.PARCHMENT, Vector2(-30, SLOT_SIZE + 6), SLOT_SIZE + 60, HORIZONTAL_ALIGNMENT_CENTER)
		caption.add_theme_font_override("font", UIStyle.font_bold())
		caption.add_theme_color_override("font_outline_color", Color(0.12, 0.07, 0.03, 0.95))
		caption.add_theme_constant_override("outline_size", 6)
		button.add_child(caption)
		button.mouse_entered.connect(func() -> void: Audio.sfx(&"ui_hover", -10.0))
		var chosen: EquipmentData.Slot = slot
		button.pressed.connect(func() -> void: _on_equipment_slot_pressed(chosen))
		stage.add_child(button)
		_equip_buttons[slot] = button
	_unlock_pill = Panel.new()
	_unlock_pill.name = "UnlockPill"
	_unlock_pill.position = PILL_RECT.position
	_unlock_pill.size = PILL_RECT.size
	_unlock_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_unlock_pill.add_theme_stylebox_override("panel", UIStyle.box(Color(0.12, 0.07, 0.04, 0.88), UIStyle.GOLD, 2, 24))
	var pill_text: Label = _text(equipment_unlock_text(), 22, UIStyle.PARCHMENT, Vector2(10, 0), PILL_RECT.size.x - 20, HORIZONTAL_ALIGNMENT_CENTER)
	pill_text.name = "PillText"
	pill_text.size.y = PILL_RECT.size.y
	pill_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_unlock_pill.add_child(pill_text)
	_page.add_child(_unlock_pill)


## "Equipment unlocks after <the armory quest's real title>" (spec 2).
static func equipment_unlock_text() -> String:
	var quest: QuestData = QuestCatalog.find(QuestDefinitions.ARMORY)
	return "Equipment unlocks after %s" % (quest.title if quest != null else "the armory quest")


func _build_level_panel() -> void:
	var panel: Panel = _make_panel("LevelPanel", LEVEL_RECT, false)
	var star: TextureRect = IconArt.rect("ICON-LEVEL", 44.0)
	if star != null:
		star.position = Vector2(24, 20)
		star.size = Vector2(44, 44)
		panel.add_child(star)
	_level_title = _text("", 40, UIStyle.PARCHMENT, Vector2(78, 14), 300)
	_level_title.add_theme_font_override("font", UIStyle.font_title())
	panel.add_child(_level_title)
	_xp_label = _text("", 22, UIStyle.PARCHMENT, Vector2(80, 64), 300)
	panel.add_child(_xp_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.name = "XpBar"
	_xp_bar.position = Vector2(24, 100)
	_xp_bar.size = Vector2(LEVEL_RECT.size.x - 48, 22)
	_xp_bar.show_percentage = false
	UiSkin.skin_bar(_xp_bar, "xp", 44.0, UIStyle.GOLD)
	panel.add_child(_xp_bar)
	_divider(panel, 140.0, LEVEL_RECT.size.x)
	var rows: Array[Array] = [["hp", "HP", "ICON-STAT-HP"], ["opening", "Opening hand", "ICON-DECKBOX"], ["max_hand", "Max hand", "ICON-DECKBOX"], ["gold", "Gold", "ICON-GOLD"]]
	for index: int in rows.size():
		var row: Array = rows[index]
		var y: float = 150.0 + 36.0 * float(index)
		var icon: TextureRect = IconArt.rect(str(row[2]), 26.0)
		if icon != null:
			icon.position = Vector2(24, y + 2)
			icon.size = Vector2(26, 26)
			panel.add_child(icon)
		panel.add_child(_text(str(row[1]), 23, UIStyle.PARCHMENT, Vector2(60, y), 220))
		var value: Label = _text("", 23, UIStyle.PARCHMENT, Vector2(LEVEL_RECT.size.x - 184, y), 160, HORIZONTAL_ALIGNMENT_RIGHT)
		value.name = "Stat_%s" % str(row[0])
		panel.add_child(value)
		_stat_values[str(row[0])] = value
	_divider(panel, 298.0, LEVEL_RECT.size.x)
	panel.add_child(_heading("PATH ESSENCE", Vector2(24, 308), 22))
	var x: float = 24.0
	for path: Affinity.Type in Affinity.colored_types():
		var vial: TextureRect = IconArt.rect(IconArt.essence_id(path), 36.0, "%s essence" % UIStyle.affinity_name(path))
		if vial != null:
			vial.position = Vector2(x, 350)
			vial.size = Vector2(36, 36)
			panel.add_child(vial)
		var amount: Label = _text("0", 24, UIStyle.affinity_color(path).lightened(0.35), Vector2(x + 40, 352), 50)
		amount.name = "Essence_%d" % int(path)
		panel.add_child(amount)
		_essence_values[int(path)] = amount
		x += 92.0


func _build_packs_panel() -> void:
	var panel: Panel = _make_panel("PacksPanel", PACKS_RECT, false)
	var icon: TextureRect = IconArt.rect("ICON-UI-PACKS", 40.0)
	if icon != null:
		icon.position = Vector2(24, 20)
		icon.size = Vector2(40, 40)
		panel.add_child(icon)
	panel.add_child(_heading("CARD PACKS", Vector2(76, 18), 34))
	_divider(panel, 76.0, PACKS_RECT.size.x)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.position = Vector2(20, 92)
	scroll.size = Vector2(PACKS_RECT.size.x - 40, PACKS_RECT.size.y - 112)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	_packs_list = UIKit.vbox(10)
	_packs_list.name = "PacksList"
	_packs_list.custom_minimum_size = Vector2(scroll.size.x - 12, 0)
	scroll.add_child(_packs_list)


func _build_items_panel() -> void:
	_items_panel = _make_panel("ItemsPanel", ITEMS_RECT, true)
	var panel: Panel = _items_panel
	var icon: TextureRect = IconArt.rect("ICON-UI-INVENTORY", 48.0)
	if icon != null:
		icon.position = Vector2(28, 22)
		icon.size = Vector2(48, 48)
		panel.add_child(icon)
	panel.add_child(_heading("ITEMS", Vector2(90, 14), 44))
	panel.add_child(_text(SUBTITLE, 22, UIStyle.PARCHMENT, Vector2(92, 70), 500))
	_divider(panel, 110.0, ITEMS_RECT.size.x)
	panel.add_child(_heading("EQUIPPED", Vector2(28, 124), 26))
	_unlocked_label = _text("", 24, UIStyle.PARCHMENT, Vector2(ITEMS_RECT.size.x - 328, 124), 300, HORIZONTAL_ALIGNMENT_RIGHT)
	_unlocked_label.name = "UnlockedCount"
	panel.add_child(_unlocked_label)
	var total: float = ITEM_SLOT_SIZE.x * 4.0 + ITEM_SLOT_GAP * 3.0
	var left: float = (ITEMS_RECT.size.x - total) * 0.5
	for index: int in MAX_ITEM_SLOTS:
		var button: Button = Button.new()
		button.name = "ItemSlot_%d" % index
		button.position = Vector2(left + float(index) * (ITEM_SLOT_SIZE.x + ITEM_SLOT_GAP), ITEM_SLOTS_Y)
		button.size = ITEM_SLOT_SIZE
		button.custom_minimum_size = ITEM_SLOT_SIZE
		button.focus_mode = Control.FOCUS_ALL
		button.add_theme_stylebox_override("focus", UIStyle.focus_ring())
		var number: Label = _text(str(index + 1), 22, UIStyle.PARCHMENT, Vector2(10, 4), 30)
		number.name = "Number"
		button.add_child(number)
		var slot_icon: TextureRect = _icon_rect(Vector2((ITEM_SLOT_SIZE.x - 84.0) * 0.5, 22), Vector2(84, 84))
		slot_icon.name = "Icon"
		button.add_child(slot_icon)
		var plus: Label = _text("+", 56, UIStyle.PARCHMENT, Vector2(0, 26), ITEM_SLOT_SIZE.x, HORIZONTAL_ALIGNMENT_CENTER)
		plus.name = "Plus"
		button.add_child(plus)
		var badge: Label = ItemBar.charge_badge(18)
		badge.position = ITEM_SLOT_SIZE - ItemBar.BADGE_SIZE - Vector2(8, 8)
		button.add_child(badge)
		var caption: Label = _text("", 20, UIStyle.PARCHMENT, Vector2(-11, ITEM_SLOT_SIZE.y + 6), ITEM_SLOT_SIZE.x + 22, HORIZONTAL_ALIGNMENT_CENTER)
		caption.name = "Caption"
		caption.clip_text = true
		button.add_child(caption)
		var slot_index: int = index
		button.pressed.connect(func() -> void: _on_item_slot_pressed(slot_index))
		button.mouse_entered.connect(func() -> void: Audio.sfx(&"ui_hover", -10.0))
		panel.add_child(button)
		_item_slot_buttons.append(button)
	var note: Label = _text(SLOTS_NOTE, 20, UIStyle.MUTED, Vector2(28, 346), ITEMS_RECT.size.x - 56, HORIZONTAL_ALIGNMENT_CENTER)
	note.name = "SlotsNote"
	note.add_theme_font_override("font", UIStyle.font_italic())
	panel.add_child(note)
	_divider(panel, 400.0, ITEMS_RECT.size.x)
	panel.add_child(_heading("INVENTORY", Vector2(28, 414), 26))
	_item_types_label = _text("", 22, UIStyle.PARCHMENT, Vector2(ITEMS_RECT.size.x - 328, 416), 300, HORIZONTAL_ALIGNMENT_RIGHT)
	_item_types_label.name = "ItemTypes"
	panel.add_child(_item_types_label)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "InventoryScroll"
	var grid_width: float = CELL_SIZE.x * float(GRID_COLUMNS) + float(CELL_GAP * (GRID_COLUMNS - 1))
	scroll.position = Vector2((ITEMS_RECT.size.x - grid_width) * 0.5 - 6.0, 454)
	scroll.size = Vector2(grid_width + 22.0, CELL_SIZE.y * 2.0 + float(CELL_GAP) + 4.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	_grid = GridContainer.new()
	_grid.name = "InventoryGrid"
	_grid.columns = GRID_COLUMNS
	_grid.add_theme_constant_override("h_separation", CELL_GAP)
	_grid.add_theme_constant_override("v_separation", CELL_GAP)
	scroll.add_child(_grid)
	_divider(panel, 712.0, ITEMS_RECT.size.x)
	var detail_frame: Panel = Panel.new()
	detail_frame.position = Vector2(28, 728)
	detail_frame.size = Vector2(108, 108)
	detail_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_frame.add_theme_stylebox_override("panel", UIStyle.box(SLOT_FILL, UIStyle.GOLD_DIM, 2, 10))
	panel.add_child(detail_frame)
	_detail_icon = _icon_rect(Vector2(10, 10), Vector2(88, 88))
	detail_frame.add_child(_detail_icon)
	_detail_name = _text("", 30, UIStyle.GOLD, Vector2(156, 722), 380)
	_detail_name.name = "DetailName"
	_detail_name.add_theme_font_override("font", UIStyle.font_title())
	panel.add_child(_detail_name)
	_detail_meta = _text("", 21, UIStyle.PARCHMENT, Vector2(158, 762), 380)
	_detail_meta.name = "DetailMeta"
	panel.add_child(_detail_meta)
	_detail_effect = _text("", 18, UIStyle.MUTED, Vector2(158, 789), 390)
	_detail_effect.name = "DetailEffect"
	_detail_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_effect.size.y = 50
	_detail_effect.clip_text = true
	panel.add_child(_detail_effect)
	_detail_status = _text("", 21, UIStyle.GOOD, Vector2(158, 838), 380)
	_detail_status.name = "DetailStatus"
	panel.add_child(_detail_status)
	_detail_button = FancyButton.make("Equip", &"", Vector2(190, 60))
	_detail_button.name = "DetailButton"
	_detail_button.position = Vector2(ITEMS_RECT.size.x - 218, 736)
	_detail_button.size = Vector2(190, 60)
	_detail_button.pressed.connect(_on_detail_button)
	panel.add_child(_detail_button)
	_use_button = FancyButton.make("Use", &"GhostButton", Vector2(190, 46))
	_use_button.name = "UseButton"
	_use_button.position = Vector2(ITEMS_RECT.size.x - 218, 806)
	_use_button.size = Vector2(190, 46)
	_use_button.pressed.connect(_on_use_button)
	panel.add_child(_use_button)
	_divider(panel, 866.0, ITEMS_RECT.size.x)
	var footer: Label = _text(FOOTER, 20, UIStyle.MUTED, Vector2(28, 878), ITEMS_RECT.size.x - 56, HORIZONTAL_ALIGNMENT_CENTER)
	footer.name = "Footer"
	footer.add_theme_font_override("font", UIStyle.font_italic())
	panel.add_child(footer)


# ---- Refresh ----------------------------------------------------------------------------------------------------------------------


func _refresh() -> void:
	if Session.profile == null:
		return
	_refresh_equipment()
	_refresh_level()
	_refresh_packs()
	_refresh_items()
	if _equipment_page != null:
		_refresh_equipment_page()
	_apply_tutorial_highlight()


## Overnight Nov 3-4, Parts B5 / B6: while a tutorial step is open the page points the way - Tilly's item in the inventory, then an empty slot;
## Bertram's blade: the Weapon slot, then the blade on the Equipment selection page.
func _apply_tutorial_highlight() -> void:
	match Session.tutorial_target():
		"items":
			var gift: ItemData = Session.content.item(Session.TILLY_GIFT_ITEM)
			if _selected_item != null and _selected_item == gift:
				highlight("empty_slot")
			elif gift != null and Session.profile.owns_item(gift):
				highlight("inventory:%s" % gift.id)
			else:
				highlight("items")
		"equipment":
			if _equipment_page != null:
				highlight("equip_grid:%s" % EquipmentRarity.STARTER_BLADE)
			else:
				highlight("equipment:weapon")
		_:
			clear_highlight()


func _refresh_equipment() -> void:
	var profile: PlayerProfile = Session.profile
	var any_open: bool = false
	for slot: EquipmentData.Slot in SLOT_ORDER:
		var button: Button = _equip_buttons[slot] as Button
		var icon: TextureRect = button.get_node("Icon") as TextureRect
		var open: bool = profile.has_equipment_slot(slot)
		any_open = any_open or open
		var equipped: EquipmentData = profile.equipped_in(slot)
		var style: StyleBox = _equip_slot_style("empty" if open else "locked", UIStyle.GOLD_DIM if open else Color(0.35, 0.33, 0.4, 0.7), 2)
		var hover: StyleBox = _equip_slot_style("hover" if open else "locked", UIStyle.GOLD if open else Color(0.35, 0.33, 0.4, 0.7), 3)
		for state: String in ["normal", "pressed", "disabled"]:
			button.add_theme_stylebox_override(state, style)
		button.add_theme_stylebox_override("hover", hover)
		icon.modulate = Color.WHITE
		if not open:
			icon.texture = IconArt.texture("ICON-PADLOCK", SLOT_SIZE) if IconArt.has("ICON-PADLOCK") else CardIcons.ui("lock")
			button.tooltip_text = "Locked - %s." % equipment_unlock_text()
		elif equipped != null:
			icon.texture = IconArt.equipment_texture(equipped, SLOT_SIZE)
			button.tooltip_text = equipped.tooltip_text()
		else:
			icon.texture = IconArt.texture(IconArt.slot_id(slot), SLOT_SIZE)
			icon.modulate = Color(1, 1, 1, 0.8)
			button.tooltip_text = "Empty %s slot - click to choose." % EquipmentData.slot_name(slot)
	_unlock_pill.visible = not any_open


func _equip_slot_style(state: String, border: Color, width: int) -> StyleBox:
	if UiArt.has("UI-SLOT-EQUIP"):
		return UiSkin.equip_slot_style(state, SLOT_SIZE)
	return UIStyle.box(LOCKED_FILL if state == "locked" else SLOT_FILL, border, width, 12)


func _refresh_level() -> void:
	var profile: PlayerProfile = Session.profile
	_level_title.text = "Level %d" % profile.level
	if profile.level >= ProgressionTable.MAX_LEVEL:
		_xp_label.text = "Max level"
		_xp_bar.max_value = 1.0
		_xp_bar.value = 1.0
	else:
		var floor_xp: int = ProgressionTable.xp_to_reach(profile.level)
		var ceil_xp: int = ProgressionTable.xp_to_reach(profile.level + 1)
		# XP Pass Oct 30: an old save can sit above the level its XP gives on the re-based curve; its bar starts empty, never negative.
		var into_level: int = clampi(profile.xp - floor_xp, 0, ceil_xp - floor_xp)
		_xp_label.text = "%d / %d XP" % [into_level, ceil_xp - floor_xp]
		_xp_bar.max_value = maxf(1.0, float(ceil_xp - floor_xp))
		_xp_bar.value = float(into_level)
	var run: DungeonRun = Session.hp_run()
	var max_hp: int = run.max_hp() if run != null else profile.base_max_hp()
	var hp: int = run.hp if run != null else max_hp
	(_stat_values["hp"] as Label).text = "%d / %d" % [hp, max_hp]
	(_stat_values["opening"] as Label).text = str(profile.base_opening_hand())
	(_stat_values["max_hand"] as Label).text = str(profile.base_max_hand_size())
	(_stat_values["gold"] as Label).text = str(Session.gold)
	for path: Variant in _essence_values.keys():
		(_essence_values[path] as Label).text = str(profile.essence_of(int(path) as Affinity.Type))


func _refresh_packs() -> void:
	for child: Node in _packs_list.get_children():
		child.queue_free()
	var shown: int = 0
	for pack: PackData in PackCatalog.all():
		var count: int = Session.profile.pack_count(pack.id)
		if count <= 0:
			continue
		shown += 1
		var row: HBoxContainer = UIKit.hbox(8)
		row.add_child(PackArt.icon(pack, 0.17))
		var name_label: Label = UIKit.label("%s  x%d" % [pack.display_name, count], &"", 21, UIStyle.PARCHMENT)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(name_label)
		var open_button: FancyButton = FancyButton.make("Open", &"GhostButton", Vector2(100, 44))
		open_button.name = "Open_%s" % pack.id
		var pack_id: String = pack.id
		open_button.pressed.connect(func() -> void: _open_pack(pack_id))
		row.add_child(open_button)
		_packs_list.add_child(row)
	if shown == 0:
		_packs_list.add_child(UIKit.spacer(80))
		var empty: Label = UIKit.label(PACKS_EMPTY, &"", 30, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		empty.name = "PacksEmpty"
		_packs_list.add_child(empty)
		var hint: Label = UIKit.label(PACKS_HINT, &"", 22, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		hint.name = "PacksHint"
		hint.add_theme_font_override("font", UIStyle.font_italic())
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_packs_list.add_child(hint)


func _refresh_items() -> void:
	var profile: PlayerProfile = Session.profile
	if _selected_item != null and not profile.owns_item(_selected_item):
		_selected_item = null
	_unlocked_label.text = "%d / %d unlocked" % [profile.equipped_count(), profile.item_slots]
	for index: int in MAX_ITEM_SLOTS:
		_refresh_item_slot(index)
	_item_types_label.text = "%d item type%s" % [profile.owned_items.size(), "" if profile.owned_items.size() == 1 else "s"]
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	for item: ItemData in profile.owned_items:
		_grid.add_child(_inventory_cell(item))
	var filler: int = maxi(0, GRID_COLUMNS * 2 - profile.owned_items.size())
	if profile.owned_items.size() > GRID_COLUMNS * 2 and profile.owned_items.size() % GRID_COLUMNS != 0:
		filler = GRID_COLUMNS - profile.owned_items.size() % GRID_COLUMNS
	for i: int in filler:
		var empty: Panel = Panel.new()
		empty.custom_minimum_size = CELL_SIZE
		empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		empty.add_theme_stylebox_override("panel", UIStyle.box(Color(0.09, 0.07, 0.14, 0.7), Color(0.55, 0.45, 0.65, 0.35), 2, 10))
		_grid.add_child(empty)
	_refresh_detail()
	_apply_tutorial_highlight()


## The level that opens item slot `index` (0-based): 1 for the two starting slots.
static func item_slot_unlock_level(index: int) -> int:
	for level: int in range(1, ProgressionTable.MAX_LEVEL + 1):
		if ProgressionTable.row(level).item_slots > index:
			return level
	return ProgressionTable.MAX_LEVEL


func _refresh_item_slot(index: int) -> void:
	var profile: PlayerProfile = Session.profile
	var button: Button = _item_slot_buttons[index]
	var icon: TextureRect = button.get_node("Icon") as TextureRect
	var plus: Label = button.get_node("Plus") as Label
	var badge: Label = button.get_node("ChargeBadge") as Label
	var caption: Label = button.get_node("Caption") as Label
	var locked: bool = index >= profile.item_slots
	var item: ItemData = null if locked else Session.content.item(profile.item_in_slot(index))
	var selected: bool = item != null and item == _selected_item
	plus.visible = false
	badge.visible = false
	icon.visible = true
	icon.modulate = Color.WHITE
	var border: Color = ACCENT if selected else (UIStyle.GOLD if item != null else UIStyle.GOLD_DIM)
	var fill: Color = LOCKED_FILL if locked else SLOT_FILL
	var normal: StyleBoxFlat = UIStyle.box(fill, border if not locked else Color(0.42, 0.38, 0.5, 0.7), 4 if selected else 2, 12)
	var hover: StyleBoxFlat = UIStyle.box(fill.lightened(0.06), UIStyle.GOLD if not locked else Color(0.5, 0.46, 0.58, 0.8), 3, 12)
	for state: String in ["normal", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, normal)
	button.add_theme_stylebox_override("hover", hover)
	if locked:
		icon.texture = IconArt.texture("ICON-PADLOCK", 64.0) if IconArt.has("ICON-PADLOCK") else CardIcons.ui("lock")
		icon.modulate = Color(1, 1, 1, 0.75)
		caption.text = "Level %d unlock" % item_slot_unlock_level(index)
		caption.add_theme_color_override("font_color", UIStyle.MUTED)
		button.tooltip_text = "Slot %d opens at level %d." % [index + 1, item_slot_unlock_level(index)]
	elif item == null:
		icon.visible = false
		plus.visible = true
		caption.text = "Empty slot"
		caption.add_theme_color_override("font_color", UIStyle.PARCHMENT)
		button.tooltip_text = "Empty slot - select an item, then click here."
	else:
		icon.texture = IconArt.item_texture(item, 84.0)
		badge.visible = true
		badge.text = "x%d" % profile.item_uses_left(item)
		caption.text = item.display_name
		caption.add_theme_color_override("font_color", UIStyle.PARCHMENT)
		button.tooltip_text = item.tooltip_text()


func _inventory_cell(item: ItemData) -> Button:
	var profile: PlayerProfile = Session.profile
	var cell: Button = Button.new()
	cell.name = "Inventory_%s" % item.id
	cell.custom_minimum_size = CELL_SIZE
	cell.focus_mode = Control.FOCUS_ALL
	var selected: bool = item == _selected_item
	var normal: StyleBoxFlat = UIStyle.box(SLOT_FILL, ACCENT if selected else UIStyle.GOLD_DIM, 4 if selected else 2, 10)
	for state: String in ["normal", "pressed"]:
		cell.add_theme_stylebox_override(state, normal)
	cell.add_theme_stylebox_override("hover", UIStyle.box(SLOT_FILL.lightened(0.06), UIStyle.GOLD, 3, 10))
	cell.add_theme_stylebox_override("focus", UIStyle.focus_ring())
	var icon: TextureRect = _icon_rect(Vector2((CELL_SIZE.x - 76.0) * 0.5, 14), Vector2(76, 76))
	icon.texture = IconArt.item_texture(item, 76.0)
	cell.add_child(icon)
	var badge: Label = ItemBar.charge_badge(17)
	badge.text = "x%d" % profile.item_uses_left(item)
	badge.position = CELL_SIZE - ItemBar.BADGE_SIZE - Vector2(6, 6)
	cell.add_child(badge)
	if profile.is_item_equipped(item):
		var tick: Label = _text("✓", 24, Color("2b1a00"), Vector2(4, 2), 30, HORIZONTAL_ALIGNMENT_CENTER)
		tick.name = "EquippedTick"
		tick.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 8))
		tick.size = Vector2(28, 28)
		cell.add_child(tick)
	cell.tooltip_text = item.tooltip_text()
	cell.pressed.connect(func() -> void: _select_item(item))
	return cell


func _refresh_detail() -> void:
	var profile: PlayerProfile = Session.profile
	var item: ItemData = _selected_item
	_use_button.visible = false
	if item == null:
		_detail_icon.texture = null
		_detail_name.text = ""
		_detail_meta.text = "Select an item to see what it does." if not profile.owned_items.is_empty() else "No items yet - Tilly Tonic's Supplies sells some."
		_detail_effect.text = ""
		_detail_status.text = ""
		_detail_button.visible = false
		return
	_detail_icon.texture = IconArt.item_texture(item, 88.0)
	_detail_name.text = item.display_name
	var charges: int = profile.item_uses_left(item)
	_detail_meta.text = "Single-use  •  %d charge%s owned" % [charges, "" if charges == 1 else "s"]
	_detail_effect.text = item.description
	var slot: int = profile.slot_of_item(item)
	_detail_status.text = "Equipped in slot %d" % (slot + 1) if slot >= 0 else "Not equipped"
	_detail_status.add_theme_color_override("font_color", UIStyle.GOOD if slot >= 0 else UIStyle.MUTED)
	_detail_button.visible = true
	_detail_button.text = "Unequip" if slot >= 0 else "Equip"
	_detail_button.disabled = slot < 0 and profile.first_empty_item_slot() < 0
	_detail_button.tooltip_text = "All %d unlocked slots are full - unequip one first." % profile.item_slots if _detail_button.disabled else ""
	# Between fights a healing item can be drunk on the spot (a dungeon run's HP); the brief's page keeps that.
	_use_button.visible = Session.hp_run() != null and ItemUseResolver.can_apply(item)


# ---- Item interaction -----------------------------------------------------------------------------------------------------------


func _select_item(item: ItemData) -> void:
	Audio.sfx(&"ui_select", -6.0)
	_selected_item = item
	_refresh_items()


func _on_item_slot_pressed(index: int) -> void:
	var profile: PlayerProfile = Session.profile
	if index >= profile.item_slots:
		Audio.sfx(&"ui_error", -6.0)
		_say("Slot %d opens at level %d." % [index + 1, item_slot_unlock_level(index)], Color("ff8a85"))
		return
	var in_slot: ItemData = Session.content.item(profile.item_in_slot(index))
	if in_slot != null:
		_select_item(in_slot)
		return
	if _selected_item == null:
		_say("Select an item in your inventory first.", UIStyle.PARCHMENT)
		return
	equip_selected_into(index)


## Equips the selected item into slot `index` (0-based); an item already in another slot moves. True when it went in.
func equip_selected_into(index: int) -> bool:
	var profile: PlayerProfile = Session.profile
	var item: ItemData = _selected_item
	if item == null:
		return false
	if profile.is_item_equipped(item):
		profile.unequip_item_id(item)
	if not profile.equip_item_id(item, index):
		_say("That slot is not free.", Color("ff8a85"))
		_refresh()
		return false
	Audio.sfx(&"tool_equip")
	Session.save_game()
	item_equipped.emit(item)
	Session.note_item_equipped(item)
	_refresh()
	return true


func _on_detail_button() -> void:
	var profile: PlayerProfile = Session.profile
	var item: ItemData = _selected_item
	if item == null:
		return
	if profile.is_item_equipped(item):
		profile.unequip_item_id(item)
		Audio.sfx(&"tool_unequip")
		Session.save_game()
		_refresh()
		return
	var free: int = profile.first_empty_item_slot()
	if free < 0:
		_say("All %d item slots are full." % profile.item_slots, Color("ff8a85"))
		return
	equip_selected_into(free)


func _on_use_button() -> void:
	var item: ItemData = _selected_item
	if item == null:
		return
	if Session.use_item(item):
		if ItemUseResolver.last_backfired:
			Audio.sfx(&"hit_light")
			_say("The %s backfires! You take %d damage instead." % [item.display_name, item.backfire_damage], Color("ff8a85"))
		else:
			Audio.sfx(&"heal")
			_say("Used %s." % item.display_name, UIStyle.GOOD)
		_refresh()
	else:
		_say("Cannot use that right now.", Color("ff8a85"))


func _open_pack(pack_id: String) -> void:
	Audio.sfx(&"ui_confirm")
	PackOpeningScreen.open_from_inventory(self, pack_id, func() -> void: _refresh())


# ---- Equipment selection page (spec 6) -------------------------------------------------------------------------------------------


func _on_equipment_slot_pressed(slot: EquipmentData.Slot) -> void:
	if not Session.profile.has_equipment_slot(slot):
		Audio.sfx(&"ui_error", -6.0)
		_say(equipment_unlock_text() + ".", Color("ff8a85"))
		return
	Audio.sfx(&"ui_select")
	open_equipment_page(slot)


func open_equipment_page(slot: EquipmentData.Slot) -> void:
	close_equipment_page()
	_equipment_slot = slot
	_selected_piece = Session.profile.equipped_in(slot)
	if _selected_piece == null and not pieces_for(slot).is_empty():
		_selected_piece = pieces_for(slot)[0]  # something to read at once
	_set_columns_visible(false)
	_equipment_page = _make_panel("EquipmentPage", EQUIP_PAGE_RECT, true)
	(_equipment_page.get_theme_stylebox(&"panel") as StyleBoxFlat).bg_color.a = 0.97
	_refresh_equipment_page()
	_apply_tutorial_highlight()
	UIKit.pop_in(_equipment_page)


func close_equipment_page() -> void:
	if _equipment_page != null:
		clear_highlight()
		_equipment_page.queue_free()
		_equipment_page = null
		_set_columns_visible(true)
		_apply_tutorial_highlight()


## The LEVEL, CARD PACKS and ITEMS panels step aside while the Equipment selection page covers them.
func _set_columns_visible(shown: bool) -> void:
	for panel_name: String in ["LevelPanel", "PacksPanel", "ItemsPanel"]:
		var panel: Control = _page.get_node_or_null(NodePath(panel_name)) as Control
		if panel != null:
			panel.visible = shown


func equipment_page_open() -> bool:
	return _equipment_page != null


## The pieces the player owns for `slot`, equipped first.
static func pieces_for(slot: EquipmentData.Slot) -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	var worn: EquipmentData = Session.profile.equipped_in(slot)
	if worn != null:
		result.append(worn)
	for piece: EquipmentData in Session.profile.owned_equipment:
		if piece.slot == slot and piece != worn:
			result.append(piece)
	return result


func _refresh_equipment_page() -> void:
	var page: Control = _equipment_page
	for child: Node in page.get_children():
		page.remove_child(child)
		child.queue_free()
	var slot: EquipmentData.Slot = _equipment_slot
	var width: float = EQUIP_PAGE_RECT.size.x
	var slot_icon: TextureRect = IconArt.rect(IconArt.slot_id(slot), 48.0)
	if slot_icon != null:
		slot_icon.position = Vector2(28, 22)
		slot_icon.size = Vector2(48, 48)
		page.add_child(slot_icon)
	page.add_child(_heading(EquipmentData.slot_name(slot).to_upper(), Vector2(90, 14), 44))
	page.add_child(_text("Choose what you wear in this slot. Gear works in every fight.", 22, UIStyle.PARCHMENT, Vector2(92, 70), 760))
	var back: FancyButton = FancyButton.make("Back", &"", Vector2(170, 56))
	back.name = "BackButton"
	back.position = Vector2(width - 198, 24)
	back.size = Vector2(170, 56)
	back.pressed.connect(func() -> void:
		Audio.sfx(&"ui_back", -4.0)
		close_equipment_page())
	page.add_child(back)
	_divider(page, 110.0, width)
	var pieces: Array[EquipmentData] = pieces_for(slot)
	page.add_child(_heading("OWNED", Vector2(28, 124), 26))
	page.add_child(_text("%d piece%s" % [pieces.size(), "" if pieces.size() == 1 else "s"], 22, UIStyle.PARCHMENT, Vector2(width - 328, 126), 300, HORIZONTAL_ALIGNMENT_RIGHT))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.position = Vector2(28, 166)
	scroll.size = Vector2(width - 56, 500)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)
	var grid: GridContainer = GridContainer.new()
	grid.name = "EquipmentGrid"
	grid.columns = 7
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(grid)
	var worn: EquipmentData = Session.profile.equipped_in(slot)
	for piece: EquipmentData in pieces:
		grid.add_child(_equipment_cell(piece, piece == worn))
	if pieces.is_empty():
		var none: Label = _text("You own nothing for this slot yet. Bertram's smithy and dungeon chests have gear.", 24, UIStyle.MUTED, Vector2(0, 160), width - 56, HORIZONTAL_ALIGNMENT_CENTER)
		none.name = "EquipmentEmpty"
		none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		scroll.add_child(none)
	_divider(page, 690.0, width)
	_equipment_detail(page, worn)


func _equipment_cell(piece: EquipmentData, worn: bool) -> Button:
	var cell: Button = Button.new()
	cell.name = "Gear_%s" % piece.id
	cell.custom_minimum_size = Vector2(140, 140)
	cell.focus_mode = Control.FOCUS_ALL
	var rarity_colour: Color = CardView.RARITY_COLORS[clampi(int(piece.rarity), 0, 3)]
	var selected: bool = piece == _selected_piece
	var normal: StyleBoxFlat = UIStyle.box(SLOT_FILL, ACCENT if selected else rarity_colour.darkened(0.2), 4 if selected else 2, 10)
	for state: String in ["normal", "pressed"]:
		cell.add_theme_stylebox_override(state, normal)
	cell.add_theme_stylebox_override("hover", UIStyle.box(SLOT_FILL.lightened(0.06), UIStyle.GOLD, 3, 10))
	cell.add_theme_stylebox_override("focus", UIStyle.focus_ring())
	var glyph: TextureRect = IconArt.equipment_glyph(piece, rarity_colour, 92.0)
	glyph.position = Vector2(24, 18)
	glyph.size = Vector2(92, 92)
	glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(glyph)
	if worn:
		var tick: Label = _text("✓", 24, Color("2b1a00"), Vector2(4, 2), 30, HORIZONTAL_ALIGNMENT_CENTER)
		tick.name = "EquippedTick"
		tick.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 8))
		tick.size = Vector2(28, 28)
		cell.add_child(tick)
	cell.tooltip_text = piece.tooltip_text()
	cell.pressed.connect(func() -> void:
		Audio.sfx(&"ui_select", -6.0)
		_selected_piece = piece
		_refresh_equipment_page())
	return cell


func _equipment_detail(page: Control, worn: EquipmentData) -> void:
	var piece: EquipmentData = _selected_piece
	var width: float = EQUIP_PAGE_RECT.size.x
	if piece == null:
		page.add_child(_text("Select a piece to see what it does.", 22, UIStyle.MUTED, Vector2(28, 720), 700))
		return
	var frame: Panel = Panel.new()
	frame.position = Vector2(28, 708)
	frame.size = Vector2(130, 130)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", UIStyle.box(SLOT_FILL, UIStyle.GOLD_DIM, 2, 10))
	page.add_child(frame)
	var rarity_colour: Color = CardView.RARITY_COLORS[clampi(int(piece.rarity), 0, 3)]
	var glyph: TextureRect = IconArt.equipment_glyph(piece, rarity_colour, 110.0)
	glyph.position = Vector2(10, 10)
	glyph.size = Vector2(110, 110)
	frame.add_child(glyph)
	var name_label: Label = _text(piece.source_name, 32, rarity_colour.lerp(UIStyle.PARCHMENT, 0.3), Vector2(180, 700), 640)
	name_label.name = "GearName"
	name_label.add_theme_font_override("font", UIStyle.font_title())
	page.add_child(name_label)
	page.add_child(_text("%s  •  Tier %d" % [EquipmentRarity.display_name(int(piece.rarity)), piece.tier], 21, UIStyle.PARCHMENT, Vector2(182, 744), 640))
	var effect: Label = _text(piece.description, 21, UIStyle.PARCHMENT, Vector2(182, 774), 720)
	effect.name = "GearEffect"
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(effect)
	var blocked: String = "" if piece == worn else Session.why_not_equip(piece)
	var status: Label = _text("Equipped" if piece == worn else (blocked if not blocked.is_empty() else "Not equipped"), 21, UIStyle.GOOD if piece == worn else (Color("ff8a85") if not blocked.is_empty() else UIStyle.MUTED), Vector2(182, 846), 760)
	status.name = "GearStatus"
	page.add_child(status)
	var button: FancyButton = FancyButton.make("Unequip" if piece == worn else "Equip", &"", Vector2(200, 62))
	button.name = "GearButton"
	button.position = Vector2(width - 228, 730)
	button.size = Vector2(200, 62)
	button.disabled = piece != worn and not blocked.is_empty()
	button.pressed.connect(func() -> void:
		if piece == worn:
			Session.unequip_slot(_equipment_slot)
			Audio.sfx(&"ui_tick")
		elif Session.equip_item(piece):
			Audio.sfx(&"ui_confirm")
			equipment_equipped.emit(piece)
		_refresh()
		_apply_tutorial_highlight())
	page.add_child(button)


# ---- Tutorial highlights (Part B5 / B6) ------------------------------------------------------------------------------------------


## Pulses a gold outline on part of the page: "items", "menu", "inventory:<item id>", "empty_slot", "equipment:<slot key>",
## "equip_grid:<piece id>". `clear_highlight()` removes them. Unknown targets do nothing.
func highlight(target: String) -> void:
	clear_highlight()
	for control: Control in _highlight_targets(target):
		var ring: Panel = Panel.new()
		ring.name = "TutorialHighlight"
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style: StyleBoxFlat = UIStyle.box(Color(0, 0, 0, 0), ACCENT, 5, 16)
		style.shadow_color = Color(ACCENT, 0.55)
		style.shadow_size = 16
		ring.add_theme_stylebox_override("panel", style)
		ring.position = Vector2(-8, -8)
		ring.size = control.size + Vector2(16, 16)
		ring.z_index = 5
		control.add_child(ring)
		_highlights.append(ring)


func clear_highlight() -> void:
	for ring: Control in _highlights:
		if is_instance_valid(ring):
			if ring.get_parent() != null:
				ring.get_parent().remove_child(ring)  # out of the tree now: a new ring keeps the name
			ring.queue_free()
	_highlights.clear()


func highlighted() -> int:
	return _highlights.size()


func _highlight_targets(target: String) -> Array[Control]:
	var result: Array[Control] = []
	if target == "items":
		result.append(_items_panel)
	elif target == "empty_slot":
		for index: int in mini(Session.profile.item_slots, MAX_ITEM_SLOTS):
			if Session.profile.item_in_slot(index).is_empty():
				result.append(_item_slot_buttons[index])
	elif target.begins_with("inventory:"):
		var cell: Control = _grid.get_node_or_null(NodePath("Inventory_%s" % target.trim_prefix("inventory:"))) as Control
		if cell != null:
			result.append(cell)
	elif target.begins_with("equipment:"):
		for slot: Variant in SLOT_KEYS.keys():
			if str(SLOT_KEYS[slot]) == target.trim_prefix("equipment:"):
				result.append(_equip_buttons[slot] as Control)
	elif target.begins_with("equip_grid:") and _equipment_page != null:
		var gear: Control = _equipment_page.find_child("Gear_%s" % target.trim_prefix("equip_grid:"), true, false) as Control
		if gear != null:
			result.append(gear)
	return result


func _process(delta: float) -> void:
	if _highlights.is_empty():
		return
	_highlight_time += delta
	var glow: float = 0.55 + 0.45 * sin(_highlight_time * 4.0)
	for ring: Control in _highlights:
		if is_instance_valid(ring):
			ring.modulate.a = glow


# ---- Input --------------------------------------------------------------------------------------------------------------------


## Esc on the Equipment selection page goes back to the page, not out of the whole screen.
func _unhandled_input(event: InputEvent) -> void:
	if _equipment_page != null and event.is_action_pressed(&"ui_cancel") and is_visible_in_tree():
		get_viewport().set_input_as_handled()
		Audio.sfx(&"ui_back", -4.0)
		close_equipment_page()
		return
	super._unhandled_input(event)


# ---- Small builders -----------------------------------------------------------------------------------------------------------


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


func _say(text: String, color: Color) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", color)
	_toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.4)
