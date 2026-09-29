class_name ItemBar
extends Control
## New brief, Part F: the equipped-items row - click an item to use it on your turn (targeting,
## when the item needs it, reuses the same TARGETING mode/flow cards already use).
## New brief (third), Part B: noticeably bigger/clearer slots - a real frame, a readable empty
## state, a gold glow (plus a gentle pulse) when an item is actually usable, and a hover tooltip
## with the item's name, full effect and targeting requirement (the same text the character screen
## and item vendor show for the same item - ItemData.tooltip_text()).

signal item_pressed(item: ItemData)

const SLOT_SIZE: Vector2 = Vector2(88, 88)
const SPACING: float = 14.0
const EMPTY_FILL: Color = Color(0.08, 0.07, 0.12, 0.75)
const EMPTY_BORDER: Color = Color(0.4, 0.38, 0.46, 0.6)
const IDLE_FILL: Color = Color(0.12, 0.1, 0.18, 0.92)
const IDLE_BORDER: Color = UIStyle.GOLD_DIM
const USABLE_FILL: Color = Color(0.16, 0.13, 0.08, 0.95)

var game: GameState
var _profile: PlayerProfile
var _slots: Array[Control] = []
var _badges: Array[Label] = []
var _items: Array[ItemData] = []
var _usable: Array[bool] = []
var _pulse_tween: Tween


func setup(game_state: GameState, profile: PlayerProfile) -> void:
	game = game_state
	_profile = profile
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(profile.item_slots * (SLOT_SIZE.x + SPACING), SLOT_SIZE.y)
	for i: int in range(profile.item_slots):
		var slot: PanelContainer = PanelContainer.new()
		slot.position = Vector2(i * (SLOT_SIZE.x + SPACING), 0)
		slot.custom_minimum_size = SLOT_SIZE
		slot.size = SLOT_SIZE
		add_child(slot)
		var icon: TextureRect = TextureRect.new()
		icon.custom_minimum_size = SLOT_SIZE * 0.62
		icon.position = SLOT_SIZE * 0.19
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(icon)
		var badge: Label = UIKit.label("", &"", 18, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_RIGHT)
		badge.add_theme_stylebox_override("normal", UIStyle.box(Color(0, 0, 0, 0.8), Color(0, 0, 0, 0), 0, 6))
		badge.position = Vector2(SLOT_SIZE.x - 30, SLOT_SIZE.y - 28)
		badge.size = Vector2(28, 24)
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
		_usable.append(false)
	refresh()


func refresh() -> void:
	var any_usable_changed: bool = false
	for i: int in range(_slots.size()):
		var item: ItemData = null
		if i < _profile.equipped_item_ids.size():
			item = Session.content.item(_profile.equipped_item_ids[i])
		_items[i] = item
		var slot: PanelContainer = _slots[i]
		var icon: TextureRect = slot.get_child(0) as TextureRect
		var badge: Label = _badges[i]
		if item == null:
			icon.texture = CardIcons.ui("item_slot")
			icon.visible = true
			icon.modulate = Color(1, 1, 1, 0.22)
			badge.text = ""
			slot.tooltip_text = "Empty item slot"
			slot.add_theme_stylebox_override("panel", UIStyle.box(EMPTY_FILL, EMPTY_BORDER, 2, 12))
			_usable[i] = false
			continue
		icon.texture = CardIcons.for_item(item)
		icon.visible = true
		icon.modulate = Color(1, 1, 1, 1.0)
		badge.text = str(_profile.item_uses_left(item))
		var usable: bool = game != null and game.can_use_item(0, item)
		if usable != _usable[i]:
			any_usable_changed = true
		_usable[i] = usable
		slot.tooltip_text = item.tooltip_text()
		if usable:
			slot.add_theme_stylebox_override("panel", UIStyle.box(USABLE_FILL, UIStyle.GOLD, 3, 12, 10))
		else:
			icon.modulate = Color(0.6, 0.6, 0.66, 0.85)
			slot.add_theme_stylebox_override("panel", UIStyle.box(IDLE_FILL, IDLE_BORDER, 2, 12))
	if any_usable_changed:
		_restart_pulse()


## A gentle, looping border-glow pulse on every currently-usable slot, so a usable item actually
## catches the eye instead of just sitting at full brightness like everything else on the HUD.
func _restart_pulse() -> void:
	if _pulse_tween != null:
		_pulse_tween.kill()
	var usable_slots: Array[Control] = []
	for i: int in range(_slots.size()):
		if _usable[i]:
			usable_slots.append(_slots[i])
	for slot: Control in usable_slots:
		slot.modulate.a = 1.0
	if usable_slots.is_empty():
		return
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.set_parallel(true)
	for slot: Control in usable_slots:
		_pulse_tween.tween_property(slot, "modulate:a", 0.62, 0.55).set_trans(Tween.TRANS_SINE)
		_pulse_tween.chain().tween_property(slot, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_SINE)


func _on_pressed(index: int) -> void:
	var item: ItemData = _items[index]
	if item == null:
		return
	item_pressed.emit(item)
