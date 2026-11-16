class_name OrderCardScreen
extends CardGameScreen
## Fable Nov 16b (Part 2): the Endless Buffet's card minigame, "Order Up" (see `OrderCardGame`): exact-cost orders at Chef Flambe
## Fontaine's kitchen pass. Three tickets hang on the rail; six cards lie on the pass. Click cards onto the plate until their costs add
## up to the ticket, then ring the bell. Keys 1-6 pick a card, Space rings the bell, R swaps the row.

const CARD_SCALE: float = 0.72
const PLATE_DROP: float = 34.0

var game: OrderCardGame
var _tickets: Array[PanelContainer] = []
var _ticket_labels: Array[Label] = []
var _slots: Array[Button] = []
var _plate: Label
var _back_chip: Label
var _bell: FancyButton
var _swap: FancyButton
var _row: HBoxContainer
var _busy: bool = false


func _init() -> void:
	super._init()
	screen_title = "Dinner in a Dash: Order Up"


func game_name() -> String:
	return "Order Up"


func backdrop_art() -> String:
	return "LOAD-BUFFET"


func host_portrait() -> String:
	return "NPC-FLAMBE"


func host_name() -> String:
	return "Chef Flambe Fontaine"


func how_lines() -> Array[String]:
	return [
		"The ticket shows a number. Pick cards from the pass whose COSTS add up to exactly that number.",
		"Ring the bell to send the plate. Three tickets finish the shift.",
		"Stuck? Swap the row for six new cards, twice a shift. Three wrong plates end it.",
	]


func _pay(stars: int) -> Dictionary:
	return OrderGame.apply_result(stars)


func _build_table(box: VBoxContainer) -> void:
	# The rail: three paper tickets hanging from a brass bar.
	var rail: PanelContainer = PanelContainer.new()
	rail.name = "TicketRail"
	rail.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var bar: StyleBoxFlat = UIStyle.box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0)
	bar.border_width_top = 8
	bar.border_color = BRASS
	bar.content_margin_top = 8.0
	rail.add_theme_stylebox_override("panel", bar)
	box.add_child(rail)
	var tickets: HBoxContainer = UIKit.hbox(34)
	tickets.alignment = BoxContainer.ALIGNMENT_CENTER
	rail.add_child(tickets)
	for index: int in range(OrderCardGame.TICKETS):
		var ticket: PanelContainer = PanelContainer.new()
		ticket.name = "Ticket%d" % (index + 1)
		ticket.custom_minimum_size = Vector2(170, 124)
		tickets.add_child(ticket)
		var text: Label = UIKit.label("", &"", 26, UIStyle.INK, HORIZONTAL_ALIGNMENT_CENTER)
		text.name = "Text"
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text.add_theme_font_override("font", UIStyle.font_bold())
		ticket.add_child(text)
		_tickets.append(ticket)
		_ticket_labels.append(text)
	# The pass: six cards, each a button; a picked card drops onto the plate strip under the row.
	_row = UIKit.hbox(14)
	_row.name = "Pass"
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(_row)
	for index: int in range(OrderCardGame.ROW_SIZE):
		var slot: Button = Button.new()
		slot.name = "Card%d" % (index + 1)
		slot.custom_minimum_size = CardView.SIZE * CARD_SCALE + Vector2(0, PLATE_DROP)
		slot.focus_mode = Control.FOCUS_ALL
		slot.add_theme_stylebox_override("normal", UIStyle.box(Color(0, 0, 0, 0)))
		slot.add_theme_stylebox_override("hover", UIStyle.box(Color(1, 1, 1, 0.07), Color(0, 0, 0, 0), 0, 12))
		slot.add_theme_stylebox_override("pressed", UIStyle.box(Color(1, 1, 1, 0.07), Color(0, 0, 0, 0), 0, 12))
		slot.add_theme_stylebox_override("disabled", UIStyle.box(Color(0, 0, 0, 0)))
		slot.add_theme_stylebox_override("focus", UIStyle.focus_ring())
		slot.pressed.connect(func() -> void: pick(index))
		_row.add_child(slot)
		_slots.append(slot)
	var plate_row: HBoxContainer = UIKit.hbox(18)
	plate_row.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(plate_row)
	_plate = chip("", "Plate")
	_plate.add_theme_font_size_override("font_size", 30)
	_plate.custom_minimum_size = Vector2(560, 0)
	plate_row.add_child(_plate)
	_back_chip = chip("", "SentBack")
	plate_row.add_child(_back_chip)
	var buttons: HBoxContainer = UIKit.hbox(18)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	_bell = game_button("", &"PrimaryButton", Vector2(340, 70), serve)
	_bell.name = "Bell"
	PromptText.bind(_bell, "Ring the bell  (Space)", &"text", "Ring the bell")
	buttons.add_child(_bell)
	_swap = game_button("", &"", Vector2(340, 70), swap_row)
	_swap.name = "SwapRow"
	buttons.add_child(_swap)


func _new_game() -> void:
	game = OrderCardGame.deal(CardGamePool.cards(Session.content, zone()), deal_rng())
	_busy = false
	set_status("Pick cards whose costs add up to the ticket, then ring the bell.")
	host_say(story_line("order.shouts", 0))
	_deal_row(false)
	_refresh()


func _on_play() -> void:
	_refresh()


## Puts the game's row on the pass (each card sliding in from above when `slide`).
func _deal_row(slide: bool) -> void:
	for index: int in range(_slots.size()):
		var slot: Button = _slots[index]
		for old: Node in slot.get_children():
			slot.remove_child(old)
			old.queue_free()
		if index >= game.row.size():
			continue
		var view: Control = face(game.row[index], CARD_SCALE)
		view.name = "Face"
		slot.add_child(view)
		slot.tooltip_text = "%s (cost %d)" % [game.row[index].display_name, game.row[index].energy_value()]
		if slide and animate:
			view.position.y = -60.0
			view.modulate.a = 0.0
			var drop: Tween = create_tween().set_parallel(true)
			drop.tween_property(view, "position:y", 0.0, 0.22).set_delay(0.04 * float(index)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			drop.tween_property(view, "modulate:a", 1.0, 0.15).set_delay(0.04 * float(index))


func _refresh() -> void:
	for index: int in range(_tickets.size()):
		var done: bool = index < game.ticket
		var active: bool = index == game.ticket and not game.is_over()
		var paper: StyleBoxFlat = UIStyle.box(PAPER if not done else Color("cfe8c4"), UIStyle.GOLD if active else Color(0.35, 0.3, 0.2), 4 if active else 2, 6, 6 if active else 0)
		_tickets[index].add_theme_stylebox_override("panel", paper)
		_tickets[index].modulate = Color(1, 1, 1, 1.0 if done or active else 0.55)
		if done:
			_ticket_labels[index].text = "Order %d\n%d  ✔" % [index + 1, game.served[index]]
		elif active:
			_ticket_labels[index].text = "Order %d\ncosts add up to\n%d" % [index + 1, game.target]
		else:
			_ticket_labels[index].text = "Order %d\n..." % (index + 1)
	for index: int in range(_slots.size()):
		var view: Control = _slots[index].get_node_or_null(^"Face") as Control
		if view == null:
			continue
		var on_plate: bool = game.picked.has(index)
		var wanted: float = PLATE_DROP if on_plate else 0.0
		if animate and absf(view.position.y - wanted) > 0.5 and view.modulate.a > 0.9:
			create_tween().tween_property(view, "position:y", wanted, 0.12)
		elif view.modulate.a > 0.9:
			view.position.y = wanted
		view.modulate = Color(1.0, 0.95, 0.72) if on_plate else Color.WHITE
		_slots[index].disabled = _busy or game.is_over() or state != "playing"
	var total: int = game.total()
	var costs: PackedStringArray = []
	for index: int in game.picked:
		costs.append(str(game.row[index].energy_value()))
	var sum_text: String = "%s = %d" % [" + ".join(costs), total] if costs.size() > 1 else str(total)
	_plate.text = "On the plate: %s   (ticket: %d)" % [sum_text, game.target] if not game.is_over() else "The pass is clear"
	_plate.add_theme_color_override("font_color", UIStyle.GOOD if total == game.target else (Color("ff9d98") if total > game.target else UIStyle.GOLD))
	_back_chip.text = "Sent back %d / %d" % [game.sent_back, OrderCardGame.SENT_BACK_LIMIT]
	_bell.disabled = _busy or game.is_over() or game.picked.is_empty() or state != "playing"
	_swap.disabled = _busy or game.is_over() or game.swaps_left <= 0 or state != "playing"
	PromptText.bind(_swap, "Swap the row  (R)   %d left" % game.swaps_left, &"text", "Swap the row   %d left" % game.swaps_left)


func _input(event: InputEvent) -> void:
	if state != "playing" or _busy or how_is_open():
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var code: int = int((event as InputEventKey).keycode)
		if code >= KEY_1 and code <= KEY_6:
			get_viewport().set_input_as_handled()
			pick(code - KEY_1)
		elif code == KEY_SPACE:
			get_viewport().set_input_as_handled()
			serve()
		elif code == KEY_R:
			get_viewport().set_input_as_handled()
			swap_row()
	elif event is InputEventJoypadButton and (event as InputEventJoypadButton).pressed:
		# X rings the bell and Y swaps the row, wherever the focus is (A picks the focused card).
		var button: int = (event as InputEventJoypadButton).button_index
		if button == JOY_BUTTON_X:
			get_viewport().set_input_as_handled()
			serve()
		elif button == JOY_BUTTON_Y:
			get_viewport().set_input_as_handled()
			swap_row()


## Puts card `index` of the pass on the plate, or takes it off.
func pick(index: int) -> void:
	if state != "playing" or _busy or game.is_over() or index >= game.row.size():
		return
	game.toggle(index)
	Audio.sfx(&"card_play_cheap" if game.picked.has(index) else &"card_return", -6.0, 0.08)
	_refresh()


func serve() -> void:
	if state != "playing" or _busy or game.is_over() or game.picked.is_empty():
		return
	_busy = true
	var total: int = game.total()
	var target: int = game.target
	var ticket_node: Control = _tickets[game.ticket]
	var right: bool = game.serve()
	if right:
		Audio.sfx(&"ding", 0.0, 0.0)
		set_status("Order up! %d on the plate." % total, UIStyle.GOOD)
		host_say(story_line("order.shouts", game.ticket))
		pop(ticket_node, 1.15)
		MinigameFx.sparkle(self, ticket_node.get_global_rect().get_center())
		_refresh()
		await pause(0.7)
		if not is_inside_tree():
			return
		if game.is_won():
			_busy = false
			_refresh()
			var first: bool = not Session.flag(ZoneDefs.get_def(zone()).flag_minigame_first)
			var lines: String = story_line("order.win")
			if first:
				lines = "%s\n%s" % [story_line("order.first"), lines]
			finish(true, game.stars(), "Shift complete!", lines)
			return
		_deal_row(true)
	else:
		Audio.sfx(&"ui_error", -6.0)
		set_status("%d is not %d: the plate comes back." % [total, target], Color("ff9d98"))
		shake_table()
		_refresh()
		await pause(0.6)
		if not is_inside_tree():
			return
		if game.is_lost():
			_busy = false
			_refresh()
			finish(false, 0, "Kitchen closed", story_line("order.lose"))
			return
	_busy = false
	_refresh()


func swap_row() -> void:
	if state != "playing" or _busy or not game.swap_row():
		return
	Audio.sfx(&"card_shuffle", -6.0)
	set_status("A fresh row. The ticket is still %d." % game.target)
	_deal_row(true)
	_refresh()


func _build_example(box: Control) -> void:
	# A ticket for 5; a 2 and a 3 drop onto the plate one after the other; the bell rings. Then it starts again.
	var by_cost: Dictionary = {}
	for card: CardData in CardGamePool.cards(Session.content, zone()):
		if not by_cost.has(card.energy_value()):
			by_cost[card.energy_value()] = card
	var costs: Array[int] = [2, 3, 4]
	for cost: int in costs:
		if not by_cost.has(cost):
			return
	var ticket: Label = UIKit.label("Order\n5", &"", 26, UIStyle.INK, HORIZONTAL_ALIGNMENT_CENTER)
	ticket.add_theme_font_override("font", UIStyle.font_bold())
	ticket.add_theme_stylebox_override("normal", UIStyle.box(PAPER, UIStyle.GOLD, 3, 6))
	ticket.position = Vector2(20, 60)
	ticket.size = Vector2(110, 96)
	ticket.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(ticket)
	var card_scale: float = 0.38
	var views: Array[Control] = []
	for index: int in range(costs.size()):
		var view: Control = face(by_cost[costs[index]] as CardData, card_scale)
		view.position = Vector2(170.0 + float(index) * 130.0, 6.0)
		box.add_child(view)
		views.append(view)
	var plate: Label = UIKit.label("", &"", 26, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	plate.position = Vector2(540, 80)
	plate.size = Vector2(160, 70)
	box.add_child(plate)
	var loop: Tween = box.create_tween().set_loops()
	loop.tween_callback(func() -> void:
		plate.text = "Plate: 0"
		plate.add_theme_color_override("font_color", UIStyle.GOLD))
	loop.tween_interval(0.7)
	loop.tween_property(views[0], "position:y", 40.0, 0.15)
	loop.tween_callback(func() -> void: plate.text = "Plate: 2")
	loop.tween_interval(0.6)
	loop.tween_property(views[1], "position:y", 40.0, 0.15)
	loop.tween_callback(func() -> void:
		plate.text = "Plate: 5\nOrder up!"
		plate.add_theme_color_override("font_color", UIStyle.GOOD))
	loop.tween_interval(1.5)
	loop.tween_property(views[0], "position:y", 6.0, 0.12)
	loop.parallel().tween_property(views[1], "position:y", 6.0, 0.12)


## Shots and tests: serves `count` tickets right (after a `wrong` number of wrong plates), then puts one card on the plate.
func autoplay(count: int, wrong: int = 0) -> void:
	for _plate_index: int in range(wrong):
		if game.is_over():
			break
		for index: int in range(game.row.size()):
			pick(index)
		await serve()
	for _ticket: int in range(count):
		if game.is_over():
			break
		for index: int in game.solution():
			pick(index)
		await serve()
	if not game.is_over() and not game.solution().is_empty():
		pick(game.solution()[0])


func _shot_mid() -> void:
	await autoplay(1)


func _shot_end(won: bool) -> void:
	if won:
		await autoplay(3)
	else:
		await autoplay(0, 3)
