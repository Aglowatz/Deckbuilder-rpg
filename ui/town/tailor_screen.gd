class_name TailorScreen
extends OverlayScreen
## Threadwell's Hats & Hems (was Thimble's, the tailor's retired name): the clothing shop. Stock grows with zones freed and levels
## (`CosmeticCatalog.vendor_stock`); locked pieces are teasers with their requirement.
## Overnight Nov 3-4, Part D: "Try" is **Preview** - the item alone, large, centred on a plain panel (the hero's body hid the hat, and its
## cloak competed with it); an owned item's Buy button is **Equip** ("Equipped" while worn), and a "No hat" entry takes the hat off. What is
## worn shows in the world as before.
## Fix pass Nov 4 (Part 3.3): two tabs, **Hats** and **Cloaks**. The plain cloak is the **Plain Cloak**, and the cloak dyes are back in the
## shop, in the Cloaks tab, each a piece like the rest (Preview / Buy / Equip, `Dye.PRICE`): the dye's preview is the hero in the Plain Cloak
## (a colour needs the cloak on the body to judge). Bought dyes are worn here or picked in the Wardrobe.

const PREVIEW_SIZE: float = 380.0
const TAB_HATS: String = "hats"
const TAB_CLOAKS: String = "cloaks"
const PLAIN_CLOAK: String = "Plain Cloak"

var _gold_label: Label
var _quip: Label
var _grid: GridContainer
var _tiles: Dictionary = {}
var _selected: CosmeticData
var _selected_dye: int = Dye.NATURAL
var _selected_label: Label
var _preview_icon: TextureRect
var _preview_name: Label
var _preview_kind: Label
var _preview_holder: CenterContainer
var _hero: HeroPreview
var _tab: String = TAB_HATS
var _tab_buttons: Dictionary = {}


func _init() -> void:
	screen_title = StoryText.shared().text("town.tailor.title")
	vendor_screen_id = "VS-THREADWELL"
	vendor_inset = 470.0
	close_text = "Leave (Esc)"


func _build() -> void:
	var story: StoryText = StoryText.shared()
	var coin: TextureRect = IconArt.glyph_or("ICON-GOLD", CardIcons.ui("coins"), UIStyle.GOLD, 38.0)
	header_extra.add_child(coin)
	_gold_label = UIKit.label("", &"", 34, UIStyle.GOLD)
	_gold_label.add_theme_font_override("font", UIStyle.font_title())
	header_extra.add_child(_gold_label)
	var line: Label = UIKit.label(story.text("town.tailor.line"), &"", 24, UIStyle.PARCHMENT)
	line.add_theme_font_override("font", UIStyle.font_italic())
	body.add_child(line)
	var row: HBoxContainer = UIKit.hbox(26)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	row.add_child(_build_preview())
	var right: VBoxContainer = UIKit.vbox(10)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(right)
	var tabs: HBoxContainer = UIKit.hbox(10)
	right.add_child(tabs)
	for tab: String in [TAB_HATS, TAB_CLOAKS]:
		var tab_button: FancyButton = FancyButton.make("Hats" if tab == TAB_HATS else "Cloaks", &"", Vector2(170, 48))
		tab_button.name = "Tab_%s" % tab
		tab_button.pressed.connect(func() -> void: show_tab(tab))
		tabs.add_child(tab_button)
		_tab_buttons[tab] = tab_button
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(1080 if stage == null else 720, 500)
	right.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 3 if stage == null else 2
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(_grid)
	show_tab(_tab)
	_selected_label = UIKit.label("Hover or press Preview to see a piece up close.", &"MutedLabel", 22)
	right.add_child(_selected_label)
	_quip = UIKit.label("", &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_quip.add_theme_font_override("font", UIStyle.font_italic())
	body.add_child(_quip)
	_refresh()


## The preview: a plain panel with the item alone, large and centred, its name and kind under it.
func _build_preview() -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "PreviewPanel"
	panel.add_theme_stylebox_override("panel", UIStyle.box(Color(0.1, 0.08, 0.15, 0.92), UIStyle.GOLD_DIM, 2, 18))
	panel.custom_minimum_size = Vector2(500 if stage != null else 460, 620)
	var column: VBoxContainer = UIKit.vbox(10)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(column)
	var holder: CenterContainer = CenterContainer.new()
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(holder)
	_preview_holder = holder
	_preview_icon = TextureRect.new()
	_preview_icon.name = "PreviewIcon"
	_preview_icon.custom_minimum_size = Vector2(PREVIEW_SIZE, PREVIEW_SIZE)
	_preview_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	holder.add_child(_preview_icon)
	_preview_name = UIKit.label("", &"HeadingLabel", 34, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_preview_name.name = "PreviewName"
	column.add_child(_preview_name)
	_preview_kind = UIKit.label("", &"MutedLabel", 22, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_preview_kind)
	column.add_child(UIKit.spacer(18))
	return panel


## Fix pass Nov 4 (Part 3.3): shows the Hats or the Cloaks tab (the cloaks, then the dyes for the Plain Cloak).
func show_tab(tab: String) -> void:
	_tab = tab
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	_tiles.clear()
	_populate()
	for key: String in _tab_buttons:
		(_tab_buttons[key] as FancyButton).theme_type_variation = &"PrimaryButton" if key == _tab else &""
	_refresh()


func current_tab() -> String:
	return _tab


func _populate() -> void:
	var slot: CosmeticData.Slot = CosmeticData.Slot.HAT if _tab == TAB_HATS else CosmeticData.Slot.CLOAK
	var state: UnlockState = Session.unlock_state()
	var open_items: Array[CosmeticData] = []
	var locked_items: Array[CosmeticData] = []
	for item: CosmeticData in CosmeticCatalog.all():
		if not item.is_for_sale() or item.slot != slot:
			continue
		if Condition.met(item.unlock, state):
			open_items.append(item)
		else:
			locked_items.append(item)
	_grid.add_child(_make_none_tile(slot))
	for item: CosmeticData in open_items:
		_grid.add_child(_make_tile(item, true))
	if slot == CosmeticData.Slot.CLOAK:
		for index: int in range(Dye.count()):
			_grid.add_child(_make_dye_tile(index))
	for item: CosmeticData in locked_items:
		_grid.add_child(_make_tile(item, false))


## "No hat" takes the hat off; the "Plain Cloak" puts the hero's own cloak back, undyed (always free, always there).
func _make_none_tile(slot: CosmeticData.Slot) -> Control:
	var key: String = none_id(slot)
	var tile: PanelContainer = UIKit.panel()
	tile.name = "Tile_%s" % key
	tile.custom_minimum_size = Vector2(340 if stage == null else 282, 150)
	var column: VBoxContainer = UIKit.vbox(4)
	tile.add_child(column)
	var hat: bool = slot == CosmeticData.Slot.HAT
	column.add_child(UIKit.label("No hat" if hat else PLAIN_CLOAK, &"HeadingLabel", 24, UIStyle.GOLD))
	var blurb: Label = UIKit.label("Let the hair breathe. Pip will pretend not to mind." if hat else "Your own dark teal cloak, undyed. The dyes below colour it.", &"", 17, UIStyle.PARCHMENT)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(300 if stage == null else 244, 46)
	column.add_child(blurb)
	column.add_child(UIKit.filler())
	var buttons: HBoxContainer = UIKit.hbox(8)
	column.add_child(buttons)
	buttons.add_child(UIKit.filler())
	var equip: FancyButton = FancyButton.make("Equip", &"PrimaryButton", Vector2(130, 44))
	equip.name = "Equip_%s" % key
	equip.pressed.connect(func() -> void: _equip_none(slot))
	buttons.add_child(equip)
	_tiles[key] = {"buy": equip, "slot": slot}
	return tile


static func none_id(slot: CosmeticData.Slot) -> String:
	return "none_hat" if slot == CosmeticData.Slot.HAT else "none_cloak"


static func dye_id(index: int) -> String:
	return "dye_%d" % index


## Fix pass Nov 4 (Part 3.3): one cloak dye, sold like a piece: a swatch, its name, Preview (the hero in the dyed Plain Cloak), Buy / Equip.
func _make_dye_tile(index: int) -> Control:
	var key: String = dye_id(index)
	var tile: PanelContainer = UIKit.panel()
	tile.name = "Tile_%s" % key
	tile.custom_minimum_size = Vector2(340 if stage == null else 282, 150)
	var column: VBoxContainer = UIKit.vbox(4)
	tile.add_child(column)
	var head: HBoxContainer = UIKit.hbox(8)
	column.add_child(head)
	var swatch: Panel = Panel.new()
	swatch.name = "Swatch_%s" % key
	swatch.custom_minimum_size = Vector2(52, 52)
	swatch.add_theme_stylebox_override("panel", UIStyle.box(Dye.primary(index), Dye.secondary(index), 3, 12))
	swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(swatch)
	head.add_child(UIKit.label("%s Dye" % Dye.dye_name(index), &"HeadingLabel", 24, UIStyle.GOLD))
	column.add_child(UIKit.label("Cloak dye", &"MutedLabel", 18))
	var blurb: Label = UIKit.label("Colours the %s %s. The named cloaks keep their own colours." % [PLAIN_CLOAK, Dye.dye_name(index).to_lower()], &"", 17, UIStyle.PARCHMENT)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(300 if stage == null else 244, 46)
	column.add_child(blurb)
	column.add_child(UIKit.filler())
	var buttons: HBoxContainer = UIKit.hbox(8)
	column.add_child(buttons)
	var price: Label = UIKit.label("", &"", 24, UIStyle.GOLD)
	price.add_theme_font_override("font", UIStyle.font_title())
	price.custom_minimum_size = Vector2(80, 0)
	buttons.add_child(price)
	var preview_button: FancyButton = FancyButton.make("Preview", &"", Vector2(110, 44))
	preview_button.name = "Preview_%s" % key
	preview_button.pressed.connect(func() -> void: preview_dye(index))
	buttons.add_child(preview_button)
	var buy: FancyButton = FancyButton.make("Buy", &"PrimaryButton", Vector2(120, 44))
	buy.name = "Buy_%s" % key
	buy.pressed.connect(func() -> void: _buy_or_wear_dye(index))
	buttons.add_child(buy)
	tile.mouse_entered.connect(func() -> void: preview_dye(index, false))
	_tiles[key] = {"price": price, "buy": buy, "preview": preview_button, "dye": index}
	return tile


func _make_tile(item: CosmeticData, open: bool) -> Control:
	var tile: PanelContainer = UIKit.panel()
	tile.name = "Tile_%s" % item.id
	tile.custom_minimum_size = Vector2(340 if stage == null else 282, 150)
	var column: VBoxContainer = UIKit.vbox(4)
	tile.add_child(column)
	var head: HBoxContainer = UIKit.hbox(8)
	column.add_child(head)
	# Oct 19 night (Part 3): the shop icon ICON-COS-<art name> once imported, else the old sprite-library picture.
	var icon: Texture2D = _icon_of(item, 52.0) if open else null
	if icon != null:
		var picture: TextureRect = TextureRect.new()
		picture.name = "Icon_%s" % item.id
		picture.texture = icon
		picture.custom_minimum_size = Vector2(52, 52)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		head.add_child(picture)
	var title: Label = UIKit.label(item.display_name if open else "???", &"HeadingLabel", 24, UIStyle.GOLD if open else UIStyle.MUTED)
	head.add_child(title)
	var kind: Label = UIKit.label("%s%s" % [item.slot_name(), "" if open else "   (%s)" % CosmeticCatalog.unlock_hint(item)], &"MutedLabel", 18)
	column.add_child(kind)
	var ready_art: bool = SpriteCosmetics.art_ready(item)
	var blurb: Label = UIKit.label(("%s%s" % [item.description, "" if ready_art else "  (Arriving soon: the art is still being painted.)"]) if open else StoryText.shared().text("tailor.locked"), &"", 17, UIStyle.PARCHMENT if open else UIStyle.MUTED)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(300 if stage == null else 244, 46)
	column.add_child(blurb)
	column.add_child(UIKit.filler())
	if not open:
		tile.modulate = Color(0.7, 0.7, 0.78)
		return tile
	var buttons: HBoxContainer = UIKit.hbox(8)
	column.add_child(buttons)
	var price: Label = UIKit.label("", &"", 24, UIStyle.GOLD)
	price.add_theme_font_override("font", UIStyle.font_title())
	price.custom_minimum_size = Vector2(80, 0)
	buttons.add_child(price)
	var preview_button: FancyButton = FancyButton.make("Preview", &"", Vector2(110, 44))
	preview_button.name = "Preview_%s" % item.id
	preview_button.pressed.connect(func() -> void: _preview(item))
	buttons.add_child(preview_button)
	var buy: FancyButton = FancyButton.make("Buy", &"PrimaryButton", Vector2(120, 44))
	buy.name = "Buy_%s" % item.id
	buy.pressed.connect(func() -> void: _buy_or_equip(item))
	buttons.add_child(buy)
	tile.mouse_entered.connect(func() -> void: _preview(item, false))
	_tiles[item.id] = {"price": price, "buy": buy, "preview": preview_button}
	return tile


## The item's own picture: its shop icon, else the hat's front image / the sprite library's item picture.
static func _icon_of(item: CosmeticData, px: float) -> Texture2D:
	var icon: Texture2D = IconArt.cosmetic_texture(item, px)
	if icon == null:
		icon = SpriteLibrary.item_icon(item.slot == CosmeticData.Slot.HAT, item.art_name)
	return icon


## Nov 2 pass, Part 5 (screenshot runs: --open=tailor --try=hat_wizard): shows an item in the preview by id.
func try_item(item_id: String) -> void:
	if item_id.begins_with("dye_"):
		show_tab(TAB_CLOAKS)
		preview_dye(int(item_id.trim_prefix("dye_")), false)
		return
	var item: CosmeticData = CosmeticCatalog.find(item_id)
	if item != null:
		show_tab(TAB_HATS if item.slot == CosmeticData.Slot.HAT else TAB_CLOAKS)
		_preview(item, false)


## Shows `item` alone, large, on the preview panel (nothing is worn or owned by previewing).
func _preview(item: CosmeticData, sound: bool = true) -> void:
	_selected = item
	_selected_dye = Dye.NATURAL
	_show_hero(false)
	_preview_icon.texture = _icon_of(item, PREVIEW_SIZE)
	_preview_name.text = item.display_name
	_preview_kind.text = item.slot_name()
	if sound:
		Audio.sfx(&"ui_tick")
	_refresh()


## Fix pass Nov 4 (Part 3.3): a dye's preview - the hero in the Plain Cloak in that colour (wearing their hat), turning on the plinth.
func preview_dye(index: int, sound: bool = true) -> void:
	_selected = null
	_selected_dye = index
	_show_hero(true)
	var look: CosmeticState = Session.cosmetics.duplicate_state()
	look.cloak_id = ""
	look.set_dye(CosmeticData.Slot.CLOAK, index)
	_hero.set_look(look)
	_preview_name.text = "%s Dye" % Dye.dye_name(index)
	_preview_kind.text = "On the %s" % PLAIN_CLOAK
	if sound:
		Audio.sfx(&"ui_tick")
	_refresh()


func previewed_dye() -> int:
	return _selected_dye


func _show_hero(on: bool) -> void:
	if on and _hero == null:
		_hero = HeroPreview.new()
		_hero.name = "DyePreview"
		_hero.custom_minimum_size = Vector2(PREVIEW_SIZE, PREVIEW_SIZE * 1.19)
		_preview_holder.add_child(_hero)
	if _hero != null:
		_hero.visible = on
	_preview_icon.visible = not on


func previewed() -> CosmeticData:
	return _selected


func _buy_or_equip(item: CosmeticData) -> void:
	if Session.cosmetics.owns(item.id):
		_equip(item)
		return
	_buy(item)


func _buy(item: CosmeticData) -> void:
	var story: StoryText = StoryText.shared()
	if Session.gold < item.price:
		_say(story.get_lines("tailor.poor"))
		Audio.sfx(&"ui_error")
		return
	if not Session.buy_cosmetic(item.id):
		_say(story.get_lines("tailor.locked"))
		return
	_wear(item.slot, item.id)
	Audio.sting(&"STG-PURCHASE")
	_say(story.get_lines("tailor.bought"))
	if stage != null:
		stage.flourish("buy")
	_preview(item, false)


## Puts on an owned item (the world and the Wardrobe show it at once).
func _equip(item: CosmeticData) -> void:
	if Session.cosmetics.equipped_id(item.slot) == item.id:
		return
	_wear(item.slot, item.id)
	Audio.sfx(&"tool_equip")
	_say(StoryText.shared().get_lines("tailor.equipped" if item.slot == CosmeticData.Slot.HAT else "tailor.cloak_on"))
	_refresh()


func _equip_none(slot: CosmeticData.Slot) -> void:
	if slot == CosmeticData.Slot.CLOAK:
		if plain_cloak_worn():
			return
		var plain: CosmeticState = Session.cosmetics.duplicate_state()
		plain.cloak_id = ""
		plain.set_dye(CosmeticData.Slot.CLOAK, Dye.NATURAL)
		Session.apply_look(plain)
		Audio.sfx(&"tool_equip")
		_say(StoryText.shared().get_lines("tailor.plain_cloak"))
		_refresh()
		return
	if Session.cosmetics.equipped_id(slot) == "":
		return
	_wear(slot, "")
	Audio.sfx(&"tool_unequip")
	_say(StoryText.shared().get_lines("tailor.bare_head"))
	_refresh()


## The Plain Cloak, undyed, is what the hero wears.
static func plain_cloak_worn() -> bool:
	return Session.cosmetics.cloak_id == "" and Session.cosmetics.cloak_dye == Dye.NATURAL


## A dye is "worn" while the Plain Cloak is on in that colour.
static func dye_worn(index: int) -> bool:
	return Session.cosmetics.cloak_id == "" and Session.cosmetics.cloak_dye == index


func _buy_or_wear_dye(index: int) -> void:
	var story: StoryText = StoryText.shared()
	if not Session.cosmetics.owns_dye(index):
		if Session.gold < Dye.PRICE:
			_say(story.get_lines("tailor.poor"))
			Audio.sfx(&"ui_error")
			return
		if not Session.buy_dye(index):
			return
		Audio.sting(&"STG-PURCHASE")
		if stage != null:
			stage.flourish("buy")
	elif dye_worn(index):
		return
	else:
		Audio.sfx(&"tool_equip")
	var dyed: CosmeticState = Session.cosmetics.duplicate_state()
	dyed.cloak_id = ""
	dyed.set_dye(CosmeticData.Slot.CLOAK, index)
	Session.apply_look(dyed)
	_say(story.get_lines("tailor.dyed"))
	preview_dye(index, false)


func _wear(slot: CosmeticData.Slot, item_id: String) -> void:
	var worn: CosmeticState = Session.cosmetics.duplicate_state()
	if slot == CosmeticData.Slot.HAT:
		worn.hat_id = item_id
	else:
		worn.cloak_id = item_id
	Session.apply_look(worn)


func _say(lines: Array[String]) -> void:
	if lines.is_empty():
		return
	var line: String = lines[randi() % lines.size()]
	if stage != null:
		stage.say_text(line)
		stage.nod(0.7)
	else:
		_quip.text = line


func _refresh() -> void:
	_gold_label.text = str(Session.gold)
	for item_id: String in _tiles:
		var entry: Dictionary = _tiles[item_id] as Dictionary
		var buy: FancyButton = entry["buy"] as FancyButton
		if entry.has("slot"):
			var bare: bool = Session.cosmetics.equipped_id(entry["slot"] as CosmeticData.Slot) == "" if entry["slot"] == CosmeticData.Slot.HAT else plain_cloak_worn()
			buy.text = "Equipped" if bare else "Equip"
			buy.disabled = bare
			continue
		if entry.has("dye"):
			var index: int = int(entry["dye"])
			var has_dye: bool = Session.cosmetics.owns_dye(index)
			var on: bool = has_dye and dye_worn(index)
			(entry["price"] as Label).text = "Owned" if has_dye else "%dg" % Dye.PRICE
			buy.text = "Equipped" if on else ("Equip" if has_dye else "Buy")
			buy.disabled = on
			continue
		var item: CosmeticData = CosmeticCatalog.find(item_id)
		var owned: bool = Session.cosmetics.owns(item_id)
		var worn: bool = owned and Session.cosmetics.equipped_id(item.slot) == item_id
		var ready: bool = SpriteCosmetics.art_ready(item)
		(entry["price"] as Label).text = "Owned" if owned else ("%dg" % item.price if ready else "Soon")
		buy.text = "Equipped" if worn else ("Equip" if owned else ("Buy" if ready else "Soon"))
		buy.disabled = worn or not ready
		(entry["preview"] as FancyButton).disabled = not ready
	if _selected != null:
		_selected_label.text = "Preview: %s (%s)" % [_selected.display_name, "owned" if Session.cosmetics.owns(_selected.id) else "%d gold" % _selected.price]
	elif _selected_dye != Dye.NATURAL and _selected_label != null:
		_selected_label.text = "Preview: %s Dye on the %s (%s)" % [Dye.dye_name(_selected_dye), PLAIN_CLOAK, "owned" if Session.cosmetics.owns_dye(_selected_dye) else "%d gold" % Dye.PRICE]
