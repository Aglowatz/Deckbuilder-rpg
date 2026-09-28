class_name EquipmentSlotChoiceScreen
extends Control
## Part E: levels 5/10/15/20/25 each unlock one equipment slot, chosen by the player. Only the
## slots not already unlocked are offered (by level 25 all 5 are unlocked regardless of order).

signal chosen(slot: EquipmentData.Slot)

var selected: int = -1
var _tiles: Dictionary = {}
var _confirm: FancyButton


func _ready() -> void:
	UIKit.full_rect(self)
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.06, 0.9)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(16)
	panel.add_child(column)
	column.add_child(UIKit.label("Choose an equipment slot", &"TitleLabel", 44, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	column.add_child(UIKit.label("This slot unlocks now; the rest follow at later levels.", &"", 20, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	for slot: EquipmentData.Slot in [EquipmentData.Slot.HELM, EquipmentData.Slot.WEAPON, EquipmentData.Slot.ARMOR, EquipmentData.Slot.BOOTS, EquipmentData.Slot.RELIC]:
		if Session.profile.has_equipment_slot(slot):
			continue
		row.add_child(_make_tile(slot))
	_confirm = FancyButton.make("Choose", &"PrimaryButton", Vector2(220, 56))
	_confirm.disabled = true
	_confirm.pressed.connect(func() -> void:
		if selected >= 0:
			chosen.emit(selected))
	column.add_child(_confirm)
	UIKit.pop_in(panel)


func _make_tile(slot: EquipmentData.Slot) -> Control:
	var tile: Button = Button.new()
	tile.custom_minimum_size = Vector2(180, 160)
	tile.focus_mode = Control.FOCUS_NONE
	tile.add_theme_stylebox_override("normal", UIStyle.box(Color(0.1, 0.08, 0.16, 0.9), UIStyle.GOLD_DIM, 3, 14, 6))
	tile.add_theme_stylebox_override("hover", UIStyle.box(Color(0.16, 0.12, 0.22, 0.9), UIStyle.GOLD, 4, 14, 12))
	tile.pressed.connect(func() -> void: _select(slot))
	tile.mouse_entered.connect(func() -> void: Audio.sfx(&"ui_hover", -8.0))
	var label: Label = UIKit.label(EquipmentData.slot_name(slot), &"HeadingLabel", 24, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(label)
	_tiles[int(slot)] = tile
	return tile


func _select(slot: EquipmentData.Slot) -> void:
	selected = slot
	Audio.sfx(&"ui_select")
	for key: Variant in _tiles.keys():
		var tile: Button = _tiles[key] as Button
		var is_selected: bool = int(key) == int(slot)
		tile.add_theme_stylebox_override("normal", UIStyle.box(Color(0.22, 0.16, 0.06, 0.9) if is_selected else Color(0.1, 0.08, 0.16, 0.9), UIStyle.PARCHMENT if is_selected else UIStyle.GOLD_DIM, 4 if is_selected else 3, 14, 12 if is_selected else 6))
	_confirm.disabled = false
