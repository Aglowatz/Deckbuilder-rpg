extends Node
## Batch 11 (Nov 2): one screenshot per cutscene / epilogue beat that has a story still behind it, through the real CutsceneScreen and
## EndingScreen (the typewriter finished, the beat's still faded in), plus a contact sheet of them all.
## Run (NOT headless): Godot --path . --resolution 1600x900 res://tools/beat_shots.tscn [-- --only=primm_end,epilogue]
## Out: _screenshots/beats/<scene>_<n>.jpg and _screenshots/beats/contact.jpg (labelled cells, 4 columns).

const OUT: String = "res://_screenshots/beats/"
const WAIT: float = 1.8
const CELL: Vector2i = Vector2i(480, 270)
const COLUMNS: int = 4

var _cells: Array[Dictionary] = []


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var only: PackedStringArray = PackedStringArray()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--only="):
			only = arg.get_slice("=", 1).split(",")
	Session.ensure_game()
	for scene_id: String in CutsceneDefs.SCENES.keys():
		if not only.is_empty() and not only.has(scene_id):
			continue
		for beat: Dictionary in CutsceneDefs.beats(scene_id):
			var n: int = int(beat["n"])
			if StoryStills.cutscene_backdrop(scene_id, n) == "":
				continue
			var screen: CutsceneScreen = CutsceneScreen.make(scene_id)
			screen.set("_index", CutsceneDefs.beats(scene_id).find(beat))
			await _capture(screen, "%s_%d" % [scene_id, n], StoryStills.cutscene_backdrop(scene_id, n))
	if only.is_empty() or only.has("epilogue"):
		for index: int in EndingDefs.BEATS.size():
			var beat: Dictionary = EndingDefs.BEATS[index]
			var still: String = StoryStills.ending_backdrop(str(beat["fx"]))
			if still == "":
				continue
			var ending: Control = (load("res://scenes/ending.tscn") as PackedScene).instantiate() as Control
			ending.call("screenshot_prepare", {"beat": index, "nostill": true})
			await _capture(ending, "epilogue_%d" % int(beat["n"]), still)
	_contact()
	get_tree().quit()


func _capture(screen: Control, name: String, still: String) -> void:
	add_child(screen)
	await get_tree().create_timer(WAIT).timeout
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_jpg(ProjectSettings.globalize_path(OUT + name + ".jpg"), 0.85)
	image.resize(CELL.x, CELL.y, Image.INTERPOLATE_BILINEAR)
	_cells.append({"name": "%s  (%s)" % [name, still.trim_prefix("STORY-")], "image": image})
	print("beat shot ", name, " ", still)
	screen.queue_free()
	await get_tree().process_frame


## The cells in a grid; each cell's name is drawn by the label row of the tool's own report (the sheet itself has no text renderer).
func _contact() -> void:
	if _cells.is_empty():
		return
	var rows: int = ceili(float(_cells.size()) / float(COLUMNS))
	var sheet: Image = Image.create(COLUMNS * CELL.x, rows * CELL.y, false, Image.FORMAT_RGB8)
	var names: PackedStringArray = PackedStringArray()
	for i: int in _cells.size():
		var image: Image = _cells[i]["image"] as Image
		image.convert(Image.FORMAT_RGB8)
		sheet.blit_rect(image, Rect2i(Vector2i.ZERO, CELL), Vector2i((i % COLUMNS) * CELL.x, (i / COLUMNS) * CELL.y))
		names.append("%d. %s" % [i + 1, str(_cells[i]["name"])])
	sheet.save_jpg(ProjectSettings.globalize_path(OUT + "contact.jpg"), 0.85)
	var file: FileAccess = FileAccess.open(OUT + "contact.txt", FileAccess.WRITE)
	file.store_string("Left to right, top to bottom (%d columns):\n%s\n" % [COLUMNS, "\n".join(names)])
	file.close()
