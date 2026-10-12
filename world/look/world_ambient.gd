class_name WorldAmbient
extends Node3D
## Ambient life of the World Look Test (docs/art/world_look_test.md): drifting pollen and dust motes that glow in the sun, a few falling leaves, birds that now and then
## cross the sky in a loose flock, and warm light shafts. Everything follows the hero, so it is only ever made where it can be seen.

const BIRD_SHADER: String = "res://world/look/world_bird.gdshader"
const SHAFT_SHADER: String = "res://world/look/world_shaft.gdshader"
const BIRD_INTERVAL: Vector2 = Vector2(22.0, 48.0)
const SHAFT_COUNT: int = 5

var camera: Camera3D
var target: Node3D
var sun_travel: Vector3 = Vector3(0.42, -0.62, -0.67)
var _motes: CPUParticles3D
var _leaves: CPUParticles3D
var _shafts: Array[MeshInstance3D] = []
var _birds: Array[Dictionary] = []
var _bird_timer: float = 6.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _bird_material: ShaderMaterial
var _bird_quad: QuadMesh
## Strength of the shafts (the scene may dim them).
var shaft_strength: float = 0.1
## Light shafts are OFF by default: with the sun behind the north-facing camera they read as flat translucent strips with hard edges over the water (see docs/art/world_look_test.md).
## Launch with `--shafts=1` to see them.
var shafts_enabled: bool = false
var _birds_enabled: bool = true


func setup(_scene: Node3D, _town: TownBuilder, cam: Camera3D, follow: Node3D, sun: Vector3) -> void:
	setup_area(cam, follow, sun, {})


## `spec` (the mood's ambient block): `motes` (amount, 0 = none), `mote_color` (hex), `leaves` (false = none), `birds` (false = none).
func setup_area(cam: Camera3D, follow: Node3D, sun: Vector3, spec: Dictionary) -> void:
	camera = cam
	target = follow
	sun_travel = sun.normalized()
	_rng.seed = 77
	_birds_enabled = bool(spec.get("birds", true))
	_build_motes()
	_build_leaves()
	_motes.amount = maxi(1, int(spec.get("motes", 110)))
	_motes.visible = int(spec.get("motes", 110)) > 0
	if spec.has("mote_color"):
		_motes.color = Color.html(str(spec["mote_color"]))
	_leaves.visible = bool(spec.get("leaves", true))
	_leaves.emitting = _leaves.visible
	_motes.emitting = _motes.visible
	if shafts_enabled:
		_build_shafts()
	_bird_quad = QuadMesh.new()
	_bird_quad.size = Vector2.ONE


# ---- Motes and leaves --------------------------------------------------------------------------------------------------------------


func _soft_dot_texture() -> Texture2D:
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.add_point(0.45, Color(1, 1, 1, 0.5))
	gradient.set_color(gradient.get_point_count() - 1, Color(1, 1, 1, 0))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 32
	texture.height = 32
	return texture


func _build_motes() -> void:
	_motes = CPUParticles3D.new()
	_motes.amount = 110
	_motes.lifetime = 9.0
	_motes.preprocess = 9.0
	_motes.local_coords = false
	_motes.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_motes.emission_box_extents = Vector3(13.0, 2.6, 13.0)
	_motes.direction = Vector3(0.6, 0.15, 0.2)
	_motes.spread = 70.0
	_motes.initial_velocity_min = 0.05
	_motes.initial_velocity_max = 0.28
	_motes.gravity = Vector3(0.0, 0.015, 0.0)
	_motes.scale_amount_min = 0.5
	_motes.scale_amount_max = 1.5
	_motes.color = Color(1.0, 0.93, 0.7, 0.7)
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.06, 0.06)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = _soft_dot_texture()
	material.vertex_color_use_as_albedo = true
	material.disable_receive_shadows = true
	material.set_meta(StyleToon.META_NO_TOON, true)
	quad.material = material
	_motes.mesh = quad
	_motes.set_meta(StyleToon.META_NO_TOON, true)
	add_child(_motes)


func _leaf_texture() -> Texture2D:
	var size: int = 48
	var image: Image = Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	for y: int in range(size):
		for x: int in range(size):
			var u: float = (float(x) + 0.5) / float(size) * 2.0 - 1.0
			var v: float = (float(y) + 0.5) / float(size) * 2.0 - 1.0
			var half_width: float = 0.5 * pow(maxf(1.0 - absf(v), 0.0), 0.7)
			var inside: float = clampf((half_width - absf(u)) * 14.0, 0.0, 1.0)
			var vein: float = 1.0 - 0.18 * clampf(1.0 - absf(u) * 14.0, 0.0, 1.0)
			image.set_pixel(x, y, Color(vein, vein, vein, inside))
	return ImageTexture.create_from_image(image)


func _build_leaves() -> void:
	_leaves = CPUParticles3D.new()
	_leaves.amount = 12
	_leaves.lifetime = 11.0
	_leaves.preprocess = 11.0
	_leaves.local_coords = false
	_leaves.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_leaves.emission_box_extents = Vector3(11.0, 0.5, 11.0)
	_leaves.direction = Vector3(0.7, -0.4, 0.2)
	_leaves.spread = 35.0
	_leaves.initial_velocity_min = 0.3
	_leaves.initial_velocity_max = 0.9
	_leaves.gravity = Vector3(0.0, -0.34, 0.0)
	_leaves.damping_min = 0.35
	_leaves.damping_max = 0.6
	_leaves.angle_min = 0.0
	_leaves.angle_max = 360.0
	_leaves.angular_velocity_min = -90.0
	_leaves.angular_velocity_max = 90.0
	_leaves.tangential_accel_min = -0.3
	_leaves.tangential_accel_max = 0.3
	_leaves.scale_amount_min = 0.8
	_leaves.scale_amount_max = 1.3
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, Color("e8c040"))
	ramp.add_point(0.4, Color("8fc050"))
	ramp.add_point(0.75, Color("d98a35"))
	ramp.set_color(ramp.get_point_count() - 1, Color("b9602d"))
	_leaves.color_initial_ramp = ramp
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.16, 0.2)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	material.alpha_scissor_threshold = 0.5
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.particles_anim_h_frames = 1
	material.particles_anim_v_frames = 1
	material.albedo_texture = _leaf_texture()
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.set_meta(StyleToon.META_NO_TOON, true)
	quad.material = material
	_leaves.mesh = quad
	_leaves.set_meta(StyleToon.META_NO_TOON, true)
	add_child(_leaves)


# ---- Light shafts ------------------------------------------------------------------------------------------------------------------


func _build_shafts() -> void:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	for i: int in range(SHAFT_COUNT):
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = load(SHAFT_SHADER) as Shader
		material.set_shader_parameter("axis", sun_travel)
		material.set_shader_parameter("length_m", _rng.randf_range(8.0, 12.5))
		material.set_shader_parameter("width_m", _rng.randf_range(1.6, 3.4))
		material.set_shader_parameter("seed", _rng.randf())
		material.set_shader_parameter("strength", shaft_strength)
		var shaft: MeshInstance3D = MeshInstance3D.new()
		shaft.mesh = quad
		shaft.material_override = material
		shaft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shaft.extra_cull_margin = 30.0
		shaft.set_meta(StyleToon.META_NO_TOON, true)
		add_child(shaft)
		_shafts.append(shaft)


func _place_shafts() -> void:
	# Fixed offsets round the hero, snapped to a coarse grid so the shafts stay put in the world while he walks.
	var origin: Vector3 = target.position
	for i: int in range(_shafts.size()):
		var angle: float = float(i) / float(_shafts.size()) * TAU + 0.5
		var spot: Vector3 = origin + Vector3(cos(angle) * 5.5, 0.0, sin(angle) * 5.5)
		spot = Vector3(round(spot.x / 5.0) * 5.0 + float(i) * 0.7, 0.0, round(spot.z / 5.0) * 5.0 - float(i) * 0.4)
		(_shafts[i] as Node3D).global_position = spot + Vector3(0.0, 4.8, 0.0)


# ---- Birds -------------------------------------------------------------------------------------------------------------------------


## A loose flock of `count` birds crossing the view from one side to the other, far away and just above the horizon.
func spawn_flock(count: int = 5, from_left: bool = true) -> void:
	var basis: Basis = camera.global_basis
	var right: Vector3 = Vector3(basis.x.x, 0.0, basis.x.z).normalized()
	var forward: Vector3 = Vector3(-basis.z.x, 0.0, -basis.z.z).normalized()
	var distance: float = _rng.randf_range(110.0, 170.0)
	var elevation: float = deg_to_rad(_rng.randf_range(2.6, 6.0))
	var side: float = -1.0 if from_left else 1.0
	var start: Vector3 = camera.global_position + forward * distance + right * side * distance * 0.8
	start.y = camera.global_position.y + tan(elevation) * distance
	var velocity: Vector3 = right * (-side) * _rng.randf_range(11.0, 16.0)
	for i: int in range(count):
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = load(BIRD_SHADER) as Shader
		material.set_shader_parameter("flap_rate", _rng.randf_range(4.5, 6.5))
		material.set_shader_parameter("phase", _rng.randf() * TAU)
		var scale_card: float = _rng.randf_range(3.2, 4.4)
		material.set_shader_parameter("card_size", Vector2(scale_card, scale_card * 0.55))
		var bird: MeshInstance3D = MeshInstance3D.new()
		bird.mesh = _bird_quad
		bird.material_override = material
		bird.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		bird.extra_cull_margin = 100.0
		bird.set_meta(StyleToon.META_NO_TOON, true)
		bird.set_meta(&"no_range_cull", true)
		bird.set_meta(&"no_occlusion_fade", true)
		add_child(bird)
		var lag: float = float(i)
		var offset: Vector3 = right * (-side) * (-lag * 5.5 - _rng.randf_range(0.0, 3.0)) + forward * _rng.randf_range(-9.0, 9.0) + Vector3(0.0, _rng.randf_range(-3.0, 3.0) + absf(lag - 2.0) * 1.3, 0.0)
		bird.global_position = start + offset
		_birds.append({"node": bird, "velocity": velocity * _rng.randf_range(0.94, 1.06), "bob": _rng.randf() * TAU, "life": 0.0})


func _update_birds(delta: float) -> void:
	_bird_timer -= delta
	if _bird_timer <= 0.0 and _birds_enabled:
		_bird_timer = _rng.randf_range(BIRD_INTERVAL.x, BIRD_INTERVAL.y)
		spawn_flock(_rng.randi_range(3, 6), _rng.randf() > 0.5)
	for index: int in range(_birds.size() - 1, -1, -1):
		var bird: Dictionary = _birds[index]
		var node: Node3D = bird["node"] as Node3D
		bird["life"] = float(bird["life"]) + delta
		node.global_position += (bird["velocity"] as Vector3) * delta + Vector3(0.0, sin(float(bird["life"]) * 1.6 + float(bird["bob"])) * 0.5 * delta, 0.0)
		if float(bird["life"]) > 18.0 or node.global_position.distance_to(camera.global_position) > 420.0:
			node.queue_free()
			_birds.remove_at(index)


# ---- Frame -------------------------------------------------------------------------------------------------------------------------


func tick(delta: float) -> void:
	if target == null:
		return
	_motes.global_position = target.global_position + Vector3(0.0, 1.6, 0.0)
	_leaves.global_position = target.global_position + Vector3(-4.0, 7.0, -3.0)
	_place_shafts()
	_update_birds(delta)


func set_shaft_strength(value: float) -> void:
	shaft_strength = value
	for shaft: MeshInstance3D in _shafts:
		(shaft.material_override as ShaderMaterial).set_shader_parameter("strength", value)
