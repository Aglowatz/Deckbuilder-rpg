class_name CharacterScreen
extends OverlayScreen
## Part E: level, XP bar, stats, item slots and equipment slots (locked ones shown as locked).
## Reachable with the C hotkey or the HUD button in town, or right after leveling up.

var _xp_bar: ProgressBar
var _xp_label: Label
var _stats_box: VBoxContainer
var _equipment_box: VBoxContainer
var _items_box: VBoxContainer
var _toast: Label


func _init() -> void:
	screen_title = "Character"
	close_text = "Close (Esc)"


func _build() -> void:
	var split: HBoxContainer = UIKit.hbox(24)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	split.add_child(_build_stats_panel())
	split.add_child(_build_equipment_panel())
	split.add_child(_build_items_panel())
	_toast = UIKit.label("", &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_toast.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.position = Vector2(400, 990)
	_toast.size = Vector2(1100, 40)
	_toast.modulate.a = 0.0
	add_child(_toast)
	_refresh()


func _build_stats_panel() -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(420, 0)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label("Level", &"HeadingLabel", 28))
	_xp_label = UIKit.label("", &"", 22, UIStyle.PARCHMENT)
	column.add_child(_xp_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(0, 18)
	_xp_bar.show_percentage = false
	column.add_child(_xp_bar)
	column.add_child(UIKit.spacer(6))
	_stats_box = UIKit.vbox(6)
	column.add_child(_stats_box)
	return panel


func _build_equipment_panel() -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(560, 0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	column.add_child(UIKit.label("Equipment", &"HeadingLabel", 28))
	_equipment_box = UIKit.vbox(6)
	column.add_child(_equipment_box)
	return panel


func _build_items_panel() -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(420, 0)
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	column.add_child(UIKit.label("Items", &"HeadingLabel", 28))
	var note: Label = UIKit.label("Items are used during a dungeon run.", &"MutedLabel", 18)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size = Vector2(360, 0)
	column.add_child(note)
	_items_box = UIKit.vbox(6)
	column.add_child(_items_box)
	return panel


# ---- Refresh --------------------------------------------------------------------------------


func _refresh() -> void:
	var profile: PlayerProfile = Session.profile
	var next_level: int = mini(profile.level + 1, ProgressionTable.MAX_LEVEL)
	var floor_xp: int = ProgressionTable.xp_to_reach(profile.level)
	var ceil_xp: int = ProgressionTable.xp_to_reach(next_level)
	_xp_label.text = "Level %d / %d" % [profile.level, ProgressionTable.MAX_LEVEL]
	if profile.level >= ProgressionTable.MAX_LEVEL:
		_xp_bar.value = 1.0
		_xp_bar.max_value = 1.0
		_xp_label.text += "  (max level)"
	else:
		_xp_bar.max_value = maxf(1.0, float(ceil_xp - floor_xp))
		_xp_bar.value = float(profile.xp - floor_xp)
		_xp_label.text += "  -  %d / %d XP to level %d" % [profile.xp - floor_xp, ceil_xp - floor_xp, next_level]
	for child: Node in _stats_box.get_children():
		child.queue_free()
	_stat_row("Starting life", str(profile.base_max_life()))
	_stat_row("Opening hand", str(profile.base_opening_hand()))
	_stat_row("Item slots", "%d / %d" % [profile.item_slots, ProgressionTable.row(ProgressionTable.MAX_LEVEL).item_slots])
	_stat_row("Deck copy limits", _copy_limits_text(profile))
	_refresh_equipment()
	_refresh_items()


func _copy_limits_text(profile: PlayerProfile) -> String:
	var parts: PackedStringArray = []
	for rarity: CardEnums.Rarity in [CardEnums.Rarity.COMMON, CardEnums.Rarity.UNCOMMON, CardEnums.Rarity.EPIC, CardEnums.Rarity.LEGENDARY]:
		parts.append("%s %d" % [CardEnums.Rarity.keys()[int(rarity)].capitalize(), profile.max_copies_for(rarity)])
	return ", ".join(parts)


func _stat_row(label: String, value: String) -> void:
	var row: HBoxContainer = UIKit.hbox(8)
	row.add_child(UIKit.label(label, &"MutedLabel", 20))
	row.add_child(UIKit.filler())
	row.add_child(UIKit.label(value, &"", 20, UIStyle.PARCHMENT))
	_stats_box.add_child(row)


const SLOT_ORDER: Array[EquipmentData.Slot] = [
	EquipmentData.Slot.HELM, EquipmentData.Slot.WEAPON, EquipmentData.Slot.ARMOR,
	EquipmentData.Slot.BOOTS, EquipmentData.Slot.RELIC,
]


func _refresh_equipment() -> void:
	for child: Node in _equipment_box.get_children():
		child.queue_free()
	var profile: PlayerProfile = Session.profile
	for slot: EquipmentData.Slot in SLOT_ORDER:
		var row: PanelContainer = PanelContainer.new()
		row.add_theme_stylebox_override("panel", UIStyle.box(Color(1, 1, 1, 0.05), Color(0, 0, 0, 0), 0, 8))
		var line: HBoxContainer = UIKit.hbox(10)
		row.add_child(line)
		var slot_label: Label = UIKit.label(EquipmentData.slot_name(slot), &"", 20, UIStyle.GOLD)
		slot_label.custom_minimum_size = Vector2(90, 0)
		line.add_child(slot_label)
		if not profile.has_equipment_slot(slot):
			line.add_child(UIKit.label("Locked", &"MutedLabel", 20))
			line.add_child(UIKit.filler())
		else:
			var equipped: EquipmentData = profile.equipped_in(slot)
			if equipped == null:
				line.add_child(UIKit.label("Empty", &"MutedLabel", 20))
				line.add_child(UIKit.filler())
				for candidate: EquipmentData in _owned_for_slot(slot):
					line.add_child(_small_button(candidate.source_name, func() -> void: _equip(candidate)))
			else:
				var info: Label = UIKit.label("%s - %s" % [equipped.source_name, equipped.description], &"", 18, UIStyle.PARCHMENT)
				info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				line.add_child(info)
				line.add_child(_small_button("Unequip", func() -> void: _unequip(slot)))
		_equipment_box.add_child(row)


func _owned_for_slot(slot: EquipmentData.Slot) -> Array[EquipmentData]:
	var result: Array[EquipmentData] = []
	for piece: EquipmentData in Session.profile.owned_equipment:
		if piece.slot == slot and Session.profile.equipped_in(slot) != piece:
			result.append(piece)
	return result


func _refresh_items() -> void:
	for child: Node in _items_box.get_children():
		child.queue_free()
	var profile: PlayerProfile = Session.profile
	if profile.owned_items.is_empty():
		_items_box.add_child(UIKit.label("No items yet.", &"MutedLabel", 18))
		return
	for owned_item: ItemData in profile.owned_items:
		var row: HBoxContainer = UIKit.hbox(8)
		var name_label: Label = UIKit.label("%s (%d left)" % [owned_item.display_name, profile.item_uses_left(owned_item)], &"", 18, UIStyle.PARCHMENT)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var usable: bool = Session.in_dungeon() and ItemUseResolver.can_apply(owned_item)
		var use_button: FancyButton = _small_button("Use", func() -> void: _use(owned_item))
		use_button.disabled = not usable
		row.add_child(use_button)
		_items_box.add_child(row)


func _small_button(text: String, callback: Callable) -> FancyButton:
	var button: FancyButton = FancyButton.make(text, &"GhostButton", Vector2(0, 34))
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(callback)
	return button


func _equip(piece: EquipmentData) -> void:
	if Session.equip_item(piece):
		Audio.sfx(&"ui_confirm")
		_refresh()


func _unequip(slot: EquipmentData.Slot) -> void:
	Session.unequip_slot(slot)
	Audio.sfx(&"ui_tick")
	_refresh()


func _use(owned_item: ItemData) -> void:
	if Session.use_item(owned_item):
		Audio.sfx(&"heal")
		_say("Used %s." % owned_item.display_name, UIStyle.GOOD)
		_refresh()
	else:
		_say("Cannot use that right now.", Color("ff8a85"))


func _say(text: String, color: Color) -> void:
	_toast.text = text
	_toast.add_theme_color_override("font_color", color)
	_toast.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.6)
	tween.tween_property(_toast, "modulate:a", 0.0, 0.4)
