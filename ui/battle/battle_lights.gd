class_name BattleLights
extends Node2D
## Graphics Tier 1, Part 3 (docs/art/graphics_tier1.md): short-lived 2D point lights for the battle's effects. Every card play, hit, spell, heal and win
## (`BattleFX.burst` / `flash_ring`) pulses a `PointLight2D` that lights the painted battleboard and the cards on it (additive, a radial falloff), so the
## effect lands on the table instead of floating over it. Only canvas items that carry LIT_BIT in their `light_mask` are lit (the board and the card views;
## never the HUD, the log or the tooltips), so the lights cost one extra draw of those items per live light. `GraphicsQuality.effect_lights(level)` caps
## how many are alive at once (1 / 3 / 6; the oldest is reused). No 2D shadows (D11). `flash()` is the one-off version for other screens (the level-up
## moment); the 3D effect lights (a chest opening, `ChestKit._open_flash`) are OmniLight3Ds with shadows on High only.

const LIT_BIT: int = 2
const DEFAULT_MASK: int = 1

static var _radial: GradientTexture2D

var level: int = GraphicsQuality.Level.MEDIUM
var _pool: Array[PointLight2D] = []
var _next: int = 0
var _tweens: Dictionary = {}


static func radial_texture() -> GradientTexture2D:
	if _radial == null:
		var gradient: Gradient = Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.add_point(0.45, Color(1, 1, 1, 0.5))
		gradient.set_color(gradient.get_point_count() - 1, Color(1, 1, 1, 0))
		_radial = GradientTexture2D.new()
		_radial.gradient = gradient
		_radial.fill = GradientTexture2D.FILL_RADIAL
		_radial.fill_from = Vector2(0.5, 0.5)
		_radial.fill_to = Vector2(1.0, 0.5)
		_radial.width = 256
		_radial.height = 256
	return _radial


func setup(quality_level: int) -> void:
	level = quality_level


func budget() -> int:
	return GraphicsQuality.effect_lights(level)


## Lights `color` at `pos` (board pixels) over a circle of `radius` pixels, peaking at `energy` and fading out over `seconds`.
func pulse(pos: Vector2, color: Color, radius: float = 260.0, energy: float = 1.0, seconds: float = 0.5) -> void:
	if budget() <= 0:
		return
	var light: PointLight2D
	if _pool.size() < budget():
		light = _make_light()
		_pool.append(light)
	else:
		light = _pool[_next % _pool.size()]
		_next += 1
		if _tweens.has(light) and is_instance_valid(_tweens[light]):
			(_tweens[light] as Tween).kill()
	light.position = pos
	light.color = Color(color.r, color.g, color.b, 1.0)
	light.texture_scale = maxf(radius, 24.0) / 128.0
	light.energy = 0.0
	light.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(light, "energy", energy, 0.06)
	tween.tween_property(light, "energy", 0.0, maxf(seconds, 0.1)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void: light.visible = false)
	_tweens[light] = tween


func _make_light() -> PointLight2D:
	var light: PointLight2D = PointLight2D.new()
	light.texture = radial_texture()
	light.blend_mode = Light2D.BLEND_MODE_ADD
	light.range_item_cull_mask = LIT_BIT
	light.range_z_min = -1024
	light.range_z_max = 1024
	# No 2D shadows (D11 in docs/art/graphics_tier1.md): a hit's light sits at the struck card, inside any occluder the card would carry, and went black.
	light.shadow_enabled = false
	light.visible = false
	add_child(light)
	return light


## Marks `node` and every canvas item under it as lit by the effect lights.
static func mark_lit(node: Node) -> void:
	if node is CanvasItem:
		(node as CanvasItem).light_mask |= LIT_BIT
	for child: Node in node.get_children():
		mark_lit(child)


## A one-off light for any screen: lights everything on `mask` under `parent` (the default mask lights every canvas item there), then frees itself.
static func flash(parent: Node, pos: Vector2, color: Color, radius: float = 600.0, energy: float = 1.0, seconds: float = 1.0, mask: int = DEFAULT_MASK) -> PointLight2D:
	if GraphicsQuality.effect_lights(Settings.graphics_quality) <= 0:
		return null
	var light: PointLight2D = PointLight2D.new()
	light.texture = radial_texture()
	light.blend_mode = Light2D.BLEND_MODE_ADD
	light.range_item_cull_mask = mask
	light.range_z_min = -1024
	light.range_z_max = 1024
	light.position = pos
	light.color = Color(color.r, color.g, color.b, 1.0)
	light.texture_scale = maxf(radius, 24.0) / 128.0
	light.energy = 0.0
	parent.add_child(light)
	var tween: Tween = light.create_tween()
	tween.tween_property(light, "energy", energy, 0.08)
	tween.tween_property(light, "energy", 0.0, maxf(seconds, 0.1)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(light.queue_free)
	return light
