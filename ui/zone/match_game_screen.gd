class_name MatchGameScreen
extends OverlayScreen
## The matching card minigame (Part H): a 4x4 table of face-down cards, flip pairs, 14 moves.

signal game_finished(stars: int, reward: Dictionary)

const COLUMNS: int = 4
const CARD_SIZE: Vector2 = Vector2(210, 190)

var game: MatchGame
var _story: ZoneStoryText
var _buttons: Array[Button] = []
var _moves_label: Label
var _status: Label
var _busy: bool = false
var _grid: GridContainer
var _result_box: VBoxContainer


func _init() -> void:
	screen_title = "The Rec Room: Match the Memories"
	close_text = "Leave (Esc)"


func _build() -> void:
	_story = ZoneStoryText.shared()
	var center: CenterContainer = CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	var column: VBoxContainer = UIKit.vbox(14)
	center.add_child(column)
	_moves_label = UIKit.label("", &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_moves_label)
	_status = UIKit.label("\n".join(_story.get_lines("match.intro")), &"MutedLabel", 22, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_status)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	column.add_child(_grid)
	_result_box = UIKit.vbox(10)
	column.add_child(_result_box)
	_new_game()


func _new_game() -> void:
	game = MatchGame.new()
	_busy = false
	for child: Node in _grid.get_children():
		child.queue_free()
	for child: Node in _result_box.get_children():
		child.queue_free()
	_buttons.clear()
	for index: int in range(game.slot_count()):
		var button: Button = Button.new()
		button.custom_minimum_size = CARD_SIZE
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(func() -> void: _flip(index))
		_grid.add_child(button)
		_buttons.append(button)
	_status.text = "\n".join(_story.get_lines("match.intro"))
	_refresh()


func _refresh() -> void:
	_moves_label.text = "Moves left: %d      Pairs: %d / %d" % [game.moves_left(), game.pairs_found, MatchGame.PAIRS]
	var names: Array[String] = _story.get_lines("match.pairs")
	for index: int in range(_buttons.size()):
		var button: Button = _buttons[index]
		for child: Node in button.get_children():
			child.queue_free()
		var up: bool = game.matched[index] or game.face_up.has(index)
		button.text = ""
		button.disabled = game.matched[index]
		if up:
			var box: VBoxContainer = UIKit.vbox(2)
			box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			box.alignment = BoxContainer.ALIGNMENT_CENTER
			box.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var icon_index: int = game.cards[index]
			var texture: Texture2D = load("%s%s.svg" % [CardIcons.BASE, MatchGame.ICONS[icon_index]]) as Texture2D
			var glyph: TextureRect = CardIcons.glyph(texture, UIStyle.GOLD if game.matched[index] else UIStyle.PARCHMENT, Vector2(96, 96))
			glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			box.add_child(glyph)
			var caption: Label = UIKit.label(names[icon_index], &"", 17, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
			caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			box.add_child(caption)
			button.add_child(box)
		else:
			button.text = "?"
			button.add_theme_font_size_override("font_size", 64)


func _flip(index: int) -> void:
	if _busy or game.is_over():
		return
	var outcome: String = game.flip(index)
	if outcome == "ignored":
		return
	Audio.sfx(&"card_draw", -4.0)
	_refresh()
	if outcome == "first":
		return
	_busy = true
	if outcome == "match":
		Audio.sfx(&"ui_confirm", -4.0)
	await get_tree().create_timer(0.55 if outcome == "mismatch" else 0.2).timeout
	game.resolve()
	_busy = false
	_refresh()
	if game.is_won() or game.is_lost():
		_finish()


func _finish() -> void:
	_busy = true
	var stars: int = game.stars()
	var reward: Dictionary = MatchGame.apply_result(stars)
	var lines: Array[String] = _story.get_lines("match.win") if stars > 0 else _story.get_lines("match.lose")
	if bool(reward["first_win"]):
		lines = _story.get_lines("match.first") + lines
	_status.text = "\n".join(lines)
	Audio.sfx(&"victory" if stars > 0 else &"defeat")
	var parts: PackedStringArray = []
	parts.append("%s  (%d moves)" % ["★".repeat(stars) + "☆".repeat(3 - stars) if stars > 0 else "Out of moves", game.moves])
	if int(reward["gold"]) > 0:
		parts.append("+%d gold" % int(reward["gold"]))
	if int(reward["xp"]) > 0:
		parts.append("+%d XP" % int(reward["xp"]))
	if not str(reward["item"]).is_empty():
		parts.append(Session.content.item(str(reward["item"])).display_name)
	_result_box.add_child(UIKit.label("   ".join(parts), &"", 30, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(16)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_result_box.add_child(row)
	var again: FancyButton = FancyButton.make("Play again", &"PrimaryButton", Vector2(240, 60))
	again.pressed.connect(_new_game)
	row.add_child(again)
	var leave: FancyButton = FancyButton.make("Leave", &"", Vector2(200, 60))
	leave.pressed.connect(request_close)
	row.add_child(leave)
	game_finished.emit(stars, reward)
