class_name CardView
extends Control
## One card on screen, full-art 2:3: the art fills the card (`CardArt`, or the placeholder: a game-icons silhouette on a
## gradient), a name/cost bar sits on top, a semi-transparent type line + rules panel covers the bottom third, with the
## attack/defense plaque and rarity gem. Three looks: FULL (hand, zoom, deckbuilder), COMPACT (field: the art cropped to its
## upper-middle, name bar and keyword chips only) and BACK (face-down / opponent hand).
## The card is laid out at 300x450; scale the node to draw it smaller or larger.

signal hovered(view: CardView)
signal unhovered(view: CardView)
signal gui_event(view: CardView, event: InputEvent)

enum Mode { FULL, COMPACT, BACK, COIN }

## Corner radius of the squarer tile a non-resource token (Contract) is drawn with.
const COIN_TOKEN_RADIUS: int = 60
## The cost pips never take more than this much of the name bar.
const MAX_PIPS_WIDTH: float = 130.0
## Smallest font a card name may be shrunk to before it wraps onto two lines instead.
const MIN_SINGLE_LINE_SIZE_FULL: int = 16
const MIN_SINGLE_LINE_SIZE_COMPACT: int = 20
const MIN_WRAPPED_SIZE_FULL: int = 11
const MIN_WRAPPED_SIZE_COMPACT: int = 14
enum Glow { NONE, PLAYABLE, SELECTED, TARGET, ATTACK, BLOCK }

const SIZE: Vector2 = Vector2(300, 450)
## Common, Uncommon, Epic, Legendary - see docs/design/combat_rules.md "Rarity". Colors AND gem
## shapes are distinct per tier (Gem below), so rarity reads at a glance even color-blind.
const RARITY_COLORS: Array[Color] = [Color("c9c2b4"), Color("5fd6a4"), Color("b48cf2"), Color("ff9c3a")]
const RARITY_NAMES: Array[String] = ["Common", "Uncommon", "Epic", "Legendary"]
const PARCHMENT_BG: Color = Color("eadfc4")
const PARCHMENT_TEXT: Color = Color("2b2233")

## The UI art kit frames (UiArt): by Path, and the card backs by the deck primary Path.
const PATH_FRAMES: Dictionary = {
	Affinity.Type.BEEFCAKE: "UI-FRAME-B",
	Affinity.Type.NECROCRAT: "UI-FRAME-N",
	Affinity.Type.GOURMAND: "UI-FRAME-G",
	Affinity.Type.REFUSEMANCER: "UI-FRAME-R",
	Affinity.Type.NEUTRAL: "UI-FRAME-C",
}
const PATH_BACKS: Dictionary = {
	Affinity.Type.BEEFCAKE: "UI-CARDBACK-B",
	Affinity.Type.NECROCRAT: "UI-CARDBACK-N",
	Affinity.Type.GOURMAND: "UI-CARDBACK-G",
	Affinity.Type.REFUSEMANCER: "UI-CARDBACK-R",
	Affinity.Type.NEUTRAL: "UI-CARDBACK-C",
}
const RARITY_GEMS: Array[String] = ["UI-RARITY-C", "UI-RARITY-U", "UI-RARITY-E", "UI-RARITY-L"]
## The cloth colours of the tinted frames (matching each Path own frame: Beefcake red, Necrocrat green, Gourmand cream-copper, Refusemancer rust-moss).
const FRAME_CLOTH: Dictionary = {
	Affinity.Type.BEEFCAKE: Color("d8392b"),
	Affinity.Type.NECROCRAT: Color("5f9a62"),
	Affinity.Type.GOURMAND: Color("e6a468"),
	Affinity.Type.REFUSEMANCER: Color("9aa832"),
}
## Frame order of the four bands: top-left, top-right, bottom-left, bottom-right.
const FRAME_PATH_ORDER: Array[Affinity.Type] = [Affinity.Type.BEEFCAKE, Affinity.Type.NECROCRAT, Affinity.Type.GOURMAND, Affinity.Type.REFUSEMANCER]
## Frame layout, in card units (the frame images are 2:3, laid out at 300x450 like the card; measured on the 1024x1536 originals):
## the art window, the name bar interior, the cost socket, the rarity gem on the left rail, the rules panel and the attack/defense sockets.
const FRAME_ART_RECT: Rect2 = Rect2(10, 11, 280, 428)
const FRAME_NAME_RECT: Rect2 = Rect2(84, 22, 162, 28)
const COMPACT_PLATE_RECT: Rect2 = Rect2(64, 4, 228, 52)
const COMPACT_NAME_RECT: Rect2 = Rect2(86, 10, 186, 38)
const FRAME_NAME_INK: Color = Color("2b2233")
const FRAME_COST_CENTER: Vector2 = Vector2(39, 34.5)
const FRAME_GEM_CENTER: Vector2 = Vector2(20.5, 166)
const FRAME_RULES_UNIT: Rect2 = Rect2(40, 312, 222, 68)
const FRAME_RULES_OTHER: Rect2 = Rect2(40, 312, 222, 80)
const FRAME_ATTACK_CENTER: Vector2 = Vector2(225.5, 392.5)
const FRAME_DEFENSE_CENTER: Vector2 = Vector2(265.0, 394.0)

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
var _defense_label: Label
var _framed: bool = false
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
	if mode == Mode.COIN:
		_build_coin()
		return
	_base_attack = data.attack
	_base_defense = data.defense
	_framed = UiArt.has(frame_id())
	if _framed:
		_build_framed()
		return
	var rarity: int = int(data.rarity)
	var border: Color = accent.darkened(0.15) if rarity == 0 else accent.darkened(0.15).lerp(RARITY_COLORS[rarity], 0.55)
	_frame = _panel(Rect2(Vector2.ZERO, SIZE), UIStyle.box(Color("1c1526"), border, 6 if rarity < 3 else 8, 14, 10))
	add_child(_frame)
	_build_art()
	if rarity >= 2:
		_build_foil(rarity)
	if dual:
		add_child(_panel(Rect2(Vector2(3, 3), SIZE - Vector2(6, 6)), UIStyle.box(Color(0, 0, 0, 0), accent2.darkened(0.1), 4, 11)))
	_build_name_bar()
	if mode == Mode.FULL:
		_build_type_line()
		_build_rules()
	else:
		_build_chips()
	_build_plaque()
	_build_overlays()


## A Resource coin on the table: a round coin (Path colour, glyph) drawn at the card's centre; scaled small it sits among the units.
## Non-resource tokens (the Contract) are drawn as a squarer parchment tile with a dashed-looking inner border so they never read as resources.
func _build_coin() -> void:
	var kind: int = data.resource_kind
	var is_token_tile: bool = not data.is_resource()
	var color: Color = ResourceKind.COLORS.get(kind, accent) as Color
	var diameter: float = 270.0
	var rect: Rect2 = Rect2((SIZE - Vector2(diameter, diameter)) * 0.5, Vector2(diameter, diameter))
	_frame = _panel(rect, UIStyle.box(color, Color(0.07, 0.05, 0.1), 18, COIN_TOKEN_RADIUS if is_token_tile else 135, 12))
	add_child(_frame)
	add_child(_panel(Rect2(rect.position + Vector2(26, 26), rect.size - Vector2(52, 52)), UIStyle.box(Color(0, 0, 0, 0), Color(1, 1, 1, 0.45), 8, 40 if is_token_tile else 110)))
	var art: Texture2D = CardArt.texture(data.id) if data.id != "" else null
	if art != null:
		var picture: TextureRect = TextureRect.new()
		picture.texture = art
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_SCALE
		picture.position = rect.position + Vector2(10, 10)
		picture.size = rect.size - Vector2(20, 20)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mask: ShaderMaterial = ShaderMaterial.new()
		mask.shader = load("res://ui/shaders/coin_art.gdshader") as Shader
		mask.set_shader_parameter("corner", 0.22 if is_token_tile else 0.5)
		picture.material = mask
		add_child(picture)
		_build_overlays()
		return
	var icon_key: String = str(CardIcons.RESOURCE_ICONS.get(ResourceKind.Kind.keys()[kind], "lorc/magic-swirl"))
	var glyph: TextureRect = CardIcons.glyph(CardIcons.named(icon_key), Color("1b1020"), Vector2(170, 170))
	glyph.position = rect.position + (rect.size - Vector2(170, 170)) * 0.5
	glyph.size = Vector2(170, 170)
	add_child(glyph)
	_build_overlays()


func _panel(rect: Rect2, style: StyleBox) -> Panel:
	var panel: Panel = Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _build_back() -> void:
	var back: Texture2D = UiArt.texture(back_id() if data != null else "UI-CARDBACK-C")
	if back != null:
		_build_back_framed(back)
		return
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
	var bar: Panel = _panel(Rect2(12, 12, 276, height), UIStyle.box(Color(accent.darkened(0.55), 0.9), accent.lightened(0.1), 2, 9))
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
	# Clip first: a Label that is not clipping has its text width as minimum size, which would stretch it over the pips.
	_name_label.clip_text = true
	_name_label.custom_minimum_size = Vector2.ZERO
	_name_label.text = _display_name()
	_name_label.position = Vector2(22, 12)
	_name_label.size = Vector2(276 - 20 - _pips_width() - 6, height)
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_override("font", UIStyle.font_title())
	_name_label.add_theme_color_override("font_color", UIStyle.PARCHMENT)
	_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_name_label.add_theme_constant_override("shadow_offset_y", 2)
	_name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fit_name(_name_label, 24 if mode == Mode.FULL else 25)
	_name_label.add_theme_constant_override("line_spacing", -6)
	add_child(_name_label)
	if not data.is_infrastructure():
		var pips: PipRow = PipRow.new()
		pips.data = data
		pips.step = _pip_step()
		pips.position = Vector2(288 - 8 - _pips_width(), 12 + (height - 30.0) * 0.5)
		pips.size = Vector2(_pips_width(), 30)
		pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(pips)


func _display_name() -> String:
	if data.is_infrastructure():
		return "%s Infrastructure" % UIStyle.affinity_name(data.color)
	return data.display_name


## Distance between cost pips: 32, tightened (the pips overlap a little) on 5+ pip costs so the name keeps room.
func _pip_step() -> float:
	var count: int = data.colored_pips.size() + (1 if data.generic_cost > 0 else 0)
	return minf(32.0, MAX_PIPS_WIDTH / float(maxi(count, 1)))


func _pips_width() -> float:
	if data.is_infrastructure():
		return 0.0
	var count: int = data.colored_pips.size() + (1 if data.generic_cost > 0 else 0)
	return maxf(30.0, count * _pip_step())


## Fits a card name into the space left of the cost pips: one line shrunk down to a floor size, otherwise wrapped lines shrunk
## until they fit the bar. A very long "Name, Epithet" falls back to just the name part (the full name is on the hover preview),
## and the label clips its contents, so a name can never touch the pips.
func _fit_name(label: Label, max_size: int) -> void:
	var available: float = label.size.x
	var max_height: float = label.size.y - 2.0
	var floor_size: int = _wrapped_floor()
	label.clip_contents = true
	var candidates: Array[String] = [label.text]
	if label.text.contains(","):
		candidates.append(label.text.get_slice(",", 0).strip_edges())
	for candidate: String in candidates:
		if _try_fit_name(label, candidate, max_size, floor_size, available, max_height):
			return
	label.text = candidates[candidates.size() - 1]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_font_size_override("font_size", floor_size)


## Smallest name sizes: the framed look has a narrower name bar (the compact look a bigger name plate over it).
func _single_floor() -> int:
	if _framed:
		return 14 if mode == Mode.FULL else 18
	return MIN_SINGLE_LINE_SIZE_FULL if mode == Mode.FULL else MIN_SINGLE_LINE_SIZE_COMPACT


func _wrapped_floor() -> int:
	if _framed:
		return 10 if mode == Mode.FULL else 13
	return MIN_WRAPPED_SIZE_FULL if mode == Mode.FULL else MIN_WRAPPED_SIZE_COMPACT


func _try_fit_name(label: Label, text: String, max_size: int, floor_size: int, available: float, max_height: float) -> bool:
	var font: Font = UIStyle.font_title()
	var single_floor: int = _single_floor()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	for size_try: int in range(max_size, single_floor - 1, -1):
		if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_try).x <= available:
			label.add_theme_font_size_override("font_size", size_try)
			return true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for size_try: int in range(max_size, floor_size - 1, -1):
		var wrapped: Vector2 = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, available, size_try, -1, TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE | TextServer.BREAK_MANDATORY)
		if wrapped.x <= available and wrapped.y <= max_height:
			label.add_theme_font_size_override("font_size", size_try)
			return true
	return false


## True when the (possibly shrunk, wrapped or shortened) name sits inside the space left of the cost pips (used by tests).
func name_fits() -> bool:
	if _name_label == null:
		return true
	var font: Font = UIStyle.font_title()
	var font_size: int = _name_label.get_theme_font_size("font_size")
	var wrap_width: float = _name_label.size.x if _name_label.autowrap_mode != TextServer.AUTOWRAP_OFF else -1.0
	var measured: Vector2 = font.get_multiline_string_size(_name_label.text, HORIZONTAL_ALIGNMENT_LEFT, wrap_width, font_size, -1, TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE | TextServer.BREAK_MANDATORY)
	return measured.x <= _name_label.size.x + 0.5 and measured.y <= _name_label.size.y


## The art area: the whole card inside the frame border. Real art (assets/art/cards/<id>.webp) when it exists, the placeholder otherwise.
## The area the art fills: inside the frame art window for the framed look, the whole card inside its border otherwise.
func art_rect() -> Rect2:
	if _framed:
		return FRAME_ART_RECT
	return Rect2(5, 5, SIZE.x - 10.0, SIZE.y - 10.0)


func _build_art() -> void:
	var rect: Rect2 = Rect2(5, 5, SIZE.x - 10.0, SIZE.y - 10.0)
	var art_texture: Texture2D = null
	if data.id != "":
		art_texture = CardArt.compact(data.id) if mode == Mode.COMPACT else CardArt.texture(data.id)
	if art_texture != null:
		var picture: TextureRect = TextureRect.new()
		picture.texture = art_texture
		# expand_mode first: with the default mode the minimum size is the texture's own (768x1152) and would clamp the size below.
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		picture.clip_contents = true
		picture.position = rect.position
		picture.size = rect.size
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(picture)
	else:
		_build_placeholder_art(rect)
	# A soft dark ramp under the rules panel keeps text readable over any art.
	var ramp: GradientTexture2D = GradientTexture2D.new()
	var shade: Gradient = Gradient.new()
	shade.set_color(0, Color(0, 0, 0, 0))
	shade.set_color(1, Color(0.04, 0.02, 0.07, 0.78))
	ramp.gradient = shade
	ramp.fill_from = Vector2(0.0, 0.0)
	ramp.fill_to = Vector2(0.0, 1.0)
	var scrim: TextureRect = TextureRect.new()
	scrim.texture = ramp
	scrim.position = Vector2(rect.position.x, SIZE.y - 190.0)
	scrim.size = Vector2(rect.size.x, 185.0)
	scrim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)
	add_child(_panel(rect, UIStyle.box(Color(0, 0, 0, 0), accent.lightened(0.2), 3, 10)))
	if dual:
		# Two Path gems in the art's corner: both Paths of this card at a glance.
		for index: int in range(2):
			var gem_color: Color = accent if index == 0 else accent2
			add_child(_panel(Rect2(22 + index * 26, 70, 22, 22), UIStyle.box(gem_color, Color("fdf3dc"), 2, 11, 4)))


## Placeholder art: the gradient with the card's icon silhouette, in the upper-middle of the frame (where the art's subject would sit).
## Epic and Legendary cards get a foil sheen across the art and a bright inner rim.
func _build_foil(rarity: int) -> void:
	var sheen: Gradient = Gradient.new()
	sheen.offsets = PackedFloat32Array([0.0, 0.42, 0.5, 0.58, 1.0])
	sheen.colors = PackedColorArray([Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.16 if rarity == 2 else 0.24), Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.0)])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = sheen
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 0.85)
	var rect: TextureRect = TextureRect.new()
	rect.texture = texture
	rect.position = Vector2(5, 5)
	rect.size = SIZE - Vector2(10, 10)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
	add_child(_panel(Rect2(Vector2(7, 7), SIZE - Vector2(14, 14)), UIStyle.box(Color(0, 0, 0, 0), Color(RARITY_COLORS[rarity], 0.85), 2, 10)))


func _build_placeholder_art(rect: Rect2) -> void:
	var art: ColorRect = ColorRect.new()
	art.position = rect.position
	art.size = rect.size
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://ui/shaders/card_art.gdshader") as Shader
	material.set_shader_parameter("top", accent.lightened(0.05))
	if dual:
		material.set_shader_parameter("bottom", accent2.darkened(0.45))
		material.set_shader_parameter("glow", accent2.lightened(0.5))
	else:
		material.set_shader_parameter("bottom", accent.darkened(0.7))
		material.set_shader_parameter("glow", accent.lightened(0.5))
	art.material = material
	add_child(art)
	var icon_size: float = rect.size.x * 0.66
	var top: float = 78.0 if mode == Mode.FULL else 90.0
	var texture: Texture2D = CardIcons.for_card(data)
	var shadow: TextureRect = CardIcons.glyph(texture, Color(0, 0, 0, 0.45), Vector2(icon_size, icon_size))
	shadow.position = Vector2((SIZE.x - icon_size) * 0.5 + 4, top + 6)
	shadow.size = Vector2(icon_size, icon_size)
	add_child(shadow)
	var icon: TextureRect = CardIcons.glyph(texture, Color("fdf3dc"), Vector2(icon_size, icon_size))
	icon.position = Vector2((SIZE.x - icon_size) * 0.5, top)
	icon.size = Vector2(icon_size, icon_size)
	add_child(icon)


func _build_type_line() -> void:
	var bar: Panel = _panel(Rect2(12, 292, 276, 28), UIStyle.box(Color(0.1, 0.07, 0.15, 0.78), Color(1, 1, 1, 0.1), 1, 7))
	add_child(bar)
	var label: Label = Label.new()
	label.text = _type_text()
	label.position = Vector2(22, 292)
	label.size = Vector2(220, 28)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", UIStyle.font_bold())
	label.add_theme_font_size_override("font_size", 16 if dual else 19)
	label.add_theme_color_override("font_color", UIStyle.PARCHMENT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	var rarity: Label = Label.new()
	rarity.text = RARITY_NAMES[int(data.rarity)]
	rarity.position = Vector2(20, 408)
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
	gem.position = Vector2(288 - 10 - 20, 296)
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
	add_child(_panel(Rect2(12, 324, 276, 78), UIStyle.box(Color(PARCHMENT_BG, 0.88), Color("8f7d57"), 2, 8)))
	var rules: RichTextLabel = RichTextLabel.new()
	rules.bbcode_enabled = true
	rules.position = Vector2(20, 327)
	rules.size = Vector2(260, 72)
	rules.scroll_active = false
	rules.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rules.add_theme_color_override("default_color", PARCHMENT_TEXT)
	var size_px: int = _rules_font_size()
	for key: String in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		rules.add_theme_font_size_override(key, size_px)
	var text: String = KeywordInfo.rules_bbcode(data)
	var flavor_ok: bool = data.flavor_text != "" and data.rules_text.length() < 40
	if flavor_ok:
		text += "\n[i][color=#6b5b73]%s[/color][/i]" % data.flavor_text
	rules.text = text
	add_child(rules)


## The biggest rules font (20 down to 11) whose wrapped text, with the flavor line when it is shown, fits the 260x72 panel.
func _rules_font_size() -> int:
	var plain: String = data.rules_text if data.rules_text != "" else (KeywordInfo.rules_bbcode(data) if data.is_infrastructure() else "")
	if data.flavor_text != "" and data.rules_text.length() < 40:
		plain += "
" + data.flavor_text
	var font: Font = UIStyle.font_bold()
	for candidate: int in range(20, 10, -1):
		var measured: Vector2 = font.get_multiline_string_size(plain, HORIZONTAL_ALIGNMENT_LEFT, 258.0, candidate)
		if measured.y <= 72.0:
			return candidate
	return 11


func _chip_names() -> Array[String]:
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
	return names


func _build_chips() -> void:
	var names: Array[String] = _chip_names()
	var y: float = 330.0
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
	var width: float = 88.0 if mode == Mode.FULL else 118.0
	var height: float = 40.0 if mode == Mode.FULL else 60.0
	_plaque = PanelContainer.new()
	_plaque.add_theme_stylebox_override("panel", UIStyle.box(Color("120d1a"), accent.lightened(0.2), 3, 14, 6))
	_plaque.position = Vector2(SIZE.x - width - 12.0, SIZE.y - height - 8.0) if mode == Mode.FULL else Vector2((SIZE.x - width) * 0.5, SIZE.y - height - 8.0)
	_plaque.size = Vector2(width, height)
	_plaque.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_plaque)
	_attack_label = Label.new()
	_attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_attack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_attack_label.add_theme_font_override("font", UIStyle.font_title())
	_attack_label.add_theme_font_size_override("font_size", 28 if mode == Mode.FULL else 40)
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
		var base: Rect2 = Rect2(Vector2(15, 90), Vector2(270, 270)) if mode == Mode.COIN else Rect2(Vector2.ZERO, SIZE)
		var outline: Panel = _panel(Rect2(base.position - Vector2(grow, grow), base.size + Vector2(grow, grow) * 2.0), UIStyle.box(Color(1, 1, 1, 0), Color(1, 1, 1, 0), 4 if ring == 0 else 6, ((COIN_TOKEN_RADIUS if (data != null and not data.is_resource()) else 135) if mode == Mode.COIN else 20) + int(grow)))
		_glow.add_child(outline)
	if _glow_kind != Glow.NONE:
		set_glow.call_deferred(_glow_kind)


# ---- Framed look (the UI art kit card frames, docs/art/ui_art_kit.md) -------------------------


## The frame overlay of this card: the Path frame, the multi-Path frame, Infrastructure, or Token ("" for a card with no data).
func frame_id() -> String:
	if data == null:
		return ""
	if data.is_token:
		return "UI-FRAME-TOKEN"
	if data.is_infrastructure():
		return "UI-FRAME-INF"
	if data.is_multipath():
		return "UI-FRAME-MULTI"
	return str(PATH_FRAMES.get(data.color, "UI-FRAME-C"))


## The face-down image: the Path back for the human's own cards, the default back for opponents, colourless and mixed decks.
func back_id() -> String:
	if bool(get_meta("opponent_back", false)):
		return "UI-CARDBACK-C"
	return player_back_id()


## The back of the player's primary Path (the default back when there is none).
static func player_back_id() -> String:
	return str(PATH_BACKS.get(player_back_path(), "UI-CARDBACK-C"))


## The primary Path of the player deck (its card backs); NEUTRAL when there is no profile.
static func player_back_path() -> Affinity.Type:
	var loop: SceneTree = Engine.get_main_loop() as SceneTree
	if loop == null:
		return Affinity.Type.NEUTRAL
	var session: Node = loop.root.get_node_or_null("Session")
	if session == null or session.get("profile") == null:
		return Affinity.Type.NEUTRAL
	return (session.get("profile") as PlayerProfile).primary_affinity


## The Path colours the cloth of a tinted frame takes (Beefcake red, Necrocrat green, Gourmand cream-copper, Refusemancer rust-moss).
static func frame_cloth_color(path: Affinity.Type) -> Color:
	return FRAME_CLOTH.get(path, Color("a09070")) as Color


func _build_back_framed(back: Texture2D) -> void:
	var picture: TextureRect = TextureRect.new()
	picture.texture = back
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_SCALE
	picture.size = SIZE
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(picture)


func _build_framed() -> void:
	_build_framed_art()
	var rarity: int = int(data.rarity)
	if rarity >= 2:
		_build_framed_foil(rarity)
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.texture = UiArt.texture(frame_id())
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.size = SIZE
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_frame_tint(texture_rect)
	add_child(texture_rect)
	_build_framed_name()
	_build_framed_cost()
	_build_framed_gem()
	if mode == Mode.FULL:
		_build_framed_type_line()
		_build_framed_rules()
	else:
		_build_framed_chips()
	_build_framed_stats()
	_build_overlays()


## Multi-Path, Infrastructure and Token frames take the card Path colours on their cloth.
func _apply_frame_tint(texture_rect: TextureRect) -> void:
	var paths: Array[Affinity.Type] = data.paths()
	if paths.is_empty() and data.is_infrastructure() and data.produces_any:
		paths = Affinity.colored_types()
	var id: String = frame_id()
	if paths.is_empty() or not (id == "UI-FRAME-MULTI" or id == "UI-FRAME-INF" or id == "UI-FRAME-TOKEN"):
		return
	var ordered: Array[Affinity.Type] = []
	for path: Affinity.Type in FRAME_PATH_ORDER:
		if paths.has(path):
			ordered.append(path)
	if ordered.is_empty():
		return
	var corners: Array[Color] = frame_corner_colors(ordered)
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load("res://ui/shaders/frame_tint.gdshader") as Shader
	material.set_shader_parameter("top_left", corners[0])
	material.set_shader_parameter("top_right", corners[1])
	material.set_shader_parameter("bottom_left", corners[2])
	material.set_shader_parameter("bottom_right", corners[3])
	material.set_shader_parameter("cream_cloth", 1.0 if id == "UI-FRAME-MULTI" else 0.0)
	texture_rect.material = material


## The four corner colours (top-left, top-right, bottom-left, bottom-right) for a card Paths in frame order (B, N, G, R): one Path colours the whole
## frame, two split it left/right, three and four give each corner its own band.
static func frame_corner_colors(ordered: Array[Affinity.Type]) -> Array[Color]:
	var colors: Array[Color] = []
	for path: Affinity.Type in ordered:
		colors.append(frame_cloth_color(path))
	var result: Array[Color] = []
	match colors.size():
		1:
			result = [colors[0], colors[0], colors[0], colors[0]]
		2:
			result = [colors[0], colors[1], colors[0], colors[1]]
		3:
			result = [colors[0], colors[1], colors[2], colors[1]]
		_:
			result = [colors[0], colors[1], colors[2], colors[3]]
	return result


func _build_framed_art() -> void:
	var rect: Rect2 = FRAME_ART_RECT
	add_child(_panel(rect, UIStyle.box(Color("1c1526"), Color(0, 0, 0, 0), 0, 10)))
	var art_texture: Texture2D = null
	if data.id != "":
		art_texture = CardArt.compact(data.id) if mode == Mode.COMPACT else CardArt.texture(data.id)
	if art_texture != null:
		var picture: TextureRect = TextureRect.new()
		picture.texture = art_texture
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		picture.clip_contents = true
		picture.position = rect.position
		picture.size = rect.size
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(picture)
	else:
		_build_placeholder_art(rect)
	# A soft dark ramp under the rules panel keeps text readable over any art.
	var ramp: GradientTexture2D = GradientTexture2D.new()
	var shade: Gradient = Gradient.new()
	shade.set_color(0, Color(0, 0, 0, 0))
	shade.set_color(1, Color(0.04, 0.02, 0.07, 0.7))
	ramp.gradient = shade
	ramp.fill_from = Vector2(0.0, 0.0)
	ramp.fill_to = Vector2(0.0, 1.0)
	var scrim: TextureRect = TextureRect.new()
	scrim.texture = ramp
	scrim.position = Vector2(rect.position.x, 270.0)
	scrim.size = Vector2(rect.size.x, rect.end.y - 270.0)
	scrim.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)


func _build_framed_foil(rarity: int) -> void:
	var sheen: Gradient = Gradient.new()
	sheen.offsets = PackedFloat32Array([0.0, 0.42, 0.5, 0.58, 1.0])
	sheen.colors = PackedColorArray([Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.16 if rarity == 2 else 0.24), Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.0)])
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = sheen
	texture.fill_from = Vector2(0.0, 0.0)
	texture.fill_to = Vector2(1.0, 0.85)
	var rect: TextureRect = TextureRect.new()
	rect.texture = texture
	rect.position = FRAME_ART_RECT.position
	rect.size = FRAME_ART_RECT.size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)


func _build_framed_name() -> void:
	var rect: Rect2 = FRAME_NAME_RECT
	var plate: Texture2D = UiArt.texture("UI-NAMEPLATE") if mode == Mode.COMPACT else null
	if plate != null:
		var plate_rect: TextureRect = TextureRect.new()
		plate_rect.texture = plate
		plate_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		plate_rect.stretch_mode = TextureRect.STRETCH_SCALE
		plate_rect.position = COMPACT_PLATE_RECT.position
		plate_rect.size = COMPACT_PLATE_RECT.size
		plate_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(plate_rect)
		rect = COMPACT_NAME_RECT
	_name_label = Label.new()
	_name_label.clip_text = true
	_name_label.custom_minimum_size = Vector2.ZERO
	_name_label.text = _display_name()
	_name_label.position = rect.position
	_name_label.size = rect.size
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_override("font", UIStyle.font_title())
	_name_label.add_theme_color_override("font_color", FRAME_NAME_INK)
	_name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fit_name(_name_label, 22 if mode == Mode.FULL else 26)
	_name_label.add_theme_constant_override("line_spacing", -6)
	add_child(_name_label)


## The cost socket: the card total energy as a number; the coloured pips it needs sit just below it. Infrastructure shows its Path colour.
func _build_framed_cost() -> void:
	if data.is_infrastructure():
		var path_colour: Color = UIStyle.affinity_color(data.color) if not data.produces_any else Color("e8d9b0")
		add_child(_framed_pip_dot(FRAME_COST_CENTER, 11.0, path_colour))
		return
	if data.is_token and data.energy_value() == 0:
		return
	var label: Label = Label.new()
	label.text = str(data.energy_value())
	label.position = FRAME_COST_CENTER - Vector2(22, 22)
	label.size = Vector2(44, 44)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", UIStyle.font_title())
	label.add_theme_font_size_override("font_size", 28 if label.text.length() < 2 else 22)
	label.add_theme_color_override("font_color", Color("ffffff"))
	label.add_theme_color_override("font_outline_color", Color("1b1020"))
	label.add_theme_constant_override("outline_size", 7)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	var pips: Array[Affinity.Type] = data.colored_pips
	var step: float = minf(19.0, 150.0 / float(maxi(pips.size(), 1)))
	for index: int in range(pips.size()):
		add_child(_framed_pip_dot(Vector2(40.0 + step * float(index), 70.0), 8.5, UIStyle.affinity_color(pips[index])))


func _framed_pip_dot(center: Vector2, radius: float, color: Color) -> Control:
	var dot: FramePip = FramePip.new()
	dot.color = color
	dot.radius = radius
	dot.position = center - Vector2(radius + 2.0, radius + 2.0)
	dot.size = Vector2(radius + 2.0, radius + 2.0) * 2.0
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return dot


## The rarity gem set into the left rail of the frame (the diamond ornament; every frame has one there).
func _build_framed_gem() -> void:
	var gem_texture: Texture2D = UiArt.texture(RARITY_GEMS[clampi(int(data.rarity), 0, 3)])
	if gem_texture == null:
		return
	var gem: TextureRect = TextureRect.new()
	gem.texture = gem_texture
	gem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var gem_size: float = 31.0 if int(data.rarity) < 3 else 35.0
	gem.size = Vector2(gem_size, gem_size)
	gem.position = FRAME_GEM_CENTER - gem.size * 0.5
	gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(gem)


func _build_framed_type_line() -> void:
	var label: Label = Label.new()
	label.text = _type_text()
	label.position = Vector2(38, 293)
	label.size = Vector2(224, 17)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.add_theme_font_override("font", UIStyle.font_bold())
	var type_size: int = 15
	while type_size > 10 and UIStyle.font_bold().get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, type_size).x > label.size.x:
		type_size -= 1
	label.add_theme_font_size_override("font_size", type_size)
	label.add_theme_color_override("font_color", UIStyle.GOLD)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)


## The rules panel of the frame: light text on its dark panel; units leave the lower-right corner to the attack/defense sockets.
func _build_framed_rules() -> void:
	var rect: Rect2 = _framed_rules_rect()
	var rules: RichTextLabel = RichTextLabel.new()
	rules.bbcode_enabled = true
	rules.position = rect.position
	rules.size = rect.size
	rules.scroll_active = false
	rules.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rules.add_theme_color_override("default_color", UIStyle.PARCHMENT)
	var size_px: int = _rules_font_size_for(rect)
	for key: String in ["normal_font_size", "bold_font_size", "italics_font_size", "bold_italics_font_size"]:
		rules.add_theme_font_size_override(key, size_px)
	var text: String = KeywordInfo.rules_bbcode(data, true)
	if _shows_flavor():
		text += "\n[i][color=#b9a9c4]%s[/color][/i]" % data.flavor_text
	rules.text = text
	add_child(rules)


func _framed_rules_rect() -> Rect2:
	return FRAME_RULES_UNIT if data.is_unit() else FRAME_RULES_OTHER


func _shows_flavor() -> bool:
	return data.flavor_text != "" and data.rules_text.length() < 40


func _rules_font_size_for(rect: Rect2) -> int:
	var plain: String = data.rules_text if data.rules_text != "" else (KeywordInfo.rules_bbcode(data) if data.is_infrastructure() else "")
	if _shows_flavor():
		plain += "\n" + data.flavor_text
	var font: Font = UIStyle.font_bold()
	for candidate: int in range(20, 10, -1):
		var measured: Vector2 = font.get_multiline_string_size(plain, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 2.0, candidate)
		if measured.y <= rect.size.y:
			return candidate
	return 11


## Compact look: keyword chips in the rules panel.
func _build_framed_chips() -> void:
	var names: Array[String] = _chip_names()
	var y: float = 304.0
	var x: float = 40.0
	for chip_text: String in names:
		var width: float = UIStyle.font_bold().get_string_size(chip_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x + 18.0
		if x + width > 262.0:
			x = 40.0
			y += 31.0
		var chip: Panel = _panel(Rect2(x, y, width, 28), UIStyle.box(Color(0.05, 0.03, 0.08, 0.85), accent.lightened(0.15), 2, 14))
		add_child(chip)
		var label: Label = Label.new()
		label.text = chip_text
		label.position = Vector2(x, y)
		label.size = Vector2(width, 28)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", UIStyle.font_bold())
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", UIStyle.GOLD)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
		x += width + 5.0


## Attack and defense numbers in the frame own sockets (circle = attack, shield = defense). The compact look puts the stat plaque over them, bigger.
func _build_framed_stats() -> void:
	if not data.is_unit():
		return
	var attack_center: Vector2 = FRAME_ATTACK_CENTER
	var defense_center: Vector2 = FRAME_DEFENSE_CENTER
	var font_size: int = 25
	if mode == Mode.COMPACT:
		var plaque: Texture2D = UiArt.texture("UI-STAT-PLAQUE")
		var plaque_size: Vector2 = Vector2(136, 48)
		var center: Vector2 = Vector2(228, 391)
		if plaque != null:
			var rect: TextureRect = TextureRect.new()
			rect.texture = plaque
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			rect.stretch_mode = TextureRect.STRETCH_SCALE
			rect.size = plaque_size
			rect.position = center - plaque_size * 0.5
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(rect)
		attack_center = center + Vector2(-31, 0)
		defense_center = center + Vector2(31, 0)
		font_size = 34
	_attack_label = _stat_label(attack_center, font_size)
	_defense_label = _stat_label(defense_center, font_size)
	_set_stats(data.attack, data.defense, 0)


func _stat_label(center: Vector2, font_size: int) -> Label:
	var label: Label = Label.new()
	label.size = Vector2(40, 36)
	label.position = center - label.size * 0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", UIStyle.font_title())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("ffffff"))
	label.add_theme_color_override("font_outline_color", Color("1b1020"))
	label.add_theme_constant_override("outline_size", 7)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


## A round cost pip, drawn for the coloured requirements under the cost socket.
class FramePip:
	extends Control
	var color: Color = Color.WHITE
	var radius: float = 8.0

	func _draw() -> void:
		var center: Vector2 = size * 0.5
		draw_circle(center + Vector2(0, 1.2), radius + 1.5, Color(0, 0, 0, 0.5))
		draw_circle(center, radius + 1.0, color.darkened(0.55))
		draw_circle(center, radius - 0.5, color)
		draw_circle(center + Vector2(-radius * 0.28, -radius * 0.32), radius * 0.32, Color(1, 1, 1, 0.4))


# ---- Live state (battle) ----------------------------------------------------------------


func _set_stats(attack: int, defense: int, damage: int) -> void:
	if _attack_label == null:
		return
	var shown_defense: int = defense - damage
	var attack_color: Color = Color("ffffff") if _framed else UIStyle.PARCHMENT
	var defense_color: Color = attack_color
	if damage > 0 or defense < _base_defense:
		defense_color = Color("ff8080")
	elif defense > _base_defense:
		defense_color = Color("9be49f")
	if attack > _base_attack:
		attack_color = Color("9be49f")
	if _defense_label != null:
		_attack_label.text = str(attack)
		_defense_label.text = str(shown_defense)
		_attack_label.add_theme_color_override("font_color", attack_color)
		_defense_label.add_theme_color_override("font_color", defense_color)
		return
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
	var step: float = 32.0

	func _draw() -> void:
		var x: float = size.x
		var pips: Array[Affinity.Type] = data.colored_pips
		# Right-aligned: colored pips first (from the right), generic on the left.
		for index: int in range(pips.size() - 1, -1, -1):
			x -= step
			_pip(Vector2(x + 15.0, 15.0), UIStyle.affinity_color(pips[index]), "")
		if data.generic_cost > 0:
			x -= step
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
