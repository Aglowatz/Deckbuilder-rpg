class_name VendorScreen
extends OverlayScreen
## The card vendor: stock is data-driven (`VendorData`/`Condition` - see docs/design/
## open_questions.md D37): each card has its own unlock condition, so the stall starts small and
## grows with progress. A locked card shows as a "???" teaser instead of its real art.

const CARD_SCALE: float = 0.68
const COLUMNS: int = 8
## With a vendor stage the grid sits on the right, so the cards are a little smaller and there are fewer columns.
const STAGED_COLUMNS: int = 5
const STAGED_SCALE: float = 0.64
## Gristle's cans: how far a card hides in its can and rises on hover.
const CAN_REST: float = 34.0
const TUB_COLORS: Array[Color] = [Color(0.86, 0.36, 0.24), Color(0.25, 0.55, 0.78), Color(0.3, 0.65, 0.35), Color(0.8, 0.62, 0.2), Color(0.6, 0.35, 0.7)]

var stock: VendorData
## When set (`PackData.VENDOR_*`), the header gets a "Card Packs" button opening that vendor's pack stall (`PackShopScreen`).
var pack_vendor_id: String = ""
## Overnight Oct 16: a zone shop's equipment stock (`ExpansionGear.zone_vendor_stock`); when it has pieces the header gets a "Gear" button.
var gear_stock: EquipmentVendorData
var pack_story_prefix: String = ""
var _filter: CardFilterBar
var _grid: GridContainer
var _gold_label: Label
var _preview: HoverPreview
var _toast: Label
var _tiles: Array[Control] = []
var _cards: Dictionary = {}
var _locked: Dictionary = {}
var _price_labels: Dictionary = {}
var _owned_labels: Dictionary = {}
var _card_scale: float = CARD_SCALE
## Overnight Oct 17, Part 2: a vendor with more than one category (cards, packs, gear) opens on a category selection
## screen (`_picker`); the card grid lives in `_cards_view`, and every category view has a Back button to the picker.
var categories: Array[VendorCategories.Kind] = []
var _picker: Control
var _cards_view: VBoxContainer
var _picker_buttons: Array[FancyButton] = []
var _showing_cards: bool = false


func _init() -> void:
	screen_title = "Sable's Card Stall"
	close_text = "Leave (Esc)"


func _build() -> void:
	if stock == null:
		stock = VendorData.graduated(Session.content, Session.deck.colors(), Condition.dungeon_cleared(TrialOfTheHollow.DUNGEON_NAME))
	# Gear is only sold once the armory quest opened the equipment slots (Part 5).
	categories = VendorCategories.list(not stock.entries.is_empty(), not pack_vendor_id.is_empty(), gear_stock != null and not gear_stock.entries.is_empty() and Session.gear_unlocked())
	if stage != null:
		_card_scale = STAGED_SCALE
	var coin: TextureRect = IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 38.0)
	header_extra.add_child(coin)
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	_preview = HoverPreview.new()
	add_child(_preview)
	_cards_view = UIKit.vbox(12)
	_cards_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(_cards_view)
	_filter = CardFilterBar.new()
	_filter.changed.connect(_apply_filter)
	_cards_view.add_child(_filter)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_cards_view.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = STAGED_COLUMNS if stage != null else COLUMNS
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(_grid)
	var state: UnlockState = Session.unlock_state()
	var entries: Array[VendorStockEntry] = stock.entries.duplicate()
	entries.sort_custom(func(a: VendorStockEntry, b: VendorStockEntry) -> bool:
		var card_a: CardData = Session.content.card(a.card_id)
		var card_b: CardData = Session.content.card(b.card_id)
		if CardPricing.price(card_a) != CardPricing.price(card_b):
			return CardPricing.price(card_a) < CardPricing.price(card_b)
		return card_a.display_name < card_b.display_name)
	for entry: VendorStockEntry in entries:
		var card: CardData = Session.content.card(entry.card_id)
		if card == null:
			continue
		_queue.append([card, not Condition.met(entry.unlock, state)])
	# Overnight Oct 17 (Phase 2, performance): the first row now, the rest a few per frame (a big stock used to stall one frame).
	for _first: int in range(FIRST_TILES):
		_build_next_tile()
	_toast = UIKit.label("", &"", 28, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_toast.add_theme_font_override("font", UIStyle.font_bold())
	_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.position = Vector2(460.0 + (vendor_inset if stage != null else 0.0) * 0.5, 1000)
	_toast.size = Vector2(1000, 40)
	_toast.modulate.a = 0.0
	_toast.z_index = 250
	add_child(_toast)
	_refresh()
	if VendorCategories.needs_picker(categories):
		_build_picker()
		_show_picker()
		return
	_show_cards_tip()


func _show_cards_tip() -> void:
	TipPanel.show_once(self, &"tip_vendor", "Buying cards", "Hover a card to zoom it, click it to buy. Gold comes from winning fights in the dungeon. You can carry [b]3 copies[/b] of a card at most, and rarer cards fewer until you level up (the [b]Own x/cap[/b] line under each card), so the vendor stops selling at your cap. Cards marked [b]???[/b] unlock as you play.", Vector2(560, 900))


const FIRST_TILES: int = 0  # Oct 17 cycle 25: 8 -> 4; Oct 18 cycle 32: 0 - the opening frame builds the screen (37 ms) and the cards start on the next one (84 ms with 4)
const TILES_PER_FRAME: int = 3
var _queue: Array[Array] = []


func _build_next_tile() -> bool:
	if _queue.is_empty():
		return false
	var next: Array = _queue.pop_front()
	var card: CardData = next[0] as CardData
	_cards[card.id] = card
	_locked[card.id] = bool(next[1])
	var tile: Control = _make_tile(card, bool(_locked[card.id]), stock.teaser_for(card.id))
	_grid.add_child(tile)
	if _filter != null:
		tile.visible = _filter.matches(card)
	return true


## True while stock tiles are still being added.
func is_building() -> bool:
	return not _queue.is_empty()


func _process(_delta: float) -> void:
	if _queue.is_empty():
		return
	for _step: int in range(TILES_PER_FRAME):
		if not _build_next_tile():
			break
	if _queue.is_empty() and _gold_label != null:
		_refresh()


func _make_tile(card: CardData, locked: bool, teaser: String) -> Control:
	var holder: Control = Control.new()
	var lift: float = CAN_REST if vendor_screen_id == "VS-GRISTLE" else 0.0
	holder.custom_minimum_size = CardView.SIZE * _card_scale + Vector2(0, 42.0 + lift)
	holder.set_meta("card_id", card.id)
	var view: CardView = CardView.create(card, CardView.Mode.BACK if locked else CardView.Mode.FULL, true)
	holder.add_child(view)
	CardView.fit(view, _card_scale)
	var card_area: Rect2 = Rect2(Vector2(0.0, lift), CardView.SIZE * _card_scale)
	if lift > 0.0:
		view.position.y += lift
	_decorate_tile(holder, view, card_area)
	if locked:
		view.modulate = Color(0.55, 0.55, 0.62)
		var lock_icon: TextureRect = IconArt.rect("ICON-PADLOCK", 64.0)
		if lock_icon != null:
			lock_icon.position = card_area.position + (card_area.size - Vector2(64, 64)) * 0.5
			holder.add_child(lock_icon)
	else:
		view.gui_event.connect(func(_v: CardView, event: InputEvent) -> void:
			var click: InputEventMouseButton = event as InputEventMouseButton
			if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
				_ask_to_buy(card))
	view.hovered.connect(func(_v: CardView) -> void:
		if not locked:
			_preview.show_for(holder, card)
		Audio.sfx(&"card_hover", -14.0))
	view.unhovered.connect(func(_v: CardView) -> void: _preview.hide_preview())
	var price: Label = UIKit.label("", &"", 24 if not locked else 15, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	price.add_theme_font_override("font", UIStyle.font_title() if not locked else UIStyle.font_body())
	price.add_theme_stylebox_override("normal", UIStyle.box(Color(0.05, 0.03, 0.09, 0.95), UIStyle.GOLD_DIM, 2, 14))
	price.position = Vector2(4, CardView.SIZE.y * _card_scale + 6.0 + lift)
	price.size = Vector2(104, 32)
	price.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(price)
	_price_labels[card.id] = price
	var owned: Label = UIKit.label("", &"", 18, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	owned.add_theme_font_override("font", UIStyle.font_bold())
	owned.add_theme_stylebox_override("normal", UIStyle.box(Color(0.05, 0.03, 0.09, 0.9), Color(0, 0, 0, 0), 0, 10))
	owned.position = Vector2(112, CardView.SIZE.y * _card_scale + 8.0 + lift)
	owned.size = Vector2(CardView.SIZE.x * _card_scale - 116.0, 28)
	owned.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	owned.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if locked:
		owned.text = ""
	holder.add_child(owned)
	_owned_labels[card.id] = owned
	if locked:
		holder.set_meta("teaser", teaser)
	_tiles.append(holder)
	return holder



## The sheet's per-vendor tile looks (docs: VENDOR SCREENS in the NPC list): Mirepoix's cloches, Gristle's tin cans, Benchley's supplement tubs, Fig Sly's hidden compartments and
## Sable's gently fanned rows. Purely cosmetic.
func _decorate_tile(holder: Control, view: CardView, area: Rect2) -> void:
	match vendor_screen_id:
		"VS-MIREPOIX":
			VendorFx.add_cloche(holder, area)
		"VS-GRISTLE":
			VendorFx.add_stand(holder, area, VendorFx.Stand.CAN, Color(0.62, 0.66, 0.7))
			VendorFx.add_pull_out(holder, view, view.position, CAN_REST)
		"VS-BENCHLEY":
			VendorFx.add_stand(holder, area, VendorFx.Stand.TUB, TUB_COLORS[_tiles.size() % TUB_COLORS.size()])
		"VS-FIGSLY":
			VendorFx.add_compartment(holder, area)
		"VS-SABLE":
			var columns: int = _grid.columns
			holder.pivot_offset = Vector2(holder.custom_minimum_size.x * 0.5, holder.custom_minimum_size.y)
			holder.rotation = (float(_tiles.size() % columns) - float(columns - 1) * 0.5) * 0.016

func _apply_filter() -> void:
	for tile: Control in _tiles:
		tile.visible = _filter.matches(_cards[str(tile.get_meta("card_id"))] as CardData)


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for id: Variant in _cards.keys():
		if not _price_labels.has(id):
			continue
		var card: CardData = _cards[id] as CardData
		var price_label: Label = _price_labels[id] as Label
		if bool(_locked.get(id, false)):
			IconArt.set_price_text(price_label, "???")
			price_label.add_theme_color_override("font_color", UIStyle.MUTED)
			continue
		var owned: int = Session.owned_count(card.id)
		var for_sale: bool = CardPricing.is_for_sale(card, owned, Session.copy_cap(card))
		var price: int = Session.effective_price(CardPricing.price(card))
		if for_sale:
			IconArt.set_price(price_label, price)
		else:
			IconArt.set_price_text(price_label, "Max")
		var affordable: bool = Session.gold >= price
		price_label.add_theme_color_override("font_color", UIStyle.GOLD if affordable and for_sale else (Color("e06a5a") if for_sale else UIStyle.MUTED))
		(_owned_labels[id] as Label).text = "Own %s" % CopyCaps.ratio_text(owned, card, Session.profile.level)


func _ask_to_buy(card: CardData) -> void:
	if bool(_locked.get(card.id, false)):
		Audio.sfx(&"ui_error", -4.0)
		_say(str(stock.teaser_for(card.id)), Color("ffcf70"))
		return
	var owned: int = Session.owned_count(card.id)
	if not CardPricing.is_for_sale(card, owned, Session.copy_cap(card)):
		Audio.sfx(&"ui_error", -4.0)
		_say("You own %s. %s" % [CopyCaps.ratio_text(owned, card, Session.profile.level), CopyCaps.reason(card, Session.profile.level)], Color("ffcf70"))
		return
	var price: int = Session.effective_price(CardPricing.price(card))
	if Session.gold < price:
		Audio.sfx(&"ui_error", -4.0)
		_say("Not enough gold: %s costs %d." % [card.display_name, price], Color("ff8a85"))
		vendor_react("poor")
		return
	var dialog: ConfirmDialog = ConfirmDialog.ask(
		self, "Buy %s?" % card.display_name,
		"%d gold for one copy. You own %d and will have %d gold left." % [price, owned, Session.gold - price],
		"Buy", "Not now",
	)
	dialog.confirmed.connect(func() -> void: _buy(card))


func _buy(card: CardData) -> void:
	var price: int = Session.effective_price(CardPricing.price(card))
	if not Session.spend_gold(price):
		return
	Session.add_cards([card] as Array[CardData])
	Session.bump_counter("cards_bought")  # Oct 20: Meet the Merchants asks for one card bought
	Session.save_game()
	Audio.sting(&"STG-PURCHASE")
	Audio.sfx(&"shop_buy")
	_say("Bought %s." % card.display_name, UIStyle.GOOD)
	vendor_react("buy")
	_refresh()


func _say(text: String, color: Color = UIStyle.PARCHMENT) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", color)
	_toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


func _open_gear() -> void:
	Audio.sfx(&"ui_open")
	var shop: EquipmentVendorScreen = EquipmentVendorScreen.new()
	shop.stock = gear_stock
	shop.screen_title = "%s: Gear" % screen_title
	shop.vendor_screen_id = ""
	shop.close_text = "Back (Esc)"
	shop.z_index = 100
	add_child(shop)
	shop.closed.connect(func() -> void:
		shop.queue_free()
		_back_to_picker())


func _open_packs() -> void:
	Audio.sfx(&"ui_open")
	var shop: PackShopScreen = PackShopScreen.make(pack_vendor_id, pack_story_prefix)
	shop.close_text = "Back (Esc)"
	shop.z_index = 100
	add_child(shop)
	shop.closed.connect(func() -> void:
		shop.queue_free()
		_back_to_picker())


# ---- Category selection (Part 2) ------------------------------------------------------------------


func _build_picker() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.name = "CategoryPicker"
	body.add_child(center)
	_picker = center
	var column: VBoxContainer = UIKit.vbox(26)
	center.add_child(column)
	column.add_child(UIKit.label("What are you after?", &"", 34, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(28)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	_picker_buttons.clear()
	for kind: VendorCategories.Kind in categories:
		var tile: FancyButton = FancyButton.make(VendorCategories.label(kind), &"PrimaryButton", Vector2(250, 250))
		tile.name = "Category%s" % VendorCategories.label(kind).replace(" ", "")
		tile.tooltip_text = VendorCategories.blurb(kind)
		tile.icon = IconArt.texture(VendorCategories.icon(kind), 128.0)
		tile.expand_icon = true
		tile.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tile.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		tile.add_theme_constant_override("icon_max_width", 128)
		tile.add_theme_font_size_override("font_size", 30)
		tile.pressed.connect(func() -> void: open_category(kind))
		row.add_child(tile)
		tile.focus_mode = Control.FOCUS_ALL  # after FancyButton._ready, which turns focus off
		_picker_buttons.append(tile)
		var blurb: Label = UIKit.label(VendorCategories.blurb(kind), &"MutedLabel", 18, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		blurb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		blurb.position = Vector2(0, 250 - 40)
		blurb.size = Vector2(250, 30)
		tile.add_child(blurb)
	for index: int in range(_picker_buttons.size()):
		var here: FancyButton = _picker_buttons[index]
		var left: FancyButton = _picker_buttons[(index - 1 + _picker_buttons.size()) % _picker_buttons.size()]
		var right: FancyButton = _picker_buttons[(index + 1) % _picker_buttons.size()]
		here.focus_neighbor_left = here.get_path_to(left)
		here.focus_neighbor_right = here.get_path_to(right)


## Opens one category: the card grid in place, packs and gear as their own screens over the picker.
func open_category(kind: VendorCategories.Kind) -> void:
	match kind:
		VendorCategories.Kind.CARDS:
			Audio.sfx(&"ui_open")
			_show_cards()
		VendorCategories.Kind.PACKS:
			_open_packs()
		VendorCategories.Kind.GEAR:
			_open_gear()


func _show_picker() -> void:
	_showing_cards = false
	_cards_view.visible = false
	_picker.visible = true
	set_close_label(close_text)
	if not _picker_buttons.is_empty() and not warming:
		_picker_buttons[0].call_deferred(&"grab_focus")


func _show_cards() -> void:
	_showing_cards = true
	if _picker != null:
		_picker.visible = false
		set_close_label("Back (Esc)")
	_cards_view.visible = true
	_refresh()
	_show_cards_tip()


func _back_to_picker() -> void:
	_refresh()
	if _picker == null:
		return
	Audio.sfx(&"ui_back")
	_show_picker()


## True while the category selection screen is up (tests and smokes).
func is_on_picker() -> bool:
	return _picker != null and _picker.visible


## Back from the card grid to the picker; from the picker (or a single-category vendor) leaves the shop.
func request_close() -> void:
	if _picker != null and _showing_cards:
		_back_to_picker()
		return
	super.request_close()
