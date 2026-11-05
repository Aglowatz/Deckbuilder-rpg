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
var _icons: Array[TextureRect] = []

const BADGE_SIZE: Vector2 = Vector2(34, 24)
## A used-up item's icon: greyscale-ish and dim (the battle bar and the Character page).
const SPENT_TINT: Color = Color(0.42, 0.42, 0.46, 0.7)


## Nov 3-4, Part A2: the charge count - a small dark pill with a gold rim and outlined text, readable on any icon (the character page uses it too).
static func charge_badge(font_size: int) -> Label:
	var badge: Label = UIKit.label("", &"", font_size, Color("fff3d6"), HORIZONTAL_ALIGNMENT_CENTER)
	badge.name = "ChargeBadge"
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_override("font", UIStyle.font_bold())
	badge.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	badge.add_theme_constant_override("outline_size", 5)
	badge.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	badge.add_theme_constant_override("shadow_offset_x", 1)
	badge.add_theme_constant_override("shadow_offset_y", 2)
	badge.add_theme_stylebox_override("normal", UIStyle.box(Color(0.06, 0.04, 0.1, 0.86), UIStyle.GOLD_DIM, 1, 8, 0))
	badge.size = BADGE_SIZE
	badge.custom_minimum_size = BADGE_SIZE
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return badge


## Sets a charge badge's text, keeping its right edge where it was (the "Used" badge is wider than "x1").
static func fit_badge(badge: Label, text: String) -> void:
	var right: Vector2 = badge.position + badge.size
	var wanted: Vector2 = Vector2(58, BADGE_SIZE.y) if text.length() > 3 else BADGE_SIZE
	badge.text = text
	badge.custom_minimum_size = wanted
	badge.size = wanted
	badge.position = right - wanted


## The slot look: the UI art kit slot (UI-HUD-SLOT) tinted per state, the old flat box without it.
func _slot_style(fill: Color, border: Color, border_width: int, shadow: int, tint: Color) -> StyleBox:
	var art: StyleBoxTexture = UiArt.nine("UI-HUD-SLOT", Vector4.ZERO, SLOT_SIZE.x / 1024.0, Vector4(8, 8, 8, 8), tint) if UiArt.has("UI-HUD-SLOT") else null
	if art != null:
		return art
	return UIStyle.box(fill, border, border_width, 12, shadow)


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
		# Nov 3-4, Part A2: the icon and the charge badge sit on a plain layer. As direct children of the PanelContainer they were
		# stretched over the whole slot, so the badge's dark box became a bar across the icon.
		var layer: Control = Control.new()
		layer.name = "Layer"
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(layer)
		var icon: TextureRect = TextureRect.new()
		icon.position = SLOT_SIZE * 0.16
		icon.size = SLOT_SIZE * 0.68
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(icon)
		var badge: Label = charge_badge(16)
		badge.position = SLOT_SIZE - BADGE_SIZE - Vector2(4, 4)
		layer.add_child(badge)
		var button: Button = Button.new()
		button.flat = true
		UIKit.full_rect(button)
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		var index: int = i
		button.pressed.connect(func() -> void: _on_pressed(index))
		slot.add_child(button)
		_slots.append(slot)
		_badges.append(badge)
		_icons.append(icon)
		_items.append(null)
		_usable.append(false)
	refresh()


func refresh() -> void:
	var any_usable_changed: bool = false
	for i: int in range(_slots.size()):
		var item: ItemData = null
		if not _profile.item_in_slot(i).is_empty():
			item = Session.content.item(_profile.item_in_slot(i))
		_items[i] = item
		var slot: PanelContainer = _slots[i]
		var icon: TextureRect = _icons[i]
		var badge: Label = _badges[i]
		var spent: ItemData = Session.content.item(_profile.spent_item_in_slot(i)) if item == null else null
		if spent != null:
			# Overnight Nov 4-5, Part 1: a used-up item stays in its slot greyed, with a "Used" badge - not the look of an empty slot.
			icon.texture = IconArt.item_texture(spent, SLOT_SIZE.x * 0.62)
			icon.visible = true
			icon.modulate = SPENT_TINT
			fit_badge(badge, "Used")
			badge.visible = true
			slot.tooltip_text = "%s - used. Each item works once." % spent.display_name
			slot.add_theme_stylebox_override("panel", _slot_style(IDLE_FILL, EMPTY_BORDER, 2, 0, Color(0.55, 0.55, 0.6)))
			_usable[i] = false
			continue
		if item == null:
			icon.texture = CardIcons.ui("item_slot")
			icon.visible = true
			icon.modulate = Color(1, 1, 1, 0.22)
			badge.text = ""
			badge.visible = false
			slot.tooltip_text = "Empty item slot"
			slot.add_theme_stylebox_override("panel", _slot_style(EMPTY_FILL, EMPTY_BORDER, 2, 0, Color(0.7, 0.72, 0.85, 0.85)))
			_usable[i] = false
			continue
		icon.texture = IconArt.item_texture(item, SLOT_SIZE.x * 0.62)  # its own ICON-ITEM-* once imported, else the old silhouette
		icon.visible = true
		icon.modulate = Color(1, 1, 1, 1.0)
		fit_badge(badge, "x%d" % _profile.item_uses_left(item))
		badge.visible = true
		var usable: bool = game != null and game.can_use_item(0, item)
		if usable != _usable[i]:
			any_usable_changed = true
		_usable[i] = usable
		slot.tooltip_text = item.tooltip_text()
		if usable:
			slot.add_theme_stylebox_override("panel", _slot_style(USABLE_FILL, UIStyle.GOLD, 3, 10, Color(1.35, 1.15, 0.8)))
		else:
			icon.modulate = Color(0.6, 0.6, 0.66, 0.85)
			slot.add_theme_stylebox_override("panel", _slot_style(IDLE_FILL, IDLE_BORDER, 2, 0, Color.WHITE))
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
