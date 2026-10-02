class_name WheelPuzzleScreen
extends OverlayScreen
## The Gainlands' power-routing puzzle (see `WheelPuzzle`): six hamster wheels, three machines. Each
## wheel's switch cycles Idle -> machine A -> machine B; "Engage" tests the setup. Emits `solved` once;
## the scene grants the one-time reward.

signal solved

const WHEEL_X: float = 140.0
const MACHINE_X: float = 1300.0
const ROW_Y: float = 70.0
const ROW_STEP: float = 105.0

var switches: Array[int] = [0, 0, 0, 0, 0, 0]
var _story: ZoneStoryText
var _canvas: Control
var _buttons: Array[FancyButton] = []
var _status: Label
var _time: float = 0.0
var _already_solved: bool = false
var _names: Array[String] = []
var _machine_names: Array[String] = []


func _init() -> void:
	screen_title = "Power Grid Control Panel"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.current()
	_already_solved = Session.flag(ZoneDefs.current().flag_puzzle_solved)
	_names = _story.get_lines("wheel.wheel_names")
	_machine_names = _story.get_lines("wheel.machines")
	var intro: Label = UIKit.label("\n".join(_story.get_lines("wheel.intro")), &"MutedLabel", 20)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(1500, 0)
	body.add_child(intro)
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(1850, 700)
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.draw.connect(_draw_grid)
	body.add_child(_canvas)
	for wheel: int in range(WheelPuzzle.WHEELS):
		var button: FancyButton = FancyButton.make("", &"PrimaryButton", Vector2(300, 64))
		button.position = Vector2(WHEEL_X + 430.0, ROW_Y + ROW_STEP * float(wheel) - 32.0)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: _cycle(wheel))
		_canvas.add_child(button)
		_buttons.append(button)
	_status = UIKit.label("", &"", 24, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_status.position = Vector2(300, 660)
	_status.size = Vector2(1300, 80)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_canvas.add_child(_status)
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_child(row)
	var engage: FancyButton = FancyButton.make("Engage the grid", &"PrimaryButton", Vector2(300, 60))
	engage.pressed.connect(_engage)
	row.add_child(engage)
	var reset_button: FancyButton = FancyButton.make("Reset", &"", Vector2(200, 60))
	reset_button.pressed.connect(_reset)
	row.add_child(reset_button)
	var hint: FancyButton = FancyButton.make("Hint", &"GhostButton", Vector2(160, 60))
	hint.pressed.connect(func() -> void: _status.text = "\n".join(_story.get_lines("wheel.hint")))
	row.add_child(hint)
	_refresh()
	if _already_solved:
		_status.text = _story.text("wheel.already")


func _process(delta: float) -> void:
	_time += delta
	if _canvas != null:
		_canvas.queue_redraw()


func _row_point(wheel: int) -> Vector2:
	return Vector2(WHEEL_X, ROW_Y + ROW_STEP * float(wheel))


func _machine_point(machine: int) -> Vector2:
	return Vector2(MACHINE_X, 130.0 + 220.0 * float(machine))


func _cycle(wheel: int) -> void:
	switches[wheel] = (switches[wheel] + 1) % WheelPuzzle.SWITCH_STATES
	Audio.sfx(&"ui_toggle")
	_status.text = ""
	_refresh()


func _reset() -> void:
	switches = [0, 0, 0, 0, 0, 0]
	_status.text = ""
	Audio.sfx(&"ui_back")
	_refresh()


func _refresh() -> void:
	for wheel: int in range(WheelPuzzle.WHEELS):
		var state: int = switches[wheel]
		var machine: int = WheelPuzzle.machine_of(wheel, state)
		_buttons[wheel].text = "Idle (napping)" if machine < 0 else "Feed  %s" % _machine_names[machine]
	_canvas.queue_redraw()


func _draw_grid() -> void:
	var delivered: Array[int] = WheelPuzzle.delivered(switches)
	var running: int = WheelPuzzle.running(switches)
	for wheel: int in range(WheelPuzzle.WHEELS):
		var centre: Vector2 = _row_point(wheel)
		var state: int = switches[wheel]
		var active: bool = state > 0
		# The wheel: a ring with spokes, spinning when it is running.
		var spin: float = _time * (4.0 if active else 0.0) + float(wheel)
		_canvas.draw_arc(centre, 34.0, 0.0, TAU, 28, Color(0.82, 0.62, 0.3) if active else Color(0.5, 0.42, 0.3), 5.0)
		for spoke: int in range(6):
			var angle: float = spin + TAU * float(spoke) / 6.0
			_canvas.draw_line(centre, centre + Vector2(cos(angle), sin(angle)) * 32.0, Color(0.7, 0.55, 0.3), 3.0)
		_canvas.draw_string(UIStyle.font_bold(), centre + Vector2(58, 8), "%s   %d W" % [_names[wheel], WheelPuzzle.OUTPUT[wheel]], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, UIStyle.PARCHMENT)
		# Both pipes to its two machines; the live one glows.
		for option: int in range(2):
			var machine: int = WheelPuzzle.WIRING[wheel][option] as int
			var live: bool = state == option + 1
			var from: Vector2 = Vector2(WHEEL_X + 740.0, centre.y)
			var to: Vector2 = _machine_point(machine) - Vector2(150, 0)
			_canvas.draw_line(from, to, Color(0.35, 1.0, 0.9) if live else Color(0.27, 0.3, 0.34), 7.0 if live else 3.0)
	for machine: int in range(WheelPuzzle.MACHINES):
		var origin: Vector2 = _machine_point(machine)
		var target: int = WheelPuzzle.TARGET[machine]
		var have: int = delivered[machine]
		var color: Color = UIStyle.GOOD if have == target else (Color("ff8a85") if have > target else Color("ffcf70"))
		_canvas.draw_rect(Rect2(origin - Vector2(150, 50), Vector2(300, 100)), Color(0.12, 0.13, 0.18), true)
		_canvas.draw_rect(Rect2(origin - Vector2(150, 50), Vector2(300, 100)), color, false, 4.0)
		_canvas.draw_string(UIStyle.font_title(), origin + Vector2(-134, -14), _machine_names[machine], HORIZONTAL_ALIGNMENT_LEFT, -1, 30, UIStyle.PARCHMENT)
		_canvas.draw_string(UIStyle.font_bold(), origin + Vector2(-134, 22), "%d / %d W" % [have, target], HORIZONTAL_ALIGNMENT_LEFT, -1, 28, color)
		var fraction: float = clampf(float(have) / float(maxi(target, 1)), 0.0, 1.5) / 1.5
		_canvas.draw_rect(Rect2(origin + Vector2(-134, 32), Vector2(268.0 * fraction, 10)), color, true)
	var tired: Color = Color("ff8a85") if running > WheelPuzzle.MAX_RUNNING else UIStyle.PARCHMENT
	_canvas.draw_string(UIStyle.font_bold(), Vector2(MACHINE_X - 150.0, 600.0), "Wheels running: %d / %d" % [running, WheelPuzzle.MAX_RUNNING], HORIZONTAL_ALIGNMENT_LEFT, -1, 26, tired)


func _engage() -> void:
	var delivered: Array[int] = WheelPuzzle.delivered(switches)
	if WheelPuzzle.is_solved(switches):
		_status.text = _story.text("wheel.solved")
		Audio.sfx(&"victory")
		if not _already_solved:
			_already_solved = true
			solved.emit()
		return
	Audio.sfx(&"ui_error")
	if WheelPuzzle.running(switches) > WheelPuzzle.MAX_RUNNING:
		_status.text = "Too many wheels running - the hamsters are exhausted (max %d)." % WheelPuzzle.MAX_RUNNING
		return
	var notes: PackedStringArray = []
	for machine: int in range(WheelPuzzle.MACHINES):
		var target: int = WheelPuzzle.TARGET[machine]
		if delivered[machine] < target:
			notes.append("%s is %d W short" % [_machine_names[machine], target - delivered[machine]])
		elif delivered[machine] > target:
			notes.append("%s has %d W too much" % [_machine_names[machine], delivered[machine] - target])
	_status.text = "The grid sputters: %s." % ", ".join(notes)
