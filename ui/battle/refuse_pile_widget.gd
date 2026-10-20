class_name RefusePileWidget
extends Control
## One player's Refuse Pile on the battleboard, right beside that player's deck (Oct 19 rework): a neat face-up pile the size of the deck's card backs showing
## the top card, a slightly offset stack under it, a count badge on the pile and a small caption; an empty pile is an empty card outline. Clicking it asks the
## battle screen to open the viewer (`pressed`); cards that go to the pile fly onto `center()`.

signal pressed(player_index: int)

## The same footprint as `DeckPile.PILE_SIZE` so the two stand as a pair.
const WIDGET_SIZE: Vector2 = Vector2(150, 136)
## The deck's card backs are 54 x 81: the pile's cards match them.
const CARD_SCALE: float = 0.18
const STACK_TOP: Vector2 = Vector2(48, 22)

var player_index: int = 0
var _count: int = 0
var _badge: Label
var _caption: Label
var _hint: Label
var _highlight: bool = false
var _stack: Control


func setup(index: int) -> void:
	player_index = index
	custom_minimum_size = WIDGET_SIZE
	size = WIDGET_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	name = "RefusePile%d" % index
	tooltip_text = "%s Refuse Pile\nCards that were refused (spent spells, destroyed units) lie here face up, beside the deck. Click to look through it." % ("Your" if index == 0 else "Opponent's")
	_caption = UIKit.label("REFUSE", &"", 14, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_caption.add_theme_font_override("font", UIStyle.font_bold())
	_caption.add_theme_color_override("font_outline_color", Color("1b1020"))
	_caption.add_theme_constant_override("outline_size", 5)
	_caption.position = Vector2(0, 2)
	_caption.size = Vector2(WIDGET_SIZE.x, 18)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caption)
	_stack = Control.new()
	_stack.position = STACK_TOP
	_stack.size = CardView.SIZE * CARD_SCALE
	_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stack)
	_badge = UIKit.label("0", &"", 17, Color("fff3d6"), HORIZONTAL_ALIGNMENT_CENTER)
	_badge.add_theme_font_override("font", UIStyle.font_bold())
	_badge.add_theme_color_override("font_outline_color", Color("1b1020"))
	_badge.add_theme_constant_override("outline_size", 5)
	_badge.add_theme_stylebox_override("normal", UIStyle.box(Color(0.12, 0.07, 0.16, 0.92), UIStyle.GOLD, 2, 10))
	_badge.size = Vector2(36, 24)
	_badge.position = STACK_TOP + _stack.size - Vector2(22, 12)
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_badge)
	_hint = UIKit.label("", &"", 14, Color("ff8a7a"), HORIZONTAL_ALIGNMENT_CENTER)
	_hint.position = Vector2(0, WIDGET_SIZE.y - 18)
	_hint.size = Vector2(WIDGET_SIZE.x, 18)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hint)
	gui_input.connect(_on_gui_input)
	_rebuild_stack(null)


## Where cards fly to when they go to this pile (global).
func center() -> Vector2:
	return global_position + STACK_TOP + _stack.size * 0.5


## Shows `pile`: the top card face up on a slightly offset stack; an empty pile is an empty card outline.
func show_pile(pile: Array[CardInstance]) -> void:
	_count = pile.size()
	_badge.text = str(_count)
	_badge.visible = _count > 0
	var top: CardInstance = pile.back() if not pile.is_empty() else null
	_rebuild_stack(top)


## True while an effect wants a card from this pile: the widget glows red and says so.
func set_targetable(on: bool) -> void:
	_highlight = on
	_hint.text = "choose a card" if on else ""
	queue_redraw()


func _rebuild_stack(top: CardInstance) -> void:
	for child: Node in _stack.get_children():
		_stack.remove_child(child)
		child.queue_free()
	var card_size: Vector2 = CardView.SIZE * CARD_SCALE
	if top == null:
		var outline: Panel = Panel.new()
		outline.size = card_size
		outline.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outline.add_theme_stylebox_override("panel", UIStyle.box(Color(0, 0, 0, 0.28), Color(UIStyle.GOLD, 0.55), 2, 6))
		_stack.add_child(outline)
		return
	# the stack under the top card: up to three offset layers, each a face-down sliver
	var layers: int = mini(_count - 1, 3)
	for layer: int in range(layers, 0, -1):
		var under: Panel = Panel.new()
		under.size = card_size
		under.position = Vector2(float(layer) * 2.5, -float(layer) * 2.5)
		under.mouse_filter = Control.MOUSE_FILTER_IGNORE
		under.add_theme_stylebox_override("panel", UIStyle.box(Color(0.82, 0.78, 0.7).darkened(0.1 * float(layer)), Color(0.25, 0.18, 0.12), 1, 5))
		_stack.add_child(under)
	var face: Control = CardView.wrapped(top.data, CARD_SCALE, CardView.Mode.FULL)
	_stack.add_child(face)


func _draw() -> void:
	if _highlight:
		draw_rect(Rect2(STACK_TOP - Vector2(6, 6), _stack.size + Vector2(12, 12)), Color("ff5a5a"), false, 3.0)
		draw_rect(Rect2(STACK_TOP - Vector2(10, 10), _stack.size + Vector2(20, 20)), Color(1.0, 0.35, 0.35, 0.35), false, 3.0)


func _on_gui_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(player_index)
		accept_event()
