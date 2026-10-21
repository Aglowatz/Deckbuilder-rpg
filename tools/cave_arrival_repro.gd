extends SceneTree
## v0.4.2 hotfix: launcher for tools/cave_arrival_repro_body.gd. A `-s` script compiles before the autoloads exist, so the body is loaded a
## frame later (as tools/release_smoke_exported.gd does). Works with `--path .` (the project) and with `--main-pack <pck>` (an export).


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	await process_frame
	var body_path: String = (get_script() as Script).resource_path.get_base_dir().path_join("cave_arrival_repro_body.gd")
	var body: Node = (load(body_path) as GDScript).new() as Node
	body.name = "CaveArrivalRepro"
	root.add_child(body)
	# The game's own main scene (the title) is not used: the body starts a New Game itself.
