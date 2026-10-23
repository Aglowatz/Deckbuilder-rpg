extends SceneTree
## Overnight Oct 22, Part 1: launcher for `tools/reference_deck_audit_body.gd` (loaded once the autoloads exist): every card of the sim's
## reference-deck packages checked against what a player can really own at that level under the Oct 22 shops.
## Run: Godot --headless --path . -s res://tools/reference_deck_audit.gd [-- --out=res://x.md]


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	(load("res://tools/reference_deck_audit_body.gd").new() as RefCounted).call("run")
	quit()
