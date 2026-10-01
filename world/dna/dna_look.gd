class_name DnaLook
extends RefCounted
## The D.N.A.'s atmosphere: no sky, a sickly cold-green ambient, depth fog that swallows the far end
## of each corridor, a dim moonlight and glow. Real shadows-casting light is one directional light;
## the fluorescent pools come from `DnaScene`'s pooled OmniLights.


static func environment() -> WorldEnvironment:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.04, 0.04)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.32, 0.5, 0.42)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.95
	env.glow_enabled = true
	env.glow_intensity = 0.35
	env.glow_strength = 0.9
	env.glow_bloom = 0.1
	env.glow_hdr_threshold = 0.9
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.9
	env.adjustment_contrast = 1.08
	env.ssao_enabled = true
	env.ssao_radius = 1.0
	env.ssao_intensity = 1.5
	env.fog_enabled = true
	env.fog_light_color = Color(0.07, 0.14, 0.12)
	env.fog_density = 0.028
	env.fog_sky_affect = 1.0
	world_env.environment = env
	return world_env


static func moonlight() -> DirectionalLight3D:
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.light_color = Color(0.6, 0.85, 0.8)
	light.light_energy = 0.32
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 26.0
	light.shadow_blur = 1.5
	return light
