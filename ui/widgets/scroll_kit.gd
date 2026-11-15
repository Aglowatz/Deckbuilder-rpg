class_name ScrollKit
extends RefCounted
## Fable Nov 15 (Part 4b): a scrolling row or list that shows it scrolls. The theme's own bars are visible everywhere since this pass
## (`UIStyle.theme`: a gold grabber on a framed dark track); this adds what a shop's row of tiles needs on top:
##   - a thicker bar in the shop's gold, drawn whenever the content overflows;
##   - the mouse wheel moves a sideways row (wheel up/down = left/right), wherever the pointer is over the row;
##   - dragging the bar works as usual, and the row follows the focus, so a controller's left/right (PadFocus moves the focus from tile
##     to tile) brings the next tile into view.
## `ScrollKit.row(scroll)` for a sideways row, `ScrollKit.list(scroll)` for an up-and-down list.

const BAR_THICKNESS: float = 18.0
## How far one wheel notch moves a sideways row (pixels of the 1080p canvas).
const WHEEL_STEP: float = 140.0


static func _style(bar: ScrollBar, vertical: bool) -> void:
	bar.custom_minimum_size = Vector2(BAR_THICKNESS, 0) if vertical else Vector2(0, BAR_THICKNESS)
	bar.add_theme_stylebox_override("scroll", UIStyle.box(Color(0.0, 0.0, 0.0, 0.5), UIStyle.GOLD_DIM, 1, 9))
	bar.add_theme_stylebox_override("scroll_focus", UIStyle.box(Color(0.0, 0.0, 0.0, 0.5), UIStyle.GOLD, 1, 9))
	bar.add_theme_stylebox_override("grabber", UIStyle.box(UIStyle.GOLD_DIM.lightened(0.12), Color(0, 0, 0, 0), 0, 9))
	bar.add_theme_stylebox_override("grabber_highlight", UIStyle.box(UIStyle.GOLD, Color(0, 0, 0, 0), 0, 9))
	bar.add_theme_stylebox_override("grabber_pressed", UIStyle.box(UIStyle.GOLD.lightened(0.15), Color(0, 0, 0, 0), 0, 9))


## A sideways row: the gold bar under it when it overflows, the wheel, the focus followed. Returns the scroll.
static func row(scroll: ScrollContainer) -> ScrollContainer:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	# (never DISABLED: a scroll with its vertical mode disabled grows to its content's height, which pushed the bar out of a fixed
	# panel - the Card Packs shelf - where it was never seen)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.follow_focus = true
	_style(scroll.get_h_scroll_bar(), false)
	scroll.set_meta(&"scroll_kit", &"row")
	if not scroll.gui_input.is_connected(_on_row_input.bind(scroll)):
		scroll.gui_input.connect(_on_row_input.bind(scroll))
	return scroll


## An up-and-down list: the gold bar beside it when it overflows, the focus followed. Returns the scroll.
static func list(scroll: ScrollContainer) -> ScrollContainer:
	scroll.follow_focus = true
	_style(scroll.get_v_scroll_bar(), true)
	scroll.set_meta(&"scroll_kit", &"list")
	return scroll


## Wheel up / down (and a sideways wheel or touchpad) moves the row; the event is used up so nothing behind the shop scrolls.
static func _on_row_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if not (event is InputEventMouseButton) or not (event as InputEventMouseButton).pressed:
		return
	var step: float = 0.0
	match (event as InputEventMouseButton).button_index:
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_LEFT:
			step = -WHEEL_STEP
		MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_RIGHT:
			step = WHEEL_STEP
	if step == 0.0:
		return
	scroll.accept_event()  # a row never scrolls up and down, and nothing behind it should
	if not overflows(scroll):
		return
	scroll.scroll_horizontal = int(clampf(float(scroll.scroll_horizontal) + step, 0.0, scroll.get_h_scroll_bar().max_value))


## True when the row's content is wider than the scroll (so the bar shows and there is more to the side).
static func overflows(scroll: ScrollContainer) -> bool:
	var bar: HScrollBar = scroll.get_h_scroll_bar()
	return bar.max_value > bar.page + 0.5
