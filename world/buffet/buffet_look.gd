class_name BuffetLook
extends RefCounted
## The Endless Buffet's warm, saturated, appetizing lighting: a peach-and-apricot sky that fades to a creamy
## horizon, a golden low sun, soft bloom and a strong colour pop. Same tone-mapper and post-processing family
## as the other zones (`GainlandsLook`), tuned warm instead of bright blue.


static func environment() -> WorldEnvironment:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("ff9a55")
	sky_material.sky_horizon_color = Color("ffd9a0")
	sky_material.ground_horizon_color = Color("ffe6bd")
	sky_material.ground_bottom_color = Color("f2b883")
	sky_material.sun_angle_max = 30.0
	sky_material.sky_curve = 0.25
	var sky: Sky = Sky.new()
	sky.sky_material = sky_material
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("ffe4c2")
	env.ambient_light_energy = 0.42
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.72
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_strength = 0.9
	env.glow_bloom = 0.12
	env.glow_hdr_threshold = 1.0
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.25
	env.adjustment_contrast = 1.06
	env.adjustment_brightness = 1.03
	env.ssao_enabled = true
	env.ssao_radius = 1.4
	env.ssao_intensity = 1.1
	env.fog_enabled = true
	env.fog_light_color = Color("ffdcb0")
	env.fog_density = 0.0022
	env.fog_sky_affect = 0.35
	world_env.environment = env
	return world_env


static func sun() -> DirectionalLight3D:
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.light_color = Color("ffe3b0")
	light.light_energy = 0.88
	light.rotation_degrees = Vector3(-46, -32, 0)
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 70.0
	light.shadow_blur = 1.4
	light.light_angular_distance = 1.2
	return light


## Rainbow sprinkles drifting down across the view (parent it to the camera): a cheap, always-on ambience.
static func sprinkles() -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.amount = 40
	particles.lifetime = 5.0
	particles.preprocess = 5.0
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(14.0, 1.0, 12.0)
	particles.direction = Vector3(0.1, -1.0, 0.0)
	particles.spread = 8.0
	particles.initial_velocity_min = 0.8
	particles.initial_velocity_max = 1.6
	particles.gravity = Vector3.ZERO
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.18, 0.05, 0.05)
	particles.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.emission_enabled = true
	material.emission = Color(1, 1, 1)
	material.emission_energy_multiplier = 0.25
	particles.material_override = material
	var ramp: Gradient = Gradient.new()
	ramp.colors = PackedColorArray([Color(1.0, 0.4, 0.6), Color(0.4, 0.9, 1.0), Color(1.0, 0.9, 0.3), Color(0.6, 1.0, 0.5)])
	ramp.offsets = PackedFloat32Array([0.0, 0.33, 0.66, 1.0])
	particles.color_initial_ramp = ramp
	particles.angle_min = 0.0
	particles.angle_max = 360.0
	particles.angular_velocity_min = -240.0
	particles.angular_velocity_max = 240.0
	particles.position = Vector3(0, 8, -6)
	return particles
