class_name StyleAmbience
extends Node3D
## Ambient particles around the player (dust motes, leaves, fireflies, steam, sparkles, ash, petals, paper scraps), configured from a `ZonePreset`.
## Soft, warm and sparse (docs/art/style_guide.md, section 9). The emitter box follows `follow` so the effect is only ever spent where the camera looks.

var follow: Node3D
var _emitters: Array[GPUParticles3D] = []
static var _soft_texture: Texture2D


func _ready() -> void:
	top_level = true


func _process(_delta: float) -> void:
	if follow != null and is_instance_valid(follow):
		global_position = follow.global_position


func configure(preset: ZonePreset, level: int) -> void:
	for emitter: GPUParticles3D in _emitters:
		emitter.queue_free()
	_emitters.clear()
	var scale_factor: float = GraphicsQuality.ambient_particles_scale(level)
	var total: float = 0.0
	for entry: Dictionary in preset.particles:
		total += float(entry["amount"]) * scale_factor
	# One global budget for the zone: if the preset asks for more, every emitter shrinks by the same factor.
	var budget_factor: float = minf(1.0, float(GraphicsQuality.ambient_particle_budget(level)) / maxf(total, 1.0))
	for entry: Dictionary in preset.particles:
		var count: int = maxi(1, int(round(float(entry["amount"]) * scale_factor * budget_factor)))
		var emitter: GPUParticles3D = _make_emitter(str(entry["kind"]), entry["color"] as Color, count)
		if emitter != null:
			add_child(emitter)
			_emitters.append(emitter)


func emitter_count() -> int:
	return _emitters.size()


static func soft_texture() -> Texture2D:
	if _soft_texture == null:
		var gradient: Gradient = Gradient.new()
		gradient.set_color(0, Color(1, 1, 1, 1))
		gradient.set_color(1, Color(1, 1, 1, 0))
		var texture: GradientTexture2D = GradientTexture2D.new()
		texture.gradient = gradient
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		texture.width = 64
		texture.height = 64
		_soft_texture = texture
	return _soft_texture


func _make_emitter(kind: String, color: Color, count: int) -> GPUParticles3D:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.name = "Particles_%s" % kind
	particles.amount = count
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	particles.visibility_aabb = AABB(Vector3(-30, -10, -30), Vector3(60, 30, 60))
	particles.set_meta(StyleToon.META_NO_TOON, true)
	var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(18.0, 5.0, 18.0)
	process.direction = Vector3.UP
	process.spread = 180.0
	var size: float = 0.08
	var additive: bool = true
	var lifetime: float = 7.0
	var textured: bool = true
	var leaf_shape: bool = false
	match kind:
		"motes":
			process.gravity = Vector3(0.0, 0.04, 0.0)
			process.initial_velocity_min = 0.05
			process.initial_velocity_max = 0.25
			process.turbulence_enabled = true
			process.turbulence_noise_strength = 0.5
			size = 0.07
			lifetime = 9.0
			process.emission_box_extents = Vector3(18.0, 3.5, 18.0)
		"leaves":
			process.gravity = Vector3(0.3, -0.7, 0.1)
			process.initial_velocity_min = 0.1
			process.initial_velocity_max = 0.4
			process.turbulence_enabled = true
			process.turbulence_noise_strength = 1.2
			process.angular_velocity_min = -120.0
			process.angular_velocity_max = 120.0
			size = 0.2
			lifetime = 10.0
			additive = false
			textured = false
			leaf_shape = true
			process.emission_box_extents = Vector3(18.0, 1.0, 18.0)
			process.emission_shape_offset = Vector3(0.0, 8.0, 0.0)
		"petals":
			process.gravity = Vector3(0.5, -0.5, 0.2)
			process.initial_velocity_min = 0.2
			process.initial_velocity_max = 0.6
			process.turbulence_enabled = true
			process.turbulence_noise_strength = 1.0
			size = 0.15
			lifetime = 10.0
			additive = false
			textured = false
			leaf_shape = true
			process.emission_box_extents = Vector3(18.0, 1.0, 18.0)
			process.emission_shape_offset = Vector3(0.0, 8.0, 0.0)
		"paper":
			process.gravity = Vector3(0.2, -0.45, 0.0)
			process.initial_velocity_min = 0.1
			process.initial_velocity_max = 0.3
			process.turbulence_enabled = true
			process.turbulence_noise_strength = 1.4
			size = 0.24
			lifetime = 12.0
			additive = false
			textured = false
			process.emission_box_extents = Vector3(16.0, 1.0, 16.0)
			process.emission_shape_offset = Vector3(0.0, 8.0, 0.0)
		"fireflies":
			process.gravity = Vector3.ZERO
			process.initial_velocity_min = 0.1
			process.initial_velocity_max = 0.5
			process.turbulence_enabled = true
			process.turbulence_noise_strength = 1.6
			process.emission_box_extents = Vector3(16.0, 1.6, 16.0)
			process.emission_shape_offset = Vector3(0.0, 1.8, 0.0)
			size = 0.13
			lifetime = 6.0
			color = color * 2.2
		"steam":
			process.gravity = Vector3(0.0, 0.5, 0.0)
			process.initial_velocity_min = 0.1
			process.initial_velocity_max = 0.4
			size = 0.8
			lifetime = 4.5
			additive = false
			process.emission_box_extents = Vector3(14.0, 0.5, 14.0)
		"sparkles":
			process.gravity = Vector3(0.0, 0.25, 0.0)
			process.initial_velocity_min = 0.1
			process.initial_velocity_max = 0.5
			process.turbulence_enabled = true
			process.turbulence_noise_strength = 0.8
			size = 0.11
			lifetime = 3.5
			color = color * 1.8
		"ash":
			process.gravity = Vector3(0.1, -0.25, 0.0)
			process.initial_velocity_min = 0.05
			process.initial_velocity_max = 0.2
			process.turbulence_enabled = true
			process.turbulence_noise_strength = 0.7
			size = 0.07
			lifetime = 10.0
			additive = false
			process.emission_box_extents = Vector3(18.0, 5.0, 18.0)
		_:
			return null
	process.scale_min = 0.6
	process.scale_max = 1.3
	var fade: Gradient = Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.add_point(0.2, Color(1, 1, 1, 1))
	fade.add_point(0.8, Color(1, 1, 1, 1))
	fade.set_color(fade.get_point_count() - 1, Color(1, 1, 1, 0))
	var ramp: GradientTexture1D = GradientTexture1D.new()
	ramp.gradient = fade
	process.color_ramp = ramp
	particles.process_material = process
	particles.lifetime = lifetime
	particles.preprocess = lifetime
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(size, size)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.vertex_color_use_as_albedo = true
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if additive else BaseMaterial3D.BLEND_MODE_MIX
	material.no_depth_test = false
	material.disable_receive_shadows = true
	if textured:
		material.albedo_texture = soft_texture()
	elif leaf_shape:
		material.albedo_texture = leaf_texture()
	material.particles_anim_h_frames = 1
	material.particles_anim_v_frames = 1
	quad.material = material
	particles.draw_pass_1 = quad
	return particles


static var _leaf_texture: Texture2D


## A pointed leaf / petal silhouette (white on transparent) for the falling-leaf emitters, so they are not squares.
static func leaf_texture() -> Texture2D:
	if _leaf_texture == null:
		var image: Image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		for y: int in range(32):
			for x: int in range(32):
				var u: float = (float(x) + 0.5) / 32.0 * 2.0 - 1.0
				var v: float = (float(y) + 0.5) / 32.0 * 2.0 - 1.0
				# a lens shape along the diagonal: narrow towards both tips
				var along: float = (u + v) * 0.7071
				var across: float = (u - v) * 0.7071
				var width: float = 0.5 * (1.0 - absf(along) * absf(along))
				var inside: float = 1.0 - smoothstep(width - 0.12, width, absf(across))
				if absf(along) > 0.95:
					inside = 0.0
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, inside))
		_leaf_texture = ImageTexture.create_from_image(image)
	return _leaf_texture


## A slow smoke plume rising from `position` (chimneys): soft, tinted by the zone (never gray), a handful of particles.
static func chimney_smoke(parent: Node3D, position: Vector3, color: Color = Color(0.95, 0.88, 0.84, 0.5), amount: int = 10) -> GPUParticles3D:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.name = "ChimneySmoke"
	particles.amount = amount
	particles.lifetime = 5.0
	particles.preprocess = 5.0
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	particles.visibility_aabb = AABB(Vector3(-4, -1, -4), Vector3(8, 10, 8))
	particles.set_meta(StyleToon.META_NO_TOON, true)
	var process: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.08
	process.direction = Vector3.UP
	process.spread = 12.0
	process.initial_velocity_min = 0.35
	process.initial_velocity_max = 0.6
	process.gravity = Vector3(0.18, 0.1, 0.0)
	process.scale_min = 0.6
	process.scale_max = 1.0
	var scale_curve: Curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.4))
	scale_curve.add_point(Vector2(1.0, 1.6))
	var scale_texture: CurveTexture = CurveTexture.new()
	scale_texture.curve = scale_curve
	process.scale_curve = scale_texture
	var fade: Gradient = Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.add_point(0.15, Color(1, 1, 1, 1))
	fade.set_color(fade.get_point_count() - 1, Color(1, 1, 1, 0))
	var ramp: GradientTexture1D = GradientTexture1D.new()
	ramp.gradient = fade
	process.color_ramp = ramp
	particles.process_material = process
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.55, 0.55)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.vertex_color_use_as_albedo = true
	material.albedo_color = color
	material.albedo_texture = soft_texture()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.disable_receive_shadows = true
	quad.material = material
	particles.draw_pass_1 = quad
	particles.position = position
	parent.add_child(particles)
	return particles


## Shrinks every emitter volume (x/z) and enlarges the particles: for fixed-camera scenes (the battle table) where the default 36 m box would spread the few particles too thin to see.
func focus(box_scale: float, size_scale: float) -> void:
	for emitter: GPUParticles3D in _emitters:
		var process: ParticleProcessMaterial = emitter.process_material as ParticleProcessMaterial
		if process == null:
			continue
		var extents: Vector3 = process.emission_box_extents
		process.emission_box_extents = Vector3(extents.x * box_scale, extents.y, extents.z * box_scale)
		process.scale_min *= size_scale
		process.scale_max *= size_scale
