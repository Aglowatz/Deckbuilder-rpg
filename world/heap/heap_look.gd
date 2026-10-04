class_name HeapLook
extends RefCounted
## The Verdant Dump's golden-hour lighting: a low warm sun, a peach-and-green dusk sky, soft bloom, a little extra
## saturation and drifting fireflies. Same tone-mapper and post-processing family as the other zones.


static func environment() -> WorldEnvironment:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("5f8fd0")
	sky_material.sky_horizon_color = Color("ffcf8a")
	sky_material.ground_horizon_color = Color("f0c890")
	sky_material.ground_bottom_color = Color("a88a5a")
	sky_material.sun_angle_max = 30.0
	sky_material.sky_curve = 0.22
	var sky: Sky = Sky.new()
	sky.sky_material = sky_material
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("ffe6c4")
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.78
	env.glow_enabled = true
	env.glow_intensity = 0.32
	env.glow_strength = 0.9
	env.glow_bloom = 0.12
	env.glow_hdr_threshold = 1.0
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.18
	env.adjustment_contrast = 1.06
	env.adjustment_brightness = 1.02
	env.ssao_enabled = true
	env.ssao_radius = 1.4
	env.ssao_intensity = 1.1
	env.fog_enabled = true
	env.fog_light_color = Color("f6d8a8")
	env.fog_density = 0.0024
	env.fog_sky_affect = 0.35
	world_env.environment = env
	return world_env


static func sun() -> DirectionalLight3D:
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.light_color = Color("ffd9a0")
	light.light_energy = 0.95
	light.rotation_degrees = Vector3(-34, -50, 0)
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 70.0
	light.shadow_blur = 1.4
	light.light_angular_distance = 1.2
	return light


## Fireflies bobbing across the view (parent it to the camera): a cheap, always-on ambience.
static func fireflies() -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.amount = 26
	particles.lifetime = 5.5
	particles.preprocess = 5.5
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(14.0, 3.0, 12.0)
	particles.direction = Vector3(0.2, 0.3, 0.0)
	particles.spread = 80.0
	particles.initial_velocity_min = 0.2
	particles.initial_velocity_max = 0.7
	particles.gravity = Vector3.ZERO
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.07
	mesh.height = 0.14
	mesh.radial_segments = 6
	mesh.rings = 3
	particles.mesh = mesh
	particles.material_override = HeapMaterials.glow(Color(1.0, 0.95, 0.4), 3.0)
	particles.position = Vector3(0, 4, -6)
	return particles
