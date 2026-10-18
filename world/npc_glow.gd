class_name NpcGlow
extends MeshInstance3D
## Playtest v0.4.0, Part A: a soft glowing disc at an NPC's feet - gold for vendors, green for quest givers - so the people worth
## walking up to read at a glance. One unshaded additive quad with a radial gradient, excluded from the toon pass, pulsing gently.

const VENDOR: Color = Color(1.0, 0.82, 0.35)
const QUEST: Color = Color(0.55, 0.95, 0.6)
const NODE_NAME: String = "NpcGlow"
const RADIUS: float = 0.95
const BASE_ALPHA: float = 0.55

static var _texture: GradientTexture2D

var _time: float = 0.0
var _color: Color = VENDOR


## Puts a glow under `npc` (a sprite actor or a model placed with ModelKit) once; returns it.
static func attach(npc: Node3D, color: Color) -> NpcGlow:
	if npc == null:
		return null
	var existing: Node = npc.get_node_or_null(NODE_NAME)
	if existing is NpcGlow:
		(existing as NpcGlow).set_color(color)
		return existing as NpcGlow
	var glow: NpcGlow = NpcGlow.new()
	glow.name = NODE_NAME
	glow._color = color
	npc.add_child(glow)
	return glow


static func of(npc: Node3D) -> NpcGlow:
	return npc.get_node_or_null(NODE_NAME) as NpcGlow if npc != null else null


static func _gradient() -> GradientTexture2D:
	if _texture == null:
		var gradient: Gradient = Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
		gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0)])
		_texture = GradientTexture2D.new()
		_texture.gradient = gradient
		_texture.fill = GradientTexture2D.FILL_RADIAL
		_texture.fill_from = Vector2(0.5, 0.5)
		_texture.fill_to = Vector2(0.5, 0.0)
		_texture.width = 128
		_texture.height = 128
	return _texture


func _ready() -> void:
	set_meta(StyleToon.META_NO_TOON, true)
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(RADIUS * 2.0, RADIUS * 2.0)
	mesh = quad
	rotation_degrees.x = -90.0
	position = Vector3(0.0, 0.04, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = _gradient()
	material.albedo_color = Color(_color, BASE_ALPHA)
	material.no_depth_test = false
	material_override = material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The parent is scaled to the figure (TownPlayer.MODEL_SCALE); keep the disc a world-size disc.
	var parent_scale: Vector3 = get_parent().scale if get_parent() is Node3D else Vector3.ONE
	if parent_scale.x > 0.0:
		scale = Vector3.ONE / parent_scale.x


func set_color(color: Color) -> void:
	_color = color
	if material_override is StandardMaterial3D:
		(material_override as StandardMaterial3D).albedo_color = Color(color, BASE_ALPHA)


func _process(delta: float) -> void:
	_time += delta
	var pulse: float = 0.5 + 0.5 * sin(_time * 2.2)
	if material_override is StandardMaterial3D:
		(material_override as StandardMaterial3D).albedo_color.a = BASE_ALPHA * (0.75 + 0.25 * pulse)
