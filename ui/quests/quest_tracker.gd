class_name QuestTracker
extends PanelContainer
## HUD widget: ONE tracked quest, compact: its name, the current objective and the progress. The player picks which quest to track in the Quest Log (J); the default is the
## most recently started one. Click the header to collapse it to a single line. Redraws on `EventBus.quest_changed`.

static var collapsed: bool = false

var _header: Button
var _body: VBoxContainer


func _ready() -> void:
	theme_type_variation = &"DarkPanel"
	custom_minimum_size = Vector2(300, 0)
	mouse_filter = Control.MOUSE_FILTER_PASS
	var column: VBoxContainer = UIKit.vbox(2)
	add_child(column)
	_header = Button.new()
	_header.name = "TrackerHeader"
	_header.flat = true
	_header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_header.clip_text = true
	_header.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_header.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_header.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_header.focus_mode = Control.FOCUS_NONE
	_header.add_theme_font_size_override("font_size", 20)
	_header.add_theme_color_override("font_color", UIStyle.GOLD)
	_header.tooltip_text = "The tracked quest. Choose which quest to track in the Quest Log (J)."
	_header.pressed.connect(toggle)
	column.add_child(_header)
	_body = UIKit.vbox(1)
	column.add_child(_body)
	EventBus.quest_changed.connect(refresh)
	refresh()


func toggle() -> void:
	collapsed = not collapsed
	refresh()


## The first objective that is not done yet (or the last one when all are), with its progress.
static func current_objective(quest: QuestData, qlog: QuestLog, state: UnlockState) -> Dictionary:
	var index: int = 0
	for i: int in range(quest.objectives.size()):
		var progress: Vector2i = qlog.objective_progress(quest, i, state)
		index = i
		if progress.x < progress.y:
			break
	var progress_now: Vector2i = qlog.objective_progress(quest, index, state)
	return {"text": quest.objectives[index].text, "done": progress_now.x >= progress_now.y, "have": progress_now.x, "need": progress_now.y}


func refresh() -> void:
	if _body == null:
		return
	for child: Node in _body.get_children():
		child.queue_free()
	var qlog: QuestLog = Session.quest_log
	var quest: QuestData = QuestCatalog.find(qlog.tracked_id())
	visible = quest != null
	if quest == null:
		return
	var state: UnlockState = Session.unlock_state()
	var ready: bool = qlog.is_ready_to_turn_in(quest, state)
	_header.text = "%s %s" % ["▸" if collapsed else "▾", quest.title]
	_body.visible = not collapsed
	if collapsed:
		return
	if ready:
		_body.add_child(_line("Hand in to %s" % quest.turn_in_npc, UIStyle.GOOD))
		return
	var current: Dictionary = current_objective(quest, qlog, state)
	var text: String = "%s %s" % ["✔" if bool(current["done"]) else "○", str(current["text"])]
	if int(current["need"]) > 1:
		text += "  %d/%d" % [int(current["have"]), int(current["need"])]
	_body.add_child(_line(text, UIStyle.GOOD if bool(current["done"]) else UIStyle.PARCHMENT))


func _line(text: String, color: Color) -> Label:
	var row: Label = UIKit.label(text, &"", 17, color)
	row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.custom_minimum_size = Vector2(270, 0)
	return row
