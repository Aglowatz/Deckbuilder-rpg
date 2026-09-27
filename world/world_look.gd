class_name WorldLook
extends RefCounted
## Shared lighting, sky and post-processing so every 3D scene has the same warm, stylized mood.


static func environment(mood: StringName = &"day") -> WorldEnvironment:
	var world_env: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	match mood:
		&"cave":
			sky_material.sky_top_color = Color("1b1230")
			sky_material.sky_horizon_color = Color("5a3550")
			sky_material.ground_horizon_color = Color("4a2c48")
			sky_material.ground_bottom_color = Color("1a1024")
		_:
			sky_material.sky_top_color = Color("4d7fc4")
			sky_material.sky_horizon_color = Color("f3c58f")
			sky_material.ground_horizon_color = Color("e2b487")
			sky_material.ground_bottom_color = Color("6c5a6a")
	sky_material.sun_angle_max = 25.0
	sky_material.sky_curve = 0.18
	var sky: Sky = Sky.new()
	sky.sky_material = sky_material
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.75 if mood == &"day" else 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.9
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_strength = 0.85
	env.glow_bloom = 0.08
	env.glow_hdr_threshold = 1.0
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.08
	env.adjustment_contrast = 1.06
	env.adjustment_brightness = 1.0
	env.ssao_enabled = true
	env.ssao_radius = 1.2
	env.ssao_intensity = 1.6
	env.fog_enabled = true
	env.fog_light_color = Color("f0c9a0") if mood == &"day" else Color("3c2544")
	env.fog_density = 0.006
	env.fog_sky_affect = 0.4
	world_env.environment = env
	return world_env


static func sun(mood: StringName = &"day") -> DirectionalLight3D:
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.light_color = Color("fff0dc") if mood == &"day" else Color("c8a0ff")
	light.light_energy = 0.95 if mood == &"day" else 0.9
	light.rotation_degrees = Vector3(-38, -32, 0)
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 60.0
	light.shadow_blur = 1.5
	light.light_angular_distance = 1.5
	return light
