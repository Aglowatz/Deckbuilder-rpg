class_name AmbientFx
extends Node3D
## Overnight Oct 17, Part 14: light per-area atmosphere that follows the hero, and a small puff of the ground under every step.
## - Gainlands: warm dust drifting in the sun.  Buffet: wisps of kitchen steam rising.  Forest: pale motes in the mist.
##   D.N.A.: grey-green ghost motes.  Verdant Dump: tiny gnats and seed fluff.  Capital: slow ash flakes.  Town: dandelion fluff.
## One small CPUParticles3D box around the hero (16-40 tiny unshaded billboards, no shadows, no lights), fewer on Low quality, none
## when the area already has its own (the forest's fireflies are kept). Footstep puffs are a pooled one-shot emitter coloured by
## the surface (`EventBus.hero_footstep`). Never on top of characters: particles stay small, soft and low-alpha.

const PRESETS: Dictionary = {
	"gainlands": {"color": Color(0.96, 0.84, 0.58, 0.45), "amount": 34, "size": 0.05, "rise": 0.05, "drift": Vector3(0.35, 0.0, 0.1), "life": 6.0, "box": Vector3(9, 2.5, 7), "height": 1.4},
	"buffet": {"color": Color(1.0, 0.98, 0.95, 0.22), "amount": 22, "size": 0.32, "rise": 0.35, "drift": Vector3(0.05, 0.0, 0.0), "life": 4.0, "box": Vector3(9, 0.5, 7), "height": 0.4},
	"forest": {"color": Color(0.85, 0.95, 0.8, 0.5), "amount": 28, "size": 0.035, "rise": 0.03, "drift": Vector3(0.05, 0.0, 0.05), "life": 7.0, "box": Vector3(8, 2.5, 7), "height": 1.5},
	"dna": {"color": Color(0.62, 0.9, 0.72, 0.4), "amount": 22, "size": 0.05, "rise": 0.08, "drift": Vector3(0.0, 0.0, 0.0), "life": 6.0, "box": Vector3(9, 2.0, 7), "height": 1.2},
	"heap": {"color": Color(0.32, 0.3, 0.22, 0.6), "amount": 30, "size": 0.025, "rise": 0.0, "drift": Vector3(0.15, 0.0, 0.1), "life": 3.0, "box": Vector3(7, 1.6, 6), "height": 1.0},
	"capital": {"color": Color(0.78, 0.76, 0.74, 0.5), "amount": 36, "size": 0.04, "rise": -0.18, "drift": Vector3(0.12, 0.0, 0.05), "life": 8.0, "box": Vector3(10, 3.0, 8), "height": 3.0},
	"town": {"color": Color(1.0, 0.98, 0.92, 0.5), "amount": 14, "size": 0.035, "rise": 0.02, "drift": Vector3(0.25, 0.0, 0.08), "life": 7.0, "box": Vector3(9, 2.0, 7), "height": 1.4},
}
## Ground colour of a step's puff by surface (`Audio.surface_at`); surfaces not listed make no puff (water, wood, metal).
const PUFF_COLORS: Dictionary = {
	&"dirt": Color(0.62, 0.5, 0.36, 0.55), &"sand": Color(0.86, 0.76, 0.56, 0.55), &"grass": Color(0.55, 0.62, 0.42, 0.35),
	&"gravel": Color(0.6, 0.58, 0.54, 0.5), &"stone": Color(0.7, 0.68, 0.64, 0.35), &"ash": Color(0.6, 0.6, 0.6, 0.6),
	&"snow": Color(0.95, 0.96, 1.0, 0.6), &"junk": Color(0.45, 0.42, 0.32, 0.5), &"mud": Color(0.4, 0.32, 0.24, 0.5),
	&"food": Color(0.95, 0.85, 0.7, 0.5), &"cream": Color(0.98, 0.93, 0.85, 0.5),
}

var target: Node3D
var preset_key: String = ""
var motes: CPUParticles3D
var _puffs: CPUParticles3D


## Adds the atmosphere for `key` (a PRESETS key) following `hero`. Returns the node (null when the key has none).
static func add(parent: Node, key: String, hero: Node3D) -> AmbientFx:
	var fx: AmbientFx = AmbientFx.new()
	fx.name = "AmbientFx"
	fx.preset_key = key
	fx.target = hero
	parent.add_child(fx)
	return fx


func _ready() -> void:
	top_level = true
	if PRESETS.has(preset_key):
		motes = _make_motes(PRESETS[preset_key] as Dictionary)
		add_child(motes)
	_puffs = _make_puffs()
	add_child(_puffs)
	if not EventBus.hero_footstep.is_connected(_on_footstep):
		EventBus.hero_footstep.connect(_on_footstep)


func _exit_tree() -> void:
	if EventBus.hero_footstep.is_connected(_on_footstep):
		EventBus.hero_footstep.disconnect(_on_footstep)


func _process(_delta: float) -> void:
	if target != null and is_instance_valid(target) and motes != null:
		var height: float = float((PRESETS[preset_key] as Dictionary)["height"])
		motes.global_position = target.global_position + Vector3(0.0, height, 0.0)


static func _quality_scale() -> float:
	# Low quality (0) keeps a third of the particles; Medium and up keep them all.
	return 0.35 if int(Settings.get("quality") if Settings.get("quality") != null else 1) <= 0 else 1.0


static func _billboard_mesh(size: float, color: Color) -> QuadMesh:
	var mesh: QuadMesh = QuadMesh.new()
	mesh.size = Vector2(size, size)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.vertex_color_use_as_albedo = true
	material.albedo_color = color
	material.albedo_texture = PackFx.dot()
	material.disable_receive_shadows = true
	mesh.material = material
	return mesh


func _make_motes(preset: Dictionary) -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.name = "Motes"
	particles.amount = maxi(4, int(float(preset["amount"]) * _quality_scale()))
	particles.lifetime = float(preset["life"])
	particles.preprocess = float(preset["life"])
	particles.local_coords = false
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = preset["box"] as Vector3
	var drift: Vector3 = preset["drift"] as Vector3
	particles.direction = (drift + Vector3(0.0, float(preset["rise"]), 0.0)).normalized() if (drift + Vector3(0.0, float(preset["rise"]), 0.0)).length() > 0.001 else Vector3.UP
	particles.spread = 35.0
	particles.gravity = Vector3.ZERO
	particles.initial_velocity_min = 0.05
	particles.initial_velocity_max = maxf(0.12, (drift + Vector3(0.0, absf(float(preset["rise"])), 0.0)).length())
	particles.scale_amount_min = 0.6
	particles.scale_amount_max = 1.3
	var ramp: Gradient = Gradient.new()
	var color: Color = preset["color"] as Color
	ramp.set_color(0, Color(color.r, color.g, color.b, 0.0))
	ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
	ramp.add_point(0.25, color)
	ramp.add_point(0.75, color)
	particles.color_ramp = ramp
	particles.mesh = _billboard_mesh(float(preset["size"]), Color.WHITE)
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return particles


func _make_puffs() -> CPUParticles3D:
	var particles: CPUParticles3D = CPUParticles3D.new()
	particles.name = "FootstepPuffs"
	particles.amount = 6
	particles.lifetime = 0.55
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = false
	particles.local_coords = false
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.08
	particles.direction = Vector3.UP
	particles.spread = 70.0
	particles.gravity = Vector3(0.0, -0.4, 0.0)
	particles.initial_velocity_min = 0.25
	particles.initial_velocity_max = 0.6
	particles.scale_amount_min = 0.7
	particles.scale_amount_max = 1.4
	var curve: Curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.6))
	curve.add_point(Vector2(1.0, 1.4))
	particles.scale_amount_curve = curve
	particles.mesh = _billboard_mesh(0.16, Color.WHITE)
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	top_level = true
	return particles


func _on_footstep(position: Vector3, surface: StringName) -> void:
	if not PUFF_COLORS.has(surface) or _puffs == null:
		return
	var color: Color = PUFF_COLORS[surface] as Color
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, color)
	ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
	_puffs.color_ramp = ramp
	_puffs.global_position = position + Vector3(0.0, 0.05, 0.0)
	_puffs.restart()
