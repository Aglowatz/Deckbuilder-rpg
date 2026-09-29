class_name VendorScreen
extends OverlayScreen
## The card vendor: stock is data-driven (`VendorData`/`Condition` - see docs/design/
## open_questions.md D37): each card has its own unlock condition, so the stall starts small and
## grows with progress. A locked card shows as a "???" teaser instead of its real art.

const CARD_SCALE: float = 0.68
const COLUMNS: int = 8

var stock: VendorData
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


func _init() -> void:
	screen_title = "Sable's Card Stall"
	close_text = "Leave (Esc)"


func _build() -> void:
	if stock == null:
		stock = VendorData.graduated(Session.content, Session.deck.colors(), Condition.dungeon_cleared(TrialOfTheHollow.DUNGEON_NAME))
	var coin: TextureRect = CardIcons.glyph(CardIcons.ui("coins"), UIStyle.GOLD, Vector2(38, 38))
	header_extra.add_child(coin)
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	_preview = HoverPreview.new()
	add_child(_preview)
	_filter = CardFilterBar.new()
	_filter.changed.connect(_apply_filter)
	body.add_child(_filter)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
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
		_cards[card.id] = card
		_locked[card.id] = not Condition.met(entry.unlock, state)
		_grid.add_child(_make_tile(card, bool(_locked[card.id]), stock.teaser_for(card.id)))
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
	TipPanel.show_once(self, &"tip_vendor", "Buying cards", "Hover a card to zoom it, click it to buy. Gold comes from winning fights in the dungeon. A deck can only use [b]3 copies[/b] of a card, so the vendor stops selling after that. Cards marked [b]???[/b] unlock as you play.", Vector2(560, 900))


func _make_tile(card: CardData, locked: bool, teaser: String) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = CardView.SIZE * CARD_SCALE + Vector2(0, 42)
	holder.set_meta("card_id", card.id)
	var view: CardView = CardView.create(card, CardView.Mode.BACK if locked else CardView.Mode.FULL)
	holder.add_child(view)
	CardView.fit(view, CARD_SCALE)
	if locked:
		view.modulate = Color(0.55, 0.55, 0.62)
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
	price.position = Vector2(4, CardView.SIZE.y * CARD_SCALE + 6.0)
	price.size = Vector2(104, 32)
	price.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(price)
	_price_labels[card.id] = price
	var owned: Label = UIKit.label("", &"", 18, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	owned.add_theme_font_override("font", UIStyle.font_bold())
	owned.add_theme_stylebox_override("normal", UIStyle.box(Color(0.05, 0.03, 0.09, 0.9), Color(0, 0, 0, 0), 0, 10))
	owned.position = Vector2(112, CardView.SIZE.y * CARD_SCALE + 8.0)
	owned.size = Vector2(CardView.SIZE.x * CARD_SCALE - 116.0, 28)
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


func _apply_filter() -> void:
	for tile: Control in _tiles:
		tile.visible = _filter.matches(_cards[str(tile.get_meta("card_id"))] as CardData)


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for id: Variant in _cards.keys():
		var card: CardData = _cards[id] as CardData
		var price_label: Label = _price_labels[id] as Label
		if bool(_locked.get(id, false)):
			price_label.text = "???"
			price_label.add_theme_color_override("font_color", UIStyle.MUTED)
			continue
		var owned: int = Session.owned_count(card.id)
		var for_sale: bool = CardPricing.is_for_sale(card, owned)
		var price: int = Session.effective_price(CardPricing.price(card))
		price_label.text = str(price) if for_sale else "Max"
		var affordable: bool = Session.gold >= price
		price_label.add_theme_color_override("font_color", UIStyle.GOLD if affordable and for_sale else (Color("e06a5a") if for_sale else UIStyle.MUTED))
		(_owned_labels[id] as Label).text = "Own %d" % owned


func _ask_to_buy(card: CardData) -> void:
	if bool(_locked.get(card.id, false)):
		Audio.sfx(&"ui_error", -4.0)
		_say(str(stock.teaser_for(card.id)), Color("ffcf70"))
		return
	var owned: int = Session.owned_count(card.id)
	if not CardPricing.is_for_sale(card, owned):
		Audio.sfx(&"ui_error", -4.0)
		_say("You already own the %d copies a deck can use." % CardPricing.MAX_OWNED_FOR_SALE, Color("ffcf70"))
		return
	var price: int = Session.effective_price(CardPricing.price(card))
	if Session.gold < price:
		Audio.sfx(&"ui_error", -4.0)
		_say("Not enough gold: %s costs %d." % [card.display_name, price], Color("ff8a85"))
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
	Session.save_game()
	Audio.sfx(&"coins")
	_say("Bought %s." % card.display_name, UIStyle.GOOD)
	_refresh()


func _say(text: String, color: Color = UIStyle.PARCHMENT) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", color)
	_toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.4)
