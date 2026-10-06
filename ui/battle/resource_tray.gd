class_name ResourceTray
extends Control
## Brief 14, Part B: a player's resources shown as five coins (Iron, Red Tape, Contract, Ingredient, Garbage) with counts and
## tooltips. On the player's own tray, a coin whose use ability is available on your turn glows gold and can be clicked to
## pick a target unit (the BattleScreen handles that targeting flow).

signal resource_pressed(kind: ResourceKind.Kind)

const SLOT: Vector2 = Vector2(58, 58)
const GAP: float = 6.0

var game: GameState
var player_index: int = 0
var interactive: bool = false
var _slots: Dictionary = {}
var _counts: Dictionary = {}
var _last_counts: Dictionary = {}


func setup(game_state: GameState, index: int, can_click: bool) -> void:
	game = game_state
	player_index = index
	interactive = can_click
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	name = "ResourceTray%d" % index
	var kinds: Array[ResourceKind.Kind] = ResourceKind.all()
	custom_minimum_size = Vector2(kinds.size() * (SLOT.x + GAP) - GAP, SLOT.y)
	size = custom_minimum_size
	for i: int in range(kinds.size()):
		var kind: ResourceKind.Kind = kinds[i]
		var slot: PanelContainer = PanelContainer.new()
		slot.position = Vector2(i * (SLOT.x + GAP), 0)
		slot.custom_minimum_size = SLOT
		slot.size = SLOT
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.name = "Resource_%s" % ResourceKind.display_name(kind).replace(" ", "")
		add_child(slot)
		var content: Control = Control.new()
		content.custom_minimum_size = SLOT - Vector2(6, 6)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(content)
		var coin: Panel = Panel.new()
		coin.position = Vector2(5, 5)
		coin.size = SLOT - Vector2(16, 16)
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coin.add_theme_stylebox_override("panel", UIStyle.box(ResourceKind.COLORS[kind] as Color, Color(0, 0, 0, 0.5), 2, 21))
		content.add_child(coin)
		var glyph: Label = UIKit.label(str(ResourceKind.GLYPHS[kind]), &"", 22, Color("1b1020"), HORIZONTAL_ALIGNMENT_CENTER)
		glyph.add_theme_font_override("font", UIStyle.font_bold())
		glyph.position = Vector2(5, 5)
		glyph.size = SLOT - Vector2(16, 16)
		glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(glyph)
		var count: Label = UIKit.label("0", &"", 19, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
		count.add_theme_font_override("font", UIStyle.font_bold())
		count.add_theme_stylebox_override("normal", UIStyle.box(Color(0, 0, 0, 0.85), Color(0, 0, 0, 0), 0, 8))
		count.position = Vector2(SLOT.x - 34, SLOT.y - 32)
		count.size = Vector2(26, 24)
		count.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(count)
		var button: Button = Button.new()
		button.flat = true
		button.position = Vector2.ZERO
		button.size = SLOT - Vector2(6, 6)
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		var captured: ResourceKind.Kind = kind
		button.pressed.connect(func() -> void: _on_pressed(captured))
		content.add_child(button)
		_slots[int(kind)] = slot
		_counts[int(kind)] = count
	refresh()


func refresh() -> void:
	if game == null:
		return
	var player: PlayerState = game.players[player_index]
	for kind: ResourceKind.Kind in ResourceKind.all():
		var total: int = player.count_resource(kind)
		var slot: PanelContainer = _slots[int(kind)] as PanelContainer
		var count_label: Label = _counts[int(kind)] as Label
		count_label.text = str(total)
		var usable: bool = interactive and total > 0 and _usable(kind)
		var border: Color = UIStyle.GOLD if usable else (UIStyle.GOLD_DIM if total > 0 else Color(0.4, 0.38, 0.46, 0.6))
		slot.add_theme_stylebox_override("panel", UIStyle.box(Color(0.1, 0.08, 0.15, 0.92) if total > 0 else Color(0.08, 0.07, 0.12, 0.7), border, 3 if usable else 2, 29))
		slot.modulate = Color(1, 1, 1, 1.0 if total > 0 else 0.5)
		slot.tooltip_text = _tooltip(kind, total, usable)
		if int(_last_counts.get(int(kind), 0)) != total:
			_pulse(slot)
		_last_counts[int(kind)] = total


func _usable(kind: ResourceKind.Kind) -> bool:
	if not ResourceKind.has_use_ability(kind):
		return false
	if not game.in_main_phase() or game.active != player_index:
		return false
	return not ResourceRules.use_targets(game, player_index, kind).is_empty() and game.can_pay_energy(player_index, 1, [] as Array[Affinity.Type])


func _tooltip(kind: ResourceKind.Kind, total: int, usable: bool) -> String:
	var text: String = "%s (%s) x%d\n%s" % [ResourceKind.display_name(kind), Affinity.display_name(ResourceKind.path_of(kind)), total, str(ResourceKind.DESCRIPTIONS[kind])]
	if interactive and ResourceKind.has_use_ability(kind):
		text += "\n\n" + ("Click to use it on a unit." if usable else "Needs 1 energy, a unit to target, and your main phase.")
	return text


func _on_pressed(kind: ResourceKind.Kind) -> void:
	if interactive:
		resource_pressed.emit(kind)


func _pulse(slot: Control) -> void:
	if not is_inside_tree():
		return
	slot.pivot_offset = slot.size * 0.5
	var tween: Tween = create_tween()
	tween.tween_property(slot, "scale", Vector2(1.18, 1.18), 0.09)
	tween.tween_property(slot, "scale", Vector2.ONE, 0.14)
