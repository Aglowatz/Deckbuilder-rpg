class_name QuizScreen
extends OverlayScreen
## The Compliance quiz (Part G): 4 multiple-choice questions about the Necrocrats. Answers are
## shuffled each attempt. Rewards scale with correct answers (see QuizRules); retry any time.

signal quiz_finished(correct: int, reward: Dictionary)

var _story: ZoneStoryText
var _index: int = 0
var _answers: Array[int] = []
var _order: Array[int] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _column: VBoxContainer


func _init() -> void:
	screen_title = "Compliance Re-Certification"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.shared()
	_rng.randomize()
	_column = UIKit.vbox(18)
	_column.custom_minimum_size = Vector2(1300, 0)
	var center: CenterContainer = CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	center.add_child(_column)
	_start()


func _start() -> void:
	_index = 0
	_answers.clear()
	_show_question()


func _clear() -> void:
	for child: Node in _column.get_children():
		child.queue_free()


func _show_question() -> void:
	_clear()
	var question: Dictionary = _story.quiz_questions[_index] as Dictionary
	_column.add_child(UIKit.label("Question %d of %d" % [_index + 1, _story.quiz_questions.size()], &"MutedLabel", 24))
	var title: Label = UIKit.label(str(question["q"]), &"TitleLabel", 44, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.custom_minimum_size = Vector2(1300, 0)
	_column.add_child(title)
	_order.clear()
	for i: int in range((question["a"] as Array).size()):
		_order.append(i)
	for i: int in range(_order.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var swap: int = _order[i]
		_order[i] = _order[j]
		_order[j] = swap
	for slot: int in range(_order.size()):
		var original: int = _order[slot]
		var button: FancyButton = FancyButton.make("%s   %s" % [char(65 + slot), str((question["a"] as Array)[original])], &"", Vector2(1200, 66))
		button.pressed.connect(func() -> void: _answer(original))
		_column.add_child(button)


func _answer(original: int) -> void:
	_answers.append(original)
	Audio.sfx(&"ui_select")
	_index += 1
	if _index >= _story.quiz_questions.size():
		_finish()
	else:
		_show_question()


func _finish() -> void:
	_clear()
	var correct: int = QuizRules.score(_story, _answers)
	var reward: Dictionary = QuizRules.apply(_story, correct)
	Audio.sfx(&"victory" if correct >= 3 else &"ui_confirm")
	_column.add_child(UIKit.label("%d / %d correct" % [correct, _story.quiz_questions.size()], &"TitleLabel", 70, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var remark: Label = UIKit.label("\n".join(_story.get_lines("quiz.result.%d" % correct)), &"", 26, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	remark.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	remark.custom_minimum_size = Vector2(1100, 0)
	_column.add_child(remark)
	var parts: PackedStringArray = []
	if int(reward["gold"]) > 0:
		parts.append("+%d gold" % int(reward["gold"]))
	if int(reward["xp"]) > 0:
		parts.append("+%d XP" % int(reward["xp"]))
	if not str(reward["item"]).is_empty():
		parts.append(Session.content.item(str(reward["item"])).display_name)
	var reward_text: String = ", ".join(parts) if not parts.is_empty() else "\n".join(_story.get_lines("quiz.nothing_new")) if correct > 0 else "No reward."
	_column.add_child(UIKit.label(reward_text, &"", 30, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_column.add_child(row)
	var again: FancyButton = FancyButton.make("Try again", &"PrimaryButton", Vector2(240, 60))
	again.pressed.connect(_start)
	row.add_child(again)
	var leave: FancyButton = FancyButton.make("Leave", &"", Vector2(200, 60))
	leave.pressed.connect(request_close)
	row.add_child(leave)
	quiz_finished.emit(correct, reward)
