extends SceneTree
## Runs tools/xp_budget.gd once the autoloads exist (the dungeon builder reads Session).


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	(load("res://tools/xp_budget.gd").new() as RefCounted).call("run")
	quit()
