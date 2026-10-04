class_name ZoneCompletionLook
extends RefCounted
## Part D: how a zone's lighting reads before and after it is freed. The zone's own look (`GainlandsLook`...)
## is the baseline; an OPPRESSED zone is dimmer, greyer and tinted with the ruler's gloom, a FREED zone
## is brighter, warmer and clearer. Applied once when the zone scene is built, to the scene's
## WorldEnvironment, its sun/moon and any lamps.

## (exposure, saturation, ambient, sun/lamp energy, fog density, tint amount)
const OPPRESSED: Dictionary = {"exposure": 0.86, "saturation": 0.78, "ambient": 0.8, "light": 0.76, "fog": 1.45, "tint": 0.34}
const FREED: Dictionary = {"exposure": 1.1, "saturation": 1.14, "ambient": 1.12, "light": 1.18, "fog": 0.75, "tint": 0.18}
const FREED_TINT: Color = Color(1.0, 0.94, 0.78)


## Applies the state ("freed" or "oppressed") of `zone_def` to every environment and light under `scene`.
static func apply(scene: Node, zone_def: ZoneDef, freed: bool) -> void:
	var settings: Dictionary = FREED if freed else OPPRESSED
	var tint: Color = FREED_TINT if freed else zone_def.gloom_tint
	for node: Node in _all_nodes(scene):
		if node is WorldEnvironment:
			_grade_environment((node as WorldEnvironment).environment, settings, tint)
		elif node is DirectionalLight3D:
			_grade_light(node as Light3D, settings, tint, 1.0)
		elif node is OmniLight3D or node is SpotLight3D:
			_grade_light(node as Light3D, settings, tint, 0.5)


## A short summary of the grading (used by tests and logs).
static func describe(freed: bool) -> String:
	return "freed (brighter, warmer)" if freed else "oppressed (dimmer, tinted by the ruler's gloom)"


static func _grade_environment(env: Environment, settings: Dictionary, tint: Color) -> void:
	if env == null:
		return
	env.tonemap_exposure *= float(settings["exposure"])
	if env.adjustment_enabled:
		env.adjustment_saturation *= float(settings["saturation"])
	env.ambient_light_energy *= float(settings["ambient"])
	env.ambient_light_color = env.ambient_light_color.lerp(tint, float(settings["tint"]) * 0.6)
	if env.fog_enabled:
		env.fog_density *= float(settings["fog"])
		env.fog_light_color = env.fog_light_color.lerp(tint, float(settings["tint"]))
	var sky: Sky = env.sky
	if sky != null and sky.sky_material is ProceduralSkyMaterial:
		var material: ProceduralSkyMaterial = sky.sky_material as ProceduralSkyMaterial
		var amount: float = float(settings["tint"])
		material.sky_top_color = material.sky_top_color.lerp(tint, amount)
		material.sky_horizon_color = material.sky_horizon_color.lerp(tint, amount)
		material.ground_horizon_color = material.ground_horizon_color.lerp(tint, amount)
		material.ground_bottom_color = material.ground_bottom_color.lerp(tint, amount)


static func _grade_light(light: Light3D, settings: Dictionary, tint: Color, tint_scale: float) -> void:
	light.light_energy *= float(settings["light"])
	light.light_color = light.light_color.lerp(tint, float(settings["tint"]) * 0.5 * tint_scale)


static func _all_nodes(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		result.append(node)
		for child: Node in node.get_children():
			stack.append(child)
	return result
