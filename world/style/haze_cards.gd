class_name HazeCards
extends Node3D
## Graphics Tier 1, Part 2 (docs/art/graphics_tier1.md): the cheap stand-ins for volumetric light - low fog cards in hollows (`style_haze_fog.gdshader`) and
## fake god-ray cards through canopies and gaps (`world_shaft.gdshader`, turned round the sun's axis to face the camera). Placed from the zone mood's
## `haze` block in data/art/zone_looks.json:
##   "haze": {"fog": [[x, z, size, strength], ...], "shafts": [[x, z, length, width, strength], ...], "fog_color": "f2cfa4", "shaft_color": "ffd9a0", "lift": 0.3}
## `GraphicsQuality.haze_cards(level)` caps how many cards are built (fog first): none on Low, 6 on Medium, 10 on High. Volumetric fog (High only) is separate.

const FOG_SHADER: String = "res://assets/shaders/style_haze_fog.gdshader"
const SHAFT_SHADER: String = "res://world/look/world_shaft.gdshader"

var fog_cards: Array[MeshInstance3D] = []
var shaft_cards: Array[MeshInstance3D] = []


static func install(parent: Node3D, spec: Dictionary, sun_travel: Vector3, fog_color: Color, sun_color: Color, level: int) -> HazeCards:
	var haze: HazeCards = HazeCards.new()
	haze.name = "HazeCards"
	parent.add_child(haze)
	haze.build(spec, sun_travel, fog_color, sun_color, GraphicsQuality.haze_cards(level))
	return haze


func build(spec: Dictionary, sun_travel: Vector3, fog_color: Color, sun_color: Color, budget: int) -> void:
	for card: MeshInstance3D in fog_cards + shaft_cards:
		card.queue_free()
	fog_cards.clear()
	shaft_cards.clear()
	if budget <= 0 or spec.is_empty():
		return
	var color: Color = Color.html(str(spec["fog_color"])) if spec.has("fog_color") else fog_color
	var shaft_color: Color = Color.html(str(spec["shaft_color"])) if spec.has("shaft_color") else sun_color
	var lift: float = float(spec.get("lift", 0.3))
	var left: int = budget
	for entry: Variant in spec.get("fog", []) as Array:
		if left <= 0:
			break
		var values: Array = entry as Array
		var size: float = float(values[2]) if values.size() > 2 else 12.0
		var strength: float = float(values[3]) if values.size() > 3 else 0.35
		fog_cards.append(_fog_card(Vector3(float(values[0]), lift, float(values[1])), size, strength, color, float(fog_cards.size()) * 3.7))
		left -= 1
	for entry: Variant in spec.get("shafts", []) as Array:
		if left <= 0:
			break
		var values: Array = entry as Array
		var length: float = float(values[2]) if values.size() > 2 else 10.0
		var width: float = float(values[3]) if values.size() > 3 else 2.6
		var strength: float = float(values[4]) if values.size() > 4 else 0.12
		shaft_cards.append(_shaft_card(Vector3(float(values[0]), 0.0, float(values[1])), length, width, strength, shaft_color, sun_travel, float(shaft_cards.size()) * 0.31))
		left -= 1


func _fog_card(at: Vector3, size: float, strength: float, color: Color, seed: float) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(size, size)
	quad.orientation = PlaneMesh.FACE_Y
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(FOG_SHADER) as Shader
	material.set_shader_parameter("color", color)
	material.set_shader_parameter("strength", strength)
	material.set_shader_parameter("seed", seed)
	material.render_priority = -3
	var card: MeshInstance3D = MeshInstance3D.new()
	card.name = "FogCard"
	card.mesh = quad
	card.material_override = material
	card.position = at
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	card.extra_cull_margin = 4.0
	card.set_meta(StyleToon.META_NO_TOON, true)
	card.set_meta(&"no_occlusion_fade", true)
	card.set_meta(&"no_ground_light", true)
	add_child(card)
	return card


func _shaft_card(at: Vector3, length: float, width: float, strength: float, color: Color, sun_travel: Vector3, seed: float) -> MeshInstance3D:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = load(SHAFT_SHADER) as Shader
	material.set_shader_parameter("axis", sun_travel)
	material.set_shader_parameter("length_m", length)
	material.set_shader_parameter("width_m", width)
	material.set_shader_parameter("strength", strength)
	material.set_shader_parameter("color", color)
	material.set_shader_parameter("seed", seed)
	var card: MeshInstance3D = MeshInstance3D.new()
	card.name = "ShaftCard"
	card.mesh = quad
	card.material_override = material
	# The card hangs from the top of the shaft: the shader draws it `length` metres down the sun's travel from the node, so the node sits where the light enters.
	card.position = at - sun_travel.normalized() * length * 0.85
	card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	card.extra_cull_margin = 30.0
	card.set_meta(StyleToon.META_NO_TOON, true)
	card.set_meta(&"no_occlusion_fade", true)
	card.set_meta(&"no_ground_light", true)
	add_child(card)
	return card
