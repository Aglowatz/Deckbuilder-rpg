class_name PadFocus
extends Node
## Controller support (Oct 26, docs/design/controller.md): the menu side of a controller, for every screen at once.
## - Screens register their root (`PadFocus.register`); the topmost visible one (highest canvas layer, then latest in the tree) is the "open screen".
## - A screen registered while the pad is in use gets its first button focused at once. A D-pad / left-stick press with no focused control in the
##   open screen focuses its first button instead of moving, so a controller can never be stuck on a screen whose focus was lost (a rebuilt list, a
##   closed sub-page). A (confirm) never wakes focus: "press to continue" screens read it themselves.
## - While the controller is in use: a gold ring is drawn around the focused control (on top of everything, even controls whose theme has no focus
##   box), its tooltip shows under it (a pad cannot hover), the focus scrolls into view, the focused control gets the hover signals the mouse would
##   give it (card previews follow the focus), and the mouse cursor hides.
## The keyboard and mouse see none of this: the ring, tooltips and hover signals are pad-only, and nothing changes while the mouse is in use.

const GROUP: StringName = &"pad_focus_root"
const RING_COLOR: Color = Color("ffd76a")
const RING_WIDTH: float = 4.0
const RING_PAD: float = 5.0
## Seconds the focus rests on a control before its tooltip shows.
const TIP_DELAY: float = 0.35
## Pixels per second the right stick scrolls a list at full tilt.
const SCROLL_SPEED: float = 1400.0

static var instance: PadFocus

var _layer: CanvasLayer
var _ring: Control
var _tip: PanelContainer
var _tip_label: Label
var _focus: Control
var _hovered: Control
var _last_focus: Control
var _rest: float = 0.0


## Marks `root` as a screen that takes controller focus while it is visible (overlays, popups, dialogs, the pause menu).
static func register(root: Control) -> void:
	if root == null:
		return
	if not root.is_in_group(GROUP):
		root.add_to_group(GROUP)
	focus_soon(root)


## Next frame, while the pad is in use: focuses `root`'s first button unless the focus is already inside it (a screen that rebuilt its buttons).
static func focus_soon(root: Control) -> void:
	if InputDevice.using_pad() and instance != null and root != null:
		instance._focus_later(root)


func _focus_later(root: Control) -> void:
	await get_tree().process_frame
	if is_instance_valid(root):
		_focus_if_lost(root)


## Focuses the first button of `root` unless the focus is already inside it.
static func _focus_if_lost(root: Control) -> void:
	if not is_instance_valid(root) or not root.is_inside_tree() or not root.is_visible_in_tree():
		return
	var owner_now: Control = root.get_viewport().gui_get_focus_owner()
	if owner_now != null and owner_now.is_visible_in_tree() and root.is_ancestor_of(owner_now):
		return
	focus_into(root)


## The topmost visible registered screen, or null when the world (or a battle) has the pad.
static func top_root(tree: SceneTree) -> Control:
	var best: Control = null
	var best_layer: int = -1000000
	for node: Node in tree.get_nodes_in_group(GROUP):
		var root: Control = node as Control
		if root == null or not root.is_visible_in_tree() or root.is_queued_for_deletion():
			continue
		var layer: int = _layer_of(root)
		if best == null or layer > best_layer or (layer == best_layer and root.is_greater_than(best)):
			best = root
			best_layer = layer
	return best


static func _layer_of(node: Node) -> int:
	var parent: Node = node
	while parent != null:
		if parent is CanvasLayer:
			return (parent as CanvasLayer).layer
		parent = parent.get_parent()
	return 0


## True when `event` is a controller press that moves menu focus (what wakes up focus on an open screen).
static func is_pad_nav(event: InputEvent) -> bool:
	if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		return false
	for action: StringName in [&"ui_up", &"ui_down", &"ui_left", &"ui_right"]:
		if event.is_action_pressed(action, false, true):
			return true
	return false


## Focuses the first button of `root` (making its buttons focusable first). Returns the focused control or null.
static func focus_into(root: Control) -> Control:
	if root == null:
		return null
	UiInput.make_focusable(root)
	return UiInput.focus_first(root)


func _ready() -> void:
	name = "PadFocus"
	instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	_layer = CanvasLayer.new()
	_layer.name = "PadFocusLayer"
	_layer.layer = 127
	add_child(_layer)
	_ring = Control.new()
	_ring.name = "PadFocusRing"
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ring.draw.connect(_draw_ring)
	_layer.add_child(_ring)
	_tip = PanelContainer.new()
	_tip.name = "PadTooltip"
	_tip.theme_type_variation = &"DarkPanel"
	_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip.visible = false
	_tip_label = Label.new()
	_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_label.custom_minimum_size = Vector2(320, 0)
	_tip_label.add_theme_font_size_override("font_size", 18)
	_tip.add_child(_tip_label)
	_layer.add_child(_tip)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	EventBus.input_device_changed.connect(_on_device_changed)


func _exit_tree() -> void:
	if instance == self:
		instance = null


func _input(event: InputEvent) -> void:
	# This node may see the event before InputDevice does (and may stop it): note the device here too. The focus is read first: a switch to
	# the pad focuses the open screen's first button, and this press must not also move it on.
	var owner_now: Control = get_viewport().gui_get_focus_owner()
	InputDevice.note(event)
	if not is_pad_nav(event):
		return
	var root: Control = top_root(get_tree())
	if root == null:
		return
	if owner_now != null and owner_now.is_visible_in_tree() and root.is_ancestor_of(owner_now):
		return
	# No focus in the open screen: this press only brings the focus there.
	if focus_into(root) != null:
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var owner_now: Control = get_viewport().gui_get_focus_owner() if InputDevice.using_pad() else null
	if owner_now != null and not owner_now.is_visible_in_tree():
		owner_now = null
	if owner_now != _focus:
		_focus = owner_now
		_rest = 0.0
	else:
		_rest += delta
	_ring.queue_redraw()
	_update_tip()
	if InputDevice.using_pad():
		_stick_scroll(delta)


func _draw_ring() -> void:
	if _focus == null or not is_instance_valid(_focus):
		return
	var rect: Rect2 = focus_rect(_focus).grow(RING_PAD)
	var pulse: float = 0.75 + 0.25 * sin(float(Time.get_ticks_msec()) / 180.0)
	var color: Color = RING_COLOR
	color.a = pulse
	_ring.draw_rect(rect.grow(2.0), Color(0, 0, 0, 0.45 * pulse), false, RING_WIDTH + 2.0)
	_ring.draw_rect(rect, color, false, RING_WIDTH)


## The control's rectangle in viewport (screen) pixels, through UiScale and canvas layers.
static func focus_rect(control: Control) -> Rect2:
	var xform: Transform2D = control.get_global_transform_with_canvas()
	return Rect2(xform.origin, control.size * xform.get_scale())


func _update_tip() -> void:
	var text: String = ""
	if _focus != null and is_instance_valid(_focus) and _rest >= TIP_DELAY:
		text = _focus.tooltip_text.strip_edges()
	if text.is_empty():
		_tip.visible = false
		return
	_tip_label.text = text
	_tip.visible = true
	_tip.reset_size()
	var rect: Rect2 = focus_rect(_focus)
	var screen: Vector2 = get_viewport().get_visible_rect().size
	var pos: Vector2 = Vector2(rect.position.x, rect.end.y + RING_PAD + 8.0)
	if pos.y + _tip.size.y > screen.y:
		pos.y = rect.position.y - RING_PAD - 8.0 - _tip.size.y
	pos.x = clampf(pos.x, 8.0, maxf(8.0, screen.x - _tip.size.x - 8.0))
	_tip.position = pos


func _on_focus_changed(control: Control) -> void:
	if not InputDevice.using_pad():
		_last_focus = control
		return
	# The focus stays inside the open screen: a D-pad step off its edge would land on a button of the screen below (the battle HUD under the
	# mulligan box, the world HUD under a shop). Step back instead.
	var root: Control = top_root(get_tree())
	if root != null and control != null and not root.is_ancestor_of(control):
		if _last_focus != null and is_instance_valid(_last_focus) and _last_focus.is_visible_in_tree() and root.is_ancestor_of(_last_focus):
			_last_focus.grab_focus.call_deferred()
		else:
			(func() -> void: focus_into(root)).call_deferred()
		return
	_last_focus = control
	_scroll_into_view(control)
	# Hover follows the pad's focus: card previews, vendor blurbs and button glows react as they would to the mouse.
	if _hovered != null and is_instance_valid(_hovered) and _hovered != control:
		_hovered.mouse_exited.emit()
	_hovered = control
	if control != null:
		control.mouse_entered.emit()


## The right stick scrolls the open screen's list (the one holding the focus, else its first visible scroll box): long texts such as the Glossary,
## a quest's story or a card list have nothing focusable to step through.
func _stick_scroll(delta: float) -> void:
	var amount: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if absf(amount) < 0.25:
		return
	var root: Control = top_root(get_tree())
	if root == null:
		return
	var scroll: ScrollContainer = null
	var parent: Node = _focus.get_parent() if _focus != null and is_instance_valid(_focus) else null
	while parent != null and scroll == null:
		scroll = parent as ScrollContainer
		parent = parent.get_parent()
	if scroll == null or not root.is_ancestor_of(scroll):
		scroll = null
		for node: Node in root.find_children("*", "ScrollContainer", true, false):
			if (node as ScrollContainer).is_visible_in_tree():
				scroll = node as ScrollContainer
				break
	if scroll != null:
		scroll.scroll_vertical += int(amount * SCROLL_SPEED * delta)


static func _scroll_into_view(control: Control) -> void:
	if control == null:
		return
	var parent: Node = control.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			(parent as ScrollContainer).ensure_control_visible(control)
			return
		parent = parent.get_parent()


func _on_device_changed(using_pad: bool) -> void:
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if using_pad else Input.MOUSE_MODE_VISIBLE
	if not using_pad and _hovered != null and is_instance_valid(_hovered):
		_hovered.mouse_exited.emit()
		_hovered = null
	if using_pad:
		# Switching to the pad on an open screen with nothing focused: focus its first button right away.
		var root: Control = top_root(get_tree())
		if root != null:
			_focus_if_lost(root)
	PromptText.refresh_all(get_tree())
