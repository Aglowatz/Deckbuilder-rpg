class_name FileCardScreen
extends CardGameScreen
## Fable Nov 16b (Part 2): the D.N.A.'s card minigame, "File in Order" (see `FileCardGame`): filing at the Mail Room's terminal, where
## "Pneumatic Soul Routing" used to be. Seven cards lie on a grey filing cabinet in the wrong order. Click one card, then another, to swap
## them (nine swaps at most) until they run in ascending cost (the same cost: the lower power first), then stamp the file. The first
## stamp on a wrong order is free and marks the cards out of place; the second is REJECTED. A right order: APPROVED, with a thump.
## Emits `solved` on the first approval: the zone scene grants the terminal's one-time reward, as it did for the old puzzle.

signal solved

const CARD_SCALE: float = 0.56
const STEEL: Color = Color("6f7682")
const STEEL_DARK: Color = Color("4a505b")

var game: FileCardGame
var _slots: Array[Button] = []
var _drawers: Array[Label] = []
var _swaps_chip: Label
var _check_chip: Label
var _stamp_button: FancyButton
var _selected: int = -1
## Slots the last stamp marked as out of place (cleared by the next swap of that slot).
var _marked: Array[int] = []
## Slots the last stamp found in place: their drawers are shut.
var _filed: Array[int] = []
var _busy: bool = false
var _stamp_mark: Label


func _init() -> void:
	super._init()
	screen_title = "Mail Room: File in Order"


func game_name() -> String:
	return "File in Order"


func backdrop_art() -> String:
	return "LOAD-DNA"


func how_lines() -> Array[String]:
	return [
		"Put the seven cards in order of COST, lowest on the left. Same cost: the lower POWER goes first.",
		"Click one card, then another, to swap them. You have nine swaps.",
		"Stamp the file to check it. The first wrong check is free and marks the cards out of place; the second is rejected.",
	]


## The terminal's reward is the zone's one-time puzzle gear, granted by the zone scene when `solved` fires; nothing is paid per game.
func _pay(stars: int) -> Dictionary:
	var result: Dictionary = {"gold": 0, "xp": 0, "item": "", "first_win": false, "stars": stars, "text": ""}
	if stars <= 0:
		return result
	var def: ZoneDef = ZoneDefs.get_def(zone())
	if def != null and not Session.flag(def.flag_puzzle_solved):
		result["first_win"] = true
		var piece: EquipmentData = Session.content.equipment_piece(def.puzzle_equipment_id)
		if piece != null:
			result["text"] = "%s joins your gear" % piece.source_name
	return result


func _build_table(box: VBoxContainer) -> void:
	var chips: HBoxContainer = UIKit.hbox(16)
	chips.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(chips)
	_swaps_chip = chip("", "Swaps")
	chips.add_child(_swaps_chip)
	_check_chip = chip("", "Checks")
	chips.add_child(_check_chip)
	# The cabinet: a grey steel face, one drawer per slot, the cards standing on top of their drawers.
	var cabinet: PanelContainer = PanelContainer.new()
	cabinet.name = "Cabinet"
	cabinet.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var steel: StyleBoxFlat = UIStyle.box(STEEL, STEEL_DARK, 6, 10, 8)
	for side: String in ["left", "right", "top", "bottom"]:
		steel.set("content_margin_" + side, 16.0)
	cabinet.add_theme_stylebox_override("panel", steel)
	box.add_child(cabinet)
	var row: HBoxContainer = UIKit.hbox(12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	cabinet.add_child(row)
	for index: int in range(FileCardGame.CARDS):
		var column: VBoxContainer = UIKit.vbox(6)
		row.add_child(column)
		var slot: Button = Button.new()
		slot.name = "Slot%d" % (index + 1)
		slot.custom_minimum_size = CardView.SIZE * CARD_SCALE
		slot.focus_mode = Control.FOCUS_ALL
		for state_name: String in ["normal", "pressed", "disabled"]:
			slot.add_theme_stylebox_override(state_name, UIStyle.box(Color(0.18, 0.2, 0.24), STEEL_DARK, 2, 8))
		slot.add_theme_stylebox_override("hover", UIStyle.box(Color(0.24, 0.26, 0.3), UIStyle.GOLD_DIM, 2, 8))
		slot.add_theme_stylebox_override("focus", UIStyle.focus_ring())
		slot.pressed.connect(func() -> void: pick(index))
		column.add_child(slot)
		_slots.append(slot)
		var drawer: Label = UIKit.label("", &"", 20, UIStyle.INK, HORIZONTAL_ALIGNMENT_CENTER)
		drawer.name = "Drawer%d" % (index + 1)
		drawer.custom_minimum_size = Vector2(0, 40)
		drawer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		drawer.add_theme_font_override("font", UIStyle.font_bold())
		column.add_child(drawer)
		_drawers.append(drawer)
	var legend: Label = UIKit.label("lowest cost  ◄                                                      ►  highest cost", &"", 20, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(legend)
	var buttons: HBoxContainer = UIKit.hbox(18)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	_stamp_button = game_button("", &"PrimaryButton", Vector2(360, 72), stamp)
	_stamp_button.name = "Stamp"
	PromptText.bind(_stamp_button, "Stamp the file  (Space)", &"text", "Stamp the file")
	buttons.add_child(_stamp_button)


func _new_game() -> void:
	game = FileCardGame.deal(CardGamePool.cards(Session.content, zone()), deal_rng())
	_selected = -1
	_marked.clear()
	_filed.clear()
	_busy = false
	if _stamp_mark != null and is_instance_valid(_stamp_mark):
		_stamp_mark.queue_free()
	_stamp_mark = null
	set_status("Click two cards to swap them. Lowest cost on the left.")
	for index: int in range(_slots.size()):
		_fill(index)
	_refresh()


func _on_play() -> void:
	_refresh()


func _fill(index: int) -> void:
	var slot: Button = _slots[index]
	for old: Node in slot.get_children():
		slot.remove_child(old)
		old.queue_free()
	if index >= game.cards.size():
		return
	var view: Control = face(game.cards[index], CARD_SCALE)
	slot.add_child(view)
	slot.tooltip_text = "%s (cost %d%s)" % [game.cards[index].display_name, game.cards[index].energy_value(), ", power %d" % game.cards[index].attack if game.cards[index].is_unit() else ""]


func _refresh() -> void:
	_swaps_chip.text = "Swaps %d / %d" % [game.swaps, FileCardGame.MAX_SWAPS]
	_swaps_chip.add_theme_color_override("font_color", Color("ff9d98") if game.swaps_left() <= 2 else UIStyle.GOLD)
	_check_chip.text = "Free check: %s" % ("1 left" if game.free_checks_left() > 0 else "used")
	for index: int in range(_slots.size()):
		var slot: Button = _slots[index]
		slot.disabled = _busy or game.is_over() or state != "playing"
		var view: Control = slot.get_node_or_null(^"Face") as Control
		if view != null:
			view.position.y = -16.0 if index == _selected else 0.0
			view.modulate = Color(1.0, 0.55, 0.5) if _marked.has(index) else (Color(1.0, 0.95, 0.72) if index == _selected else Color.WHITE)
		var filed: bool = _filed.has(index)
		_drawers[index].text = "%d  %s" % [index + 1, "FILED" if filed else "▬"]
		_drawers[index].add_theme_stylebox_override("normal", UIStyle.box(Color("9fd0a0") if filed else Color("b9bec8"), STEEL_DARK, 2, 4))
	_stamp_button.disabled = _busy or game.is_over() or state != "playing"


func _input(event: InputEvent) -> void:
	if state != "playing" or _busy or how_is_open():
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: int = int((event as InputEventKey).keycode)
		if code >= KEY_1 and code <= KEY_7:
			get_viewport().set_input_as_handled()
			pick(code - KEY_1)
		elif code == KEY_SPACE:
			get_viewport().set_input_as_handled()
			stamp()
	elif event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed and (event as InputEventJoypadButton).button_index == JOY_BUTTON_X:
		# X stamps wherever the focus is (A picks the focused card).
		get_viewport().set_input_as_handled()
		stamp()


## A click on slot `index`: the first click picks a card up, the second swaps it with that slot's card (the same slot puts it down).
func pick(index: int) -> void:
	if state != "playing" or _busy or game.is_over() or index >= game.cards.size():
		return
	if _selected < 0:
		_selected = index
		Audio.sfx(&"card_pickup", -6.0, 0.08)
		_refresh()
		return
	if _selected == index:
		_selected = -1
		Audio.sfx(&"card_return", -8.0)
		_refresh()
		return
	if game.swaps_left() <= 0:
		Audio.sfx(&"ui_error", -6.0)
		set_status("No swaps left: stamp the file.", Color("ff9d98"))
		_selected = -1
		_refresh()
		return
	var other: int = _selected
	_selected = -1
	_swap(other, index)


func _swap(a: int, b: int) -> void:
	_busy = true
	var view_a: Control = _slots[a].get_node_or_null(^"Face") as Control
	var view_b: Control = _slots[b].get_node_or_null(^"Face") as Control
	game.swap(a, b)
	_marked.erase(a)
	_marked.erase(b)
	_filed.erase(a)
	_filed.erase(b)
	Audio.sfx(&"card_play_cheap", -6.0, 0.1)
	if animate and view_a != null and view_b != null:
		# The two cards slide past each other, then the slots take their new cards.
		var offset: Vector2 = _slots[b].global_position - _slots[a].global_position
		view_a.z_index = 3
		var slide: Tween = create_tween().set_parallel(true)
		slide.tween_property(view_a, "position", offset + Vector2(0, -22), 0.2).set_trans(Tween.TRANS_QUAD)
		slide.tween_property(view_b, "position", -offset, 0.2).set_trans(Tween.TRANS_QUAD)
		await slide.finished
		if not is_inside_tree():
			return
	_fill(a)
	_fill(b)
	_busy = false
	set_status("%d swap%s left." % [game.swaps_left(), "" if game.swaps_left() == 1 else "s"] if game.swaps_left() > 0 else "That was the last swap: stamp the file.")
	_refresh()
	if is_inside_tree():
		_slots[b].grab_focus()


## The stamp: APPROVED, a free look at what is out of place, or REJECTED.
func stamp() -> void:
	if state != "playing" or _busy or game.is_over():
		return
	_busy = true
	_selected = -1
	var wrong: Array[int] = game.stamp()
	_marked = wrong.duplicate()
	_filed.clear()
	for index: int in range(game.cards.size()):
		if not wrong.has(index):
			_filed.append(index)
	_refresh()
	if game.approved:
		await _thump("APPROVED", Color("3f9a52"))
		if not is_inside_tree():
			return
		var def: ZoneDef = ZoneDefs.get_def(zone())
		var first: bool = def != null and not Session.flag(def.flag_puzzle_solved)
		var detail: String = "Seven cards, in order, in %d swap%s." % [game.swaps, "" if game.swaps == 1 else "s"]
		if first and _story != null:
			detail = "%s\n%s" % [detail, _story.text("puzzle.solved")]
		finish(true, game.stars(), "Approved!", detail)
		if first:
			solved.emit()
		return
	if game.rejected:
		await _thump("REJECTED", Color("b8372f"))
		if not is_inside_tree():
			return
		finish(false, 0, "Rejected", "The cards in red were out of place. The cabinet shuffles itself for the next applicant.")
		return
	Audio.sfx(&"book", -4.0)
	shake_table(5.0)
	set_status("%d card%s out of place (in red). That was the free check: the next wrong stamp is rejected." % [wrong.size(), "" if wrong.size() == 1 else "s"], Color("ffcf70"))
	_busy = false
	_refresh()


## The rubber stamp comes down across the cabinet.
func _thump(text: String, ink: Color) -> void:
	_stamp_mark = UIKit.label(text, &"HeadingLabel", 150, ink, HORIZONTAL_ALIGNMENT_CENTER)
	_stamp_mark.name = "StampMark"
	_stamp_mark.add_theme_font_override("font", UIStyle.font_bold())
	_stamp_mark.add_theme_constant_override("outline_size", 14)
	_stamp_mark.add_theme_color_override("font_outline_color", Color(0.98, 0.95, 0.88, 0.9))
	_stamp_mark.add_theme_stylebox_override("normal", UIStyle.box(Color(0, 0, 0, 0), ink, 10, 14))
	_stamp_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stamp_mark.z_index = 40
	_stamp_mark.rotation_degrees = -9.0
	add_child(_stamp_mark)
	_place_stamp()
	_place_stamp.call_deferred()  # once more after the layout (a shot stamps in the frame the screen opens)
	if not animate:
		Audio.sfx(&"hit_heavy", -2.0)
		return
	_stamp_mark.scale = Vector2(2.6, 2.6)
	_stamp_mark.modulate.a = 0.0
	var down: Tween = create_tween().set_parallel(true)
	down.tween_property(_stamp_mark, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	down.tween_property(_stamp_mark, "modulate:a", 1.0, 0.1)
	await down.finished
	Audio.sfx(&"hit_heavy", -2.0)
	Audio.sfx(&"book", -4.0)
	shake_table(12.0)
	await pause(0.9)


## The stamp mark lies across the middle of the cabinet.
func _place_stamp() -> void:
	if _stamp_mark == null or not is_instance_valid(_stamp_mark) or not is_inside_tree():
		return
	_stamp_mark.size = Vector2(1000, 220)
	var centre: Vector2 = get_global_transform().affine_inverse() * _stage.get_global_rect().get_center()
	_stamp_mark.position = centre - _stamp_mark.size * 0.5
	_stamp_mark.pivot_offset = _stamp_mark.size * 0.5


func _build_example(box: Control) -> void:
	# Three cards, costs 3 - 1 - 2: the 3 and the 1 swap, then the 3 and the 2, and the stamp comes down. Then it starts again.
	var by_cost: Dictionary = {}
	for card: CardData in CardGamePool.cards(Session.content, zone()):
		if not by_cost.has(card.energy_value()):
			by_cost[card.energy_value()] = card
	for cost: int in [1, 2, 3]:
		if not by_cost.has(cost):
			return
	var card_scale: float = 0.36
	var xs: Array[float] = [150.0, 290.0, 430.0]
	var three: Control = face(by_cost[3] as CardData, card_scale)
	var one: Control = face(by_cost[1] as CardData, card_scale)
	var two: Control = face(by_cost[2] as CardData, card_scale)
	for view: Control in [three, one, two]:
		box.add_child(view)
	var mark: Label = UIKit.label("APPROVED", &"", 44, Color("3f9a52"), HORIZONTAL_ALIGNMENT_CENTER)
	mark.add_theme_font_override("font", UIStyle.font_bold())
	mark.add_theme_constant_override("outline_size", 8)
	mark.add_theme_color_override("font_outline_color", Color(0.98, 0.95, 0.88))
	mark.position = Vector2(170, 180)
	mark.size = Vector2(360, 54)
	mark.rotation_degrees = -6.0
	box.add_child(mark)
	var loop: Tween = box.create_tween().set_loops()
	loop.tween_callback(func() -> void:
		three.position = Vector2(xs[0], 10)
		one.position = Vector2(xs[1], 10)
		two.position = Vector2(xs[2], 10)
		mark.modulate.a = 0.0)
	loop.tween_interval(0.8)
	loop.tween_property(three, "position:x", xs[1], 0.25)
	loop.parallel().tween_property(one, "position:x", xs[0], 0.25)
	loop.tween_interval(0.5)
	loop.tween_property(three, "position:x", xs[2], 0.25)
	loop.parallel().tween_property(two, "position:x", xs[1], 0.25)
	loop.tween_interval(0.4)
	loop.tween_property(mark, "modulate:a", 1.0, 0.1)
	loop.tween_interval(1.4)


## Shots and tests: `swaps` swaps that each put a card in its place (all of them when -1), then `stamps` stamps.
func autoplay(swaps: int = -1, stamps: int = 1) -> void:
	var wanted: Array[CardData] = game.sorted_cards()
	var done: int = 0
	for index: int in range(game.cards.size()):
		if swaps >= 0 and done >= swaps:
			break
		if game.cards[index] != wanted[index]:
			await _swap(index, game.cards.find(wanted[index]))
			done += 1
	for _stamp: int in range(stamps):
		if game.is_over():
			break
		await stamp()


func _shot_mid() -> void:
	await autoplay(2, 1)


func _shot_end(won: bool) -> void:
	if won:
		await autoplay(-1, 1)
	else:
		await autoplay(1, 2)
