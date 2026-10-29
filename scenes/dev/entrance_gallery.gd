extends Control
## Overnight Oct 28-29 (art batch Part 2): every boss / lieutenant / gatekeeper entrance (`BossIntros`), held on its full card with the cut-out
## the battle would use (`Bestiary.cutout`, Primm once per phase), captured one after another into a single contact sheet with each name under it.
## Windowed run: Godot --path . --resolution 1600x900 res://scenes/dev/entrance_gallery.tscn  -> _screenshots/oct28/entrances.png
## Also prints which picture each entrance used (cut-out / portrait / square).

const CELL: Vector2i = Vector2i(400, 225)
const COLUMNS: int = 6
const OUT: String = "res://_screenshots/oct28/entrances.png"

var _backdrop: ColorRect


func _ready() -> void:
	Session.save_enabled = false
	UIKit.full_rect(self)
	_backdrop = ColorRect.new()
	# About the battle board's middle tone, so the dark halo and a pale coat are judged against something like the real board.
	_backdrop.color = Color(0.42, 0.36, 0.3)
	UIKit.full_rect(_backdrop)
	add_child(_backdrop)
	_run.call_deferred()


func _run() -> void:
	var jobs: Array[Array] = []
	var names: Array[String] = BossIntros.keys()
	names.sort()
	for enemy_name: String in names:
		if enemy_name == "Primm":
			for phase: int in range(3):
				jobs.append([enemy_name, phase])
		else:
			jobs.append([enemy_name, -1])
	var rows: int = int(ceil(float(jobs.size()) / float(COLUMNS)))
	var sheet: Image = Image.create_empty(CELL.x * COLUMNS, CELL.y * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.1, 0.1, 0.1))
	for index: int in range(jobs.size()):
		var enemy_name: String = str(jobs[index][0])
		var phase: int = int(jobs[index][1])
		var cutout: Texture2D = Bestiary.cutout(enemy_name, phase)
		var intro: BossIntro = BossIntro.new()
		add_child(intro)
		intro.play(enemy_name, Bestiary.art(enemy_name), "", cutout)
		intro.hold()
		for frame: int in range(4):
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var shot: Image = get_viewport().get_texture().get_image()
		shot.convert(Image.FORMAT_RGBA8)
		shot.resize(CELL.x, CELL.y, Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(shot, Rect2i(Vector2i.ZERO, CELL), Vector2i((index % COLUMNS) * CELL.x, (index / COLUMNS) * CELL.y))
		var id: String = Bestiary.cutout_id(enemy_name)
		var kind: String = "square" if cutout == null else ("cut-out" if Portraits.has_portrait(id) else "portrait")
		print("entrance %d: %s%s -> %s %s" % [index, enemy_name, (" (phase %d)" % (phase + 1)) if phase >= 0 else "", kind,
			id + ("_" + Bestiary.phase_cutout_expression(enemy_name, phase) if not Bestiary.phase_cutout_expression(enemy_name, phase).is_empty() else "")])
		intro.queue_free()
		await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_screenshots/oct28"))
	sheet.save_png(OUT)
	print("entrance gallery: %d entrances -> %s" % [jobs.size(), OUT])
	get_tree().quit()
