class_name TubePuzzleScreen
extends OverlayScreen
## The Mail Room's pneumatic-tube puzzle (Part F). Click a junction to set its starting side, then
## "Send capsules" runs all 8 down the tubes (animated; junctions flip after every capsule). Each
## capsule must land in the department stamped on it. "Reset" puts the junctions and capsules back.
## Emits `solved` once - the scene grants the (one-time) reward.

signal solved

const JUNCTION_POS: Array[Vector2] = [
	Vector2(960, 250), Vector2(700, 410), Vector2(1220, 410),
	Vector2(560, 570), Vector2(840, 570), Vector2(1080, 570), Vector2(1360, 570),
]
const BIN_Y: float = 690.0

var puzzle: TubePuzzle = TubePuzzle.new()
var _start_states: Array[int] = [0, 0, 0, 0, 0, 0, 0]
var _buttons: Array[FancyButton] = []
var _canvas: Control
var _capsule_rows: Array[Label] = []
var _status: Label
var _send_button: FancyButton
var _running: bool = false
var _capsule_marker: ColorRect
var _story: ZoneStoryText
var _already_solved: bool = false


func _init() -> void:
	screen_title = "Pneumatic Soul Routing"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.shared()
	_already_solved = Session.flag(DnaZone.FLAG_PUZZLE_SOLVED)
	puzzle.reset(_start_states)
	var intro: Label = UIKit.label("\n".join(_story.get_lines("puzzle.intro")), &"MutedLabel", 20)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(1500, 0)
	body.add_child(intro)
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(1850, 830)
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.draw.connect(_draw_tubes)
	body.add_child(_canvas)
	for index: int in range(TubePuzzle.JUNCTIONS):
		var button: FancyButton = FancyButton.make("", &"PrimaryButton", Vector2(96, 64))
		button.position = JUNCTION_POS[index] - Vector2(48, 150)
		button.pressed.connect(func() -> void: _toggle(index))
		_canvas.add_child(button)
		_buttons.append(button)
	var bins: Array[String] = _story.get_lines("puzzle.bins")
	for leaf: int in range(TubePuzzle.LEAVES):
		var label: Label = UIKit.label("%d. %s" % [leaf + 1, bins[leaf]], &"HeadingLabel", 20, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(_leaf_x(leaf) - 75, BIN_Y + 18)
		label.size = Vector2(150, 56)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_canvas.add_child(label)
	# The capsule queue on the left: soul name and the department stamped on it.
	var queue: VBoxContainer = UIKit.vbox(4)
	queue.position = Vector2(20, 30)
	_canvas.add_child(queue)
	queue.add_child(UIKit.label("Capsule queue", &"HeadingLabel", 26))
	var souls: Array[String] = _story.get_lines("puzzle.souls")
	var wanted: Array[int] = TubePuzzle.targets()
	for index: int in range(TubePuzzle.CAPSULES):
		var row: Label = UIKit.label("%d. %s  >  %s" % [index + 1, souls[index], bins[wanted[index]]], &"", 19, UIStyle.PARCHMENT)
		queue.add_child(row)
		_capsule_rows.append(row)
	_status = UIKit.label("", &"", 24, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_status.position = Vector2(400, 765)
	_status.size = Vector2(1100, 60)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_canvas.add_child(_status)
	_capsule_marker = ColorRect.new()
	_capsule_marker.size = Vector2(26, 26)
	_capsule_marker.color = Color(0.5, 1.0, 0.85)
	_capsule_marker.visible = false
	_canvas.add_child(_capsule_marker)
	var row_buttons: HBoxContainer = UIKit.hbox(16)
	row_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(row_buttons)
	_send_button = FancyButton.make("Send capsules", &"PrimaryButton", Vector2(260, 60))
	_send_button.pressed.connect(_send_all)
	row_buttons.add_child(_send_button)
	var reset_button: FancyButton = FancyButton.make("Reset", &"", Vector2(200, 60))
	reset_button.pressed.connect(_reset)
	row_buttons.add_child(reset_button)
	var hint: FancyButton = FancyButton.make("Hint", &"GhostButton", Vector2(160, 60))
	hint.pressed.connect(func() -> void: _status.text = "\n".join(_story.get_lines("puzzle.hint")))
	row_buttons.add_child(hint)
	_refresh()
	if _already_solved:
		_status.text = _story.text("puzzle.already")


func _leaf_x(leaf: int) -> float:
	return 420.0 + float(leaf) * 154.0


func _toggle(index: int) -> void:
	if _running:
		return
	_start_states[index] = 1 - _start_states[index]
	puzzle.reset(_start_states)
	Audio.sfx(&"ui_toggle")
	_refresh()


func _reset() -> void:
	if _running:
		return
	_start_states = [0, 0, 0, 0, 0, 0, 0]
	puzzle.reset(_start_states)
	_status.text = ""
	_capsule_marker.visible = false
	Audio.sfx(&"ui_back")
	_refresh()


func _refresh() -> void:
	for index: int in range(_buttons.size()):
		_buttons[index].text = "◀ L" if puzzle.states[index] == 0 else "R ▶"
	var wanted: Array[int] = TubePuzzle.targets()
	for index: int in range(_capsule_rows.size()):
		var color: Color = UIStyle.PARCHMENT
		if index < puzzle.landed.size():
			color = UIStyle.GOOD if puzzle.landed[index] == wanted[index] else Color("ff8a85")
		_capsule_rows[index].add_theme_color_override("font_color", color)
	_send_button.disabled = _running
	_canvas.queue_redraw()


func _junction_point(index: int) -> Vector2:
	return JUNCTION_POS[index] + Vector2(0, -118)


## Screen point of a junction (< JUNCTIONS) or of a leaf node id (JUNCTIONS + leaf).
func _node_point(node: int) -> Vector2:
	if node < TubePuzzle.JUNCTIONS:
		return _junction_point(node)
	return Vector2(_leaf_x(node - TubePuzzle.JUNCTIONS), BIN_Y - 70.0)


func _draw_tubes() -> void:
	for j: int in range(TubePuzzle.JUNCTIONS):
		for side: int in range(2):
			var target: int = TubePuzzle.child(j, side)
			var open: bool = puzzle.states[j] == side
			var color: Color = Color(0.45, 1.0, 0.8) if open else Color(0.28, 0.36, 0.34)
			_canvas.draw_line(_junction_point(j) + Vector2(0, 34), _node_point(target), color, 6.0 if open else 4.0)
	for leaf: int in range(TubePuzzle.LEAVES):
		var rect: Rect2 = Rect2(_leaf_x(leaf) - 60, BIN_Y - 70, 120, 80)
		_canvas.draw_rect(rect, Color(0.12, 0.18, 0.17), true)
		_canvas.draw_rect(rect, Color(0.45, 0.6, 0.55), false, 3.0)


func _send_all() -> void:
	if _running:
		return
	_running = true
	puzzle.reset(_start_states)
	_status.text = "Routing..."
	_refresh()
	_capsule_marker.visible = true
	var wanted: Array[int] = TubePuzzle.targets()
	for index: int in range(TubePuzzle.CAPSULES):
		var path: Array[int] = puzzle.send_next()
		var travel: Tween = create_tween()
		for step: int in range(path.size()):
			var node: int = path[step] if step < path.size() - 1 else path[step] + TubePuzzle.JUNCTIONS
			travel.tween_property(_capsule_marker, "position", _node_point(node) - Vector2(13, 13), 0.16)
		Audio.sfx(&"ui_tick", -4.0, 0.3)
		await travel.finished
		var correct: bool = path[path.size() - 1] == wanted[index]
		Audio.sfx(&"ui_confirm" if correct else &"ui_error", -6.0)
		_refresh()
		await get_tree().create_timer(0.1).timeout
	_capsule_marker.visible = false
	_running = false
	if puzzle.is_solved():
		_status.text = _story.text("puzzle.solved")
		Audio.sfx(&"victory")
		if not _already_solved:
			_already_solved = true
			solved.emit()
	else:
		_status.text = "%d of %d souls reached the right department. Reset and try another setup." % [puzzle.correct_count(), TubePuzzle.CAPSULES]
	_refresh()
