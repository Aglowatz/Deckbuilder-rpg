extends SceneTree
## Fixes Oct 27, Part 1: the gatekeeper card-pick probe against an EXPORTED debug pack - the stock Godot binary runs the pack
## (`--main-pack`) with this script from disk, like tools/release_smoke_exported.gd. The launcher (and the probe it adds) load a frame later,
## once the autoloads exist.
##   bash tools/run_gatekeeper_pick_exported.sh <pck> [mouse|key|pad]


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	await process_frame
	var launcher_path: String = (get_script() as Script).resource_path.get_base_dir().path_join("gatekeeper_pick_launcher.gd")
	var launcher: Node = (load(launcher_path) as GDScript).new() as Node
	launcher.name = "GatekeeperPickLauncher"
	root.add_child(launcher)
