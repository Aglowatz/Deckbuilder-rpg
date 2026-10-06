class_name CardView
extends Control
## One card on screen. Built from a CardData: a frame tinted per affinity, cost pips, name,
## placeholder art (game-icons silhouette on a gradient), type line, rules text with bold
## keywords, attack/defense and a rarity gem. Three looks: FULL (hand, zoom, deckbuilder),
## COMPACT (field: art-first, no rules text) and BACK (face-down / opponent hand).
## The card is laid out at 300x420; scale the node to draw it smaller or larger.

signal hovered(view: CardView)
signal unhovered(view: CardView)
signal gui_event(view: CardView, event: InputEvent)

enum Mode { FULL, COMPACT, BACK }
enum Glow { NONE, PLAYABLE, SELECTED, TARGET, ATTACK, BLOCK }

const SIZE: Vector2 = Vector2(300, 420)
## Common, Uncommon, Epic, Legendary - see docs/design/combat_rules.md "Rarity". Colors AND gem
## shapes are distinct per tier (Gem below), so rarity reads at a glance even color-blind.
const RARITY_COLORS: Array[Color] = [Color("c9c2b4"), Color("5fd6a4"), Color("b48cf2"), Color("ff9c3a")]
const RARITY_NAMES: Array[String] = ["Common", "Uncommon", "Epic", "Legendary"]
const PARCHMENT_BG: Color = Color("eadfc4")
const PARCHMENT_TEXT: Color = Color("2b2233")

var data: CardData
var instance_uid: int = 0
var mode: Mode = Mode.FULL
var accent: Color = Color.WHITE
## Brief 9, Part F: a multi-Path card's second Path color (Color.WHITE and `dual` false for a normal card).
var accent2: Color = Color.WHITE
var dual: bool = false

var _frame: Panel
var _glow: Control
var _name_label: Label
var _attack_label: Label
var _plaque: PanelContainer
var _badge_sick: Label
var _damage_label: Label
var _tint_overlay: ColorRect
var _glow_tween: Tween
var _glow_kind: Glow = Glow.NONE
var _base_attack: int = 0
var _base_defense: int = 0


static func create(card: CardData, card_mode: Mode = Mode.FULL) -> CardView:
	var view: CardView = CardView.new()
	view.data = card
	view.mode = card_mode
	return view


## A fixed-size wrapper so scaled cards can sit in containers (grids, lists).
static func wrapped(card: CardData, card_scale: float, card_mode: Mode = Mode.FULL) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = SIZE * card_scale
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var view: CardView = create(card, card_mode)
	# This is a static display, not an interactive card (see callers): without this, the view
	# itself still defaults to stopping mouse input, silently eating clicks meant for whatever
	# it sits on top of (e.g. a clickable tile behind it). Deferred because CardView's own
	# _ready() (which runs once it actually enters the tree, after this call returns) sets
	# mouse_filter to STOP unconditionally, undoing a plain assignment made here.
	view.set_deferred(&"mouse_filter", Control.MOUSE_FILTER_IGNORE)
	holder.add_child(view)
	fit(view, card_scale)
	return holder


## Scales a card that sits at the top-left of a holder so its visible rect starts at (0, 0)
## (cards scale around their centre).
static func fit(view: CardView, card_scale: float) -> void:
	view.scale = Vector2.ONE * card_scale
	view.position = -SIZE * (1.0 - card_scale) * 0.5


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	pivot_offset = SIZE * 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP
	if data != null:
		accent = UIStyle.affinity_color(data.color)
		dual = data.is_multipath()
		accent2 = UIStyle.affinity_color(data.color2) if dual else accent
	_build()
	mouse_entered.connect(func() -> void: hovered.emit(self))
	mouse_exited.connect(func() -> void: unhovered.emit(self))
	gui_input.connect(func(event: InputEvent) -> void: gui_event.emit(self, event))


func _build() -> void:
	if _glow_tween != null and _glow_tween.is_valid():
		_glow_tween.kill()
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	if mode == Mode.BACK or data == null:
		_build_back()
		return
	_base_attack = data.attack
	_base_defense = data.defense
	_frame = _panel(Rect2(Vector2.ZERO, SIZE), UIStyle.box(Color("1c1526"), accent.darkened(0.15), 6, 20, 10))
	add_child(_frame)
	if dual:
		add_child(_panel(Rect2(Vector2(3, 3), SIZE - Vector2(6, 6)), UIStyle.box(Color(0, 0, 0, 0), accent2.darkened(0.1), 4, 17)))
	_build_name_bar()
	_build_art()
	if mode == Mode.FULL:
		_build_type_line()
		_build_rules()
	else:
		_build_chips()
	_build_plaque()
	_build_overlays()


func _panel(rect: Rect2, style: StyleBox) -> Panel:
	var panel: Panel = Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _build_back() -> void:
	var tint: Color = Color("5a3f7a") if data == null else accent.darkened(0.45)
	_frame = _panel(Rect2(Vector2.ZERO, SIZE), UIStyle.box(Color("1c1526"), UIStyle.GOLD_DIM, 6, 20, 10))
	add_child(_frame)
	var field: ColorRect = ColorRect.new()
	field.position = Vector2(16, 16)
	field.size = SIZE - Vector2(32, 32)
	field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://ui/shaders/card_art.gdshader") as Shader
	material.set_shader_parameter("top", tint.lightened(0.15))
	material.set_shader_parameter("bottom", tint.darkened(0.55))
	material.set_shader_parameter("glow", UIStyle.GOLD)
	field.material = material
	add_child(field)
	var emblem: TextureRect = CardIcons.glyph(CardIcons.ui("magic"), Color(UIStyle.GOLD, 0.85), Vector2(150, 150))
	emblem.position = (SIZE - Vector2(150, 150)) * 0.5
	emblem.size = Vector2(150, 150)
	add_child(emblem)
	add_child(_panel(Rect2(Vector2(16, 16), SIZE - Vector2(32, 32)), UIStyle.box(Color(0, 0, 0, 0), UIStyle.GOLD_DIM, 3, 8)))


func _build_name_bar() -> void:
	var height: float = 46.0 if mode == Mode.FULL else 64.0
	var bar: Panel = _panel(Rect2(12, 12, 276, height), UIStyle.box(accent.darkened(0.5), accent.lightened(0.1), 2, 9))
	add_child(bar)
	if dual:
		bar.clip_contents = true
		var blend: GradientTexture2D = GradientTexture2D.new()
		var ramp: Gradient = Gradient.new()
		ramp.set_color(0, accent.darkened(0.5))
		ramp.set_color(1, accent2.darkened(0.5))
		blend.gradient = ramp
		blend.fill_from = Vector2(0.0, 0.5)
		blend.fill_to = Vector2(1.0, 0.5)
		var fill: TextureRect = TextureRect.new()
		fill.texture = blend
		fill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fill.position = Vector2(2, 2)
		fill.size = Vector2(272, height - 4)
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_child(fill)
	_name_label = Label.new()
	_name_label.text = _display_name()
	_name_label.position = Vector2(22, 12)
	_name_label.size = Vector2(276 - 20 - _pips_width() - 6, height)
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_override("font", UIStyle.font_title())
	_name_label.add_theme_color_override("font_color", UIStyle.PARCHMENT)
	_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_name_label.add_theme_constant_override("shadow_offset_y", 2)
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if mode == Mode.COMPACT else TextServer.AUTOWRAP_OFF
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fit_name(_name_label, 24 if mode == Mode.FULL else 25)
	_name_label.add_theme_constant_override("line_spacing", -6)
	add_child(_name_label)
	if not data.is_infrastructure():
		var pips: PipRow = PipRow.new()
		pips.data = data
		pips.position = Vector2(288 - 8 - _pips_width(), 12 + (height - 30.0) * 0.5)
		pips.size = Vector2(_pips_width(), 30)
		pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pips)


func _display_name() -> String:
	if data.is_infrastructure():
		return "%s Infrastructure" % UIStyle.affinity_name(data.color)
	return data.display_name


func _pips_width() -> float:
	if data.is_infrastructure():
		return 0.0
	var count: int = data.colored_pips.size() + (1 if data.generic_cost > 0 else 0)
	return maxf(30.0, count * 32.0)


func _fit_name(label: Label, max_size: int) -> void:
	var font: Font = UIStyle.font_title()
	var chosen: int = max_size
	var available: float = label.size.x
	while chosen > 15 and mode == Mode.FULL and font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, chosen).x > available:
		chosen -= 1
	if mode == Mode.COMPACT:
		while chosen > 17 and font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, chosen).x > available * 1.9:
			chosen -= 1
	# A name that still does not fit on one line (long multi-Path card names) wraps onto two smaller lines.
	if mode == Mode.FULL and font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, chosen).x > available:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		chosen = 17
	label.add_theme_font_size_override("font_size", chosen)


func _build_art() -> void:
	var top: float = 64.0 if mode == Mode.FULL else 82.0
	var height: float = 172.0 if mode == Mode.FULL else 228.0
	var art: ColorRect = ColorRect.new()
	art.position = Vector2(12, top)
	art.size = Vector2(276, height)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://ui/shaders/card_art.gdshader") as Shader
	material.set_shader_parameter("top", accent.lightened(0.05))
	if dual:
		material.set_shader_parameter("bottom", accent2.darkened(0.45))
		material.set_shader_parameter("glow", accent2.lightened(0.5))
	material.set_shader_parameter("bottom", accent.darkened(0.7))
	material.set_shader_parameter("glow", accent.lightened(0.5))
	art.material = material
	add_child(art)
	var icon_size: float = height * 0.78
	var texture: Texture2D = CardIcons.for_card(data)
	var shadow: TextureRect = CardIcons.glyph(texture, Color(0, 0, 0, 0.45), Vector2(icon_size, icon_size))
	shadow.position = Vector2(12 + (276 - icon_size) * 0.5 + 4, top + (height - icon_size) * 0.5 + 6)
	shadow.size = Vector2(icon_size, icon_size)
	add_child(shadow)
	var icon: TextureRect = CardIcons.glyph(texture, Color("fdf3dc"), Vector2(icon_size, icon_size))
	icon.position = Vector2(12 + (276 - icon_size) * 0.5, top + (height - icon_size) * 0.5)
	icon.size = Vector2(icon_size, icon_size)
	add_child(icon)
	add_child(_panel(Rect2(12, top, 276, height), UIStyle.box(Color(0, 0, 0, 0), accent.lightened(0.2), 3, 4)))
	if dual:
		# Two Path gems in the art's corner: both Paths of this card at a glance.
		for index: int in range(2):
			var gem_color: Color = accent if index == 0 else accent2
			var dot: Panel = _panel(Rect2(22 + index * 26, top + 10, 22, 22), UIStyle.box(gem_color, Color("fdf3dc"), 2, 11, 4))
			add_child(dot)


func _build_type_line() -> void:
	var bar: Panel = _panel(Rect2(12, 242, 276, 30), UIStyle.box(Color("2b2136"), Color(1, 1, 1, 0.08), 1, 7))
	add_child(bar)
	var label: Label = Label.new()
	label.text = _type_text()
	label.position = Vector2(22, 242)
	label.size = Vector2(220, 30)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", UIStyle.font_bold())
	label.add_theme_font_size_override("font_size", 16 if dual else 19)
	label.add_theme_color_override("font_color", UIStyle.PARCHMENT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	var rarity: Label = Label.new()
	rarity.text = RARITY_NAMES[int(data.rarity)]
	rarity.position = Vector2(20, 384)
	rarity.size = Vector2(160, 30)
	rarity.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rarity.add_theme_font_override("font", UIStyle.font_bold())
	rarity.add_theme_font_size_override("font_size", 17)
	rarity.add_theme_color_override("font_color", RARITY_COLORS[int(data.rarity)])
	rarity.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rarity)
	var gem: Gem = Gem.new()
	gem.color = RARITY_COLORS[int(data.rarity)]
	gem.rarity = int(data.rarity)
	gem.position = Vector2(288 - 10 - 20, 247)
	gem.size = Vector2(20, 20)
	gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gem)


func _type_text() -> String:
	var kind: String = "Unit"
	match data.type:
		CardEnums.CardType.INFRASTRUCTURE:
			kind = "Basic Infrastructure" if data.is_basic else "Infrastructure"
		CardEnums.CardType.SPELL:
			kind = "Spell"
		CardEnums.CardType.TRAP:
			kind = "Trap"
		CardEnums.CardType.WONDER:
			kind = "Wonder"
	if data.is_token:
		kind = "Token " + kind
	if data.is_multipath():
		return "%s + %s  -  %s" % [UIStyle.affinity_name(data.color), UIStyle.affinity_name(data.color2), kind]
	return "%s  -  %s" % [UIStyle.affinity_name(data.color), kind]


func _build_rules() -> void:
	add_child(_panel(Rect2(12, 278, 276, 92), UIStyle.box(PARCHMENT_BG, Color("8f7d57"), 2, 8)))
	var rules: RichTextLabel = RichTextLabel.new()
	rules.bbcode_enabled = true
	rules.position = Vector2(20, 282)
	rules.size = Vector2(260, 84)
	rules.scroll_active = false
	rules.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rules.add_theme_color_override("default_color", PARCHMENT_TEXT)
	var size_px: int = 20 if data.rules_text.length() < 70 else 18
	for key: String in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		rules.add_theme_font_size_override(key, size_px)
	var text: String = KeywordInfo.rules_bbcode(data)
	var flavor_ok: bool = data.flavor_text != "" and data.rules_text.length() < 60
	if flavor_ok:
		text += "\n[i][color=#6b5b73]%s[/color][/i]" % data.flavor_text
	rules.text = text
	add_child(rules)


func _build_chips() -> void:
	var names: Array[String] = []
	for keyword: CardEnums.Keyword in data.keywords:
		names.append(KeywordInfo.keyword_name(keyword))
	if data.type == CardEnums.CardType.TRAP:
		names.append("Trap")
	if data.has_trigger(CardEnums.Trigger.ACTIVATED):
		names.append("Ability")
	if data.type != CardEnums.CardType.UNIT and data.type != CardEnums.CardType.TRAP:
		names.append(_type_text().split("-")[-1].strip_edges())
	if names.is_empty() and data.rules_text != "":
		names.append("Effect")
	var y: float = 318.0
	var x: float = 16.0
	for chip_text: String in names:
		var width: float = UIStyle.font_bold().get_string_size(chip_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 21).x + 22.0
		if x + width > 288.0:
			x = 16.0
			y += 34.0
		var chip: Panel = _panel(Rect2(x, y, width, 30), UIStyle.box(Color(0.05, 0.03, 0.08, 0.85), accent.lightened(0.15), 2, 15))
		add_child(chip)
		var label: Label = Label.new()
		label.text = chip_text
		label.position = Vector2(x, y)
		label.size = Vector2(width, 30)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", UIStyle.font_bold())
		label.add_theme_font_size_override("font_size", 21)
		label.add_theme_color_override("font_color", UIStyle.GOLD)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
		x += width + 6.0


func _build_plaque() -> void:
	if not data.is_unit():
		return
	var width: float = 92.0 if mode == Mode.FULL else 118.0
	var height: float = 48.0 if mode == Mode.FULL else 60.0
	_plaque = PanelContainer.new()
	_plaque.add_theme_stylebox_override("panel", UIStyle.box(Color("120d1a"), accent.lightened(0.2), 3, 14, 6))
	_plaque.position = Vector2(SIZE.x - width - 6.0, SIZE.y - height - 4.0) if mode == Mode.FULL else Vector2((SIZE.x - width) * 0.5, SIZE.y - height - 8.0)
	_plaque.size = Vector2(width, height)
	_plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plaque)
	_attack_label = Label.new()
	_attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_attack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_attack_label.add_theme_font_override("font", UIStyle.font_title())
	_attack_label.add_theme_font_size_override("font_size", 32 if mode == Mode.FULL else 40)
	_attack_label.add_theme_color_override("font_color", UIStyle.PARCHMENT)
	_attack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plaque.add_child(_attack_label)
	_set_stats(data.attack, data.defense, 0)


func _build_overlays() -> void:
	_tint_overlay = ColorRect.new()
	_tint_overlay.color = Color(0, 0, 0, 0)
	_tint_overlay.size = SIZE
	_tint_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tint_overlay)
	_badge_sick = Label.new()
	_badge_sick.text = "Zz"
	_badge_sick.position = Vector2(236, 90)
	_badge_sick.add_theme_font_override("font", UIStyle.font_bold())
	_badge_sick.add_theme_font_size_override("font_size", 34)
	_badge_sick.add_theme_color_override("font_color", Color("cfe6ff"))
	_badge_sick.add_theme_color_override("font_outline_color", Color("10203a"))
	_badge_sick.add_theme_constant_override("outline_size", 8)
	_badge_sick.visible = false
	_badge_sick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_badge_sick)
	_damage_label = Label.new()
	_damage_label.position = Vector2(20, 90)
	_damage_label.add_theme_font_override("font", UIStyle.font_title())
	_damage_label.add_theme_font_size_override("font_size", 40)
	_damage_label.add_theme_color_override("font_color", Color("ff6f6f"))
	_damage_label.add_theme_color_override("font_outline_color", Color("300808"))
	_damage_label.add_theme_constant_override("outline_size", 10)
	_damage_label.visible = false
	_damage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_damage_label)
	_glow = Control.new()
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.modulate.a = 0.0
	add_child(_glow)
	# Three border-only outlines, growing and fading, read as a soft glow.
	for ring: int in range(3):
		var grow: float = 3.0 + float(ring) * 5.0
		var outline: Panel = _panel(Rect2(Vector2(-grow, -grow), SIZE + Vector2(grow, grow) * 2.0), UIStyle.box(Color(1, 1, 1, 0), Color(1, 1, 1, 0), 4 if ring == 0 else 6, 20 + int(grow)))
		_glow.add_child(outline)
	if _glow_kind != Glow.NONE:
		set_glow.call_deferred(_glow_kind)


# ---- Live state (battle) ----------------------------------------------------------------


func _set_stats(attack: int, defense: int, damage: int) -> void:
	if _attack_label == null:
		return
	var shown_defense: int = defense - damage
	_attack_label.text = "%d/%d" % [attack, shown_defense]
	var color: Color = UIStyle.PARCHMENT
	if damage > 0 or defense < _base_defense:
		color = Color("ff8080")
	elif attack > _base_attack or defense > _base_defense:
		color = Color("9be49f")
	_attack_label.add_theme_color_override("font_color", color)


## Refreshes attack/defense/damage/exhausted/summoning-sick from the rules engine.
func apply_instance(instance: CardInstance, game: GameState) -> void:
	instance_uid = instance.uid
	if data == null or mode == Mode.BACK:
		return
	if data.is_unit():
		_set_stats(game.get_attack(instance), game.get_defense(instance), instance.damage)
	if _damage_label != null:
		_damage_label.visible = instance.damage > 0
		_damage_label.text = "-%d" % instance.damage
	if _badge_sick != null:
		_badge_sick.visible = instance.summoning_sick and data.is_unit() and not instance.exhausted and not instance.has_keyword(CardEnums.Keyword.HUSTLE)
	if _tint_overlay != null:
		_tint_overlay.color = Color(0.05, 0.05, 0.12, 0.45) if instance.exhausted else Color(0, 0, 0, 0)


func set_glow(kind: Glow) -> void:
	_glow_kind = kind
	if _glow == null:
		return
	if _glow_tween != null and _glow_tween.is_valid():
		_glow_tween.kill()
	var color: Color = Color(0, 0, 0, 0)
	match kind:
		Glow.PLAYABLE:
			color = Color("ffd76a")
		Glow.SELECTED:
			color = Color("ffffff")
		Glow.TARGET:
			color = Color("ff5a5a")
		Glow.ATTACK:
			color = Color("ff9c4a")
		Glow.BLOCK:
			color = Color("6ab8ff")
	if kind == Glow.NONE:
		_glow.modulate.a = 0.0
		return
	for ring: int in range(_glow.get_child_count()):
		var outline: Panel = _glow.get_child(ring) as Panel
		var style: StyleBoxFlat = outline.get_theme_stylebox("panel") as StyleBoxFlat
		style.border_color = Color(color, 1.0 if ring == 0 else 0.42 / float(ring))
	_glow.modulate.a = 1.0
	if kind == Glow.PLAYABLE or kind == Glow.TARGET:
		_glow_tween = create_tween().set_loops()
		_glow_tween.tween_property(_glow, "modulate:a", 0.45, 0.6).set_trans(Tween.TRANS_SINE)
		_glow_tween.tween_property(_glow, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)


# ---- Drawing helpers --------------------------------------------------------------------


class PipRow:
	extends Control
	var data: CardData

	func _draw() -> void:
		var x: float = size.x
		var pips: Array[Affinity.Type] = data.colored_pips
		# Right-aligned: colored pips first (from the right), generic on the left.
		for index: int in range(pips.size() - 1, -1, -1):
			x -= 32.0
			_pip(Vector2(x + 15.0, 15.0), UIStyle.affinity_color(pips[index]), "")
		if data.generic_cost > 0:
			x -= 32.0
			_pip(Vector2(x + 15.0, 15.0), Color("cdc5d6"), str(data.generic_cost))
		elif pips.is_empty():
			_pip(Vector2(size.x - 17.0, 15.0), Color("cdc5d6"), "0")

	func _pip(center: Vector2, color: Color, text: String) -> void:
		draw_circle(center + Vector2(0, 1.5), 14.0, Color(0, 0, 0, 0.45))
		draw_circle(center, 14.0, color.darkened(0.45))
		draw_circle(center, 12.0, color)
		draw_circle(center + Vector2(-3, -4), 4.5, Color(1, 1, 1, 0.35))
		if text != "":
			var font: Font = UIStyle.font_title()
			var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
			draw_string(font, center + Vector2(-text_size.x * 0.5, 7.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("1b1424"))


## Draws a shape that is distinct per rarity tier, not just a different color: a plain circle
## for Common, the original diamond for Uncommon, a hexagon for Epic and a four-point sparkle for
## Legendary (increasingly elaborate, so "how special is this card" reads at a glance).
class Gem:
	extends Control
	var color: Color = Color.WHITE
	var rarity: int = 0

	func _draw() -> void:
		var c: Vector2 = size * 0.5
		match rarity:
			CardEnums.Rarity.COMMON:
				draw_circle(c, 9.0, color.darkened(0.35))
				draw_circle(c, 6.5, color)
				draw_circle(c + Vector2(-2.0, -2.2), 1.8, color.lightened(0.5))
			CardEnums.Rarity.UNCOMMON:
				draw_colored_polygon(_diamond(c, 8.0), color.darkened(0.35))
				draw_colored_polygon(_diamond(c, 5.0), color)
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -6), c + Vector2(5, 0), c + Vector2(0, -1)]), color.lightened(0.4))
			CardEnums.Rarity.EPIC:
				draw_colored_polygon(_regular_polygon(c, 9.5, 6), color.darkened(0.35))
				draw_colored_polygon(_regular_polygon(c, 6.5, 6), color)
				draw_colored_polygon(PackedVector2Array([c + Vector2(-1, -6), c + Vector2(4, -3), c + Vector2(-1, 0)]), color.lightened(0.45))
			CardEnums.Rarity.LEGENDARY:
				draw_colored_polygon(_sparkle(c, 10.0, 4.0), color.darkened(0.3))
				draw_colored_polygon(_sparkle(c, 7.0, 2.6), color)
				draw_circle(c, 1.6, color.lightened(0.6))

	static func _diamond(center: Vector2, radius: float) -> PackedVector2Array:
		return PackedVector2Array([
			center + Vector2(0, -radius), center + Vector2(radius, 0),
			center + Vector2(0, radius), center + Vector2(-radius, 0),
		])

	static func _regular_polygon(center: Vector2, radius: float, sides: int) -> PackedVector2Array:
		var points: PackedVector2Array = PackedVector2Array()
		for i: int in range(sides):
			var a: float = deg_to_rad(-90.0 + 360.0 * float(i) / float(sides))
			points.append(center + Vector2(cos(a), sin(a)) * radius)
		return points

	## A classic four-point sparkle: alternating outer/inner radius over 8 vertices.
	static func _sparkle(center: Vector2, outer: float, inner: float) -> PackedVector2Array:
		var points: PackedVector2Array = PackedVector2Array()
		for i: int in range(8):
			var a: float = deg_to_rad(-90.0 + 45.0 * float(i))
			var r: float = outer if i % 2 == 0 else inner
			points.append(center + Vector2(cos(a), sin(a)) * r)
		return points


## Switches between the FULL, COMPACT and BACK looks and rebuilds the visuals.
func set_mode(new_mode: Mode) -> void:
	if mode == new_mode:
		return
	mode = new_mode
	if is_node_ready():
		_build()
