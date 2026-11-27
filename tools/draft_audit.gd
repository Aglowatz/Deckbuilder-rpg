extends SceneTree
## Nov 26 night (Part B): the draft balance audit's raw data (see tools/draft_audit_tool.gd for the flags). Headless:
##   Godot --headless --path . -s res://tools/draft_audit.gd -- --configs=open:beefcake,high:gourmand+necrocrat --drafts=6 --games=2


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var tool_script: GDScript = load("res://tools/draft_audit_tool.gd") as GDScript
	var ok: bool = bool((tool_script.new() as RefCounted).call("run"))
	quit(0 if ok else 1)
