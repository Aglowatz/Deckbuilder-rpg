class_name HandRevealPanel
extends Control
## Fable Nov 24 (Part 5): the opponent's hand as a card like Signal Reader shows it - the ACTUAL cards, enlarged, in the middle
## of the screen (it was a list of names on a banner). A click anywhere, the Close button, Enter / Space / E / Escape or the
## controller's confirm / back closes it. With many cards they are drawn smaller so the whole hand fits in two rows at most.
## Emits `closed` once; the battle screen frees it. Nothing here changes the game.

signal closed

const CARD_SCALE: float = 0.9
const CARD_SCALE_MIN: float = 0.5
const GAP: int = 16
## The share of the screen's width the row of cards may use.
const ROW_SHARE: float = 0.92
const GUARD_TIME: float = 0.35

var cards: Array[CardData] = []
var owner_name: String = "Your opponent"
var _age: float = 0.0
var _done: bool = false
var _button: FancyButton


static func make(shown: Array[CardData], whose: String = "") -> HandRevealPanel:
	var panel: HandRevealPanel = HandRevealPanel.new()
	panel.cards = shown.duplicate()
	if not whose.is_empty():
		panel.owner_name = whose
	return panel


## The scale at which `count` cards fit `width` px in one row (or in two rows of half the cards when one row would be tiny).
static func scale_for(count: int, width: float) -> float:
	if count <= 0:
		return CARD_SCALE
	var per_row: int = count if count <= 6 else int(ceil(float(count) / 2.0))
	var room: float = width * ROW_SHARE - float(GAP * maxi(0, per_row - 1))
	return clampf(room / float(per_row) / CardView.SIZE.x, CARD_SCALE_MIN, CARD_SCALE)


func _ready() -> void:
	name = "HandRevealPanel"
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	var center: CenterContainer = CenterContainer.new()
	UIKit.full_rect(center)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var column: VBoxContainer = UIKit.vbox(14)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(column)
	var title: Label = UIKit.label(title_text(), &"HeadingLabel", 40, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "Title"
	column.add_child(title)
	if cards.is_empty():
		var none: Label = UIKit.label("Not a single card. Nothing to read.", &"", 28, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		none.name = "Empty"
		column.add_child(none)
	else:
		var width: float = get_viewport_rect().size.x if is_inside_tree() and get_viewport_rect().size.x > 200.0 else 1920.0
		var card_scale: float = scale_for(cards.size(), width)
		var per_row: int = cards.size() if cards.size() <= 6 else int(ceil(float(cards.size()) / 2.0))
		var rows: VBoxContainer = UIKit.vbox(GAP)
		rows.name = "Cards"
		rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(rows)
		var row: HBoxContainer = null
		for index: int in range(cards.size()):
			if index % per_row == 0:
				row = UIKit.hbox(GAP)
				row.alignment = BoxContainer.ALIGNMENT_CENTER
				row.mouse_filter = Control.MOUSE_FILTER_IGNORE
				rows.add_child(row)
			var holder: Control = Control.new()
			holder.name = "Card%d" % index
			holder.custom_minimum_size = CardView.SIZE * card_scale
			holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
			holder.set_meta(&"card_id", cards[index].id)
			var view: Control = CardView.wrapped(cards[index], card_scale)
			view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			holder.add_child(view)
			row.add_child(holder)
	var hint: Label = UIKit.label("Their hand, as it is right now. They still hold these cards.", &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	hint.name = "Hint"
	column.add_child(hint)
	_button = FancyButton.make("Close", &"PrimaryButton", Vector2(260, 60))
	_button.name = "Close"
	_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_button.pressed.connect(close)
	column.add_child(_button)
	var how: Label = UIKit.label("Click anywhere, or press Enter / Space / E", &"MutedLabel", 18, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	how.name = "How"
	column.add_child(how)
	UIKit.pop_in(column)
	PadFocus.register(self)


func title_text() -> String:
	if cards.is_empty():
		return "%s's hand is empty" % owner_name
	return "%s's hand (%d card%s)" % [owner_name, cards.size(), "" if cards.size() == 1 else "s"]


func _process(delta: float) -> void:
	_age += delta


func close() -> void:
	if _done:
		return
	_done = true
	closed.emit()


func _gui_input(event: InputEvent) -> void:
	# a click anywhere closes it (after a moment, so the click that played the card does not)
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and _age >= GUARD_TIME:
		accept_event()
		close()


func _unhandled_input(event: InputEvent) -> void:
	if _done or _age < GUARD_TIME:
		return
	if UiInput.is_confirm(event) or UiInput.is_back(event):
		get_viewport().set_input_as_handled()
		close()
