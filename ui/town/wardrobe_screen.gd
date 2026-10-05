class_name WardrobeScreen
extends OverlayScreen
## The wardrobe (hotkey T, HUD button) and the new-game "choose your look": a rotating preview of the hero, the owned hats and cloaks, and a dye row for each.
## Purely cosmetic. In WARDROBE mode every change is applied and saved at once; in STARTER mode only the starter items are offered and "Start my adventure" confirms.

enum Mode { WARDROBE, STARTER }

signal look_confirmed

var mode: Mode = Mode.WARDROBE

var _look: CosmeticState
var _preview: HeroPreview
var _item_buttons: Dictionary = {}
var _dye_buttons: Dictionary = {}
var _description: Label
var _status: Label


static func starter() -> WardrobeScreen:
	var screen: WardrobeScreen = WardrobeScreen.new()
	screen.mode = Mode.STARTER
	return screen


func _init() -> void:
	screen_title = "Wardrobe"
	close_text = "Close (Esc)"


func _build() -> void:
	if mode == Mode.STARTER:
		screen_title = "Choose your look"
		_look = CosmeticState.new()
		for slot: CosmeticData.Slot in [CosmeticData.Slot.HAT, CosmeticData.Slot.CLOAK]:
			for item: CosmeticData in CosmeticCatalog.starters(slot):
				_look.grant(item.id)
		_look.equip(CosmeticData.Slot.HAT, "hat_wide_brim")
		_look.equip(CosmeticData.Slot.CLOAK, "cloak_short")
	else:
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
	_description = UIKit.label("", &"", 24, UIStyle.PARCHMENT)
	_description.add_theme_font_override("font", UIStyle.font_italic())
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description.custom_minimum_size = Vector2(1000, 64)
	options.add_child(_description)
	_status = UIKit.label("", &"MutedLabel", 20)
	options.add_child(_status)
	options.add_child(UIKit.filler())
	if mode == Mode.STARTER:
		var confirm: FancyButton = FancyButton.make("Start my adventure", &"PrimaryButton", Vector2(340, 64))
		confirm.name = "Confirm"
		confirm.pressed.connect(_confirm)
		options.add_child(confirm)
		_close_button.visible = false
	_refresh()


func _add_section(parent: VBoxContainer, slot: CosmeticData.Slot, title: String) -> void:
	parent.add_child(UIKit.label(title, &"HeadingLabel", 30))
	var flow: HFlowContainer = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 10)
	flow.add_theme_constant_override("v_separation", 8)
	parent.add_child(flow)
	var key: String = "hat" if slot == CosmeticData.Slot.HAT else "cloak"
	var none: FancyButton = FancyButton.make("None", &"", Vector2(120, 46))
	none.name = "%s_none" % title
	none.pressed.connect(func() -> void: _equip(slot, ""))
	flow.add_child(none)
	_item_buttons["%s|" % key] = none
	for item: CosmeticData in CosmeticCatalog.in_slot(slot):
		if not _look.owns(item.id):
			continue
		var button: FancyButton = FancyButton.make(item.display_name, &"", Vector2(210, 46))
		button.name = "%s_%s" % [title, item.id]
		button.pressed.connect(func() -> void: _equip(slot, item.id))
		button.mouse_entered.connect(func() -> void: _description.text = "%s: %s" % [item.display_name, item.description])
		flow.add_child(button)
		_item_buttons["%s|%s" % [key, item.id]] = button
	var dyes: HBoxContainer = UIKit.hbox(8)
	parent.add_child(dyes)
	dyes.add_child(UIKit.label("Dye", &"MutedLabel", 22))
	for index: int in range(Dye.count()):
		var swatch: Button = Button.new()
		swatch.name = "Dye_%s_%d" % [key, index]
		swatch.custom_minimum_size = Vector2(46, 46)
		swatch.tooltip_text = Dye.dye_name(index)
		swatch.focus_mode = Control.FOCUS_NONE
		swatch.pressed.connect(func() -> void: _dye(slot, index))
		dyes.add_child(swatch)
		_dye_buttons["%s|%d" % [key, index]] = swatch
	parent.add_child(HSeparator.new())


func _equip(slot: CosmeticData.Slot, item_id: String) -> void:
	_look.equip(slot, item_id)
	_apply()


func _dye(slot: CosmeticData.Slot, index: int) -> void:
	_look.set_dye(slot, index)
	_apply()


func _apply() -> void:
	_preview.set_look(_look)
	if mode == Mode.WARDROBE:
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
	for key: String in _dye_buttons:
		var parts2: PackedStringArray = key.split("|")
		var slot2: CosmeticData.Slot = CosmeticData.Slot.HAT if parts2[0] == "hat" else CosmeticData.Slot.CLOAK
		var index: int = int(parts2[1])
		var button2: Button = _dye_buttons[key] as Button
		var selected2: bool = _look.dye_index(slot2) == index
		for state: String in ["normal", "hover", "pressed", "focus"]:
			var box: StyleBoxFlat = StyleBoxFlat.new()
			box.bg_color = Dye.primary(index)
			box.set_corner_radius_all(10)
			box.set_border_width_all(4 if selected2 else 2)
			box.border_color = UIStyle.GOLD if selected2 else Color(0, 0, 0, 0.55)
			button2.add_theme_stylebox_override(state, box)
	var hat: CosmeticData = CosmeticCatalog.find(_look.hat_id)
	var cloak: CosmeticData = CosmeticCatalog.find(_look.cloak_id)
	_status.text = "Hat: %s (%s)    Cloak: %s (%s)" % [
		hat.display_name if hat != null else "none", Dye.dye_name(_look.hat_dye),
		cloak.display_name if cloak != null else "none", Dye.dye_name(_look.cloak_dye)]
	if hat != null and _description.text == "":
		_description.text = "%s: %s" % [hat.display_name, hat.description]


func _confirm() -> void:
	Session.choose_starting_look(_look.hat_id, _look.cloak_id, _look.hat_dye, _look.cloak_dye)
	look_confirmed.emit()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if mode == Mode.STARTER:
		return  # the choice is part of starting the game: no Esc
	super._unhandled_input(event)
