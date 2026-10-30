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
var _slot_rows: Dictionary = {}


func _init() -> void:
	screen_title = "Assistant to the Regional Merchant"
	vendor_screen_id = "VS-BEETSWORTH"
	close_text = "Leave (Esc)"


func _build() -> void:
	if stock == null:
		stock = EquipmentVendorScreen.default_stock()
	var coin: TextureRect = IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 38.0)
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
	var slot_box: VBoxContainer = UIKit.vbox(14)
	slot_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if stage != null:
		# The sheet: equipment grouped by slot (helm, weapon, armor, boots, relic), a row each.
		scroll.add_child(slot_box)
		_grid.free()
		for slot: int in EquipmentData.SLOT_NAMES.keys():
			var row: HBoxContainer = UIKit.hbox(16)
			var heading: Label = UIKit.label(EquipmentData.slot_name(slot as EquipmentData.Slot), &"HeadingLabel", 26, UIStyle.GOLD)
			heading.custom_minimum_size = Vector2(110, 0)
			heading.name = "SlotHeading%d" % slot
			row.add_child(heading)
			slot_box.add_child(row)
			_slot_rows[slot] = row
	else:
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
		var tile: Control = _make_tile(piece, Session.effective_price(entry.price), bool(_locked[piece.id]), stock.teaser_for(piece.id))
		if stage != null:
			(_slot_rows[int(piece.slot)] as HBoxContainer).add_child(tile)
		else:
			_grid.add_child(tile)
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
	# Overnight Oct 29, Phase 2: the slot and the rarity (in the rarity colour) on one line, the effect readable on the tile, and a verdict against what is worn.
	var rarity: int = clampi(int(piece.rarity), 0, 3)
	var slot_label: Label = UIKit.label("???" if locked else "%s  %s" % [EquipmentRarity.display_name(rarity), EquipmentData.slot_name(piece.slot)], &"MutedLabel", 15, UIStyle.MUTED if locked else CardView.RARITY_COLORS[rarity].lerp(UIStyle.PARCHMENT, 0.2), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(slot_label)
	if not locked:
		holder.add_theme_stylebox_override("panel", UIStyle.box(Color(0.08, 0.07, 0.1, 0.9), Color(CardView.RARITY_COLORS[rarity], 0.7), 2, 10))
	var icon_row: CenterContainer = CenterContainer.new()
	column.add_child(icon_row)
	var icon: TextureRect = IconArt.equipment_glyph(piece, Color(0.4, 0.4, 0.46) if locked else UIStyle.PARCHMENT, 64.0)
	if locked and IconArt.has("ICON-PADLOCK"):
		icon = IconArt.rect("ICON-PADLOCK", 64.0)
	icon_row.add_child(icon)
	var title: Label = UIKit.label("???" if locked else piece.source_name, &"", 20, UIStyle.PARCHMENT if not locked else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	title.custom_minimum_size = Vector2(TILE_SIZE.x - 20, 0)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	column.add_child(title)
	var desc: Label = UIKit.label("A mysterious piece of gear." if locked else _effect_text(piece), &"MutedLabel", 14, UIStyle.MUTED if locked else UIStyle.PARCHMENT.darkened(0.15), HORIZONTAL_ALIGNMENT_CENTER)
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
	if not locked:
		var equipped: EquipmentData = Session.profile.equipped_in(piece.slot) if Session.profile != null else null
		var word: String = EquipmentCompare.verdict(piece, equipped)
		var verdict: Label = UIKit.label(word if equipped == null or word == EquipmentCompare.VERDICT_EQUIPPED else "%s vs %s" % [word, equipped.source_name], &"MutedLabel", 14, _verdict_color(word), HORIZONTAL_ALIGNMENT_CENTER)
		verdict.custom_minimum_size = Vector2(TILE_SIZE.x - 20, 0)
		verdict.autowrap_mode = TextServer.AUTOWRAP_WORD
		column.add_child(verdict)
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


## The effect without the flavour sentence a vendor piece carries in front of it ("A blade with a reputation... Your units get +1 attack.").
func _effect_text(piece: EquipmentData) -> String:
	var text: String = piece.description
	var cut: int = text.find(". ")
	if piece.tier == 0 and cut > 0 and cut < text.length() - 2:
		text = text.substr(cut + 2)
	return text


static func _verdict_color(word: String) -> Color:
	match word:
		EquipmentCompare.VERDICT_UPGRADE:
			return UIStyle.GOOD
		EquipmentCompare.VERDICT_DOWNGRADE:
			return Color("e06a5a")
		EquipmentCompare.VERDICT_SIDEGRADE:
			return Color("e8c15a")
		EquipmentCompare.VERDICT_EQUIPPED:
			return UIStyle.GOLD
	return UIStyle.MUTED


## New brief, Part C: "a compare-to-equipped tooltip" - the piece's own tooltip plus whatever is
## currently equipped in that same slot, so buying doesn't mean digging into the character screen
## first to remember what you'd be replacing.
func _compare_tooltip(piece: EquipmentData) -> String:
	var profile: PlayerProfile = Session.profile
	var equipped: EquipmentData = profile.equipped_in(piece.slot) if profile != null else null
	return EquipmentCompare.tooltip(piece, equipped)  # Oct 16: the numbers that change, and what you would lose


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for id: Variant in _pieces.keys():
		var piece: EquipmentData = _pieces[id] as EquipmentData
		var price_label: Label = _price_labels[id] as Label
		if bool(_locked.get(id, false)):
			IconArt.set_price_text(price_label, "???")
			price_label.add_theme_color_override("font_color", UIStyle.MUTED)
			continue
		var price: int = Session.effective_price(stock.price_for(piece.id))
		IconArt.set_price(price_label, price)
		var owned: bool = Session.profile.owned_equipment.has(piece)
		price_label.add_theme_color_override("font_color", UIStyle.MUTED if owned else (UIStyle.GOLD if Session.gold >= price else Color("e06a5a")))
		(_owned_labels[id] as Label).text = "Owned" if owned else "Not owned"


func _ask_to_buy(piece: EquipmentData, price: int) -> void:
	if Session.profile.owned_equipment.has(piece):
		return
	if Session.gold < price:
		Audio.sfx(&"ui_error", -4.0)
		_say("Not enough gold: %s costs %d." % [piece.source_name, price], Color("ff8a85"))
		vendor_react("poor")
		return
	var detail: String = "%d gold. You will have %d gold left." % [price, Session.gold - price]
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Buy %s?" % piece.source_name, detail, "Buy", "Not now")
	dialog.confirmed.connect(func() -> void: _buy(piece, price))


func _buy(piece: EquipmentData, price: int) -> void:
	if not Session.buy_equipment(piece, price):
		return
	Audio.sting(&"STG-PURCHASE")
	_say("Bought %s." % piece.source_name, UIStyle.GOOD)
	vendor_react("buy")
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
	# Overnight Oct 29: prices from the curve (Economy.gear_price, docs/design/economy.md): basics tier 1, the advanced rack tier 3.
	var common: EquipmentData.Rarity = EquipmentData.Rarity.COMMON
	var uncommon: EquipmentData.Rarity = EquipmentData.Rarity.UNCOMMON
	var epic: EquipmentData.Rarity = EquipmentData.Rarity.RARE
	data.add("wicked_dagger", Economy.gear_price(uncommon, 1), always)
	data.add("extra_pocket", Economy.gear_price(common, 1), always)
	data.add("travelers_boots", Economy.gear_price(common, 1), always)
	data.add("solid_plate", Economy.gear_price(uncommon, 1), always)
	data.add("xray_goggles", Economy.gear_price(uncommon, 1), always)
	data.add("cardboard_cuirass", Economy.gear_price(common, 1), always)  # Oct 16: two cheap early pieces
	data.add("saucepan_helmet", Economy.gear_price(common, 1), always)
	data.add("flamethrower", Economy.gear_price(epic, 3), advanced)
	data.add("earned_blade", Economy.gear_price(epic, 3), advanced)  # Oct 29: the old Wicked Dagger's +1 attack to every unit, where a board-wide buff belongs
	data.add("cheaters_dice", Economy.gear_price(uncommon, 3), advanced)
	data.add("hover_boots", Economy.gear_price(uncommon, 3), advanced)
	data.add("thorned_loincloth", Economy.gear_price(uncommon, 3), advanced)
	data.add("big_brain_beret", Economy.gear_price(epic, 3), advanced)
	return data
