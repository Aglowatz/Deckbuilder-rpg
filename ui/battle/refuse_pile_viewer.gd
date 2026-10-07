class_name RefusePileViewer
extends Control
## The Refuse Pile browser. Two jobs: (1) look through one or both piles (scrollable, hover a card to zoom it, close with a click
## outside, the Close button or Esc); (2) targeting mode - an effect wants cards from a pile, only the legal ones glow, a click
## chooses (`card_chosen`), "up to X" effects get a Done button, and cancelling is offered when the effect allows it.

signal card_chosen(uid: int)
signal done_pressed
signal cancel_pressed
signal closed

const COLUMNS: int = 6
const CARD_SCALE: float = 0.46

var game: GameState
var targeting: bool = false

var _piles: Array[int] = []
var _options: Array[int] = []
var _picked: Array[int] = []
var _max_count: int = 1
var _multi: bool = false
var _cancellable: bool = true
var _prompt_text: String = ""
var _panel: PanelContainer
var _sections: VBoxContainer
var _zoom_holder: Control
var _footer: HBoxContainer
var _title: Label
var _prompt: Label
var _views: Dictionary = {}


func setup(game_state: GameState) -> void:
	game = game_state
	name = "RefusePileViewer"
	UIKit.full_rect(self)
	z_index = 300
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.05, 0.78)
	UIKit.full_rect(shade)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.gui_input.connect(_on_shade_input)
	add_child(shade)
	_panel = UIKit.panel(&"DarkPanel")
	_panel.position = Vector2(150, 70)
	_panel.custom_minimum_size = Vector2(1620, 940)
	_panel.size = Vector2(1620, 940)
	add_child(_panel)
	var column: VBoxContainer = UIKit.vbox(10)
	_panel.add_child(column)
	_title = UIKit.label("Refuse Pile", &"HeadingLabel", 38, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_title)
	_prompt = UIKit.label("", &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	column.add_child(_prompt)
	var body: HBoxContainer = UIKit.hbox(16)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	_sections = UIKit.vbox(14)
	_sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_sections)
	_zoom_holder = Control.new()
	_zoom_holder.custom_minimum_size = Vector2(330, 470)
	_zoom_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(_zoom_holder)
	_footer = UIKit.hbox(16)
	_footer.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(_footer)


## Browse mode: look through the given piles (player indexes), nothing can be chosen.
func open_browse(piles: Array[int]) -> void:
	targeting = false
	_piles = piles
	_options = [] as Array[int]
	_picked = [] as Array[int]
	_multi = false
	_prompt_text = "Hover a card to read it. Click anywhere outside, press Esc or Close to go back."
	_rebuild()
	visible = true
	Audio.sfx(&"ui_open", -6.0)


## Targeting mode: `options` are the legal card uids, `picked` the ones already chosen ("up to X" effects keep the viewer open
## and show Done), `prompt` the instruction.
func open_targeting(options: Array[int], picked: Array[int], max_count: int, prompt: String, cancellable: bool = true) -> void:
	targeting = true
	_options = options
	_picked = picked
	_max_count = max_count
	_multi = max_count > 1
	_cancellable = cancellable
	_prompt_text = prompt
	_piles = [] as Array[int]
	for index: int in range(game.players.size()):
		for card: CardInstance in game.players[index].refuse_pile:
			if options.has(card.uid):
				_piles.append(index)
				break
	_rebuild()
	visible = true
	Audio.sfx(&"ui_open", -6.0)


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


## The card uids currently drawn (tests, screenshots).
func shown_uids() -> Array[int]:
	var result: Array[int] = []
	for uid: Variant in _views.keys():
		result.append(int(uid))
	return result


func glow_of(uid: int) -> CardView.Glow:
	var view: CardView = _views.get(uid) as CardView
	if view == null:
		return CardView.Glow.NONE
	return view.get_meta("glow", CardView.Glow.NONE) as CardView.Glow


func _rebuild() -> void:
	for child: Node in _sections.get_children():
		_sections.remove_child(child)
		child.queue_free()
	_views.clear()
	_clear_zoom()
	if targeting:
		_title.text = "Choose from the Refuse Pile" if _piles.size() < 2 else "Choose from either Refuse Pile"
	elif _piles.size() == 1:
		_title.text = "Your Refuse Pile" if _piles[0] == 0 else "Opponent's Refuse Pile"
	else:
		_title.text = "Refuse Piles"
	_prompt.text = _prompt_text.replace("[b]", "").replace("[/b]", "").replace("\n", "  ")
	for index: int in _piles:
		_add_section(index)
	_rebuild_footer()


func _add_section(player_index: int) -> void:
	var pile: Array[CardInstance] = game.players[player_index].refuse_pile
	var heading: String = "Your Refuse Pile" if player_index == 0 else "Opponent's Refuse Pile"
	var header: Label = UIKit.label("%s  (%d)" % [heading, pile.size()], &"", 28, UIStyle.GOLD)
	header.add_theme_font_override("font", UIStyle.font_bold())
	_sections.add_child(header)
	if pile.is_empty():
		_sections.add_child(UIKit.label("No cards yet.", &"", 22, UIStyle.MUTED))
		return
	var grid: GridContainer = GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	_sections.add_child(grid)
	# Newest on top of the pile = first shown.
	for i: int in range(pile.size() - 1, -1, -1):
		var card: CardInstance = pile[i]
		var holder: Control = Control.new()
		holder.custom_minimum_size = CardView.SIZE * CARD_SCALE
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		grid.add_child(holder)
		var view: CardView = CardView.create(card.data, CardView.Mode.FULL)
		view.instance_uid = card.uid
		holder.add_child(view)
		CardView.fit(view, CARD_SCALE)
		view.hovered.connect(_on_card_hovered)
		view.unhovered.connect(_on_card_unhovered)
		view.gui_event.connect(_on_card_input)
		_views[card.uid] = view
		var glow: CardView.Glow = CardView.Glow.NONE
		if targeting:
			if _picked.has(card.uid):
				glow = CardView.Glow.SELECTED
			elif _options.has(card.uid):
				glow = CardView.Glow.TARGET
			else:
				view.modulate = Color(0.45, 0.45, 0.5)
		view.set_meta("glow", glow)
		view.set_glow(glow)


func _rebuild_footer() -> void:
	for child: Node in _footer.get_children():
		_footer.remove_child(child)
		child.queue_free()
	if targeting:
		if _multi:
			var done: FancyButton = FancyButton.make("Done (%d/%d)" % [_picked.size(), _max_count], &"PrimaryButton", Vector2(260, 56))
			done.pressed.connect(func() -> void: done_pressed.emit())
			_footer.add_child(done)
		if _cancellable:
			var cancel: FancyButton = FancyButton.make("Cancel", &"DangerButton", Vector2(220, 56))
			cancel.pressed.connect(func() -> void: cancel_pressed.emit())
			_footer.add_child(cancel)
		var hide: FancyButton = FancyButton.make("Show board", &"GhostButton", Vector2(220, 56))
		hide.pressed.connect(close)
		_footer.add_child(hide)
	else:
		var button: FancyButton = FancyButton.make("Close", &"PrimaryButton", Vector2(220, 56))
		button.pressed.connect(close)
		_footer.add_child(button)


# ---- Input ----------------------------------------------------------------------------------


func _on_card_hovered(view: CardView) -> void:
	_clear_zoom()
	if view.data == null:
		return
	var zoom: CardView = CardView.create(view.data, CardView.Mode.FULL)
	zoom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zoom.position = Vector2(15, 10)
	_zoom_holder.add_child(zoom)
	zoom.set_deferred(&"mouse_filter", Control.MOUSE_FILTER_IGNORE)
	zoom.set_meta("zoom", true)
	var card: CardInstance = game.find_card(view.instance_uid)
	if card != null:
		zoom.apply_instance(card, game)


func _on_card_unhovered(_view: CardView) -> void:
	pass


func _clear_zoom() -> void:
	for child: Node in _zoom_holder.get_children():
		_zoom_holder.remove_child(child)
		child.queue_free()


func _on_card_input(view: CardView, event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button == null or not button.pressed:
		return
	if button.button_index == MOUSE_BUTTON_RIGHT:
		if targeting and _cancellable:
			cancel_pressed.emit()
		return
	if button.button_index != MOUSE_BUTTON_LEFT or not targeting:
		return
	if _options.has(view.instance_uid):
		Audio.sfx(&"ui_click", -4.0)
		card_chosen.emit(view.instance_uid)
	else:
		Audio.sfx(&"ui_error", -8.0)


func choose(uid: int) -> void:
	if targeting and _options.has(uid):
		card_chosen.emit(uid)


func _on_shade_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
		close()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and key.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
