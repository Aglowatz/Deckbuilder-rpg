class_name RecipePuzzleScreen
extends OverlayScreen
## The Endless Buffet's recipe logic puzzle (see `RecipePuzzle`): read the clues, pick four of six ingredients
## and put them in the pot in order, then serve the stew. Serving gives only "right" or "wrong". Emits `solved`
## once; the scene grants the one-time reward.

signal solved

const SLOT_SIZE: Vector2 = Vector2(250, 96)

var order: Array[int] = []
var _story: ZoneStoryText
var _names: Array[String] = []
var _slot_buttons: Array[FancyButton] = []
var _ingredient_buttons: Array[FancyButton] = []
var _status: Label
var _already_solved: bool = false
var _tried: int = 0
var _pot: Control
var _time: float = 0.0


func _init() -> void:
	screen_title = "The Mystery Stew Pot"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.current()
	_already_solved = Session.flag(ZoneDefs.current().flag_puzzle_solved)
	_names = _story.get_lines("recipe.ingredients")
	var intro: Label = UIKit.label("\n".join(_story.get_lines("recipe.intro")), &"MutedLabel", 21)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.custom_minimum_size = Vector2(1700, 0)
	body.add_child(intro)
	var columns: HBoxContainer = UIKit.hbox(40)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(columns)
	columns.add_child(_clue_board())
	columns.add_child(_cooking_column())
	_refresh()
	if _already_solved:
		_status.text = _story.text("recipe.already")


func _clue_board() -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.custom_minimum_size = Vector2(880, 0)
	var column: VBoxContainer = UIKit.vbox(10)
	panel.add_child(UIKit.margin(column, 18))
	column.add_child(UIKit.label("The recipe card (clues)", &"HeadingLabel", 30))
	for index: int in range(RecipePuzzle.clues().size()):
		var clue: Label = UIKit.label("%d.  %s" % [index + 1, _story.text("recipe.clue.%d" % (index + 1))], &"", 24, UIStyle.PARCHMENT)
		clue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		clue.custom_minimum_size = Vector2(820, 0)
		column.add_child(clue)
	return panel


func _cooking_column() -> Control:
	var column: VBoxContainer = UIKit.vbox(14)
	column.custom_minimum_size = Vector2(880, 0)
	column.add_child(UIKit.label("The pot (first in, first out)", &"HeadingLabel", 30))
	_pot = Control.new()
	_pot.custom_minimum_size = Vector2(860, 120)
	_pot.draw.connect(_draw_pot)
	column.add_child(_pot)
	var slots: HBoxContainer = UIKit.hbox(12)
	column.add_child(slots)
	for slot: int in range(RecipePuzzle.SLOTS):
		var button: FancyButton = FancyButton.make("", &"", Vector2(200, 80))
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: _remove_slot(slot))
		slots.add_child(button)
		_slot_buttons.append(button)
	column.add_child(UIKit.label("The pantry (click to add to the pot)", &"HeadingLabel", 26))
	var grid: GridContainer = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	column.add_child(grid)
	for ingredient: int in range(RecipePuzzle.INGREDIENT_COUNT):
		var button: FancyButton = FancyButton.make(_names[ingredient] if ingredient < _names.size() else str(ingredient), &"PrimaryButton", Vector2(270, 70))
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: _add(ingredient))
		grid.add_child(button)
		_ingredient_buttons.append(button)
	_status = UIKit.label("", &"", 24, UIStyle.GOLD)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(860, 80)
	column.add_child(_status)
	var row: HBoxContainer = UIKit.hbox(14)
	column.add_child(row)
	var serve: FancyButton = FancyButton.make("Serve the stew", &"PrimaryButton", Vector2(280, 64))
	serve.pressed.connect(_serve)
	row.add_child(serve)
	var clear: FancyButton = FancyButton.make("Empty the pot", &"", Vector2(230, 64))
	clear.pressed.connect(_clear)
	row.add_child(clear)
	var hint: FancyButton = FancyButton.make("Hint", &"GhostButton", Vector2(150, 64))
	hint.pressed.connect(func() -> void: _status.text = "\n".join(_story.get_lines("recipe.hint")))
	row.add_child(hint)
	return column


func _process(delta: float) -> void:
	_time += delta
	if _pot != null:
		_pot.queue_redraw()


func _add(ingredient: int) -> void:
	if order.has(ingredient) or order.size() >= RecipePuzzle.SLOTS:
		Audio.sfx(&"ui_error", -6.0)
		return
	order.append(ingredient)
	Audio.sfx(&"ui_toggle")
	_status.text = ""
	_refresh()


func _remove_slot(slot: int) -> void:
	if slot >= order.size():
		return
	order.remove_at(slot)
	Audio.sfx(&"ui_back", -4.0)
	_status.text = ""
	_refresh()


func _clear() -> void:
	order.clear()
	_status.text = ""
	Audio.sfx(&"ui_back")
	_refresh()


func _refresh() -> void:
	for slot: int in range(RecipePuzzle.SLOTS):
		_slot_buttons[slot].text = "%d: %s" % [slot + 1, _names[order[slot]]] if slot < order.size() else "%d: (empty)" % (slot + 1)
	for ingredient: int in range(_ingredient_buttons.size()):
		_ingredient_buttons[ingredient].disabled = order.has(ingredient)
	if _pot != null:
		_pot.queue_redraw()


func _serve() -> void:
	if not RecipePuzzle.is_complete(order):
		Audio.sfx(&"ui_error")
		_status.text = _story.text("recipe.incomplete")
		return
	if RecipePuzzle.is_solved(order):
		_status.text = _story.text("recipe.solved")
		Audio.sfx(&"victory")
		if not _already_solved:
			_already_solved = true
			solved.emit()
		return
	_tried += 1
	Audio.sfx(&"ui_error")
	var lines: Array[String] = _story.get_lines("recipe.wrong")
	_status.text = lines[(_tried - 1) % lines.size()]


func _draw_pot() -> void:
	var centre: Vector2 = Vector2(430, 60)
	_pot.draw_rect(Rect2(Vector2.ZERO, _pot.size), Color(0.1, 0.07, 0.04, 0.6), true)
	_pot.draw_arc(centre + Vector2(0, 8), 150.0, 0.0, PI, 32, Color(0.5, 0.52, 0.58), 12.0)
	_pot.draw_rect(Rect2(centre + Vector2(-150, 4), Vector2(300, 40)), Color(0.4, 0.42, 0.48), true)
	var stew_color: Color = Color(0.45, 0.75, 0.25) if _already_solved else Color(0.7, 0.4, 0.15)
	_pot.draw_rect(Rect2(centre + Vector2(-140, 0), Vector2(280, 14)), stew_color, true)
	for index: int in range(order.size()):
		var bubble: Vector2 = centre + Vector2(-100.0 + 66.0 * float(index), -18.0 + sin(_time * 3.0 + float(index)) * 6.0)
		_pot.draw_circle(bubble, 20.0, [Color("f08a3a"), Color("e8e0c8"), Color("9a7a50"), Color("d64b4b"), Color("5aa040"), Color("e8a030")][order[index] % 6])
	_pot.draw_string(UIStyle.font_bold(), Vector2(20, 34), "Ingredients in the pot: %d / %d" % [order.size(), RecipePuzzle.SLOTS], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, UIStyle.PARCHMENT)
