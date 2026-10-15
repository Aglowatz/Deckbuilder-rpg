extends SceneTree
## Paint-over inputs and camera contact sheets for one area, in one windowed process (run alone, see docs/art/art_pipeline.md):
##   Godot --path . --resolution 1600x900 -s res://tools/zone_shots.gd -- --area=gainlands [--mode=po|grid|both] [--out=res://_screenshots/gainlands_slice]|grid|both]
## po:   docs/art/paintover_inputs/<area>/PO-<AREA>-HUB.png, 1600x900, Cinematic / Normal, hero visible, no UI, no world labels (one shot per area: there
##       are no sub-area scenes, docs/design/subarea_removal.md; regions of a zone are shot with `bash tools/shot.sh <scene> <name> --at=<anchor>`).
## grid: docs/art/zone_plans_shots/<area>.png, the area at the 9 angle x zoom combinations.

const HUBS: Dictionary = {
	"main_town": ["res://scenes/town.tscn", {"at": "spawn"}],
	"starting_forest": ["res://scenes/starting_area.tscn", {"quiet": "true"}],
	"gainlands": ["res://scenes/gainlands_zone.tscn", {"at": "spawn"}],
	"dna": ["res://scenes/dna_zone.tscn", {"at": "lobby_center"}],  # the paint-over was made from the lobby (the spawn moved onto the approach causeway, DN-6)
	"buffet": ["res://scenes/buffet_zone.tscn", {"at": "plaza"}],  # the paint-over was made from the plaza (the spawn moved onto the bridge, BF-8)
	"heap": ["res://scenes/heap_zone.tscn", {"at": "po_hub"}],  # the paint-over is shot from the plaza (the spawn moved onto the entrance bridge, VD-3)
	"capital_outside": ["res://scenes/capital_zone.tscn", {"at": "spawn"}],
	"capital_inside": ["res://scenes/capital_zone.tscn", {"at": "gate_inside"}],
}
const ANGLES: Array[int] = [0, 1, 2]
const ZOOMS: Array[float] = [1.2, 1.5, 1.9]

var _area: String = ""
var _mode: String = "both"
var _jobs: Array[Dictionary] = []
var _job: int = -1
var _scene: Node
var _elapsed: float = 0.0
var _started: bool = false
var _wait: float = 2.2
var _grid: Array[Image] = []
var _grid_index: int = 0
var _phase: String = "po"
var _out: String = ""


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--area="):
			_area = arg.trim_prefix("--area=")
		if arg.begins_with("--mode="):
			_mode = arg.trim_prefix("--mode=")
		if arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=").trim_suffix("/")
	var session: Node = root.get_node_or_null("Session")
	if session != null:
		session.set("save_enabled", false)
	if _mode == "grid":
		_phase = "grid"
	_build_jobs()


func _read(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _build_jobs() -> void:
	if not HUBS.has(_area):
		push_error("zone_shots: unknown area %s (one of %s)" % [_area, ", ".join(HUBS.keys())])
		quit(1)
		return
	var hub: Array = HUBS[_area] as Array
	var args: Dictionary = (hub[1] as Dictionary).duplicate()
	args["nohud"] = "true"
	_jobs.append({"scene": hub[0], "args": args, "name": "PO-%s-HUB" % _area.to_upper().replace("_", "-")})


func _settings() -> Node:
	return root.get_node_or_null("Settings")


func _process(delta: float) -> bool:
	if _phase == "done":
		return true
	if _phase == "po" and _mode == "grid":
		_phase = "grid"
	if _phase == "po":
		return _step_po(delta)
	return _step_grid(delta)


func _start_scene(path: String, args: Dictionary) -> void:
	var packed: PackedScene = load(path) as PackedScene
	_scene = packed.instantiate()
	if _scene.has_method("screenshot_prepare"):
		_scene.call("screenshot_prepare", args)
	root.add_child(_scene)
	_elapsed = 0.0


func _clean_view() -> void:
	for label: Node in root.find_children("*", "Label3D", true, false):
		(label as Label3D).visible = false
	for mesh: Node in root.find_children("*", "MeshInstance3D", true, false):
		if (mesh as MeshInstance3D).mesh is PrismMesh:
			(mesh as MeshInstance3D).visible = false


func _step_po(delta: float) -> bool:
	if _job < 0 or _scene == null:
		_job += 1
		if _job >= _jobs.size():
			if _mode == "po":
				_phase = "done"
				quit(0)
			else:
				_phase = "grid"
			return false
		var settings: Node = _settings()
		if settings != null:
			settings.set("camera_angle", 0)
			settings.set("camera_zoom", 1.5)
		_start_scene(str(_jobs[_job]["scene"]), _jobs[_job]["args"] as Dictionary)
		return false
	_elapsed += delta
	if _elapsed < _wait:
		return false
	_clean_view()
	if _elapsed < _wait + 0.3:
		return false
	var image: Image = root.get_texture().get_image()
	var dir: String = _out if _out != "" else "res://docs/art/paintover_inputs/%s" % _area
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var path: String = "%s/%s.png" % [dir, str(_jobs[_job]["name"])]
	image.save_png(ProjectSettings.globalize_path(path))
	print("saved ", path, " ", image.get_width(), "x", image.get_height())
	_scene.queue_free()
	_scene = null
	return false


func _step_grid(delta: float) -> bool:
	if _scene == null:
		var hub: Array = HUBS[_area] as Array
		var args: Dictionary = (hub[1] as Dictionary).duplicate()
		args["nohud"] = "true"
		_start_scene(str(hub[0]), args)
		_grid_index = 0
		_apply_combo()
		return false
	_elapsed += delta
	if _elapsed < (_wait + 1.0 if _grid_index == 0 else 1.6):
		return false
	_clean_view()
	var image: Image = root.get_texture().get_image()
	image.resize(800, 450, Image.INTERPOLATE_BILINEAR)
	_grid.append(image)
	_grid_index += 1
	_elapsed = 0.0
	if _grid_index >= 9:
		var sheet: Image = Image.create(2400, 1350, false, Image.FORMAT_RGB8)
		for index: int in range(9):
			sheet.blit_rect(_grid[index], Rect2i(0, 0, 800, 450), Vector2i((index % 3) * 800, (index / 3) * 450))
		var dir: String = _out if _out != "" else "res://docs/art/zone_plans_shots"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
		sheet.save_png(ProjectSettings.globalize_path("%s/%s.png" % [dir, _area]))
		print("contact sheet saved for ", _area)
		_phase = "done"
		quit(0)
		return true
	_apply_combo()
	return false


## Rows are angles (Cinematic, Classic, Overview), columns zooms (Close, Normal, Far).
func _apply_combo() -> void:
	var settings: Node = _settings()
	if settings != null:
		settings.set("camera_angle", ANGLES[_grid_index / 3])
		settings.set("camera_zoom", ZOOMS[_grid_index % 3])
