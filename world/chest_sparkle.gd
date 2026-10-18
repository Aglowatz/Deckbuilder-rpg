class_name ChestSparkle
extends MeshInstance3D
## Overnight Oct 17, Part 3: a subtle glint over an unopened chest. It fades in when the hero comes within `NEAR` metres and
## out again when they walk off; an opened chest has none (`ChestKit` removes it). One small mesh of camera-facing quads and
## one shader (assets/shaders/chest_sparkle.gdshader); hidden entirely while faded out, so far-off chests cost nothing.

const NODE_NAME: String = "ChestSparkle"
## Playtest v0.4.0 Part F: visible from farther away (was 3.0 / 3.4), bigger glints and a soft warm pulse of light over the lid.
const NEAR: float = 6.0
## A little hysteresis so standing on the edge does not flicker.
const FAR: float = 6.6
const GLINT_SIZE: float = 0.34
const LIGHT_ENERGY: float = 1.1
const FADE_SECONDS: float = 0.6
const SHADER: Shader = preload("res://assets/shaders/chest_sparkle.gdshader")
## Glint spots over the lid, as fractions of the chest's box (x, y above the top, z), with a phase each.
const SPOTS: Array[Vector4] = [
	Vector4(-0.32, 0.08, 0.1, 0.0),
	Vector4(0.28, 0.18, -0.12, 0.27),
	Vector4(0.05, 0.32, 0.18, 0.55),
	Vector4(-0.1, 0.02, -0.25, 0.8),
	Vector4(0.38, 0.4, 0.22, 0.4),
	Vector4(-0.36, 0.3, -0.2, 0.68),
]
var _light: OmniLight3D

var fade: float = 0.0
var _hero: Node3D
var _material: ShaderMaterial


## Puts a sparkle on `chest` (once); returns it, or null for a missing chest.
static func attach(chest: Node3D) -> ChestSparkle:
	if chest == null:
		return null
	var existing: ChestSparkle = of(chest)
	if existing != null:
		return existing
	var sparkle: ChestSparkle = ChestSparkle.new()
	sparkle.name = NODE_NAME
	chest.add_child(sparkle)
	return sparkle


static func of(chest: Node3D) -> ChestSparkle:
	return chest.get_node_or_null(NODE_NAME) as ChestSparkle if chest != null else null


static func remove(chest: Node3D) -> void:
	var sparkle: ChestSparkle = of(chest)
	if sparkle != null:
		sparkle.queue_free()
		chest.remove_child(sparkle)


func _ready() -> void:
	var chest: Node3D = get_parent() as Node3D
	var box: AABB = _chest_box(chest)
	top_level = true
	global_transform = Transform3D(Basis(), Vector3.ZERO)
	mesh = _build_mesh(box)
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter(&"size", GLINT_SIZE)
	_material.set_shader_parameter(&"tint", Color(1.0, 0.92, 0.6, 1.0))
	material_override = _material
	_light = OmniLight3D.new()
	_light.name = "ChestGlow"
	_light.light_color = Color(1.0, 0.85, 0.5)
	_light.omni_range = 2.4
	_light.light_energy = 0.0
	_light.shadow_enabled = false
	_light.position = box.get_center() + Vector3(0.0, box.size.y * 0.5 + 0.4, 0.0)
	add_child(_light)
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visible = false
	_set_fade(0.0)


func _process(delta: float) -> void:
	if _hero == null or not is_instance_valid(_hero):
		_hero = get_tree().get_first_node_in_group(&"audio_hero") as Node3D
		if _hero == null:
			return
	var parent: Node3D = get_parent() as Node3D
	var distance: float = _hero.global_position.distance_to(parent.global_position) if parent != null else 999.0
	var target: float = fade
	if distance <= NEAR:
		target = 1.0
	elif distance >= FAR:
		target = 0.0
	if not is_equal_approx(fade, target):
		_set_fade(move_toward(fade, target, delta / FADE_SECONDS))
	if _light != null and fade > 0.001:
		_light.light_energy = LIGHT_ENERGY * fade * (0.7 + 0.3 * sin(Time.get_ticks_msec() * 0.0032))


func _set_fade(value: float) -> void:
	fade = value
	visible = fade > 0.001
	if _material != null:
		_material.set_shader_parameter(&"fade", fade)
	if _light != null:
		_light.visible = fade > 0.001
		if fade <= 0.001:
			_light.light_energy = 0.0


## The chest's world-space box from its meshes (a 1 m cube at the chest when it has none).
static func _chest_box(chest: Node3D) -> AABB:
	var box: AABB = AABB()
	var found: bool = false
	if chest != null:
		for node: Node in chest.find_children("*", "MeshInstance3D", true, false):
			var mesh_node: MeshInstance3D = node as MeshInstance3D
			if mesh_node is ChestSparkle or mesh_node.mesh == null:
				continue
			var world: AABB = mesh_node.global_transform * mesh_node.get_aabb()
			box = world if not found else box.merge(world)
			found = true
	if not found:
		var origin: Vector3 = chest.global_position if chest != null else Vector3.ZERO
		box = AABB(origin - Vector3(0.5, 0.0, 0.5), Vector3.ONE)
	return box


static func _build_mesh(box: AABB) -> ArrayMesh:
	var vertices: PackedVector3Array = PackedVector3Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()
	var centre: Vector3 = box.get_center()
	var top: float = box.end.y
	for spot: Vector4 in SPOTS:
		var at: Vector3 = Vector3(centre.x + spot.x * box.size.x, top + spot.y * maxf(0.6, box.size.y), centre.z + spot.z * box.size.z)
		var base: int = vertices.size()
		for corner: Vector2 in [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
			vertices.append(at)
			uvs.append(corner)
			colors.append(Color(spot.w, 0.0, 0.0, 1.0))
		indices.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var result: ArrayMesh = ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	# The quads all sit on their centres; grow the bounds so culling sees the glints.
	result.custom_aabb = AABB(box.position - Vector3(0.5, 0.0, 0.5), box.size + Vector3(1.0, 1.5, 1.0))
	return result
