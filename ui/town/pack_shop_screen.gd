class_name PackShopScreen
extends OverlayScreen
## A vendor's pack stall: one tile per pack the vendor lists (`PackShop.listing`). Stocked packs can be bought, or bought and opened on
## the spot; locked packs are teasers (dimmed, a hint line from the story data). Used by the Pack Vendor, the card vendor's "Card Packs"
## button and the black market.

const ART_SCALE: float = 0.62
## With a vendor stage the row sits on the right: smaller tiles.
const STAGED_ART_SCALE: float = 0.56
## Fable Nov 15 (Part 4b): 236 wide for real (the name wraps and the two buttons stack), so four packs fit beside the vendor at the
## default text size; taller for the second button.
const STAGED_TILE: Vector2 = Vector2(236, 560)
## Vendor Screen ID per pack vendor.
const VENDOR_SCREENS: Dictionary = {PackData.VENDOR_PACK: "VS-FENWICK", PackData.VENDOR_CARD: "VS-SABLE", PackData.VENDOR_BLACK_MARKET: "VS-FIGSLY"}

## Which vendor's packs to show (`PackData.VENDOR_*`).
var vendor_id: String = PackData.VENDOR_PACK
## Story keys: "<prefix>.title" is the header, "<prefix>.line" a speech line shown under it ("" = none).
var story_prefix: String = "town.pack_vendor"

var _row: HBoxContainer
var _scroll: ScrollContainer
var _holder: Control
var _gold_label: Label
var _quip: Label
var _count_labels: Dictionary = {}
var _buy_buttons: Dictionary = {}
var _open_buttons: Dictionary = {}
var _price_labels: Dictionary = {}
var _art_scale: float = ART_SCALE
var _tile_size: Vector2 = Vector2(330, 620)


## The stall of one vendor (`PackData.VENDOR_*`); `prefix` picks its story keys ("<prefix>.title", "<prefix>.line").
static func make(vendor: String, prefix: String) -> PackShopScreen:
	var screen: PackShopScreen = PackShopScreen.new()
	screen.vendor_id = vendor
	screen.story_prefix = prefix
	screen.screen_title = StoryText.shared().text("%s.title" % prefix)
	screen.vendor_screen_id = str(VENDOR_SCREENS.get(vendor, ""))
	return screen


func _init() -> void:
	close_text = "Leave (Esc)"


func _build() -> void:
	if stage != null:
		_art_scale = STAGED_ART_SCALE
		_tile_size = STAGED_TILE
	var story: StoryText = StoryText.shared()
	var coin: TextureRect = IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 38.0)
	header_extra.add_child(coin)
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	var line_key: String = "%s.line" % story_prefix
	if story.texts.has(line_key):
		var line: Label = UIKit.label(story.text(line_key), &"", 24, UIStyle.PARCHMENT)
		line.add_theme_font_override("font", UIStyle.font_italic())
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(1500.0 - (vendor_inset if stage != null else 0.0), 0)
		body.add_child(line)
	# Fable Nov 15 (Part 4b): the row takes the width the screen really has and scrolls sideways when the packs do not fit (Fig's fourth
	# pack was cut off at Large text: the row asked for a fixed 1780 px, wider than its panel, so it was clipped with no scrollbar). A
	# gold bar under the row, the wheel, dragging and a controller's left/right all move it (ScrollKit).
	var holder: VBoxContainer = UIKit.vbox(0)
	holder.alignment = BoxContainer.ALIGNMENT_CENTER
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(holder)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "PackRowScroll"
	scroll.custom_minimum_size = Vector2(0, _tile_size.y + ScrollKit.BAR_THICKNESS + 22.0)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ScrollKit.row(scroll)
	holder.add_child(scroll)
	_scroll = scroll
	_holder = holder
	holder.resized.connect(_fit_scroll)
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
	_fit_scroll.call_deferred()


## Fable Nov 15 (Part 4b): the row is as tall as its tallest tile really is (Large text makes the tiles taller than their nominal size,
## and the second button was cut off). When even that does not fit the screen (a big UI scale) the row scrolls up and down as well, with
## its own bar, so the buttons can always be reached.
func _fit_scroll() -> void:
	if _scroll == null or _row == null or _holder == null or not is_inside_tree():
		return
	var wanted: float = _row.get_combined_minimum_size().y + ScrollKit.BAR_THICKNESS + 6.0
	var room: float = _holder.size.y
	var fits: bool = room <= 0.0 or wanted <= room + 0.5
	_scroll.custom_minimum_size.y = wanted if fits else maxf(room, 200.0)
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER if fits else ScrollContainer.SCROLL_MODE_AUTO
	if not fits:
		ScrollKit.list(_scroll)


func _make_tile(pack: PackData, stocked: bool) -> Control:
	var story: StoryText = StoryText.shared()
	var tile: PanelContainer = UIKit.panel()
	tile.custom_minimum_size = _tile_size
	var column: VBoxContainer = UIKit.vbox(8)
	tile.add_child(column)
	var art_holder: Control = Control.new()
	art_holder.custom_minimum_size = PackArt.SIZE * _art_scale
	art_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # Nov 2 pass, Part 7: the pack centred in its tile, not left of it
	art_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art: PackArt = PackArt.create(pack)
	art.scale = Vector2.ONE * _art_scale
	art.position = -PackArt.SIZE * (1.0 - _art_scale) * 0.5
	# Batch 15: a locked Path Pack is its painted parcel (wrapped, sealed in the Path's colour, padlocked) in the pack's own place and size -
	# no dimmed pack, velvet cover or lock glyph over it.
	var parcel: TextureRect = PackArt.locked_picture(pack, PackArt.SIZE * _art_scale) if not stocked else null
	if not stocked:
		art.modulate = Color(0.35, 0.35, 0.42)
	if parcel != null:
		art.free()
		art_holder.add_child(parcel)
	else:
		art_holder.add_child(art)
	if parcel != null:
		pass
	elif not stocked and vendor_screen_id == "VS-FENWICK":
		# The sheet: locked Path Packs are covered pedestals with a hint.
		var cover: VendorFx.VelvetCover = VendorFx.velvet_cover(UIStyle.affinity_color(pack.path).darkened(0.45) if pack.kind == PackData.Kind.PATH else Color(0.4, 0.12, 0.2))
		cover.position = Vector2(-4.0, 6.0)
		cover.size = PackArt.SIZE * _art_scale + Vector2(8.0, 0.0)
		art_holder.add_child(cover)
	elif not stocked:
		var lock: TextureRect = IconArt.glyph_or("ICON-PADLOCK", CardIcons.ui("lock"), Color(1, 1, 1, 0.85), 64.0)
		lock.position = (PackArt.SIZE * _art_scale - Vector2(64, 64)) * 0.5 + Vector2(0, 40)
		lock.size = Vector2(64, 64)
		art_holder.add_child(lock)
	var art_center: CenterContainer = CenterContainer.new()
	art_center.add_child(art_holder)
	column.add_child(art_center)
	var name_label: Label = UIKit.label(pack.display_name if stocked else "???", &"HeadingLabel", 26 if stage == null else 21, UIStyle.GOLD if stocked else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.custom_minimum_size = Vector2(_tile_size.x - 40.0, 0)
	column.add_child(name_label)
	var description: Label = UIKit.label(PackShop.describe(pack) if stocked else story.text("pack.hint.%s" % pack.id), &"", 19, UIStyle.PARCHMENT if stocked else UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(_tile_size.x - 40.0, 84)
	column.add_child(description)
	column.add_child(UIKit.filler())
	if not stocked:
		return tile
	if pack.kind == PackData.Kind.GENERAL and pack.general_tier >= 2 and not Session.flag(_shelf_flag()):
		# Sable's second shelf appears with a sparkle the first time it is open for business.
		Session.set_flag(_shelf_flag())
		var spot: Rect2 = Rect2(Vector2.ZERO, _tile_size)
		tile.ready.connect(func() -> void: VendorFx.sparkle(tile, spot))
	var price: Label = UIKit.label("", &"", 28, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	price.add_theme_font_override("font", UIStyle.font_title())
	column.add_child(price)
	_price_labels[pack.id] = price
	var own: Label = UIKit.label("", &"MutedLabel", 18, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(own)
	_count_labels[pack.id] = own
	var buttons: BoxContainer = UIKit.hbox(8) if stage == null else UIKit.vbox(6)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)
	var buy: FancyButton = FancyButton.make("Buy", &"PrimaryButton", Vector2(120, 48) if stage == null else Vector2(170, 44))
	buy.name = "Buy_%s" % pack.id
	buy.pressed.connect(func() -> void: _buy(pack, false))
	buy.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	buttons.add_child(buy)
	_buy_buttons[pack.id] = buy
	var open: FancyButton = FancyButton.make("Buy & open", &"", Vector2(150, 48) if stage == null else Vector2(170, 44))
	open.name = "BuyOpen_%s" % pack.id
	open.pressed.connect(func() -> void: _buy(pack, true))
	open.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	buttons.add_child(open)
	_open_buttons[pack.id] = open
	return tile


func _shelf_flag() -> StringName:
	return StringName("tier2_shelf_seen_%s" % vendor_id)


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for pack_id: Variant in _price_labels.keys():
		var pack: PackData = PackCatalog.find(str(pack_id))
		var price: int = PackShop.price_for(pack, Session.profile)
		var label: Label = _price_labels[pack_id] as Label
		IconArt.set_price(label, price)
		var affordable: bool = Session.gold >= price
		label.add_theme_color_override("font_color", UIStyle.GOLD if affordable else Color("e06a5a"))
		(_count_labels[pack_id] as Label).text = "In your inventory: %d" % Session.pack_count(str(pack_id))


func _buy(pack: PackData, open_now: bool) -> void:
	var story: StoryText = StoryText.shared()
	var price: int = PackShop.price_for(pack, Session.profile)
	if Session.gold < price:
		Audio.sfx(&"ui_error", -4.0)
		if stage != null:
			vendor_react("poor")
		else:
			_say(_pick(story.get_lines("pack.vendor.poor")), Color("ff8a85"))
		return
	if not Session.buy_pack(pack):
		return
	Audio.sting(&"STG-PURCHASE")
	if stage != null:
		vendor_react("buy")
	else:
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
