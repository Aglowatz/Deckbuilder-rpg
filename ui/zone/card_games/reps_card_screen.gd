class_name RepsCardScreen
extends CardGameScreen
## Fable Nov 16b (Part 2): the Gainlands' card minigame, "Reps" (see `RepsCardGame`): higher or lower on a card's power, at Chet
## Thunderabs' 3 a.m. studio (MG-BG-GYM). Every right guess slides a plate onto the barbell; at eight the hero lifts it. A miss tips the
## plates off again. Up / W = higher, Down / S = lower (the D-pad on a controller), or the two buttons.

const CARD_SCALE: float = 0.96
const PLATE_COLORS: Array[Color] = [Color("c9463d"), Color("3f78c9"), Color("e0b23c"), Color("4fa86a")]

var game: RepsCardGame
var _low: int = 0
var _high: int = 0
var _shown: Control
var _hidden: Control
var _power: Label
var _streak_chip: Label
var _miss_chip: Label
var _range_chip: Label
var _higher: FancyButton
var _lower: FancyButton
var _bench: Control
var _busy: bool = false
## Plates drawn on the bar (follows the streak, with a little slide), and the lift at the end (0 to 1).
var _plates: float = 0.0
var _lift: float = 0.0
var _hero: Texture2D


func _init() -> void:
	super._init()
	screen_title = "Studio 3 AM: Reps"


func game_name() -> String:
	return "Reps"


func room_art() -> String:
	return "MG-BG-GYM"


func backdrop_art() -> String:
	return "LOAD-GAINLANDS"


func host_portrait() -> String:
	return "NPC-THUNDERABS"


func host_name() -> String:
	return "Chet Thunderabs"


func how_lines() -> Array[String]:
	return [
		"One card is face up. Will the next card's POWER (its first number) be higher or lower?",
		"Eight right in a row finishes the set. A tie counts as right.",
		"A miss tips the plates off the bar. Three misses are allowed; the fourth ends the set.",
	]


func _pay(stars: int) -> Dictionary:
	return RepGame.apply_result(stars)


func _build_table(box: VBoxContainer) -> void:
	_hero = SpriteLibrary.frame_or_default("PLAYER", "FRONT_IDLE")
	var chips: HBoxContainer = UIKit.hbox(16)
	chips.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(chips)
	_streak_chip = chip("", "Streak")
	chips.add_child(_streak_chip)
	_miss_chip = chip("", "Misses")
	chips.add_child(_miss_chip)
	_range_chip = chip("", "Range")
	chips.add_child(_range_chip)
	var row: HBoxContainer = UIKit.hbox(26)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(row)
	_bench = Control.new()
	_bench.name = "Bench"
	_bench.custom_minimum_size = Vector2(560, 546)
	_bench.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_bench.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bench.draw.connect(_draw_bench)
	row.add_child(_bench)
	var left: VBoxContainer = UIKit.vbox(6)
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(left)
	_shown = Control.new()
	_shown.name = "ShownCard"
	_shown.custom_minimum_size = CardView.SIZE * CARD_SCALE
	_shown.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(_shown)
	_power = UIKit.label("", &"", 28, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_power.name = "Power"
	_power.add_theme_font_override("font", UIStyle.font_bold())
	left.add_child(_power)
	var middle: VBoxContainer = UIKit.vbox(18)
	middle.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(middle)
	_higher = game_button("", &"PrimaryButton", Vector2(300, 84), func() -> void: guess(true))
	_higher.name = "Higher"
	PromptText.bind(_higher, "▲  Higher  (Up)", &"text", "▲  Higher")
	middle.add_child(_higher)
	middle.add_child(UIKit.label("The next card's\npower is...", &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	_lower = game_button("", &"PrimaryButton", Vector2(300, 84), func() -> void: guess(false))
	_lower.name = "Lower"
	PromptText.bind(_lower, "▼  Lower  (Down)", &"text", "▼  Lower")
	middle.add_child(_lower)
	var right: VBoxContainer = UIKit.vbox(6)
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(right)
	_hidden = Control.new()
	_hidden.name = "NextCard"
	_hidden.custom_minimum_size = CardView.SIZE * CARD_SCALE
	_hidden.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right.add_child(_hidden)
	right.add_child(UIKit.label("Next card", &"", 28, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))


func _new_game() -> void:
	var units: Array[CardData] = CardGamePool.units(Session.content, zone())
	game = RepsCardGame.deal(units, deal_rng())
	_low = 99
	_high = 0
	for card: CardData in units:
		_low = mini(_low, card.attack)
		_high = maxi(_high, card.attack)
	_busy = false
	_plates = 0.0
	_lift = 0.0
	_show(_shown, face(game.current(), CARD_SCALE))
	_show(_hidden, back(CARD_SCALE))
	set_status("Higher or lower? Eight right in a row finishes the set.")
	host_say(story_line("reps.shouts", 0))
	_refresh()


func _show(holder: Control, child: Control) -> void:
	for old: Node in holder.get_children():
		holder.remove_child(old)
		old.queue_free()
	holder.add_child(child)


func _refresh() -> void:
	_streak_chip.text = "Rep %d / %d" % [game.streak, RepsCardGame.STREAK_TO_WIN]
	_miss_chip.text = "Misses %d / %d" % [mini(game.misses, RepsCardGame.MISSES_ALLOWED), RepsCardGame.MISSES_ALLOWED]
	_miss_chip.add_theme_color_override("font_color", Color("ff9d98") if game.misses >= RepsCardGame.MISSES_ALLOWED else UIStyle.GOLD)
	_range_chip.text = "Powers here run from %d to %d" % [_low, _high]
	var shown: CardData = game.current()
	_power.text = "Power %d" % shown.attack if shown != null else ""
	_higher.disabled = _busy or game.is_over() or state != "playing"
	_lower.disabled = _higher.disabled
	_bench.queue_redraw()


func _on_play() -> void:
	_refresh()


func _input(event: InputEvent) -> void:
	if state != "playing" or _busy or how_is_open():
		return
	var higher: int = -1
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: int = int((event as InputEventKey).keycode)
		if code == KEY_UP or code == KEY_W:
			higher = 1
		elif code == KEY_DOWN or code == KEY_S:
			higher = 0
	elif event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		var button: int = (event as InputEventJoypadButton).button_index
		if button == JOY_BUTTON_DPAD_UP:
			higher = 1
		elif button == JOY_BUTTON_DPAD_DOWN:
			higher = 0
	if higher >= 0:
		get_viewport().set_input_as_handled()
		guess(higher == 1)


## A guess: the next card turns over, the bar gains a plate or loses them all, and the turned card becomes the face-up card.
func guess(higher: bool) -> void:
	if state != "playing" or _busy or game.is_over():
		return
	_busy = true
	_refresh()
	var next: CardData = game.upcoming()
	var right: bool = game.guess(higher)
	await flip(_hidden, func() -> void: _show(_hidden, face(next, CARD_SCALE)))
	if not is_inside_tree():
		return
	if right:
		Audio.sfx(&"hit_metal", -6.0, 0.08)
		set_status("Power %d: right! That is rep %d." % [next.attack, game.streak], UIStyle.GOOD)
		host_say(story_line("reps.shouts", game.streak))
		pop(_hidden)
		MinigameFx.sparkle(self, _hidden.get_global_rect().get_center())
	else:
		Audio.sfx(&"ui_error", -6.0)
		set_status("Power %d: a miss. The plates come off the bar." % next.attack, Color("ff9d98"))
		shake_table()
	_slide_plates(float(game.streak))
	await pause(0.75 if right else 1.1)
	if not is_inside_tree():
		return
	_show(_shown, face(next, CARD_SCALE))
	_show(_hidden, back(CARD_SCALE))
	_busy = false
	_refresh()
	if game.is_won():
		_win()
	elif game.is_lost():
		finish(false, 0, "Set failed", story_line("reps.lose"))


func _slide_plates(target: float) -> void:
	if not animate:
		_plates = target
		_bench.queue_redraw()
		return
	var slide: Tween = create_tween()
	slide.tween_method(func(value: float) -> void:
		_plates = value
		_bench.queue_redraw(), _plates, target, 0.22 if target > _plates else 0.45)


func _win() -> void:
	_busy = true
	_refresh()
	set_status("EIGHT! Lift it!", UIStyle.GOLD)
	Audio.sfx(&"hit_heavy", -3.0)
	if animate:
		var lift: Tween = create_tween()
		lift.tween_method(func(value: float) -> void:
			_lift = value
			_bench.queue_redraw(), 0.0, 1.0, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await lift.finished
		await pause(0.5)
	else:
		_lift = 1.0
	if not is_inside_tree():
		return
	var first: bool = not Session.flag(ZoneDefs.get_def(zone()).flag_minigame_first)
	var lines: String = story_line("reps.win")
	if first:
		lines = "%s\n%s" % [story_line("reps.first"), lines]
	finish(true, game.stars(), "Set complete!", lines)


## The bench: two uprights, the bar with one plate per rep (alternating sides), the hero under it; on a win the bar goes up overhead.
func _draw_bench() -> void:
	var area: Vector2 = _bench.size
	var k: float = area.y / 420.0
	var centre_x: float = area.x * 0.5
	var floor_y: float = area.y - 30.0 * k
	var bar_y: float = floor_y - (190.0 + _lift * 130.0) * k
	# The pad and the uprights.
	_bench.draw_rect(Rect2(centre_x - 150.0 * k, floor_y - 12.0 * k, 300.0 * k, 14.0 * k), Color(0.08, 0.05, 0.1, 0.8))
	for side: float in [-1.0, 1.0]:
		_bench.draw_rect(Rect2(centre_x + (side * 120.0 - 7.0) * k, floor_y - 200.0 * k, 14.0 * k, 190.0 * k), Color("5b5f6b"))
		_bench.draw_rect(Rect2(centre_x + (side * 120.0 - 16.0) * k, floor_y - 204.0 * k, 32.0 * k, 10.0 * k), Color("8a8f9c"))
	if _hero != null:
		var hero_height: float = 230.0 * k
		var hero_size: Vector2 = Vector2(_hero.get_width(), _hero.get_height()) * (hero_height / float(_hero.get_height()))
		_bench.draw_texture_rect(_hero, Rect2(Vector2(centre_x - hero_size.x * 0.5, floor_y - hero_height - (4.0 + _lift * 6.0) * k), hero_size), false)
	# The bar and its plates.
	_bench.draw_line(Vector2(centre_x - 198.0 * k, bar_y), Vector2(centre_x + 198.0 * k, bar_y), Color("d7dbe4"), 9.0 * k)
	for side: float in [-1.0, 1.0]:
		_bench.draw_rect(Rect2(centre_x + (side * 132.0 - 5.0) * k, bar_y - 13.0 * k, 10.0 * k, 26.0 * k), Color("a9aebb"))
	for plate: int in range(RepsCardGame.STREAK_TO_WIN):
		var shown: float = clampf(_plates - float(plate), 0.0, 1.0)
		if shown <= 0.0:
			continue
		var side: float = -1.0 if plate % 2 == 0 else 1.0
		var slot: int = plate / 2
		var height: float = (104.0 - float(slot) * 13.0) * k
		var thick: float = 13.0 * k
		# A plate slides on from outside the bar.
		var x: float = centre_x + side * (148.0 + float(slot) * 15.0 + (1.0 - shown) * 60.0) * k
		var color: Color = PLATE_COLORS[slot % PLATE_COLORS.size()]
		color.a = shown
		var plate_box: StyleBoxFlat = UIStyle.box(color, Color(0, 0, 0, 0.5 * shown), 2, int(5.0 * k))
		_bench.draw_style_box(plate_box, Rect2(x - thick * 0.5, bar_y - height * 0.5, thick, height))
	if _lift > 0.6:
		_bench.draw_string(UIStyle.font_title(), Vector2(centre_x - 150.0, 56.0), "LIFT!", HORIZONTAL_ALIGNMENT_CENTER, 300, 64, UIStyle.GOLD)


func _build_example(box: Control) -> void:
	# A 3-power card, the next card turns over as a 5: "Higher" was right, a plate slides onto the bar. Then it starts again.
	var units: Array[CardData] = CardGamePool.units(Session.content, zone())
	var low_card: CardData = null
	var high_card: CardData = null
	for card: CardData in units:
		if low_card == null or card.attack < low_card.attack:
			low_card = card
		if high_card == null or card.attack > high_card.attack:
			high_card = card
	if low_card == null or high_card == null:
		return
	var card_scale: float = 0.46
	var first: Control = face(low_card, card_scale)
	first.position = Vector2(70, 14)
	box.add_child(first)
	var arrow: Label = UIKit.label("▲ Higher", &"", 30, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	arrow.position = Vector2(230, 86)
	arrow.size = Vector2(200, 40)
	box.add_child(arrow)
	var second: Control = Control.new()
	second.position = Vector2(450, 14)
	second.size = CardView.SIZE * card_scale
	second.custom_minimum_size = second.size
	second.pivot_offset = second.size * 0.5
	box.add_child(second)
	var verdict: Label = UIKit.label("", &"", 28, UIStyle.GOOD, HORIZONTAL_ALIGNMENT_CENTER)
	verdict.position = Vector2(230, 130)
	verdict.size = Vector2(200, 40)
	box.add_child(verdict)
	var turn_up: Callable = func() -> void:
		for old: Node in second.get_children():
			old.queue_free()
		second.add_child(face(high_card, card_scale))
		verdict.text = "%d > %d: right!" % [high_card.attack, low_card.attack]
	var turn_down: Callable = func() -> void:
		for old: Node in second.get_children():
			old.queue_free()
		second.add_child(back(card_scale))
		verdict.text = ""
	turn_down.call()
	var loop: Tween = box.create_tween().set_loops()
	loop.tween_interval(0.9)
	loop.tween_property(arrow, "modulate", Color(1.6, 1.4, 0.8), 0.15)
	loop.tween_property(arrow, "modulate", Color.WHITE, 0.15)
	loop.tween_property(second, "scale:x", 0.05, 0.12)
	loop.tween_callback(turn_up)
	loop.tween_property(second, "scale:x", 1.0, 0.12)
	loop.tween_interval(1.5)
	loop.tween_property(second, "scale:x", 0.05, 0.12)
	loop.tween_callback(turn_down)
	loop.tween_property(second, "scale:x", 1.0, 0.12)


## Shots and tests: `wrong` misses first (a tie cannot be missed, so it is guessed through), then `count` right guesses in a row.
func autoplay(count: int, wrong: int = 0) -> void:
	var missed: int = 0
	while missed < wrong and not game.is_over():
		var tie: bool = game.upcoming().attack == game.current().attack
		await guess(game.upcoming().attack < game.current().attack)
		if not tie:
			missed += 1
	var right: int = 0
	while right < count and not game.is_over():
		await guess(game.upcoming().attack >= game.current().attack)
		right += 1


func _shot_mid() -> void:
	await autoplay(5)


func _shot_end(won: bool) -> void:
	if won:
		await autoplay(8)
	else:
		await autoplay(0, 4)
