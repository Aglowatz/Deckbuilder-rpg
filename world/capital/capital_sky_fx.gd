class_name CapitalSkyFx
extends Node3D
## Batch 15 (Nov 13): the freed Capital's sky over the castle, once `primm_defeated` is set. Two painted cards from the Capital kit:
## - CAP-BD-LANTERNS: a drift of paper sky-lanterns that rises slowly behind the castle (two copies half a cycle apart, each fading in at the
##   bottom of its climb and out at the top). With Reduce motion or on the Low-end preset it is one still card.
## - CAP-FX-FIREWORKS: three painted bursts (green, gold, pink). One burst at a time blooms and fades somewhere over the castle every few
##   seconds: soft and occasional, no sound. Off with Reduce motion and on the Low-end preset.
## Unshaded cards in front of the castle: the lanterns climb from the grand stair, the bursts bloom before the keep's upper face. From inside
## the city the castle fills the view and the sky itself is never in frame (the camera sees about 13 m up at the head of the avenue), so
## cards behind or above the castle would never be seen. No fog, no shadows; nothing here touches the play area.

const LANTERNS: String = "CAP-BD-LANTERNS"
const FIREWORKS: String = "CAP-FX-FIREWORKS"
## Where the lantern cards stand: on the city's axis over the grand stair (the camera looks north, so they face south).
const SKY_Z: float = 6.0
## The lantern card: width in metres, the bottom of its climb, how far it climbs and how long one climb takes.
const LANTERN_WIDTH: float = 30.0
const LANTERN_BASE_Y: float = 0.5
const LANTERN_RISE: float = 9.0
const LANTERN_SECONDS: float = 50.0
## The three bursts as regions of the fireworks card (x, y, w, h in 0-1 of the trimmed picture).
const BURSTS: Array[Rect2] = [Rect2(0.02, 0.33, 0.28, 0.64), Rect2(0.24, 0.0, 0.45, 0.94), Rect2(0.63, 0.24, 0.36, 0.76)]
## Seconds between two bursts (min, max), how long one lasts, and its size in metres (min, max).
const BURST_GAP: Vector2 = Vector2(4.5, 9.0)
const BURST_SECONDS: float = 2.8
const BURST_SIZE: Vector2 = Vector2(7.0, 10.5)
## The bursts bloom just in front of the keep's upper face (z relative to the lantern cards) between these heights.
const BURST_Z: float = -7.0
const BURST_Y: Vector2 = Vector2(11.5, 17.0)
const SHADER_CODE: String = """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, depth_draw_never, fog_disabled, blend_mix;
uniform sampler2D art : source_color, filter_linear_mipmap;
uniform vec4 region = vec4(0.0, 0.0, 1.0, 1.0);
uniform float fade = 1.0;
uniform float soft = 0.0;
void fragment() {
	vec4 c = texture(art, region.xy + UV * region.zw);
	float edge = 1.0;
	if (soft > 0.0) {
		edge = 1.0 - smoothstep(1.0 - soft, 1.0, length((UV - 0.5) * 2.0));
	}
	ALBEDO = c.rgb;
	ALPHA = c.a * fade * edge;
}
"""

var _lanterns: Array[MeshInstance3D] = []
var _bursts: Array[MeshInstance3D] = []
var _time: float = 0.0
var _next_burst: float = 3.0
var _burst_index: int = -1
var _burst_age: float = 0.0
var _burst_size: float = 16.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _moving: bool = true


## True when the sky may move (the lanterns climb, the fireworks play): not with Reduce motion, not on the Low-end preset.
static func motion_allowed(reduce_motion: bool, low_end: bool) -> bool:
	return not reduce_motion and not low_end


## The freed sky under `parent`, or null when neither card is imported. `axis_x`: the castle's axis.
static func build(parent: Node3D, axis_x: float, moving: bool) -> CapitalSkyFx:
	if not EnvKit.has_art(LANTERNS) and not EnvKit.has_art(FIREWORKS):
		return null
	var fx: CapitalSkyFx = CapitalSkyFx.new()
	fx.name = "FreedSky"
	fx._moving = moving
	fx.position = Vector3(axis_x, 0.0, SKY_Z)
	parent.add_child(fx)
	return fx


func _ready() -> void:
	_rng.seed = 1113
	var shader: Shader = Shader.new()
	shader.code = SHADER_CODE
	if EnvKit.has_art(LANTERNS):
		var height: float = LANTERN_WIDTH / maxf(EnvKit.aspect(LANTERNS), 0.1)
		for copy: int in range(2 if _moving else 1):
			var card: MeshInstance3D = _card(shader, EnvKit.texture(LANTERNS), Vector2(LANTERN_WIDTH, height))
			card.position = Vector3(-6.0 if copy == 0 else 9.0, LANTERN_BASE_Y + height * 0.5 + (LANTERN_RISE * 0.45 if not _moving else 0.0), -0.5 * float(copy))
			if copy == 1:
				card.scale.x = -1.0  # the second drift is the first one mirrored, so the two never read as a repeat
			(card.material_override as ShaderMaterial).set_shader_parameter("fade", 0.92 if not _moving else 0.0)
			_lanterns.append(card)
	if _moving and EnvKit.has_art(FIREWORKS):
		for region: Rect2 in BURSTS:
			var burst: MeshInstance3D = _card(shader, EnvKit.texture(FIREWORKS), Vector2.ONE)
			var material: ShaderMaterial = burst.material_override as ShaderMaterial
			material.set_shader_parameter("region", Vector4(region.position.x, region.position.y, region.size.x, region.size.y))
			material.set_shader_parameter("soft", 0.3)
			material.set_shader_parameter("fade", 0.0)
			burst.visible = false
			_bursts.append(burst)
	set_process(_moving)
	if _moving:
		_place_lanterns()


func _card(shader: Shader, texture: Texture2D, size: Vector2) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = size
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("art", texture)
	var card: MeshInstance3D = MeshInstance3D.new()
	card.mesh = quad
	card.material_override = material
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	card.extra_cull_margin = 8.0
	card.set_meta(StyleToon.META_NO_TOON, true)
	card.set_meta(&"no_wind", true)
	card.set_meta(&"no_occlusion_fade", true)
	card.set_meta(&"no_range_cull", true)
	add_child(card)
	return card


func _process(delta: float) -> void:
	_time += delta
	_place_lanterns()
	if _bursts.is_empty():
		return
	if _burst_index < 0:
		_next_burst -= delta
		if _next_burst <= 0.0:
			_start_burst()
		return
	_burst_age += delta
	var burst: MeshInstance3D = _bursts[_burst_index]
	var t: float = _burst_age / BURST_SECONDS
	if t >= 1.0:
		burst.visible = false
		_burst_index = -1
		_next_burst = _rng.randf_range(BURST_GAP.x, BURST_GAP.y)
		return
	var grow: float = 0.5 + 0.5 * (1.0 - pow(1.0 - minf(t * 2.2, 1.0), 3.0))
	var size: float = _burst_size * grow
	burst.scale = Vector3(size, size, 1.0)
	(burst.material_override as ShaderMaterial).set_shader_parameter("fade", burst_fade(t))


## How visible a burst is at `t` (0-1 of its life): in quickly, held, out slowly; never fully opaque (it sits on the sky).
static func burst_fade(t: float) -> float:
	return clampf(minf(t / 0.12, (1.0 - t) / 0.5), 0.0, 1.0) * 0.85


## How visible a lantern card is at `phase` (0-1 of its climb): in over the first fifth, out over the last quarter.
static func lantern_fade(phase: float) -> float:
	return clampf(minf(phase / 0.2, (1.0 - phase) / 0.25), 0.0, 1.0) * 0.95


func _place_lanterns() -> void:
	for copy: int in range(_lanterns.size()):
		var card: MeshInstance3D = _lanterns[copy]
		var phase: float = fposmod(_time / LANTERN_SECONDS + 0.5 * float(copy) + 0.3, 1.0)
		var height: float = (card.mesh as QuadMesh).size.y
		card.position.y = LANTERN_BASE_Y + height * 0.5 + LANTERN_RISE * phase
		(card.material_override as ShaderMaterial).set_shader_parameter("fade", lantern_fade(phase))


func _start_burst() -> void:
	_burst_index = _rng.randi_range(0, _bursts.size() - 1)
	_burst_age = 0.0
	_burst_size = _rng.randf_range(BURST_SIZE.x, BURST_SIZE.y)
	var burst: MeshInstance3D = _bursts[_burst_index]
	var region: Rect2 = BURSTS[_burst_index]
	burst.position = Vector3(_rng.randf_range(-11.0, 11.0), _rng.randf_range(BURST_Y.x, BURST_Y.y), BURST_Z)
	burst.scale = Vector3(_burst_size * 0.5, _burst_size * 0.5 * region.size.y / maxf(region.size.x, 0.01), 1.0)
	burst.visible = true
