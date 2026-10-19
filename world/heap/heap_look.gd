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
	particles.amount = 40
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


## Petals drifting down across the view (parent it to the camera, like the fireflies): small violet and lilac quads tumbling slowly, VD-14.
static func petals() -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.name = "Petals"
	particles.amount = 26
	particles.lifetime = 9.0
	particles.preprocess = 9.0
	particles.local_coords = false
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(13.0, 1.0, 10.0)
	particles.direction = Vector3(0.5, -0.5, 0.1)
	particles.spread = 40.0
	particles.initial_velocity_min = 0.25
	particles.initial_velocity_max = 0.7
	particles.gravity = Vector3(0.0, -0.28, 0.0)
	particles.damping_min = 0.3
	particles.damping_max = 0.55
	particles.angle_min = 0.0
	particles.angle_max = 360.0
	particles.angular_velocity_min = -80.0
	particles.angular_velocity_max = 80.0
	particles.tangential_accel_min = -0.25
	particles.tangential_accel_max = 0.25
	particles.scale_amount_min = 0.7
	particles.scale_amount_max = 1.2
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, Color("b48ae8"))
	ramp.add_point(0.5, Color("d0a8f0"))
	ramp.set_color(ramp.get_point_count() - 1, Color("8c64d0"))
	particles.color_initial_ramp = ramp
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.13, 0.16)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = material
	particles.mesh = quad
	particles.position = Vector3(0, 5, -8)
	return particles


## Bees (or moths) jittering round a spot: a handful of tiny bright dots darting about within `reach` of the origin.
static func bees(color: Color, reach: float, amount: int = 6) -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.name = "Bees"
	particles.amount = amount
	particles.lifetime = 3.0
	particles.preprocess = 3.0
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = reach
	particles.direction = Vector3(1.0, 0.2, 0.0)
	particles.spread = 180.0
	particles.initial_velocity_min = 0.6
	particles.initial_velocity_max = 1.4
	particles.gravity = Vector3.ZERO
	particles.tangential_accel_min = -3.0
	particles.tangential_accel_max = 3.0
	particles.radial_accel_min = -1.5
	particles.radial_accel_max = 0.5
	particles.damping_min = 0.2
	particles.damping_max = 0.5
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.045
	mesh.height = 0.09
	mesh.radial_segments = 5
	mesh.rings = 3
	particles.mesh = mesh
	particles.material_override = HeapMaterials.glow(color, 1.6)
	particles.set_meta(&"no_occlusion_fade", true)
	return particles
