extends Node
## Overnight Oct 29, Part 4: the hat contact sheet. Every hat x every direction x idle / walk1-4 (/ talk when the hero has one), each cell twice: as the
## world draws it (a camera like the town's, body scale 1) and as the wardrobe / tailor preview draws it (the real `HeroPreview`: fov 26, 7 m, body
## scale 1.25). One PNG per hat, head-centred crops, plus a numeric table of where each hat's band lands against the brow line (stdout and
## _screenshots/<out>/fit_table.md). Windowed (a scene, so the autoloads exist):
##   Godot --path . --resolution 1200x900 res://tools/hat_contact_sheet.tscn -- --out=oct29/hats_before [--hats=WIZARD,CHEF] [--frames=idle,walk]
## Output: _screenshots/<out>/<HAT>.png (columns: FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK, each world | preview; rows: idle, walk1-4).

const DIRS: Array[String] = ["FRONT", "FRONTSIDE", "SIDE", "BACKSIDE", "BACK"]
const ALL_HATS: Array[String] = ["WIDEBRIM", "CHEF", "BOWLER", "TRICORN", "WIZARD", "LEAFCROWN"]
const CELL: int = 176
## Where the brow sits below the crown's top row, in head widths, per direction (the band of a hat should land here).
const BROW: Dictionary = {"FRONT": 0.46, "FRONTSIDE": 0.48, "SIDE": 0.46, "BACKSIDE": 0.6, "BACK": 0.7}

var _args: Dictionary = {}
var _hats: Array[String] = []
var _poses: Array[String] = []
var _world_view: SubViewport
var _world_camera: Camera3D
var _world_sprite: WorldSprite
var _preview: HeroPreview
var _jobs: Array[Dictionary] = []
var _job: int = -1
var _settle: int = 0
var _cells: Dictionary = {}  # "HAT|pose|dir|rig" -> Image
var _lines: PackedStringArray = []


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	for name: String in str(_args.get("hats", ",".join(ALL_HATS))).split(",", false):
		_hats.append(name)
	var frames: String = str(_args.get("frames", "idle,walk"))
	if frames.contains("idle"):
		_poses.append("IDLE")
	if frames.contains("walk"):
		for n: int in range(1, 5):
			_poses.append("WALK%d" % n)
	# The world rig: a camera like the town's (fov 38), close enough that the head is about 90 px across.
	_world_view = SubViewport.new()
	_world_view.size = Vector2i(600, 800)
	_world_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_world_view)
	var scene: Node3D = Node3D.new()
	_world_view.add_child(scene)
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
	_world_camera = Camera3D.new()
	_world_camera.fov = 38.0
	scene.add_child(_world_camera)
	_world_camera.look_at_from_position(Vector3(0.0, 2.1, 4.2), Vector3(0.0, 1.45, 0.0), Vector3.UP)
	_world_camera.current = true
	_world_sprite = WorldSprite.new()
	_world_sprite.turn_rate_degrees = 100000.0
	scene.add_child(_world_sprite)
	_world_sprite.setup("PLAYER", _world_camera, Vector3(0.42, -0.62, -0.67))
	# The preview rig: the wardrobe's own widget.
	_preview = HeroPreview.new()
	_preview.look = CosmeticState.new()
	var holder: CanvasLayer = CanvasLayer.new()
	add_child(holder)
	holder.add_child(_preview)
	_preview.position = Vector2(620, 0)
	_preview.set_process(false)
	_preview.viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	for hat: String in _hats:
		for pose: String in _poses:
			for dir_name: String in DIRS:
				_jobs.append({"hat": hat, "pose": pose, "dir": dir_name})
	_write_fit_table()
	print("hat_contact_sheet: %d cells x 2 rigs" % _jobs.size())


func _process(_delta: float) -> void:
	if _job >= _jobs.size():
		return
	if _settle > 0:
		_settle -= 1
		_world_sprite.follow(Vector3.ZERO, 0.016)
		_preview.sprite.follow(Vector3.ZERO, 0.016)
		if _settle == 0:
			_capture(_jobs[_job])
		return
	_job += 1
	if _job >= _jobs.size():
		_save()
		get_tree().quit()
		return
	var job: Dictionary = _jobs[_job]
	var key: String = "%s_%s" % [str(job["dir"]), str(job["pose"])]
	for sprite: WorldSprite in [_world_sprite, _preview.sprite]:
		sprite.set_hat(str(job["hat"]))
		sprite.forced_key = key
		sprite.snap_heading(Vector3(0.0, 0.0, 1.0))
		sprite.follow(Vector3.ZERO, 0.016)
	_settle = 3


## Crops a head-centred square from each rig: the crown sits a third of the way down the cell, so the whole hat shows above it.
func _capture(job: Dictionary) -> void:
	var key: String = "%s|%s|%s" % [str(job["hat"]), str(job["pose"]), str(job["dir"])]
	_cells[key + "|world"] = _crop(_world_view.get_texture().get_image(), _world_camera, _world_sprite, 1.0)
	_cells[key + "|preview"] = _crop(_preview.viewport.get_texture().get_image(), _preview._camera, _preview.sprite, 1.25)


func _crop(image: Image, camera: Camera3D, sprite: WorldSprite, body_scale: float) -> Image:
	var crown: Vector3 = sprite.global_position + Vector3(0.0, sprite.world_height * body_scale, 0.0)
	var top: Vector2 = camera.unproject_position(crown)
	var chin: Vector2 = camera.unproject_position(crown - Vector3(0.0, 0.3 * body_scale, 0.0))
	var side: float = (chin.y - top.y) * 4.0
	var origin: Vector2i = Vector2i(int(top.x - side * 0.5), int(top.y - side * 0.4))
	var rect: Rect2i = Rect2i(origin, Vector2i(int(side), int(side))).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var cell: Image = Image.create_empty(CELL, CELL, false, image.get_format())
	if rect.size.x > 0 and rect.size.y > 0:
		var part: Image = image.get_region(rect)
		part.resize(CELL, CELL, Image.INTERPOLATE_LANCZOS)
		cell.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), Vector2i.ZERO)
	return cell


func _save() -> void:
	var folder: String = "res://_screenshots/%s" % str(_args.get("out", "hats"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for hat: String in _hats:
		var sheet: Image = Image.create_empty(CELL * DIRS.size() * 2 + 8 * (DIRS.size() - 1), CELL * _poses.size(), false, Image.FORMAT_RGBA8)
		sheet.fill(Color(0.12, 0.12, 0.14))
		for row: int in range(_poses.size()):
			for column: int in range(DIRS.size()):
				var x: int = column * (CELL * 2 + 8)
				for rig_index: int in range(2):
					var rig: String = ["world", "preview"][rig_index]
					var cell: Image = _cells.get("%s|%s|%s|%s" % [hat, _poses[row], DIRS[column], rig]) as Image
					if cell != null:
						cell.convert(Image.FORMAT_RGBA8)
						sheet.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(x + rig_index * CELL, row * CELL))
		var path: String = ProjectSettings.globalize_path("%s/%s.png" % [folder, hat])
		sheet.save_png(path)
		print("hat_contact_sheet: saved %s" % path)
	# --combined=1: the hat sheets stacked into one PNG (one screenshot for every hat).
	if str(_args.get("combined", "0")) == "1":
		var sheets: Array[Image] = []
		for hat: String in _hats:
			var one: Image = Image.load_from_file(ProjectSettings.globalize_path("%s/%s.png" % [folder, hat]))
			if one != null:
				sheets.append(one)
		if not sheets.is_empty():
			var all: Image = Image.create_empty(sheets[0].get_width(), sheets[0].get_height() * sheets.size() + 12 * (sheets.size() - 1), false, Image.FORMAT_RGBA8)
			all.fill(Color(0.3, 0.1, 0.1))
			var y: int = 0
			for one: Image in sheets:
				one.convert(Image.FORMAT_RGBA8)
				all.blit_rect(one, Rect2i(Vector2i.ZERO, one.get_size()), Vector2i(0, y))
				y += one.get_height() + 12
			all.save_png(ProjectSettings.globalize_path("%s/ALL.png" % folder))
			for hat: String in _hats:
				DirAccess.remove_absolute(ProjectSettings.globalize_path("%s/%s.png" % [folder, hat]))
			print("hat_contact_sheet: saved %s/ALL.png (the per-hat sheets folded in)" % folder)
	var table: FileAccess = FileAccess.open("%s/fit_table.md" % folder, FileAccess.WRITE)
	if table != null:
		table.store_string("\n".join(_lines) + "\n")


## The numbers behind the pictures: for every hat and direction, where the hat's band (its widest row in the bottom third, the brim or the
## toque's band) lands below the crown's top row, in head widths, against the brow line it should sit on (BROW). Negative "off" = too high.
func _write_fit_table() -> void:
	_lines = ["# Hat fit table (%s)" % Time.get_datetime_string_from_system(), "", "| Hat | Dir | Card w (hw) | Card h (hw) | Sink | Band from bottom (hw) | Band below crown (hw) | Brow (hw) | Off (hw) | Band / head width |", "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|"]
	for hat: String in _hats:
		for dir_name: String in DIRS:
			var texture: Texture2D = SpriteLibrary.hat_texture(hat, dir_name)
			if texture == null:
				continue
			var fit: Dictionary = SpriteLibrary.hat_fit(hat, dir_name)
			var image: Image = texture.get_image()
			var card_w: float = float(fit["width"]) * float(fit["scale"])
			var card_h: float = card_w * float(image.get_height()) / float(image.get_width())
			var band: Dictionary = _band(image)
			var band_from_bottom: float = card_h * (1.0 - float(band["y"]) / float(image.get_height()))
			var sink: float = float(fit["sink"]) - float(fit["dy"])
			var band_below_crown: float = sink - band_from_bottom
			var brow: float = float(BROW[dir_name])
			var band_hw: float = card_w * float(band["width"]) / float(image.get_width())
			_lines.append("| %s | %s | %.2f | %.2f | %.2f | %.2f | %.2f | %.2f | %+.2f | %.2f |" % [hat, dir_name, card_w, card_h, sink, band_from_bottom, band_below_crown, brow, band_below_crown - brow, band_hw])
			print(_lines[_lines.size() - 1])


## The widest opaque row in the bottom 40 % of a hat view: {"y": row, "width": px, "cx": middle x}.
static func _band(image: Image) -> Dictionary:
	var w: int = image.get_width()
	var h: int = image.get_height()
	var best: Dictionary = {"y": h - 1, "width": 0, "cx": w * 0.5}
	for y: int in range(h - 1 - int(h * 0.4), h):
		var left: int = -1
		var right: int = -1
		for x: int in range(w):
			if image.get_pixel(x, y).a > 0.5:
				if left < 0:
					left = x
				right = x
		if left >= 0 and right - left + 1 > int(best["width"]):
			best = {"y": y, "width": right - left + 1, "cx": float(left + right) * 0.5}
	return best
