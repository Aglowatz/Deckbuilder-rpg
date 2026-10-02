class_name GainlandsLook
extends RefCounted
## The Gainlands' sunny, vibrant lighting: a bright blue sky with a pale horizon (so the void below
## the floating land reads as an endless sea of sky), warm strong sun, soft bloom and a touch of
## extra saturation. Same tone-mapper and post-processing family as the other zones (`WorldLook`),
## just tuned bright.


static func environment() -> WorldEnvironment:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("2f7de0")
	sky_material.sky_horizon_color = Color("bfe6ff")
	sky_material.ground_horizon_color = Color("d6efff")
	sky_material.ground_bottom_color = Color("9fd2f5")
	sky_material.sun_angle_max = 30.0
	sky_material.sky_curve = 0.22
	var sky: Sky = Sky.new()
	sky.sky_material = sky_material
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("fff1dc")
	env.ambient_light_energy = 0.62
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.95
	env.glow_enabled = true
	env.glow_intensity = 0.35
	env.glow_strength = 0.9
	env.glow_bloom = 0.1
	env.glow_hdr_threshold = 1.0
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.18
	env.adjustment_contrast = 1.05
	env.adjustment_brightness = 1.03
	env.ssao_enabled = true
	env.ssao_radius = 1.4
	env.ssao_intensity = 1.2
	env.fog_enabled = true
	env.fog_light_color = Color("d9efff")
	env.fog_density = 0.0018
	env.fog_sky_affect = 0.3
	world_env.environment = env
	return world_env


static func sun() -> DirectionalLight3D:
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.light_color = Color("fff3d6")
	light.light_energy = 1.25
	light.rotation_degrees = Vector3(-48, -28, 0)
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 70.0
	light.shadow_blur = 1.4
	light.light_angular_distance = 1.2
	return light


## Streaks of wind drifting across the view (parent it to the camera): a cheap, always-on ambience.
static func wind_streaks() -> CPUParticles3D:
	var streaks: CPUParticles3D = CPUParticles3D.new()
	streaks.amount = 26
	streaks.lifetime = 2.6
	streaks.preprocess = 2.6
	streaks.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	streaks.emission_box_extents = Vector3(14.0, 5.0, 12.0)
	streaks.direction = Vector3(1.0, 0.05, 0.2)
	streaks.spread = 4.0
	streaks.initial_velocity_min = 7.0
	streaks.initial_velocity_max = 11.0
	streaks.gravity = Vector3.ZERO
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.16, 0.03, 0.1)
	streaks.mesh = mesh
	streaks.material_override = GainlandsMaterials.translucent(Color(0.85, 1.0, 0.75), 0.55, 0.3)
	streaks.angle_min = 0.0
	streaks.angle_max = 360.0
	streaks.angular_velocity_min = -180.0
	streaks.angular_velocity_max = 180.0
	streaks.position = Vector3(0, 0, -10)
	return streaks
