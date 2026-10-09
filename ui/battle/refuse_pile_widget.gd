class_name RefusePileWidget
extends Control
## One player's Refuse Pile on the battleboard: a small stack showing the top card, a count badge and a label. Clicking it
## asks the battle screen to open the viewer (`pressed`).

signal pressed(player_index: int)

const WIDGET_SIZE: Vector2 = Vector2(120, 188)
const CARD_SCALE: float = 0.34

var player_index: int = 0
var _count: int = 0
var _top: CardView
var _badge: Label
var _caption: Label
var _hint: Label
var _highlight: bool = false
var _stack: Control
var _has_base: bool = false


func setup(index: int) -> void:
	player_index = index
	custom_minimum_size = WIDGET_SIZE
	size = WIDGET_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	name = "RefusePile%d" % index
	tooltip_text = "%s Refuse Pile\nCards that were refused (spent spells, destroyed units). Click to look through it." % ("Your" if index == 0 else "Opponent's")
	_caption = UIKit.label("REFUSE", &"", 18, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_caption.add_theme_font_override("font", UIStyle.font_bold())
	_caption.position = Vector2(0, 0)
	_caption.size = Vector2(WIDGET_SIZE.x, 24)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caption)
	if UiArt.has("UI-HUD-REFUSE"):
		# The Refuse Pile base (UI-HUD-REFUSE): a tray under the stack; the whole widget stays clickable.
		var base: TextureRect = TextureRect.new()
		base.texture = UiArt.texture("UI-HUD-REFUSE")
		base.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		base.stretch_mode = TextureRect.STRETCH_SCALE
		base.size = Vector2(WIDGET_SIZE.x, WIDGET_SIZE.x * 0.6)
		base.position = Vector2(0, WIDGET_SIZE.y - base.size.y - 4.0)
		base.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(base)
		_has_base = true
	_stack = Control.new()
	_stack.position = Vector2(8, 26)
	_stack.size = Vector2(CardView.SIZE.x * CARD_SCALE, CardView.SIZE.y * CARD_SCALE)
	_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stack)
	_badge = UIKit.label("0", &"", 26, UIStyle.INK, HORIZONTAL_ALIGNMENT_CENTER)
	_badge.add_theme_font_override("font", UIStyle.font_bold())
	_badge.add_theme_stylebox_override("normal", UIStyle.box(UIStyle.GOLD, UIStyle.INK, 2, 14))
	_badge.size = Vector2(52, 34)
	_badge.position = Vector2(WIDGET_SIZE.x - 58, WIDGET_SIZE.y - 40)
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_badge)
	_hint = UIKit.label("", &"", 15, Color("ff8a7a"), HORIZONTAL_ALIGNMENT_CENTER)
	_hint.position = Vector2(0, WIDGET_SIZE.y - 2)
	_hint.size = Vector2(WIDGET_SIZE.x, 20)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hint)
	gui_input.connect(_on_gui_input)
	_rebuild_stack(null)


func center() -> Vector2:
	return global_position + Vector2(8, 26) + _stack.size * 0.5


## Shows `pile`: the top card face up on top of a few card backs; an empty pile is an outlined slot.
func show_pile(pile: Array[CardInstance]) -> void:
	_count = pile.size()
	_badge.text = str(_count)
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
	_top = null
	var card_size: Vector2 = CardView.SIZE * CARD_SCALE
	if top == null:
		if not _has_base:
			var slot: Panel = Panel.new()
			slot.size = card_size
			slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_theme_stylebox_override("panel", UIStyle.box(Color(0, 0, 0, 0.35), Color(UIStyle.GOLD, 0.45), 2, 10))
			_stack.add_child(slot)
		var empty: Label = UIKit.label("empty", &"", 17, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		empty.size = card_size
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stack.add_child(empty)
		return
	var layers: int = mini(_count, 3) - 1
	for layer: int in range(layers, 0, -1):
		var back: Control = CardView.wrapped(top.data, CARD_SCALE, CardView.Mode.BACK)
		back.position = Vector2(float(layer) * 3.0, -float(layer) * 3.0)
		back.modulate = Color(0.75, 0.7, 0.8)
		_stack.add_child(back)
	var face: Control = CardView.wrapped(top.data, CARD_SCALE, CardView.Mode.FULL)
	_stack.add_child(face)


func _draw() -> void:
	if _highlight:
		draw_rect(Rect2(Vector2(2, 22), WIDGET_SIZE - Vector2(4, 26)), Color("ff5a5a"), false, 4.0)
		draw_rect(Rect2(Vector2(-2, 18), WIDGET_SIZE - Vector2(-4, 18)), Color(1.0, 0.35, 0.35, 0.35), false, 3.0)


func _on_gui_input(event: InputEvent) -> void:
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
		pressed.emit(player_index)
		accept_event()
