class_name SaveSlotsScreen
extends Control
## Brief 16, Group E: the save slot list (Save or Load). Six rows - the autosave and five manual slots - each with a screenshot thumbnail, the save's name and date,
## playtime, player level, location and gold. Saving over a slot and deleting one ask for confirmation. Used by the pause menu (Save and Load) and the title screen (Load).

signal closed
## A slot was loaded (the campaign state is already replaced); the owner changes scene via `Session.resume_loaded_game()`.
signal loaded

enum Mode { SAVE, LOAD }

var mode: Mode = Mode.LOAD
## The screenshot shown/stored for a save (taken before the pause menu covered the game).
var snapshot: Image
var _list: VBoxContainer
var _status: Label
var _name_edits: Dictionary = {}


static func make(screen_mode: Mode, thumbnail: Image = null) -> SaveSlotsScreen:
	var screen: SaveSlotsScreen = SaveSlotsScreen.new()
	screen.mode = screen_mode
	screen.snapshot = thumbnail
	return screen


func _ready() -> void:
	name = "SaveSlotsScreen"
	UIKit.full_rect(self)
	z_index = 150
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.05, 0.85)
	UIKit.full_rect(dim)
	add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(1500, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(column)
	column.add_child(UIKit.label("Save Game" if mode == Mode.SAVE else "Load Game", &"HeadingLabel", 38, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	_list = UIKit.vbox(8)
	column.add_child(_list)
	_status = UIKit.label("", &"MutedLabel", 21, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_status)
	var back: FancyButton = FancyButton.make("Back", &"", Vector2(220, 52))
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(func() -> void: closed.emit())
	column.add_child(back)
	_rebuild()
	Audio.sfx(&"ui_open", -4.0)


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_ESCAPE and get_node_or_null("ConfirmDialog") == null:
		get_viewport().set_input_as_handled()
		closed.emit()


func _rebuild() -> void:
	for child: Node in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	_name_edits.clear()
	var order: Array[int] = [SaveSlots.AUTOSAVE]
	for slot: int in range(1, SaveSlots.SLOT_COUNT + 1):
		order.append(slot)
	for slot: int in order:
		_list.add_child(_row(slot))


func _row(slot: int) -> Control:
	var info: Dictionary = SaveSlots.info(slot)
	var row_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	row_panel.name = "Slot%d" % slot
	var row: HBoxContainer = UIKit.hbox(16)
	row_panel.add_child(row)
	var thumb: TextureRect = TextureRect.new()
	thumb.custom_minimum_size = Vector2(192, 108)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var texture: Texture2D = SaveSlots.thumbnail(slot) if not info.is_empty() else null
	if texture == null and mode == Mode.SAVE and slot > 0 and snapshot != null:
		texture = ImageTexture.create_from_image(snapshot)
	thumb.texture = texture
	thumb.modulate = Color(1, 1, 1, 1) if not info.is_empty() else Color(1, 1, 1, 0.4)
	row.add_child(thumb)
	var text: VBoxContainer = UIKit.vbox(4)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text)
	if info.is_empty():
		text.add_child(UIKit.label("%s - empty" % SaveSlots.slot_label(slot), &"", 28, UIStyle.MUTED))
		if mode == Mode.SAVE and slot > 0:
			text.add_child(_name_edit(slot, "Save %d" % slot))
	else:
		if mode == Mode.SAVE and slot > 0:
			text.add_child(_name_edit(slot, str(info["name"])))
		else:
			var heading: String = "%s - %s" % [SaveSlots.slot_label(slot), str(info["name"])] if slot > 0 else "Autosave"
			var title: Label = UIKit.label(heading, &"", 28, UIStyle.GOLD)
			title.add_theme_font_override("font", UIStyle.font_bold())
			text.add_child(title)
		var detail: String = "%s  |  Playtime %s  |  Level %d  |  %s  |  %d gold" % [SaveSlots.format_date(int(info["saved_at"])), SaveSlots.format_playtime(float(info["playtime"])), int(info["level"]), str(info["location"]), int(info["gold"])]
		text.add_child(UIKit.label(detail, &"", 21, UIStyle.PARCHMENT))
		if not bool(info["compatible"]):
			text.add_child(UIKit.label("From an older version of the game - it can no longer be loaded.", &"MutedLabel", 19, Color("ffcf7a")))
	var buttons: VBoxContainer = UIKit.vbox(6)
	row.add_child(buttons)
	if mode == Mode.SAVE:
		if slot > 0:
			var save: FancyButton = FancyButton.make("Save here", &"PrimaryButton", Vector2(190, 46))
			save.name = "SaveButton"
			save.disabled = not Session.can_save_now()
			save.pressed.connect(func() -> void: _on_save(slot, not info.is_empty()))
			buttons.add_child(save)
	else:
		var load_button: FancyButton = FancyButton.make("Load", &"PrimaryButton", Vector2(190, 46))
		load_button.name = "LoadButton"
		load_button.disabled = info.is_empty() or not bool(info["compatible"])
		load_button.pressed.connect(func() -> void: _on_load(slot))
		buttons.add_child(load_button)
	if not info.is_empty() and slot > 0:
		var delete: FancyButton = FancyButton.make("Delete", &"DangerButton", Vector2(190, 40))
		delete.name = "DeleteButton"
		delete.pressed.connect(func() -> void: _on_delete(slot))
		buttons.add_child(delete)
	return row_panel


func _name_edit(slot: int, default_text: String) -> LineEdit:
	var edit: LineEdit = LineEdit.new()
	edit.name = "NameEdit%d" % slot
	edit.text = default_text
	edit.max_length = 28
	edit.placeholder_text = "Name this save"
	edit.custom_minimum_size = Vector2(420, 40)
	edit.add_theme_font_size_override("font_size", 24)
	_name_edits[slot] = edit
	return edit


func _on_save(slot: int, occupied: bool) -> void:
	if not Session.can_save_now():
		_status.text = "You cannot save during a battle or a dungeon."
		Audio.sfx(&"ui_error")
		return
	if occupied:
		var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Overwrite this save?", "%s will be replaced by your current game." % SaveSlots.slot_label(slot), "Overwrite", "Cancel", true)
		dialog.name = "ConfirmDialog"
		dialog.confirmed.connect(func() -> void: _do_save(slot))
	else:
		_do_save(slot)


func _do_save(slot: int) -> void:
	var edit: LineEdit = _name_edits.get(slot) as LineEdit
	var save_name: String = edit.text.strip_edges() if edit != null else ""
	if save_name.is_empty():
		save_name = "Save %d" % slot
	if Session.save_to_slot(slot, save_name, snapshot):
		_status.text = "Saved to %s." % SaveSlots.slot_label(slot)
		Audio.sfx(&"ui_confirm")
	else:
		_status.text = "The game could not be saved."
		Audio.sfx(&"ui_error")
	_rebuild()


func _on_load(slot: int) -> void:
	if Session.profile != null:
		var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Load this save?", "Progress since your last save will be lost.", "Load", "Cancel")
		dialog.name = "ConfirmDialog"
		dialog.confirmed.connect(func() -> void: _do_load(slot))
	else:
		_do_load(slot)


func _do_load(slot: int) -> void:
	if Session.load_from_slot(slot):
		Audio.sfx(&"ui_confirm")
		loaded.emit()
	else:
		_status.text = "That save could not be loaded."
		Audio.sfx(&"ui_error")


func _on_delete(slot: int) -> void:
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Delete this save?", "%s will be deleted for good." % SaveSlots.slot_label(slot), "Delete", "Cancel", true)
	dialog.name = "ConfirmDialog"
	dialog.confirmed.connect(func() -> void:
		SaveSlots.delete(slot)
		_status.text = "%s deleted." % SaveSlots.slot_label(slot)
		_rebuild())
