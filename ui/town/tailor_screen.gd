class_name TailorScreen
extends OverlayScreen
## Thimble's Hats & Hems: the clothing shop. The hero's rotating copy tries anything on before it is bought (hover or "Try"); pick a dye, then buy: the item is added to the
## wardrobe and worn at once. Stock grows with zones freed and levels (`CosmeticCatalog.vendor_stock`); locked pieces are teasers with their requirement.

var _look: CosmeticState
var _preview: HeroPreview
var _gold_label: Label
var _quip: Label
var _grid: GridContainer
var _tiles: Dictionary = {}
var _dye_rows: Dictionary = {}
var _selected: CosmeticData
var _selected_label: Label


func _init() -> void:
	screen_title = StoryText.shared().text("town.tailor.title")
	close_text = "Leave (Esc)"


func _build() -> void:
	var story: StoryText = StoryText.shared()
	var coin: TextureRect = CardIcons.glyph(CardIcons.ui("coins"), UIStyle.GOLD, Vector2(38, 38))
	header_extra.add_child(coin)
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	_look = Session.cosmetics.duplicate_state()
	var line: Label = UIKit.label(story.text("town.tailor.line"), &"", 24, UIStyle.PARCHMENT)
	line.add_theme_font_override("font", UIStyle.font_italic())
	body.add_child(line)
	var row: HBoxContainer = UIKit.hbox(26)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	var preview_panel: PanelContainer = UIKit.panel()
	row.add_child(preview_panel)
	_preview = HeroPreview.new()
	_preview.look = _look
	preview_panel.add_child(_preview)
	var right: VBoxContainer = UIKit.vbox(10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(right)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(1080, 500)
	right.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(_grid)
	_populate()
	_selected_label = UIKit.label("Hover or press Try to see it on you.", &"MutedLabel", 22)
	right.add_child(_selected_label)
	_add_dyes(right, CosmeticData.Slot.HAT, "Hat dye")
	_add_dyes(right, CosmeticData.Slot.CLOAK, "Cloak dye")
	_quip = UIKit.label("", &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_quip.add_theme_font_override("font", UIStyle.font_italic())
	body.add_child(_quip)
	_refresh()



func _populate() -> void:
	var state: UnlockState = Session.unlock_state()
	var open_items: Array[CosmeticData] = []
	var locked_items: Array[CosmeticData] = []
	for item: CosmeticData in CosmeticCatalog.all():
		if not item.is_for_sale():
			continue
		if Condition.met(item.unlock, state):
			open_items.append(item)
		else:
			locked_items.append(item)
	for item: CosmeticData in open_items:
		_grid.add_child(_make_tile(item, true))
	for item: CosmeticData in locked_items:
		_grid.add_child(_make_tile(item, false))



func _make_tile(item: CosmeticData, open: bool) -> Control:
	var tile: PanelContainer = UIKit.panel()
	tile.custom_minimum_size = Vector2(340, 150)
	var column: VBoxContainer = UIKit.vbox(4)
	tile.add_child(column)
	var title: Label = UIKit.label(item.display_name if open else "???", &"HeadingLabel", 24, UIStyle.GOLD if open else UIStyle.MUTED)
	column.add_child(title)
	var kind: Label = UIKit.label("%s%s" % [item.slot_name(), "" if open else "   (%s)" % CosmeticCatalog.unlock_hint(item)], &"MutedLabel", 18)
	column.add_child(kind)
	var blurb: Label = UIKit.label(item.description if open else StoryText.shared().text("tailor.locked"), &"", 17, UIStyle.PARCHMENT if open else UIStyle.MUTED)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(300, 46)
	column.add_child(blurb)
	column.add_child(UIKit.filler())
	if not open:
		tile.modulate = Color(0.7, 0.7, 0.78)
		return tile
	var buttons: HBoxContainer = UIKit.hbox(8)
	column.add_child(buttons)
	var price: Label = UIKit.label("", &"", 24, UIStyle.GOLD)
	price.add_theme_font_override("font", UIStyle.font_title())
	price.custom_minimum_size = Vector2(90, 0)
	buttons.add_child(price)
	var try_button: FancyButton = FancyButton.make("Try", &"", Vector2(90, 44))
	try_button.name = "Try_%s" % item.id
	try_button.pressed.connect(func() -> void: _try(item))
	buttons.add_child(try_button)
	var buy: FancyButton = FancyButton.make("Buy", &"PrimaryButton", Vector2(110, 44))
	buy.name = "Buy_%s" % item.id
	buy.pressed.connect(func() -> void: _buy(item))
	buttons.add_child(buy)
	tile.mouse_entered.connect(func() -> void: _try(item, false))
	_tiles[item.id] = {"price": price, "buy": buy, "try": try_button}
	return tile


func _add_dyes(parent: VBoxContainer, slot: CosmeticData.Slot, title: String) -> void:
	var key: String = "hat" if slot == CosmeticData.Slot.HAT else "cloak"
	var dyes: HBoxContainer = UIKit.hbox(8)
	parent.add_child(dyes)
	var caption: Label = UIKit.label(title, &"MutedLabel", 22)
	caption.custom_minimum_size = Vector2(130, 0)
	dyes.add_child(caption)
	var buttons: Array[Button] = []
	for index: int in range(Dye.count()):
		var swatch: Button = Button.new()
		swatch.name = "Dye_%s_%d" % [key, index]
		swatch.custom_minimum_size = Vector2(42, 42)
		swatch.tooltip_text = Dye.dye_name(index)
		swatch.focus_mode = Control.FOCUS_NONE
		swatch.pressed.connect(func() -> void:
			_look.set_dye(slot, index)
			_preview.set_look(_look)
			Audio.sfx(&"ui_tick")
			_refresh())
		dyes.add_child(swatch)
		buttons.append(swatch)
	_dye_rows[key] = buttons


## Puts `item` on the preview (worn for the try-on only; nothing is owned until it is bought).
func _try(item: CosmeticData, sound: bool = true) -> void:
	_selected = item
	_look.grant(item.id)
	_look.equip(item.slot, item.id, true)
	_preview.set_look(_look)
	if sound:
		Audio.sfx(&"ui_tick")
	_refresh()


func _buy(item: CosmeticData) -> void:
	var story: StoryText = StoryText.shared()
	if Session.cosmetics.owns(item.id):
		_say(story.get_lines("tailor.owned"))
		return
	if Session.gold < item.price:
		_say(story.get_lines("tailor.poor"))
		Audio.sfx(&"ui_error")
		return
	if not Session.buy_cosmetic(item.id):
		_say(story.get_lines("tailor.locked"))
		return
	# wear it with the dye that was previewed
	var worn: CosmeticState = Session.cosmetics.duplicate_state()
	worn.equip(item.slot, item.id, true)
	worn.set_dye(item.slot, _look.dye_index(item.slot))
	Session.apply_look(worn)
	_look.hat_id = worn.hat_id
	_look.cloak_id = worn.cloak_id
	_preview.set_look(_look)
	_preview.play_once(&"Cheer")
	Audio.sfx(&"coins", 0.0, 0.05)
	_say(story.get_lines("tailor.bought"))
	_refresh()


func _say(lines: Array[String]) -> void:
	if not lines.is_empty():
		_quip.text = lines[randi() % lines.size()]


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for item_id: String in _tiles:
		var item: CosmeticData = CosmeticCatalog.find(item_id)
		var entry: Dictionary = _tiles[item_id] as Dictionary
		var owned: bool = Session.cosmetics.owns(item_id)
		(entry["price"] as Label).text = "Owned" if owned else "%dg" % item.price
		var buy: FancyButton = entry["buy"] as FancyButton
		buy.disabled = owned
		buy.text = "Worn" if owned and Session.cosmetics.equipped_id(item.slot) == item_id else ("Owned" if owned else "Buy")
	for key: String in _dye_rows:
		var slot: CosmeticData.Slot = CosmeticData.Slot.HAT if key == "hat" else CosmeticData.Slot.CLOAK
		var buttons: Array = _dye_rows[key] as Array
		for index: int in range(buttons.size()):
			var swatch: Button = buttons[index] as Button
			var selected: bool = _look.dye_index(slot) == index
			for state_name: String in ["normal", "hover", "pressed", "focus"]:
				var box: StyleBoxFlat = StyleBoxFlat.new()
				box.bg_color = Dye.primary(index)
				box.set_corner_radius_all(10)
				box.set_border_width_all(4 if selected else 2)
				box.border_color = UIStyle.GOLD if selected else Color(0, 0, 0, 0.55)
				swatch.add_theme_stylebox_override(state_name, box)
	if _selected != null:
		_selected_label.text = "Trying on: %s (%s)" % [_selected.display_name, "owned" if Session.cosmetics.owns(_selected.id) else "%d gold" % _selected.price]
