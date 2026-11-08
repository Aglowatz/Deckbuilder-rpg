class_name QuizScreen
extends OverlayScreen
## A zone's trivia (Part G; every Path zone has one): 4 multiple-choice questions about its Path. Answers are shuffled each attempt. Rewards
## scale with correct answers (QuizRules); retry any time.
## Overnight Nov 7-8, Part 6.1: an excited anime-style classroom. The question is chalked on a big green board; the zone's quiz-giver stands
## beside it as the teacher (their existing portrait); the four answers are desk cards. Every answer gets a flourish - a correct one flashes
## green with chalk-dust sparkles, a ringing sting and a streak counter; a wrong one shakes red and the right answer lights up. The classroom
## background is MG-BG-CLASSROOM once painted (art list); until then a coded wood-and-chalkboard room stands in.

signal quiz_finished(correct: int, reward: Dictionary)

const BOARD_RECT: Rect2 = Rect2(560, 90, 1260, 470)
const TEACHER_RECT: Rect2 = Rect2(60, 160, 480, 720)
const ANSWER_SIZE: Vector2 = Vector2(620, 92)
const CHALK: Color = Color("f4f1e6")
const BOARD_GREEN: Color = Color("24432f")
const RIGHT: Color = Color("6fdc7a")
const WRONG: Color = Color("ff6b5e")
## Per-zone quiz names (the D.N.A.'s was used everywhere before).
const TITLES: Dictionary = {
	"necrocrat": "Compliance Re-Certification", "beefcake": "Fitness Theory Exam", "gourmand": "Culinary Finals", "refusemancer": "Compost Certification",
}

var _story: ZoneStoryText
var _index: int = 0
var _answers: Array[int] = []
var _order: Array[int] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _room: Control
var _board_text: Label
var _board_count: Label
var _answer_grid: GridContainer
var _answer_buttons: Array[Button] = []
var _teacher: TextureRect
var _bubble: Label
var _streak_label: Label
var _streak: int = 0
var _best_streak: int = 0
var _locked: bool = false
var _finish_box: VBoxContainer
## Overnight Nov 7-8: the seconds a flourish holds before the next question (tests set 0).
var feedback_seconds: float = 1.0


func _init() -> void:
	screen_title = ""
	close_text = "Leave (Esc)"
	background_id = ""


func music_cue() -> String:
	return MusicDirector.quiz()


## The zone's quiz name.
static func title_for(zone_id: String) -> String:
	return str(TITLES.get(zone_id, "Pop Quiz"))


## The zone's quiz-giver: {"npc_id", "name"} from its "quiz" spot ({} outside a zone).
static func teacher_for(def: ZoneDef) -> Dictionary:
	if def == null:
		return {}
	for spot: Dictionary in def.spots:
		if str(spot.get("id", "")) == "quiz" or str(spot.get("kind", "")) == "quiz":
			var extra: Dictionary = spot.get("extra", spot) as Dictionary
			var npc_id: String = str(extra.get("npc_id", spot.get("npc_id", "")))
			var speaker: String = str(extra.get("speaker", spot.get("speaker", spot.get("title", ""))))
			if not npc_id.is_empty():
				return {"npc_id": npc_id, "name": speaker}
	return {}


func _build() -> void:
	_story = ZoneStoryText.current()
	_rng.randomize()
	var def: ZoneDef = ZoneDefs.current()
	_build_room(def)
	_start()


func _build_room(def: ZoneDef) -> void:
	_room = Control.new()
	_room.name = "Classroom"
	_room.size = Vector2(1920, 1080)
	_room.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_room)
	for child: Node in get_children():
		if child is MarginContainer:
			move_child(_room, child.get_index() + 1)
			break
	if UiArt.has("MG-BG-CLASSROOM"):
		var art: TextureRect = TextureRect.new()
		art.name = "ClassroomArt"
		art.texture = UiArt.texture("MG-BG-CLASSROOM")
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.size = Vector2(1920, 1080)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_room.add_child(art)
	else:
		_build_stand_in()
	# the chalkboard
	var frame: Panel = Panel.new()
	frame.name = "Chalkboard"
	frame.position = BOARD_RECT.position - Vector2(18, 18)
	frame.size = BOARD_RECT.size + Vector2(36, 36)
	frame.add_theme_stylebox_override("panel", UIStyle.box(Color("6b4426"), Color("3d2614"), 6, 10))
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room.add_child(frame)
	var board: Panel = Panel.new()
	board.position = Vector2(18, 18)
	board.size = BOARD_RECT.size
	board.add_theme_stylebox_override("panel", UIStyle.box(BOARD_GREEN, Color(0, 0, 0, 0.3), 2, 4))
	board.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(board)
	for i: int in range(5):  # faint chalk smudges
		var smudge: ColorRect = ColorRect.new()
		smudge.color = Color(1, 1, 1, 0.035)
		smudge.position = Vector2(60 + i * 230, 40 + (i % 2) * 260)
		smudge.size = Vector2(180, 110)
		smudge.rotation = 0.08 * float(i - 2)
		smudge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board.add_child(smudge)
	var heading: Label = UIKit.label(title_for(def.id if def != null else ""), &"", 34, CHALK, HORIZONTAL_ALIGNMENT_LEFT)
	heading.name = "QuizTitle"
	heading.add_theme_font_override("font", UIStyle.font_title())
	heading.position = Vector2(34, 18)
	heading.size = Vector2(800, 48)
	board.add_child(heading)
	_board_count = UIKit.label("", &"", 26, CHALK, HORIZONTAL_ALIGNMENT_RIGHT)
	_board_count.position = Vector2(BOARD_RECT.size.x - 334, 22)
	_board_count.size = Vector2(300, 40)
	board.add_child(_board_count)
	_board_text = UIKit.label("", &"", 46, CHALK, HORIZONTAL_ALIGNMENT_CENTER)
	_board_text.name = "BoardQuestion"
	_board_text.add_theme_font_override("font", UIStyle.font_title())
	_board_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_board_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_board_text.position = Vector2(50, 80)
	_board_text.size = Vector2(BOARD_RECT.size.x - 100, BOARD_RECT.size.y - 130)
	board.add_child(_board_text)
	_finish_box = UIKit.vbox(10)
	_finish_box.position = Vector2(50, 70)
	_finish_box.size = Vector2(BOARD_RECT.size.x - 100, BOARD_RECT.size.y - 90)
	_finish_box.visible = false
	board.add_child(_finish_box)
	# the teacher
	var teacher: Dictionary = teacher_for(def)
	_teacher = TextureRect.new()
	_teacher.name = "Teacher"
	_teacher.position = TEACHER_RECT.position
	_teacher.size = TEACHER_RECT.size
	_teacher.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_teacher.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_teacher.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_teacher.pivot_offset = TEACHER_RECT.size * Vector2(0.5, 1.0)
	if not teacher.is_empty():
		_teacher.texture = Portraits.texture_for(str(teacher["npc_id"]))
	_room.add_child(_teacher)
	var plate: Label = UIKit.label(str(teacher.get("name", "Your teacher")), &"", 24, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	plate.name = "TeacherName"
	plate.add_theme_stylebox_override("normal", UIStyle.box(Color(0.07, 0.05, 0.12, 0.9), UIStyle.GOLD, 2, 10))
	plate.position = Vector2(TEACHER_RECT.position.x + 40, TEACHER_RECT.end.y - 10)
	plate.size = Vector2(TEACHER_RECT.size.x - 80, 44)
	_room.add_child(plate)
	_bubble = UIKit.label("", &"", 28, Color("1d1408"), HORIZONTAL_ALIGNMENT_CENTER)
	_bubble.name = "TeacherBubble"
	_bubble.add_theme_font_override("font", UIStyle.font_bold())
	_bubble.add_theme_stylebox_override("normal", UIStyle.box(Color("fff6dc"), Color("3d2614"), 3, 18))
	_bubble.position = Vector2(TEACHER_RECT.position.x + 120, TEACHER_RECT.position.y - 70)
	_bubble.size = Vector2(380, 60)
	_bubble.modulate.a = 0.0
	_room.add_child(_bubble)
	# the streak
	_streak_label = UIKit.label("", &"", 40, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_RIGHT)
	_streak_label.name = "Streak"
	_streak_label.add_theme_font_override("font", UIStyle.font_title())
	_streak_label.add_theme_color_override("font_outline_color", Color(0.15, 0.06, 0.0, 0.95))
	_streak_label.add_theme_constant_override("outline_size", 10)
	_streak_label.position = Vector2(1400, 20)
	_streak_label.size = Vector2(420, 60)
	_streak_label.pivot_offset = Vector2(420, 30)
	_room.add_child(_streak_label)
	# the desks: four answer cards in two rows
	_answer_grid = GridContainer.new()
	_answer_grid.name = "Answers"
	_answer_grid.columns = 2
	_answer_grid.add_theme_constant_override("h_separation", 20)
	_answer_grid.add_theme_constant_override("v_separation", 18)
	_answer_grid.position = Vector2(BOARD_RECT.position.x, BOARD_RECT.end.y + 60)
	_room.add_child(_answer_grid)


## The coded stand-in for MG-BG-CLASSROOM: a warm wooden wall with planks and a skirting rail, two sunny windows, and rows of desks.
func _build_stand_in() -> void:
	var wall: ColorRect = ColorRect.new()
	wall.name = "Wall"
	wall.color = Color("8a5a34")
	wall.size = Vector2(1920, 1080)
	wall.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room.add_child(wall)
	for i: int in range(24):
		var plank: ColorRect = ColorRect.new()
		plank.color = Color(0, 0, 0, 0.09 if i % 2 == 0 else 0.03)
		plank.position = Vector2(i * 80, 0)
		plank.size = Vector2(3, 760)
		plank.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_room.add_child(plank)
	for x: float in [140.0, 1700.0]:
		var window: Panel = Panel.new()
		window.position = Vector2(x - 80, 40)
		window.size = Vector2(160, 240)
		window.add_theme_stylebox_override("panel", UIStyle.box(Color("bfe3ff"), Color("5a3a20"), 8, 6))
		window.mouse_filter = Control.MOUSE_FILTER_IGNORE
		window.modulate = Color(1, 1, 1, 0.75)
		_room.add_child(window)
	var floor_band: ColorRect = ColorRect.new()
	floor_band.color = Color("5b3a22")
	floor_band.position = Vector2(0, 760)
	floor_band.size = Vector2(1920, 320)
	floor_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room.add_child(floor_band)
	var rail: ColorRect = ColorRect.new()
	rail.color = Color("3d2614")
	rail.position = Vector2(0, 752)
	rail.size = Vector2(1920, 12)
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room.add_child(rail)
	for row: int in range(2):
		for col: int in range(6):
			var desk: Panel = Panel.new()
			desk.position = Vector2(110 + col * 300 + row * 150, 960 + row * 70)
			desk.size = Vector2(240, 60)
			desk.add_theme_stylebox_override("panel", UIStyle.box(Color("a8723f"), Color("4a2e18"), 3, 6))
			desk.mouse_filter = Control.MOUSE_FILTER_IGNORE
			desk.modulate = Color(0.8, 0.8, 0.8, 0.9)
			_room.add_child(desk)
	# a warm sunbeam across the room (the excited, sunny mood)
	var beam: ColorRect = ColorRect.new()
	beam.color = Color(1.0, 0.92, 0.6, 0.06)
	beam.position = Vector2(-200, 120)
	beam.size = Vector2(2400, 260)
	beam.rotation = 0.18
	beam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_room.add_child(beam)


func _start() -> void:
	_index = 0
	_streak = 0
	_best_streak = 0
	_answers.clear()
	_finish_box.visible = false
	_board_text.visible = true
	_answer_grid.visible = true
	_streak_label.text = ""
	_say("Pop quiz! Pencils ready!")
	_show_question()


func _show_question() -> void:
	_locked = false
	var question: Dictionary = _story.quiz_questions[_index] as Dictionary
	_board_count.text = "Question %d of %d" % [_index + 1, _story.quiz_questions.size()]
	_board_text.text = str(question["q"])
	_board_text.modulate.a = 0.0
	create_tween().tween_property(_board_text, "modulate:a", 1.0, 0.35)
	_order.clear()
	for i: int in range((question["a"] as Array).size()):
		_order.append(i)
	for i: int in range(_order.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var swap: int = _order[i]
		_order[i] = _order[j]
		_order[j] = swap
	for child: Node in _answer_grid.get_children():
		child.queue_free()
	_answer_buttons.clear()
	for slot: int in range(_order.size()):
		var original: int = _order[slot]
		var button: Button = Button.new()
		button.name = "Answer_%d" % slot
		button.text = "%s   %s" % [char(65 + slot), str((question["a"] as Array)[original])]
		button.custom_minimum_size = ANSWER_SIZE
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 26)
		button.add_theme_color_override("font_color", Color("2b1a0c"))
		button.add_theme_color_override("font_hover_color", Color("2b1a0c"))
		button.add_theme_color_override("font_pressed_color", Color("2b1a0c"))
		button.add_theme_color_override("font_focus_color", Color("2b1a0c"))
		button.add_theme_color_override("font_disabled_color", Color("2b1a0c"))
		_style_answer(button, Color("f6e7c4"), Color("6b4426"))
		button.focus_mode = Control.FOCUS_ALL
		button.pivot_offset = ANSWER_SIZE * 0.5
		button.set_meta("original", original)
		button.pressed.connect(func() -> void: _answer(original))
		_answer_grid.add_child(button)
		_answer_buttons.append(button)
	if InputDevice.using_pad() and not _answer_buttons.is_empty():
		_answer_buttons[0].grab_focus.call_deferred()


func _style_answer(button: Button, fill: Color, border: Color) -> void:
	for state: String in ["normal", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, UIStyle.box(fill, border, 3, 12))
	button.add_theme_stylebox_override("hover", UIStyle.box(fill.lightened(0.08), UIStyle.GOLD, 4, 12))


## Overnight Nov 7-8: true when `original` is the question's right answer.
func is_correct(original: int) -> bool:
	return original == int((_story.quiz_questions[_index] as Dictionary)["correct"])


func _answer(original: int) -> void:
	if _locked:
		return
	_locked = true
	var right: bool = is_correct(original)
	_answers.append(original)
	for button: Button in _answer_buttons:
		var mine: bool = int(button.get_meta("original", -1)) == original
		var correct_one: bool = int(button.get_meta("original", -1)) == int((_story.quiz_questions[_index] as Dictionary)["correct"])
		if correct_one:
			_style_answer(button, RIGHT.lightened(0.5), Color("2f7a38"))
		elif mine:
			_style_answer(button, WRONG.lightened(0.45), Color("8a2a22"))
	var picked: Button = null
	for button: Button in _answer_buttons:
		if int(button.get_meta("original", -1)) == original:
			picked = button
	if right:
		_streak += 1
		_best_streak = maxi(_best_streak, _streak)
		Audio.sfx(&"ui_confirm")
		_say(["Correct!", "Exactly right!", "Gold star!", "Brilliant!"][mini(_streak - 1, 3)])
		_streak_label.text = "Streak x%d!" % _streak if _streak >= 2 else "Correct!"
		var pop: Tween = create_tween()
		_streak_label.scale = Vector2(1.5, 1.5)
		pop.tween_property(_streak_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if picked != null:
			_sparkle(picked.get_global_rect().get_center())
			var bounce: Tween = create_tween()
			bounce.tween_property(picked, "scale", Vector2(1.08, 1.08), 0.12)
			bounce.tween_property(picked, "scale", Vector2.ONE, 0.15)
		_teacher_hop()
	else:
		_streak = 0
		Audio.sfx(&"ui_error")
		_say(["Not quite!", "Hmm, no.", "Close, but no!"][_rng.randi_range(0, 2)])
		_streak_label.text = ""
		if picked != null:
			var base_x: float = picked.position.x
			var shake: Tween = create_tween()
			for k: int in range(4):
				shake.tween_property(picked, "position:x", base_x + (10.0 if k % 2 == 0 else -10.0), 0.05)
			shake.tween_property(picked, "position:x", base_x, 0.05)
	if feedback_seconds > 0.0:
		await get_tree().create_timer(feedback_seconds).timeout
	if not is_inside_tree():
		return
	_index += 1
	if _index >= _story.quiz_questions.size():
		_finish()
	else:
		_show_question()


func _say(text: String) -> void:
	_bubble.text = text
	_bubble.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(1.1)
	tween.tween_property(_bubble, "modulate:a", 0.0, 0.3)


func _teacher_hop() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_teacher, "scale", Vector2(1.04, 0.96), 0.08)
	tween.tween_property(_teacher, "scale", Vector2(0.97, 1.05), 0.1)
	tween.tween_property(_teacher, "scale", Vector2.ONE, 0.12)


## Chalk-dust stars bursting from a right answer.
func _sparkle(at: Vector2) -> void:
	var burst: CPUParticles2D = CPUParticles2D.new()
	burst.name = "Sparkle"
	burst.position = at
	burst.amount = 26
	burst.lifetime = 0.8
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.direction = Vector2.UP
	burst.spread = 180.0
	burst.initial_velocity_min = 180.0
	burst.initial_velocity_max = 360.0
	burst.gravity = Vector2(0, 420)
	burst.scale_amount_min = 4.0
	burst.scale_amount_max = 8.0
	burst.color = Color("fff3b0")
	burst.z_index = 50
	_room.add_child(burst)
	burst.emitting = true
	get_tree().create_timer(1.2).timeout.connect(burst.queue_free)


func _finish() -> void:
	var correct: int = QuizRules.score(_story, _answers)
	var reward: Dictionary = QuizRules.apply(_story, correct)
	Audio.sting(&"STG-MINI-SUCCESS" if correct >= 3 else &"STG-MINI-FAIL")
	_answer_grid.visible = false
	_board_text.visible = false
	_board_count.text = "Results"
	for child: Node in _finish_box.get_children():
		child.queue_free()
	_finish_box.visible = true
	var score: Label = UIKit.label("%d / %d correct" % [correct, _story.quiz_questions.size()], &"", 72, CHALK, HORIZONTAL_ALIGNMENT_CENTER)
	score.name = "Score"
	score.add_theme_font_override("font", UIStyle.font_title())
	_finish_box.add_child(score)
	if _best_streak >= 2:
		_finish_box.add_child(UIKit.label("Best streak: %d in a row" % _best_streak, &"", 26, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var remark: Label = UIKit.label(" ".join(_story.get_lines("quiz.result.%d" % correct)), &"", 26, CHALK, HORIZONTAL_ALIGNMENT_CENTER)
	remark.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	remark.custom_minimum_size = Vector2(BOARD_RECT.size.x - 120, 0)
	_finish_box.add_child(remark)
	var parts: PackedStringArray = []
	if int(reward["gold"]) > 0:
		parts.append("+%d gold" % int(reward["gold"]))
	if int(reward["xp"]) > 0:
		parts.append("+%d XP" % int(reward["xp"]))
	if not str(reward["item"]).is_empty():
		parts.append(Session.content.item(str(reward["item"])).display_name)
	var reward_text: String = ", ".join(parts) if not parts.is_empty() else " ".join(_story.get_lines("quiz.not_passed"))
	_finish_box.add_child(UIKit.label(reward_text, &"", 30, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_finish_box.add_child(row)
	var again: FancyButton = FancyButton.make("Try again", &"PrimaryButton", Vector2(240, 60))
	again.pressed.connect(_start)
	row.add_child(again)
	var leave: FancyButton = FancyButton.make("Leave", &"", Vector2(200, 60))
	leave.pressed.connect(request_close)
	row.add_child(leave)
	if correct >= QuizRules.PASS_SCORE:
		_say("Top of the class!")
		_teacher_hop()
		_sparkle(Vector2(BOARD_RECT.get_center().x, BOARD_RECT.position.y + 120))
	else:
		_say("Study up and try again!")
	quiz_finished.emit(correct, reward)
