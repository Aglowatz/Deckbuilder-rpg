extends Node
## Fixes Oct 27, Part 1: main scene for the gatekeeper card-pick probe: a level-6 Beefcake save in Crosspath, the probe on the root.


func _ready() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.pending_popups.clear()
	Session.pending_level_ups.clear()
	var probe: Node = (load((get_script() as Script).resource_path.get_base_dir().path_join("gatekeeper_pick_probe.gd")) as GDScript).new()
	probe.name = "GatekeeperPickProbe"
	probe.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(probe)
	probe.run.call_deferred()
	SceneManager.skip_loading_once = true
	SceneManager.go_to_town.call_deferred()
