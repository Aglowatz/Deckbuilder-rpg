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
	await tree.create_timer(duration, true).timeout  # runs in the pause menu too


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
	print("pad_driver: walk %s -> move strength u%.2f d%.2f l%.2f r%.2f vector %s" % [direction, Input.get_action_strength(&"move_up"), Input.get_action_strength(&"move_down"), Input.get_action_strength(&"move_left"), Input.get_action_strength(&"move_right"), Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")])
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


## Moves the focus to a visible button whose text contains `text` - along the shortest D-pad path through the focus graph - then presses A.
## Returns true when it found and pressed one.
func press_button(text: String, limit: int = 40) -> bool:
	var matches: Callable = func(control: Control) -> bool: return control is Button and (control as Button).text.contains(text) and control.is_visible_in_tree()
	if not await focus_to(matches, limit):
		return false
	await tap(JOY_BUTTON_A)
	return true


const _SIDES: Array[Side] = [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]
const _SIDE_BUTTONS: Array[JoyButton] = [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN]
const _DIRECTIONS: Array[Vector2] = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]


## Steers the focus onto a control `predicate` accepts by pressing the D-pad along the shortest path in the focus graph (re-planned after
## every press, since a press can rebuild or scroll the screen). The first press wakes the focus when nothing has it.
func focus_to(predicate: Callable, limit: int = 40) -> bool:
	for _step: int in range(limit):
		var here: Control = tree.root.gui_get_focus_owner()
		var root: Control = PadFocus.top_root(tree)
		if here == null or not here.is_visible_in_tree() or (root != null and not root.is_ancestor_of(here)):
			print("pad_driver: waking the focus (focus %s, open screen %s)" % [here, root])
			await tap(JOY_BUTTON_DPAD_DOWN)
			continue
		if bool(predicate.call(here)):
			return true
		var side: int = _plan(here, predicate)
		if side < 0:
			print("pad_driver: nothing matching is reachable from %s (open screen %s)" % [here, root])
			return false
		await tap(_SIDE_BUTTONS[side])
	var last: Control = tree.root.gui_get_focus_owner()
	return last != null and bool(predicate.call(last))


## The first D-pad side (an index into _SIDES) of the shortest focus path from `from` to a control `predicate` accepts; -1 when none is reachable.
func _plan(from: Control, predicate: Callable) -> int:
	var root: Control = PadFocus.top_root(tree)
	var first: Dictionary = {from: -1}
	var queue: Array[Control] = [from]
	while not queue.is_empty():
		var here: Control = queue.pop_front()
		for index: int in range(_SIDES.size()):
			var next: Control = PadFocus.neighbor(here, _DIRECTIONS[index], root) if root != null else here.find_valid_focus_neighbor(_SIDES[index])
			if next == null or first.has(next) or not next.is_visible_in_tree() or (root != null and not root.is_ancestor_of(next)):
				continue
			first[next] = index if here == from else int(first[here])
			if bool(predicate.call(next)):
				return int(first[next])
			queue.append(next)
	return -1
