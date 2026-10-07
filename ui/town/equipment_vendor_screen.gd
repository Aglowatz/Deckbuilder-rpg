class_name EquipmentVendorScreen
extends OverlayScreen
## New brief, Part C: the equipment vendor - stock is data-driven (EquipmentVendorData/Condition,
## mirroring the item vendor's ItemVendorData, D75/Part F). 5 basic pieces are for sale from the
## start; the 5 advanced pieces show as a "???" teaser until unlocked by a level-up reward
## (Part D). Each tile shows its slot and a tooltip that also compares against whatever is
## currently equipped in that slot.

const TILE_SIZE: Vector2 = Vector2(220, 250)
const COLUMNS: int = 5

var stock: EquipmentVendorData
var _grid: GridContainer
var _gold_label: Label
var _toast: Label
var _pieces: Dictionary = {}
var _locked: Dictionary = {}
var _price_labels: Dictionary = {}
var _owned_labels: Dictionary = {}


func _init() -> void:
	screen_title = "Assistant to the Regional Merchant"
	close_text = "Leave (Esc)"


func _build() -> void:
	if stock == null:
		stock = EquipmentVendorScreen.default_stock()
	var coin: TextureRect = CardIcons.glyph(CardIcons.ui("coins"), UIStyle.GOLD, Vector2(38, 38))
	header_extra.add_child(coin)
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 16)
	_grid.add_theme_constant_override("v_separation", 16)
	scroll.add_child(_grid)
	var state: UnlockState = Session.unlock_state()
	var entries: Array[EquipmentVendorEntry] = stock.entries.duplicate()
	entries.sort_custom(func(a: EquipmentVendorEntry, b: EquipmentVendorEntry) -> bool: return a.price < b.price)
	for entry: EquipmentVendorEntry in entries:
		var piece: EquipmentData = Session.content.equipment_piece(entry.equipment_id)
		if piece == null:
			continue
		_pieces[piece.id] = piece
		_locked[piece.id] = not Condition.met(entry.unlock, state)
		_grid.add_child(_make_tile(piece, Session.effective_price(entry.price), bool(_locked[piece.id]), stock.teaser_for(piece.id)))
	_toast = UIKit.label("", &"", 28, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_toast.add_theme_font_override("font", UIStyle.font_bold())
	_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.position = Vector2(460, 1000)
	_toast.size = Vector2(1000, 40)
	_toast.modulate.a = 0.0
	_toast.z_index = 250
	add_child(_toast)
	_refresh()
	TipPanel.show_once(self, &"tip_equipment_vendor", "Buying equipment", "Click a piece to buy it - equipment isn't consumed, so you only ever need to buy one of each. Equip it from the Character screen once you have an unlocked slot for it. The 5 grayed-out pieces are advanced gear, unlocked by a level-up reward.", Vector2(560, 900))


func _make_tile(piece: EquipmentData, price: int, locked: bool, teaser: String) -> Control:
	var holder: PanelContainer = UIKit.panel(&"DarkPanel")
	holder.custom_minimum_size = TILE_SIZE
	holder.set_meta("equipment_id", piece.id)
	holder.tooltip_text = teaser if locked else _compare_tooltip(piece)
	var column: VBoxContainer = UIKit.vbox(6)
	holder.add_child(column)
	var slot_label: Label = UIKit.label("???" if locked else EquipmentData.slot_name(piece.slot), &"MutedLabel", 15, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(slot_label)
	var icon_row: CenterContainer = CenterContainer.new()
	column.add_child(icon_row)
	var icon: TextureRect = CardIcons.glyph(CardIcons.for_equipment(piece), Color(0.4, 0.4, 0.46) if locked else UIStyle.PARCHMENT, Vector2(64, 64))
	icon_row.add_child(icon)
	var title: Label = UIKit.label("???" if locked else piece.source_name, &"", 20, UIStyle.PARCHMENT if not locked else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	title.custom_minimum_size = Vector2(TILE_SIZE.x - 20, 0)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	column.add_child(title)
	var desc: Label = UIKit.label("A mysterious piece of gear." if locked else piece.description, &"MutedLabel", 15, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	desc.custom_minimum_size = Vector2(TILE_SIZE.x - 20, 0)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	column.add_child(desc)
	var price_label: Label = UIKit.label("", &"", 22, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	price_label.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(price_label)
	_price_labels[piece.id] = price_label
	var owned: Label = UIKit.label("", &"", 16, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(owned)
	_owned_labels[piece.id] = owned
	if locked:
		holder.set_meta("teaser", teaser)
	else:
		var button: Button = Button.new()
		button.flat = true
		UIKit.full_rect(button)
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		button.pressed.connect(func() -> void: _ask_to_buy(piece, price))
		holder.add_child(button)
	return holder


## New brief, Part C: "a compare-to-equipped tooltip" - the piece's own tooltip plus whatever is
## currently equipped in that same slot, so buying doesn't mean digging into the character screen
## first to remember what you'd be replacing.
func _compare_tooltip(piece: EquipmentData) -> String:
	var text: String = piece.tooltip_text()
	var profile: PlayerProfile = Session.profile
	var equipped: EquipmentData = profile.equipped_in(piece.slot) if profile != null else null
	if equipped == null:
		text += "\n\nCurrently equipped in this slot: nothing."
	elif equipped == piece:
		text += "\n\nCurrently equipped in this slot: this piece."
	else:
		text += "\n\nCurrently equipped in this slot: %s - %s" % [equipped.source_name, equipped.description]
	return text


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for id: Variant in _pieces.keys():
		var piece: EquipmentData = _pieces[id] as EquipmentData
		var price_label: Label = _price_labels[id] as Label
		if bool(_locked.get(id, false)):
			price_label.text = "???"
			price_label.add_theme_color_override("font_color", UIStyle.MUTED)
			continue
		var price: int = Session.effective_price(stock.price_for(piece.id))
		price_label.text = "%d gold" % price
		var owned: bool = Session.profile.owned_equipment.has(piece)
		price_label.add_theme_color_override("font_color", UIStyle.MUTED if owned else (UIStyle.GOLD if Session.gold >= price else Color("e06a5a")))
		(_owned_labels[id] as Label).text = "Owned" if owned else "Not owned"


func _ask_to_buy(piece: EquipmentData, price: int) -> void:
	if Session.profile.owned_equipment.has(piece):
		return
	if Session.gold < price:
		Audio.sfx(&"ui_error", -4.0)
		_say("Not enough gold: %s costs %d." % [piece.source_name, price], Color("ff8a85"))
		return
	var detail: String = "%d gold. You will have %d gold left." % [price, Session.gold - price]
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Buy %s?" % piece.source_name, detail, "Buy", "Not now")
	dialog.confirmed.connect(func() -> void: _buy(piece, price))


func _buy(piece: EquipmentData, price: int) -> void:
	if not Session.buy_equipment(piece, price):
		return
	Audio.sfx(&"coins")
	_say("Bought %s." % piece.source_name, UIStyle.GOOD)
	_refresh()


func _say(text: String, color: Color = UIStyle.PARCHMENT) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", color)
	_toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


## The one equipment vendor in the game: 5 basic pieces always for sale, the 5 advanced pieces
## locked behind the same level-10 reward Part D's level-up popup announces (docs/design/
## progression.md).
static func default_stock() -> EquipmentVendorData:
	var data: EquipmentVendorData = EquipmentVendorData.new()
	var always: Condition = null
	var advanced: Condition = Condition.player_level(ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL)
	data.add("wicked_dagger", 120, always)
	data.add("extra_pocket", 90, always)
	data.add("travelers_boots", 100, always)
	data.add("solid_plate", 110, always)
	data.add("xray_goggles", 130, always)
	data.add("flamethrower", 320, advanced)
	data.add("cheaters_dice", 260, advanced)
	data.add("hover_boots", 300, advanced)
	data.add("thorned_loincloth", 280, advanced)
	data.add("big_brain_beret", 300, advanced)
	return data
