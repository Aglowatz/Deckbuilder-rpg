class_name QuestLogScreen
extends OverlayScreen
## The Quest Log (hotkey J): Active / Completed tabs, a list on the left and the selected quest's
## summary, objectives (with progress) and rewards on the right.

var _tab_active: bool = true
var _selected: String = ""
var _list: VBoxContainer
var _detail: VBoxContainer
var _tab_buttons: Dictionary = {}


func _init() -> void:
	screen_title = "Quest Log"
	close_text = "Close (J)"


func _build() -> void:
	var tabs: HBoxContainer = UIKit.hbox(10)
	body.add_child(tabs)
	for tab_name: String in ["Active", "Completed"]:
		var button: FancyButton = FancyButton.make(tab_name, &"", Vector2(200, 50))
		button.pressed.connect(func() -> void: _set_tab(tab_name == "Active"))
		tabs.add_child(button)
		_tab_buttons[tab_name] = button
	var split: HBoxContainer = UIKit.hbox(24)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	var list_scroll: ScrollContainer = ScrollContainer.new()
	list_scroll.custom_minimum_size = Vector2(560, 0)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	split.add_child(list_scroll)
	_list = UIKit.vbox(8)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.add_child(_list)
	var detail_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(detail_panel)
	_detail = UIKit.vbox(10)
	detail_panel.add_child(_detail)
	_set_tab(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_J:
		get_viewport().set_input_as_handled()
		request_close()
		return
	super._unhandled_input(event)


func _set_tab(active: bool) -> void:
	_tab_active = active
	_selected = ""
	_refresh()


func _quest_ids() -> Array[String]:
	return Session.quest_log.active if _tab_active else Session.quest_log.completed


func _refresh() -> void:
	for child: Node in _list.get_children():
		child.queue_free()
	var ids: Array[String] = _quest_ids()
	if _selected.is_empty() and not ids.is_empty():
		_selected = ids[0]
	if ids.is_empty():
		_list.add_child(UIKit.label("Nothing here yet." if _tab_active else "No completed quests yet.", &"MutedLabel", 26))
	var state: UnlockState = Session.unlock_state()
	for quest_id: String in ids:
		var quest: QuestData = QuestCatalog.find(quest_id)
		if quest == null:
			continue
		var met: int = Session.quest_log.objectives_met_count(quest, state)
		var label: String = quest.title if not _tab_active else "%s   %d/%d" % [quest.title, met, quest.objectives.size()]
		var button: FancyButton = FancyButton.make(label, &"PrimaryButton" if quest_id == _selected else &"GhostButton", Vector2(540, 56))
		button.pressed.connect(func() -> void:
			_selected = quest_id
			_refresh())
		_list.add_child(button)
	_show_detail(state)


func _show_detail(state: UnlockState) -> void:
	for child: Node in _detail.get_children():
		child.queue_free()
	var quest: QuestData = QuestCatalog.find(_selected)
	if quest == null:
		return
	_detail.add_child(UIKit.label(quest.title, &"HeadingLabel", 34))
	if not quest.giver_npc.is_empty():
		_detail.add_child(UIKit.label("Given by %s" % quest.giver_npc, &"MutedLabel", 20))
	var summary: Label = UIKit.label(Villain.fill(quest.summary), &"", 24, UIStyle.PARCHMENT)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.custom_minimum_size = Vector2(720, 0)
	_detail.add_child(summary)
	_detail.add_child(UIKit.spacer(8))
	_detail.add_child(UIKit.label("Objectives", &"HeadingLabel", 26))
	var done_quest: bool = Session.quest_log.is_completed(quest.id)
	for index: int in range(quest.objectives.size()):
		var progress: Vector2i = Session.quest_log.objective_progress(quest, index, state)
		var done: bool = done_quest or progress.x >= progress.y
		var text: String = "%s %s" % ["✔" if done else "○", quest.objectives[index].text]
		if progress.y > 1:
			text += "   %d/%d" % [progress.y if done_quest else progress.x, progress.y]
		var row: Label = UIKit.label(text, &"", 24, UIStyle.GOOD if done else UIStyle.PARCHMENT)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.custom_minimum_size = Vector2(720, 0)
		_detail.add_child(row)
	if _tab_active and not done_quest:
		var tracked_now: bool = Session.quest_log.tracked_id() == quest.id
		var track: FancyButton = FancyButton.make("Tracking in the HUD" if tracked_now else "Track this quest", &"PrimaryButton" if not tracked_now else &"GhostButton", Vector2(300, 50))
		track.name = "TrackButton"
		track.disabled = tracked_now
		track.pressed.connect(func() -> void:
			Session.quest_log.track(quest.id)
			EventBus.quest_changed.emit()
			_refresh())
		_detail.add_child(track)
	if not quest.turn_in_npc.is_empty() and not done_quest:
		_detail.add_child(UIKit.label("Hand in to: %s" % quest.turn_in_npc, &"MutedLabel", 20))
	_detail.add_child(UIKit.spacer(8))
	var rewards: String = quest.reward_summary()
	if not rewards.is_empty():
		_detail.add_child(UIKit.label("Reward: %s%s" % [rewards, " (received)" if done_quest else ""], &"", 24, UIStyle.GOLD))
