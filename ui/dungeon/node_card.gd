class_name NodeCard
extends Control
## Fable Nov 12c (Part B): the illustrated card every non-combat dungeon pop-up is built on - the healing shrine, the Hollow Well, events,
## rescues, treasure, deck challenges and the "Before the fight" rules panel. It replaces the flat purple box with a small cyan glyph.
##
## A two-part card inside the game's ornate gold frame:
## - an illustration BANNER across the top, made from art the game already has: the dungeon's own painted map, cropped round this room and
##   blurred (or the optional generic `UI-NODE-BANNER` painting when it exists), under a soft colour wash per kind and a vignette; the
##   room kind's large icon in the middle with a glow and a gentle bob (or the foe's picture, for the pre-fight panel); drifting particles
##   that fit the kind (motes for a shrine, mist for a well, sparkles for treasure, embers before a fight);
## - a vellum BODY: the kind in small caps over the name, the flavour line in italics, what it does mechanically as icon rows, the outcome
##   preview (`HpPreview`: the heal as a ghost segment and "HP 9 → 15"), cost chips, then the choices as buttons with icons.
##
## Motion: the card scales and fades in over a quarter of a second and the banner a beat later; `heal_shimmer` and `swallow` are the
## confirm effects. All of it is still under Reduce motion. Esc / the pad's B press `back_button` (where leaving is allowed).
## Text follows the dialogue text size setting. The screens (ShrineScreen, ChallengeScreen, EventScreen, TreasureScreen, RulesBrief) keep
## their rules and only build on this.

enum Kind { SHRINE, WELL, EVENT, TREASURE, RESCUE, CHALLENGE, FIGHT }

const KIND_LABEL: Array[String] = ["Shrine", "Well", "Event", "Treasure", "Rescue", "Challenge", "Before the fight"]
const KIND_ICON: Array[String] = ["ICON-NODE-HEAL", "ICON-NODE-CHALLENGE", "ICON-NODE-EVENT", "ICON-NODE-TREASURE", "ICON-NODE-RESCUE", "ICON-NODE-CHALLENGE", "ICON-NODE-BATTLE"]
## The colour wash over the banner and the glow behind the icon.
const KIND_WASH: Array[Color] = [Color("3fc1b4"), Color("4f8fd6"), Color("c98a3e"), Color("e0b040"), Color("d9735e"), Color("8f62d0"), Color("c2473d")]
const KIND_PARTICLES: Array[String] = ["motes", "mist", "dust", "sparkles", "embers", "motes", "embers"]

const BANNER_ART_ID: String = "UI-NODE-BANNER"
const BANNER_HEIGHT: float = 236.0
const DEFAULT_WIDTH: float = 900.0
## The vellum body's colours (dark ink on warm paper, like a card's rules box).
const VELLUM: Color = Color("efe2c3")
const VELLUM_EDGE: Color = Color("b89a5e")
const INK: Color = Color("2c2233")
const INK_SOFT: Color = Color("5f5266")
const GOLD_INK: Color = Color("8a5a12")
const GOOD_INK: Color = Color("2f7a43")
const BAD_INK: Color = Color("a8402e")
const OPEN_TIME: float = 0.25

const _BANNER_SHADER: String = """
shader_type canvas_item;
uniform sampler2D art : filter_linear, repeat_disable;
uniform bool has_art = false;
uniform vec2 center = vec2(0.5, 0.5);
uniform vec2 span = vec2(0.46, 0.2);
uniform float blur = 0.011;
uniform vec4 wash : source_color = vec4(0.25, 0.75, 0.7, 1.0);
uniform float wash_amount = 0.42;
uniform float vignette = 0.66;
uniform float reveal = 1.0;
void fragment() {
	vec3 base;
	if (has_art) {
		vec2 uv = center + (UV - vec2(0.5)) * span;
		vec3 sum = texture(art, clamp(uv, vec2(0.002), vec2(0.998))).rgb * 1.5;
		float total = 1.5;
		for (int ring = 0; ring < 3; ring++) {
			float r = blur * float(ring + 1) / 3.0;
			for (int step = 0; step < 8; step++) {
				float a = 6.2831853 * (float(step) + 0.5 * float(ring)) / 8.0;
				float w = 1.0 - float(ring) * 0.25;
				sum += texture(art, clamp(uv + vec2(cos(a) * span.x, sin(a) * span.y * 3.0) * r * 2.0, vec2(0.002), vec2(0.998))).rgb * w;
				total += w;
			}
		}
		base = sum / total;
	} else {
		base = mix(wash.rgb * 0.34, wash.rgb * 0.12, UV.y) + vec3(0.03, 0.02, 0.05);
	}
	float lum = dot(base, vec3(0.299, 0.587, 0.114));
	// the wash: the picture keeps its lights and darks and leans to the kind's colour
	vec3 tinted = mix(vec3(lum), wash.rgb, 0.62) * (0.45 + lum * 1.05);
	vec3 colour = mix(base, tinted, wash_amount);
	// a pool of light where the icon sits, darker toward the corners and the title's edge
	vec2 d = (UV - vec2(0.5, 0.46)) * vec2(1.0, 1.9);
	float v = smoothstep(0.18, 0.86, length(d));
	colour *= 1.0 - vignette * v;
	colour += wash.rgb * 0.16 * (1.0 - smoothstep(0.0, 0.42, length(d)));
	colour *= mix(0.72, 1.0, smoothstep(1.0, 0.72, UV.y));
	COLOR = vec4(colour * reveal, 1.0);
}
"""

static var _banner_shader: Shader = null
static var _soft_dot: Texture2D = null
static var _glow: Texture2D = null

var kind: Kind = Kind.EVENT
var card_width: float = DEFAULT_WIDTH
## The banner's height: `BANNER_HEIGHT`, less for a card with a long body (a pre-fight panel with many rules) so it still fits the screen.
var banner_height: float = BANNER_HEIGHT
## What the screens fill: the body's content column and the button row under it.
var content: VBoxContainer
var buttons: HBoxContainer
## Pressed by Esc / the pad's B (null = Esc does nothing here).
var back_button: BaseButton = null
var frame: PanelContainer
var banner: Control
var icon: TextureRect
var title_label: Label
var kicker_label: Label
var _title: String = ""
var _kicker: String = ""
var _art: ColorRect
var _glow_rect: TextureRect
var _particles: CPUParticles2D
var _chips: HFlowContainer
var _age: float = 0.0
var _hp: HpPreview = null
var _bob: Tween = null
var _fitted_height: float = -1.0


static func make(card_kind: Kind, title: String, width: float = DEFAULT_WIDTH, kicker: String = "", banner_h: float = BANNER_HEIGHT) -> NodeCard:
	var card: NodeCard = NodeCard.new()
	card.name = "NodeCard"
	card.kind = card_kind
	card.card_width = width
	card.banner_height = banner_h
	card._title = title
	card._kicker = kicker if not kicker.is_empty() else KIND_LABEL[int(card_kind)]
	card._build()
	return card


## Body text sizes follow the dialogue text size setting (Settings > Accessibility).
static func text_px(base: int) -> int:
	var settings: Node = Engine.get_main_loop().root.get_node_or_null("Settings") if Engine.get_main_loop() is SceneTree else null
	var scale: float = float(settings.call("dialogue_text_scale")) if settings != null and settings.has_method("dialogue_text_scale") else 1.0
	return maxi(12, int(round(float(base) * scale)))


static func still() -> bool:
	return Settings.reduce_motion


static func wash_of(card_kind: Kind) -> Color:
	return KIND_WASH[int(card_kind)]


func _build() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.name = "Shade"
	shade.color = Color(0.02, 0.01, 0.05, 0.84)
	UIKit.full_rect(shade)
	add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	center.name = "Center"
	UIKit.full_rect(center)
	add_child(center)
	frame = UIKit.panel()
	frame.name = "Frame"
	frame.custom_minimum_size = Vector2(card_width, 0)
	center.add_child(frame)
	var column: VBoxContainer = UIKit.vbox(0)
	column.name = "Column"
	frame.add_child(column)
	_build_banner(column)
	var edge: ColorRect = ColorRect.new()
	edge.name = "BannerEdge"
	edge.color = Color("d9a84a")
	edge.custom_minimum_size = Vector2(0, 3)
	edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(edge)
	var body: PanelContainer = PanelContainer.new()
	body.name = "Body"
	var vellum: StyleBoxFlat = StyleBoxFlat.new()
	vellum.bg_color = VELLUM
	vellum.border_color = VELLUM_EDGE
	vellum.set_border_width_all(2)
	vellum.border_width_top = 0
	vellum.set_corner_radius_all(0)
	vellum.corner_radius_bottom_left = 8
	vellum.corner_radius_bottom_right = 8
	vellum.shadow_color = Color(0.25, 0.18, 0.05, 0.25)
	vellum.shadow_size = 0
	vellum.content_margin_left = 40.0
	vellum.content_margin_right = 40.0
	vellum.content_margin_top = 18.0
	vellum.content_margin_bottom = 24.0
	body.add_theme_stylebox_override("panel", vellum)
	column.add_child(body)
	var inner: VBoxContainer = UIKit.vbox(12)
	inner.name = "BodyColumn"
	body.add_child(inner)
	inner.add_child(_title_plate())
	content = UIKit.vbox(10)
	content.name = "Content"
	inner.add_child(content)
	_chips = HFlowContainer.new()
	_chips.name = "Chips"
	_chips.alignment = FlowContainer.ALIGNMENT_CENTER
	_chips.add_theme_constant_override("h_separation", 10)
	_chips.add_theme_constant_override("v_separation", 6)
	_chips.visible = false
	inner.add_child(_chips)
	buttons = UIKit.hbox(18)
	buttons.name = "Buttons"
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.add_child(UIKit.spacer(2))
	inner.add_child(buttons)


func _ready() -> void:
	PadFocus.register(self)
	# the card scales and fades in over a quarter of a second, the banner's picture a beat later
	if still():
		_set_reveal(1.0)
		return
	frame.pivot_offset = Vector2(card_width * 0.5, 240.0)
	frame.scale = Vector2(0.93, 0.93)
	frame.modulate.a = 0.0
	_set_reveal(0.0)
	var opening: Tween = create_tween().set_parallel(true)
	opening.tween_property(frame, "scale", Vector2.ONE, OPEN_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	opening.tween_property(frame, "modulate:a", 1.0, OPEN_TIME * 0.8)
	opening.tween_method(_set_reveal, 0.0, 1.0, 0.32).set_delay(0.14)
	if icon != null:
		icon.modulate.a = 0.0
		opening.tween_property(icon, "modulate:a", 1.0, 0.25).set_delay(0.2)
		_start_bob()
	if _glow_rect != null:
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(_glow_rect, "modulate:a", 0.95, 1.3).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(_glow_rect, "modulate:a", 0.6, 1.3).set_trans(Tween.TRANS_SINE)


func _start_bob() -> void:
	if _bob != null and _bob.is_valid():
		_bob.kill()
	if icon == null or still():
		return
	_bob = create_tween().set_loops()
	var rest: float = icon.position.y
	_bob.tween_property(icon, "position:y", rest - 6.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bob.tween_property(icon, "position:y", rest + 2.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _process(delta: float) -> void:
	_age += delta
	if frame != null and not is_equal_approx(frame.size.y, _fitted_height):
		_fitted_height = frame.size.y
		_fit_to_screen()


## A card taller than the screen (many rules, Large text, a result with a card in it) gives up banner height until it fits: the body is
## what must be read. The banner never goes under MIN_BANNER.
const SCREEN_ROOM: float = 1052.0
const MIN_BANNER: float = 104.0


func _fit_to_screen() -> void:
	var over: float = frame.size.y - SCREEN_ROOM
	if over <= 1.0 or banner == null or banner.custom_minimum_size.y <= MIN_BANNER:
		return
	banner_height = maxf(MIN_BANNER, banner.custom_minimum_size.y - over)
	banner.custom_minimum_size.y = banner_height
	var middle: float = (card_width - 8.0) * 0.5
	for piece: Control in [icon, _glow_rect]:
		if piece == null or not is_instance_valid(piece) or piece.size.y <= 0.0:
			continue
		var room: float = banner_height - (16.0 if piece == icon else -60.0)
		var px: float = minf(piece.size.y, room)
		piece.size = Vector2(px * piece.size.x / piece.size.y, px)
		piece.position = Vector2(middle - piece.size.x * 0.5, banner_height * 0.5 - px * 0.5)
	if _particles != null:
		_particles.position.y = banner_height * 0.5
		_particles.emission_rect_extents.y = banner_height * 0.5
	_start_bob()


func _unhandled_input(event: InputEvent) -> void:
	if _age < ConfirmKey.GUARD_TIME or back_button == null or not is_instance_valid(back_button) or back_button.disabled or not back_button.is_visible_in_tree():
		return
	if UiInput.is_back(event):
		get_viewport().set_input_as_handled()
		back_button.pressed.emit()


func _set_reveal(amount: float) -> void:
	if _art != null and _art.material is ShaderMaterial:
		(_art.material as ShaderMaterial).set_shader_parameter("reveal", amount)


# ---- The banner ---------------------------------------------------------------------------------------------------------------


func _build_banner(column: VBoxContainer) -> void:
	banner = Control.new()
	banner.name = "Banner"
	banner.clip_contents = true
	banner.custom_minimum_size = Vector2(card_width - 8.0, banner_height)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(banner)
	_art = ColorRect.new()
	_art.name = "BannerArt"
	UIKit.full_rect(_art)
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _banner_shader == null:
		_banner_shader = Shader.new()
		_banner_shader.code = _BANNER_SHADER
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = _banner_shader
	material.set_shader_parameter("wash", wash_of(kind))
	_art.material = material
	banner.add_child(_art)
	# the optional generic painting (a dungeon alcove) is the base under every wash when the owner has provided it
	if UiArt.has(BANNER_ART_ID):
		set_banner_art(UiArt.texture(BANNER_ART_ID), Vector2(0.5, 0.5), Vector2(1.0, 1.0), 0.0)
	_particles = _make_particles(KIND_PARTICLES[int(kind)])
	if _particles != null:
		banner.add_child(_particles)
	_glow_rect = TextureRect.new()
	_glow_rect.name = "IconGlow"
	_glow_rect.texture = _glow_texture()
	_glow_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_glow_rect.size = Vector2(330, 330)
	_glow_rect.position = Vector2((card_width - 8.0) * 0.5 - 165.0, banner_height * 0.5 - 165.0 - 6.0)
	_glow_rect.modulate = Color(wash_of(kind).lightened(0.35), 0.8)
	_glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glow_rect.material = additive
	banner.add_child(_glow_rect)
	icon = TextureRect.new()
	icon.name = "KindIcon"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_px: float = minf(168.0, banner_height - 52.0)
	icon.size = Vector2(icon_px, icon_px)
	icon.position = Vector2((card_width - 8.0) * 0.5 - icon_px * 0.5, banner_height * 0.5 - icon_px * 0.5 - 4.0)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(icon)
	set_icon(KIND_ICON[int(kind)])


## The banner's picture: `texture` (the dungeon's painted map) shown round `focus` (0..1 on the picture), `span` of it wide and high,
## blurred. A banner is 3.8 times wider than high, so the default span keeps the picture's proportions.
func set_banner_art(texture: Texture2D, focus: Vector2 = Vector2(0.5, 0.5), span: Vector2 = Vector2(0.46, 0.2), blur: float = 0.011) -> void:
	if texture == null or _art == null:
		return
	if UiArt.has(BANNER_ART_ID) and texture != UiArt.texture(BANNER_ART_ID):
		return  # the generic painting wins once it exists (Part B, item 8)
	var material: ShaderMaterial = _art.material as ShaderMaterial
	# keep the crop inside the picture
	var half: Vector2 = span * 0.5
	var at: Vector2 = Vector2(clampf(focus.x, half.x, 1.0 - half.x), clampf(focus.y, half.y, 1.0 - half.y))
	material.set_shader_parameter("art", texture)
	material.set_shader_parameter("has_art", true)
	material.set_shader_parameter("center", at)
	material.set_shader_parameter("span", span)
	material.set_shader_parameter("blur", blur)


func has_banner_art() -> bool:
	return _art != null and (_art.material as ShaderMaterial).get_shader_parameter("has_art") == true


## The banner's map crop for a room of the current dungeon: the painted map of `Session`'s dungeon round the room's spot on it.
func set_banner_for_node(node: DungeonMap.MapNode) -> void:
	var plan: DungeonCatalog.Blueprint = null
	if Session.main_dungeon_active or Session.mini_active:
		plan = MainDungeons.blueprint(Session.dungeon_key)
	else:
		plan = DungeonCatalog.find(DungeonCatalog.TUTORIAL_ID)
	var texture: Texture2D = MapArt.texture_for(plan.map_id) if plan != null else null
	if texture == null:
		return
	# a room's `position` is already a fraction of the painted map (0..1 from its top left)
	set_banner_art(texture, node.position if node != null else Vector2(0.5, 0.5))


func set_icon(id: String) -> void:
	if icon == null:
		return
	icon.texture = IconArt.texture(id, 168.0) if IconArt.has(id) else null
	icon.visible = icon.texture != null


## The pre-fight panel: the foe's picture in the banner in place of the kind icon - a transparent cut-out standing on the banner's edge,
## or the square Bestiary picture in a gold-rimmed medallion.
func set_banner_portrait(picture: Texture2D, cutout: bool) -> void:
	if picture == null or banner == null:
		return
	icon.visible = false
	var width: float = card_width - 8.0
	if cutout:
		var figure: TextureRect = TextureRect.new()
		figure.name = "FoeCutout"
		# a bust: the top 58 % of the figure (head and shoulders), standing on the banner's lower edge
		var bust: AtlasTexture = AtlasTexture.new()
		bust.atlas = picture
		bust.region = Rect2(0.0, 0.0, float(picture.get_width()), float(picture.get_height()) * 0.58)
		figure.texture = bust
		figure.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		figure.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		figure.size = Vector2(360, banner_height - 6.0)
		figure.position = Vector2(width * 0.5 - 180.0, 6.0)
		figure.mouse_filter = Control.MOUSE_FILTER_IGNORE
		banner.add_child(figure)
		icon = figure
		return
	var rim: Panel = Panel.new()
	rim.name = "FoeMedallion"
	var rim_px: float = minf(190.0, banner_height - 34.0)
	rim.size = Vector2(rim_px, rim_px)
	rim.position = Vector2(width * 0.5 - rim_px * 0.5, banner_height * 0.5 - rim_px * 0.5)
	rim.add_theme_stylebox_override("panel", UIStyle.box(Color(0.06, 0.04, 0.09), Color("d9a84a"), 4, int(rim_px * 0.5)))
	rim.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(rim)
	var face: TextureRect = TextureRect.new()
	face.name = "FoePicture"
	face.texture = picture
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	face.position = Vector2(4, 4)
	face.size = Vector2(rim_px - 8.0, rim_px - 8.0)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rim.add_child(face)
	icon = null


static func _dot_texture() -> Texture2D:
	if _soft_dot == null:
		var gradient: Gradient = Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.set_color(1, Color(1, 1, 1, 0))
		var texture: GradientTexture2D = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 32
		texture.height = 32
		_soft_dot = texture
	return _soft_dot


static func _glow_texture() -> Texture2D:
	if _glow == null:
		var gradient: Gradient = Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
		gradient.colors = PackedColorArray([Color(1, 1, 1, 0.75), Color(1, 1, 1, 0.28), Color(1, 1, 1, 0.0)])
		var texture: GradientTexture2D = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 128
		texture.height = 128
		_glow = texture
	return _glow


## Drifting particles over the banner: "motes" rise slowly (a shrine), "mist" slides sideways in big soft puffs (a well), "sparkles"
## twinkle (treasure), "embers" rise fast and warm (a rescue, a fight), "dust" hangs in the air (an event). None under Reduce motion.
func _make_particles(style: String) -> CPUParticles2D:
	if still():
		return null
	var particles: CPUParticles2D = CPUParticles2D.new()
	particles.name = "BannerParticles"
	particles.texture = _dot_texture()
	var width: float = card_width - 8.0
	particles.position = Vector2(width * 0.5, banner_height * 0.5)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(width * 0.5, banner_height * 0.5)
	particles.gravity = Vector2.ZERO
	particles.spread = 25.0
	var colour: Color = wash_of(kind).lightened(0.55)
	var ramp: Gradient = Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.25, 0.75, 1.0])
	var low: bool = GraphicsQuality.low_end
	match style:
		"mist":
			particles.amount = 7 if low else 14
			particles.lifetime = 7.0
			particles.direction = Vector2(1, -0.1)
			particles.initial_velocity_min = 8.0
			particles.initial_velocity_max = 22.0
			particles.scale_amount_min = 5.0
			particles.scale_amount_max = 9.0
			ramp.colors = PackedColorArray([Color(colour, 0.0), Color(colour, 0.11), Color(colour, 0.09), Color(colour, 0.0)])
		"sparkles":
			particles.amount = 12 if low else 26
			particles.lifetime = 1.4
			particles.direction = Vector2(0, -1)
			particles.initial_velocity_min = 2.0
			particles.initial_velocity_max = 10.0
			particles.scale_amount_min = 0.25
			particles.scale_amount_max = 0.6
			ramp.colors = PackedColorArray([Color(1, 0.95, 0.7, 0.0), Color(1, 0.95, 0.7, 0.95), Color(1, 0.9, 0.55, 0.5), Color(1, 0.9, 0.5, 0.0)])
		"embers":
			particles.amount = 10 if low else 22
			particles.lifetime = 3.2
			particles.direction = Vector2(0.15, -1)
			particles.initial_velocity_min = 22.0
			particles.initial_velocity_max = 48.0
			particles.scale_amount_min = 0.18
			particles.scale_amount_max = 0.42
			ramp.colors = PackedColorArray([Color(1.0, 0.75, 0.4, 0.0), Color(1.0, 0.7, 0.35, 0.9), Color(1.0, 0.45, 0.25, 0.5), Color(0.8, 0.25, 0.2, 0.0)])
		"dust":
			particles.amount = 10 if low else 20
			particles.lifetime = 6.0
			particles.direction = Vector2(0.6, -0.4)
			particles.initial_velocity_min = 3.0
			particles.initial_velocity_max = 9.0
			particles.scale_amount_min = 0.2
			particles.scale_amount_max = 0.5
			ramp.colors = PackedColorArray([Color(colour, 0.0), Color(colour, 0.5), Color(colour, 0.4), Color(colour, 0.0)])
		_:
			particles.amount = 10 if low else 22
			particles.lifetime = 4.6
			particles.direction = Vector2(0, -1)
			particles.initial_velocity_min = 8.0
			particles.initial_velocity_max = 20.0
			particles.scale_amount_min = 0.22
			particles.scale_amount_max = 0.5
			ramp.colors = PackedColorArray([Color(colour, 0.0), Color(colour, 0.8), Color(colour, 0.6), Color(colour, 0.0)])
	particles.color_ramp = ramp
	particles.preprocess = particles.lifetime
	var additive: CanvasItemMaterial = CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	particles.material = additive
	return particles


# ---- The body -----------------------------------------------------------------------------------------------------------------


## The title plate: the kind in small caps between two hair lines, then the name.
func _title_plate() -> Control:
	var plate: VBoxContainer = UIKit.vbox(2)
	plate.name = "TitlePlate"
	var row: HBoxContainer = UIKit.hbox(14)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	for side: int in range(2):
		if side == 1:
			kicker_label = UIKit.label(spaced_caps(_kicker), &"", 16, GOLD_INK, HORIZONTAL_ALIGNMENT_CENTER)
			kicker_label.name = "Kicker"
			kicker_label.add_theme_font_override("font", UIStyle.font_bold())
			row.add_child(kicker_label)
		var line: ColorRect = ColorRect.new()
		line.color = Color(VELLUM_EDGE, 0.9)
		line.custom_minimum_size = Vector2(120, 2)
		line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(line)
		if side == 0:
			continue
	# (line, kicker, line): the loop adds the first line, then the kicker and the second line
	plate.add_child(row)
	title_label = UIKit.label(_title, &"TitleLabel", 46, INK, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.name = "CardTitle"
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.custom_minimum_size = Vector2(card_width - 120.0, 0)
	title_label.add_theme_color_override("font_shadow_color", Color(1, 1, 1, 0.0))
	title_label.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.0))
	plate.add_child(title_label)
	return plate


## "SHRINE" as small caps: capitals with a little air between the letters.
static func spaced_caps(text: String) -> String:
	var upper: String = text.to_upper()
	var out: String = ""
	for index: int in range(upper.length()):
		out += upper[index]
		if index < upper.length() - 1:
			out += " "
	return out


func set_title(title: String) -> void:
	_title = title
	if title_label != null:
		title_label.text = title


func clear_content() -> void:
	for child: Node in content.get_children():
		content.remove_child(child)
		child.queue_free()
	for child: Node in buttons.get_children():
		buttons.remove_child(child)
		child.queue_free()
	for child: Node in _chips.get_children():
		_chips.remove_child(child)
		child.queue_free()
	_chips.visible = false
	back_button = null
	_hp = null


## The flavour line: italic, soft ink, wrapped into lines of even length (no lone last word).
func flavour(text: String) -> Label:
	var label: Label = UIKit.label(no_orphan(text), &"", text_px(23), INK_SOFT, HORIZONTAL_ALIGNMENT_CENTER)
	label.name = "Flavour"
	label.add_theme_font_override("font", UIStyle.font_italic())
	_balance(label, UIStyle.font_italic(), text_px(23))
	content.add_child(label)
	return label


## Wraps `label` at a width that gives lines of even length: a paragraph a little over one line long breaks in the middle, not after
## its second-to-last word.
func _balance(label: Label, font: Font, size: int) -> void:
	var room: float = card_width - 140.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.custom_minimum_size = Vector2(balanced_width(label.text, font, size, room), 0)


## The wrap width (at most `room`) that splits `text` into its natural number of lines at even lengths.
static func balanced_width(text: String, font: Font, size: int, room: float) -> float:
	if font == null or text.is_empty():
		return room
	var widest: float = 0.0
	for paragraph: String in text.split(String.chr(10)):
		widest = maxf(widest, font.get_string_size(paragraph, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x)
	if widest <= room:
		return minf(room, widest + 8.0)
	var lines: float = ceilf(widest / room)
	return clampf(widest / lines * 1.09 + 24.0, room * 0.55, room)


## A plain body line in ink (results, explanations).
func line(text: String, colour: Color = INK, size: int = 23, bold: bool = false) -> Label:
	var label: Label = UIKit.label(no_orphan(text), &"", text_px(size), colour, HORIZONTAL_ALIGNMENT_CENTER)
	label.name = "Line"
	if bold:
		label.add_theme_font_override("font", UIStyle.font_bold())
	_balance(label, UIStyle.font_bold() if bold else UIStyle.font_body(), text_px(size))
	content.add_child(label)
	return label


## What the room does, as one row: icon + text pairs with a middle dot between them ("heart Heal 4 HP · card lose a random card").
## `parts`: [[icon id, text], ...]; an empty icon id leaves the text alone.
func effect(parts: Array) -> HFlowContainer:
	var row: HFlowContainer = HFlowContainer.new()
	row.name = "Effect"
	row.alignment = FlowContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("h_separation", 10)
	row.add_theme_constant_override("v_separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for index: int in range(parts.size()):
		var part: Array = parts[index] as Array
		if index > 0:
			row.add_child(UIKit.label("·", &"", text_px(26), GOLD_INK))
		var pair: HBoxContainer = UIKit.hbox(7)
		pair.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon_id: String = str(part[0])
		if not icon_id.is_empty() and IconArt.has(icon_id):
			var glyph: TextureRect = IconArt.rect(icon_id, float(text_px(30)))
			glyph.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			pair.add_child(glyph)
		var text: Label = UIKit.label(str(part[1]), &"", text_px(25), INK)
		text.add_theme_font_override("font", UIStyle.font_bold())
		pair.add_child(text)
		row.add_child(pair)
	content.add_child(row)
	return row


## A small chip for a cost or a note ("card -1 for this dungeon"), in the chip row over the buttons.
func chip(icon_id: String, text: String, colour: Color = BAD_INK) -> PanelContainer:
	var holder: PanelContainer = PanelContainer.new()
	holder.name = "Chip"
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(colour, 0.12)
	style.border_color = Color(colour, 0.75)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 12.0
	style.content_margin_right = 14.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	holder.add_theme_stylebox_override("panel", style)
	var row: HBoxContainer = UIKit.hbox(6)
	holder.add_child(row)
	if not icon_id.is_empty() and IconArt.has(icon_id):
		var glyph: TextureRect = IconArt.rect(icon_id, float(text_px(24)))
		glyph.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(glyph)
	row.add_child(UIKit.label(text, &"", text_px(19), colour.darkened(0.15)))
	_chips.add_child(holder)
	_chips.visible = true
	return holder


## The outcome preview: the HP bar with the heal as a ghost segment, and "HP 9 → 15" (or "HP 15 / 15 · already full").
func hp_preview(current: int, after: int, maximum: int) -> HpPreview:
	_hp = HpPreview.new()
	_hp.name = "HpPreview"
	_hp.setup(current, after, maximum, card_width - 200.0)
	_hp.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(_hp)
	return _hp


## A choice. The primary one is the gold button; `icon_id` puts the kind's icon on it.
func button(text: String, primary: bool = true, icon_id: String = "", min_width: float = 280.0) -> FancyButton:
	var made: FancyButton = FancyButton.make(text, &"PrimaryButton" if primary else &"", Vector2(min_width, 62.0 if primary else 56.0))
	if not icon_id.is_empty() and IconArt.has(icon_id):
		IconArt.button_icon(made, icon_id, 30.0)
	buttons.add_child(made)
	made.focus_mode = Control.FOCUS_ALL  # after it is in the tree (a FancyButton sets its own focus mode when it is ready): the pad and Tab reach it
	return made


## Keeps the last two words of a paragraph together (no orphan word on a line of its own).
static func no_orphan(text: String) -> String:
	var trimmed: String = text.strip_edges()
	var cut: int = trimmed.rfind(" ")
	if cut <= 0 or trimmed.count(" ") < 3:
		return trimmed
	return trimmed.substr(0, cut) + " " + trimmed.substr(cut + 1)


# ---- Confirm effects -----------------------------------------------------------------------------------------------------------


## A band of light across the HP bar while it fills (the shrine, the well).
func heal_shimmer() -> void:
	if _hp != null:
		_hp.shimmer()


## The well swallows the card: `control` shrinks and sinks into the banner's icon, then `then` runs.
func swallow(control: Control, then: Callable = Callable()) -> void:
	if control == null or still():
		if then.is_valid():
			then.call()
		return
	control.pivot_offset = control.size * 0.5
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(control, "scale", Vector2(0.2, 0.2), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(control, "modulate:a", 0.0, 0.45).set_delay(0.1)
	if _glow_rect != null:
		tween.tween_property(_glow_rect, "scale", Vector2(1.25, 1.25), 0.25)
		tween.chain().tween_property(_glow_rect, "scale", Vector2.ONE, 0.3)
	if then.is_valid():
		tween.chain().tween_callback(then)


## The HP bar of the outcome preview.
class HpPreview:
	extends VBoxContainer

	const BAR_HEIGHT: float = 26.0
	var current: int = 0
	var after: int = 0
	var maximum: int = 1
	var shown: float = 0.0
	var label: Label
	var bar: Control
	var _shimmer: float = -1.0

	func setup(hp_now: int, hp_after: int, hp_max: int, width: float) -> void:
		current = hp_now
		after = clampi(hp_after, 0, maxi(1, hp_max))
		maximum = maxi(1, hp_max)
		shown = float(current)
		add_theme_constant_override("separation", 6)
		label = UIKit.label("", &"", NodeCard.text_px(26), NodeCard.INK, HORIZONTAL_ALIGNMENT_CENTER)
		label.name = "HpText"
		label.add_theme_font_override("font", UIStyle.font_title())
		add_child(label)
		bar = Control.new()
		bar.name = "HpBar"
		bar.custom_minimum_size = Vector2(width, BAR_HEIGHT)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.draw.connect(_draw_bar)
		add_child(bar)
		_refresh()

	## "HP 9 → 15", "HP 15 / 15 · already full", or "HP 13 / 15" once the change has been made.
	func text() -> String:
		if after > current:
			return "HP  %d  →  %d" % [current, after] + ("  (full)" if after >= maximum else "")
		if after < current:
			return "HP  %d  →  %d" % [current, after]
		if current >= maximum:
			return "HP  %d / %d  ·  already full" % [current, maximum]
		return "HP  %d / %d" % [current, maximum]

	func _refresh() -> void:
		label.text = text()
		bar.queue_redraw()

	## Plays the change: the solid bar grows into the ghost segment.
	func apply() -> void:
		var from: float = shown
		if NodeCard.still():
			_set_shown(float(after))
		else:
			var tween: Tween = create_tween()
			tween.tween_method(_set_shown, from, float(after), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_callback(func() -> void:
				current = after
				_refresh())
			return
		current = after
		_refresh()

	func _set_shown(value: float) -> void:
		shown = value
		label.text = "HP  %d / %d" % [roundi(value), maximum]
		bar.queue_redraw()

	func shimmer() -> void:
		if NodeCard.still():
			return
		var tween: Tween = create_tween()
		tween.tween_method(func(value: float) -> void:
			_shimmer = value
			bar.queue_redraw(), 0.0, 1.0, 0.7)
		tween.tween_callback(func() -> void:
			_shimmer = -1.0
			bar.queue_redraw())

	func _draw_bar() -> void:
		var size: Vector2 = bar.size
		var radius: int = int(BAR_HEIGHT * 0.5)
		var back: StyleBoxFlat = StyleBoxFlat.new()
		back.bg_color = Color("3a2b33")
		back.border_color = Color("7a5a2a")
		back.set_border_width_all(2)
		back.set_corner_radius_all(radius)
		bar.draw_style_box(back, Rect2(Vector2.ZERO, size))
		var inner: Rect2 = Rect2(Vector2(3, 3), size - Vector2(6, 6))
		var ghost_to: float = float(maxi(after, current)) / float(maximum)
		var solid_to: float = clampf(shown / float(maximum), 0.0, 1.0)
		if after > current and ghost_to > solid_to:
			var ghost: StyleBoxFlat = StyleBoxFlat.new()
			ghost.bg_color = Color(0.45, 0.85, 0.5, 0.45)
			ghost.border_color = Color(0.55, 0.95, 0.6, 0.9)
			ghost.set_border_width_all(1)
			ghost.set_corner_radius_all(radius - 3)
			bar.draw_style_box(ghost, Rect2(inner.position, Vector2(maxf(inner.size.y, inner.size.x * ghost_to), inner.size.y)))
		if solid_to > 0.0:
			var fill: StyleBoxFlat = StyleBoxFlat.new()
			fill.bg_color = Color("c8443c") if after >= current else Color("c8443c")
			fill.set_corner_radius_all(radius - 3)
			bar.draw_style_box(fill, Rect2(inner.position, Vector2(maxf(inner.size.y, inner.size.x * solid_to), inner.size.y)))
			bar.draw_rect(Rect2(inner.position + Vector2(6, 2), Vector2(maxf(0.0, inner.size.x * solid_to - 12.0), 4.0)), Color(1, 1, 1, 0.22))
		if after < current:
			# a loss: the part that goes is hatched darker
			var lost_from: float = float(after) / float(maximum)
			bar.draw_rect(Rect2(inner.position + Vector2(inner.size.x * lost_from, 0), Vector2(inner.size.x * (solid_to - lost_from), inner.size.y)), Color(0, 0, 0, 0.35))
		if _shimmer >= 0.0:
			var x: float = inner.position.x + inner.size.x * solid_to * _shimmer
			bar.draw_rect(Rect2(Vector2(x - 14.0, inner.position.y), Vector2(28.0, inner.size.y)), Color(1, 1, 1, 0.5 * (1.0 - absf(_shimmer - 0.5) * 2.0) + 0.15))
