class_name InputDevice
extends Node
## Controller support (Oct 26, docs/design/controller.md): which device the player is using right now - the keyboard and mouse, or a controller - so
## button prompts show the right glyphs ("E" or "A" / "Cross"). The last real input decides: a pad button or a stick past the dead zone switches to
## the controller, a key, a click or a real mouse move switches back. Every switch emits `EventBus.input_device_changed`; `PromptText` re-renders
## the prompts that registered with it. One instance lives under SceneManager; the state is static so ui/ code and tests read it without a node.

enum Kind { KEYBOARD, PAD }
## The pad's face-button names: Xbox (A B X Y, LB/RB, View/Menu) or PlayStation (Cross Circle Square Triangle, L1/R1, Create/Options).
enum Layout { XBOX, PLAYSTATION }

## How far the mouse must move in one event to count as "back to the mouse" (a resting hand jitters a pixel or two).
const MOUSE_SWITCH_PIXELS: float = 6.0
## How far a stick or trigger must move to count as "using the controller".
const STICK_SWITCH: float = 0.45

static var kind: Kind = Kind.KEYBOARD
## The layout read from the last pad's name (Settings.pad_prompts can force one).
static var detected_layout: Layout = Layout.XBOX
static var pad_name: String = ""


func _ready() -> void:
	name = "InputDevice"
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not Input.joy_connection_changed.is_connected(_on_joy_connection):
		Input.joy_connection_changed.connect(_on_joy_connection)
	var pads: Array[int] = Input.get_connected_joypads()
	if not pads.is_empty():
		_read_layout(pads[0])


func _input(event: InputEvent) -> void:
	note(event)


## Looks at one input event and switches the device when it is a real use of the other one. Returns true when the device changed.
static func note(event: InputEvent) -> bool:
	var next: Kind = kind
	if event is InputEventJoypadButton:
		if (event as InputEventJoypadButton).pressed:
			next = Kind.PAD
			_read_layout(event.device)
	elif event is InputEventJoypadMotion:
		if absf((event as InputEventJoypadMotion).axis_value) >= STICK_SWITCH:
			next = Kind.PAD
			_read_layout(event.device)
	elif event is InputEventKey:
		if (event as InputEventKey).pressed:
			next = Kind.KEYBOARD
	elif event is InputEventMouseButton:
		if (event as InputEventMouseButton).pressed:
			next = Kind.KEYBOARD
	elif event is InputEventMouseMotion:
		if (event as InputEventMouseMotion).relative.length() >= MOUSE_SWITCH_PIXELS:
			next = Kind.KEYBOARD
	if next == kind:
		return false
	set_kind(next)
	return true


static func set_kind(next: Kind) -> void:
	if next == kind:
		return
	kind = next
	GameLog.info("input", "prompts now show the %s" % ("controller" if kind == Kind.PAD else "keyboard"))
	EventBus.input_device_changed.emit(kind == Kind.PAD)


static func using_pad() -> bool:
	return kind == Kind.PAD


## The layout the prompts use: Settings.pad_prompts 0 = detect from the pad's name, 1 = Xbox, 2 = PlayStation.
static func layout() -> Layout:
	var forced: int = Settings.pad_prompts if Settings != null else 0
	if forced == 1:
		return Layout.XBOX
	if forced == 2:
		return Layout.PLAYSTATION
	return detected_layout


static func _read_layout(device: int) -> void:
	if device < 0:
		return
	var joy: String = Input.get_joy_name(device)
	if joy.is_empty() or joy == pad_name:
		return
	pad_name = joy
	detected_layout = layout_for_name(joy)


## PlayStation pads by name (SDL's names: "PS4 Controller", "PS5 Controller", "DualSense Wireless Controller", "Sony ..."); everything else reads as Xbox.
static func layout_for_name(joy: String) -> Layout:
	var lower: String = joy.to_lower()
	for word: String in ["playstation", "dualshock", "dualsense", "sony", "ps3", "ps4", "ps5"]:
		if lower.contains(word):
			return Layout.PLAYSTATION
	return Layout.XBOX


func _on_joy_connection(device: int, connected: bool) -> void:
	if connected:
		pad_name = ""
		_read_layout(device)
		GameLog.info("input", "controller connected: %s" % Input.get_joy_name(device))
	elif Input.get_connected_joypads().is_empty() and kind == Kind.PAD:
		set_kind(Kind.KEYBOARD)


const XBOX_BUTTONS: Dictionary = {
	JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y", JOY_BUTTON_BACK: "View", JOY_BUTTON_GUIDE: "Guide", JOY_BUTTON_START: "Menu",
	JOY_BUTTON_LEFT_STICK: "LS", JOY_BUTTON_RIGHT_STICK: "RS", JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "D-pad Up", JOY_BUTTON_DPAD_DOWN: "D-pad Down", JOY_BUTTON_DPAD_LEFT: "D-pad Left", JOY_BUTTON_DPAD_RIGHT: "D-pad Right", JOY_BUTTON_MISC1: "Share",
}
const PLAYSTATION_BUTTONS: Dictionary = {
	JOY_BUTTON_A: "Cross", JOY_BUTTON_B: "Circle", JOY_BUTTON_X: "Square", JOY_BUTTON_Y: "Triangle", JOY_BUTTON_BACK: "Create", JOY_BUTTON_GUIDE: "PS", JOY_BUTTON_START: "Options",
	JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3", JOY_BUTTON_LEFT_SHOULDER: "L1", JOY_BUTTON_RIGHT_SHOULDER: "R1",
	JOY_BUTTON_DPAD_UP: "D-pad Up", JOY_BUTTON_DPAD_DOWN: "D-pad Down", JOY_BUTTON_DPAD_LEFT: "D-pad Left", JOY_BUTTON_DPAD_RIGHT: "D-pad Right", JOY_BUTTON_MISC1: "Mic",
}


## The name of a pad code on the current (or the given) layout: "A", "Cross", "LT", "L2", "Left stick up".
static func pad_text(code: int, which: int = -1) -> String:
	var shown: Layout = layout() if which < 0 else which as Layout
	if code == Keybinds.PAD_NONE:
		return "-"
	if code < Keybinds.PAD_AXIS_BASE:
		var names: Dictionary = PLAYSTATION_BUTTONS if shown == Layout.PLAYSTATION else XBOX_BUTTONS
		return str(names.get(code, "Button %d" % code))
	var axis: int = (code - Keybinds.PAD_AXIS_BASE) / 2
	var positive: bool = (code - Keybinds.PAD_AXIS_BASE) % 2 == 1
	match axis:
		JOY_AXIS_LEFT_X:
			return "Left stick right" if positive else "Left stick left"
		JOY_AXIS_LEFT_Y:
			return "Left stick down" if positive else "Left stick up"
		JOY_AXIS_RIGHT_X:
			return "Right stick right" if positive else "Right stick left"
		JOY_AXIS_RIGHT_Y:
			return "Right stick down" if positive else "Right stick up"
		JOY_AXIS_TRIGGER_LEFT:
			return "L2" if shown == Layout.PLAYSTATION else "LT"
		JOY_AXIS_TRIGGER_RIGHT:
			return "R2" if shown == Layout.PLAYSTATION else "RT"
	return "Axis %d%s" % [axis, "+" if positive else "-"]
