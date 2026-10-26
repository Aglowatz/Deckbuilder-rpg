class_name UiInput
extends RefCounted
## Overnight Oct 17, Part 13: every screen reads input through named actions, so a controller can be mapped later in one place
## (project.godot's input map and `Keybinds`): "confirm" is ui_accept (Enter, Space, keypad Enter, a pad's A) or the overworld
## interact action (E); "back" is ui_cancel (Escape, a pad's B). Screens call these instead of checking key codes.


## True for a fresh press of confirm (not an echo).
static func is_confirm(event: InputEvent) -> bool:
	if event == null or event.is_echo():
		return false
	if event.is_action_pressed(&"ui_accept"):
		return true
	return InputMap.has_action(&"interact") and event.is_action_pressed(&"interact")


## Controller support (Oct 26): true for a fresh press of a key or a controller button, or a stick / trigger that just crossed half way (a
## stick sends many motion events while held; only the first one past the middle counts). Mouse events are not presses here. The world's
## shortcut keys (C, B, J...) check this before their actions, so a held key's echo or a resting stick never repeats them.
static func is_fresh_press(event: InputEvent) -> bool:
	var key: InputEventKey = event as InputEventKey
	if key != null:
		return key.pressed and not key.echo
	var button: InputEventJoypadButton = event as InputEventJoypadButton
	if button != null:
		return button.pressed
	var motion: InputEventJoypadMotion = event as InputEventJoypadMotion
	if motion == null:
		return false
	var axis_key: String = "%d:%d" % [motion.device, motion.axis]
	var cached: Array = _axis_seen.get(axis_key, [0, 0.0, false]) as Array
	if int(cached[0]) == motion.get_instance_id():
		return bool(cached[2])
	var fresh: bool = absf(motion.axis_value) >= 0.5 and absf(float(cached[1])) < 0.5
	_axis_seen[axis_key] = [motion.get_instance_id(), motion.axis_value, fresh]
	return fresh


## device:axis -> [the last motion event's instance id, its value, whether it was a fresh press].
static var _axis_seen: Dictionary = {}


## True for a fresh press of back.
static func is_back(event: InputEvent) -> bool:
	return event != null and not event.is_echo() and event.is_action_pressed(&"ui_cancel")


## Makes every button under `root` reachable with the keyboard / a pad (FancyButton turns focus off by default so a click does not leave a
## focused button behind in the world HUD). Overlay screens, popups and dialogs call this once they are built.
static func make_focusable(root: Node) -> int:
	var count: int = 0
	for node: Node in root.find_children("*", "BaseButton", true, false):
		var button: BaseButton = node as BaseButton
		if button.focus_mode == Control.FOCUS_NONE:
			button.focus_mode = Control.FOCUS_ALL
			count += 1
	return count


## Gives focus to the first visible, enabled button under `root` (in tree order), skipping any in `skip`. Returns it or null.
static func focus_first(root: Node, skip: Array[Control] = []) -> Control:
	for node: Node in root.find_children("*", "BaseButton", true, false):
		var button: BaseButton = node as BaseButton
		if skip.has(button) or button.disabled or not button.is_visible_in_tree() or button.focus_mode == Control.FOCUS_NONE:
			continue
		button.grab_focus()
		return button
	return null
