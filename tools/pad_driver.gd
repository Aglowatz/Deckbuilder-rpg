class_name PadDriver
extends RefCounted
## Controller support (Oct 26): sends simulated controller events (device 0, Godot's standard mapping) through `Input.parse_input_event`, the same
## path a real pad's events take, for the gamepad smoke and probes. Buttons are tapped (press + release a few frames apart); the left stick is
## held at a tilt for a while (the walk), the triggers likewise.

var tree: SceneTree
## Every event sent (the smoke checks it never sent a key or a mouse event).
var sent: int = 0


func _init(scene_tree: SceneTree) -> void:
	tree = scene_tree


func frames(count: int) -> void:
	for i: int in range(count):
		await tree.process_frame


func seconds(duration: float) -> void:
	await tree.create_timer(duration, false).timeout


func button(index: JoyButton, pressed: bool) -> void:
	var event: InputEventJoypadButton = InputEventJoypadButton.new()
	event.device = 0
	event.button_index = index
	event.pressed = pressed
	event.pressure = 1.0 if pressed else 0.0
	Input.parse_input_event(event)
	sent += 1
	await tree.process_frame


func tap(index: JoyButton, times: int = 1) -> void:
	for i: int in range(times):
		await button(index, true)
		await frames(2)
		await button(index, false)
		await frames(2)


func axis(which: JoyAxis, value: float) -> void:
	var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
	event.device = 0
	event.axis = which
	event.axis_value = value
	Input.parse_input_event(event)
	sent += 1
	await tree.process_frame


## Holds the left stick at `direction` (x right, y down; length = tilt) for `duration` seconds, then lets it go.
func walk(direction: Vector2, duration: float) -> void:
	await axis(JOY_AXIS_LEFT_X, direction.x)
	await axis(JOY_AXIS_LEFT_Y, direction.y)
	await seconds(duration)
	await axis(JOY_AXIS_LEFT_X, 0.0)
	await axis(JOY_AXIS_LEFT_Y, 0.0)


## Pushes and releases the left stick once in a direction (a menu step taken with the stick).
func flick(direction: Vector2) -> void:
	await axis(JOY_AXIS_LEFT_X, direction.x)
	await axis(JOY_AXIS_LEFT_Y, direction.y)
	await frames(2)
	await axis(JOY_AXIS_LEFT_X, 0.0)
	await axis(JOY_AXIS_LEFT_Y, 0.0)
	await frames(2)


## Steps the menu focus with the D-pad until `predicate` (given the focus owner) holds, at most `limit` presses. Returns true when it did.
func focus_until(predicate: Callable, step: JoyButton = JOY_BUTTON_DPAD_DOWN, limit: int = 40) -> bool:
	for i: int in range(limit):
		var owner_now: Control = tree.root.gui_get_focus_owner()
		if owner_now != null and bool(predicate.call(owner_now)):
			return true
		await tap(step)
	var last: Control = tree.root.gui_get_focus_owner()
	return last != null and bool(predicate.call(last))


## Moves the focus to the first visible button whose text contains `text` (D-pad down, then up, then right/left), then presses A.
func press_button(text: String, limit: int = 30) -> bool:
	var matches: Callable = func(control: Control) -> bool: return control is Button and (control as Button).text.contains(text)
	for direction: JoyButton in [JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_LEFT]:
		if await focus_until(matches, direction, limit):
			await tap(JOY_BUTTON_A)
			return true
	return false
