class_name CharacterScreen
extends OverlayScreen
## Part E: level, XP bar, stats, item slots and equipment slots (locked ones shown as locked).
## Reachable with the C hotkey or the HUD button in town, or right after leveling up.
## New brief (third), Part C: equipment is shown as 5 square slots placed over a humanoid
## silhouette (helm/head, armor/chest, weapon/one hand, relic/other hand-hip, boots/feet) instead
## of a plain list - see `_build_equipment_panel`/`_refresh_equipment`.

const EQUIP_SLOT_SIZE: Vector2 = Vector2(76, 76)
const EQUIP_STAGE_SIZE: Vector2 = Vector2(360, 480)
## Position of each slot's top-left corner on the stage (EQUIP_STAGE_SIZE), placed to read as
## "worn" on the silhouette: helm at the head, armor over the chest, weapon in one hand, relic at
## the other hand/hip, boots at the feet.
const EQUIP_SLOT_POSITIONS: Dictionary = {
	EquipmentData.Slot.HELM: Vector2(142, 22),
	EquipmentData.Slot.WEAPON: Vector2(19, 237),
	EquipmentData.Slot.ARMOR: Vector2(142, 152),
	EquipmentData.Slot.RELIC: Vector2(264, 222),
	EquipmentData.Slot.BOOTS: Vector2(142, 377),
}

var _xp_bar: ProgressBar
var _xp_label: Label
var _stats_box: VBoxContainer
var _equipment_stage: Control
var _equipment_slot_buttons: Dictionary = {}
var _items_box: VBoxContainer
var _items_note: Label
var _toast: Label
var _picker: Control


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
	panel.custom_minimum_size = Vector2(420, 0)
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	column.add_child(UIKit.label("Equipment", &"HeadingLabel", 28))
	var center: CenterContainer = CenterContainer.new()
	column.add_child(center)
	_equipment_stage = Control.new()
	_equipment_stage.custom_minimum_size = EQUIP_STAGE_SIZE
	_equipment_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	center.add_child(_equipment_stage)
	_equipment_stage.add_child(_build_silhouette())
	for slot: EquipmentData.Slot in SLOT_ORDER:
		var button: Button = _make_equipment_slot_button(slot)
		button.position = EQUIP_SLOT_POSITIONS[slot] as Vector2
		_equipment_stage.add_child(button)
		_equipment_slot_buttons[slot] = button
	return panel


## A plain, procedural humanoid outline (head/torso/arms/legs as soft rounded-rect panels) for the
## equipment slots to sit over - built from shapes, not a found icon, so it can span the whole
## stage and line up exactly with the slot positions below it (no game-icons "character"/"person"
## silhouette actually reaches head-to-foot - they're bust icons).
func _build_silhouette() -> Control:
	var root: Control = Control.new()
	root.size = EQUIP_STAGE_SIZE
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tint: Color = Color(0.62, 0.56, 0.72, 0.16)
	_add_body_part(root, Rect2(145, 25, 70, 70), 35, tint) # head
	_add_body_part(root, Rect2(110, 95, 140, 190), 30, tint) # torso
	_add_body_part(root, Rect2(40, 115, 35, 180), 16, tint) # left arm
	_add_body_part(root, Rect2(285, 115, 35, 160), 16, tint) # right arm
	_add_body_part(root, Rect2(138, 270, 38, 165), 14, tint) # left leg
	_add_body_part(root, Rect2(184, 270, 38, 165), 14, tint) # right leg
	return root


func _add_body_part(root: Control, rect: Rect2, radius: int, tint: Color) -> void:
	var part: Panel = Panel.new()
	part.position = rect.position
	part.size = rect.size
	part.mouse_filter = Control.MOUSE_FILTER_IGNORE
	part.add_theme_stylebox_override("panel", UIStyle.box(tint, Color(0, 0, 0, 0), 0, radius))
	root.add_child(part)


func _make_equipment_slot_button(slot: EquipmentData.Slot) -> Button:
	var button: Button = Button.new()
	button.custom_minimum_size = EQUIP_SLOT_SIZE
	button.size = EQUIP_SLOT_SIZE
	# Not flat: a flat Button only draws its stylebox on hover/press/disabled, but this slot's
	# frame (locked/empty/equipped) must stay visible all the time.
	button.focus_mode = Control.FOCUS_NONE
	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = EQUIP_SLOT_SIZE * 0.62
	icon.size = EQUIP_SLOT_SIZE * 0.62
	icon.position = EQUIP_SLOT_SIZE * 0.19
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)
	var caption: Label = UIKit.label(EquipmentData.slot_name(slot), &"", 13, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	caption.position = Vector2(0, EQUIP_SLOT_SIZE.y + 2)
	caption.size = Vector2(EQUIP_SLOT_SIZE.x, 18)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(caption)
	button.mouse_entered.connect(func() -> void: Audio.sfx(&"ui_hover", -10.0))
	button.pressed.connect(func() -> void: _on_equipment_slot_pressed(slot))
	return button


func _build_items_panel() -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(420, 0)
	var column: VBoxContainer = UIKit.vbox(8)
	panel.add_child(column)
	column.add_child(UIKit.label("Items", &"HeadingLabel", 28))
	# New brief, Part F: equip up to your item-slot limit to carry items into a fight (the item
	# bar, usable on your turn); the "Use" button below still works between fights/on the map.
	_items_note = UIKit.label("", &"MutedLabel", 18)
	_items_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_items_note.custom_minimum_size = Vector2(360, 0)
	column.add_child(_items_note)
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
	_stat_row("Deck copy limit", "%d per card (infrastructure unlimited)" % DeckValidator.MAX_COPIES)
	_stat_row("Max hand size", str(profile.base_max_hand_size()))
	_stat_row("Path essence", _essence_text(profile))
	_refresh_equipment()
	_refresh_items()


## Part F: essence by Path ("Beefcake 12, Gourmand 0, ..."), the currency of the Alchemist.
func _essence_text(profile: PlayerProfile) -> String:
	var parts: PackedStringArray = []
	for path: Affinity.Type in Affinity.colored_types():
		parts.append("%s %d" % [UIStyle.affinity_name(path), profile.essence_of(path)])
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
	var profile: PlayerProfile = Session.profile
	for slot: EquipmentData.Slot in SLOT_ORDER:
		var button: Button = _equipment_slot_buttons[slot] as Button
		var icon: TextureRect = button.get_child(0) as TextureRect
		if not profile.has_equipment_slot(slot):
			icon.texture = CardIcons.ui("lock")
			icon.modulate = Color(0.55, 0.55, 0.62, 0.85)
			var locked_style: StyleBoxFlat = UIStyle.box(Color(0.06, 0.05, 0.09, 0.85), Color(0.35, 0.33, 0.4, 0.7), 2, 10)
			button.add_theme_stylebox_override("normal", locked_style)
			button.add_theme_stylebox_override("hover", locked_style)
			button.add_theme_stylebox_override("pressed", locked_style)
			button.add_theme_stylebox_override("disabled", locked_style)
			button.disabled = true
			button.tooltip_text = "Locked - %s" % _equipment_unlock_hint()
			continue
		button.disabled = false
		var equipped: EquipmentData = profile.equipped_in(slot)
		if equipped == null:
			icon.texture = null
			var empty_hover: StyleBoxFlat = UIStyle.box(Color(0.14, 0.11, 0.2, 0.9), UIStyle.GOLD, 3, 10)
			button.add_theme_stylebox_override("normal", UIStyle.box(Color(0.1, 0.08, 0.16, 0.85), UIStyle.GOLD_DIM, 2, 10))
			button.add_theme_stylebox_override("hover", empty_hover)
			button.add_theme_stylebox_override("pressed", empty_hover)
			button.tooltip_text = "Empty %s slot - click to equip." % EquipmentData.slot_name(slot)
		else:
			icon.texture = CardIcons.for_equipment(equipped)
			icon.modulate = Color(1, 1, 1, 1)
			var equipped_hover: StyleBoxFlat = UIStyle.box(Color(0.2, 0.16, 0.1, 0.95), UIStyle.GOLD, 3, 10, 10)
			button.add_theme_stylebox_override("normal", UIStyle.box(Color(0.16, 0.13, 0.08, 0.92), UIStyle.GOLD, 3, 10, 8))
			button.add_theme_stylebox_override("hover", equipped_hover)
			button.add_theme_stylebox_override("pressed", equipped_hover)
			button.tooltip_text = equipped.tooltip_text()


## Equipment slots unlock one at a time, player's choice, at these levels (ProgressionTable) - no
## single slot has a fixed unlock level, so the locked tooltip states the whole rule instead.
func _equipment_unlock_hint() -> String:
	var levels: PackedStringArray = []
	for level: int in ProgressionTable.EQUIPMENT_CHOICE_LEVELS:
		levels.append(str(level))
	return "equipment slots unlock at levels %s (you choose which slot each time)." % ", ".join(levels)


func _on_equipment_slot_pressed(slot: EquipmentData.Slot) -> void:
	Audio.sfx(&"ui_select")
	_open_equipment_picker(slot)


## New brief (third), Part C: clicking an unlocked slot lets the player pick from owned equipment
## for that slot (or unequip whatever is there) - a small popup over the character screen.
func _open_equipment_picker(slot: EquipmentData.Slot) -> void:
	_close_picker()
	var profile: PlayerProfile = Session.profile
	var overlay: Control = Control.new()
	UIKit.full_rect(overlay)
	add_child(overlay)
	_picker = overlay
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.06, 0.8)
	UIKit.full_rect(shade)
	overlay.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	overlay.add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(480, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label("Choose %s" % EquipmentData.slot_name(slot), &"HeadingLabel", 26, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var equipped: EquipmentData = profile.equipped_in(slot)
	var pieces: Array[EquipmentData] = []
	for piece: EquipmentData in profile.owned_equipment:
		if piece.slot == slot:
			pieces.append(piece)
	if pieces.is_empty():
		column.add_child(UIKit.label("You don't own any %s yet." % EquipmentData.slot_name(slot).to_lower(), &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	for piece: EquipmentData in pieces:
		var is_equipped: bool = piece == equipped
		var row: HBoxContainer = UIKit.hbox(10)
		row.add_child(CardIcons.glyph(CardIcons.for_equipment(piece), UIStyle.GOLD if is_equipped else UIStyle.PARCHMENT, Vector2(40, 40)))
		var info: Label = UIKit.label("%s%s\n%s" % [piece.source_name, " [equipped]" if is_equipped else "", piece.description], &"", 16, UIStyle.GOOD if is_equipped else UIStyle.PARCHMENT)
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		if not is_equipped:
			row.add_child(_small_button("Equip", func() -> void: _equip_from_picker(piece)))
		column.add_child(row)
	if equipped != null:
		var unequip_button: FancyButton = FancyButton.make("Unequip", &"", Vector2(160, 48))
		unequip_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		unequip_button.pressed.connect(func() -> void: _unequip_from_picker(slot))
		column.add_child(unequip_button)
	var cancel: FancyButton = FancyButton.make("Cancel", &"", Vector2(160, 48))
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cancel.pressed.connect(_close_picker)
	column.add_child(cancel)
	UIKit.pop_in(panel)


func _equip_from_picker(piece: EquipmentData) -> void:
	_equip(piece)
	_close_picker()


func _unequip_from_picker(slot: EquipmentData.Slot) -> void:
	_unequip(slot)
	_close_picker()


func _close_picker() -> void:
	if _picker != null:
		_picker.queue_free()
		_picker = null


## The equipment picker closes on Esc instead of the whole character screen, when it's open.
func _unhandled_input(event: InputEvent) -> void:
	if _picker != null and event.is_action_pressed(&"ui_cancel") and is_visible_in_tree():
		get_viewport().set_input_as_handled()
		Audio.sfx(&"ui_back", -4.0)
		_close_picker()
		return
	super._unhandled_input(event)


func _refresh_items() -> void:
	for child: Node in _items_box.get_children():
		child.queue_free()
	var profile: PlayerProfile = Session.profile
	_items_note.text = "Equipped %d / %d. Equipped items are usable on your turn in battle; \"Use\" also works between fights/on the map." % [profile.equipped_item_ids.size(), profile.item_slots]
	if profile.owned_items.is_empty():
		_items_box.add_child(UIKit.label("No items yet - Wick's Supplies in town sells some.", &"MutedLabel", 18))
		return
	for owned_item: ItemData in profile.owned_items:
		var row: HBoxContainer = UIKit.hbox(8)
		var equipped: bool = profile.is_item_equipped(owned_item)
		var name_label: Label = UIKit.label("%s (%d left)%s" % [owned_item.display_name, profile.item_uses_left(owned_item), " [equipped]" if equipped else ""], &"", 18, UIStyle.GOOD if equipped else UIStyle.PARCHMENT)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.mouse_filter = Control.MOUSE_FILTER_STOP
		# New brief, Part B: same tooltip text as the battle item bar and the item vendor.
		name_label.tooltip_text = owned_item.tooltip_text()
		row.add_child(name_label)
		var equip_button: FancyButton = _small_button("Unequip" if equipped else "Equip", func() -> void: _toggle_equip(owned_item))
		equip_button.disabled = not equipped and profile.equipped_item_ids.size() >= profile.item_slots
		row.add_child(equip_button)
		var usable: bool = Session.life_run() != null and ItemUseResolver.can_apply(owned_item)
		var use_button: FancyButton = _small_button("Use", func() -> void: _use(owned_item))
		use_button.disabled = not usable
		row.add_child(use_button)
		_items_box.add_child(row)


func _toggle_equip(owned_item: ItemData) -> void:
	var profile: PlayerProfile = Session.profile
	if profile.is_item_equipped(owned_item):
		profile.unequip_item_id(owned_item)
		Audio.sfx(&"ui_tick")
	elif profile.equip_item_id(owned_item):
		Audio.sfx(&"ui_confirm")
	else:
		_say("All %d item slots are full." % profile.item_slots, Color("ff8a85"))
		return
	Session.save_game()
	_refresh()


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
