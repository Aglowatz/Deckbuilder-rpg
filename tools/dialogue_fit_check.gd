extends SceneTree
## Oct 21 (ChatGPT dialogue pass): runs tools/dialogue_fit_measure.gd once the autoloads exist (DialogueBox needs Settings), for
## tools/apply_dialogue_pass.js. Quits after 60 s whatever happens.
##   Godot --headless --path . -s res://tools/dialogue_fit_check.gd


func _initialize() -> void:
	create_timer(60.0).timeout.connect(quit)
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	(load("res://tools/dialogue_fit_measure.gd").new() as RefCounted).call("run", root)
	quit()
