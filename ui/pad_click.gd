class_name PadClick
extends RefCounted
## Controller support (Oct 26): controls that take mouse clicks but are not buttons (card tiles in the Deck Station, a vendor's stock, the reward
## picks) become pad-focusable, and the pad's A on one is a left click, X a right click (the Deck Station's "take one out"). The click is the same
## InputEventMouseButton the mouse would send, given to the control's own `gui_input`, so the screen's handler runs unchanged. They are focusable only
## while a pad is in use (`PadFocus` flips them on a device switch), so keyboard focus and the mouse behave exactly as before.

const GROUP: StringName = &"pad_clickable"


static func enable(control: Control) -> void:
	if control == null or control.is_in_group(GROUP):
		return
	control.add_to_group(GROUP)
	control.focus_mode = Control.FOCUS_ALL if InputDevice.using_pad() else Control.FOCUS_NONE
	control.gui_input.connect(_on_gui_input.bind(control))


## On a device switch: pad-clickable controls are focusable only while a pad is in use.
static func sync_all(tree: SceneTree, using_pad: bool) -> void:
	for node: Node in tree.get_nodes_in_group(GROUP):
		var control: Control = node as Control
		if control != null:
			if not using_pad and control.has_focus():
				control.release_focus()
			control.focus_mode = Control.FOCUS_ALL if using_pad else Control.FOCUS_NONE


static func _on_gui_input(event: InputEvent, control: Control) -> void:
	if not event is InputEventJoypadButton or not (event as InputEventJoypadButton).pressed:
		return
	var button: MouseButton = MOUSE_BUTTON_NONE
	if event.is_action_pressed(&"ui_accept"):
		button = MOUSE_BUTTON_LEFT
	elif (event as InputEventJoypadButton).button_index == JOY_BUTTON_X:
		button = MOUSE_BUTTON_RIGHT
	if button == MOUSE_BUTTON_NONE:
		return
	control.accept_event()
	click(control, button)


## Sends `control` a click (press, then release) at its centre, as the mouse would.
static func click(control: Control, button: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	for pressed: bool in [true, false]:
		var mouse: InputEventMouseButton = InputEventMouseButton.new()
		mouse.button_index = button
		mouse.pressed = pressed
		mouse.position = control.size * 0.5
		mouse.global_position = control.get_global_rect().get_center()
		if not is_instance_valid(control) or not control.is_inside_tree():
			return
		control.gui_input.emit(mouse)
