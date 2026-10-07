class_name OrderGameScreen
extends OverlayScreen
## The Endless Buffet's minigame, "Order Up!" (see `OrderGame`): an assembly game hosted by Chef Flambe Fontaine.
## A ticket names a dish; press the ingredient stations in order (click, or keys 1-6) before the ticket's timer
## runs out. A wrong ingredient tosses the plate and costs time.

signal game_finished(stars: int, reward: Dictionary)

const COUNTDOWN: float = 3.0
const STATION_COLORS: Array[Color] = [
	Color(0.92, 0.7, 0.36), Color(0.52, 0.28, 0.16), Color(1.0, 0.84, 0.25),
	Color(0.45, 0.78, 0.3), Color(0.88, 0.2, 0.2), Color(0.98, 0.78, 0.25),
]

var game: OrderGame
var _story: ZoneStoryText
var _stations: Array[String] = []
var _dishes: Array[String] = []
var _canvas: Control
var _status: Label
var _result_box: VBoxContainer
var _start_button: FancyButton
var _station_buttons: Array[FancyButton] = []
var _clock: float = 0.0
## "idle", "countdown", "playing" or "done".
var _state: String = "idle"
var _flash_text: String = ""
var _flash_color: Color = Color.WHITE
var _flash_time: float = 0.0
var _last_ticket: int = -1


func _init() -> void:
	screen_title = "Dinner in a Dash: Order Up!"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.current()
	_stations = _story.get_lines("order.stations")
	_dishes = _story.get_lines("order.dishes")
	var column: VBoxContainer = UIKit.vbox(10)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(column)
	_status = UIKit.label("\n".join(_story.get_lines("order.intro")), &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(1500, 0)
	column.add_child(_status)
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(1850, 470)
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.draw.connect(_draw_counter)
	column.add_child(_canvas)
	_result_box = UIKit.vbox(10)
	column.add_child(_result_box)
	var row: HBoxContainer = UIKit.hbox(14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	for station: int in range(OrderGame.STATION_COUNT):
		var button: FancyButton = FancyButton.make("%d  %s" % [station + 1, _stations[station] if station < _stations.size() else "?"], &"PrimaryButton", Vector2(270, 74))
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: _press(station))
		row.add_child(button)
		_station_buttons.append(button)
	var start_row: HBoxContainer = UIKit.hbox(14)
	start_row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(start_row)
	_start_button = FancyButton.make("Start the shift", &"PrimaryButton", Vector2(320, 66))
	_start_button.focus_mode = Control.FOCUS_NONE
	_start_button.pressed.connect(_start)
	start_row.add_child(_start_button)
	game = OrderGame.new()
	_refresh_buttons()


func _start() -> void:
	game = OrderGame.new()
	for child: Node in _result_box.get_children():
		child.queue_free()
	_clock = -COUNTDOWN
	_state = "countdown"
	_flash_text = ""
	_last_ticket = -1
	_status.text = "Aprons on..."
	Audio.sfx(&"ui_confirm")
	_refresh_buttons()


func _refresh_buttons() -> void:
	_start_button.visible = _state == "idle" or _state == "done"
	_start_button.text = "Start the shift" if _state == "idle" else "Another shift"
	for button: FancyButton in _station_buttons:
		button.disabled = _state != "playing"


func _input(event: InputEvent) -> void:
	if _state != "playing":
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: int = int((event as InputEventKey).keycode)
		if code >= KEY_1 and code <= KEY_6:
			get_viewport().set_input_as_handled()
			_press(code - KEY_1)


func _press(station: int) -> void:
	if _state != "playing" or _clock < 0.0:
		return
	var result: OrderGame.Result = game.press(station, _clock)
	match result:
		OrderGame.Result.ADDED:
			Audio.sfx(&"ui_tick", -2.0, 0.15)
		OrderGame.Result.WRONG:
			_flash("TOSSED!", Color("ff8a85"))
			Audio.sfx(&"ui_error", -6.0)
		OrderGame.Result.SERVED:
			var earned: int = int(game.points_per_ticket[game.points_per_ticket.size() - 1])
			_flash(["", "SERVED", "NICE!", "ORDER UP!"][earned], [Color.WHITE, Color.WHITE, UIStyle.GOOD, UIStyle.GOLD][earned] as Color)
			Audio.sfx(&"ding", 0.0, 0.05)


func _flash(text: String, color: Color) -> void:
	_flash_text = text
	_flash_color = color
	_flash_time = 0.8


func _process(delta: float) -> void:
	_flash_time = maxf(0.0, _flash_time - delta)
	if _state == "countdown" or _state == "playing":
		_clock += delta
		if _state == "countdown" and _clock >= 0.0:
			_state = "playing"
			game.start(0.0)
			_status.text = "GO!"
			_refresh_buttons()
		if _state == "playing":
			if game.advance(_clock):
				_flash("86'D!", Color("ff8a85"))
				Audio.sfx(&"ui_error", -4.0)
			if game.current != _last_ticket and not game.is_finished():
				_last_ticket = game.current
				var shouts: Array[String] = _story.get_lines("order.shouts")
				_status.text = "\"%s\"" % shouts[game.current % shouts.size()]
			if game.is_finished() and not game.in_gap(_clock):
				_finish()
	if _canvas != null:
		_canvas.queue_redraw()


func _draw_counter() -> void:
	var area: Vector2 = _canvas.size
	_canvas.draw_rect(Rect2(Vector2.ZERO, area), Color(0.16, 0.09, 0.07, 0.6))
	# The ticket rail.
	_canvas.draw_rect(Rect2(Vector2(60, 24), Vector2(area.x - 120.0, 8)), Color(0.7, 0.72, 0.78))
	if _state == "countdown":
		_canvas.draw_string(UIStyle.font_title(), Vector2(area.x * 0.5 - 30.0, area.y * 0.55), str(maxi(int(ceilf(-_clock)), 1)), HORIZONTAL_ALIGNMENT_LEFT, -1, 120, UIStyle.GOLD)
		return
	if _state != "playing" and _state != "done":
		_canvas.draw_string(UIStyle.font_title(), Vector2(area.x * 0.5 - 340.0, area.y * 0.5), "Chef Turbo's kitchen is open.", HORIZONTAL_ALIGNMENT_CENTER, 680, 52, UIStyle.PARCHMENT)
		return
	var ticket_index: int = mini(game.current, OrderGame.TICKET_COUNT - 1)
	if _state == "playing" and not game.is_finished():
		var recipe: Array = game.recipe()
		var dish_name: String = _dishes[game.dish_index()] if game.dish_index() < _dishes.size() else "Dish"
		# The ticket paper.
		var ticket: Rect2 = Rect2(Vector2(90, 46), Vector2(560, 380))
		_canvas.draw_rect(ticket, Color(0.99, 0.97, 0.86))
		_canvas.draw_rect(ticket, Color(0.8, 0.15, 0.15), false, 5.0)
		_canvas.draw_string(UIStyle.font_title(), ticket.position + Vector2(24, 54), "Ticket %d / %d" % [ticket_index + 1, OrderGame.TICKET_COUNT], HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color(0.5, 0.1, 0.1))
		_canvas.draw_string(UIStyle.font_title(), ticket.position + Vector2(24, 104), dish_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color(0.15, 0.1, 0.08))
		for index: int in range(recipe.size()):
			var station: int = int(recipe[index])
			var done: bool = index < game.plate.size()
			var color: Color = STATION_COLORS[station]
			var y: float = ticket.position.y + 138.0 + float(index) * 36.0
			_canvas.draw_rect(Rect2(Vector2(ticket.position.x + 26, y), Vector2(28, 28)), color if done else color.darkened(0.55))
			var label_text: String = "%s%s" % ["[x] " if done else "[ ] ", _stations[station] if station < _stations.size() else "?"]
			_canvas.draw_string(UIStyle.font_bold(), Vector2(ticket.position.x + 68, y + 24.0), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.15, 0.1, 0.08) if not done else Color(0.1, 0.5, 0.15))
		# The timer bar.
		var fraction: float = clampf(game.time_left(_clock) / game.ticket_seconds(), 0.0, 1.0)
		var bar: Rect2 = Rect2(Vector2(720, 70), Vector2(1020, 38))
		_canvas.draw_rect(bar, Color(0.1, 0.07, 0.07))
		var bar_color: Color = Color("5fd47a") if fraction >= 0.5 else (Color("f2c94c") if fraction >= 0.25 else Color("e0504a"))
		_canvas.draw_rect(Rect2(bar.position, Vector2(bar.size.x * fraction, bar.size.y)), bar_color)
		_canvas.draw_rect(bar, Color(1, 1, 1, 0.5), false, 3.0)
		_canvas.draw_string(UIStyle.font_bold(), Vector2(720, 140), "%.1f s left" % game.time_left(_clock), HORIZONTAL_ALIGNMENT_LEFT, -1, 28, UIStyle.PARCHMENT)
		# The plate: the stack so far.
		var plate_centre: Vector2 = Vector2(1230, 330)
		_canvas.draw_circle(plate_centre + Vector2(0, 40), 130.0, Color(0.95, 0.95, 0.97))
		_canvas.draw_circle(plate_centre + Vector2(0, 40), 104.0, Color(0.85, 0.87, 0.92))
		for index: int in range(game.plate.size()):
			var layer: int = int(game.plate[index])
			_canvas.draw_rect(Rect2(plate_centre + Vector2(-80, 20.0 - float(index) * 22.0), Vector2(160, 20)), STATION_COLORS[layer])
	# The score strip: one dot per ticket.
	for ticket_dot: int in range(OrderGame.TICKET_COUNT):
		var centre: Vector2 = Vector2(780.0 + float(ticket_dot) * 58.0, area.y - 40.0)
		var dot_color: Color = Color(0.4, 0.4, 0.46)
		if ticket_dot < game.points_per_ticket.size():
			dot_color = [Color("e06a5a"), Color(0.9, 0.9, 0.9), UIStyle.GOOD, UIStyle.GOLD][game.points_per_ticket[ticket_dot]]
		_canvas.draw_circle(centre, 20.0, Color(0, 0, 0, 0.6))
		_canvas.draw_circle(centre, 16.0, dot_color)
	_canvas.draw_string(UIStyle.font_bold(), Vector2(60, area.y - 30.0), "Points %d / %d     Tossed plates %d" % [game.points(), OrderGame.max_points(), game.mistakes], HORIZONTAL_ALIGNMENT_LEFT, -1, 26, UIStyle.PARCHMENT)
	if _flash_time > 0.0:
		_canvas.draw_string(UIStyle.font_title(), Vector2(area.x * 0.5 - 200.0, 220.0), _flash_text, HORIZONTAL_ALIGNMENT_CENTER, 400, 64, _flash_color)


func _finish() -> void:
	_state = "done"
	var stars: int = game.stars()
	var reward: Dictionary = OrderGame.apply_result(stars)
	var lines: Array[String] = _story.get_lines("order.win") if stars > 0 else _story.get_lines("order.lose")
	if bool(reward["first_win"]):
		lines = _story.get_lines("order.first") + lines
	_status.text = "\n".join(lines)
	Audio.sfx(&"victory" if stars > 0 else &"defeat")
	var parts: PackedStringArray = []
	parts.append("%s  (%d points)" % [("★".repeat(stars) + "☆".repeat(3 - stars)) if stars > 0 else "Shift failed", game.points()])
	if int(reward["gold"]) > 0:
		parts.append("+%d gold" % int(reward["gold"]))
	if int(reward["xp"]) > 0:
		parts.append("+%d XP" % int(reward["xp"]))
	if not PackRewards.minigame_text(reward).is_empty():
		parts.append(PackRewards.minigame_text(reward))
	if not str(reward["item"]).is_empty() and Session.content.item(str(reward["item"])) != null:
		parts.append(Session.content.item(str(reward["item"])).display_name)
	_result_box.add_child(UIKit.label("   ".join(parts), &"", 30, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	_refresh_buttons()
	game_finished.emit(stars, reward)
