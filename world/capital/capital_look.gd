class_name CapitalLook
extends RefCounted
## The Capital's lighting. Outside the facade it is a bruised, cold twilight (a dim violet sun, thick fog, desaturated colour);
## while the Beefcake service is down the Capital is dark (`dark`), and once Primm falls it is bright and warm (`freed`).
## `ZoneCompletionLook` is NOT used here: the Capital grades itself from its debuffs and its own freed state.


static func environment(dark: bool, freed: bool) -> WorldEnvironment:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	if freed:
		sky_material.sky_top_color = Color("6fa8e0")
		sky_material.sky_horizon_color = Color("ffe0a8")
		sky_material.ground_horizon_color = Color("e8d4a8")
		sky_material.ground_bottom_color = Color("9a8a6a")
	else:
		sky_material.sky_top_color = Color("3c3a5c") if not dark else Color("14132a")
		sky_material.sky_horizon_color = Color("a28aa8") if not dark else Color("3a2f50")
		sky_material.ground_horizon_color = Color("807088") if not dark else Color("2a2438")
		sky_material.ground_bottom_color = Color("2a2430")
	sky_material.sky_curve = 0.25
	var sky: Sky = Sky.new()
	sky.sky_material = sky_material
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c8bede") if not dark else Color("5a5478")
	env.ambient_light_energy = 0.5 if not dark else 0.4
	if freed:
		env.ambient_light_color = Color("fff0d0")
		env.ambient_light_energy = 0.62
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.85 if not freed else 0.72
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_strength = 1.0
	env.glow_bloom = 0.15
	env.glow_hdr_threshold = 0.95
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.85 if not freed else 1.1
	env.adjustment_contrast = 1.08
	env.ssao_enabled = true
	env.ssao_radius = 1.5
	env.ssao_intensity = 1.2
	env.fog_enabled = true
	env.fog_light_color = Color("8a7a98") if not dark else Color("2a2438")
	if freed:
		env.fog_light_color = Color("f0e0c0")
	env.fog_density = 0.0034 if not freed else 0.0016
	env.fog_sky_affect = 0.45
	world_env.environment = env
	return world_env


static func sun(dark: bool, freed: bool) -> DirectionalLight3D:
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.light_color = Color("b8a8d8") if not freed else Color("ffe6b0")
	light.light_energy = (0.7 if not dark else 0.45) if not freed else 0.9
	light.rotation_degrees = Vector3(-52, -32, 0)
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 80.0
	light.shadow_blur = 1.4
	return light


## Drifting ash / dust (parent it to the camera): the kingdom is coming apart.
static func ash() -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.amount = 70
	particles.lifetime = 7.0
	particles.preprocess = 7.0
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(14, 6, 9)
	particles.direction = Vector3(0.3, -0.25, 0.0)
	particles.spread = 40.0
	particles.initial_velocity_min = 0.1
	particles.initial_velocity_max = 0.5
	particles.gravity = Vector3(0.05, -0.12, 0.0)
	var mote: SphereMesh = SphereMesh.new()
	mote.radius = 0.03
	mote.height = 0.06
	mote.radial_segments = 4
	mote.rings = 2
	particles.mesh = mote
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.85, 0.82, 0.9, 0.55)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = material
	particles.position = Vector3(0, 1.0, -5.0)
	return particles


## Confetti and petals for the freed Capital (parent it to the camera).
static func confetti() -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.amount = 60
	particles.lifetime = 6.0
	particles.preprocess = 6.0
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(14, 1, 9)
	particles.direction = Vector3(0, -1, 0)
	particles.spread = 25.0
	particles.initial_velocity_min = 0.4
	particles.initial_velocity_max = 0.9
	particles.gravity = Vector3(0, -0.3, 0)
	var piece: QuadMesh = QuadMesh.new()
	piece.size = Vector2(0.12, 0.08)
	particles.mesh = piece
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.7, 0.8)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	particles.material_override = material
	particles.position = Vector3(0, 7.0, -5.0)
	return particles
