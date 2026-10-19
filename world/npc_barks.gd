class_name NpcBarks
extends CanvasLayer
## Overnight Oct 17, Part 11: NPCs say a short line when the hero walks past (dad jokes, puns, the odd millennial reference), in a
## small speech bubble over their head. The lines live in the NPC source of truth (`data/npcs/npcs.json`, "barks", read through
## `NpcRegistry`). The bubble is screen UI that follows the NPC (no text in the 3D world). One NPC speaks at a time, each at most
## once every `NPC_COOLDOWN` seconds, never during dialogue or a menu (`blocked`), and only when the hero comes close.

const RANGE: float = 3.2
const SHOW_SECONDS: float = 3.4
const NPC_COOLDOWN: float = 45.0
const GLOBAL_COOLDOWN: float = 7.0
const HEAD_HEIGHT: float = 2.15

## The hero (any Node3D).
var target: Node3D
## Returns true while barks must stay quiet (dialogue, a menu, a cutscene).
var blocked: Callable = Callable()
var _entries: Array[Dictionary] = []
var _bubble: PanelContainer
var _label: Label
var _speaker: Node3D
var _shown: float = 0.0
var _global: float = 2.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


## Registers an NPC model/actor with its list NPC ID; NPCs without barks are ignored.
func register(node: Node3D, npc_id: String) -> void:
	var lines: Array[String] = NpcRegistry.barks(npc_id)
	if node == null or lines.is_empty():
		return
	_entries.append({"node": node, "id": npc_id, "lines": lines, "cooldown": _rng.randf_range(0.0, 6.0), "inside": false})


## Registers a node with its own lines (an ambient worker whose words live in a zone story file, not the NPC list).
func register_lines(node: Node3D, id: String, lines: Array[String]) -> void:
	if node == null or lines.is_empty():
		return
	_entries.append({"node": node, "id": id, "lines": lines, "cooldown": _rng.randf_range(0.0, 6.0), "inside": false})


func entry_count() -> int:
	return _entries.size()


func _ready() -> void:
	layer = 4
	_rng.randomize()
	_bubble = PanelContainer.new()
	_bubble.name = "BarkBubble"
	_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.add_theme_stylebox_override("panel", UIStyle.box(Color(0.99, 0.96, 0.88, 0.94), Color(0.25, 0.17, 0.1, 0.9), 2, 12))
	_label = UIKit.label("", &"", 20, Color("2a1a10"), HORIZONTAL_ALIGNMENT_CENTER)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(260, 0)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble.add_child(UIKit.margin(_label, 8))
	_bubble.visible = false
	add_child(_bubble)


func _process(delta: float) -> void:
	_global -= delta
	for entry: Dictionary in _entries:
		entry["cooldown"] = float(entry["cooldown"]) - delta
	if _speaker != null:
		_shown -= delta
		if _shown <= 0.0 or not is_instance_valid(_speaker) or _is_blocked():
			_hide()
		else:
			_place()
		return
	if target == null or not is_instance_valid(target) or _is_blocked():
		return
	for entry: Dictionary in _entries:
		var node: Node3D = entry["node"] as Node3D
		if not is_instance_valid(node) or not node.is_visible_in_tree():
			continue
		var near: bool = node.global_position.distance_to(target.global_position) < RANGE
		var was_inside: bool = bool(entry["inside"])
		entry["inside"] = near
		# Speak on walking up (entering the range), not every frame while standing there.
		if near and not was_inside and _global <= 0.0 and float(entry["cooldown"]) <= 0.0:
			var lines: Array[String] = entry["lines"]
			_show(node, lines[_rng.randi() % lines.size()])
			entry["cooldown"] = NPC_COOLDOWN
			_global = GLOBAL_COOLDOWN
			return


func _is_blocked() -> bool:
	return blocked.is_valid() and bool(blocked.call())


func _show(node: Node3D, text: String) -> void:
	_speaker = node
	_shown = SHOW_SECONDS
	_label.text = text
	_bubble.visible = true
	_bubble.reset_size()
	_bubble.modulate.a = 0.0
	create_tween().tween_property(_bubble, "modulate:a", 1.0, 0.18)
	_place()


func _hide() -> void:
	_speaker = null
	_bubble.visible = false


func _place() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null or _speaker == null:
		return
	var head: Vector3 = _speaker.global_position + Vector3(0.0, HEAD_HEIGHT, 0.0)
	if camera.is_position_behind(head):
		_bubble.visible = false
		return
	_bubble.visible = true
	var at: Vector2 = camera.unproject_position(head)
	_bubble.position = at - Vector2(_bubble.size.x * 0.5, _bubble.size.y + 6.0)


## The line on screen ("" when none), for tests and smokes.
func current_line() -> String:
	return _label.text if _speaker != null else ""
