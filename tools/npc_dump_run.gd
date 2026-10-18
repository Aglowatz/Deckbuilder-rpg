extends SceneTree
## Runs tools/npc_dump.gd once the autoloads exist.


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	(load("res://tools/npc_dump.gd").new() as RefCounted).call("run")
	quit()
