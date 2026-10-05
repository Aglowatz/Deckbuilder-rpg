class_name QuestTracker
extends PanelContainer
## HUD widget: the active quest and its objective progress, collapsible (click the header, or
## it remembers the choice for the rest of the session). Redraws on `EventBus.quest_changed`.

static var collapsed: bool = false
## The quest whose objectives are shown (click a quest title to switch); quests in `removed_ids` are removed from the tracker (they stay in the log, J).
static var focus_id: String = ""
static var removed_ids: Array[String] = []

var _header: Button
var _body: VBoxContainer


func _ready() -> void:
	theme_type_variation = &"DarkPanel"
	custom_minimum_size = Vector2(430, 0)
	mouse_filter = Control.MOUSE_FILTER_PASS
	var column: VBoxContainer = UIKit.vbox(4)
	add_child(column)
	_header = Button.new()
	_header.flat = true
	_header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_header.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_header.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_header.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_header.focus_mode = Control.FOCUS_NONE
	_header.add_theme_font_size_override("font_size", 22)
	_header.add_theme_color_override("font_color", UIStyle.GOLD)
	_header.pressed.connect(toggle)
	column.add_child(_header)
	_body = UIKit.vbox(3)
	column.add_child(_body)
	EventBus.quest_changed.connect(refresh)
	refresh()


func toggle() -> void:
	collapsed = not collapsed
	refresh()


func refresh() -> void:
	if _body == null:
		return
	for child: Node in _body.get_children():
		child.queue_free()
	var state: UnlockState = Session.unlock_state()
	var qlog: QuestLog = Session.quest_log
	var active: Array[QuestData] = []
	for quest_id: String in qlog.active:
		var quest: QuestData = QuestCatalog.find(quest_id)
		if quest != null:
			active.append(quest)
	var visible_quests: Array[QuestData] = []
	for quest: QuestData in active:
		if not removed_ids.has(quest.id):
			visible_quests.append(quest)
	if not visible_quests.is_empty() and not visible_quests.any(func(q: QuestData) -> bool: return q.id == focus_id):
		focus_id = visible_quests[0].id
	_header.text = "%s Quests (%d)   [J] log" % ["▸" if collapsed else "▾", visible_quests.size()]
	_body.visible = not collapsed
	visible = true
	if collapsed:
		return
	if active.is_empty():
		_body.add_child(UIKit.label("No active quests.", &"MutedLabel", 20))
		return
	if visible_quests.is_empty():
		_body.add_child(UIKit.label("Nothing tracked.", &"MutedLabel", 20))
	for quest: QuestData in visible_quests:
		var ready: bool = qlog.is_ready_to_turn_in(quest, state)
		var title: String = quest.title + ("  (hand in to %s)" % quest.turn_in_npc if ready else "")
		var row: HBoxContainer = UIKit.hbox(6)
		var pick: Button = Button.new()
		pick.name = "Track_%s" % quest.id
		pick.flat = true
		pick.text = title
		pick.alignment = HORIZONTAL_ALIGNMENT_LEFT
		pick.focus_mode = Control.FOCUS_NONE
		pick.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pick.tooltip_text = "Show this quest's objectives"
		pick.add_theme_font_size_override("font_size", 22)
		pick.add_theme_color_override("font_color", UIStyle.GOLD if quest.id == focus_id else UIStyle.PARCHMENT)
		pick.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		pick.pressed.connect(func() -> void:
			focus_id = quest.id
			refresh())
		row.add_child(pick)
		var remove: Button = Button.new()
		remove.name = "Untrack_%s" % quest.id
		remove.text = "✕"
		remove.flat = true
		remove.focus_mode = Control.FOCUS_NONE
		remove.tooltip_text = "Remove from the tracker (it stays in the quest log)"
		remove.pressed.connect(func() -> void:
			removed_ids.append(quest.id)
			refresh())
		row.add_child(remove)
		_body.add_child(row)
		if quest.id == focus_id or ready:
			for objective_index: int in range(quest.objectives.size()):
				_body.add_child(_objective_row(quest, objective_index, qlog, state))
	if not removed_ids.is_empty():
		var restore: Button = Button.new()
		restore.name = "TrackAll"
		restore.text = "Show removed quests (%d)" % removed_ids.size()
		restore.flat = true
		restore.focus_mode = Control.FOCUS_NONE
		restore.add_theme_font_size_override("font_size", 18)
		restore.pressed.connect(func() -> void:
			removed_ids.clear()
			refresh())
		_body.add_child(restore)


func _objective_row(quest: QuestData, index: int, qlog: QuestLog, state: UnlockState) -> Label:
	var progress: Vector2i = qlog.objective_progress(quest, index, state)
	var done: bool = progress.x >= progress.y
	var text: String = "%s %s" % ["✔" if done else "○", quest.objectives[index].text]
	if progress.y > 1:
		text += "  %d/%d" % [progress.x, progress.y]
	var row: Label = UIKit.label(text, &"", 19, UIStyle.GOOD if done else UIStyle.MUTED)
	row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.custom_minimum_size = Vector2(400, 0)
	return row
