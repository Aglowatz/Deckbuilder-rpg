class_name QuestTracker
extends PanelContainer
## HUD widget: the active quest and its objective progress, collapsible (click the header, or
## it remembers the choice for the rest of the session). Redraws on `EventBus.quest_changed`.

static var collapsed: bool = false

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
	_header.text = "%s Quests (%d)   [J] log" % ["▸" if collapsed else "▾", active.size()]
	_body.visible = not collapsed
	visible = true
	if collapsed:
		return
	if active.is_empty():
		_body.add_child(UIKit.label("No active quests.", &"MutedLabel", 20))
		return
	for index: int in range(active.size()):
		var quest: QuestData = active[index]
		var ready: bool = qlog.is_ready_to_turn_in(quest, state)
		var title: String = quest.title + ("  (hand in to %s)" % quest.turn_in_npc if ready else "")
		_body.add_child(UIKit.label(title, &"", 22, UIStyle.PARCHMENT))
		if index == 0 or ready:
			for objective_index: int in range(quest.objectives.size()):
				_body.add_child(_objective_row(quest, objective_index, qlog, state))


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
