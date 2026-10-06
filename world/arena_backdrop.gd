class_name ArenaBackdrop
extends Node3D
## The 3D scene behind the battle table: a small hex meadow at dusk with banners and mountains,
## seen from a slowly swaying camera. It is dimmed by the battle screen so cards stay readable.

var _camera: Camera3D
var _time: float = 0.0


func _ready() -> void:
	GroundDecals.begin(Settings.graphics_quality)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 11
	var paint_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	paint_rng.seed = 29
	for row: int in range(-4, 5):
		for col: int in range(-5, 6):
			var pos: Vector3 = HexGrid.cell_to_world(col, row)
			var dist: float = Vector2(pos.x, pos.z).length()
			if dist > 9.5:
				var water: Node3D = ModelKit.tile("hex_water")
				ModelKit.place(self, water, pos)
				continue
			ModelKit.place(self, ModelKit.tile("hex_grass"), pos)
			_paint_tile(paint_rng, pos, dist)
			if dist > 5.0 and rng.randf() < 0.55:
				var pick: String = ["tree_single_A", "tree_single_B", "rock_single_A", "rock_single_C", "trees_A_small", "trees_B_small"][rng.randi() % 6]
				ModelKit.place(self, ModelKit.nature(pick), pos + Vector3(rng.randf_range(-0.4, 0.4), 0, rng.randf_range(-0.4, 0.4)), rng.randf() * 360.0, 1.3)
	for side: int in [-1, 1]:
		ModelKit.place(self, ModelKit.prop("flag_blue"), Vector3(side * 5.0, 0, 0), 0.0, 2.0)
	_dress_ring()
	_add_landmark()
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


## Painted variation on a grass tile: moss, packed earth and worn stone patches so no tile is one flat colour; the play area stays calmer than the rim.
func _paint_tile(rng: RandomNumberGenerator, pos: Vector3, dist: float) -> void:
	var count: int = 2 if dist > 5.0 else 1
	for i: int in range(count):
		var offset: Vector3 = Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(-0.7, 0.7))
		var kind: GroundDecals.Kind = [GroundDecals.Kind.MOSS_PATCH, GroundDecals.Kind.DIRT_PATCH, GroundDecals.Kind.STAIN][rng.randi() % 3]
		var palette: Array[Color] = []
		match kind:
			GroundDecals.Kind.MOSS_PATCH:
				palette = [Color("4f7a3a"), Color("6a9a48")]
			GroundDecals.Kind.DIRT_PATCH:
				palette = [Color("7e7a50"), Color("676442"), Color("4e4a34")]
			_:
				palette = [Color("5a5a64"), Color("7a7a80")]
		GroundDecals.add_patch(self, pos + offset + Vector3(0.0, 0.45, 0.0), rng.randf_range(0.7, 1.1), kind, palette, rng.randf() * 40.0, rng.randf_range(0.8, 1.0), rng.randf() * 180.0)


## A ring of small set dressing (rocks, crates, barrels, sacks, lumber) on the rim only: clusters of three, nothing inside the play area or around the banners.
func _dress_ring() -> void:
	var scatter: ScatterTool = ScatterTool.new()
	scatter.seed_value = 41
	scatter.bounds = Rect2(-12.0, -9.0, 24.0, 18.0)
	scatter.is_floor = func(pos: Vector3) -> bool:
		var radius: float = Vector2(pos.x, pos.z).length()
		return radius > 5.6 and radius < 9.0 and pos.z < 2.5 and (absf(pos.x) > 3.5 or pos.z < -3.0)
	for side: int in [-1, 1]:
		scatter.keep_out_circles.append(Vector3(side * 5.0, 0.0, 1.5))
	var nature: String = "decoration/nature"
	var props: String = "decoration/props"
	var entries: Array[ScatterTool.Entry] = [
		ScatterTool.Entry.make(nature, "rock_single_B", 2.0, 1.0, 1.5, 0.08),
		ScatterTool.Entry.make(nature, "rock_single_D", 2.0, 1.0, 1.5, 0.08),
		ScatterTool.Entry.make(nature, "rock_single_E", 1.5, 1.0, 1.4, 0.08),
		ScatterTool.Entry.make(props, "barrel", 1.0, 1.0, 1.3),
		ScatterTool.Entry.make(props, "crate_A_big", 1.0, 1.0, 1.3),
		ScatterTool.Entry.make(props, "sack", 1.0, 1.0, 1.4),
		ScatterTool.Entry.make(props, "resource_lumber", 0.6, 1.0, 1.2),
		ScatterTool.Entry.make(nature, "tree_single_A_cut", 0.6, 1.0, 1.3),
	]
	var count: int = [16, 28, 42][clampi(Settings.graphics_quality, 0, 2)]
	for placement: ScatterTool.Placement in scatter.scatter("battle_rim", entries, count, 3, 1.0):
		var node: Node3D = ModelKit.hex_model(placement.folder, placement.model)
		ModelKit.place(self, node, placement.position, rad_to_deg(placement.yaw), placement.scale * 1.7)


## The far-side focal point behind the enemy: a war tent between two tall banners with a warm lantern glow, so the board reads as a diorama with a destination.
func _add_landmark() -> void:
	var anchor: Vector3 = Vector3(0.0, 0.0, -6.3)
	ModelKit.place(self, ModelKit.prop("tent"), anchor, 0.0, 2.6)
	for side: int in [-1, 1]:
		ModelKit.place(self, ModelKit.prop("flag_blue"), anchor + Vector3(side * 3.2, 0.0, 0.8), side * 12.0, 3.4)
	ModelKit.place(self, ModelKit.prop("weaponrack"), anchor + Vector3(2.0, 0.0, 1.8), -20.0, 1.8)
	var glow: OmniLight3D = OmniLight3D.new()
	glow.light_color = Color("ffb867")
	glow.light_energy = 2.2
	glow.omni_range = 5.0
	glow.shadow_enabled = false
	glow.position = anchor + Vector3(0.0, 1.6, 2.0)
	add_child(glow)
