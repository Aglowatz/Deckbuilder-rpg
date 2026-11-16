class_name CardQuizScreen
extends CardGameScreen
## Fable Nov 16c (Part 1): the card quiz (see `CardQuizGame`), which replaces the classroom trivia in all four Path zones. The zone's
## quiz-giver is the host, the painted classroom (MG-BG-CLASSROOM) is the room, and the rewards, the pass mark (three of four) and the
## flags are the old trivia's (`QuizRules.apply`): the D.N.A.'s "Pass Director Ectomund's Compliance quiz" works as before.
## Each question shows a cropped piece of a real card's painting ("Which card is this?") or a card's painting and name ("What does it
## cost?", "What is its POWER?") with four answers; after the answer the whole card turns up. 1-4 pick an answer, or the buttons.

const CLASSROOM_ART: String = "MG-BG-CLASSROOM"
const PICTURE_HEIGHT: float = 430.0
const RIGHT: Color = Color("6fdc7a")
const WRONG: Color = Color("ff6b5e")
## Per-zone quiz names.
const TITLES: Dictionary = {
	"necrocrat": "Compliance Re-Certification", "beefcake": "Fitness Theory Exam", "gourmand": "Culinary Finals", "refusemancer": "Compost Certification",
}

var game: CardQuizGame
var _count_chip: Label
var _right_chip: Label
var _prompt: Label
var _picture_slot: CenterContainer
var _answers: GridContainer
var _buttons: Array[FancyButton] = []
var _busy: bool = false
var _teacher: Dictionary = {}
## Seconds the answer stays up before the next question.
var feedback_seconds: float = 1.7


func _init() -> void:
	super._init()
	screen_title = "Card Quiz"


## The zone's quiz name.
static func title_for(for_zone: String) -> String:
	return str(TITLES.get(for_zone, "Card Quiz"))


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
	_teacher = teacher_for(ZoneDefs.get_def(zone()))
	screen_title = title_for(zone())
	super._build()


func music_cue() -> String:
	return MusicDirector.quiz()


func game_name() -> String:
	return "Card Quiz"


func room_art() -> String:
	return CLASSROOM_ART


func backdrop_art() -> String:
	return ""


func host_portrait() -> String:
	return str(_teacher.get("npc_id", ""))


func host_name() -> String:
	return str(_teacher.get("name", "Your teacher"))


func how_lines() -> Array[String]:
	return [
		"Four questions about real cards: this zone's Path and the colourless cards.",
		"A piece of a card's art: which card is it? Or a card's art and name: what is its COST or POWER?",
		"Three right answers pass. A first pass pays the big reward; after that every attempt pays a little.",
	]


## The old trivia's reward, by right answers (not by stars).
func _pay(_stars: int) -> Dictionary:
	var story: ZoneStoryText = ZoneStoryText.for_zone(zone())
	var reward: Dictionary = QuizRules.apply(story, game.correct_count())
	reward["first_win"] = bool(reward.get("first_pass", false))
	return reward


## A failed attempt after a first pass is still paid the small fee; a fail before it gets the teacher's "not a pass" line.
func reward_text(reward: Dictionary, _won: bool) -> String:
	var parts: PackedStringArray = []
	if int(reward.get("gold", 0)) > 0:
		parts.append("+%d gold" % int(reward["gold"]))
	if int(reward.get("xp", 0)) > 0:
		parts.append("+%d XP" % int(reward["xp"]))
	var item_id: String = str(reward.get("item", ""))
	if not item_id.is_empty() and Session.content.item(item_id) != null:
		parts.append(Session.content.item(item_id).display_name)
	return "   ".join(parts) if not parts.is_empty() else "No reward this time. Three right answers pass; try again whenever you like."


func _build_table(box: VBoxContainer) -> void:
	var chips: HBoxContainer = UIKit.hbox(16)
	chips.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(chips)
	_count_chip = chip("", "QuestionCount")
	chips.add_child(_count_chip)
	_right_chip = chip("", "RightCount")
	chips.add_child(_right_chip)
	_prompt = UIKit.label("", &"", 38, Color("f4f1e6"), HORIZONTAL_ALIGNMENT_CENTER)
	_prompt.name = "Prompt"
	_prompt.add_theme_font_override("font", UIStyle.font_title())
	_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prompt.custom_minimum_size = Vector2(900, 56)
	box.add_child(_prompt)
	var row: HBoxContainer = UIKit.hbox(34)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	_picture_slot = CenterContainer.new()
	_picture_slot.name = "Picture"
	_picture_slot.custom_minimum_size = Vector2(420, PICTURE_HEIGHT + 20.0)
	row.add_child(_picture_slot)
	_answers = GridContainer.new()
	_answers.name = "Answers"
	_answers.columns = 1
	_answers.add_theme_constant_override("v_separation", 14)
	_answers.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_answers)


func _new_game() -> void:
	game = CardQuizGame.deal(CardGamePool.cards(Session.content, zone()), deal_rng(), func(card: CardData) -> bool: return CardArt.has_art(card.id))
	_busy = false
	_show_question()


func _on_play() -> void:
	host_say(story_line("quiz.start") if not story_line("quiz.start").is_empty() else "Cards on the desk. Eyes on the board.")
	_refresh()


func _show_question() -> void:
	var question: CardQuizGame.Question = game.current()
	for old: Node in _answers.get_children():
		_answers.remove_child(old)
		old.queue_free()
	_buttons.clear()
	if question == null:
		_refresh()
		return
	_prompt.text = question.prompt()
	_set_picture(_question_picture(question))
	for index: int in range(question.choices.size()):
		var button: FancyButton = game_button("%d.   %s" % [index + 1, question.choices[index]], &"", Vector2(520, 84), func() -> void: answer(index))
		button.name = "Answer%d" % (index + 1)
		button.add_theme_font_size_override("font_size", 28)
		_answers.add_child(button)
		_buttons.append(button)
	set_status("Press 1 to 4, or pick an answer.")
	_refresh()
	if state == "playing":
		_focus_table.call_deferred()


func _set_picture(picture: Control) -> void:
	for old: Node in _picture_slot.get_children():
		_picture_slot.remove_child(old)
		old.queue_free()
	if picture != null:
		_picture_slot.add_child(picture)


## The picture of a question: the cropped piece (ART), or the whole painting with the card's name under it (COST, POWER). Never the
## card face: that would print the answer.
func _question_picture(question: CardQuizGame.Question) -> Control:
	var art: Texture2D = CardArt.texture(question.card.id)
	var frame: PanelContainer = PanelContainer.new()
	frame.name = "ArtFrame"
	var style: StyleBoxFlat = UIStyle.box(Color(0.05, 0.03, 0.08, 0.92), BRASS, 4, 10)
	for side: String in ["left", "right", "top", "bottom"]:
		style.set("content_margin_" + side, 8.0)
	frame.add_theme_stylebox_override("panel", style)
	var column: VBoxContainer = UIKit.vbox(6)
	frame.add_child(column)
	var picture: TextureRect = TextureRect.new()
	picture.name = "Art"
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_SCALE
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if question.kind == CardQuizGame.Kind.ART:
		var piece_height: float = PICTURE_HEIGHT - 40.0
		if art != null:
			var region: AtlasTexture = AtlasTexture.new()
			region.atlas = art
			var art_size: Vector2 = art.get_size()
			region.region = Rect2(question.crop.position * art_size, question.crop.size * art_size)
			picture.texture = region
			picture.custom_minimum_size = Vector2(piece_height * region.region.size.x / region.region.size.y, piece_height)
		else:
			picture.custom_minimum_size = Vector2(piece_height * 0.9, piece_height)
		column.add_child(picture)
	else:
		var art_height: float = PICTURE_HEIGHT - 70.0
		picture.texture = art
		picture.custom_minimum_size = Vector2(art_height * CardArt.ASPECT, art_height)
		picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		column.add_child(picture)
		var plate: Label = UIKit.label(question.card.display_name, &"", 24, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
		plate.name = "CardName"
		plate.add_theme_font_override("font", UIStyle.font_bold())
		column.add_child(plate)
	return frame


func _refresh() -> void:
	var total: int = game.questions.size()
	_count_chip.text = "Question %d of %d" % [mini(game.index() + 1, total), total]
	_right_chip.text = "Right: %d   (pass: %d)" % [game.correct_count(), QuizRules.PASS_SCORE]
	for button: FancyButton in _buttons:
		button.disabled = _busy or state != "playing"


func _input(event: InputEvent) -> void:
	if state != "playing" or _busy or how_is_open():
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: int = int((event as InputEventKey).keycode)
		if code >= KEY_1 and code <= KEY_4:
			get_viewport().set_input_as_handled()
			answer(code - KEY_1)


## Answers the current question with choice `index`.
func answer(index: int) -> void:
	if state != "playing" or _busy or game.is_over():
		return
	var question: CardQuizGame.Question = game.current()
	if index < 0 or index >= question.choices.size():
		return
	_busy = true
	var right: bool = game.answer(index)
	for button: FancyButton in _buttons:
		button.disabled = true
	for slot: int in range(_buttons.size()):
		if slot == question.correct:
			_buttons[slot].modulate = RIGHT.lightened(0.25)
		elif slot == index:
			_buttons[slot].modulate = WRONG.lightened(0.2)
		else:
			_buttons[slot].modulate = Color(1, 1, 1, 0.55)
	_right_chip.text = "Right: %d   (pass: %d)" % [game.correct_count(), QuizRules.PASS_SCORE]
	# The whole card turns up: the answer can be read off it.
	await flip(_picture_slot, func() -> void: _set_picture(face(question.card, (PICTURE_HEIGHT - 10.0) / CardView.SIZE.y)))
	if not is_inside_tree():
		return
	if right:
		Audio.sfx(&"ui_confirm")
		set_status("Right: %s." % _answer_line(question), RIGHT)
		host_say(["Correct!", "Exactly right!", "Gold star!", "Brilliant!"][mini(game.correct_count() - 1, 3)])
		if animate and index < _buttons.size():
			pop(_buttons[index])
			MinigameFx.sparkle(self, _buttons[index].get_global_rect().get_center())
	else:
		Audio.sfx(&"ui_error", -6.0)
		set_status("Not quite: %s." % _answer_line(question), Color("ff9d98"))
		host_say(["Not quite!", "Hmm, no.", "Close, but no!"][game.index() % 3])
		shake_table(6.0)
	await pause(feedback_seconds)
	if not is_inside_tree():
		return
	_busy = false
	if game.is_over():
		_end()
	else:
		_show_question()


func _answer_line(question: CardQuizGame.Question) -> String:
	match question.kind:
		CardQuizGame.Kind.COST:
			return "%s costs %d" % [question.card.display_name, question.card.energy_value()]
		CardQuizGame.Kind.POWER:
			return "%s has %d power" % [question.card.display_name, question.card.attack]
	return "it is %s" % question.card.display_name


func _end() -> void:
	var correct: int = game.correct_count()
	var total: int = game.questions.size()
	var remark: String = story_line("quiz.result.%d" % correct)
	var won: bool = game.passed()
	finish(won, game.stars(), "%d of %d right: %s" % [correct, total, "passed!" if won else "not a pass"], remark)
	var panel: Control = result_panel()
	if panel != null:
		var again: Button = panel.find_child("PlayAgain", true, false) as Button
		if again != null:
			again.text = "Try again"


func _build_example(box: Control) -> void:
	# A piece of a card's art, four names, the right one lights up; then the whole card. Then it starts again.
	var pool: Array[CardData] = CardGamePool.cards(Session.content, zone())
	var card: CardData = null
	for candidate: CardData in pool:
		if CardArt.has_art(candidate.id):
			card = candidate
			break
	if card == null and not pool.is_empty():
		card = pool[0]
	if card == null:
		return
	var holder: Control = Control.new()
	holder.position = Vector2(60, 12)
	holder.size = Vector2(170, 216)
	holder.pivot_offset = holder.size * 0.5
	box.add_child(holder)
	var piece: TextureRect = TextureRect.new()
	piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	piece.stretch_mode = TextureRect.STRETCH_SCALE
	piece.size = Vector2(170, 190)
	var art: Texture2D = CardArt.texture(card.id)
	if art != null:
		var region: AtlasTexture = AtlasTexture.new()
		region.atlas = art
		region.region = Rect2(Vector2(0.27, 0.2) * art.get_size(), CardQuizGame.CROP_SHARE * art.get_size())
		piece.texture = region
	var whole: Control = face(card, 216.0 / CardView.SIZE.y)
	whole.visible = false
	holder.add_child(piece)
	holder.add_child(whole)
	var names: VBoxContainer = UIKit.vbox(6)
	names.position = Vector2(290, 20)
	names.size = Vector2(360, 200)
	box.add_child(names)
	var right_label: Label = null
	var others: Array[String] = []
	for other: CardData in pool:
		if other.id != card.id and others.size() < 2:
			others.append(other.display_name)
	var listed: Array[String] = [others[0] if others.size() > 0 else "?", card.display_name, others[1] if others.size() > 1 else "?"]
	for index: int in range(listed.size()):
		var label: Label = UIKit.label("%d.   %s" % [index + 1, listed[index]], &"", 24, UIStyle.PARCHMENT)
		label.add_theme_stylebox_override("normal", UIStyle.box(Color(0.05, 0.03, 0.08, 0.7), UIStyle.GOLD_DIM, 2, 8))
		label.custom_minimum_size = Vector2(360, 44)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		names.add_child(label)
		if listed[index] == card.display_name:
			right_label = label
	var loop: Tween = box.create_tween().set_loops()
	loop.tween_interval(1.1)
	loop.tween_property(right_label, "modulate", Color(0.6, 1.5, 0.7), 0.15)
	loop.tween_property(holder, "scale:x", 0.05, 0.12)
	loop.tween_callback(func() -> void:
		piece.visible = false
		whole.visible = true)
	loop.tween_property(holder, "scale:x", 1.0, 0.12)
	loop.tween_interval(1.6)
	loop.tween_property(holder, "scale:x", 0.05, 0.12)
	loop.tween_callback(func() -> void:
		piece.visible = true
		whole.visible = false
		right_label.modulate = Color.WHITE)
	loop.tween_property(holder, "scale:x", 1.0, 0.12)


## Shots and tests: answers the remaining questions, the first `wrong` of them wrongly.
func autoplay(count: int, wrong: int = 0) -> void:
	var done: int = 0
	while done < count and not game.is_over():
		var question: CardQuizGame.Question = game.current()
		var pick: int = question.correct
		if done < wrong:
			pick = (question.correct + 1) % question.choices.size()
		await answer(pick)
		done += 1


func _shot_mid() -> void:
	await autoplay(1)


func _shot_end(won: bool) -> void:
	if won:
		await autoplay(4)
	else:
		await autoplay(4, 3)
