extends Control
## Art import Oct 29 (Part 1): every story still that sits behind a scene's own narration (`StoryStills.BACKDROP_IDS`), played in its real
## screen - the dungeon cutscene, the ending beat, the story scene in the dialogue box, the memory fragment - with its first lines typed out,
## captured one after another into one contact sheet (and one full-size picture each with --full=true).
## Windowed run: Godot --path . --resolution 1600x900 res://scenes/dev/still_gallery.tscn [-- --full=true]  -> _screenshots/oct29/stills.png

const CELL: Vector2i = Vector2i(640, 360)
const COLUMNS: int = 3
const OUT_DIR: String = "res://_screenshots/oct29"

var _full: bool = false


func _ready() -> void:
	Session.save_enabled = false
	Session.ensure_game()
	UIKit.full_rect(self)
	var base: ColorRect = ColorRect.new()
	base.color = Color(0.2, 0.25, 0.2)
	UIKit.full_rect(base)
	add_child(base)
	_full = OS.get_cmdline_user_args().has("--full=true")
	_run.call_deferred()


func _jobs() -> Array[Array]:
	var jobs: Array[Array] = []
	for scene_id: String in ["wonder", "vacancy", "sever", "primm_intro", "primm_reveal"]:
		jobs.append(["cutscene", scene_id])
	for index: int in range(EndingDefs.BEATS.size()):
		if not StoryStills.ending_backdrop(str(EndingDefs.BEATS[index]["fx"])).is_empty():
			jobs.append(["ending", str(index)])
	for scene_id: String in ["pc_capture", "lab_cell4", "royal_funeral", "isla_homecoming"]:
		jobs.append(["scene", scene_id])
	for number: int in range(1, MemoryDefs.COUNT + 1):
		jobs.append(["memory", str(number)])
	return jobs


func _run() -> void:
	var jobs: Array[Array] = _jobs()
	var rows: int = int(ceil(float(jobs.size()) / float(COLUMNS)))
	var sheet: Image = Image.create_empty(CELL.x * COLUMNS, CELL.y * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.1, 0.1, 0.1))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for index: int in range(jobs.size()):
		var kind: String = str(jobs[index][0])
		var key: String = str(jobs[index][1])
		var holder: Control = Control.new()
		UIKit.full_rect(holder)
		add_child(holder)
		var still: String = ""
		match kind:
			"cutscene":
				holder.add_child(CutsceneScreen.make(key))
				still = StoryStills.cutscene_backdrop(key)
			"ending":
				var ending: EndingScreen = EndingScreen.new()
				ending.screenshot_prepare({"beat": int(key), "nostill": true})
				holder.add_child(ending)
				still = StoryStills.ending_backdrop(str(EndingDefs.BEATS[int(key)]["fx"]))
			"scene":
				var dialogue: DialogueBox = DialogueBox.new()
				holder.add_child(dialogue)
				StoryScenePlayer.play(dialogue, key)
				still = StoryStills.scene_backdrop(key)
			"memory":
				var number: int = int(key)
				var story: StoryText = StoryText.shared()
				holder.add_child(MemoryScreen.make(number, story.text(MemoryDefs.key(number, "title")), story.get_lines(MemoryDefs.key(number, "fragment"))))
				still = StoryStills.memory_backdrop(number)
		await get_tree().create_timer(3.2).timeout
		if kind == "memory":
			# Two more lines, so the shot shows how a few lines read over the picture.
			var screen: MemoryScreen = holder.get_child(0) as MemoryScreen
			screen.call("_next_line")
			await get_tree().create_timer(1.3).timeout
			screen.call("_next_line")
			await get_tree().create_timer(1.3).timeout
		await RenderingServer.frame_post_draw
		var shot: Image = get_viewport().get_texture().get_image()
		shot.convert(Image.FORMAT_RGBA8)
		if _full:
			shot.save_png("%s/still_%s.png" % [OUT_DIR, still.to_lower()])
		shot.resize(CELL.x, CELL.y, Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(shot, Rect2i(Vector2i.ZERO, CELL), Vector2i((index % COLUMNS) * CELL.x, (index / COLUMNS) * CELL.y))
		print("still %d: %s %s -> %s (in game: %s)" % [index, kind, key, still, str(KeyArt.has(still))])
		holder.queue_free()
		await get_tree().create_timer(0.3).timeout
	sheet.save_png(OUT_DIR + "/stills.png")
	print("still gallery: %d scenes -> %s/stills.png" % [jobs.size(), OUT_DIR])
	get_tree().quit()
