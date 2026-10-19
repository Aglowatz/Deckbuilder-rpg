class_name PostBattleBackdrop
extends Control
## Oct 19 (post-battle backgrounds): the one backdrop behind every screen that follows a fight - the result panel, the rewards screen,
## the trial-complete recap, a boss's closing words, the level-up and quest-complete popups. It shows where the player is: the
## battleboard of the fight just played (`for_board`, BB-* through `Battleboards`) or the live scene behind a popup (`live`), always
## softly blurred, gently darkened and vignetted so panels and text read on top, and fading in so the battle melts into it.
## Mapping: docs/art/post_battle_backgrounds.md. Story stills keep their own STORY-* art (they draw over this).

const FADE_IN: float = 0.45
const BLUR_RADIUS: float = 0.006
const LIVE_BLUR_LOD: float = 2.6
const DARKEN: float = 0.42

const _BOARD_SHADER: String = """
shader_type canvas_item;
uniform float radius = 0.006;
uniform float darken = 0.42;
void fragment() {
	vec4 sum = vec4(0.0);
	float total = 0.0;
	for (int ring = 0; ring < 3; ring++) {
		float r = radius * float(ring + 1) / 3.0;
		for (int step = 0; step < 8; step++) {
			float a = 6.2831853 * (float(step) + 0.5 * float(ring)) / 8.0;
			float w = 1.0 - float(ring) * 0.25;
			sum += texture(TEXTURE, UV + vec2(cos(a), sin(a) * 1.7778) * r) * w;
			total += w;
		}
	}
	sum += texture(TEXTURE, UV) * 1.5;
	total += 1.5;
	vec4 blurred = sum / total;
	COLOR = vec4(blurred.rgb * (1.0 - darken), 1.0);
}
"""

const _LIVE_SHADER: String = """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float lod = 2.6;
uniform float darken = 0.42;
void fragment() {
	vec3 blurred = textureLod(screen_tex, SCREEN_UV, lod).rgb;
	COLOR = vec4(blurred * (1.0 - darken), 1.0);
}
"""

static var _board_material: ShaderMaterial = null
static var _live_material: ShaderMaterial = null

## The battleboard id (or context key) shown, "" for a live backdrop (tests and the docs table read it).
var board: String = ""


## The fight's place: `key_or_id` is a battle context key ("zone:beefcake", "dungeon:hollow", "capital:in") or a Battleboard id ("BB-HOG").
static func for_board(key_or_id: String, fade: bool = true) -> PostBattleBackdrop:
	var backdrop: PostBattleBackdrop = _base("PostBattleBackdrop")
	backdrop.board = key_or_id
	var picture: TextureRect = TextureRect.new()
	picture.name = "Board"
	picture.texture = Battleboards.texture_for(key_or_id)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.material = _board_mat()
	UIKit.full_rect(picture)
	backdrop.add_child(picture)
	backdrop._finish(fade)
	return backdrop


## The live scene behind (a zone, Crosspath), blurred - for popups that open over the world.
static func live(fade: bool = true) -> PostBattleBackdrop:
	var backdrop: PostBattleBackdrop = _base("PostBattleBackdropLive")
	var copy: BackBufferCopy = BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	backdrop.add_child(copy)
	var blur: ColorRect = ColorRect.new()
	blur.name = "Blur"
	blur.material = _live_mat()
	blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIKit.full_rect(blur)
	backdrop.add_child(blur)
	backdrop._finish(fade)
	return backdrop


## Where a dungeon's rewards screen should take place when the offer does not say: the run's own board (the Forgotten Cave, a zone's
## main or side dungeon, the Capital's castle or Primm's chamber).
static func dungeon_board_key() -> String:
	if Session.main_dungeon_active or Session.mini_active:
		var plan: DungeonCatalog.Blueprint = MainDungeons.blueprint(Session.dungeon_key)
		if plan != null and not plan.battleboard_id.is_empty():
			return plan.battleboard_id
		return "dungeon:%s" % Session.dungeon_key
	return "dungeon:hollow"


static func _base(node_name: String) -> PostBattleBackdrop:
	var backdrop: PostBattleBackdrop = PostBattleBackdrop.new()
	backdrop.name = node_name
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIKit.full_rect(backdrop)
	return backdrop


func _finish(fade: bool) -> void:
	add_child(UIKit.vignette(0.7))
	if fade:
		modulate.a = 0.0
		tree_entered.connect(func() -> void: create_tween().tween_property(self, "modulate:a", 1.0, FADE_IN), CONNECT_ONE_SHOT)


static func _board_mat() -> ShaderMaterial:
	if _board_material == null:
		var shader: Shader = Shader.new()
		shader.code = _BOARD_SHADER
		_board_material = ShaderMaterial.new()
		_board_material.shader = shader
		_board_material.set_shader_parameter("radius", BLUR_RADIUS)
		_board_material.set_shader_parameter("darken", DARKEN)
	return _board_material


static func _live_mat() -> ShaderMaterial:
	if _live_material == null:
		var shader: Shader = Shader.new()
		shader.code = _LIVE_SHADER
		_live_material = ShaderMaterial.new()
		_live_material.shader = shader
		_live_material.set_shader_parameter("lod", LIVE_BLUR_LOD)
		_live_material.set_shader_parameter("darken", DARKEN)
	return _live_material
