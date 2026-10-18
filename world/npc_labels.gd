class_name NpcLabels
extends CanvasLayer
## Playtest v0.4.0, Part A: floating name labels over NPCs as screen UI (never text in the 3D world). Vendors, quest givers and quest
## objectives always show theirs ("Sable - Cards"); every other NPC shows its name when the hero walks within `NEAR` metres and
## fades out when they leave. Labels follow their anchor on screen, keep off each other (a label that would overlap another is
## pushed up), hide behind the camera and while `blocked` (dialogue, menus, battles, cutscenes). One layer per scene; register
## every labelled NPC with `register`.

const NEAR: float = 4.2
const FADE: float = 1.4
const FADE_SPEED: float = 6.0
const VENDOR: Color = Color("ffd166")
const QUEST: Color = Color("9cf5a0")
const PLAIN: Color = Color("f1e6c8")
const OUTLINE: Color = Color(0.08, 0.05, 0.12, 0.95)
const MIN_SCALE: float = 0.72

## The hero.
var target: Node3D
## True while labels must stay hidden (dialogue, a menu, a cutscene, a battle).
var blocked: Callable = Callable()
## `boost.call(key) -> bool`: a plain NPC whose key is boosted (a quest to give, a quest ready, the tracked objective) keeps its label up
## like a quest giver. Polled every `BOOST_EVERY` seconds.
var boost: Callable = Callable()
const BOOST_EVERY: float = 0.5
var _boost_timer: float = 0.0
var camera: Camera3D
var _entries: Array[Dictionary] = []


static func install(parent: Node, hero: Node3D, cam: Camera3D, blocked_check: Callable) -> NpcLabels:
	var layer: NpcLabels = NpcLabels.new()
	layer.name = "NpcLabels"
	layer.target = hero
	layer.camera = cam
	layer.blocked = blocked_check
	parent.add_child(layer)
	return layer


func _ready() -> void:
	layer = 4


## `anchor` is a node at the top of the figure (a spot's marker); `kind` is "vendor", "quest" or "npc"; `always` keeps the label on
## screen regardless of distance (vendors, quest givers, quest objectives).
func register(anchor: Node3D, text: String, kind: String = "npc", always: bool = false, head: float = 0.0, key: String = "") -> Label:
	if anchor == null or text.strip_edges().is_empty():
		return null
	unregister(anchor)
	var label: Label = Label.new()
	label.name = "Label_%s" % text.replace(" ", "_")
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", UIStyle.font_title())
	label.add_theme_font_size_override("font_size", 24 if always else 21)
	label.add_theme_color_override("font_color", color_for(kind))
	label.add_theme_color_override("font_outline_color", OUTLINE)
	label.add_theme_constant_override("outline_size", 9)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.modulate.a = 0.0
	label.visible = false
	label.z_index = 30 if always else 20
	add_child(label)
	_entries.append({"anchor": anchor, "label": label, "always": always, "alpha": 0.0, "kind": kind, "head": head, "key": key, "boosted": false})
	return label


## The label's text for a list NPC: vendors say what they sell ("Sable - Cards"); everyone else their short name.
static func text_for(npc_id: String, fallback: String) -> String:
	var entry: NpcRegistry.Entry = NpcRegistry.find(npc_id)
	var name: String = entry.short_name() if entry != null else short_title(fallback)
	if name.is_empty():
		name = short_title(fallback)
	var sells: String = sells_for(npc_id)
	return "%s - %s" % [name, sells] if not sells.is_empty() else name


## A spot title cut at its first comma or bracket ("Foreman Gus, Wheelwright" -> "Foreman Gus"), like a list NPC's short name.
static func short_title(title: String) -> String:
	var result: String = title
	for cut: String in [",", " ("]:
		var at: int = result.find(cut)
		if at > 0:
			result = result.substr(0, at)
	return result.strip_edges()


## "Cards", "Gear", "Items", "Clothes", "Packs", "Alchemy" for a vendor NPC (from its list role), "" for anyone else.
static func sells_for(npc_id: String) -> String:
	var entry: NpcRegistry.Entry = NpcRegistry.find(npc_id)
	if entry == null:
		return ""
	var role: String = entry.role.to_lower()
	if not role.begins_with("vendor"):
		return ""
	if role.contains("black market"):
		return ""
	if role.contains("equipment"):
		return "Gear"
	if role.contains("consumable") or role.contains("item"):
		return "Items"
	if role.contains("clothing") or role.contains("hats"):
		return "Clothes"
	if role.contains("card"):
		return "Cards"
	if role.contains("pack"):
		return "Packs"
	if role.contains("alchemist") or role.contains("crafting"):
		return "Alchemy"
	return "Shop"


## "vendor", "quest" or "npc" for a list NPC (its role), with the black market left alone ("" = no label at all).
static func kind_for(npc_id: String) -> String:
	var entry: NpcRegistry.Entry = NpcRegistry.find(npc_id)
	if entry == null:
		return "npc"
	var role: String = entry.role.to_lower()
	if role.contains("black market"):
		return ""
	if role.begins_with("vendor"):
		return "vendor"
	if role.contains("quest giver") or role.contains("quest"):
		return "quest"
	return "npc"


static func color_for(kind: String) -> Color:
	match kind:
		"vendor":
			return VENDOR
		"quest":
			return QUEST
	return PLAIN


## Drops the label registered on `anchor` (an NPC that left the scene).
func unregister(anchor: Node3D) -> void:
	for index: int in range(_entries.size() - 1, -1, -1):
		if _entries[index]["anchor"] == anchor:
			(_entries[index]["label"] as Label).queue_free()
			_entries.remove_at(index)


## Changes a label's kind (a quest giver whose quest is done goes back to a plain near-only label, and the other way round).
func set_kind(anchor: Node3D, kind: String, always: bool) -> void:
	for entry: Dictionary in _entries:
		if entry["anchor"] == anchor:
			entry["kind"] = kind
			entry["always"] = always
			var label: Label = entry["label"] as Label
			label.add_theme_color_override("font_color", color_for(kind))
			label.add_theme_font_size_override("font_size", 24 if always else 21)
			label.z_index = 30 if always else 20


func entry_count() -> int:
	return _entries.size()


func visible_count() -> int:
	var count: int = 0
	for entry: Dictionary in _entries:
		if (entry["label"] as Label).visible:
			count += 1
	return count


func _is_blocked() -> bool:
	return blocked.is_valid() and bool(blocked.call())


func _process(delta: float) -> void:
	var cam: Camera3D = camera if camera != null and is_instance_valid(camera) else get_viewport().get_camera_3d()
	var hidden: bool = cam == null or _is_blocked()
	var placed: Array[Dictionary] = []
	_boost_timer -= delta
	if _boost_timer <= 0.0:
		_boost_timer = BOOST_EVERY
		_poll_boost()
	for entry: Dictionary in _entries:
		var anchor: Node3D = entry["anchor"] as Node3D
		var label: Label = entry["label"] as Label
		if not is_instance_valid(anchor) or not is_instance_valid(label):
			continue
		var wanted: float = 0.0
		var world: Vector3 = anchor.global_position + Vector3(0.0, float(entry["head"]), 0.0)
		var on_screen: bool = not cam.is_position_behind(world) and get_viewport().get_visible_rect().grow(-8.0).has_point(cam.unproject_position(world))
		if not hidden and anchor.is_visible_in_tree() and on_screen:
			if bool(entry["always"]) or bool(entry["boosted"]):
				wanted = 1.0
			elif target != null and is_instance_valid(target):
				var distance: float = anchor.global_position.distance_to(target.global_position)
				wanted = clampf(1.0 - (distance - NEAR) / FADE, 0.0, 1.0)
		var alpha: float = move_toward(float(entry["alpha"]), wanted, delta * FADE_SPEED)
		entry["alpha"] = alpha
		label.modulate.a = alpha
		label.visible = alpha > 0.02
		if not label.visible:
			continue
		var screen: Vector2 = cam.unproject_position(world)
		# Far-away figures get a slightly smaller label so the high camera preset stays tidy.
		var depth: float = cam.global_position.distance_to(world)
		var scale_factor: float = clampf(1.0 - (depth - 14.0) / 40.0, MIN_SCALE, 1.0)
		label.scale = Vector2.ONE * scale_factor
		label.reset_size()
		var size: Vector2 = label.size * scale_factor
		label.position = screen - Vector2(size.x * 0.5, size.y + 4.0)
		# Keep the whole label on screen when its figure stands near the edge.
		var view: Rect2 = get_viewport().get_visible_rect()
		label.position.x = clampf(label.position.x, view.position.x + 6.0, view.end.x - size.x - 6.0)
		label.pivot_offset = Vector2.ZERO
		placed.append({"label": label, "rect": Rect2(label.position, size), "always": entry["always"]})
	_spread(placed)


## A plain NPC with a quest mark (or the tracked objective) keeps its label up, in the quest colour, until the mark goes.
func _poll_boost() -> void:
	if not boost.is_valid():
		return
	for entry: Dictionary in _entries:
		var key: String = str(entry["key"])
		if key.is_empty() or bool(entry["always"]):
			continue
		var wanted: bool = bool(boost.call(key))
		if wanted == bool(entry["boosted"]):
			continue
		entry["boosted"] = wanted
		var label: Label = entry["label"] as Label
		label.add_theme_color_override("font_color", QUEST if wanted else color_for(str(entry["kind"])))
		label.add_theme_font_size_override("font_size", 24 if wanted else 21)
		label.z_index = 30 if wanted else 20


## Labels that overlap get pushed up, lower ones first, so two neighbours never print over each other.
func _spread(placed: Array[Dictionary]) -> void:
	placed.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["rect"] as Rect2).position.y > (b["rect"] as Rect2).position.y)
	for i: int in range(placed.size()):
		var rect: Rect2 = placed[i]["rect"] as Rect2
		for j: int in range(i):
			var other: Rect2 = placed[j]["rect"] as Rect2
			if rect.intersects(other.grow(2.0)):
				rect.position.y = other.position.y - rect.size.y - 2.0
		placed[i]["rect"] = rect
		(placed[i]["label"] as Label).position = rect.position
