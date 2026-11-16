class_name SortCardScreen
extends CardGameScreen
## Fable Nov 16b (Part 2): the Verdant Dump's card minigame, "Sort It Out" (see `SortCardGame`): conveyor sorting on Recycle Rhonda's
## fair stage. Cards ride a scrap-wood belt; send the front card (the one in the gold frame) into the bin of its TYPE - Unit, Spell,
## Infrastructure or Other - before it falls off the end. Click a bin, press 1-4, or use the arrows / the D-pad (left, down, up, right).

const CARD_SCALE: float = 0.5
const BELT_SIZE: Vector2 = Vector2(1320, 300)
const BIN_SIZE: Vector2 = Vector2(300, 138)
const BIN_COLORS: Array[Color] = [Color("8a4a36"), Color("3f6f8a"), Color("7a6a3a"), Color("5a4a7a")]
const BIN_KEYS: Array[String] = ["1  ◄", "2  ▼", "3  ▲", "4  ►"]

var game: SortCardGame
var clock: float = 0.0
var _belt: Control
var _bins: Array[Button] = []
var _nodes: Dictionary = {}
var _front_name: Label
var _sorted_chip: Label
var _lost_chip: Label
var _ended: bool = false


func _init() -> void:
	super._init()
	screen_title = "County Fair: Sort It Out"


func game_name() -> String:
	return "Sort It Out"


func backdrop_art() -> String:
	return "LOAD-DUMP"


func host_portrait() -> String:
	return "NPC-RHONDA"


func host_name() -> String:
	return "Recycle Rhonda"


func how_lines() -> Array[String]:
	return [
		"Cards ride the belt. Send the front card (gold frame) into the bin of its TYPE before it falls off the end.",
		"The type is printed under each card's picture: Unit, Spell, Infrastructure. Tools, Traps and Wonders go in Other.",
		"Twenty cards. Sixteen in the right bin wins; the fifth one lost stops the belt.",
	]


func _pay(stars: int) -> Dictionary:
	return SortGame.apply_result(stars)


func _build_table(box: VBoxContainer) -> void:
	var chips: HBoxContainer = UIKit.hbox(16)
	chips.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(chips)
	_sorted_chip = chip("", "Sorted")
	chips.add_child(_sorted_chip)
	_lost_chip = chip("", "Lost")
	chips.add_child(_lost_chip)
	_belt = Control.new()
	_belt.name = "Belt"
	_belt.custom_minimum_size = BELT_SIZE
	_belt.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_belt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_belt.draw.connect(_draw_belt)
	box.add_child(_belt)
	_front_name = UIKit.label("", &"", 26, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_front_name.name = "FrontName"
	_front_name.add_theme_font_override("font", UIStyle.font_bold())
	box.add_child(_front_name)
	var row: HBoxContainer = UIKit.hbox(22)
	row.name = "Bins"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(row)
	for bin: int in range(SortCardGame.BIN_COUNT):
		var button: Button = _make_bin(bin)
		row.add_child(button)
		_bins.append(button)


## A painted bin: a wooden crate in the bin's colour with the type's icon(s), its name and its key.
func _make_bin(bin: int) -> Button:
	var button: Button = Button.new()
	button.name = "Bin%s" % CardGamePool.KIND_NAMES[bin]
	button.custom_minimum_size = BIN_SIZE
	button.focus_mode = Control.FOCUS_ALL
	var wood: Color = BIN_COLORS[bin]
	for state_name: String in ["normal", "hover", "pressed", "disabled"]:
		var crate: StyleBoxFlat = UIStyle.box(wood.lightened(0.12) if state_name == "hover" else (wood.darkened(0.15) if state_name == "pressed" else wood), Color("3a2a1c"), 5, 10, 4)
		crate.border_width_top = 12
		button.add_theme_stylebox_override(state_name, crate)
	button.add_theme_stylebox_override("focus", UIStyle.focus_ring())
	button.pressed.connect(func() -> void: press(bin))
	var column: VBoxContainer = UIKit.vbox(2)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(column)
	var icons: HBoxContainer = UIKit.hbox(6)
	icons.alignment = BoxContainer.ALIGNMENT_CENTER
	icons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(icons)
	var types: Array[CardEnums.CardType] = [CardEnums.CardType.UNIT]
	if bin == CardGamePool.Kind.SPELL:
		types = [CardEnums.CardType.SPELL]
	elif bin == CardGamePool.Kind.INFRASTRUCTURE:
		types = [CardEnums.CardType.INFRASTRUCTURE]
	elif bin == CardGamePool.Kind.OTHER:
		types = [CardEnums.CardType.TOOL, CardEnums.CardType.TRAP, CardEnums.CardType.WONDER]
	for type: CardEnums.CardType in types:
		var icon: TextureRect = IconArt.rect(IconArt.type_id(type), 46.0 if types.size() == 1 else 36.0)
		if icon != null:
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icons.add_child(icon)
	var title: Label = UIKit.label(CardGamePool.KIND_NAMES[bin], &"", 28, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_font_override("font", UIStyle.font_bold())
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title)
	var key: Label = UIKit.label(BIN_KEYS[bin], &"", 18, Color(1, 1, 1, 0.75), HORIZONTAL_ALIGNMENT_CENTER)
	key.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(key)
	return button


func _new_game() -> void:
	game = SortCardGame.deal(CardGamePool.cards(Session.content, zone()), CardGamePool.infrastructure(Session.content, zone()), deal_rng())
	clock = 0.0
	_ended = false
	for node: Variant in _nodes.values():
		(node as Control).queue_free()
	_nodes.clear()
	set_status("Gloves on. The belt is starting...")
	host_say(story_line("sort.shouts", 0))
	_refresh()


func _refresh() -> void:
	_sorted_chip.text = "Sorted %d / %d   (%d wins)" % [game.correct_count(), game.cards.size(), SortCardGame.TO_WIN]
	_lost_chip.text = "Lost %d   (the fifth stops the belt)" % game.lost_count()
	_lost_chip.add_theme_color_override("font_color", Color("ff9d98") if game.lost_count() >= 4 else UIStyle.GOLD)
	for button: Button in _bins:
		button.disabled = state != "playing" or game.is_finished()


func _on_play() -> void:
	_refresh()


func _input(event: InputEvent) -> void:
	if state != "playing" or how_is_open():
		return
	var bin: int = -1
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: int = int((event as InputEventKey).keycode)
		if code >= KEY_1 and code <= KEY_4:
			bin = code - KEY_1
		else:
			bin = [KEY_LEFT, KEY_DOWN, KEY_UP, KEY_RIGHT].find(code)
	elif event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		bin = [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_RIGHT].find((event as InputEventJoypadButton).button_index)
	if bin >= 0:
		get_viewport().set_input_as_handled()
		press(bin)


## Sends the front card to bin `bin`.
func press(bin: int) -> void:
	if state != "playing" or game.is_finished():
		return
	var card_index: int = game.next_card
	var result: SortCardGame.Result = game.press(bin, clock)
	if result == SortCardGame.Result.IGNORED:
		return
	var node: Control = _nodes.get(card_index) as Control
	_nodes.erase(card_index)
	if result == SortCardGame.Result.CORRECT:
		Audio.sfx(&"boing", -12.0, 0.25)  # the little squeak of the chute
		Audio.sfx(&"card_play_cheap", -8.0, 0.1)
		set_status("%s: right bin." % CardGamePool.KIND_NAMES[bin], UIStyle.GOOD)
		host_say(story_line("sort.shouts", game.correct_count() / 4))
		_send_to_bin(node, bin, true)
		pop(_bins[bin], 1.06)
	else:
		Audio.sfx(&"ui_error", -6.0)
		set_status("Wrong bin! That was %s." % _article(CardGamePool.KIND_NAMES[game.bin_of(card_index)]), Color("ff9d98"))
		shake_table()
		_send_to_bin(node, bin, false)
	_refresh()
	_check_end()


static func _article(kind: String) -> String:
	return ("an %s" if kind.left(1) in ["I", "O", "U"] and kind != "Unit" else "a %s") % kind


## The card leaves the belt for the bin: it shrinks toward the bin's mouth (a wrong one flashes red first).
func _send_to_bin(node: Control, bin: int, right: bool) -> void:
	if node == null:
		return
	if not animate:
		node.queue_free()
		return
	if not right:
		node.modulate = Color(1.0, 0.45, 0.4)
	node.pivot_offset = node.size * 0.5
	var bin_centre: Vector2 = _bins[bin].get_global_rect().get_center() - _belt.get_global_rect().position
	var fly: Tween = create_tween().set_parallel(true)
	fly.tween_property(node, "position", bin_centre - node.size * 0.5, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fly.tween_property(node, "scale", Vector2(0.25, 0.25), 0.28)
	fly.tween_property(node, "modulate:a", 0.0, 0.1).set_delay(0.2)
	fly.chain().tween_callback(node.queue_free)


func _process(delta: float) -> void:
	if state != "playing" or game == null or _ended:
		return
	clock += delta
	var fell: int = game.next_card
	if game.advance(clock) > 0:
		Audio.sfx(&"ui_error", -8.0)
		set_status("It fell off the end!", Color("ff9d98"))
		shake_table()
		for index: int in range(fell, game.next_card):
			var node: Control = _nodes.get(index) as Control
			_nodes.erase(index)
			if node != null:
				var drop: Tween = create_tween().set_parallel(true)
				drop.tween_property(node, "position:y", node.position.y + 200.0, 0.3)
				drop.tween_property(node, "modulate:a", 0.0, 0.3)
				drop.chain().tween_callback(node.queue_free)
		_refresh()
	_place_cards()
	_belt.queue_redraw()
	_check_end()


## Every card on the belt at its place; a card that has just appeared gets its node.
func _place_cards() -> void:
	var card_size: Vector2 = CardView.SIZE * CARD_SCALE
	for index: int in range(game.next_card, game.cards.size()):
		if SortCardGame.spawn_time(index) > clock:
			break
		var node: Control = _nodes.get(index) as Control
		if node == null:
			node = face(game.cards[index], CARD_SCALE)
			node.name = "BeltCard%d" % index
			node.size = card_size
			_belt.add_child(node)
			_nodes[index] = node
		var along: float = SortCardGame.progress(index, clock)
		node.position = Vector2(lerpf(-card_size.x * 0.6, BELT_SIZE.x - card_size.x * 0.75, along), (BELT_SIZE.y - card_size.y) * 0.5)
		node.modulate.a = clampf(along * 14.0, 0.0, 1.0)  # a card fades in as it comes onto the belt
		node.z_index = 2 if index == game.next_card else 1
	var front: CardData = game.cards[game.next_card] if game.front_visible(clock) else null
	_front_name.text = front.display_name if front != null else ""


func _check_end() -> void:
	if _ended or not game.is_finished():
		return
	_ended = true
	_refresh()
	_front_name.text = ""
	if game.is_won():
		var first: bool = not Session.flag(ZoneDefs.get_def(zone()).flag_minigame_first)
		var lines: String = story_line("sort.win")
		if first:
			lines = "%s\n%s" % [story_line("sort.first"), lines]
		finish(true, game.stars(), "Sorted! %d of %d" % [game.correct_count(), game.cards.size()], lines)
	else:
		finish(false, 0, "The belt stops", "%d sorted, %d lost. %s" % [game.correct_count(), game.lost_count(), story_line("sort.lose")])


## The belt: scrap planks with moving slats, rollers at both ends, a gold frame round the front card, the drop at the right.
func _draw_belt() -> void:
	var area: Vector2 = _belt.size
	var top: float = 34.0
	var band: Rect2 = Rect2(0.0, top, area.x, area.y - top * 2.0)
	_belt.draw_rect(band, Color("3a2b20"))
	var slat: float = 66.0
	var speed: float = 70.0
	for index: int in range(int(area.x / slat) + 2):
		var x: float = fposmod(float(index) * slat + clock * speed, area.x + slat) - slat
		_belt.draw_rect(Rect2(x, top + 4.0, slat - 6.0, band.size.y - 8.0), Color("4d3a2a") if index % 2 == 0 else Color("584433"))
		_belt.draw_line(Vector2(x + slat - 6.0, top + 4.0), Vector2(x + slat - 6.0, band.end.y - 4.0), Color(0, 0, 0, 0.35), 3.0)
	_belt.draw_rect(Rect2(0.0, top - 10.0, area.x, 12.0), Color("7a5a3a"))
	_belt.draw_rect(Rect2(0.0, band.end.y - 2.0, area.x, 12.0), Color("7a5a3a"))
	# The edge the cards fall off.
	_belt.draw_rect(Rect2(area.x - 26.0, top - 10.0, 26.0, band.size.y + 24.0), Color(0.75, 0.2, 0.15, 0.55))
	_belt.draw_string(UIStyle.font_bold(), Vector2(area.x - 150.0, top - 16.0), "THE END", HORIZONTAL_ALIGNMENT_RIGHT, 140, 20, Color("ff9d98"))
	if game != null and state == "playing" and game.front_visible(clock):
		var node: Control = _nodes.get(game.next_card) as Control
		if node != null:
			_belt.draw_rect(Rect2(node.position - Vector2(6, 6), node.size + Vector2(12, 12)), UIStyle.GOLD, false, 5.0)


func _build_example(box: Control) -> void:
	# A unit rides along and drops into the Unit bin, then a spell into the Spell bin. Then it starts again.
	var unit: CardData = null
	var spell: CardData = null
	for card: CardData in CardGamePool.cards(Session.content, zone()):
		if unit == null and CardGamePool.kind_of(card) == CardGamePool.Kind.UNIT:
			unit = card
		if spell == null and CardGamePool.kind_of(card) == CardGamePool.Kind.SPELL:
			spell = card
	if unit == null or spell == null:
		return
	var card_scale: float = 0.3
	var bins: Array[Label] = []
	for index: int in range(2):
		var bin: Label = UIKit.label(CardGamePool.KIND_NAMES[index], &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		bin.add_theme_stylebox_override("normal", UIStyle.box(BIN_COLORS[index], Color("3a2a1c"), 4, 8))
		bin.position = Vector2(170.0 + float(index) * 220.0, 176.0)
		bin.size = Vector2(170, 54)
		bin.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		box.add_child(bin)
		bins.append(bin)
	var cards: Array[Control] = [face(unit, card_scale), face(spell, card_scale)]
	for view: Control in cards:
		view.position = Vector2(24, 20)
		box.add_child(view)
	var loop: Tween = box.create_tween().set_loops()
	for index: int in range(2):
		var view: Control = cards[index]
		var bin_x: float = bins[index].position.x + 40.0
		loop.tween_callback(func() -> void:
			view.position = Vector2(24, 20)
			view.modulate.a = 1.0)
		loop.tween_property(view, "position:x", bin_x, 1.1)
		loop.tween_property(bins[index], "modulate", Color(1.5, 1.4, 1.0), 0.1)
		loop.tween_property(view, "position:y", 150.0, 0.2)
		loop.parallel().tween_property(view, "modulate:a", 0.0, 0.2)
		loop.tween_property(bins[index], "modulate", Color.WHITE, 0.15)
		loop.tween_interval(0.3)


## Shots and tests: plays the run without the clock - `count` cards into their right bins (a `wrong` number of them, the first ones, into a
## wrong bin), then leaves the next few cards riding the belt.
func autoplay(count: int, wrong: int = 0) -> void:
	for index: int in range(count):
		if game.is_finished():
			break
		clock = SortCardGame.spawn_time(game.next_card) + 1.2
		_place_cards()
		press(game.bin_of(game.next_card) if index >= wrong else (game.bin_of(game.next_card) + 1) % SortCardGame.BIN_COUNT)
	if not game.is_finished():
		clock = SortCardGame.spawn_time(mini(game.next_card + 2, game.cards.size() - 1)) + 0.4
		_place_cards()
		_belt.queue_redraw()


func _shot_mid() -> void:
	autoplay(9, 1)


func _shot_end(won: bool) -> void:
	if won:
		autoplay(20, 2)
	else:
		autoplay(5, 5)
