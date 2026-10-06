class_name FastTravelStation
extends Node3D
## A Beefcake Rift Station (brief 10b): a squat-rack frame of weight plates with a jagged glowing rift torn open between the
## uprights. Dormant (a faint seam) until the town it stands in has been reached, then torn open. Procedural, no assets.
## Face +Z (the camera side). `rip_effect()` is the tearing animation that plays just before a trip.

const SHADER: Shader = preload("res://world/travel/rift_portal.gdshader")
const RIFT_SIZE: Vector2 = Vector2(2.3, 2.5)
const OPEN_WIDTH: float = 0.5
const SEAM_WIDTH: float = 0.07

var active: bool = false
var _rift_material: ShaderMaterial
var _light: OmniLight3D
var _sparks: CPUParticles3D
var _rift: MeshInstance3D
var _time: float = 0.0


func build(sign_lines: Array[String], active_now: bool) -> void:
	_add_platform()
	for side: float in [-1.25, 1.25]:
		_add_upright(side)
	_add_bar(Vector3(0.0, 2.5, 0.0), 2.75, 0.07)
	_add_rift()
	_add_sign(sign_lines)
	_add_tub()
	_light = OmniLight3D.new()
	_light.position = Vector3(0.0, 1.3, 0.8)
	_light.omni_range = 6.0
	add_child(_light)
	_sparks = CPUParticles3D.new()
	_sparks.position = Vector3(0.0, 0.4, 0.0)
	_sparks.amount = 28
	_sparks.lifetime = 2.2
	_sparks.direction = Vector3.UP
	_sparks.spread = 18.0
	_sparks.initial_velocity_min = 0.5
	_sparks.initial_velocity_max = 1.3
	_sparks.gravity = Vector3.ZERO
	_sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_sparks.emission_box_extents = Vector3(0.45, 0.05, 0.1)
	var spark_mesh: SphereMesh = SphereMesh.new()
	spark_mesh.radius = 0.035
	spark_mesh.height = 0.07
	var spark_material: StandardMaterial3D = StandardMaterial3D.new()
	spark_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark_material.albedo_color = Color(0.6, 0.95, 1.0)
	spark_mesh.material = spark_material
	_sparks.mesh = spark_mesh
	add_child(_sparks)
	set_active(active_now)


func set_active(on: bool) -> void:
	active = on
	_rift_material.set_shader_parameter("width", OPEN_WIDTH if on else SEAM_WIDTH)
	_rift_material.set_shader_parameter("charge", 1.1 if on else 0.35)
	_light.light_color = Color(0.45, 0.9, 1.0) if on else Color(0.6, 0.55, 0.7)
	_light.light_energy = 1.7 if on else 0.25
	_sparks.emitting = on


## The tear: the rift rips wide, flares and shakes the whole frame, then settles. Returns the tween (awaitable).
func rip_effect(duration: float = 1.5) -> Tween:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_rift_material, "shader_parameter/width", 1.0, duration * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_rift_material, "shader_parameter/charge", 3.4, duration * 0.6)
	tween.tween_property(_light, "light_energy", 7.0, duration * 0.6)
	tween.chain().tween_property(_rift, "scale", Vector3(1.35, 1.2, 1.0), duration * 0.4)
	_sparks.amount = 90
	_sparks.initial_velocity_max = 3.5
	return tween


func _process(delta: float) -> void:
	_time += delta
	if _rift != null and active:
		_light.light_energy = 1.7 + sin(_time * 3.1) * 0.35


# ---- Parts ---------------------------------------------------------------------------------------------


func _material(color: Color, metallic: float = 0.0, rough: float = 0.8) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = rough
	return material


func _cylinder(radius: float, height: float, pos: Vector3, color: Color, rot: Vector3 = Vector3.ZERO, metallic: float = 0.0) -> MeshInstance3D:
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 20
	mesh.material = _material(color, metallic, 0.45 if metallic > 0.0 else 0.85)
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.rotation_degrees = rot
	add_child(node)
	return node


func _add_platform() -> void:
	_cylinder(1.9, 0.12, Vector3(0.0, 0.06, 0.2), Color("4a4350"))
	_cylinder(1.6, 0.06, Vector3(0.0, 0.14, 0.2), Color("7a2f2f"))


func _add_upright(x: float) -> void:
	_cylinder(0.07, 2.55, Vector3(x, 1.4, 0.0), Color("b8bcc4"), Vector3.ZERO, 0.8)
	for i: int in range(4):
		var radius: float = 0.42 - float(i) * 0.04
		_cylinder(radius, 0.1, Vector3(x, 0.24 + float(i) * 0.11, 0.0), Color("2a2a30") if i % 2 == 0 else Color("a83232"), Vector3.ZERO, 0.4)
	for i: int in range(2):
		_cylinder(0.3, 0.1, Vector3(x, 2.1 - float(i) * 0.11, 0.0), Color("2a2a30"), Vector3.ZERO, 0.4)


func _add_bar(pos: Vector3, length: float, radius: float) -> void:
	_cylinder(radius, length, pos, Color("c8ccd4"), Vector3(0.0, 0.0, 90.0), 0.8)
	for side: float in [-1.0, 1.0]:
		_cylinder(0.3, 0.12, pos + Vector3(side * 0.95, 0.0, 0.0), Color("a83232"), Vector3(0.0, 0.0, 90.0), 0.4)


func _add_rift() -> void:
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = RIFT_SIZE
	_rift_material = ShaderMaterial.new()
	_rift_material.shader = SHADER
	mesh.material = _rift_material
	_rift = MeshInstance3D.new()
	_rift.mesh = mesh
	_rift.position = Vector3(0.0, 1.4, 0.0)
	_rift.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_rift)


func _add_sign(lines: Array[String]) -> void:
	var title: Label3D = Label3D.new()
	title.text = lines[0] if not lines.is_empty() else ""
	title.font = UIStyle.font_title()
	title.font_size = 64
	title.pixel_size = 0.0042
	title.outline_size = 16
	title.outline_modulate = Color(0.1, 0.03, 0.03, 0.95)
	title.modulate = Color("ffcf70")
	title.position = Vector3(0.0, 3.3, 0.1)
	StyleLabel.lean_back(title)
	add_child(title)
	if lines.size() > 1:
		var small: Label3D = Label3D.new()
		small.text = lines[1]
		small.font = UIStyle.font_title()
		small.font_size = 38
		small.pixel_size = 0.0038
		small.outline_size = 10
		small.outline_modulate = Color(0.1, 0.03, 0.03, 0.95)
		small.modulate = Color("f3e9d2")
		small.position = Vector3(0.0, 3.0, 0.1)
		StyleLabel.lean_back(small)
		add_child(small)


## A protein tub and a spare plate at the side: every Beefcake workplace has both.
func _add_tub() -> void:
	_cylinder(0.26, 0.5, Vector3(1.75, 0.31, 0.9), Color("e8b04a"))
	_cylinder(0.27, 0.08, Vector3(1.75, 0.6, 0.9), Color("a83232"))
	_cylinder(0.36, 0.1, Vector3(-1.75, 0.11, 1.3), Color("2a2a30"), Vector3.ZERO, 0.4)


## Puts the whole station on a visual layer (the Capital's underground hideout is not lit by the sun, see `CapitalBuilder`).
func set_render_layer(layer: int) -> void:
	_set_layers(self, layer)


func _set_layers(node: Node, layer: int) -> void:
	if node is GeometryInstance3D:
		(node as GeometryInstance3D).layers = layer
	if node is Light3D:
		(node as Light3D).light_cull_mask = layer
	for child: Node in node.get_children():
		_set_layers(child, layer)
