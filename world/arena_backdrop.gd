class_name ArenaBackdrop
extends Node3D
## The 3D scene behind the battle table: a small hex meadow at dusk with banners and mountains,
## seen from a slowly swaying camera. It is dimmed by the battle screen so cards stay readable.

var _camera: Camera3D
var _time: float = 0.0


func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 11
	for row: int in range(-4, 5):
		for col: int in range(-5, 6):
			var pos: Vector3 = HexGrid.cell_to_world(col, row)
			var dist: float = Vector2(pos.x, pos.z).length()
			if dist > 9.5:
				var water: Node3D = ModelKit.tile("hex_water")
				ModelKit.place(self, water, pos)
				continue
			ModelKit.place(self, ModelKit.tile("hex_grass"), pos)
			if dist > 5.0 and rng.randf() < 0.55:
				var pick: String = ["tree_single_A", "tree_single_B", "rock_single_A", "rock_single_C", "trees_A_small", "trees_B_small"][rng.randi() % 6]
				ModelKit.place(self, ModelKit.nature(pick), pos + Vector3(rng.randf_range(-0.4, 0.4), 0, rng.randf_range(-0.4, 0.4)), rng.randf() * 360.0, 1.3)
	for side: int in [-1, 1]:
		ModelKit.place(self, ModelKit.prop("flag_blue"), Vector3(side * 5.0, 0, 0), 0.0, 2.0)
	for i: int in range(5):
		var far: Vector3 = HexGrid.cell_to_world(-4 + i * 2, -7)
		ModelKit.place(self, ModelKit.nature("mountain_A_grass_trees"), far, 0.0, 1.5)
	_camera = Camera3D.new()
	_camera.fov = 45.0
	add_child(_camera)
	_camera.current = true
	StyleRig.install(self, StylePresets.BATTLE, _camera)
	_add_lights()
	_update_camera()


func _process(delta: float) -> void:
	_time += delta
	_update_camera()


func _update_camera() -> void:
	_camera.position = Vector3(sin(_time * 0.08) * 2.5, 9.0, 9.5)
	_camera.look_at(Vector3(0, 0.5, 0.5), Vector3.UP)


## A warm light pool over the play area and a cool back light: the board glows, the surround falls away into violet shade so the cards pop.
func _add_lights() -> void:
	var pool: SpotLight3D = SpotLight3D.new()
	pool.name = "PlayAreaPool"
	pool.light_color = Color("ffd8a0")
	pool.light_energy = 22.0
	pool.spot_range = 34.0
	pool.spot_angle = 34.0
	pool.spot_angle_attenuation = 2.4
	pool.spot_attenuation = 0.9
	pool.shadow_enabled = false
	pool.position = Vector3(0.0, 16.0, 5.0)
	pool.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	add_child(pool)
	var back: OmniLight3D = OmniLight3D.new()
	back.name = "CoolBackLight"
	back.light_color = Color("7a8cff")
	back.light_energy = 2.2
	back.omni_range = 26.0
	back.shadow_enabled = false
	back.position = Vector3(0.0, 5.0, -12.0)
	add_child(back)
