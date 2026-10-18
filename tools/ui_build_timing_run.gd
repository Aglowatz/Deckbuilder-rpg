extends SceneTree
## Runs tools/ui_build_timing.gd once the autoloads exist.


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	await (load("res://tools/ui_build_timing.gd").new() as RefCounted).call("run", self)
	quit()
