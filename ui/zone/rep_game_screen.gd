class_name RepGameScreen
extends OverlayScreen
## The Gainlands' minigame, "Rep Counter" (see `RepGame`): a timing / rhythm lifting game hosted by
## Jazzy Jules. Rings close on the bar; press SPACE (or click PUMP!) the moment each one lands.

signal game_finished(stars: int, reward: Dictionary)

const TARGET_RADIUS: float = 46.0
const RING_START: float = 150.0
const COUNTDOWN: float = 3.0

var game: RepGame
var _story: ZoneStoryText
var _canvas: Control
var _status: Label
var _result_box: VBoxContainer
var _start_button: FancyButton
var _pump_button: FancyButton
var _clock: float = 0.0
## "idle", "countdown", "playing" or "done".
var _state: String = "idle"
var _flash_text: String = ""
var _flash_color: Color = Color.WHITE
var _flash_time: float = 0.0
var _shout: String = ""


func _init() -> void:
	screen_title = "Studio 3 AM: Rep Counter"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.current()
	var column: VBoxContainer = UIKit.vbox(10)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(column)
	_status = UIKit.label("\n".join(_story.get_lines("reps.intro")), &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(1500, 0)
	column.add_child(_status)
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(1850, 560)
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.draw.connect(_draw_set)
	column.add_child(_canvas)
	_result_box = UIKit.vbox(10)
	column.add_child(_result_box)
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	_start_button = FancyButton.make("Start the set", &"PrimaryButton", Vector2(280, 66))
	_start_button.focus_mode = Control.FOCUS_NONE
	_start_button.pressed.connect(_start)
	row.add_child(_start_button)
	_pump_button = FancyButton.make("PUMP!  (Space)", &"PrimaryButton", Vector2(380, 66))
	_pump_button.focus_mode = Control.FOCUS_NONE
	_pump_button.pressed.connect(_pump)
	row.add_child(_pump_button)
	game = RepGame.new()
	_refresh_buttons()


func _start() -> void:
	game = RepGame.new()
	for child: Node in _result_box.get_children():
		child.queue_free()
	_clock = -COUNTDOWN
	_state = "countdown"
	_shout = ""
	_flash_text = ""
	_status.text = "Get ready..."
	Audio.sfx(&"ui_confirm")
	_refresh_buttons()


func _refresh_buttons() -> void:
	_start_button.visible = _state == "idle" or _state == "done"
	_start_button.text = "Start the set" if _state == "idle" else "Another set"
	_pump_button.visible = _state == "playing" or _state == "countdown"


func _input(event: InputEvent) -> void:
	if _state != "playing" and _state != "countdown":
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_pump()


func _pump() -> void:
	if _state != "playing" or _clock < 0.0:
		return
	var rating: int = game.press(_clock)
	if rating < 0:
		return
	_show_rating(rating)


func _show_rating(rating: int) -> void:
	_flash_time = 0.7
	match rating:
		RepGame.Rating.PERFECT:
			_flash_text = "PERFECT!"
			_flash_color = UIStyle.GOLD
			Audio.sfx(&"hit_heavy", -4.0, 0.1)
		RepGame.Rating.GOOD:
			_flash_text = "GOOD"
			_flash_color = UIStyle.GOOD
			Audio.sfx(&"hit_light", -2.0, 0.1)
		RepGame.Rating.OK:
			_flash_text = "OK"
			_flash_color = Color(1, 1, 1)
			Audio.sfx(&"ui_tick", 0.0, 0.1)
		_:
			_flash_text = "MISS"
			_flash_color = Color("ff8a85")
			Audio.sfx(&"ui_error", -6.0)


func _process(delta: float) -> void:
	_flash_time = maxf(0.0, _flash_time - delta)
	if _state == "countdown" or _state == "playing":
		_clock += delta
		if _state == "countdown" and _clock >= 0.0:
			_state = "playing"
			_status.text = "GO!"
			_refresh_buttons()
		if _state == "playing":
			var missed: int = game.advance(_clock)
			if missed > 0:
				_show_rating(RepGame.Rating.MISS)
			_update_shout()
			if game.is_finished() and _clock > RepGame.BEATS[RepGame.REPS - 1] + RepGame.OK_WINDOW + 0.5:
				_finish()
	if _canvas != null:
		_canvas.queue_redraw()


func _update_shout() -> void:
	var shouts: Array[String] = _story.get_lines("reps.shouts")
	var index: int = clampi(game.next_rep, 0, shouts.size() - 1)
	if game.next_rep < RepGame.REPS and RepGame.BEATS[game.next_rep] - _clock < RepGame.APPROACH:
		_shout = shouts[index]
		_status.text = "\"%s\"" % _shout


func _draw_set() -> void:
	var area: Vector2 = _canvas.size
	var centre: Vector2 = Vector2(area.x * 0.5, area.y * 0.46)
	_canvas.draw_rect(Rect2(Vector2.ZERO, area), Color(0.1, 0.05, 0.18, 0.55))
	# The bar: a barbell with boulder plates, bobbing with the beat.
	var lift: float = 0.0
	if _state == "playing" and game.next_rep < RepGame.REPS:
		var dt: float = RepGame.BEATS[game.next_rep] - _clock
		lift = clampf(1.0 - dt / RepGame.APPROACH, 0.0, 1.0) * 26.0
	var bar_y: float = centre.y + 22.0 - lift
	_canvas.draw_line(Vector2(centre.x - 130.0, bar_y), Vector2(centre.x + 130.0, bar_y), Color(0.78, 0.8, 0.86), 8.0)
	for side: float in [-1.0, 1.0]:
		_canvas.draw_circle(Vector2(centre.x + side * 128.0, bar_y), 30.0, Color(0.5, 0.46, 0.44))
		_canvas.draw_circle(Vector2(centre.x + side * 128.0, bar_y), 22.0, Color(0.62, 0.58, 0.56))
	# The target ring and the approaching rings.
	_canvas.draw_arc(centre, TARGET_RADIUS, 0.0, TAU, 40, Color(1, 1, 1, 0.9), 6.0)
	if _state == "playing" or _state == "countdown":
		for rep: int in range(game.next_rep, RepGame.REPS):
			var dt: float = RepGame.BEATS[rep] - _clock
			if dt > RepGame.APPROACH:
				break
			var fraction: float = clampf(dt / RepGame.APPROACH, 0.0, 1.0)
			var radius: float = TARGET_RADIUS + fraction * (RING_START - TARGET_RADIUS)
			var alpha: float = 1.0 - fraction * 0.5
			_canvas.draw_arc(centre, radius, 0.0, TAU, 48, Color(1.0, 0.45, 0.8, alpha), 7.0)
	if _state == "countdown":
		var number: int = int(ceilf(-_clock))
		_canvas.draw_string(UIStyle.font_title(), centre + Vector2(-26, 24), str(maxi(number, 1)), HORIZONTAL_ALIGNMENT_LEFT, -1, 90, UIStyle.GOLD)
	if _state == "playing" and not _shout.is_empty():
		_canvas.draw_string(UIStyle.font_title(), Vector2(centre.x - 500.0, 120.0), _shout, HORIZONTAL_ALIGNMENT_CENTER, 1000, 60, Color(1.0, 0.55, 0.85))
	if _flash_time > 0.0:
		_canvas.draw_string(UIStyle.font_title(), centre + Vector2(-150, -190), _flash_text, HORIZONTAL_ALIGNMENT_CENTER, 300, 64, _flash_color)
	# Rep tracker: eight dots coloured by rating.
	for rep: int in range(RepGame.REPS):
		var dot: Vector2 = Vector2(centre.x - 7.0 * 36.0 * 0.5 - 20.0 + float(rep) * 52.0, area.y - 70.0)
		var color: Color = Color(0.35, 0.35, 0.42)
		if rep < game.ratings.size():
			color = [Color("e06a5a"), Color(0.9, 0.9, 0.9), UIStyle.GOOD, UIStyle.GOLD][game.ratings[rep]]
		_canvas.draw_circle(dot, 17.0, Color(0, 0, 0, 0.6))
		_canvas.draw_circle(dot, 14.0, color)
	_canvas.draw_string(UIStyle.font_bold(), Vector2(40, area.y - 24), "Rep %d / %d      Points %d / %d" % [mini(game.next_rep + 1, RepGame.REPS), RepGame.REPS, game.points(), RepGame.max_points()], HORIZONTAL_ALIGNMENT_LEFT, -1, 28, UIStyle.PARCHMENT)


func _finish() -> void:
	_state = "done"
	var stars: int = game.stars()
	var reward: Dictionary = RepGame.apply_result(stars)
	var lines: Array[String] = _story.get_lines("reps.win") if stars > 0 else _story.get_lines("reps.lose")
	if bool(reward["first_win"]):
		lines = _story.get_lines("reps.first") + lines
	_status.text = "\n".join(lines)
	Audio.sfx(&"victory" if stars > 0 else &"defeat")
	var parts: PackedStringArray = []
	parts.append("%s  (%d points)" % [("★".repeat(stars) + "☆".repeat(3 - stars)) if stars > 0 else "Set failed", game.points()])
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
