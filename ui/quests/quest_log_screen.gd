class_name QuestLogScreen
extends OverlayScreen
## The Quest Log (hotkey J), Oct 16 overhaul: MAIN / SIDE / COMPLETED tabs, the quest list on the left (the tracked one marked) and a details
## pane on the right: category, description, the objectives checklist, the giver, where to go next and a rewards preview with pack and
## equipment pictures. Select a quest to track it in the HUD. Keyboard: Left/Right (or 1-3) switch tabs, Up/Down pick, Enter tracks.

enum Tab { MAIN, SIDE, COMPLETED }
const TAB_NAMES: Array[String] = ["Main", "Side", "Completed"]

var _tab: Tab = Tab.MAIN
var _selected: String = ""
var _list: VBoxContainer
var _detail: VBoxContainer
var _tab_buttons: Array[FancyButton] = []


func _init() -> void:
	screen_title = "Quest Log"
	title_icon_id = "ICON-UI-QUESTS"
	close_text = "Close (%s)" % Keybinds.first_key(&"open_quests")
	background_id = "UI-BG-QUESTLOG"


func _build() -> void:
	var tabs: HBoxContainer = UIKit.hbox(10)
	body.add_child(tabs)
	for index: int in range(TAB_NAMES.size()):
		var button: FancyButton = FancyButton.make(TAB_NAMES[index], &"", Vector2(190, 50))
		button.name = "Tab%s" % TAB_NAMES[index]
		var tab_index: int = index
		button.pressed.connect(func() -> void: _set_tab(tab_index as Tab))
		tabs.add_child(button)
		_tab_buttons.append(button)
	# Overnight Oct 17 (Phase 2, UI consistency): the key hint ran under the frame's right edge in pale grey on the brown page; shorter, readable, inset.
	var hint: Label = UIKit.label("Left/Right: tabs  ·  Up/Down: choose", &"", 18, Color("4a3524"))
	hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tabs.add_child(hint)
	tabs.add_child(UIKit.spacer(0, 110))
	var split: HBoxContainer = UIKit.hbox(24)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(split)
	var list_scroll: ScrollContainer = ScrollContainer.new()
	list_scroll.custom_minimum_size = Vector2(540, 0)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	split.add_child(list_scroll)
	_list = UIKit.vbox(8)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_scroll.add_child(_list)
	var detail_panel: PanelContainer = UIKit.panel(&"DarkPanel")
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(detail_panel)
	var detail_scroll: ScrollContainer = ScrollContainer.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_panel.add_child(detail_scroll)
	_detail = UIKit.vbox(10)
	_detail.name = "QuestDetail"
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.add_child(_detail)
	# Open on the tracked quest's tab, with it selected.
	var tracked: QuestData = QuestCatalog.find(Session.quest_log.tracked_id())
	_tab = Tab.MAIN if tracked == null or tracked.is_main() else Tab.SIDE
	_selected = tracked.id if tracked != null else ""
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_quests"):
		get_viewport().set_input_as_handled()
		request_close()
		return
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key: Key = (event as InputEventKey).physical_keycode
		var handled: bool = true
		match key:
			KEY_LEFT:
				_set_tab(posmod(_tab - 1, TAB_NAMES.size()) as Tab)
			KEY_RIGHT:
				_set_tab(posmod(_tab + 1, TAB_NAMES.size()) as Tab)
			KEY_1, KEY_2, KEY_3:
				_set_tab((key - KEY_1) as Tab)
			KEY_UP:
				_move_selection(-1)
			KEY_DOWN:
				_move_selection(1)
			KEY_ENTER, KEY_KP_ENTER:
				_track(_selected)
			_:
				handled = false
		if handled:
			get_viewport().set_input_as_handled()
			return
	super._unhandled_input(event)


func _set_tab(tab: Tab) -> void:
	if tab == _tab and not _selected.is_empty():
		return
	_tab = tab
	_selected = ""
	Audio.sfx(&"ui_tick")
	_refresh()


func _move_selection(step: int) -> void:
	var ids: Array[String] = quest_ids(_tab)
	if ids.is_empty():
		return
	_selected = ids[posmod(ids.find(_selected) + step, ids.size())]
	_refresh()


## The quests a tab lists: active MAIN or SIDE quests (by order), or every completed quest (most recent first).
static func quest_ids(tab: Tab) -> Array[String]:
	var qlog: QuestLog = Session.quest_log
	var result: Array[String] = []
	if tab == Tab.COMPLETED:
		for index: int in range(qlog.completed.size() - 1, -1, -1):
			if QuestCatalog.find(qlog.completed[index]) != null:
				result.append(qlog.completed[index])
		return result
	for quest_id: String in qlog.cycle_order(QuestCatalog.all()):
		if QuestCatalog.find(quest_id).is_main() == (tab == Tab.MAIN):
			result.append(quest_id)
	return result


func _track(quest_id: String) -> void:
	if Session.quest_log.track(quest_id):
		Audio.sfx(&"ui_select")
		EventBus.quest_changed.emit()
		_refresh()


func _refresh() -> void:
	for index: int in range(_tab_buttons.size()):
		_tab_buttons[index].theme_type_variation = &"PrimaryButton" if index == _tab else &"GhostButton"
	for child: Node in _list.get_children():
		child.queue_free()
	var ids: Array[String] = quest_ids(_tab)
	if (_selected.is_empty() or not ids.has(_selected)) and not ids.is_empty():
		_selected = ids[0]
	if ids.is_empty():
		_list.add_child(UIKit.label("No completed quests yet." if _tab == Tab.COMPLETED else "Nothing here right now.", &"MutedLabel", 26))
	var state: UnlockState = Session.unlock_state()
	var tracked: String = Session.quest_log.tracked_id()
	for quest_id: String in ids:
		var quest: QuestData = QuestCatalog.find(quest_id)
		var met: int = mini(Session.quest_log.current_index(quest, state), quest.objectives.size())  # steps done in order (Oct 20: never counts a hidden one)
		var label: String = quest.title if _tab == Tab.COMPLETED else "%s   %d/%d" % [quest.title, met, quest.objectives.size()]
		if quest_id == tracked and _tab != Tab.COMPLETED:
			label = "» " + label
		var button: FancyButton = FancyButton.make(label, &"PrimaryButton" if quest_id == _selected else &"GhostButton", Vector2(520, 54))
		button.name = "Quest_%s" % quest_id
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.clip_text = true
		if _tab == Tab.COMPLETED:
			IconArt.button_icon(button, "ICON-CHECK", 28.0)
		elif Session.quest_log.is_ready_to_turn_in(quest, state):
			IconArt.button_icon(button, "ICON-MAP-TURNIN", 28.0)
		button.pressed.connect(func() -> void:
			_selected = quest_id
			if _tab != Tab.COMPLETED:
				_track(quest_id)
			_refresh())
		_list.add_child(button)
	_show_detail(state)


func _show_detail(state: UnlockState) -> void:
	for child: Node in _detail.get_children():
		child.queue_free()
	var quest: QuestData = QuestCatalog.find(_selected)
	if quest == null:
		return
	var qlog: QuestLog = Session.quest_log
	var done_quest: bool = qlog.is_completed(quest.id)
	var head: HBoxContainer = UIKit.hbox(10)
	_detail.add_child(head)
	var tag: Label = UIKit.label(quest.category_tag(), &"", 16, Color("1d1408"))
	tag.add_theme_font_override("font", UIStyle.font_bold())
	var tag_panel: PanelContainer = PanelContainer.new()
	var tag_box: StyleBoxFlat = StyleBoxFlat.new()
	tag_box.bg_color = QuestTracker.MAIN_COLOR if quest.is_main() else QuestTracker.SIDE_COLOR
	tag_box.set_corner_radius_all(6)
	tag_box.content_margin_left = 8
	tag_box.content_margin_right = 8
	tag_panel.add_theme_stylebox_override("panel", tag_box)
	tag_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tag_panel.add_child(tag)
	head.add_child(tag_panel)
	head.add_child(UIKit.label(quest.title, &"HeadingLabel", 34))
	var summary: Label = UIKit.label(Villain.fill(quest.summary), &"", 23, UIStyle.PARCHMENT)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.custom_minimum_size = Vector2(700, 0)
	_detail.add_child(summary)
	var people: PackedStringArray = []
	if not quest.giver_npc.is_empty():
		people.append("Given by %s" % quest.giver_npc)
	if not quest.turn_in_npc.is_empty() and quest.turn_in_npc != quest.giver_npc:
		people.append("hand in to %s" % quest.turn_in_npc)
	elif not quest.turn_in_npc.is_empty():
		people.append("hand it back to them")
	if not people.is_empty():
		_detail.add_child(UIKit.label(", ".join(people), &"MutedLabel", 19))
	_detail.add_child(UIKit.label("Objectives", &"HeadingLabel", 25))
	var current: int = qlog.current_index(quest, state)
	# Oct 20, Part 5: the steps done and the current one only (`QuestLog.visible_steps`); the rest is one "???" line.
	for index: int in qlog.visible_steps(quest, state):
		var objective: QuestObjective = quest.objectives[index]
		var progress: Vector2i = qlog.objective_progress(quest, index, state)
		var done: bool = done_quest or progress.x >= progress.y
		var is_current: bool = not done_quest and index == current
		var row: HBoxContainer = UIKit.hbox(8)
		if done:
			row.add_child(IconArt.rect("ICON-CHECK", 26.0))
		else:
			var mark: Label = UIKit.label("»" if is_current else "○", &"", 22, UIStyle.GOLD if is_current else Color(UIStyle.PARCHMENT, 0.5))
			mark.custom_minimum_size = Vector2(26, 0)
			row.add_child(mark)
		var text: String = objective.text
		if progress.y > 1:
			text += "   %d/%d" % [progress.y if done_quest else progress.x, progress.y]
		var color: Color = UIStyle.GOOD if done else (UIStyle.GOLD if is_current else Color(UIStyle.PARCHMENT, 0.6))
		var line: Label = UIKit.label(text, &"", 22, color)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(560, 0)
		if is_current:
			line.add_theme_font_override("font", UIStyle.font_bold())
		row.add_child(line)
		if objective.milestone != null and not objective.milestone.is_empty():
			row.add_child(_reward_icons(objective.milestone, 32.0, qlog.milestone_paid(quest.id, index) or done_quest))
		_detail.add_child(row)
	if qlog.hidden_steps(quest, state) > 0:
		var hidden_row: HBoxContainer = UIKit.hbox(8)
		var hidden_mark: Label = UIKit.label("○", &"", 22, Color(UIStyle.PARCHMENT, 0.4))
		hidden_mark.custom_minimum_size = Vector2(26, 0)
		hidden_row.add_child(hidden_mark)
		hidden_row.add_child(UIKit.label(QuestLog.HIDDEN_STEPS_TEXT, &"", 22, Color(UIStyle.PARCHMENT, 0.45)))
		hidden_row.name = "HiddenSteps"
		_detail.add_child(hidden_row)
	if not done_quest:
		var where: String = where_to_go(quest, state)
		if not where.is_empty():
			var where_row: HBoxContainer = UIKit.hbox(8)
			where_row.add_child(IconArt.rect("ICON-MAP-QUEST", 28.0))
			var where_label: Label = UIKit.label("Where to go: %s" % where, &"", 21, UIStyle.PARCHMENT)
			where_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			where_label.custom_minimum_size = Vector2(640, 0)
			where_row.add_child(where_label)
			_detail.add_child(where_row)
		var tracked_now: bool = qlog.tracked_id() == quest.id
		var track: FancyButton = FancyButton.make("Tracking in the HUD" if tracked_now else "Track this quest (Enter)", &"GhostButton" if tracked_now else &"PrimaryButton", Vector2(340, 50))
		track.name = "TrackButton"
		track.disabled = tracked_now
		track.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		track.pressed.connect(func() -> void: _track(quest.id))
		_detail.add_child(track)
	_detail.add_child(UIKit.label("Rewards%s" % (" (received)" if done_quest else ""), &"HeadingLabel", 25))
	_detail.add_child(_reward_row(quest.completion_reward()))
	var insight: bool = false
	for flag_name: String in quest.reward_unlock_flags:
		insight = insight or flag_name.begins_with("capital_insight_")
	if insight:
		_detail.add_child(UIKit.label("+ Insight into %s" % Villain.display_name(), &"", 20, UIStyle.GOLD))


## The "where to go" line: the current objective's hint, else the turn-in NPC, else the quest's giver.
static func where_to_go(quest: QuestData, state: UnlockState) -> String:
	var qlog: QuestLog = Session.quest_log
	if qlog.is_ready_to_turn_in(quest, state):
		return "Hand in to %s%s" % [quest.turn_in_npc, (" (%s)" % area_name(quest.turn_in_area)) if quest.turn_in_area != "" else ""]
	var objective: QuestObjective = qlog.current_objective(quest, state)
	if objective == null:
		return ""
	var area: String = area_name(objective.target_area)
	if objective.hint != "":
		return objective.hint + ((" (%s)" % area) if area != "" and not objective.hint.contains(area) else "")
	return area


static func area_name(area: String) -> String:
	match area:
		"", "anywhere":
			return ""
		"town":
			return StoryText.shared().text("town.name")
		"forest":
			return "the Starting Forest"
	return ZoneDefs.get_def(area).display_name if ZoneDefs.has_def(area) else area


## Pictures and names of a reward bundle: packs (their pack art), equipment (its icon), then cards, items, gold and XP as text.
func _reward_row(reward: QuestReward) -> Control:
	var flow: HFlowContainer = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 16)
	flow.add_theme_constant_override("v_separation", 8)
	flow.custom_minimum_size = Vector2(700, 0)
	for pack_id: String in reward.pack_ids:
		var pack: PackData = PackCatalog.find(pack_id)
		flow.add_child(_reward_chip(_pack_icon(pack_id, 48.0), pack.display_name if pack != null else pack_id))
	for equipment_id: String in reward.equipment_ids:
		flow.add_child(_reward_chip(_equipment_icon(equipment_id, 44.0), QuestReward.equipment_name(equipment_id)))
	for card_id: String in reward.card_ids:
		flow.add_child(_reward_chip(IconArt.rect("ICON-UI-COLLECTION", 36.0), QuestReward.card_name(card_id)))
	for item_id: String in reward.item_ids:
		flow.add_child(_reward_chip(IconArt.rect("ICON-NODE-TREASURE", 36.0), QuestReward.item_name(item_id)))
	if reward.gold > 0:
		flow.add_child(_reward_chip(IconArt.rect("ICON-GOLD", 34.0), "%d gold" % reward.gold))
	if reward.xp > 0:
		flow.add_child(_reward_chip(IconArt.rect("ICON-XP", 34.0), "%d XP" % reward.xp))
	if flow.get_child_count() == 0:
		flow.add_child(UIKit.label("The satisfaction of a job well done.", &"MutedLabel", 20))
	return flow


## Small icons for a milestone reward beside its objective (dimmed once paid).
func _reward_icons(reward: QuestReward, px: float, paid: bool) -> Control:
	var row: HBoxContainer = UIKit.hbox(4)
	row.modulate.a = 0.45 if paid else 1.0
	row.tooltip_text = "Step reward: %s%s" % [reward.summary(), " (received)" if paid else ""]
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	for pack_id: String in reward.pack_ids:
		row.add_child(_pack_icon(pack_id, px))
	for equipment_id: String in reward.equipment_ids:
		row.add_child(_equipment_icon(equipment_id, px))
	if reward.gold > 0 and reward.pack_ids.is_empty() and reward.equipment_ids.is_empty():
		row.add_child(IconArt.rect("ICON-GOLD", px))
	for child: Node in row.get_children():
		(child as Control).mouse_filter = Control.MOUSE_FILTER_PASS
	return row


func _reward_chip(icon: Control, text: String) -> HBoxContainer:
	var chip: HBoxContainer = UIKit.hbox(6)
	chip.name = "RewardChip"
	chip.add_child(icon)
	var label: Label = UIKit.label(text, &"", 20, UIStyle.GOLD)
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip.add_child(label)
	return chip


static func _pack_icon(pack_id: String, px: float) -> Control:
	var pack: PackData = PackCatalog.find(pack_id)
	var art_id: String = PackArt.art_id_for(pack) if pack != null else ""
	if art_id != "":
		var rect: TextureRect = TextureRect.new()
		rect.texture = UiArt.texture(art_id)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.custom_minimum_size = Vector2(px * 0.72, px)
		return rect
	return IconArt.rect("ICON-UI-PACKS", px)


static func _equipment_icon(equipment_id: String, px: float) -> Control:
	var content: ContentSet = Session.content
	var piece: EquipmentData = content.equipment_piece(equipment_id) if content != null else null
	if piece != null:
		var glyph: TextureRect = IconArt.equipment_glyph(piece, UIStyle.GOLD, px)
		glyph.tooltip_text = piece.tooltip_text()
		return glyph
	return IconArt.rect("ICON-UI-CHARACTER", px)
