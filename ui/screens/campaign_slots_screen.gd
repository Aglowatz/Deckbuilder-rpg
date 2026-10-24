class_name CampaignSlotsScreen
extends Control
## Overnight Oct 23, Part 6: the three campaign slots on the title screen. NEW (New Game: pick the slot to start in; a used slot asks first)
## or PLAY (Load Game: pick a campaign to continue). Each slot shows its Path, level, area, play time and when it was last played; a
## used slot can be copied into another slot or deleted, both with a confirmation. The campaigns themselves are `CampaignSlots`.

signal closed
## A campaign was picked: `campaign` is now active (CampaignSlots.activate). `fresh` = start a new game in it.
signal picked(campaign: int, fresh: bool)
## PLAY: the player wants that campaign's other saves (its manual slots); `campaign` is active.
signal browse(campaign: int)

enum Mode { NEW, PLAY }

var mode: Mode = Mode.PLAY
var _list: HBoxContainer
var _copy_from: int = -1
var _status: Label


static func make(screen_mode: Mode) -> CampaignSlotsScreen:
	var screen: CampaignSlotsScreen = CampaignSlotsScreen.new()
	screen.mode = screen_mode
	return screen


func _ready() -> void:
	name = "CampaignSlotsScreen"
	UIKit.full_rect(self)
	UiScale.fit(self)
	z_index = 150
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(UiSkin.menu_backdrop(Color(0.02, 0.01, 0.05, 0.85)))
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	add_child(center)
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(1500, 0)
	center.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(16)
	panel.add_child(column)
	var head: HBoxContainer = UIKit.hbox(12)
	column.add_child(head)
	head.add_child(UIKit.label("Choose a slot for your new game" if mode == Mode.NEW else "Choose a campaign", &"HeadingLabel", 36))
	head.add_child(UIKit.filler())
	var back: FancyButton = FancyButton.make("Back", &"GhostButton", Vector2(150, 48))
	back.name = "CampaignBack"
	back.pressed.connect(func() -> void: closed.emit())
	head.add_child(back)
	_status = UIKit.label("", &"MutedLabel", 20)
	_status.name = "CampaignStatus"
	column.add_child(_status)
	_list = UIKit.hbox(18)
	column.add_child(_list)
	refresh()


func refresh() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	for campaign: int in range(1, CampaignSlots.COUNT + 1):
		_list.add_child(_card(campaign))
	_status.text = "Copying slot %d: pick the slot to copy it into." % _copy_from if _copy_from > 0 else ""


## The lines a slot card shows (also read by tests): "Slot 1", then either "Empty" or Path / level / area / play time / last played.
static func card_lines(campaign: int) -> Array[String]:
	var lines: Array[String] = ["Slot %d" % campaign]
	var found: Dictionary = CampaignSlots.info(campaign)
	if found.is_empty():
		lines.append("Empty")
		return lines
	var path: int = int(found.get("path", int(Affinity.Type.NEUTRAL)))
	lines.append("%s Path" % Affinity.display_name(path as Affinity.Type) if path != int(Affinity.Type.NEUTRAL) else "No Path yet")
	lines.append("Level %d" % int(found.get("level", 1)))
	lines.append(str(found.get("location", "Unknown")))
	lines.append("Play time %s" % SaveSlots.format_playtime(float(found.get("playtime", 0.0))))
	lines.append("Last played %s" % SaveSlots.format_date(int(found.get("saved_at", 0))))
	return lines


func _card(campaign: int) -> PanelContainer:
	var card: PanelContainer = UIKit.panel(&"DarkPanel")
	card.name = "Campaign_%d" % campaign
	card.custom_minimum_size = Vector2(470, 420)
	var column: VBoxContainer = UIKit.vbox(8)
	card.add_child(column)
	var lines: Array[String] = card_lines(campaign)
	var used: bool = lines.size() > 2
	column.add_child(UIKit.label(lines[0], &"HeadingLabel", 30, UIStyle.GOLD))
	for index: int in range(1, lines.size()):
		var line: Label = UIKit.label(lines[index], &"" if index <= 2 else &"MutedLabel", 22 if index <= 2 else 19, UIStyle.PARCHMENT)
		column.add_child(line)
	column.add_child(UIKit.filler())
	if _copy_from > 0:
		if campaign != _copy_from:
			var into: FancyButton = FancyButton.make("Copy here", &"PrimaryButton", Vector2(0, 52))
			into.name = "CopyHere"
			into.pressed.connect(func() -> void: _confirm_copy(_copy_from, campaign))
			column.add_child(into)
		else:
			var cancel: FancyButton = FancyButton.make("Cancel copy", &"GhostButton", Vector2(0, 52))
			cancel.pressed.connect(func() -> void:
				_copy_from = -1
				refresh())
			column.add_child(cancel)
		return card
	if mode == Mode.NEW:
		var start: FancyButton = FancyButton.make("Start here" if not used else "Start over here", &"PrimaryButton" if not used else &"DangerButton", Vector2(0, 52))
		start.name = "StartHere"
		start.pressed.connect(func() -> void: _start(campaign, used))
		column.add_child(start)
	elif used:
		var play: FancyButton = FancyButton.make("Play", &"PrimaryButton", Vector2(0, 52))
		play.name = "Play"
		play.pressed.connect(func() -> void: _play(campaign))
		column.add_child(play)
		var others: FancyButton = FancyButton.make("Other saves", &"GhostButton", Vector2(0, 44))
		others.name = "OtherSaves"
		others.pressed.connect(func() -> void:
			CampaignSlots.activate(campaign)
			browse.emit(campaign))
		column.add_child(others)
	if used:
		var row: HBoxContainer = UIKit.hbox(10)
		var copy: FancyButton = FancyButton.make("Copy", &"", Vector2(0, 46))
		copy.name = "Copy"
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.pressed.connect(func() -> void:
			_copy_from = campaign
			refresh())
		row.add_child(copy)
		var delete: FancyButton = FancyButton.make("Delete", &"DangerButton", Vector2(0, 46))
		delete.name = "Delete"
		delete.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		delete.pressed.connect(func() -> void: _confirm_delete(campaign))
		row.add_child(delete)
		column.add_child(row)
	return card


func _start(campaign: int, used: bool) -> void:
	if not used:
		_pick(campaign, true)
		return
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Start over in slot %d?" % campaign, "Everything saved in this slot (its autosave and its manual saves) is deleted. The other slots are not touched.", "Start Over", "Cancel", true)
	dialog.confirmed.connect(func() -> void:
		# With saving off (smokes, --no-save) nothing is deleted: the new game simply is not saved.
		if Session.save_enabled:
			CampaignSlots.delete(campaign)
		_pick(campaign, true))


func _play(campaign: int) -> void:
	_pick(campaign, false)


func _pick(campaign: int, fresh: bool) -> void:
	CampaignSlots.activate(campaign)
	Audio.sfx(&"ui_confirm")
	picked.emit(campaign, fresh)


func _confirm_copy(from: int, to: int) -> void:
	var overwrite: bool = not CampaignSlots.is_empty(to)
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Copy slot %d into slot %d?" % [from, to], "Slot %d is replaced by a copy of slot %d." % [to, from] if overwrite else "Slot %d gets a copy of slot %d." % [to, from], "Copy", "Cancel", overwrite)
	dialog.confirmed.connect(func() -> void:
		CampaignSlots.copy(from, to)
		_copy_from = -1
		refresh())
	dialog.cancelled.connect(func() -> void:
		_copy_from = -1
		refresh())


func _confirm_delete(campaign: int) -> void:
	var dialog: ConfirmDialog = ConfirmDialog.ask(self, "Delete slot %d?" % campaign, "Its autosave and every manual save in it are deleted for good.", "Delete", "Cancel", true)
	dialog.confirmed.connect(func() -> void:
		CampaignSlots.delete(campaign)
		refresh())
