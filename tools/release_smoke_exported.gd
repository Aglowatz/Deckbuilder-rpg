extends SceneTree
## Daytime Oct 19 (v0.4.1): the release smoke run against the EXPORTED pack. Release templates ignore `--script`, so the stock Godot binary
## of the same version runs the exported .pck (`--main-pack`) with this script from disk - the game content is exactly what ships. A
## `-s` script compiles before the autoloads exist, so this launcher only loads the smoke body (release_smoke_exported_body.gd) a frame
## later, the way tools/run_balance_sim.gd loads its tool.
##   bash tools/run_release_smoke_exported.sh


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	await process_frame
	var body_path: String = (get_script() as Script).resource_path.get_base_dir().path_join("release_smoke_exported_body.gd")
	var body: Node = (load(body_path) as GDScript).new() as Node
	body.name = "ReleaseSmokeExported"
	root.add_child(body)
