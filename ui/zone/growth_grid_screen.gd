class_name GrowthGridScreen
extends OverlayScreen
## The Verdant Dump's puzzle (see `GrowthGrid`): a 5 x 5 garden. Plant a seed in a plot and that plot and its four
## neighbours flip between bare and in bloom. Bring every plot into bloom. Emits `solved` once; the scene grants the
## one-time reward.

signal solved

var board: Array[bool] = []
var plantings: int = 0
var _story: ZoneStoryText
var _buttons: Array[FancyButton] = []
var _status: Label
var _counter: Label
var _already_solved: bool = false


func _init() -> void:
	screen_title = "The Seed Shrine"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.current()
	_already_solved = Session.flag(ZoneDefs.current().flag_puzzle_solved)
	board = GrowthGrid.start_board()
	var intro: Label = UIKit.label("\n".join(_story.get_lines("growth.intro")), &"MutedLabel", 21)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(1700, 0)
	body.add_child(intro)
	var center: CenterContainer = CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var column: VBoxContainer = UIKit.vbox(14)
	center.add_child(column)
	_counter = UIKit.label("", &"HeadingLabel", 30, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_counter)
	var grid: GridContainer = GridContainer.new()
	grid.columns = GrowthGrid.SIZE
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	column.add_child(grid)
	for cell: int in range(GrowthGrid.CELLS):
		var button: FancyButton = FancyButton.make("", &"", Vector2(150, 96))
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: _plant(cell))
		grid.add_child(button)
		_buttons.append(button)
	_status = UIKit.label("", &"", 24, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(1100, 60)
	column.add_child(_status)
	var row: HBoxContainer = UIKit.hbox(14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	var reset_button: FancyButton = FancyButton.make("Reset the garden", &"", Vector2(280, 60))
	reset_button.pressed.connect(_reset)
	row.add_child(reset_button)
	var hint: FancyButton = FancyButton.make("Hint", &"GhostButton", Vector2(160, 60))
	hint.pressed.connect(func() -> void: _status.text = "\n".join(_story.get_lines("growth.hint")))
	row.add_child(hint)
	_refresh()
	if _already_solved:
		_status.text = _story.text("growth.already")


func _plant(cell: int) -> void:
	board = GrowthGrid.plant(board, cell)
	plantings += 1
	Audio.sfx(&"ui_toggle")
	_status.text = ""
	_refresh()
	if GrowthGrid.is_solved(board):
		_status.text = _story.text("growth.solved")
		Audio.sfx(&"victory")
		if not _already_solved:
			_already_solved = true
			solved.emit()


func _reset() -> void:
	board = GrowthGrid.start_board()
	plantings = 0
	_status.text = ""
	Audio.sfx(&"ui_back")
	_refresh()


func _refresh() -> void:
	var blooming: int = 0
	for cell: int in range(GrowthGrid.CELLS):
		var bloom: bool = board[cell]
		if bloom:
			blooming += 1
		_buttons[cell].text = "BLOOM" if bloom else "bare"
		_buttons[cell].self_modulate = Color(1.0, 0.65, 0.85) if bloom else Color(0.55, 0.45, 0.35)
	_counter.text = "In bloom: %d / %d      Seeds planted: %d" % [blooming, GrowthGrid.CELLS, plantings]
