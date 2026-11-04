class_name PeekPanel
extends CenterContainer
## Fix pass Nov 4 (Part 1.1): the player's own Peek. Shows the top cards of the deck (top card first); for each one the player
## picks Top or Bottom. Cards sent to the top go back in the order they were picked (the first one is drawn next).
## Emits `chosen(top_uids, bottom_uids)` on Done; the battle screen turns it into a GameAction.PEEK.

signal chosen(top_uids: Array[int], bottom_uids: Array[int])

const CARD_SCALE: float = 0.58

## How far above the screen centre the panel sits (pixels in the 1920x1080 canvas).
var lift: float = 0.0

var cards: Array[CardInstance] = []
## uid -> "top" / "bottom" in pick order.
var top_order: Array[int] = []
var bottom_order: Array[int] = []

var _status: Dictionary = {}  # uid -> Label
var _done: FancyButton


static func make(shown: Array[CardInstance]) -> PeekPanel:
	var panel: PeekPanel = PeekPanel.new()
	panel.cards = shown.duplicate()
	return panel


func _ready() -> void:
	UIKit.full_rect(self)
	position.y -= lift
	mouse_filter = Control.MOUSE_FILTER_STOP
	var frame: PanelContainer = UIKit.panel()
	add_child(frame)
	var column: VBoxContainer = UIKit.vbox(12)
	frame.add_child(column)
	column.add_child(UIKit.label("Peek %d" % cards.size(), &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER))
	var how: String = "Keep it on top, or send it to the bottom of your deck." if cards.size() == 1 \
		else "The top %d cards of your deck, top card first. Choose Top or Bottom for each.\nCards you keep on top go back in the order you pick them: the first is drawn next." % cards.size()
	column.add_child(UIKit.label(how, &"", 21, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER))
	var row: HBoxContainer = UIKit.hbox(18)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	for card: CardInstance in cards:
		row.add_child(_card_column(card))
	var buttons: HBoxContainer = UIKit.hbox(14)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)
	var reset: FancyButton = FancyButton.make("Reset", &"", Vector2(160, 52))
	reset.pressed.connect(_reset)
	buttons.add_child(reset)
	_done = FancyButton.make("Done", &"PrimaryButton", Vector2(200, 52))
	_done.pressed.connect(_finish)
	buttons.add_child(_done)
	_refresh()
	UIKit.pop_in(frame)
	PadFocus.register(self)


func _card_column(card: CardInstance) -> Control:
	var column: VBoxContainer = UIKit.vbox(8)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(CardView.wrapped(card.data, CARD_SCALE))
	var status: Label = UIKit.label("", &"", 22, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_status[card.uid] = status
	column.add_child(status)
	var buttons: HBoxContainer = UIKit.hbox(8)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)
	var top: FancyButton = FancyButton.make("Top", &"", Vector2(96, 46))
	top.pressed.connect(func() -> void: pick(card.uid, true))
	buttons.add_child(top)
	var bottom: FancyButton = FancyButton.make("Bottom", &"", Vector2(110, 46))
	bottom.pressed.connect(func() -> void: pick(card.uid, false))
	buttons.add_child(bottom)
	return column


## Puts a card on top (next free top position) or on the bottom; picking again moves it.
func pick(uid: int, on_top: bool) -> void:
	top_order.erase(uid)
	bottom_order.erase(uid)
	if on_top:
		top_order.append(uid)
	else:
		bottom_order.append(uid)
	Audio.sfx(&"ui_select")
	_refresh()


func is_complete() -> bool:
	return top_order.size() + bottom_order.size() == cards.size()


func _reset() -> void:
	top_order.clear()
	bottom_order.clear()
	_refresh()


func _refresh() -> void:
	for card: CardInstance in cards:
		var label: Label = _status[card.uid]
		if top_order.has(card.uid):
			label.text = "Top #%d" % (top_order.find(card.uid) + 1) if cards.size() > 1 else "Top"
		elif bottom_order.has(card.uid):
			label.text = "Bottom"
		else:
			label.text = "Choose"
	if _done != null:
		_done.disabled = not is_complete()


func _finish() -> void:
	if not is_complete():
		return
	chosen.emit(top_order.duplicate(), bottom_order.duplicate())
