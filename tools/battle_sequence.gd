extends Node
## Battle feel (overnight Oct 28-29, Part 4): a practice battle the bot plays for you, filmed as a contact sheet - one frame every `--every`
## seconds from `--from` for `--frames` frames, each stamped with its time - so one turn's animations (cards flying, landing, lunges, numbers,
## deaths, resources, the turn banner) can be judged before / after on one picture.
## Windowed: Godot --path . --resolution 1600x900 res://tools/battle_sequence.tscn -- --path=beefcake --out=battle_seq_beefcake
##   [--from=6] [--every=0.2] [--frames=30] [--speed=0] [--enemy=Cave Scavenger] [--bot=8]
## Output: _screenshots/oct28/<out>.png (4 columns, 480 x 270 cells). Also prints the battle's turn at each frame.

const CELL: Vector2i = Vector2i(480, 270)
const COLUMNS: int = 4

var _args: Dictionary = {}
var _battle: Node
var _sheet: Image
var _index: int = 0
var _next_at: float = 0.0
var _time: float = 0.0
var _from: float = 6.0
var _every: float = 0.2
var _frames: int = 30


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--") and arg.contains("="):
			_args[arg.substr(2, arg.find("=") - 2)] = arg.substr(arg.find("=") + 1)
	_from = float(_args.get("from", "6"))
	_every = float(_args.get("every", "0.2"))
	_frames = int(_args.get("frames", "30"))
	Session.save_enabled = false
	var path_name: String = str(_args.get("path", "beefcake"))
	var types: Dictionary = {"beefcake": Affinity.Type.BEEFCAKE, "necrocrat": Affinity.Type.NECROCRAT, "gourmand": Affinity.Type.GOURMAND, "refusemancer": Affinity.Type.REFUSEMANCER}
	Session.ensure_game(types.get(path_name, Affinity.Type.BEEFCAKE) as Affinity.Type)
	Settings.battle_speed = clampi(int(_args.get("speed", "0")), 0, Settings.BATTLE_SPEEDS.size() - 1)
	var packed: PackedScene = load("res://scenes/battle.tscn") as PackedScene
	_battle = packed.instantiate()
	_battle.call("screenshot_prepare", {"enemy": str(_args.get("enemy", "Cave Scavenger")), "bot": str(_args.get("bot", "8")), "no_tutorial": "true", "no_intro": "true"})
	get_tree().root.add_child.call_deferred(_battle)
	var rows: int = int(ceil(float(_frames) / float(COLUMNS)))
	_sheet = Image.create_empty(CELL.x * COLUMNS, CELL.y * rows, false, Image.FORMAT_RGBA8)
	_sheet.fill(Color(0.08, 0.08, 0.08))
	_next_at = _from


func _process(delta: float) -> void:
	# Real time, so hit pauses and slow motion show as they feel.
	_time += delta / maxf(Engine.time_scale, 0.0001)
	if _time < _next_at or _index >= _frames:
		return
	_next_at += _every
	_capture.call_deferred()


func _capture() -> void:
	await RenderingServer.frame_post_draw
	var shot: Image = get_viewport().get_texture().get_image()
	shot.convert(Image.FORMAT_RGBA8)
	shot.resize(CELL.x, CELL.y, Image.INTERPOLATE_BILINEAR)
	_sheet.blit_rect(shot, Rect2i(Vector2i.ZERO, CELL), Vector2i((_index % COLUMNS) * CELL.x, (_index / COLUMNS) * CELL.y))
	var game: GameState = _battle.get("game") as GameState if is_instance_valid(_battle) else null
	print("frame %d at %.2f s: turn %d, active %d" % [_index, _time, game.turn if game != null else -1, game.active if game != null else -1])
	_index += 1
	if _index >= _frames:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_screenshots/oct28"))
		var out: String = "res://_screenshots/oct28/%s.png" % str(_args.get("out", "battle_seq"))
		_sheet.save_png(out)
		print("battle sequence: %d frames -> %s" % [_frames, out])
		get_tree().quit()
