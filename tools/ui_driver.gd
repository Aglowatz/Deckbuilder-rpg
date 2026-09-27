class_name UiDriver
extends RefCounted
## Sends real mouse events to a running scene and finds controls by their text. Used by the
## end-to-end smoke tests to play the game through the same input path as a human.

var tree: SceneTree
var mouse: Vector2 = Vector2(960, 540)


func _init(scene_tree: SceneTree) -> void:
	tree = scene_tree


func frames(count: int) -> void:
	for i: int in range(count):
		await tree.process_frame


func seconds(duration: float) -> void:
	await tree.create_timer(duration, false).timeout


## Canvas (design) coordinates -> window pixels, which is what injected events expect.
func _win(pos: Vector2) -> Vector2:
	return tree.root.get_final_transform() * pos


func move_to(pos: Vector2) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = _win(pos)
	motion.global_position = _win(pos)
	motion.relative = _win(pos) - _win(mouse)
	mouse = pos
	Input.parse_input_event(motion)
	await tree.process_frame


func press(pos: Vector2, button_index: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = _win(pos)
	event.global_position = _win(pos)
	event.button_index = button_index
	event.pressed = true
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if button_index == MOUSE_BUTTON_LEFT else MOUSE_BUTTON_MASK_RIGHT
	Input.parse_input_event(event)
	await tree.process_frame


func release(pos: Vector2, button_index: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = _win(pos)
	event.global_position = _win(pos)
	event.button_index = button_index
	event.pressed = false
	Input.parse_input_event(event)
	await tree.process_frame


func click(pos: Vector2, button_index: MouseButton = MOUSE_BUTTON_LEFT) -> void:
	await move_to(pos)
	await press(pos, button_index)
	await release(pos, button_index)


## Press on `from`, move in steps to `to`, release (a drag and drop).
func drag(from: Vector2, to: Vector2) -> void:
	await move_to(from)
	await press(from)
	for step: int in range(1, 7):
		await move_to(from.lerp(to, float(step) / 6.0))
	await release(to)


func key(keycode: Key, pressed: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	Input.parse_input_event(event)
	await tree.process_frame


func tap_key(keycode: Key) -> void:
	await key(keycode, true)
	await key(keycode, false)


## First visible Button (or FancyButton) whose text contains `text`.
func find_button(text: String, root: Node = null) -> Button:
	var start: Node = root if root != null else tree.root
	for node: Node in start.find_children("*", "Button", true, false):
		var button: Button = node as Button
		if button.is_visible_in_tree() and not button.disabled and button.text.contains(text):
			return button
	return null


func button_center(button: Button) -> Vector2:
	return button.get_global_rect().get_center()


func click_button(text: String) -> bool:
	var button: Button = find_button(text)
	if button == null:
		return false
	await click(button_center(button))
	return true


func center_of_control(control: Control) -> Vector2:
	return control.get_global_transform() * (control.size * 0.5)
