class_name ConfirmKey
extends Node
## Fresh eyes round 2 (Oct 31): one rule for every "Continue" - E, Enter, Space and the pad's A press the screen's button, as a click does. The
## mid-game critic counted five different "continue" conventions (dialogue E / click, stills click / Space, mouse-only Continue on the
## event result and the pre-fight rules card) and got stuck as a keyboard player. `attach(screen, button)` adds this node under the screen:
## while the screen is visible and the button enabled, a confirm press that nothing else took presses it, after a short guard so the key
## that opened the screen can never also close it. A focused FancyButton takes Enter / Space / A itself; this catches E and any confirm
## press while nothing has the focus.

const GUARD_TIME: float = 0.4

var button: BaseButton
var _age: float = 0.0


static func attach(screen: Control, target: BaseButton, guard: float = GUARD_TIME) -> ConfirmKey:
	if screen == null or target == null:
		return null
	var key: ConfirmKey = ConfirmKey.new()
	key.name = "ConfirmKey"
	key.button = target
	key._age = -maxf(0.0, guard - GUARD_TIME)
	screen.add_child(key)
	return key


func _process(delta: float) -> void:
	_age += delta


func _unhandled_input(event: InputEvent) -> void:
	if _age < GUARD_TIME or button == null or not is_instance_valid(button) or button.disabled or not button.is_visible_in_tree():
		return
	var screen: Control = get_parent() as Control
	if screen != null and not screen.is_visible_in_tree():
		return
	if UiInput.is_confirm(event):
		get_viewport().set_input_as_handled()
		button.pressed.emit()
