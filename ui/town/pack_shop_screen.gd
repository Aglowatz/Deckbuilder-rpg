class_name PackShopScreen
extends OverlayScreen
## A vendor's pack stall: one tile per pack the vendor lists (`PackShop.listing`). Stocked packs can be bought, or bought and opened on
## the spot; locked packs are teasers (dimmed, a hint line from the story data). Used by the Pack Vendor, the card vendor's "Card Packs"
## button and the black market.

const ART_SCALE: float = 0.62

## Which vendor's packs to show (`PackData.VENDOR_*`).
var vendor_id: String = PackData.VENDOR_PACK
## Story keys: "<prefix>.title" is the header, "<prefix>.line" a speech line shown under it ("" = none).
var story_prefix: String = "town.pack_vendor"

var _row: HBoxContainer
var _gold_label: Label
var _quip: Label
var _count_labels: Dictionary = {}
var _buy_buttons: Dictionary = {}
var _open_buttons: Dictionary = {}
var _price_labels: Dictionary = {}


## The stall of one vendor (`PackData.VENDOR_*`); `prefix` picks its story keys ("<prefix>.title", "<prefix>.line").
static func make(vendor: String, prefix: String) -> PackShopScreen:
	var screen: PackShopScreen = PackShopScreen.new()
	screen.vendor_id = vendor
	screen.story_prefix = prefix
	screen.screen_title = StoryText.shared().text("%s.title" % prefix)
	return screen


func _init() -> void:
	close_text = "Leave (Esc)"


func _build() -> void:
	var story: StoryText = StoryText.shared()
	var coin: TextureRect = CardIcons.glyph(CardIcons.ui("coins"), UIStyle.GOLD, Vector2(38, 38))
	header_extra.add_child(coin)
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	var line_key: String = "%s.line" % story_prefix
	if story.texts.has(line_key):
		var line: Label = UIKit.label(story.text(line_key), &"", 24, UIStyle.PARCHMENT)
		line.add_theme_font_override("font", UIStyle.font_italic())
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(1500, 0)
		body.add_child(line)
	var center: CenterContainer = CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(1780, 640)
	center.add_child(scroll)
	_row = UIKit.hbox(26)
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_row)
	var state: UnlockState = Session.unlock_state()
	for pack: PackData in PackShop.listing(vendor_id):
		if PackShop.is_visible(pack, state):
			_row.add_child(_make_tile(pack, PackShop.is_unlocked(pack, state)))
	_quip = UIKit.label("", &"", 28, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_quip.add_theme_font_override("font", UIStyle.font_italic())
	_quip.custom_minimum_size = Vector2(0, 40)
	body.add_child(_quip)
	_refresh()


func _make_tile(pack: PackData, stocked: bool) -> Control:
	var story: StoryText = StoryText.shared()
	var tile: PanelContainer = UIKit.panel()
	tile.custom_minimum_size = Vector2(330, 620)
	var column: VBoxContainer = UIKit.vbox(8)
	tile.add_child(column)
	var art_holder: Control = Control.new()
	art_holder.custom_minimum_size = PackArt.SIZE * ART_SCALE
	art_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art: PackArt = PackArt.create(pack)
	art.scale = Vector2.ONE * ART_SCALE
	art.position = -PackArt.SIZE * (1.0 - ART_SCALE) * 0.5
	if not stocked:
		art.modulate = Color(0.35, 0.35, 0.42)
	art_holder.add_child(art)
	if not stocked:
		var lock: TextureRect = CardIcons.glyph(CardIcons.ui("lock"), Color(1, 1, 1, 0.85), Vector2(64, 64))
		lock.position = (PackArt.SIZE * ART_SCALE - Vector2(64, 64)) * 0.5 + Vector2(0, 40)
		lock.size = Vector2(64, 64)
		art_holder.add_child(lock)
	var art_center: CenterContainer = CenterContainer.new()
	art_center.add_child(art_holder)
	column.add_child(art_center)
	var name_label: Label = UIKit.label(pack.display_name if stocked else "???", &"HeadingLabel", 26, UIStyle.GOLD if stocked else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(name_label)
	var description: Label = UIKit.label(PackShop.describe(pack) if stocked else story.text("pack.hint.%s" % pack.id), &"", 19, UIStyle.PARCHMENT if stocked else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(290, 84)
	column.add_child(description)
	column.add_child(UIKit.filler())
	if not stocked:
		return tile
	var price: Label = UIKit.label("", &"", 28, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	price.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(price)
	_price_labels[pack.id] = price
	var own: Label = UIKit.label("", &"MutedLabel", 18, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(own)
	_count_labels[pack.id] = own
	var buttons: HBoxContainer = UIKit.hbox(8)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)
	var buy: FancyButton = FancyButton.make("Buy", &"PrimaryButton", Vector2(120, 48))
	buy.name = "Buy_%s" % pack.id
	buy.pressed.connect(func() -> void: _buy(pack, false))
	buttons.add_child(buy)
	_buy_buttons[pack.id] = buy
	var open: FancyButton = FancyButton.make("Buy & open", &"", Vector2(150, 48))
	open.name = "BuyOpen_%s" % pack.id
	open.pressed.connect(func() -> void: _buy(pack, true))
	buttons.add_child(open)
	_open_buttons[pack.id] = open
	return tile


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for pack_id: Variant in _price_labels.keys():
		var pack: PackData = PackCatalog.find(str(pack_id))
		var price: int = PackShop.price_for(pack, Session.profile)
		var label: Label = _price_labels[pack_id] as Label
		label.text = "%d gold" % price
		var affordable: bool = Session.gold >= price
		label.add_theme_color_override("font_color", UIStyle.GOLD if affordable else Color("e06a5a"))
		(_count_labels[pack_id] as Label).text = "In your inventory: %d" % Session.pack_count(str(pack_id))


func _buy(pack: PackData, open_now: bool) -> void:
	var story: StoryText = StoryText.shared()
	var price: int = PackShop.price_for(pack, Session.profile)
	if Session.gold < price:
		Audio.sfx(&"ui_error", -4.0)
		_say(_pick(story.get_lines("pack.vendor.poor")), Color("ff8a85"))
		return
	if not Session.buy_pack(pack):
		return
	Audio.sfx(&"coins")
	_say(_pick(story.get_lines("pack.vendor.bought")), UIStyle.GOOD)
	_refresh()
	if open_now:
		PackOpeningScreen.open_from_inventory(self, pack.id, func() -> void: _refresh())


func _pick(lines: Array[String]) -> String:
	return lines[Session.rng.randi_range(0, lines.size() - 1)] if not lines.is_empty() else ""


func _say(text: String, color: Color) -> void:
	_quip.text = text
	_quip.add_theme_color_override("font_color", color)
	_quip.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(2.4)
	tween.tween_property(_quip, "modulate:a", 0.0, 0.5)
