class_name WorldSky
extends Node3D
## The World Look Test's sky (docs/art/world_look_test.md): a painted gradient (sky shader on the town's own environment), the SKY-SUN glow card at the light's direction,
## the six SKY-CLOUD sprites in three depth layers drifting with parallax (slower the farther), and soft cloud shadows drifting over the ground.

const SKY_SHADER: String = "res://tests/world/world_sky.gdshader"
const CLOUD_SHADER: String = "res://tests/world/world_cloud.gdshader"
const SUN_SHADER: String = "res://tests/world/world_sunglow.gdshader"
const SHADOW_SHADER: String = "res://tests/world/world_cloud_shadow.gdshader"
const SKY_DIR: String = "res://assets/art/world_test/sky/"
const SUN_DISTANCE: float = 1500.0
## Layers: orbit radius round the town (m), drift speed (m/s at cloud-speed 1.0), the clouds used (SKY-CLOUD-nn), their angular width (degrees), base elevation range (degrees), count.
const LAYERS: Array[Dictionary] = [
	{"radius": 1350.0, "speed": 3.5, "ids": [3, 6, 5, 1], "width": Vector2(14.0, 24.0), "elevation": Vector2(3.0, 9.0), "count": 11, "haze": 0.62},
	{"radius": 980.0, "speed": 6.5, "ids": [1, 2, 4, 6, 3], "width": Vector2(16.0, 28.0), "elevation": Vector2(5.0, 13.0), "count": 10, "haze": 0.42},
	{"radius": 720.0, "speed": 10.0, "ids": [2, 4, 1, 3], "width": Vector2(16.0, 30.0), "elevation": Vector2(8.0, 18.0), "count": 8, "haze": 0.22},
]

var camera: Camera3D
var sun_toward: Vector3 = Vector3(-0.42, 0.62, 0.67)
var center: Vector3 = Vector3(25.2, 0.0, 12.47)
var _sky_material: ShaderMaterial
var _sun_card: MeshInstance3D
var _sun_material: ShaderMaterial
var _clouds: Array[Dictionary] = []
var _speed_scale: float = 1.0
var _shadow_plane: MeshInstance3D
var _shadow_material: ShaderMaterial
var _time: float = 0.0
var _haze: Color = Color("f2cfa4")


func setup(cam: Camera3D, env: Environment, sun_travel: Vector3) -> void:
	camera = cam
	sun_toward = -sun_travel.normalized()
	if env != null:
		_sky_material = ShaderMaterial.new()
		_sky_material.shader = load(SKY_SHADER) as Shader
		_sky_material.set_shader_parameter("sun_dir", sun_toward)
		var sky: Sky = Sky.new()
		sky.sky_material = _sky_material
		sky.radiance_size = Sky.RADIANCE_SIZE_32
		env.sky = sky
		env.background_mode = Environment.BG_SKY
	_build_sun()
	_build_clouds()
	_build_shadow_plane()


func _build_sun() -> void:
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2.ONE
	_sun_material = ShaderMaterial.new()
	_sun_material.shader = load(SUN_SHADER) as Shader
	_sun_material.set_shader_parameter("tex", load(SKY_DIR + "sun.png"))
	_sun_card = MeshInstance3D.new()
	_sun_card.mesh = quad
	_sun_card.material_override = _sun_material
	_sun_card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_sun_card.extra_cull_margin = 4000.0
	_sun_card.set_meta(StyleToon.META_NO_TOON, true)
	add_child(_sun_card)


func _build_clouds() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	var textures: Dictionary = {}
	for i: int in range(1, 7):
		textures[i] = load("%scloud_%02d.png" % [SKY_DIR, i]) as Texture2D
	var layer_index: int = 0
	for layer: Dictionary in LAYERS:
		var count: int = int(layer["count"])
		for n: int in range(count):
			var ids: Array = layer["ids"] as Array
			var id: int = int(ids[rng.randi() % ids.size()])
			var texture: Texture2D = textures[id] as Texture2D
			var radius: float = float(layer["radius"])
			var width_range: Vector2 = layer["width"] as Vector2
			var width_deg: float = rng.randf_range(width_range.x, width_range.y)
			var width: float = 2.0 * radius * tan(deg_to_rad(width_deg * 0.5))
			var height: float = width * float(texture.get_height()) / float(texture.get_width())
			var elevation_range: Vector2 = layer["elevation"] as Vector2
			var elevation: float = rng.randf_range(elevation_range.x, elevation_range.y)
			var angle: float = (float(n) + rng.randf_range(-0.3, 0.3)) / float(count) * TAU
			var quad: QuadMesh = QuadMesh.new()
			quad.size = Vector2.ONE
			quad.center_offset = Vector3(0.0, 0.5, 0.0)
			var material: ShaderMaterial = ShaderMaterial.new()
			material.shader = load(CLOUD_SHADER) as Shader
			material.set_shader_parameter("tex", texture)
			material.set_shader_parameter("card_size", Vector2(width, height))
			material.set_shader_parameter("haze_amount", float(layer["haze"]) + rng.randf_range(-0.05, 0.08))
			material.set_shader_parameter("opacity", rng.randf_range(0.82, 0.97))
			material.render_priority = -10 - layer_index
			var card: MeshInstance3D = MeshInstance3D.new()
			card.mesh = quad
			card.material_override = material
			card.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			card.extra_cull_margin = 2000.0
			card.set_meta(StyleToon.META_NO_TOON, true)
			add_child(card)
			_clouds.append({"node": card, "material": material, "radius": radius, "angle": angle, "altitude": radius * tan(deg_to_rad(elevation)), "speed": float(layer["speed"]) * rng.randf_range(0.8, 1.25)})
		layer_index += 1
	_place_clouds()


func _build_shadow_plane() -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(300.0, 300.0)
	_shadow_material = ShaderMaterial.new()
	_shadow_material.shader = load(SHADOW_SHADER) as Shader
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.018
	noise.fractal_octaves = 3
	var texture: NoiseTexture2D = NoiseTexture2D.new()
	texture.noise = noise
	texture.width = 512
	texture.height = 512
	texture.seamless = true
	_shadow_material.set_shader_parameter("noise_tex", texture)
	_shadow_plane = MeshInstance3D.new()
	_shadow_plane.mesh = plane
	_shadow_plane.material_override = _shadow_material
	_shadow_plane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_shadow_plane.extra_cull_margin = 200.0
	_shadow_plane.position = Vector3(center.x, 0.07, center.z)
	_shadow_plane.set_meta(StyleToon.META_NO_TOON, true)
	add_child(_shadow_plane)


func set_cloud_speed(value: float) -> void:
	_speed_scale = value


func set_haze_color(color: Color) -> void:
	_haze = color
	if _sky_material != null:
		_sky_material.set_shader_parameter("horizon_color", color.lerp(Color(1.0, 0.95, 0.88), 0.25))
	for entry: Dictionary in _clouds:
		(entry["material"] as ShaderMaterial).set_shader_parameter("haze", color.lerp(Color(0.85, 0.88, 0.97), 0.3))


func tick(delta: float) -> void:
	_time += delta
	for entry: Dictionary in _clouds:
		entry["angle"] = float(entry["angle"]) + _speed_scale * float(entry["speed"]) * delta / float(entry["radius"])
	_place_clouds()
	if camera != null:
		_sun_card.global_position = camera.global_position + sun_toward * SUN_DISTANCE
		_shadow_material.set_shader_parameter("follow_pos", camera.global_position)
		_shadow_plane.global_position = Vector3(camera.global_position.x, 0.07, camera.global_position.z)


func _place_clouds() -> void:
	for entry: Dictionary in _clouds:
		var angle: float = float(entry["angle"])
		var radius: float = float(entry["radius"])
		(entry["node"] as Node3D).position = center + Vector3(sin(angle) * radius, float(entry["altitude"]), -cos(angle) * radius)
