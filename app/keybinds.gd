class_name Keybinds
extends RefCounted
## Every rebindable key of the game. Each action has two slots (primary and secondary); a slot holds a physical keycode (0 = empty). The bindings live in the
## engine's InputMap, so code asks `event.is_action_pressed(&"open_map")` and a rebind applies at once. Overrides are saved by `Settings` in settings.cfg ([keys]).
## Keys that are not rebindable on purpose: Esc (closes menus, and is the default pause key), Enter and Space for confirming dialogue and popups, the mouse, and the
## minigames' own number keys.

const GROUP_OVERWORLD: String = "Overworld"
const GROUP_BATTLE: String = "Battle"
const SLOTS: int = 2
## Keys that cannot be bound to an action (they cancel the capture or are fixed UI keys).
const RESERVED: Array[int] = [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER, KEY_TAB]

## id, label, group, default keys (primary, secondary). Order is the order of the settings screen.
const ACTIONS: Array[Dictionary] = [
	{"id": &"move_up", "label": "Move up", "group": GROUP_OVERWORLD, "keys": [KEY_W, KEY_UP]},
	{"id": &"move_down", "label": "Move down", "group": GROUP_OVERWORLD, "keys": [KEY_S, KEY_DOWN]},
	{"id": &"move_left", "label": "Move left", "group": GROUP_OVERWORLD, "keys": [KEY_A, KEY_LEFT]},
	{"id": &"move_right", "label": "Move right", "group": GROUP_OVERWORLD, "keys": [KEY_D, KEY_RIGHT]},
	{"id": &"interact", "label": "Interact / talk / enter", "group": GROUP_OVERWORLD, "keys": [KEY_E, KEY_SPACE]},
	{"id": &"open_character", "label": "Character screen", "group": GROUP_OVERWORLD, "keys": [KEY_C, 0]},
	{"id": &"open_deck", "label": "Deck builder", "group": GROUP_OVERWORLD, "keys": [KEY_B, 0]},
	{"id": &"open_packs", "label": "Card packs", "group": GROUP_OVERWORLD, "keys": [KEY_P, 0]},
	{"id": &"open_wardrobe", "label": "Wardrobe", "group": GROUP_OVERWORLD, "keys": [KEY_T, 0]},
	{"id": &"open_quests", "label": "Quest log", "group": GROUP_OVERWORLD, "keys": [KEY_J, 0]},
	{"id": &"open_map", "label": "Map", "group": GROUP_OVERWORLD, "keys": [KEY_M, 0]},
	{"id": &"dungeon_rules", "label": "Dungeon rules", "group": GROUP_OVERWORLD, "keys": [KEY_R, 0]},
	{"id": &"dismount", "label": "Dismount (rafts and mounts)", "group": GROUP_OVERWORLD, "keys": [KEY_Q, 0]},
	{"id": &"pause", "label": "Pause menu", "group": GROUP_OVERWORLD, "keys": [KEY_ESCAPE, 0]},
	{"id": &"battle_advance", "label": "Next phase (Combat / End turn)", "group": GROUP_BATTLE, "keys": [KEY_SPACE, 0]},
	{"id": &"battle_end_turn", "label": "End turn at once", "group": GROUP_BATTLE, "keys": [0, 0]},
]

## action -> Array[int] of SLOTS physical keycodes.
static var bindings: Dictionary = {}


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


## Puts every action at its default and registers it in the InputMap. Called once at startup (and by tests after changing bindings).
static func reset_all() -> void:
	bindings = {}
	for action: StringName in action_ids():
		bindings[action] = defaults(action)
	apply_to_input_map()


static func reset_action(action: StringName) -> void:
	bindings[action] = defaults(action)
	apply_to_input_map()


static func keys_of(action: StringName) -> Array[int]:
	if not bindings.has(action):
		return defaults(action)
	var result: Array[int] = []
	for code: Variant in bindings[action] as Array:
		result.append(int(code))
	return result


static func is_default(action: StringName) -> bool:
	return keys_of(action) == defaults(action)


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


## Rewrites the InputMap events of every action from `bindings`.
static func apply_to_input_map() -> void:
	for action: StringName in action_ids():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		InputMap.action_erase_events(action)
		for code: int in keys_of(action):
			if code == 0:
				continue
			var event: InputEventKey = InputEventKey.new()
			event.physical_keycode = code as Key
			InputMap.action_add_event(action, event)


## The text of a physical keycode as the player's keyboard layout shows it ("W", "Up", "Space").
static func key_text(code: int) -> String:
	if code == 0:
		return "-"
	var shown: Key = DisplayServer.keyboard_get_keycode_from_physical(code as Key) if DisplayServer.get_name() != "headless" else (code as Key)
	var text: String = OS.get_keycode_string(shown)
	return text if not text.is_empty() else OS.get_keycode_string(code as Key)


## The keys of an action as one string for hints and buttons: "E / Space".
static func hint(action: StringName) -> String:
	var parts: PackedStringArray = []
	for code: int in keys_of(action):
		if code != 0:
			parts.append(key_text(code))
	return " / ".join(parts) if not parts.is_empty() else "unbound"


## The first key of an action for short labels, e.g. "Deck (B)".
static func first_key(action: StringName) -> String:
	for code: int in keys_of(action):
		if code != 0:
			return key_text(code)
	return "-"


static func save_to(config: ConfigFile) -> void:
	for action: StringName in action_ids():
		if not is_default(action):
			config.set_value("keys", str(action), keys_of(action))


static func load_from(config: ConfigFile) -> void:
	bindings = {}
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
	apply_to_input_map()
