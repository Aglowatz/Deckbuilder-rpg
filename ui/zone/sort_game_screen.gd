class_name SortGameScreen
extends OverlayScreen
## The Verdant Heap's minigame, "Sort It Out!" (see `SortGame`): a recycling-sorting game hosted by Blue-Ribbon Bev
## Pettigrew. Junk rides down the conveyor; send the front piece to the right bin (click a bin, or keys 1-4 / the arrow
## keys) before it reaches the end.

signal game_finished(stars: int, reward: Dictionary)

const COUNTDOWN: float = 3.0
const BIN_COLORS: Array[Color] = [Color(0.45, 0.32, 0.18), Color(0.55, 0.6, 0.66), Color(0.35, 0.7, 0.5), Color(0.3, 0.5, 0.85)]
const ITEM_COLORS: Array[Color] = [Color(0.6, 0.4, 0.2), Color(0.7, 0.72, 0.78), Color(0.45, 0.85, 0.6), Color(0.95, 0.92, 0.8)]

var game: SortGame
var _story: ZoneStoryText
var _bins: Array[String] = []
var _items: Array[String] = []
var _canvas: Control
var _status: Label
var _result_box: VBoxContainer
var _start_button: FancyButton
var _bin_buttons: Array[FancyButton] = []
var _clock: float = 0.0
## "idle", "countdown", "playing" or "done".
var _state: String = "idle"
var _flash_text: String = ""
var _flash_color: Color = Color.WHITE
var _flash_time: float = 0.0


func _init() -> void:
	screen_title = "County Fair: Sort It Out!"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.current()
	_bins = _story.get_lines("sort.bins")
	_items = _story.get_lines("sort.items")
	var column: VBoxContainer = UIKit.vbox(10)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(column)
	_status = UIKit.label("\n".join(_story.get_lines("sort.intro")), &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(1500, 0)
	column.add_child(_status)
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(1850, 430)
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.draw.connect(_draw_belt)
	column.add_child(_canvas)
	_result_box = UIKit.vbox(10)
	column.add_child(_result_box)
	var row: HBoxContainer = UIKit.hbox(14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	for bin: int in range(SortGame.BIN_COUNT):
		var button: FancyButton = FancyButton.make("%d  %s" % [bin + 1, _bins[bin] if bin < _bins.size() else "?"], &"PrimaryButton", Vector2(300, 74))
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: _press(bin))
		row.add_child(button)
		_bin_buttons.append(button)
	var start_row: HBoxContainer = UIKit.hbox(14)
	start_row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(start_row)
	_start_button = FancyButton.make("Start the run", &"PrimaryButton", Vector2(320, 66))
	_start_button.focus_mode = Control.FOCUS_NONE
	_start_button.pressed.connect(_start)
	start_row.add_child(_start_button)
	game = SortGame.new()
	_refresh_buttons()


func _start() -> void:
	game = SortGame.new()
	for child: Node in _result_box.get_children():
		child.queue_free()
	_clock = -COUNTDOWN
	_state = "countdown"
	_flash_text = ""
	_status.text = "Gloves on..."
	Audio.sfx(&"ui_confirm")
	_refresh_buttons()


func _refresh_buttons() -> void:
	_start_button.visible = _state == "idle" or _state == "done"
	_start_button.text = "Start the run" if _state == "idle" else "Another run"
	for button: FancyButton in _bin_buttons:
		button.disabled = _state != "playing"


func _input(event: InputEvent) -> void:
	if _state != "playing":
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: int = int((event as InputEventKey).keycode)
		var bin: int = -1
		if code >= KEY_1 and code <= KEY_4:
			bin = code - KEY_1
		elif code == KEY_LEFT:
			bin = 0
		elif code == KEY_DOWN:
			bin = 1
		elif code == KEY_UP:
			bin = 2
		elif code == KEY_RIGHT:
			bin = 3
		if bin >= 0:
			get_viewport().set_input_as_handled()
			_press(bin)


func _press(bin: int) -> void:
	if _state != "playing" or _clock < 0.0:
		return
	match game.press(bin, _clock):
		SortGame.Result.CORRECT:
			_flash("+%d" % [1 if game.streak < 4 else (2 if game.streak < 8 else 3)], UIStyle.GOOD)
			Audio.sfx(&"ui_tick", -2.0, 0.15)
		SortGame.Result.WRONG:
			_flash("WRONG BIN!", Color("ff8a85"))
			Audio.sfx(&"ui_error", -6.0)


func _flash(text: String, color: Color) -> void:
	_flash_text = text
	_flash_color = color
	_flash_time = 0.7


func _process(delta: float) -> void:
	_flash_time = maxf(0.0, _flash_time - delta)
	if _state == "countdown" or _state == "playing":
		_clock += delta
		if _state == "countdown" and _clock >= 0.0:
			_state = "playing"
			_status.text = "GO!"
			_refresh_buttons()
		if _state == "playing":
			if game.advance(_clock) > 0:
				_flash("MISSED!", Color("ff8a85"))
				Audio.sfx(&"ui_error", -8.0)
			if not game.is_finished():
				var shouts: Array[String] = _story.get_lines("sort.shouts")
				_status.text = "\"%s\"" % shouts[(game.next_piece / 4) % shouts.size()]
			if game.is_finished():
				_finish()
	if _canvas != null:
		_canvas.queue_redraw()


func _draw_belt() -> void:
	var area: Vector2 = _canvas.size
	_canvas.draw_rect(Rect2(Vector2.ZERO, area), Color(0.1, 0.14, 0.1, 0.6))
	var belt: Rect2 = Rect2(Vector2(100, 160), Vector2(area.x - 200.0, 80))
	_canvas.draw_rect(belt, Color(0.2, 0.2, 0.22))
	for tick: int in range(40):
		var x: float = belt.position.x + fposmod(float(tick) * 44.0 - _clock * 60.0, belt.size.x)
		_canvas.draw_line(Vector2(x, belt.position.y + 4.0), Vector2(x, belt.end.y - 4.0), Color(0.3, 0.3, 0.34), 3.0)
	_canvas.draw_rect(belt, Color(0.6, 0.62, 0.66), false, 4.0)
	_canvas.draw_string(UIStyle.font_bold(), Vector2(belt.position.x, belt.position.y - 14.0), "ENTRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, UIStyle.MUTED)
	_canvas.draw_string(UIStyle.font_bold(), Vector2(belt.end.x - 120.0, belt.position.y - 14.0), "THE EDGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("ff8a85"))
	# The bins at the end of the belt.
	for bin: int in range(SortGame.BIN_COUNT):
		var bin_rect: Rect2 = Rect2(Vector2(belt.end.x - 120.0 + float(bin) * 0.0, 270.0), Vector2(0, 0))
		var origin: Vector2 = Vector2(260.0 + float(bin) * 400.0, 290.0)
		_canvas.draw_rect(Rect2(origin, Vector2(300, 90)), BIN_COLORS[bin])
		_canvas.draw_rect(Rect2(origin, Vector2(300, 90)), Color(1, 1, 1, 0.5), false, 4.0)
		_canvas.draw_string(UIStyle.font_title(), origin + Vector2(20, 58), "%d  %s" % [bin + 1, _bins[bin] if bin < _bins.size() else "?"], HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color(1, 1, 1))
		bin_rect.size = Vector2.ZERO
	if _state == "countdown":
		_canvas.draw_string(UIStyle.font_title(), Vector2(area.x * 0.5 - 30.0, 120.0), str(maxi(int(ceilf(-_clock)), 1)), HORIZONTAL_ALIGNMENT_LEFT, -1, 100, UIStyle.GOLD)
	if _state == "playing":
		# The pieces on the belt, front piece highlighted.
		for piece: int in range(game.next_piece, SortGame.PIECES):
			if SortGame.spawn_time(piece) > _clock + 0.05:
				break
			var fraction: float = SortGame.progress(piece, _clock)
			var centre: Vector2 = Vector2(belt.position.x + 40.0 + fraction * (belt.size.x - 80.0), belt.position.y + 40.0)
			var item_index: int = SortGame.ORDER[piece]
			var bin: int = SortGame.ITEM_BINS[item_index]
			_canvas.draw_circle(centre, 32.0, Color(0, 0, 0, 0.5))
			_canvas.draw_circle(centre, 28.0, ITEM_COLORS[bin])
			if piece == game.next_piece:
				_canvas.draw_arc(centre, 38.0, 0.0, TAU, 32, UIStyle.GOLD, 4.0)
				var label_text: String = _items[item_index] if item_index < _items.size() else "?"
				_canvas.draw_string(UIStyle.font_title(), Vector2(centre.x - 150.0, belt.end.y + 44.0), label_text, HORIZONTAL_ALIGNMENT_CENTER, 300, 30, UIStyle.PARCHMENT)
	if _flash_time > 0.0:
		_canvas.draw_string(UIStyle.font_title(), Vector2(area.x * 0.5 - 200.0, 90.0), _flash_text, HORIZONTAL_ALIGNMENT_CENTER, 400, 56, _flash_color)
	# Score strip: one dot per piece.
	for piece: int in range(SortGame.PIECES):
		var dot: Vector2 = Vector2(560.0 + float(piece) * 36.0, area.y - 24.0)
		var color: Color = Color(0.35, 0.35, 0.4)
		if piece < game.outcomes.size():
			color = [Color("e06a5a"), Color(0.9, 0.7, 0.3), UIStyle.GOOD][game.outcomes[piece] + 1]
		_canvas.draw_circle(dot, 12.0, Color(0, 0, 0, 0.6))
		_canvas.draw_circle(dot, 9.0, color)
	_canvas.draw_string(UIStyle.font_bold(), Vector2(40, area.y - 16.0), "Points %d     Streak %d     Sorted %d / %d" % [game.points_total, game.streak, game.correct_count(), SortGame.PIECES], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, UIStyle.PARCHMENT)


func _finish() -> void:
	_state = "done"
	var stars: int = game.stars()
	var reward: Dictionary = SortGame.apply_result(stars)
	var lines: Array[String] = _story.get_lines("sort.win") if stars > 0 else _story.get_lines("sort.lose")
	if bool(reward["first_win"]):
		lines = _story.get_lines("sort.first") + lines
	_status.text = "\n".join(lines)
	Audio.sfx(&"victory" if stars > 0 else &"defeat")
	var parts: PackedStringArray = []
	parts.append("%s  (%d sorted, %d points)" % [("★".repeat(stars) + "☆".repeat(3 - stars)) if stars > 0 else "Run failed", game.correct_count(), game.points_total])
	if int(reward["gold"]) > 0:
		parts.append("+%d gold" % int(reward["gold"]))
	if int(reward["xp"]) > 0:
		parts.append("+%d XP" % int(reward["xp"]))
	if not str(reward["item"]).is_empty() and Session.content.item(str(reward["item"])) != null:
		parts.append(Session.content.item(str(reward["item"])).display_name)
	_result_box.add_child(UIKit.label("   ".join(parts), &"", 30, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	_refresh_buttons()
	game_finished.emit(stars, reward)
