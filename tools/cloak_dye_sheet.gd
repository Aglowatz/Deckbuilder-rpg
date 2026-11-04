extends Node
## Overnight Nov 3-4, Part D3: the cloak dye check. The hero's plain cloak in every direction (FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK), idle and
## walking, in a row of dyes (natural first), rendered the way the world draws the sprite. Windowed (a scene, so the autoloads exist):
##   Godot --path . --resolution 1200x900 res://tools/cloak_dye_sheet.tscn -- --out=res://docs/overnight_shots/nov3/cloak_dye_sheet.png [--dyes=-1,0,3,8]
## Rows: one per dye x pose; columns: the five directions.

const DIRS: Array[String] = ["FRONT", "FRONTSIDE", "SIDE", "BACKSIDE", "BACK"]
const POSES: Array[String] = ["IDLE", "WALK2"]
const CELL: Vector2i = Vector2i(180, 240)

var _args: Dictionary = {}
var _view: SubViewport
var _camera: Camera3D
var _sprite: WorldSprite
var _jobs: Array[Dictionary] = []
var _job: int = -1
var _settle: int = 0
var _cells: Array[Image] = []
var _dyes: Array[int] = []


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	for value: String in str(_args.get("dyes", "-1,0,3,6,9")).split(",", false):
		_dyes.append(int(value))
	_view = SubViewport.new()
	_view.size = Vector2i(450, 600)
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_view)
	var scene: Node3D = Node3D.new()
	_view.add_child(scene)
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.55, 0.62, 0.7)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.8, 0.8, 0.9)
	env.ambient_light_energy = 0.7
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.environment = env
	scene.add_child(world_env)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40.0, -30.0, 0.0)
	scene.add_child(sun)
	_camera = Camera3D.new()
	_camera.fov = 38.0
	scene.add_child(_camera)
	_camera.look_at_from_position(Vector3(0.0, 1.6, 4.4), Vector3(0.0, 0.85, 0.0), Vector3.UP)
	_camera.current = true
	_sprite = WorldSprite.new()
	_sprite.turn_rate_degrees = 100000.0
	scene.add_child(_sprite)
	_sprite.setup("PLAYER", _camera, Vector3(0.42, -0.62, -0.67))
	for dye: int in _dyes:
		for pose: String in POSES:
			for dir_name: String in DIRS:
				_jobs.append({"dye": dye, "key": "%s_%s" % [dir_name, pose]})


func _process(_delta: float) -> void:
	if _job >= _jobs.size():
		return
	if _settle > 0:
		_settle -= 1
		_sprite.follow(Vector3.ZERO, 0.016)
		if _settle == 0:
			var image: Image = _view.get_texture().get_image()
			image.resize(CELL.x, CELL.y, Image.INTERPOLATE_LANCZOS)
			_cells.append(image)
		return
	_job += 1
	if _job >= _jobs.size():
		_save()
		get_tree().quit()
		return
	var job: Dictionary = _jobs[_job]
	var dye: int = int(job["dye"])
	_sprite.set_dye(Dye.primary(dye) if dye >= 0 else Color.WHITE, 1.0 if dye >= 0 else 0.0)
	_sprite.forced_key = str(job["key"])
	_sprite.snap_heading(Vector3(0.0, 0.0, 1.0))
	_sprite.follow(Vector3.ZERO, 0.016)
	_settle = 3


func _save() -> void:
	var columns: int = DIRS.size()
	var rows: int = int(ceil(float(_cells.size()) / float(columns)))
	var sheet: Image = Image.create_empty(CELL.x * columns, CELL.y * rows, false, _cells[0].get_format())
	for index: int in _cells.size():
		sheet.blit_rect(_cells[index], Rect2i(Vector2i.ZERO, CELL), Vector2i((index % columns) * CELL.x, (index / columns) * CELL.y))
	var out: String = str(_args.get("out", "res://_screenshots/cloak_dye_sheet.png"))
	sheet.save_png(ProjectSettings.globalize_path(out))
	print("cloak_dye_sheet: %d cells -> %s" % [_cells.size(), out])
