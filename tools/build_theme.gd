extends SceneTree
## Bakes UIStyle.theme() into res://ui/game_theme.tres. The project setting gui/theme/custom
## points at it so every Control (including those under CanvasLayers) gets the game's look.
##   Godot --headless --path . -s res://tools/build_theme.gd


func _initialize() -> void:
	var theme: Theme = UIStyle.theme()
	var error: Error = ResourceSaver.save(theme, "res://ui/game_theme.tres")
	print("theme saved: ", error_string(error))
	quit(0 if error == OK else 1)
