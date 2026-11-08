class_name CardMatchScreen
extends OverlayScreen
## Overnight Nov 7-8, Part 6.3: Dex Shufflewick's card-matching table (CardMatchCircuit). The MatchGame rules (16 cards, 8 pairs, 14 moves) dealt
## from a Path's real card art: face down they show a card back, face up the card itself (art and name). Beat Dex's score (12 moves, 11 at the
## final table) to earn the table's flag. Flourishes are code-only: a gold pulse and sparkles on a pair, a shake on a miss, a moves meter that
## turns red near the end, the result's stars popping in.

signal table_finished(won: bool, moves: int, earned: bool)

const COLUMNS: int = 8
const CARD_SCALE: float = 0.62
const MISS_SECONDS: float = 0.7

var table: String = "beefcake"
var game: MatchGame
var _ids: Array[String] = []
var _slots: Array[Button] = []
var _busy: bool = false
var _grid: GridContainer
var _moves: Label
var _target: Label
var _status: Label
var _result: VBoxContainer
## Tests set 0.
var miss_seconds: float = MISS_SECONDS


func _init() -> void:
	screen_title = "Dex's Table"
	close_text = "Leave (Esc)"


func music_cue() -> String:
	return MusicDirector.minigame(table if CardMatchCircuit.ZONES.has(table) else "necrocrat")


func _build() -> void:
	screen_title = "Dex's Table: the Final Deal" if table == CardMatchCircuit.FINAL else "Dex's Table: %s Cards" % Affinity.display_name(ZoneEffects.path_of(table))
	if title_label != null:
		title_label.text = screen_title
	_ids = CardMatchCircuit.card_ids(table, Session.content)
	var column: VBoxContainer = UIKit.vbox(12)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(column)
	var top: HBoxContainer = UIKit.hbox(40)
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(top)
	_moves = UIKit.label("", &"HeadingLabel", 34)
	_moves.name = "Moves"
	top.add_child(_moves)
	_target = UIKit.label("Beat Dex: %d moves or fewer" % CardMatchCircuit.target_for(table), &"", 26, UIStyle.GOLD)
	top.add_child(_target)
	_status = UIKit.label("Flip two cards at a time. Find all eight pairs.", &"MutedLabel", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_status)
	var center: CenterContainer = CenterContainer.new()
	column.add_child(center)
	_grid = GridContainer.new()
	_grid.name = "Table"
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	center.add_child(_grid)
	_result = UIKit.vbox(10)
	_result.name = "Result"
	column.add_child(_result)
	_new_game()


func _new_game() -> void:
	game = MatchGame.new()
	_busy = false
	for child: Node in _grid.get_children():
		child.queue_free()
	for child: Node in _result.get_children():
		child.queue_free()
	_slots.clear()
	for index: int in range(game.slot_count()):
		var slot: Button = Button.new()
		slot.name = "Slot_%d" % index
		slot.custom_minimum_size = CardView.SIZE * CARD_SCALE
		slot.focus_mode = Control.FOCUS_ALL
		slot.pivot_offset = CardView.SIZE * CARD_SCALE * 0.5
		slot.add_theme_stylebox_override("normal", UIStyle.box(Color(0.12, 0.08, 0.18), UIStyle.GOLD_DIM, 3, 12))
		slot.add_theme_stylebox_override("hover", UIStyle.box(Color(0.16, 0.11, 0.24), UIStyle.GOLD, 3, 12))
		slot.add_theme_stylebox_override("focus", UIStyle.focus_ring())
		slot.pressed.connect(func() -> void: _flip(index))
		_grid.add_child(slot)
		_slots.append(slot)
	_refresh()


## The card a slot shows when face up.
func card_at(index: int) -> CardData:
	var pair: int = game.cards[index]
	return Session.content.card(_ids[pair]) if pair < _ids.size() else null


func _refresh() -> void:
	var left: int = game.moves_left()
	_moves.text = "Moves: %d / %d" % [game.moves, MatchGame.MAX_MOVES]
	_moves.add_theme_color_override("font_color", Color("ff8a7a") if game.moves > CardMatchCircuit.target_for(table) else UIStyle.PARCHMENT)
	for index: int in range(_slots.size()):
		var slot: Button = _slots[index]
		for child: Node in slot.get_children():
			child.queue_free()
		var up: bool = game.matched[index] or game.face_up.has(index)
		slot.disabled = game.matched[index]
		if up and card_at(index) != null:
			var view: Control = CardView.wrapped(card_at(index), CARD_SCALE)
			view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if game.matched[index]:
				view.modulate = Color(1.0, 0.95, 0.75)
			slot.add_child(view)
		else:
			var back: Label = UIKit.label("?", &"", 72, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
			back.add_theme_font_override("font", UIStyle.font_title())
			back.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			back.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			back.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(back)
	if left <= 2 and not game.is_over():
		_status.text = "Careful: %d move%s left." % [left, "" if left == 1 else "s"]


func _flip(index: int) -> void:
	if _busy or game.is_over():
		return
	var outcome: String = game.flip(index)
	if outcome == "ignored":
		return
	Audio.sfx(&"card_draw", -4.0)
	_refresh()
	var slot: Button = _slots[index]
	var flip: Tween = create_tween()
	slot.scale = Vector2(0.85, 1.0)
	flip.tween_property(slot, "scale", Vector2.ONE, 0.12)
	if outcome == "first":
		return
	_busy = true
	var pair: Array[int] = [game.face_up[0], game.face_up[1]]
	if outcome == "match":
		Audio.sfx(&"ui_confirm", -4.0)
		_status.text = "A pair!"
		for i: int in pair:
			var pulse: Tween = create_tween()
			pulse.tween_property(_slots[i], "scale", Vector2(1.08, 1.08), 0.1)
			pulse.tween_property(_slots[i], "scale", Vector2.ONE, 0.14)
			_sparkle(_slots[i].get_global_rect().get_center())
		if miss_seconds > 0.0:
			await get_tree().create_timer(0.25).timeout
	else:
		_status.text = "Not a pair."
		for i: int in pair:
			var base: float = _slots[i].position.x
			var shake: Tween = create_tween()
			for k: int in range(4):
				shake.tween_property(_slots[i], "position:x", base + (6.0 if k % 2 == 0 else -6.0), 0.04)
			shake.tween_property(_slots[i], "position:x", base, 0.04)
		if miss_seconds > 0.0:
			await get_tree().create_timer(miss_seconds).timeout
	if not is_inside_tree():
		return
	game.resolve()
	_busy = false
	_refresh()
	if game.is_won() or game.is_lost():
		_finish()


func _sparkle(at: Vector2) -> void:
	var burst: CPUParticles2D = CPUParticles2D.new()
	burst.position = at
	burst.amount = 18
	burst.lifetime = 0.7
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.spread = 180.0
	burst.initial_velocity_min = 140.0
	burst.initial_velocity_max = 300.0
	burst.gravity = Vector2(0, 380)
	burst.scale_amount_min = 3.0
	burst.scale_amount_max = 7.0
	burst.color = Color("ffe08a")
	burst.z_index = 50
	add_child(burst)
	burst.emitting = true
	get_tree().create_timer(1.0).timeout.connect(burst.queue_free)


## Ends the table: records the result in the Circuit, refreshes the quest, and shows the outcome.
func _finish() -> void:
	_busy = true
	var won: bool = game.is_won()
	var earned: bool = CardMatchCircuit.record(Session.flags, table, won, game.moves)
	if earned:
		Session.refresh_quests()
		Session.save_game()
	Audio.sting(&"STG-MINI-SUCCESS" if won else &"STG-MINI-FAIL")
	var beat: bool = won and game.moves <= CardMatchCircuit.target_for(table)
	var line: String
	if earned:
		line = "You beat Dex's score! %s" % ("The Lucky Spats is yours: turn in the Circuit." if table == CardMatchCircuit.FINAL else "One table closer to the final deal.")
	elif beat:
		line = "You beat Dex's score again. He pretends not to mind."
	elif won:
		line = "All pairs in %d moves: Dex did it in %d. So close." % [game.moves, CardMatchCircuit.target_for(table)]
	else:
		line = "Out of moves. Dex shuffles, grinning. Again?"
	_status.text = line
	var stars: Label = UIKit.label("★★★" if beat else ("★★" if won else "☆"), &"", 60, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	stars.name = "Stars"
	stars.pivot_offset = Vector2(120, 40)
	_result.add_child(stars)
	stars.scale = Vector2(0.4, 0.4)
	create_tween().tween_property(stars, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_result.add_child(row)
	var again: FancyButton = FancyButton.make("Deal again", &"PrimaryButton", Vector2(240, 60))
	again.pressed.connect(_new_game)
	row.add_child(again)
	var leave: FancyButton = FancyButton.make("Leave", &"", Vector2(200, 60))
	leave.pressed.connect(request_close)
	row.add_child(leave)
	table_finished.emit(won, game.moves, earned)
