class_name ItemBar
extends Control
## New brief, Part F: the equipped-items row - click an item to use it on your turn (targeting,
## when the item needs it, reuses the same TARGETING mode/flow cards already use).

signal item_pressed(item: ItemData)

const SLOT_SIZE: Vector2 = Vector2(64, 64)
const SPACING: float = 10.0

var game: GameState
var _profile: PlayerProfile
var _slots: Array[Control] = []
var _badges: Array[Label] = []
var _items: Array[ItemData] = []


func setup(game_state: GameState, profile: PlayerProfile) -> void:
	game = game_state
	_profile = profile
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(profile.item_slots * (SLOT_SIZE.x + SPACING), SLOT_SIZE.y)
	for i: int in range(profile.item_slots):
		var slot: PanelContainer = UIKit.panel(&"DarkPanel")
		slot.position = Vector2(i * (SLOT_SIZE.x + SPACING), 0)
		slot.custom_minimum_size = SLOT_SIZE
		slot.size = SLOT_SIZE
		add_child(slot)
		var icon: TextureRect = TextureRect.new()
		icon.custom_minimum_size = SLOT_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		var badge: Label = UIKit.label("", &"", 16, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_RIGHT)
		badge.add_theme_stylebox_override("normal", UIStyle.box(Color(0, 0, 0, 0.75), Color(0, 0, 0, 0), 0, 6))
		badge.position = Vector2(SLOT_SIZE.x - 26, SLOT_SIZE.y - 24)
		badge.size = Vector2(24, 22)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(badge)
		var button: Button = Button.new()
		button.flat = true
		UIKit.full_rect(button)
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		var index: int = i
		button.pressed.connect(func() -> void: _on_pressed(index))
		slot.add_child(button)
		_slots.append(slot)
		_badges.append(badge)
		_items.append(null)
	refresh()


func refresh() -> void:
	for i: int in range(_slots.size()):
		var item: ItemData = null
		if i < _profile.equipped_item_ids.size():
			item = Session.content.item(_profile.equipped_item_ids[i])
		_items[i] = item
		var slot: PanelContainer = _slots[i]
		var icon: TextureRect = slot.get_child(0) as TextureRect
		var badge: Label = _badges[i]
		if item == null:
			icon.texture = null
			icon.visible = false
			badge.text = ""
			slot.tooltip_text = "Empty item slot"
			slot.modulate = Color(1, 1, 1, 0.35)
			continue
		icon.texture = CardIcons.for_item(item)
		icon.visible = true
		badge.text = str(_profile.item_uses_left(item))
		var usable: bool = game != null and game.can_use_item(0, item)
		slot.modulate = Color(1, 1, 1, 1.0) if usable else Color(0.55, 0.55, 0.6, 0.8)
		slot.tooltip_text = "%s\n%s" % [item.display_name, item.description]


func _on_pressed(index: int) -> void:
	var item: ItemData = _items[index]
	if item == null:
		return
	item_pressed.emit(item)
