class_name ItemVendorScreen
extends OverlayScreen
## New brief, Part F: the item vendor - stock is data-driven (ItemVendorData/Condition, the item
## equivalent of the card vendor's VendorData/D37): each item has its own price and unlock
## condition, so the stall starts small and grows with progress. A locked item shows as a "???"
## teaser instead of its real icon/description.

const TILE_SIZE: Vector2 = Vector2(220, 230)
const COLUMNS: int = 5

var stock: ItemVendorData
var _grid: GridContainer
var _gold_label: Label
var _toast: Label
var _items: Dictionary = {}
var _locked: Dictionary = {}
var _price_labels: Dictionary = {}
var _owned_labels: Dictionary = {}


func _init() -> void:
	screen_title = "Tilly Tonic's Supplies"
	close_text = "Leave (Esc)"


func _build() -> void:
	if stock == null:
		stock = ItemVendorScreen.default_stock()
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
	var entries: Array[ItemVendorEntry] = stock.entries.duplicate()
	entries.sort_custom(func(a: ItemVendorEntry, b: ItemVendorEntry) -> bool: return a.price < b.price)
	for entry: ItemVendorEntry in entries:
		var item: ItemData = Session.content.item(entry.item_id)
		if item == null:
			continue
		_items[item.id] = item
		_locked[item.id] = not Condition.met(entry.unlock, state)
		_grid.add_child(_make_tile(item, Session.effective_price(entry.price), bool(_locked[item.id]), stock.teaser_for(item.id)))
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
	TipPanel.show_once(self, &"tip_item_vendor", "Buying items", "Click an item to buy it. Buying one you already own tops up its uses instead of cluttering your bag with a duplicate. Equip up to your item-slot limit from the Character screen to use them in battle.", Vector2(560, 900))


func _make_tile(item: ItemData, price: int, locked: bool, teaser: String) -> Control:
	var holder: PanelContainer = UIKit.panel(&"DarkPanel")
	holder.custom_minimum_size = TILE_SIZE
	holder.set_meta("item_id", item.id)
	# New brief, Part B: same hover tooltip (name, full effect, targeting requirement) as the
	# battle item bar and the character screen - a locked item keeps its spoiler-free teaser.
	holder.tooltip_text = teaser if locked else item.tooltip_text()
	var column: VBoxContainer = UIKit.vbox(6)
	holder.add_child(column)
	var icon_row: CenterContainer = CenterContainer.new()
	column.add_child(icon_row)
	var icon: TextureRect = CardIcons.glyph(CardIcons.for_item(item), Color(0.4, 0.4, 0.46) if locked else UIStyle.PARCHMENT, Vector2(64, 64))
	icon_row.add_child(icon)
	var title: Label = UIKit.label("???" if locked else item.display_name, &"", 20, UIStyle.PARCHMENT if not locked else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	title.custom_minimum_size = Vector2(TILE_SIZE.x - 20, 0)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD
	column.add_child(title)
	var desc: Label = UIKit.label("A mysterious supply." if locked else item.description, &"MutedLabel", 15, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	desc.custom_minimum_size = Vector2(TILE_SIZE.x - 20, 0)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	column.add_child(desc)
	var price_label: Label = UIKit.label("", &"", 22, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	price_label.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(price_label)
	_price_labels[item.id] = price_label
	var owned: Label = UIKit.label("", &"", 16, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(owned)
	_owned_labels[item.id] = owned
	if locked:
		holder.set_meta("teaser", teaser)
	else:
		var button: Button = Button.new()
		button.flat = true
		UIKit.full_rect(button)
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		button.pressed.connect(func() -> void: _ask_to_buy(item, price))
		holder.add_child(button)
	return holder


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for id: Variant in _items.keys():
		var item: ItemData = _items[id] as ItemData
		var price_label: Label = _price_labels[id] as Label
		if bool(_locked.get(id, false)):
			price_label.text = "???"
			price_label.add_theme_color_override("font_color", UIStyle.MUTED)
			continue
		var price: int = Session.effective_price(stock.price_for(item.id))
		price_label.text = "%d gold" % price
		price_label.add_theme_color_override("font_color", UIStyle.GOLD if Session.gold >= price else Color("e06a5a"))
		var owned_count: int = Session.profile.item_uses_left(item) if Session.profile.owns_item(item) else 0
		(_owned_labels[id] as Label).text = ("Owned - %d uses left" % owned_count) if owned_count > 0 else "Not owned"


func _ask_to_buy(item: ItemData, price: int) -> void:
	if Session.gold < price:
		Audio.sfx(&"ui_error", -4.0)
		_say("Not enough gold: %s costs %d." % [item.display_name, price], Color("ff8a85"))
		return
	var owned: bool = Session.profile.owns_item(item)
	var detail: String = "%d gold. You will have %d gold left." % [price, Session.gold - price]
	if owned:
		detail += " You already own this - buying it tops up its uses."
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Buy %s?" % item.display_name, detail, "Buy", "Not now")
	dialog.confirmed.connect(func() -> void: _buy(item, price))


func _buy(item: ItemData, price: int) -> void:
	if not Session.buy_item(item, price):
		return
	Audio.sfx(&"coins")
	_say("Bought %s." % item.display_name, UIStyle.GOOD)
	_refresh()


func _say(text: String, color: Color = UIStyle.PARCHMENT) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", color)
	_toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


## The one item vendor in the game (Tilly Tonic, in town). New brief, Part D: simplified from 3 level
## tiers down to 2 - basic (always for sale: the 3 original items plus 5 of the 10 Part F
## consumables) and advanced (the other 5 of the 10, locked behind the same level-up reward
## ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL announces), mirroring the equipment
## vendor's own basic/advanced shape. Also folds `reckless_tonic` (one of the 3 originals) back
## into "always for sale", where the other 2 originals already were - it had oddly been gated
## behind the old level-6 tier even though it predates the whole tiered system.
static func default_stock() -> ItemVendorData:
	var data: ItemVendorData = ItemVendorData.new()
	var always: Condition = null
	var advanced: Condition = Condition.player_level(ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL)
	data.add("healing_draught", 40, always)
	data.add("vitality_charm", 25, always)
	data.add("reckless_tonic", 30, always)
	data.add("healing_salve", 50, always)
	data.add("field_bandage", 35, always)
	data.add("scroll_of_insight", 45, always)
	data.add("firebrand_charm", 45, always)
	data.add("sharpening_stone", 40, always)
	data.add("binding_chains", 55, advanced)
	data.add("silence_powder", 35, advanced)
	data.add("grave_dust", 30, advanced)
	data.add("summoning_charm", 40, advanced)
	data.add("ward_sigil", 35, advanced)
	return data
