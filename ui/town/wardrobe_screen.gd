class_name WardrobeScreen
extends OverlayScreen
## The wardrobe (hotkey T, HUD button): a turning preview of the painted hero, the owned hats and cloaks, and the cloak dye row. Purely cosmetic; every change is applied
## and saved at once. The hero starts in the default look (the dark teal hooded cloak, no hat): there is no look to choose at the start of a game any more.

var _look: CosmeticState
var _preview: HeroPreview
var _item_buttons: Dictionary = {}
var _dye_buttons: Dictionary = {}
var _description: Label
var _status: Label


func _init() -> void:
	screen_title = "Wardrobe"
	title_icon_id = "ICON-UI-WARDROBE"
	close_text = "Close (Esc)"


func _build() -> void:
	_look = Session.cosmetics.duplicate_state()
	var row: HBoxContainer = UIKit.hbox(30)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(row)
	var preview_panel: PanelContainer = UIKit.panel()
	row.add_child(preview_panel)
	_preview = HeroPreview.new()
	_preview.look = _look
	preview_panel.add_child(_preview)
	var options: VBoxContainer = UIKit.vbox(10)
	options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(options)
	_add_section(options, CosmeticData.Slot.HAT, "Hat")
	_add_section(options, CosmeticData.Slot.CLOAK, "Cloak")
	_add_dyes(options)
	_description = UIKit.label("", &"", 24, UIStyle.PARCHMENT)
	_description.add_theme_font_override("font", UIStyle.font_italic())
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description.custom_minimum_size = Vector2(1000, 64)
	options.add_child(_description)
	_status = UIKit.label("", &"MutedLabel", 20)
	options.add_child(_status)
	options.add_child(UIKit.filler())
	_refresh()


func _add_section(parent: VBoxContainer, slot: CosmeticData.Slot, title: String) -> void:
	parent.add_child(UIKit.label(title, &"HeadingLabel", 30))
	var flow: HFlowContainer = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 10)
	flow.add_theme_constant_override("v_separation", 8)
	parent.add_child(flow)
	var key: String = "hat" if slot == CosmeticData.Slot.HAT else "cloak"
	var none: FancyButton = FancyButton.make("None" if slot == CosmeticData.Slot.HAT else "Plain teal cloak", &"", Vector2(120 if slot == CosmeticData.Slot.HAT else 230, 46))
	none.name = "%s_none" % title
	none.pressed.connect(func() -> void: _equip(slot, ""))
	flow.add_child(none)
	_item_buttons["%s|" % key] = none
	var owned_count: int = 0
	for item: CosmeticData in CosmeticCatalog.in_slot(slot):
		if not _look.owns(item.id):
			continue
		owned_count += 1
		var ready: bool = SpriteCosmetics.art_ready(item)
		var button: FancyButton = FancyButton.make(item.display_name if ready else "%s (arriving soon)" % item.display_name, &"", Vector2(210 if ready else 300, 46))
		button.name = "%s_%s" % [title, item.id]
		# Oct 19 night (Part 3): the shop icon ICON-COS-<art name> once imported, else the old sprite-library picture.
		var icon: Texture2D = IconArt.cosmetic_texture(item, 58.0)
		if icon == null and ready:
			icon = SpriteLibrary.item_icon(slot == CosmeticData.Slot.HAT, item.art_name)
		if icon != null:
			button.icon = icon
			button.expand_icon = true
			button.custom_minimum_size = Vector2(250, 58)
		button.disabled = not ready
		button.pressed.connect(func() -> void: _equip(slot, item.id))
		button.mouse_entered.connect(func() -> void: _description.text = "%s: %s" % [item.display_name, item.description])
		flow.add_child(button)
		_item_buttons["%s|%s" % [key, item.id]] = button
	if owned_count == 0:
		flow.add_child(UIKit.label("Nothing yet: Pip Threadwell sells them in town.", &"MutedLabel", 20))
	parent.add_child(HSeparator.new())


func _add_dyes(parent: VBoxContainer) -> void:
	var dyes: HBoxContainer = UIKit.hbox(8)
	parent.add_child(dyes)
	dyes.add_child(UIKit.label("Cloak dye", &"MutedLabel", 22))
	for index: int in range(Dye.NATURAL, Dye.count()):
		var swatch: Button = Button.new()
		swatch.name = "Dye_cloak_%d" % index
		swatch.custom_minimum_size = Vector2(46, 46)
		swatch.tooltip_text = Dye.dye_name(index)
		swatch.focus_mode = Control.FOCUS_NONE
		if index == Dye.NATURAL:
			swatch.text = "A"
		swatch.pressed.connect(func() -> void: _dye(index))
		dyes.add_child(swatch)
		_dye_buttons[index] = swatch
	parent.add_child(HSeparator.new())


func _equip(slot: CosmeticData.Slot, item_id: String) -> void:
	_look.equip(slot, item_id)
	_apply()


func _dye(index: int) -> void:
	_look.set_dye(CosmeticData.Slot.CLOAK, index)
	_apply()


func _apply() -> void:
	_preview.set_look(_look)
	Session.apply_look(_look)
	Audio.sfx(&"ui_tick")
	_refresh()


func _refresh() -> void:
	for key: String in _item_buttons:
		var parts: PackedStringArray = key.split("|")
		var slot: CosmeticData.Slot = CosmeticData.Slot.HAT if parts[0] == "hat" else CosmeticData.Slot.CLOAK
		var button: FancyButton = _item_buttons[key] as FancyButton
		var selected: bool = _look.equipped_id(slot) == parts[1]
		button.theme_type_variation = &"PrimaryButton" if selected else &""
	for index: Variant in _dye_buttons:
		var swatch: Button = _dye_buttons[index] as Button
		var selected_dye: bool = _look.cloak_dye == int(index)
		for state: String in ["normal", "hover", "pressed", "focus"]:
			var box: StyleBoxFlat = StyleBoxFlat.new()
			box.bg_color = Dye.primary(int(index)) if int(index) >= 0 else Color("3a3550")
			box.set_corner_radius_all(10)
			box.set_border_width_all(4 if selected_dye else 2)
			box.border_color = UIStyle.GOLD if selected_dye else Color(0, 0, 0, 0.55)
			swatch.add_theme_stylebox_override(state, box)
	var hat: CosmeticData = CosmeticCatalog.find(_look.hat_id)
	var cloak: CosmeticData = CosmeticCatalog.find(_look.cloak_id)
	_status.text = "Hat: %s    Cloak: %s (%s)" % [hat.display_name if hat != null else "none", cloak.display_name if cloak != null else "dark teal hooded cloak", Dye.dye_name(_look.cloak_dye)]
