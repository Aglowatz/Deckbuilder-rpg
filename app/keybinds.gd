class_name Keybinds
extends RefCounted
## Every rebindable key of the game. Each action has two slots (primary and secondary); a slot holds a physical keycode (0 = empty). The bindings live in the
## engine's InputMap, so code asks `event.is_action_pressed(&"open_map")` and a rebind applies at once. Overrides are saved by `Settings` in settings.cfg ([keys]).
## Keys that are not rebindable on purpose: Esc (closes menus, and is the default pause key), Enter and Space for confirming dialogue and popups, the mouse, and the
## minigames' own number keys.
##
## Controller support (Oct 26, docs/design/controller.md): every action also has one controller slot, a "pad code" - a button index (0..99, Godot's standard
## SDL mapping, so Xbox and PlayStation pads agree on positions) or a stick/trigger direction (PAD_AXIS_BASE + axis * 2 + 1 when positive). Pad overrides are
## saved in settings.cfg ([pad]). Fixed controller buttons (not rebindable, like Esc and Enter): A confirms and B goes back in every menu (`ui_accept` /
## `ui_cancel`), Start is the pause button, the right stick turns the camera, the left stick and the D-pad move menu focus.

const GROUP_OVERWORLD: String = "Overworld"
const GROUP_DUNGEON: String = "Dungeon map"
const GROUP_BATTLE: String = "Battle"
const SLOTS: int = 2
## Keys that cannot be bound to an action (they cancel the capture or are fixed UI keys).
const RESERVED: Array[int] = [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER, KEY_TAB]

## Pad codes: -1 = unbound; 0..99 = a JoyButton; PAD_AXIS_BASE + axis * 2 (+1 for the positive direction) = a stick or trigger direction.
const PAD_NONE: int = -1
const PAD_AXIS_BASE: int = 100
const PAD_LS_LEFT: int = PAD_AXIS_BASE + JOY_AXIS_LEFT_X * 2
const PAD_LS_RIGHT: int = PAD_AXIS_BASE + JOY_AXIS_LEFT_X * 2 + 1
const PAD_LS_UP: int = PAD_AXIS_BASE + JOY_AXIS_LEFT_Y * 2
const PAD_LS_DOWN: int = PAD_AXIS_BASE + JOY_AXIS_LEFT_Y * 2 + 1
const PAD_LT: int = PAD_AXIS_BASE + JOY_AXIS_TRIGGER_LEFT * 2 + 1
const PAD_RT: int = PAD_AXIS_BASE + JOY_AXIS_TRIGGER_RIGHT * 2 + 1
## Pad buttons no action may take (Start is the pause button; A / B confirm and go back in menus but may also serve one action per group).
const RESERVED_PAD: Array[int] = [JOY_BUTTON_START]
## How far a stick or trigger must move to count as a press (bindings and the settings capture).
const PAD_DEADZONE: float = 0.3

## id, label, group, default keys (primary, secondary), default pad code. Order is the order of the settings screen. "pad_fixed" = shown, not rebindable.
const ACTIONS: Array[Dictionary] = [
	{"id": &"move_up", "label": "Move up", "group": GROUP_OVERWORLD, "keys": [KEY_W, KEY_UP], "pad": PAD_LS_UP},
	{"id": &"move_down", "label": "Move down", "group": GROUP_OVERWORLD, "keys": [KEY_S, KEY_DOWN], "pad": PAD_LS_DOWN},
	{"id": &"move_left", "label": "Move left", "group": GROUP_OVERWORLD, "keys": [KEY_A, KEY_LEFT], "pad": PAD_LS_LEFT},
	{"id": &"move_right", "label": "Move right", "group": GROUP_OVERWORLD, "keys": [KEY_D, KEY_RIGHT], "pad": PAD_LS_RIGHT},
	{"id": &"interact", "label": "Interact / talk / enter", "group": GROUP_OVERWORLD, "keys": [KEY_E, KEY_SPACE], "pad": JOY_BUTTON_A},
	{"id": &"open_menu", "label": "Menu (character, deck, quests...)", "group": GROUP_OVERWORLD, "keys": [0, 0], "pad": JOY_BUTTON_DPAD_UP},
	{"id": &"open_character", "label": "Character screen", "group": GROUP_OVERWORLD, "keys": [KEY_C, 0], "pad": JOY_BUTTON_Y},
	{"id": &"open_deck", "label": "Deck builder", "group": GROUP_OVERWORLD, "keys": [KEY_B, 0], "pad": JOY_BUTTON_X},
	{"id": &"open_packs", "label": "Card packs", "group": GROUP_OVERWORLD, "keys": [KEY_P, 0], "pad": JOY_BUTTON_DPAD_RIGHT},
	{"id": &"open_wardrobe", "label": "Wardrobe", "group": GROUP_OVERWORLD, "keys": [KEY_T, 0], "pad": JOY_BUTTON_DPAD_DOWN},
	{"id": &"open_quests", "label": "Quest log", "group": GROUP_OVERWORLD, "keys": [KEY_J, 0], "pad": JOY_BUTTON_DPAD_LEFT},
	{"id": &"quest_prev", "label": "Tracked quest: previous", "group": GROUP_OVERWORLD, "keys": [KEY_BRACKETLEFT, KEY_COMMA], "pad": JOY_BUTTON_LEFT_SHOULDER},
	{"id": &"quest_next", "label": "Tracked quest: next", "group": GROUP_OVERWORLD, "keys": [KEY_BRACKETRIGHT, KEY_PERIOD], "pad": JOY_BUTTON_RIGHT_SHOULDER},
	{"id": &"open_map", "label": "Map", "group": GROUP_OVERWORLD, "keys": [KEY_M, 0], "pad": JOY_BUTTON_BACK},
	{"id": &"dismount", "label": "Dismount (rafts and mounts)", "group": GROUP_OVERWORLD, "keys": [KEY_Q, 0], "pad": JOY_BUTTON_B},
	{"id": &"camera_swivel_left", "label": "Camera: turn left (hold)", "group": GROUP_OVERWORLD, "keys": [KEY_Z, 0], "pad": PAD_LT},
	{"id": &"camera_swivel_right", "label": "Camera: turn right (hold)", "group": GROUP_OVERWORLD, "keys": [KEY_X, 0], "pad": PAD_RT},
	{"id": &"camera_angle", "label": "Camera: cycle angle", "group": GROUP_OVERWORLD, "keys": [KEY_V, 0], "pad": JOY_BUTTON_RIGHT_STICK},
	{"id": &"camera_zoom", "label": "Camera: cycle zoom", "group": GROUP_OVERWORLD, "keys": [KEY_F, 0], "pad": JOY_BUTTON_LEFT_STICK},
	{"id": &"pause", "label": "Pause menu", "group": GROUP_OVERWORLD, "keys": [KEY_ESCAPE, 0], "pad": JOY_BUTTON_START, "pad_fixed": true},
	{"id": &"dungeon_rules", "label": "Dungeon rules", "group": GROUP_DUNGEON, "keys": [KEY_R, 0], "pad": JOY_BUTTON_Y},
	{"id": &"battle_advance", "label": "Next phase (Combat / End turn)", "group": GROUP_BATTLE, "keys": [KEY_SPACE, 0], "pad": JOY_BUTTON_X},
	{"id": &"battle_end_turn", "label": "End turn at once", "group": GROUP_BATTLE, "keys": [0, 0], "pad": JOY_BUTTON_BACK},
	{"id": &"battle_inspect", "label": "Inspect the selected card", "group": GROUP_BATTLE, "keys": [0, 0], "pad": JOY_BUTTON_Y},
]

## action -> Array[int] of SLOTS physical keycodes.
static var bindings: Dictionary = {}
## action -> int pad code (only actions whose pad code differs from the default... or every action after `reset_all`).
static var pad_bindings: Dictionary = {}


static func action_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for entry: Dictionary in ACTIONS:
		result.append(entry["id"] as StringName)
	return result


static func entry(action: StringName) -> Dictionary:
	for candidate: Dictionary in ACTIONS:
		if candidate["id"] == action:
			return candidate
	return {}


static func group_of(action: StringName) -> String:
	return str(entry(action).get("group", ""))


static func defaults(action: StringName) -> Array[int]:
	var result: Array[int] = []
	for code: Variant in entry(action).get("keys", [0, 0]) as Array:
		result.append(int(code))
	while result.size() < SLOTS:
		result.append(0)
	return result


static func pad_default(action: StringName) -> int:
	return int(entry(action).get("pad", PAD_NONE))


static func pad_fixed(action: StringName) -> bool:
	return bool(entry(action).get("pad_fixed", false))


## Puts every action at its default and registers it in the InputMap. Called once at startup (and by tests after changing bindings).
static func reset_all() -> void:
	bindings = {}
	pad_bindings = {}
	for action: StringName in action_ids():
		bindings[action] = defaults(action)
		pad_bindings[action] = pad_default(action)
	apply_to_input_map()


static func reset_action(action: StringName) -> void:
	bindings[action] = defaults(action)
	pad_bindings[action] = pad_default(action)
	apply_to_input_map()


static func keys_of(action: StringName) -> Array[int]:
	if not bindings.has(action):
		return defaults(action)
	var result: Array[int] = []
	for code: Variant in bindings[action] as Array:
		result.append(int(code))
	return result


static func pad_of(action: StringName) -> int:
	return int(pad_bindings.get(action, pad_default(action)))


static func is_default(action: StringName) -> bool:
	return keys_of(action) == defaults(action) and pad_of(action) == pad_default(action)


static func all_default() -> bool:
	for action: StringName in action_ids():
		if not is_default(action):
			return false
	return true


## Binds `code` to `slot` of `action`. A key already used by another action of the same group moves out of that action (its slot becomes empty); the name of that action is
## returned ("" when nothing was displaced). Reserved keys are refused (returns "reserved"). Code 0 just clears the slot.
static func rebind(action: StringName, slot: int, code: int) -> String:
	if slot < 0 or slot >= SLOTS:
		return ""
	if code != 0 and RESERVED.has(code):
		return "reserved"
	var displaced: String = ""
	if code != 0:
		for other: StringName in action_ids():
			if group_of(other) != group_of(action):
				continue
			var other_keys: Array[int] = keys_of(other)
			for index: int in range(SLOTS):
				if other_keys[index] == code and not (other == action and index == slot):
					other_keys[index] = 0
					bindings[other] = other_keys
					displaced = str(entry(other).get("label", other)) if other != action else displaced
	var mine: Array[int] = keys_of(action)
	mine[slot] = code
	bindings[action] = mine
	apply_to_input_map()
	return displaced


## Binds pad `code` to `action` (PAD_NONE clears it). Like `rebind`: a code another action of the same group used moves out of it (that action's name is returned),
## Start is refused ("reserved") and the pause button cannot move ("fixed").
static func rebind_pad(action: StringName, code: int) -> String:
	if pad_fixed(action):
		return "fixed"
	if code != PAD_NONE and RESERVED_PAD.has(code):
		return "reserved"
	var displaced: String = ""
	if code != PAD_NONE:
		for other: StringName in action_ids():
			if other == action or group_of(other) != group_of(action) or pad_of(other) != code:
				continue
			if pad_fixed(other):
				return "reserved"
			pad_bindings[other] = PAD_NONE
			displaced = str(entry(other).get("label", other))
	pad_bindings[action] = code
	apply_to_input_map()
	return displaced


## Rewrites the InputMap events of every action from `bindings` and `pad_bindings`, and gives the menus' confirm / back actions the pad's A and B.
static func apply_to_input_map() -> void:
	for action: StringName in action_ids():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_set_deadzone(action, PAD_DEADZONE)
		InputMap.action_erase_events(action)
		for code: int in keys_of(action):
			if code == 0:
				continue
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = code as Key
			InputMap.action_add_event(action, event)
		var pad: InputEvent = pad_event(pad_of(action))
		if pad != null:
			InputMap.action_add_event(action, pad)
	_add_fixed_pad(&"ui_accept", JOY_BUTTON_A)
	_add_fixed_pad(&"ui_cancel", JOY_BUTTON_B)


static func _add_fixed_pad(action: StringName, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		return
	var event: InputEventJoypadButton = InputEventJoypadButton.new()
	event.button_index = button
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)


## The InputEvent of a pad code (an any-device joypad button or stick / trigger direction); null for PAD_NONE.
static func pad_event(code: int) -> InputEvent:
	if code == PAD_NONE:
		return null
	if code < PAD_AXIS_BASE:
		var button: InputEventJoypadButton = InputEventJoypadButton.new()
		button.device = -1
		button.button_index = code as JoyButton
		return button
	var motion: InputEventJoypadMotion = InputEventJoypadMotion.new()
	motion.device = -1
	motion.axis = ((code - PAD_AXIS_BASE) / 2) as JoyAxis
	motion.axis_value = 1.0 if (code - PAD_AXIS_BASE) % 2 == 1 else -1.0
	return motion


## The pad code of a pressed controller event (what the settings capture binds); PAD_NONE for anything else or a stick inside the dead zone.
static func pad_code_of(event: InputEvent) -> int:
	var button: InputEventJoypadButton = event as InputEventJoypadButton
	if button != null:
		return int(button.button_index) if button.pressed else PAD_NONE
	var motion: InputEventJoypadMotion = event as InputEventJoypadMotion
	if motion != null and absf(motion.axis_value) >= 0.6:
		return PAD_AXIS_BASE + int(motion.axis) * 2 + (1 if motion.axis_value > 0.0 else 0)
	return PAD_NONE


## The text of a physical keycode as the player's keyboard layout shows it ("W", "Up", "Space").
static func key_text(code: int) -> String:
	if code == 0:
		return "-"
	var shown: Key = DisplayServer.keyboard_get_keycode_from_physical(code as Key) if DisplayServer.get_name() != "headless" else (code as Key)
	var text: String = OS.get_keycode_string(shown)
	if text.is_empty():
		text = OS.get_keycode_string(code as Key)
	return str(PUNCTUATION.get(text, text))


## Engine names of punctuation keys -> the character on the key.
const PUNCTUATION: Dictionary = {"BracketLeft": "[", "BracketRight": "]", "BraceLeft": "[", "BraceRight": "]", "Comma": ",", "Period": ".", "Slash": "/", "Semicolon": ";", "Apostrophe": "'", "Minus": "-", "Equal": "=", "QuoteLeft": "`", "Backslash": "\\"}


## The keys of an action as one string for hints and buttons: "E / Space" - or its controller button ("A", "Cross") while the player uses a pad.
static func hint(action: StringName) -> String:
	if InputDevice.using_pad():
		var code: int = pad_of(action)
		return InputDevice.pad_text(code) if code != PAD_NONE else "unbound"
	var parts: PackedStringArray = []
	for code: int in keys_of(action):
		if code != 0:
			parts.append(key_text(code))
	return " / ".join(parts) if not parts.is_empty() else "unbound"


## The first key of an action for short labels, e.g. "Deck (B)" - the controller button while the player uses a pad.
static func first_key(action: StringName) -> String:
	if InputDevice.using_pad():
		var code: int = pad_of(action)
		return InputDevice.pad_text(code) if code != PAD_NONE else "-"
	for code: int in keys_of(action):
		if code != 0:
			return key_text(code)
	return "-"


## The menus' back key: "Esc", or the pad's B ("Circle" on a PlayStation pad).
static func back_key() -> String:
	return InputDevice.pad_text(JOY_BUTTON_B) if InputDevice.using_pad() else "Esc"


## The menus' confirm key: "Enter", or the pad's A ("Cross").
static func confirm_key() -> String:
	return InputDevice.pad_text(JOY_BUTTON_A) if InputDevice.using_pad() else "Enter"


## The world's interact prompt prefix: "[E]" or "[A]".
static func prompt(action: StringName = &"interact") -> String:
	return "[%s]" % first_key(action)


static func save_to(config: ConfigFile) -> void:
	for action: StringName in action_ids():
		if keys_of(action) != defaults(action):
			config.set_value("keys", str(action), keys_of(action))
		if pad_of(action) != pad_default(action):
			config.set_value("pad", str(action), pad_of(action))


static func load_from(config: ConfigFile) -> void:
	bindings = {}
	pad_bindings = {}
	for action: StringName in action_ids():
		var saved: Variant = config.get_value("keys", str(action), []) if config.has_section_key("keys", str(action)) else null
		var keys: Array[int] = defaults(action)
		if saved is Array:
			keys = []
			for code: Variant in saved as Array:
				keys.append(int(code))
			while keys.size() < SLOTS:
				keys.append(0)
			keys.resize(SLOTS)
		bindings[action] = keys
		pad_bindings[action] = int(config.get_value("pad", str(action), pad_default(action))) if not pad_fixed(action) else pad_default(action)
	apply_to_input_map()
